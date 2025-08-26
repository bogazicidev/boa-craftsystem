local QBCore = exports['qb-core']:GetCoreObject()

-- Config kontrolü
CreateThread(function()
    while not Config do
        Wait(100)
    end
    
    print("^2[BOA-Craft] ^7Server Config yüklendi!")
    
    -- Config yüklendikten sonra eventleri kaydet
    print("^2[BOA-Craft] ^7Server events kaydedildi!")
end)

-- Oyuncu level bilgilerini al
RegisterNetEvent('boa-craft:getPlayerLevel', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local identifier = Player.PlayerData.citizenid
    local playerData = GetPlayerCraftLevel(identifier)
    local xpPercentage = GetXPPercentage(playerData.xp, playerData.level)
    
    TriggerClientEvent('boa-craft:receivePlayerLevel', src, {
        level = playerData.level,
        xp = playerData.xp,
        xpPercentage = xpPercentage,
        totalXP = playerData.total_xp
    })
end)

-- Craft işlemi
RegisterNetEvent('boa-craft:craftItem', function(itemName)
    local src = source
    print("^2[BOA-Craft] ^7Craft eventi alındı - Player:", src, "Item:", itemName)
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        print("^1[BOA-Craft] ^7Hata: Player bulunamadı!")
        return 
    end
    
    local identifier = Player.PlayerData.citizenid
    print("^2[BOA-Craft] ^7Player identifier:", identifier)
    
    local playerData = GetPlayerCraftLevel(identifier)
    print("^2[BOA-Craft] ^7Player level data:", playerData.level, playerData.xp)
    
    local craftItem = Config.CraftItems[itemName]
    print("^2[BOA-Craft] ^7Craft item bulundu:", craftItem and "Evet" or "Hayır")
    
    if not craftItem then
        print("^1[BOA-Craft] ^7Hata: Geçersiz item -", itemName)
        TriggerClientEvent('boa-craft:showNotification', src, 'Geçersiz item!', 'error')
        return
    end
    
    print("^2[BOA-Craft] ^7Craft item detayları:", craftItem.label, "Level:", craftItem.level, "XP:", craftItem.xp)
    
    -- Level kontrolü
    if playerData.level < craftItem.level then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Bu itemi craft etmek için level ' .. craftItem.level .. ' gerekiyor!'
        })
        return
    end
    
    -- Malzeme kontrolü
    print("^2[BOA-Craft] ^7Malzeme kontrolü başlıyor...")
    local hasAllIngredients = true
    local missingItems = {}
    
    for ingredient, ingredientData in pairs(craftItem.ingredients) do
        local amount = type(ingredientData) == "table" and ingredientData.amount or ingredientData
        local itemCount = exports.ox_inventory:GetItemCount(src, ingredient)
        print("^2[BOA-Craft] ^7Malzeme kontrolü:", ingredient, "Gerekli:", amount, "Mevcut:", itemCount)
        
        if itemCount < amount then
            hasAllIngredients = false
            table.insert(missingItems, ingredient)
            print("^1[BOA-Craft] ^7Eksik malzeme:", ingredient)
        end
    end
    
    if not hasAllIngredients then
        print("^1[BOA-Craft] ^7Craft iptal edildi - Yeterli malzeme yok!")
        TriggerClientEvent('boa-craft:showNotification', src, 'Yeterli malzeme yok!', 'error')
        return
    end
    
    print("^2[BOA-Craft] ^7Tüm malzemeler mevcut, craft işlemi başlıyor...")
    
    -- Malzemeleri çıkar (sadece blueprint olmayanlar)
    print("^2[BOA-Craft] ^7Malzemeler çıkarılıyor...")
    for ingredient, ingredientData in pairs(craftItem.ingredients) do
        local amount = type(ingredientData) == "table" and ingredientData.amount or ingredientData
        local blueprint = type(ingredientData) == "table" and ingredientData.blueprint or false
        
        if not blueprint then
            print("^2[BOA-Craft] ^7Malzeme çıkarılıyor:", ingredient, amount)
            exports.ox_inventory:RemoveItem(src, ingredient, amount)
        else
            print("^3[BOA-Craft] ^7Malzeme tüketilmiyor (blueprint=true):", ingredient)
        end
    end
    
    -- Craft edilen itemi ver
    print("^2[BOA-Craft] ^7Craft edilen item veriliyor:", itemName)
    exports.ox_inventory:AddItem(src, itemName, 1)
    
    -- XP ekle
    local newData = AddPlayerXP(identifier, craftItem.xp)
    local newXpPercentage = GetXPPercentage(newData.xp, newData.level)
    
    -- Başarılı bildirim
    TriggerClientEvent('boa-craft:showNotification', src, craftItem.label .. ' başarıyla craft edildi! +' .. craftItem.xp .. ' XP', 'success')
    
    -- Level atladıysa bildirim
    if newData.levelUp then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = 'Tebrikler! Level ' .. newData.level .. ' oldunuz!'
        })
    end
    
    -- Güncel level bilgilerini gönder
    TriggerClientEvent('boa-craft:receivePlayerLevel', src, {
        level = newData.level,
        xp = newData.xp,
        xpPercentage = newXpPercentage,
        totalXP = newData.total_xp
    })
    
    -- Craft itemlerini de güncelle
    local availableItems = {}
    for itemName, itemData in pairs(Config.CraftItems) do
        local canCraft = newData.level >= itemData.level
        local hasIngredients = true
        
        -- Malzeme kontrolü
        for ingredient, amount in pairs(itemData.ingredients) do
            local itemCount = exports.ox_inventory:GetItemCount(src, ingredient)
            if itemCount < amount then
                hasIngredients = false
                break
            end
        end
        
        -- Ingredients'e label'ları ekle
        local ingredientsWithLabels = {}
        for ingredient, amount in pairs(itemData.ingredients) do
            ingredientsWithLabels[ingredient] = {
                amount = amount,
                label = Config.ItemLabels[ingredient] or ingredient
            }
        end
        
        table.insert(availableItems, {
            name = itemName,
            label = itemData.label,
            image = itemData.image,
            level = itemData.level,
            xp = itemData.xp,
            category = itemData.category or "materials", -- Kategori bilgisini ekle
            ingredients = itemData.ingredients,
            ingredientsWithLabels = ingredientsWithLabels,
            ingredientStatus = ingredientStatus,
            canCraft = canCraft and hasIngredients,
            levelRequired = newData.level >= itemData.level,
            hasIngredients = hasIngredients
        })
    end
    
    TriggerClientEvent('boa-craft:receiveCraftItems', src, availableItems)
