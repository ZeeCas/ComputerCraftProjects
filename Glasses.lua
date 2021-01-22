-- -- TODO:
-- 1.Clean-up -- Meh
-- 2.Turt Control
-- 3.Ender requester. -- Done 
glass = peripheral.wrap("right")
sensor = peripheral.wrap("top")
controller = peripheral.wrap("left")
maxLines = 7
getfenv(("").gsub).glass_chat = {}
messages = getfenv(("").gsub).glass_chat
authedusers = {"ZeeDerpMaster", "Sleetyy", "icedfrappuccino", "korvuus", "soundsofmadness", "mpfthprblmtq",""}
staffList = {"DragonSlayer","eytixis","iim_wolf"}

chatColors = {}
chatColors["ZeeDerpMaster"] = 0x3C93C2
chatColors["Sleetyy"] = 0xFFFFFF
chatColors["mpfthprblmtq"] = 0x800080
chatColors["SoundsOfMadness"] = 0x883388

--
for i = 1, maxLines do
    table.insert(messages, "$$$$")
end
--
function startNewNew()
    while true do
        authCheck()
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
        sleep(0.1)
    end
end
-----
function listener()
    while true do
        authCheck()
        local tEvent = {os.pullEventRaw()}
        if tEvent[1] == "chat_command" then
            cmd = split(tEvent[2])
            user = tostring(tEvent[3])
            parseCMD(cmd, user)
        end
    end
end
--
function parseCMD(cmd, usr)
    local cmd_lower = cmd[1]:lower()
    if cmd_lower == "maxlines" then
        for i = 1, tonumber(maxLines) do
            table.remove(messages, 1)
        end
        maxLines = tonumber(cmd[2])
        for i = 1, tonumber(maxLines) do
            table.insert(messages, "$$$$")
        end
    elseif cmd_lower == "chatcolor" then
        chatColors[usr] = loadstring("return " .. cmd[2])()
    elseif cmd_lower == "nuke" then
        nuke()
    elseif cmd_lower == "invsee" then
        local surface = glass.getUserSurface(user)
        invsee(sensor, cmd[2], user)
        sleep(3)
        surface.clear()
    elseif cmd_lower == "request" then
        controller.extractItem({id=tonumber(cmd[2]),dmg=tonumber(cmd[3]),qty=tonumber(cmd[4])}, "south")
    elseif cmd_lower == "auth" then 
        table.insert(authedusers,cmd[2])
    elseif cmd_lower == "deauth" then
        local index={}
        for k,v in pairs(authedusers) do
            index[v]=k
        end
        table.remove(authedusers,print(index[cmd[2]]))
    elseif cmd_lower == "whereis" then
        local surface = glass.getUserSurface(user)
        if table.contains(staffList, cmd[2]) then 
            glassCMDOutput(user,"You cannot track that player")
            sleep(2)
            surface.clear()
        else
            getPos(cmd[2],user)
            sleep(3)
            surface.clear()
        end
    else
        local cmd_msg = table.concat(cmd, " ")
        if glass.getStringWidth(cmd_msg) > 325 then
            cutMsgOne = string.sub(cmd_msg, 1, 48)
            cutMsgTwo = string.sub(cmd_msg, 49, string.len(cmd_msg))
            table.insert(messages, usr .. ": " .. cutMsgOne)
            table.insert(messages, usr .. ": " .. cutMsgTwo)
            table.remove(messages, 1)
            table.remove(messages, 1)
        else
            table.insert(messages, usr .. ": " .. cmd_msg)
            table.remove(messages, 1)
        end
    end
end
--
function getPos(player,usr)
    local xOff = 4877
    local yOff = 13
    local zOff = 3574
    local posX = math.floor(sensor.getPlayerData(player).position.x + xOff)
    local posY = math.floor(sensor.getPlayerData(player).position.y + yOff)
    local posZ = math.floor(sensor.getPlayerData(player).position.z + zOff)
    glassCMDOutput(usr,player.." is at "..posX.." "..posY.." "..posZ)
end
--
function glassCMDOutput(usr,text)
    local surface = glass.getUserSurface(usr)
    surface.addBox(336,80,surface.getStringWidth(text),10, 0x000000, 0.5)
    surface.addText(336,80,text)
end
--
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
--
function authCheck()
    currentUsers = glass.getUsers()
    for i = 1, #currentUsers do
        if table.contains(authedusers, currentUsers[i]) == false then
            for i, v in pairs(currentUsers) do
                print(v)
            end
            nuke()
        else
            print''
        end
    end
end
--
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
--
function table.contains(tab, ele)
    for i = 1, #tab do
        if tab[i] == ele then
            return true
        end
    end
    return false
end
--
function split(str)
    local words = {}
    for word in str:gmatch("%S+") do
        words[#words + 1] = word
    end
    return words
end
--
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
--
function nuke()
    getfenv(("").gsub).glass_chat = {}
    glass.clear()
    shell.run("reboot")
end
--
function drawItem(x, y, id, dmg, usr)
    local surface = glass.getUserSurface(usr)
    local margin = 20
    local bg = 0x404040
    local fg = 0x9e9e9e
    surface.addBox((x * margin) - 1, (y * margin) - 1, margin, margin, bg, 1)
    surface.addBox((x * margin) - 1, (y * margin) - 1, margin - 2, margin - 2, bg, 1)
    surface.addIcon(x * margin, y * margin, id, dmg)
end
--
parallel.waitForAny(listener, startNewNew)
--