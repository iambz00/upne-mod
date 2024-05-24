local addonName, _ = ...
Upnemod = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
Upnemod.name = addonName
Upnemod.version = C_AddOns.GetAddOnMetadata(addonName, "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local LibGearScore = LibStub:GetLibrary("LibGearScore.1000", true)

Upnemod.channelList = { }
for ch, channel_text in pairs(L["CHANNELS_LIST"]) do
    for cmd in channel_text:gmatch("([^,]+)") do
        Upnemod.channelList[cmd] = ch
    end
end

Upnemod.channelListOption = {
    SAY     = L["SAY"],
    YELL    = L["YELL"],
    PARTY   = L["PARTY"],
    RAID    = L["RAID"],
    INSTANCE_CHAT = L["INSTANCE"],
    RAID_WARNING = L["RAID_WARNING"]
}

BINDING_HEADER_UPNEMOD = addonName;
BINDING_NAME_UPNEMOD_INSPECT_TARGET = L["Inspect Target"]
BINDING_NAME_UPNEMOD_INSPECT_MOUSEOVER = L["Inspect Mouseover"]

local player = UnitName"player"

Upnemod.dbDefault = {
    realm = {
        [player] = {
            ANNOUNCE_INTERRUPT  = true,
            ANNOUNCE_CHANNEL    = "SAY",
            TOOLTIP_AURA_SRC    = true,
            TOOLTIP_AURA_ID     = true,
            TRADE_CLASS_COLOR   = true,
            DELETE_CONFIRM      = true,
            RAIDICON_TOT        = true,
            FIX_COMBATTEXT      = true,
            CALLME_ON           = false,
            CALLME_SOUND        = 568197,
            TOOLTIP_UNIT_GS     = true,
            INSPECT_GS          = true,
            VEHICLEUI_SCALE     = 0.6,
            VEHICLEUI_HIDEBG    = true,
            DRUID_MANABAR       = false,
            INSTANCE_CHAT_KR    = true,
            FPS_SHOW            = false,
            FPS_OPTION          = false,
        }
    }
}

local playerGUID
local MSG_PREFIX = "|cff00ff00■ |cffffaa00"..addonName.."|r "
local p = function(str, ...) print(MSG_PREFIX.."|cffdddddd"..tostring(str).."|r", ...) end

Upnemod.Set = { }
local normalize = {
    announceInterrupt   = "ANNOUNCE_INTERRUPT",
    announceChannel     = "ANNOUNCE_CHANNEL",
    tooltip_auraSrc     = "TOOLTIP_AURA_SRC",
    tooltip_auraId      = "TOOLTIP_AURA_ID",
    trade_classColor    = "TRADE_CLASS_COLOR",
    deleteConfirm       = "DELETE_CONFIRM",
    tot_raidIcon        = "RAIDICON_TOT",
    fixCombatText       = "FIX_COMBATTEXT",
    callme              = "CALLME_ON",
    callmeSound         = "CALLME_SOUND",
    tooltip_gs          = "TOOLTIP_UNIT_GS",
    inspect_gs          = "INSPECT_GS",
    vehicleUIScale      = "VEHICLEUI_SCALE",
    vehicleUISlim       = "VEHICLEUI_HIDEBG",
    druidManaBar        = "DRUID_MANABAR",
    fpsShow             = "FPS_SHOW",
    fpsOption           = "FPS_OPTION",
    fpsAnchor           = "FPS_Anchor",
    fpsAnchorFrame      = "FPS_AnchorFrame",
    fpsAnchorFrameAnchor = "FPS_AnchorFrameAnchor",
    fpsOffsetX          = "FPS_OffsetX",
    fpsOffsetY          = "FPS_OffsetY",
    tooltip_ilvl        = false,
}

local function upne_Tooltiphandler_GearScore(tooltip, ...)
    local _, unitID = tooltip:GetUnit()
    if unitID then
        local guid, gearScore = LibGearScore:GetScore(unitID)
        if gearScore then
            local gs = gearScore.GearScore or 0
            if tonumber(gs) > 0 then
                gs = gearScore.Color and gearScore.Color:WrapTextInColorCode(gs) or gs
                local ilvl = gearScore.AvgItemLevel or 0
                --tooltip:AddDoubleLine(gs, ilvl)
                tooltip:AddLine(gs .."|cff9d9d9d/|r|cffffffff".. ilvl.."|r")
            end
        end
    end
end

local function upne_AuraHandler(auraFunc, gt, ...)
    local _, _, _, _, _, _, src, _, _, auraId = auraFunc(...)	-- UnitAura or UnitBuff or UnitDebuff
    local db = Upnemod.db
    if auraId then
        local left = db.TOOLTIP_AURA_ID and ("ID: |cffffffff"..auraId.."|r") or " "
        local right = ""
        if db.TOOLTIP_AURA_SRC and src then
            right, _ = UnitName(src)
            local _, class, _ = UnitClass(src)
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                right = string.format("|cff%.2x%.2x%.2x%s|r", classColor.r*255, classColor.g*255, classColor.b*255, right)
            end
            right = "by "..right
        end
        if db.TOOLTIP_AURA_ID or db.TOOLTIP_AURA_SRC then
            gt:AddDoubleLine(left, right)
            gt:Show()
        end
    end
end

function Upnemod:OnInitialize()
    self.wholeDb = LibStub("AceDB-3.0"):New("upneDB", self.dbDefault)
    self.db = self.wholeDb.realm[player]

    -- Convert DB
    local is_old_options = false
    for _, db in pairs(self.wholeDb.realm) do
        for k, _ in pairs(normalize) do
            if db[k] then
                is_old_options = true
            end
        end
    end
    if is_old_options then
        for _, db in pairs(self.wholeDb.realm) do
            for k, v in pairs(normalize) do
                if v then
                    db[v] = db[k]
                end
                db[k] = nil
            end
        end
    end

    self.wholeDb.global.version = self.version

    self:BuildOptions()

    playerGUID = UnitGUID("player")

    LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, self.optionsTable)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.name, self.name, nil)

    -- Hooks and Setups
    ---- GearScore on Tooltip
    GameTooltip:HookScript("OnTooltipSetUnit", upne_Tooltiphandler_GearScore)
    ---- Spell Caster/ID on Aura/Buff/Debuff Tooltip
    hooksecurefunc(GameTooltip, "SetUnitAura", function(...) upne_AuraHandler(UnitAura, ...) end)
    hooksecurefunc(GameTooltip, "SetUnitBuff", function(...) upne_AuraHandler(UnitBuff, ...) end)
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(...) upne_AuraHandler(UnitDebuff, ...) end)
    ---- Raid Target Icon on TargetOfTarget/TargetOfFocus
    self:SetupToTRaidIcon()
    self:TurnOnCombatText()

    -- Apply options
    for _, v in pairs({"ANNOUNCE_INTERRUPT", "TRADE_CLASS_COLOR", "DELETE_CONFIRM", "CALLME_ON", "INSPECT_GS",
     "VEHICLEUI_SCALE", "VEHICLEUI_HIDEBG", "DRUID_MANABAR", "INSTANCE_CHAT_KR", "FPS_SHOW", "FPS_OPTION"})
        do self.Set[v](_, self.db[v]) end

    -- Slash Commands
    SLASH_UPNE1 = "/upne"
    SLASH_UPNE2 = L["SLASH_CMD_UPNE2"]
    SLASH_UPNE3 = L["SLASH_CMD_UPNE3"]
    SlashCmdList["UPNE"] = function(msg)
        local cmd, val = msg:match("^(%S*)%s*(.*)")
        if L["SLASH_OPT_INTERRUPT"][cmd] then
            local channel = Upnemod.channelList[val:upper()]
            if channel then
                self.db.ANNOUNCE_INTERRUPT = true
                self.db.ANNOUNCE_CHANNEL = channel
            else
                self.db.ANNOUNCE_INTERRUPT = false
            end
            self.Set:ANNOUNCE_INTERRUPT()
        else
            InterfaceOptionsFrame_OpenToCategory(self.name)
            InterfaceOptionsFrame_OpenToCategory(self.name)
        end
    end
    SLASH_CALC1 = "/calc"
    SLASH_CALC2 = L["SLASH_CMD_CALC2"]
    SlashCmdList["CALC"] = function(msg) Upnemod:Calc(msg) end
    SLASH_CALCS1 = "/calc2"
    SLASH_CALCS2 = L["SLASH_CMD_CALC_SILENT2"]
    SlashCmdList["CALCS"] = function(msg) Upnemod:Calc(msg, true) end
