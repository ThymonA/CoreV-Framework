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

--- Cache global variables
local assert = assert

--- Cahce FiveM globals
local exports = assert(exports)

--- Load translation module in configuration
local cvf_translations = assert(exports['cvf_translations'] or {})
local getTranslation = assert(cvf_translations.__t or function() return 'MISSING TRANSLATION' end)
local _T = function(...) return getTranslation(cvf_translations, ...) end

local config = {}

--- Default job for any player (fallback job)
config.defaultJob = {
    name = 'unemployed',
    label = _T('jobs', 'unemployed_label')
}

--- Default grade for any player (fallback grade)
config.defaultGrade = {
    name = 'unemployed',
    label = _T('jobs', 'unemployed_label')
}

return config