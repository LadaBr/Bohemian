---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 22:06
---

local _, E = ...

local A = E.EVENTS
local C = E.CORE

E.EVENT = {
}

C:RegisterEvent('CHAT_MSG_GUILD_ACHIEVEMENT')
C:RegisterEvent('CHAT_MSG_ACHIEVEMENT')
C:RegisterEvent('ACHIEVEMENT_EARNED')


function A:CHAT_MSG_GUILD_ACHIEVEMENT(...)
    --print("CHAT_MSG_GUILD_ACHIEVEMENT", ...)
end

function A:CHAT_MSG_ACHIEVEMENT(...)
    --print("CHAT_MSG_ACHIEVEMENT", ...)
end

function A:ACHIEVEMENT_EARNED(id)
    local link = GetAchievementLink(id)
    SendChatMessage(format("has earned the achievement %s!", link), "GUILD")
    PlaySound(12891)
    --if IsInRaid() then
    --    SendChatMessage(format("has earned the achievement %s!", link), "RAID")
    --elseif IsInGroup() then
    --    SendChatMessage(format("has earned the achievement %s!", link), "PARTY")
    --end

end