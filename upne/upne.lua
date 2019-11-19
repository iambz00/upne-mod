local addonName, addon = ...
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
		upneDB.version = "20191101"
		upneDB.interrupt = true
		upneDB.interruptChannel = "PARTY"
		upneDB.tooltipItemLevel = true
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
	local _, _, _, itemLevel, _, itemType = GetItemInfo(itemLink)
	local itemID, _ = GetItemInfoInstant(itemLink)

	if itemType == GetItemClassInfo(LE_ITEM_CLASS_WEAPON) or itemType == GetItemClassInfo(LE_ITEM_CLASS_ARMOR) then
		tooltip:AddDoubleLine("아이템 레벨   |cffffffff" .. itemLevel .. "|r", "(ID:  |cffffffff" .. itemID .. "|r)")
	end
end

function GameTooltip_Add_Item_Level_Short(tooltip, ...)
	local itemLink = tooltip:GetItem()
	local _, _, _, itemLevel, _, itemType = GetItemInfo(itemLink)
	local itemID, _ = GetItemInfoInstant(itemLink)

	if itemType == GetItemClassInfo(LE_ITEM_CLASS_WEAPON) or itemType == GetItemClassInfo(LE_ITEM_CLASS_ARMOR) then
		tooltip:AddLine("아이템 레벨 |cffffffff" .. itemLevel .. "|r")
		tooltip:AddLine("아이템 ID |cffffffff" .. itemID .. "|r")
	end
end

function upne_ConfigPanel()
	_G.UpneOptions_Check1:SetChecked(upneDB.interrupt)
	_G.UpneOptions_Check2:SetChecked(upneDB.tooltipItemLevel)
	_G.UpneOptions_Check3:SetChecked(upneDB.setShamanColor)
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