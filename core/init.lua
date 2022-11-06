---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 18:25
---

local AddonName, E = ...

_G[AddonName] = {
    RegisterModule = function (...)
        E:RegisterModule(...)
    end,
    RegisterEvent = function (...)
        E:RegisterEvent(...)
    end
}


E:RegisterAddon(AddonName)
local EventFrame = CreateFrame('Frame')
E.EventFrame = EventFrame
E:RegisterEvent('ADDON_LOADED')
E:RegisterEvent('CHAT_MSG_ADDON')
E:RegisterEvent('GUILD_ROSTER_UPDATE')
E:RegisterEvent('PLAYER_ENTERING_WORLD')
E:RegisterEvent('GROUP_ROSTER_UPDATE')
EventFrame:RegisterEvent('PLAYER_LOGOUT')


EventFrame:SetScript('OnEvent', function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ADDON_LOADED" then
        E:OnEvent(event, ...)
    else
        if not E.firstLoad then
            E:QueueEvent(event, ...)
        else
            E:OnEvent(...)
        end
    end
end)

