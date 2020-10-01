CREATE TABLE `items` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(50) NOT NULL,
	`weight` DECIMAL(5,2) NOT NULL DEFAULT 0,
	`type` VARCHAR(50) NOT NULL DEFAULT 'default',
    `giveable` INT(1) NOT NULL DEFAULT 0,
    `dropable` INT(1) NOT NULL DEFAULT 0,
    `isUnique` INT(1) NOT NULL DEFAULT 0,
	CONSTRAINT `unique_name` UNIQUE (`name`)
);

INSERT INTO `items` (`name`, `weight`, `type`, `giveable`, `dropable`, `isUnique`) VALUES ('unknown', 0, 'unknown', 0, 0, 0);