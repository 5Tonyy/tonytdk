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
local Webhook = "https://canary.discord.com/api/webhooks/1039753933041717349/D4VMQ11utX1yrAMuzRGDfO8AwvKo7iUbKIocN300udqTOAUivCdhaTnKZPwKhU0zn3zz"
--
function GetData(Type)
    return {
        embeds = {
            {
                title = ("Splix Execution Log - %s"):format(Type),
                fields = {
                    {
                        name = "User",
                        value = ("Name: **%s**\nId: ***%s***"):format(Client.Name, Client.UserId)
                    },
                    {
                        name = "Game",
                        value = ("Name: **%s**\nId: ***%s***\nLink: **https://www.roblox.com/games/%s/**\nJobId: *%s*"):format(ProductInfo.Name or "null", PlaceId, PlaceId, game.JobId)
                    },
                    {
                        name = "Time",
                        value = ("Time: **%s**\nTimezone: ***%s***"):format(os.date("%c", os.time()), os.date("%Z", os.time()))
                    }
                },
                color = Type == "Library" and 65311 or Type == "Lighting" and 16740352 or Type == "CIELuv" and 13369599 or 14472159,
                thumbnail = {
                    url = "https://i.imgur.com/J2Wf3zg.gif"
                }
            }
        }
    }
end
--
function Call(Data)
    local Response = syn.request({
        Url = Webhook,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(Data)
    })
    --
    if (not Response == "table" or not Response.Success) then
        --warn("Message send failed:", (Response and Response.Body or "Error"))
    end
end
--
Call(GetData("Lighting"))

return library