end)

-- Craft itemlerini gönder
RegisterNetEvent('boa-craft:getCraftItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local identifier = Player.PlayerData.citizenid
    local playerData = GetPlayerCraftLevel(identifier)
    local availableItems = {}
    
    for itemName, itemData in pairs(Config.CraftItems) do
        local canCraft = playerData.level >= itemData.level
        local hasIngredients = true
        
        -- Malzeme kontrolü ve durum bilgisi
        local ingredientStatus = {}
        for ingredient, ingredientData in pairs(itemData.ingredients) do
            local amount = type(ingredientData) == "table" and ingredientData.amount or ingredientData
            local itemCount = exports.ox_inventory:GetItemCount(src, ingredient)
            ingredientStatus[ingredient] = itemCount >= amount
            if itemCount < amount then
                hasIngredients = false
            end
        end
        
        -- Ingredients'e label'ları ekle
        local ingredientsWithLabels = {}
        for ingredient, ingredientData in pairs(itemData.ingredients) do
            local amount = type(ingredientData) == "table" and ingredientData.amount or ingredientData
            local blueprint = type(ingredientData) == "table" and ingredientData.blueprint or false
            ingredientsWithLabels[ingredient] = {
                amount = amount,
                blueprint = blueprint,
                label = Config.ItemLabels[ingredient] or ingredient
            }
        end
        
        table.insert(availableItems, {
            name = itemName,
            label = itemData.label,
            image = itemData.image,
            level = itemData.level,
            xp = itemData.xp,
            category = itemData.category or "materials", -- Kategori bilgisini ekle
            productionTime = itemData.productionTime,
            ingredients = itemData.ingredients,
            ingredientsWithLabels = ingredientsWithLabels,
            ingredientStatus = ingredientStatus,
            canCraft = canCraft and hasIngredients,
            levelRequired = playerData.level >= itemData.level,
            hasIngredients = hasIngredients
        })
    end
    
    TriggerClientEvent('boa-craft:receiveCraftItems', src, availableItems)
end)

