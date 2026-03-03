local QBCore = exports['qb-core']:GetCoreObject()
local fishing = {
    active = false,
    location = nil,
    startCoords = nil,
    zones = {},
    blips = {},
    seller = nil,
    fishingThread = nil,
    rodProp = nil
}

local locationCooldowns = {}

local function Notify(msg, type)
    if type == 'success' then
        TriggerEvent('QBCore:Notify', msg, 'success')
    elseif type == 'error' then
        TriggerEvent('QBCore:Notify', msg, 'error')
    else
        TriggerEvent('QBCore:Notify', msg, 'primary')
    end
end

local function HasRod()
    local count = exports.ox_inventory:GetItemCount('fishingrod')
    return count and count > 0
end

local function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

local function AttachRodProp()
    local ped = PlayerPedId()
    
    if fishing.rodProp and DoesEntityExist(fishing.rodProp) then
        DeleteEntity(fishing.rodProp)
        fishing.rodProp = nil
    end
    
    local model = GetHashKey('prop_fishing_rod_02')
    RequestModel(model)
    local attempts = 0
    while not HasModelLoaded(model) and attempts < 50 do
        Wait(10)
        attempts = attempts + 1
    end
    
    if HasModelLoaded(model) then
        fishing.rodProp = CreateObject(model, 0, 0, 0, true, true, false)
        
        AttachEntityToEntity(
            fishing.rodProp, ped,
            GetPedBoneIndex(ped, 28422),
            0.08, 0.08, 0.0,
            180.0, 180.0, 0.0,
            true, true, false, true, 1, true
        )
    end
end

local function RemoveRodProp()
    if fishing.rodProp and DoesEntityExist(fishing.rodProp) then
        DeleteEntity(fishing.rodProp)
        fishing.rodProp = nil
    end
end

local function PlayCastAnimation()
    local ped = PlayerPedId()
    LoadAnimDict('mini@triathlon')
    TaskPlayAnim(ped, 'mini@triathlon', 'idle_e', 8.0, 8.0, 1500, 49, 0, false, false, false)
    Wait(1500)
end

local function PlayIdleFishingAnimation()
    local ped = PlayerPedId()
    LoadAnimDict('amb@world_human_stand_fishing@idle_a')
    TaskPlayAnim(ped, 'amb@world_human_stand_fishing@idle_a', 'idle_b', 8.0, 8.0, -1, 49, 0, false, false, false)
end

local function PlayReelAnimation()
    local ped = PlayerPedId()
    LoadAnimDict('mini@triathlon')
    TaskPlayAnim(ped, 'mini@triathlon', 'idle_e', 8.0, 8.0, 1000, 49, 0, false, false, false)
end

local function PlayBiteReactionAnimation()
    local ped = PlayerPedId()
    LoadAnimDict('mini@triathlon')
    TaskPlayAnim(ped, 'mini@triathlon', 'idle_e', 8.0, 8.0, 500, 49, 0, false, false, false)
end

local function StopAllAnimations()
    ClearPedTasks(PlayerPedId())
    RemoveRodProp()
end

local function StopFishing(success)
    if not fishing.active then return end
    
    fishing.active = false
    fishing.location = nil
    fishing.startCoords = nil
    
    StopAllAnimations()
    RemoveRodProp()
    
    if lib.progressBarActive then
        lib.progressBarActive = false
    end
    
    if fishing.fishingThread then
        fishing.fishingThread = nil
    end
    
    if not success then
        Notify(Locales[Config.Language].stop, 'primary')
    end
end

local function ShowProgressBar(duration, text)
    local success = lib.progressBar({
        duration = duration,
        label = text,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
        },
        anim = {
            dict = 'mini@triathlon',
            clip = 'idle_e'
        },
    })
    
    return success
end

local function DoSkillCheckLoop()
    if not Config.Skillbar.enabled then
        return true
    end
    
    if not exports['takenncs-skillbar'] then
        Notify('Skillbar not found', 'error')
        return false
    end
    
    local attempts = 3
    local successes = 0
    
    for i = 1, attempts do
        local ok = exports['takenncs-skillbar']:skillbar(Config.Skillbar.speed)
        
        if not ok then
            return false
        end
        
        successes = successes + 1
        
        if i < attempts then
            Wait(600)
        end
    end
    
    return successes == attempts
