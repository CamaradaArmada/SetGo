local _, ns = ...
local L = ns.L
local LEM = ns.LibEditMode

-- Bar layout, stored per Edit Mode layout. Button contents are per character
-- and live in SetGoFetchDB instead.
local DEFAULTS = {
	point = "CENTER",
	x = 0,
	y = -200,
	numButtons = 12,
	orientation = "HORIZONTAL",
	flyDir = "UP",
	spacing = 2,
	scale = 100,
	rows = 1,
	visibility = "ALWAYS",
	showEmpty = true,
	bagAnchor = false,
	barArt = false,
}
local FALLBACK = "__default"

-- Ask the library which layout is active every time, instead of trusting a
-- copy that could drift out of sync.
local function ActiveName()
	local name = LEM and LEM.GetActiveLayoutName and LEM:GetActiveLayoutName()
	return name or ns.activeLayout
end

function ns.GetLayout(name)
	local layouts = ns.layoutDB.layouts
	name = name or ActiveName() or FALLBACK
	local t = layouts[name]
	if type(t) ~= "table" then
		t = {}
		layouts[name] = t
	end
	-- Before 0.6.3 the whole bar scaled, gaps and position included; now the
	-- buttons scale and the gaps don't, as on Blizzard's bars. Once per
	-- layout: keep the bar where it was, and the old default gap of 4 becomes
	-- Blizzard's 2.
	if next(t) ~= nil and not t.blizzScale then
		local scale = (tonumber(t.scale) or 100) / 100
		if t.x then
			t.x = t.x * scale
		end
		if t.y then
			t.y = t.y * scale
		end
		if t.spacing == nil or t.spacing == 4 then
			t.spacing = 2
		end
		t.spacing = math.max(2, math.min(10, tonumber(t.spacing) or 2))
		t.scale = math.max(50, math.min(200, math.floor((tonumber(t.scale) or 100) / 10 + 0.5) * 10))
	end
	t.blizzScale = true
	for key, value in pairs(DEFAULTS) do
		if t[key] == nil then
			t[key] = value
		end
	end
	return t
end

function ns.Layout()
	return ns.GetLayout(ActiveName())
end

function ns.ActiveLayoutName()
	return ActiveName() or FALLBACK
end

-- Up/down for a horizontal bar, left/right for a vertical one.
function ns.FlyDir(layout)
	local dir = layout.flyDir
	if ns.Orientation(layout) == "VERTICAL" then
		if dir ~= "LEFT" and dir ~= "RIGHT" then
			dir = "RIGHT"
		end
	elseif dir ~= "UP" and dir ~= "DOWN" then
		dir = "UP"
	end
	return dir
end

-- Edit Mode only ever edits the active layout, so always redraw.
local function Changed()
	ns.ApplyLayout()
end

local function Round(value)
	return math.floor(value + 0.5)
end

-- Settings the bag bar decides while the bar is anchored to it.
local function Anchored(layoutName)
	return ns.GetLayout(layoutName).bagAnchor == true
end

local function Slider(key, name, min, max, step)
	return {
		kind = LEM.SettingType.Slider,
		name = name,
		disabled = Anchored,
		default = DEFAULTS[key],
		minValue = min,
		maxValue = max,
		valueStep = step,
		get = function(layoutName)
			return ns.GetLayout(layoutName)[key]
		end,
		set = function(layoutName, value)
			ns.GetLayout(layoutName)[key] = Round(value)
			Changed(layoutName)
		end,
	}
end

local SWAP_AXIS = { UP = "RIGHT", DOWN = "LEFT", RIGHT = "UP", LEFT = "DOWN" }

