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
    CREATE TABLE `player_identifiers` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `name` VARCHAR(255) NOT NULL,
        `steam` VARCHAR(255) NULL DEFAULT NULL,
        `license` VARCHAR(255) NULL DEFAULT NULL,
        `xbl` VARCHAR(255) NULL DEFAULT NULL,
        `live` VARCHAR(255) NULL DEFAULT NULL,
        `discord` VARCHAR(255) NULL DEFAULT NULL,
        `fivem` VARCHAR(255) NULL DEFAULT NULL,
        `ip` VARCHAR(255) NULL DEFAULT NULL,
        `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`)
    );
]]

--- Returns current migration
return migration