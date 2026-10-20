local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- SetGo!'s own page
--------------------------------------------------------------------------------

ns.TABS = { "presets", "modules", "settings" }

-- Global options are hidden until the player shows them: presets keep
-- character options only. They still turn up in the search.
function ns.HideGlobal()
	if ns.db.hideGlobal ~= nil then
		return ns.db.hideGlobal
	end
	return true
end

function ns.DefaultTab()
	local tab = ns.db and ns.db.defaultTab
	for _, t in ipairs(ns.TABS) do
		if t == tab then
			return t
		end
	end
	return "presets"
end

--------------------------------------------------------------------------------
-- The size of SetGo!'s windows (the book, the Quick Menu; not the
-- welcome a new character gets): the account's, at once, as a scale
--------------------------------------------------------------------------------

ns.SCALE_MIN, ns.SCALE_MAX, ns.SCALE_STEP = 0.75, 1.5, 0.05
ns.SCALED = { "SetGoFrame", "SetGoQuickFrame", "SetGoIconPicker" }
-- the ones the player moves: they keep their centre where it is
local KEEP_CENTRE = { SetGoFrame = true }

function ns.UIScale()
	local db = ns.db
	local s = db and db.scaleOn and tonumber(db.scale) or 1
	return math.max(ns.SCALE_MIN, math.min(ns.SCALE_MAX, s))
end

local function ScaleOne(f, name, s)
	if math.abs((tonumber(f:GetScale()) or 1) - s) < 0.001 then
		return
	end
	local x, y = f:GetCenter()
	x, y = tonumber(x), tonumber(y)
	local old = tonumber(f:GetEffectiveScale())
	if KEEP_CENTRE[name] and x and y and old and (tonumber(f:GetNumPoints()) or 0) > 0 then
		f:SetScale(s)
		local new = tonumber(f:GetEffectiveScale()) or s
		f:ClearAllPoints()
		f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x * old / new, y * old / new)
	else
		f:SetScale(s)
	end
end

-- on every window there is (and on one just made: ns.ScaleFrame(frame))
function ns.ApplyScale()
	if InCombatLockdown() then
		return
	end
	local s = ns.UIScale()
	for _, name in ipairs(ns.SCALED) do
		local f = _G[name]
		-- the icon picker inside the book follows the book
		if f and f.SetScale and not (name == "SetGoIconPicker" and f:GetParent() ~= UIParent) then
			ScaleOne(f, name, s)
		end
	end
end

-- what the box and the slider say, waiting for Apply (nil: as it is)
local scaleDraft = {}

function ns.ScaleWaiting()
	local db = ns.db or {}
	local on = scaleDraft.on
	local value = scaleDraft.value
	return (on ~= nil and on ~= (db.scaleOn == true))
		or (value ~= nil and math.abs(value - (tonumber(db.scale) or 1)) > 0.001)
end

function ns.ApplyScaleDraft()
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return
	end
	if scaleDraft.on ~= nil then
		ns.db.scaleOn = scaleDraft.on or nil
	end
	if scaleDraft.value ~= nil then
		ns.db.scale = scaleDraft.value
	end
	scaleDraft = {}
	ns.ApplyScale()
end

function ns.DiscardScale()
	scaleDraft = {}
end

function ns.ScaleFrame(f)
	if f and f.SetScale then
		f:SetScale(ns.UIScale())
	end
end

