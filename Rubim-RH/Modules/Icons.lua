---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Rubim.
--- DateTime: 01/06/2018 02:32
---
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
local Icons = {}
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

--INTERRUPTS---
local int_smart = true

--RUN ONCE
local runonce = 0
local playerSpec = 0

--
local currentSize = 40

--DB to VAR
RubimRH.config.Spells = {}

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
        if RubimPVP ~= nil then
            info.text, info.hasArrow = "PvP Stuff", nil
            info.checked = false
            info.func = function(self)
                RubimRH.PvPConfig()
            end
            UIDropDownMenu_AddButton(info)
        end

        info.text, info.hasArrow = "Class Config", nil
        info.checked = false
        info.func = function(self)
            RubimRH.ClassConfig(playerSpec)
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
        if RubimRH.config.Spells ~= nil and #RubimRH.config.Spells > 0 then
            info.text, info.hasArrow, info.menuList = "Spells", true, "Spells"
            info.checked = false
            info.func = function(self)
                if SkillFramesArray[1]:IsVisible() then
                    for i = 1, #SkillFramesArray do
                        SkillFramesArray[i]:Hide()
                    end
                else
                    for i = 1, #SkillFramesArray do
                        SkillFramesArray[i]:Show()
                    end
                end

            end
            UIDropDownMenu_AddButton(info)
        end
    elseif menuList == "Spells" then
        --SKILL 1
        for i = 1, #RubimRH.config.Spells do
            info.text = GetSpellInfo(RubimRH.config.Spells[i].spellID)
            info.checked = RubimRH.config.Spells[i].isActive
            info.func = function(self)
                PlaySound(891, "Master");
                if RubimRH.config.Spells[i].isActive then
                    RubimRH.config.Spells[i].isActive = false
                else
                    RubimRH.config.Spells[i].isActive = true
                end
                print("|cFF69CCF0" .. GetSpellInfo(RubimRH.config.Spells[i].spellID) .. "|r: |cFF00FF00" .. tostring(RubimRH.config.Spells[i].isActive))
            end
            UIDropDownMenu_AddButton(info, level)
        end
        -- Show the "Games" sub-menu
        --        for s in (tostring(GetSpellInfo(RubimRH.config.Spells1)) .. "; " .. tostring(GetSpellInfo(RubimRH.config.Spells2))):gmatch("[^;%s][^;]*") do
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

local updateConfigFunc = function()
    if runonce == 0 then
        print("===================")
        print("|cFF69CCF0R Rotation Assist:")
        print("|cFF00FF96Right-Click on the Main")
        print("|cFF00FF96Icon to more options")
        print("|cFF00FF96ENABLE NAMEPLATES")
        print("===================")

        if GetCVar("nameplateShowEnemies") == 0 and GetCVar("nameplateShowAll") == 0 then
            SetCVar("nameplateShowEnemies", 1)
        end
        SetCVar("nameplateOtherBottomInset", 0.1)
        SetCVar("nameplateOtherTopInset", 0.08)

        local mainOption = RubimRH.db.profile.mainOption
        Icons.MainIcon = CreateFrame("Frame", nil)
        Icons.MainIcon:SetBackdrop(nil)
        Icons.MainIcon:SetFrameStrata("BACKGROUND")
        Icons.MainIcon:SetSize(currentSize, 40)
        --Icons.MainIcon:SetPoint("CENTER", 0, -200)
        Icons.MainIcon:SetPoint(mainOption.align, mainOption.xCord, mainOption.yCord)
        Icons.MainIcon.texture = Icons.MainIcon:CreateTexture(nil, "BACKGROUND")
        Icons.MainIcon.texture:SetAllPoints(true)
        Icons.MainIcon.texture:SetColorTexture(0, 0, 0, 0)
        Icons.MainIcon:SetScale(1)
        Icons.MainIcon:Show(1)
        Icons.MainIcon:SetMovable(true)
        Icons.MainIcon:EnableMouse(true)
        Icons.MainIcon:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and not self.isMoving then
                self:StartMoving();
                self.isMoving = true;
            end
        end)
        Icons.MainIcon:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
            end
        end)
        Icons.MainIcon:SetScript("OnHide", function(self)
            if (self.isMoving) then
                self:StopMovingOrSizing();
                self.isMoving = false;
            end
        end)

        local IconRotation = CreateFrame("Frame", "MainIconFrame", Icons.MainIcon)
        IconRotation:SetBackdrop(nil)
        IconRotation:SetFrameStrata("BACKGROUND")
        --IconRotation:SetSize(18, 18)
        IconRotation:SetSize(40, 40)
        --IconRotation:SetPoint("TOPLEFT", 19, 6)
        --IconRotation:SetPoint("TOPLEFT", 50, 6)
        IconRotation:SetPoint("LEFT", 0, 0)
        IconRotation.texture = IconRotation:CreateTexture(nil, "BACKGROUND")
        IconRotation.texture:SetAllPoints(true)
        IconRotation.texture:SetColorTexture(0, 0, 0, 1.0)
        IconRotation:SetMovable(true)
        IconRotation:EnableMouse(true)

        local IconRotationInfoText = IconRotation:CreateFontString("InfoText", "OVERLAY")
        IconRotationInfoText:SetFontObject(GameFontNormalSmall)
        IconRotationInfoText:SetJustifyH("LEFT") --
        IconRotationInfoText:SetPoint("CENTER", IconRotation, "CENTER", 0, 0)
        IconRotationInfoText:SetFont("Fonts\\FRIZQT__.TTF", 10, "THICKOUTLINE")
        IconRotationInfoText:SetShadowOffset(1, -1)
        IconRotationInfoText:SetTextColor(1, 0, 0, 0.9)

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
            if RubimPVP ~= nil and button == "MiddleButton" then
                RubimRH.createMacro()
                RubimRH.editMacro()
            end

            if button == "LeftButton" and not Icons.MainIcon.isMoving then
                Icons.MainIcon:StartMoving();
                Icons.MainIcon.isMoving = true;
            end
        end)

        IconRotation:SetScript("OnMouseUp", function(self, button)
            if button == "RightButton" then
                ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3)
            end

            if button == "LeftButton" and Icons.MainIcon.isMoving then
                local _, _, arg2, arg3, arg4 = Icons.MainIcon:GetPoint()
                mainOption.align = arg2
                mainOption.xCord = arg3
                mainOption.yCord = arg4
                Icons.MainIcon:StopMovingOrSizing();
                Icons.MainIcon.isMoving = false;
            end
        end)
        IconRotation:SetScript("OnHide", function(self)
            if (Icons.MainIcon.isMoving) then
                Icons.MainIcon:StopMovingOrSizing();
                Icons.MainIcon.isMoving = false;
            end
        end)
        runonce = 1
    end
