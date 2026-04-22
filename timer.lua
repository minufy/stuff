Timer = Object:extend()

function Timer:new(time, timer)
    self.time = time
    self.timer = timer or 0
end

function Timer:update(dt)
    self.timer = self.timer+dt
end

function Timer:run()
    if self.timer >= self.time then
        self.timer = 0
        return true
    end
    return false
end