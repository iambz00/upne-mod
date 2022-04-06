local addonName, addon = ...
Upnemod = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
Upnemod.name = addonName
Upnemod.version = GetAddOnMetadata(addonName, "Version")
Upnemod.channelList = {
	["SAY"] = "SAY",	["S"] = "SAY",	["ㄴ"] = "SAY",	["일반"] = "SAY",
	["YELL"] = "YELL",	["Y"] = "YELL",	["ㅛ"] = "YELL",	["외침"] = "YELL",
	["PARTY"] = "PARTY",	["P"] = "PARTY",	["ㅔ"] = "PARTY",	["파티"] = "PARTY",
	["RAID"] = "RAID",	["R"] = "RAID",	["ㄱ"] = "RAID",	["공"] = "RAID",
	["INSTANCE"] = "INSTANCE",	["I"] = "INSTANCE",	["ㅑ"] = "INSTANCE",
	["RAID_WARNING"] = "RAID_WARNING",	["RW"] = "RAID_WARNING",	["경보"] = "RAID_WARNING",
}
Upnemod.channelListOption = {
	["SAY"] = "일반",
	["YELL"] = "외침",
	["PARTY"] = "파티",
	["RAID"] = "공격대",
	["RAID_WARNING"] = "공격대경보",
}

BINDING_HEADER_UPNEMOD = "upnemod";
BINDING_NAME_UPNEMOD_INSPECT_TARGET = "대상 살펴보기 ";
BINDING_NAME_UPNEMOD_INSPECT_MOUSEOVER = "마우스오버 살펴보기";

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
			tot_raidIcon = true,
			fixCombatText = true,
		}
	}
}

local playerGUID
local MSG_PREFIX = "|cff00ff00■ |cffffaa00upnemod|r "
local MSG_SUFFIX = " |cff00ff00■|r"
local p = function(str) print(MSG_PREFIX..str..MSG_SUFFIX) end

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
	self:SetTradeClassColor()
	self:SetToTRaidIcon()
	self:SetFixCombatText()

	-- Slash Commands
	SLASH_UPNE1 = "/ㅇㅇ"
	SLASH_UPNE2 = "/upne"
	SlashCmdList["UPNE"] = function(msg)
		local cmd, val = msg:match("^(%S*)%s*(.*)")
		if cmd == "차단" or cmd == "int" or cmd == "interrupt" then
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
	SLASH_CALC1 = "/계산"
	SLASH_CALC2 = "/calc"
	SlashCmdList["CALC"] = function(msg)
		local func, err = load("return "..msg)
		if func then
			local ok, result = pcall(func)
			if ok then
				SendChatMessage("계산: "..msg.." = "..result, "SAY")
			else
				p("계산 오류")
			end
			p("계산 오류")
		end
--[[		local origHandler = geterrorhandler()
		seterrorhandler(function (msg)
			print("잘못된 계산식입니다.")
		end)
		msg = "local answer="..msg..";if answer then SendChatMessage('계산: "..msg.." = '..answer,'SAY') end"
		RunScript(msg)
		seterrorhandler(origHandler)
]]
	end
	-- Silent calculating
	SLASH_CALCU1 = "/계산2"
	SLASH_CALCU2 = "/calc2"
	SlashCmdList["CALCU"] = function(msg)
		local func, err = load("return "..msg)
		if func then
			local ok, result = pcall(func)
			if ok then
				p("계산: "..msg.." = "..result)
			else
				p("계산 오류")
			end
			p("계산 오류")
		end
	end
end

function Upnemod:SetAnnounceInterrupt()
	if self.db.announceInterrupt then
		Upnemod:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		p("차단 알림 - " .. self.channelListOption[self.db.announceChannel])
	else
		Upnemod:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		p("차단 알림 해제")
	end
end

function Upnemod:SetTooltipIlvl()
	local function GameTooltip_Ilvl(tooltip, ...)
		local itemLink = tooltip:GetItem()
		if itemLink then
			local _, _, _, itemLevel, _, itemType = GetItemInfo(itemLink)
			local itemID, _ = GetItemInfoInstant(itemLink)

			if itemType == GetItemClassInfo(LE_ITEM_CLASS_WEAPON) or itemType == GetItemClassInfo(LE_ITEM_CLASS_ARMOR) then
				tooltip:AddDoubleLine("아이템 레벨   |cffffffff" .. itemLevel .. "|r", "(ID:  |cffffffff" .. itemID .. "|r)")
			end
		end
	end

	local function GameTooltip_Ilvl_Narrow(tooltip, ...)
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

	if self.db.tooltip_ilvl then
		self:SetTooltipHandler(GameTooltip, GameTooltip_Ilvl)
		self:SetTooltipHandler(ItemRefTooltip, GameTooltip_Ilvl)
		self:SetTooltipHandler(ShoppingTooltip1, GameTooltip_Ilvl_Narrow)
		self:SetTooltipHandler(ShoppingTooltip2, GameTooltip_Ilvl_Narrow)
		p("툴팁에 아이템 레벨 표시")
	else
		self:SetTooltipHandler(GameTooltip, nil)
		self:SetTooltipHandler(ItemRefTooltip, nil)
		self:SetTooltipHandler(ShoppingTooltip1, nil)
		self:SetTooltipHandler(ShoppingTooltip2, nil)
		p("툴팁에 아이템 레벨 끄기")
	end
