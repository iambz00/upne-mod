local addonName, addon = ...
Upnemod = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
Upnemod.name = addonName
Upnemod.version = GetAddOnMetadata(addonName, "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local LibGearScore = LibStub:GetLibrary("LibGearScore.1000", true)

local CHANNEL_LIST = { "SAY", "YELL", "PARTY", "RAID", "INSTANCE", "RAID_WARNING" }
Upnemod.channelList = { }
for _, channel in ipairs(CHANNEL_LIST) do
    for keyword in L["CHANNELS_"..channel]:gmatch("([^,]+)") do
        Upnemod.channelList[keyword] = channel
    end
end
Upnemod.channelListOption = {
    SAY     = L["SAY"],
    YELL    = L["YELL"],
    PARTY   = L["PARTY"],
    RAID    = L["RAID"],
    INSTANCE = L["INSTANCE"],
    RAID_WARNING = L["RAID_WARNING"]
}

BINDING_HEADER_UPNEMOD = addonName;
BINDING_NAME_UPNEMOD_INSPECT_TARGET = L["Inspect Target"]
BINDING_NAME_UPNEMOD_INSPECT_MOUSEOVER = L["Inspect Mouseover"]

local player = UnitName"player"

Upnemod.dbDefault = {
    realm = {
        [player] = {
            announceInterrupt = true,
            announceChannel = "SAY",
            tooltip_ilvl = true,
            tooltip_auraSrc = true,
            tooltip_auraId = true,
            trade_classColor = true,
            deleteConfirm = true,
            tot_raidIcon = true,
            fixCombatText = true,
            callme = false,
            callmeSound = 568197,
            tooltip_gs = true,
            inspect_gs = true,
            vehicleUIScale = 1.0,
            vehicleUISlim = false,
            druidManaBar = false,
            fpsShow = false,
            fpsOption = false,
        }
    }
}

local playerGUID
local MSG_PREFIX = "|cff00ff00■ |cffffaa00"..addonName.."|r "
local p = function(str, ...) print(MSG_PREFIX..str, ...) end

function Upnemod:OnInitialize()
    self.wholeDb = LibStub("AceDB-3.0"):New("upneDB", self.dbDefault)
    self.db = self.wholeDb.realm[player]
    self:BuildOptions()

    playerGUID = UnitGUID"player"
    self.tooltipHandler = {}

    LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, self.optionsTable)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.name, self.name, nil)

    self:SetTooltipAura()
    self:SetAnnounceInterrupt()
    self:SetTooltipIlvl()
    self:SetTooltipGearScore()
    self:SetTradeClassColor()
    self:SetDeleteConfirm()
    self:SetToTRaidIcon()
    self:SetFixCombatText()
    self:SetCallme()
    self:SetInspectGearScore()
    self:SetVehicleUISize()
    self:SetVehicleUISlim()
    self:SetDruidManaBar()
    self:SetFramerate()

    -- Slash Commands
    SLASH_UPNE1 = "/upne"
    SLASH_UPNE2 = L["SLASH_CMD_UPNE2"]
    SLASH_UPNE3 = L["SLASH_CMD_UPNE3"]
    SlashCmdList["UPNE"] = function(msg)
        local cmd, val = msg:match("^(%S*)%s*(.*)")
        if L["SLASH_OPT_INTERRUPT"][cmd] then
            channel = channelList[val:upper()]
            if channel then
                self.db.announceInterrupt = true
                self.db.announceChannel = channel
            else
                self.db.announceInterrupt = false
            end
            self:SetAnnounceInterrupt()
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
                p(L["Calculator"]..msg.." = "..result)
            else
                SendChatMessage(L["Calculator"]..msg.." = "..result, "SAY")
            end
        else
            p(L["Calculation Error"])
        end
    else
        p(L["Calculation Error"])
    end
end

function Upnemod:SetAnnounceInterrupt()
    local result = ""
    if self.db.announceInterrupt then
        Upnemod:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        result = L["Turn On" ]..L["Announce Interruption"].." : "..self.channelListOption[self.db.announceChannel]
    else
        Upnemod:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        result = L["Turn Off"]..L["Announce Interruption"]
    end
    return result
end

function Upnemod:SetTooltipHandler(tooltip, scriptName, func)
    if func then
        local orgHandler = tooltip:GetScript(scriptName)
        if orgHandler then
            self.tooltipHandler[tooltip:GetName()] = orgHandler
            tooltip:HookScript(scriptName, func)
        else
            tooltip:SetScript(scriptName, func)
        end
    else
        local orgHandler = self.tooltipHandler[tooltip:GetName()]
        if orgHandler then
            tooltip:SetScript(scriptName, orgHandler)
        else
            tooltip:SetScript(scriptName, nil)
        end
    end
