local _, E = ...
local C = E.CORE

CRAFTS_DISPLAYED = 8
CRAFTS_LIST_DISPLAYED = 19
CRAFTS_LIST_ROW_HEIGHT = 16.5
CRAFT_SKILL_BUTTON_WIDTH = 293

function E:CreateGuildCraftListFrame()
    local f = C:CreateFrame("Frame", "GuildCraftListFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetSize(384, 512)
    f:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 0, 14)
    f:SetHitRectInsets(0, 34, 0, 75)
    f:SetFrameStrata("HIGH")
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetScript("OnHide", function()
        E:PositionGuildCraftFrame()
    end)
    f:SetScript("OnShow", function()
        E:PositionGuildCraftFrame()
    end)
    f:Hide()
    f.mode = "single"
    table.insert(UISpecialFrames, f:GetName())

    local clear = C:CreateFrame("BUTTON", "$parentClear", f, "UIPanelButtonTemplate");
    clear:SetPoint("TOPLEFT", 183 , -409)
    clear:SetText("Clear")
    clear:SetScript("OnClick", function()
        GuildCraftListMemberSearchValue:SetSearchValue()
        GuildCraftListMemberSearchValue:ClearFocus()
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
    for i=1, CRAFTS_LIST_DISPLAYED do
        local skillFrame = C:CreateFrame("Button", "$parentSkillFrame"..i, f)
        local skillFrameText = skillFrame:CreateFontString("$parentText","ARTWORK", "GameFontNormal")
        skillFrameText:SetText("Recipe")
        skillFrameText:SetFont("Fonts\\FRIZQT__.TTF", 11)
        skillFrameText:SetSize(192, 11)
        skillFrameText:SetPoint("LEFT", 8, 0)
        skillFrameText:SetJustifyH("LEFT")

        skillFrame:SetSize(CRAFT_SKILL_BUTTON_WIDTH, CRAFTS_LIST_ROW_HEIGHT)
        skillFrame:SetFontString(skillFrameText)
        local skillFrameFont = CreateFont(skillFrame:GetName().."Font")
        skillFrameFont:SetFontObject("GameFontNormal")
        skillFrame:SetNormalFontObject(skillFrameFont)
        skillFrame:SetHighlightFontObject("GameFontHighlight")
        skillFrame:SetDisabledFontObject("GameFontDisable")
        skillFrame:Show()
        skillFrame.collapsed = false
        if not prevSkillFrame then
            skillFrame:SetPoint("TOPLEFT", 22, -96)
        else
            skillFrame:SetPoint("TOPLEFT", prevSkillFrame, "BOTTOMLEFT", 0, 0)
        end
        skillFrame:SetScript("OnClick", function(self)
            if self.config then
                if self.config.type == "header" then
                    Bohemian_ProfessionsConfig.collapsed[self.config.profName] = not Bohemian_ProfessionsConfig.collapsed[self.config.profName]
                    E:RenderCraftsMulti(GuildCraftListMemberSearchValue:GetSearchValue())
                end
                if self.config.profession then
                    if GuildCraftListMemberSearchValue.blockSearch then
                        E:RenderCrafts(self.config.playerName, self.config.profession, E:GetGuildCrafts()[self.config.playerName][self.config.profession.name])
                    else
                        local searchText = GuildCraftListMemberSearchValue:GetText()
                        E:RenderFilteredCrafts(searchText, self.config.profession, self.config.playerName)
                    end

                    E:SelectCraftListButton(self)
                end
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

        local highlightBtn = skillFrame:CreateTexture("$parentHighlight", "ARTWORK")
        highlightBtn:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
        highlightBtn:SetPoint("LEFT", 3, 0)
        highlightBtn:SetSize(16,16)
        highlightBtn:SetAlpha(0)

        skillFrame:SetNormalTexture(minusBtn)
        skillFrame:SetDisabledTexture(disabledBtn)
        skillFrame:SetHighlightTexture(highlightBtn)

        local skillButtonRankFrame = C:CreateFrame("StatusBar", "$parentSkillButtonRankFrame", skillFrame)
        skillButtonRankFrame:SetMinMaxValues(0, 1)
        skillButtonRankFrame:SetValue(1)
        skillButtonRankFrame:SetSize(50, 10)
        skillButtonRankFrame:SetPoint("RIGHT", skillFrame, "RIGHT", -5, 0)
        skillButtonRankFrame:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
        skillButtonRankFrame:SetStatusBarColor(0.25, 0.25, 0.75)



        local skillFrameTextRight = skillFrame:CreateFontString("$parentTextRight","ARTWORK", "GameFontNormal")
        skillFrameTextRight:SetJustifyH("RIGHT")
        skillFrameTextRight:SetSize(30, 9)
        skillFrameTextRight:SetPoint("RIGHT", skillButtonRankFrame, "LEFT", -5, 0)
        skillFrameTextRight:SetFont("Fonts\\FRIZQT__.TTF", 9)

        local skillFrameSpec = C:CreateFrame("Frame", "$parentSpec", skillFrame)
        skillFrameSpec:SetSize(12, 12)
        skillFrameSpec:SetPoint("RIGHT", skillFrameTextRight, "LEFT", -3, 0)

        skillFrameSpec:SetScript("OnEnter", function(self)
            if self.tooltip then
                GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0);
                GameTooltip:SetText(self.tooltip);
                GameTooltip:Show();
            end
        end)
        skillFrameSpec:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)

        local skillFrameSpecText = skillFrameSpec:CreateFontString("$parentSkillRank","ARTWORK", "GameFontHighlightSmall")
        skillFrameSpecText:SetPoint("CENTER", 1, 0)
        skillFrameSpecText:SetJustifyH("CENTER")
        skillFrameSpecText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
        skillFrameSpec.text = skillFrameSpecText

        local skillFrameSpecBg = skillFrameSpec:CreateTexture("$parentBackground", "ARTWORK")
        skillFrameSpecBg:SetAllPoints(true)

        local skillButtonRank = skillButtonRankFrame:CreateFontString("$parentSkillRank","ARTWORK", "GameFontHighlightSmall")
        skillButtonRank:SetText("375/375")
        skillButtonRank:SetPoint("CENTER", skillButtonRankFrame)
        skillButtonRank:SetJustifyH("CENTER")
        skillButtonRank:SetFont("Fonts\\FRIZQT__.TTF", 8)

        local skillButtonBg = skillButtonRankFrame:CreateTexture("$parentBackground", "BACKGROUND")
        skillButtonBg:SetColorTexture(0,0, 0, 0.8)
        skillButtonBg:SetAllPoints(true)

        local skillButtonBorder = C:CreateFrame("Button", "$parentBorder", skillButtonRankFrame)
        skillButtonBorder:SetSize(50, 24)
        skillButtonBorder:SetPoint("LEFT", -0, 0)
        skillButtonBorder:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder")

        prevSkillFrame = skillFrame
    end

    local scroll = C:CreateFrame('ScrollFrame', '$parentScrollFrame', f, 'FauxScrollFrameTemplate')
    scroll:SetSize(296, CRAFTS_LIST_DISPLAYED * CRAFTS_LIST_ROW_HEIGHT)
    scroll:SetPoint('TOPRIGHT', f, 'TOPRIGHT', -67, -96)


    local scrollTop = scroll:CreateTexture("$parentTop", "BACKGROUND")
    scrollTop:SetSize(29,102)
    scrollTop:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
    scrollTop:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -2, 4)
    scrollTop:SetTexCoord(0, 0.445, 0, 0.4)

    local scrollBottom = scroll:CreateTexture("$parentBottom", "BACKGROUND")
    scrollBottom:SetSize(29,106)
    scrollBottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
    scrollBottom:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", -2, -2)
    scrollBottom:SetTexCoord(0.515625, 0.960625, 0, 0.4140625)

    local scrollMiddle = scroll:CreateTexture("$parentMiddle", "BACKGROUND")
    scrollMiddle:SetSize(29,1)
    scrollMiddle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
    scrollMiddle:SetPoint("TOP", scrollTop, "BOTTOM", 0, 0)
    scrollMiddle:SetPoint("BOTTOM", scrollBottom, "TOP", 0, 0)
    scrollMiddle:SetTexCoord(0, 0.445, 0.75, 1)

    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, CRAFTS_LIST_ROW_HEIGHT, function()
            E:UpdateCraftList()
        end)
    end)



    local e = C:CreateFrame("EditBox", "GuildCraftListMemberSearchValue", f)
    e:SetWidth(150)
    e:SetHeight(33)
    e:SetPoint("TOPLEFT", f, 28, -403)
    e:SetFont("Fonts\\FRIZQT__.TTF", 11)
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
        E:RenderCraftsMulti(self:GetText())
    end)
    e:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == searchText then
            self:SetText("")
            self.blockSearch = false
        end
    end)

    e:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(searchText)
            self.blockSearch = true
        end
    end)
    e.GetSearchValue = function(self)
        return self:GetText() == searchText and "" or self:GetText()
    end
    e.SetSearchValue = function (self, value)
        if not value then
            self:SetText(searchText)
            self.blockSearch = true
        else
            self:SetText(value)
            self.blockSearch = false
        end
        E:RenderCraftsMulti(value)
    end
    local showOffline = C:CreateFrame("CheckButton", "$parentOfflineMembers", f, "UICheckButtonTemplate")
    showOffline:SetPoint("TOPLEFT", f, 170, -55)
    showOffline:SetSize(20, 20)
    showOffline:SetChecked(Bohemian_ProfessionsConfig.showOfflineMembers)
    showOffline:SetScript("OnClick", function(self)
        Bohemian_ProfessionsConfig.showOfflineMembers = self:GetChecked()
        E:RenderCraftsMulti(GuildCraftListMemberSearchValue:GetSearchValue())
    end)

    font = showOffline:CreateFontString("$parentText","ARTWORK", "GameFontNormalSmall")
    font:SetText("Offline Members")
    font:SetPoint("RIGHT", showOffline, "LEFT", -5, 1)
