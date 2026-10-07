local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- Profiles (SetGoDB.profiles): a setup to put on any character, a starting
-- point (nothing keeps it in step with the game on its own).
--   { id, icon, favorite, layout = { preset = n } or { name }, layoutMade,
--     ui = { [element key] = true/false } (action bars 2 to 8 and the
--       elements Edit Mode places but a setting turns on),
--     scope = { settings, keys, bars = "global" or "profile" }: each from
--       the shared set (SetGoDB.shared, Global) or its own (Profile); for
--       the action bars Global means SetGo! leaves them alone,
--     settings = { [variable] = value } (its own character options, used
--       when its scope is profile; kept when not),
--     customModules = true/false, modules = { [module key] = true/false },
--       moduleSettings = { [variable] = value } (the modules' own options;
--       applied only when customModules, kept when not),
--     keys = { [key] = command }, keysBy, keysAt (who saved them, when; its
--       own, used when its scope is profile),
--     created, saved, class }
-- What the player changes goes into the set the profile in use takes it
-- from: the keys when saved in Blizzard's key bindings menu (Keybinds.lua),
-- the settings when Blizzard's Options window closes (below), the action
-- bars as they are arranged, per character and talent group (Skills.lua).
--------------------------------------------------------------------------------

local function PresetOf(name)
	local p = name and ns.db.profiles[name]
	return type(p) == "table" and p or nil
end
ns.ProfileOf = PresetOf

-- the profile in use on this character, if it still exists
function ns.ActivePreset()
	local name = ns.charDB.profile
	return PresetOf(name) and name or nil
end
ns.ActiveProfile = ns.ActivePreset

local function Copy(t)
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in pairs(t) do
		out[k] = Copy(v)
	end
	return out
end

--------------------------------------------------------------------------------
-- Global or Profile: where a profile takes each part from
--------------------------------------------------------------------------------

ns.SCOPE_FIELDS = { "settings", "keys", "bars" }

function ns.ScopeOf(p, field)
	local scope = type(p) == "table" and type(p.scope) == "table" and p.scope[field]
	return scope == "profile" and "profile" or "global"
end

function ns.SharedScope()
	return { settings = "global", keys = "global", bars = "global" }
end

-- the settings a profile applies (nil: none kept yet)
function ns.SettingsOf(p)
	if ns.ScopeOf(p, "settings") == "profile" then
		return p.settings
	end
	return ns.db.shared.settings
end

-- the table its keys live in (.keys, .keysBy, .keysAt): its own or the
-- shared set
function ns.KeysHolder(p)
	if ns.ScopeOf(p, "keys") == "profile" then
		return p
	end
	return ns.db.shared
end

local function Save(name, p)
	local old = PresetOf(name)
	local now = time()
	p.id = p.id or (old and old.id) or ns.NewId()
	p.created = (old and old.created) or p.created or now
	p.class = (old and old.class) or p.class or select(2, UnitClass("player"))
	p.saved = now
	ns.db.profiles[name] = p
end

--------------------------------------------------------------------------------
-- What a profile switches on
--------------------------------------------------------------------------------

local function BarCount()
	return GetActionBarToggles and select("#", GetActionBarToggles()) or 0
end

local function CVarExists(cvar)
	return C_CVar and C_CVar.GetCVar and C_CVar.GetCVar(cvar) ~= nil
end

