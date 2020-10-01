CREATE TABLE `weapons` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT DEFAULT NULL,
    `job_id` INT DEFAULT NULL,
    `name` VARCHAR(100) NOT NULL,
	`bullets` INT NOT NULL DEFAULT 120,
    `location` VARCHAR(50) NOT NULL DEFAULT 'safe',
    CONSTRAINT `fk_weapons_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`),
    CONSTRAINT `fk_weapons_job` FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`)
);