end

function Upnemod:SetTooltipIlvl()
    local function GameTooltip_Ilvl(tooltip, ...)
        local _, itemLink = tooltip:GetItem()
        if itemLink then
            local _, _, _, itemLevel, _, itemType = GetItemInfo(itemLink)
            local itemID, _ = GetItemInfoInstant(itemLink)

            if itemType == GetItemClassInfo(LE_ITEM_CLASS_WEAPON) or itemType == GetItemClassInfo(LE_ITEM_CLASS_ARMOR) then
                tooltip:AddDoubleLine(string.format("%s  |cffffffff%d|r", L["Item Level"], itemLevel), "(ID:  |cffffffff"..itemID.."|r)")
            end
        end
    end

    local function GameTooltip_Ilvl_Narrow(tooltip, ...)
        local _, itemLink = tooltip:GetItem()
        if itemLink then
            local _, _, _, itemLevel, _, itemType = GetItemInfo(itemLink)
            local itemID, _ = GetItemInfoInstant(itemLink)

            if itemType == GetItemClassInfo(LE_ITEM_CLASS_WEAPON) or itemType == GetItemClassInfo(LE_ITEM_CLASS_ARMOR) then
                tooltip:AddLine(L["Item Level"].." |cffffffff" .. itemLevel .. "|r")
                tooltip:AddLine("ID |cffffffff" .. itemID .. "|r")
            end
        end
    end

    local result = ""
    if self.db.tooltip_ilvl then
        self:SetTooltipHandler(GameTooltip, "OnTooltipSetItem", GameTooltip_Ilvl)
        self:SetTooltipHandler(ItemRefTooltip, "OnTooltipSetItem", GameTooltip_Ilvl)
        self:SetTooltipHandler(ShoppingTooltip1, "OnTooltipSetItem", GameTooltip_Ilvl_Narrow)
        self:SetTooltipHandler(ShoppingTooltip2, "OnTooltipSetItem", GameTooltip_Ilvl_Narrow)
        result =  L["Turn On" ]..L["Show [Item Lv/ID] on Tooltip"]
    else
        self:SetTooltipHandler(GameTooltip, "OnTooltipSetItem", nil)
        self:SetTooltipHandler(ItemRefTooltip, "OnTooltipSetItem", nil)
        self:SetTooltipHandler(ShoppingTooltip1, "OnTooltipSetItem", nil)
        self:SetTooltipHandler(ShoppingTooltip2, "OnTooltipSetItem", nil)
        result =  L["Turn Off"]..L["Show [Item Lv/ID] on Tooltip"]
    end
    return result
end

function Upnemod:SetTooltipGearScore()
    local function GameTooltip_GearScore(tooltip, ...)
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

    local result = ""
    if self.db.tooltip_gs then
        self:SetTooltipHandler(GameTooltip, "OnTooltipSetUnit", GameTooltip_GearScore)
        result = L["Turn On" ]..L["Show GS/ILvl on Target Tooltip"]
    else
        self:SetTooltipHandler(GameTooltip, "OnTooltipSetUnit", nil)
        result = L["Turn Off"]..L["Show GS/ILvl on Target Tooltip"]
    end
end

local function upne_AuraHandler(uaf, gt, ...)
    local _, _, _, _, _, _, src, _, _, auraId = uaf(...)	-- UnitAura or UnitBuff or UnitDebuff
    local db = Upnemod.db
    if auraId then
        local left = db.tooltip_auraId and ("ID: |cffffffff"..auraId.."|r") or " "
        local right = ""
        if db.tooltip_auraSrc and src then
            right, _ = UnitName(src)
            local _, class, _ = UnitClass(src)
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                right = string.format("|cff%.2x%.2x%.2x%s|r", classColor.r*255, classColor.g*255, classColor.b*255, right)
            end
            right = "by "..right
        end
        if db.tooltip_auraId or db.tooltip_auraSrc then
            gt:AddDoubleLine(left, right)
            gt:Show()
        end
    end
end

function Upnemod:SetTooltipAura()
    self.sua = GameTooltip.SetUnitAura
    self.sub = GameTooltip.SetUnitBuff
    self.sud = GameTooltip.SetUnitDebuff

    if self.db.tooltip_auraSrc then
        GameTooltip.SetUnitAura = function(gt, ...)
            self.sua(gt, ...)
            upne_AuraHandler(UnitAura, gt, ...)
        end
        GameTooltip.SetUnitBuff = function(gt, ...)
            self.sub(gt, ...)
            upne_AuraHandler(UnitBuff, gt, ...)
        end
        GameTooltip.SetUnitDebuff = function(gt, ...)
            self.sud(gt, ...)
            upne_AuraHandler(UnitDebuff, gt, ...)
        end
    end
