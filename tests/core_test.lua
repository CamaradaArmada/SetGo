dofile(arg[1] .. "/mock.lua")
local B = arg[2]
ATLASES = setmetatable({}, { __index = function() return true end })
local function check(cond, msg)
	if not cond then
		error("FAIL: " .. msg, 2)
	end
	print("ok  " .. msg)
end

-- key bindings
local BINDINGS = { { "MOVEFORWARD", "MOVEMENT" }, { "JUMP", "MOVEMENT" }, { "ACTIONBUTTON1", "BAR" } }
bound = { W = "MOVEFORWARD", SPACE = "JUMP", ["1"] = "ACTIONBUTTON1" }
function GetNumBindings() return #BINDINGS end
function GetBinding(i)
	local b = BINDINGS[i]
	local keys = {}
	for k, c in pairs(bound) do if c == b[1] then keys[#keys + 1] = k end end
	table.sort(keys)
	return b[1], b[2], unpack(keys)
end
function SetBinding(key, cmd)
	check(not COMBAT, "SetBinding out of combat")
	bound[key] = cmd
end
SAVED = 0
function SaveBindings() SAVED = SAVED + 1 end
function LoadBindings() end
GetCurrentBindingSet = function() return 2 end
UnitClass = function() return "Mage", "MAGE" end
UnitGUID = function() return "Player-1" end
UnitFullName = function() return "Arthas", "Realm" end
UnitName = function() return "Arthas" end
C_AddOns = { DoesAddOnExist = function() return true end, IsAddOnLoaded = function() return true end,
	GetAddOnEnableState = function() return 2 end, EnableAddOn = function() end }

-- Edit Mode
C_EditMode = {
	GetLayouts = function() return LAYOUTS end,
	ConvertLayoutInfoToString = function(info) return "DATA:" .. info.layoutName end,
	ConvertStringToLayoutInfo = function(s) return { layoutName = "x", systems = {}, src = s } end,
	SaveLayouts = function(info)
		LAYOUTS = { layouts = {}, activeLayout = info.activeLayout }
		for i, l in ipairs(info.layouts) do if i > 2 then table.insert(LAYOUTS.layouts, l) end end
	end,
	SetActiveLayout = function(i) LAYOUTS.activeLayout = i end,
	IsValidLayoutName = function() return true end,
	OnLayoutAdded = function() end,
	OnLayoutDeleted = function() end,
}
EditModePresetLayoutManager = { GetCopyOfPresetLayouts = function() return { { layoutName = "Modern" }, { layoutName = "Classic" } } end }
Enum = { EditModeLayoutType = { Preset = 0, Account = 1, Character = 2 }, EditModePresetLayoutsMeta = { NumValues = 2 } }
LAYOUTS = { layouts = { { layoutName = "Mine", layoutType = 1 } }, activeLayout = 1 }

-- bars and CVars
BARS = { false, false, false, false, false, false, false }
function GetActionBarToggles() return unpack(BARS) end
function SetActionBarToggles(...) BARS = { ... } end
CV = { nameplateShowSelf = "0", cooldownViewerEnabled = "0", damageMeterEnabled = "1", showSwingTimer = "0" }
PERCHAR = { nameplateShowSelf = true }
C_CVar = {
	GetCVar = function(v) return CV[v] end,
	SetCVar = function(v, x) CV[v] = tostring(x) end,
	GetCVarBool = function(v) return CV[v] == "1" end,
	GetCVarInfo = function(v) return CV[v], "0", not PERCHAR[v], PERCHAR[v] or false end,
}

-- action bars
ACTIONS = { [1] = { "spell", 100 }, [2] = { "item", 200 }, [3] = { "macro", 5 } }
MACROS = { [5] = "Heal" }
CURSOR = nil
function GetActionInfo(slot) local a = ACTIONS[slot]; if a then return a[1], a[2], a[3] end end
function GetActionText(slot) local a = ACTIONS[slot]; if a and a[1] == "macro" then return MACROS[a[2]] end end
function GetMacroIndexByName(name) for i, n in pairs(MACROS) do if n == name then return i end end return 0 end
PickupSpell = nil
C_Spell = { PickupSpell = function(id) CURSOR = { "spell", id } end }
PickupItem = nil
C_Item = { PickupItem = function(id) CURSOR = { "item", id } end }
function PickupMacro(i) CURSOR = { "macro", i } end
function PickupAction(slot) CURSOR = ACTIONS[slot]; ACTIONS[slot] = nil end
function PlaceAction(slot) local old = ACTIONS[slot]; ACTIONS[slot] = CURSOR; CURSOR = old end
function ClearCursor() CURSOR = nil end
function GetCursorInfo() return CURSOR and CURSOR[1] end
TALENT = 1
function GetActiveTalentGroup() return TALENT end
CLOCK = 1000
function GetTime() return CLOCK end
C_SpecializationInfo = { GetActiveSpecGroup = function() return TALENT end }

-- old data: 0.16 (version 4), a profile using option profile 1; option
-- profile 2 used by none
SetGoDB = { version = 4, modules = { fannypack = true, chat = false },
	profiles = { Old = { id = "old1", layout = { name = "Mine" }, ui = { bar2 = true, cdm = true }, options = 1,
		keys = { W = "MOVEFORWARD" }, created = 10 } },
	optionProfiles = { [1] = { name = "Opts", settings = { charVar = 5 } }, [2] = { name = "Orphan", settings = { charVar = 7 } } } }
SetGoCharDB = { profile = "Old", optProfile = 1, ownModules = true, modules = { chat = true } }


MENUS = {}
local realCreate = CreateFrame
CreateFrame = function(kind, name, parent, template)
	local f = realCreate(kind, name, parent, template)
	if template == "WowStyle1DropdownTemplate" then
		-- like Blizzard's: the menu is built (and radios asked if selected) at once
		f.SetupMenu = function(self, gen) table.insert(MENUS, gen); gen(self, DESC_EVAL()) end
		f.GenerateMenu = function(self) for _, g in ipairs(MENUS) do end end
	end
	if template == "UICheckButtonTemplate" then
		f.SetChecked = function(self, v) self._checked = v end
		f.GetChecked = function(self) return self._checked end
	end
	return f
end
function DESC_EVAL()
	local d = {}
	for _, m in ipairs({ "CreateTitle", "CreateDivider", "CreateButton", "CreateCheckbox" }) do
		d[m] = function() return DESC_EVAL() end
	end
	d.CreateRadio = function(self, text, isSelected) if isSelected then isSelected() end return DESC_EVAL() end
	d.SetEnabled = function() end
	return d
end
local function Desc(log)
	local d = {}
	for _, m in ipairs({ "CreateTitle", "CreateDivider", "CreateRadio", "CreateButton", "CreateCheckbox" }) do
		d[m] = function(self, text, a, b)
			local child = Desc(log)
			table.insert(log, { m = m, text = text, a = a, b = b, d = child })
			return child
		end
	end
	d.SetEnabled = function(self, v) self.enabled = v end
	return d
end
MenuUtil = { CreateContextMenu = function(owner, gen) CTX = gen end }
local function RunCtx()
	local log = {}
	CTX(nil, Desc(log))
	return log
end
local function Click(log, text)
	for _, e in ipairs(log) do
		if e.text == text and e.a then
			e.a()
			return true
		end
	end
	error("no menu entry " .. tostring(text))
end
local function LastPopup() return POPUPS[#POPUPS] end

local ns = {}
LOAD(B .. "/SetGo", { "Libs/LibStub/LibStub.lua", "Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua", "Libs/LibDataBroker-1.1/LibDataBroker-1.1.lua" }, "SetGo", ns)
LOAD(B .. "/SetGo", { "Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua" }, "SetGo", ns)
LOAD(B .. "/SetGo", { "Locale.lua", "LocaleProfiles.lua", "Core.lua", "Data.lua", "Pages.lua", "Profiles.lua", "Skills.lua", "PresetData.lua", "Widgets.lua", "UI.lua", "ProfileForm.lua", "Welcome.lua", "Keybinds.lua", "Minimap.lua", "Init.lua" }, "SetGo", ns)
-- a module with one option (Chat)
local chatDB = { font = "A" }
local chatS = ns.Pseudo("SETGO_CHAT_font", "Font", "", "A", function() return chatDB.font end, function(v) chatDB.font = v end)
ns.RegisterModule({ key = "chat", title = "Chat", items = function() return { { kind = "dropdown", setting = chatS, settings = { chatS }, name = "Font", options = {} }, { kind = "keybind", name = "K", action = "X" } } end })
FIRE_EVENT("ADDON_LOADED", "SetGo")
-- fake settings
local live = { charVar = 1, accVar = false }
local function Setting(var, scope, default)
	return { GetVariable = function() return var end, GetName = function() return "Name " .. var end,
		GetValue = function() return live[var] end, SetValue = function(_, v) live[var] = v end,
		GetDefaultValue = function() return default end, GetVariableType = function() return type(default) end, smScope = scope }
end
local charS, accS = Setting("charVar", "char", 1), Setting("accVar", "account", false)
ns.known = { charVar = charS, accVar = accS }
ns.PathSettings = function(path) return path == "char" and { charS } or path == "account" and { accS } or {} end
SettingsPanel = CreateFrame("Frame", "SettingsPanel")
SettingsPanel.GetAllCategories = function() return { {} } end
local realBuild = ns.BuildPath
local VARIANTS = {}
ns.BuildPath = function(path, variant)
	if path == "options" then
		VARIANTS[#VARIANTS + 1] = variant or "default"
		local items = { { kind = "checkbox", setting = charS, settings = { charS }, name = "C" } }
		if variant ~= "char" then
			items[2] = { kind = "checkbox", setting = accS, settings = { accS }, name = "A", account = true }
		end
		return { { key = "p1", title = "One", items = items, variant = variant }, { key = "p2", title = "Two", items = {}, variant = variant } }
	end
	return realBuild(path)
end

-- migration (v7): keys and bars become the profile's own; settings its own
-- because it applied them
local old = SetGoDB.profiles.Old
check(SetGoDB.version == 7 and type(SetGoDB.shared) == "table", "version 7, shared set")
check(old.scope.settings == "profile" and old.scope.keys == "profile" and old.scope.bars == "profile", "Old: all its own")
check(old.custom == nil and old.settings.charVar == 5, "custom gone, settings kept")

FIRE_EVENT("PLAYER_ENTERING_WORLD", true, false)
RUN_TIMERS()
check(SetGoDB.shared.keys and SetGoDB.shared.keys.W == "MOVEFORWARD", "shared keys start from the game")
check(SetGoDB.shared.settings and SetGoDB.shared.settings.charVar == 1, "shared settings start from the game")

ns.Open()
check(ns.state.tab == "presets" and ns.state.group == "newpreset" and ns.creating.edit == "Old", "profiles: the form of the one in use")
check(not ns.FormDirty(), "nothing changed yet")
RELOADED = 0
ns.ApplyProfile("Old")
check(live.charVar == 5 and RELOADED == 1, "applied its own settings, reloaded")
ns.ResumeSkills()
check(ns.charDB.skills.old1 ~= nil, "its bars kept")

-- the left tabs: no Game Settings any more
check(#ns.TABS == 3 and ns.TABS[3] == "settings", "three tabs")
ns.Select("game")
check(ns.state.group == "newpreset", "old group: back to profiles")

-- Settings tab
ns.ShowFormTab("settings")
check(ns.state.group == "newpreset" and ns.form.tab == "settings", "settings tab on the form")
check(ns.form.scope.settings == "profile" and ns.form.scope.keys == "profile", "shows the profile's scopes")
ns.SetFormScope("keys", "global")
check(ns.FormDirty(), "scope change: dirty")
ns.FormButton()
check(old.scope.keys == "global" and old.keys and old.keys.W == "MOVEFORWARD", "saved: keys Global, its own kept")

-- recording keys: into the shared set, only what changed
SetGoDB.shared.keys.F1 = "OTHERCHAR" -- set by another character
bound.Q = "JUMP"
SaveBindings()
RUN_TIMERS()
check(SetGoDB.shared.keys.Q == "JUMP" and SetGoDB.shared.keys.F1 == "OTHERCHAR", "shared keys: change merged, other kept")
check(old.keys.Q == nil, "its own keys untouched")

-- recording settings: Blizzard's Options window closing
live.charVar = 6
FIRE_SCRIPT(SettingsPanel, "OnHide")
RUN_TIMERS()
check(old.settings.charVar == 6, "settings into its own")
ns.LeaveForm(function() ns.OpenForm("Old") end)
ns.ShowFormTab("settings")
ns.SetFormScope("settings", "global")
ns.FormButton()
live.charVar = 8
FIRE_SCRIPT(SettingsPanel, "OnHide")
RUN_TIMERS()
check(SetGoDB.shared.settings.charVar == 8 and old.settings.charVar == 6, "Global: into the shared ones, its own kept")

-- bars Global: nothing recorded, nothing put back
ns.SetFormScope("bars", "global")
ns.FormButton()
check(old.scope.bars == "global", "bars Global")
local keptBars = ns.charDB.skills.old1[1][1]
ACTIONS[1] = { "spell", 999 }
CLOCK = CLOCK + 100
FIRE_EVENT("ACTIONBAR_SLOT_CHANGED")
RUN_TIMERS()
check(ns.charDB.skills.old1[1][1] == keptBars, "Global bars: not recorded")
check(ns.ProfileDiff("Old").skills == 0, "Global bars: not counted")

-- a new profile: everything Global; Profile copies from the game or another
ns.SlotClick("options", nil)
check(ns.form.scope.settings == "global" and ns.form.scope.keys == "global" and ns.form.scope.bars == "global", "new: all Global")
ns.FormButton()
check(ns.form.tab == "modules", "Next: modules")
ns.FormButton()
check(ns.form.tab == "settings", "Next: settings")
ns.SetFormScope("keys", "profile")
check(ns.form.keys and ns.form.keys.Q == "JUMP", "Profile keys start from the game")
ns.SetFormScope("settings", "profile")
ns.FormCopyField("settings", old, "Old")
check(ns.form.scope.settings == "profile" and ns.form.settings.charVar == 8, "copied what Old applies (the shared ones)")
ns.FormCopyField("bars", nil, ns.L.COPY_CURRENT)
check(ns.form.skillsFrom == nil, "bars Global: no copy")
ns.SetFormScope("bars", "profile")
ns.FormCopyField("bars", nil, ns.L.COPY_CURRENT)
check(ns.form.skillsFrom == "current", "bars: current")
ns.Refresh()
local box
for _, f in ipairs(FRAMES) do
	if f._scripts.OnEditFocusGained then box = f end
end
box:SetText("Healer")
RELOADED = 0
ns.FormButton()
check(LastPopup().which == "SETGO_CONFIRM", "Save and Apply asks")
LastPopup().data.onAccept()
local healer = SetGoDB.profiles.Healer
check(healer and SetGoCharDB.profile == "Healer", "made and applied")
check(healer.scope.keys == "profile" and healer.keys.Q == "JUMP" and healer.scope.settings == "profile" and healer.settings.charVar == 8, "its own keys and settings")
check(healer.scope.bars == "profile", "its own bars")
ns.ResumeSkills()

-- several profiles on Global: applying one puts the shared set on
SetGoDB.shared.settings.charVar = 3
old.scope.settings = "global"
RELOADED = 0
ns.ApplyProfile("Old")
check(live.charVar == 3 and RELOADED == 1, "Global settings applied")
ns.ResumeSkills()

-- export / import: own settings travel, Global ones don't
local txt = ns.ExportProfile("Healer")
local pp = ns.ParseProfileText(txt)
check(pp.custom and pp.settings.charVar == 8, "own settings exported")
check(not ns.ParseProfileText(ns.ExportProfile("Old")).custom, "Global settings not exported")
ns.ImportProfile(txt)
check(ns.creating and ns.creating.edit == nil and ns.form.scope.settings == "profile" and ns.form.settings.charVar == 8, "import: own settings")
ns.LeaveForm(function() ns.OpenForm("Healer") end)

-- copy keeps scopes
local copy = ns.CopyProfile("Healer")
check(SetGoDB.profiles[copy].scope.keys == "profile" and SetGoDB.profiles[copy].keys.Q == "JUMP", "copy keeps its own keys")

-- modules tab and Save to active profile
ns.SelectTab("modules")
chatDB.font = "C"
ns.SaveToActiveProfile()
check(SetGoDB.profiles.Old.customModules and SetGoDB.profiles.Old.moduleSettings.SETGO_CHAT_font == "C", "modules saved")
ns.SelectTab("settings")
check(ns.state.group == "setgo", "SetGo! tab: its page")

-- menus
ns.SelectTab("presets")
ns.SlotMenu({ kind = "options", profile = "Healer" })
local log = RunCtx()
check(#log > 3, "card menu")
ns.ContextMenu(UIParent)
check(#RunCtx() > 3, "minimap menu")

-- closing with changes, combat
local F = _G.SetGoFrame
ns.SelectTab("presets")
ns.form.ui.bar3 = not ns.form.ui.bar3
ns.Toggle()
RUN_TIMERS()
check(F:IsShown() and LastPopup().which == "SETGO_UNSAVED", "unsaved: asks")
StaticPopupDialogs.SETGO_UNSAVED.OnButton3()
check(not F:IsShown(), "exit without saving")
ns.Open()
ns.SelectTab("modules")
FIRE_EVENT("PLAYER_REGEN_DISABLED")
check(not F:IsShown(), "combat: closed")
FIRE_EVENT("PLAYER_REGEN_ENABLED")
check(F:IsShown() and ns.state.group == "modules", "after combat: back where it was")
ns.Toggle()
RUN_TIMERS()
check(not F:IsShown(), "clean close")

-- 0.23: Copy from on Global goes into the shared set, after asking
ns.Open()
ns.LeaveForm(function() ns.OpenForm("Old") end)
ns.ShowFormTab("settings")
check(ns.form.scope.keys == "global", "Old keys Global")
ns.FormCopyField("keys", SetGoDB.profiles.Healer, "Healer")
check(ns.form.shared and ns.form.shared.keys.Q == "JUMP" and ns.FormDirty(), "Global copy waits on the form")
SetGoDB.profiles.Healer.keys.ZZ = "JUMP"
ns.FormButton()
check(SetGoDB.shared.keys.ZZ == nil and SetGoDB.shared.keys.Q == "JUMP" and SetGoDB.shared.keys.F1 == nil, "shared keys replaced on save")
-- bars: copied into the active profile wait for Apply; recording doesn't overwrite them
SetGoCharDB.profile = "Healer"
local H = SetGoDB.profiles.Healer
ns.charDB.skills.other = { [1] = { [1] = "spell:555" } }
SetGoDB.profiles.Tank = { id = "other", scope = { bars = "profile" }, created = 5 }
ns.LeaveForm(function() ns.OpenForm("Healer") end)
ns.ShowFormTab("settings")
ns.FormCopyField("bars", SetGoDB.profiles.Tank, "Tank")
ns.FormButton()
check(ns.charDB.skills[H.id][1][1] == "spell:555" and ns.charDB.copiedSkills == H.id, "bars copied, waiting")
ACTIONS[1] = { "spell", 777 }
CLOCK = CLOCK + 100
FIRE_EVENT("ACTIONBAR_SLOT_CHANGED")
RUN_TIMERS()
check(ns.charDB.skills[H.id][1][1] == "spell:555", "moving a button doesn't overwrite the copy")
local d = ns.ProfileDiff("Healer")
check(d.total > 0, "Apply shows something to do")
ns.ApplyProfile("Healer")
check(ns.charDB.copiedSkills == nil and ACTIONS[1] and ACTIONS[1][2] == 555, "applied: the copied bars on")
ns.ResumeSkills()
-- Apply and exit
local F = _G.SetGoFrame
ns.Open()
ns.form.ui.bar4 = not ns.form.ui.bar4
local want = ns.form.ui.bar4
ns.Toggle()
RUN_TIMERS()
check(LastPopup().which == "SETGO_UNSAVED", "asks")
StaticPopupDialogs.SETGO_UNSAVED.OnAccept()
check(not F:IsShown() and H.ui.bar4 == want and BARS[3] == want, "apply and exit: saved and applied")
-- the minimap button: a module's click, Shift for SetGo!
local quickOpened = 0
ns.RegisterModule({ key = "quick", title = "Quick!", items = function() return {} end, minimapClick = function() quickOpened = quickOpened + 1 end })
ns.SetModuleOn("quick", true)
local obj = LibStub("LibDataBroker-1.1"):GetDataObjectByName("SetGo")
SHIFT = false
IsShiftKeyDown = function() return SHIFT end
obj.OnClick(UIParent, "LeftButton")
check(quickOpened == 1 and not F:IsShown(), "click: Quick!")
SHIFT = true
obj.OnClick(UIParent, "LeftButton")
check(F:IsShown() and quickOpened == 1, "Shift+click: SetGo!")
ns.SetModuleOn("quick", false)
SHIFT = false
ns.Toggle()
obj.OnClick(UIParent, "LeftButton")
check(F:IsShown() and quickOpened == 1, "Quick! off: click opens SetGo!")
-- the module pages have a header
ns.SelectTab("modules")
ns.SelectTab("settings")
check(ns.state.group == "setgo", "SetGo! page")
print("ALL PASSED")
