--[[
        LibAverageItemLevel

Recognize Other's Item Level on Inspection.
Temporarily stores data not maintained across sessions.
Gathers data ONLY from User-Intended-Inspection.

1. Load Lib

local LibItemLevel = LibStub:GetLibrary("LibAverageItemLevel", true)

2. Get Item Level

LibItemLevel:GetItemLevel(unit)
LibItemLevel:GetItemLevelByGUID(GUID)

Returns nil if there's no stored data

3. (Automatically) Gather Item Level Data on Inspection

4. Set/Unset Callback 
LibItemLevel:SetCallback(Upnemod, "ItemLevel_Update")
LibItemLevel:UnsetCallback(Upnemod)




guid and store
calculate ilvl

Currently Blizzard's formula for equipped average item level is as follows:

 sum of item levels for equipped gear (I)
-----------------------------------------  = Equipped Average Item Level
       number of slots (S)

(I) = in taking the sum, the tabard and shirt always count as zero
      some heirloom items count as zero, other heirlooms count as one

(S) = number of slots depends on the contents of the main and off hand as follows:
      17 with both hands holding items 
      17 with a single one-hand item (or a single two-handed item with Titan's Grip)
      16 with a two-handed item equipped (and no Titan's Grip)
      16 with both hands empty


]]

local library = "LibAverageItemLevel"
assert(LibStub, format("%s requires LibStub", library))

---@class LibAverageItemLevel
local lib, oldminor = LibStub:NewLibrary(library, 1)
if not lib then return end
oldminor = oldminor or 0

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
local CALLBACK_EVENT = "LibAverageItemLevel_Update"

lib.INVSLOT = { 
    INVSLOT_HEAD,   INVSLOT_NECK,   INVSLOT_SHOULDER,   INVSLOT_CHEST,
    INVSLOT_WAIST,  INVSLOT_LEGS,   INVSLOT_FEET,   INVSLOT_WRIST,  INVSLOT_HAND,
    INVSLOT_FINGER1,    INVSLOT_FINGER2,    INVSLOT_TRINKET1,    INVSLOT_TRINKET2,
    INVSLOT_BACK,   INVSLOT_MAINHAND,   INVSLOT_OFFHAND,
}   -- Means 1 to 17 except 4

lib.store = lib.store or { }

function lib:GetItemLevel(unit)
    return self:GetItemLevelByGUID(UnitGUID(unit))
end

function lib:GetItemLevelByGUID(guid)
    return self.store[guid]
end

local NUMSLOT = {
    MAIN_AND_OFF = 16,
    TWOHANDED = 15,
    EMPTY_HAND = 15,
}

-- From Old 5.4 Version
lib.DELTA = { -- Level to Add
	[  1] = 8 , -- 1 / 1
	[373] = 4 , -- 1 / 2
	[374] = 8 , -- 2 / 2
	[375] = 4 , -- 1 / 3
	[376] = 4 , -- 2 / 3
	[377] = 4 , -- 3 / 3
	[378] = 7 ,
	[379] = 4 , -- 1 / 2
	[380] = 4 , -- 2 / 2
	[445] = 0 , -- 0 / 2
	[446] = 4 , -- 1 / 2
	[447] = 8 , -- 2 / 2
	[451] = 0 , -- 0 / 1
	[452] = 8 , -- 1 / 1
	[453] = 0 , -- 0 / 2
	[454] = 4 , -- 1 / 2
	[455] = 8 , -- 2 / 2
	[456] = 0 , -- 0 / 1
	[457] = 8 , -- 1 / 1
	[458] = 0 , -- 0 / 4
	[459] = 4 , -- 1 / 4
	[460] = 8 , -- 2 / 4
	[461] = 12, -- 3 / 4
	[462] = 16, -- 4 / 4
	[465] = 0 , -- 0 / 2
	[466] = 4 , -- 1 / 2
	[467] = 8 , -- 2 / 2
	[468] = 0 , -- 0 / 4
	[469] = 4 , -- 1 / 4
	[470] = 8 , -- 2 / 4
	[471] = 12, -- 3 / 4
	[472] = 16, -- 4 / 4
	[491] = 0 , -- 0 / 2
	[492] = 4 , -- 1 / 2
	[493] = 8 , -- 2 / 2
	[494] = 0 , -- 0 / 4
	[495] = 4 , -- 1 / 4
	[496] = 8 , -- 2 / 4
	[497] = 12, -- 3 / 4
	[498] = 16, -- 4 / 4
}
function GetActualItemLevel(link)
  local baseLevel = select(4,GetItemInfo(link))
  local upgrade = link:match(":(%d+)\124h%[")
  if baseLevel and upgrade then
    return baseLevel + levelAdjust[upgrade]
  else
    return baseLevel
  end
end
function lib:StoreItemLevel(guid, unit)
    local sumItemLevel = 0
    local numSlot = NUMSLOT.MAIN_AND_OFF
    local emptySlots = 0
    for _, invslot in pairs(self.INVSLOT) do
        local itemLink = GetInventoryItemLink(unit, invslot)
        if itemLink then
-- DEBUG START
            local ulvl = itemLink:match(":(%d+)\124h%[") or -1  -- -1 for test, 0 for real
            local _,_,_, ilvl = C_Item.GetItemInfo(itemLink)
            print(itemLink, ilvl, lib.DELTA[ulvl] or -1, ulvl)
-- DEBUG END
            local item = Item:CreateFromItemLink(itemLink)
            sumItemLevel = sumItemLevel + (item:GetCurrentItemLevel() or 0)
        else
            emptySlots = emptySlots + 1
        end
    end
    local mLink = GetInventoryItemLink(unit, INVSLOT_MAINHAND)
    local oLink = GetInventoryItemLink(unit, INVSLOT_OFFHAND)
    local mLoc
    if mLink then
        _, _, _, mLoc = GetItemInfoInstant(mLink)
    end

    if mLink then
        if not oLink then
            if mLoc == "INVTYPE_2HWEAPON" or mLoc == "INVTYPE_RANGEDRIGHT" or mLoc == "INVTYPE_RANGED" then
                numSlot = NUMSLOT.TWOHANDED
            end
            emptySlots = emptySlots - 1
        end
    else
        emptySlots = emptySlots - 1
        if not oLink then
            numSlot = NUMSLOT.EMPTY_HAND
            emptySlots = emptySlots - 1
        end
    end
    -- else MAIN_AND_OFF
    local ilvl_equip = ceil(sumItemLevel / numSlot)
    lib.store[guid] = ilvl_equip
    lib.callbacks:Fire(CALLBACK_EVENT, guid, ilvl_equip)
    if emptySlots > 1 and lib.inspecting and lib.inspecting.round and lib.inspecting.round < 5 then
        lib.inspecting.round = lib.inspecting.round + 1
        C_Timer.NewTimer(0.3, function() lib:StoreItemLevel(guid, unit) end)
    end
end

function lib:SetCallback(addon, callback)
    self.RegisterCallback(addon, CALLBACK_EVENT, callback)
end

function lib:UnsetCallback(addon)
    self.UnregisterCallback(addon, CALLBACK_EVENT)
end

-- Event Handling
lib.frame = lib.frame or CreateFrame("Frame")

function lib.frame:OnEvent(event, ...)
    return lib.frame[event] and lib.frame[event](lib, ...)
end

function lib.frame:INSPECT_READY(guid, ...)
    local inspecting = self.inspecting
    if inspecting then
        if guid == inspecting.guid then
            -- UnitIsVisible, CanInspect, CheckInteractDistance 
            lib:StoreItemLevel(guid, inspecting.unit)
        end
    end
end

lib.frame:SetScript("OnEvent", lib.frame.OnEvent)
lib.frame:RegisterEvent("INSPECT_READY")

function lib.NotifyInspect(unit)
    if unit and UnitIsPlayer(unit) then
        lib.inspecting = { unit = unit, guid = UnitGUID(unit), round = 0 }
    end
end

function lib.ClearInspectPlayer()
    lib.inspecting = nil
end

hooksecurefunc("NotifyInspect", lib.NotifyInspect)
hooksecurefunc("ClearInspectPlayer", lib.ClearInspectPlayer)


