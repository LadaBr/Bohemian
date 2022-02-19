---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 21:07
---

local AddonName, E = ...
local LibDeflate = LibStub:GetLibrary("LibDeflate")

Bohemian_LogConfig = {
    autoBackup = 24
}
BohemianDKPLog = {}

Bohemian.RegisterModule(AddonName, E, function()
    E:CreateLogFrame()
    E:CreateLogButton()
    E:AddConfigFrames(E.CORE:CreateModuleInterfaceConfig("Log"))

    Bohemian_LogConfig.playersSyncList = Bohemian_LogConfig.playersSyncList or {}
end)


local C = E.CORE

E.cheaters = {}
E.suspects = {}
E.LOG_QUEUE = {}
E.playersForSync = {}
E.waitingForPlayers = {}
E.lastLogUpdate = {}
E.checkCheatersIn = 5
E.defaultChecksumDelay = 1
E.checksumDelay = E.defaultChecksumDelay
E.isInitialSyncActive = true
E.EVENT_QUEUE = {}

CurrentDKPLog = {}

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

function E:StartAntiCheat()
    C:AddToUpdateQueue(function(_, elapsed)
        if not E.checkedCheaters and E.checkCheatersIn <= 0 then
            E.checkedCheaters = true
            E:CheckSuspects()
        end
        if E.checkCheatersIn > 0 then
            E.checkCheatersIn = E.checkCheatersIn - elapsed
        end
    end)
end

function E:ProcessQueue()
    local i = #E.EVENT_QUEUE
    while #E.EVENT_QUEUE > 0 do
        C:OnEvent(unpack(table.remove(E.EVENT_QUEUE, i)))
        i = i - 1
    end
    E:Debug("Queue processed")
end

function E:ProcessLog(id, time, timeSort, fullName, prev, new, reason, editor, external, reverted)
    if not C.guildRoster[fullName] then
        return
    end
    if not CurrentDKPLog.current.data[fullName] then
        CurrentDKPLog.current.data[fullName] = {}
    end
    time = tonumber(time)
    timeSort = tonumber(timeSort)

    if not time then
        return
    end
    local isExternal = external == "1"
    reverted = reverted == "1"

    local current = tonumber(new)
    CurrentDKPLog.current.data[fullName][id] = { id = id, time = time, prev = tonumber(prev), current = current, reason = reason, editor = editor, external = isExternal, reverted = reverted, timeSort = timeSort }
    local currentFullName = GetGuildRosterInfo(GetGuildRosterSelection());
    E.suspects[fullName] = current
    CurrentDKPLog.current.oldest = (CurrentDKPLog.current.oldest > time or CurrentDKPLog.current.oldest == 0) and time or CurrentDKPLog.current.oldest
    CurrentDKPLog.current.newest = CurrentDKPLog.current.newest < time and time or CurrentDKPLog.current.newest
    if currentFullName == fullName then
        E:RefreshDKPLog(fullName)
    end
end

function E:CheckSuspects()
    for name, dkp in pairs(E.suspects) do
        E:DetectChanges(name, dkp)
        E.suspects[name] = nil
    end
end

function E:GetGuildLog()
    local guildName = GetGuildInfo("player")
    return BohemianDKPLog[guildName]
end

function E:ProcessCheater(fullName, prev, cur)
    self.cheaters[fullName] = true
    if CanEditOfficerNote() and CanEditPublicNote() then
        E:Print(format("%s %s is a cheater! DKP edited outside of the addon! Change: %d -> %d", C:colorize("WARNING!", C.COLOR.RED), C:AddClassColorToName(fullName), prev, cur))
    end
end

function E:DetectChanges(fullName, currentDKP)
    if not C:GetModule("Bohemian_DKP").roster[fullName] then
        return
    end
    self.cheaters[fullName] = false
    local prevItem
    local log = self:GetSortedLog(fullName, "DESC")
    for i = #log, 1, -1 do
        local item = log[i]
        if prevItem then
            if prevItem.current ~= item.prev then
                self:ProcessCheater(fullName, prevItem.current, item.prev)
                return
            end
        end
        prevItem = item
    end
    if prevItem and prevItem.current ~= currentDKP then
        self:ProcessCheater(fullName, prevItem.current, currentDKP)
    end
end
function E:FillExternalEdit(log, fullName)
    return self:FindInconsistencies(log, fullName, function(newLog, prev, cur)
        table.insert(newLog, 1, {
            current = cur or 0,
            prev = prev or 0,
            reason = "External edit"
        })
    end)
