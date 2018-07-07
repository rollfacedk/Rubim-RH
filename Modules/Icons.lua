---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rubim.
--- DateTime: 01/06/2018 02:32
---
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")


--INTERRUPTS---
local int_smart = true

--RUN ONCE
local runonce = 0

--DB to VAR
classSpell = {}
local updateConfigFunc = function()
    if runonce == 0 then
        print("===================")
        print("|cFF69CCF0R Rotation Assist:")
        print("|cFF00FF96Right-Click on the Main")
        print("|cFF00FF96Icon to more options")
        print("===================")
        runonce = 1
    end
    if GetCVar("nameplateShowEnemies") == 0 then
        SetCVar("nameplateShowEnemies", 1)
    end
    SetCVar("nameplateOtherBottomInset", 0.1)
    SetCVar("nameplateOtherTopInset", 0.08)

    --Default
    local QuestionMark = 212812
    --DK
    local DeathStrike = 49998
    local RuneTap = 194679
    local BreathOfSindragosa = 152279
    local SindragosasFury = 190778
    local PillarOfFrost = 51271

    --DH
    local FelRush = 195072
    local EyeBeam = 198013

    --Warrior
    local Warbreaker = 209577
    local Ravager = 152277
    local OdynsFury = 205545

    --Paladin
    local JusticarVengeance = 215661
    local WordofGlory = 210191

    --Shaman
    local HealingSurge = 188070

    --Rogue
    local RolltheBones = 193316

    --DK
    if select(2, UnitClass("player")) == "DEATHKNIGHT" then
        --Blood
        if GetSpecialization() == 1 then
            classSpell = {}
            classSpell = RubimRH.db.profile.dk.blood.spells
            --table.insert(classSpell, { spellID = DeathStrike, isActive = true })
            --table.insert(classSpell, { spellID = RuneTap, isActive = true })
            --Frost
        elseif GetSpecialization() == 2 then
            classSpell = {}
            classSpell = RubimRH.db.profile.dk.frost.spells
            --table.insert(classSpell, { spellID = DeathStrike, isActive = true })
            --table.insert(classSpell, { spellID = BreathOfSindragosa, isActive = true })
            --table.insert(classSpell, { spellID = SindragosasFury, isActive = true })
            --table.insert(classSpell, { spellID = PillarOfFrost, isaCtive = true})
            --Unholy
        elseif GetSpecialization() == 3 then
            classSpell = {}
            classSpell = RubimRH.db.profile.dk.unholy.spells
            --table.insert(classSpell, { spellID = DeathStrike, isActive = true })
        end
    end

    --DEMON HUNTER
    if select(3, UnitClass("player")) == 12 then
        if GetSpecialization() == 1 then
            classSpell = {}
            classSpell = RubimRH.db.profile.dh.havoc.spells
        end
    end

    --WARRIOR
    if select(3, UnitClass("player")) == 1 then
        if GetSpecialization() == 1 then
            classSpell = {}
            classSpell = RubimRH.db.profile.wr.arms.spells
        elseif GetSpecialization() == 2 then
            classSpell = {}
            classSpell = RubimRH.db.profile.wr.fury.spells
        end
    end

    --PALADIN
    if select(3, UnitClass("player")) == 2 then
        if GetSpecialization() == 2 then
            classSpell = {}
            classSpell = RubimRH.db.profile.pl.prot.spells
        end
        if GetSpecialization() == 3 then
            classSpell = {}
            classSpell = RubimRH.db.profile.pl.ret.spells
        end
    end
    --SHAMAN
    if select(3, UnitClass("player")) == 7 then
        classSpell = {}
        classSpell = RubimRH.db.profile.sh.enh.spells
    end

    --ROGUE
    if select(3, UnitClass("player")) == 4 then
        classSpell = {}
        classSpell = RubimRH.db.profile.rg.out.spells
    end

    --DRUID
    if select(3, UnitClass("player")) == 11 then
        classSpell = {}
        classSpell = RubimRH.db.profile.dr.feral.spells
    end
end

