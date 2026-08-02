-- Add only is_active column (for Active / Deactive in admin)
-- Run in phpMyAdmin if column does not exist yet.
-- Skip if you get error #1060 (Duplicate column)

USE `u337172093_tripo`;

ALTER TABLE `users`
  ADD COLUMN `is_active` TINYINT(1) NOT NULL DEFAULT 1 AFTER `phone`;

-- Optional: make sure everyone is Active
UPDATE `users` SET `is_active` = 1 WHERE `is_active` IS NULL OR `is_active` = 0;