end

local updateConfig = CreateFrame("frame")
updateConfig:SetScript("OnEvent", updateConfigFunc)
updateConfig:RegisterEvent("PLAYER_LOGIN")
updateConfig:RegisterEvent("PLAYER_ENTERING_WORLD")
updateConfig:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")


-- MainIcons
function RubimRH.tooltipShow(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
    GameTooltip:Show()
end

function RubimRH.tooltipHide()
    GameTooltip_Hide()
end

-- if text is provided, sets up the button to show a tooltip when moused over. Otherwise, removes the tooltip.
function RubimRH.appendTooltip(self, text)
    if text then
        self.tooltipText = text
        self:SetScript("OnEnter", RubimRH.tooltipShow)
        self:SetScript("OnLeave", RubimRH.tooltipHide)
    else
        self:SetScript("OnEnter", nil)
        self:SetScript("OnLeave", nil)
    end
end

SkillFramesArray = {}
local function createIcon(loopVar, xOffset, description)
    Icons.MainIcon:SetSize(currentSize * 2, 40)

    if SkillFramesArray[loopVar] ~= nil then
        SkillFramesArray[loopVar].texture:SetTexture(GetSpellTexture(RubimRH.config.Spells[loopVar].spellID))
        RubimRH.appendTooltip(SkillFramesArray[loopVar], description)
        if RubimRH.config.Spells[loopVar].isActive then
            SkillFramesArray[loopVar]:SetAlpha(1.0)
        else
            SkillFramesArray[loopVar]:SetAlpha(0.2)
        end
    else
        local newIcon = CreateFrame("Frame", "SkillFrame" .. loopVar, Icons.MainIcon)
        table.insert(SkillFramesArray, newIcon)
        RubimRH.appendTooltip(SkillFramesArray[#SkillFramesArray], description)
        newIcon:Hide()
        newIcon:SetBackdrop(nil)
        newIcon:SetFrameStrata("BACKGROUND")
        --IconRotation:SetSize(18, 18)
        newIcon:SetSize(40, 40)
        --IconRotation:SetPoint("TOPLEFT", 19, 6)
        --IconRotation:SetPoint("TOPLEFT", 50, 6)
        newIcon:SetPoint("LEFT", xOffset, 0)
        newIcon.texture = newIcon:CreateTexture(nil, "BACKGROUND")
        newIcon.texture:SetAllPoints(true)
        newIcon.texture:SetColorTexture(0, 0, 0, 1.0)
        newIcon.texture:SetTexture(GetSpellTexture(RubimRH.config.Spells[loopVar].spellID))
        newIcon:EnableMouse(true)
        newIcon:SetMovable(true)
        if RubimRH.config.Spells[loopVar].isActive then
            newIcon:SetAlpha(1.0)
        else
            newIcon:SetAlpha(0.2)
        end
        newIcon:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and not Icons.MainIcon.isMoving then
                Icons.MainIcon:StartMoving();
                Icons.MainIcon.isMoving = true;
            end
        end)
        newIcon:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and Icons.MainIcon.isMoving then
                Icons.MainIcon:StopMovingOrSizing();
                Icons.MainIcon.isMoving = false;
            end
            if button == "RightButton" and not Icons.MainIcon.isMoving then
                PlaySound(891, "Master");
                if RubimRH.config.Spells[loopVar].isActive then
                    RubimRH.config.Spells[loopVar].isActive = false
                    newIcon:SetAlpha(0.2)
                else
                    RubimRH.config.Spells[loopVar].isActive = true
                    newIcon:SetAlpha(1.0)
                end
                print("|cFF69CCF0" .. GetSpellInfo(RubimRH.config.Spells[loopVar].spellID) .. "|r: |cFF00FF00" .. tostring(RubimRH.config.Spells[loopVar].isActive))
            end
        end)

        newIcon:SetScript("OnHide", function(self)
            if (Icons.MainIcon.isMoving) then
                Icons.MainIcon:StopMovingOrSizing();
                Icons.MainIcon.isMoving = false;
            end
        end)
    end
end

RubimRH.Listener:Add('Rubim_Events', 'ACTIVE_TALENT_GROUP_CHANGED', function(...)
    if RubimRH.config.Spells == nil then
        return
    end
    for i = 1, #SkillFramesArray do
        SkillFramesArray[i]:Hide()
    end
    if #RubimRH.config.Spells ~= nil then
        for i = 1, #RubimRH.config.Spells do
            createIcon(i, 40 * (i), RubimRH.config.Spells[i].description)
        end
    end
end)

RubimRH.Listener:Add('Rubim_Events', 'PLAYER_ENTERING_WORLD', function(...)
    if RubimRH.config.Spells == nil then
        return
    end
    for i = 1, #SkillFramesArray do
        SkillFramesArray[i]:Hide()
    end
    if #RubimRH.config.Spells ~= nil then
        for i = 1, #RubimRH.config.Spells do
            createIcon(i, 40 * (i), RubimRH.config.Spells[i].description)
        end
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


local updateIcon = CreateFrame("Frame");
updateIcon:SetScript("OnUpdate", function(self, sinceLastUpdate)
    updateIcon:onUpdate(sinceLastUpdate);
end)

function updateIcon:onUpdate(sinceLastUpdate)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate;
    if (self.sinceLastUpdate >= 0.2) then

        if RubimRH.shouldStop() == "ERROR" then
            MainIconFrame.texture:SetTexture("Interface\\Addons\\Rubim-RH\\Media\\nosupport.tga")
            return
        end

        playerSpec = Cache.Persistent.Player.Spec[1]
        if CDText ~= nil then
            CDText:SetText(RubimRH.ColorOnOff(RubimRH.config.cooldown) .. "CD")
            AoEText:SetText(RubimRH.ColorOnOff(RubimRH.useAoE) .. "AoE")
        end

        local singleRotation, singleRotation2 = RubimRH.shouldStop()
        local passiveRotation, passiveRotation2 = nil
        if RubimRH.shouldStop() == nil then
            singleRotation, singleRotation2 = RubimRH.Rotation.APLs[playerSpec]()
            _, passiveRotation2 = RubimRH.Rotation.PASSIVEs[playerSpec]()
        end

        if singleRotation == 0 or singleRotation == 1 then
            MainIconFrame.texture:SetTexture(singleRotation2)
        else
            MainIconFrame.texture:SetTexture(GetSpellTexture(singleRotation))
        end

        if RubimExtra then
            RubimRH.passiveIcon.texture:SetTexture(passiveRotation2)

            if singleRotation == 0 then
                RubimRH.stIcon.texture:SetTexture(nil)
            elseif singleRotation == 1 then
                RubimRH.stIcon.texture:SetTexture(singleRotation2)
            else
                RubimRH.stIcon.texture:SetTexture(GetSpellTexture(singleRotation))
            end
        end
        self.sinceLastUpdate = 0;
    end

end

    CinematicFrame:HookScript("OnShow", function(self, ...)
        MainIconFrame:Hide()
    end)

    CinematicFrame:HookScript("OnHide", function(self, ...)
        MainIconFrame:Show()
    end)