local updateConfig = CreateFrame("frame")
updateConfig:SetScript("OnEvent", updateConfigFunc)
updateConfig:RegisterEvent("PLAYER_LOGIN")
updateConfig:RegisterEvent("PLAYER_ENTERING_WORLD")
updateConfig:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")


-- RogueMenu

-- Create the dropdown, and configure its appearance
local dropDown = CreateFrame("FRAME", "DropDownMenu", UIParent, "UIDropDownMenuTemplate")
dropDown:SetPoint("CENTER")
dropDown:Hide()
UIDropDownMenu_SetWidth(dropDown, 200)
UIDropDownMenu_SetText(dropDown, "Nothing")

-- Create and bind the initialization function to the dropdown menu
UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    if (level or 1) == 1 then
        info.text, info.hasArrow = "Class Config", nil
        info.checked = false
        info.func = function(self)
            RubimRH.ClassConfig()
        end
        UIDropDownMenu_AddButton(info)
        --
        info.text, info.hasArrow = "Cooldowns", nil
        info.checked = RubimRH.useCD
        info.func = function(self)
            RubimRH.CDToggle()
        end
        UIDropDownMenu_AddButton(info)
        --
        info.text, info.hasArrow = "AoE", nil
        info.checked = RubimRH.useAoE
        info.func = function(self)
            RubimRH.AoEToggle()
        end
        UIDropDownMenu_AddButton(info)
        --
        info.text, info.hasArrow = "CC Break", nil
        info.checked = ccBreak
        info.func = function(self)
            PlaySound(891, "Master");
            RubimRH.CCToggle()
        end
        UIDropDownMenu_AddButton(info)
        --
        info.text, info.hasArrow, info.menuList = "Interrupts", true, "Interrupts"
        info.checked = false
        info.func = function(self)
        end
        UIDropDownMenu_AddButton(info)
        --
        if classSpell ~= nil and    #classSpell > 0 then
            info.text, info.hasArrow, info.menuList = "Spells", true, "Spells"
            info.checked = false
            info.func = function(self)
            end
            UIDropDownMenu_AddButton(info)
        end
    elseif menuList == "Spells" then
        --SKILL 1
        for i = 1, #classSpell do
            info.text = GetSpellInfo(classSpell[i].spellID)
            info.checked = classSpell[i].isActive
            info.func = function(self)
                PlaySound(891, "Master");
                if classSpell[i].isActive then
                    classSpell[i].isActive = false
                else
                    classSpell[i].isActive = true
                end
                print("|cFF69CCF0" .. GetSpellInfo(classSpell[i].spellID) .. "|r: |cFF00FF00" .. tostring(classSpell[i].isActive))
            end
            UIDropDownMenu_AddButton(info, level)
        end
        -- Show the "Games" sub-menu
        --        for s in (tostring(GetSpellInfo(ClassSpell1)) .. "; " .. tostring(GetSpellInfo(ClassSpell2))):gmatch("[^;%s][^;]*") do
        --            info.text = s
        --            UIDropDownMenu_AddButton(info, level)
        --        end
    elseif menuList == "Interrupts" then
        --2 PIECES
        info.text = "Smart"
        info.checked = int_smart
        info.func = function(self)
            PlaySound(891, "Master");
            if int_smart then
                int_smart = false
                print("|cFF69CCF0" .. "Interrupting" .. "|r: |cFF00FF00" .. "Disabled ")
            else
                int_smart = true
                print("|cFF69CCF0" .. "Interrupting" .. "|r: |cFF00FF00" .. "Smart/Everything")
            end
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

Sephul = CreateFrame("Frame", nil, UIParent)
Sephul:SetBackdrop(nil)
Sephul:SetFrameStrata("HIGH")
Sephul:SetSize(30, 30)
Sephul:SetScale(1);
Sephul:SetPoint("TOPLEFT", 1, -50)
Sephul.texture = Sephul:CreateTexture(nil, "TOOLTIP")
Sephul.texture:SetAllPoints(true)
Sephul.texture:SetColorTexture(0, 1, 0, 1.0)
Sephul.texture:SetTexture(GetSpellTexture(226262))
Sephul:Hide()


