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
    ALTER TABLE `players` ADD `group` VARCHAR(20) NOT NULL DEFAULT 'user' AFTER `name`;
]]

--- Returns current migration
return migration