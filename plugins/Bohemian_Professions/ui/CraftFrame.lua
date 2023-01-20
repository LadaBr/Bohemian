local _, E = ...
local C = E.CORE
function E:CreateGuildCraftFrame()
    local f = C:CreateFrame("Frame", "GuildCraftFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetSize(384, 512)
    f:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 0, 14)
    f:SetHitRectInsets(0, 34, 0, 75)
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    f.mode = "single"
    f:SetScript("OnHide", function (self)
        self.profession = nil
        self.playerName = nil
        E:SelectCraftListButton()
        E:UpdateCraftList()

    end)
    f.attachedX = -30
    f.detachedY = 14

    --local bg = f:CreateTexture(nil, "ARTWORK")
    --bg:SetPoint("TOPLEFT", 185 , -412)
    --bg:SetSize(155, 18)
    --bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock")
    ----local ULx,ULy,LLx,LLy,URx,URy,LRx,LRy = bg:GetTexCoord()
    --bg:SetTexCoord(0, 0.5, 0, 0.1)
    ----local w = bg:GetWidth();
    ----bg:SetWidth(w * 0.5)

    local clear = C:CreateFrame("BUTTON", "$parentClear", f, "UIPanelButtonTemplate");
    clear:SetPoint("TOPLEFT", 183 , -409)
    clear:SetText("Clear")
    clear:SetScript("OnClick", function()
        GuildCraftMemberSearchValue:SetSearchValue()
        GuildCraftMemberSearchValue:ClearFocus()
    end)
    clear:SetWidth(77)

    local closeBtn = C:CreateFrame("BUTTON", "$parentExitButton", f, "UIPanelButtonTemplate");
    closeBtn:SetPoint("LEFT", clear, "RIGHT", 3, 0)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        f:Hide()
    end)
    closeBtn:SetWidth(77)

    local close = C:CreateFrame("BUTTON", "$parentClose", f, "UIPanelCloseButton");
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -30, -8)

    local portrait = f:CreateTexture("$parentPortrait", "BACKGROUND")
    portrait:SetSize(60,60)
    portrait:SetPoint("TOPLEFT", 7, -6)

    local border1 = f:CreateTexture("$parentBorderTopLeft", "BORDER")
    border1:SetSize(256,256)
    border1:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopLeft")
    border1:SetPoint("TOPLEFT")

    local border2 = f:CreateTexture("$parentBorderTopRight", "BORDER")
    border2:SetSize(128,256)
    border2:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-TopRight")
    border2:SetPoint("TOPRIGHT")

    local border3 = f:CreateTexture("$parentBorderBotLeft", "BORDER")
    border3:SetSize(256,256)
    border3:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-BotLeft")
    border3:SetPoint("BOTTOMLEFT")

    local border4 = f:CreateTexture("$parentBorderBotRight", "BORDER")
    border4:SetSize(128,256)
    border4:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-BotRight")
    border4:SetPoint("BOTTOMRIGHT")

    local font = f:CreateFontString("$parentTitle","BORDER", "GameFontNormal")
    font:SetText("Profession")
    font:SetPoint("TOP", 0, -18)



    local skillBorder1 = f:CreateTexture("$parentSkillBorderLeft", "ARTWORK")
    skillBorder1:SetSize(256,8)
    skillBorder1:SetTexture("Interface\\TradeSkillFrame\\UI-TradeSkill-SkillBorder")
    skillBorder1:SetPoint("TOPLEFT", 63, -50)
    skillBorder1:SetTexCoord(0, 1.0, 0, 0.25)

    local skillBorder2 = f:CreateTexture("$parentSkillBorder", "ARTWORK")
    skillBorder2:SetSize(28,8)
    skillBorder2:SetTexture("Interface\\TradeSkillFrame\\UI-TradeSkill-SkillBorder")
    skillBorder2:SetPoint("LEFT", GuildCraftFrameSkillBorderLeft, "RIGHT", 0, 0)
    skillBorder2:SetTexCoord(0, 0.109375, 0.25, 0.5)


    local skillBorder3 = f:CreateTexture("$parentHorizontalSkillBorderLeft", "ARTWORK")
    skillBorder3:SetSize(256,16)
    skillBorder3:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-HorizontalBar")
    skillBorder3:SetPoint("TOPLEFT", 15, -221)
    skillBorder3:SetTexCoord(0, 1.0, 0, 0.25)

    local skillBorder4 = f:CreateTexture("$parentHorizontalSkillBorder", "ARTWORK")
    skillBorder4:SetSize(75,16)
    skillBorder4:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-HorizontalBar")
    skillBorder4:SetPoint("LEFT", GuildCraftFrameHorizontalSkillBorderLeft, "RIGHT", 0, 0)
    skillBorder4:SetTexCoord(0, 0.29296875, 0.25, 0.5)

    local skillRankFrame = C:CreateFrame("StatusBar", "$parentSkillRankFrame", f)
    skillRankFrame:SetMinMaxValues(0, 1)
    skillRankFrame:SetValue(0)
    skillRankFrame:SetSize(268, 15)
    skillRankFrame:SetPoint("TOPLEFT", 73, -37)
    skillRankFrame:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
    skillRankFrame:SetStatusBarColor(0.25, 0.25, 0.75)

    local skillName = skillRankFrame:CreateFontString("$parentSkillName","ARTWORK", "GameFontNormalSmall")
    skillName:SetText("Profession")
    skillName:SetPoint("LEFT", 6, 1)

    local skillRank = skillRankFrame:CreateFontString("$parentSkillRank","ARTWORK", "GameFontHighlightSmall")
    skillRank:SetText("0/0")
    skillRank:SetSize(128, 0)
    skillRank:SetPoint("LEFT", "$parentSkillName", "RIGHT", 13, 0)
    skillRank:SetJustifyH("LEFT")

    local skillRankBg = skillRankFrame:CreateTexture("$parentBackground", "BACKGROUND")
    skillRankBg:SetColorTexture(1, 1, 1, 0.2)

    local skillRankBorder = C:CreateFrame("Button", "$parentBorder", skillRankFrame)
    skillRankBorder:SetSize(281, 32)
    skillRankBorder:SetPoint("LEFT", -5, 0)
    skillRankBorder:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")

    local highlightFrame = C:CreateFrame("Frame", "$parentHighlight", f, BackdropTemplateMixin and "BackdropTemplate" or nil)
    highlightFrame:SetSize(297, 16)
    highlightFrame:SetPoint("TOPLEFT", 0, -30)
    highlightFrame:SetFrameStrata("HIGH")
    highlightFrame:Hide()

    local tx = highlightFrame:CreateTexture("$parentTex", "ARTWORK")
    tx:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
    tx:SetAllPoints(true)

    local prevSkillFrame
    for i=1, CRAFTS_DISPLAYED do
        local skillFrame = C:CreateFrame("Button", "$parentSkillFrame"..i, f)
        local skillFrameText = skillFrame:CreateFontString("$parentText","ARTWORK", "GameFontNormal")
        skillFrameText:SetText("Recipe")
        skillFrameText:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        skillFrameText:SetSize(290, 11)
        skillFrameText:SetPoint("LEFT", 8, 0)
        skillFrameText:SetJustifyH("LEFT")
        skillFrame:SetSize(CRAFT_SKILL_BUTTON_WIDTH, 16)
        skillFrame:SetFontString(skillFrameText)
        skillFrame:SetNormalFontObject("GameFontNormal")
        skillFrame:SetHighlightFontObject("GameFontHighlight")
        skillFrame:SetDisabledFontObject("GameFontDisable")
        skillFrame:Show()
        if not prevSkillFrame then
            skillFrame:SetPoint("TOPLEFT", 22, -96)
        else
            skillFrame:SetPoint("TOPLEFT", prevSkillFrame, "BOTTOMLEFT", 0, 0)
        end
        skillFrame:SetScript("OnClick", function(self)
            if self.craft then
                E:SelectCraftButton(self)
            end
        end)

        local minusBtn = skillFrame:CreateTexture("$parentNormal", "ARTWORK")
        minusBtn:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
        minusBtn:SetPoint("LEFT", 3, 0)
        minusBtn:SetSize(16,16)
        minusBtn:SetAlpha(0)

        local disabledBtn = skillFrame:CreateTexture("$parentDisabled", "ARTWORK")
        disabledBtn:SetTexture("Interface\\Buttons\\UI-PlusButton-Disabled")
        disabledBtn:SetPoint("LEFT", 3, 0)
        disabledBtn:SetSize(16,16)
        disabledBtn:SetAlpha(0)

        skillFrame:SetNormalTexture(minusBtn)
        skillFrame:SetDisabledTexture(disabledBtn)
        prevSkillFrame = skillFrame
    end

    local scroll = C:CreateFrame('ScrollFrame', '$parentScrollFrame', f, 'ClassTrainerListScrollFrameTemplate')
    scroll:SetSize(296, 130)
    scroll:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -67, -96)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, 16, function()
            E:UpdateCrafts()
        end)
    end)
    local scrollDetail = C:CreateFrame('ScrollFrame', '$parentScrollDetailFrame', f, 'ClassTrainerDetailScrollFrameTemplate')
    scrollDetail:SetSize(297, 176)
    scrollDetail:SetPoint('TOPLEFT', 20, -234)

    local scrollDetailChild = C:CreateFrame('Frame', '$parentChildFrame', scrollDetail)
    scrollDetailChild:SetSize(297, 150)

    font = scrollDetailChild:CreateFontString("$parentSkillName","BACKGROUND", "GameFontNormal")
    font:SetSize(244, 0)
    font:SetText("Skill Name")
    font:SetJustifyH("LEFT")
    font:SetPoint("TOPLEFT", 50, -5)

    font = scrollDetailChild:CreateFontString("$parentCooldown", "BACKGROUND", "GameFontRedSmall")
    font:SetText("COOLDOWN")
    font:SetPoint("TOPLEFT", "$parentSkillName", "BOTTOMLEFT", 0, 0)

    local headerLeft = scrollDetailChild:CreateTexture("$parentHeaderLeft", "ARTWORK")
    headerLeft:SetSize(256,64)
    headerLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-DetailHeaderLeft")
    headerLeft:SetPoint("TOPLEFT", 0, 3)

    local headerRight = scrollDetailChild:CreateTexture("$parentHeaderRight", "ARTWORK")
    headerRight:SetSize(64,64)
    headerRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-DetailHeaderRight")
    headerRight:SetPoint("TOPLEFT", headerLeft, "TOPRIGHT", 0, 0)

    font = scrollDetailChild:CreateFontString("$parentDescription", "BACKGROUND", "GameFontHighlightSmall")
    font:SetSize(290, 0)
    font:SetJustifyH("LEFT")
    font:SetPoint("TOPLEFT", 5, -50)

    font = scrollDetailChild:CreateFontString("$parentReagentLabel", "BACKGROUND", "GameFontNormalSmall")
    font:SetText(SPELL_REAGENTS)
    font:SetPoint("TOPLEFT", 8, -47)



    local skillIcon = C:CreateFrame("Button", "$parentSkillIcon", scrollDetailChild)
    skillIcon:SetSize(37,37)
    skillIcon:SetPoint("TOPLEFT", 8, -3)

    local skillIconTexture = skillIcon:CreateTexture("$parentTexture", "ARTWORK")
    skillIconTexture:SetAllPoints(true)


    local skillIconText = skillIcon:CreateFontString("$parentCount", "ARTWORK", "NumberFontNormal")
    skillIconText:SetJustifyH("RIGHT")
    skillIconText:SetPoint("BOTTOMRIGHT", -5, 2)

    skillIcon:SetScript("OnClick", function(self)
        HandleModifiedItemClick(self.itemLink)
    end)
    skillIcon:SetScript("OnEnter", function(self)
        if self.itemLink then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.itemLink)
            CursorUpdate(self)
        end
    end)
    skillIcon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        ResetCursor()
    end)

    local reagents = {}
    for i=1, 8 do
        local skillReagent = C:CreateFrame("Button", "$parentSkillReagent"..i, scrollDetailChild, "QuestItemTemplate")
        skillReagent.id = i
        skillReagent:SetScript("OnEnter", function(self)
            if self.itemLink then
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                GameTooltip:SetHyperlink(self.itemLink)
                CursorUpdate(self)
            end
        end)
        skillReagent:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            ResetCursor()
        end)
        skillReagent:SetScript("OnClick", function(self)
            HandleModifiedItemClick(self.itemLink)
        end)

        _G["GuildCraftFrameScrollDetailFrameChildFrameSkillReagent"..i.."Name"]:SetText("Test")
        table.insert(reagents, skillReagent)
    end
    reagents[1]:SetPoint("TOPLEFT", "$parentReagentLabel", "BOTTOMLEFT", -2, -3)
    reagents[2]:SetPoint("LEFT", reagents[1], "RIGHT", 0, 0)
    reagents[3]:SetPoint("TOPLEFT", reagents[1], "BOTTOMLEFT", 0, -2)
    reagents[4]:SetPoint("LEFT", reagents[3], "RIGHT", 0, 0)
    reagents[5]:SetPoint("TOPLEFT", reagents[3], "BOTTOMLEFT", 0, -2)
    reagents[6]:SetPoint("LEFT", reagents[5], "RIGHT", 0, 0)
    reagents[7]:SetPoint("TOPLEFT", reagents[6], "BOTTOMLEFT", 0, -2)
    reagents[8]:SetPoint("LEFT", reagents[7], "RIGHT", 0, 0)

    scrollDetail:SetScrollChild(scrollDetailChild)

    local e = C:CreateFrame("EditBox", "GuildCraftMemberSearchValue", f)
    e:SetWidth(150)
    e:SetHeight(33)
    e:SetPoint("TOPLEFT", scrollDetail, "BOTTOMLEFT", 8, 7)
    e:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    e:SetTextInsets(0,0,0,0)
    e:SetMultiLine(false)
    e:SetAutoFocus(false)
    e:SetJustifyH("LEFT")
    e.blockSearch = true
    e:SetScript( "OnEscapePressed", function( )
        e:ClearFocus()
    end )
    local searchText = C:colorize("Search", C.COLOR.GRAY)
    e:SetText(searchText)
    e:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    e:SetScript("OnTextChanged", function(self)
        if self.blockSearch then
            return
        end
        E:RenderFilteredCrafts(self:GetText(), GuildCraftFrame.profession, GuildCraftFrame.playerName)
    end)
    e:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == searchText then
            self:SetText("")
            self.blockSearch = false
        end
    end)
    e.SetSearchValue = function (self, value)
        if not value or value == "" then
            self:SetText(searchText)
            self.blockSearch = true
            local guildCrafts = E:GetGuildCrafts()
            E:RenderCrafts(GuildCraftFrame.playerName, GuildCraftFrame.profession, guildCrafts[GuildCraftFrame.playerName][GuildCraftFrame.profession.name])
        else
            self:SetText(value)
            self.blockSearch = false
            E:RenderFilteredCrafts(self:GetText(), GuildCraftFrame.profession, GuildCraftFrame.playerName)
        end
    end
    e:SetScript("OnEditFocusLost", function(self)
        if self.blockSearch then
            return
        end
        self:SetSearchValue(self:GetText())
    end)

    local playerReagents = C:CreateFrame("CheckButton", "$parentPlayerReagents", f, "UICheckButtonTemplate")
    playerReagents:SetPoint("TOPLEFT", f, 150, -65)
    playerReagents:SetSize(20, 20)
    playerReagents:SetChecked(Bohemian_ProfessionsConfig.showProfessions)
    playerReagents:SetScript("OnClick", function(self)
        Bohemian_ProfessionsConfig.showOwnReagents = self:GetChecked()
        if E.selectedCraftButton then
            E:UpdateCrafts()
            E:SelectCraftButton(E.selectedCraftButton)
        end
    end)

    font = playerReagents:CreateFontString("$parentText","ARTWORK", "GameFontNormalSmall")
    font:SetText("Own reagents")
    font:SetPoint("RIGHT", playerReagents, "LEFT", -5, 1)
    table.insert(UISpecialFrames, f:GetName())
