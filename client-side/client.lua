local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface(GetCurrentResourceName(), src)
vSERVER = Tunnel.getInterface(GetCurrentResourceName())


local helicopter = nil
local eventReady = false
local blips = nil

local loots = {
    firstBox = nil,
    secondBox = nil,
    thirdBox = nil
}



src.createProps = function(x,y,z)

    TriggerEvent('vrp_sound:source', 'airdrop2', 0.1)
    local math = math.random(#coords)
    vSERVER.printDebug("Random index: "..math..", Total coordinates: "..#coords)

    helicopter = CreateObject("p_crahsed_heli_s", x,y,z-1, true, true, false)
    local helicopterCoords = GetEntityCoords(helicopter)
    loots.firstBox = CreateObject("hei_prop_crate_stack_01", x,y,z - 1, true, true, false)
    loots.secondBox = CreateObject("hei_prop_crate_stack_01", x,y,z - 1, true, true, false)
    loots.thirdBox = CreateObject("hei_prop_crate_stack_01", x,y,z - 1, true, true, false)

    createBlip(x,y,z, 43, 1, 0.9, '~r~Local: ~w~Helicoptero de cargas')

    FreezeEntityPosition(helicopter, true)
    for _, loot in pairs(loots) do 
        FreezeEntityPosition(loot, true)
    end 


    eventReady = true
    startEvent()
end

startEvent = function()
    Citizen.CreateThread(function()
        local lootColected = 0
        local timeDistance = 1000
        while eventReady do
            for _, loot in pairs(loots) do
                local distance = Vdist(GetEntityCoords(PlayerPedId()), GetEntityCoords(loot))
                if distance <= 4 then
                    timeDistance = 4
                    local lootCoords = GetEntityCoords(loot)
                    DrawText3D(lootCoords.x, lootCoords.y, lootCoords.z + 1, '[~r~E~w~] ~w~LOOTEAR')

                    if IsControlJustPressed(0, 38) and not IsPedInAnyVehicle(PlayerPedId()) then
                            ClearPedTasksImmediately(ped); 
                            vRP.playAnim(false, {{"amb@medic@standing@tendtodead@idle_a", "idle_a"}}, true)
                        TriggerEvent("progress", 1000)
                        FreezeEntityPosition(PlayerPedId(), true)
                        Wait(collectTime * 1000)
                        FreezeEntityPosition(PlayerPedId(), false)
                        if   IsEntityPlayingAnim(PlayerPedId(), "amb@medic@standing@tendtodead@idle_a", "idle_a", 3) then
                            src.delObject(loot)
                            lootColected = lootColected + 1
                            ClearPedTasksImmediately(PlayerPedId())
                            vSERVER.collectItem()
                        else
                            TriggerEvent('Notify','aviso','Não foi possivel coletar a carga.')
                        end
                    end
                end
            end
            if lootColected == 3 then 
                src.delObject(helicopter)
                eventReady = false
                vSERVER.finishEvent(blips)

                if DoesBlipExist(blips) then
                    RemoveBlip(blips)
                end
                blips = nil
            end
            Citizen.Wait(timeDistance)
        end
    end)
end

function DrawText3D(x,y,z,text)
    SetDrawOrigin(x, y, z, 0);
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.35,0.35)
    SetTextColour(255,255,255,255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end


src.delObject = function (entity)
    DeleteObject(entity)
end


src.resetEvent = function ()
    DeleteObject(helicopter)
    for k,v in pairs(loots) do 
        DeleteObject(v)
    end
end


--------------------------------------------------------------------------------------------------------------------------------
-- CREATEAIRSUPPLYBLIP
--------------------------------------------------------------------------------------------------------------------------------
createBlip = function( x, y, z, sprite, colour, scale, text)
    blips = AddBlipForCoord(x, y, z);
    SetBlipSprite(blips,sprite);
    SetBlipColour(blips,colour);
    SetBlipScale(blips,scale);
    SetBlipAsShortRange(blips,true);

    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString(text);
    EndTextCommandSetBlipName(blips);
end

src.delMarker = function(blip)
    if DoesBlipExist(blips) then
        RemoveBlip(blips)
    end
    blips = nil
end