Logs = {}
LogTime = 240
local MAX_LOGS = 100

function Log(...)
    local text = os.date().." : "
    for i, t in ipairs({...}) do
        text = text..tostring(t).." "
    end
    if #Logs >= MAX_LOGS then
        table.remove(Logs, 1)
    end
    table.insert(Logs, {text=text, timer=0})
    print(text)
end

function DrawLog()
    love.graphics.setFont(LogFont)
    for i, log in ipairs(Logs) do
        love.graphics.setColor(1, 1, 1, 1-log.timer/LogTime)
        love.graphics.print(log.text, 0, (#Logs-i)*LogFont:getHeight())
    end
    ResetColor()
end

function UpdateLog(dt)
    for i=#Logs, 1, -1 do
        Logs[i].timer = Logs[i].timer+dt
        if Logs[i].timer > LogTime then
            table.remove(Logs, i)
        end
    end
end