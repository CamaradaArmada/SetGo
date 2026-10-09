local _, ns = ...
local L = ns.L

-- The modules (SetGo_Fetch, SetGo_Look, SetGo_Speak, SetGo_Hide) talk to the
-- core through this table: SetGo.RegisterModule, SetGo.Pseudo, SetGo.Print.
SetGo = ns

local function Try(func, ...)
	if type(func) ~= "function" then
		return
	end
	local results = { pcall(func, ...) }
	if results[1] then
		return unpack(results, 2)
	end
end
ns.Try = Try

-- SetGo!'s own sounds (book, page turns, checkboxes); off with the mute
-- option in SetGo! settings
function ns.Sound(kit, fallback)
	if ns.db and ns.db.mute then
		return
	end
	PlaySound(SOUNDKIT and SOUNDKIT[kit] or fallback)
end

function ns.Print(msg)
	print("|cff69ccf0SetGo!|r " .. msg)
end

--------------------------------------------------------------------------------
-- Saved data (see Profiles.lua for what a profile holds)
--   SetGoDB (account): profiles = the player's profiles { [name] = profile },
--     optionProfiles = { [1..3] = option profile }, lastPreset, modules
--     (switched on for the account), minimap
--   SetGoCharDB (character): seen, profile (the profile in use here),
--     optProfile (the option profile applied here last), skills (the action
--     bars, per profile and talent group), ownModules + modules
--------------------------------------------------------------------------------

-- What a profile switches on and off: action bars 2 to 8 and the elements
-- Edit Mode places but a setting turns on. They are left out of the option
-- pages and the option profiles, since the profile decides them.
ns.UI_ELEMENTS = {
	{ key = "bar2", bar = 1, var = "PROXY_SHOW_ACTIONBAR_2", n = 2 },
	{ key = "bar3", bar = 2, var = "PROXY_SHOW_ACTIONBAR_3", n = 3 },
	{ key = "bar4", bar = 3, var = "PROXY_SHOW_ACTIONBAR_4", n = 4 },
	{ key = "bar5", bar = 4, var = "PROXY_SHOW_ACTIONBAR_5", n = 5 },
	{ key = "bar6", bar = 5, var = "PROXY_SHOW_ACTIONBAR_6", n = 6 },
	{ key = "bar7", bar = 6, var = "PROXY_SHOW_ACTIONBAR_7", n = 7 },
	{ key = "bar8", bar = 7, var = "PROXY_SHOW_ACTIONBAR_8", n = 8 },
	{ key = "prd", cvar = "nameplateShowSelf", label = { "DISPLAY_PERSONAL_RESOURCE", "Personal Resource Display" } },
	{ key = "cdm", cvar = "cooldownViewerEnabled", label = { "COOLDOWN_VIEWER_LABEL", "Cooldown Manager" } },
	{ key = "defensives", cvar = "externalDefensivesEnabled", label = { "EXTERNAL_DEFENSIVES_LABEL", "External Defensives" } },
	{ key = "damage", cvar = "damageMeterEnabled", label = { "DAMAGE_METER_LABEL", "Damage Meter" } },
	{ key = "swing", cvar = "showSwingTimer", label = { "SWING_TIMER_LABEL", "Swing Timer" } },
}
ns.UI_VARS = {}
for _, e in ipairs(ns.UI_ELEMENTS) do
	ns.UI_VARS[e.var or e.cvar] = e
end

function ns.NewId()
	return ("%x%04x"):format(time(), math.random(0, 65535))
end

function ns.CharName()
	local name, realm
	if UnitFullName then
		name, realm = UnitFullName("player")
	end
	name = name or UnitName("player") or "?"
	if realm and realm ~= "" then
		return name .. "-" .. realm
	end
	return name
end

