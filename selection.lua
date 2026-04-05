Selection = {}

local function calc_rect(sx, ex, sy, ey)
    local x, y, w, h
    if sx < ex then
        w = ex-sx
        x = sx
    else
        w = sx-ex
        x = sx-w
    end
    if sy < ey then
        h = ey-sy
        y = sy
    else
        h = sy-ey
        y = sy-h
    end
    return x, y, w, h
end

local function get_group_names()
    local group_names = {}
    for i, type in ipairs(OBJECT_TYPES) do
        table.insert(group_names, type)
    end
    table.insert(group_names, "img")
    return group_names
end

function Selection:init()
    self.x = 0
    self.y = 0
    self.w = 0
    self.h = 0

    self.start_x = self.x
    self.start_y = self.y
    self.end_x = self.x
    self.end_y = self.y
    self.selected_objects = {}
    self.prev_col = {}
    self.cycle_i = 1

    self.tile_mouse_i = 1
end

function Selection.get_col(self)
    return Physics.col(self, get_group_names())
end

function Selection:draw_selection()
    local active = not Mouse.tile_mode and Input.mb[1].down
    local active_tile = Mouse.tile_mode and Input.ctrl.down and (Input.mb[1].down or Input.mb[2].down)
    if active or active_tile then
        local color = 1
        if active_tile and self.tile_mouse_i == 2 then
            color = 0
        end
        love.graphics.setColor(color, color, color, 0.2)
        if active_tile then
            local sx, sy = RoundS(self.x, TILE_SIZE), RoundS(self.y, TILE_SIZE)
            local w, h = RoundS(self.w, TILE_SIZE, 1), RoundS(self.h, TILE_SIZE, 1)
            love.graphics.rectangle("fill", sx, sy, w, h)
        else
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        end
    end
end

function Selection:update_selection()
    if Input.mb[1].pressed then
        local col = self.get_col(Mouse)
        if #col > 0 then
            self.selected_objects = {col[1]}
            return
        end
    end

    if Input.mb[1].down then
        self.end_x = Mouse.x
        self.end_y = Mouse.y
    end

    self.x, self.y, self.w, self.h = calc_rect(self.start_x, self.end_x, self.start_y, self.end_y)
    
    if Input.mb[1].released then
        self.selected_objects = self:get_col()
    end
end

function Selection:draw_selected_objects()
    if Input.cycle.down then
        local object = self.selected_objects[self.cycle_i]
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1, 0, 1, 0.6)
        love.graphics.rectangle("line", object.x, object.y, object.w, object.h)
    end
    for i, object in ipairs(self.selected_objects) do
        if Input.cycle.down then
            love.graphics.setFont(Font)
            love.graphics.setColor(1, 0, 1, 0.8)
            love.graphics.print(tostring(i), object.x+object.w+2, object.y)
        else
            love.graphics.setLineWidth(2)
            love.graphics.setColor(0, 1, 1, 0.6)
            love.graphics.rectangle("line", object.x, object.y, object.w, object.h)
        end
    end
end

function Selection:ctrl_select(col)
    local existed = false
    for i, object in ipairs(self.selected_objects) do
        if object.key == col[1].key then
            existed = true
            table.remove(self.selected_objects, i)
            break
        end
    end
    if not existed then
        table.insert(self.selected_objects, col[1])
    end
end

function Selection:single_selection()
    if Input.mb[1].pressed then
        local col = self.get_col(Mouse)
        if #col <= 0 then
            self.selected_objects = {}
            return
        end
        
        if Input.ctrl.down then
            self:ctrl_select(col)
        else
            if #self.selected_objects <= 1 then
                self.selected_objects = {col[1]}
            end
        end
    end
end

function Selection:update_selected_objects()
    for i, object in ipairs(self.selected_objects) do
        if Input.mb[1].down then
            object.x = object.x-Mouse.dx
            object.y = object.y-Mouse.dy
        elseif Input.mb[1].up then
            local grid = TILE_SIZE/2
            local x = RoundS(object.x, grid)
            local y = RoundS(object.y, grid)
            object.x = x
            object.y = y
            if object.group_name == "img" then
                Edit:move_img_object(x, y, object.key)
            else
                Edit:move_object(x, y, object.key)
            end
        end
        if Input.delete.pressed then
            if object.group_name == "img" then
                Edit:remove_img_object(object.key)
            else
                Edit:remove_object(object.key)
            end
        end
    end
    if Input.deselect.pressed or Input.delete.pressed then
        self.selected_objects = {}
    end
end

function Selection:add_script()
    for i, o in ipairs(self.selected_objects) do
        local path = "assets/levels/"..Level.level_index.."/"..o.key..".lua"
        local file = io.open(path, "w")
        if file then
            file:close()
        end
        Log("script added for "..o.key)
    end
end

function Selection:get_key_str()
    local str = ""
    for i, o in ipairs(self.selected_objects) do
        if i > 1 then
            str = str..","..o.key
        else
            str = o.key
        end
    end
    return str
end

function Selection:update_cycle()
    if Input.cycle.pressed then
        self.cycle_i = 1
    end
    if Input.wheel.up then
        self.cycle_i = self.cycle_i-1
    elseif Input.wheel.down then
        self.cycle_i = self.cycle_i+1
    end
    if self.cycle_i > #self.selected_objects then
        self.cycle_i = #self.selected_objects
    elseif self.cycle_i < 1 then
        self.cycle_i = 1
    end
end

function Selection:update()
    if Input.cycle.released then
        self.selected_objects = {self.selected_objects[self.cycle_i]}
    end
    if Input.cycle.down then
        self:update_cycle()
        return
    end
    if Input.mb[1].pressed then
        self.start_x = Mouse.x
        self.start_y = Mouse.y
    end
    if #self.selected_objects > 0 then
        self:single_selection()
        self:update_selected_objects()
    else
        self:update_selection()
    end
    if Input.mb[1].released then
        self.w = 0
        self.h = 0
    end
    if Input.ctrl.down and Input.add_script.pressed then
        self:add_script()
    end
end

function Selection:draw()
    if #self.selected_objects > 0 then
        self:draw_selected_objects()
    else
        self:draw_selection()
    end
end

function Selection:fill_tiles()
    local sx, sy = Round(self.x, TILE_SIZE), Round(self.y, TILE_SIZE)
    local w, h = Round(self.w, TILE_SIZE), Round(self.h, TILE_SIZE)
    for x = sx, sx+w do
        for y = sy, sy+h do
            if self.tile_mouse_i == 1 then
                Edit:add_tile(x, y, Mouse.current_name)
            else
                Edit:remove_tile(x, y)
            end
        end
    end
end

function Selection:update_tile()
    for i = 1, 2 do
        if Input.mb[i].pressed then
            self.tile_mouse_i = i
            self.start_x = RoundS(Mouse.x, TILE_SIZE, 0)
            self.start_y = RoundS(Mouse.y, TILE_SIZE, 0)
        end
    
        if Input.mb[i].down then
            self.end_x = RoundS(Mouse.x, TILE_SIZE, 0)
            self.end_y = RoundS(Mouse.y, TILE_SIZE, 0)
        end
    
        self.x, self.y, self.w, self.h = calc_rect(self.start_x, self.end_x, self.start_y, self.end_y)
        
        if Input.mb[i].released then
            self:fill_tiles()
            self.w = 0
            self.h = 0
        end
    end
end