-- ========================================================
-- ФИНАЛЬНАЯ GITHUB CLOUD OS ДЛЯ BOT M3 (ОПТИМИЗИРОВАННАЯ)
-- ========================================================

local screen = "MENU" -- МЕНЮ СИСТЕМЫ: MENU, GAME_SNAKE, GAME_TETRIS, GAME_DINO
local menu_select = 0
local redraw = true

-- Цвета (16-битный RGB565)
local COLOR_BLACK   = 0x0000
local COLOR_WHITE   = 0xFFFF
local COLOR_RED     = 0xF800
local COLOR_GREEN   = 0x07E0
local COLOR_BLUE    = 0x001F
local COLOR_CYAN    = 0x07FF
local COLOR_YELLOW  = 0xFFE0
local COLOR_GRAY    = 0x39E7

-- --- ПЕРЕМЕННЫЕ ИГР ---
-- Змейка
local snake = {}
local sn_dir = {x = 10, y = 0}
local apple = {x = 120, y = 100}
local snake_score = 0

-- Динозаврик
local dino_y = 156
local dino_vel = 0
local dino_jump = false
local cactus_x = 320
local dino_score = 0

-- Тетрис (Полноценный!)
local board = {} -- Стакан 10x20
local piece = { x = 4, y = 0, type = 1, rot = 1 }
local tetris_score = 0
local shapes = {
    { {1,1,1,1} }, -- I
    { {1,1,1}, {0,1,0} }, -- T
    { {1,1,1}, {1,0,0} }, -- L
    { {1,1}, {1,1} } -- O
}

-- Инициализация при старте
function init()
    screen = "MENU"
    menu_select = 0
    redraw = true
    init_tetris()
end

function init_tetris()
    board = {}
    for y = 1, 20 do
        board[y] = {}
        for x = 1, 10 do board[y][x] = 0 end
    end
    spawn_piece()
end