end

function E:GetCurrentDKP(fullName)
    return C:GetModule("Bohemian_DKP"):GetCurrentDKP(fullName)
end

function E:FindInconsistencies(log, fullName, cb)
    local prevItem
    local newLog = {}
    for i = #log, 1, -1 do
        local item = log[i]
        if prevItem then
            if prevItem.current ~= item.prev then
                cb(newLog, prevItem.current, item.prev)
            end
        end
        table.insert(newLog, 1, item)
        prevItem = item
    end
    local currentDKP = self:GetCurrentDKP(fullName)
    if prevItem and prevItem.current ~= currentDKP then
        cb(newLog, prevItem.current, currentDKP)
    end
    return newLog
end
function E:ShareLog(id, time, timeSort, fullName, prev, new, reason, editor, external, reverted)
    C:SendPriorityEvent("GUILD", self.EVENT.LOG, id, time, timeSort, fullName, prev, new, reason, editor, external or 0, reverted or 0)
end
function E:AddReason(frame, reason, reverted)
    local prevItem = self.sortedLog[frame.index + 1]
    self:ShareLog(C:uuid(), GetServerTime(), prevItem.time + 1, frame.fullName, frame.item.prev, frame.item.current, reason, C:GetPlayerName(true), 1, reverted)
end

function E:SyncLog()
    C:SendPriorityEvent("GUILD", self.EVENT.SYNC_LOG, Bohemian_LogConfig.lastTimeOnline and Bohemian_LogConfig.lastTimeOnline - 360 or 0)
end
function E:SyncLogFrom(name, since)
    E:Print("Syncing log from", name, date('%Y/%m/%d %H:%M', since))
    C:SendPriorityEventTo(name, self.EVENT.SYNC_LOG, since or 0)
end

