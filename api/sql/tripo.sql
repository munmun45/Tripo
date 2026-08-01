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

-- ---------- demo seed users ----------
-- password set via tools/seed_passwords.php → Tripo@123
INSERT INTO `users` (`name`, `email`, `password_hash`, `phone`) VALUES
(
  'Demo Traveler',
  '9999999999@tripo.phone',
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  '9999999999'
),
(
  'Munmun Maharana',
  '9876543210@tripo.phone',
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  '9876543210'
)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

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