-- 0.17: the option profiles become each profile's own options, and the
-- modules a profile switches; this character's own module switches go
local function MigrateV5(db, charDB)
	local ops = type(db.optionProfiles) == "table" and db.optionProfiles or {}
	for _, p in pairs(db.profiles) do
		if type(p) == "table" then
			p.id = p.id or ns.NewId()
			local op = p.options and ops[p.options]
			if type(op) == "table" and type(op.settings) == "table" then
				local copy = {}
				for k, v in pairs(op.settings) do
					copy[k] = v
				end
				p.settings, p.custom = copy, true
			end
			p.options = nil
		end
	end
	db.optionProfiles = nil
	charDB.optProfile, charDB.ownModules = nil, nil
	if type(charDB.modules) == "table" and charDB.modules ~= db.modules then
		charDB.modules = nil
	end
end

-- 0.18: a profile changes the modules only when it says so (the ones that
-- already did keep doing it); keys and action bars always go with it
local function MigrateV6(db)
	for _, p in pairs(db.profiles) do
		if type(p) == "table" then
			if p.customModules == nil then
				p.customModules = type(p.modules) == "table" and next(p.modules) ~= nil
			end
			p.applyKeys, p.applySkills = nil, nil
		end
	end
end

-- 0.22: settings, keybinds and action bars each come from a shared set
-- (Global) or the profile's own (Profile). What profiles had stays theirs:
-- keybinds and bars their own, settings their own when they applied them.
local function MigrateV7(db)
	for _, p in pairs(db.profiles) do
		if type(p) == "table" then
			if type(p.scope) ~= "table" then
				p.scope = {
					settings = p.custom and "profile" or "global",
					keys = "profile",
					bars = "profile",
				}
			end
			p.custom, p.applyKeys, p.applySkills = nil, nil, nil
		end
	end
end

function ns.InitDB()
	if type(SetGoDB) ~= "table" then
		SetGoDB = {}
	end
	local db = SetGoDB
	if type(db.profiles) ~= "table" then
		db.profiles = {}
	end
	if type(db.templateExports) ~= "table" then
		db.templateExports = {}
	end
	db.keybinds, db.seeds = nil, nil
	if type(SetGoCharDB) ~= "table" then
		SetGoCharDB = {}
	end
	if (tonumber(db.version) or 0) < 5 then
		MigrateV5(db, SetGoCharDB)
	end
	if (tonumber(db.version) or 0) < 6 then
		MigrateV6(db)
	end
	if (tonumber(db.version) or 0) < 7 then
		MigrateV7(db)
	end
	db.version = 7
	-- the shared set (Global): filled from the game the first time it is used
	if type(db.shared) ~= "table" then
		db.shared = {}
	end
	if type(SetGoCharDB.skills) ~= "table" then
		SetGoCharDB.skills = {}
	end
	SetGoCharDB.clearUndo, SetGoCharDB.modules = nil, nil
	SetGoCharDB.optProfile, SetGoCharDB.ownModules = nil, nil
	ns.db, ns.charDB = db, SetGoCharDB
end

--------------------------------------------------------------------------------
-- Edit Mode layouts: stored by name, since each character can have its own
-- layouts and their numbers differ between characters.
--------------------------------------------------------------------------------

-- Preset layouts come first in the game's numbering. Forever has three
-- (Modern, Classic, Gamepad), Retail two: ask the client instead of assuming.
local function PresetCopies()
	local copies = EditModePresetLayoutManager and Try(EditModePresetLayoutManager.GetCopyOfPresetLayouts, EditModePresetLayoutManager)
	return type(copies) == "table" and copies or {}
end

