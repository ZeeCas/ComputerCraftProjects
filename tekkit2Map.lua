-- Map Parsing for Tekkit 2 -- 
if not os.loadAPI("json") then
    shell.run("pastebin get StabXgNv json")
end
url = "http://tekkit2.craftersland.net:8120/up/world/world/"

function getPlayers()
    local r = http.get(url)
    local data = r.readAll()
    data = json.decode(data)['players']
    for i,v in pairs(data) do
        print(v['name'])
    end
end

getPlayers()