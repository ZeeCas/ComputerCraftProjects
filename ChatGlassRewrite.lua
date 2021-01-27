-- Main Declaration --
glass = peripheral.wrap("right")
sensor = peripheral.wrap("top")

getfenv(("").gsub).glass_chat = {}
messages = getfenv(("").gsub).glass_chat
maxLines = 7
stop = false

authedUsers = {"ZeeDerpMaster", "Sleetyy", "icedfrappuccino", "korvuus", "soundsofmadness", "mpfthprblmtq","MageOfTheNorth"}
staffList = {"DragonSlayer","eytixis","iim_wolf","oozoozami"}
trackedPlayers = {}
tracker = {}

chatColors = {}
chatColors["ZeeDerpMaster"] = 0x3C93C2
chatColors["Sleetyy"] = 0xFFFFFF
chatColors["mpfthprblmtq"] = 0x800080
chatColors["SoundsOfMadness"] = 0x883388
chatColors["MageOfTheNorth"] = 0x00FBFF

sensorX = 4877
sensorY = 13  
sensorZ = 3574

for i = 1, maxLines do
    table.insert(messages, "$$$$")
end
-- End Main Declarations -- 

-- Main Functions --

function Main(user)
    local surface = glass.getUserSurface(user)
    glass.clear()
    height = (maxLines * 10)
    glass.addBox(0, 20, 335, height, 0x000000, 0.5)
    for i = 1, #messages do
        pos = 10 + (i * 10)
        message = messages[i]
        color = chatColors[getName(message)]
        glass.addText(5, pos, message, color)
    end
    onlineList()
end

function parseCMD(cmd,user)
    local surface = glass.getUserSurface(user)
    local cmd_lower = cmd[1]:lower()
    if cmd_lower == "chatcolor" then
        chatColors[user] = loadstring("return " .. cmd[2])()
        glassCMDOutput(user,"Chat color is now "..cmd[2])
        sleep(2)
        surface.clear()
    elseif cmd_lower == "nuke" then
        nuke()
    elseif cmd_lower == "invsee" then
        invsee(sensor, cmd[2], user)
        sleep(3)
        surface.clear()
    elseif cmd_lower == "request" then
        controller.extractItem({id=tonumber(cmd[2]),dmg=tonumber(cmd[3]),qty=tonumber(cmd[4])}, "south")
        glassCMDOutput(user,"Requested "..cmd[4].." of "..cmd[2])
        sleep(2)
        surface.clear()
    elseif cmd_lower == "auth" then 
        table.insert(authedUsers,cmd[2])
        glassCMDOutput(user,"Added "..cmd[2].." to authorized users.")
        sleep(2)
        surface.clear()
    elseif cmd_lower == "deauth" then
        local index={}
        for k,v in pairs(authedUsers) do
            index[v]=k
        end
        table.remove(authedusers,print(index[cmd[2]]))
        glassCMDOutput(user,"Removed "..cmd[2].." from authorized users.")
        sleep(2)
        surface.clear()
    elseif cmd_lower == "whereis" then
        if table.contains(staffList, cmd[2]) then 
            glassCMDOutput(user,"You cannot track that player")
            sleep(2)
            surface.clear()
        else
            getPos(cmd[2],user)
            sleep(3)
            surface.clear()
        end
    elseif cmd_lower == "track" then
        table.insert(trackedPlayers, cmd[2])
    elseif cmd_lower == "clear" then
        trackedPlayers = {}
        surface.clear()
    elseif cmd_lower == "trackon" then
        tracker[user] = true
    elseif cmd_lower == "trackoff" then
        surface.clear()
        tracker[user] = false
    elseif cmd_lower == "help" then 
        glassCMDOutput(user,"Commands are : chatcolor, nuke, invsee, request, auth, deauth, whereis, trackon, trackoff, track, and clear")
        sleep(3)
        surface.clear()
    else
        local cmd_msg = table.concat(cmd, " ")
        local total_msg = user .. ": " .. cmd_msg
        if glass.getStringWidth(cmd_msg) > 325 then
            cutMsgOne = string.sub(cmd_msg, 1, 48)
            cutMsgTwo = string.sub(cmd_msg, 49, string.len(cmd_msg))
            table.insert(messages, user .. ": " .. cutMsgOne)
            table.insert(messages, user .. ": " .. cutMsgTwo)
            table.remove(messages, 1)
            table.remove(messages, 1)
        else
            table.insert(messages, user .. ": " .. cmd_msg)
            table.remove(messages, 1)
        end
    end
end

-- function listener()
--     local tEvent = {os.pullEventRaw()}
--     if tEvent[1] == "chat_command" then
--         cmd = split(tEvent[2])
--         user = tostring(tEvent[3])
--         parseCMD(cmd, user)
--     end
-- end

