require 'util/util'
require 'util/assets'
require 'util/enum'
require 'util/vec2'
require 'util/rect'
require 'util/poly'
require 'util/math'
require 'util/camera'
require 'util/animation'
require 'util/fps_counter'

require 'game'

function love.load()
    love.graphics.setDefaultFilter("nearest")

    MainCamera = Camera()

    GameInstance = Game()

    Fps = FpsCounter()
    Fps.enabled = false
end

function love.update(dt)
    GameInstance:update(dt)

    Fps:update(dt)
end

function love.draw()
    love.graphics.push()

    MainCamera:do_transform()

    GameInstance:render()

    love.graphics.pop()

    Fps:render()
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
    if key == "f1" then
        Fps.enabled = not Fps.enabled
    end

    GameInstance:key_pressed(key)
end

function love.keyreleased(key)
    GameInstance:key_released(key)
end

function love.focus(f)

end

function love.quit()

end
