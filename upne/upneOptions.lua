function UpneOptions_OnLoad(panel)
	panel.name = "upne options"
	-- panel.parent
	panel.okay = function(self) end
	panel.cancel = function(self) end
	-- panel.default
	-- panel.refresh
	InterfaceOptions_AddCategory(panel)

	local frame, fs
	frame = CreateFrame("CheckButton", "UpneOptions_Check1", panel, "UpneCheckButtonTemplate")
	frame:SetPoint("TOPLEFT", UpneOptions_Description, "BOTTOMLEFT", 0, -20)
	frame = CreateFrame("CheckButton", "UpneOptions_Check2", panel, "UpneCheckButtonTemplate")
	frame:SetPoint("TOPLEFT", UpneOptions_Check1, "BOTTOMLEFT", 0, -8)

--[[	frame = CreateFrame("CheckButton", "UpneOptions_Check3", panel, "UpneCheckButtonTemplate")
	frame:SetPoint("TOPLEFT", UpneOptions_Check2, "BOTTOMLEFT", 0, -8)
	frame = CreateFrame("EditBox", "UpneOptions_EditBox2_1", panel, "UpneInputBoxTemplate")
	frame:SetPoint("LEFT", UpneOptions_Check2, "RIGHT", 100, 0)
	EditBoxSetup(frame)

	frame = CreateFrame("Frame", "UpneOptions_Separator1", panel, "UpneSeparatorTemplate")
	frame:SetPoint("TOPLEFT", UpneOptions_Description, "BOTTOMLEFT", 0, -150)
	frame:SetSize(230,30)
]]
	_G.UpneOptions_Version:SetText("")
	_G.UpneOptions_Description:SetText("")

	_G.UpneOptions_Check1Text:SetText(" 차단 채널")
	_G.UpneOptions_Check1.func = UpneInterruptAlarm
	
	_G.UpneOptions_Check2Text:SetText(" 툴팁에 아이템 레벨 표시 ")
	_G.UpneOptions_Check2.func = UpneTooltipItemLevel

--	_G.UpneOptions_Check2Text:SetText(" 툴팁에 아이템 ID 표시 ")
--	_G.UpneOptions_Check2.func = UpneTooltipItemID

--[[
	_G.UpneOptions_EditBox2_1Text:SetText("x")
	_G.UpneOptions_EditBox2_2Text:SetText("y")
	_G.UpneOptions_EditBox2_1.NextEditBox = _G.UpneOptions_EditBox2_2
	_G.UpneOptions_EditBox2_2.NextEditBox = _G.UpneOptions_EditBox2_1
	_G.UpneOptions_EditBox2_1.func = function(self)
		Upne.tooltip_x = self:GetNumber()
	end
	_G.UpneOptions_EditBox2_2.func = function(self)
		Upne.tooltip_y = self:GetNumber()
	end
]]

	local cbox = CreateFrame("Frame", "upne_cbox", _G.UpneOptions_Check1, "UIDropDownMenuTemplate")
	cbox:SetPoint("LEFT", _G.UpneOptions_Check1Text, "RIGHT")
	--UIDropDownMenu_Initialize(cbox, UpneOptions_DropDownInterrupt, "")
	--cbox.value = Upne.upneDB.interruptChannel
	--UIDropDownMenu_SetSelectedValue(cbox, cbox.value)

end

function UpneOptions_DropDownInterrupt(dropdown)
	local cboxList = {
		[1] = { text = "차단알림 채널", isTitle = true, notCheckable = true },
		[2] = { text = "일반", value = "SAY",  },
		[3] = { text = "파티", value = "PARTY", },
		[4] = { text = "인스턴스", value = "INSTANCE" },
		[5] = { text = "공격대", value = "RAID" },
		[6] = { text = "외침", value = "YELL" },
		[7] = { text = "공격대경보", value = "RAID_WARNING" },
	}
	UIDropDownMenu_AddButton(cboxList[1])
	for i = 2, #cboxList do
		cboxList[i].func = function(self)
			dropdown.value = self.value
			Upne.upneDB.interruptChannel = self.value
			UIDropDownMenu_SetSelectedValue(dropdown, self.value)
		end
		UIDropDownMenu_AddButton(cboxList[i])
	end
end

function UpneOptions_OnShow(panel)
--	_G.UpneOptions_Check1:SetChecked(Upne.upneDB.interrupt)
--	_G.UpneOptions_Check2:SetChecked(Upne.upneDB.tooltipItemLevel)

--	_G.UpneOptions_EditBox2_1:SetText(tostring(_G.Upne.tooltip_x))
--	_G.UpneOptions_EditBox2_2:SetText(tostring(_G.Upne.tooltip_y))
--	_G.UpneOptions_EditBox2_1:SetNumeric(true)
--	_G.UpneOptions_EditBox2_2:SetNumeric(true)

end

function UpneCheckButton_OnClick(self, button, down)
	self.func(self)
end

function UpneCheckButton_OnLeave(self)
	GameTooltip:Hide()
end

function UpneInterruptAlarm(self)
	Upne.upneDB.interrupt = self:GetChecked()
	upne_InterruptAlarm()
end

function UpneTooltipItemLevel(self)
	Upne.upneDB.tooltipItemLevel = self:GetChecked()
	if Upne.upneDB.tooltipItemLevel then
		upne_SetTooltipHandler(GameTooltip, GameTooltip_Add_Item_Level)
		upne_SetTooltipHandler(ItemRefTooltip, GameTooltip_Add_Item_Level)
		upne_SetTooltipHandler(ShoppingTooltip1, GameTooltip_Add_Item_Level_Short)
		upne_SetTooltipHandler(ShoppingTooltip2, GameTooltip_Add_Item_Level_Short)
	else
		upne_SetTooltipHandler(GameTooltip, nil)
		upne_SetTooltipHandler(ItemRefTooltip, nil)
		upne_SetTooltipHandler(ShoppingTooltip1, nil)
		upne_SetTooltipHandler(ShoppingTooltip2, nil)
	end
end

--[[ Editbox callbacks
function EditBoxSetup(self)
	self:SetAutoFocus(false)
	self:SetScript("OnTabPressed", UpneEditBox_OnTabPressed)
	self:SetScript("OnEnterPressed", UpneEditBox_OnEnterPressed)
	self:SetScript("OnEscapePressed", UpneEditBox_OnEnterPressed)
	self:SetScript("OnTextChanged", UpneEditBox_OnTextChanged)
	self:SetScript("OnEnter", UpneEditBox_OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide )
	return self
end

function UpneEditBox_OnTabPressed(self)
	UpneEditBox_OnEnterPressed(self)
	if self.NextEditBox then
		self.NextEditBox:SetFocus()
	end
end
function UpneEditBox_OnEnterPressed(self)
	if self.func then
		self.func(self)
	end
	self:ClearFocus()
end
function UpneEditBox_OnTextChanged(self)
end
]]