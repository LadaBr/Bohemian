---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 12.02.2022 12:20
---
local _, E = ...
local C = E.CORE

RAID_INFO_FRAME_OFFSET_X = 0

local timers = {
    { index = "active", name = "Active", title = "Active", order = 1 },
    { index = "regen", name = "Regen", title = "Regen", order = 2 },
    { index = "cc", name = "CC", title = "CC", order = 3 },
    { index = "dead", name = "Dead", title = "Dead", order = 4 },
    { index = "idle", name = "Idle", title = "Idle", order = 5 },
    { index = "idle_ooc", name = "IdleOOC", title = "Idle (OOC)", order = 6 },
    { index = "afk", name = "AFK", title = "Away", order = 7 },
    { index = "offline", name = "Offline", title = "Offline", order = 8 },
}

local textures = {
    [1] = { 0, 1.0, 0.2265625, 0.33984375 },
    [2] = { 0, 1.0, 0, 0.11328125 },
    [3] = { 0, 1.0, 0.11328125, 0.2265625 },
    [4] = { 0, 1.0, 0.33984375, 0.453125 },
    [5] = { 0, 1.0, 0.453125, 0.56640625 },
}

function E:AddConfigFrames(f)
    local toggleParry = C:CreateFrame("CheckButton", "$parentAnnounceParry", f, "UICheckButtonTemplate");
    toggleParry:SetSize(22, 22)
    toggleParry:SetPoint("TOPLEFT", f, "TOPLEFT", 230, -22)
    toggleParry:SetChecked(Bohemian_RaidConfig.announceParry)

    font = toggleParry:CreateFontString("$parentText", "ARTWORK", "GameFontNormal")
    font:SetJustifyH("LEFT")
    font:SetSize(200, 14)
    font:SetPoint("RIGHT", toggleParry, "LEFT", 0, 0)
    font:SetText("Announce parry")

    local toggleMD = C:CreateFrame("CheckButton", "$parentAnnounceMD", f, "UICheckButtonTemplate");
    toggleMD:SetSize(22, 22)
    toggleMD:SetPoint("TOPLEFT", toggleParry, "BOTTOMLEFT", 0, 0)
    toggleMD:SetChecked(Bohemian_RaidConfig.announceMD)

    font = toggleMD:CreateFontString("$parentText", "ARTWORK", "GameFontNormal")
    font:SetJustifyH("LEFT")
    font:SetSize(200, 14)
    font:SetPoint("RIGHT", toggleMD, "LEFT", 0, 0)
    font:SetText("Announce Misdirection")
end

