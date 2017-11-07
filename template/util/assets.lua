local loaded_images = {}

function load_image(image_path)
    if not loaded_images[image_path] then
        loaded_images[image_path] = love.graphics.newImage(image_path)
    end

    return loaded_images[image_path]
end