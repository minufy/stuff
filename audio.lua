Audio = {}
Audio.global_volume = 10

function NewAudio(name)
    local audio = {
        source = love.audio.newSource("assets/audio/"..name..".ogg", "static"),
    }
    function audio:play(volume, pitch)
        volume = volume or 1
        pitch = pitch or 1
        self.source:setVolume(volume*Audio.global_volume/10)
        self.source:setPitch(pitch)
        self.source:stop()
        self.source:play()
    end
    Audio[name] = audio
    return audio
end

function Audio:change_global_volume(x)
    Audio.global_volume = Audio.global_volume+x
    if Audio.global_volume > 10 then
        Audio.global_volume = 10
    elseif Audio.global_volume < 0 then
        Audio.global_volume = 0
    end
end

Music = {}
Music.volume = 0.5
function Music:update()
    if self.source then
        self.source:setVolume(Audio.global_volume/10*self.volume)
    end
end