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
local class = assert(class)
local corev = assert(corev)
local ipairs = assert(ipairs)
local pairs = assert(pairs)
local insert = assert(table.insert)
local lower = assert(string.lower)
local error = assert(error)

--- Create a `jobs` class
local jobs = class "jobs"

--- Set default values
jobs:set {
    jobs = {},
    defaultJob = {
        job_id = nil,
        grade = nil
    }
}

--- Creates a job object based on given `name` and `grades`
--- @param name string Name of job, example: unemployed, police etc. (lowercase)
--- @param label string Label of job, this will be displayed as name of given job
--- @param grades table List of grades as table, every grade needs to be a table as well
--- @return job|nil Returns a `job` class if found or created, otherwise `nil`
local function createJobObject(name, label, grades)
    name = corev:ensure(name, 'unknown')
    label = corev:ensure(label, 'Unknown')
    grades = corev:ensure(grades, {})

    if (name == 'unknown') then
        return nil
    end

    name = lower(name)

    --- If job already exists, then return stored job and don't override existing one
    for _, _job in pairs(jobs.jobs) do
        if (_job.name == name) then
            return _job
        end
    end

    --- Create a `job` class
    local job = class "job"

    --- Set default values
    job:set {
        id = nil,
        name = name,
        label = label,
        grades = {}
    }

    local existingId = corev.db:fetchScalar('SELECT `id` FROM `jobs` WHERE `name` = @name LIMIT 1', {
        ['@name'] = job.name
    })

    if (existingId == nil) then
        job.id = corev.db:insert('INSERT INTO `jobs` (`name`, `label`) VALUES (@name, @label)', {
            ['@name'] = job.name,
            ['@label'] = job.label
        })
    else
        job.id = corev:ensure(existingId, 0)
    end

    if (corev:typeof(grades) == 'table') then
        for index, grade in ipairs(grades) do
            if (corev:typeof(grade) == 'table') then
                --- Create a `job-grade` class
                local jobGrade = class "job-grade"

                --- Set default values
                jobGrade:set {
                    job_id = job.id,
                    grade = corev:ensure(index, 1) - 1,
                    name = lower(corev:ensure(grade.name, 'unknown')),
                    label = corev:ensure(grade.label, 'Unknown')
                }

                job.grades[jobGrade.grade] = jobGrade
            end
        end
    end

    local dbGrades = corev.db:fetchAll('SELECT * FROM `job_grades` WHERE `job_id` = @jobId', {
        ['@jobId'] = job.id
    })

    local existingGrades = {}

    --- Update job_grades
    for _, grade in pairs(job.grades) do
        for _, dbGrade in pairs(dbGrades) do
            if (corev:ensure(dbGrade.grade, -1) == grade.grade) then
                insert(existingGrades, grade)

                if (grade.name ~= dbGrade.name or grade.label ~= dbGrade.label) then
                    corev.db:execute('UPDATE `job_grades` SET `name` = @name, `label` = @label WHERE `job_id` = @jobId AND `grade` = @grade', {
                        ['@name'] = grade.name,
                        ['@label'] = grade.label,
                        ['@jobId'] = job.id,
                        ['@grade'] = grade.grade
                    })
                end
            end
        end
    end

    --- Add job_grades
    for _, grade in pairs(job.grades) do
        local needToBeAdded = true

        for _, existingGrade in pairs(existingGrades) do
            if (grade.grade == existingGrade.grade) then
                needToBeAdded = false
            end
        end

        if (needToBeAdded) then
            corev.db:insert('INSERT INTO `job_grades` (`job_id`, `grade`, `name`, `label`) VALUES (@jobId, @grade, @name, @label)', {
                ['@jobId'] = job.id,
                ['@grade'] = grade.grade,
                ['@name'] = grade.name,
                ['@label'] = grade.label
            })
        end
    end

    --- Load default job if not already loaded
    if (jobs.defaultJob.job_id == nil) then
        --- Load default job names from configuration
        local defaultJobName = lower(corev:ensure(corev:cfg('jobs', 'defaultJob', 'name'), 'unemployed'))
        local defaultJobGrade = lower(corev:ensure(corev:cfg('jobs', 'defaultGrade', 'name'), 'unemployed'))

        local jobGradeResult = corev.db:fetchAll('SELECT `job_id`, `grade` FROM `job_grades` WHERE `job_id` = (SELECT `id` FROM `jobs` WHERE `name` = @jobName LIMIT 1) AND `name` = @gradeName LIMIT 1', {
            ['@jobName'] = defaultJobName,
            ['@gradeName'] = defaultJobGrade
        })

        jobGradeResult = corev:ensure(jobGradeResult, {})

        if (#jobGradeResult <= 0) then
            error(corev:t('jobs', 'default_job_not_exists'))
            return
        end

        local dbJobId = corev:ensure(jobGradeResult[1].job_id, -1)
        local dbJobGrade = corev:ensure(jobGradeResult[1].grade, -1)

        if (dbJobId < 0 or dbJobGrade < 0) then
            error(corev:t('jobs', 'default_job_not_exists'))
            return
        end

        jobs.defaultJob.job_id = dbJobId
        jobs.defaultJob.grade = dbJobGrade
    end

    --- Delete job_grades
    for _, dbGrade in pairs(dbGrades) do
        local canBeRemoved = true

        for _, existingGrade in pairs(existingGrades) do
            if (corev:ensure(dbGrade.grade, -1) == existingGrade.grade) then
                canBeRemoved = false
            end
        end

        if (canBeRemoved) then
            if (corev.db:tableExists('players')) then
                --- Change `job` values if player has removable `job` and `grade`
                corev.db:execute('UPDATE `players` SET `job` = @newJob, `grade` = @newGrade WHERE `job` = @oldJob AND `grade` = @oldGrade', {
                    ['@oldJob'] = dbGrade.job_id,
                    ['@oldGrade'] = dbGrade.grade,
                    ['@newJob'] = jobs.defaultJob.job_id,
                    ['@newGrade'] = jobs.defaultJob.grade
                })

                --- Change `job2` values if player has removable `job2` and `grade2`
                corev.db:execute('UPDATE `players` SET `job2` = @newJob, `grade2` = @newGrade WHERE `job2` = @oldJob AND `grade2` = @oldGrade', {
                    ['@oldJob'] = dbGrade.job_id,
                    ['@oldGrade'] = dbGrade.grade,
                    ['@newJob'] = jobs.defaultJob.job_id,
                    ['@newGrade'] = jobs.defaultJob.grade
                })
            end

            --- After players has been updated, `job_grades` is safe to remove
            corev.db:execute('DELETE FROM `job_grades` WHERE `job_id` = @jobId AND `grade` = @grade', {
                ['@jobId'] = dbGrade.job_id,
                ['@grade'] = dbGrade.grade
            })
        end
    end

    jobs.jobs[job.id] = job

    return job
end

--- Register `createJobObject` as global function
global.createJobObject = createJobObject