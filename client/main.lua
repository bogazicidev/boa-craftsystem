local QBCore = exports['qb-core']:GetCoreObject()
local isCraftOpen = false
local currentLocation = nil

-- Config kontrolü ve başlatma
CreateThread(function()
    while not Config do
        Wait(100)
    end
    
    print("^2[BOA-Craft] ^7Config yüklendi!")
    
    -- Blip oluştur
    for _, location in pairs(Config.CraftLocations) do
        local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
        SetBlipSprite(blip, location.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, location.blip.scale)
        SetBlipColour(blip, location.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(location.blip.label)
        EndTextCommandSetBlipName(blip)
    end
    
    -- Target sistemi
    for _, location in pairs(Config.CraftLocations) do
        exports.ox_target:addBoxZone({
            coords = location.coords,
            size = vec3(2, 2, 3),
            rotation = location.coords.w,
            options = {
                {
                    name = 'craft_bench_' .. location.name,
                    icon = 'fas fa-hammer',
                    label = location.name .. ' Aç',
                    onSelect = function()
                        OpenCraftMenu(location)
                    end
                }
            }
        })
    end
end)

-- Craft menüsünü aç
function OpenCraftMenu(location)
    if isCraftOpen then return end
    
    currentLocation = location
    isCraftOpen = true
    
    -- Oyuncu level bilgilerini al
    TriggerServerEvent('boa-craft:getPlayerLevel')
    
    -- Craft itemlerini al
    TriggerServerEvent('boa-craft:getCraftItems')
    
    -- UI'yi aç
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openCraftMenu',
        location = location.name
    })
end

-- Craft menüsünü kapat
function CloseCraftMenu()
    if not isCraftOpen then return end
    
    isCraftOpen = false
    currentLocation = nil
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeCraftMenu'
    })
end

-- Level bilgilerini al
RegisterNetEvent('boa-craft:receivePlayerLevel', function(data)
    SendNUIMessage({
        action = 'updatePlayerLevel',
        data = data
    })
end)

-- Craft itemlerini al
RegisterNetEvent('boa-craft:receiveCraftItems', function(items)
    SendNUIMessage({
        action = 'updateCraftItems',
        items = items
    })
end)

-- Bildirim göster
RegisterNetEvent('boa-craft:showNotification', function(message, type, duration)
    SendNUIMessage({
        action = 'showNotification',
        message = message,
        type = type or 'info',
        duration = duration or 5000
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    CloseCraftMenu()
    cb('ok')
end)

RegisterNUICallback('craftItem', function(data, cb)
    if not data.itemName then
        cb('error')
        return
    end
    
    TriggerServerEvent('boa-craft:craftItem', data.itemName)
    cb('ok')
end)

RegisterNUICallback('refreshData', function(data, cb)
    -- Oyuncu level bilgilerini al
    TriggerServerEvent('boa-craft:getPlayerLevel')
    
    -- Craft itemlerini al
    TriggerServerEvent('boa-craft:getCraftItems')
    
    cb('ok')
end)

RegisterNUICallback('getPlayerLevel', function(data, cb)
    TriggerServerEvent('boa-craft:getPlayerLevel')
    cb('ok')
end)

RegisterNUICallback('getCraftItems', function(data, cb)
    TriggerServerEvent('boa-craft:getCraftItems')
    cb('ok')
end)

RegisterNUICallback('completeProduction', function(data, cb)
    TriggerServerEvent('boa-craft:completeProduction', data.itemName)
    cb('ok')
end)

RegisterNUICallback('cancelProduction', function(data, cb)
    TriggerServerEvent('boa-craft:cancelProduction', data.itemName)
    cb('ok')
end)

-- ESC tuşu ile menüyü kapat
CreateThread(function()
    while true do
        Wait(0)
        if isCraftOpen then
            if IsControlJustPressed(0, 322) then -- ESC
                CloseCraftMenu()
            end
        else
            Wait(500)
        end
    end
end)
