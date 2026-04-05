Physics = {}

function Physics.dist(self, group_names, r)
    local found_all = {}
    for _, group_name in ipairs(group_names) do
        local group = Game.objects[group_name]
        if group ~= nil then
            for _, other in ipairs(group) do
                if self ~= other and Dist(self, other) <= r then
                    table.insert(found_all, other)
                end
            end
        end
    end
    return found_all
end

function Physics.col(self, group_names)
    local found_all = {}
    for _, group_name in ipairs(group_names) do
        local group = Game.objects[group_name]
        if group ~= nil then
            local found = Physics.col_group(self, group)
            for _, other in ipairs(found) do
                table.insert(found_all, other)
            end
        end
    end
    return found_all
end

function Physics.col_group(self, group_name)
    local found = {}
    for _, other in ipairs(group_name) do
        if self ~= other and AABB(self, other) then
            table.insert(found, other)
        end
    end
    return found
end

function Physics.solve_x(self, x, col)
    if col then
        if x > 0 then
            self.x = col.x-self.w
        else
            self.x = col.x+col.w
        end
    end
end

function Physics.solve_y(self, y, col)
    if col then
        if y > 0 then
            self.y = col.y-self.h
        else
            self.y = col.y+col.h
        end
    end
end

function Physics.move_and_col(self, x, y, layers)
    self.x = self.x+x
    self.y = self.y+y
    layers = layers or {1}
    local found_all = {}
    for i, layer in ipairs(layers) do
        local tiles = Game.objects["tiles"][layer]
        local around = tiles:around(Round(self.x, TILE_SIZE), Round(self.y, TILE_SIZE))
        local found = Physics.col_group(self, around)
        for _, other in ipairs(found) do
            table.insert(found_all, other)
        end
    end
    return found_all
end