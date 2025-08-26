# BOA-Craft Sistemi

FiveM sunucunuz için gelişmiş bir craft sistemi. Oyuncular belirli konumlarda craft yapabilir, level atlayabilir ve çeşitli itemler üretebilir.

## Özellikler

- 🎯 **Target Sistemi**: Ox_target ile entegre çalışma tezgahı etkileşimi
- 📊 **Level Sistemi**: XP kazanarak level atlama
- 🔒 **Kilit Sistemi**: Level ve malzeme gereksinimlerine göre item kilitleme
- 🎨 **Modern UI**: Responsive ve kullanıcı dostu arayüz
- 📦 **Ox_inventory Entegrasyonu**: Mevcut envanter sistemi ile uyumlu
- 🗄️ **Veritabanı Desteği**: Oyuncu level ve XP verilerini saklama
- 📍 **Çoklu Konum**: Birden fazla craft konumu desteği

## Kurulum

1. Scripti `resources` klasörüne kopyalayın
2. `server.cfg` dosyasına `ensure boa-craft` ekleyin
3. Sunucuyu yeniden başlatın

## Gereksinimler

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target)
- [oxmysql](https://github.com/overextended/oxmysql)
- [qb-core](https://github.com/qbcore-framework/qb-core)

## Konfigürasyon

### Craft Konumları

`config.lua` dosyasında craft konumlarını ayarlayabilirsiniz:

```lua
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
    }
}
```

### Craft Itemleri

Craft edilebilir itemleri `config.lua` dosyasında tanımlayabilirsiniz:

```lua
Config.CraftItems = {
    ["plastik"] = {
        label = "Plastik",
        image = "plastik.png",
        level = 1,
        xp = 5,
        ingredients = {
            ["petrol"] = 2,
            ["kimyasal"] = 1
        }
    }
}
```

### Level Sistemi

Level sistemi ayarlarını değiştirebilirsiniz:

```lua
Config.LevelSystem = {
    baseXP = 100, -- Her level için gereken XP
    xpMultiplier = 1.2 -- Her level artışında XP çarpanı
}
```

## Kullanım

1. Craft konumuna gidin
2. Target sistemi ile çalışma tezgahına tıklayın
3. Sol panelde level ve XP bilgilerinizi görün
4. Sağ panelde craft edilebilir itemleri seçin
5. Gerekli malzemeleriniz varsa itemi craft edin

## Veritabanı

Script otomatik olarak `boa_craft_levels` tablosunu oluşturur:

```sql
CREATE TABLE `boa_craft_levels` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(50) NOT NULL,
    `level` int(11) DEFAULT 1,
    `xp` int(11) DEFAULT 0,
    `total_xp` int(11) DEFAULT 0,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
);
```

## Item Resimleri

Item resimlerini `C:\Users\Administrator\Desktop\BGZC-Zombie\txData\BGZCZombie\resources\[ox]\ox_inventory\web\images` klasöründen alabilirsiniz.

## Komutlar

- `/craft` - Craft menüsünü aç (geliştirme için)

## Destek

Herhangi bir sorun yaşarsanız, lütfen GitHub üzerinden issue açın.

## Lisans

Bu script MIT lisansı altında lisanslanmıştır.

## Güncellemeler

### v1.0.0
- İlk sürüm
- Temel craft sistemi
- Level ve XP sistemi
- Modern UI
- Target sistemi entegrasyonu