-- the elements this client has
function ns.UIElements()
	local list = {}
	local bars = BarCount()
	for _, e in ipairs(ns.UI_ELEMENTS) do
		if (e.bar and e.bar <= bars) or (e.cvar and CVarExists(e.cvar)) then
			list[#list + 1] = e
		end
	end
	return list
end

function ns.UILabel(e)
	if e.bar then
		return ns.G("OPTION_SHOW_ACTION_BAR", L.UI_BAR):format(e.n)
	end
	return ns.G(e.label[1], e.label[2])
end

-- the game's state: { [key] = true/false }
function ns.UILive()
	local live = {}
	local bars = GetActionBarToggles and { GetActionBarToggles() } or {}
	for _, e in ipairs(ns.UIElements()) do
		if e.bar then
			live[e.key] = bars[e.bar] and true or false
		else
			live[e.key] = C_CVar.GetCVarBool and C_CVar.GetCVarBool(e.cvar) == true or C_CVar.GetCVar(e.cvar) == "1"
		end
	end
	return live
end

-- the elements of a profile that differ from the game: labels
function ns.UIDiff(ui)
	local out = {}
	local live = ns.UILive()
	for _, e in ipairs(ns.UIElements()) do
		local want = type(ui) == "table" and ui[e.key]
		if want ~= nil and want ~= live[e.key] then
			out[#out + 1] = { label = ns.UILabel(e), short = e.bar and L.UI_BAR_SHORT:format(e.n) or ns.UILabel(e), on = want }
		end
	end
	return out
end

-- Switches them as the profile says (the ones it has). Returns how many
-- changed. Bars go in one call, as Blizzard's cache would otherwise send
-- outdated values when several change at once.
function ns.WriteUI(ui, onlyAccount)
	if type(ui) ~= "table" or InCombatLockdown() then
		return 0
	end
	local live = ns.UILive()
	local changed = 0
	local bars
	for _, e in ipairs(ns.UIElements()) do
		local want = ui[e.key]
		if want ~= nil and want ~= live[e.key] then
			if e.bar and not onlyAccount then
				bars = bars or { GetActionBarToggles() }
				bars[e.bar] = want and true or false
				changed = changed + 1
			elseif e.cvar then
				local _, _, _, perCharacter = C_CVar.GetCVarInfo(e.cvar)
				if not (onlyAccount and perCharacter) then
					C_CVar.SetCVar(e.cvar, want and "1" or "0")
					changed = changed + 1
				end
			end
		end
	end
	if bars then
		Try(SetActionBarToggles, unpack(bars, 1, BarCount()))
	end
	return changed
end

-- At login: an element kept for the whole account follows the profile this
-- character uses, as another character may have switched it since.
function ns.ReapplyAccountUI()
	local name = ns.ActivePreset()
	local p = PresetOf(name)
	if p and ns.WriteUI(p.ui, true) > 0 then
		ns.Print(L.MSG_UI_REAPPLIED:format(name))
	end
end

--------------------------------------------------------------------------------
-- A profile's own options (character options only)
--------------------------------------------------------------------------------

-- this character's options, as the game has them
function ns.OptionSnapshot()
	local settings = {}
	for _, setting in ipairs(ns.CharSettings()) do
		local value = ns.SteadyValue(setting)
		if value ~= nil and type(value) ~= "table" then
			settings[setting:GetVariable()] = value
		end
	end
	return settings
end

-- The settings as they were when last read: Blizzard's Options window
-- closing records only what changed since, into the set the profile in use
-- takes them from (so a change made on another character isn't undone).
local settingsBase

-- the shared set starts as the game is now (the first time it's needed)
function ns.EnsureShared()
	local shared = ns.db.shared
	if not shared.keys and ns.StoreKeys then
		ns.StoreKeys(shared)
	end
	if not shared.settings and ns.SettingsReady() then
		shared.settings = ns.OptionSnapshot()
	end
end

local function RecordSettings()
	if not (ns.db and ns.SettingsReady()) then
		return
	end
	local now = ns.OptionSnapshot()
	local base = settingsBase
	settingsBase = now
	local name = ns.ActivePreset()
	local p = PresetOf(name)
	if not (base and p) then
		return
	end
	local changed = {}
	for var, value in pairs(now) do
		if base[var] == nil or not ns.Same(base[var], value) then
			changed[var] = value
		end
	end
	if not next(changed) then
		return
	end
	local own = ns.ScopeOf(p, "settings") == "profile"
	local holder = own and p or ns.db.shared
	if type(holder.settings) ~= "table" then
		holder.settings = Copy(now)
	end
	for var, value in pairs(changed) do
		holder.settings[var] = value
	end
	ns.Print((own and L.MSG_SETTINGS_IN_PROFILE or L.MSG_SETTINGS_SHARED):format(name))
	if ns.Refresh then
		ns.Refresh()
	end
end

-- at login, once the game's settings are ready
function ns.WatchSettings()
	if not ns.SettingsReady() then
		return false
	end
	ns.EnsureShared()
	settingsBase = ns.OptionSnapshot()
	if SettingsPanel and not ns.settingsHooked then
		ns.settingsHooked = true
		SettingsPanel:HookScript("OnHide", function()
			C_Timer.After(0, RecordSettings)
		end)
	end
	return true
end

-- How this character differs from a set of options:
--   change = { { setting, value, name } } what Apply changes here
function ns.SettingsDiff(settings)
	local out = { change = {} }
	if type(settings) ~= "table" or not ns.SettingsReady() then
		return out
	end
	ns.AllSettings() -- builds ns.known
	for _, setting in ipairs(ns.CharSettings()) do
		local var = setting:GetVariable()
		local stored = settings[var]
		if stored ~= nil then
			local want = ns.Coerce(setting, stored)
			local live = ns.SteadyValue(setting)
			if live ~= nil and type(live) ~= "table" and not ns.Same(live, want) then
				out.change[#out.change + 1] = { setting = setting, value = want, name = Try(setting.GetName, setting) or var }
			end
		end
	end
	return out
end

-- its changes, waiting to be applied
local function StageOptions(settings)
	ns.optionsDraft = nil
	for _, c in ipairs(ns.SettingsDiff(settings).change) do
		ns.Set(c.setting, c.value)
	end
end

-- the modules installed, as they are now: { [key] = true/false }
function ns.ModuleStates()
	local states = {}
	for _, m in ipairs(ns.KNOWN_MODULES) do
		if ns.AddonInstalled(m.addon) then
			states[m.key] = ns.ModuleOn(m.key)
		end
	end
	return states
end

-- the modules a profile switches differently from now: { { key, on } }
local function ModulesDiff(modules)
	local out = {}
	for key, now in pairs(ns.ModuleStates()) do
		local want = type(modules) == "table" and modules[key]
		if want ~= nil and want ~= now then
			out[#out + 1] = { key = key, on = want }
		end
	end
	return out
end

-- every option the modules show, by variable (they register their pages
-- with SetGo.RegisterModule); keybinds are not options
function ns.ModuleVars()
	local vars = {}
	for _, m in ipairs(ns.modules or {}) do
		local ok, items = pcall(m.items)
		for _, item in ipairs(ok and type(items) == "table" and items or {}) do
			for _, setting in ipairs(item.settings or {}) do
				local var = Try(setting.GetVariable, setting)
				if var then
					vars[var] = setting
				end
			end
		end
	end
	ns.moduleVars = vars
	return vars
end

-- the modules' options as they are now
function ns.ModuleSnapshot()
	local out = {}
	for var, setting in pairs(ns.ModuleVars()) do
		local value = Try(setting.GetValue, setting)
		if value ~= nil and type(value) ~= "table" then
			out[var] = value
		end
	end
	return out
end

-- the modules' options a profile sets differently from now: { { setting, value } }
local function ModuleSettingsDiff(settings)
	local out = {}
	if type(settings) ~= "table" then
		return out
	end
	local vars = ns.ModuleVars()
	for var, want in pairs(settings) do
		local setting = vars[var]
		if setting then
			local have = Try(setting.GetValue, setting)
			if have ~= nil and not ns.Same(have, want) then
				out[#out + 1] = { setting = setting, value = want }
			end
		end
	end
	return out
end

-- Save to active profile (the Modules tab): which modules are on, and
-- their options
function ns.SaveModulesToProfile(name)
	local p = PresetOf(name)
	if not p then
		return false
	end
	p.modules = ns.ModuleStates()
	p.moduleSettings = ns.ModuleSnapshot()
	p.customModules = true
	Save(name, p)
	return true
end

local function ModuleTitle(key)
	for _, m in ipairs(ns.KNOWN_MODULES) do
		if m.key == key then
			return L[m.title] or key
		end
	end
	return key
end

--------------------------------------------------------------------------------
-- Profiles: what Apply would change here
--------------------------------------------------------------------------------

-- { total, lines = { text }, layout = nil | "missing" | "other" }
function ns.ProfileDiff(name)
	local p = PresetOf(name)
	-- short: the same, in a few words, for the form (the action bars left out)
	local diff = { total = 0, lines = {}, short = {}, skills = 0 }
	if not p then
		return diff
	end
	local lines, short = diff.lines, diff.short
	if p.layout then
		local index = ns.LayoutIndex(p.layout)
		local _, active = ns.GetLayouts()
		if not index then
			diff.layout = "missing"
			lines[#lines + 1] = L.DIFF_LAYOUT_GONE
			short[#short + 1] = L.SHORT_LAYOUT_GONE
		elseif active and index ~= active then
			diff.layout = "other"
			diff.total = diff.total + 1
			lines[#lines + 1] = L.DIFF_LAYOUT_TO:format(ns.LayoutName(p.layout) or "?")
			short[#short + 1] = L.SHORT_LAYOUT:format(ns.LayoutName(p.layout) or "?")
		end
	end
	for _, d in ipairs(ns.UIDiff(p.ui)) do
		diff.total = diff.total + 1
		lines[#lines + 1] = (d.on and L.DIFF_UI_ON or L.DIFF_UI_OFF):format(d.label)
		short[#short + 1] = (d.on and L.SHORT_ON or L.SHORT_OFF):format(d.short)
	end
	do
		local n = #ns.SettingsDiff(ns.SettingsOf(p)).change
		if n > 0 then
			diff.total = diff.total + n
			lines[#lines + 1] = L.SHORT_OPTIONS:format(n)
			short[#short + 1] = L.SHORT_OPTIONS:format(n)
		end
	end
	if p.customModules then
		for _, d in ipairs(ModulesDiff(p.modules)) do
			diff.total = diff.total + 1
			local text = (d.on and L.SHORT_ON or L.SHORT_OFF):format(ModuleTitle(d.key))
			lines[#lines + 1] = text
			short[#short + 1] = text
		end
		local n = #ModuleSettingsDiff(p.moduleSettings)
		if n > 0 then
			diff.total = diff.total + n
			lines[#lines + 1] = L.SHORT_MODULE_OPTIONS:format(n)
			short[#short + 1] = L.SHORT_MODULE_OPTIONS:format(n)
		end
	end
	local keys = ns.KeysHolder(p).keys
	if keys then
		local n = ns.KeysDiff(keys)
		if n > 0 then
			diff.total = diff.total + n
			lines[#lines + 1] = L.DIFF_KEYS:format(n)
			short[#short + 1] = L.SHORT_KEYS:format(n)
		end
	end
	if ns.ScopeOf(p, "bars") == "profile" and ns.SkillsDiff then
		local n = ns.SkillsDiff(p)
		if n > 0 then
			diff.total = diff.total + n
			diff.skills = n
			lines[#lines + 1] = L.DIFF_SKILLS:format(n)
		end
	end
	return diff
end
ns.PresetDiff = ns.ProfileDiff

-- This character now uses another profile: the action bars of the one it
-- leaves are kept first.
function ns.SetActiveProfile(name)
	if ns.charDB.profile ~= name and ns.SaveSkills then
		ns.SaveSkills()
	end
	ns.charDB.profile = name
	ns.db.lastPreset = name
end

-- Apply: the profile on this character. Its action bars (or, the first time
-- here, the ones it has now become its own), its keys, its option profile,
-- what it switches on and its layout; a reload when something needs it.
-- force: reload anyway (a layout was just made).
function ns.ApplyProfile(name, force)
	local p = PresetOf(name)
	if not p then
		return
	end
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return
	end
	if not ns.SettingsReady() then
		ns.Print(L.MSG_NOT_READY)
		return
	end
	-- a layout made for it, or the guide's first profile: Edit Mode opens
	-- after the reload (or at once, when nothing reloads)
	if p.newLayout or p.guide then
		force = force or p.newLayout
		p.newLayout, p.guide = nil, nil
		ns.charDB.openEditMode = true
	end
	ns.AllSettings() -- builds ns.known
	ns.optionsDraft = nil
	ns.SetActiveProfile(name)
	ns.EnsureShared()
	-- its action bars (when it keeps its own): put back now, then checked
	-- again once the server has confirmed them (after the reload, if one
	-- follows; see Skills.lua)
	if ns.ScopeOf(p, "bars") == "profile" and ns.RestoreSkills then
		ns.RestoreSkills(p)
		ns.QueueSkills(p)
	end
	-- its keys, or the shared ones (none kept yet: the game's become them)
	do
		local holder = ns.KeysHolder(p)
		if holder.keys then
			if ns.KeysDiff(holder.keys) > 0 then
				ns.ApplyKeys(holder.keys)
			end
		else
			ns.StoreKeys(holder)
		end
	end
	-- global options changed on its pages wait in the staging; they go too
	ns.ClearStaged("char")
	if p.layout then
		local index = ns.LayoutIndex(p.layout)
		if index then
			ns.SetLayout(index)
		else
			ns.Print(L.MSG_LAYOUT_MISSING:format(name))
		end
	end
	-- its settings, or the shared ones (the same: none kept yet, the
	-- game's become them)
	if ns.SettingsOf(p) then
		StageOptions(ns.SettingsOf(p))
	elseif ns.ScopeOf(p, "settings") == "profile" then
		p.settings = ns.OptionSnapshot()
	else
		ns.db.shared.settings = ns.OptionSnapshot()
	end
	-- its modules (they load or sleep on the reload) and their options (at
	-- once)
	local modules = 0
	if p.customModules then
		for _, d in ipairs(ModulesDiff(p.modules)) do
			ns.SetModuleOn(d.key, d.on)
			modules = modules + 1
		end
		ns.moduleDraft = nil
		for _, d in ipairs(ModuleSettingsDiff(p.moduleSettings)) do
			Try(d.setting.SetValue, d.setting, d.value)
		end
	end
	local ui = ns.WriteUI(p.ui) + modules
	local changed, failed = ns.ApplyStaged()
	if not changed then
		return
	end
	changed = changed + ui
	-- no reload: the check once the server has confirmed the bars
	if changed == 0 and not force and ns.ResumeSkills then
		C_Timer.After(1.5, ns.ResumeSkills)
	end
	if changed == 0 and (failed or 0) == 0 and not force then
		ns.Print(L.MSG_PRESET_ACTIVE:format(name))
		ns.OpenEditModeAfterReload()
		if ns.Refresh then
			ns.Refresh()
		end
		return
	end
	ns.FinishApply(changed, failed, force)
end
ns.ApplyUserPreset = ns.ApplyProfile

-- A new profile record from the game as it is now
local function NewProfile()
	local p = {
		id = ns.NewId(),
		ui = ns.UILive(),
		modules = ns.ModuleStates(),
		customModules = false,
		scope = ns.SharedScope(),
	}
	ns.EnsureShared()
	return p
end

-- Stores a profile without applying anything (the form, or a layout made
-- for it): a new one starts from the game as it is now and becomes this
-- character's. edit: the profile being edited (its name may change).
function ns.StoreProfile(name, edit, fields)
	local p = PresetOf(edit) or PresetOf(name)
	local new = p == nil
	p = p or NewProfile()
	if edit and edit ~= name and PresetOf(edit) then
		ns.RenameProfile(edit, name)
	end
	for k, v in pairs(fields or {}) do
		p[k] = v
	end
	Save(name, p)
	if new then
		ns.SetActiveProfile(name)
	end
	return p
end
ns.StorePreset = ns.StoreProfile

--------------------------------------------------------------------------------
-- A new profile, or the one being edited (opts.replace: its old name). opts:
--   name
--   layout = { use = index }                   a layout that exists
--          | { template = data, bars }         a new one, from a SetGo!
--                                              template (and its bars)
--          | { template = data, from, imported }  a copy or an import
--   ui, modules = { [key] = true/false }       nil: as the game has them
--   scope = { settings, keys, bars }, settings = { [variable] = value },
--   keys = { [key] = command } (its own), skillsFrom = a profile's id (its
--   action bars here are copied) or "current" (the bars as they are now)
--   icon
--   noApply: only stored (a new layout is made, but not made active)
-- Applied after storing unless noApply. Returns true.
--------------------------------------------------------------------------------

function ns.CreateProfile(opts)
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return false
	end
	local name = opts.name
	if not name or name == "" then
		return false
	end
	if PresetOf(name) and name ~= opts.replace then
		return false
	end
	if not opts.replace and ns.ProfilesFull() then
		ns.Print(L.MSG_PROFILES_FULL:format(ns.MAX_PROFILES))
		return false
	end
	if not ns.SettingsReady() then
		ns.Print(L.MSG_NOT_READY)
		return false
	end
	local layout = opts.layout or {}
	local p = opts.replace and PresetOf(opts.replace)
	if not p then
		p = NewProfile()
	elseif opts.replace ~= name then
		ns.RenameProfile(opts.replace, name)
	end
	if opts.ui then
		p.ui = Copy(opts.ui)
	end
	if opts.modules then
		p.modules = Copy(opts.modules)
	end
	if opts.customModules ~= nil then
		p.customModules = opts.customModules and true or false
	end
	if opts.moduleSettings then
		p.moduleSettings = Copy(opts.moduleSettings)
	end
	if opts.scope then
		p.scope = Copy(opts.scope)
	end
	if opts.settings then
		p.settings = Copy(opts.settings)
	end
	if opts.keys then
		p.keys = Copy(opts.keys)
		p.keysBy, p.keysAt = ns.CharName(), time()
	end
	if opts.skillsFrom and opts.skillsFrom ~= p.id then
		-- this character's bars for it: another profile's, or (current)
		-- what the bars hold when it is applied
		local from = opts.skillsFrom ~= "current" and ns.charDB.skills[opts.skillsFrom]
		ns.charDB.skills[p.id] = from and Copy(from) or nil
	end
	if opts.icon ~= nil then
		p.icon = opts.icon
	end
	local created
	if layout.use then
		p.layout = ns.LayoutRef(layout.use)
	elseif layout.template then
		-- a new account layout, named after the profile (copied from another
		-- layout, a template or an import)
		local index, made = ns.CreateLayout(layout.template, name, layout.imported, opts.noApply)
		if not index then
			return false
		end
		created = true
		if layout.from then
			ns.CopyLayoutData(layout.from, made)
		end
		p.layout = { name = made }
		p.layoutMade = true
		for var, on in pairs(layout.bars or {}) do
			local e = ns.UI_VARS[var]
			if e then
				p.ui[e.key] = on and true or false
			end
		end
	end
	Save(name, p)
	ns.Print(L.MSG_SAVED:format(name))
	-- a new layout: the interface reloads first, so every element shows in
	-- Edit Mode; it opens after the reload (and after the first profile's)
	if created then
		p.newLayout = true
	end
	if opts.noApply then
		if ns.Refresh then
			ns.Refresh()
		end
		return true
	end
	ns.ApplyProfile(name)
	return true
end

-- Edit Mode, after the reload that followed a new layout
function ns.OpenEditModeAfterReload()
	if not (ns.charDB and ns.charDB.openEditMode) then
		return
	end
	ns.charDB.openEditMode = nil
	C_Timer.After(1.5, function()
		if not InCombatLockdown() and EditModeManagerFrame and ShowUIPanel then
			ShowUIPanel(EditModeManagerFrame)
		end
	end)
end

--------------------------------------------------------------------------------
-- Order and favourites. The profiles show in the order the player sets
-- (SetGoDB.order); up to three are favourites, listed in the minimap menu.
--------------------------------------------------------------------------------

ns.MAX_FAVORITES = 3
-- as many as the cards that fit on the left page
ns.MAX_PROFILES = 6

function ns.ProfilesFull()
	local n = 0
	for _, p in pairs(ns.db.profiles) do
		if type(p) == "table" then
			n = n + 1
		end
	end
	return n >= ns.MAX_PROFILES
end

function ns.ProfileSlots()
	local db = ns.db
	db.order = type(db.order) == "table" and db.order or {}
	local list, seen = {}, {}
	for _, name in ipairs(db.order) do
		if PresetOf(name) and not seen[name] then
			seen[name] = true
			list[#list + 1] = name
		end
	end
	-- the ones not placed yet, oldest first
	for _, name in ipairs(ns.ByCreation(db.profiles)) do
		if not seen[name] and PresetOf(name) then
			seen[name] = true
			list[#list + 1] = name
		end
	end
	db.order = list
	return { unpack(list) }
end

function ns.MoveProfile(name, delta)
	local list = ns.ProfileSlots()
	for i, n in ipairs(list) do
		if n == name then
			local j = i + delta
			if j >= 1 and j <= #list then
				list[i], list[j] = list[j], list[i]
				ns.db.order = list
				return true
			end
			return false
		end
	end
	return false
end

function ns.Favorites()
	local list = {}
	for _, name in ipairs(ns.ProfileSlots()) do
		if PresetOf(name).favorite then
			list[#list + 1] = name
		end
	end
	return list
end

-- false when the three are taken
function ns.SetFavorite(name, on)
	local p = PresetOf(name)
	if not p then
		return false
	end
	if on and not p.favorite and #ns.Favorites() >= ns.MAX_FAVORITES then
		ns.Print(L.MSG_FAVORITES_FULL:format(ns.MAX_FAVORITES))
		return false
	end
	p.favorite = on and true or nil
	return true
end

--------------------------------------------------------------------------------
-- Export text: SGP1;N=<name>;I=<icon>;U=<element keys on>;S=<own settings>;
-- M=<modules on>;O=<module options>;L=<layout text>. Its name, icon, layout,
-- what it switches on, and its settings and modules when it changes them
-- (keys and action bars stay with each player and character).
--------------------------------------------------------------------------------

local function Escape(s)
	return (tostring(s):gsub("[%%;=|,:]", function(c)
		return ("%%%02X"):format(c:byte())
	end))
end

local function Unescape(s)
	return (s:gsub("%%(%x%x)", function(h)
		return string.char(tonumber(h, 16))
	end))
end

function ns.ExportProfile(name)
	local p = PresetOf(name)
	if not p then
		return nil
	end
	local data = ns.LayoutText(p.layout)
	if not data then
		ns.Print(L.MSG_LAYOUT_FAILED)
		return nil
	end
	local on = {}
	for _, e in ipairs(ns.UI_ELEMENTS) do
		if type(p.ui) == "table" and p.ui[e.key] ~= nil then
			on[#on + 1] = e.key .. (p.ui[e.key] and "+" or "-")
		end
	end
	local parts = { "SGP1", "N=" .. Escape(name), "U=" .. table.concat(on, ",") }
	if p.icon then
		parts[#parts + 1] = "I=" .. Escape(p.icon)
	end
	-- its own settings, and its modules with their options, when it changes
	-- them
	local function Values(t)
		local list = {}
		for var, v in pairs(t or {}) do
			local enc
			if type(v) == "boolean" then
				enc = v and "b1" or "b0"
			elseif type(v) == "number" then
				enc = "n" .. tostring(v)
			elseif type(v) == "string" then
				enc = "s" .. Escape(v)
			end
			if enc then
				list[#list + 1] = Escape(var) .. ":" .. enc
			end
		end
		table.sort(list)
		return table.concat(list, ",")
	end
	if ns.ScopeOf(p, "settings") == "profile" and p.settings then
		parts[#parts + 1] = "S=" .. Values(p.settings)
	end
	if p.customModules then
		local mods = {}
		for key, on in pairs(p.modules or {}) do
			mods[#mods + 1] = key .. (on and "+" or "-")
		end
		table.sort(mods)
		parts[#parts + 1] = "M=" .. table.concat(mods, ",")
		parts[#parts + 1] = "O=" .. Values(p.moduleSettings)
	end
	parts[#parts + 1] = "L=" .. Escape(data)
	return table.concat(parts, ";")
end

-- { name, icon, ui, layout = Blizzard's layout text, custom, settings,
--   customModules, modules, moduleSettings } or nil
function ns.ParseProfileText(text)
	if type(text) ~= "string" then
		return nil
	end
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	if text:sub(1, 5) ~= "SGP1;" then
		return nil
	end
	local out = { ui = {} }
	for part in text:sub(6):gmatch("[^;]+") do
		local key, value = part:match("^(%a)=(.*)$")
		if key == "N" then
			out.name = Unescape(value)
		elseif key == "I" then
			local v = Unescape(value)
			out.icon = tonumber(v) or v
		elseif key == "U" then
			for item in value:gmatch("[^,]+") do
				local k, sign = item:match("^(%w+)([%+%-])$")
				if k then
					out.ui[k] = sign == "+"
				end
			end
		elseif key == "L" then
			out.layout = Unescape(value)
		elseif key == "S" or key == "O" then
			local t = {}
			for item in value:gmatch("[^,]+") do
				local var, kind, v = item:match("^([^:]+):(%a)(.*)$")
				if var then
					var = Unescape(var)
					if kind == "b" then
						t[var] = v == "1"
					elseif kind == "n" then
						t[var] = tonumber(v)
					elseif kind == "s" then
						t[var] = Unescape(v)
					end
				end
			end
			if key == "S" then
				out.settings, out.custom = t, true
			else
				out.moduleSettings = t
			end
		elseif key == "M" then
			out.modules, out.customModules = {}, true
			for item in value:gmatch("[^,]+") do
				local k, sign = item:match("^(%w+)([%+%-])$")
				if k then
					out.modules[k] = sign == "+"
				end
			end
		end
	end
	if not out.layout or not out.name then
		return nil
	end
	return out
end

function ns.CopyProfile(name)
	local p = PresetOf(name)
	if not p then
		return nil
	end
	if ns.ProfilesFull() then
		ns.Print(L.MSG_PROFILES_FULL:format(ns.MAX_PROFILES))
		return nil
	end
	local copy = Copy(p)
	copy.id = ns.NewId()
	copy.layoutMade = nil
	copy.created, copy.saved = nil, nil
	local newName = ns.FreePresetName(L.COPY_NAME:format(name))
	Save(newName, copy)
	-- this character's action bars for it go with the copy
	local skills = ns.charDB.skills[p.id]
	if skills then
		ns.charDB.skills[copy.id] = Copy(skills)
	end
	return newName
end

function ns.DeleteProfileAll(name)
	local p = PresetOf(name)
	if p and p.id then
		ns.charDB.skills[p.id] = nil
	end
	ns.DeleteProfile(name)
end

-- copies a layout's module data (the Fetch! bar) to another layout
function ns.CopyLayoutData(fromName, toName)
	for _, def in ipairs(ns.modules) do
		if def.CopyLayout and fromName and toName then
			Try(def.CopyLayout, fromName, toName)
		end
	end
end

-- The layout that goes with a profile when it is deleted: only one SetGo!
-- made for it, still there, that no other profile uses. nil otherwise.
function ns.PresetLayoutToDelete(name)
	local p = PresetOf(name)
	local layout = p and p.layoutMade and p.layout and p.layout.name
	if not layout or not ns.LayoutIndex(p.layout) then
		return nil
	end
	for other, q in pairs(ns.db.profiles) do
		if other ~= name and type(q) == "table" and q.layout and q.layout.name == layout then
			return nil
		end
	end
	return layout
end

-- a free profile name: base, or base (2), (3)...
function ns.FreePresetName(base)
	local name, n = base, 1
	while PresetOf(name) do
		n = n + 1
		name = ("%s (%d)"):format(base, n)
	end
	return name
end

-- For the profile's page: what it holds, in lines
function ns.ProfileSummary(name)
	local p = PresetOf(name)
	local lines = {}
	if not p then
		return lines
	end
	local layoutName = ns.LayoutName(p.layout)
	if p.layout and not ns.LayoutIndex(p.layout) then
		lines[#lines + 1] = L.PRESET_LAYOUT_GONE:format(p.layout.name or "?")
	elseif layoutName then
		lines[#lines + 1] = L.PRESET_LAYOUT:format(layoutName)
	else
		lines[#lines + 1] = L.PRESET_NO_LAYOUT
	end
	local on = {}
	for _, e in ipairs(ns.UIElements()) do
		if type(p.ui) == "table" and p.ui[e.key] then
			on[#on + 1] = e.bar and tostring(e.n) or ns.UILabel(e)
		end
	end
	lines[#lines + 1] = L.PROFILE_UI:format(#on > 0 and table.concat(on, ", ") or L.NONE)
	return lines
end

local function Id(name)
	return (name:lower():gsub("[^%w]+", "_"))
end

--------------------------------------------------------------------------------
-- Layout templates: the author's starting points for a new profile
-- (PresetData.lua): an Edit Mode layout and which action bars show.
--   { name, data = Blizzard's layout text, bars = { [variable] = true/false } }
-- Made with /setgo template <name> from the active layout and bars; tests
-- are kept in SetGoDB.templateExports until they go into PresetData.lua.
--------------------------------------------------------------------------------

ns.LAYOUT_TEMPLATES = ns.LAYOUT_TEMPLATES or {}

function ns.LayoutTemplates()
	local list = {}
	for _, t in ipairs(ns.LAYOUT_TEMPLATES) do
		list[#list + 1] = t
	end
	local tests = {}
	for _, t in pairs(ns.db.templateExports or {}) do
		if type(t) == "table" and t.data then
			tests[#tests + 1] = t
		end
	end
	table.sort(tests, function(a, b)
		return (a.created or 0) < (b.created or 0)
	end)
	for _, t in ipairs(tests) do
		t.test = true
		list[#list + 1] = t
	end
	return list
end

function ns.ExportTemplate(name)
	local _, active = ns.GetLayouts()
	local data = ns.LayoutText(ns.LayoutRef(active))
	if not data then
		ns.Print(L.MSG_LAYOUT_FAILED)
		return
	end
	-- which of action bars 2 to 8 show
	local bars = {}
	local live = ns.UILive()
	for _, e in ipairs(ns.UIElements()) do
		if e.bar then
			bars[e.var] = live[e.key]
		end
	end
	ns.db.templateExports[Id(name)] = { name = name, data = data, bars = bars, created = time() }
	ns.Print(L.MSG_TEMPLATE_SAVED:format(name))
end
