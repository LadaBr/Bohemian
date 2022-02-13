local _, E = ...
local C = E.CORE
FRIENDS_FRAME_TAB_COUNT = 5

local defaultWidth = FriendsFrame:GetWidth()
GuildFrame:HookScript("OnShow", function()
    if not InCombatLockdown() then
        E:PositionGuildCraftFrame()
    end
end)
FriendsFrame:HookScript("OnHide", function()
    if not InCombatLockdown() then
        E:PositionGuildCraftFrame()
    end
end)

for i = 1, FRIENDS_FRAME_TAB_COUNT do
    button = getglobal("FriendsFrameTab"..i);
    button:HookScript("OnClick", function(...)
        local tabIndex = PanelTemplates_GetSelectedTab(FriendsFrame)
        if tabIndex ~= 3 then
            if not InCombatLockdown() then
                FriendsFrame:SetWidth(defaultWidth)
                E:PositionGuildCraftFrame()
            end
        end
    end)
end
