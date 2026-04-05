function rgb(r, g, b)
    return {r/255, g/255, b/255}
end

function rgba(r, g, b, a)
    return {r/255, g/255, b/255, a}
end

function Alpha(rgb, a)
    return {rgb[1], rgb[2], rgb[3], a}
end

function ResetColor()
    love.graphics.setColor(1, 1, 1, 1)
end

function Dist(a, b)
    local ax = a.x+a.w/2
    local ay = a.y+a.h/2
    local bx = b.x+b.w/2
    local by = b.y+b.h/2
    return math.sqrt((ax-bx)^2+(ay-by)^2)
end

function Sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    end
    return 0
end

function AABB(a, b)
    return a.x < b.x+b.w and
           b.x < a.x+a.w and
           a.y < b.y+b.h and
           b.y < a.y+a.h
end

function NewImage(name)
    local path = "assets/imgs/"..name..".png"
    if love.filesystem.getInfo(path) then
        return love.graphics.newImage(path)
    else
        Log("not found: "..path)
        return love.graphics.newImage("assets/imgs/error.png")
    end
end

function RoundS(x, r, ofs)
    return Round(x, r, ofs)*r
end

function Round(x, r, ofs)
    r = r or 1
    ofs = ofs or 0.5
    return math.floor(x/r+ofs)
end

function SinEffect()
    return math.sin(love.timer.getTime()*4)
end

function EaseOut(x)
    return 1-(1-x)^2
end

function UpdateTargetFPS()
    local _, _, flags = love.window.getMode()
    TargetFPS = (flags.refreshrate > 0) and flags.refreshrate or 60
end

function love.displaychanged()
    UpdateTargetFPS()
end