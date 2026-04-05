Mouse = {}

function Mouse:init()
    self.group_name = "mouse"

    self.x = 0
    self.y = 0
    self.w = 1
    self.h = 1
    
    self.tile_x = 0
    self.tile_y = 0

    self.dx = 0
    self.dy = 0
    
    self.tile_mode = true
    self.current_name = "tile"
    self.current_i = 1
end

function Mouse:camera_control()
    if Input.ctrl.down then
        if Input.wheel.up then
            Camera:scale_zoom(1.5)
        end
        if Input.wheel.down then
            Camera:scale_zoom(1/1.5)
        end
    else
        if not Input.cycle.down then
            if Input.wheel.up then
                self.current_i = self.current_i+1
                self:set()
            end
            if Input.wheel.down then
                self.current_i = self.current_i-1
                self:set()
            end
        end
    end
    if Input.reset_zoom.pressed then
        Camera:set_zoom(1)
    end

    if Input.mb[3].down then
        Camera:add(self.dx, self.dy)
        Camera:snap_back()
    end
end

function Mouse:update(dt)
    self.x = Res:get_x()+Camera.x
    self.y = Res:get_y()+Camera.y

    self.dx = self.dx-Res:get_x()
    self.dy = self.dy-Res:get_y()
    
    self.tile_x = Round(self.x, TILE_SIZE, 0)
    self.tile_y = Round(self.y, TILE_SIZE, 0)

    if Input.swap_mode.pressed then
        self.tile_mode = not self.tile_mode
        Selection.selected_objects = {}
        self.current_i = 1
        self:set()
    end
    
    self:camera_control()
    
    if self.tile_mode then
        if Input.ctrl.down then
            Selection:update_tile()
        else
            if Input.mb[1].down then
                Edit:add_tile(self.tile_x, self.tile_y, self.current_name)
            elseif Input.mb[2].down then
                Edit:remove_tile(self.tile_x, self.tile_y)
            end
        end
    else
        if Input.shift.down and Input.mb[1].pressed then
            if IMG_TABLE[self.current_name] == nil then
                Edit:add_object(self.tile_x*TILE_SIZE, self.tile_y*TILE_SIZE, self.current_name)
            else
                Edit:add_img_object(self.tile_x*TILE_SIZE, self.tile_y*TILE_SIZE, self.current_name)
            end
        end
        Selection:update()
    end

    self.dx = Res:get_x()
    self.dy = Res:get_y()
    
    if Input.mb[1].released or Input.mb[2].released or Input.delete.pressed then
        Edit:undo_push()
    end
end

function Mouse:draw()
    local x, y = Res:get_x()+Camera.x, Res:get_y()+Camera.y
    love.graphics.circle("fill", x, y, 2)
    love.graphics.setFont(Font)
    love.graphics.print(self.current_name, x+10, y+10)
    
    Selection:draw()
    
    ResetColor()
end

function Mouse:draw_hud()
    local y = 0
    love.graphics.setFont(Font)

    love.graphics.print(Round(self.x)..","..Round(self.y), 0, y)

    y = y+Font:getHeight()
    love.graphics.print(self.tile_x..","..self.tile_y, 0, y)
    
    y = y+Font:getHeight()
    local keys_str = Selection:get_key_str()
    love.graphics.print(keys_str, 0, y)
end

function Mouse:set()
    self:bound_i()
    self:find_name()
end

function Mouse:find_name()
    if self.tile_mode then
        self.current_name = TILE_TYPES[self.current_i]
    else
        if self.current_i > #OBJECT_TYPES then
            self.current_name = IMG_TYPES[self.current_i-#OBJECT_TYPES]
        else
            self.current_name = OBJECT_TYPES[self.current_i]
        end
    end
end

function Mouse:bound_i()
    if self.current_i < 1 then
        self.current_i = 1
    end
    if self.tile_mode then
        if self.current_i > #TILE_TYPES then
            self.current_i = #TILE_TYPES
        end
    else
        if self.current_i > #OBJECT_TYPES+#IMG_TYPES then
            self.current_i = #OBJECT_TYPES+#IMG_TYPES
        end
    end
end

-- 외부에서 접근
function Mouse:deselect_all()
    Selection.selected_objects = {}
end