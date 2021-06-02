mount = function (peripheral_type) -- Wraps a peripheral
    for _,location in pairs(peripheral.getNames()) do
        if peripheral.getType(location) == peripheral_type then 
            return peripheral.wrap(location) 
        end
    end
    return false
end

-- Initializes Main Variables
glass = mount("openperipheral_glassesbridge")
sensor = mount("sensor")
controller = mount("appeng_me_tilecontroller")
lamp = mount("modem")
maxLines = 7
messages = {}
authedusers = {"ZeeDerpMaster", "Sleetyy","Rapoosa","DragonSlayer"}
trackOnTab = {}
staffList = {"DragonSlayer","eytixis","iim_wolf","oozoozami"}
trackedPlayers = {}
sen_pos = {x=4872,y=118,z=3678}
-- Creates chat colors.
chatColors = {}
chatColors["ZeeDerpMaster"] = 0x3C93C2
chatColors["Sleetyy"] = 0xFFFFFF
chatColors["mpfthprblmtq"] = 0x800080
chatColors["SoundsOfMadness"] = 0x883388
chatColors["Rapoosa"] = 0xE55934
-- Initializes message table
for i = 1, maxLines do
    table.insert(messages, "$$$$")
end
--
function initialize() -- Main running function. displays messages on glasses.
    while true do
        authCheck()
        trackOn()
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
--
function listener() -- Listens for incoming chat commands
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
function parseCMD(cmd, usr) -- Parses incoming chat commands using a terrible nested if
    local surface = glass.getUserSurface(usr)
    if not cmd then 
        sleep(.01)
    end
    local cmd_lower = cmd[1]:lower()
    if cmd_lower == "chatcolor" then -- Changes chat color for the user
        chatColors[usr] = loadstring("return " .. cmd[2])()
        glassCMDOutput(usr,"Chat color is now "..cmd[2])
        sleep(2)
        surface.clear()
    elseif cmd_lower == "nuke" then -- Clears chat and reboots PC
        nuke()
    elseif cmd_lower == "invsee" then -- Shows selected player's inventory for 3 seconds
        invsee(sensor, cmd[2], usr)
        sleep(3)
        surface.clear()
    elseif cmd_lower == "request" then -- Requests an item from an ae system to an inventory
        controller.extractItem({id=tonumber(cmd[2]),dmg=tonumber(cmd[3]),qty=tonumber(cmd[4])}, "south")
        glassCMDOutput(usr,"Requested "..cmd[4].." of "..cmd[2])
        sleep(2)
        surface.clear()
    elseif cmd_lower == "auth" then  -- Adds a user to authorized user list
        table.insert(authedusers,cmd[2])
        glassCMDOutput(user,"Added "..cmd[2].." to authorized users.")
        sleep(2)
        surface.clear()
    elseif cmd_lower == "deauth" then -- Removes a user from the authorized user list
        local index={}
        for k,v in pairs(authedusers) do
            index[v]=k
        end
        table.remove(authedusers,print(index[cmd[2]]))
        glassCMDOutput(usr,"Removed "..cmd[2].." from authorized users.")
        sleep(2)
        surface.clear()
    elseif cmd_lower == "whereis" then -- Shows coordinates of selected player for 2 seconds
        if table.contains(staffList, cmd[2]) then 
            glassCMDOutput(usr,"You cannot track that player")
            sleep(2)
            surface.clear()
        else
            getPos(cmd[2],usr)
            sleep(3)
            surface.clear()
        end
    elseif cmd_lower == "track" then -- Adds selected player to an updating coordinates output
        table.insert(trackedPlayers,cmd[2])
        table.insert(trackOnTab,usr)
    elseif cmd_lower == "clear" then -- Clears user surface
        surface.clear()
    elseif cmd_lower == "lamp" then
        for _,v in pairs(lamp.getNamesRemote()) do
            lamp.callRemote(v,"setColor",tonumber(cmd[2]))
        end
    elseif cmd_lower == "help" then -- Displays possible commands
        glassCMDOutput(user,"Commands are : chatcolor, nuke, invsee, request, auth, deauth, whereis, lamp, track, and clear")
        sleep(3)
        surface.clear()
    else
        local cmd_msg = table.concat(cmd, " ")
        local totalmsg = usr .. ": " .. cmd_msg
        if glass.getStringWidth(totalmsg) > 325 then
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
function getPos(player,usr) -- Displays position of given player to a user
    if not player then
        sleep(.01)
    end
    glassCMDOutput(usr,player..': x '..math.ceil(sensor.getPlayerData(player).position.x+sen_pos.x)..' y '..math.ceil(sensor.getPlayerData(player).position.y+sen_pos.y)..' z '..math.ceil(sensor.getPlayerData(player).position.z+sen_pos.z),0xFF1100)

