﻿local addonName, addon = ...
local Upne = CreateFrame("Frame", "Upne")
_G["Upne"] = Upne
Upne:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local channelList = {
	["SAY"] = "SAY",	["S"] = "SAY",	["ㄴ"] = "SAY",	["일반"] = "SAY",
	["YELL"] = "YELL",	["Y"] = "YELL",	["ㅛ"] = "YELL",	["외침"] = "YELL",
	["PARTY"] = "PARTY",	["P"] = "PARTY",	["ㅔ"] = "PARTY",	["파티"] = "PARTY",
	["RAID"] = "RAID",	["R"] = "RAID",	["ㄱ"] = "RAID",	["공"] = "RAID",
	["INSTANCE"] = "INSTANCE",	["I"] = "INSTANCE",	["ㅑ"] = "INSTANCE",
	["RAID_WARNING"] = "RAID_WARNING",	["RW"] = "RAID_WARNING",	["경보"] = "RAID_WARNING",
}

Upne:RegisterEvent("PLAYER_LOGIN")
Upne.handler = {}

function Upne:PLAYER_LOGIN(self, arg1, ...)
	-- Init DB
	if not upneDB then
		upneDB = {}
		upneDB.version = "20200414"
		upneDB.interrupt = true
		upneDB.interruptChannel = "PARTY"
		upneDB.tooltipItemLevel = true
		upneDB.tooltipSrc = true
		upneDB.setShamanColor = true
		--upneDB.tooltipItemID = true
	end
	Upne.upneDB = upneDB

	-- Setting config panel
	upne_ConfigPanel()

	-- Slash Commands
	SLASH_UPNE1 = "/ㅇㅇ"
	SLASH_UPNE2 = "/upne"
	SlashCmdList["UPNE"] = function(msg)
		local cmd, val = msg:match("^(%S*)%s*(.*)")
		if cmd == "차단" or cmd == "int" or cmd == "interrupt" then
			channel = channelList[val:upper()]
			if channel then
				upneDB.interrupt = true
				upneDB.interruptChannel = channel
			else
				upneDB.interrupt = false
			end
			upne_InterruptAlarm()
		else
			InterfaceOptionsFrame_OpenToCategory("upneMod")
			InterfaceOptionsFrame_OpenToCategory("upneMod")
		end
	end
	SLASH_CALC1 = "/계산"
	SLASH_CALC2 = "/calc"
	SlashCmdList["CALC"] = function(msg)
		local origHandler = geterrorhandler()
		seterrorhandler(function (msg)
			print("잘못된 계산식입니다.")
		end)
		msg = "local answer="..msg..";if answer then SendChatMessage('계산: "..msg.."','SAY');SendChatMessage('결과: '..answer,'SAY') end"
		RunScript(msg)
		seterrorhandler(origHandler)
	end

	-- Init handlers
	if upneDB.interrupt then
		Upne:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end

	if upneDB.tooltipItemLevel then
		upne_SetTooltipHandler(GameTooltip, GameTooltip_Add_Item_Level)
		upne_SetTooltipHandler(ItemRefTooltip, GameTooltip_Add_Item_Level)
		upne_SetTooltipHandler(ShoppingTooltip1, GameTooltip_Add_Item_Level_Short)
		upne_SetTooltipHandler(ShoppingTooltip2, GameTooltip_Add_Item_Level_Short)
	end

	if Upne.upneDB.setShamanColor then
		upne_SetShamanColor(0.0, 0.44, 0.87)
	else
		upne_SetShamanColor(0.96, 0.55, 0.73)
	end

	Upne.sua = GameTooltip.SetUnitAura
	Upne.sub = GameTooltip.SetUnitBuff
	Upne.sud = GameTooltip.SetUnitDebuff

	if Upne.upneDB.tooltipSrc then
		upne_SetAuraSrc()
	end

	Upne:RegisterEvent("TRADE_SHOW")
	--Upne:RegisterEvent("TRADE_UPDATE")
end

function upne_InterruptAlarm()
	if upneDB.interrupt then
		Upne:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		print("■ 차단 알림 - " .. upneDB.interruptChannel)
	else
		Upne:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		print("■ 차단 알림 해제")
	end
end

function upne_SetTooltipHandler(tooltip, func)
	if func then
		orig_handler = tooltip:GetScript("OnTooltipSetItem")
		if orig_handler then
			Upne.handler[tooltip:GetName()] = orig_handler
			tooltip:HookScript("OnTooltipSetItem", func)
		else
			tooltip:SetScript("OnTooltipSetItem", func)
		end
	else
		orig_handler = Upne.handler[tooltip:GetName()]
		if orig_handler then
			tooltip:SetScript("OnTooltipSetItem", orig_handler)
		else
			tooltip:SetScript("OnTooltipSetItem", nil)
		end
	end
end
--[[
function upne_SetAuraSrc()
	GameTooltip.SetUnitAura = function(self, ...)
		Upne.sua(self, ...)
		local _,_,_,_,_,_,src = UnitAura(...)
		local name = "Unknown"
		if src then
			name, _ = UnitName(src)
			local _, class, _ = UnitClass(src)
			local classColor = RAID_CLASS_COLORS[class]
			if classColor then
				name = string.format("|cff%.2x%.2x%.2x%s|r", classColor.r*255, classColor.g*255, classColor.b*255, name)
			end
		end
		self:AddDoubleLine(" ", "by "..name)
		self:Show()
	end
end
]]

