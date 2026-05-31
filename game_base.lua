local GameBase = {}

function GameBase:add(Object, ...)
    local o = Object(...)
    local group_name = tostring(o)
    if self.objects[group_name] == nil then
        self.objects[group_name] = {}
    end
    table.insert(self.objects[group_name], o)
    return o
end

function GameBase:register_object(object, key)
    self.lookup[key] = object
    object.key = key
end

function GameBase:lookup_object(key)
    return self.lookup[key]
end

setmetatable(GameBase, {
    __call = function (self, ...)
        for i, other in ipairs({...}) do
            for k, v in pairs(self) do
                if type(v) == "function" then
                    other[k] = v
                end
            end
        end
    end
})

return GameBase