----------------------- [ FXCore ] -----------------------
-- GitLab: https://git.thymonarens.nl/ThymonA/fx_core/
-- GitHub: https://github.com/ThymonA/FXCore/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: ThymonA
-- Name: FXCore
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ FXCore ] -----------------------
FXCore      = {
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