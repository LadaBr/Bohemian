
local _, E = ...
local C = E.CORE



function E:CreateGuildFrameTalentsButtons()
    for i=1, GUILDMEMBERS_TO_DISPLAY do
        local specContainer = C:CreateFrame("Frame", "GuildFrameSpecContainer"..i, _G["GuildFrameButton"..i])
        specContainer:SetSize(15,15)
        specContainer:SetPoint("RIGHT", "GuildFrameButton"..i.."Class", "RIGHT", 2, 0)
        local spec = specContainer:CreateTexture("$parentSpecIcon", "ARTWORK")
        spec:SetAllPoints(specContainer)
        C:AddTooltip(specContainer, "ANCHOR_TOP")
    end
end

function E:UpdateTalentsInfo(i, row)
    local fullName = GetGuildRosterInfo(i)
    E:SetTalentFrame(_G["GuildFrameSpecContainer"..row], _G["GuildFrameSpecContainer"..row.."SpecIcon"], fullName)
end

function E:SetTalentFrame(specFrame, specIcon, fullName)
    local _, spec, amounts = self:GetPlayerTalents(fullName)
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
