CREATE TABLE `jobs` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(20) NOT NULL,
	`label` VARCHAR(50) NOT NULL DEFAULT '',
	`whitelisted` INT(1) NOT NULL DEFAULT 0,
	CONSTRAINT `unique_name` UNIQUE (`name`)
);

CREATE TABLE `job_grades` (
	`job_id` INT,
    `grade` INT(5) NOT NULL DEFAULT 0,
	`name` VARCHAR(20) NOT NULL DEFAULT '',
	`label` VARCHAR(50) NOT NULL DEFAULT '',
	`salary` INT(3) NOT NULL DEFAULT 0,
	PRIMARY KEY (`job_id`,`grade`),
    CONSTRAINT `unique_job_name` UNIQUE (`job_id`, `name`),
    CONSTRAINT `fk_jobs` FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`)
);