end
--
function track(player,usr,pos) -- Handles the placement and updating of users in the tracked list
    if not player then
        sleep(.01)
    end
    local pos = 80 + pos  
    local surface = glass.getUserSurface(usr)
    surface.addText(0,pos,player..': x '..math.ceil(sensor.getPlayerData(player).position.x+sen_pos.x)..' y '..math.ceil(sensor.getPlayerData(player).position.y+sen_pos.y)..' z '..math.ceil(sensor.getPlayerData(player).position.z+sen_pos.z),0xFF1100)
end
--
function trackOn() -- Shows tracked players to users who enable it
    for i,v in pairs(trackOnTab) do
        local surface = glass.getUserSurface(trackOnTab[i])
        for i,v in pairs(trackedPlayers) do
            surface.clear()
            pos = 80
            track(v,trackOnTab[i],pos)
            pos = pos + 10
        end
    end
end
--
function glassCMDOutput(usr,text)  -- Displays given text to a user surface
    local surface = glass.getUserSurface(usr)
    surface.addBox(0,90,glass.getStringWidth(text),10, 0x000000, 0.5)
    surface.addText(0,90,text)
end
--
function onlineList() -- Displays the players currently wearing ChatGlass
    if #glass.getUsers() > 0 then
        local usrNum = #glass.getUsers()
        local usrNam = glass.getUsers()
        glass.addBox(336, 20, 91, 70, 0x000000, 0.5)
        for i = 1, usrNum do
            h = 10 + (i * 10)
            glass.addText(337, h, usrNam[i], chatColors[getName(usrNam[i])])
        end
    end
end
--
function authCheck() -- Ensures all players wearing ChatGlass are contained within authedusers
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

--
function invsee(sen, player, usr) -- Handles the displaying of items from a given players inventory to a user
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
function table.contains(tab, ele) -- Checks if an element : ele , is in a table : tab
    for i = 1, #tab do
        if tab[i] == ele then
            return true
        end
    end
    return false
end
--
function split(str) -- Splits a string on spaces
    local words = {}
    for word in str:gmatch("%S+") do
        words[#words + 1] = word
    end
    return words
end
--
function getName(message) -- Returns the name from a string containing a username followed me a colon and a message
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
function nuke() -- Clears all glasses, clears messages table, and reboots.
    glass.clear()
    messages = {}
    glass.clear()
    shell.run("reboot")
    glass.clear()
end
--
function drawItem(x, y, id, dmg, usr) -- Draws a given item on the players surface.
    local surface = glass.getUserSurface(usr)
    local margin = 20
    local bg = 0x404040
    local fg = 0x9e9e9e
    surface.addBox((x * margin) - 1, (y * margin) - 1, margin, margin, bg, 1)
    surface.addBox((x * margin) - 1, (y * margin) - 1, margin - 2, margin - 2, bg, 1)
    surface.addIcon(x * margin, y * margin, id, dmg)
end
--
function indexOf(item,table) -- Returns the idex of item in a table
    local index={}
    for k,v in pairs(table) do
       index[v]=k
    end
    return index[item]
end
--
parallel.waitForAny(listener, initialize) -- Fake multithreading
--