end

function Upnemod:Calc(msg, silent)
    local func, err = loadstring("return "..msg)
    if func then
        local ok, result = pcall(func)
        if ok then
            if silent then
                p(L["Calculator"].." : "..msg.." = "..result)
            else
                SendChatMessage(L["Calculator"].." : |cffffffff"..msg.." = "..result.."|r", "SAY")
            end
        else
            p(L["Calculation Error"])
        end
    else
        p(L["Calculation Error"])
    end
end

function Upnemod.Set:ANNOUNCE_INTERRUPT(on)
    if on then
        Upnemod:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        return Upnemod.channelListOption[Upnemod.db.ANNOUNCE_CHANNEL]
    else
        Upnemod:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        return ""
    end
end
function Upnemod.Set:ANNOUNCE_CHANNEL() end

function Upnemod:COMBAT_LOG_EVENT_UNFILTERED(...)
    --local _, combatEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, destRaidFlags, 
    --    spellId, spellName, _, extraSpellId, extraSpellName = CombatLogGetCurrentEventInfo()
    local _, combatEvent, _, sourceGUID, _, _, _, _, destName, _, destRaidFlags, 
        _, _, _, extraSpellId, extraSpellName = CombatLogGetCurrentEventInfo()
    if combatEvent == "SPELL_INTERRUPT" and sourceGUID == playerGUID then
        if not destName then destName = L["No Target"] end

        -- Resolving RaidTarget
        -- COMBATLOG_OBJECT_RAIDTARGET_MASK = 0x000000FF in FrameXML/Constants.lua
        local raidTarget = bit.band(destRaidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
        for n=1, 8 do
            if raidTarget == 1 then
                raidTarget = n
                break
            end
            -- raidTarget = raidTarget >> 1
            raidTarget = raidTarget / 2
        end
        local rt = ""
        if raidTarget >= 1 and raidTarget <= 8 then
            rt = "{rt"..raidTarget.."}"
        end
        -- RaidTarget end
        local spellLink = extraSpellId and GetSpellLink(extraSpellId) or "["..extraSpellName.."]"

        if (not IsInGroup()) then
            p(L["Interrupt"].." - "..rt..destName.." "..spellLink)
        else
            local channel = self.db.ANNOUNCE_CHANNEL
            if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
                if channel == "PARTY" or channel == "RAID" or channel == "RAID_WARNING" then
                    channel = "INSTANCE_CHAT"
                end
            end
            SendChatMessage(L["Interrupt"].." - "..rt..destName.." "..spellLink, channel)
        end
    end
end

function Upnemod.Set:TOOLTIP_UNIT_GS() return "" end
function Upnemod.Set:TOOLTIP_AURA_SRC() return "" end
function Upnemod.Set:TOOLTIP_AURA_ID() return "" end

function Upnemod.Set:TRADE_CLASS_COLOR(on)
    if on then
        Upnemod:RegisterEvent("TRADE_SHOW")
    else
        Upnemod:UnregisterEvent("TRADE_SHOW")
    end
    return ""
end

function Upnemod:TRADE_SHOW(...)
    TradeFrameRecipientNameText:SetTextColor(RAID_CLASS_COLORS[select(2,UnitClass("npc"))]:GetRGBA())
end

function Upnemod.Set:DELETE_CONFIRM(on)
    if on then
        Upnemod:RegisterEvent("DELETE_ITEM_CONFIRM")
    else
        Upnemod:UnregisterEvent("DELETE_ITEM_CONFIRM")
    end
    return ""
end

function Upnemod:DELETE_ITEM_CONFIRM(...)
    -- DELETE_CONFIRM_STRING is Empty.. why?
    DELETE_CONFIRM_STRING = DELETE_CONFIRM_STRING or DELETE_GOOD_ITEM:match("\"([^\"]+)\"")
    StaticPopup1EditBox:SetText(DELETE_CONFIRM_STRING)
    --StaticPopup1Button1:Enable()
end

function Upnemod:SetupToTRaidIcon()
    if self.db.RAIDICON_TOT then
        local t = TargetFrameToT
        if not t.raidTargetIcon then
            t.raidTargetIcon = t:CreateTexture()
            local tx = t.raidTargetIcon
            tx:SetPoint("LEFT", t, "LEFT", 8, 0)
            tx:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
            tx:SetWidth(16)
            tx:SetHeight(16)
            tx:SetDrawLayer("Artwork",0)
            tx:Show()
        end

        t = FocusFrameToT
        if not t.raidTargetIcon then
            t.raidTargetIcon = t:CreateTexture()
            local tx = t.raidTargetIcon
            tx:SetPoint("LEFT", t, "LEFT", 8, 0)
            tx:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
            tx:SetWidth(16)
            tx:SetHeight(16)
            tx:SetDrawLayer("Artwork",0)
            tx:Show()
        end
        hooksecurefunc("UnitFrame_OnEvent", function()
            SetRaidTargetIconTexture(TargetFrameToT.raidTargetIcon, GetRaidTargetIndex("targettarget") or 0)
            SetRaidTargetIconTexture(FocusFrameToT.raidTargetIcon, GetRaidTargetIndex("focustarget") or 0)
        end)
    end
end

function Upnemod.Set:INSPECT_GS(on)
    if on then
        Upnemod:RegisterEvent("INSPECT_READY")
        LibGearScore.RegisterCallback(Upnemod, "LibGearScore_Update")
    else
        Upnemod:UnregisterEvent("INSPECT_READY")
        if Upnemod.inspectGearScore then
            Upnemod.inspectGearScore:Hide()
        end
    end
    return ""
end

function Upnemod:LibGearScore_Update(event, guid, gearScore)
    if self.inspectingGUID and guid and self.inspectGearScore and InspectModelFrame then
        if gearScore then
            self.inspectGearScore:SetTextColor((gearScore.Color or CreateColor(0.62, 0.62, 0.62)):GetRGB())
            self.inspectGearScore:SetText((gearScore.GearScore or 0).."\n|cffffffff"..(gearScore.AvgItemLevel or 0).."|r")
            self.inspectGearScore:Show()
        end
    end
end

function Upnemod:INSPECT_READY(event, ...)
    if not self.inspectGearScore and InspectModelFrame then
        local text = InspectModelFrame:CreateFontString()
        text:SetPoint("TOPRIGHT")
        text:SetFontObject("GameFontNormalSmall")
        text:SetJustifyH("RIGHT")
        text:SetJustifyV("TOP")
        text:SetTextColor(1, 1, 1)
        self.inspectGearScore = text
    end

    local guid = ...
    self.inspectingGUID = guid
end

function Upnemod.Set:FIX_COMBATTEXT() return "" end

function Upnemod:TurnOnCombatText()
    if self.db.FIX_COMBATTEXT then
        C_Timer.NewTicker(5, function()
            if GetCVar("enableFloatingCombatText") ~= "1" then
                SetCVar("enableFloatingCombatText", 1)
                p(L["Combat Message Enabled"])
            end
        end, 4)
    end
end

function Upnemod.Set:CALLME_ON(on)
    if on then
        Upnemod:RegisterEvent("CHAT_MSG_CHANNEL"              , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_GUILD"                , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_INSTANCE_CHAT"        , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER" , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_OFFICER"              , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_PARTY"                , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_PARTY_LEADER"         , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_RAID"                 , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_RAID_LEADER"          , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_RAID_WARNING"         , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_SAY"                  , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_WHISPER"              , "OnCallMe")
        Upnemod:RegisterEvent("CHAT_MSG_YELL"                 , "OnCallMe")
    else
        Upnemod:UnregisterEvent("CHAT_MSG_CHANNEL"             )
        Upnemod:UnregisterEvent("CHAT_MSG_GUILD"               )
        Upnemod:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT"       )
        Upnemod:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
        Upnemod:UnregisterEvent("CHAT_MSG_OFFICER"             )
        Upnemod:UnregisterEvent("CHAT_MSG_PARTY"               )
        Upnemod:UnregisterEvent("CHAT_MSG_PARTY_LEADER"        )
        Upnemod:UnregisterEvent("CHAT_MSG_RAID"                )
        Upnemod:UnregisterEvent("CHAT_MSG_RAID_LEADER"         )
        Upnemod:UnregisterEvent("CHAT_MSG_RAID_WARNING"        )
        Upnemod:UnregisterEvent("CHAT_MSG_SAY"                 )
        Upnemod:UnregisterEvent("CHAT_MSG_WHISPER"             )
        Upnemod:UnregisterEvent("CHAT_MSG_YELL"                )
    end
    return ""
end

function Upnemod:OnCallMe(event, msg, author)
    local name = author and author:match("^([^-]*)-") or ""
    if msg:match(player) and (name ~= player) then
        PlaySoundFile(self.db.CALLME_SOUND)
    end
end

function Upnemod.Set:VEHICLEUI_SCALE(on)
    OverrideActionBar:SetScale(Upnemod.db.VEHICLEUI_SCALE or 1.0)
end

function Upnemod.Set:VEHICLEUI_HIDEBG(on)
    if on then
        OverrideActionBar.Divider1:Hide()
        OverrideActionBar.Divider2:Hide()
        OverrideActionBar.Divider3:Hide()
        OverrideActionBarEndCapL:Hide()
        OverrideActionBarEndCapR:Hide()
        OverrideActionBarBorder:Hide()
        OverrideActionBarBG:Hide()
    else
        OverrideActionBar.Divider1:Show()
        OverrideActionBar.Divider2:Show()
        OverrideActionBar.Divider3:Show()
        OverrideActionBarEndCapL:Show()
        OverrideActionBarEndCapR:Show()
        OverrideActionBarBorder:Show()
        OverrideActionBarBG:Show()
    end
end

function Upnemod.Set:DRUID_MANABAR(on)
    if on then
        PlayerFrameAlternateManaBar:ClearAllPoints()
        PlayerFrameAlternateManaBar:SetPoint("TOPLEFT", PlayerFrameManaBar, "BOTTOMLEFT", 0, -2)
        PlayerFrameAlternateManaBar:SetPoint("TOPRIGHT", PlayerFrameManaBar, "BOTTOMRIGHT", 0, -2)
        ShowTextStatusBarText(PlayerFrameAlternateManaBar)
        PlayerFrameAlternateManaBarText:SetScale(0.7)
        PlayerFrameAlternateManaBarBorder:Hide()
        return ""
    else
        return L["Need reload to apply"]
    end

end

function Upnemod.Set:INSTANCE_CHAT_KR(on)
    if GetLocale() == "koKR" then
        if on then
            Upnemod.SLASH_INVITE4_OLD = SLASH_INVITE4
            Upnemod.SLASH_INSTANCE_CHAT2_OLD = SLASH_INSTANCE_CHAT2
            SLASH_INSTANCE_CHAT2 = SLASH_INVITE4
            SLASH_INVITE4 = SLASH_INVITE3
        else
            SLASH_INVITE4 = Upnemod.SLASH_INVITE4_OLD or SLASH_INVITE4
            SLASH_INSTANCE_CHAT2 = Upnemod.SLASH_INSTANCE_CHAT2_OLD or SLASH_INSTANCE_CHAT2
        end
    end
    return ""
end

function Upnemod.Set:FPS_SHOW(on)
    if on then
        if not FramerateLabel:IsShown() then
            ToggleFramerate()
            Upnemod:RefreshFramerate()
        end
    else
        if FramerateLabel:IsShown() then
            ToggleFramerate()
        end
    end
    return ""
end

function Upnemod.Set:FPS_OPTION() Upnemod:RefreshFramerate() return "" end
function Upnemod.Set:FPS_Anchor() Upnemod:RefreshFramerate() end
function Upnemod.Set:FPS_AnchorFrame() Upnemod:RefreshFramerate() end
function Upnemod.Set:FPS_AnchorFrameAnchor() Upnemod:RefreshFramerate() end
function Upnemod.Set:FPS_OffsetX() Upnemod:RefreshFramerate() end
function Upnemod.Set:FPS_OffsetY() Upnemod:RefreshFramerate() end

function Upnemod:RefreshFramerate()
    if not self.db.FPS_AnchorFrame then
        local anchor
        self.db.FPS_Anchor, anchor, self.db.FPS_AnchorFrameAnchor, self.db.FPS_OffsetX, self.db.FPS_OffsetY = FramerateLabel:GetPoint()
        self.db.FPS_AnchorFrame = anchor:GetName()
    end

    if self.db.FPS_OPTION then
        FramerateLabel:ClearAllPoints()
        FramerateText:ClearAllPoints()
        FramerateLabel:SetPoint(self.db.FPS_Anchor, self.db.FPS_AnchorFrame, self.db.FPS_AnchorFrameAnchor, self.db.FPS_OffsetX, self.db.FPS_OffsetY)
        FramerateText:SetPoint("LEFT",FramerateLabel,"RIGHT")
    end
end

function Upnemod:BuildOptions()
    local anchorPoints = {
        TOPLEFT     = L["TOPLEFT"]    ,
        TOP         = L["TOP"]        ,
        TOPRIGHT    = L["TOPRIGHT"]   ,
        LEFT        = L["LEFT"]       ,
        CENTER      = L["CENTER"]     ,
        RIGHT       = L["RIGHT"]      ,
        BOTTOMLEFT  = L["BOTTOMLEFT"] ,
        BOTTOM      = L["BOTTOM"]     ,
        BOTTOMRIGHT = L["BOTTOMRIGHT"],
    }

    self.optionsTable = {
        name = self.name,
        handler = self,
        type = "group",
        get = function(info) return self.db[info[#info]] end,
        set = function(info, value)
            local action = info[#info] 
            self.db[action] = value
            if self.Set[action] then
                local message = self.Set[action](_, value)
                if message and L[action] then
                    p((value and L["Turn On" ] or L["Turn Off"])..L[action]..message)
                end
            end
        end,
        args = {
            ANNOUNCE_INTERRUPT = {
                name = L["ANNOUNCE_INTERRUPT"],
                type = "toggle",
                order = 101,
            },
            ANNOUNCE_CHANNEL = {
                name = L["ANNOUNCE_CHANNEL"],
                type = "select",
                values = self.channelListOption,
                order = 102,
            },
            INSPECT_GS = {
                name = L["INSPECT_GS"],
                type = "toggle",
                order = 151,
                width = "full",
            },
            TOOLTIP_UNIT_GS = {
                name = L["TOOLTIP_UNIT_GS"],
                type = "toggle",
                order = 152,
                width = "full",
            },
            TOOLTIP_AURA_SRC = {
                name = L["TOOLTIP_AURA_SRC"],
                type = "toggle",
                order = 301,
                width = "full",
            },
            TOOLTIP_AURA_ID = {
                name = L["TOOLTIP_AURA_ID"],
                type = "toggle",
                order = 302,
                width = "full",
            },
            TRADE_CLASS_COLOR = {
                name = L["TRADE_CLASS_COLOR"],
                type = "toggle",
                order = 401,
                width = "full",
            },
            DELETE_CONFIRM = {
                name = L["DELETE_CONFIRM"],
                type = "toggle",
                order = 411,
                width = "full",
            },
            RAIDICON_TOT = {
                name = L["RAIDICON_TOT"],
                type = "toggle",
                order = 501,
                width = "full",
            },
            FIX_COMBATTEXT = {
                name = L["FIX_COMBATTEXT"],
                type = "toggle",
                order = 601,
                width = "full",
                desc = L["Description_FixCombatMessage"],
            },
            CALLME_ON = {
                name = L["CALLME_ON"],
                type = "toggle",
                order = 701,
                width = "full",
            },
            CALLME_SOUND = {
                name = L["CALLME_SOUND"],
                type = "input",
                order = 711,
            },
            callmePlay = {
                name = L["Play"],
                type = "execute",
                order = 721,
                func = function() PlaySoundFile(self.db.CALLME_SOUND) end
            },
            VEHICLEUI_SCALE = {
                name = L["VEHICLEUI_SCALE"],
                type = "range",
                order = 801,
                width = "full",
                min = 0.2,
                max = 1.2,
                step = 0.01,
                isPercent = true,
            },
            VEHICLEUI_HIDEBG = {
                name = L["VEHICLEUI_HIDEBG"],
                type = "toggle",
                order = 802,
                width = "full",
            },
            DRUID_MANABAR = {
                name = L["DRUID_MANABAR"],
                type = "toggle",
                descStyle = "inline",
                desc = L["Description_DruidManaBar"],
                order = 901,
                width = "full",
            },
            -- INSTANCE_CHAT_KR = {},
            FPS_SHOW = {
                name = L["FPS_SHOW"],
                type = "toggle",
                order = 1001,
            },
            FPS_OPTION = {
                name = L["FPS_OPTION"],
                type = "toggle",
                order = 1002,
            },
            FPS_Anchor = {
                name = L["FPS: Anchor Point"],
                type = "select",
                style = "dropdown",
                values = anchorPoints,
                order = 1010,
            },
            FPS_AnchorFrame = {
                name = L["FPS: Anchor Frame"],
                type = "input",
                order = 1020,
            },
            FPS_AnchorFrameAnchor = {
                name = L["FPS: Anchor Frame's Anchor Point"],
                type = "select",
                style = "dropdown",
                values = anchorPoints,
                order = 1030,
            },
            FPS_OffsetX = {
                name = L["FPS: X Offset"],
                type = "range",
                softMin = -200,
                softMax = 200,
                bigStep = 10,
                order = 1040,
            },
            FPS_OffsetY = {
                name = L["FPS: Y Offset"],
                type = "range",
                softMin = -200,
                softMax = 200,
                bigStep = 10,
                order = 1050,
            },
        }
    }
    if GetLocale() == "koKR" then
        self.optionsTable.args.INSTANCE_CHAT_KR = {
            name = L["INSTANCE_CHAT_KR"],
            type = "toggle",
            order = 991,
            width = "full",
        }
    end
end
