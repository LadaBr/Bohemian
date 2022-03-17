---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 23:38
---

local _, E = ...
local C = E.CORE

DKP_LOG_ROW_AMOUNT = 24
DKP_LOG_ROW_HEIGHT = 15
DKP_LOG_FRAME_WIDTH = 657
DKP_LOG_FRAME_HEIGHT = 410
DKP_LOG_REASON_WIDTH = 160

StaticPopupDialogs["ADD_REASON_LOG"] = {
    text = "Add reason",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 150,
    wide = true,
    editBoxWidth = 250,
    OnAccept = function(self, data)
        E:AddReason(data, self.editBox:GetText())
    end,
    OnShow = function(self)
        self.editBox:SetText("");
        self.editBox:SetFocus();
    end,
    OnHide = function(self)
        ChatEdit_FocusActiveWindow();
        self.editBox:SetText("");
    end,
    EditBoxOnEnterPressed = function(self, data)
        local parent = self:GetParent()
        E:AddReason(data, parent.editBox:GetText())
        parent:Hide();
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide();
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
};

StaticPopupDialogs["WIPE_DATA_ALL"] = {
    text = "Do you want to wipe ALL data?\n\nThis will create a backup automatically.",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        E:WipeDataAll()
    end,
    OnShow = function(self)
        self.editBox:SetText("");
        self.editBox:SetFocus();
    end,
    OnHide = function(self)
        ChatEdit_FocusActiveWindow();
        self.editBox:SetText("");
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        E:WipeDataAll()
        parent:Hide();
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide();
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    showAlert = 1,
    hideOnEscape = 1
};

StaticPopupDialogs["WIPE_DATA_PLAYER"] = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        E:RequestWipeData(self.data)
    end,
    OnShow = function(self)
        self.editBox:SetText("");
        self.editBox:SetFocus();
    end,
    OnHide = function(self)
        ChatEdit_FocusActiveWindow();
        self.editBox:SetText("");
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        E:WipeDataAll()
        parent:Hide();
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide();
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    showAlert = 1,
    hideOnEscape = 1
};

function E:ToggleLogFrame()
    if BohemkaDKPLogFrame:IsShown() then
        BohemkaDKPLogFrame:Hide()
    else
        BohemkaDKPLogFrame:Show()
    end
end

function E:CreateLogButton()
    local log = C:CreateFrame("Button", "ButtonLog", f, "UIPanelButtonTemplate")
    log:SetPoint("LEFT", ButtonAdd, "RIGHT", 0, 0)
    local point, relativeTo, relativePoint, xOfs, yOfs = ButtonSubtract:GetPoint()
    ButtonSubtract:SetPoint(point, relativeTo, relativePoint, xOfs - 30, yOfs)
    log:SetSize(30, 20)
    log:SetText("?")
    log:RegisterForClicks("AnyUp")
    log:SetScript("OnClick", function()
        E:ToggleLogFrame()
    end)

    ButtonLogText:SetPoint("BOTTOM", 0, 4)
end

function E:CreateDKPLogHeader(name, width, text, justify, ...)
    local date = C:CreateFrame("BUTTON", "$parentHeader"..name, BohemkaDKPLogFrame);
    date:SetPoint(...)
    local dateFont = date:CreateFontString("$parentText","ARTWORK", "GameFontNormal")
    dateFont:SetText(text)
    dateFont:SetJustifyH(justify)
    dateFont:SetPoint("LEFT", 0, 0)
    dateFont:SetPoint("RIGHT", 0, 0)
    date:SetSize(width, 25)
    date.text = dateFont
    return date
end

