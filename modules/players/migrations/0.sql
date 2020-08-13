CREATE TABLE `players` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
	`accounts` LONGTEXT NOT NULL,
	`job` INT,
	`grade` INT,
	`job2` INT,
	`grade2` INT,
    CONSTRAINT `unique_identifier` UNIQUE (`identifier`),
    CONSTRAINT `fk_job` FOREIGN KEY (`job`,`grade`) REFERENCES `job_grades`(`job_id`,`grade`),
	CONSTRAINT `fk_job2` FOREIGN KEY (`job2`,`grade2`) REFERENCES `job_grades`(`job_id`,`grade`)
);