end

function E:RenderCrafts(playerName, profession, crafts)
    GuildCraftFrame:Show()
    self:PositionGuildCraftFrame()
    self:ResetGuildCraftScroll()
    GuildCraftFrameSkillRankFrame:SetMinMaxValues(0, profession.maxRank or 375)
    GuildCraftFrameSkillRankFrameSkillName:SetText(format(TRADE_SKILL_TITLE, profession.name));
    GuildCraftFrameSkillRankFrame:SetValue(profession.rank)
    GuildCraftFrameSkillRankFrameSkillRank:SetText(profession.rank.."/"..(profession.maxRank or "-"));
    GuildCraftFrameTitle:SetText(C:AddClassColorToName(playerName).."'s "..profession.name)
    SetPortraitToTexture(GuildCraftFramePortrait, profession.icon)
    local tmp = {}
    for name, data in pairs(crafts) do
        table.insert(tmp, {name=name, data=data})
    end
    table.sort(tmp, function (a, b) return a.data.id < b.data.id end)
    GuildCraftFrame.crafts = tmp
    GuildCraftFrame.profession = profession
    GuildCraftFrame.playerName = playerName
    self:UpdateCrafts()
    self:UpdateCraftList()
    self:SelectCraftButton(GuildCraftFrameSkillFrame1)
