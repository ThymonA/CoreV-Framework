----------------------- [ CoreV ] -----------------------
-- GitLab: https://git.arens.io/ThymonA/corev-framework/
-- GitHub: https://github.com/ThymonA/CoreV-Framework/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: Thymon Arens <contact@arens.io>
-- Name: CoreV
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ CoreV ] -----------------------
local migration = {}

--- Prevent migration from executing before dependend sql has been executed
migration.dependencies = {}

--- Execute this sql after `dependencies` has been executed
migration.sql = [[
    CREATE TABLE `jobs` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `name` VARCHAR(20) NOT NULL DEFAULT 'unknown',
        `label` VARCHAR(50) NOT NULL DEFAULT 'Unknown',
        CONSTRAINT `unique_name` UNIQUE (`name`)
    );

    CREATE TABLE `job_grades` (
        `job_id` INT,
        `grade` INT(5) NOT NULL DEFAULT 0,
        `name` VARCHAR(20) NOT NULL DEFAULT 'unknown',
        `label` VARCHAR(50) NOT NULL DEFAULT 'Unknown',
        PRIMARY KEY (`job_id`,`grade`),
        CONSTRAINT `unique_job_name` UNIQUE (`job_id`, `name`),
        CONSTRAINT `fk_job_grades_jobs` FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`)
    );
]]

--- Returns current migration
return migration