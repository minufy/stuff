Shadow = {}

function Shadow:init(offset)
    self.shader = love.graphics.newShader("assets/shader/shadow.glsl")
    self.offset = offset
    self.canvas = love.graphics.newCanvas(Res.w, Res.h)
end

function Shadow:start()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
end

function Shadow:stop()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setCanvas(Res.canvas)
    
    love.graphics.setShader(self.shader)
    love.graphics.draw(self.canvas, Shader.offset, Shader.offset)

    love.graphics.setShader()
    love.graphics.draw(self.canvas)
    
    love.graphics.setBlendMode("alpha")
end