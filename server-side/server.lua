local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface(GetCurrentResourceName(), src)
vCLIENT = Tunnel.getInterface(GetCurrentResourceName())


function SendWebhookMessage(webhook,message)
    if webhook ~= nil and webhook ~= "" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end


RegisterCommand("helicrash",function(source,args,rawCommand)
    local source = source
    local user_id = vRP.getUserId(source)
    local users = vRP.getUsers()

    if not vRP.hasPermission(user_id, permAdmin) then
        return
    end
    vCLIENT.createProps(-1)
    TriggerClientEvent('Notify',-1,'HELICRASH','Um helicóptero de carga foi interceptado, siga as cordenadas enviadas em seu gps para coletar as cargas.')
end)



src.syncDelObjects = function(entity)
    for k,v in pairs(vRP.getUsers()) do
        vCLIENT.delObject(-1,entity)
    end
end

src.collectItem = function()
    local source = source 
    local user_id = vRP.getUserId(source)
    local math = math.random(#items)
    local identity = vRP.getUserIdentity(user_id)
    local itemsReceived = ''
    local resultItems = {}

    for k,v in pairs(items[math]) do

        if v.money then 
            vRP.giveMoney(user_id,v.amount)
        else
            vRP.giveInventoryItem(user_id,v.item,v.amount)
        end

        table.insert(resultItems,{ name = vRP.itemNameList(v.item), amount = vRP.format(v.amount) })
        itemsReceived = itemsReceived..' '..vRP.format(v.amount)..' '..vRP.itemNameList(v.item)..''

    end
    SendWebhookMessage(webhook,"```prolog\n[ID]: "..user_id.." "..identity.name.." "..identity.firstname.." \n[===========REVINDICOU O HELI-CRASH ==========]\n[ITENS]: "..itemsReceived..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
    TriggerClientEvent('chatMessage', -1, '[Heli-Crash]  '..identity.name.." "..identity.firstname .. " [" .. user_id .. "]", {255, 0, 0}, 'Coletou '..itemsReceived..' ')
end


src.finishEvent = function(blip)
    vCLIENT.delMarker(-1,blip)
end


src.printDebug = function(info)
    print(info)
end



RegisterCommand("resetcrash",function(source,args,rawCommand)
    local source = source
    local user_id = vRP.getUserId(source)
    local users = vRP.getUsers()

    if not vRP.hasPermission(user_id, permAdmin) then
        return
    end
    vCLIENT.delMarker(-1)
    vCLIENT.resetEvent(-1)
end)