function E:CreateLogFrame()
    local logFrame = C:CreateFrame("Frame", "BohemkaDKPLogFrame", GuildMemberDetailFrame,  BackdropTemplateMixin and "BackdropTemplate" or nil)
    logFrame:SetPoint("TOPLEFT", GuildMemberDetailFrame, "TOPRIGHT", 0, 0)
    logFrame:SetSize(DKP_LOG_FRAME_WIDTH, DKP_LOG_FRAME_HEIGHT)
    logFrame:SetBackdrop(BACKDROP_DIALOG_32_32)
    local f2 = C:CreateFrame("BUTTON", "$parentClose", logFrame, "UIPanelCloseButton");
    f2:SetPoint("TOPRIGHT", logFrame, "TOPRIGHT", -4, -4)

    GuildInfoFrame:SetScript("OnShow", function(self)
        logFrame:ClearAllPoints(true)
        logFrame:SetParent(GuildInfoFrame)
        logFrame:SetPoint("TOPLEFT", GuildInfoFrame, "TOPRIGHT", 0, 0)
        E:RefreshDKPLogAll()
        logFrame:Show()
    end)

    GuildInfoCancelButton:SetScript("OnClick", function()
        E:ToggleLogFrame()
    end)

    GuildInfoCancelButton:SetText("Log")

    GuildInfoFrame:SetScript("OnHide", function(self)
        logFrame:ClearAllPoints(true)
        logFrame:SetParent(GuildMemberDetailFrame)
        logFrame:SetPoint("TOPLEFT", GuildMemberDetailFrame, "TOPRIGHT", 0, 0)
    end)

    local dateCol = self:CreateDKPLogHeader("Date", 125, "Date/Time", "CENTER", "TOPLEFT", logFrame, "TOPLEFT", 9, -11)
    local name = self:CreateDKPLogHeader("Name", 100, "Name", "LEFT", "LEFT", dateCol, "RIGHT")
    local net = self:CreateDKPLogHeader("Net", 60, "Net", "CENTER", "LEFT", name, "RIGHT")
    local delta = self:CreateDKPLogHeader("Delta", 70, "Delta", "CENTER", "LEFT", net, "RIGHT", 0, 0)
    local desc = self:CreateDKPLogHeader("Reason", DKP_LOG_REASON_WIDTH, "Reason", "LEFT", "LEFT", delta, "RIGHT")
    desc.text:SetPoint("LEFT", 10, 0)
    local editor = self:CreateDKPLogHeader("Owner", 100, "Actionee", "CENTER", "LEFT", desc, "RIGHT")

    local wipe = C:CreateFrame("BUTTON", "$parentWipe", logFrame, "UIPanelButtonTemplate");
    wipe:SetPoint("RIGHT", editor, "LEFT", 0, 0)
    wipe:SetWidth(80)
    wipe:SetText("Wipe")
    wipe:SetFrameStrata("HIGH")
    wipe:SetScript("OnClick", function()
        local fullName = GetGuildRosterInfo(GetGuildRosterSelection());
        StaticPopupDialogs["WIPE_DATA_PLAYER"].text = "Do you want to wipe ALL data of "..C:AddClassColorToName(fullName).."?\n\nThis will NOT create a backup."
        local dialog = StaticPopup_Show("WIPE_DATA_PLAYER")
        dialog.data = fullName
    end)

    local logFrameBody = C:CreateFrame("Frame", "BohemkaDKPLogFrameScrollFrameScrollChildFrame", logFrame,  BackdropTemplateMixin and "BackdropTemplate" or nil)
    logFrameBody:SetPoint("TOPLEFT", dateCol, "BOTTOMLEFT", 0, 0)
    logFrameBody:SetSize(logFrame:GetWidth(), logFrame:GetHeight() - dateCol:GetHeight())

    local Scroll = C:CreateFrame('ScrollFrame', '$parentScrollFrame', logFrame, 'UIPanelScrollFrameTemplate')
    Scroll:SetPoint('TOPLEFT', logFrame, 'TOPLEFT', 10, -37)
    Scroll:SetPoint('BOTTOMRIGHT', logFrame, 'BOTTOMRIGHT', -34, 10)
    Scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, DKP_LOG_ROW_HEIGHT, function()
            GameTooltip:Hide()
            E:UpdateDKPLog()
        end)
    end)

    local prevRow = dateCol
    for i=1, DKP_LOG_ROW_AMOUNT do
        local row = C:CreateFrame("Frame", "BohemkaDKPLogFrameRow"..i, logFrameBody,  BackdropTemplateMixin and "BackdropTemplate" or nil)
        if i == 1 then
            row:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, -2)
        else
            row:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT")
        end

        row:SetSize(DKP_LOG_FRAME_WIDTH - 20, DKP_LOG_ROW_HEIGHT)

        local dateFont = row:CreateFontString("$parentDate","ARTWORK", "GameFontHighlightSmall")
        dateFont:SetPoint("LEFT", 0, 0)
        dateFont:SetSize(dateCol:GetWidth(), DKP_LOG_ROW_HEIGHT)

        local nameFrame = C:CreateFrame("Button", "$parentNameFrame", row)
        nameFrame:SetScript("OnEnter", function(self)
            if self.tooltip or self.itemLink then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -24);
                GameTooltip:SetText(self.tooltip);
                GameTooltip:Show();
            end
        end)
        nameFrame:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)
        nameFrame:Hide()

        local nameFont = row:CreateFontString("$parentName","ARTWORK", "GameFontHighlightSmall")
        nameFont:SetPoint("LEFT", dateFont, "RIGHT", 0, 0)
        nameFont:SetSize(name:GetWidth() - 3, DKP_LOG_ROW_HEIGHT)
        nameFont:SetJustifyH("LEFT")
        nameFrame:SetAllPoints(nameFont);

        local netFont = row:CreateFontString("$parentNet","ARTWORK", "GameFontHighlightSmall")
        netFont:SetPoint("LEFT", nameFont, "RIGHT", 2, 0)
        netFont:SetSize(net:GetWidth() - 20, DKP_LOG_ROW_HEIGHT)
        netFont:SetJustifyH("RIGHT")

        local deltaFont = row:CreateFontString("$parentDelta","ARTWORK", "GameFontHighlightSmall")
        deltaFont:SetPoint("LEFT", netFont, "RIGHT", 5, 0)
        deltaFont:SetSize(delta:GetWidth() - 15, DKP_LOG_ROW_HEIGHT)
        deltaFont:SetJustifyH("RIGHT")

        local descFrame = C:CreateFrame("Button", "$parentDescFrame", row)
        descFrame:SetScript("OnEnter", function(self)
            if self.tooltip or self.itemLink then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, -24);
                if self.itemLink then
                    GameTooltip:SetHyperlink(self.itemLink);
                elseif self.tooltip then
                    GameTooltip:SetText(self.tooltip);
                end

                GameTooltip:Show();
            end
        end)
        descFrame:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)
        descFrame:Hide()

        local descFont = descFrame:CreateFontString("$parentDesc","ARTWORK", "GameFontHighlightSmall")
        descFont:SetPoint("LEFT", deltaFont, "RIGHT", 35, 0)
        descFont:SetSize(desc:GetWidth() - 8, DKP_LOG_ROW_HEIGHT)
        descFont:SetJustifyH("LEFT")
        descFrame:SetAllPoints(descFont);

        local descFrameMenu = C:CreateFrame("Frame", "$parentMenu", descFrame, "UIDropDownMenuTemplate")
        descFrame:RegisterForClicks("AnyUp")
        descFrame:SetScript("OnClick", function(self)
            if self.enableDropdown then
                ToggleDropDownMenu(1, nil, descFrameMenu, "cursor", 3, -3)
            end
        end)
        descFrame.menu = descFrameMenu

        -- UIDropDownMenu_SetWidth(descFrame, 50)
        UIDropDownMenu_Initialize(descFrameMenu, function(_, level, _)
            local info = UIDropDownMenu_CreateInfo()
            info.keepShownOnClick = false
            info.notCheckable = true
            if level == 1 then
                info.text = "Add reason"
                info.disabled = not CanEditPublicNote()
                info.func = function()
                    local dialog = StaticPopup_Show("ADD_REASON_LOG", descFrame)
                    dialog.data = descFrame
                end
                UIDropDownMenu_AddButton(info, level)
                info.text = "Revert"
                info.disabled = not CanEditPublicNote()
                info.func = function()
                    local currentDKP = E:GetCurrentDKP(descFrame.fullName)
                    E:AddReason(descFrame, "Reverted - "..date('%Y/%m/%d %H:%M', GetServerTime()), 1)
                    C:GetModule("Bohemian_DKP"):SaveDKP(C.rosterIndex[descFrame.fullName], currentDKP + (descFrame.item.prev - descFrame.item.current), "GUILD", "Reverted external edit")
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end, "MENU")

        local editorFont = row:CreateFontString("$parentOwner","ARTWORK", "GameFontHighlightSmall")
        editorFont:SetPoint("LEFT", descFont, "RIGHT", 3, 0)
        editorFont:SetSize(editor:GetWidth() - 3, DKP_LOG_ROW_HEIGHT)
        editorFont:SetJustifyH("CENTER")
        prevRow = row
    end
