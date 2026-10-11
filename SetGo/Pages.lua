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
	return setgo
end

