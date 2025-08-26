-- UI işlemleri için yardımcı fonksiyonlar

-- Item resimlerini yükle
function LoadItemImages()
    local images = {}
    for itemName, itemData in pairs(Config.CraftItems) do
        if itemData.image then
            images[itemName] = itemData.image
        end
    end
    return images
end

-- Item resim yolunu al
function GetItemImagePath(itemName)
    local itemData = Config.CraftItems[itemName]
    if itemData and itemData.image then
        return "https://via.placeholder.com/80x80/4a90e2/ffffff?text=" .. itemData.label
    end
    return "https://via.placeholder.com/80x80/4a90e2/ffffff?text=Item"
end

-- Malzeme kontrolü
function CheckIngredients(playerId, ingredients)
    local hasAll = true
    local missing = {}
    
    for ingredient, amount in pairs(ingredients) do
        local item = exports.ox_inventory:GetItem(playerId, ingredient, nil, true)
        if not item or item.count < amount then
            hasAll = false
            table.insert(missing, ingredient)
        end
    end
    
    return hasAll, missing
end

-- Craft itemlerini filtrele
function FilterCraftItems(playerLevel, playerInventory)
    local availableItems = {}
    
    for itemName, itemData in pairs(Config.CraftItems) do
        local canCraft = playerLevel >= itemData.level
        local hasIngredients = true
        
        -- Malzeme kontrolü
        for ingredient, amount in pairs(itemData.ingredients) do
            local item = exports.ox_inventory:GetItem(playerId, ingredient, nil, true)
            if not item or item.count < amount then
                hasIngredients = false
                break
            end
        end
        
        table.insert(availableItems, {
            name = itemName,
            label = itemData.label,
            image = GetItemImagePath(itemName),
            level = itemData.level,
            xp = itemData.xp,
            ingredients = itemData.ingredients,
            canCraft = canCraft and hasIngredients,
            levelRequired = playerLevel >= itemData.level,
            hasIngredients = hasIngredients
        })
    end
    
    return availableItems
end

-- Level hesaplama yardımcı fonksiyonları
function CalculateRequiredXP(level)
    local requiredXP = Config.LevelSystem.baseXP
    for i = 1, level - 1 do
        requiredXP = requiredXP * Config.LevelSystem.xpMultiplier
    end
    return requiredXP
end

function CalculateXPPercentage(currentXP, level)
    local requiredXP = CalculateRequiredXP(level)
    return (currentXP / requiredXP) * 100
end

-- UI güncelleme fonksiyonları
function UpdateCraftUI(playerLevel, playerXP, playerXPPercentage, craftItems)
    SendNUIMessage({
        action = 'updatePlayerLevel',
        data = {
            level = playerLevel,
            xp = playerXP,
            xpPercentage = playerXPPercentage
        }
    })
    
    SendNUIMessage({
        action = 'updateCraftItems',
        items = craftItems
    })
end

-- Bildirim fonksiyonları
function ShowNotification(type, message)
    exports.ox_lib:notify({
        type = type,
        description = message
    })
end

-- Debug fonksiyonları (geliştirme sırasında kullanım için)
function DebugPrint(message)
    if Config.Debug then
        print("^3[BOA-Craft Debug] ^7" .. message)
    end
end

-- Item bilgilerini konsola yazdır (debug için)
function PrintCraftItems()
    print("^2[BOA-Craft] ^7Craft Itemleri:")
    for itemName, itemData in pairs(Config.CraftItems) do
        print(string.format("  %s: Level %d, %d XP", itemName, itemData.level, itemData.xp))
    end
end

-- Konum bilgilerini konsola yazdır (debug için)
function PrintCraftLocations()
    print("^2[BOA-Craft] ^7Craft Konumları:")
    for i, location in ipairs(Config.CraftLocations) do
        print(string.format("  %d. %s: %s", i, location.name, tostring(location.coords)))
    end
end
