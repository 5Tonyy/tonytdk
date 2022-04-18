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
return library
