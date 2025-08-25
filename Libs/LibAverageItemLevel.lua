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
LibItemLevel:SetCallback(addon, CALLBACK_FUNCTION_NAME)
LibItemLevel:UnsetCallback(addon)


]]

local library = "LibAverageItemLevel"
assert(LibStub, format("%s requires LibStub", library))

---@class LibAverageItemLevel
local lib, oldminor = LibStub:NewLibrary(library, 2)
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
function lib:StoreItemLevel(guid, unit)
    if lib.inspecting.guid ~= guid then return end

    local sumItemLevel = 0
    local numSlot = NUMSLOT.MAIN_AND_OFF
    for _, invslot in pairs(self.INVSLOT) do
        local itemLink = GetInventoryItemLink(unit, invslot)
        if itemLink then
            local item = Item:CreateFromItemLink(itemLink)
            sumItemLevel = sumItemLevel + (item:GetCurrentItemLevel() or 0)
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
            if mLoc == "INVTYPE_2HWEAPON" or mLoc == "INVTYPE_RANGED" then
                numSlot = NUMSLOT.TWOHANDED
            end
        end
    else
        if not oLink then
            numSlot = NUMSLOT.EMPTY_HAND
        end
    end
    -- else MAIN_AND_OFF
    local ilvl_equip = ceil(sumItemLevel / numSlot)
    local old_ilvl = lib.store[guid] or 0

    if lib.inspecting.guid ~= guid then return end
    lib.store[guid] = ilvl_equip
    lib.callbacks:Fire(CALLBACK_EVENT, guid, ilvl_equip)

    -- Repeat until no changes - Equipments 
    if old_ilvl ~= ilvl_equip then
        C_Timer.NewTimer(0.1, function() lib:StoreItemLevel(guid, unit) end)
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


