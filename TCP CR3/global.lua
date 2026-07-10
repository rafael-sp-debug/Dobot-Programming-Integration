-- global.lua

SERVER_IP = "192.168.1.6" -- Dirección IP del controlador dentro de la red local.
SERVER_PORT = 6001 -- Puerto TCP en el que el robot esperara la conexión del cliente.

-- Alias de puntos enseñados
--
-- P1 = punto seguro / home
-- P2 = aproximación al stack de origen
-- P3 = punto exacto de agarre de la pieza superior
-- P4 = aproximación al stack de destino
-- P5 = punto exacto de colocación
-- P6 = pose final después de colocar la última pieza
-- P7 = punto 1 para saludo
-- P8 = punto 2 para saludo

P_HOME = P1
P_SAFE = P1

P_PICK_APPROACH = P2
P_PICK = P3

P_PLACE_APPROACH = P4
P_PLACE = P5

P_FINAL = P6

P_WAVE_1 = P7
P_WAVE_2 = P8


P_CAPY_1 = P9
P_CAPY_2 = P10
P_CAPY_3 = P11
P_CAPY_4 = P12



-- Conversión de buffers TCP a texto legible.
-- Esta función convierte una tabla indexada de forma lineal
-- por ejemplo {72, 79, 77, 69}, en texto ASCII "HOME".
--
-- Se usa cuando el buffer recibido desde TCPRead no llega
-- como string directo, sino como una secuencia lineal de bytes
-- o de fragmentos de texto.
--
-- Reglas:
-- 1. Si un elemento es numerico y esta entre 0 y 255,
--    se interpreta como un byte ASCII.
-- 2. Si un elemento ya es string, se concatena tal cual.
-- 3. Si un elemento es otra tabla, se procesa de manera recursiva
--    usando buffer_a_texto(), porque puede contener otra estructura valida.
--
-- En otras palabras:
-- tabla_lineal_a_texto() sirve para reconstruir texto cuando
-- el buffer viene como una lista ordenada de elementos.
function tabla_lineal_a_texto(t)
    local s = ""
    local i = 1

    while t[i] ~= nil do
        local v = t[i]

        if type(v) == "number" then
            if v >= 0 and v <= 255 then
                s = s .. string.char(v)
            end
        elseif type(v) == "string" then
            s = s .. v
        elseif type(v) == "table" then
            s = s .. buffer_a_texto(v)
        end

        i = i + 1
    end

    return s
end

-- Esta función normaliza cualquier dato recibido desde TCPRead
-- y trata de convertirlo a texto util.
--
-- Existe porque en este entorno Lua embebido el buffer recibido
-- por TCPRead no siempre llega en un formato unico y predecible.
-- En pruebas realizadas, puede aparecer como:
-- - string
-- - number
-- - table lineal
-- - table anidada con campos como value o buf
--
-- Estrategia de trabajo:
-- 1 Si el dato ya es string, se devuelve tal cual.
-- 2 Si es un numero entre 0 y 255, se interpreta como ASCII.
-- 3 Si no es tabla, se convierte con tostring().
-- 4 Si es una tabla con campos comunes de buffer embebido
--   como value o buf, se extrae ese contenido y se procesa recursivamente.
-- 5 Si es una tabla lineal, se intenta reconstruir el texto
--   con tabla_lineal_a_texto().
-- 6 Como ultimo recurso, se recorren todos los subcampos
--   buscando cualquier fragmento de texto valido.
--
-- En resumen:
-- buffer_a_texto() es la rutina general de desempaque
-- y conversion de buffers TCP a texto interpretable.
--
-- Gracias a esta funcion, el resto del programa puede trabajar
-- de forma uniforme con comandos como PING, HOME o SALIR,
-- sin importar como haya llegado realmente el buffer desde TCPRead.
function buffer_a_texto(data)
    if data == nil then
        return ""
    end

    -- Caso mas simple: el buffer ya llega como texto.
    if type(data) == "string" then
        return data
    end

    -- Si llega como numero, intentar interpretarlo como byte ASCII.
    if type(data) == "number" then
        if data >= 0 and data <= 255 then
            return string.char(data)
        else
            return tostring(data)
        end
    end

    -- Si no es tabla, devolver una representacion generica.
    if type(data) ~= "table" then
        return tostring(data)
    end

    -- Algunos entornos o APIs embebidas encapsulan el contenido
    -- util dentro de campos como value o buf.
    -- Si existen, procesamos directamente ese subcampo.
    if data.value ~= nil then
        return buffer_a_texto(data.value)
    end

    if data.buf ~= nil then
        return buffer_a_texto(data.buf)
    end

    -- Si la tabla parece una secuencia lineal de bytes o strings,
    -- intentar reconstruir texto directamente.
    local s = tabla_lineal_a_texto(data)

    if s ~= "" then
        return s
    end

    -- Ultimo recurso:
    -- recorrer cualquier subcampo buscando contenido interpretable.
    for k, v in pairs(data) do
        local parcial = buffer_a_texto(v)

        if parcial ~= "" then
            return parcial
        end
    end

    -- Si nada produjo texto util, regresar cadena vacia.
    return ""
end

-- Limpia el comando recibido para dejarlo en formato uniforme.
function limpiar_cmd(txt)
    txt = buffer_a_texto(txt)

    txt = string.gsub(txt, "\r", "") -- elimina retorno de carro
    txt = string.gsub(txt, "\n", "") -- elimina salto de linea
    txt = string.match(txt, "^%s*(.-)%s*$") -- quita espacios al inicio y al final

    if txt == nil then
        txt = ""
    end

    txt = string.upper(txt) -- cambia el texto a mayusculas

    return txt
end
