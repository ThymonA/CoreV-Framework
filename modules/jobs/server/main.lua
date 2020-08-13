----------------------- [ CoreV ] -----------------------
-- GitLab: https://git.thymonarens.nl/ThymonA/corev-framework/
-- GitHub: https://github.com/ThymonA/CoreV-Framework/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: ThymonA
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
            if (jobs.jobs ~= nil and jobs.jobs[jobInfo.job_name] == nil) then
                local job = class('job')

                --- Set default values
                job:set {
                    id = jobInfo.job_id,
                    name = jobInfo.job_name,
                    label = jobInfo.job_label,
                    whitelisted = jobInfo.job_whitelisted == 1,
                    grades = {}
                }

                jobs.jobs[jobInfo.job_name] = job
            end

            local jobGrade = class('job-grade')

            --- Set default values
            jobGrade:set {
                grade = jobInfo.grade_grade,
                name = jobInfo.grade_name,
                label = jobInfo.grade_label,
                salary = jobInfo.grade_salary
            }

            jobs.jobs[jobInfo.job_name].grades[tostring(jobGrade.grade)] = jobGrade
        end
    end
end

--- Trigger event when database is ready
database:ready(function()
    jobs:loadJobs()
end)

addModule('jobs', jobs)