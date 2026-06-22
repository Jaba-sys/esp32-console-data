-- ========================================================
-- WI-FI ИГРА: 3D ТУННЕЛЬ НА LUA (ПСЕВДО-3D RAYCASTING)
-- ========================================================
local time = 0
local speed = 0.15
local player_x = 0

function init()
    time = 0
    player_x = 0
    clear_screen()
end

function loop()
    clear_screen()
    time = time + speed
    
    -- Считываем управление влево/вправо
    if joystick_up() then player_x = player_x - 0.2 end -- условно джойстик 1
    if joystick_down() then player_x = player_x + 0.2 end
    
    -- Рисуем псевдо-3D туннель линиями из центра
    local cx, cy = 160, 120
    for i = 1, 8 do
        local r = (i * 20 - (time * 20) % 20)
        if r > 0 then
            local offset = player_x * (150 - r) / 10
            draw_rect(cx - r + offset, cy - r, r * 2, r * 2, 0x07FF)
        end
    end
    
    draw_text("3D TUNNEL RUNNER", 85, 10, 2, 0xFFFF)
    return true
end
