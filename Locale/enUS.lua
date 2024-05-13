local addonName, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

if not L then return end

L["CHANNELS_SAY"]     = "S,SAY"
L["CHANNELS_YELL"]    = "Y,YELL,SH,SHOUT"
L["CHANNELS_PARTY"]   = "P,PARTY"
L["CHANNELS_RAID"]    = "RA,RAID,RSAY"
L["CHANNELS_INSTANCE"] = "I,INSTANCE"
L["CHANNELS_RAID_WARNING"] = "RW"

L["SAY"]     = true
L["YELL"]    = true
L["PARTY"]   = true
L["RAID"]    = true
L["INSTANCE"] = true
L["RAID_WARNING"] = true

L["Inspect Target"] = true
L["Inspect Mouseover"] = true

L["SLASH_CMD_UPNE2"] = "/dd"
L["SLASH_CMD_UPNE3"] = "/upne"
L["SLASH_CMD_CALC2"] = "/calc"
L["SLASH_CMD_CALC_SILENT2"] = "/calc2"

L["SLASH_OPT_INTERRUPT"] = {
    ["INT"]  = true, 
    ["INTERRUPT"] = true
}

L["Calculator"] = true
L["Calculation Error"] = true

L["Turn On"] = "(|cffffffffTurn On |r) "
L["Turn Off"] = "(|cff999999Turn Off|r) "

L["Announce Interruption"] = true
L["Announce Interruption: Channel"] = true
L["Interrupt"] = true
L["No Target"] = true
L["Show GS/ILvl on Target Tooltip"] = "Show GS/ILvl on Target Tooltip(After Inpection)"
L["Show [Spell ID] on Aura Tooltip"] = true
L["Show [Caster Name] on Aura Tooltip"] = true
L["Show Target Class Color on Trade Window"] = true
L["Automatically Input DELETE CONFIRM String"] = true
L["Show Raid Icon on ToT/ToF"] = "Show Raid Icon on ToT/ToF (Target of Target, Target of Focus)"
L["Show GearScore on Inspection"] = true
L["Fix Combat Message ON"] = true
L["Combat Message Enabled"] = "Combat Message Enabled.(It was disabled by some reason)"
L["Description_FixCombatMessage"] = "Turn On Combat Message on Login"
L["Alarm when Someone calls My Name"] = true
L["Alarm Sound"] = true
L["Play"] = true
L["Vehicle UI Scale"] = true
L["Vehicle UI Hide BG"] = true
L["Enhance Druid ManaBar"] = true
L["Description_DruidManaBar"] = "Always Show Numbers, Adjust Font/Frame Size, Remove Border. Undoing Needs Reload."
L["FPS: Show FPS"] = true
L["FPS: Move Frame"] = true
L["FPS: Anchor Point"] = true
L["FPS: Anchor Frame"] = true
L["FPS: Anchor Frame's Anchor Point"] = true
L["X Offset"] = true
L["Y Offset"] = true

L["TOPLEFT"]    = true
L["TOP"]        = true
L["TOPRIGHT"]   = true
L["LEFT"]       = true
L["CENTER"]     = true
L["RIGHT"]      = true
L["BOTTOMLEFT"] = true
L["BOTTOM"]     = true
L["BOTTOMRIGHT"] = true
