-- ========================================================
-- ДИНОЗАВРИК НА LUA: ФИНАЛЬНАЯ ВЕРСИЯ С РЕАЛИСТИЧНЫМ СПРАЙТОМ
-- ========================================================

local dino_y = 156
local velocity = 0
local is_jumping = false
local is_ducking = false
local dino_height = 24
local score = 0

-- Препятствия
local obs_x = 320
local obs_y = 155
local obs_w = 16
local obs_h = 25
local obs_type = 0
local spawn_delay = 0

-- Декорации фона (Параллакс для реализма)
local bush_x = 220
local cloud_x = 120

function init()
    dino_y = 156
    velocity = 0
    is_jumping = false
    is_ducking = false
    dino_height = 24
    score = 0
    obs_x = 320
    obs_y = 155
    obs_w = 16
    obs_h = 25
    obs_type = 0
    spawn_delay = 0
    bush_x = 220
    cloud_x = 120
    
    clear_screen()
    draw_line(0, 180, 320, 180, 0xFFFF) -- Белая линия земли
end

function loop()
    -- 1. СТИРАЕМ СТАРЫЕ КАДРЫ
    -- Вместо квадрата стираем точно ту область, где был динозаврик
    draw_rect(40, dino_y, 24, 24, 0x0000)
    draw_rect(obs_x, obs_y, obs_w + 4, obs_h, 0x0000)
    draw_rect(bush_x, 172, 16, 8, 0x0000)
    draw_rect(cloud_x, 40, 24, 10, 0x0000)

    -- 2. УПРАВЛЕНИЕ ДЖОЙСТИКАМИ
    if joystick_up() and not is_jumping and not is_ducking then
        velocity = -14
        is_jumping = true
    end

    if joystick_down() and not is_jumping then
        if not is_ducking then
            is_ducking = true
            dino_height = 12
            dino_y = 168 -- Приседаем к земле
        end
    else
        if is_ducking then
            is_ducking = false
            dino_height = 24
            dino_y = 156 -- Встаем в полный рост
        end
    end

    -- 3. ФИЗИКА
    if is_jumping then
        dino_y = dino_y + velocity
        velocity = velocity + 0.8
        if dino_y >= 156 then
            dino_y = 156
            is_jumping = false
            velocity = 0
        end
    end

    -- Движение окружения
    cloud_x = cloud_x - 1
    if cloud_x < -30 then cloud_x = 350 end

    bush_x = bush_x - 3
    if bush_x < -20 then bush_x = 340 end

    obs_x = obs_x - 7
    if obs_x < -30 then
        spawn_delay = spawn_delay + 1
        if spawn_delay > 15 then
            obs_x = 320
            score = score + 1
            spawn_delay = 0
            
            -- Рандомим барьеры (Птеродактиль летит высоко на весь экран, под него надо приседать!)
            if math.random(1, 100) > 55 then
                obs_type = 1 
                obs_y = 110
                obs_w = 20
                obs_h = 45 
            else
                obs_type = 0 -- Красивый ветвистый кактус
                obs_y = 155
                obs_w = 16
                obs_h = 25
            end
        end
    end

    -- 4. ПРОВЕРКА СТОЛКНОВЕНИЙ
    if obs_x > 22 and obs_x < 60 then
        if (dino_y + dino_height) > obs_y and dino_y < (obs_y + obs_h) then
            draw_text("GAME OVER", 110, 100, 4, 0xF800)
            return false 
        end
    end

    -- 5. ОТРИСОВКА РЕАЛИСТИЧНОЙ ГРАФИКИ
    draw_line(0, 180, 320, 180, 0xFFFF) -- Земля
    draw_rect(cloud_x, 40, 24, 10, 0x7BEF) -- Облако в небе
    draw_rect(bush_x, 172, 16, 8, 0x0400)  -- Реалистичный кустик

    -- Отрисовка препятствий
    if obs_x < 320 then
        if obs_type == 0 then
            draw_cactus(obs_x, obs_y, obs_w, obs_h) -- Прорисованный кактус из C++
        else
            draw_rect(obs_x, obs_y, obs_w, obs_h, 0xF81F) -- Птеродактиль-барьер
        end
    end

    -- РЕАЛИСТИЧНЫЙ ДИНОЗАВРИК
    if is_ducking then
        -- Когда приседает, рисуем его уменьшенным бирюзовым спрайтом
        draw_rect(40, dino_y, 24, 12, 0x07FF) 
    else
        -- КОМАНДА НА ОТРИСОВКУ МАССИВА: Вызывает тот самый массив 24x24 из памяти ESP32
        draw_dino_bitmap(40, math.floor(dino_y)) 
    end

    draw_text("SCORE: " .. score, 130, 10, 2, 0xFFFF)
    return true 
end
