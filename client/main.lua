local QBCore = exports['qb-core']:GetCoreObject()
local CurrentCops = 0

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

local models = {
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03',
    'prop_fleeca_atm',
}
exports['qb-target']:AddTargetModel(models, {
    options = { 
      {
        type = "client",
        event = "serrulata-atmrobbery:client:robatm",
        label = 'Rob ATM',
      }
    },
    distance = 2.0,
})

RegisterNetEvent('serrulata-atmrobbery:client:robatm', function()
	local pos = GetEntityCoords(PlayerPedId())
    local hasItem = QBCore.Functions.HasItem(Config.HackItem)
        if CurrentCops >= Config.Cops then
            QBCore.Functions.TriggerCallback("serrulata:server:Cooldown",function(isCooldown)
            if not isCooldown then
                if hasItem then
                    local Player = GetEntityCoords(PlayerPedId())
                    exports["ps-dispatch"]:CustomAlert({
                        coords = pos,
                        message = "ATM Robbery",
                        dispatchCode = "10-31",
                        description = "Robbery In progress",
                        radius = 0,
                        sprite = 108,
                        color = 1,
                        scale = 0.7,
                        length = 3,
                    })
                    exports['ps-ui']:Scrambler(function(success)  
                        if success then
                            ClearPedTasksImmediately(PlayerPedId())
                            TriggerEvent('serrulata-atmrobbery:hacksuccess')
                        else
                            Citizen.Wait(1000)
                            ClearPedTasksImmediately(PlayerPedId())
                            TriggerEvent('serrulata-atmrobbery:hackfailed')
                        end
                    end, Config.HackType, Config.HackTime, 0)
                else
                    QBCore.Functions.Notify("You don't seem to have the right tools for this", "error")
                end
            else
                QBCore.Functions.Notify("not enough police", "error")
            end
        else
            QBCore.Functions.Notify("The ATM seems to have already been robbed")
        end
    end)
end)


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

RegisterNetEvent('serrulata-atmrobbery:hackfailed', function(data)
    QBCore.Functions.Notify("Seems Like you failed...")
	TriggerServerEvent("evidence:server:CreateFingerDrop", GetPedBoneCoords(PlayerPedId))
end)

RegisterNetEvent('serrulata-atmrobbery:hacksuccess', function(data)
	QBCore.Functions.Notify("You did it! Now Grab the cash and get out of here!")
    ClearPedTasksImmediately(PlayerPedId())
	ATMRobbery()
	TriggerServerEvent("serrulata-atmrobbery:server:success")	
    TriggerServerEvent('serrulata-atmrobbery:Server:timer')
end)
