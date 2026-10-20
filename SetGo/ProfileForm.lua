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

local ALL_TABS = { "layout", "settings", "modules", "addons" }

-- the tabs shown: Addons only while there are other addons (Ace3 ones may
-- load later, on demand: looked at each time)
local function Tabs()
	local list = {}
	local ace = ns.AddonList and (#ns.AddonList() > 0 or #ns.AceAddons() > 0)
	for _, tab in ipairs(ALL_TABS) do
		if tab ~= "addons" or ace then
			list[#list + 1] = tab
		end
	end
	return list
end
local BLIZZARD_TINT = { 0.12, 0.23, 0.45 } -- Blizzard's layouts: blue ink
local CELL_H, CELL_GAP = 28, 3
local LIST_ROWS = 5 -- the account's layouts, all shown
local DEFAULT_ICON = 134400 -- the question mark
local ICON = 64
local NAME_MAX = 24
local TABS_TOP = U.PAD_TOP + ICON + 8
local TAB_H = 28
local BODY_TOP = TABS_TOP + TAB_H + 8
local FOOT_H = 70 -- the button, the line over it and the rule
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
	form.layout = p and { keep = true } or { use = index }
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
	if tab == "options" then
		tab = "settings"
	end
	form.tab = tab
	ns.Select("newpreset")
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

-- Import profile: a SetGo! profile as text, every tab of the form filled;
-- nothing is kept until saved. into: the profile open on the form, which
-- it replaces (its name stays); else (the cards) a new profile.
-- opts: { settings, keys } false leaves that part of the code out (the
-- Import menu's boxes)
function ns.ImportProfile(text, into, opts)
	text = strtrim(text or "")
	local profile = ns.ParseProfileText(text)
	if not profile then
		local info = text ~= "" and C_EditMode and Try(C_EditMode.ConvertStringToLayoutInfo, text)
		ns.Print(type(info) == "table" and L.MSG_USE_IMPORT_LAYOUT or L.MSG_BAD_PROFILE)
		return
	end
	local replacing = into ~= nil and ns.creating ~= nil and ns.creating.edit == into
	if not replacing then
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
	if not replacing then
		head.name:SetText(ns.FreePresetName(profile.name))
	end
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
		local into = data and data.into
		local opts = data and data.opts
		C_Timer.After(0, function()
			ns.ImportProfile(text, into, opts)
		end)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

function ns.AskImportProfile(into, opts)
	C_Timer.After(0, function()
		U.Popup("SETGO_IMPORT_PROFILE", L.POPUP_IMPORT_PROFILE, { into = into, opts = opts })
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
-- Icon picker: the game's icons (as for macros), all of them, spells or
-- items; a grid that scrolls with the mouse wheel or the arrows
--------------------------------------------------------------------------------

local picker
local PICK_COLS, PICK_ROWS, PICK_SIZE, PICK_GAP = 9, 6, 36, 4
local PICK_TOP = 60

local function IconTypes(filter)
	local types = IconDataProviderIconType
	if filter == "spell" and types then
		return { types.Spell }
	elseif filter == "item" and types then
		return { types.Item }
	end
	return nil -- all
end

local function IconProvider()
	if picker.provider then
		return picker.provider
	end
	if CreateAndInitFromMixin and IconDataProviderMixin then
		local extra = IconDataProviderExtraType and IconDataProviderExtraType.Spellbook
		picker.provider = Try(CreateAndInitFromMixin, IconDataProviderMixin, extra)
		if picker.provider and picker.provider.SetIconTypes then
			Try(picker.provider.SetIconTypes, picker.provider, IconTypes(picker.filter))
		end
	end
	return picker.provider
end

local function IconCount()
	local p = IconProvider()
	return p and (Try(p.GetNumIcons, p) or 0) or 0
end

local function IconAt(i)
	local p = IconProvider()
	return p and Try(p.GetIconByIndex, p, i)
end

local function FillPicker()
	local total = IconCount()
	local rows = math.ceil(total / PICK_COLS)
	picker.offset = math.max(0, math.min(picker.offset or 0, rows - PICK_ROWS))
	for i, b in ipairs(picker.buttons) do
		local index = picker.offset * PICK_COLS + i
		local icon = index <= total and IconAt(index)
		b.icon = icon
		if icon then
			b.tex:SetTexture(icon)
			b:Show()
		else
			b:Hide()
		end
	end
	picker.up:SetEnabled(picker.offset > 0)
	picker.down:SetEnabled(picker.offset < rows - PICK_ROWS)
end

local function SetFilter(filter)
	picker.filter = filter
	picker.offset = 0
	local p = picker.provider
	if p and p.SetIconTypes then
		Try(p.SetIconTypes, p, IconTypes(filter))
	end
	FillPicker()
end

local function CreatePicker()
	local template = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("BasicFrameTemplateWithInset")
		and "BasicFrameTemplateWithInset" or nil
	picker = CreateFrame("Frame", "SetGoIconPicker", U.frame or UIParent, template)
	if picker:GetParent() == UIParent then
		ns.ScaleFrame(picker)
	end
	local w = PICK_COLS * (PICK_SIZE + PICK_GAP) + 50
	local h = PICK_ROWS * (PICK_SIZE + PICK_GAP) + PICK_TOP + 20
	picker:SetSize(w, h)
	picker:SetFrameStrata("FULLSCREEN_DIALOG")
	picker:EnableMouse(true)
	picker:EnableMouseWheel(true)
	if not template then
		local bg = picker:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.08, 0.06, 0.04, 0.95)
	end
	local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", 0, -6)
	title:SetText(L.PICK_ICON)
	table.insert(UISpecialFrames, "SetGoIconPicker")
	-- the filter, as in Blizzard's icon selector
	picker.filterMenu = CreateFrame("DropdownButton", nil, picker, "WowStyle1DropdownTemplate")
	picker.filterMenu:SetWidth(130)
	picker.filterMenu:SetPoint("TOPLEFT", 12, -28)
	picker.filterMenu:SetupMenu(function(_, root)
		for _, f in ipairs({ { "all", L.PICK_ALL }, { "spell", L.PICK_SPELLS }, { "item", L.PICK_ITEMS } }) do
			root:CreateRadio(f[2], function()
				return (picker.filter or "all") == f[1]
			end, function()
				SetFilter(f[1])
			end)
		end
	end)
	picker.buttons = {}
	for i = 1, PICK_COLS * PICK_ROWS do
		local b = CreateFrame("Button", nil, picker)
		b:SetSize(PICK_SIZE, PICK_SIZE)
		local r, c = math.floor((i - 1) / PICK_COLS), (i - 1) % PICK_COLS
		b:SetPoint("TOPLEFT", 12 + c * (PICK_SIZE + PICK_GAP), -PICK_TOP - r * (PICK_SIZE + PICK_GAP))
		b.tex = b:CreateTexture(nil, "ARTWORK")
		b.tex:SetAllPoints()
		local hl = b:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetColorTexture(1, 1, 1, 0.25)
		b:SetScript("OnClick", function(self)
			if self.icon and picker.onPick then
				picker.onPick(self.icon)
			end
			picker:Hide()
		end)
		picker.buttons[i] = b
	end
	picker.up = W.PageArrow(picker, "Prev", function()
		picker.offset = picker.offset - PICK_ROWS
		FillPicker()
	end)
	picker.up:SetPoint("TOPRIGHT", -8, -PICK_TOP)
	picker.down = W.PageArrow(picker, "Next", function()
		picker.offset = picker.offset + PICK_ROWS
		FillPicker()
	end)
	picker.down:SetPoint("BOTTOMRIGHT", -8, 12)
	picker:SetScript("OnMouseWheel", function(_, delta)
		picker.offset = picker.offset - delta
		FillPicker()
	end)
	picker:SetScript("OnHide", function()
		local p = picker.provider
		picker.provider = nil
		if p and p.Release then
			Try(p.Release, p)
		end
	end)
	picker:Hide()
end

-- owner: the window it belongs to (closes with it), anchor: where it shows;
-- SetGo!'s right page unless given (the first profile's guide)
function ns.PickIcon(onPick, owner, anchor)
	if not picker then
		CreatePicker()
	end
	owner, anchor = owner or U.frame, anchor or U.rightPage
	if owner and picker:GetParent() ~= owner then
		picker:SetParent(owner)
		picker:SetFrameStrata("FULLSCREEN_DIALOG")
	end
	picker:ClearAllPoints()
	picker:SetPoint("TOPLEFT", anchor or UIParent, "TOPLEFT", 20, -60)
	picker.onPick = onPick
	picker.offset = 0
	picker:Show()
	FillPicker()
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
		head.name:SetFocus()
		return nil
	end
	if name ~= form.edit and ns.ProfileOf(name) then
		ns.Print(L.MSG_NAME_TAKEN:format(name))
		head.name:SetFocus()
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
	return NameText() ~= "" or form.layout.new or form.layout.use ~= o.use or form.icon ~= nil
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
local function CopySources(root)
	local what = form.tab or "layout"
	root:CreateButton(L.COPY_CURRENT, function()
		CopyFrom(nil, what)
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
		local b = root:CreateButton(name, function()
			CopyFrom(p, what)
		end)
		local empty = (what == "modules" and not (p and (p.customModules or p.moduleSettings)))
			or (what == "addons" and not (p and (p.customAddons or (p.aceProfiles and next(p.aceProfiles)))))
		if empty and b and b.SetEnabled then
			b:SetEnabled(false)
		end
	end
end

local function CreateHead(rightPage, width)
	head = CreateFrame("Frame", nil, rightPage)
	head:SetPoint("TOPLEFT", U.PAD, -U.PAD_TOP)
	head:SetSize(width, TABS_TOP - U.PAD_TOP + TAB_H + 2)
	head:SetFrameLevel(rightPage:GetFrameLevel() + 20)
	local r, g, bl = W.Ink()

	-- the icon, round
	head.icon = CreateFrame("Button", nil, head)
	head.icon:SetSize(ICON, ICON)
	head.icon:SetPoint("TOPLEFT", 0, 0)
	head.icon.tex = head.icon:CreateTexture(nil, "ARTWORK")
	head.icon.tex:SetAllPoints()
	if head.icon.CreateMaskTexture then
		local mask = head.icon:CreateMaskTexture()
		mask:SetAllPoints(head.icon.tex)
		mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		head.icon.tex:AddMaskTexture(mask)
	end
	if HasAtlas("communities-ring-gold") then
		local ring = head.icon:CreateTexture(nil, "OVERLAY")
		ring:SetAtlas("communities-ring-gold")
		ring:SetPoint("CENTER")
		ring:SetSize(ICON + 10, ICON + 10)
	end
	local ihl = head.icon:CreateTexture(nil, "HIGHLIGHT")
	ihl:SetAllPoints()
	ihl:SetColorTexture(1, 1, 1, 0.15)
	head.icon:SetScript("OnClick", function()
		ns.PickIcon(function(icon)
			form.icon = icon
			ns.Refresh()
		end)
	end)
	W.TipScripts(head.icon, L.NP_ICON, L.NP_ICON_DESC)

	-- the name: a headline you can write in
	local x = ICON + 14
	local nameW = width - x
	head.name = CreateFrame("EditBox", nil, head)
	head.name:SetSize(nameW, 32)
	head.name:SetPoint("TOPLEFT", x, 0)
	head.name:SetAutoFocus(false)
	Try(head.name.SetMaxLetters, head.name, NAME_MAX)
	head.name:SetFontObject(GameFontNormalHuge or GameFontNormalLarge)
	Try(head.name.SetFont, head.name, "Fonts\\FRIZQT__.TTF", 20, "")
	head.name:SetTextColor(r, g, bl)
	Try(head.name.SetShadowColor, head.name, 0, 0, 0, 0)
	head.name:SetTextInsets(8, 8, 0, 0)
	local bg = head.name:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(r, g, bl, 0.12)
	head.name:SetScript("OnEditFocusGained", function()
		bg:SetColorTexture(r, g, bl, 0.2)
	end)
	head.name:SetScript("OnEditFocusLost", function()
		bg:SetColorTexture(r, g, bl, 0.12)
	end)
	head.name:SetScript("OnEscapePressed", head.name.ClearFocus)
	head.name:SetScript("OnEnterPressed", head.name.ClearFocus)
	head.name:HookScript("OnTextChanged", function(_, userInput)
		if userInput and ns.RefreshFormButton then
			ns.RefreshFormButton()
		end
	end)
	W.TipScripts(head.name, L.NP_NAME, L.NP_NAME_DESC, true)

	-- Copy from, under the name: a field in ink that opens the menu
	head.copy = InkField(head, L.NP_COPY_FROM .. " " .. L.COPY_CURRENT)
	head.copy:SetPoint("TOPLEFT", x + 4, -38)
	head.copy:SetScript("OnClick", function(self)
		if MenuUtil and MenuUtil.CreateContextMenu then
			MenuUtil.CreateContextMenu(self, function(_, root)
				CopySources(root)
			end)
		end
	end)
	W.TipScripts(head.copy, L.NP_COPY_PROFILE, function()
		return L["NP_COPY_" .. (form.tab or "layout"):upper() .. "_DESC"]
	end, true)

	-- Import, on the right of the same line: a profile someone shared, made
	-- as a new one (as Import profile on the cards' menu)
	head.import = W.Button(head, 120, L.IMPORT_PROFILE, function(self)
		local function Run(opts)
			local edit = form.edit
			if edit then
				-- into the profile open: always asked first
				U.Confirm(L.POPUP_IMPORT_REPLACE:format(edit), function()
					ns.AskImportProfile(edit, opts)
				end)
			else
				ns.AskImportProfile(nil, opts)
			end
		end
		-- the menu: what comes in too, then Import
		if MenuUtil and MenuUtil.CreateContextMenu then
			MenuUtil.CreateContextMenu(self or head.import, function(_, root)
				ns.ImportMenuItems(root, Run)
			end)
		else
			Run(nil)
		end
	end, 22)
	local fs = head.import.GetFontString and head.import:GetFontString()
	head.import:SetWidth(math.max(100, (fs and tonumber(fs:GetStringWidth()) or 90) + 30))
	head.import:SetPoint("TOPRIGHT", head, "TOPRIGHT", 0, -36)
	W.TipScripts(head.import, L.IMPORT_PROFILE, function()
		return form.edit and L.IMPORT_REPLACE_DESC or L.IMPORT_PROFILE_DESC
	end)

	-- the tabs, the width of the page, on a darker band
	local band = head:CreateTexture(nil, "BACKGROUND")
	band:SetColorTexture(r, g, bl, 0.1)
	band:SetPoint("TOPLEFT", 0, -(TABS_TOP - U.PAD_TOP))
	band:SetSize(width, TAB_H)
	head.tabs = {}
	head.tabsWidth = width
	local tabW = width / #ALL_TABS
	for i, tab in ipairs(ALL_TABS) do
		local t = U.MakeTab(head, L["FORM_TAB_" .. tab:upper()], tabW, function()
			ns.ShowFormTab(tab)
		end)
		t:SetHeight(TAB_H)
		t:SetPoint("TOPLEFT", (i - 1) * tabW, -(TABS_TOP - U.PAD_TOP))
		head.tabs[tab] = t
	end
	head:Hide()
end

--------------------------------------------------------------------------------
-- The bottom: a rule, a line, the button
--------------------------------------------------------------------------------

local function CreateFoot(rightPage, width)
	foot = CreateFrame("Frame", nil, rightPage)
	foot:SetPoint("BOTTOMLEFT", U.PAD, 0)
	foot:SetSize(width, FOOT_H)
	foot:SetFrameLevel(rightPage:GetFrameLevel() + 20)
	foot.main = W.Button(foot, 150, L.SAVE, function()
		ns.FormButton()
	end, 24)
	foot.main:SetPoint("BOTTOM", foot, "BOTTOM", 0, 17)
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
	local rule = U.Rule(foot, 0, FOOT_H - 48, width)
	rule:SetAlpha(1)
	foot.pending = W.Text(foot, W.FONT_SMALL, width, "", 0.8)
	foot.pending:SetJustifyH("CENTER")
	foot.pending:SetPoint("BOTTOM", foot, "BOTTOM", 0, 52)
	Try(foot.pending.SetWordWrap, foot.pending, false)
	foot.undo = U.IconBox(foot, { "common-icon-undo" }, "<", function()
		local edit, tab = form.edit, form.tab
		ns.creating = nil
		ns.OpenForm(edit, tab)
	end)
	foot.undo:SetPoint("BOTTOMRIGHT", foot, "BOTTOMRIGHT", 0, 15)
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
	foot.back:SetPoint("BOTTOMLEFT", foot, "BOTTOMLEFT", 0, 18)
	foot.back:Hide()
	-- a new profile: the next tab (Save and Apply works from any tab)
	foot.next = W.Button(foot, 90, L.GUIDE_NEXT, function()
		local i = TabIndex(form.tab)
		local tabs = Tabs()
		if tabs[i + 1] then
			ns.ShowFormTab(tabs[i + 1])
		end
	end, 22)
	foot.next:SetPoint("BOTTOMRIGHT", foot, "BOTTOMRIGHT", 0, 18)
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
	foot.undo:SetShown(edit ~= nil)
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
	head.icon.tex:SetTexture(form.icon or DEFAULT_ICON)
	-- the Settings tab has a Copy from for each of its parts
	head.copy:SetShown(form.tab ~= "settings")
	head.import:SetEnabled(form.edit ~= nil or not ns.ProfilesFull())
	-- the tabs shown, side by side over the band
	local shown = Tabs()
	local tabW = head.tabsWidth / #shown
	for tab, t in pairs(head.tabs) do
		t:Hide()
	end
	for i, tab in ipairs(shown) do
		local t = head.tabs[tab]
		t:SetWidth(tabW)
		t:ClearAllPoints()
		t:SetPoint("TOPLEFT", (i - 1) * tabW, -(TABS_TOP - U.PAD_TOP))
		t:SetOn(tab == form.tab)
		t:Show()
	end
	ns.RefreshFormButton()
end

--------------------------------------------------------------------------------
-- Pieces
--------------------------------------------------------------------------------

-- a toggle in the cards' style: selected full ink, the rest faded
local function Toggle(parent, width, height, text)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(width, height)
	U.Card(b)
	b.text = W.Text(b, W.FONT_BODY, width - 6, text)
	b.text:SetJustifyH("CENTER")
	b.text:SetPoint("CENTER")
	Try(b.text.SetWordWrap, b.text, false)
	function b:SetOn(on, locked)
		if on then
			self:Look(0.22, 0.9, false)
			self.text:SetAlpha(1)
		else
			self:Look(0.03, 0.25, false)
			self.text:SetAlpha(0.45)
		end
		if locked then
			self.text:SetAlpha(0.8)
		end
	end
	return b
end

local function Cell(parent, width, tint)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(width, CELL_H)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	U.Card(b, tint)
	b.text = W.Text(b, W.FONT_BODY, width - 20, "")
	b.text:SetJustifyH("LEFT")
	b.text:SetPoint("LEFT", 10, 0)
	Try(b.text.SetWordWrap, b.text, false)
	b:SetScript("OnEnter", function(self)
		if self.tip then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.tip, 1, 1, 1)
			if self.tipLine then
				GameTooltip:AddLine(self.tipLine, nil, nil, nil, true)
			end
			if self.tipWarn then
				GameTooltip:AddLine(self.tipWarn, 1, 0.3, 0.3, true)
			end
			GameTooltip:Show()
		end
	end)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return b
end

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

local function CreateLayoutBody(width)
	local body = CreateFrame("Frame", nil, np)
	body:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	body:SetSize(width, BODY_H)
	np.layoutBody = body

	-- Blizzard's two, side by side (Refresh places them)
	np.width = width
	np.blizzard = {}
	for i = 1, 2 do
		np.blizzard[i] = Cell(body, (width - 6) / 2, BLIZZARD_TINT)
	end
	-- the account's five (+ New in the first free row)
	local y = CELL_H + CELL_GAP
	np.account = {}
	for i = 1, LIST_ROWS do
		local c = Cell(body, width)
		c:SetPoint("TOPLEFT", 0, -(y + (i - 1) * (CELL_H + CELL_GAP)))
		np.account[i] = c
	end
	y = y + LIST_ROWS * (CELL_H + CELL_GAP) + 2

	-- a title with its rule, tighter than the option pages'
	local function Head(at, text)
		local fs = W.Text(body, W.FONT_HEADER, width, text)
		fs:SetPoint("TOPLEFT", 0, -(at + 6))
		local rule = body:CreateTexture(nil, "ARTWORK")
		rule:SetHeight(1)
		local r, g, bl = W.Ink()
		rule:SetColorTexture(r, g, bl, 0.35)
		rule:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -3)
		rule:SetPoint("RIGHT", body, "LEFT", width, 0)
		return at + 6 + 16 + 3 + 6
	end

	-- action bars 1 to 8
	y = Head(y, L.NP_BARS)
	np.bars = {}
	local sq = 28
	for n = 1, 8 do
		local b = Toggle(body, sq, sq, tostring(n))
		b:SetPoint("TOPLEFT", (n - 1) * (sq + 6), -y)
		if n == 1 then
			W.TipScripts(b, L.UI_BAR_SHORT:format(1), L.BAR1_LOCKED)
		else
			b:SetScript("OnClick", function()
				local key = "bar" .. n
				form.ui[key] = not form.ui[key]
				ns.Refresh()
			end)
			W.TipScripts(b, function()
				return ns.G("OPTION_SHOW_ACTION_BAR", L.UI_BAR):format(n)
			end, function()
				return form.ui and form.ui["bar" .. n] and L.STATE_ON or L.STATE_OFF
			end)
		end
		np.bars[n] = b
	end
	y = y + sq + 2

	-- the elements, in two columns
	y = Head(y, L.NP_UI)
	np.elements = {}
	local colW, rowH, i = (width - 6) / 2, 22, 0
	for _, e in ipairs(ns.UIElements()) do
		if not e.bar then
			local label = ns.UILabel(e)
			local b = Toggle(body, colW, rowH, label)
			b:SetPoint("TOPLEFT", (i % 2) * (colW + 6), -(y + math.floor(i / 2) * (rowH + 5)))
			i = i + 1
			b.element = e
			b:SetScript("OnClick", function()
				form.ui[e.key] = not form.ui[e.key]
				ns.Refresh()
			end)
			W.TipScripts(b, label, function()
				return form.ui and form.ui[e.key] and L.STATE_ON or L.STATE_OFF
			end)
			np.elements[#np.elements + 1] = b
		end
	end
end

local function Pick(cell, selected, empty)
	if empty then
		cell:Look(0.02, 0.15, false)
	elseif selected then
		cell:Look(0.22, 0.9, true)
	else
		cell:Look(0.07, 0.35, false)
	end
end

local function RefreshLayoutBody()
	local blizzard, account = GridLayouts()
	-- a layout that went away (deleted meanwhile): back to the first one
	if form.layout.use and not ns.GetLayouts()[form.layout.use] then
		form.layout = { use = blizzard[1] and blizzard[1].index or 1 }
	end
	-- the row: Blizzard's two (a profile of the list keeps its own layout,
	-- nothing picked, until another is picked)
	local w = (np.width - 6) / 2
	for i, cell in ipairs(np.blizzard) do
		cell:ClearAllPoints()
		cell:SetWidth(w)
		cell.text:SetWidth(w - 20)
		cell:SetPoint("TOPLEFT", (i - 1) * (w + 6), 0)
	end
	for i, cell in ipairs(np.blizzard) do
		local l = blizzard[i]
		cell:SetShown(l ~= nil)
		if l then
			cell.text:SetText(l.name)
			cell.tip, cell.tipLine, cell.tipWarn = LayoutText(l), nil, nil
			Pick(cell, form.layout.use == l.index)
			cell:SetScript("OnClick", function()
				form.layout = { use = l.index }
				ns.Refresh()
			end)
		end
	end
	-- the account's slots don't matter any more: a profile keeps its layout
	-- as text (Layouts.lua)
	local full, max = false, 0
	for i, cell in ipairs(np.account) do
		local l = account[i]
		if l then
			cell.text:SetText(l.name)
			cell.tip, cell.tipLine, cell.tipWarn = l.name, nil, nil
			Pick(cell, form.layout.use == l.index)
			cell:SetEnabled(true)
			cell:SetScript("OnClick", function()
				form.layout = { use = l.index }
				ns.Refresh()
			end)
			cell:Show()
		elseif i == #account + 1 then
			-- the last row: + New (right click: what it copies), or full
			local making = form.layout.new
			if full then
				cell.text:SetText(L.NP_LAYOUTS_FULL_CELL)
				cell.tip, cell.tipLine = L.NP_NEW_CELL, nil
				cell.tipWarn = ns.G("HUD_EDIT_MODE_ERROR_MAX_ACCOUNT_LAYOUTS", L.NP_LAYOUT_FULL):format(max)
				Pick(cell, false, true)
				cell:SetScript("OnClick", nil)
			else
				cell.text:SetText(making and L.NP_NEW_FROM:format(form.layout.fromLabel or L.CURRENT_LAYOUT) or L.NP_NEW_CELL)
				cell.tip, cell.tipLine, cell.tipWarn = L.NP_NEW_CELL, L.NP_NEW_CELL_TIP, nil
				Pick(cell, making)
				cell:SetScript("OnClick", function(self, button)
					if button == "RightButton" then
						NewLayoutMenu(self)
						return
					end
					if not form.layout.new then
						form.layout = { new = true, fresh = true, from = "current", fromLabel = L.CURRENT_LAYOUT }
						ns.Refresh()
					end
				end)
			end
			cell:Show()
		else
			-- a free slot, after + New
			cell.text:SetText("")
			cell.tip, cell.tipLine, cell.tipWarn = nil, nil, nil
			Pick(cell, false, true)
			cell:SetScript("OnClick", nil)
			cell:Show()
		end
	end
	for n, b in ipairs(np.bars) do
		if n == 1 then
			b:SetOn(true, true)
		else
			b:SetOn(form.ui["bar" .. n] and true or false)
		end
	end
	for _, b in ipairs(np.elements) do
		b:SetOn(form.ui[b.element.key] and true or false)
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

-- a module's options for a profile: keybinds are left out (they change the
-- game at once), and so are rows only meant for the module's page (pageOnly)
local function ModuleItems(key)
	local def = ModuleDef(key)
	local ok, items = pcall(def and def.items or function() end)
	local out = {}
	for _, item in ipairs(ok and type(items) == "table" and items or {}) do
		if item.kind ~= "keybind" and not item.pageOnly then
			out[#out + 1] = item
		end
	end
	return out
end

local function CreateModulesBody(width)
	local body = CreateFrame("Frame", nil, np)
	body:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	body:SetSize(width, BODY_H)
	np.modulesBody = body
	np.customModules = CustomRow(body, L.FORM_CUSTOM_MODULES, L.FORM_CUSTOM_MODULES_DESC, ns.SetFormModules, L.INFO_MODULES)

	local listW = width - 22
	local scroll = CreateFrame("ScrollFrame", nil, body, ScrollTemplate())
	scroll:SetPoint("TOPLEFT", 0, -ROW_H)
	scroll:SetSize(listW, BODY_H - ROW_H - 18)
	-- a choice marked * changed: it reloads the game when applied
	np.moduleReload = W.Text(body, W.FONT_SMALL, width, L.RELOAD_LEGEND, 0.8)
	np.moduleReload:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 0, 2)
	np.moduleReload:Hide()
	if scroll.ScrollBar and scroll.ScrollBar.SetHideIfUnscrollable then
		scroll.ScrollBar:SetHideIfUnscrollable(true)
	end
	local list = CreateFrame("Frame", nil, scroll)
	list:SetSize(listW, 10)
	scroll:SetScrollChild(list)
	np.moduleScroll, np.moduleList, np.moduleListW = scroll, list, listW

	np.moduleRows = {}
	for _, m in ipairs(ns.KNOWN_MODULES) do
		if ns.AddonInstalled(m.addon) then
			local row = CreateFrame("Button", nil, list)
			row:SetSize(listW, CELL_H + 4)
			U.Card(row)
			row.key = m.key
			row.on = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
			row.on:SetSize(24, 24)
			row.on:SetPoint("LEFT", 6, 0)
			-- the asterisk: switching a module on or off reloads the game
			row.title = W.Text(row, W.FONT_HEADER, listW - 80, L[m.title] .. " *")
			row.title:SetPoint("LEFT", row.on, "RIGHT", 4, 0)
			row.arrow = W.Text(row, W.FONT_HEADER, nil, "+", 0.7)
			row.arrow:SetPoint("RIGHT", -12, 0)
			W.TipScripts(row.on, L[m.title], L.MODULE_SWITCH_DESC)
			row.on:SetScript("OnClick", function(self)
				ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
				form.modules[m.key] = self:GetChecked() and true or false
				ns.Refresh()
			end)
			row:SetScript("OnClick", function()
				np.openModule = np.openModule ~= m.key and m.key or nil
				ns.Refresh()
			end)
			W.TipScripts(row, L[m.title], L[m.desc])
			-- its options, built once
			local panel = CreateFrame("Frame", nil, list)
			panel:SetWidth(listW)
			panel.refreshers = {}
			local items = ModuleItems(m.key)
			local h = 8
			if #items > 0 then
				h = U.RenderItems(panel, items, 8)
			else
				-- nothing a profile keeps: what it does, and that it has none
				local fs, th = W.Text(panel, W.FONT_SMALL, listW - 20, L[m.desc] .. "\n\n" .. L.MODULE_NO_PROFILE, 0.8)
				fs:SetPoint("TOPLEFT", 10, -8)
				h = 8 + th
			end
			panel:SetHeight(h + 8)
			panel:Hide()
			row.panel = panel
			np.moduleRows[#np.moduleRows + 1] = row
		end
	end
	if #np.moduleRows == 0 then
		local note = W.Text(list, W.FONT_SMALL, listW, L.NO_MODULES, 0.8)
		note:SetPoint("TOPLEFT")
	end
	-- unticked: the modules can't be changed (over their rows only: the
	-- addons below have their own Don't change)
	np.moduleBlock = CreateFrame("Frame", nil, list)
	np.moduleBlock:SetPoint("TOPLEFT", list, "TOPLEFT")
	np.moduleBlock:SetSize(listW, 10)
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

-- a card: the icon, the name, the profile (Ace3) and the box on the first
-- line; under the name the version (red when out of date) and the author;
-- then, when it has them, a thin rule and the button that shows the addons
-- that go with it
local TEXT_H = 44 -- the name and the line under it
local MORE_H = 32 -- the rule and the button of the addons that go with it
local FIELD_MAX = 0.4 -- the profile field: at most this much of the card
local ADDON_ICON = 28
local CHILD_INDENT = 24
local TEXT_X = ADDON_ICON + 16

local openGroups = {} -- the groups shown open (this session)

-- the profile field's text: the one chosen, else Don't change
local function ProfileLabel(row)
	local chosen = row.ace and form.aceProfiles[row.ace]
	return L.ADDON_PROFILE:format(chosen or L.ACE_KEEP)
end

local function AddonRow(list, width)
	local r, g, bl = W.Ink()
	local row = CreateFrame("Frame", nil, list)
	row:SetSize(width, TEXT_H)
	U.Card(row)
	row:Look(0.07, 0.35, false)
	row.icon = ns.RoundIcon(row, ADDON_ICON)
	row.icon:SetPoint("TOPLEFT", 8, -8)
	row.on = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
	row.on:SetSize(24, 24)
	row.on:SetPoint("TOPRIGHT", -6, -9)
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
	local textW = width - TEXT_X - 40
	row.name = W.Text(row, W.FONT_BODY, textW, "")
	row.name:SetPoint("TOPLEFT", TEXT_X, -8)
	Try(row.name.SetWordWrap, row.name, false)
	row.info = W.Text(row, W.FONT_SMALL, textW, "", 0.8)
	row.info:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -3)
	Try(row.info.SetWordWrap, row.info, false)
	-- the profile: a field in ink, as Copy from in the header
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
	-- a thin rule over the button of the addons that go with it
	row.rule = row:CreateTexture(nil, "ARTWORK")
	row.rule:SetHeight(1)
	row.rule:SetColorTexture(r, g, bl, 0.25)
	row.rule:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -TEXT_H)
	row.rule:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -TEXT_H)
	-- the addons that go with it: a button with a border, in ink
	row.more = CreateFrame("Button", nil, row)
	row.more:SetHeight(20)
	U.Card(row.more)
	row.more:Look(0.04, 0.6, false)
	row.more.text = W.Text(row.more, W.FONT_SMALL, nil, "")
	row.more.text:SetPoint("CENTER")
	row.more:SetScript("OnClick", function()
		openGroups[row.group] = not openGroups[row.group] or nil
		ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		ns.Refresh()
	end)
	W.TipScripts(row.more, function()
		return row.title
	end, function()
		return L.ADDON_CHILDREN:format(#(row.children or {}))
	end)
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
		row.info:SetAlpha(dim and 0.45 or 0.8)
		row.icon:SetDesaturated(dim or state == false)
		local x = child and CHILD_INDENT or 0
		local rowW = width - x
		local h = TEXT_H
		-- the room the name has: up to the box (or the card's edge)
		local textW = rowW - TEXT_X - (e.addon and 38 or 10)
		-- the profile field: Ace3 addons, on the first line, left of the box
		-- (greyed while off here)
		local hasProfiles = row.db ~= nil
		row.dd:SetShown(hasProfiles)
		if hasProfiles then
			local on = state ~= false and not dim
			row.dd.text:SetText(ProfileLabel(row))
			row.dd:Fit(math.floor(rowW * FIELD_MAX))
			row.dd:ClearAllPoints()
			if e.addon then
				row.dd:SetPoint("RIGHT", row.on, "LEFT", -4, 0)
			else
				row.dd:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -11)
			end
			row.dd:SetEnabled(on)
			row.dd:SetAlpha(on and 1 or 0.45)
			textW = textW - (tonumber(row.dd:GetWidth()) or 0) - 8
		end
		row.name:SetWidth(math.max(textW, 40))
		row.info:SetWidth(math.max(textW, 40))
		-- the button of a main addon, centred under a thin rule: + 4 addons (open:
		-- - 4 addons)
		local hasKids = #row.children > 0
		row.rule:SetShown(hasKids)
		row.more:SetShown(hasKids)
		if hasKids then
			row.more.text:SetText(L.ADDON_MORE:format(openGroups[row.group] and "-" or "+", #row.children))
			row.more:SetWidth((tonumber(row.more.text:GetStringWidth()) or 80) + 20)
			row.more:ClearAllPoints()
			row.more:SetPoint("TOP", row, "TOP", 0, -(h + 6))
			h = h + MORE_H
		end
		local rowH = h
		row:SetHeight(rowH)
		row:SetWidth(rowW)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", list, "TOPLEFT", x, -y)
		row:Show()
		y = y + rowH + CELL_GAP
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

-- The Addons tab: a list that scrolls
local function CreateAddonsBody(width)
	local body = CreateFrame("Frame", nil, np)
	body:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	body:SetSize(width, BODY_H)
	np.addonsBody = body
	np.customAddons = CustomRow(body, L.FORM_CUSTOM_ADDONS, L.FORM_CUSTOM_ADDONS_DESC, function(on)
		ns.SetFormAddons(on)
	end, L.INFO_ADDONS)
	local listW = width - 22
	local scroll = CreateFrame("ScrollFrame", nil, body, ScrollTemplate())
	scroll:SetPoint("TOPLEFT", 0, -ROW_H)
	scroll:SetSize(listW, BODY_H - ROW_H - 18)
	-- switching an addon on or off reloads the game when applied
	np.addonsReload = W.Text(body, W.FONT_SMALL, width, L.RELOAD_LEGEND, 0.8)
	np.addonsReload:SetPoint("BOTTOMLEFT", body, "BOTTOMLEFT", 0, 2)
	np.addonsReload:Hide()
	if scroll.ScrollBar and scroll.ScrollBar.SetHideIfUnscrollable then
		scroll.ScrollBar:SetHideIfUnscrollable(true)
	end
	local list = CreateFrame("Frame", nil, scroll)
	list:SetSize(listW, 10)
	scroll:SetScrollChild(list)
	np.aceList, np.aceListW = list, listW
	body:Hide()
end

local function RefreshAddonsBody()
	np.customAddons:SetChecked(form.customAddons and true or false)
	np.aceList:SetHeight(math.max(RefreshAddonList(), 10))
	np.addonsReload:SetShown(AddonsChanged())
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
		local open = np.openModule == row.key
		row:Look(open and 0.16 or 0.07, open and 0.8 or 0.35, open)
		row.arrow:SetText(open and "-" or "+")
		y = y + CELL_H + 4 + CELL_GAP
		if open then
			row.panel:ClearAllPoints()
			row.panel:SetPoint("TOPLEFT", np.moduleList, "TOPLEFT", 0, -y)
			row.panel:Show()
			for _, refresh in ipairs(row.panel.refreshers) do
				refresh()
			end
			y = y + row.panel:GetHeight() + CELL_GAP
		else
			row.panel:Hide()
		end
	end
	np.moduleBlock:SetHeight(math.max(y, 1))
	np.moduleList:SetHeight(math.max(y, 10))
	np.moduleReload:SetShown(on and not SameFlags(form.modules, (form.orig or {}).modules) or false)
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

-- Copy from, for one part: as the game is now, or another profile (only
-- the ones that have something to give). On Global it asks first: the
-- shared set changes for every profile that uses it.
local function FieldCopy(field, p, label)
	if form.scope[field] == "profile" then
		ns.FormCopyField(field, p, label)
		return
	end
	U.Confirm(L.POPUP_COPY_GLOBAL, function()
		ns.FormCopyField(field, p, label)
	end)
end

local function FieldSources(field, root)
	local function Entry(label, p)
		return root:CreateRadio(label, function()
			return form.copied ~= nil and form.copied[field] == label
		end, function()
			-- after the menu closes (the popup on Global)
			C_Timer.After(0, function()
				FieldCopy(field, p, label)
			end)
		end)
	end
	Entry(L.COPY_CURRENT, nil)
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
		local b = Entry(name, p)
		local has
		if field == "settings" then
			has = ns.SettingsOf(p) ~= nil
		elseif field == "keys" then
			has = ns.KeysHolder(p).keys ~= nil
		else
			has = ns.ScopeOf(p, "bars") == "profile" and p.id and ns.charDB.skills[p.id] ~= nil
		end
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
	local r, g, bl = W.Ink()
	np.fields = {}
	local y = 0
	local half = (width - 6) / 2
	for _, f in ipairs(FIELDS) do
		local row = {}
		-- its title and rule
		local title = W.Text(body, W.FONT_HEADER, nil, L[f.title])
		title:SetPoint("TOPLEFT", 0, -(y + 4))
		local info = W.Info(body, L[f.title], L["INFO_" .. f.key:upper()])
		info:SetPoint("LEFT", title, "RIGHT", 4, 0)
		local rule = body:CreateTexture(nil, "ARTWORK")
		rule:SetHeight(1)
		rule:SetColorTexture(r, g, bl, 0.35)
		rule:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
		rule:SetPoint("RIGHT", body, "LEFT", width, 0)
		y = y + 4 + 16 + 3 + 6
		-- Global or Profile
		row.global = Toggle(body, half, 26, L.SCOPE_GLOBAL)
		row.global:SetPoint("TOPLEFT", 0, -y)
		row.global:SetScript("OnClick", function()
			ns.SetFormScope(f.key, "global")
		end)
		W.TipScripts(row.global, L.SCOPE_GLOBAL, L["SCOPE_GLOBAL_" .. f.key:upper() .. "_DESC"])
		row.own = Toggle(body, half, 26, L.SCOPE_PROFILE)
		row.own:SetPoint("TOPLEFT", half + 6, -y)
		row.own:SetScript("OnClick", function()
			ns.SetFormScope(f.key, "profile")
		end)
		W.TipScripts(row.own, L.SCOPE_PROFILE, L["SCOPE_PROFILE_" .. f.key:upper() .. "_DESC"])
		y = y + 26 + 6
		-- what the choice means, in a line or two
		row.note = W.Text(body, W.FONT_SMALL, width, "", 0.8)
		row.note:SetPoint("TOPLEFT", 0, -y)
		Try(row.note.SetMaxLines, row.note, 2)
		-- Copy from: Blizzard's dropdown (not for Global bars)
		row.copy = CreateFrame("DropdownButton", nil, body, "WowStyle1DropdownTemplate")
		row.copy:SetPoint("TOPLEFT", 0, -(y + 26))
		row.copy:SetWidth(220)
		Try(row.copy.SetDefaultText, row.copy, L.SCOPE_COPY_DEFAULT)
		row.copy:SetupMenu(function(_, root)
			FieldSources(f.key, root)
		end)
		W.TipScripts(row.copy, L.NP_COPY_PROFILE, function()
			local tip = L["SCOPE_COPY_" .. f.key:upper() .. "_DESC"]
			if form.scope[f.key] ~= "profile" then
				tip = tip .. "\n\n" .. L.SCOPE_COPY_GLOBAL_NOTE
			end
			return tip
		end, true)
		y = y + 26 + 24 + 6
		np.fields[f.key] = row
	end
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
		row.global:SetOn(not own)
		row.own:SetOn(own)
		row.note:SetText(FieldNote(f.key, own))
		row.copy:SetShown(own or f.key ~= "bars")
		Try(row.copy.GenerateMenu, row.copy)
	end
end

--------------------------------------------------------------------------------

function ns.RefreshNewPreset()
	if not (np and ns.creating and form.layout) then
		return
	end
	local tab = not form.choosing and form.tab or nil
	np.choiceBody:SetShown(form.choosing and true or false)
	np.layoutBody:SetShown(tab == "layout")
	np.modulesBody:SetShown(tab == "modules")
	np.addonsBody:SetShown(tab == "addons")
	np.settingsBody:SetShown(tab == "settings")
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
	elseif tab == "modules" then
		RefreshModulesBody()
	elseif tab == "addons" then
		RefreshAddonsBody()
	elseif tab == "settings" then
		RefreshSettingsBody()
	else
		RefreshLayoutBody()
	end
end

-- what the guide's tips point at (Tour.lua)
function ns.FormFrames()
	if not (np and head and foot) then
		return {}
	end
	return {
		name = head.name, customize = np.customize, next = foot.next,
		layout = np.blizzard and np.blizzard[1], bars = np.bars and np.bars[1],
		frames = np.elements and np.elements[1],
		settings = np.fields and np.fields.settings and np.fields.settings.global,
		modules = np.customModules, addons = np.customAddons,
	}
end
ns.FormTabs = Tabs

-- built with the window (UI.lua)
function ns.CreateProfileForm()
	local rightPage = U.rightPage
	local width = U.PAGE_W - U.PAD * 2
	np = CreateFrame("Frame", nil, rightPage)
	np:SetAllPoints()
	rightPage.newpreset = np
	CreateChoiceBody(width)
	CreateLayoutBody(width)
	CreateModulesBody(width)
	CreateAddonsBody(width)
	CreateSettingsBody(width)
	CreateHead(rightPage, width)
	CreateFoot(rightPage, width)
end
