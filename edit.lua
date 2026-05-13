local lume = require("modules.lume")

Edit = {}

function Edit:init()
    self.editing = false
    self.undo = {}
    self.undo_i = 1
    self.remove_scripts = {}
    self.unlocked = false
    Mouse:init()
    Selection:init()
end

function Edit:update(dt)
    if CONSOLE then
        if Input.toggle_editor.pressed then
            self.editing = not self.editing
            Level:reload()
            if not self.editing then
                Camera:set_zoom(1)
            end
        end
        if Input.ctrl.down then
            if Input.save.pressed then
                self:save()
            end
            if Input.reload.pressed then
                Level:load_level()
            end
        end
        if Input.unlock.pressed then
            self.unlocked = not self.unlocked
        end
    end
    
    if self.editing then
        Mouse:update(dt)
        if Input.ctrl.down then
            if Input.undo.pressed then
                Mouse:deselect_all()
                self:undo_undo()
            end
        end
    end
end

function Edit:draw()
    Mouse:draw()
end

function Edit:draw_hud()
    Mouse:draw_hud()
end

function Edit:add_object(x, y, type, dir, alt)
    local data = {
        x = x,
        y = y,
        type = type,
    }
    if dir ~= 0 then
        data.dir = dir
    end
    if alt then
        data.alt = true
    end
    Level.level.objects[tostring(data):sub(8)] = data
    Level:reload()
end

function Edit:add_img_object(x, y, type, dir)
    local data = {
        x = x,
        y = y,
        type = type,
    }
    if dir ~= 0 then
        data.dir = dir
    end
    Level.level.img_objects[tostring(data):sub(8)] = data
    Level:reload()
end

function Edit:add_remove_script(key)
    local path = "assets/levels/"..Level.level_name.."/"..key..".lua"
    if love.filesystem.getInfo(path) then
        table.insert(self.remove_scripts, path)
    end
end

function Edit:remove_object(key)
    self:add_remove_script(key)
    Level.level.objects[key] = nil
    Level:reload()
end

function Edit:remove_img_object(key)
    self:add_remove_script(key)
    Level.level.img_objects[key] = nil
    Level:reload()
end

function Edit:remove_tile(x, y)
    if Level.level.tiles[x..","..y] == nil then
        return
    end
    Level.level.tiles[x..","..y] = nil
    Level:reload()
end

function Edit:add_tile(x, y, type)
    if Level.level.tiles[x..","..y] == type then
        return
    end
    Level.level.tiles[x..","..y] = type
    Level:reload()
end

function Edit:get_object_value(value, key)
    return Level.level.objects[key][value]
end

function Edit:set_object_value(value, key, x, no_reload)
    no_reload = no_reload or false
    Level.level.objects[key][value] = x
    if not no_reload then
        Level:reload()
    end
end

function Edit:get_img_object_value(value, key)
    return Level.level.img_objects[key][value]
end

function Edit:set_img_object_value(value, key, x, no_reload)
    no_reload = no_reload or false
    Level.level.img_objects[key][value] = x
    if not no_reload then
        Level:reload()
    end
end

function Edit:undo_push()
    for i = #self.undo, self.undo_i+1, -1 do
        table.remove(self.undo, i)
    end
    table.insert(self.undo, lume.serialize(Level.level))
    self.undo_i = #self.undo
end

function Edit:undo_undo()
    if self.undo_i-1 >= 1 then
        self.undo_i = self.undo_i-1
        Level.level = lume.deserialize(self.undo[self.undo_i])
        Level:reload()
    end
end

function Edit:save()
    local data = "return "..lume.serialize(Level.level)
    local path = "assets/levels/"..Level.level_name.."/level.lua"
    local file, err = io.open(path, "w")
    if file then
        file:write(data)
        file:close()
        Log("saved to "..path)
    else
        Log(err)
    end
    for i, script_path in ipairs(self.remove_scripts) do
        if love.filesystem.getInfo(script_path) then
            local success, script_err = os.remove(script_path)
            if success then
                Log(script_path.." deleted")
            else
                Log("error deleting "..script_path.." | "..script_err)
            end
        end
    end
end