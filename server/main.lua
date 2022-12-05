local QBCore = exports['qb-core']:GetCoreObject()
local CoolDown = false
local MoneyType = Config.MoneyType
local HackItem = Config.HackItem

RegisterServerEvent('serrulata-atmrobbery:server:timer', function()
    CoolDown = true
    local timer = Config.CoolDown * (60 * 1000)
    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            CoolDown = false
        end
    end
end)

QBCore.Functions.CreateCallback("serrulata-atmrobbery:server:Cooldown",function(source, cb)
    if CoolDown then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent("serrulata-atmrobbery:server:success",function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    Player.Functions.RemoveItem(HackItem, 1)
    Player.Functions.AddMoney(MoneyType, math.random(Config.PaymentMin, Config.PaymentMax))
end)
