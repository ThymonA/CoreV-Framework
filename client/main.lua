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
Citizen.CreateThread(function()
    print('[^5Core^4V^7] Is now loading.....')

	resource:loadAll()

    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    print(('============= [ ^5Core^4V^7 ] =============\n^2All framework executables are loaded ^7\n=====================================\n-> ^1External Resources: ^7%s ^7\n-> ^1Internal Resources: ^7%s ^7\n-> ^1Internal Modules:   ^7%s ^7\n=====================================\n^3VERSION: ^71.0.0\n============= [ ^5Core^4V^7 ] =============')
        :format(resource:countAllLoaded()))

    return
end)

Citizen.CreateThread(function()
	while true do
		if (NetworkIsSessionStarted() or NetworkIsPlayerActive(PlayerId())) then
			TSE('corev:core:playerLoaded')
			return
        end
        
        Citizen.Wait(0)
	end
end)