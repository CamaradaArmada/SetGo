local _, ns = ...
local Try = ns.Try

--------------------------------------------------------------------------------
-- Action bar art, drawn as Blizzard's action bar 1 is (MainActionBar,
-- Forever 1.60.1, read from the game): the frame around the bar, the slot
-- art in each button, and the divider between buttons while the padding is
-- at its minimum. Shared by Fetch! (its bar and flyouts) and the UI Tweaks
-- (Blizzard's bars 2 to 8). Only textures and plain frames: nothing here
-- touches what Blizzard protects.
--   The values are fixed below, not read from bar 1 at load; when Blizzard
--   changes the assets, the new ones are read again and copied here.
--   Every atlas is checked before use; a missing one is left out (the slot
--   falls back to a dark square).
--------------------------------------------------------------------------------

local Art = {}
ns.Art = Art

Art.FRAME = {
	atlas = "UI-HUD-ActionBar-Frame",
	slice = { 32, 40, 32, 40 }, -- left, top, right, bottom
	sliceMode = 1,
	-- how far it reaches past the buttons
	left = 6, top = 6, right = 4, bottom = 5,
}
Art.SLOT_ART = "UI-HUD-ActionBar-IconFrame-Slot" -- with the art
Art.SLOT_BACKGROUND = "UI-HUD-ActionBar-IconFrame-Background" -- without
-- Dividers, as bar 1 draws them at its minimum padding:
--   between buttons side by side, a standing piece over their shared edge;
--   between buttons stacked, a lying piece. Each sits under the buttons,
--   reaching INSET into the button it belongs to.
Art.DIVIDER_STANDING = {
	first = "UI-HUD-ActionBar-Frame-Divider-ThreeSlice-EdgeTop",
	center = "!UI-HUD-ActionBar-Frame-Divider-ThreeSlice-Center",
	last = "UI-HUD-ActionBar-Frame-Divider-ThreeSlice-EdgeBottom",
	thick = 12, -- width
	edge = 15, -- height of the top and bottom pieces
}
Art.DIVIDER_LYING = {
	first = "UI-HUD-ActionBar-Frame-Divider-Threeslice-EdgeLeft",
	center = "_UI-HUD-ActionBar-Frame-Divider-Threeslice-Center",
	last = "UI-HUD-ActionBar-Frame-Divider-Threeslice-EdgeRight",
	thick = 12, -- height
	edge = 12, -- width of the left and right pieces
}
Art.INSET = 5
Art.MIN_SPACING = 2

local atlasCache = {}
function Art.AtlasExists(name)
	if atlasCache[name] == nil then
		local ok = false
		if C_Texture and C_Texture.GetAtlasInfo then
			ok = type(Try(C_Texture.GetAtlasInfo, name)) == "table"
		end
		atlasCache[name] = ok
	end
	return atlasCache[name]
end
local AtlasExists = Art.AtlasExists

--------------------------------------------------------------------------------
-- Frame: a texture on parent, around its edges (hidden). nil when the game
-- doesn't have the atlas.
--------------------------------------------------------------------------------

function Art.FrameTexture(parent)
	local F = Art.FRAME
	if not AtlasExists(F.atlas) then
		return nil
	end
	local tex = parent:CreateTexture(nil, "BACKGROUND", nil, -3)
	tex:SetAtlas(F.atlas)
	if tex.SetTextureSliceMargins then
		pcall(tex.SetTextureSliceMargins, tex, unpack(F.slice))
		if tex.SetTextureSliceMode then
			pcall(tex.SetTextureSliceMode, tex, F.sliceMode)
		end
	end
	tex:SetPoint("TOPLEFT", parent, "TOPLEFT", -F.left, F.top)
	tex:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", F.right, -F.bottom)
	tex:Hide()
	return tex
end

--------------------------------------------------------------------------------
-- Slot: the template's SlotArt and SlotBackground where it has them, made
-- otherwise (hidden)
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

function Art.Slots(main)
	if not main.fpSlots then
		main.fpSlots = {
			art = SlotTexture(main, "SlotArt", Art.SLOT_ART),
			background = SlotTexture(main, "SlotBackground", Art.SLOT_BACKGROUND),
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
	local standing = kind == Art.DIVIDER_STANDING
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
function Art.PlaceDivider(pool, parent, index, btn, side)
	local standing = side == "LEFT" or side == "RIGHT"
	local kind = standing and Art.DIVIDER_STANDING or Art.DIVIDER_LYING
	if not HasDivider(kind) then
		return nil
	end
	local key = index .. (standing and "s" or "l")
	local d = pool[key]
	if not d then
		d = NewDivider(parent, kind)
		pool[key] = d
	end
	local INSET = Art.INSET
	d:ClearAllPoints()
	if standing then
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

-- hides the dividers of a pool not in keep ({ [divider] = true })
function Art.HideAll(pool, keep)
	for _, d in pairs(pool) do
		if not keep[d] then
			d:Hide()
		end
	end
end
