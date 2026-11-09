local _, ns = ...

--------------------------------------------------------------------------------
-- Bar art (an Edit Mode option, per layout), drawn as Blizzard's action bar
-- 1 is: the frame around the bar, the slot art in each button, and the
-- divider between buttons while the padding is at its minimum (within each
-- row or column). Flyouts always have the frame, slot art and dividers.
--   No end caps: Forever has those as an option of bar 1.
--   The pieces (atlases, sizes, the frame, the slots, the dividers) are the
--   core's (SetGo!'s Art.lua), shared with the UI Tweaks.
--   Only the look is shared with bar 1: padding, size, rows and the art
--   toggle stay Fetch!'s own.
--   Anchored to the bag bar there is no art, only the slot background, so
--   the bags don't show through empty buttons.
--------------------------------------------------------------------------------

local Art = SetGo.Art
local Slots, PlaceDivider, HideAll = Art.Slots, Art.PlaceDivider, Art.HideAll
local MIN_SPACING = Art.MIN_SPACING

function ns.ArtOn(layout)
	layout = layout or ns.Layout()
	return layout.barArt == true and not ns.Anchored(layout)
end

local frameArt
local function FrameArt(bar)
	if frameArt == nil then
		frameArt = Art.FrameTexture(bar) or false
	end
	return frameArt or nil
end

--------------------------------------------------------------------------------
-- Dividers
--------------------------------------------------------------------------------

-- The bar: buttons run left to right (horizontal) or top to bottom
-- (vertical), in rows (columns) of perLine.
local barDividers = {}
local function ApplyDividers(bar, mains, layout, on)
	local keep = {}
	local show = on and (tonumber(layout.spacing) or MIN_SPACING) <= MIN_SPACING
	if show then
		local count = ns.Count(layout)
		local lines = math.max(1, math.min(count, tonumber(layout.rows) or 1))
		local perLine = math.ceil(count / lines)
		local side = ns.Orientation(layout) == "VERTICAL" and "TOP" or "LEFT"
		local scale = (tonumber(layout.scale) or 100) / 100
		for i = 2, count do
			-- not the first button of a row
			if (i - 1) % perLine ~= 0 then
				local d = PlaceDivider(barDividers, bar, i, mains[i], side)
				if d then
					d:SetScale(scale)
					keep[d] = true
				end
			end
		end
	end
	HideAll(barDividers, keep)
end

--------------------------------------------------------------------------------
-- Flyouts: bar 1's art, always (so the flyout stands out), padding 2
--------------------------------------------------------------------------------

-- the side of each next slot that faces the one before it
local FLY_SIDE = { UP = "BOTTOM", DOWN = "TOP", LEFT = "RIGHT", RIGHT = "LEFT" }

function ns.FlyoutFrameArt(fly)
	local frame = Art.FrameTexture(fly)
	if not frame then
		return false
	end
	frame:Show()
	fly.art = { frame = frame }
	fly.dividers = {}
	return true
end

-- After the flyout is laid out (fly.visible: its shown slots, in order).
function ns.ApplyFlyoutArt(fly, dir)
	local keep = {}
	local side = FLY_SIDE[dir] or "BOTTOM"
	for n, fb in ipairs(fly.visible or {}) do
		Slots(fb).art:Show()
		if n > 1 and fly.dividers then
			local d = PlaceDivider(fly.dividers, fly, n, fb, side)
			if d then
				keep[d] = true
			end
		end
	end
	if fly.dividers then
		HideAll(fly.dividers, keep)
	end
end

-- Flyouts stay in DIALOG whatever the bar's strata (for clients without
-- fixed strata).
function ns.FixFlyStrata(mains)
	for i = 1, ns.MAX_BUTTONS do
		local fly = mains[i] and mains[i].fpFlyout
		if fly and fly:GetFrameStrata() ~= "DIALOG" then
			fly:SetFrameStrata("DIALOG")
		end
	end
end

--------------------------------------------------------------------------------

-- Out of combat (from ApplyLayout): textures and plain frames only.
function ns.ApplyArt(bar, mains)
	local layout = ns.Layout()
	local on = ns.ArtOn(layout)
	local anchored = ns.Anchored(layout)
	local frame = FrameArt(bar)
	if frame then
		frame:SetShown(on)
	end
	for i = 1, ns.MAX_BUTTONS do
		local slots = Slots(mains[i])
		slots.art:SetShown(on)
		slots.background:SetShown(anchored and not on)
	end
	ApplyDividers(bar, mains, layout, on)
end
