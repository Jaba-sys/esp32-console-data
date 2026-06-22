-- ИГРА ДИНОЗАВРИК НА LUA (Загружается с GitHub)

local dino_y = 156
local velocity = 0
local is_jumping = false
local score = 0
local obs_x = 320
local bush_x = 220

-- Функция инициализации (вызывается 1 раз при старте)
function init()
    dino_y = 156
    velocity = 0
    score = 0
    obs_x = 320
    bush_x = 220
    clear_screen()
    draw_line(0, 180, 320, 180, 0xFFFF) -- Белая земля
end

-- Основной игровой цикл (вызывается многократно)
function loop()
    -- Очищаем старые пиксели (рисуем черные квадраты поверх старых позиций)
    draw_rect(40, dino_y, 24, 24, 0x0000)
    draw_rect(obs_x, 155, 16, 25, 0x0000)
    draw_rect(bush_x, 172, 16, 8, 0x0000)

    -- Чтение джойстика через C++ функции
    if joystick_up() and not is_jumping then
        velocity = -14
        is_jumping = true
    end

    -- Физика прыжка
    if is_jumping then
        dino_y = dino_y + velocity
        velocity = velocity + 0.8
        if dino_y >= 156 then
            dino_y = 156
            is_jumping = false
            velocity = 0
        end
    end

    -- Движение декораций и кактусов
    bush_x = bush_x - 3
    if bush_x < -20 then bush_x = 340 end

    obs_x = obs_x - 6
    if obs_x < -20 then
        obs_x = 320
        score = score + 1
    end

    -- Проверка столкновения (Хитбокс)
    if obs_x > 22 and obs_x < 60 and (dino_y + 24) > 155 then
        game_over_screen()
        return false -- Остановить игру
    end

    -- Отрисовка кадра
    draw_rect(bush_x, 172, 16, 8, 0x03E0) -- Зеленый кустик
    draw_cactus(obs_x, 155, 16, 25)       -- Красивый кактус
    draw_dino(40, dino_y)                 -- Наш бирюзовый дино

    print_score(score)
    return true -- Продолжать игру
end
