Level = {}

local function set_type(Object, type)
    function Object:__tostring()
        return type
    end
end

local Tiles = require("objects.tiles")
local Img = require("objects.img")
set_type(Tiles, "tiles")
set_type(Img, "img")

function Level:init(level_index)
    for _, type in ipairs(TILE_TYPES) do
        NewImage(type, "tile."..type)
    end
    
    OBJECT_TABLE = {}
    for _, type in ipairs(OBJECT_TYPES) do
        OBJECT_TABLE[type] = require("objects."..type)
        set_type(OBJECT_TABLE[type], type)
    end

    IMG_KEYS = {}
    for _, type in ipairs(IMG_TYPES) do
        IMG_KEYS[type] = true
        NewImage(type, "img."..type)
    end

    self.level_index = level_index or 1
    self.level = {}
    self:load_level()
end

function Level:load_level()
    local level = "assets.levels."..self.level_index..".level"
    if CONSOLE then
        package.loaded[level] = nil
    end
    local path = "assets/levels/"..self.level_index.."/level.lua"
    if love.filesystem.getInfo(path) then
        self.level = require(level)
        if self.level.tiles == nil then
            self.level.tiles = {}
        end
        if self.level.objects == nil then
            self.level.objects = {}
        end
        if self.level.img_objects == nil then
            self.level.img_objects = {}
        end
        Edit.undo = {}
        if CONSOLE then
            Edit:undo_push()
        end
        self:reload()
        return true
    else
        Log("not found: "..path)
        return false
    end
end

function Level:reload()
    Game:reset()
    Game:add(Tiles, self.level.tiles)
    local inits = {}
    for k, o in pairs(self.level.objects) do
        local object = Game:add(OBJECT_TABLE[o.type], o)
        OBJECT_ALIGN[tostring(o.type)](object, o.dir)
        object.key = k
        if not Edit.editing and object.init then
            table.insert(inits, function ()
                object:init()
            end)
        end
    end
    for _, f in ipairs(inits) do
        f()
    end
    for k, o in pairs(self.level.img_objects) do
        local object = Game:add(Img, o.x, o.y, o.type)
        object.key = k
    end
end