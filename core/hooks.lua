---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 18:11
---

local _, E = ...
GUILD_FRAME_PADDING_RIGHT = 10
FRIENDS_FRAME_TAB_COUNT = 5

local defaultWidth = FriendsFrame:GetWidth()

function E:GuildStatus_UpdateHook()
    if E.firstLoad then
        E:OnEvent("GUILD_FRAME_BEFORE_UPDATE")
        E:OnEvent("GUILD_FRAME_UPDATE")
        E:OnEvent("GUILD_FRAME_AFTER_UPDATE")
    end
end

hooksecurefunc("GuildStatus_Update", E.GuildStatus_UpdateHook)

GuildFrame:HookScript("OnShow", function()
    if not InCombatLockdown() then
        E:RenderGuildColumnHeaders()
    end
end)

for i = 1, FRIENDS_FRAME_TAB_COUNT do
    button = getglobal("FriendsFrameTab"..i);
    button:HookScript("OnClick", function(...)
        local tabIndex = PanelTemplates_GetSelectedTab(FriendsFrame)
        if tabIndex ~= 3 then
            if not InCombatLockdown() then
                FriendsFrame:SetWidth(defaultWidth)
            end
        end
    end)
end
