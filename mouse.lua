Mouse = {}

function Mouse:__tostring()
    return "mouse"
end

function MB(i, type)
    return Input.mb[i][type] or Input.mb_emu[i][type]
end

function Mouse:init()
    self.x = 0
    self.y = 0
    self.smooth_x = 0
    self.smooth_y = 0
    self.w = 1
    self.h = 1
    
    self.tile_x = 0
    self.tile_y = 0

    self.dx = 0
    self.dy = 0
    
    self.tile_mode = true
    self.current_name = TILE_TYPES[1]
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

    if MB(3, "down") then
        Camera:add(self.dx, self.dy)
        Camera:snap_back()
    end
end

function Mouse:update(dt)
    self.x = Res:get_x()+Camera.x
    self.y = Res:get_y()+Camera.y

    self.smooth_x = self.smooth_x+(self.x-self.smooth_x)*0.3*dt
    self.smooth_y = self.smooth_y+(self.y-self.smooth_y)*0.3*dt

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
            if MB(1, "down") then
                Edit:add_tile(self.tile_x, self.tile_y, self.current_name)
            elseif MB(2, "down") then
                Edit:remove_tile(self.tile_x, self.tile_y)
            end
        end
    else
        if Input.shift.down and MB(1, "pressed") then
            if IMG_KEYS[self.current_name] == nil then
                Edit:add_object(self.tile_x*TILE_SIZE, self.tile_y*TILE_SIZE, self.current_name, Input.alt.down)
            else
                Edit:add_img_object(self.tile_x*TILE_SIZE, self.tile_y*TILE_SIZE, self.current_name)
            end
        end
        Selection:update()
    end

    self.dx = Res:get_x()
    self.dy = Res:get_y()
    
    if MB(1, "released") or MB(2, "released") or Input.delete.pressed then
        Edit:undo_push()
    end
end

function Mouse:draw()
    if self.tile_mode then
        love.graphics.rectangle("fill", self.smooth_x-2, self.smooth_y-2, 2, 2)
    else
        love.graphics.circle("fill", self.smooth_x, self.smooth_y, 2)
    end
    love.graphics.setFont(Font)
    love.graphics.print(self.current_name, self.smooth_x+10, self.smooth_y+10)
    
    Selection:draw()
    
    ResetColor()
end

function Mouse:draw_hud()
    Res:pass(function ()
        local y = 10
        love.graphics.setFont(LogFont)
    
        love.graphics.print(Round(self.x)..","..Round(self.y), 10, y)
    
        y = y+LogFont:getHeight()
        love.graphics.print(self.tile_x..","..self.tile_y, 10, y)
        
        y = y+LogFont:getHeight()
        local keys_str = Selection:get_key_str()
        love.graphics.print(keys_str, 10, y)
        
        y = y+LogFont:getHeight()
        if Edit.unlocked then
            love.graphics.print("unlocked", 10, y)
        end
    end)
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