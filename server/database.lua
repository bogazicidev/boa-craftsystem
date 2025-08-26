local function InitializeDatabase()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `boa_craft_levels` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(50) NOT NULL,
            `level` int(11) DEFAULT 1,
            `xp` int(11) DEFAULT 0,
            `total_xp` int(11) DEFAULT 0,
            `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
            `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    print("^2[BOA-Craft] ^7Veritabanı tablosu oluşturuldu!")
end

-- Config kontrolü
CreateThread(function()
    while not Config do
        Wait(100)
    end
    
    print("^2[BOA-Craft] ^7Database Config yüklendi!")
    
    -- Database başlat
    InitializeDatabase()
    
    print("^2[BOA-Craft] ^7Database fonksiyonları hazır!")
end)

-- Oyuncu level bilgilerini al
function GetPlayerCraftLevel(identifier)
    local result = MySQL.single.await('SELECT * FROM boa_craft_levels WHERE identifier = ?', {identifier})
    
    if not result then
        -- Yeni oyuncu için kayıt oluştur
        MySQL.insert.await('INSERT INTO boa_craft_levels (identifier, level, xp, total_xp) VALUES (?, 1, 0, 0)', {identifier})
        return {
            level = 1,
            xp = 0,
            total_xp = 0
        }
    end
    
    return result
end

-- Oyuncuya XP ekle
function AddPlayerXP(identifier, xp)
    local playerData = GetPlayerCraftLevel(identifier)
    local newTotalXP = playerData.total_xp + xp
    local currentLevel = playerData.level
    local currentXP = playerData.xp + xp
    
    -- Level hesaplama
    local requiredXP = Config.LevelSystem.baseXP
    for i = 1, currentLevel - 1 do
        requiredXP = requiredXP * Config.LevelSystem.xpMultiplier
    end
    
    local newLevel = currentLevel
    while currentXP >= requiredXP do
        currentXP = currentXP - requiredXP
        newLevel = newLevel + 1
        requiredXP = requiredXP * Config.LevelSystem.xpMultiplier
    end
    
    -- Veritabanını güncelle
    MySQL.update.await('UPDATE boa_craft_levels SET level = ?, xp = ?, total_xp = ? WHERE identifier = ?', {
        newLevel, currentXP, newTotalXP, identifier
    })
    
    return {
        level = newLevel,
        xp = currentXP,
        total_xp = newTotalXP,
        levelUp = newLevel > currentLevel
    }
end

-- Level için gereken XP hesapla
function GetRequiredXP(level)
    if level <= 0 then
        return Config.LevelSystem.baseXP
    end
    
    local requiredXP = Config.LevelSystem.baseXP
    for i = 1, level - 1 do
        requiredXP = requiredXP * Config.LevelSystem.xpMultiplier
    end
    return requiredXP
end

-- XP yüzdesini hesapla
function GetXPPercentage(currentXP, level)
    local requiredXP = GetRequiredXP(level)
    if requiredXP <= 0 then
        return 0
    end
    return (currentXP / requiredXP) * 100
end
