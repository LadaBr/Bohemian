---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 21:19
---

local _, E = ...

local A = E.EVENTS
local C = E.CORE

E.EVENT = {
    LOG = "LOG",
    SYNC_LOG = "SYNC_LOG",
    WIPE_DATA = "WIPE_DATA",
    WIPE_DATA_ALL = "WIPE_DATA_ALL",
}

function A:READY()
    --E:InitDKPLog()
    --E:CleanUpLogs()
    --E:DetectChangesAll()
    E:StartAntiCheat()
    --C_Timer.After(300, function ()
    --    E:CheckAutoBackup()
    --end)
end

function A:LOG(id, time, timeSort, fullName, prev, new, reason, editor, external, reverted)
    if fullName == "all" then
        local totalMembers, _, _ = GetNumGuildMembers();
        for i=1, totalMembers do
            local name = GetGuildRosterInfo(i);
            if name then
                A:LOG_SINGLE(id, time, timeSort, name, prev, new, reason, editor, external, reverted)
            end
        end
    else
        A:LOG_SINGLE(id, time, timeSort, fullName, prev, new, reason, editor, external, reverted)
    end
end

function A:LOG_SINGLE(id, time, timeSort, fullName, prev, new, reason, editor, external, reverted)
    E:ProcessLog(id, time, timeSort, fullName, prev, new, reason, editor, external, reverted)
end



function A:SYNC_LOG(since, sender)
    if sender == C:GetPlayerName(true) then
        return
    end
    E:LogToChunks(since, function(id, data)
        C:SendEventTo(sender, C.EVENT.PAYLOAD_START, "SYNC_LOG", #data, id)
    end)
end

function A:DKP_CHANGED(time, fullName, prevValue, value, reason, editor)
    E:Debug("DKP changed:", time, fullName, prevValue, value, reason, editor)
    E:ShareLog(C:uuid(), time, time, fullName, prevValue, value, reason, editor)
end

function A:CACHED_GUILD_MEMBER(_, fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway, classFileName)
    if not E.initialized then
        return
    end
    local currentDKP = C:GetModule("Bohemian_DKP"):NoteDKPToNumber(note)
    if C:GetModule("Bohemian_DKP").roster[fullName] ~= currentDKP then
        E.suspects[fullName] = currentDKP
    end
end

function A:CACHED_GUILD_DATA()
    E.checkedCheaters = false
    E.checkCheatersIn = 5
end

function A:GUILD_FRAME_UPDATE()
    if E.logLoaded then
        E:UpdateDetailFrame()
    end
    if E:CanWipeData() then
        BohemkaDKPLogFrameWipe:Show()
        BohemianInterfaceOptionsPanelLogWipe:Enable()
    else
        BohemkaDKPLogFrameWipe:Hide()
        BohemianInterfaceOptionsPanelLogWipe:Disable()
    end
end


function A:GUILD_FRAME_AFTER_UPDATE()
    E:UpdateCheaters()
end

function A:SYNC_READY()
    E:InitDKPLog()
    E:Debug("Amount of players with addon", C:GetPlayerCountWithAddon())
    if C:GetPlayerCountWithAddon() == 0 then
        E:Debug("No players for wipe check. Skipping to log sync.")
        E:StartLogSyncSequence()
    else
        E:WaitForAll(function(player)
            E:CheckForWipe(player, 0)
        end)
        C_Timer.After(5, function()
            E:StartLogSyncSequence()
        end)
    end
end


function A:START_SYNC_LOG(players)
    if #players == 0 then
        E:Debug("Log is already synced.")
        E:FinishLogSync()
        return
    end
    E:WaitForAllList(function(player)
        E:SyncLogFrom(player.name, player.time)
    end, players)
end

function A:PAYLOAD_PROCESSED(type, _, sender)
    if type == "SYNC_LOG" then
        local chunks = C:GetPlayerChunks(name, type)
        if #chunks == 0 then
            E.waitingForPlayers[sender] = false
            E:Debug("Synced log of", sender)
            Bohemian_LogConfig.playersSyncList[sender] = GetServerTime()
            if not E:IsWaitingForPlayers() then
                E:Debug("Log was synced to latest version")
                E:FinishLogSync()
            end
        end
    end
end

function A:LAST_WIPE_DATA_REQUEST(since, sender)
    since = tonumber(since)
    local tmp = {}
    local total = 0
    for name, wipes in pairs(CurrentDKPLog.current.wipes) do
        for _, wipe in pairs(wipes) do
            if wipe >= since then
                if not tmp[name] then
                    tmp[name] = wipe
                    total = total + 1
                elseif tmp[name] < wipe then
                    tmp[name] = wipe
                end
            end
        end
    end

    for name, wipe in pairs(tmp) do
        total = total - 1
        C:SendPriorityEventTo(sender, "LAST_WIPE_DATA", name, wipe, total)
    end
end

function A:LAST_WIPE_DATA(name, time, remaining, sender)
    if tonumber(remaining) <= 0 then
        E.waitingForPlayers[sender] = nil
    end
    E:SaveWipeData(name, tonumber(time))
    E:Debug("Received wipe time for", name, time, sender)
    E:WipeLog(name, tonumber(time))
    if not E:IsWaitingForPlayers() then
        E:StartLogSyncSequence()
    end
end

function A:LOG_WIPE(fullName, time)
    time = tonumber(time)
    E:SaveWipeData(fullName, time)
    E:WipeLog(fullName, time)
end

function A:GUILD_MEMBER_COUNT_CHANGED(_, online)
    for player, _ in pairs(online) do
        E:CheckForWipe(player.name, 0)
        C:SendPriorityEventTo(player.name, "LAST_LOG_UPDATE_REQUEST_SINGLE")
    end
end

function A:LAST_LOG_UPDATE_REQUEST(sender)
    if not E.initialized then
        E.EVENT_QUEUE[#E.EVENT_QUEUE + 1] = {"LAST_LOG_UPDATE_REQUEST", sender}
        return
    end
    C:SendPriorityEventTo(sender, "LAST_LOG_UPDATE", CurrentDKPLog.current.newest)
end

function A:LAST_LOG_UPDATE_REQUEST_SINGLE(sender)
    if not E.initialized then
        E.EVENT_QUEUE[#E.EVENT_QUEUE + 1] = {"LAST_LOG_UPDATE_REQUEST", sender}
        return
    end
    C:SendPriorityEventTo(sender, "LAST_LOG_UPDATE_SINGLE", CurrentDKPLog.current.newest)
end

function A:LAST_LOG_UPDATE(time, sender)
    if sender == C:GetPlayerName(true) then
        return
    end
    E.waitingForPlayers[sender] = nil
    time = tonumber(time)
    E.lastLogUpdate[sender] = time
    if not E:IsWaitingForPlayers() then
        E:UpdateLog()
    end
end

function A:LAST_LOG_UPDATE_SINGLE(time, sender)
    time = tonumber(time)
    local localPlayerLastSync = Bohemian_LogConfig.playersSyncList[sender] or 0
    if time > localPlayerLastSync then
        E:SyncLogFrom(sender, localPlayerLastSync)
    end
end
