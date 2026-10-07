local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- Reads the options straight from Blizzard's Settings panel: categories,
-- their layouts and the initializers in them. Nothing here writes to
-- Blizzard's tables; values are only changed on Apply (see Core).
--------------------------------------------------------------------------------

ns.known = {} -- [variable] = setting, for everything shown in a path

-- Blizzard category labels (global strings) with English fallbacks
local CATEGORIES = {
	controls = { "CONTROLS_LABEL", "Controls" },
	interface = { "INTERFACE_LABEL", "Interface" },
	actionbars = { "ACTIONBARS_LABEL", "Action Bars" },
	combat = { "COMBAT_LABEL", "Combat" },
	social = { "SOCIAL_LABEL", "Social" },
	gamepad = { "GAMEPAD_LABEL", "Gamepad" },
	ping = { "PING_SYSTEM_LABEL", "Ping System" },
	advanced = { "ADVANCED_OPTIONS_LABEL", "Advanced" },
	nameplates = { "NAMEPLATE_OPTIONS_LABEL", "Nameplates" },
}

function ns.CategoryLabel(key)
	local c = CATEGORIES[key]
	return c and ns.G(c[1], c[2]) or key
end

-- Pages in Blizzard's order. Pages that end up empty are left out.
ns.PATHS = {
	char = {
		{ key = "actionbars", cats = { "actionbars" } },
		{ key = "controls", cats = { "controls" } },
		{ key = "interface", cats = { "interface", "social" } },
		{ key = "combat", cats = { "combat" } },
		{ key = "gamepad", cats = { "gamepad" }, gamepad = true },
		{ key = "advanced", cats = { "advanced" } },
		{ key = "nameplates", cats = { "nameplates" }, checksOnly = true },
	},
	-- what the book shows: character and global options together, in
	-- Blizzard's order (global ones hidden unless the player shows them)
	options = {
		{ key = "actionbars", cats = { "actionbars" } },
		{ key = "controls", cats = { "controls" } },
		{ key = "interface", cats = { "interface" } },
		{ key = "combat", cats = { "combat" } },
		{ key = "social", cats = { "social" } },
		{ key = "gamepad", cats = { "gamepad" }, gamepad = true },
		{ key = "ping", cats = { "ping" } },
		{ key = "advanced", cats = { "advanced" } },
		{ key = "nameplates", cats = { "nameplates" }, checksOnly = true },
	},
	account = {
		{ key = "controls", cats = { "controls" } },
		{ key = "interface", cats = { "interface" } },
		{ key = "actionbars", cats = { "actionbars" } },
		{ key = "combat", cats = { "combat" } },
		{ key = "social", cats = { "social" } },
		{ key = "gamepad", cats = { "gamepad" }, gamepad = true },
		{ key = "ping", cats = { "ping" } },
		{ key = "advanced", cats = { "advanced" } },
		{ key = "nameplates", cats = { "nameplates" }, checksOnly = true },
	},
}

--------------------------------------------------------------------------------
-- Scope: account or character
--------------------------------------------------------------------------------

-- Settings that don't map to a single CVar. Everything else is classified by
-- how the game stores its CVar.
local CHAR_PROXIES = {
	PROXY_SELF_CAST = true, -- autoSelfCast
	PROXY_ACTION_TARGETING = true, -- SoftTargetEnemy
	PROXY_ACCOUNT_COMPLETED_QUEST_FILTERING = true, -- minimap tracking
	PROXY_TRIVIAL_QUEST_FILTERING = true, -- minimap tracking
	PROXY_BLOCK_GUILD_INVITES = true,
}

function ns.Scope(setting)
	if setting.smScope then
		return setting.smScope
	end
	local var = Try(setting.GetVariable, setting)
	if type(var) ~= "string" then
		return "account"
	end
	if CHAR_PROXIES[var] or var:find("^PROXY_SHOW_ACTIONBAR_") then
		return "char"
	end
	if C_CVar and C_CVar.GetCVarInfo then
		local value, _, _, perCharacter = C_CVar.GetCVarInfo(var)
		if value ~= nil then
			return perCharacter and "char" or "account"
		end
	end
	return "account"
end

--------------------------------------------------------------------------------
-- Blizzard categories and initializers
--------------------------------------------------------------------------------