function E:AddRaidButtonFrame()
    local tooltipFrame = C:CreateFrame("Frame", "$parentTooltip", RaidFrame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    tooltipFrame:SetSize(215, 165)
    tooltipFrame:SetPoint("LEFT", UIParent, 500, 200)
    tooltipFrame:SetFrameStrata("TOOLTIP")
    tooltipFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    tooltipFrame:SetBackdropColor(0, 0, 0, 1)

    local prevResist
    for i = 1, 5 do
        local resist = CreateFrame("Frame", "$parentResist" .. i, tooltipFrame, "MagicResistanceFrameTemplate")

        if i == 1 then
            resist:SetPoint("TOPLEFT", 8, -10)
        else
            resist:SetPoint("TOP", prevResist, "BOTTOM", 0, 0)
        end

        local texture = resist:CreateTexture("$parentTexture", "BACKGROUND")
        texture:SetAllPoints(true)
        texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ResistanceIcons")
        texture:SetTexCoord(unpack(textures[i]))

        local font = resist:CreateFontString("$parentValue", "BORDER", "GameFontHighlightSmall")
        font:SetText("-")
        font:SetPoint("BOTTOM", 0, 3)
        prevResist = resist
    end
    tooltipFrame:Hide()
    for i = 1, MAX_RAID_MEMBERS do
        local button = _G["RaidGroupButton" .. i]
        local classButton = _G["RaidGroupButton" .. i .. "Class"]
        local nameButton = _G["RaidGroupButton" .. i .. "Name"]
        classButton:SetText("")
        classButton:SetSize(12, 12)
        C:SetFrameOffsetX(nameButton, 14)
        classButton:ClearAllPoints(true)
        classButton:SetPoint("RIGHT", nameButton, "LEFT", -4, 1)
        if button and classButton then
            local texture = classButton:CreateTexture("$parentTexture", "ARTWORK")
            texture:SetAllPoints(true)
            C:AddTooltip(classButton, "ANCHOR_TOP")
        end
        local info = CreateFrame("Frame", "$parentInfo", button);
        info:SetSize(12, 12)
        info:SetPoint("RIGHT", -2, 1)
        info:SetScript("OnEnter", function(self)
            if self.tooltip then
                E.selectedMember = self.tooltip
                E:UpdateTimers()
                E:UpdateResistInfo(self.tooltip.fullName)
                tooltipFrame:SetPoint("LEFT", _G["RaidGroupButton" .. i .. "Info"], "RIGHT", 3, 0)
                tooltipFrame:Show()
            end
        end)
        info:SetScript("OnLeave", function()
            E.selectedMember = nil
            tooltipFrame:Hide()
        end)
        local texture = info:CreateTexture("$parentTexture", "ARTWORK")
        texture:SetAllPoints(true)
        texture:SetTexture(134331)
    end

    local session = tooltipFrame:CreateFontString("$parentTimerSession", "BORDER", "GameFontNormalSmall")
    session:SetText("Session")
    session:SetPoint("BOTTOMLEFT", 50, 15)
    local sessionValue = tooltipFrame:CreateFontString("$parentTimerSessionValue", "BORDER", "GameFontHighlightSmall")
    sessionValue:SetText("-")
    sessionValue:SetPoint("LEFT", session, "RIGHT", 59, 0)
    sessionValue:SetWidth(100)
    sessionValue:SetJustifyH("LEFT")

    local prevTimer
    for i, timer in ipairs(timers) do
        local textFrame = C:CreateFrame("Frame", "$parentTimer" .. timer.name, tooltipFrame)
        textFrame:SetSize(55, 9)
        if i == 1 then
            textFrame:SetPoint("TOPLEFT", 50, -13)
        else
            textFrame:SetPoint("TOPLEFT", prevTimer, "BOTTOMLEFT", 0, -5)
        end
        local text = textFrame:CreateFontString("$parentText", "BORDER", "GameFontNormalSmall")
        text:SetText(timer.title)
        text:SetWidth(55)
        text:SetJustifyH("LEFT")
        text:SetPoint("LEFT", 0, 0)

        local textValue = textFrame:CreateFontString("$parentValue", "BORDER", "GameFontHighlightSmall")
        textValue:SetText("-")
        textValue:SetPoint("LEFT", text, "RIGHT", 5, 0)

        textValue:SetJustifyH("RIGHT")
        textValue:SetWidth(45)

        local valuePrc = textFrame:CreateFontString("$parentValuePrc", "BORDER", "GameFontHighlightSmall")
        valuePrc:SetText("-")
        valuePrc:SetPoint("LEFT", textValue, "RIGHT", 5, 0)
        valuePrc:SetWidth(40)
        valuePrc:SetJustifyH("RIGHT")
        prevTimer = textFrame
    end
end

function E:TimeToReadable(value)
    local text
    if value == nil then
        return
    end
    if value < 60 then
        text = string.format(value == 0 and "%.0fs" or "%.1fs", value)
    else
        text = E:ConditionalTimeFormat(value)
    end
    return text
end

function E:ConditionalTimeFormat(value)
    local seconds, minutes, hours, days = E:TimeToParts(value)
    local text = string.format("%ds", seconds)

    if minutes > 0 then
        text = string.format("%dm", minutes) .. text
    end

    if hours > 0 then
        text = string.format("%dh", hours) .. text
    end

    if days > 0 then
        text = string.format("%dd", days) .. text
    end
    return text
end

function E:TimeToParts(value)
    local seconds = floor(mod(value, 60))
    local minutes = floor(mod(value, 3600) / 60)
    local hours = floor(mod(value, 86400) / 3600)
    local days = floor(value / 86400)
    return seconds, minutes, hours, days
end

function E:TimeToPercent(value, fullName)
    local percent = value / E.currentSession.stats[fullName].timers.session * 100
    return string.format("%.1f%%", percent)
end

function E:GetSessionDuration(fullName)
    return E.currentSession and E.currentSession.stats and E.currentSession.stats[fullName] and E.currentSession.stats[fullName].timers.session
end

function E:UpdateTimers()
    if not E.selectedMember then
        return
    end
    for _, timer in pairs(timers) do
        local name = timer.name
        local frame = _G["RaidFrameTooltipTimer" .. name]
        local textValue = _G["RaidFrameTooltipTimer" .. name .. "Value"]
        local textValuePrc = _G["RaidFrameTooltipTimer" .. name .. "ValuePrc"]
        local value
        if E.selectedMember.fullName and E.currentSession and E.currentSession.stats[E.selectedMember.fullName] then
            value = E.currentSession.stats[E.selectedMember.fullName].timers[timer.index]
        end
        if textValue then
            if value and value > 0 and E:GetSessionDuration(E.selectedMember.fullName) > 0 then
                textValuePrc:SetText(E:TimeToPercent(value, E.selectedMember.fullName))
                textValue:SetText(E:TimeToReadable(value))
                frame:SetAlpha(1)
            else
                textValue:SetText("-")
                textValuePrc:SetText("-")
                frame:SetAlpha(0.75)
            end

        end
    end
    if E.selectedMember.fullName and E.currentSession and E.currentSession.stats[E.selectedMember.fullName] then
        RaidFrameTooltipTimerSessionValue:SetText(C:display_time(E.currentSession.stats[E.selectedMember.fullName].timers.session))
    else
        RaidFrameTooltipTimerSessionValue:SetText("-")
    end
end

function E:UpdateResistInfo(name)
    for i = 1, 5 do
        local resistInfo = name and E.resistInfo[name] or nil
        local value = resistInfo and resistInfo[i + 1] or nil
        local text = _G["RaidFrameTooltipResist" .. i .. "Value"]
        if text then
            if value ~= nil then
                if value < 0 then
                    text:SetText(RED_FONT_COLOR_CODE .. value .. FONT_COLOR_CODE_CLOSE);
                elseif value == 0 then
                    text:SetText(value);
                else
                    text:SetText(GREEN_FONT_COLOR_CODE .. value .. FONT_COLOR_CODE_CLOSE);
                end
            else
                text:SetText("-")
            end
        end

    end
end

function E:UpdateTooltip()
    E:UpdateResistInfo(E.selectedMember and E.selectedMember.fullName or nil)

end

function E:UpdateRaidFrame(i, data)
    local button = _G["RaidGroupButton" .. i]

    local classButton = _G["RaidGroupButton" .. i .. "Class"]
    local infoButton = _G["RaidGroupButton" .. i .. "Info"]
    classButton:SetText("")
    local classButtonTexture = _G["RaidGroupButton" .. i .. "ClassTexture"]
    local module = C:GetModule("Bohemian_Talents")
    infoButton.tooltip = data
    if data then
        if module and module:GetPlayerTalents(data.fullName) then
            module:SetTalentFrame(classButton, classButtonTexture, data.fullName)
            classButtonTexture:SetTexCoord(0, 1, 0, 1)
        else
            local coords = CLASS_ICON_TCOORDS[data.fileName]
            classButtonTexture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
            classButtonTexture:SetTexCoord(unpack(coords))
            classButtonTexture:Show()
        end
        _G["RaidGroupButton" .. i.."Info"]:Show()
    else
        classButtonTexture:Hide()
        _G["RaidGroupButton" .. i.."Info"]:Hide()
    end
end

RAID_INFO_FRAME_ROW_HEIGHT = 14
RAID_INFO_ROWS = 25
RAID_INFO_FRAME_WIDTH = 60

function E:ResizeRaidInfoFrame(width)
    RaidInfoFrame:SetWidth(RaidInfoFrame:GetWidth() + width)
    RaidInfoScrollFrame:SetWidth(RaidInfoScrollFrame:GetWidth() + width)
    RaidInfoDetailHeader:SetWidth(RaidInfoDetailHeader:GetWidth() + width)
    for i = 1, 10 do
        _G["RaidInfoInstance" .. i]:SetWidth(_G["RaidInfoInstance" .. i]:GetWidth() + width)
    end
    C:SetFrameOffsetX(RaidInfoIDLabel, width)
end

function E:AddRaidInfoFrame()
    local f = C:CreateFrame("Frame", "$parentStats", RaidInfoFrame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    E.raidInfoFrame = f
    f:SetScript("OnShow", function()
        E:SortPlayers()
        E:UpdateRaidInfoFrame()
    end)
    --f:Hide()
    RaidInfoScrollFrameScrollBar:Hide()
    RaidInfoScrollFrameScrollBar:SetPoint("TOPLEFT", RaidInfoScrollFrame, "TOPRIGHT", 8, -3);
    E:ResizeRaidInfoFrame(RAID_INFO_FRAME_WIDTH)
    RaidInfoFrame:HookScript("OnShow", function()
        f:Show()
    end)
    RaidFrame:HookScript("OnShow", function()
        RaidFrameRaidInfoButton:Enable()
    end)
    RaidInfoFrame:HookScript("OnHide", function()
        f:Hide()
    end)

    f:SetPoint("TOPRIGHT", RaidInfoFrame, "TOPLEFT", 1, 0)
    E:FixRaidInfoFramePosition()
    f:SetSize(805, 426)
    f:SetBackdrop(BACKDROP_DIALOG_32_32)
    local font = RaidFrame:CreateFontString("$parentSessionDuration", "BORDER", "GameFontHighlightSmall")
    font:SetPoint("TOPLEFT", 80, -6)
    --font:SetText("00:00:00")

    local rock = f:CreateTexture(nil, "BACKGROUND")
    rock:SetPoint("TOPLEFT", f, 10, -11)
    rock:SetPoint("BOTTOMRIGHT", -11, 10)
    rock:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock", true, true)
    rock:SetHorizTile(true)
    rock:SetVertTile(true)

    local marbleFrame = C:CreateFrame("Frame", "$parentMarble", f)
    marbleFrame:SetPoint("TOPLEFT", f, 11, -64)
    marbleFrame:SetPoint("BOTTOMRIGHT", -11, 10)
    marbleFrame:SetFrameStrata("MEDIUM")
    marbleFrame:SetFrameLevel(100)
    local marble = marbleFrame:CreateTexture(nil, "ARTWORK")
    marble:SetAllPoints(true)
    marble:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", true, true)
    marble:SetHorizTile(true)
    marble:SetVertTile(true)

    local columns = {}

    local b = C:CreateFrame("BUTTON", "$parentColumnNameHeader", f, "GuildFrameColumnHeaderTemplate");
    b:SetPoint("BOTTOMLEFT", marble, "TOPLEFT", 2, 0)
    b:SetText("Name")
    b.sort = "name"
    b:SetFrameLevel(100)
    WhoFrameColumn_SetWidth(b, 100)
    table.insert(columns, b)
    local prevTimer = b

    for i = 1, 5 do

        local resistHeader = C:CreateFrame("BUTTON", "$parentColumnResist" .. i .. "Header", f, "GuildFrameColumnHeaderTemplate");
        local resist = C:CreateFrame("Frame", "$parentResist" .. i, resistHeader, "MagicResistanceFrameTemplate")
        resist:EnableMouse(false)
        resist:SetPoint("CENTER", resistHeader, 0, 0)
        resistHeader:SetPoint("TOPLEFT", prevTimer, "TOPRIGHT", -2, 0)
        resistHeader:SetFrameLevel(100)
        resist:SetFrameLevel(1000)
        resist:SetSize(20, 18)
        resistHeader.sort = "resist-" .. (i + 1)
        WhoFrameColumn_SetWidth(resistHeader, resist:GetWidth() + 12)

        local texture = resist:CreateTexture("$parentTexture", "BACKGROUND")
        texture:SetAllPoints(true)
        texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ResistanceIcons")
        texture:SetTexCoord(unpack(textures[i]))
        prevTimer = resistHeader
        table.insert(columns, resistHeader)
    end

    for i, timer in ipairs(timers) do
        local h = C:CreateFrame("BUTTON", "$parentColumn" .. i .. "Header", f, "GuildFrameColumnHeaderTemplate");
        h:SetPoint("TOPLEFT", prevTimer, "TOPRIGHT", -2, 0)
        h:SetFrameLevel(100)
        WhoFrameColumn_SetWidth(h, 65)
        h:SetText(timer.title)
        h.sort = "timer-" .. timer.index
        prevTimer = h
        table.insert(columns, h)
    end

    for _, column in ipairs(columns) do
        column:HookScript("OnClick", function(self)
            self.sortDirection = self.sortDirection == "ASC" and "DESC" or "ASC"
            E.sort = self.sort
            E.sortDir = self.sortDirection
            E:SortPlayers()
            E:UpdateRaidInfoRows()
        end)
    end
    local prevRow
    for i = 1, RAID_INFO_ROWS do
        local row = C:CreateFrame("Frame", "RaidInfoRow" .. i, marbleFrame)
        if i == 1 then
            row:SetPoint("TOPLEFT", 0, -1)
        else
            row:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, 0)
        end
        row:SetSize(760, RAID_INFO_FRAME_ROW_HEIGHT)
        local prevCol
        for _, column in ipairs(columns) do
            local font = row:CreateFontString("$parentCol" .. _, "BORDER", "GameFontHighlightSmall")
            font:SetText("")
            if _ == 1 then
                font:SetPoint("LEFT", 8, 0)
                font:SetWidth(column:GetWidth() - 8)
            else
                font:SetPoint("LEFT", prevCol, "RIGHT", 2, 0)
                font:SetWidth(column:GetWidth() - 4)
            end

            if _ > 1 and _ < 7 then
                font:SetJustifyH("CENTER")
            elseif _ > 6 and _ < 15 then
                font:SetJustifyH("RIGHT")
            else
                font:SetJustifyH("LEFT")
            end

            prevCol = font
        end

        prevRow = row
    end

    local scroll = C:CreateFrame('ScrollFrame', '$parentScrollFrame', f, 'FauxScrollFrameTemplate')
    scroll:SetSize(f:GetWidth() - 45, RAID_INFO_ROWS * RAID_INFO_FRAME_ROW_HEIGHT)
    scroll:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -36, -68)
    scroll:SetFrameLevel(5)
    f.scroll = scroll

    local scrollTop = scroll:CreateTexture("$parentTop", "BACKGROUND")
    scrollTop:SetSize(29, 102)
    scrollTop:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
    scrollTop:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -2, 4)
    scrollTop:SetTexCoord(0, 0.445, 0, 0.4)

    local scrollBottom = scroll:CreateTexture("$parentBottom", "BACKGROUND")
    scrollBottom:SetSize(29, 106)
    scrollBottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
    scrollBottom:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", -2, -2)
    scrollBottom:SetTexCoord(0.515625, 0.960625, 0, 0.4140625)

    local scrollMiddle = scroll:CreateTexture("$parentMiddle", "BACKGROUND")
    scrollMiddle:SetSize(29, 1)
    scrollMiddle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
    scrollMiddle:SetPoint("TOP", scrollTop, "BOTTOM", 0, 0)
    scrollMiddle:SetPoint("BOTTOM", scrollBottom, "TOP", 0, 0)
    scrollMiddle:SetTexCoord(0, 0.445, 0.75, 1)

    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, CRAFTS_LIST_ROW_HEIGHT, function()
            E:UpdateRaidInfoFrame(true)
        end)
    end)

    local history = C:CreateFrame("Frame", "$parentHistoryDropdown", f, "UIDropDownMenuTemplate")
    history:SetPoint("TOPLEFT", 6, -11)
    UIDropDownMenu_SetWidth(history, 150)
    history:SetFrameLevel(1000)
    history.value = "Current"

    local initMenu = function()
        local selectedValue = UIDropDownMenu_GetSelectedValue(history);
        local info = UIDropDownMenu_CreateInfo();

        info.text = "Current"
        info.func = function()
            history:SetValue("Current")
        end;
        info.value = "Current"
        if ( info.value == selectedValue ) then
            info.checked = 1;
        else
            info.checked = nil;
        end
        UIDropDownMenu_AddButton(info);

        local sessions = E:GetAllSessions()
        table.sort(sessions, function(a, b) return a.created < b.created end)
        for _, session in ipairs(sessions) do
            info.text = session.name.." - "..date('%Y/%m/%d %H:%M:%S', session.created);
            info.func = function(self)
                history:SetValue(self.value)
            end;
            info.value = session
            if ( info.value == selectedValue ) then
                info.checked = 1;
            else
                info.checked = nil;
            end
            UIDropDownMenu_AddButton(info);
        end

    end
    history.SetValue = function (self, value)
        self.value = value
        E.showedSession = value ~= "Current" and value
        UIDropDownMenu_SetSelectedValue(self, value);
        E:UpdateRaidInfoFrame()
    end
    UIDropDownMenu_Initialize(history, initMenu);
    UIDropDownMenu_SetSelectedValue(history, history.value);
