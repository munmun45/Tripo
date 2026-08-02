-- Safe package seed (no ALTER). Run in phpMyAdmin if Packages tab is empty.
USE `u337172093_tripo`;

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
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_packages_city` (`city`),
  KEY `idx_packages_country` (`country`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- Optional (only if is_admin column already exists):
-- UPDATE `users` SET `is_admin` = 1 WHERE `phone` IN ('9876543210', '9999999999');
-- Or open once: /tripo/api/tools/ensure_admin_schema.php
