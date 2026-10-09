local _, ns = ...

--------------------------------------------------------------------------------
-- Bar art (an Edit Mode option, per layout), drawn as Blizzard's action bar
-- 1 is (MainActionBar, Forever 1.60.1, read with /fetch dump):
--   the frame around the bar, the slot art in each button, and the divider
--   between buttons while the padding is at its minimum (within each row
--   or column). Flyouts always have the frame, slot art and dividers.
--   No end caps: Forever has those as an option of bar 1.
--   The values are fixed below, not read from bar 1 at load; when Blizzard
--   changes the assets, /fetch dump shows the new ones to copy here.
--   Only the look is shared with bar 1: padding, size, rows and the art
--   toggle stay Fetch!'s own.
--   Anchored to the bag bar there is no art, only the slot background, so
--   the bags don't show through empty buttons.
--   Every atlas is checked before use; a missing one is left out (the slot
--   falls back to a dark square).
--------------------------------------------------------------------------------

local FRAME = {
	atlas = "UI-HUD-ActionBar-Frame",
	slice = { 32, 40, 32, 40 }, -- left, top, right, bottom
	sliceMode = 1,
	-- how far it reaches past the buttons
	left = 6, top = 6, right = 4, bottom = 5,
}
local SLOT_ART = "UI-HUD-ActionBar-IconFrame-Slot" -- with the art
local SLOT_BACKGROUND = "UI-HUD-ActionBar-IconFrame-Background" -- anchored
-- Dividers, as bar 1 draws them at its minimum padding:
--   between buttons side by side, a standing piece over their shared edge;
--   between buttons stacked, a lying piece. Each sits under the buttons,
--   reaching INSET into the button it belongs to.
local DIVIDER_STANDING = {
	first = "UI-HUD-ActionBar-Frame-Divider-ThreeSlice-EdgeTop",
	center = "!UI-HUD-ActionBar-Frame-Divider-ThreeSlice-Center",
	last = "UI-HUD-ActionBar-Frame-Divider-ThreeSlice-EdgeBottom",
	thick = 12, -- width
	edge = 15, -- height of the top and bottom pieces
}
local DIVIDER_LYING = {
	first = "UI-HUD-ActionBar-Frame-Divider-Threeslice-EdgeLeft",
	center = "_UI-HUD-ActionBar-Frame-Divider-Threeslice-Center",
	last = "UI-HUD-ActionBar-Frame-Divider-Threeslice-EdgeRight",
	thick = 12, -- height
	edge = 12, -- width of the left and right pieces
}
local INSET = 5
local MIN_SPACING = 2

local atlasCache = {}
local function AtlasExists(name)
	if atlasCache[name] == nil then
		local ok = false
		if C_Texture and C_Texture.GetAtlasInfo then
			ok = type(ns.Try(C_Texture.GetAtlasInfo, name)) == "table"
		end
		atlasCache[name] = ok
	end
	return atlasCache[name]
end

function ns.ArtOn(layout)
	layout = layout or ns.Layout()
	return layout.barArt == true and not ns.Anchored(layout)
end

--------------------------------------------------------------------------------
-- Frame
--------------------------------------------------------------------------------

local frameArt
local function FrameArt(bar)
	if frameArt ~= nil then
		return frameArt or nil
	end
	if not AtlasExists(FRAME.atlas) then
		frameArt = false
		return nil
	end
	frameArt = bar:CreateTexture(nil, "BACKGROUND", nil, -3)
	frameArt:SetAtlas(FRAME.atlas)
	if frameArt.SetTextureSliceMargins then
		pcall(frameArt.SetTextureSliceMargins, frameArt, unpack(FRAME.slice))
		if frameArt.SetTextureSliceMode then
			pcall(frameArt.SetTextureSliceMode, frameArt, FRAME.sliceMode)
		end
	end
	frameArt:SetPoint("TOPLEFT", bar, "TOPLEFT", -FRAME.left, FRAME.top)
	frameArt:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", FRAME.right, -FRAME.bottom)
	frameArt:Hide()
	return frameArt
end

--------------------------------------------------------------------------------
-- Slot: the template's SlotArt and SlotBackground where it has them
--------------------------------------------------------------------------------

local function SlotTexture(main, key, atlas)
	local tex = main[key]
	if not tex then
		tex = main:CreateTexture(nil, "BACKGROUND", nil, -1)
		tex:SetAllPoints()
		main[key] = tex
	end
	if AtlasExists(atlas) then
		tex:SetAtlas(atlas)
	else
		tex:SetColorTexture(0, 0, 0, 0.5)
	end
	tex:SetAlpha(1)
	tex:Hide()
	return tex
