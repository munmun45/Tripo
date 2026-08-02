-- Extra package fields to match Tripo app TravelPackage model
-- Skip if columns already exist (#1060)

USE `u337172093_tripo`;

ALTER TABLE `travel_packages`
  ADD COLUMN `highlights` TEXT NULL AFTER `description`,
  ADD COLUMN `includes` TEXT NULL AFTER `highlights`;
