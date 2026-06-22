-- ========================================================
-- GITHUB CLOUD OS ДЛЯ BOT M3 (ЕДИНЫЙ ФАЙЛ)
-- ========================================================

local current_screen = "MENU" -- MENU, DINO, SNAKE, TETRIS, SETTINGS
local menu_tab = 0            -- 0: Built-in, 1: Wi-Fi Games
local menu_select = 0
local need_redraw = true

-- Настройки консоли
local brightness = 200

-- Переменные Динозаврика
local dino_y, dino_vel, dino_jump = 156, 0, false
local obs_x, score = 320, 0

-- Переменные Змейки
local snake, sn_dir, apple = {}, {x=10, y=0}, {x=120, y=100}
local last_sn_time = 0

function init()
    current_screen = "MENU"
    menu_tab = 0
    menu_select = 0
    need_redraw = true
    
    -- Инициализируем змейку
    snake = {{x=60, y=100}, {x=50, y=100}, {x=40, y=100}}
end

-- --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---
function draw_menu_ui()
    clear()
    -- Рендерим вкладки верхнего меню
    local c_tab0 = (menu_tab == 0) and 0x07E0 or 0x2104
    local c_tab1 = (menu_tab == 1) and 0x07FF or 0x2104
    rect(10, 10, 145, 30, c_tab0)
    rect(165, 10, 145, 30, c_tab1)
    
    text("BUILT-IN GAMES", 25, 18, 2, (menu_tab == 0) and 0x0000 or 0xFFFF)
    text("WI-FI CLOUD", 195, 18, 2, (menu_tab == 1) and 0x0000 or 0xFFFF)
    line(0, 50, 320, 50, 0xFFFF)

    -- Рендерим контент вкладок
    if menu_tab == 0 then
        rect(20, 70, 280, 35, (menu_select == 0) and 0x07E0 or 0x18C3)
        text("1. RETRO SNAKE", 40, 80, 2, (menu_select == 0) and 0x0000 or 0xFFFF)

        rect(20, 115, 280, 35, (menu_select == 1) and 0x07E0 or 0x18C3)
        text("2. PERFECT TETRIS", 40, 125, 2, (menu_select == 1) and 0x0000 or 0xFFFF)
    else
        rect(20, 70, 280, 35, (menu_select == 0) and 0x07FF or 0x18C3)
        text("1. CLOUD DINO RUN", 40, 80, 2, (menu_select == 0) and 0x0000 or 0xFFFF)
    end

    -- Кнопка настроек внизу
    rect(20, 200, 280, 25, (menu_select == 2) and 0xF81F or 0x18C3)
    text("CONSOLE SYSTEM SETTINGS", 75, 206, 1, 0xFFFF)
end

-- --- ЛОГИКА ИГРЫ ЗМЕЙКА ---
function update_snake(jx, jy, click)
    if click then current_screen = "MENU" need_redraw = true return end
    
    if jx < 1000 and sn_dir.x == 0 then sn_dir = {x=-10, y=0} end
    if jx > 3000 and sn_dir.x == 0 then sn_dir = {x=10, y=0} end
    if jy < 1000 and sn_dir.y == 0 then sn_dir = {x=0, y=-10} end
    if jy > 3000 and sn_dir.y == 0 then sn_dir = {x=0, y=10} end

    clear()
    -- Рисуем яблоко
    rect(apple.x, apple.y, 8, 8, 0xF800)
    
    -- Двигаем тело змейки
    local next_x = snake[1].x + sn_dir.x
    local next_y = snake[1].y + sn_dir.y
    
    if next_x < 0 then next_x = 310 elseif next_x > 310 then next_x = 0 end
    if next_y < 0 then next_y = 230 elseif next_y > 230 then next_y = 0 end
    
    table.insert(snake, 1, {x=next_x, y=next_y})
    
    -- Проверка поедания яблока
    if math.abs(next_x - apple.x) < 10 and math.abs(next_y - apple.y) < 10 then
        apple.x = math.random(2, 30) * 10
        apple.y = math.random(2, 22) * 10
    else
        table.remove(snake)
    end

    -- Отрисовка змейки
    for i, segment in ipairs(snake) do
        rect(segment.x, segment.y, 9, 9, 0x07E0)
    end
end

-- --- ЛОГИКА ИГРЫ ДИНОЗАВРИК ---
function update_dino(jx, jy, click)
    if click then current_screen = "MENU" need_redraw = true return end
    clear()
    
    line(0, 180, 320, 180, 0xFFFF) -- Земля
    
    if jy < 1000 and not dino_jump then
        dino_vel = -12
        dino_jump = true
    end

    if dino_jump then
        dino_y = dino_y + dino_vel
        dino_vel = dino_vel + 0.8
        if dino_y >= 156 then
            dino_y = 156
            dino_jump = false
        end
    end

    obs_x = obs_x - 6
    if obs_x < -20 then
        obs_x = 320
        score = score + 1
    end

    rect(obs_x, 155, 15, 25, 0x07E0) -- Кактус
    dino(40, math.floor(dino_y), 0x07FF) -- Вызов динозаврика через C++ массив!
    
    text("SCORE: " .. score, 10, 10, 2, 0xFFFF)
end

-- --- ГЛАВНЫЙ ЦИКЛ ОПЕРАЦИОННОЙ СИСТЕМЫ LUA ---
function loop()
    local jx, jy, click = joy1() -- Считываем первый джойстик

    if current_screen == "MENU" then
        if need_redraw then draw_menu_ui() need_redraw = false end

        -- Навигация
        if jy < 1000 then
            if menu_select > 0 then menu_select = menu_select - 1 need_redraw = true end
            sys_delay(200)
        end
        if jy > 3000 then
            if menu_select < 2 then menu_select = menu_select + 1 need_redraw = true end
            sys_delay(200)
        end
        if jx < 1000 and menu_tab == 1 then menu_tab = 0 menu_select = 0 need_redraw = true sys_delay(250) end
        if jx > 3000 and menu_tab == 0 then menu_tab = 1 menu_select = 0 need_redraw = true sys_delay(250) end

        -- Клик выбора
        if click then
            sys_delay(250)
            if menu_tab == 0 then
                if menu_select == 0 then current_screen = "SNAKE" snake = {{x=60, y=100}, {x=50, y=100}} 
                elseif menu_select == 1 then current_screen = "TETRIS" end
            else
                if menu_select == 0 then current_screen = "DINO" obs_x = 320 score = 0 end
            end
        end

    elseif current_screen == "SNAKE" then
        update_snake(jx, jy, click)
        sys_delay(130)
    elseif current_screen == "DINO" then
        update_dino(jx, jy, click)
        sys_delay(30)
    elseif current_screen == "TETRIS" then
        clear()
        text("TETRIS LUA SYSTEM ACTIVE", 40, 100, 2, 0x07FF)
        text("Click stick to EXIT", 60, 140, 2, 0xFFFF)
        if click then current_screen = "MENU" need_redraw = true sys_delay(250) end
    end

    return true -- Продолжать работу системы
end

-- Имитация небольшой задержки для контроля скорости
function sys_delay(ms)
    local start = os.clock()
    while os.clock() - start < (ms / 1000) do end
end
