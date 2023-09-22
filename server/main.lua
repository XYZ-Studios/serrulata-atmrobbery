local QBCore = exports['qbx-core']:GetCoreObject() lib.locale() local HackItem = Config.HackItem
local ATM = {} local CoolDown = {} 


function IsATMInTable(atmObjectNetId)
    for i, v in ipairs(ATM) do
        if v == atmObjectNetId then
            return true
        end
    end
    return false
end

RegisterServerEvent('serrulata-atmrobbery:server:startRobbery', function(atmObjectNetId)
    local src = source
    local objecid = atmObjectNetId

    if not IsATMInTable(objecid) then
        table.insert(ATM, objecid)

        print('[^2Serrulata ATM Robbery^7] ATM with ID ' .. objecid .. ' is now in the table')

        TriggerEvent('serrulata-atmrobbery:server:timer', atmObjectNetId)
        TriggerClientEvent('serrulata-atmrobbery:client:robbingatming', src, atmObjectNetId)
    else
        if CoolDown[objecid] then
            TriggerClientEvent('ox_lib:notify', src, {description = locale('atm_cooldownmsg'), type = 'error'})
            TriggerEvent('serrulata-atmrobbery:server:giveitemback')
        else
            print('[^2Serrulata ATM Robbery^7] ATM with ID ' .. objecid .. ' is already in the table.')
        end
    end

    for i, v in ipairs(ATM) do
        print('[^2Serrulata ATM Robbery^7] ATM with ID ' .. v .. ' is now in the table.')
    end
end)

RegisterServerEvent('serrulata-atmrobbery:server:timer', function(atmObjectNetId)
    if CoolDown[atmObjectNetId] == nil then
        CoolDown[atmObjectNetId] = true
        local timer = Config.CoolDown * (60 * 1000)
        while timer > 0 do
            Wait(1000)
            timer = timer - 1000
        end
        CoolDown[atmObjectNetId] = false
        print('[^2Serrulata ATM Robbery^7] ATM with ID ' .. atmObjectNetId .. ' is now available.')

        for i, v in ipairs(ATM) do
            if v == atmObjectNetId then
                table.remove(ATM, i)
                print('[^2Serrulata ATM Robbery^7] ATM with ID ' .. atmObjectNetId .. ' removed from table.')
                break 
            end
        end
    end
end)

-- Reward System  / Item Removal
RegisterNetEvent("serrulata-atmrobbery:server:reward",function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', math.random(Config.PaymentMin, Config.PaymentMax))
    TriggerClientEvent('ox_lib:notify', src, {description = locale('success_money'), type = 'success'})
end)

RegisterNetEvent('serrulata-atmrobbery:server:removeitem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(HackItem, 1)
end)

RegisterNetEvent('serrulata-atmrobbery:server:giveitemback', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(HackItem, 1)
end)

-- Console Events
-- Starting Events 
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
       print('[^2Serrulata ATM Robbery^7] Started ^2Successfully^7')
    end
 end)
 
 AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
         print('[^2Serrulata ATM Robbery^7] Stopped ^2Successfully^7')
    end
 end)