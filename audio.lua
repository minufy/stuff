Audio = {}
Audio.global_volume = 10

Source = Object:extend()

function Source:new(name, volume, type, cb)
    type = type or "static"
    self.source = love.audio.newSource("assets/audio/"..name..".ogg", type)
    cb(self.source)
end

function Source:play(pitch)
    pitch = pitch or 1
    self.source:setVolume(self.volume*Audio.global_volume/10)
    self.source:setPitch(pitch)
    self.source:stop()
    self.source:play()
end

function Source:update()
    self.source:setVolume(self.volume*Audio.global_volume/10)
end

function Audio:add(name, type, update)
    local source = Source(name, type)
    if update then
        table.insert(self.sources, source)
    end
    Audio[name] = source
    return source
end

function Audio:change_global_volume(x)
    Audio.global_volume = Audio.global_volume+x
    if Audio.global_volume > 10 then
        Audio.global_volume = 10
    elseif Audio.global_volume < 0 then
        Audio.global_volume = 0
    end
end

function Audio:set_global_volume(x)
    Audio.global_volume = x
end

function Audio:update(dt)
    for i, source in ipairs(self.source) do
        source:update()
    end
end