--NOT USABLE ANYMORE
--RubimRH.Interrupt = CreateFrame("Frame", "Interrupt")
--RubimRH.Interrupt:SetBackdrop(nil)
--RubimRH.Interrupt:SetFrameStrata("HIGH")
--RubimRH.Interrupt:SetSize(1, 1)
--RubimRH.Interrupt:SetScale(1);
--RubimRH.Interrupt:SetPoint("TOPLEFT", 10, 0)
--RubimRH.Interrupt.texture = RubimRH.Interrupt:CreateTexture(nil, "TOOLTIP")
--RubimRH.Interrupt.texture:SetAllPoints(true)
--RubimRH.Interrupt.texture:SetColorTexture(0, 1, 0, 1.0)
--RubimRH.Interrupt:Hide()
--RubimRH.SetFramePos(Interrupt, 1, 0, 1, 1)

local IconRotation = CreateFrame("Frame", nil)
IconRotation:SetBackdrop(nil)
IconRotation:SetFrameStrata("BACKGROUND")
--IconRotation:SetSize(18, 18)
IconRotation:SetSize(40, 40)
--IconRotation:SetPoint("TOPLEFT", 19, 6)
--IconRotation:SetPoint("TOPLEFT", 50, 6)
IconRotation:SetPoint("CENTER", 0, -200)
IconRotation.texture = IconRotation:CreateTexture(nil, "BACKGROUND")
IconRotation.texture:SetAllPoints(true)
IconRotation.texture:SetColorTexture(0, 0, 0, 1.0)
IconRotation:SetMovable(true)
IconRotation:EnableMouse(true)

local IconRotationCDText = IconRotation:CreateFontString("CDText", "OVERLAY")
IconRotationCDText:SetFontObject(GameFontNormalSmall)
IconRotationCDText:SetJustifyH("LEFT") --
IconRotationCDText:SetPoint("CENTER", IconRotation, "CENTER", -10, -15)
IconRotationCDText:SetFont("Fonts\\FRIZQT__.TTF", 8, "THICKOUTLINE")
IconRotationCDText:SetShadowOffset(1, -1)
IconRotationCDText:SetTextColor(1, 1, 1, 0.5)

local IconRotationAoEText = IconRotation:CreateFontString("AoEText", "OVERLAY")
IconRotationAoEText:SetFontObject(GameFontNormalSmall)
IconRotationAoEText:SetJustifyH("RIGHT") --
IconRotationAoEText:SetPoint("CENTER", IconRotation, "CENTER", 10, -15)
IconRotationAoEText:SetFont("Fonts\\FRIZQT__.TTF", 8, "THICKOUTLINE")
IconRotationAoEText:SetShadowOffset(1, -1)
IconRotationAoEText:SetTextColor(1, 1, 1, 0.5)

IconRotation:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not self.isMoving then
        if ExtraPvP == true then
            RubimRH.createMacro()
            RubimRH.editMacro()
        end
        self:StartMoving();
        self.isMoving = true;
    end
end)
IconRotation:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.isMoving then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end

    if button == "RightButton" then
        ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3)
    end
end)
IconRotation:SetScript("OnHide", function(self)
    if (self.isMoving) then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end
end)

local updateIcon = CreateFrame("Frame");
updateIcon:SetScript("OnUpdate", function(self, sinceLastUpdate)
    updateIcon:onUpdate(sinceLastUpdate);
end)

function updateIcon:onUpdate(sinceLastUpdate)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate;
    if (self.sinceLastUpdate >= 0.2) then
        IconRotationCDText:SetText(RubimRH.ColorOnOff(RubimRH.useCD) .. "CD")
        IconRotationAoEText:SetText(RubimRH.ColorOnOff(RubimRH.useAoE) .. "AoE")
        if select(2, MainRotation()) ~= nil then
            IconRotation.texture:SetTexture(select(2, MainRotation()))
        else
            IconRotation.texture:SetTexture(GetSpellTexture(MainRotation()))
        end
        if RubimExtra then
            if select(2, MainRotation()) ~= nil then
                RubimRH.stIcon.texture:SetTexture(0)
            else
                RubimRH.stIcon.texture:SetTexture(GetSpellTexture(MainRotation()))
            end
        end
        self.sinceLastUpdate = 0;
    end
end