function ns.SettingsReady()
	local cats = SettingsPanel and SettingsPanel.GetAllCategories and Try(SettingsPanel.GetAllCategories, SettingsPanel)
	return type(cats) == "table" and #cats > 0
end

local function FindCategory(key)
	local label = ns.CategoryLabel(key)
	local cats = SettingsPanel and Try(SettingsPanel.GetAllCategories, SettingsPanel)
	if type(cats) ~= "table" then
		return nil
	end
	local seen = {}
	local function Search(list)
		for _, cat in ipairs(list or {}) do
			if not seen[cat] then
				seen[cat] = true
				if Try(cat.GetName, cat) == label then
					return cat
				end
				local found = Search(Try(cat.GetSubcategories, cat))
				if found then
					return found
				end
			end
		end
	end
	return Search(cats)
end

local function Initializers(key)
	local cat = FindCategory(key)
	local layout = cat and Try(SettingsPanel.GetLayout, SettingsPanel, cat)
	local list = layout and layout.GetInitializers and Try(layout.GetInitializers, layout)
	return type(list) == "table" and list or {}
end

local function TemplateOf(init)
	local t = (init.GetTemplate and Try(init.GetTemplate, init)) or init.frameTemplate or init.template
	return type(t) == "string" and t or ""
end

local function Shown(init)
	if init.ShouldShow then
		local ok, shown = pcall(init.ShouldShow, init)
		return not ok or shown ~= false
	end
	return true
end

-- controls SetGo! can draw; the rest are listed by /setgo report
local function KindOf(init, data)
	local template = TemplateOf(init)
	if template:find("SectionHeader") then
		return "header"
	end
	if data.bindingIndex then
		return "keybind"
	end
	if data.cbSetting and data.sliderSetting then
		return "cbslider"
	end
	if data.cbSetting and data.dropdownSetting then
		return "cbdropdown"
	end
	local setting = data.setting
	if type(setting) ~= "table" or not setting.GetVariable then
		return nil
	end
	if template:find("Keybind") then
		return nil
	end
	local options = data.options
	if type(options) == "function" then
		return "dropdown"
	end
	if type(options) == "table" and options.minValue and options.maxValue then
		return "slider"
	end
	if Try(setting.GetVariableType, setting) == "boolean" then
		return "checkbox"
	end
	return nil
end

ns.skipped = {}

local function Describe(init, data)
	local name = data.name or (data.setting and Try(data.setting.GetName, data.setting))
	return ("%s (%s)"):format(tostring(name or "?"), TemplateOf(init))
end

