Input = {}

function NewInput(keys)
    return {
        keys = keys,
        pressed = false,
        released = false,
        down = false,
        up = true,
    }
end

local function updateAction(action, isDown)
    local down = isDown()
    local up = not down
    action.pressed = down and not action.down
    action.released = up and not action.up
    action.down = down
    action.up = up
end

function UpdateInputs()
    for _, action in pairs(Input) do
        if action.keys then
            updateAction(action, function()
                for _, key in ipairs(action.keys) do
                    if love.keyboard.isDown(key) then return true end
                end
                return false
            end)
        end
    end

    for i = 1, 3 do
        updateAction(Input.mb[i], function()
            return love.mouse.isDown(i)
        end)
    end
end

function love.wheelmoved(dx, dy)
    Input.wheel.up = dy > 0
    Input.wheel.down = dy < 0
end

function ResetWheelInput()
    Input.wheel.up = false
    Input.wheel.down = false
end

Input.mb = {NewInput(), NewInput(), NewInput()}
Input.wheel = NewInput()