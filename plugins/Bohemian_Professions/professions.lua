---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 18:24
---
local AddonName, E = ...

Bohemian_ProfessionsConfig = {
    showProfessions = true,
    showOwnReagents = true,
    showOfflineMembers = true,
    collapsed = {},
}
Bohemian.RegisterModule(AddonName, E, function()

    Bohemian_ProfessionsConfig.lastCraftSync = Bohemian_ProfessionsConfig.lastCraftSync or {}
    E:CreateGuildFrameProfessionsColumnHeader()
    E:CreateGuildCraftFrame()
    E:AddLFGFrameButton()
    E:CreateGuildCraftListFrame()
    E:AdjustDetailFrame()
    E:RenderColumns()
    E:Hook()
    E:StartCraftHistoryProcessQueue()

end)

local C = E.CORE
E.sharedCrafts = {}
if not Professions then
    Professions = {}
end

if not Crafts then
    Crafts = {}
end

if not CraftsSyncTime then
    CraftsSyncTime = {}
end

E.EVENT = {
    PROFESSION_INFO = "PROFESSION_INFO",
    PROFESSION_INFO_REQUEST = "PROFESSION_INFO_REQUEST",
    CRAFT = "CRAFT",
    CRAFT2 = "CRAFT2",
    CRAFT_HISTORY_REQUEST = "CRAFT_HISTORY_REQUEST",
    CRAFT_HISTORY_SYNC_FINISHED = "CRAFT_HISTORY_SYNC_FINISHED",
}

function E:ShareProfessions(sendTo)
    local skills = {}
    local skillRanks = {}
    for skillIndex = 1, GetNumSkillLines() do
        local skillName, isHeader, _, skillRank, _, _,
        skillMaxRank, _, _, _, _, _,
        _ = GetSkillLineInfo(skillIndex)
        if not isHeader then
            if E.PROFESSIONS[skillName] then
                skillRanks[skillName] = skillRank .. "-" .. skillMaxRank
            end
        end
    end
    local _, _, offset, numSlots = GetSpellTabInfo(1)
    local foundMining = false
    for j = offset + 1, offset + numSlots do
        local name, _, _, _, _, _, spellId = GetSpellInfo(GetSpellBookItemName(j, BOOKTYPE_SPELL))
        if E.PROFESSIONS[name] then
            local data = spellId
            if name ~= "Mining" then
                if name == "Find Herbs" then
                    data = 9134
                    name = "Herbalism"
                elseif name == "Find Minerals" then
                    data = 29354
                    name = "Mining"
                    foundMining = true
                end
                if skillRanks[name] then
                    data = data .. "-" .. skillRanks[name]
                end
                table.insert(skills, data)
            end
        end
    end
    local payload = table.concat(skills, ",")
    C:SendEventTo(sendTo, self.EVENT.PROFESSION_INFO, payload)
end

function E:GetPlayerProfessions(fullName)
    return Professions[fullName] or {}
end

function E:RequestProfessionInfo()
    C:SendEvent("GUILD", self.EVENT.PROFESSION_INFO_REQUEST)
end

function E:RequestProfessionInfoFrom(player)
    C:SendEventTo(player, self.EVENT.PROFESSION_INFO_REQUEST)
end

function E:CanSync()
    return not IsInInstance() and not IsActiveBattlefieldArena()
end

E.updateQueue = {}

function E:ShareCrafts()
    local numCrafts = GetNumCrafts()
    local profName, _, _ = GetCraftDisplaySkillLine()
    if not profName then
        return
    end
    local profId = E.PROFESSION_IDS[profName]
    self.sharedCrafts[profName] = GetServerTime()
    local i = 1
    local wait = 0
    C:AddToUpdateQueue(function(id, elapsed)
        if wait > 0 then
            wait = wait - elapsed
            return
        end
        if i > numCrafts then
            C:RemoveFromUpdateQueue(id)
            C:SendEvent("GUILD", E.EVENT.CRAFT_HISTORY_SYNC_FINISHED, C:GetPlayerName(true), self.sharedCrafts[profName])
            return
        end
        if not E:ValidateCraft(profName) then
            C:RemoveFromUpdateQueue(id)
            return
        end
        local craftName, _, craftType, numAvailable = GetCraftInfo(i)
        local craftTypeId = E.SKILL_TYPE_ID[craftType]
        local numReagents = GetCraftNumReagents(i)
        local minMade, maxMade = GetCraftNumMade(i)
        local link = GetCraftItemLink(i)
        local skillId = E:ParseSpellLink(link)
        local icon = GetCraftIcon(i)
        local cooldown = GetCraftCooldown(i) or 0
        local reagents = {}
        for j = 1, numReagents do
            local _, reagentTexture, reagentCount, playerReagentCount = GetCraftReagentInfo(i, j);
            local reagentLink = GetCraftReagentItemLink(i, j)
            local reagentId = E:ParseItemLink(reagentLink)
            table.insert(reagents, table.concat(table.removeNil({ reagentCount, playerReagentCount, reagentId }), "~"))
        end
        reagents = table.concat(reagents, "*")
        C:SendEvent("GUILD", self.EVENT.CRAFT2, profId, skillId, craftTypeId, numAvailable, cooldown, reagents, i, minMade, maxMade, icon, E.sharedCrafts[profName])
        i = i + 1
    end)
