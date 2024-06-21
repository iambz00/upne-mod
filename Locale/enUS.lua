local addonName, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

if not L then return end

L["CHANNELS_LIST"] = {
    SAY     = "S,SAY",
    YELL    = "Y,YELL,SH,SHOUT",
    PARTY   = "P,PARTY",
    RAID    = "RA,RAID,RSAY",
    INSTANCE_CHAT = "I,INSTANCE",
    RAID_WARNING = "RW",
}

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

L["Item Level"]         = "Item Level"
L["ANNOUNCE_INTERRUPT"] = "Announce Interruption"
L["ANNOUNCE_CHANNEL"]   = "Announce Interruption: Channel"
L["Interrupt"]          = true
L["No Target"]          = true
L["TOOLTIP_AURA_SRC"]   = "Show [Spell ID] on Aura Tooltip"
L["TOOLTIP_AURA_ID"]    = "Show [Caster Name] on Aura Tooltip"
L["TRADE_CLASS_COLOR"]  = "Show Target Class Color on Trade Window"
L["DELETE_CONFIRM"]     = "Automatically Input \"DELETE\" String"
L["RAIDICON_TOT"]       = "Show Raid Icon on ToT/ToF (Target of Target, Target of Focus)"
L["FIX_COMBATTEXT"]     = "Turn on Combat Message on logging in"
L["Combat Message Enabled"] = "Combat Message Enabled.(It was disabled by some reason)"
L["FIX_COMBATTEXT_HELP"] = "Sometimes UI or addon cause it off"
L["CALLME_ON"]          = "Alarm when Someone calls My Name"
L["CALLME_SOUND"]       = "Alarm Sound"
L["Play"]               = true
L["TOOLTIP_UNIT_ILVL"]  = "Show ILvl on Target Tooltip(After Inpection)"
L["INSPECT_ILVL"]       = "Show ILvl on Inspection"
L["VEHICLEUI_SCALE"]    = "Vehicle UI Scale"
L["VEHICLEUI_HIDEBG"]   = "Vehicle UI Hide BG"
L["DRUID_MANABAR"]      = "Enhance Druid ManaBar"
L["DRUID_MANABAR_HELP"] = "Always Show Numbers, Adjust Font/Frame Size, Remove Border. Undoing Needs Reload."
L["LFG_LEAVE_INSTANCE"] = "Show Instance Leaving Popup on finish"
L["LFG_LEAVE_WAIT"]     = "Popup Remains(sec)"
L["FPS_SHOW"]           = "FPS: Show FPS"
L["FPS_OPTION"]         = "FPS: Move Frame"
L["FPS: Anchor Point"]  = true
L["FPS: Anchor Frame"]  = true
L["FPS: Anchor Frame's Anchor Point"] = true
L["FPS: X Offset"]      = true
L["FPS: Y Offset"]      = true
L["Need reload to apply"] = true

-- koKR only
--L["INSTANCE_CHAT_KR"] = true

L["TOPLEFT"]    = true
L["TOP"]        = true
L["TOPRIGHT"]   = true
L["LEFT"]       = true
L["CENTER"]     = true
L["RIGHT"]      = true
L["BOTTOMLEFT"] = true
L["BOTTOM"]     = true
L["BOTTOMRIGHT"] = true
