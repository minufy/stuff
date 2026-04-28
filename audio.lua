Audio = {}

function NewAudio(name)
    local audio = {
        source = love.audio.newSource("assets/audio/"..name..".ogg", "static"),
    }
    function audio:play(v)
        v = v or 0.5
        self.source:setVolume(v)
        self.source:stop()
        self.source:play()
    end
    Audio[name] = audio
    return audio
end

Music = {}