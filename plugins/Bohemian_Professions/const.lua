---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by brode.
--- DateTime: 07.02.2022 18:06
---
local _, E = ...

E.PROFESSIONS = {
    ["Cooking"] = 5,
    ["Blacksmithing"] = 0,
    ["Enchanting"] = 1,
    ["Fishing"] = 6,
    ["Tailoring"] = 0,
    ["First Aid"] = 7,
    ["Shadoweave Tailoring"] = -1,
    ["Spellfire Tailoring"] = -1,
    ["Mooncloth Tailoring"] = -1,
    ["Potion Master"] = -10,
    ["Elixir Master"] = -10,
    ["Transmutation Master"] = -10,
    ["Gnomish Engineer"] = -1,
    ["Goblin Engineer"] = -1,
    ["Tribal Leatherworking"] = -1,
    ["Dragonscale Leatherworking"] = -1,
    ["Elemental Leatherworking"] = -1,
    ["Weaponsmith"] = -1,
    ["Armorsmith"] = -1,
    ["Alchemy"] = -9,
    ["Find Herbs"] = 2,
    ["Find Minerals"] = 2,
    ["Skinning"] = 2,
    ["Herbalism"] = 2,
    ["Engineering"] = 0,
    ["Leatherworking"] = 0,
    ["Jewelcrafting"] = 1,
    ["Mining"] = 2,
}
E.SECONDARY_PROFESSIONS = {
    ["Cooking"] = true,
    ["Fishing"] = true,
    ["First Aid"] = true,
}

E.PROFESSION_ICON_OVERRIDE = {
    ["Elixir Master"] = 134739,
    ["Potion Master"] = 134762,
    ["Transmutation Master"] = 136050,
}

E.PROFESSIONS_SPEC = {
    ["Alchemy"] = {
        ["Elixir Master"] = true,
        ["Potion Master"] = true,
        ["Transmutation Master"] = true,
    },
    ["Blacksmithing"] = {
        ["Weaponsmith"] = true,
        ["Armorsmith"] = true,
    },
    ["Leatherworking"] = {
        ["Tribal Leatherworking"] = true,
        ["Dragonscale Leatherworking"] = true,
        ["Elemental Leatherworking"] = true,
    },
    ["Engineering"] = {
        ["Gnomish Engineer"] = true,
        ["Goblin Engineer"] = true,
    },
    ["Tailoring"] = {
        ["Shadoweave Tailoring"] = true,
        ["Spellfire Tailoring"] = true,
        ["Mooncloth Tailoring"] = true,
    },
}

E.SkillTypeColor = { };
E.SkillTypeColor["optimal"]	= { r = 1.00, g = 0.50, b = 0.25, font = "GameFontNormalLeftOrange" };
E.SkillTypeColor["medium"]	= { r = 1.00, g = 1.00, b = 0.00, font = "GameFontNormalLeftYellow" };
E.SkillTypeColor["easy"]		= { r = 0.25, g = 0.75, b = 0.25, font = "GameFontNormalLeftLightGreen" };
E.SkillTypeColor["trivial"]	= { r = 0.50, g = 0.50, b = 0.50, font = "GameFontNormalLeftGrey" };
E.SkillTypeColor["header"]	= { r = 1.00, g = 0.82, b = 0,    font = "GameFontNormalLeft" };
