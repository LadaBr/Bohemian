---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 10.02.2022 13:27
---

local _, E = ...

local A = E.EVENTS
local C = E.CORE
C:RegisterEvent('LOOT_OPENED')

local hookedFrames = {}
function A:LOOT_OPENED()
    for i=1, GetNumLootItems() do
        local frame = _G["ElvLootSlot"..i]
        if frame and not hookedFrames[frame] then
            hookedFrames[frame] = true
            E:HookLootItemFrameElvUI(frame, i)
        end
    end
end

function A:MODULE_LOADED(module)
    if E.isElvUI then
        E:ProcessModule(module)
    end
end

function A:GUILD_FRAME_AFTER_UPDATE()
    if E.isElvUI then
        for i=1, GUILDMEMBERS_TO_DISPLAY do
            _G["GuildFrameButton" .. i .. "Class"]:Hide()
        end
    end
end

function A:GUILD_FRAME_UPDATE()
    if E.isElvUI then
        if GuildFrameGuildStatusColumnHeader5 then
            GuildFrameGuildStatusColumnHeader5:SetWidth(GuildFrameGuildStatusColumnHeader5:GetWidth() - 18.5)
        end
    end
end