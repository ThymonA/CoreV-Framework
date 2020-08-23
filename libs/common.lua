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
CoreV      = {
    Translations = {}
}

_ENV.SERVER             = IsDuplicityVersion()
_ENV.CLIENT             = not _ENV.SERVER
_ENV.OperatingSystem    = Config.OS
_ENV.IDTYPE             = string.lower(Config.IdentifierType or 'license')
_ENV.LANGUAGE           = string.lower(Config.Langauge or 'en')
_G.SERVER               = IsDuplicityVersion()
_G.CLIENT               = not _G.SERVER
_G.OperatingSystem      = Config.OS
_G.IDTYPE               = string.lower(Config.IdentifierType or 'license')
_G.LANGUAGE             = string.lower(Config.Langauge or 'en')

if (SERVER) then
    _ENV.DBNAME = Config.DatabaseName or 'Unknown'
    _G.DBNAME = Config.DatabaseName or 'Unknown'
end