end

function E:ColorizeValue(value)
    if value > 0 then
        color = C.COLOR.GREEN
    elseif value < 0 then
        color = C.COLOR.RED
    else
        color = C.COLOR.WHITE
    end
    return C:colorize(value, color)
end

function E:RefreshDKPLog(fullName)
    if not fullName then
        return
    end
    local sortedLog = self:GetSortedLog(fullName, "DESC")
    sortedLog = self:FillExternalEdit(sortedLog, fullName)
    self.sortedLog = sortedLog
    self.multiLog = false
    FauxScrollFrame_Update(BohemkaDKPLogFrameScrollFrame, #sortedLog, DKP_LOG_ROW_AMOUNT, DKP_LOG_ROW_HEIGHT)
    self:UpdateDKPLog()
    E:DetectChanges(fullName, E:GetCurrentDKP(fullName))
end

function E:RefreshDKPLogAll()
    local sortedLog = E:GetFullLog()
    self.sortedLog = sortedLog
    self.multiLog = true
    FauxScrollFrame_Update(BohemkaDKPLogFrameScrollFrame, #sortedLog, DKP_LOG_ROW_AMOUNT, DKP_LOG_ROW_HEIGHT)
    self:UpdateDKPLog()
end

function E:UpdateDetailFrame()
    local fullName = GetGuildRosterInfo(GetGuildRosterSelection());
    E:RefreshDKPLog(fullName)
    E:UpdateDKPLog()
end

function E:UpdateDKPLog()
    local logOffset = FauxScrollFrame_GetOffset(BohemkaDKPLogFrameScrollFrame)
    local fullName = GetGuildRosterInfo(GetGuildRosterSelection());
    local sortedLog = self.sortedLog
    if not sortedLog then
        return
    end
    if self.multiLog then
        BohemkaDKPLogFrame:SetWidth(DKP_LOG_FRAME_WIDTH)
        BohemkaDKPLogFrameHeaderName:Show()
        BohemkaDKPLogFrameHeaderNet:SetPoint("LEFT", BohemkaDKPLogFrameHeaderName, "RIGHT")
    else
        BohemkaDKPLogFrame:SetWidth(DKP_LOG_FRAME_WIDTH - 100)
        BohemkaDKPLogFrameHeaderName:Hide()
        BohemkaDKPLogFrameHeaderNet:SetPoint("LEFT", BohemkaDKPLogFrameHeaderDate, "RIGHT")
    end
    for i=1, DKP_LOG_ROW_AMOUNT do
        local index = i + logOffset
        local row = _G["BohemkaDKPLogFrameRow"..i]
        local descFrame = _G["BohemkaDKPLogFrameRow"..i.."DescFrame"]
        local nameFrame = _G["BohemkaDKPLogFrameRow"..i.."NameFrame"]
        local item = sortedLog[index]
        if item then
            row:Show()
            local dateCol = _G["BohemkaDKPLogFrameRow"..i.."Date"]
            local nameCol = _G["BohemkaDKPLogFrameRow"..i.."Name"]

            local net = _G["BohemkaDKPLogFrameRow"..i.."Net"]
            local deltaCol = _G["BohemkaDKPLogFrameRow"..i.."Delta"]
            local desc = _G["BohemkaDKPLogFrameRow"..i.."DescFrameDesc"]
            local owner = _G["BohemkaDKPLogFrameRow"..i.."Owner"]
            if self.multiLog then
                local tmp = {}
                for _, name in ipairs(item.names) do
                    tmp[#tmp + 1] = C:AddClassColorToName(name)
                end
                local tmp2 = {}
                local tmp3 = {}
                for i, data in ipairs(tmp) do
                    if i % 5 == 0 then
                        tmp3[#tmp3 + 1] = table.concat(tmp2, ", ")
                        tmp2 = {}
                    end
                    tmp2[#tmp2 + 1] = data
                end
                tmp3[#tmp3 + 1] = table.concat(tmp2, ", ")
                local txt = table.concat(tmp3, "\n")
                txt = #item.names > 1 and "("..#item.names..") "..txt or txt
                if #item.names > 1 then
                    nameFrame.tooltip = txt
                else
                    nameFrame.tooltip = nil
                end
                nameCol:SetText(txt)
                nameCol:Show()
                nameFrame:Show()
                net:SetPoint("LEFT", nameCol, "RIGHT", 5, 0)
            else
                net:SetPoint("LEFT", dateCol, "RIGHT", 2, 0)
                nameFrame:Hide()
                nameFrame.tooltip = nil
                nameCol:Hide()
            end

            local dateFormat
            if sortedLog[index].timeSort and sortedLog[index].timeSort > 1 and not sortedLog[index].external and not string.find(sortedLog[index].reason, 'Data restored from') then
                local since = GetServerTime() - sortedLog[index].timeSort
                if since <= 24*60*60 then
                    dateFormat = "%H:%M"
                elseif since <= 24*60*60*7 then
                    dateFormat = "%a %H:%M"
                elseif since <= 24*60*60*365 then
                    dateFormat = '%m/%d %H:%M'
                else
                    dateFormat = '%Y/%m/%d %H:%M'
                end
                dateCol:SetText(date(dateFormat, sortedLog[index].timeSort))
            else
                dateCol:SetText("-")
            end
            local reason = sortedLog[index].reason
            local isExternal = false
            if reason == "External edit" then
                reason = C:colorize(reason, C.COLOR.RED)
                isExternal = true
            elseif reason == "" then
                reason = C:colorize("-", C.COLOR.GRAY)
            elseif reason == "Initial DKP" then
                reason = C:colorize(reason, C.COLOR.YELLOW)
            elseif reason:match('^killing of') then
                local bossName = reason:match('^killing of (.+)')
                reason = C:colorize("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:12:12:0:0|t "..bossName, C.COLOR.DARKRED)
            elseif reason:match('^roll') then
                local value, itemLink = reason:match("^roll (%d+) (.*)")
                reason = "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:16:16:0:0|t "..value.." "..itemLink
            end
            local tooltip = reason
            if reason:match('\|Hitem:%d+:') then
                tooltip = nil
                descFrame.itemLink = reason
            else
                descFrame.itemLink = nil
            end
            net:SetText(self:ColorizeValue(sortedLog[index].current))
            local delta = sortedLog[index].current - sortedLog[index].prev
            deltaCol:SetText(self:ColorizeValue(delta))
            desc:SetText(reason)

            if sortedLog[index].reverted then
                row:SetAlpha(.5)
            else
                row:SetAlpha(1)
            end

            local assignee = sortedLog[index].editor
            if assignee then
                assignee = C:AddClassColorToName(assignee)
            end
            owner:SetText(assignee or "-")
            if #reason > 25 then
                descFrame.tooltip = tooltip
            else
                descFrame.tooltip = nil
            end
            descFrame.enableDropdown = isExternal
            descFrame:Show()
            nameFrame:Show()
        else
            row:Hide()
            nameFrame:Hide()
            descFrame:Hide()
        end
        descFrame.item = sortedLog[index]
        descFrame.index = index
        descFrame.fullName = fullName
    end
end


function E:UpdateCheaters()
    local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);
    local numMembers = C:GetNumVisibleGuildMembers()
    for i=1, GUILDMEMBERS_TO_DISPLAY do
        local index = i + guildOffset
        local fullName, _, _, _, _, _, note = GetGuildRosterInfo(index)
        if fullName then
            if i <= numMembers then
                local btn = _G["GuildFrameGuildStatusButton"..i.."Note"]
                local dkp = C:GetModule("Bohemian_DKP"):NoteDKPToNumber(note)
                if self.cheaters[fullName] and dkp then
                    dkp = C:colorize(dkp, C.COLOR.RED)
                    btn:SetText(dkp)
                end
            end
        end
    end
end

function E:UpdateLastBackupInfo()
    BohemianInterfaceOptionsPanelLogLastBackup:SetText("Last backup: "..(CurrentDKPLog.lastBackup and date('%Y/%m/%d %H:%M', CurrentDKPLog.lastBackup) or "-"))
end

function E:UnloadDataForBackupDropdown()
    self.backupDropdownData = nil
end

function E:AddConfigFrames(f)
    local backup = C:CreateFrame("BUTTON", "$parentBackup", f, "UIPanelButtonTemplate");
    backup:SetPoint("TOPLEFT", f, "TOPLEFT", 30, -26)
    backup:SetWidth(120)
    backup:SetText("Backups")
    local backupDropdown = C:CreateFrame("Frame", "$parentButton", backup);
    backup:SetScript("OnClick", function()
        if UIDROPDOWNMENU_OPEN_MENU  == backupDropdown then
            E:UnloadDataForBackupDropdown()
        else
            E:LoadDataForBackupDropdown()
        end
        ToggleDropDownMenu(1, nil, backupDropdown, backup:GetName(), 0, 0)
    end)

    local title, _ = C:AddConfigEditBox(f, {"TOPLEFT", backup, "BOTTOMLEFT", 0, -15}, "AutoBackup", "Automatic backup", Bohemian_LogConfig.autoBackup, "hour(s)")

    local lastBackup = f:CreateFontString("$parentLastBackup","ARTWORK", "GameFontHighlightSmall")
    lastBackup:SetJustifyH("CENTER")
    lastBackup:SetSize(220, 14)
    lastBackup:SetPoint("LEFT", backup, "RIGHT", -10, 0)
    self:UpdateLastBackupInfo()


    UIDropDownMenu_Initialize(backupDropdown, function(_, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true
        info.keepShownOnClick = false

        if level == 1 then
            info.keepShownOnClick = false
            info.text = C:colorize("Create", C.COLOR.NORMAL)
            info.func = function()
                E:CreateBackup()
            end
            UIDropDownMenu_AddButton(info, level)
            for _, t in ipairs(E.backupDropdownData) do
                info.text = t.str
                info.menuList = "time-"..t.str
                info.hasArrow = true
                info.keepShownOnClick = true
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList and string.find(menuList, "time")  then
            local _, dateStr = strsplit("-", menuList)
            local times
            for _, t in ipairs(E.backupDropdownData) do
                if t.str == dateStr then
                    times = t.children
                    break
                end
            end
            for _, t in ipairs(times or {}) do
                info.text = t.str
                info.hasArrow = true
                info.menuList = "action-"..t.time
                info.keepShownOnClick = true
                UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList and string.find(menuList, "action")  then
            local _, timeStr = strsplit("-", menuList)
            local time = tonumber(timeStr)
            info.hasArrow = false
            info.disabled = not E:CanRestoreBackup()
            info.text = C:colorize("Restore", info.disabled and C.COLOR.DISABLE or C.COLOR.GREEN )
            info.keepShownOnClick = true
            info.func = function()
                E:RestoreBackup(time)
            end
            UIDropDownMenu_AddButton(info, level)

            info.text = C:colorize("Delete", C.COLOR.RED)
            info.hasArrow = false
            info.keepShownOnClick = false
            info.disabled = false
            info.func = function()
                E:DeleteBackup(time)
                ToggleDropDownMenu(1, nil, backupDropdown, backup:GetName(), 0, 0)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)


    local wipe = C:CreateFrame("BUTTON", "$parentWipe", f, "UIPanelButtonTemplate");
    wipe:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 15)
    wipe:SetWidth(120)
    wipe:SetText("Wipe data")
    wipe:SetScript("OnClick", function()
        StaticPopup_Show("WIPE_DATA_ALL")
    end)
    local name = f:GetName()
    f.okay = function()
        Bohemian_LogConfig.autoBackup = _G[name.."EditBoxAutoBackup"]:GetNumber()
    end
    f.cancel = function()
        _G[name.."EditBoxAutoBackup"]:SetNumber(Bohemian_LogConfig.autoBackup)
    end

end

function E:LoadDataForBackupDropdown()
    local tmp = {}
    for time, _ in pairs(CurrentDKPLog.backup) do
        table.insert(tmp, time)
    end
    table.sort(tmp, function(a,b) return a > b  end)
    local split = {}
    for _, time in ipairs(tmp) do
        local dateStr = date('%Y/%m/%d', time)
        if not split[dateStr] then
            split[dateStr] = {}
        end
        split[dateStr] = time
    end
    local dates = {}
    for dateStr, time in pairs(split) do
        dates[#dates + 1] = { str = dateStr, time = time, children = {}}
    end
    table.sort(dates, function(a,b) return a.time > b.time  end)
    for _, time in ipairs(tmp) do
        local timeStr = date('%H:%M', time)
        local dateStr = date('%Y/%m/%d', time)
        for _, t in ipairs(dates) do
            if t.str == dateStr then
                t.children[#t.children + 1] = {time = time, str = timeStr}
            end
        end
    end
    self.backupDropdownData = dates
end