local function Presets()
	local copies = PresetCopies()
	local count = tonumber(Enum and Enum.EditModePresetLayoutsMeta and Enum.EditModePresetLayoutsMeta.NumValues)
	count = count or (#copies > 0 and #copies) or 2
	local fallback = { ns.G("LAYOUT_STYLE_MODERN", "Modern"), ns.G("LAYOUT_STYLE_CLASSIC", "Classic"), ns.G("LAYOUT_STYLE_GAMEPAD", "Gamepad") }
	local list = {}
	for i = 1, count do
		list[i] = (copies[i] and copies[i].layoutName) or fallback[i] or ("Preset " .. i)
	end
	return list
end

-- the Classic preset, used when resetting to defaults
function ns.ClassicLayout()
	local classic = Enum and Enum.EditModePresetLayouts and Enum.EditModePresetLayouts.Classic
	if classic then
		for i, copy in ipairs(PresetCopies()) do
			if copy.layoutIndex == classic then
				return { preset = i }
			end
		end
	end
	return { preset = 2 }
end

function ns.GetLayouts()
	local info = C_EditMode and Try(C_EditMode.GetLayouts)
	local list = {}
	if type(info) ~= "table" then
		return list, nil
	end
	local presets = Presets()
	for i, name in ipairs(presets) do
		list[#list + 1] = { index = i, name = name, preset = true }
	end
	local charType = Enum and Enum.EditModeLayoutType and Enum.EditModeLayoutType.Character or 2
	for i, layout in ipairs(info.layouts or {}) do
		list[#list + 1] = { index = i + #presets, name = layout.layoutName, character = layout.layoutType == charType }
	end
	return list, info.activeLayout
end

function ns.LayoutRef(index)
	if not index then
		return nil
	end
	for _, l in ipairs((ns.GetLayouts())) do
		if l.index == index then
			if l.preset then
				return { preset = index }
			end
			return { name = l.name }
		end
	end
end

-- A layout of the player's own travels inside the profile as Blizzard's
-- export text, so the profile works on a character that doesn't have it.
function ns.LayoutData(name)
	local info = C_EditMode and Try(C_EditMode.GetLayouts)
	for _, layout in ipairs(type(info) == "table" and info.layouts or {}) do
		if layout.layoutName == name then
			return Try(C_EditMode.ConvertLayoutInfoToString, layout)
		end
	end
end

-- the layout the pages show: the staged one, or the active one
function ns.CurrentLayoutRef()
	if ns.stagedLayout then
		return { preset = ns.stagedLayout.preset, name = ns.stagedLayout.name }
	end
	local _, active = ns.GetLayouts()
	return ns.LayoutRef(active)
end

-- a layout's name as the player sees it
function ns.LayoutName(ref)
	if type(ref) ~= "table" then
		return nil
	end
	if ref.name then
		return ref.name
	end
	local l = ns.GetLayouts()[ref.preset or 0]
	return l and l.name
end

function ns.LayoutIndex(ref)
	if type(ref) ~= "table" then
		return nil
	end
	if ref.preset then
		return ref.preset
	end
	for _, l in ipairs((ns.GetLayouts())) do
		if not l.preset and l.name == ref.name then
			return l.index
		end
	end
end

--------------------------------------------------------------------------------
-- Values
--------------------------------------------------------------------------------

local function Same(a, b)
	if a == b then
		return true
	end
	local na, nb = tonumber(a), tonumber(b)
	return na ~= nil and nb ~= nil and math.abs(na - nb) < 0.0001
end
ns.Same = Same

-- a stored value in the type the setting expects
function ns.Coerce(setting, value)
	local kind = Try(setting.GetVariableType, setting)
	if kind == "boolean" then
		if type(value) == "boolean" then
			return value
		end
		return value == 1 or value == "1" or value == "true"
	elseif kind == "number" then
		return tonumber(value)
	elseif kind == "string" then
		return value ~= nil and tostring(value) or nil
	end
	return value
end

function ns.LiveValue(setting)
	return Try(setting.GetValue, setting)
end

-- A module can hold a CVar for a while and put it back later (Look!'s
-- soft targeting). Presets compare and save the value it goes back
-- to, not the module's own. Proxy settings that read a CVar say which.
local ANY = (Enum and Enum.SoftTargetEnableFlags and Enum.SoftTargetEnableFlags.Any) or 3
local GAMEPAD = (Enum and Enum.SoftTargetEnableFlags and Enum.SoftTargetEnableFlags.Gamepad) or 1
local PROXY_CVARS = {
	PROXY_ACTION_TARGETING = {
		cvar = "SoftTargetEnemy",
		get = function(v)
			return tonumber(v) == ANY
		end,
		set = function(on)
			return tostring(on and ANY or GAMEPAD)
		end,
	},
}

-- the modules, and the Quick Menu (Quick.lua), that may hold a value
local function Holders()
	local list = {}
	if ns.quickHold then
		list[1] = ns.quickHold
	end
	for _, def in ipairs(ns.modules or {}) do
		list[#list + 1] = def
	end
	return list
end

local function HeldValue(cvar)
	for _, def in ipairs(Holders()) do
		if def.RestoreValue then
			local v = Try(def.RestoreValue, cvar)
			if v ~= nil then
				return v
			end
		end
	end
end

function ns.SteadyValue(setting)
	local var = setting:GetVariable()
	if type(var) == "string" then
		local proxy = PROXY_CVARS[var]
		local held = HeldValue(proxy and proxy.cvar or var)
		if held ~= nil then
			if proxy then
				return proxy.get(held)
			end
			return ns.Coerce(setting, held)
		end
	end
	return ns.LiveValue(setting)
end

-- SetGo! wrote a setting a module holds: the module puts back this value
local function TellModules(var, value)
	local proxy = type(var) == "string" and PROXY_CVARS[var]
	local cvar, v = var, value
	if proxy then
		cvar, v = proxy.cvar, proxy.set(value)
	elseif type(v) == "boolean" then
		v = v and "1" or "0"
	end
	for _, def in ipairs(Holders()) do
		if def.SetRestoreValue then
			Try(def.SetRestoreValue, cvar, v)
		end
	end
end

--------------------------------------------------------------------------------
-- Staging: changes wait here until Apply. Only values that differ from the
-- game's current ones are kept.
--------------------------------------------------------------------------------

ns.staged = {}
ns.stagedLayout = nil

-- scope: "char" or "account" clears only that side; nil clears all
function ns.ClearStaged(scope)
	if not scope then
		wipe(ns.staged)
		ns.stagedLayout = nil
		return
	end
	for var in pairs(ns.staged) do
		local setting = ns.known and ns.known[var]
		if setting and ns.Scope(setting) == scope then
			ns.staged[var] = nil
		end
	end
	if scope == "char" then
		ns.stagedLayout = nil
	end
end

-- The options of the profile open on its form (its Options tab, with Apply
-- custom settings ticked): the pages show and change them, not the game.
-- nil: the pages show the game.
function ns.EditedOptions()
	return ns.optionsDraft
end

-- The module settings of the profile open on its form (its Modules tab,
-- with Change modules ticked): the module pages show and change them.
local function ModuleDraft(var)
	local md = ns.moduleDraft
	return md and ns.moduleVars and ns.moduleVars[var] and md or nil
end

function ns.Get(setting)
	local var = setting:GetVariable()
	local md = ModuleDraft(var)
	if md then
		local v = md.moduleSettings and md.moduleSettings[var]
		if v ~= nil then
			return v
		end
		return Try(setting.GetValue, setting)
	end
	local op = ns.EditedOptions()
	-- global options shown on an option profile's pages are the game's
	if op and not setting.smImmediate and ns.Scope(setting) == "char" then
		local stored = op.settings and op.settings[var]
		if stored ~= nil then
			return ns.Coerce(setting, stored)
		end
		return ns.SteadyValue(setting)
	end
	local v = ns.staged[var]
	if v ~= nil then
		return v
	end
	return ns.LiveValue(setting)
end

function ns.Set(setting, value)
	if value == nil then
		return
	end
	local var = setting:GetVariable()
	local md = ModuleDraft(var)
	if md then
		if type(value) ~= "table" then
			md.moduleSettings = md.moduleSettings or {}
			md.moduleSettings[var] = value
			if md.OnChanged then
				md:OnChanged()
			end
		end
		return
	end
	if setting.smImmediate then
		Try(setting.SetValue, setting, value)
		return
	end
	local op = ns.EditedOptions()
	if op and ns.Scope(setting) == "char" then
		-- straight into the option profile; the game changes when it is applied
		if type(value) ~= "table" then
			op.settings = op.settings or {}
			op.settings[var] = value
			if op.OnChanged then
				op:OnChanged()
			end
		end
		return
	end
	if Same(value, ns.LiveValue(setting)) then
		ns.staged[var] = nil
	else
		ns.staged[var] = value
	end
end

function ns.GetLayout()
	if ns.stagedLayout then
		return ns.LayoutIndex(ns.stagedLayout)
	end
	local _, active = ns.GetLayouts()
	return active
end

function ns.SetLayout(index)
	local _, active = ns.GetLayouts()
	if not index or index == active then
		ns.stagedLayout = nil
	else
		ns.stagedLayout = ns.LayoutRef(index)
	end
end

local function LayoutPending()
	if not ns.stagedLayout then
		return false
	end
	local index = ns.LayoutIndex(ns.stagedLayout)
	local _, active = ns.GetLayouts()
	return index ~= nil and index ~= active
end

function ns.CountStaged()
	local n = 0
	for var in pairs(ns.staged) do
		if ns.known[var] then
			n = n + 1
		end
	end
	if LayoutPending() then
		n = n + 1
	end
	return n
end

-- Blizzard's defaults for a list of items (one page or a whole path)
function ns.StageDefaults(items, withLayout)
	for _, item in ipairs(items) do
		for _, setting in ipairs(item.settings or {}) do
			local default
			if not setting.smNoDefault then
				default = Try(setting.GetDefaultValue, setting)
			end
			if default ~= nil then
				ns.Set(setting, default)
			end
		end
	end
	if withLayout then
		ns.SetLayout(ns.LayoutIndex(ns.ClassicLayout()))
	end
end

--------------------------------------------------------------------------------
-- Apply. The values go through Blizzard's own setting objects, so side
-- effects (a second CVar, a bitmask) match the Options window. The interface
-- reloads afterwards, which also clears any taint from running their code.
--------------------------------------------------------------------------------

local function NeedsBindingSave(setting)
	local flags = Settings and Settings.CommitFlag
	return flags and flags.SaveBindings and Try(setting.HasCommitFlag, setting, flags.SaveBindings) == true
end

-- The value goes straight to the setting's own writer (the CVar, the proxy's
-- setter, the modifier key). SetValue would also fire Blizzard's value
-- changed callbacks, which then run tainted by us and trip over secret
-- values (the player frame's status text, for one). The UI reloads after
-- Apply, so nothing needs those callbacks to refresh.
local function Write(setting, value)
	if type(setting.SetValueDerived) == "function" then
		setting:SetValueDerived(value)
	else
		setting:SetValue(value, true)
	end
end

-- Side effects that Blizzard runs from a value changed callback and that a
-- reload doesn't redo.
local SIDE_EFFECTS = {
	spellActivationOverlayOpacity = function(value)
		C_CVar.SetCVar("displaySpellActivationOverlays", (tonumber(value) or 0) > 0 and "1" or "0")
	end,
}

-- Returns changed, failed; nil when not allowed right now.
function ns.ApplyStaged()
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return nil
	end
	local changed, failed = 0, 0
	local bars, saveBindings

	for var, value in pairs(ns.staged) do
		local setting = ns.known[var]
		local bar = type(var) == "string" and tonumber(var:match("^PROXY_SHOW_ACTIONBAR_(%d+)$"))
		if setting and bar and GetActionBarToggles then
			-- one call for all bars, as Blizzard's cache would otherwise
			-- send outdated values when several change at once
			bars = bars or { GetActionBarToggles() }
			bars[bar - 1] = value and true or false
			changed = changed + 1
		elseif setting then
			if pcall(Write, setting, value) then
				changed = changed + 1
				TellModules(var, value)
				saveBindings = saveBindings or NeedsBindingSave(setting)
				if SIDE_EFFECTS[var] then
					Try(SIDE_EFFECTS[var], value)
				end
			else
				failed = failed + 1
			end
		end
	end
	if bars then
		Try(SetActionBarToggles, unpack(bars, 1, select("#", GetActionBarToggles())))
	end
	if saveBindings and SaveBindings then
		Try(SaveBindings, GetCurrentBindingSet and GetCurrentBindingSet() or 1)
	end

	if LayoutPending() then
		-- through the game's own Edit Mode API, which Edit Mode picks up
		-- from its layout update event. Last, so nothing saves an older copy
		-- of the layouts over ours before the reload.
		local index = ns.LayoutIndex(ns.stagedLayout)
		if index then
			Try(C_EditMode.SetActiveLayout, index)
			changed = changed + 1
		else
			failed = failed + 1
		end
	end
	ns.ClearStaged()
	return changed, failed
end

-- Saves the player's layouts as Blizzard does (the presets first, then
-- theirs), with the one at position pos active (or the index keep, when
-- given). Returns the index of the one at pos.
local function SaveWith(saved, pos, keep)
	local layouts = {}
	for _, copy in ipairs(PresetCopies()) do
		layouts[#layouts + 1] = copy
	end
	local presets = #layouts
	if presets == 0 then
		presets = #Presets()
	end
	for _, layout in ipairs(saved) do
		layouts[#layouts + 1] = layout
	end
	local index = presets + pos
	if not pcall(C_EditMode.SaveLayouts, { layouts = layouts, activeLayout = keep or index }) then
		return nil
	end
	return index
end
ns.SaveLayoutsWith = SaveWith

-- Makes an account layout from Blizzard's layout text, as Edit Mode's
-- import does: after the other account layouts, named base (with a number
-- when taken), and active (keepActive: the one active stays so). Returns its
-- index and name, or nil when there is no room (5 per type) or the text is
-- broken.
function ns.AccountLayoutsFull()
	local all = C_EditMode and Try(C_EditMode.GetLayouts)
	local accountType = Enum and Enum.EditModeLayoutType and Enum.EditModeLayoutType.Account or 1
	local max = tonumber(Constants and Constants.EditModeConsts and Constants.EditModeConsts.EditModeMaxLayoutsPerType) or 5
	local count = 0
	for _, layout in ipairs(type(all) == "table" and all.layouts or {}) do
		if layout.layoutType == accountType then
			count = count + 1
		end
	end
	return count >= max, max
end

function ns.CreateLayout(data, base, imported, keepActive)
	local info = Try(C_EditMode.ConvertStringToLayoutInfo, data)
	local all = C_EditMode and Try(C_EditMode.GetLayouts)
	if type(info) ~= "table" or type(all) ~= "table" then
		return nil
	end
	local full, max = ns.AccountLayoutsFull()
	if full then
		ns.Print(L.MSG_LAYOUT_FULL:format(max))
		return nil
	end
	local saved = all.layouts or {}
	local accountType = Enum and Enum.EditModeLayoutType and Enum.EditModeLayoutType.Account or 1
	local lastAccount, taken = 0, {}
	for i, layout in ipairs(saved) do
		taken[layout.layoutName] = true
		if layout.layoutType == accountType then
			lastAccount = i
		end
	end
	for _, name in ipairs(Presets()) do
		taken[name] = true
	end
	base = base or L.ADDON
	local name, n = base, 1
	while taken[name] or (C_EditMode.IsValidLayoutName and Try(C_EditMode.IsValidLayoutName, name) == false) do
		n = n + 1
		name = ("%s (%d)"):format(base, n)
		if n > 20 then
			return nil
		end
	end
	info.layoutName = name
	info.layoutType = accountType
	table.insert(saved, lastAccount + 1, info)
	local keep
	if keepActive then
		-- the one active moves down when the new one goes before it
		local presets = #PresetCopies()
		if presets == 0 then
			presets = #Presets()
		end
		keep = all.activeLayout or 1
		if keep >= presets + lastAccount + 1 then
			keep = keep + 1
		end
	end
	local index = SaveWith(saved, lastAccount + 1, keep)
	if index then
		-- as Edit Mode does after adding one: the game makes it active (unless
		-- kept) and tells Edit Mode, which reads the layouts again
		Try(C_EditMode.OnLayoutAdded, index, not keepActive, imported and true or false)
		ns.Print(L.MSG_LAYOUT_CREATED:format(name))
		return index, name
	end
end

-- Deletes one of the player's layouts by name, as Edit Mode does. The one
-- active goes back to Blizzard's first when it is the one deleted. Module
-- data for it (the Fetch! bar) goes too.
function ns.DeleteLayout(name)
	local all = C_EditMode and Try(C_EditMode.GetLayouts)
	if type(all) ~= "table" or InCombatLockdown() then
		return false
	end
	local saved, pos = {}, nil
	for i, layout in ipairs(all.layouts or {}) do
		if layout.layoutName == name and not pos then
			pos = i
		else
			saved[#saved + 1] = layout
		end
	end
	if not pos then
		return false
	end
	local presets = #PresetCopies()
	if presets == 0 then
		presets = #Presets()
	end
	local index = presets + pos
	local active = all.activeLayout or 1
	if active == index then
		active = 1
	elseif active > index then
		active = active - 1
	end
	local layouts = {}
	for _, copy in ipairs(PresetCopies()) do
		layouts[#layouts + 1] = copy
	end
	for _, layout in ipairs(saved) do
		layouts[#layouts + 1] = layout
	end
	if not pcall(C_EditMode.SaveLayouts, { layouts = layouts, activeLayout = active }) then
		return false
	end
	Try(C_EditMode.OnLayoutDeleted, index)
	for _, def in ipairs(ns.modules or {}) do
		if def.DeleteLayout then
			Try(def.DeleteLayout, name)
		end
	end
	ns.Print(L.MSG_LAYOUT_DELETED:format(name))
	return true
end

-- A layout's export text: a Blizzard preset (index) or one of the player's
-- (name)
function ns.LayoutText(ref)
	if type(ref) ~= "table" then
		return nil
	end
	if ref.name then
		return ns.LayoutData(ref.name)
	end
	local copy = PresetCopies()[ref.preset or 0]
	return copy and Try(C_EditMode.ConvertLayoutInfoToString, copy)
end

-- force: reload even with nothing changed here (a preset switching modules)
function ns.FinishApply(changed, failed, force)
	if not changed then
		return
	end
	if failed and failed > 0 then
		ns.Print(L.MSG_FAILED:format(failed))
	end
	if changed == 0 and force then
		ReloadUI()
		return
	end
	if changed == 0 then
		ns.Print(L.NO_CHANGES)
		return
	end
	ns.Print(L.MSG_APPLIED:format(changed))
	ReloadUI()
end

--------------------------------------------------------------------------------
-- The player's presets: this character's settings, the Edit Mode layout and
-- the keys. Global settings belong to the whole account, so a preset leaves
-- them alone (presets from before 0.10 may still hold some; they are skipped).
--------------------------------------------------------------------------------

function ns.CharSettings()
	return ns.PathSettings("char")
end

function ns.AllSettings()
	local list = {}
	for _, path in ipairs({ "account", "char" }) do
		for _, setting in ipairs(ns.PathSettings(path)) do
			list[#list + 1] = setting
		end
	end
	return list
end

function ns.RenameProfile(old, new)
	local db = ns.db.profiles
	if not db[old] or db[new] then
		return false
	end
	db[new], db[old] = db[old], nil
	if ns.charDB.profile == old then
		ns.charDB.profile = new
	end
	if ns.db.lastPreset == old then
		ns.db.lastPreset = new
	end
	-- it keeps its place in the list
	for i, name in ipairs(type(ns.db.order) == "table" and ns.db.order or {}) do
		if name == old then
			ns.db.order[i] = new
		end
	end
	return true
end

function ns.DeleteProfile(name)
	ns.db.profiles[name] = nil
	if ns.charDB.profile == name then
		ns.charDB.profile = nil
	end
	if ns.db.lastPreset == name then
		ns.db.lastPreset = nil
	end
end

-- oldest first, so a new profile takes the next free slot
local function ByCreation(store)
	local names = {}
	for name in pairs(store) do
		names[#names + 1] = name
	end
	table.sort(names, function(a, b)
		local ca = type(store[a]) == "table" and store[a].created or 0
		local cb = type(store[b]) == "table" and store[b].created or 0
		if ca ~= cb then
			return ca < cb
		end
		return a:lower() < b:lower()
	end)
	return names
end
ns.ByCreation = ByCreation

