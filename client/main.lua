local QBCore = exports['qb-core']:GetCoreObject()
local CurrentCops = 0
local HackingTime = Config.HackingTime*1000

local models = {
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03',
    'prop_fleeca_atm'
}


RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

---------------------------------------------------------------------------------------# Target #---------------------------------------------------------------------------------------
if Config.Framework == 'QBCore' then
    exports['qb-target']:AddTargetModel(models, {
        options = {
            {
            type = "client",
            event = "serrulata-atmrobbery:robatm",
            icon = 'fa-sharp fa-solid fa-arrow-up-from-bracket',
            label = 'Rob ATM',
            item = Config.HackItem,
            }
        },
      distance = 2.5,
    })

elseif Config.Framework == 'OX' then

    local options = {

        {
            event = 'serrulata-atmrobbery:robatm',
            icon = 'fa-sharp fa-solid fa-arrow-up-from-bracket',
            label = 'Rob ATM',
            distance = 1.0,
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
--------------------------------------------------------------------------------------- # Functions # ---------------------------------------------------------------------------------------
function DispatchCalled()
    if Config.Dispatch == 'ps-dispatch' then
         
        exports["ps-dispatch"]:CustomAlert({
            coords = GetEntityCoords(PlayerPedId()),
            message = "Attempted ATM Robbery",
            dispatchCode = "10-31",
            description = "Attempted Robbery",
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

    end
end

function hacksuccess()

    QBCore.Functions.Notify("You did it! Now Grab the cash and get out of here!")

    ClearPedTasksImmediately(PlayerPedId())

    ATMRobbery()

    DispatchCalled()

    Wait(7500)

    TriggerServerEvent('serrulata-atmrobbery:server:timer')

    if Config.MoneyType == true then

	    TriggerServerEvent("serrulata-atmrobbery:server:success")

    else

        TriggerServerEvent("serrulata-atmrobbery:server:success2")

    end
end

function hackfailed(data)
    
    QBCore.Functions.Notify("Seems Like you failed...", 'error')

	-- TriggerServerEvent("evidence:server:CreateFingerDrop", GetPedBoneCoords(PlayerPedId)) -- questionable  event if it works

    TriggerServerEvent('serrulata-atmrobbery:server:giveitemback')

    DispatchCalled()
    
end

function ATMRobbery()
    Anim = true
    QBCore.Functions.Progressbar("power_hack", "Taking money...", (7500), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@ornate_bank@grab_cash_heels",
        anim = "grab",
        flags = 16,
    }, {
       model = "prop_cs_heist_bag_02",
       bone = 57005,
       coords = { x = -0.005, y = 0.00, z = -0.16 },
       rotation = { x = 250.0, y = -30.0, z = 0.0 },


    }, {}, function()
        Anim = false
        StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
		SetPedComponentVariation((PlayerPedId()), 5, 47, 0, 0)

    end, function()
        Anim = false
        StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
		
    end)
end

---------------------------------------------------------------------------------------# Events #---------------------------------------------------------------------------------------
RegisterNetEvent('serrulata-atmrobbery:robatm', function()
    if Config.Framework == 'QBCore' or 'OX' then
        
        if CurrentCops >= Config.Cops then

            QBCore.Functions.TriggerCallback("serrulata-atmrobbery:server:Cooldown",function(isCooldown)
                if not isCooldown then

                    TriggerEvent('animations:client:EmoteCommandStart', {"parkingmeter"})
                    TriggerServerEvent('serrulata-atmrobbery:server:removeitem')

                    QBCore.Functions.Progressbar('cnct_elect', 'Hacking the ATM...', HackingTime, false, true, {
                        disableMovement = true,

                        disableCarMovement = true,

                        disableMouse = false,

                        disableCombat = true,

                    }, {}, {}, {}, function()

                end)

                Wait(HackingTime) 

                TriggerEvent('animations:client:EmoteCommandStart', {"c"})

                exports['ps-ui']:Scrambler(function(success)

                    if success then

                        ClearPedTasksImmediately(PlayerPedId())

                        hacksuccess()
                        
                    else

                        Wait(1000)

                        ClearPedTasksImmediately(PlayerPedId())

                        hackfailed()

                    end
                end, Config.HackType, Config.HackTime, 0)

            else

                QBCore.Functions.Notify("The ATM seems to have already been robbed")

            end

        end)

        else
            QBCore.Functions.Notify("Not Enough Police", "error")
        end

    end

end)
---------------------------------------------------------------------------------------# Start/Stop Resource #---------------------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
      print('Serrulata ATM Robbery: Started')
   end
end)

AddEventHandler('onResourceStop', function(resource)
   if resource == GetCurrentResourceName() then
        print('Serrulata ATM Robbery: Stopped')
   end
end)