function eventRun()
    for _,user in pairs(glass.getUsers()) do
        refreshTimer = os.startTimer(1.0)
        Main(user)
        while stop do
            local tEvent = {os.pullEventRaw()}
            if tEvent[1] == "timer" then
                refreshTimer = os.startTimer(1.0)
                Main(user)
            elseif tEvent[1] == "chat_command" then
                local cmd = split(tEvent[2])
                local usr = tostring(tEvent[3])
                parseCMD(cmd, usr)

                refreshTimer = os.startTimer(1.0)
                Main(user)
            elseif tEvent == "key" then
                if tEvent[2] == keys.q then
                    stop = true
                end
            end
            if tracker[user] then
                track(user)
            end
        end
    end
end

-- End Main Functions -- 

-- Helper Functions --

function track(user)
    local surface = glass.getUserSurface(user)
    surface.clear()
    for i,player in pairs(trackedPlayers) do 
        pos = 100 + (i * 10)
        local posX = math.floor(sensor.getPlayerData(player).position.x + sensorX)
        local posY = math.floor(sensor.getPlayerData(player).position.y + sensorY)
        local posZ = math.floor(sensor.getPlayerData(player).position.z + sensorZ)
        surface.addText(0,pos,player.." is at "..posX..","..posY..","..posZ)
    end
end

function table.contains(tab, ele)
    for i = 1, #tab do
        if tab[i] == ele then
            return true
        end
    end
    return false
end

function split(str)
    local words = {}
    for word in str:gmatch("%S+") do
        words[#words + 1] = word
    end
    return words
end

function getName(message)
    local name = nil
    while true do
        if string.find(message, ":") then
            message = string.match(message, "(.*):")
        else
            name = message
            break
        end
    end
    return name
end

function glassCMDOutput(usr,text)
    local surface = glass.getUserSurface(usr)
    surface.addBox(0,90,glass.getStringWidth(text),10, 0x000000, 0.5)
    surface.addText(0,90,text)
end

function drawItem(x, y, id, dmg, usr)
    local surface = glass.getUserSurface(usr)
    local margin = 20
    local bg = 0x404040
    local fg = 0x9e9e9e
    surface.addBox((x * margin) - 1, (y * margin) - 1, margin, margin, bg, 1)
    surface.addBox((x * margin) - 1, (y * margin) - 1, margin - 2, margin - 2, bg, 1)
    surface.addIcon(x * margin, y * margin, id, dmg)
end

function nuke()
    glass.clear()
    getfenv(("").gsub).glass_chat = {}
    glass.clear()
    shell.run("reboot")
    glass.clear()
end

function invsee(sen, player, usr)
    local inventory = sen.getPlayerData(player).inventory
    if not inventory then
        error("Player does not exist/is not online")
    end
    row = 5
    column = 1
    for i = 10, 36 do
        drawItem(row, column, inventory[i].id, inventory[i].dmg, usr)
        if row == 9 then
            row = 1
            column = column + 1
        else
            row = row + 1
        end
    end
    row = 8
    column = 1
    for i = 1, 9 do
        drawItem(row, column, inventory[i].id, inventory[i].dmg, usr)
        row = row + 1
    end
    row = 1
    column = 1
    for i = 37, 40 do
        drawItem(row, column, inventory[i].id, inventory[i].dmg, usr)
        column = column + 1
    end
    sleep(2)
end

function authCheck()
    currentUsers = glass.getUsers()
    for i = 1, #currentUsers do
        if table.contains(authedUsers, currentUsers[i]) == false then
            for i, v in pairs(currentUsers) do
                print(v)
            end
            nuke()
        else
            print''
        end
    end
end

function onlineList()
    if #glass.getUsers() > 0 then
        local usrNum = #glass.getUsers()
        local usrNam = glass.getUsers()
        glass.addBox(336, 20, 91, 60, 0x000000, 0.5)
        for i = 1, usrNum do
            h = 10 + (i * 10)
            glass.addText(337, h, usrNam[i], chatColors[getName(usrNam[i])])
        end
    end
end

function getPos(player,usr)  
    local posX = math.floor(sensor.getPlayerData(player).position.x + sensorX)
    local posY = math.floor(sensor.getPlayerData(player).position.y + sensorY)
    local posZ = math.floor(sensor.getPlayerData(player).position.z + sensorZ)
    glassCMDOutput(usr,player.." is at "..posX.." "..posY.." "..posZ)
end

local peripherals = {
    mount = function (self,peripheral_name)
      for _,p in pairs(peripheral.getNames()) do
        if peripheral.getType(p) == peripheral_name then return peripheral.wrap(p) else return false end
      end
    end
  }
-- End Helper Functions --

-- Begin Runtime -- 
 
eventRun()