function upne_SetAuraSrc()
	GameTooltip.SetUnitAura = function(gt, ...)
		Upne.sua(gt, ...)
		upne_AuraHandler(UnitAura, gt, ...)
	end
	GameTooltip.SetUnitBuff = function(gt, ...)
		Upne.sub(gt, ...)
		upne_AuraHandler(UnitBuff, gt, ...)
	end
	GameTooltip.SetUnitDebuff = function(gt, ...)
		Upne.sud(gt, ...)
		upne_AuraHandler(UnitDebuff, gt, ...)
	end
end

function upne_AuraHandler(uaf, gt, ...)
	local _, _, _, _, _, _, src = uaf(...)	-- UnitAura or UnitBuff or UnitDebuff
	if src then
		local name, _ = UnitName(src)
		local _, class, _ = UnitClass(src)
		local classColor = RAID_CLASS_COLORS[class]
		if classColor then
			name = string.format("|cff%.2x%.2x%.2x%s|r", classColor.r*255, classColor.g*255, classColor.b*255, name)
		end
		gt:AddDoubleLine(" ", "by "..name)
		gt:Show()
	end
end

function upne_UnSetAuraSrc()
	GameTooltip.SetUnitAura = Upne.sua
	GameTooltip.SetUnitBuff = Upne.sub
	GameTooltip.SetUnitDebuff = Upne.sud
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

function Upne:COMBAT_LOG_EVENT_UNFILTERED(...)
	local _, combatEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, destRaidFlags, 
		spellId, spellName, _, extraSpellId, extraSpellName = CombatLogGetCurrentEventInfo()
	if combatEvent == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player") then
		if not destName then destName = "대상없음" end

		local spellLink, extraSpellLink

		spellLink = spellName
		extraSpellLink = extraSpellName
--[[
		if spellId and GetSpellLink then
			spellLink = GetSpellLink(spellId)
		else
			spellLink = spellName
		end
		if extraSpellId and GetSpellLink then
			extraSpellLink = GetSpellLink(extraSpellId)
		else
			extraSpellLink = extraSpellName
		end
]]
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
			--print(" * 차단 ["..spellLink.."] -> "..raidTarget..destName.."의 ["..extraSpellLink .."]")
			print(" * 차단 -> "..raidTarget..destName.."의 ["..extraSpellLink .."]")
		else
			--SendChatMessage("차단 ["..spellLink.."] -> "..raidTarget..destName.."의 ["..extraSpellLink .."]", upneDB.interruptChannel)
			SendChatMessage("차단 -> "..raidTarget..destName.."의 ["..extraSpellLink .."]", upneDB.interruptChannel)
		end
--	elseif combatEvent == "SPELL_AURA_APPLIED" and UnitIsPlayer(sourceGUID) and destGUID == UnitGUID("player") then
--		print(" * 오라 받음 [" .. sourceName .. "] 의 [" .. spellName .. "]")
	end
end

--[[
	itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
	itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent
	= GetItemInfo(itemID or "itemString" or "itemName" or "itemLink") 

	itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID
	= GetItemInfoInstant(itemID or "itemString" or "itemName" or "itemLink") 
]]

function GameTooltip_Add_Item_Level(tooltip, ...)
	local itemLink = tooltip:GetItem()
	if itemLink then
		local _, _, _, itemLevel, _, itemType = GetItemInfo(itemLink)
		local itemID, _ = GetItemInfoInstant(itemLink)

		if itemType == GetItemClassInfo(LE_ITEM_CLASS_WEAPON) or itemType == GetItemClassInfo(LE_ITEM_CLASS_ARMOR) then
			tooltip:AddDoubleLine("아이템 레벨   |cffffffff" .. itemLevel .. "|r", "(ID:  |cffffffff" .. itemID .. "|r)")
		end
	end
end

function GameTooltip_Add_Item_Level_Short(tooltip, ...)
	local itemLink = tooltip:GetItem()
	if itemLink then
		local _, _, _, itemLevel, _, itemType = GetItemInfo(itemLink)
		local itemID, _ = GetItemInfoInstant(itemLink)

		if itemType == GetItemClassInfo(LE_ITEM_CLASS_WEAPON) or itemType == GetItemClassInfo(LE_ITEM_CLASS_ARMOR) then
			tooltip:AddLine("아이템 레벨 |cffffffff" .. itemLevel .. "|r")
			tooltip:AddLine("아이템 ID |cffffffff" .. itemID .. "|r")
		end
	end
end

function upne_ConfigPanel()
	_G.UpneOptions_Check1:SetChecked(upneDB.interrupt)
	_G.UpneOptions_Check2:SetChecked(upneDB.tooltipItemLevel)
	_G.UpneOptions_Check3:SetChecked(upneDB.setShamanColor)
	_G.UpneOptions_Check4:SetChecked(upneDB.tooltipSrc)
	interruptDropDown = _G.upne_cbox
	UIDropDownMenu_Initialize(interruptDropDown, UpneOptions_DropDownInterrupt, "")
	interruptDropDown.value = upneDB.interruptChannel
	UIDropDownMenu_SetSelectedValue(interruptDropDown, interruptDropDown.value)
end

function upne_SetShamanColor(r,g,b)
	RAID_CLASS_COLORS.SHAMAN.r = r
	RAID_CLASS_COLORS.SHAMAN.g = g
	RAID_CLASS_COLORS.SHAMAN.b = b
end

function Upne:TRADE_SHOW(...)
	TradeFrameRecipientNameText:SetTextColor(GetClassColor(select(2,UnitClass("npc"))))
end