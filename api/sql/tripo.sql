-- Tripo MySQL schema
-- Import in phpMyAdmin / MySQL for database used by http://munmunmaharana.in/tripo/api
-- Suitable for ~100 concurrent app users with simple PHP + MySQLi.

CREATE DATABASE IF NOT EXISTS `tripo_db`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `tripo_db`;

-- ---------- users ----------
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(120) NOT NULL,
  `email` VARCHAR(190) DEFAULT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `is_admin` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_phone` (`phone`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- sessions / API tokens ----------
CREATE TABLE IF NOT EXISTS `api_tokens` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `token` CHAR(64) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_token` (`token`),
  KEY `idx_token_user` (`user_id`),
  CONSTRAINT `fk_tokens_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- saved travel packages ----------
CREATE TABLE IF NOT EXISTS `saved_packages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `package_id` VARCHAR(40) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_package` (`user_id`, `package_id`),
  CONSTRAINT `fk_saved_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- trip notes ----------
CREATE TABLE IF NOT EXISTS `notes` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(200) NOT NULL DEFAULT '',
  `body` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notes_user` (`user_id`),
  CONSTRAINT `fk_notes_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- todo groups ----------
CREATE TABLE IF NOT EXISTS `todo_groups` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(120) NOT NULL,
  `color_value` INT UNSIGNED NOT NULL DEFAULT 4278218495,
  `icon_code` INT UNSIGNED NOT NULL DEFAULT 58727,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_todo_groups_user` (`user_id`),
  CONSTRAINT `fk_todo_groups_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- todo items ----------
CREATE TABLE IF NOT EXISTS `todo_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` INT UNSIGNED NOT NULL,
  `text` VARCHAR(500) NOT NULL,
  `done` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_todo_items_group` (`group_id`),
  CONSTRAINT `fk_todo_items_group`
    FOREIGN KEY (`group_id`) REFERENCES `todo_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- travel packages catalog ----------
CREATE TABLE IF NOT EXISTS `travel_packages` (
  `id` VARCHAR(40) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `city` VARCHAR(120) NOT NULL,
  `country` VARCHAR(120) NOT NULL,
  `image_url` VARCHAR(500) NOT NULL DEFAULT '',
  `price` DECIMAL(12,2) NOT NULL DEFAULT 0,
  `duration_days` INT UNSIGNED NOT NULL DEFAULT 1,
  `rating` DECIMAL(3,2) NOT NULL DEFAULT 0,
  `reviews` INT UNSIGNED NOT NULL DEFAULT 0,
  `category` VARCHAR(60) NOT NULL DEFAULT '',
  `description` TEXT NULL,
  `highlights` TEXT NULL,
  `includes` TEXT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_packages_city` (`city`),
  KEY `idx_packages_country` (`country`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- demo seed users ----------
-- password set via tools/seed_passwords.php → Tripo@123
INSERT INTO `users` (`name`, `email`, `password_hash`, `phone`, `is_admin`) VALUES
(
  'Demo Traveler',
  '9999999999@tripo.phone',
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  '9999999999',
  1
),
(
  'Munmun Maharana',
  '9876543210@tripo.phone',
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  '9876543210',
  1
)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `is_admin` = VALUES(`is_admin`);

INSERT INTO `travel_packages`
(`id`,`title`,`city`,`country`,`image_url`,`price`,`duration_days`,`rating`,`reviews`,`category`,`description`)
VALUES
('1','Santorini Sunset Escape','Santorini','Greece','https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800&q=80',89999,6,4.90,312,'Romantic','Whitewashed alleys and caldera sunsets.'),
('2','Kyoto Temple Trail','Kyoto','Japan','https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80',124999,6,4.80,248,'Culture','Temples, tea houses and bamboo groves.'),
('3','Bali Wellness Retreat','Ubud','Indonesia','https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800&q=80',67999,3,4.70,189,'Wellness','Yoga, spa and jungle villas.'),
('4','Swiss Alps Adventure','Interlaken','Switzerland','https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&q=80',149999,9,4.90,156,'Adventure','Peaks, trains and glacial lakes.'),
('5','Dubai Desert Luxury','Dubai','UAE','https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80',95999,5,4.80,421,'Luxury','Desert camps and skyline nights.'),
('6','Paris Heritage Walk','Paris','France','https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=80',112999,5,4.80,502,'Culture','Museums, cafes and riverside walks.'),
('7','Maldives Overwater Bliss','Male','Maldives','https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800&q=80',189999,6,4.90,267,'Romantic','Overwater villas and lagoon days.'),
('8','Goa Coastal Escape','Goa','India','https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800&q=80',24999,4,4.60,890,'Beach','Beaches, cafes and sunset cruises.'),
('9','Iceland Northern Lights','Reykjavik','Iceland','https://images.unsplash.com/photo-1531168556467-80aace0d8141?w=800&q=80',159999,7,4.80,143,'Adventure','Auroras, glaciers and hot springs.'),
('10','Manali Mountain Getaway','Manali','India','https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800&q=80',18999,4,4.50,640,'Mountain','Snow peaks and valley drives.'),
('11','Banff Lakeside Escape','Banff','Canada','https://images.unsplash.com/photo-1503614472-8c93d56e92ce?w=800&q=80',134999,6,4.90,210,'Mountain','Turquoise lakes and alpine trails.'),
('12','Jasper Wilderness Trail','Jasper','Canada','https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',129999,7,4.80,118,'Adventure','Wildlife and glacier country.'),
('13','Calgary City Break','Calgary','Canada','https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=800&q=80',79999,3,4.50,95,'Culture','City sights and nearby Rockies.')
ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `city` = VALUES(`city`),
  `country` = VALUES(`country`),
  `price` = VALUES(`price`),
  `category` = VALUES(`category`);

-- After import, open once:
--   http://munmunmaharana.in/tripo/api/tools/seed_passwords.php
-- Demo login: phone 9999999999 / password Tripo@123
-- Then DELETE tools/seed_passwords.php from the server.

INSERT INTO `saved_packages` (`user_id`, `package_id`)
SELECT u.id, x.package_id
FROM `users` u
JOIN (
  SELECT '1' AS package_id UNION ALL
  SELECT '2' UNION ALL
  SELECT '3'
) x
WHERE u.phone = '9999999999'
ON DUPLICATE KEY UPDATE `package_id` = VALUES(`package_id`);
