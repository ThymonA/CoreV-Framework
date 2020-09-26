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
local notifications = class('notifications')

--- Show a notifiaction (client side)
--- @param msg string notification message
--- @param hudColorIndex number Color index
function notifications:showNotification(msg, hudColorIndex)
    if (hudColorIndex == nil or type(hudColorIndex) ~= 'number') then hudColorIndex = 140 end

    SetNotificationTextEntry('STRING')
    SetNotificationFlashColor(hudColorIndex)
    SetNotificationBackgroundColor(hudColorIndex)
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, true)
end

--- Show a help notification
--- @param msg string notification message
--- @param thisFrame number show only this frame
--- @param beep boolean make a beep sound
--- @param duration number duration of message
function notifications:showHelpNotification(msg, thisFrame, beep, duration)
    local name = 'corev:helpNotification'

    if (thisFrame == nil or type(thisFrame) ~= 'number' or type(thisFrame) ~= 'boolean') then thisFrame = false end
    if (type(thisFrame) == 'number' and (thisFrame < 0 or thisFrame > 1)) then thisFrame = false end
    if (beep == nil or type(beep) ~= 'number' or type(beep) ~= 'boolean') then beep = false end
    if (type(beep) == 'number' and (beep < 0 or beep > 1)) then beep = false end
    if (duration == nil or type(duration) ~= 'number') then duration = -1 end

    AddTextEntry(name, msg)

    if (thisFrame) then
        DisplayHelpTextThisFrame(name, false)
    else
        BeginTextCommandDisplayHelp(name)
        EndTextCommandDisplayHelp(0, false, beep, duration)
    end
end

addModule('notifications', notifications)