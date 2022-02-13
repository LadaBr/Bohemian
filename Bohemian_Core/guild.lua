---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 17:50
---

local _, E = ...
E.onlinePlayers = {}

function E:GetNumVisibleGuildMembers()
    GuildRoster();
    local totalMembers, onlineMembers, _ = GetNumGuildMembers();
    local numGuildMembers = 0;
    --local showOffline = GuildFrameLFGButton:GetChecked()
    local showOffline = GetGuildRosterShowOffline()
    if (showOffline) then
        numGuildMembers = totalMembers;
    else
        numGuildMembers = onlineMembers;
    end
    return numGuildMembers
end

function E:CacheGuildRoster()
    local newRoster = {}
    local newRosterIndexMap = {}
    local newRosterIndex = {}
    local newOnlinePlayers = {}
    --local newRosterDKP= {}
    local totalMembers, _, _ = GetNumGuildMembers();
    --local canEdit = CanEditPublicNote()
    --local canEditOfficer = CanEditOfficerNote()
    for i = 0, totalMembers do
        local fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway, classFileName = GetGuildRosterInfo(i);
        if fullName then
            newRoster[fullName] = { fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway, classFileName }
            newRosterIndex[fullName] = i
            newRosterIndexMap[i] = fullName
            self:OnEvent("CACHED_GUILD_MEMBER", i, unpack(newRoster[fullName]))
            if online then
                newOnlinePlayers[fullName] = newRoster[fullName]
            end
        end
    end
    self.guildRoster = newRoster
    local wentOffline = {}
    for name, data in pairs(E.onlinePlayers) do
        if not newOnlinePlayers[name] then
            wentOffline[name] = data
        end
    end
    local wentOnline = {}
    for name, data in pairs(newOnlinePlayers) do
        if not E.onlinePlayers[name] then
            wentOnline[name] = data
        end
    end
    if E.firstLoad then
        self:OnEvent(E.EVENT.GUILD_MEMBER_COUNT_CHANGED, wentOffline, wentOnline)
    end
    self.onlinePlayers = newOnlinePlayers
    self.guildRosterIndexMap = newRosterIndexMap
    self.rosterIndex = newRosterIndex
    self:OnEvent(self.EVENT.CACHED_GUILD_DATA)
end

function E:GetGuildMemberByIndex(i)
    return self.guildRoster[self.guildRosterIndexMap[i]]
end

function E:GetGuildName(unit)
    local guildName = GetGuildInfo(unit or "player")
    return guildName
end

function E:GetPlayerCountWithAddon()
    local total = 0
    for _, _ in pairs(E.onlineChecks) do
        total = total + 1
    end
    return total
end