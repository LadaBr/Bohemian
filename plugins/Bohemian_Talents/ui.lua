
local _, E = ...
local C = E.CORE



function E:CreateGuildFrameTalentsButtons()
    for i=1, GUILDMEMBERS_TO_DISPLAY do
        local specContainer = C:CreateFrame("Frame", "GuildFrameSpecContainer"..i, _G["GuildFrameButton"..i])
        specContainer:SetSize(15,15)
        specContainer:SetPoint("RIGHT", "GuildFrameButton"..i.."Class", "RIGHT", 0, 0)
        local spec = specContainer:CreateTexture("$parentSpecIcon", "ARTWORK")
        spec:SetAllPoints(specContainer)
        specContainer:SetScript("OnEnter", function(self)
            if self.tooltip then
                GameTooltip:SetOwner(self, "ANCHOR_TOP");
                GameTooltip:SetText(self.tooltip);
                GameTooltip:Show();
            end
        end)
        specContainer:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)
    end
end

function E:UpdateTalentsInfo(i, row)
    local fullName = GetGuildRosterInfo(i)
    local _, spec, amounts = self:GetPlayerTalents(fullName)
    local specFrame = _G["GuildFrameSpecContainer"..row]
    local specIcon = _G["GuildFrameSpecContainer"..row.."SpecIcon"]
    if spec then
        local tooltip = table.concat(amounts, "/")
        specIcon:SetTexture(spec.icon)
        specFrame.tooltip = tooltip
        specFrame:Show()
    else
        specIcon:SetTexture(nil)
        specFrame.tooltip = nil
        specFrame:Hide()
    end
end
