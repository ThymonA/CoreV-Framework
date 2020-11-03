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
local corev = assert(corev)
local createJobObject = assert(createJobObject)
local getJob = assert(getJob)
local lower = assert(string.lower)

--- Cahce FiveM globals
local exports = assert(exports)

--- Mark this resource as `database` migration dependent resource
corev.db:migrationDependent()

--- Register default job (fallback job)
corev.db:dbReady(function()
    local defaultConfigJob = corev:cfg('jobs', 'defaultJob')
    local defaultConfigGrade = corev:cfg('jobs', 'defaultGrade')

    defaultConfigJob = corev:ensure(defaultConfigJob, {})
    defaultConfigGrade = corev:ensure(defaultConfigGrade, {})

    local defaultJob = {
        name = lower(corev:ensure(defaultConfigJob.name, 'unemployed')),
        label = corev:ensure(defaultConfigJob.label, 'Unemployed')
    }

    local defaultGrade = {
        name = lower(corev:ensure(defaultConfigGrade.name, 'unemployed')),
        label = corev:ensure(defaultConfigGrade.label, 'Unemployed')
    }

    --- Creates default job for any player without job or player's where job has been removed
    createJobObject(defaultJob.name, defaultJob.label, { defaultGrade })
end)

--- Creates a job object based on given `name` and `grades`
--- @param name string Name of job, example: unemployed, police etc. (lowercase)
--- @param label string Label of job, this will be displayed as name of given job
--- @param grades table List of grades as table, every grade needs to be a table as well
--- @return job|nil Returns a `job` class if found or created, otherwise `nil`
function addAJob(name, label, grades)
    name = corev:ensure(name, 'unknown')
    label = corev:ensure(label, 'Unknown')
    grades = corev:ensure(grades, {})

    if (name == 'unknown') then
        return nil
    end

    name = lower(name)

    return createJobObject(name, label, grades)
end

--- Register `addAJob` and `loadJob` as export function
exports('__a', addAJob)
exports('__l', getJob)