local setgo
function ns.SetGoItems()
	if setgo then
		return setgo
	end
	local tab = ns.Pseudo("SETGO_DEFAULT_TAB", L.SETGO_TAB, L.SETGO_TAB_DESC, "presets", function()
		return ns.DefaultTab()
	end, function(value)
		ns.db.defaultTab = value
	end)
	local minimap = ns.Pseudo("SETGO_MINIMAP", L.SETGO_MINIMAP, L.SETGO_MINIMAP_DESC, true, function()
		return not (ns.db.minimap and ns.db.minimap.hide)
	end, function(on)
		ns.db.minimap = ns.db.minimap or {}
		ns.db.minimap.hide = not on
		local icon = LibStub and LibStub("LibDBIcon-1.0", true)
		if icon then
			if on then
				icon:Show("SetGo")
			else
				icon:Hide("SetGo")
			end
		end
	end)
	local mute = ns.Pseudo("SETGO_MUTE", L.SETGO_MUTE, L.SETGO_MUTE_DESC, false, function()
		return ns.db.mute == true
	end, function(on)
		ns.db.mute = on and true or nil
	end)
	-- both wait for Apply (the window would change under the mouse)
	local scaleOn = ns.Pseudo("SETGO_SCALE_ON", ns.G("USE_UISCALE", L.SETGO_SCALE), L.SETGO_SCALE_DESC, false, function()
		if scaleDraft.on ~= nil then
			return scaleDraft.on
		end
		return ns.db.scaleOn == true
	end, function(on)
		scaleDraft.on = on and true or false
	end)
	local scale = ns.Pseudo("SETGO_SCALE", ns.G("UI_SCALE", L.SETGO_SCALE), L.SETGO_SCALE_DESC, 1, function()
		return scaleDraft.value or tonumber(ns.db.scale) or 1
	end, function(value)
		value = tonumber(value) or 1
		-- in steps of 5%
		value = math.floor(value / ns.SCALE_STEP + 0.5) * ns.SCALE_STEP
		scaleDraft.value = math.max(ns.SCALE_MIN, math.min(ns.SCALE_MAX, value))
	end)
	local scaleOptions = {
		minValue = ns.SCALE_MIN, maxValue = ns.SCALE_MAX,
		steps = math.floor((ns.SCALE_MAX - ns.SCALE_MIN) / ns.SCALE_STEP + 0.5),
		formatters = MinimalSliderWithSteppersMixin and MinimalSliderWithSteppersMixin.Label and FormatPercentageRounded
			and { [MinimalSliderWithSteppersMixin.Label.Right] = FormatPercentageRounded } or nil,
	}
	local function TabOptions()
		local list = {}
		for _, t in ipairs(ns.TABS) do
			list[#list + 1] = { value = t, label = L["TAB_" .. t:upper()] }
		end
		return list
	end
	-- the window size waits for Apply, at the bottom of the page (as the
	-- options of the modules' pages)
	setgo = {
		{ kind = "header", name = L.SETGO_GENERAL },
		{ kind = "dropdown", setting = tab, settings = { tab }, name = L.SETGO_TAB, tooltip = L.SETGO_TAB_DESC, options = TabOptions },
		{ kind = "checkbox", setting = minimap, settings = { minimap }, name = L.SETGO_MINIMAP, tooltip = L.SETGO_MINIMAP_DESC },
		{ kind = "checkbox", setting = mute, settings = { mute }, name = L.SETGO_MUTE, tooltip = L.SETGO_MUTE_DESC },
		{ kind = "header", name = L.SETGO_SCALE },
		{ kind = "cbslider", setting = scaleOn, second = scale, settings = { scaleOn, scale }, options = scaleOptions,
			name = scaleOn.name, tooltip = L.SETGO_SCALE_DESC, secondName = scale.name, secondTooltip = L.SETGO_SCALE_DESC },
		{ kind = "header", name = ns.G("KEY_BINDINGS", L.SCOPE_KEYS) },
		{ kind = "keybind", name = L.SETGO_KEY, tooltip = L.SETGO_KEY_DESC, action = "SETGO_TOGGLE" },
	}
	-- the Quick Menu (Quick.lua): its key
	local q = ns.QUICK_L
	if q then
		setgo[#setgo + 1] = { kind = "keybind", name = q.KEY, tooltip = q.KEY_DESC, action = "SETGO_QUICK" }
	end
	-- help: the tour (Tour.lua, Blizzard's help tips over SetGo! and its
	-- modules) and the GitHub address, side by side in the middle
	setgo[#setgo + 1] = { kind = "header", name = L.SETGO_HELP }
	setgo[#setgo + 1] = { kind = "custom", build = function(page, y, width)
		local W = ns.Widgets
		local bw, gap = 170, 8
		local tour = W.Button(page, bw, L.TOUR_BUTTON, function()
			if InCombatLockdown() then
				ns.Print(L.MSG_COMBAT)
				return
			end
			-- the guide, from the Profiles page
			ns.StartGuide()
		end, 24)
		tour:SetPoint("TOPLEFT", page, "TOPLEFT", math.floor(width / 2 - bw - gap / 2), -(y + 4))
		W.TipScripts(tour, L.TOUR_BUTTON, L.TOUR_BUTTON_DESC)
		local git = W.Button(page, bw, L.SETGO_GITHUB, function()
			ns.ui.Popup("SETGO_EXPORT", L.POPUP_GITHUB, { text = ns.GITHUB })
		end, 24)
		git:SetPoint("LEFT", tour, "RIGHT", gap, 0)
		W.TipScripts(git, L.SETGO_GITHUB, L.SETGO_GITHUB_DESC)
		return y + 4 + 24 + 10
	end }
	return setgo
end

ns.GITHUB = "https://github.com/CamaradaArmada/SetGo"

