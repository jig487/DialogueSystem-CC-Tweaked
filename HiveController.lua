local mon = peripheral.wrap("top")
local modem = peripheral.wrap("right")
local name = "simon"
local rqst = "step"
local arg2 = 2
local debugCount = 0
local next = next

local tree = { 
    simon = { -- IMPORTANT: 2rd index (or whatever the default choice val is for the terminal) in the list must be the one you want shown first otherwise code breaks. Fix later. First string is a player option. Second is the response if player chooses that option. 3rd index is the ID of that pair. 4th index is the IDs to display if this pair is chosen.
        fill = {{32,""},{},{"Error: Missing button label"}},--{Text color, response string}{target IDs}{button labels}
        {"","",0,0}, --ID pairs like this are used to end the conversation. Will generate only a goodbye button.
        {"","Hello, I'm Simon.",1,2},
        {"Nice weather today!","My data indicates the weather is within acceptable parameters.",2,2},
        {"Your floppy disk is out!","I am not capable of hate. But if I was, I'd hate you.",2,2},
        {"Did you polish your monitor?","Thanks for noticing.",2,2}
    },
    alex = { --1 option with single branches 
        fill = {{64,""},{},{"Error: Missing button label"}},
        {"","", 0, 0},
        {"","Hiya there, hun!", 1, 2},
        {"Nice weather today, huh?","Oh it's just darlin today!", 2, 3},
        {"Are you doing anything after this?","Hmm well I've got to turn over the hay, feed the animals, clean the barnyard, water and weed my garden, get ready for baling...", 3, 4},
        {"Never mind...","Oh, alright!", 4, 0},
    },
    justicedog = { --multiple branches
        fill = {{16384,""},{},{"Error: Missing button label"}},
        {"Goodbye, hero","good luck out there, kid.",0,0},
        {"","I can't be tamed.",1,2},
        {"Uh...","I'm an agent of vengeance. An avatar of justice. A righteous conduit of terrible purpose.",2,3},
        {"...","I eat homework, and only God can judge me.",3,4},
        {"Is there anything difficult about your...job? Quest?","Friend, my bowels are an eternal sea of torment. I am in agony.",4,5},
        {"Where were you when I was a kid?","I dream of travelling through time, consuming every wretched scrap of homework to exist on this blighted plane.",4,10},
        {"...","Pain is a rampaging bull, and I am its china shop.",5,6},
        {"...","Still, my mission remains.",6,7},
        {"...","...If you'll excuse me, the spirit of vengeance needs to go to the uh, little dog's room.",7,0},
        {"Where were you when I was a kid?","I dream of travelling through time, consuming every wretched scrap of homework to exist on this blighted plane.",9,10},
        {"...","Then, I think about how much paper and stone and tree bark that would be, and I feel very ill.",10,7},
    }
}

local function newLine()
    local x, y = mon.getCursorPos()
    mon.setCursorPos(1,y + 1)
end

local function bug(a)
    mon.write(debugCount..": "..a)
    newLine()
end

local function msgWait()
    local event, side, frequency, replyFrequency, message, distance = os.pullEvent("modem_message")
    name, rqst, arg2 = string.match(message, "(%a+)%s*(%a+)%s*(%d+)")
    arg2 = tonumber(arg2)
    return name, rqst, arg2
end

mon.setTextScale(0.5)
mon.setCursorPos(1,1)
modem.open(42)
term.clear()
mon.clear()
mon.setTextColor(1)
local oldTerm = term.redirect(mon)
while true do
    debugCount = debugCount + 1
    term.setCursorPos(1,1)
    mon.setCursorPos(1,1)
    bug("Waiting for request...")
    local name, rqst, arg2 = msgWait()
    term.clear()
    mon.clear()
    bug("Message recieved: "..name.." "..rqst.." "..arg2)
    if rqst == "step" then
        bug("Fill request from "..name.." for "..arg2..". Generating fill table...")
        bug("Adding response for "..name.." "..arg2.."...") --Add response
        if arg2 == nil then
            tree[name].fill[1][2] = "Error, arg2 = nil"
            bug("Error: arg2 is nil. Added error response")
        else
            tree[name].fill[1][2] = tree[name][arg2][2]
            bug("Added ID "..tree[name][arg2][2].." as response")
        end
        bug("Finished adding response")
        bug("Generating target indexes for "..name.." "..arg2.."...")
        bug("Index of "..arg2..", current ID of "..tree[name][arg2][3]..", target ID "..tree[name][arg2][4])
        if next(tree[name][2]) ~= nil then
            for i=1, #tree[name].fill[2] do tree[name].fill[2][i] = nil end
        end
        local count = 0
        bug("Length of #tree."..name.." is "..#tree[name])
        for i = 1, #tree[name] do--Generate target ID table
            if tree[name][i][3] == tree[name][arg2][4] then
                bug("Added index "..i.." from target ID "..tree[name][arg2][4].." comparing to scrutinized ID "..tree[name][i][3])
                tree[name].fill[2][1+count] = i
                count = count + 1
            end
        end
        bug("Finished generating index table with length "..#tree[name].fill[2]..". Serialized table:")
        bug(textutils.serialize(tree[name].fill[2]))
        bug("Adding button labels for "..name.." "..arg2.."...")
        if next(tree[name][3]) ~= nil then
            for i=0, #tree[name].fill[3] do tree[name].fill[3][i] = nil end
        end
        local count = 0
        for i = 1, #tree[name].fill[2] do --Add button labels
            tree[name].fill[3][1+count] = tree[name][tree[name].fill[2][i]][1]
            count = count + 1
            bug("Added button label: "..tree[name][tree[name].fill[2][i]][1])
        end
        bug("Finished adding button labels with length "..#tree[name].fill[3])
        bug("Finished generating fill table for "..name.." "..arg2..". Sending...")
        modem.transmit(42, 42, tree[name].fill)
        bug("Fill table sent")
    elseif rqst == "goodbye" then
        bug("goodbye response recieved from "..name)
    else
        bug("Error: Type did not match any cases.")
    end
end
term.redirect(oldTerm)