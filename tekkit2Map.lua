-- Map Parsing for Tekkit 2 -- 
url = "http://tekkit2.craftersland.net:8120/up/world/world/"

function extractLiveMap()
    local t = {}
    local name, armor, account, health, world, x, y, z
    local a = 0
    local b = 0
    local ts
    fh = http.get(url)
    s = fh.readAll()  
    fh.close()
    ts = string.find(s, "{\"timestamp\":(%d+),")
    -- Extract out the player information
    players = {}
    playerCount = 0
    local a = 0
    local b = 0
    local name, armor, account, health, z, y, world, x
    while (true) do
        a, b, name, armor, account, health, z, y, world, x = string.find(s, "\"sort\":0,\"name\":\"([^\"]+)\",\"armor\":(%d+),\"account\":\"([^\"]+)\",\"health\":(%d+),\"type\":\"player\",\"z\":([-0-9.]+),\"y\":([-0-9.]+),\"world\":\"([^\"]+)\",\"x\":([-0-9.]+)", b + 1)
        if (a == nil) then
            break
        end
    if world == "DIM-1" then
        world = "nether"
    elseif world == "DIM-28" then
        world = "moon"
    elseif world == "DIM-29" then
        world = "mars"
    elseif world == "-some-other-bogus-world-" then
        world = "camouflage"
    elseif world:sub(1, 8) == "DIM_MYST" then
        world = "myst_"..world:sub(9)
    elseif world:sub(1, 16) == "DIM_SPACESTATION" then
        world = "spacestation_"..world:sub(17)
    end
    worlds[world] = 1
    players[account] = {}
    players[account].armor = tonumber(armor)
    players[account].name = name
    players[account].health = tonumber(health)
    players[account].world = world
    local yn = tonumber(y)
    if yn > 999 then
    yn = 999
    end
    players[account].loc = vector.new(tonumber(x), yn, tonumber(z))
    playerCount = playerCount + 1
    end
end

extractLiveMap()
for i,v in pairs(players) do
    print(i,v)
end