function E:LogToChunks(since, cb)
    since = tonumber(since)

    local items = {}
    for name, data in pairs(CurrentDKPLog.current.data) do

        for id, item in pairs(data) do
            if item.time and item.time >= since then
                table.insert(items, { name, item })
            end
        end
    end
    E:Debug("Syncing", #items, "items since", date('%Y/%m/%d %H:%M', tonumber(since)))
    local i = 1
    local chunks = {}
    local payloads = {}
    C:AddToUpdateQueue(function(id)
        for j = 1, 100 do
            if i > #items then
                C:RemoveFromUpdateQueue(id)
                table.insert(payloads, { C:PreparePayloadForSend(chunks) })
                for _, payload in ipairs(payloads) do
                    cb(unpack(payload))
                end
                break
            end
            if i % 100 == 0 then
                table.insert(payloads, { C:PreparePayloadForSend(chunks) })
                chunks = {}
            end
            table.insert(chunks, E:LogItemToPayload(unpack(items[i])))
            i = i + 1
        end
    end)
end
function E:LogItemToPayload(name, item)
    return C:PreparePayload(E.EVENT.LOG, item.id, item.time, item.timeSort, name, item.prev, item.current, item.reason, item.editor or "", item.external and 1 or 0, item.reverted and 1 or 0)
end
function E:DetectChangesAll()
    if self.searchingForCheaters then
        return
    end
    self.searchingForCheaters = true
    local i = 1
    local total = GetNumGuildMembers()
    C:AddToUpdateQueue(function(id)
        if i >= total then
            C:RemoveFromUpdateQueue(id)
            self.searchingForCheaters = false
        end
        local fullName = GetGuildRosterInfo(i);
        E:DetectChanges(fullName, self:GetCurrentDKP(fullName))
        i = i + 1
    end)
end
function E:InitDKPLog()
    local guildName = C:GetGuildName()
    if not BohemianDKPLog[guildName] then
        BohemianDKPLog[guildName] = {
            current = {
                data = {},
                wipes = {},
                oldest = 0,
                newest = 0,
            },
            backup = {},
        }
    end
    CurrentDKPLog = BohemianDKPLog[guildName]
    E.logLoaded = true
    E:UpdateLastBackupInfo()
end
function E:RequestWipeData(fullName)
    if not fullName then
        return
    end
    if not self:CanWipeData() then
        return
    end

    E:Debug("Wiping data of", fullName)
    SendChatMessage(format("DKP data have been wiped for %s", fullName), "GUILD")
    local time = GetServerTime()
    C:SendPriorityEvent("GUILD", "LOG_WIPE", fullName, time)
end
function E:WipeDataAll()
    if not CanEditPublicNote() then
        return
    end
    self:CreateBackup()
    self:RequestWipeData("all")
end
function E:CreateBackup()
    E:Debug("Backup created")
    if not CurrentDKPLog.backup then
        CurrentDKPLog.backup = {}
    end
    local time = GetServerTime()
    local tmp = {}
    for name, data in pairs(CurrentDKPLog.current.data) do
        for _, item in pairs(data) do
            table.insert(tmp, self:LogItemToPayload(name, item))
        end
    end
    CurrentDKPLog.backup[time] = C:encodeBase64(C:EncodePayload(tmp))
    CurrentDKPLog.lastBackup = time
    self:UpdateLastBackupInfo()
end
function E:ProcessLogPayload(data)
    local payload = table.concat(data, "\n")
    local serialized = LibSerialize:Serialize(payload)
    local compressed = LibDeflate:CompressDeflate(serialized)
    return LibDeflate:EncodeForWoWAddonChannel(compressed)
end
function E:ProcessPayloadToLog(data)
    data = LibDeflate:DecodeForWoWAddonChannel(data)
    data = LibDeflate:DecompressDeflate(data)
    local _, deserialized = LibSerialize:Deserialize(data)
    return { strsplit("\n", deserialized) }
end
function E:CheckAutoBackup()
    if Bohemian_LogConfig.autoBackup and Bohemian_LogConfig.autoBackup > 0 then
        if not CurrentDKPLog.lastBackup then
            self:CreateBackup()
        elseif GetServerTime() - CurrentDKPLog.lastBackup > 3600 * Bohemian_LogConfig.autoBackup then
            self:CreateBackup()
        end
    end

    C_Timer.After(60, function()
        E:CheckAutoBackup()
    end)
end

function E:CleanUpLogs()
    for name, data in pairs(CurrentDKPLog.current.data) do
        if not C.guildRoster[name] then
            CurrentDKPLog.current.data[name] = nil
        else
            for id, item in pairs(data) do
                if item.editor == "0" or item.editor == "" or not item.timeSort then
                    CurrentDKPLog.current.data[name][id] = nil
                end
            end
        end
    end
end

function E:DeleteBackup(time)
    CurrentDKPLog.backup[time] = nil
    if CurrentDKPLog.lastBackup == time then
        CurrentDKPLog.lastBackup = nil
    end
    E:UpdateLastBackupInfo()
    E:Print("Deleted backup from", date('%Y/%m/%d %H:%M', time))
end

function E:RestoreBackup(time)
    if self:CanRestoreBackup() then
        E:WipeDataAll()
        C_Timer.After(4, function()

            local data = C:DecodePayload(C:decodeBase64(CurrentDKPLog.backup[time]))
            local name = C:GetPlayerName(true)
            local players = {}
            local time = GetServerTime()
            for i, item in ipairs(data) do
                local event, args = C:ProcessEvent(item, _, name)
                --local time = tonumber(args[2])
                local playerName = args[4]
                if not players[playerName] then
                    players[playerName] = {}
                end
                players[playerName][#players[playerName] + 1] = {
                    args[1],
                    tonumber(args[2]),
                    tonumber(args[3]),
                    args[4],
                    tonumber(args[5]),
                    tonumber(args[6]), args[7], args[8], args[9]
                }
                --local value = tonumber(args[5])
                --local prevValue = tonumber(args[4])
                --if not playersTime[playerName] then
                --    playersTime[playerName] = time
                --    playersValue[playerName] = value
                --    playersValueLowest[playerName] = prevValue
                --elseif playersTime[playerName] < time then
                --    playersValue[playerName] = value
                --elseif playersTime[playerName] > time then
                --    playersValueLowest[playerName] = prevValue
                --end
                --E:ShareLog(args[1], time + i, args[3], args[4], args[5], args[6], args[7], args[8], args[9])
                --print(args[1], time + i , args[3], args[4], args[5], args[6], args[7], args[8], args[9])
            end
            for player, items in pairs(players) do
                table.sort(items, function(a, b)
                    return a[3] < b[3]
                end)
                local oldest = items[1]
                local newest = items[#items]
                if C.rosterIndex[player] then
                    C:GetModule("Bohemian_DKP"):SetDKPSilent(player, C.rosterIndex[player], newest[6])
                end
                E:ShareLog(C:uuid(), time, oldest[3] - 1, player, oldest[5], oldest[5], "Data restored from " .. date('%Y/%m/%d %H:%M', time), C:GetPlayerName(true), 0, 1)
                for i, item in ipairs(items) do
                    E:ShareLog(item[1], time + i, item[3], item[4], item[5], item[6], item[7], item[8], item[9])
                end
                --E:LogToChunks(0, function(id, data)
                --    C:BroadcastPayload("SYNC_LOG", "GUILD", data)
                --end)
            end

            E:Print("Restored backup from", date('%Y/%m/%d %H:%M', time))
        end)

    end
end
function E:CanRestoreBackup()
    return IsGuildLeader()
end

function E:CanWipeData()
    return IsGuildLeader()
end

function E:FinishLogSync()
    E.initialized = true
    E:DetectChangesAll()
    E:ProcessQueue()
    E:Debug("Log synchronization finished in "..(time() - E.longSyncStart).."s")
    E:CleanUpLogs()
    C_Timer.After(10, function()
        E:StartAntiCheat()
    end)
end

function E:StartLogSyncSequence()
    E.longSyncStart = time()
    E:Debug("Synchronizing DKP log...")
    if C:GetPlayerCountWithAddon() == 0 then
        C:OnEvent("START_SYNC_LOG", E.LOG_QUEUE)
    else
        E:RequestLastLogUpdate()
    end

end

function E:GetSortedLog(fullName, order)
    local sortedLog = {}
    if not CurrentDKPLog or not CurrentDKPLog.current then
        return sortedLog
    end
    local sortFn = {
        ASC = function(a, b)
            return a.timeSort < b.timeSort
        end,
        DESC = function(a, b)
            return a.timeSort > b.timeSort
        end
    }
    local log = CurrentDKPLog.current.data[fullName]

    if log then
        for _, data in pairs(log) do
            table.insert(sortedLog, data)
        end
    end
    table.sort(sortedLog, sortFn[order])
    return sortedLog
end

function E:CheckForWipe(fullName, since)
    C:SendPriorityEventTo(fullName, "LAST_WIPE_DATA_REQUEST", since)
end

function E:WipeLog(fullName, time)
    time = time or 0
    for name, items in pairs(CurrentDKPLog.current.data) do
        if name == fullName or fullName == "all" then
            for id, data in pairs(items) do
                if data.time and data.time < time then
                    CurrentDKPLog.current.data[name][id] = nil
                end
            end
        end
    end
    E:Print("Wiped log of", fullName)
    E:UpdateDetailFrame()
end

function E:SaveWipeData(fullName, time)
    time = tonumber(time)
    if not CurrentDKPLog.current.wipes[fullName] then
        CurrentDKPLog.current.wipes[fullName] = {}
    end
    CurrentDKPLog.current.wipes[fullName][time] = time
end

function E:IsWaitingForPlayers()
    local finished = true
    for _, waiting in pairs(E.waitingForPlayers) do
        if waiting then
            finished = false
            break
        end
    end
    return not finished
end

function E:CreateChecksum()
    return LibDeflate:Adler32(CurrentDKPLog.hash)
end

function E:RequestLastLogUpdate()
    E.lastLogUpdate = {}
    -- E:WaitForAll()
    C:SendPriorityEvent("GUILD", "LAST_LOG_UPDATE_REQUEST")
    C_Timer.After(5, function()
        E:UpdateLog()
    end)
end

function E:WaitForAll(cb, playerList)
    for player, _ in pairs(playerList or C.onlineChecks) do
        E.waitingForPlayers[player] = true
        if cb then
            cb(player)
        end
    end
end

function E:WaitForAllList(cb, playerList)
    for _, player in ipairs(playerList) do
        E.waitingForPlayers[player.name] = true
        if cb then
            cb(player)
        end
    end
end

function E:UpdateLog()
    E.LOG_QUEUE = {}
    for player, time in pairs(E.lastLogUpdate) do
        local localPlayerLastSync = Bohemian_LogConfig.playersSyncList[player] or 0
        if time > localPlayerLastSync then
            E:Debug("Adding request to queue for updated log from", player)
            E.LOG_QUEUE[#E.LOG_QUEUE + 1] = {["name"] = player, ["time"] = localPlayerLastSync}
        end
    end
    C:OnEvent("START_SYNC_LOG", E.LOG_QUEUE)
end
