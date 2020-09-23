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
local jobs = class('resource_jobs')

--- Set defaults
jobs:set {
    markers = m('markers')
}

for jobName, job in pairs(Config.Jobs or {}) do
    local name = 'unknown'

    if (jobName ~= nil and type(jobName) == 'string') then name = jobName end

    name = string.upper(name)

    for locationName, location in pairs(job or {}) do
        local locName = 'unknown'

        if (locationName ~= nil and type(locationName) == 'string') then locName = locationName end

        locName = string.upper(locName)

        local markers = location.Markers or {}

        for _, marker in pairs(markers) do
            local index = 0

            if (_ ~= nil and type(_) == 'number') then index = _ end

            if (index >= 0 and index <= 9) then
                index = ('0%s'):format(index)
            elseif (index >= 10) then
                index = ('%s'):format(index)
            else
                index = '00'
            end

            jobs.markers:add(('%s_%s'):format(locName, index),
                ('%s_%s'):format(name, locName),
                { jobs = {
                    { name = name, grades = location.Allowed or {} }
                }},
                location.Type or -1,
                marker or vector3(0, 0, 0),
                location.Size or vector3(1.5, 1.5, 0.5),
                location.Color or '#FFFFFF',
                {
                    location = marker or vector3(0, 0, 0),
                    index = tonumber(index),
                    name = locName
                })
        end
    end
end