local QBCore = require "client.modules.core" local Config = require "client.modules.config" lib.locale() isLoggedIn = LocalPlayer.state.isLoggedIn
local CurrentCops = 0
local HackingTime = Config.HackingTime*1000

local models = {
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03',
    'prop_fleeca_atm'
}

if Config.Target == 'qb-target' then 
    exports['qb-target']:AddTargetModel(models, {
        options = {
            {
            type = "client",
            event = "serrulata-atmrobbery:client:robatm",
            icon = 'fa-sharp fa-solid fa-arrow-up-from-bracket',
            label = locale('target_label'),
            item = Config.HackItem,
            }
        },
      distance = 2.5,
    })

elseif Config.Target == 'ox-target' then 
    local options = {
        {event = 'serrulata-atmrobbery:client:robatm', icon = 'fa-sharp fa-solid fa-arrow-up-from-bracket', label = locale('target_label'), distance = 2.0,
            canInteract = function(entity, distance, coords, name, bone)
                local item = QBCore.Functions.HasItem(Config.HackItem)
                if item then
                    return true
                else
                    return false
                end
            end
        },
    }
    exports.ox_target:addModel(models, options)
end

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

--  Functions
function Dispatching()
    if Config.Dispatch == 'ps-dispatch' then 
        exports["ps-dispatch"]:CustomAlert({
            coords = GetEntityCoords(cache.ped()),
            message = locale('dispatch_msg'),
            dispatchCode = "10-31",
            description = locale('dispach_dec'),
            radius = 0,
            sprite = 108,
            color = 1,
            scale = 0.7,
            length = 3,
        })

    elseif Config.Dispatch == 'cd_dispatch' then 
        local data = exports['cd_dispatch']:GetPlayerInfo()

        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = {'police'}, 
            coords = data.coords,
            title = '10-31 - Attempted ATM Robbery',
            message = 'A '..data.sex..' robbing a ATM at '..data.street, 
            flash = 0,
            unique_id = tostring(math.random(0000000,9999999)),
            blip = {
                sprite = 108, 
                scale = 0.7, 
                colour = 1,
                flashes = false, 
                text = '911 - Attempted ATM Robbery',
                time = (3*60*1000),
                sound = 1,
            }
        })
    elseif Config.Dispatch == 'custom' then 
        print('Insert your dispatch code here')
        print('Am at line 72 in client/main.lua')
    end
end


function AnimationRun()
    QBCore.Functions.Progressbar("power_hack", "Taking money...", (7500), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@ornate_bank@grab_cash_heels",
        anim = "grab",
        flags = 16,
    }, {}, function()
        StopAnimTask(cache.ped, "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
		SetPedComponentVariation((cache.ped), 5, 47, 0, 0)

        if Config.Emotes == 'scully_emotemenu' then
            exports.scully_emotemenu:cancelEmote()
        elseif Config.Emotes == 'custom' then 
            print('Insert your emote here')
            print('Am at line 90 in client/main.lua')
        end

    end, function()

        if Config.Emotes == 'scully_emotemenu' then
            exports.scully_emotemenu:cancelEmote()
        elseif Config.Emotes == 'custom' then 
            print('Insert your emote here')
            print('Am at line 99 in client/main.lua')
        end

        StopAnimTask(cache.ped, "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
    end)
end

function ATMRobbery()
    local playerPed = cache.ped
    local playerCoords = GetEntityCoords(GetPlayerPed(-1))
    local closestATMObject = nil
    local closestDistance = 999.0 

    for _, model in ipairs(models) do
        local atmObject = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, GetHashKey(model), false, false, false)

        if DoesEntityExist(atmObject) then
            local distance = #(playerCoords - GetEntityCoords(atmObject))

            if distance < closestDistance then
                closestATMObject = atmObject
                closestDistance = distance
            end
        end
    end

    if closestATMObject then
        local atmObjectNetId = NetworkGetNetworkIdFromEntity(closestATMObject)

        TriggerServerEvent('serrulata-atmrobbery:server:startRobbery', atmObjectNetId)
    else
        print('[^1Serrulata ATM Robbery^7] Error: No ATM found nearby')
    end
end

RegisterNetEvent('serrulata-atmrobbery:client:robbingatming', function(isCoolDown)
    local src = source
    TriggerServerEvent('serrulata-atmrobbery:server:removeitem')
    
    exports['ps-ui']:Scrambler(function(success)
        if success then
            AnimationRun()
            TriggerServerEvent('serrulata-atmrobbery:server:reward')
        else
            Dispatching()
            TriggerServerEvent('serrulata-atmrobbery:server:giveitemback')
        end
    end, Config.HackType, Config.HackTime, 0)
end)

RegisterNetEvent('serrulata-atmrobbery:client:robatm', function()
    if Config.Framework == 'QBCore' or 'QBX' then 
        if CurrentCops >= Config.Cops then

            if Config.Emotes == 'scully_emotemenu' then
                exports.scully_emotemenu:playEmoteByCommand('parkingmeter')
            elseif Config.Emotes == 'custom' then 
                print('Insert your emote here')
                print('Am at line 123 in client/main.lua')
            end

            if lib.progressBar({duration = HackingTime, label = locale('progbar_label'), useWhileDead = false, canCancel = true, disable = {car = true,},
            
            }) then ATMRobbery() else print('Canceled') end

        else
            lib.notify({title = locale('no_cops'), type = 'error'})
        end
    end
end)