end

local function StartFishing(index)
    if fishing.active then
        Notify(Locales[Config.Language].already_fishing, 'error')
        return
    end
    
    if not HasRod() then
        Notify(Locales[Config.Language].no_rod, 'error')
        return
    end
    
    local location = Config.Locations[index]
    if not location then 
        Notify(Locales[Config.Language].error_location, 'error')
        return 
    end
    
    if locationCooldowns[index] and locationCooldowns[index] > GetGameTimer() then
        Notify(Locales[Config.Language].empty, 'error')
        return
    end
    
    fishing.active = true
    fishing.location = index
    fishing.startCoords = GetEntityCoords(PlayerPedId())
    
    local progressSuccess = ShowProgressBar(3000, Locales[Config.Language].preparing)

    if not progressSuccess then
        StopFishing()
        return
    end

FreezeEntityPosition(PlayerPedId(), true)

    AttachRodProp()
    
    PlayCastAnimation()
    
    PlayIdleFishingAnimation()
    
    Notify(Locales[Config.Language].start, 'primary')
    
    fishing.fishingThread = CreateThread(function()
        local catchTime = math.random(Config.CatchTime.min, Config.CatchTime.max)
        local elapsed = 0
        local ped = PlayerPedId()
        
        while fishing.active and elapsed < catchTime do
            Wait(100)
            elapsed = elapsed + 100
            
            local coords = GetEntityCoords(ped)
            if #(coords - fishing.startCoords) > Config.MaxDistance then
                Notify(Locales[Config.Language].move, 'error')
                StopFishing()
                return
            end
            
            if not HasRod() then
                Notify(Locales[Config.Language].no_rod, 'error')
                StopFishing()
                return
            end
            
            if IsControlJustPressed(0, 38) then
                StopFishing()
                return
            end
        end
        
        if fishing.active then
            ClearPedTasks(ped)
                        
            PlayBiteReactionAnimation()
            
            local skillSuccess = DoSkillCheckLoop()
            
            if skillSuccess then
                PlayReelAnimation()
                Wait(1000)
                
                TriggerServerEvent('takenncs-fishing:server:catchFish', index)
            else
                Notify(Locales[Config.Language].skill_fail, 'error')
                StopFishing()
            end
        end
    end)
end

local function OpenSellMenu()
    local L = Locales[Config.Language]
    
    TriggerServerEvent('takenncs-fishing:server:getFishForSale')
end

exports('UseFishingRod', function()
    if not Config or not Config.Locations then
        Notify('Viga', 'error')
        return false
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local L = Locales[Config.Language]
    
    local nearestSpot = nil
    local nearestDistance = 10.0
    
    for i = 1, #Config.Locations do
        local location = Config.Locations[i]
        if location and location.coords then
            local distance = #(coords - location.coords)
            if distance < nearestDistance then
                nearestDistance = distance
                nearestSpot = i
            end
        end
    end
    
    if nearestSpot then
        StartFishing(nearestSpot)
        return true
    else
        Notify(L.error_not_near_spot, 'error')
        return false
    end
end)

local function CreateZones()
    if not Config or not Config.Locations then return end
    
    for i = 1, #fishing.zones do
        exports.ox_target:removeZone(fishing.zones[i])
    end
    fishing.zones = {}
    
    for i = 1, #Config.Locations do
        local loc = Config.Locations[i]
        if loc and loc.coords then
            local zone = exports.ox_target:addBoxZone({
                coords = loc.coords,
                size = vec3(loc.radius or 3.0, loc.radius or 3.0, 1.0),
                rotation = 0,
                debug = false,
                options = {
                    {
                        name = 'fishing_' .. i,
                        icon = 'fas fa-fish',
                        label = 'Alusta kalapüüki',
                        distance = 2.5,
                        canInteract = function()
                            if locationCooldowns[i] and locationCooldowns[i] > GetGameTimer() then
                                return false
                            end
                            return not fishing.active and HasRod()
                        end,
                        onSelect = function()
                            StartFishing(i)
                        end
                    }
                }
            })
            
            table.insert(fishing.zones, zone)
        end
    end
