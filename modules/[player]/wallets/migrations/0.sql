CREATE TABLE `wallets` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT,
    `name` VARCHAR(50) NOT NULL,
	`balance` INT NOT NULL DEFAULT 0,
    CONSTRAINT `unique_player_wallet` UNIQUE (`player_id`,`name`),
    CONSTRAINT `fk_player` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`)
);