-- items of one category for one scope ("char", "account", or "all")
local function CollectCategory(key, scope, out)
	local header
	local inList = {}
	for _, init in ipairs(Initializers(key)) do
		inList[init] = true
	end
	for _, init in ipairs(Initializers(key)) do
		local data = type(init.data) == "table" and init.data or {}
		local kind = KindOf(init, data)
		if kind == "header" then
			header = data.name
		elseif kind == "keybind" then
			-- key bindings apply at once and are listed with the global options
			local action = GetBinding and Try(GetBinding, data.bindingIndex)
			if (scope == "account" or scope == "all") and action and Shown(init) then
				if header then
					out[#out + 1] = { kind = "header", name = header }
					header = nil
				end
				out[#out + 1] = { kind = "keybind", cat = key, action = action, name = (GetBindingName and GetBindingName(action)) or action, account = true }
			end
		elseif kind and Shown(init) then
			local item = { kind = kind, cat = key, tooltip = data.tooltip }
			if kind == "cbslider" or kind == "cbdropdown" then
				item.setting = data.cbSetting
				item.name = data.cbLabel or data.name
				item.second = data.sliderSetting or data.dropdownSetting
				item.secondName = data.sliderLabel or data.dropDownLabel
				item.secondTooltip = data.sliderTooltip or data.dropDownTooltip
				item.options = data.sliderOptions or data.dropdownOptions
				item.settings = { item.setting, item.second }
			else
				item.setting = data.setting
				item.name = Try(init.GetName, init) or Try(data.setting.GetName, data.setting)
				item.options = data.options
				item.settings = { item.setting }
			end
			local parent = init.GetParentInitializer and Try(init.GetParentInitializer, init)
			item.indent = (data.indent or (parent and inList[parent])) and true or false
			local itemScope = ns.Scope(item.setting)
			item.account = itemScope ~= "char"
			-- what a profile switches on (action bars 2 to 8, the elements)
			-- belongs to the profile, not to these pages
			local var = Try(item.setting.GetVariable, item.setting)
			if var and ns.UI_VARS[var] then
				itemScope = nil
			end
			if itemScope and (scope == "all" or itemScope == scope) then
				if header then
					out[#out + 1] = { kind = "header", name = header }
					header = nil
				end
				out[#out + 1] = item
				for _, s in ipairs(item.settings) do
					ns.known[s:GetVariable()] = s
				end
			end
		elseif not kind and init.data and not ns.skipped[init] then
			ns.skipped[init] = Describe(init, data)
		end
	end
end

-- opens Blizzard's Options on one category
function ns.OpenBlizzardCategory(key)
	local cat = FindCategory(key)
	local id = cat and Try(cat.GetID, cat)
	if id and Settings.OpenToCategory then
		Settings.OpenToCategory(id)
	end
end

--------------------------------------------------------------------------------
-- Modules: separate addons (SetGo_Fetch, SetGo_Look, SetGo_Speak,
-- SetGo_Hide, SetGo_Quick),
-- disabled until switched on in the Modules page. A loaded module adds its
-- own page with SetGo.RegisterModule; its options apply at once.
--------------------------------------------------------------------------------

-- A setting that isn't Blizzard's: the value lives wherever get/set put it,
-- and it applies at once (no staging, no reload). The default's type sets
-- the value type.
function ns.Pseudo(var, name, tooltip, default, get, set)
	local s = { smScope = "account", smImmediate = true, variable = var, name = name, tooltip = tooltip, default = default, get = get, set = set }
	function s:GetVariable()
		return self.variable
	end
	function s:GetName()
		return self.name
	end
	function s:GetValue()
		return self.get()
	end
	function s:SetValue(value)
		self.set(value)
	end
	function s:GetDefaultValue()
		return self.default
	end
	function s:GetVariableType()
		return type(self.default)
	end
	function s:HasCommitFlag()
		return false
	end
	return s
end

-- SetGo!'s own icon (the addon list, the minimap button, the window)
ns.ICON = "Interface\\Icons\\inv_misc_gear_01"

-- a module's icon: the one its .toc gives the addon list
function ns.ModuleIcon(addon)
	local meta = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
	local icon = meta and ns.Try(meta, addon, "IconTexture")
	if type(icon) == "string" and icon ~= "" then
		return icon
	end
	return 134400 -- the question mark
end

-- the modules SetGo! knows about, in the order they are listed; on: on
-- until the player switches it off (else off until switched on)
ns.KNOWN_MODULES = {
	{ addon = "SetGo_Quick", key = "quick", title = "MOD_QUICK", desc = "MOD_QUICK_DESC", on = true },
	{ addon = "SetGo_Fetch", key = "fetch", title = "MOD_FETCH", desc = "MOD_FETCH_DESC" },
	{ addon = "SetGo_Look", key = "adventure", title = "MOD_LOOK", desc = "MOD_LOOK_DESC" }, -- key kept from SetGo_Adventure
	{ addon = "SetGo_Speak", key = "chat", title = "MOD_SPEAK", desc = "MOD_SPEAK_DESC" }, -- key kept from SetGo_Chat
	{ addon = "SetGo_Hide", key = "hide", title = "MOD_HIDE", desc = "MOD_HIDE_DESC" },
}

ns.modules = {}

-- def = { key, title, items = function() return { ...items } end }
function ns.RegisterModule(def)
	ns.modules[#ns.modules + 1] = def
end

local function AddonInstalled(name)
	if C_AddOns and C_AddOns.DoesAddOnExist then
		return C_AddOns.DoesAddOnExist(name)
	end
	return C_AddOns and C_AddOns.GetAddOnInfo and C_AddOns.GetAddOnInfo(name) ~= nil
end

local function AddonEnabled(name)
	local state = C_AddOns.GetAddOnEnableState(name, UnitGUID("player"))
	return (tonumber(state) or 0) > 0
end

ns.AddonInstalled, ns.AddonEnabled = AddonInstalled, AddonEnabled

-- Modules are switched on and off by SetGo!, not in the game's addon list:
-- they always load, and one that is off only registers its settings page and
-- does nothing else. The switches are the account's (SetGoDB.modules); a
-- profile sets them when applied.
local function Flags()
	return ns.db and ns.db.modules
end

function ns.ModuleOn(key)
	local flags = Flags()
	if type(flags) ~= "table" then
		return true
	end
	if flags[key] == nil then
		for _, m in ipairs(ns.KNOWN_MODULES) do
			if m.key == key then
				return m.on == true
			end
		end
	end
	return flags[key] == true
end

function ns.SetModuleOn(key, on)
	local flags = Flags()
	if type(flags) ~= "table" then
		flags = {}
		ns.db.modules = flags
	end
	flags[key] = on and true or false
end

-- At login: the first time, the account's switches start from what loaded
-- on this character; and every installed module is kept enabled in the
-- game's addon list, so it loads (asleep when off). One more reload may be
-- needed the very first time.
function ns.SetupModules()
	local guid = UnitGUID("player")
	if type(ns.db.modules) ~= "table" then
		ns.db.modules = {}
		for _, m in ipairs(ns.KNOWN_MODULES) do
			if AddonInstalled(m.addon) then
				local loaded = C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(m.addon)
				ns.db.modules[m.key] = loaded and true or false
			end
		end
	end
	for _, m in ipairs(ns.KNOWN_MODULES) do
		if AddonInstalled(m.addon) and not AddonEnabled(m.addon) then
			Try(C_AddOns.EnableAddOn, m.addon, guid)
		end
	end
end

-- a module was switched on or off: the interface must reload to follow
function ns.OnModuleToggled()
	ns.moduleReloadPending = true
	if ns.AskReload then
		ns.AskReload()
	end
end

--------------------------------------------------------------------------------
-- Pages of a path
--------------------------------------------------------------------------------

local function GamepadOn()
	return C_CVar.GetCVarBool and C_CVar.GetCVarBool("GamePadEnable") == true
end

local built = {}

local function BuildPage(def, scope)
	local items = {}
	for i, cat in ipairs(def.cats) do
		local part = {}
		CollectCategory(cat, scope, part)
		if #part > 0 and i > 1 then
			-- a second category merged into the page gets its name as a title
			items[#items + 1] = { kind = "title", name = ns.CategoryLabel(cat) }
		end
		for _, item in ipairs(part) do
			items[#items + 1] = item
		end
	end
	if def.checksOnly then
		-- keep the page up to its last checkbox; the rest (sizes, auras,
		-- colors) stays in Blizzard's menu, one click away
		local last = 0
		for i, item in ipairs(items) do
			if item.kind == "checkbox" then
				last = i
			end
		end
		for i = #items, last + 1, -1 do
			table.remove(items, i)
		end
		if last > 0 then
			items[#items + 1] = { kind = "blizzard", cat = def.cats[1], name = L.NAMEPLATES_ADVANCED, tooltip = L.NAMEPLATES_ADVANCED_DESC }
		end
	end
	if def.module then
		for _, item in ipairs(def.module.items and def.module.items() or {}) do
			items[#items + 1] = item
		end
	end
	local count = 0
	for _, item in ipairs(items) do
		if item.settings then
			count = count + #item.settings
		elseif item.kind == "keybind" or item.kind == "note" then
			count = count + 1
		end
	end
	return {
		key = def.key,
		title = def.title or (def.layout and L.PAGE_LAYOUT) or ns.CategoryLabel(def.cats[1]),
		items = items,
		layout = def.layout,
		count = count,
		gamepad = def.gamepad,
	}
end

-- Every page of the path that has something to show. Built once per
-- session; the gamepad page is only listed while the gamepad is enabled.
-- "options": with or without the global options (variant "char" or "all";
-- by default as the player's Hide global options says). A page with no
-- character option is left out while they are hidden.
function ns.BuildPath(path, variant)
	if path == "options" then
		variant = variant or (ns.HideGlobal() and "char" or "all")
		local key = "options:" .. variant
		if not built[key] then
			local pages = {}
			for _, def in ipairs(ns.PATHS.options) do
				local page = BuildPage(def, variant)
				page.variant = variant
				if page.count > 0 or page.layout then
					pages[#pages + 1] = page
				end
			end
			built[key] = pages
		end
		local list = {}
		for _, page in ipairs(built[key]) do
			if not page.gamepad or GamepadOn() then
				list[#list + 1] = page
			end
		end
		return list
	end
	if path == "modules" then
		-- the Modules page, then one page per loaded module
		if not built.modules then
			-- one page per module (switched on and off by its button on the
			-- left page)
			local pages = {}
			for _, m in ipairs(ns.modules) do
				pages[#pages + 1] = BuildPage({ key = "module_" .. m.key, cats = {}, module = m, title = m.title }, "account")
			end
			built.modules = pages
		end
		return built.modules
	end
	if not built[path] then
		local scope = path == "char" and "char" or "account"
		ns.known = ns.known or {}
		local pages = {}
		for _, def in ipairs(ns.PATHS[path]) do
			local page = BuildPage(def, scope)
			if page.count > 0 or page.layout then
				pages[#pages + 1] = page
			end
		end
		built[path] = pages
	end
	local list = {}
	for _, page in ipairs(built[path]) do
		if not page.gamepad or GamepadOn() then
			list[#list + 1] = page
		end
	end
	return list
end

-- every setting of a path (including hidden gamepad ones)
function ns.PathSettings(path)
	ns.BuildPath(path)
	local list, seen = {}, {}
	for _, page in ipairs(built[path]) do
		for _, item in ipairs(page.items) do
			for _, s in ipairs(item.settings or {}) do
				if not seen[s] then
					seen[s] = true
					list[#list + 1] = s
				end
			end
		end
	end
	return list
end

-- items of the pages shown right now (for resets)
function ns.PathItems(path)
	local items = {}
	for _, page in ipairs(ns.BuildPath(path)) do
		for _, item in ipairs(page.items) do
			items[#items + 1] = item
		end
	end
	return items
end

-- /setgo find <text>: every option in Blizzard's menus whose name or
-- variable contains the text, with where it lives and what SetGo! makes of
-- it (the kind it would draw, shown or hidden, account or character).
function ns.Find(text)
	text = (text or ""):lower()
	if text == "" then
		return
	end
	local cats = SettingsPanel and Try(SettingsPanel.GetAllCategories, SettingsPanel)
	if type(cats) ~= "table" then
		ns.Print(L.MSG_NOT_READY)
		return
	end
	local found, seen = 0, {}
	local function Visit(cat, path)
		if seen[cat] then
			return
		end
		seen[cat] = true
		local name = Try(cat.GetName, cat) or "?"
		path = path and (path .. " > " .. name) or name
		local layout = Try(SettingsPanel.GetLayout, SettingsPanel, cat)
		local list = layout and layout.GetInitializers and Try(layout.GetInitializers, layout)
		for _, init in ipairs(type(list) == "table" and list or {}) do
			local data = type(init.data) == "table" and init.data or {}
			local setting = data.setting or data.cbSetting
			local var = setting and Try(setting.GetVariable, setting)
			local label = data.name or data.cbLabel or (setting and Try(setting.GetName, setting)) or ""
			local hay = (tostring(label) .. " " .. tostring(var or "")):lower()
			if hay:find(text, 1, true) then
				found = found + 1
				local kind = KindOf(init, data)
				print(("|cff69ccf0%s|r: %s [%s] template=%s kind=%s shown=%s scope=%s"):format(
					path, tostring(label), tostring(var), TemplateOf(init), tostring(kind),
					tostring(Shown(init)), setting and ns.Scope(setting) or "-"))
			end
		end
		for _, sub in ipairs(Try(cat.GetSubcategories, cat) or {}) do
			Visit(sub, path)
		end
	end
	for _, cat in ipairs(cats) do
		Visit(cat)
	end
	ns.Print(L.MSG_FOUND:format(found, text))
end

-- /setgo report: what each page holds, for tuning
function ns.Report()
	for _, path in ipairs({ "char", "account", "modules" }) do
		ns.BuildPath(path)
		for _, page in ipairs(built[path]) do
			ns.Print(("%s / %s: %d"):format(path, page.title, page.count))
		end
	end
	local n = 0
	for _, text in pairs(ns.skipped) do
		n = n + 1
		print("  skipped: " .. text)
	end
	ns.Print(("%d controls skipped"):format(n))
end
