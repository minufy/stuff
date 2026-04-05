Audio = {}

function NewAudio(name, volume)
    volume = volume or 0.5
    local audio = {
        source = love.audio.newSource("assets/audio/"..name..".ogg", "static"),
        volume = volume
    }
    function audio:play(v)
        v = v or self.volume
        self.source:setVolume(v)
        self.source:stop()
        self.source:play()
    end
    Audio[name] = audio
    return audio
end