end

local function CreateBlips()
    if not Config or not Config.Locations then return end
    
    for i = 1, #fishing.blips do
        RemoveBlip(fishing.blips[i])
    end
    fishing.blips = {}
    
    for i = 1, #Config.Locations do
        local loc = Config.Locations[i]
        if loc and loc.coords then
            local blip = AddBlipForCoord(loc.coords)
            SetBlipSprite(blip, 68)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 3)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(loc.name or "Kalastuskoht")
            EndTextCommandSetBlipName(blip)
            
            table.insert(fishing.blips, blip)
        end
    end
end

local function CreateSeller()
    if not Config or not Config.Seller then return end
    
    local model = Config.Seller.model
    
    RequestModel(model)
    local attempts = 0
    while not HasModelLoaded(model) and attempts < 50 do
        Wait(10)
        attempts = attempts + 1
    end
    
    if not HasModelLoaded(model) then
        return
    end
    
    if fishing.seller and DoesEntityExist(fishing.seller) then
        DeletePed(fishing.seller)
    end
    
    fishing.seller = CreatePed(4, model, 
        Config.Seller.coords.x, 
        Config.Seller.coords.y, 
        Config.Seller.coords.z - 1.0, 
        Config.Seller.heading, 
        false, true
    )
    
    if DoesEntityExist(fishing.seller) then
        SetEntityInvincible(fishing.seller, true)
        FreezeEntityPosition(fishing.seller, true)
        SetBlockingOfNonTemporaryEvents(fishing.seller, true)
        
        exports.ox_target:addLocalEntity(fishing.seller, {
            {
                name = 'sell_fish',
                icon = 'fas fa-dollar-sign',
                label = 'Müü kala',
                distance = 2.5,
                onSelect = function()
                    OpenSellMenu()
                end
            }
        })
    end
end

RegisterNetEvent('takenncs-fishing:client:openSellMenu')
AddEventHandler('takenncs-fishing:client:openSellMenu', function(fishItems, totalValue)
    local L = Locales[Config.Language]
        
    if #fishItems == 0 then
        Notify(L.no_fish, 'error')
        return
    end
    
    local metadata = {}
    for _, fish in ipairs(fishItems) do
        table.insert(metadata, {
            value = ('%s: %dx'):format(fish.label, fish.count),
            progress = 100,
            color = '#4CAF50'
        })
    end
    
    lib.registerContext({
        id = 'fish_sell_menu',
        title = L.sell_menu_title,
        options = {
            {
                title = L.sell_all,
                description = ('Kokku: $%d'):format(totalValue),
                icon = 'dollar-sign',
                iconColor = 'green',
                metadata = metadata,
                onSelect = function()
                    TriggerServerEvent('takenncs-fishing:server:sellFish')
                end
            }
        }
    })
    
    lib.showContext('fish_sell_menu')
end)

RegisterNetEvent('takenncs-fishing:client:catchSuccess')
AddEventHandler('takenncs-fishing:client:catchSuccess', function(fishLabel)
    StopFishing(true)
    Notify(Locales[Config.Language].caught:format(fishLabel), 'success')
end)

RegisterNetEvent('takenncs-fishing:client:catchFailed')
AddEventHandler('takenncs-fishing:client:catchFailed', function()
    StopFishing()
end)

RegisterNetEvent('takenncs-fishing:client:updateLocations')
AddEventHandler('takenncs-fishing:client:updateLocations', function(locations)
    if locations then
        Config.Locations = locations
        for i = 1, #locations do
            if locations[i].cooldown and locations[i].cooldown > 0 then
                locationCooldowns[i] = locations[i].cooldown * 1000
            end
        end
        CreateZones()
    end
end)

CreateThread(function()
    while not exports.ox_target do
        Wait(100)
    end
    
    CreateZones()
    CreateBlips()
    CreateSeller()
    
    while true do
        Wait(30000)
        CreateZones()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if fishing.active then
            StopFishing()
        end
        
        RemoveRodProp()
        
        for i = 1, #fishing.blips do
            RemoveBlip(fishing.blips[i])
        end
        
        if fishing.seller and DoesEntityExist(fishing.seller) then
            DeletePed(fishing.seller)
        end
    end
end)