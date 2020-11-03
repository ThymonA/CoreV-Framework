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
    ['cvf_player'] = 0
}

--- Execute this sql after `dependencies` has been executed
migration.sql = [[
    CREATE TABLE `player_skins` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `player_id` INT NOT NULL,
        `data`  MEDIUMTEXT NOT NULL,
        `model` VARCHAR(100) NOT NULL DEFAULT 'mp_m_freemode_01',

        CONSTRAINT `fk_player_skins_player_id` FOREIGN KEY (`player_id`) REFERENCES `players`(`id`),

        PRIMARY KEY (`id`)
    );
]]

--- Returns current migration
return migration