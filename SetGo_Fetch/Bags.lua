local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Anchor to the bag bar (an Edit Mode option, per layout).
--   The bar takes one button per bag slot (the four bags and the reagent
--   bag; the backpack stays uncovered), each centred on its bag at the bag's
--   own size. Position, size and scale are read from Blizzard's buttons
--   every time, so moving or resizing the bag bar in Edit Mode carries the
--   bar with it.
--   Right click on the keyring hides the bar, to reach the bags beneath;
--   another right click brings it back. Out of combat only: the bar holds
--   secure buttons, which can't be shown or hidden in combat.
--------------------------------------------------------------------------------

-- left to right on Blizzard's default bag bar, used until the buttons have
-- a place on screen to sort by
local SLOT_NAMES = {
	"CharacterReagentBag0Slot",
	"CharacterBag3Slot",
	"CharacterBag2Slot",
	"CharacterBag1Slot",
	"CharacterBag0Slot",
}
local KEYRING_NAMES = { "KeyRingButton", "MainMenuBarKeyRingButton", "BagsBarKeyRingButton" }

-- The bag buttons there are, in screen order (left to right, or top to
-- bottom on a vertical bag bar), the bag bar's orientation, and whether they
-- have a place on screen yet (pos: each button's centre, in screen pixels).
function ns.BagSlots()
	local slots = {}
	for _, name in ipairs(SLOT_NAMES) do
		local slot = _G[name]
		if slot and slot.IsShown and slot:IsShown() then
			slots[#slots + 1] = slot
		end
	end
	if #slots == 0 then
		return nil
	end
	local placed = true
	local pos = {}
	local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
	for _, slot in ipairs(slots) do
		local x, y = slot:GetCenter()
		if not x then
			placed = false
			break
		end
		local s = slot:GetEffectiveScale()
		x, y = x * s, y * s
		pos[slot] = { x = x, y = y }
		minX, maxX = math.min(minX, x), math.max(maxX, x)
		minY, maxY = math.min(minY, y), math.max(maxY, y)
	end
	local orientation = "HORIZONTAL"
	if placed and #slots > 1 then
		if (maxY - minY) > (maxX - minX) then
			orientation = "VERTICAL"
			table.sort(slots, function(a, b)
				return pos[a].y > pos[b].y
			end)
		else
			table.sort(slots, function(a, b)
				return pos[a].x < pos[b].x
			end)
		end
	end
	return slots, orientation, placed and pos or nil
end

-- Anchored: the option is on and there are bag buttons to sit on.
function ns.Anchored(layout)
	layout = layout or ns.Layout()
	return layout.bagAnchor == true and ns.BagSlots() ~= nil
end

function ns.Count(layout)
	if ns.Anchored(layout) then
		local slots = ns.BagSlots()
		return math.min(ns.MAX_BUTTONS, #slots)
	end
	return math.max(1, math.min(ns.MAX_BUTTONS, tonumber(layout.numButtons) or ns.MAX_BUTTONS))
end

function ns.Orientation(layout)
	if ns.Anchored(layout) then
		local _, orientation = ns.BagSlots()
		return orientation
	end
	return layout.orientation
end

function ns.FindKeyring()
	for _, name in ipairs(KEYRING_NAMES) do
		if _G[name] then
			return _G[name], name
		end
	end
	-- not under a known name: look for it on the bag bar
	local holder = _G.BagsBar or _G.MicroButtonAndBagsBar
	if holder and holder.GetChildren then
		for _, child in ipairs({ holder:GetChildren() }) do
			local name = child.GetName and child:GetName()
			if name and name:find("KeyRing") then
				return child, name
			end
		end
	end
end

-- Places the bar on the bag buttons. Out of combat only (ApplyLayout).
-- The bar is set where the bags are, on UIParent, not anchored to them: a
-- secure frame anchored to Blizzard's buttons would make them protected, and
-- Blizzard could no longer move them in combat. So the bar follows the bag
-- bar through hooks instead (below).
local retries = 0
function ns.ApplyBagLayout(bar, mains, slots, pos)
	if not pos then
		-- no place on screen yet (still loading): try again shortly
		if retries < 20 then
			retries = retries + 1
			C_Timer.After(0.5, ns.ApplyLayout)
		end
		return
	end
	retries = 0
	local ui = UIParent:GetEffectiveScale()
	local left, right, bottom, top = math.huge, -math.huge, math.huge, -math.huge
	local level = 0
	local boxes = {}
	for i, slot in ipairs(slots) do
		local p = pos[slot]
		local half = slot:GetWidth() * slot:GetEffectiveScale() / 2
		-- centre and size in UIParent units
		boxes[i] = { x = p.x / ui, y = p.y / ui, size = 2 * half / ui }
		left, right = math.min(left, (p.x - half) / ui), math.max(right, (p.x + half) / ui)
		bottom, top = math.min(bottom, (p.y - half) / ui), math.max(top, (p.y + half) / ui)
		level = math.max(level, slot:GetFrameLevel())
	end

	bar:SetScale(1)
	bar:ClearAllPoints()
	bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	bar:SetSize(math.max(1, right - left), math.max(1, top - bottom))
	-- above the bag buttons, in their strata
	bar:SetFrameStrata(slots[1]:GetFrameStrata())
	bar:SetFrameLevel(level + 5)

	for i = 1, ns.MAX_BUTTONS do
		local main = mains[i]
		local box = boxes[i]
		ns.CloseFlyout(main)
		main:ClearAllPoints()
		if box then
			-- the bag button's size; offsets are in the button's own scale
			local scale = box.size > 0 and box.size / ns.SIZE or 1
			main:SetScale(scale)
			main.fpFlyout:SetScale(scale)
			main:SetPoint("CENTER", bar, "BOTTOMLEFT", (box.x - left) / scale, (box.y - bottom) / scale)
			main:SetFrameLevel(level + 6)
		end
		local enabled = box ~= nil
		main.fpDisabled = not enabled
		main:SetShown(enabled)
		ns.ApplyAttributes(main)
	end
end

-- back to the bar's own place in its strata
function ns.ResetBagLevels(bar, mains)
	if not ns.baseStrata then
		return
	end
	bar:SetFrameStrata(ns.baseStrata)
	bar:SetFrameLevel(ns.baseLevel)
	for i = 1, ns.MAX_BUTTONS do
		mains[i]:SetFrameLevel(ns.baseLevel + 1)
	end
end

--------------------------------------------------------------------------------
-- A bag on the cursor puts the anchored bar away, so the bag can go into a
-- bag slot; the bar comes back once the cursor is empty. Runs on
-- CURSOR_CHANGED only, never on a timer. Out of combat only, like the
-- keyring.
--------------------------------------------------------------------------------

local CONTAINER = Enum and Enum.ItemClass and Enum.ItemClass.Container or 1
local QUIVER = Enum and Enum.ItemClass and Enum.ItemClass.Quiver or 11

local function BagOnCursor()
	local kind, itemID = GetCursorInfo()
	if kind ~= "item" or type(itemID) ~= "number" then
		return false
	end
	local _, _, _, _, _, classID = ns.Try(C_Item.GetItemInfoInstant, itemID)
	if ns.IsSecret(classID) then
		return false
	end
	return classID == CONTAINER or classID == QUIVER
end

function ns.CheckBagOnCursor()
	if InCombatLockdown() then
		return
	end
	local holding = BagOnCursor()
	if holding ~= (ns.bagOnCursor == true) then
		ns.bagOnCursor = holding
		if ns.Anchored() then
			ns.CloseAll()
			ns.ApplyVisibility()
		end
	end
end

--------------------------------------------------------------------------------
-- Following the bag bar: its size changes in Edit Mode (scale), a bag slot
-- that shows or hides, and the keyring's right click.
--------------------------------------------------------------------------------

-- next frame, once the bag bar's new place has settled; coalesced
local relayoutPending = false
local function Relayout()
	if relayoutPending or not ns.Layout().bagAnchor then
		return
	end
	relayoutPending = true
	C_Timer.After(0, function()
		relayoutPending = false
		ns.ApplyLayout()
	end)
end
ns.BagRelayout = Relayout

local hooked = false
function ns.HookBags()
	if hooked then
		return
	end
	hooked = true
	local holder = _G.BagsBar
	if holder then
		-- Edit Mode moves and resizes the bag bar with these
		pcall(hooksecurefunc, holder, "SetScale", Relayout)
		pcall(hooksecurefunc, holder, "SetPoint", Relayout)
		pcall(hooksecurefunc, holder, "Layout", Relayout)
	end
	for _, name in ipairs(SLOT_NAMES) do
		local slot = _G[name]
		if slot then
			slot:HookScript("OnShow", Relayout)
			slot:HookScript("OnHide", Relayout)
		end
	end

	local keyring = ns.FindKeyring()
	if keyring then
		keyring:HookScript("OnMouseUp", function(_, button)
			if button ~= "RightButton" or ns.inEditMode or not ns.Anchored() then
				return
			end
			if InCombatLockdown() then
				print("|cffedd57fFetch!:|r " .. L.COMBAT)
				return
			end
			ns.bagPeek = not ns.bagPeek
			ns.CloseAll()
			ns.ApplyVisibility()
		end)
	end
end