-- Üretim tamamlama
RegisterNetEvent('boa-craft:completeProduction', function(itemName)
    local src = source
    print("^2[BOA-Craft] ^7Üretim tamamlandı - Player:", src, "Item:", itemName)
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        return 
    end
    
    local identifier = Player.PlayerData.citizenid
    local playerData = GetPlayerCraftLevel(identifier)
    local craftItem = Config.CraftItems[itemName]
    
    if not craftItem then
        TriggerClientEvent('boa-craft:showNotification', src, 'Geçersiz item!', 'error')
        return
    end
    
    -- Level kontrolü
    if playerData.level < craftItem.level then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Bu itemi craft etmek için level ' .. craftItem.level .. ' gerekiyor!'
        })
        return
    end
    
    -- Malzeme kontrolü
    local hasAllIngredients = true
    local missingItems = {}
    
    for ingredient, ingredientData in pairs(craftItem.ingredients) do
        local amount = type(ingredientData) == "table" and ingredientData.amount or ingredientData
        local itemCount = exports.ox_inventory:GetItemCount(src, ingredient)
        
        if itemCount < amount then
            hasAllIngredients = false
            table.insert(missingItems, ingredient)
        end
    end
    
    if not hasAllIngredients then
        TriggerClientEvent('boa-craft:showNotification', src, 'Yeterli malzeme yok!', 'error')
        return
    end
    
    -- Malzemeleri çıkar (sadece blueprint olmayanlar)
    for ingredient, ingredientData in pairs(craftItem.ingredients) do
        local amount = type(ingredientData) == "table" and ingredientData.amount or ingredientData
        local blueprint = type(ingredientData) == "table" and ingredientData.blueprint or false
        
        if not blueprint then
            exports.ox_inventory:RemoveItem(src, ingredient, amount)
        end
    end
    
    -- Craft edilen itemi ver
    exports.ox_inventory:AddItem(src, itemName, 1)
    
    -- XP ekle
    local newData = AddPlayerXP(identifier, craftItem.xp)
    local newXpPercentage = GetXPPercentage(newData.xp, newData.level)
    
    -- Başarılı bildirim
    TriggerClientEvent('boa-craft:showNotification', src, craftItem.label .. ' başarıyla üretildi! +' .. craftItem.xp .. ' XP', 'success')
    
    -- Level atladıysa bildirim
    if newData.levelUp then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            description = 'Tebrikler! Level ' .. newData.level .. ' oldunuz!'
        })
    end
    
    -- Güncel level bilgilerini gönder
    TriggerClientEvent('boa-craft:receivePlayerLevel', src, {
        level = newData.level,
        xp = newData.xp,
        xpPercentage = newXpPercentage,
        totalXP = newData.total_xp
    })
    
    -- Craft itemlerini de güncelle
    local availableItems = {}
    for itemName, itemData in pairs(Config.CraftItems) do
        local canCraft = newData.level >= itemData.level
        local hasIngredients = true
        
        -- Malzeme kontrolü
        for ingredient, amount in pairs(itemData.ingredients) do
            local itemCount = exports.ox_inventory:GetItemCount(src, ingredient)
            if itemCount < amount then
                hasIngredients = false
                break
            end
        end
        
        -- Ingredients'e label'ları ekle
        local ingredientsWithLabels = {}
        for ingredient, amount in pairs(itemData.ingredients) do
            ingredientsWithLabels[ingredient] = {
                amount = amount,
                label = Config.ItemLabels[ingredient] or ingredient
            }
        end
        
        table.insert(availableItems, {
            name = itemName,
            label = itemData.label,
            image = itemData.image,
            level = itemData.level,
            xp = itemData.xp,
            category = itemData.category or "materials",
            productionTime = itemData.productionTime,
            ingredients = itemData.ingredients,
            ingredientsWithLabels = ingredientsWithLabels,
            ingredientStatus = ingredientStatus,
            canCraft = canCraft and hasIngredients,
            levelRequired = newData.level >= itemData.level,
            hasIngredients = hasIngredients
        })
    end
    
    TriggerClientEvent('boa-craft:receiveCraftItems', src, availableItems)
end)

-- Üretim iptal
RegisterNetEvent('boa-craft:cancelProduction', function(itemName)
    local src = source
    print("^2[BOA-Craft] ^7Üretim iptal edildi - Player:", src, "Item:", itemName)
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        return 
    end
    
    local craftItem = Config.CraftItems[itemName]
    
    if not craftItem then
        return
    end
    
    -- İptal bildirimi (sağ üstte)
    TriggerClientEvent('ox_lib:notify', src, {
        type = 'error',
        description = craftItem.label .. ' üretimi iptal edildi!'
    })
end)
