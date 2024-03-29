---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 06.11.2022 15:31
---
local _, E = ...


E.raidMembers = {}
E.raidMembersIndex = {}
E.raidMembersOffline = {}


function E:CacheRaid()
    local members = GetNumGroupMembers();
    local realmName = GetNormalizedRealmName()
    local newRaidMembers = {}
    local newRaidMembersIndex = {}
    local newRaidMembersOffline = {}
    for i = 1, members do
        local name, _, _, _, class, fileName, _, online, _, role = GetRaidRosterInfo(i)
        if name then
            name, realm = UnitFullName(name)
            if not realm or #realm <= 0 then
                realm = realmName
            end
            local fullName = name .. "-" .. realm
            newRaidMembers[fullName] = { name = name, realm = realm, fullName = fullName, fileName = fileName, class = class, online = online, role = role }
            newRaidMembersIndex[i] = fullName
            if not online then
                newRaidMembersOffline[fullName] = newRaidMembers[fullName]
            end
        end
    end
    E.raidMembers = newRaidMembers
    E.raidMembersIndex = newRaidMembersIndex
    E.raidMembersOffline = newRaidMembersOffline
end


function E:GetGuildMembersInRaid()
    local members = {}
    local total = 0
    for name, member in pairs(E.raidMembers) do
        if E.guildRoster[name] then
            members[name] = member
            total = total + 1
        end
    end
    return members, total
end

function E:IsGuildRaid()
    local name, type, difficulty, difficultyName, maxPlayers = GetInstanceInfo()
    if type == "raid" then
        local members, total = E:GetGuildMembersInRaid()
        if total / maxPlayers >= Bohemian_RaidConfig.guildRaidMemberRatio / 100 then
            return true
        end
    end
    return false
end