---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 23:37
---
local _, E = ...
local C = E.CORE

GUILD_FRAME_COLUMN_WIDTH_PROFESSIONS = 101
GUILD_FRAME_GUILD_STATUS_COLUMN_WIDTH_NOTE = 94
GUILD_FRAME_GUILD_STATUS_COLUMN_WIDTH_ONLINE = 49
GUILD_FRAME_GUILD_STATUS_COLUMN_WIDTH_ONLINE_NO_SCROLL = 40

GUILD_FRAME_COLUMN_WIDTH_DKP = 60

E.editModeButtons = {
    "SelectAllDKP",
    "ButtonSubtractAll",
    "ButtonAddAll"
}

StaticPopupDialogs["SET_GUILDPLAYERDKP"] = {
    text = "Set DKP",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 150,
    wide = true,
    editBoxWidth = 200,
    OnAccept = function(self)
        E:SetDKPFromEditBox(self.editBox)
    end,
    OnShow = function(self)
        --Sets the text to the 7th return from GetGuildRosterInfo(GetGuildRosterSelection());
        self.editBox:SetText(E:NoteDKPToNumber(select(7, GetGuildRosterInfo(GetGuildRosterSelection()))));
        self.editBox:SetFocus();
    end,
    OnHide = function(self)
        ChatEdit_FocusActiveWindow();
        self.editBox:SetText("");
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent();
        E:SetDKPFromEditBox(parent.editBox)
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
StaticPopupDialogs["SUBTRACT_GUILDPLAYERDKP"] = {
    text = "Subtract DKP",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 150,
    wide = true,
    editBoxWidth = 200,
    OnAccept = function(self)
        E:SubtractDKPFromEditBox(self.editBox)
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
        local parent = self:GetParent();
        E:SubtractDKPFromEditBox(parent.editBox)
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
StaticPopupDialogs["ADD_GUILDPLAYERDKP"] = {
    text = "Add DKP",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 150,
    wide = true,
    editBoxWidth = 200,
    OnAccept = function(self)
        E:AddDKPFromEditBox(self.editBox)
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
        local parent = self:GetParent();
        E:AddDKPFromEditBox(parent.editBox)
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

StaticPopupDialogs["SUBTRACT_GUILDPLAYERDKP_MANY"] = {
    text = "Subtract DKP",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 150,
    wide = true,
    editBoxWidth = 200,
    OnAccept = function(self)
        local dkp, reason, percent = E:GetDKPFromEditBox(self.editBox)
        E:SubtractDKPSelected(dkp, nil, reason, percent)
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
        local dkp, reason, percent = E:GetDKPFromEditBox(parent.editBox)
        E:SubtractDKPSelected(dkp, nil, reason, percent)
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

StaticPopupDialogs["ADD_GUILDPLAYERDKP_MANY"] = {
    text = "Add DKP",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 150,
    wide = true,
    editBoxWidth = 200,
    OnAccept = function(self)
        local dkp, reason, percent = E:GetDKPFromEditBox(self.editBox)
        E:AddDKPSelected(dkp, nil, reason, percent)
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
        local dkp, reason, percent = E:GetDKPFromEditBox(parent.editBox)
        E:AddDKPSelected(dkp, nil, reason, percent)
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
StaticPopupDialogs["AWARD_GUILDPLAYERDKP_RAID"] = {
    text = "Award DKP",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 150,
    wide = true,
    editBoxWidth = 200,
    OnAccept = function(self)
        E:AwardDKPRaid(E:GetDKPFromEditBox(self.editBox))
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
        E:AwardDKPRaid(E:GetDKPFromEditBox(parent.editBox))
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

function E:CreateGuildFrameEditModeButtons()
    local buttonsWidth = 30
    local subtract = C:CreateFrame("Button", "ButtonSubtractAll", GuildFrame, "UIPanelButtonTemplate")
    subtract:SetPoint("LEFT", GuildFrameGuildListToggleButton, "RIGHT", 2, 0)
    subtract:SetWidth(buttonsWidth)
    subtract:SetText("-")
    subtract:RegisterForClicks("AnyUp")
    subtract:SetScript("OnClick", function()
        StaticPopup_Show("SUBTRACT_GUILDPLAYERDKP_MANY")
    end)
    subtract:Hide()

    local add = C:CreateFrame("Button", "ButtonAddAll", GuildFrame, "UIPanelButtonTemplate")
    add:SetPoint("LEFT", subtract, "RIGHT", 0, 0)
    add:SetWidth(buttonsWidth)
    add:SetText("+")
    add:RegisterForClicks("AnyUp")
    add:SetScript("OnClick", function()
        StaticPopup_Show("ADD_GUILDPLAYERDKP_MANY")
    end)
    add:Hide()

    f = C:CreateFrame("BUTTON", "SelectAllDKP", GuildFrame, "UIPanelButtonTemplate");
    f:SetText("Select All")
    f:SetWidth(80)
    f:Hide()
    f:SetPoint("LEFT", add, "RIGHT", 2, 0)
    GuildFrameLFGButton:HookScript("OnClick", function()
        local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
        local numMembers = C:GetNumVisibleGuildMembers()
        local allSelected = true
        for i = 1, GetNumGuildMembers() do
            local index = i + guildOffset
            local fullName = GetGuildRosterInfo(index)
            if i <= numMembers and not self.editModeSelected[fullName] then
                allSelected = false
                break
            end
        end
        E.isSelectedAll = allSelected
    end)
    f:SetScript("OnClick", function()
        E.isSelectedAll = not E.isSelectedAll
        E.editModeSelected = {}
        local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame);
        local numMembers = C:GetNumVisibleGuildMembers()
        for i = 1, GetNumGuildMembers() do
            local index = i + guildOffset
            local fullName = GetGuildRosterInfo(index)
            if i <= numMembers then
                E.editModeSelected[fullName] = E.isSelectedAll
            else
                E.editModeSelected[fullName] = nil
            end
        end
        E:UpdateSelectedMembers()
    end)
end

function E:SelectGuildMember(index, state)
    if index <= GUILDMEMBERS_TO_DISPLAY then
        _G["GuildFrameDKPSelectButton" .. index]:SetChecked(state)
    end
end

function E:ShowEditModeButtons()
    for _, button in ipairs(self.editModeButtons) do
        _G[button]:Show()
    end
    if not E.isShown then
        C.GUILD_FRAME_ADDITIONAL_WIDTH = C.GUILD_FRAME_ADDITIONAL_WIDTH + 12
    end
    E.isShown = true
end
function E:HideEditModeButtons()
    for _, button in ipairs(self.editModeButtons) do
        _G[button]:Hide()
    end

    if E.isShown then
        C.GUILD_FRAME_ADDITIONAL_WIDTH = C.GUILD_FRAME_ADDITIONAL_WIDTH - 12
    end
    E.isShown = false
end

function E:UpdateSelectedMembers()
    local numMembers = C:GetNumVisibleGuildMembers()
    local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
    local showOffline = GetGuildRosterShowOffline()
    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        local index = i + guildOffset
        local fullName = GetGuildRosterInfo(index)
        if fullName then
            if not showOffline and i > numMembers and not C.onlinePlayers[fullName] then
                self.editModeSelected[fullName] = nil
            end
            E:SelectGuildMember(i, self.editModeSelected[fullName])
        end
    end
end

function E:CreateGuildFrameGuildStatusNoteColumnHeader()
    local f = C:AddGuildStatusColumnHeader("GuildFrameGuildStatusColumnHeader5", GUILD_FRAME_GUILD_STATUS_COLUMN_WIDTH_NOTE, 3, "OfficerNote", true, "GameFontHighlightSmall")
    f:SetText("Note")
    f:Disable()
    C:SetGuildStatusColumnOrder("GuildFrameGuildStatusColumnHeader4", 4)
end

function E:ReplaceGuildFrameGuildStatusNoteHeaderWithDKP()
    local noteBtn = _G["GuildFrameGuildStatusColumnHeader3"]
    noteBtn:SetParent(GuildPlayerStatusFrame)
    noteBtn:SetText("DKP")
    WhoFrameColumn_SetWidth(noteBtn, GUILD_FRAME_COLUMN_WIDTH_DKP)
    C:SwapColumnBetween("GuildFrameGuildStatusColumnHeader3", C.GuildStatusHeaderOrder, C.GuildHeaderOrder)
    C:SetGuildColumnOrder("GuildFrameGuildStatusColumnHeader3", 999)
end

function E:FixToggleButton()
    local padding = 0
    if self.isEditMode and Bohemian_DKPConfig.showDKP then
        padding = -150
    end
    C.ToggleButtonPosition = padding
end

function E:AddLFGFrameButton()
    local dkpButton = C:CreateFrame("CheckButton", "GuildFrameDKPToggle", GuildFrameLFGFrame, "UICheckButtonTemplate")
    dkpButton:SetSize(20, 20)
    dkpButton:SetChecked(Bohemian_DKPConfig.showDKP)
    dkpButton:SetScript("OnClick", function(self)
        Bohemian_DKPConfig.showDKP = self:GetChecked()
        E:RenderColumns()
    end)
    C:AddLFGButton(dkpButton:GetName(), 3, 30)
    font = dkpButton:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall")
    font:SetText("DKP")
    font:SetPoint("RIGHT", dkpButton, "LEFT", -3, 1)
    E:RenderColumns()
end

function E:CreateDKPCheckButton(index)
    local dkpCheckButton = C:CreateFrame("CheckButton", "GuildFrameDKPSelectButton" .. index, GuildFrame, "UICheckButtonTemplate");
    dkpCheckButton:SetPoint("LEFT", "GuildFrameGuildStatusButton" .. index .. "Note", "RIGHT", 2, 0)
    dkpCheckButton:SetFrameStrata("HIGH")
    dkpCheckButton:Hide()
    dkpCheckButton:SetSize(18, 18)
    dkpCheckButton:SetScript("OnClick", function(self)
        local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
        local guildIndex = guildOffset + index
        local isChecked = self:GetChecked()
        local fullName = GetGuildRosterInfo(guildIndex)
        E.editModeSelected[fullName] = isChecked
    end)
end
function E:ReplaceGuildFrameGuildStatusNoteWithDKP(index)
    local noteButton = _G["GuildFrameGuildStatusButton" .. index .. "Note"]
    local frame = FriendsFrame.playerStatusFrame and GuildPlayerStatusFrame or GuildStatusFrame
    noteButton:SetParent(frame)
    noteButton:SetJustifyH("RIGHT")
    --noteButton:SetPoint("LEFT", "GuildFrameProf"..index.."Frame"..PROFESSION_AMOUNT, "RIGHT", -2, 0)
end

function E:UpdateColumnAfterUpdate()
    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        E:ReplaceGuildFrameGuildStatusNoteWithDKP(i)
    end
    WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader5, E:GetNoteColumnWidth())
    WhoFrameColumn_SetWidth(GuildFrameGuildStatusColumnHeader3, GUILD_FRAME_COLUMN_WIDTH_DKP)
end

function E:GetNoteColumnWidth()
    return GuildListScrollFrame:IsVisible() and GUILD_FRAME_GUILD_STATUS_COLUMN_WIDTH_NOTE - 25 or GUILD_FRAME_GUILD_STATUS_COLUMN_WIDTH_NOTE
end

function E:RefreshDKPColumn(index, note, online)
    local btn = _G["GuildFrameGuildStatusButton" .. index .. "Note"]
    local dkp = note and note ~= '' and self:NoteDKPToNumber(note) or "-"
    if online then
        btn:SetTextColor(1.0, 1.0, 1.0)
    elseif not online then
        btn:SetTextColor(0.5, 0.5, 0.5)
    end
    btn:SetText(dkp or "-")
end

function E:AddGuildMemberColumns()
    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        self:ReplaceGuildFrameGuildStatusNoteWithDKP(i)
        self:CreateDKPCheckButton(i)
    end
end

function E:AdjustDetailFrame()
    local detailNoteLabel = _G["GuildMemberDetailNoteLabel"]
    local detailFrame = _G["GuildMemberDetailFrame"]
    detailNoteLabel:SetText("DKP:")

    f = C:CreateFrame("Frame", "DetailFrameDKPFrame", detailFrame);
    f:SetPoint("LEFT", "GuildFrameGuildStatusColumnHeader2", "RIGHT", -2, 0)
    f:SetSize(60, 14)
    f:SetPoint("LEFT", detailNoteLabel, "RIGHT", 2, 0)
    f:SetScript("OnMouseUp", function()
        if CanEditPublicNote() then
            StaticPopup_Show("SET_GUILDPLAYERDKP")
        end
    end)

    C:IncreaseDetailFrameHeight(GUILD_DETAIL_NORM_HEIGHT - GUILD_DETAIL_OFFICER_HEIGHT + 24)

    font = f:CreateFontString("GuildMemberDetailFrameDKP", "ARTWORK", "GameFontHighlightLeft")
    font:SetWidth(60)
    font:SetPoint("LEFT")

    detailNoteLabel.dkp = font
    _G["GuildMemberDetailOfficerNoteLabel"]:SetText(NOTE_COLON)
    _G["GuildMemberDetailOfficerNoteLabel"]:SetPoint("TOPLEFT", detailNoteLabel, "BOTTOMLEFT", 0, -8)
    _G["GuildMemberNoteBackground"]:Hide()

    local subtract = C:CreateFrame("Button", "ButtonSubtract", f, "UIPanelButtonTemplate")
    subtract:SetPoint("LEFT", f, "RIGHT", 30, 0)
    subtract:SetSize(30, 20)
    subtract:SetText("-")
    subtract:RegisterForClicks("AnyUp")
    subtract:SetScript("OnClick", function()
        StaticPopup_Show("SUBTRACT_GUILDPLAYERDKP")
    end)
    subtract:Hide()
    local add = C:CreateFrame("Button", "ButtonAdd", f, "UIPanelButtonTemplate")
    add:SetPoint("LEFT", subtract, "RIGHT", 0, 0)
    add:SetSize(30, 20)
    add:SetText("+")
    add:RegisterForClicks("AnyUp")
    add:SetScript("OnClick", function()
        StaticPopup_Show("ADD_GUILDPLAYERDKP")
    end)
    add:Hide()

    ButtonAddText:SetPoint("BOTTOM", 0, 4)
    ButtonSubtractText:SetPoint("BOTTOM", 0, 4)

    f.subtract = subtract
    f.add = add
end

function E:UpdateDetailFrame()
    local _, _, _, _, _, _, note, _, _ = GetGuildRosterInfo(GetGuildRosterSelection());
    if (GetGuildRosterSelection() > 0) then
        GuildMemberDetailNoteLabel.dkp:SetText(self:NoteDKPToNumber(note))
    end
end

function E:UpdateDKPControls()
    if E.waitingForServer then
        ButtonAddAll:Disable()
        ButtonAdd:Disable()
        ButtonSubtractAll:Disable()
        ButtonSubtract:Disable()
    else
        ButtonAddAll:Enable()
        ButtonAdd:Enable()
        ButtonSubtractAll:Enable()
        ButtonSubtract:Enable()
    end

end

function E:RenderColumns()
    if Bohemian_DKPConfig.showDKP then
        GuildFrameGuildStatusColumnHeader3:Show()
        GuildFrameDKPButton:Show()
    else
        GuildFrameGuildStatusColumnHeader3:Hide()
        GuildFrameDKPButton:Hide()
    end
    if self.isEditMode and Bohemian_DKPConfig.showDKP then
        self:ShowEditModeButtons()
    else
        self:HideEditModeButtons()
    end
    C:GuildStatus_UpdateHook()
end

function E:CreateGuildFrameDKPButton()
    f = C:CreateFrame("BUTTON", "GuildFrameDKPButton", GuildFrame, "UIPanelButtonTemplate");
    f:SetPoint("LEFT", "GuildFrameControlButton", "RIGHT", 0, 0)
    f:SetText("DKP")
    if not CanEditPublicNote() then
        f:Disable()
    end
    f:SetScript("OnClick", function()
        E.isEditMode = not E.isEditMode
        E:RenderColumns()
    end)
    f:SetWidth(65)
    GuildFrameGuildInformationButton:ClearAllPoints(true)
    GuildFrameAddMemberButton:ClearAllPoints(true)
    GuildFrameControlButton:ClearAllPoints(true)
    GuildFrameGuildInformationButton:SetPoint("BOTTOMLEFT", "GuildFrame", 4, 4)
    GuildFrameAddMemberButton:SetPoint("LEFT", "GuildFrameGuildInformationButton", "RIGHT", 0, 0)
    GuildFrameControlButton:SetPoint("LEFT", "GuildFrameAddMemberButton", "RIGHT", 0, 0)
end

function E:UpdateUIGuildPermissions()
    if CanEditPublicNote() then
        DetailFrameDKPFrame.add:Show()
        DetailFrameDKPFrame.subtract:Show()
        GuildFrameDKPButton:Enable()
    else
        DetailFrameDKPFrame.add:Hide()
        DetailFrameDKPFrame.subtract:Hide()
        GuildFrameDKPButton:Disable()
    end
end

local difficulties = {
    { 0, "Any" },
    { 1, "5 Player" },
    { 2, "5 Player (Heroic)" },
    { 3, "10 Player" },
    { 4, "25 Player" },
}

function E:AddConfigFrames(f)
    local importFrame = C:CreateFrame("Frame", "BohemkaDKPImportFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    importFrame:SetPoint("CENTER")
    importFrame:SetSize(512, 512)
    importFrame:SetFrameStrata("DIALOG")
    importFrame:SetBackdrop(BACKDROP_DIALOG_32_32)
    importFrame:Hide()

    local f2 = C:CreateFrame("BUTTON", "$parentClose", importFrame, "UIPanelCloseButton");
    f2:SetPoint("TOPRIGHT", importFrame, "TOPRIGHT", -4, -4)

    local editbox = C:CreateFrame("EditBox", "$parentEditBox", importFrame)
    editbox:SetAllPoints(importFrame)
    editbox:SetWidth(importFrame:GetWidth() - 30)
    editbox:SetHeight(importFrame:GetHeight())
    editbox:SetFontObject("GameFontHighlight")
    editbox:SetAutoFocus(true)
    editbox:SetMultiLine(true)
    editbox:SetTextInsets(8, 4, 4, 4)
    editbox:SetJustifyH("LEFT")
    editbox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        importFrame:Hide()
    end)

    local Scroll = C:CreateFrame('ScrollFrame', '$parentEditBoxScroll', importFrame, 'UIPanelScrollFrameTemplate')
    Scroll:SetPoint('TOPLEFT', importFrame, 'TOPLEFT', 10, -30)
    Scroll:SetPoint('BOTTOMRIGHT', importFrame, 'BOTTOMRIGHT', -36, 42)
    Scroll:SetScrollChild(editbox)

    local import = C:CreateFrame("BUTTON", "$parentImport", importFrame, "UIPanelButtonTemplate");
    import:SetPoint("BOTTOM", 0, 15)
    import:SetWidth(120)
    import:SetText("Import")
    import:SetScript("OnClick", function()
        E:Debug("Importing DKP")
        local totalMembers, _, _ = GetNumGuildMembers();
        local tmp = {}
        local c = 0
        for _, v in ipairs({ strsplit("\n", BohemkaDKPImportFrameEditBox:GetText()) }) do
            local name, _, dkp = strsplit(",", v)
            dkp = tonumber(dkp)
            if dkp then
                tmp[strsplit("-", name)] = dkp
                c = c + 1
            end
        end
        E:Debug("Processing total amount of", c, "records")
        if c > 0 then
            for i = 1, totalMembers do
                fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway = GetGuildRosterInfo(i);
                local importedDKP = tmp[strsplit("-", fullName)]
                if importedDKP then
                    E:SaveDKP(i, importedDKP, nil, "Imported")
                end
            end
        end
        importFrame:Hide()
    end)

    local editBoxHeight = 385

    import = C:CreateFrame("BUTTON", "$parentImport", f, "UIPanelButtonTemplate");
    import:SetPoint("TOPLEFT", f, "TOPLEFT", 30, -26)
    import:SetWidth(120)
    import:SetText("Import")
    import:SetScript("OnClick", function()
        importFrame:Show()
        BohemkaDKPImportFrameImport:Show()
        BohemkaDKPImportFrameEditBox:SetText("")
    end)

    local export = C:CreateFrame("BUTTON", "$parentExport", f, "UIPanelButtonTemplate");
    export:SetPoint("TOP", import, "BOTTOM", 0, -2)
    export:SetWidth(120)
    export:SetText("Export")
    export:SetScript("OnClick", function()
        local totalMembers, _, _ = GetNumGuildMembers()
        local data = "name,class,dkp\n"
        local tmp = {}
        for i = 1, totalMembers do
            local fullName, _, _, _, class, _, note = GetGuildRosterInfo(i);
            table.insert(tmp, format("%s,%s,%d", fullName, class, E:NoteDKPToNumber(note)))
        end
        data = data .. table.concat(tmp, "\n")
        importFrame:Show()
        BohemkaDKPImportFrameEditBox:SetText(data)
        BohemkaDKPImportFrameEditBox:HighlightText()
        BohemkaDKPImportFrameImport:Hide()
    end)

    local l = f:CreateLine()
    l:SetColorTexture(0.3, 0.3, 0.3)
    l:SetStartPoint("TOPLEFT", f, 30, -100)
    l:SetEndPoint("TOPRIGHT", f, -30, -100)
    l:SetThickness(1)

    local bossRewardsFont = f:CreateFontString("$parentTextItemPrice", "ARTWORK", "GameFontNormal")
    bossRewardsFont:SetJustifyH("CENTER")
    bossRewardsFont:SetSize(400, 14)
    bossRewardsFont:SetPoint("TOP", l, "BOTTOM", 0, -10)
    bossRewardsFont:SetText("Boss Reward")

    local frameName = f:GetName()
    local editboxBg, editbox
    for index, difficulty in ipairs(difficulties) do
        editboxBg = C:CreateFrame("Frame", "$parentEditBoxBossRewards" .. difficulty[1], f, "TooltipBackdropTemplate")
        editboxBg:SetSize(bossRewardsFont:GetWidth(), editBoxHeight)
        editboxBg:SetPoint("TOP", bossRewardsFont, "BOTTOM", 0, -5)

        editbox = C:CreateFrame("EditBox", "$parentBossRewards", editboxBg)
        editbox:SetAllPoints(editboxBg)
        editbox:SetWidth(editboxBg:GetWidth() - 30)
        editbox:SetHeight(editboxBg:GetHeight())
        editbox:SetFontObject("GameFontHighlight")
        editbox:SetAutoFocus(false)
        editbox:SetMultiLine(true)
        editbox:SetText(C:TableToConfigText(E:GetDifficultyBossRewards(difficulty[1])))
        editbox:SetTextInsets(8, 8, 8, 8)
        editbox:SetJustifyH("LEFT")
        editbox:SetJustifyV("TOP")
        editbox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)

        Scroll = C:CreateFrame('ScrollFrame', '$parentEditBoxBossRewardsScroll' .. difficulty[1], f, 'UIPanelScrollFrameTemplate')
        Scroll:SetPoint('TOPLEFT', editboxBg, 'TOPLEFT', 8, -4)
        Scroll:SetPoint('BOTTOMRIGHT', editboxBg, 'BOTTOMRIGHT', -26, 3)
        Scroll:SetScrollChild(editbox)
        editboxBg.editbox = editbox
        editboxBg.scroll = Scroll

        editbox:Hide()
        editboxBg:Hide()
        Scroll:Hide()
    end

    font = f:CreateFontString("$parentTextItemPrice", "ARTWORK", "GameFontNormalSmall")
    font:SetJustifyH("LEFT")
    font:SetWidth(editboxBg:GetWidth())
    font:SetPoint("TOPLEFT", editboxBg, "BOTTOMLEFT", 10, -3)
    font:SetText("Example:")

    font2 = f:CreateFontString("$parentTextItemPrice", "ARTWORK", "GameFontHighlightSmall")
    font2:SetJustifyH("LEFT")
    font2:SetSize(editbox:GetWidth(), 40)
    font2:SetPoint("TOPLEFT", font, "BOTTOMLEFT", 0, 5)
    font2:SetText("Boss 1=10\nBoss 2=30")

    local bossRewardsDifficultyDropdown = C:CreateFrame("Frame", "$parentAuctionKeyBindDropdown", f, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(bossRewardsDifficultyDropdown, 200)
    bossRewardsDifficultyDropdown:SetPoint("TOPLEFT", l, "BOTTOMLEFT", 0, -2)
    bossRewardsDifficultyDropdown.value = Bohemian_DKPConfig.selectedDifficulty
    E:ShowBossRewardEditBox(frameName, Bohemian_DKPConfig.selectedDifficulty)

    local initMenu = function()
        local selectedValue = UIDropDownMenu_GetSelectedValue(bossRewardsDifficultyDropdown);
        local info = UIDropDownMenu_CreateInfo();

        for index, difficulty in ipairs(difficulties) do
            info.text = difficulty[2];
            info.func = function(self)
                bossRewardsDifficultyDropdown:SetValue(self.value)
            end;
            info.value = difficulty[1]
            if (info.value == selectedValue) then
                info.checked = 1;
            else
                info.checked = nil;
            end
            UIDropDownMenu_AddButton(info);
        end

    end

    UIDropDownMenu_Initialize(bossRewardsDifficultyDropdown, initMenu);
    UIDropDownMenu_SetSelectedValue(bossRewardsDifficultyDropdown, bossRewardsDifficultyDropdown.value);

    bossRewardsDifficultyDropdown.SetValue = function(self, value)
        self.value = value;
        Bohemian_DKPConfig.selectedDifficulty = value
        UIDropDownMenu_SetSelectedValue(self, value);
        E:ShowBossRewardEditBox(frameName, value)
    end
    bossRewardsDifficultyDropdown.GetValue = function(self)
        return UIDropDownMenu_GetSelectedValue(self);
    end
    bossRewardsDifficultyDropdown.RefreshValue = function(self)
        UIDropDownMenu_Initialize(self, initMenu)
        UIDropDownMenu_SetSelectedValue(self, self.value);
        E:ShowBossRewardEditBox(frameName, self.value)
    end

    f.okay = function()
        for index, difficulty in ipairs(difficulties) do
            Bohemian_DKPConfig.bossRewards[difficulty[1]] = C:ConfigTextToTable(E:GetBossRewardEditBox(frameName, difficulty[1]).editbox:GetText())
        end
    end
    f.cancel = function()
        for index, difficulty in ipairs(difficulties) do
            E:GetBossRewardEditBox(frameName, difficulty[1]).editbox:SetText(C:TableToConfigText(Bohemian_DKPConfig.bossRewards[difficulty[1]]))
        end
    end

end

function E:UpdateAwardDKPButton()
    if not E.raidUILoaded then
        return
    end
    RaidFrameAllAssistCheckButton:ClearAllPoints(true)
    if not IsInRaid() or not E:CanEditDKP() then
        ButtonAwardRaidDKP:Hide()
        RaidFrameAllAssistCheckButton:SetPoint(unpack(E.allAssistPoint))
    else
        ButtonAwardRaidDKP:Show()
        RaidFrameAllAssistCheckButton:SetPoint("TOPRIGHT", -60, 0)
    end
end

function E:GetBossRewardEditBox(frameName, difficulty)
    return _G[frameName .. "EditBoxBossRewards" .. difficulty]
end

function E:CurrentBossRewardEditBox(frameName)
    return E:GetBossRewardEditBox(frameName, Bohemian_DKPConfig.selectedDifficulty)
end

function E:ShowBossRewardEditBox(frameName, difficulty)
    for i, d in ipairs(difficulties) do
        local editBox = E:GetBossRewardEditBox(frameName, d[1])
        editBox:Hide()
        editBox.scroll:Hide()
        editBox.editbox:Hide()
    end
    local editBox = E:GetBossRewardEditBox(frameName, difficulty)
    if not editBox then
        return
    end
    editBox:Show()
    editBox.scroll:Show()
    editBox.editbox:Show()
end