local _, ns = ...

--------------------------------------------------------------------------------
-- Snapping in Edit Mode, while Blizzard's "Snap" option is on.
--   The bar snaps to the grid (when it is shown), to the screen's edges and
--   centre, and to Blizzard's Edit Mode frames: side by side, edges lined
--   up, centres lined up. One way only: we read where Blizzard's frames are
--   and never register with their magnetism manager, so nothing of theirs
--   is touched (no taint). Blizzard's frames don't snap to ours.
--   While dragging, a line shows where it will snap; it snaps on release.
--------------------------------------------------------------------------------

local RANGE = 10 -- how close, in UIParent units, before it snaps

local function Call(obj, method, ...)
	if obj and type(obj[method]) == "function" then
		local ok, value = pcall(obj[method], obj, ...)
		if ok then
			return value
		end
	end
end

-- Blizzard's "Snap" checkbox. If this client doesn't say, snap.
local function SnapOn()
	local manager = EditModeManagerFrame
	local value = Call(manager, "IsSnapEnabled")
	if value == nil then
		local check = manager and manager.EnableSnapCheckButton
		value = Call(check, "IsControlChecked")
		if value == nil and check and check.Button then
			value = Call(check.Button, "GetChecked")
		end
	end
	return value ~= false
end

-- The grid's spacing while it is shown, or nil.
local function GridSpacing()
	local manager = EditModeManagerFrame
	local grid = manager and manager.Grid
	if not grid or not grid:IsShown() then
		return nil
	end
	local spacing = Call(grid, "GetGridSpacing") or grid.gridSpacing or Call(manager, "GetGridSpacing")
	if type(spacing) == "number" and spacing > 0 then
		return spacing
	end
end

-- A frame's sides in UIParent units, or nil if it has no place on screen.
local function Rect(frame)
	local l, b, w, h = frame:GetRect()
	if not l or not w or w <= 0 or h <= 0 then
		return nil
	end
	local s = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
	l, b, w, h = l * s, b * s, w * s, h * s
	return { l = l, r = l + w, b = b, t = b + h, cx = l + w / 2, cy = b + h / 2 }
end

-- Blizzard's Edit Mode frames that are on screen.
local function Targets(bar)
	local list, seen = {}, {}
	local function Add(frame)
		if frame and frame ~= bar and not seen[frame] and frame.IsVisible and frame:IsVisible() then
			seen[frame] = true
			local rect = Rect(frame)
			if rect then
				list[#list + 1] = rect
			end
		end
	end
	local manager = EditModeManagerFrame
	if manager and type(manager.registeredSystemFrames) == "table" then
		for _, frame in ipairs(manager.registeredSystemFrames) do
			Add(frame)
		end
	end
	local magnet = EditModeMagnetismManager
	if magnet and type(magnet.magneticFrames) == "table" then
		for frame in pairs(magnet.magneticFrames) do
			if type(frame) == "table" then
				Add(frame)
			end
		end
	end
	return list
end

-- Closest snap on one axis: candidates are { from = our edge, to = line }.
local function Best(candidates)
	local delta, line
	for _, c in ipairs(candidates) do
		local d = c.to - c.from
		if math.abs(d) <= RANGE and (not delta or math.abs(d) < math.abs(delta)) then
			delta, line = d, c.to
		end
	end
	return delta or 0, line
end

-- How far to move the bar to snap, and the lines it snaps to.
function ns.SnapDelta(bar)
	if not SnapOn() then
		return 0, 0
	end
	local me = Rect(bar)
	if not me then
		return 0, 0
	end
	local W, H = UIParent:GetSize()
	local xs, ys = {}, {}
	local function X(from, to)
		xs[#xs + 1] = { from = from, to = to }
	end
	local function Y(from, to)
		ys[#ys + 1] = { from = from, to = to }
	end

	-- screen edges and centre
	X(me.l, 0); X(me.r, W); X(me.cx, W / 2)
	Y(me.b, 0); Y(me.t, H); Y(me.cy, H / 2)

	-- grid lines, outwards from the centre of the screen
	local spacing = GridSpacing()
	if spacing then
		for _, edge in ipairs({ me.l, me.r, me.cx }) do
			X(edge, W / 2 + math.floor((edge - W / 2) / spacing + 0.5) * spacing)
		end
		for _, edge in ipairs({ me.b, me.t, me.cy }) do
			Y(edge, H / 2 + math.floor((edge - H / 2) / spacing + 0.5) * spacing)
		end
	end

	-- Blizzard's frames: only those beside us (within range on the other axis)
	for _, o in ipairs(Targets(bar)) do
		if me.b < o.t + RANGE and me.t > o.b - RANGE then
			X(me.l, o.r); X(me.r, o.l)
			X(me.l, o.l); X(me.r, o.r); X(me.cx, o.cx)
		end
		if me.l < o.r + RANGE and me.r > o.l - RANGE then
			Y(me.b, o.t); Y(me.t, o.b)
			Y(me.b, o.b); Y(me.t, o.t); Y(me.cy, o.cy)
		end
	end

	local dx, lineX = Best(xs)
	local dy, lineY = Best(ys)
	return dx, dy, lineX, lineY
end

--------------------------------------------------------------------------------
-- Guide lines while dragging
--------------------------------------------------------------------------------

local overlay, lineX, lineY
local function Lines()
	if overlay then
		return
	end
	overlay = CreateFrame("Frame", nil, UIParent)
	overlay:SetAllPoints(UIParent)
	overlay:SetFrameStrata("TOOLTIP")
	overlay:Hide()
	lineX = overlay:CreateTexture(nil, "OVERLAY")
	lineX:SetColorTexture(1, 0.82, 0, 0.8)
	lineX:SetWidth(2)
	lineY = overlay:CreateTexture(nil, "OVERLAY")
	lineY:SetColorTexture(1, 0.82, 0, 0.8)
	lineY:SetHeight(2)
end

local function ShowLines(x, y)
	lineX:SetShown(x ~= nil)
	if x then
		lineX:ClearAllPoints()
		lineX:SetPoint("TOP", UIParent, "TOPLEFT", x, 0)
		lineX:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x, 0)
	end
	lineY:SetShown(y ~= nil)
	if y then
		lineY:ClearAllPoints()
		lineY:SetPoint("LEFT", UIParent, "BOTTOMLEFT", 0, y)
		lineY:SetPoint("RIGHT", UIParent, "BOTTOMRIGHT", 0, y)
	end
end

-- Follows the library's drag of our bar (its selection frame).
function ns.SetupSnap(bar, selection)
	if not selection then
		return
	end
	Lines()
	local elapsed = 0
	overlay:SetScript("OnUpdate", function(_, dt)
		if InCombatLockdown() then
			ns.snapDragging = false
			overlay:Hide()
			return
		end
		elapsed = elapsed + dt
		if elapsed < 0.05 then
			return
		end
		elapsed = 0
		local _, _, x, y = ns.SnapDelta(bar)
		ShowLines(x, y)
	end)
	selection:HookScript("OnDragStart", function()
		if InCombatLockdown() or ns.Anchored() then
			return
		end
		ns.snapDragging = true
		overlay:Show()
	end)
	-- the library's own OnDragStop saves the place first (and our callback
	-- snaps it), then this runs
	selection:HookScript("OnDragStop", function()
		ns.snapDragging = false
		overlay:Hide()
	end)
	selection:HookScript("OnHide", function()
		ns.snapDragging = false
		overlay:Hide()
	end)
end
