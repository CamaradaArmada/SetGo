local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Pages that aren't Blizzard categories: Quick settings (the first page of
-- the book) and SetGo!'s own settings. Everything
-- here applies at once, straight to the game's CVars, like the key bindings
-- for the same options do. Nothing runs in the background.
--------------------------------------------------------------------------------

local function CVarBool(var)
	return C_CVar.GetCVarBool and C_CVar.GetCVarBool(var) or C_CVar.GetCVar(var) == "1"
end

local function CVarNumber(var, fallback)
	return tonumber(C_CVar.GetCVar(var)) or fallback
end

-- a few CVars (the UI scale) are locked in combat
local SECURE = { uiScale = true, useUiScale = true }

local function SetCVar(var, value)
	if SECURE[var] and InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return
	end
	C_CVar.SetCVar(var, tostring(value))
end

local function Toggle(var, name, tip)
	local s = ns.Pseudo("QS_" .. var, name, tip, false, function()
		return CVarBool(var)
	end, function(on)
		SetCVar(var, on and "1" or "0")
	end)
	return { kind = "checkbox", setting = s, settings = { s }, name = name, tooltip = tip }
end

local function Number(var, name, tip, fallback)
	return ns.Pseudo("QS_" .. var, name, tip, fallback, function()
		return CVarNumber(var, fallback)
	end, function(value)
		SetCVar(var, value)
	end)
end

local function Formatters(format)
	if MinimalSliderWithSteppersMixin and MinimalSliderWithSteppersMixin.Label then
		return { [MinimalSliderWithSteppersMixin.Label.Right] = format }
	end
end

local function Percent(value)
	return ("%d%%"):format(math.floor((tonumber(value) or 0) * 100 + 0.5))
end

local function Fps(value)
	return ("%d FPS"):format(math.floor((tonumber(value) or 0) + 0.5))
end

local function SliderRange(min, max, step, format)
	return { minValue = min, maxValue = max, steps = math.floor((max - min) / step + 0.5), formatters = Formatters(format) }
end

local function Slider(var, name, tip, min, max, step, format, fallback)
	local s = Number(var, name, tip, fallback or min)
	return { kind = "slider", setting = s, settings = { s }, name = name, tooltip = tip, options = SliderRange(min, max, step, format) }
end

-- a checkbox with its slider, as in Blizzard's graphics menu
local function Limited(boolVar, numVar, name, tip, min, max, step, format)
	local on = ns.Pseudo("QS_" .. boolVar, name, tip, false, function()
		return CVarBool(boolVar)
	end, function(value)
		SetCVar(boolVar, value and "1" or "0")
	end)
	local value = Number(numVar, name, tip, min)
	return {
		kind = "cbslider", setting = on, second = value, settings = { on, value },
		name = name, tooltip = tip, secondName = nil, options = SliderRange(min, max, step, format),
	}
end

