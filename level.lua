Level = {}

local Tiles = require("objects.tiles")
local Img = require("objects.img")

function Level:init()
    TILE_IMGS = {}
    for i, type in ipairs(TILE_TYPES) do
        TILE_IMGS[type] = NewImage(type)
    end

    OBJECT_TABLE = {}
    for i, type in ipairs(OBJECT_TYPES) do
        OBJECT_TABLE[type] = require("objects."..type)
    end

    IMG_TABLE = {}
    for i, type in ipairs(IMG_TYPES) do
        IMG_TABLE[type] = NewImage(type)
    end

    self.level_index = 1
    self.level = {}
    self:load_level()
end

function Level:load_level()
    local path = "assets/levels/"..self.level_index.."/level.lua"
    if love.filesystem.getInfo(path) then
        self.level = require("assets.levels."..self.level_index..".level")
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
    Game.objects = {}
    Game:add(Tiles, self.level.tiles)
    for k, o in pairs(self.level.objects) do
        local object = Game:add(OBJECT_TABLE[o.type], o.x, o.y)
        object.key = k
        local path = "assets/levels/"..self.level_index.."/"..k..".lua"
        if love.filesystem.getInfo(path) then
            object.data = require("assets.levels."..self.level_index.."."..k)
        end
    end
    for k, o in pairs(self.level.img_objects) do
        local object = Game:add(Img, o.x, o.y, o.type)
        object.key = k
    end
end