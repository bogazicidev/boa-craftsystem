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
            label = "Çalışma Tezgahı"
        }
    },

    {
        name = "Çalışma Tezgahı",
        coords = vector4(707.11254882812, -966.90228271484, 30.412851333618, 177.7586517334),
        blip = {
            sprite = 566,
            color = 5,
            scale = 0.8,
            label = "Çalışma Tezgahı"
        }
    }
    -- Daha fazla konum eklenebilir
}

/* KATEGORİLER
all - "Tümü" (Tüm itemleri gösterir)
weapons - "Silahlar" (Silah kategorisi)
tools - "Araçlar" (Araç kategorisi)
materials - "Malzemeler" (Malzeme kategorisi)
electronics - "Elektronik" (Elektronik kategorisi)*/

-- Blueprint true ise item üzerinden gitmez. 

-- Item Label'ları (Görünen İsimler)
Config.ItemLabels = {
    ["water"]                = "Su",
    ["beer"]                 = "Bira",
    ["gelişmiş_silah"]       = "Gelişmiş Silah",
    ["elektronik_devre"]     = "Elektronik Devre",
    ["enerji_kristali"]      = "Enerji Kristali",
    ["id_card"]              = "Silah Blueprinti",
    ["handcuffs"]            = "Kelepçe",
    ["iron"]                 = "Demir",
    ["titanyum"]             = "Titanyum"
}

-- Craft Itemleri
Config.CraftItems = {

    ["handcuffs"] = {  /* verilecek item */
        label = "Kelepçe",
        image = "handcuffs.png",
        level = 1,
        xp = 201,
        category = "materials", -- Kategori
        productionTime = 5, -- 10 saniye
        ingredients = {
            ["iron"] = { amount = 2, blueprint = false } -- Tüketilecek

        }
    },

    
    ["WEAPON_COMBATSHOTGUN"] = {
        label = "Pompalı Silah",
        image = "WEAPON_COMBATSHOTGUN.png",
        level = 3,
        xp = 30,
        category = "weapons", -- Kategori
        productionTime = 10, -- 10 saniye
        ingredients = {
            ["id_card"] = { amount = 1, blueprint = true },
            ["iron"] = { amount = 5, blueprint = false }
        }
    }
}

-- Level Sistemi
Config.LevelSystem = {
    baseXP = 100, -- Her level için gereken XP
    xpMultiplier = 1.5 -- Her level artışında XP çarpanı
}

-- UI Ayarları
Config.UI = {
    leftPanelWidth = 30, -- Sol panel genişliği (%)
    rightPanelWidth = 70, -- Sağ panel genişliği (%)
    maxItemsPerPage = 8
}