local quick
function ns.QuickItems()
	if quick then
		return quick
	end
	local minRender = tonumber(GetMinRenderScale and GetMinRenderScale()) or 0.33
	local maxRender = tonumber(GetMaxRenderScale and GetMaxRenderScale()) or 2
	quick = {
		{ kind = "note", name = L.QUICK_NOTE },
		{ kind = "header", name = L.QUICK_TOOLS },
		{ kind = "button", name = L.CDM, tooltip = L.CDM_DESC, func = function() ns.OpenCooldownManager() end },
		{ kind = "button", name = L.QUICK_KEYBIND, tooltip = L.QUICK_KEYBIND_DESC, func = function() ns.OpenQuickKeybind() end },
		{ kind = "button", name = L.ALL_KEYBINDS, tooltip = L.ALL_KEYBINDS_DESC, func = function() ns.OpenKeybindings() end },
		{ kind = "header", name = L.QUICK_TOGGLES },
		Toggle("nameplateShowEnemies", L.QS_ENEMY_PLATES, L.QS_ENEMY_PLATES_DESC),
		Toggle("nameplateShowFriendlyPlayers", L.QS_FRIEND_PLATES, L.QS_FRIEND_PLATES_DESC),
		Toggle("lockActionBars", L.QS_LOCK_BARS, L.QS_LOCK_BARS_DESC),
		Toggle("autoSelfCast", L.QS_SELF_CAST, L.QS_SELF_CAST_DESC),
		Toggle("findYourselfAnywhere", L.QS_SELF_HIGHLIGHT, L.QS_SELF_HIGHLIGHT_DESC),
		Toggle("Sound_EnableMusic", L.QS_MUSIC, L.QS_MUSIC_DESC),
		Toggle("Sound_EnableAllSound", L.QS_SOUND, L.QS_SOUND_DESC),
		{ kind = "header", name = L.QUICK_INTERFACE },
		Limited("useUiScale", "uiScale", L.QS_UI_SCALE, L.QS_UI_SCALE_DESC, 0.65, 1.15, 0.01, Percent),
		{ kind = "header", name = L.QUICK_PERFORMANCE },
		Limited("useMaxFPS", "maxFPS", L.QS_FPS, L.QS_FPS_DESC, 8, 200, 1, Fps),
		Limited("useMaxFPSBk", "maxFPSBk", L.QS_FPS_BG, L.QS_FPS_BG_DESC, 8, 200, 1, Fps),
		Slider("RenderScale", L.QS_RENDER, L.QS_RENDER_DESC, minRender, maxRender, 0.01, Percent, 1),
		{ kind = "header", name = L.QUICK_SOUND },
		Slider("Sound_MasterVolume", L.QS_VOL_MASTER, nil, 0, 1, 0.01, Percent, 1),
		Slider("Sound_MusicVolume", L.QS_VOL_MUSIC, nil, 0, 1, 0.01, Percent, 0.4),
		Slider("Sound_SFXVolume", L.QS_VOL_SFX, nil, 0, 1, 0.01, Percent, 1),
		Slider("Sound_AmbienceVolume", L.QS_VOL_AMBIENCE, nil, 0, 1, 0.01, Percent, 0.6),
		Slider("Sound_DialogVolume", L.QS_VOL_DIALOG, nil, 0, 1, 0.01, Percent, 1),
		Toggle("Sound_EnableSoundWhenGameIsInBG", L.QS_SOUND_BG, L.QS_SOUND_BG_DESC),
	}
	return quick
end

--------------------------------------------------------------------------------
-- SetGo!'s own settings
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
	local function TabOptions()
		local list = {}
		for _, t in ipairs(ns.TABS) do
			list[#list + 1] = { value = t, label = L["TAB_" .. t:upper()] }
		end
		return list
	end
	setgo = {
		{ kind = "dropdown", setting = tab, settings = { tab }, name = L.SETGO_TAB, tooltip = L.SETGO_TAB_DESC, options = TabOptions },
		{ kind = "checkbox", setting = minimap, settings = { minimap }, name = L.SETGO_MINIMAP, tooltip = L.SETGO_MINIMAP_DESC },
		{ kind = "checkbox", setting = mute, settings = { mute }, name = L.SETGO_MUTE, tooltip = L.SETGO_MUTE_DESC },
		{ kind = "keybind", name = L.SETGO_KEY, tooltip = L.SETGO_KEY_DESC, action = "SETGO_TOGGLE" },
	}
	-- the Quick Menu (Quick.lua): its key
	local q = ns.QUICK_L
	if q then
		setgo[#setgo + 1] = { kind = "keybind", name = q.KEY, tooltip = q.KEY_DESC, action = "SETGO_QUICK" }
	end
	-- the tour (Tour.lua): Blizzard's help tips over SetGo! and its modules
	setgo[#setgo + 1] = { kind = "button", name = L.TOUR_BUTTON, tooltip = L.TOUR_BUTTON_DESC, func = function()
		if InCombatLockdown() then
			ns.Print(L.MSG_COMBAT)
			return
		end
		ns.HideKeep()
		if not ns.StartTour() then
			ns.Print(L.MSG_TOUR_NONE)
		end
	end }
	-- the presets: each one made into a profile of its own and applied
	local presets = ns.PresetList()
	if #presets > 0 then
		setgo[#setgo + 1] = { kind = "header", name = L.PRESETS }
		setgo[#setgo + 1] = { kind = "note", name = L.PRESETS_PAGE_NOTE }
		for _, entry in ipairs(presets) do
			setgo[#setgo + 1] = { kind = "button", name = entry.name, tooltip = entry.desc or L.WIZ_PRESET_TIP, func = function()
				ns.ApplyPreset(entry)
			end }
		end
	end
	return setgo
end

