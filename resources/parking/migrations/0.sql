CREATE TABLE `player_vehicles` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT,
    `plate` VARCHAR(10) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
	`vehicle` LONGTEXT  NOT NULL,
    CONSTRAINT `unique_player_vehicles_place` UNIQUE (`plate`),
    CONSTRAINT `fk_player_vehicles_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`)
);