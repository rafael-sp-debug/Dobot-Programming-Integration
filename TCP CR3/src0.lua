-- Version: Lua 5.3.5
-- Script principal de ejecucion
--
-- Responsabilidades:
-- 1 Inicializar parametros de movimiento y gripper.
-- 2 Crear y mantener el servidor TCP.
-- 3 Recibir comandos remotos desde la computadora.
-- 4 Ejecutar rutinas con movimiento del robot.
-- 5 Cerrar la sesion y regresar el robot a estado seguro.

Accel(40) -- Ajusta la aceleración de movimientos tipo Go, Jump o MoveJ.
Speed(40) -- Ajusta la velocidad de movimientos tipo Go, MoveJ, GoR o MoveJR.
SpeedS(30) -- Ajusta la velocidad para movimientos lineales como Move, Jump, Arc3 o Circle3.

DhInit() -- Inicializa el gripper.
DhOpen() -- Abre el gripper al inicio para dejar el efector en un estado conocido.
Sleep(500) -- Espera breve para asegurar que la apertura del gripper termine antes de seguir.

-- Bandera principal del ciclo de recepcion.
local ejecutando = true

-- Identificador del socket TCP creado por TCPCreate().
local socket = 0

-- Variable general para capturar codigos de error de la API.
local err = 0

-- Parametros de la rutina pick and place.
local altura_pieza = 70
local num_piezas = 3
local tiempo_gripper = math.ceil(1 * 1000)

-- Mueve el robot al punto seguro definido en global.lua.
function ir_seguro()
    Go(P_SAFE)
end

-- Lleva el robot al punto HOME.
function rutina_home()
    Go(P_HOME)
end

-- Rutina simple de saludo usando dos puntos alternados.
function rutina_saludo()
    Go(P_SAFE)
    Go(P_WAVE_1)
    Go(P_WAVE_2)
    Go(P_WAVE_1)
    Go(P_WAVE_2)
    Go(P_SAFE)
end
function capy()
    gripper_open()
    Go(P_CAPY_1)
    Go(P_CAPY_2)
    gripper_close()
    Go(P_CAPY_3)
    Go(P_CAPY_4)
    gripper_open()
end
-- Apertura del gripper con espera.
function gripper_open()
    DhOpen()
    Sleep(tiempo_gripper)
end

-- Cierre del gripper con espera.
function gripper_close()
    DhClose()
    Sleep(tiempo_gripper)
end

-- Rutina elemental de traslado de una pieza.
function pick_and_place(p_seguro, p_aprox_origen, p_toma_actual, p_aprox_entrega_actual, p_entrega_actual, es_ultima)

    -- PICK
    MoveJ(p_seguro)
    Sync()

    gripper_open()
    Sync()

    MoveJ(p_aprox_origen)
    Sync()

    Move(p_toma_actual)
    Sync()

    gripper_close()
    Sync()

    Move(p_aprox_origen)
    Sync()

    MoveJ(p_seguro)
    Sync()

    -- PLACE
    MoveJ(p_aprox_entrega_actual)
    Sync()

    Move(p_entrega_actual)
    Sync()

    gripper_open()
    Sync()

    if es_ultima then
        -- Despues de colocar la ultima pieza, ir a la pose final definida.
        MoveJ(P_FINAL)
        Sync()
    else
        Move(p_aprox_entrega_actual)
        Sync()

        MoveJ(p_seguro)
        Sync()
    end
end

