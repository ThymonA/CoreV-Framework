ALTER TABLE `weapons` ADD `components` LONGTEXT NOT NULL AFTER `location`;
ALTER TABLE `weapons` ADD `tint` INT NOT NULL DEFAULT 1 AFTER `components`;