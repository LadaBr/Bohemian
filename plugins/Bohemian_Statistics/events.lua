---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 22:06
---

local _, E = ...

local A = E.EVENTS
local C = E.CORE
E.EVENT = {
    STATS = "STATS",
    REQUEST_STATS = "REQUEST_STATS",
}

C:RegisterEvent('ACHIEVEMENT_EARNED')
C:RegisterEvent('PLAYER_PVP_KILLS_CHANGED')
C:RegisterEvent('ARENA_TEAM_UPDATE')
C:RegisterEvent('PVP_RATED_STATS_UPDATE')

function A:READY()
    E:RequestStats()
    --E:ShareStats()
end

function A:GUILD_FRAME_BEFORE_UPDATE()
    E:UpdateSelectedListFrame()
end

function A:GUILD_FRAME_UPDATE()
    E:UpdateSelectedListFrame()
end

function A:GUILD_ROSTER_UPDATE()
    if E.selectedList ~= 3 then
        E.updateWhenOpened = true
    else
        E.shouldRefresh = true
        E.refreshIn = 0.01
    end
end

function A:GUILD_FRAME_AFTER_UPDATE()
    E:UpdateSelectedListFrame()
    E:UpdateStatisticRows()
    if E.selectedList == 3 and E.updateWhenOpened then
        E.updateWhenOpened = false
        E:UpdateMemberStats()
        return
    end
end

--function A:UPDATE_GUILD_MEMBER(row, i, numMembers, fullName, rank, rankIndex, level, class, zone, note, officerNote, online, isAway, classFileName)
--    E.members[row] = {
--        index = i,
--        name = fullName,
--        online = online,
--        classFileName = classFileName
--    }
--    local stats = Bohemian_Statistics[fullName]
--    if stats then
--        for k, v in pairs(stats) do
--            E.members[row][k] = v
--        end
--    end
--    print("Updated", row, fullName)
--    if row == GUILDMEMBERS_TO_DISPLAY then
--        E:UpdateStatisticRows()
--    end
--end


function A:STATS(achievementPoints, hk, rat2v2, rat3v3, rat5v5, rep, sender)
    Bohemian_Statistics.players[sender] = {
        achievement = tonumber(achievementPoints),
        hk = tonumber(hk),
        arena2v2 = tonumber(rat2v2),
        arena3v3 = tonumber(rat3v3),
        arena5v5 = tonumber(rat5v5),
        rep = tonumber(rep)
    }
    if E.refreshIn <= 0 then
        E:UpdateMemberStats()
    else
        E.shouldRefresh = true
    end

    E.refreshIn = 5
end

function A:REQUEST_STATS(sender)
    if sender == C:GetPlayerName(true) then
        return
    end
    E:ShareStats(sender)
end

function A:ACHIEVEMENT_EARNED()
    E:ShareStats()
end

function A:PLAYER_PVP_KILLS_CHANGED()
    E:ShareStats()
end

function A:ARENA_TEAM_UPDATE()
    E:ShareStats()
end

function A:PVP_RATED_STATS_UPDATE()
    E.statsLoaded = true
    E:ShareStats()
end

function A:REPUTATION_CHANGED(playerName)
    if playerName ~= C:GetPlayerName(true) then
        return
    end
    E:ShareStats()
end