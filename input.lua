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

local function update_action(action, isDown)
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
            update_action(action, function()
                for _, key in ipairs(action.keys) do
                    if love.keyboard.isDown(key) then return true end
                end
                return false
            end)
        end
    end

    for i = 1, 3 do
        update_action(Input.mb[i], function()
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

Input.swap_mode = NewInput({"tab"})
Input.toggle_editor = NewInput({"`"})
Input.ctrl = NewInput({"lctrl"})
Input.save = NewInput({"s"})
Input.shift = NewInput({"lshift"})
Input.delete = NewInput({"delete", "x"})
Input.deselect = NewInput({"escape"})
Input.undo = NewInput({"z"})
Input.add_script = NewInput({"backspace"})
Input.reset_zoom = NewInput({"rshift"})
Input.next_level = NewInput({"pagedown"})
Input.prev_level = NewInput({"pageup"})
Input.cycle = NewInput({"lalt"})
Input.alt = NewInput({"lalt"})
Input.space = NewInput({"space"})
Input.unlock = NewInput({"q"})

Input.mb_emu_1 = NewInput({"1"})
Input.mb_emu_2 = NewInput({"3"})
Input.mb_emu_3 = NewInput({"2"})

Input.mb_emu = {
    Input.mb_emu_1,
    Input.mb_emu_2,
    Input.mb_emu_3,
}