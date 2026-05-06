Shader = {}
Shader.offset = {
    x = 4,
    y = 4
}

function Shader:init(path)
    self.shader = love.graphics.newShader(path)
    self.canvas = love.graphics.newCanvas(Res.w, Res.h)
end

function Shader:start()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
end

function Shader:stop()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setCanvas(Res.canvas)
    love.graphics.setShader(self.shader)
    love.graphics.draw(self.canvas, Shader.offset.x, Shader.offset.y)
    love.graphics.setShader()
    love.graphics.draw(self.canvas)
    love.graphics.setBlendMode("alpha")
end