end

function E:UpdateCrafts()
    FauxScrollFrame_Update(GuildCraftFrameScrollFrame, #GuildCraftFrame.crafts, CRAFTS_DISPLAYED, 16, nil, nil, nil);
    local skillOffset = FauxScrollFrame_GetOffset(GuildCraftFrameScrollFrame);
    local hasScroll = GuildCraftFrameScrollFrame:IsVisible()
    local isSelected = false
    for i=1,CRAFTS_DISPLAYED do
        local craft = GuildCraftFrame.crafts[i + skillOffset]
        local skillButton = _G["GuildCraftFrameSkillFrame"..i]
        skillButton.craft = craft
        if craft then
            local text = craft.name
            local available = 0
            if Bohemian_ProfessionsConfig.showOwnReagents then
                local count
                for _, reagent in ipairs(craft.data.reagents) do
                    local playerCount = GetItemCount(reagent.link, true)
                    if reagent.count == 0 then
                        break
                    end
                    local tmp = math.floor(playerCount / reagent.count)
                    if count == nil then
                        count = tmp
                    else
                        if tmp < count then
                            count = tmp
                        end
                    end
                end
                available = count
            else
                available = craft.data.available
            end
            if available == nil then
                text = text.." [?]"
            else
                if available > 0 then
                    text = text.." ["..available.."]"
                end
            end

            skillButton:SetText(text)
            local color = self:GetSkillTypeColor(craft.data.type)
            skillButton.craft = craft
            if color then
                skillButton:SetNormalFontObject(color.font);
            end
            if hasScroll then
                skillButton:SetWidth(CRAFT_SKILL_BUTTON_WIDTH)
            else
                skillButton:SetWidth(CRAFT_SKILL_BUTTON_WIDTH + 22)
            end
        else
            skillButton:SetText("")
        end

        if self:UpdateCraftHighlight(i) then
            isSelected = true
        end
    end

    if not isSelected then
        GuildCraftFrameHighlight:Hide()
        GuildCraftFrameHighlightTex:SetVertexColor(0, 0, 0, 0)
    end
end
function E:UpdateCraftHighlight(i)
    local skillOffset = FauxScrollFrame_GetOffset(GuildCraftFrameScrollFrame);
    local skillButton = _G["GuildCraftFrameSkillFrame"..i]
    local craft = GuildCraftFrame.crafts[i + skillOffset]
    if craft and self.selectedCraft and craft == self.selectedCraft then
        GuildCraftFrameHighlight:Show()
        GuildCraftFrameHighlight:SetPoint("TOPLEFT", skillButton, "TOPLEFT", 0, 0);
        GuildCraftFrameHighlight:SetWidth(skillButton:GetWidth())
        skillButton:LockHighlight()
        local color = E:GetSkillTypeColor(self.selectedCraft.data.type)
        if color then
            GuildCraftFrameHighlightTex:SetVertexColor(color.r, color.g, color.b, 1)
        end
        return true
    else
        skillButton:UnlockHighlight()
        return false
    end
end
function E:SelectCraftButton(button)
    GuildCraftFrameHighlight:Hide()
    E.selectedCraftButton = button
    E.selectedCraft = button and button.craft or button
    GuildCraftFrameScrollDetailFrame:Hide()

    for i=1,CRAFTS_DISPLAYED do
        local skillButton = _G["GuildCraftFrameSkillFrame"..i]
        if button then
            E:UpdateCraftHighlight(i)
        end
        if button and button.craft and button == skillButton then
            GuildCraftFrameScrollDetailFrame:Show()
            GuildCraftFrameScrollDetailFrameChildFrameSkillIconTexture:SetTexture(button.craft.data.icon)
            GuildCraftFrameScrollDetailFrameChildFrameSkillIcon.itemLink = button.craft.data.link
            local maxMade = button.craft.data.max or 0
            local minMade = button.craft.data.min or 0
            local iconText = GuildCraftFrameScrollDetailFrameChildFrameSkillIconCount
            if ( maxMade > 1 ) then
                if ( minMade == maxMade ) then
                    iconText:SetText(minMade);
                else
                    iconText:SetText(minMade.."-"..maxMade);
                end
                if ( iconText:GetWidth() > 39 ) then
                    iconText:SetText("~"..floor((minMade + maxMade)/2));
                end
            else
                iconText:SetText("");
            end
            if button.craft.data.cooldown and button.craft.data.cooldown > 0 then
                GuildCraftFrameScrollDetailFrameChildFrameCooldown:SetText(COOLDOWN_REMAINING.." "..SecondsToTime(button.craft.data.cooldown))
            else
                GuildCraftFrameScrollDetailFrameChildFrameCooldown:SetText("")
            end
            GuildCraftFrameScrollDetailFrameChildFrameSkillName:SetText(button.craft.name)
            if button.craft.data.desc and button.craft.data.desc ~= " " then
                GuildCraftFrameScrollDetailFrameChildFrameDescription:SetText(button.craft.data.desc);
                GuildCraftFrameScrollDetailFrameChildFrameReagentLabel:SetPoint("TOPLEFT", GuildCraftFrameScrollDetailFrameChildFrameDescription, "BOTTOMLEFT", 0, -10);
            else
                GuildCraftFrameScrollDetailFrameChildFrameDescription:SetText("");
                GuildCraftFrameScrollDetailFrameChildFrameReagentLabel:SetPoint("TOPLEFT", GuildCraftFrameScrollDetailFrameChildFrameDescription, "TOPLEFT", 0, 0);
            end
            local creatable = 1
            for j=1,8 do
                local reagent = button.craft.data.reagents[j]
                local reagentFrame = _G["GuildCraftFrameScrollDetailFrameChildFrameSkillReagent"..j]
                local name = _G["GuildCraftFrameScrollDetailFrameChildFrameSkillReagent"..j.."Name"]
                local count = _G["GuildCraftFrameScrollDetailFrameChildFrameSkillReagent"..j.."Count"]
                if reagentFrame then
                    if reagent then
                        reagentFrame:Show()
                        reagentFrame.itemLink = reagent.link
                        SetItemButtonTexture(reagentFrame, reagent.count > 0 and reagent.texture or "Interface\\Icons\\INV_Misc_QuestionMark")
                        local playerReagentCount = Bohemian_ProfessionsConfig.showOwnReagents and GetItemCount(reagent.link, true) or reagent.playerCount or 0
                        local reagentName = reagent.link and reagent.link:match('%[(.+)%]') or "???"
                        name:SetText(reagentName)
                        if ( playerReagentCount < reagent.count ) then
                            SetItemButtonTextureVertexColor(reagentFrame, 0.5, 0.5, 0.5);
                            name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
                            creatable = nil;
                        else
                            SetItemButtonTextureVertexColor(reagentFrame, 1.0, 1.0, 1.0);
                            name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
                        end

                        if reagent.playerCount and reagent.playerCount >= 100 then
                            playerReagentCount = "*";
                        end
                        if not reagent.playerCount then
                            playerReagentCount = "?"
                        end
                        local countText = reagent.count
                        if reagent.count == 0 then
                            countText = "?"
                        end
                        count:SetText(playerReagentCount.." /"..countText);
                    else
                        reagentFrame:Hide()
                    end
                end
            end
        end
    end
end
function E:ScrollToSelectedCraft()
    if not GuildCraftListFrame:IsVisible() then
        return
    end
    local selectedItem = 0
    local skillOffset = FauxScrollFrame_GetOffset(GuildCraftListFrameScrollFrame)
    for i, button in ipairs(GuildCraftListFrame.buttons) do
        if GuildCraftFrame.playerName and button.playerName == GuildCraftFrame.playerName and GuildCraftFrame.profession.name == button.profession.name then
            selectedItem = i
            break
        end
    end
    skillOffset = math.max(0, selectedItem - CRAFTS_LIST_DISPLAYED)
    FauxScrollFrame_SetOffset(GuildCraftListFrameScrollFrame, skillOffset)
    GuildCraftListFrameScrollFrameScrollBar:SetValue(skillOffset * CRAFTS_LIST_ROW_HEIGHT)
end
