-- Run this in phpMyAdmin if users table already exists (old email-based schema).

ALTER TABLE `users`
  MODIFY `email` VARCHAR(190) NULL,
  MODIFY `phone` VARCHAR(20) NOT NULL;

-- Add unique phone if missing
ALTER TABLE `users`
  ADD UNIQUE KEY `uq_users_phone` (`phone`);

-- Optional: fill empty phones from email local-part (manual check after)
-- UPDATE users SET phone = '9999999999' WHERE phone = '' OR phone IS NULL LIMIT 1;