end

local function Slots(main)
	if not main.fpSlots then
		main.fpSlots = {
			art = SlotTexture(main, "SlotArt", SLOT_ART),
			background = SlotTexture(main, "SlotBackground", SLOT_BACKGROUND),
		}
	end
	return main.fpSlots
end

--------------------------------------------------------------------------------
-- Dividers
--------------------------------------------------------------------------------

local function HasDivider(kind)
	return AtlasExists(kind.first) and AtlasExists(kind.center) and AtlasExists(kind.last)
end

local function NewDivider(parent, kind)
	local d = CreateFrame("Frame", nil, parent)
	local standing = kind == DIVIDER_STANDING
	local first = d:CreateTexture(nil, "BORDER")
	first:SetAtlas(kind.first)
	local last = d:CreateTexture(nil, "BORDER")
	last:SetAtlas(kind.last)
	local center = d:CreateTexture(nil, "BORDER")
	center:SetAtlas(kind.center)
	if standing then
		d:SetWidth(kind.thick)
		first:SetHeight(kind.edge)
		first:SetPoint("TOPLEFT")
		first:SetPoint("TOPRIGHT")
		last:SetHeight(kind.edge)
		last:SetPoint("BOTTOMLEFT")
		last:SetPoint("BOTTOMRIGHT")
		-- as on bar 1, only the top 90% of the piece
		center:SetTexCoord(0, 1, 0, 0.9)
		center:SetPoint("TOPLEFT", first, "BOTTOMLEFT")
		center:SetPoint("BOTTOMRIGHT", last, "TOPRIGHT")
	else
		d:SetHeight(kind.thick)
		first:SetWidth(kind.edge)
		first:SetPoint("TOPLEFT")
		first:SetPoint("BOTTOMLEFT")
		last:SetWidth(kind.edge)
		last:SetPoint("TOPRIGHT")
		last:SetPoint("BOTTOMRIGHT")
		-- tiled sideways, as on bar 1
		if center.SetHorizTile then
			pcall(center.SetHorizTile, center, true)
		end
		center:SetPoint("TOPLEFT", first, "TOPRIGHT")
		center:SetPoint("BOTTOMRIGHT", last, "BOTTOMLEFT")
	end
	d.kind = kind
	d:Hide()
	return d
end

-- A divider on side "side" of btn (the side facing the previous button).
-- pool: a table of dividers for this parent, by index and kind.
local function PlaceDivider(pool, parent, index, btn, side)
	local kind = (side == "LEFT" or side == "RIGHT") and DIVIDER_STANDING or DIVIDER_LYING
	if not HasDivider(kind) then
		return nil
	end
	local key = index .. (kind == DIVIDER_STANDING and "s" or "l")
	local d = pool[key]
	if not d then
		d = NewDivider(parent, kind)
		pool[key] = d
	end
	d:ClearAllPoints()
	if kind == DIVIDER_STANDING then
		d:SetPoint("TOP", btn, "TOP")
		d:SetPoint("BOTTOM", btn, "BOTTOM")
		if side == "LEFT" then
			d:SetPoint("RIGHT", btn, "LEFT", INSET, 0)
		else
			d:SetPoint("LEFT", btn, "RIGHT", -INSET, 0)
		end
	else
		d:SetPoint("LEFT", btn, "LEFT")
		d:SetPoint("RIGHT", btn, "RIGHT")
		if side == "TOP" then
			d:SetPoint("BOTTOM", btn, "TOP", 0, -INSET)
		else
			d:SetPoint("TOP", btn, "BOTTOM", 0, INSET)
		end
	end
	-- under the buttons
	d:SetFrameLevel(math.max(0, btn:GetFrameLevel() - 1))
	d:Show()
	return d
end

local function HideAll(pool, keep)
	for _, d in pairs(pool) do
		if not keep[d] then
			d:Hide()
		end
	end
end

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
	if not AtlasExists(FRAME.atlas) then
		return false
	end
	local frame = fly:CreateTexture(nil, "BACKGROUND", nil, -3)
	frame:SetAtlas(FRAME.atlas)
	if frame.SetTextureSliceMargins then
		pcall(frame.SetTextureSliceMargins, frame, unpack(FRAME.slice))
		if frame.SetTextureSliceMode then
			pcall(frame.SetTextureSliceMode, frame, FRAME.sliceMode)
		end
	end
	frame:SetPoint("TOPLEFT", fly, "TOPLEFT", -FRAME.left, FRAME.top)
	frame:SetPoint("BOTTOMRIGHT", fly, "BOTTOMRIGHT", FRAME.right, -FRAME.bottom)
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
