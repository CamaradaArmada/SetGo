local _, ns = ...
local L, W = ns.L, ns.Widgets
local Try = ns.Try
local U = ns.ui

--------------------------------------------------------------------------------
-- Right page: a profile's form, a new one or one in the list.
--   On top, on every tab: its icon (round), its name (a headline you can
--   write in), Copy from (what the tab shows: as the game has it now, or
--   from another profile), then the three tabs.
--   Layout: its Edit Mode layout (Blizzard's two, then the account's in a
--     short list that scrolls, + New last; right click on + New: what the new
--     one copies), action bars 1 to 8 and the elements it switches on.
--   Modules: Change modules (unticked: the profile leaves them alone), then
--     each module, one open at a time: on or off, and its options.
--   Settings: character settings, keybinds and action bars, each Global
--     (the shared set; for the bars, left to the player) or Profile (its
--     own, with Copy from).
--   At the bottom, always: one button. A new profile: Next until every tab
--     has been seen, then Save and Apply. One in the list: Save when
--     something changed, then Apply.
--   ns.creating = { edit = name or nil } while the form is open
--------------------------------------------------------------------------------

local form = {}
ns.form = form

-- Layout (its layout, bars and frames, then the settings), Addons (the
-- modules, then the other addons) and Interface Tweaks
local ALL_TABS = { "layout", "addons", "tweaks" }
-- the old tabs, now parts of these
local TAB_OF = { settings = "layout", modules = "addons" }

