-- Add admin flag for Windows admin app
ALTER TABLE `users`
  ADD COLUMN `is_admin` TINYINT(1) NOT NULL DEFAULT 0 AFTER `phone`;

UPDATE `users` SET `is_admin` = 1 WHERE `phone` = '9876543210';
