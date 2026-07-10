-- Version Lua 5.3.5
-- CR3 - Traslado de 3 piezas cúbicas con gripper
-- Cada pieza mide 70 mm de alto
-- P1 = punto seguro (home)
-- P2 = aproximación al stack de origen
-- P3 = punto exacto de agarre de la pieza superior
-- P4 = aproximación al stack de destino
-- P5 = punto exacto de colocación
-- P6 = pose final después de colocar la última pieza (evitar singularidad)

DhInit(115200,1)
Speed(100)
Sync()

local altura_pieza = 70
local num_piezas = 3
local tiempo_gripper = math.ceil(1 * 1000)

-- Referencias iniciales
local toma_actual = P3
local aprox_entrega_actual = P4
local entrega_actual = P5

-- Gripper
function gripper_open()
    DhOpen(0,1)
    Sleep(tiempo_gripper)
end

function gripper_close()
    DhClose(0,1)
    Sleep(tiempo_gripper)
end

-- Pick and place
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
        Move(P6)
        Sync()
    else
        Move(p_aprox_entrega_actual)
        Sync()

        MoveJ(p_seguro)
        Sync()
    end
end

-- Abrir gripper al inicio
gripper_open()

-- Ciclo principal
for nivel = 0, num_piezas - 1 do

    local es_ultima = (nivel == num_piezas - 1)

    pick_and_place(P1, P2, toma_actual, aprox_entrega_actual, entrega_actual, es_ultima)

    -- Solo actualizar si no fue la última pieza
    if not es_ultima then
        -- Origen: la siguiente pieza está 70 mm más abajo
        toma_actual = RP(toma_actual, {0, 0, -altura_pieza, 0})

        -- Destino: la siguiente pieza queda 70 mm más arriba
        aprox_entrega_actual = RP(aprox_entrega_actual, {0, 0, altura_pieza, 0})
        entrega_actual = RP(entrega_actual, {0, 0, altura_pieza, 0})
    end
end

-- Retornar a Home y dejar gripper abierto al terminar para reiniciar
Go(P1)
gripper_open()