-- other addons installed (Ace3 ones may load later, on demand: looked at
-- each time)
local function HasOtherAddons()
	return ns.AddonList and (#ns.AddonList() > 0 or #ns.AceAddons() > 0) or false
end

local function Tabs()
	return ALL_TABS
end
local BLIZZARD_TINT = { 0.12, 0.23, 0.45 } -- Blizzard's layouts: blue ink
local CELL_H, CELL_GAP = 28, 3
local DEFAULT_ICON = 134400 -- the question mark
local HEAD_H = 76 -- the name and the button, then Copy from and Export
local TABS_TOP = U.PAD_TOP + HEAD_H
local TAB_H = 28
local BODY_TOP = TABS_TOP + TAB_H + 18
local FOOT_H = 44 -- the line, Back and Next
local BODY_H = 564 - BODY_TOP - FOOT_H
local ROW_H = 30 -- Change modules

local head, foot, np

local function Copy(t)
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in pairs(t) do
		out[k] = v
	end
	return out
end

local function Flag(v)
	return v and true or false
end

local function SameFlags(a, b)
	a, b = a or {}, b or {}
	for k, v in pairs(a) do
		if Flag(v) ~= Flag(b[k]) then
			return false
		end
	end
	for k, v in pairs(b) do
		if Flag(v) ~= Flag(a[k]) then
			return false
		end
	end
	return true
end

local function SameValues(a, b)
	a, b = a or {}, b or {}
	for k, v in pairs(a) do
		if b[k] ~= v then
			return false
		end
	end
	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end
	return true
end

local function NameText()
	return head and strtrim(head.name:GetText() or "") or ""
end

-- the name on the form (the title shows it)
function ns.SetFormName(name)
	if head then
		head.name:SetText(name or "")
		ns.Refresh()
	end
end

function ns.FormName()
	local name = NameText()
	return name ~= "" and name or nil
end

local function TabIndex(tab)
	for i, t in ipairs(Tabs()) do
		if t == tab then
			return i
		end
	end
	return 1
end

local function LayoutText(l)
	return l.preset and ns.G("HUD_EDIT_MODE_PRESET_LAYOUT", "%s"):format(l.name) or l.name
end

-- the layouts the grid shows: Blizzard's first two, then the account's
-- (character layouts are left out)
local function GridLayouts()
	local list, active = ns.GetLayouts()
	local blizzard, account = {}, {}
	for _, l in ipairs(list) do
		if l.preset then
			if #blizzard < 2 then
				blizzard[#blizzard + 1] = l
			end
		elseif not l.character then
			account[#account + 1] = l
		end
	end
	return blizzard, account, active
end

--------------------------------------------------------------------------------
-- The presets menu: a new profile starts here. Current configuration, then
-- Blizzard's two layouts, side by side, then SetGo!'s presets, one card
-- each. A card is picked; Apply (the bottom) makes it a profile at once,
-- Customize opens the profile's tabs with it filled in.
-- onPick(entry): entry from ns.CurrentPreset(), ns.BlizzardPresets() or
-- ns.PresetList(). Returns the height used and the cards.
--------------------------------------------------------------------------------

function ns.BuildPresetMenu(parent, width, y, onPick)
	local function Label(at, text)
		local fs = W.Text(parent, W.FONT_SMALL, width, text, 0.8)
		fs:SetPoint("TOPLEFT", 0, -at)
		return at + 16
	end
	local cards = {}
	-- what is on now
	do
		local entry = ns.CurrentPreset()
		local c = CreateFrame("Button", nil, parent)
		c:SetSize(width, 34)
		c:SetPoint("TOPLEFT", 0, -y)
		U.Card(c)
		c:Look(0.07, 0.35, false)
		local t = W.Text(c, W.FONT_BODY, width - 20, entry.name)
		t:SetPoint("LEFT", 10, 0)
		Try(t.SetWordWrap, t, false)
		c.entry = entry
		c:SetScript("OnClick", function()
			onPick(entry)
		end)
		W.TipScripts(c, entry.name, entry.desc)
		cards[#cards + 1] = c
		y = y + 34 + 12
	end
	local blizzard = ns.BlizzardPresets()
	if #blizzard > 0 then
		y = Label(y, L.PRESETS_BLIZZARD)
		local n = #blizzard
		local w = (width - 6 * (n - 1)) / n
		for i, entry in ipairs(blizzard) do
			local c = CreateFrame("Button", nil, parent)
			c:SetSize(w, 34)
			c:SetPoint("TOPLEFT", (i - 1) * (w + 6), -y)
			U.Card(c, BLIZZARD_TINT)
			c:Look(0.07, 0.35, false)
			local t = W.Text(c, W.FONT_BODY, w - 20, entry.name)
			t:SetPoint("LEFT", 10, 0)
			Try(t.SetWordWrap, t, false)
			c.entry = entry
			c:SetScript("OnClick", function()
				onPick(entry)
			end)
			W.TipScripts(c, entry.name, L.PRESET_BLIZZARD_TIP)
			cards[#cards + 1] = c
		end
		y = y + 34 + 12
	end
	local ours = ns.PresetList()
	if #ours > 0 then
		y = Label(y, L.PRESETS_SETGO)
		local CARD_H, SIZE = 56, 42
		for _, entry in ipairs(ours) do
			local c = CreateFrame("Button", nil, parent)
			c:SetSize(width, CARD_H)
			c:SetPoint("TOPLEFT", 0, -y)
			U.Card(c)
			c:Look(0.07, 0.35, false)
			local pic = ns.RoundIcon(c, SIZE)
			pic:SetPoint("LEFT", 7, 0)
			pic:SetTexture(entry.icon or DEFAULT_ICON)
			local t = W.Text(c, W.FONT_HEADER, width - SIZE - 26, entry.name)
			t:SetPoint("TOPLEFT", pic, "TOPRIGHT", 10, 0)
			Try(t.SetWordWrap, t, false)
			local d = W.Text(c, W.FONT_SMALL, width - SIZE - 26, entry.desc or "", 0.8)
			d:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -3)
			Try(d.SetMaxLines, d, 2)
			c.entry = entry
			c:SetScript("OnClick", function()
				onPick(entry)
			end)
			W.TipScripts(c, entry.name, L.WIZ_PRESET_TIP)
			cards[#cards + 1] = c
			y = y + CARD_H + 6
		end
	end
	return y, cards
end

-- the layout in use, if the grid shows it; else Blizzard's first
local function ActiveGridLayout()
	local blizzard, account, active = GridLayouts()
	for _, group in ipairs({ blizzard, account }) do
		for _, l in ipairs(group) do
			if l.index == active then
				return active
			end
		end
	end
	return blizzard[1] and blizzard[1].index or 1
end

--------------------------------------------------------------------------------
-- The form's values
--------------------------------------------------------------------------------

-- the pages call this when one of the profile's options changes
local function OnChanged()
	if ns.RefreshFormButton then
		ns.RefreshFormButton()
	end
end

-- edit: the profile (nil: a new one)
local function FormDefaults(edit)
	local p = edit and ns.ProfileOf(edit)
	wipe(form)
	form.OnChanged = OnChanged
	form.edit = edit
	form.tab = "layout"
	-- a new profile starts on the presets menu (Custom: the tabs)
	form.choosing = not edit
	-- a profile of the list keeps its own layout (its text) until another is
	-- picked; a new one starts from the layout in use
	local index = not p and ActiveGridLayout() or nil
	-- (a new one: New layout, from the one in use; Edit Mode opens to place
	-- it after the reload)
	form.layout = p and { keep = true }
		or { new = true, fresh = true, from = "current", fromLabel = L.CURRENT_LAYOUT, start = true }
	-- what it switches on and its modules: the profile's, else the game's
	form.ui = ns.UILive()
	form.modules = ns.ModuleStates()
	form.customModules = false
	form.scope = ns.SharedScope()
	form.copied = {}
	if p then
		for key, on in pairs(p.ui or {}) do
			form.ui[key] = on
		end
		for key, on in pairs(p.modules or {}) do
			if form.modules[key] ~= nil then
				form.modules[key] = on
			end
		end
		form.icon = p.icon
		for _, field in ipairs(ns.SCOPE_FIELDS) do
			form.scope[field] = ns.ScopeOf(p, field)
		end
		form.settings = Copy(p.settings)
		form.keys = Copy(p.keys)
		form.customModules = p.customModules and true or false
		form.moduleSettings = Copy(p.moduleSettings)
	end
	-- other addons (Addons.lua): on or off (Change addons), their profiles
	-- (none listed: none changed)
	form.aceProfiles = Copy(p and p.aceProfiles) or {}
	form.customAddons = p and p.customAddons and true or false
	form.addonStates = Copy(p and p.addonStates)
	-- the module pages show something even when the profile keeps none yet
	if form.customModules and not form.moduleSettings then
		form.moduleSettings = ns.ModuleSnapshot()
	end
	form.orig = {
		use = index, ui = Copy(form.ui), modules = Copy(form.modules), icon = form.icon,
		scope = Copy(form.scope), settings = Copy(form.settings), keys = Copy(form.keys),
		customModules = form.customModules, moduleSettings = Copy(form.moduleSettings),
		aceProfiles = Copy(form.aceProfiles),
		customAddons = form.customAddons, addonStates = Copy(form.addonStates),
	}
end

-- something on the form differs from the profile (a new one always does)
local function Dirty()
	if not form.edit then
		-- the presets menu: nothing filled in yet
		return not form.choosing
	end
	local o = form.orig or {}
	if NameText() ~= form.edit then
		return true
	end
	if form.layout.new or form.layout.use ~= o.use or form.icon ~= o.icon then
		return true
	end
	if form.customModules ~= o.customModules or form.skillsFrom or (form.shared and next(form.shared)) then
		return true
	end
	return not (SameFlags(form.ui, o.ui) and SameFlags(form.modules, o.modules)
		and SameValues(form.scope, o.scope) and SameValues(form.settings, o.settings)
		and SameValues(form.keys, o.keys) and SameValues(form.moduleSettings, o.moduleSettings)
		and SameValues(form.aceProfiles, o.aceProfiles)
		and form.customAddons == o.customAddons and SameFlags(form.addonStates, o.addonStates))
end
ns.FormDirty = Dirty


-- Opens the form: a new profile (edit nil) or one of the list, on a tab
-- (else the one it was on)
function ns.OpenForm(edit, tab)
	if not edit and ns.ProfilesFull() then
		ns.Print(L.MSG_PROFILES_FULL:format(ns.MAX_PROFILES))
		edit = ns.creating and ns.creating.edit or ns.ActivePreset() or ns.ProfileSlots()[1]
	end
	if not (ns.creating and ns.creating.edit == edit) then
		FormDefaults(edit)
		ns.creating = { edit = edit }
		if head then
			head.name:SetText(edit or "")
		end
	end
	ns.ShowFormTab(tab or form.tab or "layout")
end

function ns.ShowFormTab(tab)
	form.tab = TAB_OF[tab] or tab
	ns.Select("newpreset")
end

-- Empty profile (+ New): the form with the game as it is now, on its tabs
function ns.FormStartEmpty()
	if not (ns.creating and not ns.creating.edit and form.choosing) then
		return
	end
	form.pick = ns.CurrentPreset()
	ns.FormCustomize()
end

-- Leaves the form (nothing on it is kept until saved)
function ns.LeaveForm(after)
	ns.creating = nil
	ns.optionsDraft, ns.moduleDraft = nil, nil
	if after then
		after()
	end
end

-- The Settings tab: Global or Profile. Profile on a profile without any of
-- its own: they start as the game has them now (or Copy from). Back to
-- Global, its own are kept.
function ns.SetFormScope(field, scope)
	if form.scope[field] ~= scope then
		-- a copy chosen for the other side goes
		form.copied[field] = nil
		if form.shared then
			form.shared[field] = nil
		end
		if field == "bars" then
			form.skillsFrom = nil
		end
	end
	form.scope[field] = scope
	if scope == "profile" then
		if field == "settings" and not form.settings and ns.SettingsReady() then
			form.settings = ns.OptionSnapshot()
		elseif field == "keys" and not form.keys then
			form.keys = ns.CopyKeys(ns.CurrentKeybinds())
		end
	end
	ns.Refresh()
end

-- Copy from, on the Settings tab: the game as it is now (p nil) or another
-- profile (what it applies). Into the profile's own set, or (Global) into
-- the shared one, which every profile on Global uses: kept when saved.
function ns.FormCopyField(field, p, label)
	local shared = form.scope[field] ~= "profile"
	local data
	if field == "settings" then
		local from = p and ns.SettingsOf(p)
		if p and not from then
			return
		end
		if not p and not ns.SettingsReady() then
			ns.Print(L.MSG_NOT_READY)
			return
		end
		data = from and Copy(from) or ns.OptionSnapshot()
	elseif field == "keys" then
		local from = p and ns.KeysHolder(p).keys
		if p and not from then
			return
		end
		data = from and Copy(from) or ns.CopyKeys(ns.CurrentKeybinds())
	elseif field == "bars" then
		if shared then
			-- Global bars are the player's own: nothing to copy into
			return
		end
		form.skillsFrom = p and p.id or "current"
	end
	if data then
		if shared then
			form.shared = form.shared or {}
			form.shared[field] = data
		elseif field == "settings" then
			form.settings = data
		else
			form.keys = data
		end
	end
	form.copied[field] = label
	ns.Refresh()
end

-- Change modules: the same, for the modules and their options
function ns.SetFormModules(on)
	form.customModules = on and true or false
	if form.customModules and not form.moduleSettings then
		form.moduleSettings = ns.ModuleSnapshot()
	end
	ns.Refresh()
end

-- a profile's name
local function NameOf(p)
	for name, q in pairs(ns.db.profiles) do
		if q == p then
			return name
		end
	end
	return "?"
end

-- Copy from: what the tab shows, from the game as it is now (p nil) or from
-- another profile
local function CopyFrom(p, what)
	if what == "layout" then
		if p then
			local text = ns.ProfileLayoutText(p)
			if text then
				form.layout = { new = true, template = text, fromLabel = NameOf(p), data = ns.ProfileLayoutData(p) or false }
			end
			for key, on in pairs(p.ui or {}) do
				form.ui[key] = on
			end
		else
			form.layout = { use = ActiveGridLayout() }
			form.ui = ns.UILive()
		end
		ns.Refresh()
	elseif what == "modules" then
		local modules = p and p.modules or ns.ModuleStates()
		for key, on in pairs(modules or {}) do
			if form.modules[key] ~= nil then
				form.modules[key] = on
			end
		end
		if p then
			form.moduleSettings = Copy(p.moduleSettings) or form.moduleSettings
		else
			form.moduleSettings = ns.ModuleSnapshot()
		end
		ns.SetFormModules(true)
	elseif what == "addons" then
		if p then
			form.aceProfiles = Copy(p.aceProfiles) or {}
			form.customAddons = p.customAddons and true or false
			form.addonStates = Copy(p.addonStates)
		else
			-- the addons as they are now, and the profiles they use
			form.aceProfiles = {}
			for _, a in ipairs(ns.AceAddons()) do
				form.aceProfiles[a.addon] = Try(a.db.GetCurrentProfile, a.db)
			end
			form.customAddons = true
			form.addonStates = ns.AddonStates()
		end
		ns.Refresh()
	end
end

--------------------------------------------------------------------------------
-- Import: a SetGo! profile (its name, icon, layout and what it switches on
-- fill the form) or Blizzard's layout text (the layout only). Either way a
-- new layout is made when saved, so a free account slot is needed.
--------------------------------------------------------------------------------

-- Import, on + New: Blizzard's layout text (the layout only)
local function Import(text)
	text = strtrim(text or "")
	if ns.ParseProfileText(text) then
		ns.Print(L.MSG_USE_IMPORT_PROFILE)
		return
	end
	local info = text ~= "" and C_EditMode and Try(C_EditMode.ConvertStringToLayoutInfo, text)
	if type(info) ~= "table" then
		ns.Print(L.MSG_BAD_LAYOUT)
		return
	end
	form.layout = { new = true, fresh = true, template = text, imported = true, fromLabel = L.IMPORTED }
	ns.Refresh()
end

-- Import profile: a SetGo! profile as text, a new profile on the form with
-- every tab filled; nothing is kept until saved.
-- opts: { settings, keys } false leaves that part of the code out (the
-- Import menu's boxes)
function ns.ImportProfile(text, opts)
	text = strtrim(text or "")
	local profile = ns.ParseProfileText(text)
	if not profile then
		local info = text ~= "" and C_EditMode and Try(C_EditMode.ConvertStringToLayoutInfo, text)
		ns.Print(type(info) == "table" and L.MSG_USE_IMPORT_LAYOUT or L.MSG_BAD_PROFILE)
		return
	end
	if ns.ProfilesFull() then
		ns.Print(L.MSG_PROFILES_FULL:format(ns.MAX_PROFILES))
		return
	end
	ns.LeaveForm(function()
		ns.OpenForm(nil)
	end)
	if ns.creating == nil or ns.creating.edit ~= nil then
		return
	end
	form.choosing = nil
	-- its layout, if this version of the game can read it (Blizzard's own
	-- format); else the form keeps the layout it has, and says so
	local layoutOK = type(C_EditMode and Try(C_EditMode.ConvertStringToLayoutInfo, profile.layout)) == "table"
	if layoutOK then
		form.layout = { new = true, template = profile.layout, imported = true, fromLabel = profile.name, data = profile.layoutData or false }
	end
	for key, on in pairs(profile.ui) do
		form.ui[key] = on
	end
	form.icon = profile.icon
	if profile.customModules then
		form.customModules = true
		for key, on in pairs(profile.modules or {}) do
			if form.modules[key] ~= nil then
				form.modules[key] = on
			end
		end
		form.moduleSettings = ns.ModuleSnapshot()
		for var, v in pairs(profile.moduleSettings or {}) do
			form.moduleSettings[var] = v
		end
	end
	-- its character settings and keybinds, when the code has them: this
	-- profile's own (Profile), so the shared set isn't touched; what this
	-- version of the game doesn't have is left out
	opts = opts or {}
	if profile.settings and opts.settings ~= false then
		ns.AllSettings()
		local kept, skipped = {}, 0
		-- (the game's list not read yet: all of them kept)
		local known = ns.known and next(ns.known) and ns.known
		for var, v in pairs(profile.settings) do
			if not known or known[var] then
				kept[var] = v
			else
				skipped = skipped + 1
			end
		end
		form.scope.settings = "profile"
		form.settings = kept
		if skipped > 0 then
			ns.Print(L.MSG_IMPORT_SKIPPED:format(skipped))
		end
	end
	if profile.keys and opts.keys ~= false then
		form.scope.keys = "profile"
		form.keys = Copy(profile.keys)
	end
	head.name:SetText(ns.FreePresetName(profile.name))
	ns.Print(L.MSG_PROFILE_IMPORTED:format(profile.name))
	if not layoutOK then
		ns.Print(L.MSG_IMPORT_NO_LAYOUT)
		U.Popup("SETGO_NOTICE", L.MSG_IMPORT_NO_LAYOUT)
	end
	ns.Refresh()
end

StaticPopupDialogs.SETGO_NOTICE = {
	text = "%s",
	button1 = OKAY or "Okay",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
}

StaticPopupDialogs.SETGO_IMPORT_PROFILE = {
	text = "%s",
	button1 = ACCEPT or "Accept",
	button2 = CANCEL or "Cancel",
	hasEditBox = true,
	maxLetters = 0,
	editBoxWidth = 320,
	OnAccept = function(self, data)
		local text = U.EditBoxOf(self):GetText()
		local opts = data and data.opts
		C_Timer.After(0, function()
			ns.ImportProfile(text, opts)
		end)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

function ns.AskImportProfile(opts)
	C_Timer.After(0, function()
		U.Popup("SETGO_IMPORT_PROFILE", L.POPUP_IMPORT_PROFILE, { opts = opts })
	end)
end

-- The Import menu, as the Export one: what of the code comes in too, when
-- it has them (ticked each time it opens), then Import. run(opts) asks for
-- the code.
function ns.ImportMenuItems(parent, run)
	local with = { settings = false, keys = false }
	local function Box(label, key)
		local box = parent:CreateCheckbox(label, function()
			return with[key]
		end, function()
			with[key] = not with[key]
		end)
		if box and box.SetResponse and MenuResponse then
			box:SetResponse(MenuResponse.Refresh)
		end
		if box and box.SetTooltip then
			box:SetTooltip(function(tooltip)
				GameTooltip_SetTitle(tooltip, label)
				GameTooltip_AddNormalLine(tooltip, L.IMPORT_PART_DESC)
			end)
		end
	end
	Box(L.SCOPE_SETTINGS, "settings")
	Box(ns.G("KEY_BINDINGS", L.SCOPE_KEYS), "keys")
	parent:CreateDivider()
	parent:CreateButton(L.IMPORT_PROFILE .. "...", function()
		run({ settings = with.settings, keys = with.keys })
	end)
end

StaticPopupDialogs.SETGO_IMPORT_LAYOUT = {
	text = "%s",
	button1 = ACCEPT or "Accept",
	button2 = CANCEL or "Cancel",
	hasEditBox = true,
	maxLetters = 0,
	editBoxWidth = 320,
	OnAccept = function(self)
		Import(U.EditBoxOf(self):GetText())
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

StaticPopupDialogs.SETGO_EXPORT = {
	text = "%s",
	button1 = CLOSE or "Close",
	hasEditBox = true,
	maxLetters = 0,
	editBoxWidth = 320,
	OnShow = function(self, data)
		data = data or self.data
		local box = U.EditBoxOf(self)
		box:SetText(data and data.text or "")
		box:HighlightText()
		box:SetFocus()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

function ns.ExportProfileText(name, opts)
	local text = ns.PackProfileText(ns.ExportProfile(name, opts))
	if text then
		U.Popup("SETGO_EXPORT", L.POPUP_EXPORT_PROFILE:format(name), { text = text })
	end
end

--------------------------------------------------------------------------------
-- Apply, after asking (Blizzard's own popup: the reload must come from it).
-- Keys and action bars always go with the profile.
--------------------------------------------------------------------------------

function ns.ConfirmApply(name)
	local p = ns.ProfileOf(name)
	if not p then
		return
	end
	local text = L.POPUP_UPRESET_APPLY:format(name)
	if p.newLayout then
		text = text .. "\n\n" .. L.POPUP_NEW_LAYOUT_NOTE
	elseif p.guide then
		text = text .. "\n\n" .. L.POPUP_GUIDE_NOTE
	end
	U.Confirm(text, function()
		ns.ApplyProfile(name)
	end)
end

--------------------------------------------------------------------------------
-- Save (a profile of the list), or Save and Apply (a new one)
--------------------------------------------------------------------------------

local function CheckName()
	local name = NameText()
	if name == "" then
		ns.Print(L.MSG_NAME_EMPTY)
		ns.AskRename()
		return nil
	end
	if name ~= form.edit and ns.ProfileOf(name) then
		ns.Print(L.MSG_NAME_TAKEN:format(name))
		ns.AskRename()
		return nil
	end
	return name
end

-- apply: also put it on this character (a new profile)
local function FormSave(name, apply)
	local first = #ns.ProfileSlots() == 0
	local opts = {
		name = name, replace = form.edit, icon = form.icon, ui = Copy(form.ui), modules = form.modules,
		scope = Copy(form.scope), settings = form.settings, skillsFrom = form.skillsFrom, shared = form.shared,
		customModules = form.customModules, moduleSettings = form.moduleSettings,
		aceProfiles = form.aceProfiles,
		customAddons = form.customAddons, addonStates = form.addonStates,
		noApply = true,
	}
	if form.layout.new then
		local data, fromName = form.layout.template, nil
		if not data then
			local ref = form.layout.from == "current" and ns.CurrentLayoutRef() or form.layout.from
			data = ns.LayoutText(ref)
			fromName = ns.LayoutName(ref)
		end
		if not data then
			ns.Print(L.MSG_LAYOUT_FAILED)
			return
		end
		-- Edit Mode opens after the reload only for a layout the player chose
		-- to make (+ New), to place it
		opts.layout = { template = data, from = fromName, imported = form.layout.imported, editMode = form.layout.fresh,
			data = form.layout.data }
		-- a SetGo! template also says which bars show
		for var, on in pairs(form.layout.bars or {}) do
			local e = ns.UI_VARS[var]
			if e then
				opts.ui[e.key] = on and true or false
			end
		end
	elseif form.layout.use then
		opts.layout = { use = form.layout.use }
	end
	-- its own keys, when they changed on the form
	if form.keys and not SameValues(form.keys, (form.orig or {}).keys) then
		opts.keys = form.keys
	end
	-- a new layout made now is made active when applied right after
	opts.noApply = not apply
	ns.optionsDraft, ns.moduleDraft = nil, nil
	local tab = form.tab
	if not ns.CreateProfile(opts) then
		return
	end
	if not apply then
		ns.creating = nil
		ns.OpenForm(name, tab)
		ns.Refresh()
	end
end

-- Something on the form not saved yet (closing the window asks). A new
-- profile counts once it has a name or anything changed from the start.
function ns.FormHasChanges()
	if not (ns.creating and form.layout) then
		return false
	end
	if form.edit then
		return Dirty()
	end
	local o = form.orig or {}
	return NameText() ~= "" or (form.layout.new and not form.layout.start) or form.layout.use ~= o.use or form.icon ~= nil
		or form.customModules or form.skillsFrom or (form.shared and next(form.shared) ~= nil)
		or not SameValues(form.scope, o.scope)
		or not (SameFlags(form.ui, o.ui) and SameFlags(form.modules, o.modules))
end

-- Apply and exit (closing the window): saved and put on this character.
-- True when done, or nothing to save.
function ns.FormSaveAndApply()
	if not ns.FormHasChanges() then
		return true
	end
	local name = CheckName()
	if not name then
		return false
	end
	FormSave(name, true)
	return ns.ProfileOf(name) ~= nil
end

-- Customize: the profile's tabs, filled in with the preset picked (the
-- current configuration: the form as it starts)
function ns.FormCustomize()
	local entry = form.pick
	if not entry then
		return
	end
	local opts = ns.PresetOpts(entry)
	if not opts then
		ns.Print(L.MSG_LAYOUT_FAILED)
		return
	end
	form.choosing = nil
	if not entry.current then
		form.layout = { new = true, template = opts.layout.template, imported = opts.layout.imported,
			fromLabel = entry.name, data = opts.layout.data }
		form.ui = Copy(opts.ui)
		form.modules = Copy(opts.modules)
		form.customModules = opts.customModules and true or false
		form.moduleSettings = Copy(opts.moduleSettings)
		form.icon = opts.icon
		head.name:SetText(opts.name)
	else
		-- what is on now: the form as it starts, named and with an icon
		head.name:SetText(opts.name)
		form.icon = opts.icon
	end
	ns.ShowFormTab("layout")
end

-- the form's button
function ns.FormButton()
	if not form.edit and form.choosing then
		-- Apply: the preset picked, made a profile at once (after asking)
		if form.pick then
			ns.ApplyPreset(form.pick, function()
				ns.LeaveForm()
			end, function()
				ns.SelectTab("presets")
			end)
		end
		return
	end
	if not form.edit then
		local name = CheckName()
		if not name then
			return
		end
		local text = L.POPUP_NP_SAVE_APPLY:format(name)
		if form.layout.fresh then
			text = text .. "\n\n" .. L.POPUP_NEW_LAYOUT_NOTE
		end
		U.Confirm(text, function()
			FormSave(name, true)
		end)
	elseif Dirty() then
		local name = CheckName()
		if name then
			FormSave(name, false)
		end
	else
		ns.ConfirmApply(form.edit)
	end
end

--------------------------------------------------------------------------------
-- The header: icon, name, Copy from, then the tabs
--------------------------------------------------------------------------------

local function HasAtlas(atlas)
	return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) ~= nil
end

-- A field in ink that opens a menu: its text, Blizzard's arrow (the first
-- the client has), a ground a little darker than the page, a line under the
-- text on hover (Copy from in the header; the addons' profile)
local function InkField(parent, label)
	local r, g, bl = W.Ink()
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(200, 20)
	b.text = W.Text(b, W.FONT_BODY, nil, label or "", 0.85)
	b.text:SetPoint("LEFT", 6, 0)
	Try(b.text.SetWordWrap, b.text, false)
	local field = b:CreateTexture(nil, "BACKGROUND")
	field:SetAllPoints()
	field:SetColorTexture(r, g, bl, 0.1)
	b:HookScript("OnEnter", function()
		field:SetColorTexture(r, g, bl, 0.18)
	end)
	b:HookScript("OnLeave", function()
		field:SetColorTexture(r, g, bl, 0.1)
	end)
	b.arrow = b:CreateTexture(nil, "ARTWORK")
	local arrowW = 12
	if HasAtlas("friendslist-categorybutton-arrow-down") then
		b.arrow:SetAtlas("friendslist-categorybutton-arrow-down")
		b.arrow:SetSize(12, 7)
	elseif HasAtlas("common-dropdown-c-button-hover-arrow") then
		b.arrow:SetAtlas("common-dropdown-c-button-hover-arrow")
		b.arrow:SetSize(12, 12)
	else
		b.arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
		b.arrow:SetSize(14, 14)
		arrowW = 14
	end
	b.arrow:SetPoint("LEFT", b.text, "RIGHT", 6, 0)
	b.arrow:SetVertexColor(r, g, bl)
	-- room for the text, the arrow and the margins (the text can change);
	-- maxW: no wider than that (the text is cut)
	function b:Fit(maxW)
		local extra = 6 + 6 + arrowW + 8
		local textW = tonumber(self.text:GetStringWidth()) or 120
		if maxW and textW + extra > maxW then
			textW = maxW - extra
			self.text:SetWidth(textW)
		else
			self.text:SetWidth(0)
		end
		self:SetWidth(textW + extra)
	end
	local line = b:CreateTexture(nil, "HIGHLIGHT")
	line:SetHeight(1)
	line:SetColorTexture(r, g, bl, 0.6)
	line:SetPoint("BOTTOMLEFT", b.text, "BOTTOMLEFT", 0, -2)
	line:SetPoint("BOTTOMRIGHT", b.text, "BOTTOMRIGHT", 0, -2)
	b:Fit()
	return b
end

-- Copy from: as the game is now, or another profile (what the tab shows)
-- Copy from (the header): everything a profile holds, from another
-- profile or from the game as it is now: the layout, bars and frames, the
-- modules and other addons, the character settings, keybinds and bar
-- slots (as Global or its own, as the other has them). Asked first: it
-- replaces all of this form; nothing is kept until saved.
local function CopyAll(p)
	CopyFrom(p, "layout")
	CopyFrom(p, "modules")
	CopyFrom(p, "addons")
	local name = p and NameOf(p) or L.COPY_CURRENT
	for _, field in ipairs({ "settings", "keys", "bars" }) do
		if p and ns.ScopeOf(p, field) ~= "profile" then
			ns.SetFormScope(field, "global")
		else
			ns.SetFormScope(field, "profile")
			ns.FormCopyField(field, p, name)
		end
	end
	ns.Refresh()
end

local function CopySources(root)
	local function Run(p, label)
		-- after the menu closes
		C_Timer.After(0, function()
			U.Confirm(L.POPUP_COPY_ALL:format(label), function()
				CopyAll(p)
			end)
		end)
	end
	root:CreateButton(L.COPY_CURRENT, function()
		Run(nil, L.COPY_CURRENT)
	end)
	local others = {}
	for _, name in ipairs(ns.ProfileSlots()) do
		if name ~= form.edit then
			others[#others + 1] = name
		end
	end
	if #others > 0 then
		root:CreateDivider()
	end
	for _, name in ipairs(others) do
		local p = ns.ProfileOf(name)
		root:CreateButton(name, function()
			Run(p, name)
		end)
	end
end

local function CreateHead(rightPage, width)
	head = CreateFrame("Frame", nil, rightPage)
	head:SetPoint("TOPLEFT", U.PAD, -U.PAD_TOP)
	head:SetSize(width, HEAD_H + TAB_H + 2)
	head:SetFrameLevel(rightPage:GetFrameLevel() + 20)
	local r, g, bl = W.Ink()

	-- the icon: gone from the window (profiles show their name only); kept
	-- hidden for the code and the codes that still carry one
	head.icon = CreateFrame("Button", nil, head)
	head.icon.tex = head.icon:CreateTexture(nil, "ARTWORK")
	head.icon:Hide()

	-- the name: shown, not written in (Rename next to it asks for it in a
	-- popup, as Blizzard's macros); the box under it keeps it for the form
	head.name = CreateFrame("EditBox", nil, head)
	head.name:SetSize(10, 10)
	head.name:SetAutoFocus(false)
	head.name:EnableMouse(false)
	head.name:EnableKeyboard(false)
	head.name:SetFontObject(GameFontNormal)
	head.name:SetAlpha(0)
	head.name:SetPoint("TOPLEFT")
	head.title = head:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
	Try(head.title.SetFont, head.title, "Fonts\\FRIZQT__.TTF", 20, "")
	head.title:SetPoint("TOPLEFT", 4, -4)
	head.title:SetJustifyH("LEFT")
	Try(head.title.SetWordWrap, head.title, false)
	head.rename = W.Button(head, 90, L.RENAME, function()
		ns.AskRename()
	end, 22)
	local rfs = head.rename.GetFontString and head.rename:GetFontString()
	head.rename:SetWidth(math.max(80, (rfs and tonumber(rfs:GetStringWidth()) or 60) + 24))
	head.rename:SetPoint("LEFT", head.title, "RIGHT", 10, 0)
	W.TipScripts(head.rename, L.RENAME, L.RENAME_DESC)
	head.nameW = width - 120

	-- Copy from, under the name: Blizzard's dropdown
	head.copy = CreateFrame("DropdownButton", nil, head, "WowStyle1DropdownTemplate")
	head.copy:SetPoint("TOPLEFT", 2, -38)
	head.copy:SetWidth(220)
	Try(head.copy.SetDefaultText, head.copy, L.SCOPE_COPY_DEFAULT)
	head.copy:SetupMenu(function(_, root)
		if form.scope then
			CopySources(root)
		end
	end)
	W.TipScripts(head.copy, L.NP_COPY_PROFILE, L.NP_COPY_ALL_DESC, true)

	-- Export: on the card's right click now; kept hidden for the code
	head.import = CreateFrame("Button", nil, head)
	head.import:Hide()

	-- the tabs: Blizzard's top tabs (its gold ones), else ours
	head.tabs = {}
	head.tabsWidth = width
	local blizzard = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("PanelTopTabButtonTemplate")
		and PanelTemplates_SelectTab and PanelTemplates_DeselectTab
	local tabW = width / #ALL_TABS
	local prev
	for i, tab in ipairs(ALL_TABS) do
		local label = L["FORM_TAB_" .. tab:upper()]
		local t
		if blizzard then
			t = CreateFrame("Button", nil, head, "PanelTopTabButtonTemplate")
			t:SetText(label)
			t:SetScript("OnClick", function()
				ns.Sound("IG_CHARACTER_INFO_TAB", 841)
				ns.ShowFormTab(tab)
			end)
			function t:SetOn(on)
				if on then
					PanelTemplates_SelectTab(self)
				else
					PanelTemplates_DeselectTab(self)
				end
			end
			if prev then
				t:SetPoint("LEFT", prev, "RIGHT", 4, 0)
			else
				t:SetPoint("BOTTOMLEFT", head, "TOPLEFT", 6, -(HEAD_H + TAB_H))
			end
			t.blizzard = true
		else
			t = U.MakeTab(head, label, tabW, function()
				ns.ShowFormTab(tab)
			end)
			t:SetHeight(TAB_H)
			t:SetPoint("TOPLEFT", (i - 1) * tabW, -HEAD_H)
		end
		prev = t
		head.tabs[tab] = t
		-- Blizzard's "New" on Interface Tweaks while it has unseen features
		if tab == "tweaks" and C_XMLUtil and C_XMLUtil.GetTemplateInfo
			and C_XMLUtil.GetTemplateInfo("NewFeatureLabelNoAnimateTemplate") then
			local label = CreateFrame("Frame", nil, t, "NewFeatureLabelNoAnimateTemplate")
			-- where Blizzard puts it on its top tabs (the friends list's)
			label:SetPoint("RIGHT", t, "BOTTOMRIGHT", 28, 0)
			label:SetFrameLevel(t:GetFrameLevel() + 5)
			head.newLabel = label
		end
	end
	-- a line under the tabs, the width of the panel
	local rule = head:CreateTexture(nil, "ARTWORK")
	rule:SetHeight(1)
	rule:SetColorTexture(r, g, bl, 0.25)
	rule:SetPoint("TOPLEFT", 0, -(HEAD_H + TAB_H))
	rule:SetPoint("TOPRIGHT", 0, -(HEAD_H + TAB_H))
	head:Hide()
end

--------------------------------------------------------------------------------
-- The bottom: the line (what changed, the step), Back and Next
--------------------------------------------------------------------------------

local function CreateFoot(rightPage, width)
	foot = CreateFrame("Frame", nil, rightPage)
	foot:SetPoint("BOTTOMLEFT", U.PAD, 0)
	foot:SetSize(width, FOOT_H)
	foot:SetFrameLevel(rightPage:GetFrameLevel() + 20)
	-- the button: on the right of the header's first line
	foot.main = W.Button(foot, 130, L.SAVE, function()
		ns.FormButton()
	end, 24)
	foot.main:SetPoint("TOPRIGHT", rightPage, "TOPRIGHT", -U.PAD, -(U.PAD_TOP + 38))
	W.TipScripts(foot.main, function()
		return foot.main:GetText()
	end, function()
		if not form.edit and form.choosing then
			return L.PRESET_APPLY_DESC
		elseif not form.edit then
			return L.NP_SAVE_APPLY_DESC
		elseif Dirty() then
			return form.layout and form.layout.new and L.NP_SAVE_NEWLAYOUT or L.NP_SAVE_DESC
		end
		return L.UPRESET_APPLY_DESC
	end)
	local rule = U.Rule(foot, 0, 4, width)
	rule:SetAlpha(1)
	foot.pending = W.Text(foot, W.FONT_SMALL, width - 200, "", 0.8)
	foot.pending:SetJustifyH("CENTER")
	foot.pending:SetPoint("BOTTOM", foot, "BOTTOM", 0, 15)
	Try(foot.pending.SetWordWrap, foot.pending, false)
	-- Undo: next to the button, in the header
	foot.undo = U.IconBox(foot, { "common-icon-undo" }, "<", function()
		local edit, tab = form.edit, form.tab
		ns.creating = nil
		ns.OpenForm(edit, tab)
	end)
	foot.undo:SetPoint("RIGHT", foot.main, "LEFT", -4, 0)
	-- a new profile: back to the tab before
	foot.back = W.Button(foot, 90, L.WIZ_BACK, function()
		local i = TabIndex(form.tab)
		if i > 1 then
			ns.ShowFormTab(Tabs()[i - 1])
		elseif not form.edit then
			-- the first tab: back to the presets menu
			form.choosing = true
			ns.Refresh()
		end
	end, 22)
	foot.back:SetPoint("BOTTOMLEFT", foot, "BOTTOMLEFT", 0, 10)
	foot.back:Hide()
	-- a new profile: the next tab (Save and Apply works from any tab)
	foot.next = W.Button(foot, 90, L.GUIDE_NEXT, function()
		local i = TabIndex(form.tab)
		local tabs = Tabs()
		if tabs[i + 1] then
			ns.ShowFormTab(tabs[i + 1])
		end
	end, 22)
	foot.next:SetPoint("BOTTOMRIGHT", foot, "BOTTOMRIGHT", 0, 10)
	foot.next:Hide()
	W.TipScripts(foot.next, L.GUIDE_NEXT, L.NP_NEXT_DESC)
	W.TipScripts(foot.undo, L.NP_UNDO, L.NP_UNDO_DESC)
	foot:Hide()
end

-- the button and the line over it
function ns.RefreshFormButton()
	if not (foot and ns.creating) then
		return
	end
	local edit = form.edit
	foot.main:SetEnabled(true)
	foot.back:SetShown(not edit and not form.choosing)
	-- Undo: always there, greyed while nothing changed
	foot.undo:SetShown(not form.choosing)
	foot.undo:SetEnabled(edit ~= nil and Dirty())
	local tabs = Tabs()
	foot.next:SetShown(not edit and not form.choosing and tabs[TabIndex(form.tab) + 1] ~= nil)
	if np and np.customize then
		np.customize:SetEnabled(form.pick ~= nil)
	end
	if not edit and form.choosing then
		-- the presets menu: Apply the one picked
		foot.main:SetText(L.PRESET_APPLY)
		foot.main:SetEnabled(form.pick ~= nil)
		foot.pending:SetText(form.pick and form.pick.name or L.PRESETS_PICK_NOTE)
		return
	end
	if not edit then
		foot.main:SetText(L.SAVE_AND_APPLY)
		foot.pending:SetText(L.FORM_STEP:format(TabIndex(form.tab), #tabs))
		return
	end
	if Dirty() then
		foot.main:SetText(L.SAVE)
		foot.pending:SetText(L.FORM_CHANGED)
		return
	end
	local diff = ns.ProfileDiff(edit)
	local active = edit == ns.ActivePreset()
	-- the action bars aren't counted here (they follow the player's own
	-- arranging); Apply still puts them back
	local shown = diff.total - (diff.skills or 0)
	foot.main:SetText(L.PRESET_APPLY)
	foot.main:SetEnabled(not active or diff.total > 0)
	if active and shown > 0 then
		foot.pending:SetText(table.concat(diff.short, "  \194\183  "))
	elseif active then
		foot.pending:SetText(L.PROFILE_MATCHES)
	else
		foot.pending:SetText("")
	end
end

-- the header and the bottom: on any tab of the form
function ns.RefreshFormHead(onForm)
	if not head then
		return
	end
	onForm = onForm and ns.creating ~= nil
	head:SetShown(onForm and not form.choosing)
	foot:SetShown(onForm)
	if not onForm then
		return
	end
	-- the name, and Rename after it
	head.title:SetText(NameText() ~= "" and NameText() or L.NEW_PRESET)
	local tw = tonumber(head.title:GetStringWidth()) or 100
	head.title:SetWidth(math.min(tw + 2, head.nameW - (tonumber(head.rename:GetWidth()) or 80) - 10))
	-- Copy from: everything, on every tab
	head.copy:Show()
	Try(head.copy.GenerateMenu, head.copy)
	head.import:SetEnabled(form.edit ~= nil)
	for tab, t in pairs(head.tabs) do
		t:SetOn(tab == form.tab)
		t:Show()
	end
	if head.newLabel then
		local any = false
		for key, where in pairs(ns.NEW_FEATURES or {}) do
			any = any or (where == "tweaks" and ns.IsNew(key))
		end
		head.newLabel:SetShown(any)
	end
	ns.RefreshFormButton()
end

--------------------------------------------------------------------------------
-- Pieces
--------------------------------------------------------------------------------

-- a checkbox and its label, on a row of its own (Change modules, Apply own
-- settings)
local function CustomRow(parent, label, tip, onClick, info)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb:SetSize(26, 26)
	cb:SetPoint("TOPLEFT", parent, "TOPLEFT", -3, 0)
	local text = W.Text(parent, W.FONT_BODY, nil, label)
	text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
	-- the longer explanation
	if info then
		W.Info(parent, label, info):SetPoint("LEFT", text, "RIGHT", 4, 0)
	end
	W.TipScripts(cb, label, tip)
	cb:SetScript("OnClick", function(self)
		ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		onClick(self:GetChecked() and true or false)
	end)
	return cb
end

local function ScrollTemplate()
	return C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("ScrollFrameTemplate")
		and "ScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
end

--------------------------------------------------------------------------------
-- The Layout tab
--------------------------------------------------------------------------------

-- what a new layout copies: right click on + New
local function NewLayoutMenu(owner)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	MenuUtil.CreateContextMenu(owner, function(_, root)
		root:CreateTitle(L.NP_COPY_FROM)
		local function Pick(label, from)
			root:CreateRadio(label, function()
				local lay = form.layout or {}
				return lay.new and not lay.template and lay.fromLabel == label
			end, function()
				form.layout = { new = true, fresh = true, from = from, fromLabel = label }
				ns.Refresh()
			end)
		end
		Pick(L.CURRENT_LAYOUT, "current")
		local blizzard, account = GridLayouts()
		for _, group in ipairs({ blizzard, account }) do
			for _, l in ipairs(group) do
				Pick(LayoutText(l), l.preset and { preset = l.index } or { name = l.name })
			end
		end
		local templates = ns.LayoutTemplates()
		if #templates > 0 then
			root:CreateDivider()
			for _, t in ipairs(templates) do
				root:CreateRadio(L.NP_TEMPLATE_ENTRY:format(t.name), function()
					return (form.layout or {}).template == t.data
				end, function()
					form.layout = { new = true, fresh = true, template = t.data, bars = t.bars, fromLabel = t.name }
					ns.Refresh()
				end)
			end
		end
		root:CreateDivider()
		root:CreateButton(ns.G("HUD_EDIT_MODE_IMPORT_LAYOUT", L.NP_IMPORT), function()
			C_Timer.After(0, function()
				U.Popup("SETGO_IMPORT_LAYOUT", L.POPUP_IMPORT_LAYOUT)
			end)
		end)
	end)
end
ns.NewLayoutMenu = NewLayoutMenu

-- A new profile's first page: the presets menu (a preset is applied at
-- once, after asking; Custom, the bottom button, opens the tabs)
local function CreateChoiceBody(width)
	local body = CreateFrame("Frame", nil, np)
	body:SetPoint("TOPLEFT", U.PAD, -U.PAD_TOP)
	body:SetSize(width, 564 - U.PAD_TOP - FOOT_H)
	np.choiceBody = body
	local title = W.Text(body, W.FONT_HEADER, width, L.WIZ_PRESETS_TITLE)
	title:SetPoint("TOPLEFT", 0, 0)
	local sub, h = W.Text(body, W.FONT_SMALL, width, L.WIZ_PRESETS_SUB, 0.85)
	sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	local y = 22 + (tonumber(h) or 28) + 14
	local _, cards = ns.BuildPresetMenu(body, width, y, function(entry)
		form.pick = entry
		ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		ns.Refresh()
	end)
	np.presetCards = cards
	np.customize = W.Button(body, 150, L.WIZ_CUSTOM, function()
		ns.FormCustomize()
	end, 24)
	np.customize:SetPoint("BOTTOM", body, "BOTTOM", 0, 6)
	W.TipScripts(np.customize, L.WIZ_CUSTOM, L.CUSTOMIZE_DESC)
	body:Hide()
end

-- a Blizzard checkbox and its label (the bars, the frames)
local function CheckRow(parent, x, y, width, label, tip, onClick)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb:SetSize(24, 24)
	cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x - 2, -y)
	cb.label = W.Text(parent, W.FONT_BODY, width - 28, label)
	cb.label:SetPoint("LEFT", cb, "RIGHT", 2, 0)
	Try(cb.label.SetWordWrap, cb.label, false)
	W.TipScripts(cb, label, tip)
	cb:SetScript("OnClick", function(self)
		ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		onClick(self:GetChecked() and true or false)
	end)
	return cb
end

-- the layout dropdown's text: the one picked, a new one, or the profile's own
local function LayoutChoiceText()
	local lay = form.layout or {}
	if lay.new then
		return L.LAYOUT_NEW_FROM:format(lay.fromLabel or L.CURRENT_LAYOUT)
	end
	if lay.use then
		local l = ns.GetLayouts()[lay.use]
		if l then
			return LayoutText(l)
		end
	end
	return form.edit and L.LAYOUT_OWN:format(form.edit) or L.LAYOUT_KEEP
end

-- the dropdown's menu: New layout (from the one in use; a new profile's
-- start), Blizzard's layouts, SetGo!'s presets, the account's layouts, then
-- Copy from (another profile's layout, or a layout code)
local function LayoutMenu(root)
	local blizzard, account = GridLayouts()
	local function Is(test)
		return function()
			return test(form.layout or {})
		end
	end
	-- the profile's own layout (a profile of the list keeps it as text)
	if form.edit then
		root:CreateRadio(L.LAYOUT_OWN:format(form.edit), Is(function(lay)
			return lay.keep
		end), function()
			form.layout = { keep = true }
			ns.Refresh()
		end)
	end
	root:CreateRadio(L.LAYOUT_NEW, Is(function(lay)
		return lay.new and lay.from == "current" and not lay.template
	end), function()
		form.layout = { new = true, fresh = true, from = "current", fromLabel = L.CURRENT_LAYOUT }
		ns.Refresh()
	end)
	local function Use(l)
		root:CreateRadio(LayoutText(l), Is(function(lay)
			return not lay.new and lay.use == l.index
		end), function()
			form.layout = { use = l.index }
			ns.Refresh()
		end)
	end
	if #blizzard > 0 then
		root:CreateDivider()
		root:CreateTitle(L.PRESETS_BLIZZARD)
		for _, l in ipairs(blizzard) do
			Use(l)
		end
	end
	-- SetGo!'s presets: their layout (and the bars it shows)
	local presets = ns.PresetList and ns.PresetList() or {}
	local templates = ns.LayoutTemplates()
	if #presets + #templates > 0 then
		root:CreateDivider()
		root:CreateTitle(L.PRESETS_SETGO)
		for _, entry in ipairs(presets) do
			root:CreateRadio(entry.name, Is(function(lay)
				return lay.new and lay.preset == entry.name
			end), function()
				local opts = ns.PresetOpts(entry)
				if not (opts and opts.layout and opts.layout.template) then
					ns.Print(L.MSG_LAYOUT_FAILED)
					return
				end
				form.layout = { new = true, fresh = true, template = opts.layout.template, imported = opts.layout.imported,
					data = opts.layout.data, fromLabel = entry.name, preset = entry.name }
				for n = 2, 8 do
					local key = "bar" .. n
					if opts.ui and opts.ui[key] ~= nil then
						form.ui[key] = opts.ui[key] and true or false
					end
				end
				ns.Refresh()
			end)
		end
		for _, t in ipairs(templates) do
			root:CreateRadio(t.name, Is(function(lay)
				return lay.template == t.data
			end), function()
				form.layout = { new = true, fresh = true, template = t.data, bars = t.bars, fromLabel = t.name }
				ns.Refresh()
			end)
		end
	end
	if #account > 0 then
		root:CreateDivider()
		root:CreateTitle(L.YOUR_LAYOUTS)
		for _, l in ipairs(account) do
			Use(l)
		end
	end
	root:CreateDivider()
	local copy = root:CreateButton(L.SCOPE_COPY_DEFAULT)
	for _, name in ipairs(ns.ProfileSlots()) do
		if name ~= form.edit then
			local p = ns.ProfileOf(name)
			local b = copy:CreateRadio(name, Is(function(lay)
				return lay.new and lay.template ~= nil and lay.fromLabel == name
			end), function()
				CopyFrom(p, "layout")
			end)
			if not ns.ProfileLayoutText(p) and b and b.SetEnabled then
				b:SetEnabled(false)
			end
		end
	end
	copy:CreateDivider()
	copy:CreateButton(ns.G("HUD_EDIT_MODE_IMPORT_LAYOUT", L.NP_IMPORT), function()
		C_Timer.After(0, function()
			U.Popup("SETGO_IMPORT_LAYOUT", L.POPUP_IMPORT_LAYOUT)
		end)
	end)
end

local function CreateLayoutBody(width)
	local body = CreateFrame("Frame", nil, np)
	body:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	body:SetSize(width, BODY_H)
	body.refreshers = {}
	np.layoutBody = body
	np.width = width

	-- the Edit Mode layout: one dropdown
	local y = W.Header(body, 0, width, L.EDITMODE_LAYOUT)
	local dd = CreateFrame("DropdownButton", nil, body, "WowStyle1DropdownTemplate")
	dd:SetPoint("TOPLEFT", 2, -y)
	dd:SetWidth(math.min(320, width - 4))
	dd:SetupMenu(function(_, root)
		LayoutMenu(root)
	end)
	W.TipScripts(dd, L.EDITMODE_LAYOUT, L.LAYOUT_DD_DESC, true)
	np.layoutDD = dd
	y = y + 26 + 6

	-- action bars 1 to 8, Blizzard's checkboxes in two columns
	y = W.Header(body, y, width, L.NP_BARS)
	local colW = math.floor(width / 2)
	np.bars = {}
	for n = 1, 8 do
		local col, row = (n - 1) % 2, math.floor((n - 1) / 2)
		local label = ns.G("OPTION_SHOW_ACTION_BAR", L.UI_BAR):format(n)
		local cb = CheckRow(body, col * colW, y + row * 26, colW, label, n == 1 and L.BAR1_ALWAYS or nil, function(on)
			form.ui["bar" .. n] = on
			ns.Refresh()
		end)
		if n == 1 then
			cb:Disable()
		end
		np.bars[n] = cb
	end
	y = y + 4 * 26 + 6

	-- the frames it shows, the same way
	y = W.Header(body, y, width, L.NP_UI)
	np.elements = {}
	local i = 0
	for _, e in ipairs(ns.UIElements()) do
		if not e.bar then
			local label = ns.UILabel(e)
			local col, row = i % 2, math.floor(i / 2)
			local cb = CheckRow(body, col * colW, y + row * 26, colW, label, nil, function(on)
				form.ui[e.key] = on
				ns.Refresh()
			end)
			cb.element = e
			np.elements[#np.elements + 1] = cb
			i = i + 1
		end
	end
	np.layoutH = y + math.ceil(i / 2) * 26 + 6
end

local function RefreshLayoutBody()
	local blizzard = GridLayouts()
	-- a layout that went away (deleted meanwhile): back to the first one
	if form.layout.use and not ns.GetLayouts()[form.layout.use] then
		form.layout = { use = blizzard[1] and blizzard[1].index or 1 }
	end
	Try(np.layoutDD.SetDefaultText, np.layoutDD, LayoutChoiceText())
	-- the text: the radio picked, else the default (the profile's own, a
	-- new one)
	Try(np.layoutDD.GenerateMenu, np.layoutDD)
	for n, cb in ipairs(np.bars) do
		cb:SetChecked(n == 1 or (form.ui["bar" .. n] and true or false))
	end
	for _, cb in ipairs(np.elements) do
		cb:SetChecked(form.ui[cb.element.key] and true or false)
	end
end

--------------------------------------------------------------------------------
-- The Modules tab: Change modules, then each module (one open at a time):
-- on or off, and its options (the profile's while the tab is open)
--------------------------------------------------------------------------------

local function ModuleDef(key)
	for _, def in ipairs(ns.modules or {}) do
		if def.key == key then
			return def
		end
	end
end

-- A module's key on the form (a keybind row marked profileOnly): read from
-- and written into the keys the profile uses (Settings tab), its own or the
-- shared ones, until saved. The game gets it when the profile is applied.
local function FormKeys(write)
	if form.scope.keys == "profile" then
		if write and not form.keys then
			form.keys = ns.CopyKeys(ns.CurrentKeybinds())
		end
		return form.keys or ns.CurrentKeybinds()
	end
	if form.shared and form.shared.keys then
		return form.shared.keys
	end
	local shared = ns.db.shared and ns.db.shared.keys
	if write then
		form.shared = form.shared or {}
		form.shared.keys = shared and Copy(shared) or ns.CopyKeys(ns.CurrentKeybinds())
		return form.shared.keys
	end
	return shared or ns.CurrentKeybinds()
end

local KeyStore = {}

-- its key (the first, as Blizzard's list shows one)
function KeyStore.get(action)
	local found
	for key, command in pairs(FormKeys(false)) do
		if command == action and (not found or key < found) then
			found = key
		end
	end
	return found
end

-- key "": none
function KeyStore.set(action, key)
	local function Put()
		local keys = FormKeys(true)
		local before = key ~= "" and keys[key]
		for k, command in pairs(keys) do
			if command == action then
				keys[k] = nil
			end
		end
		if key ~= "" then
			keys[key] = action
		end
		if before and before ~= action then
			local name = GetBindingName and GetBindingName(before) or before
			ns.Print(L.MSG_KEY_REPLACED:format(GetBindingText and GetBindingText(key) or key, name))
		end
		ns.Refresh()
	end
	-- the shared set, the first time on this form: every profile on Global
	if form.scope.keys ~= "profile" and not (form.shared and form.shared.keys) then
		U.Confirm(L.POPUP_COPY_GLOBAL, Put)
		return
	end
	Put()
end

-- a module's options for a profile: keybinds are left out (they change the
-- game at once), and so are rows only meant for the module's page (pageOnly).
-- A keybind marked profileOnly stays, into the profile's keys (KeyStore).
local function ModuleItems(key)
	local def = ModuleDef(key)
	local ok, items = pcall(def and def.items or function() end)
	local out = {}
	for _, item in ipairs(ok and type(items) == "table" and items or {}) do
		if item.kind == "keybind" then
			if item.profileOnly then
				local row = {}
				for k, v in pairs(item) do
					row[k] = v
				end
				row.store = KeyStore
				row.tooltip = (item.tooltip and item.tooltip .. "\n\n" or "") .. L.FORM_KEY_NOTE
				out[#out + 1] = row
			end
		elseif not item.pageOnly then
			out[#out + 1] = item
		end
	end
	return out
end

-- A row of the Addons tab, the same for the modules and the other addons,
-- as the game's addon list: no box, a faint ground, the icon (round), the
-- name and a line under it, the box on the right; left of the box, the
-- arrow that opens what is under it (a module's options, an addon's
-- companions) and, for Ace3 addons, its profile
local ROW_TEXT_H = 40
local function ListRow(list, width)
	local row = CreateFrame("Button", nil, list)
	row:SetSize(width, ROW_TEXT_H)
	row.ground = row:CreateTexture(nil, "BACKGROUND")
	row.ground:SetAllPoints()
	row.ground:SetColorTexture(1, 1, 1, 0.03)
	local hl = row:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	hl:SetColorTexture(1, 1, 1, 0.05)
	row.icon = ns.RoundIcon(row, 26)
	row.icon:SetPoint("LEFT", 8, 0)
	row.on = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
	row.on:SetSize(24, 24)
	row.on:SetPoint("RIGHT", -6, 0)
	row.arrow = row:CreateTexture(nil, "ARTWORK")
	row.arrow:SetSize(14, 14)
	row.arrow:SetPoint("RIGHT", row.on, "LEFT", -8, 0)
	function row:SetOpen(open, can)
		self.arrow:SetShown(can and true or false)
		if not can then
			return
		end
		local atlas = open and "friendslist-categorybutton-arrow-down" or "friendslist-categorybutton-arrow-right"
		if not (C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)) then
			self.arrow:SetTexture(open and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
		else
			self.arrow:SetAtlas(atlas)
		end
	end
	row.name = W.Text(row, W.FONT_BODY, width - 120, "")
	row.name:SetPoint("TOPLEFT", 44, -5)
	Try(row.name.SetWordWrap, row.name, false)
	row.info = W.Text(row, W.FONT_SMALL, width - 120, "", 0.7)
	row.info:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -3)
	Try(row.info.SetWordWrap, row.info, false)
	return row
end

local function CreateModulesBody(parent, width)
	local body = CreateFrame("Frame", nil, parent)
	body:SetWidth(width)
	np.modulesBody = body
	local y = W.Header(body, 0, width, L.ADDON)
	local custom = CreateFrame("Frame", nil, body)
	custom:SetPoint("TOPLEFT", 0, -y)
	custom:SetSize(width, ROW_H)
	np.customModules = CustomRow(custom, L.FORM_CUSTOM_MODULES, L.FORM_CUSTOM_MODULES_DESC, ns.SetFormModules, L.INFO_MODULES)
	y = y + ROW_H
	local list = CreateFrame("Frame", nil, body)
	list:SetPoint("TOPLEFT", 0, -y)
	list:SetSize(width, 10)
	np.moduleList, np.moduleListW, np.moduleTop = list, width, y

	np.moduleRows = {}
	for _, m in ipairs(ns.KNOWN_MODULES) do
		if ns.AddonInstalled(m.addon) then
			local row = ListRow(list, width)
			row.key = m.key
			row.icon:SetTexture(ns.ModuleIcon(m.addon))
			-- the asterisk: switching a module on or off reloads the game
			row.name:SetText(L[m.title] .. " *")
			-- a line: what it is (the whole text in its tooltip)
			row.info:SetText(L[(m.title or "") .. "_SHORT"] or L[m.desc] or "")
			W.TipScripts(row.on, L[m.title], L.MODULE_SWITCH_DESC)
			row.on:SetScript("OnClick", function(self)
				ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
				form.modules[m.key] = self:GetChecked() and true or false
				ns.Refresh()
			end)
			W.TipScripts(row, L[m.title], L[m.desc])
			-- its options, built once, under the row: the controls only (no
			-- notes); none, nothing opens
			local items = {}
			for _, item in ipairs(ModuleItems(m.key)) do
				if item.kind ~= "note" and item.kind ~= "title" then
					items[#items + 1] = item
				end
			end
			local hasControls = false
			for _, item in ipairs(items) do
				if item.kind ~= "header" then
					hasControls = true
				end
			end
			if hasControls then
				local panel = CreateFrame("Frame", nil, list)
				panel:SetWidth(width)
				panel.refreshers = {}
				panel:SetHeight(U.RenderItems(panel, items, 8, width - 8) + 8)
				panel:Hide()
				row.panel = panel
				row:SetScript("OnClick", function()
					np.openModule = np.openModule ~= m.key and m.key or nil
					ns.Refresh()
				end)
			end
			np.moduleRows[#np.moduleRows + 1] = row
		end
	end
	if #np.moduleRows == 0 then
		local note = W.Text(list, W.FONT_SMALL, width, L.NO_MODULES, 0.8)
		note:SetPoint("TOPLEFT")
	end
	-- unticked: the modules can't be changed
	np.moduleBlock = CreateFrame("Frame", nil, list)
	np.moduleBlock:SetPoint("TOPLEFT", list, "TOPLEFT")
	np.moduleBlock:SetSize(width, 10)
	np.moduleBlock:EnableMouse(true)
	np.moduleBlock:SetFrameLevel(list:GetFrameLevel() + 30)
	W.TipScripts(np.moduleBlock, L.FORM_CUSTOM_MODULES, L.FORM_MODULES_OFF)
end

--------------------------------------------------------------------------------
-- The Addons tab (Addons.lua): Change addons, then every addon installed,
-- on or off for this profile, and for the Ace3 ones the profile each
-- switches to (or Don't change, which works with Change addons unticked)
--------------------------------------------------------------------------------

-- Turns Change addons on or off; on the first time, the addons as they are
function ns.SetFormAddons(on)
	form.customAddons = on and true or false
	if form.customAddons and not form.addonStates then
		form.addonStates = ns.AddonStates()
	end
	ns.Refresh()
end

-- the profile menu of an Ace3 addon (Don't change, or one of its profiles)
local function ProfileMenu(owner, row)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	MenuUtil.CreateContextMenu(owner, function(_, root)
		root:CreateRadio(L.ACE_KEEP, function()
			return form.aceProfiles[row.ace] == nil
		end, function()
			form.aceProfiles[row.ace] = nil
			ns.Refresh()
		end)
		for _, name in ipairs(row.db and ns.AceProfileNames(row.db) or {}) do
			root:CreateRadio(name, function()
				return form.aceProfiles[row.ace] == name
			end, function()
				form.aceProfiles[row.ace] = name
				ns.Refresh()
			end)
		end
	end)
end

local FIELD_MAX = 0.4 -- the profile field: at most this much of the card
local CHILD_INDENT = 24

local openGroups = {} -- the groups shown open (this session)

-- the profile field's text: the one chosen, else Don't change
local function ProfileLabel(row)
	local chosen = row.ace and form.aceProfiles[row.ace]
	return L.ADDON_PROFILE:format(chosen or L.ACE_KEEP)
end

local function AddonRow(list, width)
	local row = ListRow(list, width)
	row:SetScript("OnClick", function(self)
		if self.children and #self.children > 0 then
			openGroups[self.group] = not openGroups[self.group] or nil
			ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
			ns.Refresh()
		end
	end)
	row.on:SetScript("OnClick", function(self)
		ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		local on = self:GetChecked() and true or false
		form.addonStates = form.addonStates or {}
		form.addonStates[row.addon] = on
		-- the main addon: the ones that go with it too
		for _, child in ipairs(row.children or {}) do
			form.addonStates[child] = on
		end
		ns.Refresh()
	end)
	W.TipScripts(row.on, function()
		return row.title
	end, function()
		return row.tip
	end)
	-- the profile: a field that opens the menu, left of the arrow and the box
	row.dd = InkField(row, "")
	row.dd:SetScript("OnClick", function(self)
		ProfileMenu(self, row)
	end)
	W.TipScripts(row.dd, function()
		return row.title
	end, function()
		-- the whole name (the field can cut it)
		return ProfileLabel(row) .. "\n\n" .. L.ACE_TIP
	end, true)
	return row
end

local rowsMade = {}
local emptyNote

-- an addon's state on the form (its own when Change addons is on, else
-- the game's)
local function StateOf(name)
	if form.customAddons and form.addonStates and form.addonStates[name] ~= nil then
		return form.addonStates[name] and true or false
	end
	return ns.AddonOn(name)
end

local function Info(e)
	-- version (red: made for an older game) and author
	local version = e.version and L.ADDON_VERSION:format(e.version)
	if version and e.outdated then
		version = "|cffd02020" .. version .. "|r"
	elseif not version and e.outdated then
		version = "|cffd02020" .. ns.G("ADDON_INTERFACE_VERSION", L.ADDON_OUTDATED) .. "|r"
	end
	local parts = {}
	parts[#parts + 1] = version
	parts[#parts + 1] = e.author and L.ADDON_AUTHOR:format(e.author)
	return table.concat(parts, "  \194\183  ")
end


local function RefreshAddonList()
	local list, width = np.aceList, np.aceListW
	form.aceProfiles = form.aceProfiles or {}
	local custom = form.customAddons
	-- the game's groups: an addon whose group is another addon here goes
	-- under it
	local all, byName, matched = ns.AddonList(), {}, {}
	for _, a in ipairs(all) do
		byName[a.name] = a
	end
	local tops, kids = {}, {}
	local aceMap = ns.AceMap(all)
	-- which addon each one goes with: its Group or X-Part-Of (Spoken_Quests
	-- and SpokenQuests are the same), else an addon whose name its own
	-- starts with (SpokenZonesAudio: Spoken_Zones); then up to the top one
	local function KeyOf(text)
		return (tostring(text or ""):lower():gsub("[^%w]", ""))
	end
	local byKey = {}
	for _, a in ipairs(all) do
		byKey[KeyOf(a.name)] = byKey[KeyOf(a.name)] or a.name
	end
	local parentOf = {}
	for _, a in ipairs(all) do
		local own = KeyOf(a.name)
		local found
		for _, g in ipairs({ a.group or false, a.partOf or false }) do
			local p = g and byKey[KeyOf(g)]
			if not found and p and p ~= a.name then
				found = p
			end
		end
		if not found then
			local bestKey
			for key, name in pairs(byKey) do
				if #key >= 5 and key ~= own and own:sub(1, #key) == key and (not bestKey or #key > #bestKey) then
					bestKey, found = key, name
				end
			end
		end
		parentOf[a.name] = found
	end
	local function Top(name)
		local p, seen = parentOf[name], { [name] = true }
		while p and parentOf[p] and not seen[parentOf[p]] do
			seen[p] = true
			p = parentOf[p]
		end
		return p
	end
	for _, a in ipairs(all) do
		local ace = aceMap[a.name]
		if ace then
			matched[ace.addon] = true
		end
		local e = {
			addon = a.name, title = a.title, deps = a.deps, ace = ace, icon = a.icon, atlas = a.atlas,
			version = a.version, author = a.author, outdated = a.outdated,
		}
		local parent = Top(a.name)
		if parent and parent ~= a.name then
			kids[parent] = kids[parent] or {}
			table.insert(kids[parent], e)
		else
			tops[#tops + 1] = e
		end
	end
	-- Ace3 databases no addon here was matched to: their dropdown alone
	for _, ace in ipairs(ns.AceAddons()) do
		if not matched[ace.addon] then
			tops[#tops + 1] = { title = ace.addon, ace = ace }
		end
	end
	local y, n = 0, 0
	local function Place(e, child, parentOn)
		n = n + 1
		local row = rowsMade[n] or AddonRow(list, width)
		rowsMade[n] = row
		row.addon, row.title = e.addon, e.title
		row.ace = e.ace and e.ace.addon or nil
		row.db = e.ace and e.ace.db or nil
		row.group = e.addon
		local children = not child and e.addon and kids[e.addon] or nil
		row.children = {}
		for _, k in ipairs(children or {}) do
			row.children[#row.children + 1] = k.addon
		end
		row.name:SetText(e.title)
		row.info:SetText(Info(e))
		if e.atlas then
			row.icon:SetAtlas(e.atlas)
		else
			row.icon:SetTexture(e.icon or 134400)
		end
		-- what it needs, in Blizzard's words
		local deps = {}
		for _, d in ipairs(e.deps or {}) do
			if type(d) == "string" then
				deps[#deps + 1] = d
			end
		end
		row.tip = #deps > 0 and (ns.G("ADDON_DEPENDENCIES", L.ADDON_DEPS) .. table.concat(deps, ", ")) or L.ADDON_SWITCH_DESC
		local state
		row.on:SetShown(e.addon ~= nil)
		if e.addon then
			state = StateOf(e.addon)
			row.on:SetChecked(state)
			-- a dependent of an addon that is off: it can't load
			local usable = custom and parentOn ~= false
			row.on:SetEnabled(usable and true or false)
			row.on:SetAlpha(usable and 1 or 0.45)
		end
		local dim = parentOn == false
		row.name:SetAlpha(dim and 0.45 or 1)
		row.info:SetAlpha(dim and 0.45 or 0.7)
		row.icon:SetDesaturated(dim or state == false)
		local x = child and CHILD_INDENT or 0
		local rowW = width - x
		local hasKids = #row.children > 0
		row:SetOpen(openGroups[row.group], hasKids)
		-- the room the name has: up to the arrow and the box
		local textW = rowW - 44 - 36 - (hasKids and 22 or 0)
		-- the profile field: Ace3 addons, on the first line, left of the box
		-- (greyed while off here)
		local hasProfiles = row.db ~= nil
		row.dd:SetShown(hasProfiles)
		if hasProfiles then
			local on = state ~= false and not dim
			row.dd.text:SetText(ProfileLabel(row))
			row.dd:Fit(math.floor(rowW * FIELD_MAX))
			row.dd:ClearAllPoints()
			row.dd:SetPoint("RIGHT", hasKids and row.arrow or row.on, "LEFT", -8, 0)
			row.dd:SetEnabled(on)
			row.dd:SetAlpha(on and 1 or 0.45)
			textW = textW - (tonumber(row.dd:GetWidth()) or 0) - 8
		end
		row.name:SetWidth(math.max(textW, 40))
		row.info:SetWidth(math.max(textW, 40))
		-- a main addon: how many go with it, after its version
		if hasKids then
			local info = row.info:GetText() or ""
			local more = L.ADDON_MORE:format(openGroups[row.group] and "-" or "+", #row.children)
			row.info:SetText(info ~= "" and (info .. "  \194\183  " .. more) or more)
		end
		local rowH = ROW_TEXT_H
		row:SetHeight(rowH)
		row:SetWidth(rowW)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", list, "TOPLEFT", x, -y)
		row:Show()
		y = y + rowH + 2
		if hasKids and openGroups[row.group] then
			local on = state ~= false
			for _, k in ipairs(children) do
				Place(k, true, on)
			end
		end
	end
	for _, e in ipairs(tops) do
		Place(e, false, nil)
	end
	for i = n + 1, #rowsMade do
		rowsMade[i]:Hide()
	end
	if not emptyNote then
		emptyNote = W.Text(list, W.FONT_SMALL, width, L.ADDONS_NONE, 0.8)
		emptyNote:SetPoint("TOPLEFT")
	end
	emptyNote:SetShown(n == 0)
	return y
end

local function AddonsChanged()
	if not (form.customAddons and form.addonStates) then
		return false
	end
	for name, on in pairs(form.addonStates) do
		if ns.AddonOn(name) ~= (on and true or false) then
			return true
		end
	end
	return false
end

-- The other addons: under the modules, in the same list
local function CreateAddonsBody(parent, width)
	local body = CreateFrame("Frame", nil, parent)
	body:SetWidth(width)
	np.addonsBody = body
	local y = W.Header(body, 0, width, L.OTHER_ADDONS)
	local custom = CreateFrame("Frame", nil, body)
	custom:SetPoint("TOPLEFT", 0, -y)
	custom:SetSize(width, ROW_H)
	np.customAddons = CustomRow(custom, L.FORM_CUSTOM_ADDONS, L.FORM_CUSTOM_ADDONS_DESC, function(on)
		ns.SetFormAddons(on)
	end, L.INFO_ADDONS)
	y = y + ROW_H
	local list = CreateFrame("Frame", nil, body)
	list:SetPoint("TOPLEFT", 0, -y)
	list:SetSize(width, 10)
	np.aceList, np.aceListW, np.aceTop = list, width, y
	body:Hide()
end

local function RefreshAddonsBody()
	np.customAddons:SetChecked(form.customAddons and true or false)
	local h = math.max(RefreshAddonList(), 10)
	np.aceList:SetHeight(h)
	np.addonsBody:SetHeight(np.aceTop + h)
	return np.aceTop + h
end

local function RefreshModulesBody()
	local on = form.customModules
	np.customModules:SetChecked(on)
	np.moduleBlock:SetShown(not on)
	if not on then
		np.openModule = nil
	end
	local y = 0
	for _, row in ipairs(np.moduleRows) do
		row:SetAlpha(on and 1 or 0.45)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", np.moduleList, "TOPLEFT", 0, -y)
		row.on:SetChecked(form.modules[row.key] and true or false)
		local open = row.panel ~= nil and np.openModule == row.key
		row:SetOpen(open, row.panel ~= nil)
		y = y + ROW_TEXT_H + 2
		if open then
			row.panel:ClearAllPoints()
			row.panel:SetPoint("TOPLEFT", np.moduleList, "TOPLEFT", 4, -y)
			row.panel:Show()
			for _, refresh in ipairs(row.panel.refreshers) do
				refresh()
			end
			y = y + row.panel:GetHeight() + CELL_GAP
		elseif row.panel then
			row.panel:Hide()
		end
	end
	np.moduleBlock:SetHeight(math.max(y, 1))
	np.moduleList:SetHeight(math.max(y, 10))
	np.modulesBody:SetHeight(np.moduleTop + math.max(y, 10))
	return np.moduleTop + math.max(y, 10)
end

--------------------------------------------------------------------------------
-- The Settings tab: character settings, keybinds and action bars. Each one
-- Global (the shared set; for the bars, the player's own arranging) or
-- Profile (its own), with Copy from under Profile.
--------------------------------------------------------------------------------

local FIELDS = {
	{ key = "settings", title = "SCOPE_SETTINGS" },
	{ key = "keys", title = "SCOPE_KEYS" },
	{ key = "bars", title = "SCOPE_BARS" },
}

-- what the dropdown says: Global, or Profile (new, a copy, its own)
local function ScopeText(field)
	if not form.scope or form.scope[field] ~= "profile" then
		return L.SCOPE_GLOBAL
	end
	local label = form.copied and form.copied[field]
	if label == L.COPY_CURRENT then
		return L.SCOPE_PROFILE_NEW
	elseif label then
		return L.SCOPE_PROFILE_COPY:format(label)
	end
	return L.SCOPE_PROFILE
end

-- Global, Profile (its own set: the one it has, else the game as it is
-- now), or Copy from another profile (into its own)
local function ScopeMenu(field, root)
	-- built with the window, before any profile is open: nothing yet
	if not (form.scope and form.copied) then
		return
	end
	local function Tip(desc, title, text)
		if text and desc and desc.SetTooltip then
			desc:SetTooltip(function(tooltip)
				GameTooltip_SetTitle(tooltip, title)
				GameTooltip_AddNormalLine(tooltip, text)
			end)
		end
	end
	Tip(root:CreateRadio(L.SCOPE_GLOBAL, function()
		return form.scope[field] ~= "profile"
	end, function()
		ns.SetFormScope(field, "global")
	end), L.SCOPE_GLOBAL, L["SCOPE_GLOBAL_" .. field:upper() .. "_DESC"])
	Tip(root:CreateRadio(L.SCOPE_PROFILE, function()
		return form.scope[field] == "profile" and not form.copied[field]
	end, function()
		form.copied[field] = nil
		ns.SetFormScope(field, "profile")
	end), L.SCOPE_PROFILE, L["SCOPE_PROFILE_" .. field:upper() .. "_DESC"])
	local others = {}
	for _, name in ipairs(ns.ProfileSlots()) do
		if name ~= form.edit then
			others[#others + 1] = name
		end
	end
	-- the bar slots: no Copy from
	if #others == 0 or field == "bars" then
		return
	end
	local copy = root:CreateButton(L.SCOPE_COPY_DEFAULT)
	for _, name in ipairs(others) do
		local p = ns.ProfileOf(name)
		local has
		if field == "settings" then
			has = ns.SettingsOf(p) ~= nil
		elseif field == "keys" then
			has = ns.KeysHolder(p).keys ~= nil
		else
			has = ns.ScopeOf(p, "bars") == "profile" and p.id and ns.charDB.skills[p.id] ~= nil
		end
		local b = copy:CreateRadio(name, function()
			return form.scope[field] == "profile" and form.copied[field] == name
		end, function()
			-- after the menu closes
			C_Timer.After(0, function()
				ns.SetFormScope(field, "profile")
				ns.FormCopyField(field, p, name)
			end)
		end)
		if not has and b and b.SetEnabled then
			b:SetEnabled(false)
		end
	end
end

local function CreateSettingsBody(width)
	local body = CreateFrame("Frame", nil, np)
	body:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	body:SetSize(width, BODY_H)
	np.settingsBody = body
	np.fields = {}
	local y = 0
	local DD_W = 220
	for _, f in ipairs(FIELDS) do
		local row = {}
		-- its title (with the i) on the left, the dropdown on the right
		y = W.Header(body, y, width, L[f.title])
		row.dd = CreateFrame("DropdownButton", nil, body, "WowStyle1DropdownTemplate")
		row.dd:SetPoint("TOPRIGHT", body, "TOPLEFT", width - 2, -(y - 4))
		row.dd:SetWidth(DD_W)
		row.dd:SetupMenu(function(_, root)
			ScopeMenu(f.key, root)
		end)
		Try(row.dd.SetSelectionTranslator, row.dd, function()
			return ScopeText(f.key)
		end)
		W.TipScripts(row.dd, L[f.title], L["INFO_" .. f.key:upper()], true)
		-- what the choice means, in a line or two, left of the dropdown
		row.note = W.Text(body, W.FONT_SMALL, width - DD_W - 16, "", 0.8)
		row.note:SetPoint("TOPLEFT", 0, -(y - 2))
		Try(row.note.SetMaxLines, row.note, 3)
		-- the old names, for the guide's tip (Tour.lua)
		row.global = row.dd
		y = y + 48
		np.fields[f.key] = row
	end
	np.settingsH = y
end

-- what a part holds now, under its buttons
local function FieldNote(key, own)
	if not own then
		if form.shared and form.shared[key] then
			return L.SCOPE_GLOBAL_PENDING
		end
		return L["SCOPE_GLOBAL_" .. key:upper() .. "_NOTE"]
	end
	if key == "keys" then
		local n = 0
		for _ in pairs(form.keys or {}) do
			n = n + 1
		end
		return L.SCOPE_PROFILE_KEYS_NOTE:format(n)
	elseif key == "settings" then
		local n = 0
		for _ in pairs(form.settings or {}) do
			n = n + 1
		end
		return n > 0 and L.SCOPE_PROFILE_SETTINGS_NOTE:format(n) or L.SCOPE_PROFILE_SETTINGS_EMPTY
	end
	local p = form.edit and ns.ProfileOf(form.edit)
	local kept = p and p.id and ns.charDB.skills[p.id] ~= nil and form.skillsFrom == nil
	return kept and L.SCOPE_PROFILE_BARS_NOTE or L.SCOPE_PROFILE_BARS_NEW
end

local function RefreshSettingsBody()
	for _, f in ipairs(FIELDS) do
		local row = np.fields[f.key]
		local own = form.scope[f.key] == "profile"
		row.note:SetText(FieldNote(f.key, own))
		Try(row.dd.SetDefaultText, row.dd, ScopeText(f.key))
		Try(row.dd.GenerateMenu, row.dd)
	end
end

--------------------------------------------------------------------------------

function ns.RefreshNewPreset()
	if not (np and ns.creating and form.layout) then
		return
	end
	local tab = not form.choosing and form.tab or nil
	np.choiceBody:SetShown(form.choosing and true or false)
	np.layoutScroll:SetShown(tab == "layout")
	np.addonsScroll:SetShown(tab == "addons")
	-- the reload line belongs to the Addons tab (set again below when open)
	np.addonsReload:Hide()
	np.addonsBody:SetShown(HasOtherAddons())
	-- leaving Interface Tweaks: its new features have been seen
	if np.tweaksBody:IsShown() and tab ~= "tweaks" and np.SeeTweaks then
		np.SeeTweaks()
	end
	np.tweaksBody:SetShown(tab == "tweaks")
	if form.choosing then
		for _, c in ipairs(np.presetCards or {}) do
			local on = form.pick ~= nil and (form.pick == c.entry
				or (form.pick.current and c.entry.current)
				or (form.pick.blizzard and form.pick.blizzard == c.entry.blizzard)
				or (form.pick.preset and form.pick.preset == c.entry.preset))
			if on then
				c:Look(0.22, 0.9, true)
			else
				c:Look(0.07, 0.35, false)
			end
		end
		return
	elseif tab == "addons" then
		-- one list: the modules (unless SetGo!'s settings switched them all
		-- off), then the other addons under them
		local modulesOff = ns.db and ns.db.modulesOff
		np.modulesBody:SetShown(not modulesOff)
		local y = modulesOff and 0 or RefreshModulesBody()
		if HasOtherAddons() then
			np.addonsBody:ClearAllPoints()
			np.addonsBody:SetPoint("TOPLEFT", np.addonsChild, "TOPLEFT", 0, -(y + 6))
			y = y + 6 + RefreshAddonsBody()
		end
		np.addonsChild:SetHeight(y + 8)
		-- a module or addon switched on or off: the game reloads when applied
		local modsChanged = form.customModules and not SameFlags(form.modules, (form.orig or {}).modules)
		np.addonsReload:SetShown((modsChanged or AddonsChanged()) and true or false)
	elseif tab == "tweaks" then
		np.RefreshTweaks()
	else
		RefreshLayoutBody()
		RefreshSettingsBody()
	end
end

-- what the guide's tips point at (Tour.lua)
function ns.FormFrames()
	if not (np and head and foot) then
		return {}
	end
	return {
		name = head.name, customize = np.customize, next = foot.next,
		layout = np.layoutDD, bars = np.bars and np.bars[1],
		frames = np.elements and np.elements[1],
		settings = np.fields and np.fields.settings and np.fields.settings.global,
		modules = np.customModules, addons = np.customAddons,
	}
end
ns.FormTabs = Tabs
ns.FormHasOtherAddons = HasOtherAddons

-- built with the window (UI.lua)
function ns.CreateProfileForm()
	local rightPage = U.rightPage
	local width = U.PAGE_W - U.PAD * 2
	np = CreateFrame("Frame", nil, rightPage)
	np:SetAllPoints()
	rightPage.newpreset = np
	CreateChoiceBody(width)

	-- Layout: the layout, bars and frames, then the settings, in one list
	-- that scrolls
	local listW = width - 22
	local scroll = CreateFrame("ScrollFrame", nil, np, ScrollTemplate())
	scroll:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	scroll:SetSize(listW, BODY_H)
	if scroll.ScrollBar and scroll.ScrollBar.SetHideIfUnscrollable then
		scroll.ScrollBar:SetHideIfUnscrollable(true)
	end
	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(listW, 10)
	scroll:SetScrollChild(child)
	np.layoutScroll = scroll
	CreateLayoutBody(listW)
	CreateSettingsBody(listW)
	np.layoutBody:SetParent(child)
	np.layoutBody:ClearAllPoints()
	np.layoutBody:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
	np.layoutBody:SetHeight(np.layoutH or 10)
	np.layoutBody:Show()
	np.settingsBody:SetParent(child)
	np.settingsBody:ClearAllPoints()
	np.settingsBody:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -((np.layoutH or 0) + 16))
	np.settingsBody:SetHeight(np.settingsH or 10)
	np.settingsBody:Show()
	child:SetHeight((np.layoutH or 0) + 16 + (np.settingsH or 0) + 6)
	scroll:Hide()

	-- Addons: one list that scrolls, the modules on top, the other addons
	-- under them (when there are any); what opens pushes the rest down
	local ascroll = CreateFrame("ScrollFrame", nil, np, ScrollTemplate())
	ascroll:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	ascroll:SetSize(listW, BODY_H - 18)
	if ascroll.ScrollBar and ascroll.ScrollBar.SetHideIfUnscrollable then
		ascroll.ScrollBar:SetHideIfUnscrollable(true)
	end
	local achild = CreateFrame("Frame", nil, ascroll)
	achild:SetSize(listW, 10)
	ascroll:SetScrollChild(achild)
	ascroll:Hide()
	np.addonsScroll, np.addonsChild = ascroll, achild
	CreateModulesBody(achild, listW)
	np.modulesBody:SetPoint("TOPLEFT", achild, "TOPLEFT", 0, 0)
	CreateAddonsBody(achild, listW)
	-- a choice marked * changed: it reloads the game when applied
	np.addonsReload = W.Text(np, W.FONT_SMALL, width, L.RELOAD_LEGEND, 0.8)
	np.addonsReload:SetPoint("TOPLEFT", np, "TOPLEFT", U.PAD, -(BODY_TOP + BODY_H - 14))
	np.addonsReload:Hide()
	np.moduleReload = np.addonsReload

	-- Interface Tweaks: their page, as the gear's pages draw it (built the
	-- first time it shows). They are the profile in use's, and change at once.
	local tweaks = CreateFrame("Frame", nil, np)
	tweaks:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	tweaks:SetSize(width, BODY_H)
	tweaks:Hide()
	np.tweaksBody = tweaks
	tweaks.note = W.Text(tweaks, W.FONT_SMALL, width, "", 0.8)
	tweaks.note:SetPoint("TOPLEFT", 0, 0)
	-- each part (Action bars, Minimap...) in a box with a bronze edge; the
	-- explanations left out (their tooltips keep them)
	local BRONZE = { 0.72, 0.53, 0.3 }
	local backdrop = BackdropTemplateMixin and "BackdropTemplate" or nil
	function np.SeeTweaks()
		for key, dot in pairs(tweaks.dots or {}) do
			ns.SeeNew(key)
			dot:Hide()
		end
	end
	function np.RefreshTweaks()
		tweaks.note:Hide()
		if not tweaks.scroll then
			local ts = CreateFrame("ScrollFrame", nil, tweaks, ScrollTemplate())
			ts:SetPoint("TOPLEFT", 0, 0)
			ts:SetSize(listW, BODY_H)
			if ts.ScrollBar and ts.ScrollBar.SetHideIfUnscrollable then
				ts.ScrollBar:SetHideIfUnscrollable(true)
			end
			local page = CreateFrame("Frame", nil, ts)
			page:SetWidth(listW)
			page.refreshers = {}
			-- the items in groups, each starting at a header
			local groups, current = {}, nil
			for _, item in ipairs(ns.TweaksItems()) do
				if item.kind == "header" or not current then
					current = {}
					groups[#groups + 1] = current
				end
				if item.kind ~= "note" then
					current[#current + 1] = item
				end
			end
			local y, PAD_IN = 0, 10
			for i = #groups, 1, -1 do
				if #groups[i] == 0 then
					table.remove(groups, i)
				end
			end
			for _, group in ipairs(groups) do
				local box = CreateFrame("Frame", nil, page, backdrop)
				box:SetPoint("TOPLEFT", 0, -y)
				box:SetWidth(listW - 2)
				box.refreshers = page.refreshers
				if box.SetBackdrop then
					box:SetBackdrop({
						bgFile = "Interface\\Buttons\\WHITE8X8",
						edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
						edgeSize = 12,
						insets = { left = 3, right = 3, top = 3, bottom = 3 },
					})
					box:SetBackdropColor(0, 0, 0, 0.25)
					box:SetBackdropBorderColor(BRONZE[1], BRONZE[2], BRONZE[3], 1)
				end
				local inner = CreateFrame("Frame", nil, box)
				inner:SetPoint("TOPLEFT", PAD_IN, -PAD_IN)
				inner:SetWidth(listW - 2 - PAD_IN * 2)
				inner.refreshers = page.refreshers
				-- item by item: a blue dot left of each new feature, until seen
				local h = 0
				for _, item in ipairs(group) do
					local at = h
					h = U.RenderItems(inner, { item }, h, listW - 2 - PAD_IN * 2)
					if item.newKey and ns.IsNew(item.newKey) then
						local dot = inner:CreateTexture(nil, "OVERLAY")
						dot:SetSize(12, 12)
						if not (C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo("plunderstorm-new-dot-sm")
							and dot:SetAtlas("plunderstorm-new-dot-sm") ~= false) then
							dot:SetAtlas("communities-icon-notification")
						end
						dot:SetPoint("RIGHT", inner, "TOPLEFT", -1, -(at + 7))
						tweaks.dots = tweaks.dots or {}
						tweaks.dots[item.newKey] = dot
					end
				end
				inner:SetHeight(h)
				box:SetHeight(h + PAD_IN * 2 - 6)
				y = y + h + PAD_IN * 2 - 6 + 10
			end
			page:SetHeight(y + 4)
			ts:SetScrollChild(page)
			tweaks.scroll, tweaks.page = ts, page
		end
		for _, refresh in ipairs(tweaks.page.refreshers) do
			refresh()
		end
	end

	CreateHead(rightPage, width)
	CreateFoot(rightPage, width)
end