local function BuildSettings()
	return {
		{
			kind = LEM.SettingType.Checkbox,
			name = L.BAG_ANCHOR,
			default = DEFAULTS.bagAnchor,
			get = function(layoutName)
				return ns.GetLayout(layoutName).bagAnchor
			end,
			set = function(layoutName, value)
				ns.GetLayout(layoutName).bagAnchor = value and true or false
				ns.bagPeek = false
				if value and not ns.BagSlots() then
					print("|cffedd57fFetch!:|r " .. L.BAG_NONE)
				end
				Changed(layoutName)
				-- the settings the bag bar decides grey out
				C_Timer.After(0, function()
					LEM:RefreshFrameSettings(ns.bar)
				end)
			end,
		},
		{
			kind = LEM.SettingType.Checkbox,
			name = L.BAR_ART,
			default = DEFAULTS.barArt,
			disabled = Anchored,
			get = function(layoutName)
				return ns.GetLayout(layoutName).barArt
			end,
			set = function(layoutName, value)
				ns.GetLayout(layoutName).barArt = value and true or false
				Changed(layoutName)
			end,
		},
		Slider("numButtons", L.NUM_BUTTONS, 1, ns.MAX_BUTTONS, 1),
		{
			kind = LEM.SettingType.Dropdown,
			name = L.ORIENTATION,
			default = DEFAULTS.orientation,
			disabled = Anchored,
			values = {
				{ text = L.HORIZONTAL, value = "HORIZONTAL" },
				{ text = L.VERTICAL, value = "VERTICAL" },
			},
			get = function(layoutName)
				return ns.GetLayout(layoutName).orientation
			end,
			set = function(layoutName, value)
				local t = ns.GetLayout(layoutName)
				if t.orientation ~= value then
					t.orientation = value
					t.flyDir = SWAP_AXIS[t.flyDir] or t.flyDir
				end
				Changed(layoutName)
				-- the direction list depends on the orientation
				C_Timer.After(0, function()
					LEM:RefreshFrameSettings(ns.bar)
				end)
			end,
		},
		{
			kind = LEM.SettingType.Dropdown,
			name = L.FLYOUT_DIR,
			default = DEFAULTS.flyDir,
			values = function()
				if ns.Orientation(ns.Layout()) == "VERTICAL" then
					return {
						{ text = L.RIGHT, value = "RIGHT" },
						{ text = L.LEFT, value = "LEFT" },
					}
				end
				return {
					{ text = L.UP, value = "UP" },
					{ text = L.DOWN, value = "DOWN" },
				}
			end,
			get = function(layoutName)
				return ns.FlyDir(ns.GetLayout(layoutName))
			end,
			set = function(layoutName, value)
				ns.GetLayout(layoutName).flyDir = value
				Changed(layoutName)
			end,
		},
		-- the same ranges and steps as Blizzard's Icon Padding and Icon Size
		Slider("spacing", L.SPACING, 2, 10, 1),
		Slider("scale", L.SCALE, 50, 200, 10),
		{
			kind = LEM.SettingType.Slider,
			name = L.ROWS,
			default = DEFAULTS.rows,
			disabled = Anchored,
			minValue = 1,
			maxValue = ns.MAX_BUTTONS,
			valueStep = 1,
			get = function(layoutName)
				local t = ns.GetLayout(layoutName)
				return math.min(t.rows, t.numButtons)
			end,
			set = function(layoutName, value)
				ns.GetLayout(layoutName).rows = Round(value)
				Changed(layoutName)
			end,
		},
		{
			kind = LEM.SettingType.Dropdown,
			name = L.VISIBILITY,
			default = DEFAULTS.visibility,
			values = {
				{ text = L.VIS_ALWAYS, value = "ALWAYS" },
				{ text = L.VIS_COMBAT, value = "COMBAT" },
				{ text = L.VIS_NOCOMBAT, value = "NOCOMBAT" },
				{ text = L.VIS_HIDDEN, value = "HIDDEN" },
			},
			get = function(layoutName)
				return ns.GetLayout(layoutName).visibility
			end,
			set = function(layoutName, value)
				ns.GetLayout(layoutName).visibility = value
				Changed(layoutName)
			end,
		},
		{
			kind = LEM.SettingType.Checkbox,
			name = L.SHOW_EMPTY,
			default = DEFAULTS.showEmpty,
			get = function(layoutName)
				return ns.GetLayout(layoutName).showEmpty
			end,
			set = function(layoutName, value)
				ns.GetLayout(layoutName).showEmpty = value and true or false
				Changed(layoutName)
			end,
		},
	}