-- Rutina completa de traslado de piezas.
function rutina_pick_and_place()

    -- Referencias iniciales.
    local toma_actual = P_PICK
    local aprox_entrega_actual = P_PLACE_APPROACH
    local entrega_actual = P_PLACE

    gripper_open()
    Sync()

    for nivel = 0, num_piezas - 1 do

        local es_ultima = (nivel == num_piezas - 1)

        pick_and_place(
            P_SAFE,
            P_PICK_APPROACH,
            toma_actual,
            aprox_entrega_actual,
            entrega_actual,
            es_ultima
        )

        -- Solo actualizar si no fue la ultima pieza.
        if not es_ultima then
            -- Origen: la siguiente pieza esta 70 mm mas abajo.
            toma_actual = RP(toma_actual, {0, 0, -altura_pieza, 0})

            -- Destino: la siguiente pieza queda 70 mm mas arriba.
            aprox_entrega_actual = RP(aprox_entrega_actual, {0, 0, altura_pieza, 0})
            entrega_actual = RP(entrega_actual, {0, 0, altura_pieza, 0})
        end
    end
end

-- Envia una respuesta textual al cliente TCP.
-- Se usa para confirmar ejecucion, errores o cierre de sesion.
function responder(msg)
    local werr = TCPWrite(socket, msg, 1)
    if werr ~= 0 then
        print("TCPWrite error: " .. tostring(werr))
    end
end

-- Despacha el comando ya normalizado y ejecuta la rutina correspondiente.
-- Los comandos llegan ya convertidos a mayusculas por limpiar_cmd().
function ejecutar_comando(cmd)
    if cmd == "PING" then
        responder("PONG\n")

    elseif cmd == "HOME" then
        rutina_home()
        responder("EJECUTADO: HOME\n")

    elseif cmd == "SEGURIDAD" then
        ir_seguro()
        responder("EJECUTADO: SEGURIDAD\n")

    elseif cmd == "ABRIR" then
        DhOpen()
        Sleep(500)
        responder("EJECUTADO: ABRIR\n")

    elseif cmd == "CERRAR" then
        DhClose()
        Sleep(500)
        responder("EJECUTADO: CERRAR\n")

    elseif cmd == "SALUDO" then
        rutina_saludo()
        responder("EJECUTADO: SALUDO\n")

    elseif cmd == "DEMO" then
        rutina_pick_and_place()
        responder("EJECUTADO: DEMO\n")
        

    elseif cmd == "CAPY" then
        capy()
        responder("EJECUTADO: CAPY\n")

    elseif cmd == "SALIR" then
        -- Cierra la sesion TCP y provoca salida ordenada del ciclo principal.
        responder("BYE\n")
        ejecutando = false

    else
        responder("ERROR: COMANDO_DESCONOCIDO\n")
    end
end

-- Inicializacion del servidor TCP.
print("Creando servidor TCP...")
err, socket = TCPCreate(true, SERVER_IP, SERVER_PORT)

if err ~= 0 then
    print("TCPCreate fallo: " .. tostring(err))
else
    print("Esperando cliente...")

    -- Timeout 0: espera bloqueante hasta que se conecte un cliente.
    err = TCPStart(socket, 0)

    if err ~= 0 then
        print("TCPStart fallo: " .. tostring(err))
        TCPDestroy(socket)
    else
        print("Cliente conectado")

        -- Mensaje inicial para que el cliente sepa que el servidor ya esta listo.
        responder("SERVIDOR TCP DOBOT LISTO\n")

        -- Bucle principal de recepcion de comandos.
        -- TCPRead() puede devolver una estructura que no es string directo.
        -- Por eso el valor recibido siempre se procesa con limpiar_cmd(),
        -- funcion definida en global.lua.
        while ejecutando do
            local rec
            err, rec = TCPRead(socket, 0, "string")

            if err == 0 then
                local cmd = limpiar_cmd(rec)

                -- print("Comando interpretado: [" .. cmd .. "]")

                if cmd ~= "" then
                    ejecutar_comando(cmd)
                else
                    responder("ERROR: COMANDO_VACIO\n")
                end
            else
                print("TCPRead fallo: " .. tostring(err))
                break
            end
        end

        -- Cierre formal del socket al salir del bucle principal.
        local derr = TCPDestroy(socket)
        print("TCPDestroy: " .. tostring(derr))
    end
end

-- Estado final seguro del robot al terminar el script:
-- regresar a punto seguro y dejar el gripper abierto.
Go(P_SAFE)
DhOpen()
