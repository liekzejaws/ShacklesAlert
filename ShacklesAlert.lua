-------------------------------------------------------------------------------
-- ShacklesAlert
-- Alerts for Shackles of the Legion and Karazhan trash mob debuffs.
--
-- Monitors boss emotes and player debuffs to display prominent on-screen
-- warnings with visual overlays and sound alerts.
--
-- Target Client: World of Warcraft Classic (1.12)
-- Author: Jars <Thunder Ale Brewing Co.>
-- License: GPL v2
-------------------------------------------------------------------------------

local ShacklesAlert = {}

-------------------------------------------------------------------------------
-- Configuration
-------------------------------------------------------------------------------

-- Shackles of the Legion
ShacklesAlert.SHACKLES_WARNING_TEXT   = "SHACKLES INCOMING!"
ShacklesAlert.SHACKLES_DEBUFF_TEXT    = "YOU ARE SHACKLED!"
ShacklesAlert.SHACKLES_DEBUFF_NAME   = "Shackles of the Legion"
ShacklesAlert.SHACKLES_TIMER_DURATION = 9
ShacklesAlert.SOUND_FILE              = "Interface\\AddOns\\ShacklesAlert\\alert.wav"

-- Astral Insight
ShacklesAlert.ASTRAL_TEXTURE      = "Interface\\Icons\\Ability_Creature_Cursed_03"
ShacklesAlert.ASTRAL_WARNING_TEXT = "DO NOT CAST"

-- Don't Move
ShacklesAlert.DONT_MOVE_TEXTURE      = "Interface\\Icons\\Spell_Fire_Immolation"
ShacklesAlert.DONT_MOVE_WARNING_TEXT = "DON'T MOVE!"

-- Zone restriction (applies to Astral Insight and Don't Move only).
-- Add the exact subzone names where these warnings should be active.
ShacklesAlert.ACTIVE_ZONES = {
    ["Tower of Karazhan"]  = true,
    ["Guardian's Library"] = true,
    ["Gamesman's Hall"]    = true,
}

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------

local function IsZoneActive()
    local currentZone = GetZoneText()
    if ShacklesAlert.ACTIVE_ZONES[currentZone] then
        return true
    else
        return false
    end
end

-------------------------------------------------------------------------------
-- Shackles of the Legion
--
-- Detects boss emotes and the player debuff "Shackles of the Legion".
-- Displays a large red warning centered on screen with a dark overlay
-- and plays an alert sound. The warning dismisses after 9 seconds.
-------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")

-- Warning frame
local warningFrame = CreateFrame("Frame", nil, UIParent)
warningFrame:SetWidth(400)
warningFrame:SetHeight(100)
warningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
warningFrame:Hide()

local warningText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
warningText:SetAllPoints()
warningText:SetTextColor(1, 0, 0)
warningText:SetText(ShacklesAlert.SHACKLES_WARNING_TEXT)
warningText:SetShadowColor(0, 0, 0, 1)
warningText:SetShadowOffset(2, -2)

-- Fullscreen dim overlay
local glowFrame = CreateFrame("Frame", nil, UIParent)
glowFrame:SetAllPoints(UIParent)
glowFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
glowFrame:SetBackdropColor(0, 0, 0, 0.5)
glowFrame:Hide()

-- Auto-hide timer
local timerFrame = CreateFrame("Frame")
timerFrame:Hide()

local elapsedTime = 0

timerFrame:SetScript("OnUpdate", function()
    elapsedTime = elapsedTime + arg1
    if elapsedTime >= ShacklesAlert.SHACKLES_TIMER_DURATION then
        warningFrame:Hide()
        glowFrame:Hide()
        this:Hide()
    end
end)

local function ShowWarning(text)
    warningText:SetText(text)
    warningFrame:Show()
    glowFrame:Show()
    PlaySoundFile(ShacklesAlert.SOUND_FILE)
    elapsedTime = 0
    timerFrame:Show()
end

local function CheckPlayerDebuffs()
    for i = 1, 40 do
        local name = UnitDebuff("player", i)
        if not name then break end
        if name == ShacklesAlert.SHACKLES_DEBUFF_NAME then
            ShowWarning(ShacklesAlert.SHACKLES_DEBUFF_TEXT)
            break
        end
    end
end

-- Event registration
eventFrame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
eventFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
eventFrame:RegisterEvent("PLAYER_AURAS_CHANGED")

eventFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_RAID_BOSS_EMOTE" or event == "CHAT_MSG_MONSTER_EMOTE" then
        local msg = arg1
        if msg and string.find(string.lower(msg), "shackles of the legion") then
            ShowWarning(ShacklesAlert.SHACKLES_WARNING_TEXT)
        end
    elseif event == "PLAYER_AURAS_CHANGED" then
        CheckPlayerDebuffs()
    end
end)

-------------------------------------------------------------------------------
-- Astral Insight (Karazhan)
--
-- Monitors for the Astral Insight debuff by its icon texture while in
-- configured Karazhan zones. Displays a yellow "DO NOT CAST" warning
-- with the debuff icon and a dark overlay for the duration of the debuff.
-------------------------------------------------------------------------------

-- Warning frame
local astralWarningFrame = CreateFrame("Frame", nil, UIParent)
astralWarningFrame:SetWidth(400)
astralWarningFrame:SetHeight(100)
astralWarningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
astralWarningFrame:Hide()

