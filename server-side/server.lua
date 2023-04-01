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



src.synchronizeDeletedObjects = function(entity)
    for k,v in pairs(vRP.getUsers()) do
        vCLIENT.delObject(-1,entity)
    end
end

src.collectRandomItem = function()
    local source = source 
    local user_id = vRP.getUserId(source)
    local randomItemIndex = math.random(#items)
    local identity = vRP.getUserIdentity(user_id)
    local itemsReceived = ''
    local resultItems = {}
  
    local function giveItem(item)
      if item.money then 
        vRP.giveMoney(user_id, item.amount)
      else
        vRP.giveInventoryItem(user_id, item.item, item.amount)
      end
    end
  
    local function addItemToResultList(item)
      table.insert(resultItems, { name = vRP.itemNameList(item.item), amount = vRP.format(item.amount) })
      itemsReceived = itemsReceived..' '..vRP.format(item.amount)..' '..vRP.itemNameList(item.item)
    end
  
    for k, item in pairs(items[randomItemIndex]) do
      giveItem(item)
      addItemToResultList(item)
    end
  
    local message = string.format(
      "```prolog\n[ID]: %s %s %s\n[===========REVINDICOU O HELI-CRASH ==========]\n[ITENS]: %s %s\r```",
      user_id,
      identity.name,
      identity.firstname,
      itemsReceived,
      os.date("[Data]: %d/%m/%Y [Hora]: %H:%M:%S")
    )
  
    SendWebhookMessage(webhook, message)
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