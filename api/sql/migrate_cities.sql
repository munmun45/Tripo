-- Countries, states, cities for admin Cities page
USE `u337172093_tripo`;

CREATE TABLE IF NOT EXISTS `countries` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(120) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_country_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `states` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `country_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(120) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_state_country` (`country_id`, `name`),
  KEY `idx_states_country` (`country_id`),
  CONSTRAINT `fk_states_country`
    FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cities` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(120) NOT NULL,
  `country_id` INT UNSIGNED NOT NULL,
  `state_id` INT UNSIGNED NOT NULL,
  `image_url` VARCHAR(500) NOT NULL DEFAULT '',
  `tagline` VARCHAR(200) NOT NULL DEFAULT '',
  `active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_city_state` (`state_id`, `name`),
  KEY `idx_cities_country` (`country_id`),
  CONSTRAINT `fk_cities_country`
    FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cities_state`
    FOREIGN KEY (`state_id`) REFERENCES `states` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed countries
INSERT INTO `countries` (`name`) VALUES
('India'),('UAE'),('France'),('Indonesia'),('Japan'),('USA'),('UK'),
('Singapore'),('Greece'),('Switzerland'),('Maldives'),('Iceland'),('Canada')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Seed states (name + country)
INSERT INTO `states` (`country_id`, `name`)
SELECT c.id, s.name FROM `countries` c
JOIN (
  SELECT 'India' AS country, 'Goa' AS name UNION ALL
  SELECT 'India', 'Maharashtra' UNION ALL
  SELECT 'India', 'Delhi' UNION ALL
  SELECT 'India', 'Karnataka' UNION ALL
  SELECT 'India', 'Himachal Pradesh' UNION ALL
  SELECT 'UAE', 'Dubai' UNION ALL
  SELECT 'France', 'Île-de-France' UNION ALL
  SELECT 'Indonesia', 'Bali' UNION ALL
  SELECT 'Japan', 'Tokyo' UNION ALL
  SELECT 'Japan', 'Kyoto' UNION ALL
  SELECT 'USA', 'New York' UNION ALL
  SELECT 'UK', 'England' UNION ALL
  SELECT 'Singapore', 'Singapore' UNION ALL
  SELECT 'Greece', 'South Aegean' UNION ALL
  SELECT 'Switzerland', 'Bern' UNION ALL
  SELECT 'Maldives', 'Kaafu' UNION ALL
  SELECT 'Iceland', 'Capital Region' UNION ALL
  SELECT 'Canada', 'Alberta'
) s ON s.country = c.name
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- Seed cities (matched to app destinations)
INSERT INTO `cities` (`name`, `country_id`, `state_id`, `image_url`, `tagline`, `active`)
SELECT x.city, c.id, st.id, x.image_url, x.tagline, 1
FROM (
  SELECT 'Goa' AS city, 'India' AS country, 'Goa' AS state,
    'https://images.unsplash.com/photo-1512343879784-a9602f3c5d45?w=800&q=80' AS image_url,
    'Beaches & nightlife' AS tagline
  UNION ALL SELECT 'Dubai','UAE','Dubai','https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80','Luxury skyline'
  UNION ALL SELECT 'Paris','France','Île-de-France','https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=80','Romance & culture'
  UNION ALL SELECT 'Bali','Indonesia','Bali','https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800&q=80','Temples & calm'
  UNION ALL SELECT 'Mumbai','India','Maharashtra','https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?w=800&q=80','City of dreams'
  UNION ALL SELECT 'Delhi','India','Delhi','https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800&q=80','Heritage capital'
  UNION ALL SELECT 'Bengaluru','India','Karnataka','https://images.unsplash.com/photo-1596176538476-4cf8c2f6f8f2?w=800&q=80','Garden city'
  UNION ALL SELECT 'Tokyo','Japan','Tokyo','https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800&q=80','Neon & tradition'
  UNION ALL SELECT 'New York','USA','New York','https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800&q=80','The big apple'
  UNION ALL SELECT 'London','UK','England','https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&q=80','History & style'
  UNION ALL SELECT 'Singapore','Singapore','Singapore','https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=800&q=80','Garden metropolis'
  UNION ALL SELECT 'Santorini','Greece','South Aegean','https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800&q=80','Sunset cliffs'
  UNION ALL SELECT 'Kyoto','Japan','Kyoto','https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80','Temples & tea'
  UNION ALL SELECT 'Ubud','Indonesia','Bali','https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800&q=80','Rice terraces'
  UNION ALL SELECT 'Interlaken','Switzerland','Bern','https://images.unsplash.com/photo-1527004013197-933c4bb611b3?w=800&q=80','Alpine adventure'
) x
JOIN `countries` c ON c.name = x.country
JOIN `states` st ON st.name = x.state AND st.country_id = c.id
ON DUPLICATE KEY UPDATE
  `image_url` = VALUES(`image_url`),
  `tagline` = VALUES(`tagline`);