end

function Upnemod:SetTradeClassColor()
    if self.db.trade_classColor then
        self:RegisterEvent("TRADE_SHOW")
    else
        self:UnregisterEvent("TRADE_SHOW")
    end
end

function Upnemod:SetDeleteConfirm()
    if self.db.deleteConfirm then
        self:RegisterEvent("DELETE_ITEM_CONFIRM")
    else
        self:UnregisterEvent("DELETE_ITEM_CONFIRM")
    end
end

--[[ http://wow.gamepedia.com/COMBAT_LOG_EVENT
  COMBAT_LOG_EVENT_UNFILTERED
    timestamp, event, hideCaster, sourceGUID, sourceName,
    sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags 
  SPELL
    spellId, spellName, spellSchool 
  _INTERRUPT
    extraSpellId, extraSpellName, extraSchool 

]]

function Upnemod:COMBAT_LOG_EVENT_UNFILTERED(...)
    local _, combatEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, destRaidFlags, 
        spellId, spellName, _, extraSpellId, extraSpellName = CombatLogGetCurrentEventInfo()
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
        if raidTarget >= 1 and raidTarget <= 8 then
            raidTarget = "{rt"..raidTarget.."}"
        else
            raidTarget = ""
        end
        -- RaidTarget end

        if (not IsInGroup()) then
            p(L["Interrupt"].." - "..raidTarget..destName..L["'s "]..(extraSpellId and GetSpellLink(extraSpellId) or extraSpellName) .."")
        else
            SendChatMessage(L["Interrupt"].." - "..raidTarget..destName..L["'s "]..(extraSpellId and GetSpellLink(extraSpellId) or extraSpellName), self.db.announceChannel)
        end
    end
end

--[[
    itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
    itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent
    = GetItemInfo(itemID or "itemString" or "itemName" or "itemLink") 

    itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID
    = GetItemInfoInstant(itemID or "itemString" or "itemName" or "itemLink") 
]]

function Upnemod:TRADE_SHOW(...)
    TradeFrameRecipientNameText:SetTextColor(RAID_CLASS_COLORS[select(2,UnitClass("npc"))]:GetRGBA())
end

function Upnemod:DELETE_ITEM_CONFIRM(...)
    -- DELETE_CONFIRM_STRING is Empty.. why?
    DELETE_CONFIRM_STRING = DELETE_CONFIRM_STRING or DELETE_GOOD_ITEM:match("\"([^\"]+)\"")
    StaticPopup1EditBox:SetText(DELETE_CONFIRM_STRING)
    --StaticPopup1Button1:Enable()
end

function Upnemod:SetToTRaidIcon()
    if self.db.tot_raidIcon then
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
        --hooksecurefunc("TargetofTarget_Update",upne_TargetofTarget_Update)
        hooksecurefunc("UnitFrame_OnEvent",upne_TargetofTarget_Update)
    end
end

function upne_TargetofTarget_Update(self, elapsed)
    SetRaidTargetIconTexture(TargetFrameToT.raidTargetIcon, GetRaidTargetIndex("targettarget") or 0)
    SetRaidTargetIconTexture(FocusFrameToT.raidTargetIcon, GetRaidTargetIndex("focustarget") or 0)
end

function Upnemod:SetInspectGearScore()
    local result = ""
    if self.db.inspect_gs then
        self:RegisterEvent("INSPECT_READY")
        LibGearScore.RegisterCallback(self, "LibGearScore_Update")
        result =  L["Turn On" ]..L["Show GearScore on Inspection"]
    else
        self:RegisterEvent("INSPECT_READY")
        if self.inspectGearScore then
            self.inspectGearScore:Hide()
        end
        result =  L["Turn Off"]..L["Show GearScore on Inspection"]
    end
end

function Upnemod:LibGearScore_Update(event, guid, gearScore)
    if self.inspectingGUID and guid and self.inspectGearScore and InspectModelFrame then
        if gearScore then
            self.inspectGearScore:SetTextColor((gearScore.Color or CreateColor(0.62, 0.62, 0.62)):GetRGB())
            self.inspectGearScore:SetText((gearScore.GearScore or 0).."\n|cffffffff"..(gearScore.AvgItemLevel or 0).."|r")
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