end

function E:SelectCraftListButton(button)
    self.selectedCraftListButton = button and button.config or button
    for i=1,CRAFTS_LIST_DISPLAYED do
        local skillButton = _G["GuildCraftListFrameSkillFrame"..i]
        if button then
            self:UpdateCraftListHighlight(i)
        end
    end
end

function E:RenderFilteredCrafts(searchValue, profession, playerName)
    local crafts = self:FilterCrafts(searchValue, profession.name, playerName)
    self:RenderCrafts(playerName, profession, crafts)
end

function E:UpdateCraftList()
    if not GuildCraftListFrame:IsVisible() then
        return
    end
    GuildCraftListFrameHighlight:Hide()
    local skillOffset = FauxScrollFrame_GetOffset(GuildCraftListFrameScrollFrame)
    local hasScroll = #GuildCraftListFrame.buttons > CRAFTS_LIST_DISPLAYED
    local isSelected = false
    FauxScrollFrame_Update(GuildCraftListFrameScrollFrame, #GuildCraftListFrame.buttons, CRAFTS_LIST_DISPLAYED, CRAFTS_LIST_ROW_HEIGHT)
    for i=1,CRAFTS_LIST_DISPLAYED do
        local skillButton = _G["GuildCraftListFrameSkillFrame"..i]
        local skillButtonFont = _G["GuildCraftListFrameSkillFrame"..i.."Font"]
        local skillButtonSpec = _G["GuildCraftListFrameSkillFrame"..i.."Spec"]
        local skillButtonSpecBg = _G["GuildCraftListFrameSkillFrame"..i.."SpecBackground"]
        local skillButtonTextRight = _G["GuildCraftListFrameSkillFrame"..i.."TextRight"]
        local skillButtonStatusBar = _G["GuildCraftListFrameSkillFrame"..i.."SkillButtonRankFrame"]
        local skillButtonStatusBarText = _G["GuildCraftListFrameSkillFrame"..i.."SkillButtonRankFrameSkillRank"]
        local skillButtonNormal = _G["GuildCraftListFrameSkillFrame"..i.."Normal"]
        local skillButtonDisabled = _G["GuildCraftListFrameSkillFrame"..i.."Disabled"]
        local skillButtonHighlight = _G["GuildCraftListFrameSkillFrame"..i.."Highlight"]
        local button = GuildCraftListFrame.buttons[i + skillOffset]
        if button then
            skillButton:Show()
            if not Bohemian_ProfessionsConfig.collapsed[button.profName] then
                skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
            else
                skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
            end
            skillButton.config = button
            if GuildCraftFrame.playerName and button.playerName == GuildCraftFrame.playerName and GuildCraftFrame.profession.name == button.profession.name then
                self:SelectCraftListButton(skillButton)
                isSelected = true
            end
            skillButton:SetNormalFontObject(button.font or skillButtonFont)
            local fontColor = button.fontColor and button.fontColor or E.SkillTypeColor[button.type]
            local rightFontColor = button.rightFontColor and button.rightFontColor or { r = 0.95, g = 0.95, b = 0.95 }
            skillButtonFont:SetTextColor(fontColor.r,fontColor.g,fontColor.b)
            skillButtonTextRight:SetTextColor(rightFontColor.r,rightFontColor.g,rightFontColor.b)
            local specText = ""
            if button.spec and button.spec.icon then
                skillButtonSpecBg:SetTexture(self:GetProfessionIcon(button.spec))
                skillButtonSpec.tooltip = button.spec.name
            else
                skillButtonSpecBg:SetTexture(nil)
                skillButtonSpec.tooltip = nil
            end
            skillButtonSpec.text:SetText(specText)
            if hasScroll then
                skillButton:SetWidth(CRAFT_SKILL_BUTTON_WIDTH)
            else
                skillButton:SetWidth(CRAFT_SKILL_BUTTON_WIDTH + 22)
            end
            skillButtonTextRight:SetText(button.rightTitle)
            if button.type == "header" then
                skillButtonNormal:SetAlpha(1)
                skillButtonDisabled:SetAlpha(1)
                skillButtonHighlight:SetAlpha(1)
                skillButton:SetText("    "..button.title)
            else
                skillButtonNormal:SetAlpha(0)
                skillButtonDisabled:SetAlpha(0)
                skillButtonHighlight:SetAlpha(0)
                skillButton:SetText(button.title)
            end
            if button.statusBar then
                skillButtonStatusBar:Show()
                skillButtonStatusBar:SetMinMaxValues(0, button.statusBar.maxRank or 375)
                skillButtonStatusBar:SetValue(button.statusBar.rank)
                skillButtonStatusBarText:SetText(button.statusBar.rank.."/"..(button.statusBar.maxRank or "-"));
            else
                skillButtonStatusBar:Hide()
            end
            self:UpdateCraftListHighlight(i)
        else
            skillButton:Hide()
        end
    end
    if not isSelected then
        GuildCraftListFrameHighlight:Hide()
        GuildCraftListFrameHighlightTex:SetVertexColor(0, 0, 0, 0)
    end
end


function E:ResetGuildCraftScroll()
    FauxScrollFrame_SetOffset(GuildCraftFrameScrollFrame, 0)
    GuildCraftFrameScrollFrameScrollBar:SetMinMaxValues(0, 0)
    GuildCraftFrameScrollFrameScrollBar:SetValue(0)
end

function E:ResetGuildCraftListScroll()
    FauxScrollFrame_SetOffset(GuildCraftListFrameScrollFrame, 0)
    GuildCraftListFrameScrollFrameScrollBar:SetMinMaxValues(0, 0)
    GuildCraftListFrameScrollFrameScrollBar:SetValue(0)
end

function E:RenderCraftsMulti(searchValue)
    GuildCraftListFrameTitle:SetText("Guild Professions")
    if searchValue and #searchValue > 0 then
        self:ResetGuildCraftListScroll()
    end
    GuildCraftListFrameSkillRankFrame:Hide()
    SetPortraitToTexture(GuildCraftListFramePortrait, 134939)
    local tmp = {}
    local icons = {}
    local guildCrafts = E:GetGuildCrafts()
    for playerName, professions in pairs(guildCrafts) do
        if Bohemian_ProfessionsConfig.showOfflineMembers or C:IsPlayerOnline(playerName) then
            for profName, profession in pairs(professions) do
                if not tmp[profName] then
                    tmp[profName] = {}
                end
                if Professions[playerName] then
                    for _, data in ipairs(Professions[playerName]) do
                        if data.name == profName then
                            tmp[profName][playerName] = { data = data }
                            icons[profName] = data.icon
                            if E.PROFESSIONS_SPEC[profName] then
                                for _, data2 in ipairs(Professions[playerName]) do
                                    for specName, _ in pairs(E.PROFESSIONS_SPEC[profName]) do
                                        if data2.name == specName then
                                            icons[specName] = data2.icon
                                            tmp[profName][playerName].spec = data2
                                            break
                                        end
                                    end

                                end
                            end
                            break
                        end
                    end
                    if tmp[profName][playerName] then
                        local totalRecipes = 0
                        local add = false
                        for craftName, _ in pairs(profession) do
                            if searchValue then
                                if not add and string.find(strlower(craftName), strlower(searchValue)) then
                                    add = true
                                end
                            else
                                add = true
                            end
                            totalRecipes = totalRecipes + 1
                        end
                        if add then
                            tmp[profName][playerName].profession = profession
                            tmp[profName][playerName].totalRecipes = totalRecipes
                        else
                            tmp[profName][playerName] = nil
                        end
                    end
                end
            end
        end
    end
    local professionNames = {}
    for profName, players in pairs(tmp) do
        local count = 0
        for _ in pairs(players) do count = count + 1 end
        if count > 0 then
            professionNames[#professionNames + 1] = profName
        end
    end
    table.sort(professionNames, function (a, b) return a < b end)
    local buttons = {}
    for i, profName in ipairs(professionNames) do
        local players = tmp[profName]
        local playersOrdered = {}
        for playerName, profession in pairs(players) do
            playersOrdered[#playersOrdered + 1] = { playerName = playerName, profession = profession }
        end
        table.sort(playersOrdered, function (a, b) return a.profession.totalRecipes > b.profession.totalRecipes end)
        local icon = icons[profName]
        local text = profName
        if icon then
            text = "|T"..icon..":12:12:0:0|t "..text
        end
        buttons[#buttons + 1] = {
            title = text,
            font = "GameFontNormalLeft",
            type = "header",
            profName = profName
        }
        if not Bohemian_ProfessionsConfig.collapsed[profName] then
            for _, player in ipairs(playersOrdered) do
                local playerName = player.playerName
                local profession = player.profession
                local isOnline = C:IsPlayerOnline(playerName)
                local data = profession.data
                local title
                local classColor = C:GetClassColor(playerName)
                local shortName = strsplit("-", playerName)
                local rightFontColor
                if isOnline then
                    title = shortName
                else
                    title = shortName
                    classColor = C.COLOR.GRAY
                    rightFontColor = C.COLOR.GRAY
                end

                buttons[#buttons + 1] = {
                    title = "        "..title,
                    statusBar = {
                        rank = data.rank,
                        maxRank = data.maxRank,
                    },
                    playerName = playerName,
                    profession = data,
                    highlightColor = classColor,
                    fontColor = classColor,
                    rightTitle = "["..profession.totalRecipes.."]",
                    rightFontColor = rightFontColor,
                    spec = profession.spec
                }
            end
        end
    end
    GuildCraftListFrame.buttons = buttons
    FauxScrollFrame_Update(GuildCraftListFrameScrollFrame, #buttons, CRAFTS_LIST_DISPLAYED, CRAFTS_LIST_ROW_HEIGHT)
    self:UpdateCraftList()
end

function E:UpdateCraftListHighlight(i)
    local skillOffset = FauxScrollFrame_GetOffset(GuildCraftListFrameScrollFrame);
    local skillButton = _G["GuildCraftListFrameSkillFrame"..i]
    local button = GuildCraftListFrame.buttons[i + skillOffset]
    if button and self.selectedCraftListButton and button == self.selectedCraftListButton then
        GuildCraftListFrameHighlight:Show()
        GuildCraftListFrameHighlight:SetPoint("TOPLEFT", skillButton, "TOPLEFT", 0, 0);
        GuildCraftListFrameHighlight:SetWidth(skillButton:GetWidth())
        skillButton:LockHighlight()
        local color = E.SkillTypeColor[button.type] or button.highlightColor
        if color then
            GuildCraftListFrameHighlightTex:SetVertexColor(color.r, color.g, color.b, 1)
        end
        return true
    else
        skillButton:UnlockHighlight()
        return false
    end
end
