require 'util/util'
require 'util/enum'
require 'util/vec2'
require 'util/rect'
require 'util/poly'
require 'util/math'
require 'util/camera'
require 'game'

function love.load()
    GuiFont = love.graphics.newFont("fonts/cour.ttf", 16)
    love.graphics.setFont(GuiFont)

    love.graphics.setDefaultFilter("nearest")

    MainCamera = Camera()

    Game = MyGame()
end

function love.update(dt)
    Game:update(dt)
end

function love.draw()
    MainCamera:do_transform()

    Game:render()
end

function love.mousepressed(x, y, button)
    Game:mouse_pressed(MainCamera:screen_to_world(vec2(x, y)), button)
end

function love.mousereleased(x, y, button)
    Game:mouse_released(MainCamera:screen_to_world(vec2(x, y)), button)
end

function love.keypressed(key)
    Game:key_pressed(key)
end

function love.keyreleased(key)
    Game:key_released(key)
end

function love.focus(f)

end

function love.quit()

end
