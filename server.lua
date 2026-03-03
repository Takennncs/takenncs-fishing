local QBCore = exports['qb-core']:GetCoreObject()

local function Notify(src, msg, type)
    if type == 'success' then
        TriggerClientEvent('QBCore:Notify', src, msg, 'success')
    elseif type == 'error' then
        TriggerClientEvent('QBCore:Notify', src, msg, 'error')
    else
        TriggerClientEvent('QBCore:Notify', src, msg, 'primary')
    end
end

local function GetRandomFish()
    local totalChance = 0
    for _, fish in pairs(Config.Fish) do
        totalChance = totalChance + fish.chance
    end
    
    local rand = math.random(1, totalChance)
    local current = 0
    
    for fishName, fishData in pairs(Config.Fish) do
        current = current + fishData.chance
        if rand <= current then
            return fishName, fishData
        end
    end
    
    return 'fishingbass', Config.Fish['fishingbass']
end

local function UpdateLocation(index)
    local location = Config.Locations[index]
    if not location then return end
    
    location.fished = location.fished + 1
    
    if location.fished >= location.maxFishing then
        location.fished = 0
        location.cooldown = os.time() + Config.LocationCooldown
    end
    
    TriggerClientEvent('takenncs-fishing:client:updateLocations', -1, Config.Locations)
end

RegisterNetEvent('takenncs-fishing:server:catchFish')
AddEventHandler('takenncs-fishing:server:catchFish', function(locationIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local location = Config.Locations[locationIndex]
    if not location then
        Notify(src, 'Viga: Vale asukoht', 'error')
        return
    end
    
    if location.cooldown > os.time() then
        Notify(src, 'Siin kohas pole enam kala', 'error')
        return
    end
    
    local rodCount = exports.ox_inventory:GetItemCount(src, Config.FishingRod)
    if not rodCount or rodCount < 1 then
        Notify(src, 'Sul pole õnge', 'error')
        return
    end
    
    local canCarry = exports.ox_inventory:CanCarryItem(src, 'fishingbass', 1)
    if not canCarry then
        Notify(src, 'Sinu inventar on täis', 'error')
        return
    end
    
    local fishName, fishData = GetRandomFish()
    local added = exports.ox_inventory:AddItem(src, fishName, 1)
    
    if added then
        UpdateLocation(locationIndex)
        Notify(src, ('Püüdsid %s'):format(fishData.label), 'success')
        TriggerClientEvent('takenncs-fishing:client:catchSuccess', src, fishData.label)
    else
        Notify(src, 'Kala pääses minema', 'error')
        TriggerClientEvent('takenncs-fishing:client:catchFailed', src)
    end
end)

RegisterNetEvent('takenncs-fishing:server:sellFish')
AddEventHandler('takenncs-fishing:server:sellFish', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local totalPrice = 0
    local soldCount = 0
    
    for fishName, fishData in pairs(Config.Fish) do
        local count = exports.ox_inventory:GetItemCount(src, fishName)
        
        if count and count > 0 then
            local price = count * fishData.price
            local removed = exports.ox_inventory:RemoveItem(src, fishName, count)
            
            if removed then
                totalPrice = totalPrice + price
                soldCount = soldCount + count
            end
        end
    end
    
    if totalPrice > 0 then
        Player.Functions.AddMoney('cash', totalPrice, 'fishing-sold')
        Notify(src, ('Müüsid %d kala $%d eest'):format(soldCount, totalPrice), 'success')
    else
        Notify(src, 'Sul pole kala müügiks', 'error')
    end
end)

RegisterNetEvent('takenncs-fishing:server:sellSpecificFish')
AddEventHandler('takenncs-fishing:server:sellSpecificFish', function(fishName, count)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local fishData = Config.Fish[fishName]
    if not fishData then
        Notify(src, 'Viga: Kala ei eksisteeri', 'error')
        return
    end
    
    local hasCount = exports.ox_inventory:GetItemCount(src, fishName)
    if not hasCount or hasCount < count then
        Notify(src, 'Sul pole nii palju kala', 'error')
        return
    end
    
    local totalPrice = count * fishData.price
    local removed = exports.ox_inventory:RemoveItem(src, fishName, count)
    
    if removed then
        Player.Functions.AddMoney('cash', totalPrice, 'fishing-sold')
        Notify(src, ('Müüsid %dx %s $%d eest'):format(count, fishData.label, totalPrice), 'success')
    else
        Notify(src, 'Müük ebaõnnestus', 'error')
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        
        local now = os.time()
        local updated = false
        
        for i = 1, #Config.Locations do
            if Config.Locations[i].cooldown > 0 and Config.Locations[i].cooldown <= now then
                Config.Locations[i].cooldown = 0
                updated = true
            end
        end
        
        if updated then
            TriggerClientEvent('takenncs-fishing:client:updateLocations', -1, Config.Locations)
        end
    end
end)

RegisterNetEvent('takenncs-fishing:server:getFishForSale')
AddEventHandler('takenncs-fishing:server:getFishForSale', function()
    local src = source
    local fishItems = {}
    local totalValue = 0
    
    for fishName, fishData in pairs(Config.Fish) do
        local count = exports.ox_inventory:GetItemCount(src, fishName)
        if count and count > 0 then
            table.insert(fishItems, {
                name = fishName,
                label = fishData.label,
                count = count,
                price = fishData.price,
                total = count * fishData.price,
                image = fishData.image
            })
            totalValue = totalValue + (count * fishData.price)
        end
    end
    
    TriggerClientEvent('takenncs-fishing:client:openSellMenu', src, fishItems, totalValue)
end)