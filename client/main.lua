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
Citizen.CreateThread(function()
	resource:loadAll()

    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    print(('=========== [ CoreV ] ===========\nAll framework executables are loaded \n-> External Resources: %s\n-> Internal Resources: %s\n-> Internal Modules: %s\n=========== [ CoreV ] ===========')
        :format(resource:countAllLoaded()))
end)

Citizen.CreateThread(function()
	while true do
		if (NetworkIsSessionStarted() or NetworkIsPlayerActive(PlayerId())) then
			TSE('corev:core:playerLoaded')
			break;
        end
        
        Citizen.Wait(0)
	end
end)