end

function E:GetAllSessions()
    local tmp = {}
    for _, instance in pairs(Bohemian_RaidStats) do
        for _, difficulty in pairs(instance) do
            for _, session in pairs(difficulty) do
                tmp[#tmp + 1] = session
            end
        end
    end
    return tmp
end

function E:FormatValue(value, fullName)
    local session = E:GetSessionDuration(fullName) or E.showedSession and E.showedSession.stats and E.showedSession.stats[fullName] and E.showedSession.stats[fullName].timers.session
    return (value and session and session > 0) and string.format("%s", E:TimeToReadable(value)) or "-"
end

function E:UpdateRaidInfoFrame(skipSort)
    if not E.raidInfoFrame or not E.raidInfoFrame:IsShown() or not E.sortedPlayers then
        return
    end
    FauxScrollFrame_Update(E.raidInfoFrame.scroll, #E.sortedPlayers, RAID_INFO_ROWS, RAID_INFO_FRAME_ROW_HEIGHT, nil, nil, nil);
    local showScrollBar = E.raidInfoFrame.scroll:IsVisible()
    if not showScrollBar then
        E.raidInfoFrame:SetWidth(782)
    else
        E.raidInfoFrame:SetWidth(805)
    end
    E:FixRaidInfoFramePosition()
    if not skipSort then
        E:SortPlayers()
    end
    E:UpdateRaidInfoRows()
end

function E:FixRaidInfoFramePosition()
    RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", E.raidInfoFrame:GetWidth() + RAID_INFO_FRAME_OFFSET_X, 0)
end

function E:GetSelectedSession()
    return E.showedSession or E.currentSession
end

function E:GetSortedPlayers(sortType, sortDir)
    local tmp = {}
    if E.showedSession then
        for memberName, stats in pairs(E.showedSession.stats) do
            local data = {}
            data.data = {name = strsplit("-", memberName), fullName = memberName }
            data.resist = {}
            data.stats = stats
            tmp[#tmp + 1] = data
        end
    else
        for i, memberName in ipairs(E.raidMembersIndex) do
            local data = {}
            data.data = E.raidMembers[memberName]
            data.resist = E.resistInfo[memberName] or {}
            if E.currentSession then
                data.stats = E.currentSession.stats[memberName] or {
                    timers = {}
                }
            else
                data.stats = {
                    timers = {}
                }
            end
            tmp[#tmp + 1] = data
        end
    end

    if sortType == "name" then
        table.sort(tmp, function(a, b)
            if sortDir == "ASC" then
                return a.data.name < b.data.name
            else
                return a.data.name > b.data.name
            end
        end)
        return tmp
    end
    if not sortType then
        return tmp
    end
    local sortType, id = strsplit("-", sortType)
    if sortType == "resist" then
        id = tonumber(id)
        table.sort(tmp, function(a, b)
            if sortDir == "ASC" then
                return (a.resist[id] or -1) < (b.resist[id] or -1)
            else
                return (a.resist[id] or -1) > (b.resist[id] or -1)
            end
        end)
        return tmp
    end
    if sortType == "timer" then
        table.sort(tmp, function(a, b)
            if sortDir == "ASC" then
                return (a.stats.timers[id] or -1) < (b.stats.timers[id] or -1)
            else
                return (a.stats.timers[id] or -1) > (b.stats.timers[id] or -1)
            end
        end)
        return tmp
    end
    return tmp
end

function E:SortPlayers()
    E.sortedPlayers = E:GetSortedPlayers(E.sort, E.sortDir)
end

function E:GetResistColor(value)
    if value < 0 then
        return RED_FONT_COLOR_CODE .. value .. FONT_COLOR_CODE_CLOSE
    elseif value == 0 then
        return value
    else
        return GREEN_FONT_COLOR_CODE .. value .. FONT_COLOR_CODE_CLOSE
    end
end

function E:UpdateRaidInfoRows()
    local offset = FauxScrollFrame_GetOffset(E.raidInfoFrame.scroll);
    for i = 1, RAID_INFO_ROWS do
        local index = i + offset
        local row = _G["RaidInfoRow" .. i]
        local member = E.sortedPlayers[index]
        if member then
            local memberName = member.data.fullName
            local name = _G["RaidInfoRow" .. i .. "Col1"]
            name:SetText(C:AddClassColorToName(member.data.fullName))
            for j = 1, 5 do
                local resistValue = member.resist[j + 1]
                local resist = _G["RaidInfoRow" .. i .. "Col" .. (1 + j)]
                resist:SetText(resistValue and E:GetResistColor(resistValue) or "-")
            end
            local timers = member.stats and member.stats.timers or {}

            _G["RaidInfoRow" .. i .. "Col7"]:SetText(E:FormatValue(timers.active, memberName))
            _G["RaidInfoRow" .. i .. "Col8"]:SetText(E:FormatValue(timers.regen, memberName))
            _G["RaidInfoRow" .. i .. "Col9"]:SetText(E:FormatValue(timers.cc, memberName))
            _G["RaidInfoRow" .. i .. "Col10"]:SetText(E:FormatValue(timers.dead, memberName))
            _G["RaidInfoRow" .. i .. "Col11"]:SetText(E:FormatValue(timers.idle, memberName))
            _G["RaidInfoRow" .. i .. "Col12"]:SetText(E:FormatValue(timers.idle_ooc, memberName))
            _G["RaidInfoRow" .. i .. "Col13"]:SetText(E:FormatValue(timers.afk, memberName))
            _G["RaidInfoRow" .. i .. "Col14"]:SetText(E:FormatValue(timers.offline, memberName))
            row:Show()
        else
            row:Hide()
        end
    end
end