end

function E:ShareTradeSkills()
    local numCrafts = GetNumTradeSkills()
    local profName = GetTradeSkillLine()
    if not profName then
        return
    end
    local profId = E.PROFESSION_IDS[profName]
    self.sharedCrafts[profName] = GetServerTime()
    local i = 1
    local wait = 0
    C:AddToUpdateQueue(function(id, elapsed)
        if wait > 0 then
            wait = wait - elapsed
            return
        end
        if i > numCrafts then
            C:RemoveFromUpdateQueue(id)
            C:SendEvent("GUILD", E.EVENT.CRAFT_HISTORY_SYNC_FINISHED, C:GetPlayerName(true), self.sharedCrafts[profName])
            return
        end
        if not E:ValidateProf(profName) then
            C:RemoveFromUpdateQueue(id)
            return
        end

        local craftName, craftType, numAvailable = GetTradeSkillInfo(i)
        if craftType ~= "header" then
            local craftTypeId = E.SKILL_TYPE_ID[craftType]
            local numReagents = GetTradeSkillNumReagents(i)
            local minMade, maxMade = GetTradeSkillNumMade(i)
            local link = GetTradeSkillRecipeLink(i)
            local icon = GetTradeSkillIcon(i)
            local skillId = E:ParseSpellLink(link)
            local cooldown = GetTradeSkillCooldown(i) or 0
            local reagents = {}
            for j = 1, numReagents do
                local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(i, j);
                local reagentLink = GetTradeSkillReagentItemLink(i, j)

                if reagentName == nil or reagentLink == nil then
                    wait = 0.1
                    return
                end
                local reagentId = E:ParseItemLink(reagentLink)
                table.insert(reagents, table.concat(table.removeNil({ reagentCount, playerReagentCount, reagentId }), "~"))
            end
            reagents = table.concat(reagents, "*")
            if not E:ValidateProf(profName) then
                C:RemoveFromUpdateQueue(id)
                return
            end
            C:SendEvent("GUILD", E.EVENT.CRAFT2, profId, skillId, craftTypeId, numAvailable, cooldown, reagents, i, minMade, maxMade, icon, E.sharedCrafts[profName])
        end
        i = i + 1
    end)
end
function E:ValidateProf(profName)
    local profNameTest = GetTradeSkillLine()
    if profNameTest ~= profName then
        self.sharedCrafts[profName] = nil
        return false
    end
    return true
end
function E:ValidateCraft(profName)
    local profNameTest = GetCraftDisplaySkillLine()
    if profNameTest ~= profName then
        self.sharedCrafts[profName] = nil
        return false
    end
    return true
end
function E:ShareCraftsDelayed()
    local profName = GetCraftName()
    if self.sharedCrafts[profName] and GetServerTime() - self.sharedCrafts[profName] < 60 then
        return
    end
    self:ShareCrafts()
end

function E:ShareTradeSkillsDelayed()
    local profName = GetTradeSkillLine()
    if self.sharedCrafts[profName] and GetServerTime() - self.sharedCrafts[profName] < 60 then
        return
    end
    self:ShareTradeSkills()
end


function E:GetPlayerCraftHistory(name)
    return E:GetGuildCrafts()[name or C:GetPlayerName(true)]
end
function E:FilterCrafts(searchValue, profName, playerName)
    local crafts = self:GetPlayerCraftHistory(playerName)
    local result = {}
    if crafts and crafts[profName] then
        for craftName, data in pairs(crafts[profName]) do
            if string.find(strlower(craftName), searchValue) then
                result[craftName] = data
            end
        end
    end
    return result
end
function E:FilterCraftPlayers(searchValue)
    local result = {}
    for playerName, professions in pairs(E:GetGuildCrafts()) do
        for profName, profession in pairs(professions) do
            for craftName, data in pairs(profession) do
                if string.find(strlower(craftName), strlower(searchValue)) then
                    if not result[playerName] then
                        result[playerName] = {}
                    end
                    if not result[playerName][profName] then
                        result[playerName][profName] = {}
                    end
                    result[playerName][profName][craftName] = data
                end
            end
        end
    end
    return result
end
function E:GetProfessionIcon(profession)
    return E.PROFESSION_ICON_OVERRIDE[profession.name] or profession.icon
