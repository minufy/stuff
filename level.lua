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

function Level:init(level_name)
    TILE_QUADS = {}
    for _, type in ipairs(TILE_TYPES) do
        NewImage(type)
        TILE_QUADS[type] = {}
        local w, h = Image[type]:getDimensions()
        for y = 0, h-TILE_SIZE, TILE_SIZE do
            for x = 0, w-TILE_SIZE, TILE_SIZE do
                table.insert(TILE_QUADS[type], love.graphics.newQuad(x, y, TILE_SIZE, TILE_SIZE, Image[type]))
            end
        end
    end

    OBJECT_TABLE = {}
    for _, type in ipairs(OBJECT_TYPES) do
        OBJECT_TABLE[type] = require("objects."..type)
        set_type(OBJECT_TABLE[type], type)
    end

    IMG_KEYS = {}
    for _, type in ipairs(IMG_TYPES) do
        IMG_KEYS[type] = true
        NewImage(type)
    end
    
    self.level = {}
    self:load_level(level_name)
end

function Level:load_level(level_name)
    if level_name then
        self.level_name = level_name
    end
    local level = "assets.levels."..self.level_name..".level"
    local level_path = "assets/levels/"..self.level_name.."/level.lua"
    local data = "assets.levels."..self.level_name..".data"
    local data_path = "assets/levels/"..self.level_name.."/data.lua"
    if CONSOLE then
        package.loaded[level] = nil
    end
    if love.filesystem.getInfo(level_path) then
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

        self.data = {}
        if love.filesystem.getInfo(data_path) then
            self.data = require(data)
        end

        self:reload()
        return true
    else
        Log("not found: "..level_path)
        return false
    end
end

function Level:reload()
    if Game.before_reload then
        Game:before_reload()
    end
    Game:add(Tiles, self.level.tiles)
    local inits = {}
    for k, o in pairs(self.level.objects) do
        local object = Game:add(OBJECT_TABLE[o.type], o)
        OBJECT_ALIGN[tostring(o.type)](object, o.dir)
        
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
        local object = Game:add(Img, o)
        OBJECT_ALIGN.img(object, o.dir)
        Game:register_object(object, k)
    end
    if Game.after_reload then
        Game:after_reload()
    end
end