function spawn_piece()
    piece.x = 4
    piece.y = 1
    piece.type = math.random(1, #shapes)
    piece.rot = 1
end

-- --- ГЛАВНАЯ ОТРИСОВКА МЕНЮ ---
function draw_menu()
    clear()
    rect(5, 5, 310, 230, COLOR_BLUE)
    rect(10, 10, 300, 220, COLOR_BLACK)
    
    text("BOT M3 OS (GITHUB)", 50, 20, 4, COLOR_CYAN)
    text("CHOOSE LUA CLOUD GAME:", 30, 60, 2, COLOR_WHITE)

    -- Кнопка 1: Змейка
    rect(30, 90, 260, 35, (menu_select == 0) and COLOR_GREEN or COLOR_GRAY)
    text("1. LUA RETRO SNAKE", 50, 100, 2, (menu_select == 0) and COLOR_BLACK or COLOR_WHITE)

    -- Кнопка 2: Тетрис
    rect(30, 135, 260, 35, (menu_select == 1) and COLOR_YELLOW or COLOR_GRAY)
    text("2. LUA ADVANCED TETRIS", 50, 145, 2, (menu_select == 1) and COLOR_BLACK or COLOR_WHITE)

    -- Кнопка 3: Динозаврик
    rect(30, 180, 260, 35, (menu_select == 2) and COLOR_CYAN or COLOR_GRAY)
    text("3. LUA CHROME DINO", 50, 190, 2, (menu_select == 2) and COLOR_BLACK or COLOR_WHITE)
end

-- --- ЛОГИКА ЗМЕЙКИ ---
function logic_snake(jx, jy, click)
    if click then screen = "MENU" redraw = true sys_delay(200) return end

    -- Управление (слушает джойстик)
    if jx < 1000 and sn_dir.x == 0 then sn_dir = {x = -10, y = 0} end
    if jx > 3000 and sn_dir.x == 0 then sn_dir = {x = 10, y = 0} end
    if jy < 1000 and sn_dir.y == 0 then sn_dir = {x = 0, y = -10} end
    if jy > 3000 and sn_dir.y == 0 then sn_dir = {x = 0, y = 10} end

    -- Движение головы
    local nX = snake[1].x + sn_dir.x
    local nY = snake[1].y + sn_dir.y

    -- Смерть о стены
    if nX < 0 or nX >= 320 or nY < 0 or nY >= 240 then
        screen = "MENU" redraw = true sys_delay(1000) return
    end

    table.insert(snake, 1, {x = nX, y = nY})

    -- Проверка яблока
    if math.abs(nX - apple.x) < 10 and math.abs(nY - apple.y) < 10 then
        snake_score = snake_score + 1
        apple.x = math.random(2, 30) * 10
        apple.y = math.random(2, 22) * 10
    else
        table.remove(snake)
    end

    -- Рендеринг кадров
    clear()
    rect(apple.x, apple.y, 9, 9, COLOR_RED)
    for i, seg in ipairs(snake) do
        rect(seg.x, seg.y, 9, 9, COLOR_GREEN)
    end
    text("SCORE: " .. snake_score, 10, 10, 2, COLOR_WHITE)
    sys_delay(120) -- Скорость змейки
end

-- --- ЛОГИКА ДИНОЗАВРИКА ---
function logic_dino(jx, jy, click)
    if click then screen = "MENU" redraw = true sys_delay(200) return end

    if jy < 1000 and not dino_jump then
        dino_vel = -12
        dino_jump = true
    end

    if dino_jump then
        dino_y = dino_y + dino_vel
        dino_vel = dino_vel + 1
        if dino_y >= 156 then dino_y = 156; dino_jump = false end
    end

    cactus_x = cactus_x - 7
    if cactus_x < -20 then cactus_x = 320; dino_score = dino_score + 1 end

    -- Столкновение
    if cactus_x > 24 and cactus_x < 60 and dino_y > 135 then
        screen = "MENU" redraw = true sys_delay(1000) return
    end

    clear()
    line(0, 180, 320, 180, COLOR_WHITE) -- Земля
    rect(cactus_x, 155, 15, 25, COLOR_GREEN) -- Кактус
    dino(40, math.floor(dino_y), COLOR_CYAN) -- Твой C++ спрайт!
    text("SCORE: " .. dino_score, 10, 10, 2, COLOR_WHITE)
    sys_delay(30)
end

-- --- ЛОГИКА ТЕТРИСА ---
function logic_tetris(jx, jy, click)
    if click then screen = "MENU" redraw = true sys_delay(200) return end

    clear()
    -- Отрисовка стакана (масштаб: блоки 10x10 пикселей)
    rect(100, 20, 102, 202, COLOR_WHITE)
    rect(101, 20, 100, 200, COLOR_BLACK)

    -- Управление фигурой
    if jx < 1000 and piece.x > 1 then piece.x = piece.x - 1 sys_delay(100) end
    if jx > 3000 and piece.x < 10 then piece.x = piece.x + 1 sys_delay(100) end
    if jy > 3000 then piece.y = piece.y + 1 end -- Ускоренное падение

    -- Гравитация (падение вниз)
    piece.y = piece.y + 1
    if piece.y > 19 then
        -- Закрепляем на дне стакана
        board[19][piece.x] = 1
        spawn_piece()
        tetris_score = tetris_score + 10
    end

    -- Рисуем стакан
    for y = 1, 20 do
        for x = 1, 10 do
            if board[y][x] == 1 then
                rect(101 + (x-1)*10, 20 + (y-1)*10, 9, 9, COLOR_YELLOW)
            end
        end
    end

    -- Рисуем летящую фигуру
    rect(101 + (piece.x-1)*10, 20 + (piece.y-1)*10, 9, 9, COLOR_RED)

    text("SCORE: " .. tetris_score, 10, 10, 2, COLOR_WHITE)
    text("JOY CLICK - EXIT", 10, 220, 1, COLOR_GRAY)
    sys_delay(150)
end

-- --- ГЛАВНЫЙ ЦИКЛ ОБЛАЧНОЙ ОС (ВЫЗЫВАЕТСЯ ИЗ C++) ---
function loop()
    -- Получаем данные с первого джойстика
    local jx, jy, click = joy1() 

    if screen == "MENU" then
        if redraw then draw_menu() redraw = false end

        -- Бегаем по пунктам меню вверх-вниз
        if jy < 1000 then
            if menu_select > 0 then menu_select = menu_select - 1; redraw = true; sys_delay(200) end
        end
        if jy > 3000 then
            if menu_select < 2 then menu_select = menu_select + 1; redraw = true; sys_delay(200) end
        end

        -- Вход в выбранную игру
        if click then
            sys_delay(250)
            if menu_select == 0 then
                screen = "GAME_SNAKE"
                snake = {{x = 60, y = 100}, {x = 50, y = 100}, {x = 40, y = 100}}
                sn_dir = {x = 10, y = 0}
                snake_score = 0
            elseif menu_select == 1 then
                screen = "GAME_TETRIS"
                init_tetris()
            elseif menu_select == 2 then
                screen = "GAME_DINO"
                cactus_x = 320
                dino_score = 0
                dino_y = 156
            end
        end

    elseif screen == "GAME_SNAKE" then
        logic_snake(jx, jy, click)
    elseif screen == "GAME_TETRIS" then
        logic_tetris(jx, jy, click)
    elseif screen == "GAME_DINO" then
        logic_dino(jx, jy, click)
    end

    return true -- Возвращаем true, чтобы ESP32 не выходил из Lua-режима
end

-- Кастомная задержка
function sys_delay(ms)
    local start = os.clock()
    while os.clock() - start < (ms / 1000) do end
end