function Upnemod:SetFixCombatText()
    if self.db.fixCombatText then
        C_Timer.NewTicker(5, function()
            if GetCVar("enableFloatingCombatText") ~= "1" then
                SetCVar("enableFloatingCombatText", 1)
                p(L["Combat Message Enabled"])
            end
        end, 4)
    end
end

function Upnemod:SetCallme()
    local result = ""
    if self.db.callme then
        self:RegisterEvent("CHAT_MSG_CHANNEL"              , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_GUILD"                , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT"        , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER" , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_OFFICER"              , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_PARTY"                , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_PARTY_LEADER"         , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_RAID"                 , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_RAID_LEADER"          , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_RAID_WARNING"         , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_SAY"                  , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_WHISPER"              , "OnChatMsg")
        self:RegisterEvent("CHAT_MSG_YELL"                 , "OnChatMsg")
        result = L["Turn On" ]..L["Alarm when Someone calls My Name"]
    else
        self:UnregisterEvent("CHAT_MSG_CHANNEL"             )
        self:UnregisterEvent("CHAT_MSG_GUILD"               )
        self:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT"       )
        self:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
        self:UnregisterEvent("CHAT_MSG_OFFICER"             )
        self:UnregisterEvent("CHAT_MSG_PARTY"               )
        self:UnregisterEvent("CHAT_MSG_PARTY_LEADER"        )
        self:UnregisterEvent("CHAT_MSG_RAID"                )
        self:UnregisterEvent("CHAT_MSG_RAID_LEADER"         )
        self:UnregisterEvent("CHAT_MSG_RAID_WARNING"        )
        self:UnregisterEvent("CHAT_MSG_SAY"                 )
        self:UnregisterEvent("CHAT_MSG_WHISPER"             )
        self:UnregisterEvent("CHAT_MSG_YELL"                )
        result = L["Turn Off"]..L["Alarm when Someone calls My Name"]
    end
end

function Upnemod:OnChatMsg(event, msg, author)
    local name = author and author:match("^([^-]*)-") or ""
    if msg:match(player) and (name ~= player) then
        PlaySoundFile(self.db.callmeSound)
    end
end

function Upnemod:SetVehicleUISize()
    OverrideActionBar:SetScale(self.db.vehicleUIScale or 1.0)
end

function Upnemod:SetVehicleUISlim()
    if self.db.vehicleUISlim then
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

function Upnemod:SetDruidManaBar()
    if self.db.druidManaBar then
        PlayerFrameAlternateManaBar:ClearAllPoints()
        PlayerFrameAlternateManaBar:SetPoint("TOPLEFT", PlayerFrameManaBar, "BOTTOMLEFT", 0, -2)
        PlayerFrameAlternateManaBar:SetPoint("TOPRIGHT", PlayerFrameManaBar, "BOTTOMRIGHT", 0, -2)
        ShowTextStatusBarText(PlayerFrameAlternateManaBar)
        PlayerFrameAlternateManaBarText:SetScale(0.7)
        PlayerFrameAlternateManaBarBorder:Hide()
    end
end

function Upnemod:SetFramerate()
    if not self.db.fpsAnchorFrame then
        local anchor
        self.db.fpsAnchor, anchor, self.db.fpsAnchorFrameAnchor, self.db.fpsOffsetX, self.db.fpsOffsetY = FramerateLabel:GetPoint()
        self.db.fpsAnchorFrame = anchor:GetName()
    end
    if self.db.fpsShow then
        if not FramerateLabel:IsShown() then
            ToggleFramerate()
        end
    end

    if self.db.fpsOption then
        FramerateLabel:ClearAllPoints()
        FramerateText:ClearAllPoints()
        FramerateLabel:SetPoint(self.db.fpsAnchor, self.db.fpsAnchorFrame, self.db.fpsAnchorFrameAnchor, self.db.fpsOffsetX, self.db.fpsOffsetY)
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
        set = function(info, value) self.db[info[#info]] = value end,
        args = {
            announceInterrupt = {
                name = L["Announce Interruption"],
                type = "toggle",
                order = 101,
                set = function(info, value) self.db[info[#info]] = value
                        p(self:SetAnnounceInterrupt()) end,
            },
            announceChannel = {
                name = L["Announce Interruption: Channel"],
                type = "select",
                values = self.channelListOption,
                order = 102,
                set = function(info, value) self.db[info[#info]] = value
                        p(self:SetAnnounceInterrupt()) end,
            },
            tooltip_ilvl = {
                name = L["Show [Item Lv/ID] on Tooltip"],
                type = "toggle",
                order = 201,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value
                        p(self:SetTooltipIlvl()) end,
            },
            tooltip_gs = {
                name = L["Show GS/ILvl on Target Tooltip"],
                type = "toggle",
                order = 251,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value
                        p(self:SetTooltipGearScore()) end,
            },
            tooltip_auraId = {
                name = L["Show [Spell ID] on Aura Tooltip"],
                type = "toggle",
                order = 301,
                width = "full",
            },
            tooltip_auraSrc = {
                name = L["Show [Caster Name] on Aura Tooltip"],
                type = "toggle",
                order = 302,
                width = "full",
            },
            trade_classColor = {
                name = L["Show Target Class Color on Trade Window"],
                type = "toggle",
                order = 401,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value
                        self:SetTradeClassColor() end,
            },
            deleteConfirm = {
                name = L["Automatically Input DELETE CONFIRM String"],
                type = "toggle",
                order = 411,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value
                        self:SetDeleteConfirm() end,
            },
            tot_raidIcon = {
                name = L["Show Raid Icon on ToT/ToF"],
                type = "toggle",
                order = 501,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value
                        self:SetToTRaidIcon() end,
            },
            inspect_gs = {
                name = L["Show GearScore on Inspection"],
                type = "toggle",
                order = 551,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value
                        self:SetInspectGearScore() end,
            },
            fixCombatText = {
                name = L["Fix Combat Message ON"],
                type = "toggle",
                order = 601,
                width = "full",
                desc = L["Description_FixCombatMessage"],
                set = function(info, value) self.db[info[#info]] = value
                        self:SetFixCombatText() end,
            },
            callme = {
                name = L["Alarm when Someone calls My Name"],
                type = "toggle",
                order = 701,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value
                        self:SetCallme() end,
            },
            callmeSound = {
                name = L["Alarm Sound"],
                type = "input",
                order = 711,
            },
            callmePlay = {
                name = L["Play"],
                type = "execute",
                value = self.db.callmePlay,
                order = 721,
                func = function() PlaySoundFile(self.db.callmeSound) end
            },
            vehicleUIScale = {
                name = L["Zoom Vehicle UI Size"],
                type = "range",
                order = 801,
                width = "full",
                min = 0.2,
                max = 1.2,
                step = 0.01,
                isPercent = true,
                set = function(info, value) self.db[info[#info]] = value
                        self:SetVehicleUISize() end,
            },
            vehicleUISlim = {
                name = L["Hide Vehicle UI Background"],
                type = "toggle",
                order = 802,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value
                        self:SetVehicleUISlim() end,
            },
            druidManaBar = {
                name = L["Enhance Druid ManaBar"],
                type = "toggle",
                descStyle = "inline",
                desc = L["Description_DruidManaBar"],
                order = 901,
                width = "full",
                set = function(info, value) self.db[info[#info]] = value 
                        self:SetDruidManaBar() end,
            },
            fpsShow = {
                name = L["FPS: Show FPS"],
                type = "toggle",
                order = 1001,
                set = function(info, value) self.db[info[#info]] = value self:SetFramerate() end,
            },
            fpsOption = {
                name = L["FPS: Move Frame"],
                type = "toggle",
                order = 1002,
                set = function(info, value) self.db[info[#info]] = value self:SetFramerate() end,
            },
            fpsAnchor = {
                name = L["FPS: Anchor Point"],
                type = "select",
                style = "dropdown",
                values = anchorPoints,
                order = 1010,
                set = function(info, value) self.db[info[#info]] = value self:SetFramerate() end,
            },
            fpsAnchorFrame = {
                name = L["FPS: Anchor Frame"],
                type = "input",
                order = 1020,
                set = function(info, value) self.db[info[#info]] = value self:SetFramerate() end,
            },
            fpsAnchorFrameAnchor = {
                name = L["FPS: Anchor Frame's Anchor Point"],
                type = "select",
                style = "dropdown",
                values = anchorPoints,
                order = 1030,
                set = function(info, value) self.db[info[#info]] = value self:SetFramerate() end,
            },
            fpsOffsetX = {
                name = L["X Offset"],
                type = "range",
                softMin = -200,
                softMax = 200,
                bigStep = 10,
                order = 1040,
                set = function(info, value) self.db[info[#info]] = value self:SetFramerate() end,
            },
            fpsOffsetY = {
                name = L["Y Offset"],
                type = "range",
                softMin = -200,
                softMax = 200,
                bigStep = 10,
                order = 1050,
                set = function(info, value) self.db[info[#info]] = value self:SetFramerate() end,
            },
        }
    }
end
