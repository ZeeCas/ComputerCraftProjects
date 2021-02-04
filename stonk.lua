-- Usage : pastebin get GRtBJVtW stock, stock amc,gme,aapl etc
-- Setup : Advanced Computer, 4x3  Advanced Monitors, place computer on the left of the monitors
-- run the command above, then run "stock", then run it again with you stocks seperated
-- by commas
args = {...}
mon = peripheral.wrap("left")
mon.setTextScale(1)

if not os.loadAPI("json") then
    shell.run("pastebin get StabXgNv json")
end

request = http.get("https://query1.finance.yahoo.com/v7/finance/quote?&lang=en-US&region=US&corsDomain=finance.yahoo.com&symbols="..args[1]).readAll()
decoded = json.decode(request)

while true do
    for i,v in pairs(decoded['quoteResponse']['result']) do
        request = http.get("https://query1.finance.yahoo.com/v7/finance/quote?&lang=en-US&region=US&corsDomain=finance.yahoo.com&symbols="..args[1]).readAll()
        decoded = json.decode(request)
        if decoded['quoteResponse']['result'][i]['marketState'] == "REGULAR" then
            if string.sub(decoded['quoteResponse']['result'][i]['regularMarketChange'],1,1) == "-" then
                mon.setTextColor(colors.red)
                mon.write(decoded['quoteResponse']['result'][i]['symbol'].."  ".."$"..decoded['quoteResponse']['result'][i]['regularMarketPrice'].."  "..decoded['quoteResponse']['result'][i]['regularMarketChange'].."  "..decoded['quoteResponse']['result'][i]['regularMarketChangePercent'])
            else
                mon.setTextColor(colors.green)
                mon.write(decoded['quoteResponse']['result'][i]['symbol'].."  ".."$"..decoded['quoteResponse']['result'][i]['regularMarketPrice'].."  "..decoded['quoteResponse']['result'][i]['regularMarketChange'].."  "..decoded['quoteResponse']['result'][i]['regularMarketChangePercent'])
            end
        elseif decoded['quoteResponse']['result'][i]['marketState'] == "PREPRE" or decoded['quoteResponse']['result'][i]['marketState'] == "POSTPOST" then
            if string.sub(decoded['quoteResponse']['result'][i]['postMarketChange'],1,1) == "-" then
                mon.setTextColor(colors.red)
                mon.write(decoded['quoteResponse']['result'][i]['symbol'].."  ".."$"..decoded['quoteResponse']['result'][i]['postMarketPrice'].."  "..decoded['quoteResponse']['result'][i]['postMarketChange'].."  "..decoded['quoteResponse']['result'][i]['postMarketChangePercent'])
            else
                mon.setTextColor(colors.green)
                mon.write(decoded['quoteResponse']['result'][i]['symbol'].."  ".."$"..decoded['quoteResponse']['result'][i]['postMarketPrice'].."  "..decoded['quoteResponse']['result'][i]['postMarketChange'].."  "..decoded['quoteResponse']['result'][i]['postMarketChangePercent'])
            end
        end  
        mon.setCursorPos(1,i)
    end
    sleep(5)
    mon.clear()
end