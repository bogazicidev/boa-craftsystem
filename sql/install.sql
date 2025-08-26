-- BOA Craft Sistemi Veritabanı Kurulumu
-- Bu dosyayı veritabanınızda çalıştırın

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

-- Örnek veriler (isteğe bağlı)
-- INSERT INTO `boa_craft_levels` (`identifier`, `level`, `xp`, `total_xp`) VALUES
-- ('test_player_1', 1, 0, 0),
-- ('test_player_2', 5, 75, 475);

-- Tablo yapısını kontrol etmek için
-- DESCRIBE `boa_craft_levels`;

-- Mevcut kayıtları görmek için
-- SELECT * FROM `boa_craft_levels`;