end

function E:GetGuildCrafts()
    local guildName = C:GetGuildName()
    return Crafts[guildName] or {}
    --return Crafts["Bohemian Lions"] or {}
end

function E:CleanUpOldMembers(cb)
    for playerName, _ in pairs(E:GetGuildCrafts()) do
        local inGuild = false
        for name, _ in pairs(C.guildRoster) do
            if playerName == name then
                inGuild = true
                break
            end
        end
        if not inGuild then
            cb(playerName)
        end
    end
end

function E:ParseSpellLink(link)
    local linkStringId = link:match('^|c%x+|H.+:(%d+)|')
    return tonumber(linkStringId)
end

function E:ParseItemLink(link)
    local linkStringId = link:match('^|c%x+|Hitem+:(%d+):')
    return tonumber(linkStringId)
end

function E:GetSkillTypeColor(type)
    return E.SkillTypeColor[type]
end

function E:GetProfessionID(profName)
    return E.PROFESSION_IDS[profName]
end

function E:RequestPlayersProfessionInfoHistory()
    for playerName, _ in pairs(E:GetGuildCrafts()) do
        local lastSync = CraftsSyncTime[playerName] or 0
        C:SendEvent("GUILD", E.EVENT.CRAFT_HISTORY_REQUEST, playerName, lastSync)
    end
end

function E:GetPlayerCraftsSince(playerName, since)
    local playerCrafts = E:GetGuildCrafts()[playerName]
    local allCrafts = {}
    local currentTime = GetServerTime()
    if playerCrafts then
        for profName, item in pairs(playerCrafts) do
            for craftName, data in pairs(item) do
                if not data.time then
                    item[craftName].time = currentTime
                end
                if data.time > since then
                    allCrafts[#allCrafts + 1] = { playerName, data, profName, craftName }
                end
            end
        end
    end
    return allCrafts
end
E.playerCraftHistoryQueue = {}
function E:SharePlayerCraftHistory(allCrafts, sender)
    table.insert(E.playerCraftHistoryQueue, { allCrafts, sender })
end

function E:StartCraftHistoryProcessQueue()
    local currentItem
    C:AddToUpdateQueue(function(id, elapsed)
        local size = #E.playerCraftHistoryQueue
        if size > 0 and not currentItem then
            currentItem = table.remove(E.playerCraftHistoryQueue, 1)
            local crafts = currentItem[1]
            local sender = currentItem[2]
            local i = 1
            local guildCrafts = E:GetGuildCrafts()
            local playerName
            local syncTime
            C:AddToUpdateQueue(function(id2)
                if i > #crafts then
                    C:RemoveFromUpdateQueue(id2)
                    C:SendEventTo(sender, E.EVENT.CRAFT_HISTORY_SYNC_FINISHED, playerName, syncTime)
                    currentItem = nil
                    return
                end
                for j = 1, 10 do
                    if i > #crafts then
                        break
                    end
                    local item = crafts[i]
                    playerName = item[1]
                    local data = item[2]
                    local profName = item[3]
                    local craftName = item[4]
                    if not syncTime then
                        syncTime = data.time
                    elseif data.time < syncTime then
                        syncTime = data.time
                    end
                    if not tonumber(data.type) then
                        data.type = E.SKILL_TYPE_ID[data.type]
                    end
                    if not data.profId then
                        data.profId = E:GetProfessionID(profName)
                    end
                    if not data.skillId then
                        if not data.link then
                            guildCrafts[playerName][profName][craftName] = nil
                        end
                        data.skillId = E:ParseSpellLink(data.link)
                    end
                    local reagents = {}
                    local corrupted = false
                    for _, reagent in pairs(data.reagents) do
                        if not reagent.id then
                            if not reagent.link then
                                guildCrafts[playerName][profName][craftName] = nil
                                corrupted = true
                                break
                            end
                            reagent.id = E:ParseItemLink(reagent.link)
                            if not reagent.id then
                                guildCrafts[playerName][profName][craftName] = nil
                                corrupted = true
                                break
                            end
                        end
                        table.insert(reagents, table.concat({ reagent.count, reagent.playerCount, reagent.id }, "~"))
                    end
                    if not corrupted then
                        reagents = table.concat(reagents, "*")
                        --local event = C:PreparePayload(E.EVENT.CRAFT2, data.profId, data.skillId, data.type, data.available, data.cooldown, reagents, data.id, data.min, data.max, data.icon, data.time, playerName)
                        C:SendEventTo(sender, E.EVENT.CRAFT2, data.profId, data.skillId, data.type, data.available, data.cooldown, reagents, data.id, data.min, data.max, data.icon, data.time, playerName)
                    end
                    i = i + 1
                end
            end)
        end

    end)
end