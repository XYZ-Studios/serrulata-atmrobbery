local QBCore = exports['qb-core']:GetCoreObject()

local MoneyType = Config.MoneyType
local HackItem = Config.HackItem
local CoolDown = false


--------------------------------------------------------------------------------------- # Events # ---------------------------------------------------------------------------------------
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

RegisterNetEvent("serrulata-atmrobbery:server:success",function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    Player.Functions.AddMoney('cash', math.random(Config.PaymentMin, Config.PaymentMax))
end)

RegisterServerEvent('serrulata-atmrobbery:server:success2', function()
    local src = source
	local Player =  QBCore.Functions.GetPlayer(source)
    local bags = 1
	local info = {
		worth = math.random(Config.PaymentMin, Config.PaymentMax)
	}
	Player.Functions.AddItem('markedbills', bags, false, info)
    Player.Functions.RemoveItem(HackItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")
end)
--------------------------------------------------------------------------------------- # Start / Stop Resoure # ----------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
    local version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    PerformHttpRequest('https://github.com/Serrulata-Studios/serrulata-atmrobbery/blob/main/version.txt', function(err, text, headers)
       if text ~= version then
          print('^1[ERROR]^3 Your version of serrulata-atmrobbery is outdated. Please download the latest version from our Github^7')
       else
          print('^2[INFO]^3 serrulata-atmrobbery is up to date. Version: ^2'..version..' ^3- ^2https://github.com/Serrulata/serrulata-atmrobbery^7')
       end
    end, 'GET', '', {version = 'this'})
   end
end)

--------------------------------------------------------------------------------------- # Callbacks # ---------------------------------------------------------------------------------------
QBCore.Functions.CreateCallback("serrulata-atmrobbery:server:Cooldown",function(source, cb)
    if CoolDown then
        cb(true)
    else
        cb(false)
    end
end)