local astralText = astralWarningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
astralText:SetPoint("LEFT", 60, 0)
astralText:SetTextColor(1, 1, 0)
astralText:SetText(ShacklesAlert.ASTRAL_WARNING_TEXT)
astralText:SetShadowOffset(2, -2)

local astralIcon = astralWarningFrame:CreateTexture(nil, "ARTWORK")
astralIcon:SetWidth(48)
astralIcon:SetHeight(48)
astralIcon:SetPoint("LEFT", astralWarningFrame, "LEFT", 0, 0)
astralIcon:SetTexture(ShacklesAlert.ASTRAL_TEXTURE)

-- Fullscreen dark overlay
local astralGlow = CreateFrame("Frame", nil, UIParent)
astralGlow:SetAllPoints(UIParent)
astralGlow.texture = astralGlow:CreateTexture(nil, "BACKGROUND")
astralGlow.texture:SetAllPoints()
astralGlow.texture:SetTexture(0, 0, 0, 0.6)
astralGlow:Hide()

local function CheckAstralInsight()
    if not IsZoneActive() then
        astralWarningFrame:Hide()
        astralGlow:Hide()
        return
    end

    local found = false
    for i = 0, 15 do
        local buffIndex = GetPlayerBuff(i, "HARMFUL")
        if buffIndex >= 0 then
            local texture = GetPlayerBuffTexture(buffIndex)
            if texture == ShacklesAlert.ASTRAL_TEXTURE then
                astralWarningFrame:Show()
                astralGlow:Show()
                astralText:SetText(ShacklesAlert.ASTRAL_WARNING_TEXT)
                astralText:SetTextColor(1, 1, 0)
                astralIcon:SetTexture(texture)
                found = true
                break
            end
        end
    end

    if not found then
        astralWarningFrame:Hide()
        astralGlow:Hide()
    end
end

local astralCheckFrame = CreateFrame("Frame")
astralCheckFrame:SetScript("OnUpdate", function()
    CheckAstralInsight()
end)

-------------------------------------------------------------------------------
-- Don't Move (Karazhan)
--
-- Monitors for the Immolation-type debuff by its icon texture while in
-- configured Karazhan zones. Displays a red "DON'T MOVE!" warning with
-- the debuff icon and a dark overlay. Plays the alert sound once per
-- debuff application.
-------------------------------------------------------------------------------

-- Warning frame
local dontMoveWarningFrame = CreateFrame("Frame", nil, UIParent)
dontMoveWarningFrame:SetWidth(400)
dontMoveWarningFrame:SetHeight(100)
dontMoveWarningFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
dontMoveWarningFrame:Hide()

local dontMoveText = dontMoveWarningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
dontMoveText:SetPoint("LEFT", 60, 0)
dontMoveText:SetTextColor(1, 0, 0)
dontMoveText:SetText(ShacklesAlert.DONT_MOVE_WARNING_TEXT)
dontMoveText:SetShadowOffset(2, -2)

local dontMoveIcon = dontMoveWarningFrame:CreateTexture(nil, "ARTWORK")
dontMoveIcon:SetWidth(48)
dontMoveIcon:SetHeight(48)
dontMoveIcon:SetPoint("LEFT", dontMoveWarningFrame, "LEFT", 0, 0)
dontMoveIcon:SetTexture(ShacklesAlert.DONT_MOVE_TEXTURE)

-- Fullscreen dark overlay
local dontMoveGlow = CreateFrame("Frame", nil, UIParent)
dontMoveGlow:SetAllPoints(UIParent)
dontMoveGlow.texture = dontMoveGlow:CreateTexture(nil, "BACKGROUND")
dontMoveGlow.texture:SetAllPoints()
dontMoveGlow.texture:SetTexture(0, 0, 0, 0.6)
dontMoveGlow:Hide()

local dontMovePlaying = false

local function CheckDontMove()
    if not IsZoneActive() then
        dontMoveWarningFrame:Hide()
        dontMoveGlow:Hide()
        dontMovePlaying = false
        return
    end

    local found = false
    for i = 0, 15 do
        local buffIndex = GetPlayerBuff(i, "HARMFUL")
        if buffIndex >= 0 then
            local texture = GetPlayerBuffTexture(buffIndex)
            if texture == ShacklesAlert.DONT_MOVE_TEXTURE then
                dontMoveWarningFrame:Show()
                dontMoveGlow:Show()
                dontMoveIcon:SetTexture(texture)
                dontMoveText:SetText(ShacklesAlert.DONT_MOVE_WARNING_TEXT)
                dontMoveText:SetTextColor(1, 0, 0)

                if not dontMovePlaying then
                    PlaySoundFile(ShacklesAlert.SOUND_FILE)
                    dontMovePlaying = true
                end

                found = true
                break
            end
        end
    end

    if not found then
        dontMoveWarningFrame:Hide()
        dontMoveGlow:Hide()
        dontMovePlaying = false
    end
end

local dontMoveCheckFrame = CreateFrame("Frame")
dontMoveCheckFrame:SetScript("OnUpdate", function()
    CheckDontMove()
end)

-------------------------------------------------------------------------------
-- Slash Commands
-------------------------------------------------------------------------------

SLASH_SHACKLESALERT1 = "/shacklesalert"
SlashCmdList["SHACKLESALERT"] = function(msg)
    if msg == "test" then
        ShowWarning("TEST WARNING")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ShacklesAlert Commands:|r")
        DEFAULT_CHAT_FRAME:AddMessage("/shacklesalert test - Test the warning")
    end
end
