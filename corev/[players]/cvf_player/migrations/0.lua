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
migration.dependencies = {
    ['cvf_jobs'] = 0
}

--- Execute this sql after `dependencies` has been executed
migration.sql = [[
    CREATE TABLE `players` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `identifier` VARCHAR(50) NOT NULL,
        `name` VARCHAR(100) NOT NULL DEFAULT 'Unknown',
        `job` INT,
        `grade` INT,
        `job2` INT,
        `grade2` INT,
        CONSTRAINT `unique_player_identifier` UNIQUE (`identifier`),
        CONSTRAINT `fk_player_job` FOREIGN KEY (`job`,`grade`) REFERENCES `job_grades`(`job_id`,`grade`),
        CONSTRAINT `fk_player_job2` FOREIGN KEY (`job2`,`grade2`) REFERENCES `job_grades`(`job_id`,`grade`)
    );
]]

--- Returns current migration
return migration