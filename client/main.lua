local QBCore = exports['qb-core']:GetCoreObject()
local CurrentCops = 0
local HackingTime = Config.HackingTime*1000

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

local models = {
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03',
    'prop_fleeca_atm'
}
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



RegisterNetEvent('serrulata-atmrobbery:robatm', function()
    TriggerEvent('serrulata-atmrobbery:police2')
    if CurrentCops >= Config.Cops then
        QBCore.Functions.TriggerCallback("serrulata-atmrobbery:server:Cooldown",function(isCooldown)
        if not isCooldown then
            TriggerEvent('animations:client:EmoteCommandStart', {"parkingmeter"})
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
                    TriggerEvent('serrulata-atmrobbery:hacksuccess')
                else
                    Wait(1000)
                    ClearPedTasksImmediately(PlayerPedId())
                    TriggerEvent('serrulata-atmrobbery:hackfailed')
                end
            end, Config.HackType, Config.HackTime, 0)
        else
            QBCore.Functions.Notify("The ATM seems to have already been robbed")
        end
        end)
    else
        QBCore.Functions.Notify("Not Enough Police", "error")
    end
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

RegisterNetEvent('serrulata-atmrobbery:police2', function(data)
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
end)

RegisterNetEvent('serrulata-atmrobbery:hacksuccess', function(data)
	QBCore.Functions.Notify("You did it! Now Grab the cash and get out of here!")
    ClearPedTasksImmediately(PlayerPedId())
	ATMRobbery()
    Wait(7500)
    TriggerServerEvent('serrulata-atmrobbery:Server:timer')
    if Config.MoneyType == true then
	    TriggerServerEvent("serrulata-atmrobbery:server:success")
    else
        TriggerServerEvent("serrulata-atmrobbery:server:success2")
    end
end)
