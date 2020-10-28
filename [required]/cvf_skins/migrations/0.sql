CREATE TABLE `player_skins` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(100) NOT NULL,
   	`data`  MEDIUMTEXT NOT NULL,
	`model` VARCHAR(100) NOT NULL DEFAULT 'mp_m_freemode_01',

    CONSTRAINT `unique_player_skins_identifier` UNIQUE (`identifier`),

	PRIMARY KEY (`id`)
);