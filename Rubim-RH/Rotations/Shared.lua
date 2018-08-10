---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rubim.
--- DateTime: 12/07/2018 07:01
---

local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

local ProlongedPower = Item(142117)
local Healthstone = 5512

local trinket1 = 1030910
local trinket2 = 1030902
function RubimRH.Shared()
    if Item(Healthstone):IsReady() and Player:HealthPercentage() <= RubimRH.db.profile.mainOption.healthstoneper then
        return 0, 538745
    end
end