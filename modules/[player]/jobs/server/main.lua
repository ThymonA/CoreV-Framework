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
local database = m('database')
local jobs = class('jobs')

--- Set default values
jobs:set {
    jobs = {}
}

--- Load all jobs from database
function jobs:loadJobs()
    local jobInfos = database:fetchAll('SELECT `j`.`id` AS `job_id`, `j`.`name` AS `job_name`, `j`.`label` AS `job_label`, `j`.`whitelisted` AS `job_whitelisted`, `jg`.`grade` AS `grade_grade`, `jg`.`name` AS `grade_name`, `jg`.`label` AS `grade_label`, `jg`.`salary` AS `grade_salary` FROM `job_grades` AS `jg` LEFT JOIN `jobs` AS `j` ON `j`.`id` = `jg`.`job_id` ORDER BY `j`.`name` ASC, `jg`.`grade` ASC', {})

    if (jobInfos ~= nil and #jobInfos > 0) then
        for _, jobInfo in pairs(jobInfos or {}) do
            if (jobs.jobs ~= nil and jobs.jobs[string.lower(jobInfo.job_name)] == nil) then
                local job = class('job')

                --- Set default values
                job:set {
                    id = jobInfo.job_id,
                    name = jobInfo.job_name,
                    label = jobInfo.job_label,
                    whitelisted = jobInfo.job_whitelisted == 1,
                    grades = {}
                }

                --- Get grade by number
                --- @param grade int Grade
                function job:getGrade(grade)
                    if (self.grades[tostring(grade)] ~= nil) then
                        return self.grades[tostring(grade)]
                    end

                    return nil
                end

                --- Get grade by name
                --- @param gradeName string Grade Name
                function job:getGradeByName(gradeName)
                    for _, grade in pairs(self.grades or {}) do
                        if (string.lower(grade.name) == string.lower(gradeName)) then
                            return grade
                        end
                    end

                    return nil
                end

                jobs.jobs[string.lower(jobInfo.job_name)] = job
            end

            local jobGrade = class('job-grade')

            --- Set default values
            jobGrade:set {
                grade = jobInfo.grade_grade,
                name = jobInfo.grade_name,
                label = jobInfo.grade_label,
                salary = jobInfo.grade_salary
            }

            jobs.jobs[string.lower(jobInfo.job_name)].grades[tostring(jobGrade.grade)] = jobGrade
        end
    end
end

--- Get job by name
--- @param jobName string Job Name
function jobs:getJob(id)
    for _, job in pairs(self.jobs or {}) do
        if (job.id == id) then
            return job
        end
    end

    return nil
end

--- Get job by name
--- @param jobName string Job Name
function jobs:getJobByName(jobName)
    if (self.jobs[string.lower(jobName)] ~= nil) then
        return self.jobs[string.lower(jobName)]
    end

    return nil
end

--- Trigger event when database is ready
database:ready(function()
    jobs:loadJobs()
end)

addModule('jobs', jobs)