--This version is to be used if you do not have / want to use Advanced Peripherals

local name = string.gsub(string.lower(os.getComputerLabel()):gsub("%s+", ""), "%s+", "")
local choice = 2
local modem = peripheral.find("modem")
modem.open(42)
turtle.back()
turtle.up()
turtle.select(1)
turtle.place()
turtle.turnLeft()
turtle.forward()
turtle.turnRight()
turtle.place()
turtle.down()
turtle.forward()
turtle.turnRight()
turtle.forward()
turtle.turnLeft()
local mon = peripheral.find("monitor")
term.clear()
mon.clear()
mon.setTextScale(0.5)
mon.setTextColor(1)
term.setTextColor(1)
mon.setCursorPos(1,1)
term.setCursorPos(1,1)

local fill = {{1,""},{},{"Error: Missing button label"}}

local bList = {}

local function sendWait(a,b) -- a = type of request, b = value for request
    local a = a or "step"
    local b = b or 1
    modem.transmit(42, 42, name.." "..a.." "..b)
    local event, side, frequency, replyFrequency, message, distance = os.pullEvent("modem_message")
    return message
end

local function clean() --Resets buttons list
    local count = #bList
    for i=0, count do bList[i]=nil end
end

local function bPress() --Waits for mon touch event then checks if xPos and yPos are over one of the buttons in buttons list. Returns results accordingly
    local event, side, xPos, yPos = os.pullEvent("monitor_touch")
    for i = 1, #bList do 
        if bList[i][1] <= xPos and xPos <= bList[i][3] and bList[i][2] <= yPos and yPos <= bList[i][4] then
            return fill[2][i] --Successfull button press. Returns the target ID for player choice
        end
    end
    return 0 --Unsuccessfull button press. Couldn't match touch coords with any stored button coords. Returns 0
end

local function say(a)
    local a = a or fill[1][2]
    local x,y = mon.getSize()
    local lines = require "cc.strings".wrap(a, x)
    for i = 1, #lines do
      term.setCursorPos(1, i)
      textutils.slowWrite(lines[i])
    end
end

while true do
    fill = sendWait("step",choice)
    local oldTerm = term.redirect(mon)
    mon.setCursorPos(1,1)                   --Respond to player
    mon.setTextColor(fill[1][1])
    mon.clear()
    if choice == 1 then 
        if fill[1][2] == "" then
            say("'...'")
        else
            say("'"..fill[1][2].."'")
        end
        os.sleep(2)
        break
    end
    if fill[1][2] == "" then
        say("'...'")
    else
        say("'"..fill[1][2].."'")
    end
    mon.setTextColor(1)
    term.redirect(oldTerm)
    local x,y = mon.getCursorPos()
    mon.setCursorPos(1,y+2)
    local oldTerm = term.redirect(mon)
    for i = 1, #fill[2] do
        local X1 , Y1 = mon.getCursorPos()
        write("["..i.."] "..fill[3][i])
        local X2 , Y2 = mon.getCursorPos()
        bList[i] = {X1,Y1,X2,Y2}
        mon.setCursorPos(1,Y2+1)
    end
    if fill[2][1] ~= 1 then
        local X1 , Y1 = mon.getCursorPos()
        write("["..(#fill[2]+1).."] Goodbye")
        local X2 , Y2 = mon.getCursorPos()
        bList[#bList+1] = {X1,Y1,X2,Y2}
    end
    term.redirect(oldTerm)
    choice = bPress()
    while choice == 0 do
        choice = bPress()
    end
    clean()
end
turtle.digUp()
turtle.turnLeft()
turtle.forward()
turtle.digUp()
turtle.back()
turtle.turnRight()
