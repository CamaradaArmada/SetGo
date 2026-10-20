local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Fetch!'s page in SetGo!: how the flyouts behave. Where the bar sits and
-- how it looks stays in Edit Mode, per layout.
--------------------------------------------------------------------------------

local function Option(key, name, tooltip, after)
	local default = ns.Behavior()[key]
	return SetGo.Pseudo("SETGO_FP_" .. key, name, tooltip, default, function()
		return ns.Behavior()[key]
	end, function(value)
		if type(value) == "number" then
			value = math.floor(value + 0.5)
		end
		ns.Behavior()[key] = value
		if after then
			after()
		end
	end)
end

local function Relayout()
	-- hold mode changes how keybinds fire (the buttons' attributes)
	ns.ApplyLayout()
end

local items
local function Items()
	if items then
		return items
	end
	-- defaults, not the saved values
	local defaults = { hover = false, modifier = "NONE", holdMode = "OFF", holdDelay = 250, stickyClose = 6, mute = false, preview = false }
	local function Make(key, name, tooltip, after)
		local s = Option(key, name, tooltip, after)
		s.default = defaults[key]
		return s
	end
	local hover = Make("hover", L.HOVER, L.HOVER_DESC)
	local modifier = Make("modifier", L.MODIFIER, L.MODIFIER_DESC)
	local hold = Make("holdMode", L.HOLD_MODE, L.HOLD_DESC, Relayout)
	local delay = Make("holdDelay", L.HOLD_DELAY, L.HOLD_DELAY_DESC)
	local close = Make("stickyClose", L.STICKY_CLOSE, L.STICKY_CLOSE_DESC)
	local mute = Make("mute", L.MUTE, L.MUTE_DESC)
	local preview = Make("preview", L.PREVIEW, L.PREVIEW_DESC, ns.RequestUpdate)

	local function Modifiers()
		return {
			{ value = "NONE", label = L.NONE },
			{ value = "SHIFT", label = L.SHIFT },
			{ value = "CTRL", label = L.CTRL },
			{ value = "ALT", label = L.ALT },
		}
	end
	local function HoldModes()
		return {
			{ value = "OFF", label = L.OFF },
			{ value = "HOLD", label = L.HOLD },
			{ value = "STICKY", label = L.STICKY },
		}
	end
	local function Seconds(v)
		return tostring(math.floor(v + 0.5))
	end
	local function Formatters(fmt)
		if MinimalSliderWithSteppersMixin and CreateMinimalSliderFormatter then
			local right = MinimalSliderWithSteppersMixin.Label.Right
			return { [right] = CreateMinimalSliderFormatter(right, fmt) }
		end
	end

	items = {
		{ kind = "note", name = L.PAGE_NOTE },
		{ kind = "header", name = L.SEC_OPEN },
		{ kind = "checkbox", setting = hover, settings = { hover }, name = L.HOVER, tooltip = L.HOVER_DESC },
		{ kind = "dropdown", setting = modifier, settings = { modifier }, name = L.MODIFIER, tooltip = L.MODIFIER_DESC, options = Modifiers, indent = true },
		{ kind = "dropdown", setting = hold, settings = { hold }, name = L.HOLD_MODE, tooltip = L.HOLD_DESC, options = HoldModes },
		{ kind = "slider", setting = delay, settings = { delay }, name = L.HOLD_DELAY, tooltip = L.HOLD_DELAY_DESC, indent = true,
			options = { minValue = 150, maxValue = 600, steps = 9, formatters = Formatters(Seconds) } },
		{ kind = "slider", setting = close, settings = { close }, name = L.STICKY_CLOSE, tooltip = L.STICKY_CLOSE_DESC, indent = true,
			options = { minValue = 0, maxValue = 30, steps = 30, formatters = Formatters(Seconds) } },
		{ kind = "header", name = L.SEC_EXTRAS },
		{ kind = "checkbox", setting = mute, settings = { mute }, name = L.MUTE, tooltip = L.MUTE_DESC },
		{ kind = "checkbox", setting = preview, settings = { preview }, name = L.PREVIEW, tooltip = L.PREVIEW_DESC },
	}
	return items
end

-- A new Edit Mode layout copied in SetGo! from another takes the bar with
-- it, as Blizzard's bars go with the copy. Only when the source has one.
local function Copy(t)
	local out = {}
	for k, v in pairs(t) do
		out[k] = type(v) == "table" and Copy(v) or v
	end
	return out
end

local function CopyLayout(fromName, toName)
	local layouts = ns.layoutDB and ns.layoutDB.layouts
	local from = layouts and fromName and layouts[fromName]
	if type(from) ~= "table" or not toName then
		return
	end
	layouts[toName] = Copy(from)
	if ns.ApplyLayout then
		ns.ApplyLayout()
	end
end

-- a layout SetGo! deleted: its bar goes too
local function DeleteLayout(name)
	local layouts = ns.layoutDB and ns.layoutDB.layouts
	if layouts and name then
		layouts[name] = nil
	end
end

-- The bar of a layout, for SetGo! to keep inside a profile with the Edit
-- Mode layout (profiles, export, presets). Flat, simple values only. The
-- field names are stored in profiles and presets: don't rename them.
-- The buttons' contents (SetGoFetchDB) stay out: they are per character.

local function Simple(v)
	local t = type(v)
	return t == "boolean" or t == "number" or t == "string"
end

-- a copy of the bar saved for layout name, or nil; never creates one
local function GetLayoutData(name)
	local layouts = ns.layoutDB and ns.layoutDB.layouts
	local t = layouts and name and layouts[name]
	if type(t) ~= "table" then
		return nil
	end
	local out = {}
	for k, v in pairs(t) do
		if type(k) == "string" and Simple(v) then
			out[k] = v
		end
	end
	return out
end

-- saves a copy of data as layout name's bar, in place of what was there;
-- only the fields Fetch! knows. Redraws when name is the active layout and
-- the bar exists (module on); with the module off it only saves.
local function SetLayoutData(name, data)
	local layouts = ns.layoutDB and ns.layoutDB.layouts
	if not layouts or type(name) ~= "string" or type(data) ~= "table" then
		return
	end
	local known = ns.LAYOUT_DEFAULTS or {}
	local t = {}
	for k, v in pairs(data) do
		if (known[k] ~= nil or k == "blizzScale") and Simple(v) then
			t[k] = v
		end
	end
	-- the values are already in today's units: the pre-0.6.3 conversion
	-- (ns.GetLayout) must not run on them
	if next(t) ~= nil then
		t.blizzScale = true
	end
	layouts[name] = t
	if ns.bar and ns.ApplyLayout and SetGo.ModuleOn and SetGo.ModuleOn("fetch")
		and ns.ActiveLayoutName and ns.ActiveLayoutName() == name then
		ns.ApplyLayout()
	end
end

SetGo.RegisterModule({ key = "fetch", title = L.ADDON, items = Items, CopyLayout = CopyLayout, DeleteLayout = DeleteLayout,
	GetLayoutData = GetLayoutData, SetLayoutData = SetLayoutData,
	-- its tips in SetGo!, once, the first time it is on: at the first
	-- button, then at a flyout once one opens
	tour = {
		{ text = L.TOUR_DRAG, frame = function() return ns.mains and ns.mains[1] end },
		{ text = L.TOUR_OPEN, frame = function() return ns.mains and ns.mains[1] end },
		{ text = L.TOUR_KEYS, wait = function()
			for _, main in ipairs(ns.mains or {}) do
				if main.fpFlyout and main.fpFlyout:IsShown() then
					return main.fpFlyout
				end
			end
		end },
	} })
