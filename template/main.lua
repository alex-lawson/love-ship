require 'util/util'
require 'util/assets'
require 'util/enum'
require 'util/vec2'
require 'util/rect'
require 'util/poly'
require 'util/math'
require 'util/camera'
require 'util/animation'
require 'util/tilemap'

-- for testing, switch to:
-- require 'example/example_game'
require 'game'

function love.load()
    GuiFont = love.graphics.newFont("fonts/cour.ttf", 16)
    love.graphics.setFont(GuiFont)

    love.graphics.setDefaultFilter("nearest")

    MainCamera = Camera()

    GameInstance = Game()
end

function love.update(dt)
    GameInstance:update(dt)
end

function love.draw()
    MainCamera:do_transform()

    GameInstance:render()
end

function love.mousepressed(x, y, button)
    GameInstance:mouse_pressed(MainCamera:screen_to_world(vec2(x, y)), button)
end

function love.mousereleased(x, y, button)
    GameInstance:mouse_released(MainCamera:screen_to_world(vec2(x, y)), button)
end

function love.wheelmoved(x, y)
    GameInstance:mouse_wheel_moved(x, y)
end

function love.keypressed(key)
    GameInstance:key_pressed(key)
end

function love.keyreleased(key)
    GameInstance:key_released(key)
end

function love.focus(f)

end

function love.quit()

end
