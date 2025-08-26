Config = {}

-- Craft Konumları
Config.CraftLocations = {
    {
        name = "Çalışma Tezgahı",
        coords = vector4(-216.46813964844, -1318.9626464844, 30.890405654907, 271.23385620117),
        blip = {
            sprite = 566,
            color = 5,
            scale = 0.8,
            label = "Craft Tezgahı"
        }
    }
    -- Daha fazla konum eklenebilir
}

-- Level Sistemi
Config.LevelSystem = {
    xpPerLevel = 100, -- 1 level için gereken XP
    xpPerCraft = 10   -- Varsayılan craft XP'si
}

-- Craft Tarifleri
Config.CraftRecipes = {
    -- Plastik Tarifi (Test için)
    ["plastic"] = {
        label = "Plastik",
        description = "Basit plastik malzeme",
        requiredItems = {
            ["plastic"] = 1
        },
        requiredLevel = 1,
        xpReward = 10,
        category = "materials"
    },
    
    -- Silah Tarifleri
    ["weapon_pistol"] = {
        label = "Pistol",
        description = "Basit tabanca",
        requiredItems = {
            ["steel"] = 5,
            ["gunpowder"] = 2,
            ["spring"] = 1
        },
        requiredLevel = 1,
        xpReward = 15,
        category = "weapons"
    },
    
    ["weapon_smg"] = {
        label = "SMG",
        description = "Hafif makineli tüfek",
        requiredItems = {
            ["steel"] = 8,
            ["gunpowder"] = 4,
            ["spring"] = 2,
            ["plastic"] = 3
        },
        requiredLevel = 2,
        xpReward = 25,
        category = "weapons"
    },
    
    -- Zırh Tarifleri
    ["armor"] = {
        label = "Zırh",
        description = "Koruyucu zırh",
        requiredItems = {
            ["steel"] = 10,
            ["plastic"] = 5,
            ["fabric"] = 3
        },
        requiredLevel = 2,
        xpReward = 20,
        category = "armor"
    },
    
    -- Tıbbi Tarifleri
    ["medkit"] = {
        label = "İlk Yardım Çantası",
        description = "Sağlık için ilk yardım çantası",
        requiredItems = {
            ["fabric"] = 2,
            ["plastic"] = 1,
            ["alcohol"] = 1
        },
        requiredLevel = 1,
        xpReward = 12,
        category = "medical"
    },
    
    ["bandage"] = {
        label = "Bandaj",
        description = "Yara sarma bandajı",
        requiredItems = {
            ["fabric"] = 1,
            ["plastic"] = 1
        },
        requiredLevel = 1,
        xpReward = 8,
        category = "medical"
    }
}

-- Kategoriler
Config.Categories = {
    ["materials"] = {
        label = "Malzemeler",
        icon = "🔧"
    },
    ["weapons"] = {
        label = "Silahlar",
        icon = "🔫"
    },
    ["armor"] = {
        label = "Zırhlar", 
        icon = "🛡️"
    },
    ["medical"] = {
        label = "Tıbbi",
        icon = "💊"
    }
}