end

-- Up to 0.3.6 the library assumed two preset layouts, but Forever has three,
-- so bar settings were saved under the name of the next layout (the last one
-- under FALLBACK). Move them once to the right names.
function ns.MigratePresetFix()
	local db = ns.layoutDB
	if db.presetFix then
		return
	end
	local presets = LEM and LEM.numPresets or 2
	local info = C_EditMode and C_EditMode.GetLayouts and C_EditMode.GetLayouts()
	if type(info) ~= "table" then
		return
	end
	db.presetFix = true
	if presets <= 2 then
		return
	end
	local customs = info.layouts or {}
	local names = { "Modern", "Classic", "Gamepad" }
	local old, new = db.layouts, {}
	for k, v in pairs(old) do
		new[k] = v
	end
	for i = 3, presets + #customs do
		local oldName = customs[i - 2] and customs[i - 2].layoutName or FALLBACK
		local newName = i <= presets and (names[i] or ("Preset " .. i)) or customs[i - presets].layoutName
		new[newName] = old[oldName]
	end
	db.layouts = new
end

-- The bar's place per layout follows the layouts, even while the module is
-- switched off in SetGo! (no bar then, but the data stays right): a New
-- Layout copied from another takes its bar, a renamed one keeps it, a
-- deleted one drops it. The library reports these when Edit Mode saves.
local watching = false
function ns.WatchLayouts()
	if watching or not (LEM and LEM.RegisterCallback) then
		return
	end
	watching = true
	LEM:RegisterCallback("create", function(layoutName, _, sourceName)
		local layouts = ns.layoutDB.layouts
		if sourceName and type(layouts[sourceName]) == "table" and layouts[layoutName] == nil then
			layouts[layoutName] = CopyTable(layouts[sourceName])
		end
	end)
	LEM:RegisterCallback("rename", function(oldName, newName)
		local layouts = ns.layoutDB.layouts
		if layouts[oldName] ~= nil then
			layouts[newName] = layouts[oldName]
			layouts[oldName] = nil
		end
		if ns.activeLayout == oldName then
			ns.activeLayout = newName
		end
	end)
	LEM:RegisterCallback("delete", function(layoutName)
		ns.layoutDB.layouts[layoutName] = nil
	end)
end

function ns.SetupEditMode()
	if not LEM or not LEM.AddFrame then
		return
	end
	local bar = ns.bar
	bar.editModeName = L.ADDON

	LEM:AddFrame(bar, function(_, layoutName, point, x, y)
		local t = ns.GetLayout(layoutName)
		-- anchored to the bag bar: a drag doesn't move it (it snaps back),
		-- and the place saved for when it is undone stays as it was
		if not t.bagAnchor then
			-- dropped after a drag: snap (the bar isn't scaled, so the
			-- offsets are UIParent units, like the snap)
			if ns.snapDragging and ns.SnapDelta then
				local dx, dy = ns.SnapDelta(bar)
				x, y = x + dx, y + dy
			end
			t.point, t.x, t.y = point, x, y
		end
		Changed(layoutName)
	end, { point = DEFAULTS.point, x = DEFAULTS.x, y = DEFAULTS.y }, L.ADDON)
	LEM:AddFrameSettings(bar, BuildSettings())
	if ns.SetupSnap and LEM.frameSelections then
		ns.SetupSnap(bar, LEM.frameSelections[bar])
	end

	LEM:RegisterCallback("layout", function(layoutName)
		ns.MigratePresetFix()
		ns.activeLayout = layoutName or FALLBACK
		ns.ApplyLayout()
	end)
	LEM:RegisterCallback("enter", function()
		ns.inEditMode = true
		ns.CloseAll()
		ns.ApplyVisibility()
		ns.RequestUpdate()
	end)
	LEM:RegisterCallback("exit", function()
		ns.inEditMode = false
		-- the bag bar may have moved or changed size
		if ns.BagRelayout then
			ns.BagRelayout()
		end
		ns.ApplyVisibility()
		ns.RequestUpdate()
	end)
end