end

function Upnemod:SetTooltipHandler(tooltip, func)
	if func then
		local orgHandler = tooltip:GetScript("OnTooltipSetItem")
		if orgHandler then
			self.tooltipHandler[tooltip:GetName()] = orgHandler
			tooltip:HookScript("OnTooltipSetItem", func)
		else
			tooltip:SetScript("OnTooltipSetItem", func)
		end
	else
		local orgHandler = self.tooltipHandler[tooltip:GetName()]
		if orgHandler then
			tooltip:SetScript("OnTooltipSetItem", orgHandler)
		else
			tooltip:SetScript("OnTooltipSetItem", nil)
		end
	end
end

function Upnemod:SetTooltipAura()
	local function upne_AuraHandler(uaf, gt, ...)
		local _, _, _, _, _, _, src, _, _, auraId = uaf(...)	-- UnitAura or UnitBuff or UnitDebuff
		local db = self.db
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
		if not destName then destName = "대상없음" end

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
			p("차단 -> "..raidTarget..destName.."의 "..(extraSpellId and GetSpellLink(extraSpellId) or extraSpellName) .."")
		else
			SendChatMessage("차단 -> "..raidTarget..destName.."의 "..(extraSpellId and GetSpellLink(extraSpellId) or extraSpellName), self.db.announceChannel)
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

function Upnemod:TRADE_SHOW(...)
	TradeFrameRecipientNameText:SetTextColor(GetClassColor(select(2,UnitClass("npc"))))
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
	local index = GetRaidTargetIndex("targettarget")
	if index then
		SetRaidTargetIconTexture(TargetFrameToT.raidTargetIcon, index)
	else
		SetRaidTargetIconTexture(TargetFrameToT.raidTargetIcon, 0)
	end

	index = GetRaidTargetIndex("focustarget")
	if index then
		SetRaidTargetIconTexture(FocusFrameToT.raidTargetIcon, index)
	else
		SetRaidTargetIconTexture(FocusFrameToT.raidTargetIcon, 0)
	end
end

function Upnemod:SetFixCombatText()
	if self.db.fixCombatText then
		C_Timer.NewTicker(5, function()
			if GetCVar("enableFloatingCombatText") ~= "1" then
				SetCVar("enableFloatingCombatText", 1)
				InterfaceOptionsCombatPanelEnableFloatingCombatText.setFunc("1")
				p("전투메시지 표시가 꺼져 있어서 켰습니다.")
			end
		end, 4)
	end
end

function Upnemod:BuildOptions()
	self.optionsTable = {
		name = self.name,
		handler = self,
		type = 'group',
		get = function(info) return self.db[info[#info]] end,
		set = function(info, value) self.db[info[#info]] = value end,
		args = {
			announceInterrupt = {
				name = '차단알림 사용',
				type = 'toggle',
				order = 101,
				set = function(info, value) self.db[info[#info]] = value
						self:SetAnnounceInterrupt()	end,
			},
			announceChannel = {
				name = '차단알림 채널',
				type = 'select',
				values = self.channelListOption,
				order = 102,
				set = function(info, value) self.db[info[#info]] = value
						self:SetAnnounceInterrupt() end,
			},
			tooltip_ilvl = {
				name = '툴팁에 아이템 레벨/ID 표시',
				type = 'toggle',
				order = 201,
				width = "full",
				set = function(info, value) self.db[info[#info]] = value
						self:SetTooltipIlvl() end,
			},
			tooltip_auraId = {
				name = '버프/디버프 툴팁에 주문ID 표시',
				type = 'toggle',
				order = 301,
				width = "full",
			},
			tooltip_auraSrc = {
				name = '버프/디버프 툴팁에 시전자 표시',
				type = 'toggle',
				order = 302,
				width = "full",
			},
			trade_classColor = {
				name = '거래창에서 상대방 직업색상 보이기',
				type = 'toggle',
				order = 401,
				width = "full",
				set = function(info, value) self.db[info[#info]] = value
						self:SetTradeClassColor() end,
			},
			tot_raidIcon = {
				name = '대상의 대상/주시대상의 대상 공격대 아이콘 표시',
				type = 'toggle',
				order = 501,
				width = "full",
				set = function(info, value) self.db[info[#info]] = value
						self:SetToTRaidIcon() end,
			},
			fixCombatText = {
				name = '전투메시지 표시하기 고정',
				type = 'toggle',
				order = 601,
				width = 'full',
				desc = '간혹 전투메시지 표시가 꺼져 있는 현상을 방지',
				set = function(info, value) self.db[info[#info]] = value
						self:SetFixCombatText() end,
			},
		}
	}
end
