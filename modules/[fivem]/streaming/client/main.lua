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
local streaming = class('streaming')

--- Load a requested model
function streaming:requestModel(hash, cb)
    local model = hash

    if (hash == nil or (type(hash) ~= 'number' and type(hash) ~= 'string')) then return end
    if (type(hash) == 'string') then model = GetHashKey(hash) end

    if (not HasModelLoaded(model) and IsModelInCdimage(model)) then
        RequestModel(hash)

        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
    end

    if (cb ~= nil and type(cb) == 'function') then
        cb()
    end
end

--- Load a texture dictonary and trigger callback when loaded
--- @param textureDictionary string Name of texture dictonary
--- @param cb function Callback
function streaming:requestTextureDictionary(textureDictionary, cb)
    if (textureDictionary == nil or type(textureDictionary) ~= 'string') then return end

    if (not HasStreamedTextureDictLoaded(textureDictionary)) then
        Citizen.CreateThread(function()
            RequestStreamedTextureDict(textureDictionary, true)

            while (not HasStreamedTextureDictLoaded(textureDictionary)) do
                Citizen.Wait(0)
            end

            if (cb ~= nil and type(cb) == 'function') then
                cb()
            end
        end)
    else
        if (cb ~= nil and type(cb) == 'function') then
            cb()
        end
    end
end

addModule('streaming', streaming)