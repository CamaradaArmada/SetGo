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
--   Options: Apply own settings (unticked: the profile neither saves nor
--     applies character settings), then the option pages.
--   At the bottom, always: one button. A new profile: Next until every tab
--     has been seen, then Save and Apply. One in the list: Save when
--     something changed, then Apply.
--   ns.creating = { edit = name or nil } while the form is open
--------------------------------------------------------------------------------

local form = {}
ns.form = form

local FORM_TABS = { "layout", "modules", "options" }
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
local ROW_H = 30 -- Change modules / Apply own settings
-- a profile's Options tab: the option pages in a box under its row
ns.FORM_BOX = { top = BODY_TOP + ROW_H + 4, bottom = FOOT_H + 2 }

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
	for i, t in ipairs(FORM_TABS) do
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
	form.visited = { layout = true }
	local index = p and ns.LayoutIndex(p.layout) or ActiveGridLayout()
	form.layout = { use = index }
	-- what it switches on and its modules: the profile's, else the game's
	form.ui = ns.UILive()
	form.modules = ns.ModuleStates()
	form.custom, form.customModules = false, false
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
		form.custom = p.custom and true or false
		form.settings = Copy(p.settings)
		form.customModules = p.customModules and true or false
		form.moduleSettings = Copy(p.moduleSettings)
	end
	-- the module pages show something even when the profile keeps none yet
	if form.customModules and not form.moduleSettings then
		form.moduleSettings = ns.ModuleSnapshot()
	end
	form.orig = {
		use = index, ui = Copy(form.ui), modules = Copy(form.modules), icon = form.icon,
		custom = form.custom, settings = Copy(form.settings),
		customModules = form.customModules, moduleSettings = Copy(form.moduleSettings),
	}
end

-- something on the form differs from the profile (a new one always does)
local function Dirty()
	if not form.edit then
		return true
	end
	local o = form.orig or {}
	if NameText() ~= form.edit then
		return true
	end
	if form.layout.new or form.layout.use ~= o.use or form.icon ~= o.icon then
		return true
	end
	if form.custom ~= o.custom or form.customModules ~= o.customModules then
		return true
	end
	return not (SameFlags(form.ui, o.ui) and SameFlags(form.modules, o.modules)
		and SameValues(form.settings, o.settings) and SameValues(form.moduleSettings, o.moduleSettings))
end
ns.FormDirty = Dirty

-- every tab seen (a new profile)
local function AllVisited()
	for _, tab in ipairs(FORM_TABS) do
		if not form.visited[tab] then
			return false
		end
	end
	return true
end

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
	if tab == "options" and not ns.SettingsReady() then
		ns.Print(L.MSG_NOT_READY)
		return
	end
	form.tab = tab
	form.visited[tab] = true
	if tab == "options" then
		ns.Select("profileopts")
	else
		ns.Select("newpreset")
	end
end

-- Leaves the form (nothing on it is kept until saved)
function ns.LeaveForm(after)
	ns.creating = nil
	ns.optionsDraft, ns.moduleDraft = nil, nil
	if after then
		after()
	end
end

-- Apply own settings: ticked on a profile without any, they start as this
-- character has them. Unticked, they are kept.
function ns.SetFormCustom(on)
	form.custom = on and true or false
	if form.custom and not form.settings then
		form.settings = ns.OptionSnapshot()
	end
	if U.state.group == "profileopts" then
		ns.ShowIndex(U.state.index or 1, true)
	else
		ns.Refresh()
	end
end

-- Change modules: the same, for the modules and their options
function ns.SetFormModules(on)
	form.customModules = on and true or false
	if form.customModules and not form.moduleSettings then
		form.moduleSettings = ns.ModuleSnapshot()
	end
	ns.Refresh()
end

-- Copy from: what the tab shows, from the game as it is now (p nil) or from
-- another profile
local function CopyFrom(p, what)
	if what == "layout" then
		if p then
			local index = ns.LayoutIndex(p.layout)
			if index then
				form.layout = { use = index }
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
	elseif what == "options" then
		form.settings = p and Copy(p.settings) or ns.OptionSnapshot()
		ns.SetFormCustom(true)
	end
end
ns.FormCopyFrom = CopyFrom

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
	form.layout = { new = true, template = text, imported = true, fromLabel = L.IMPORTED }
	ns.Refresh()
end

-- Import profile (the cards): a SetGo! profile as text, into a new
-- profile's form, every tab filled; it is made when saved
function ns.ImportProfile(text)
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
	if ns.AccountLayoutsFull() then
		ns.Print(L.MSG_IMPORT_NO_LAYOUT)
	else
		form.layout = { new = true, template = profile.layout, imported = true, fromLabel = profile.name }
	end
	for key, on in pairs(profile.ui) do
		form.ui[key] = on
	end
	form.icon = profile.icon
	if profile.custom then
		form.custom, form.settings = true, profile.settings
	end
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
	head.name:SetText(ns.FreePresetName(profile.name))
	ns.Print(L.MSG_PROFILE_IMPORTED:format(profile.name))
	ns.Refresh()
end

StaticPopupDialogs.SETGO_IMPORT_PROFILE = {
	text = "%s",
	button1 = ACCEPT or "Accept",
	button2 = CANCEL or "Cancel",
	hasEditBox = true,
	maxLetters = 0,
	editBoxWidth = 320,
	OnAccept = function(self)
		local text = U.EditBoxOf(self):GetText()
		C_Timer.After(0, function()
			ns.ImportProfile(text)
		end)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

function ns.AskImportProfile()
	C_Timer.After(0, function()
		U.Popup("SETGO_IMPORT_PROFILE", L.POPUP_IMPORT_PROFILE)
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

function ns.ExportProfileText(name)
	local text = ns.ExportProfile(name)
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
	picker = CreateFrame("Frame", "SetGoIconPicker", U.frame, template)
	local w = PICK_COLS * (PICK_SIZE + PICK_GAP) + 50
	local h = PICK_ROWS * (PICK_SIZE + PICK_GAP) + PICK_TOP + 20
	picker:SetSize(w, h)
	picker:SetPoint("TOPLEFT", U.rightPage, "TOPLEFT", 20, -60)
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

function ns.PickIcon(onPick)
	if not picker then
		CreatePicker()
	end
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
		custom = form.custom, settings = form.settings,
		customModules = form.customModules, moduleSettings = form.moduleSettings,
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
		opts.layout = { template = data, from = fromName, imported = form.layout.imported }
		-- a SetGo! template also says which bars show
		for var, on in pairs(form.layout.bars or {}) do
			local e = ns.UI_VARS[var]
			if e then
				opts.ui[e.key] = on and true or false
			end
		end
	else
		opts.layout = { use = form.layout.use }
	end
	-- a new layout made now is made active when applied right after
	opts.noApply = not apply
	if apply and first then
		-- the first profile: Edit Mode after its reload
		ns.charDB.openEditMode = true
	end
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
		or form.custom or form.customModules
		or not (SameFlags(form.ui, o.ui) and SameFlags(form.modules, o.modules))
end

-- Save (closing the window): true when saved, or nothing to save
function ns.FormSaveOnly()
	if not ns.FormHasChanges() then
		return true
	end
	local name = CheckName()
	if not name then
		return false
	end
	FormSave(name, false)
	return ns.ProfileOf(name) ~= nil
end

-- the form's button
function ns.FormButton()
	if not form.edit then
		if not AllVisited() then
			-- Next: the next tab not seen yet
			for _, tab in ipairs(FORM_TABS) do
				if not form.visited[tab] then
					ns.ShowFormTab(tab)
					return
				end
			end
		end
		local name = CheckName()
		if not name then
			return
		end
		local text = L.POPUP_NP_SAVE_APPLY:format(name)
		if form.layout.new then
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
		local empty = (what == "options" and not (p and p.settings))
			or (what == "modules" and not (p and (p.customModules or p.moduleSettings)))
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

	-- Copy from, under the name: a line of ink that opens the menu
	head.copy = CreateFrame("Button", nil, head)
	head.copy:SetPoint("TOPLEFT", x + 4, -38)
	head.copy:SetSize(200, 20)
	head.copy.text = W.Text(head.copy, W.FONT_BODY, nil, L.NP_COPY_FROM .. " " .. L.COPY_CURRENT, 0.85)
	head.copy.text:SetPoint("LEFT")
	head.copy.arrow = head.copy:CreateTexture(nil, "ARTWORK")
	head.copy.arrow:SetSize(14, 14)
	head.copy.arrow:SetPoint("LEFT", head.copy.text, "RIGHT", 4, -1)
	head.copy.arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
	head.copy.arrow:SetVertexColor(r, g, bl)
	head.copy:SetWidth((head.copy.text:GetStringWidth() or 120) + 22)
	local line = head.copy:CreateTexture(nil, "HIGHLIGHT")
	line:SetHeight(1)
	line:SetColorTexture(r, g, bl, 0.6)
	line:SetPoint("BOTTOMLEFT", head.copy.text, "BOTTOMLEFT", 0, -2)
	line:SetPoint("BOTTOMRIGHT", head.copy.text, "BOTTOMRIGHT", 0, -2)
	head.copy:SetScript("OnClick", function(self)
		if MenuUtil and MenuUtil.CreateContextMenu then
			MenuUtil.CreateContextMenu(self, function(_, root)
				CopySources(root)
			end)
		end
	end)
	W.TipScripts(head.copy, L.NP_COPY_PROFILE, function()
		return L["NP_COPY_" .. (form.tab or "layout"):upper() .. "_DESC"]
	end)

	-- the tabs, the width of the page, on a darker band
	local band = head:CreateTexture(nil, "BACKGROUND")
	band:SetColorTexture(r, g, bl, 0.1)
	band:SetPoint("TOPLEFT", 0, -(TABS_TOP - U.PAD_TOP))
	band:SetSize(width, TAB_H)
	head.tabs = {}
	local tabW = width / #FORM_TABS
	for i, tab in ipairs(FORM_TABS) do
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
		if not form.edit then
			return AllVisited() and L.NP_SAVE_APPLY_DESC or L.NP_NEXT_DESC
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
	if not edit then
		local seen = 0
		for _, tab in ipairs(FORM_TABS) do
			seen = seen + (form.visited[tab] and 1 or 0)
		end
		if AllVisited() then
			foot.main:SetText(L.SAVE_AND_APPLY)
			foot.pending:SetText(L.FORM_NEW_READY)
		else
			foot.main:SetText(L.GUIDE_NEXT)
			foot.pending:SetText(L.FORM_STEP:format(seen, #FORM_TABS))
		end
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
	head:SetShown(onForm)
	foot:SetShown(onForm)
	if not onForm then
		return
	end
	head.icon.tex:SetTexture(form.icon or DEFAULT_ICON)
	for tab, t in pairs(head.tabs) do
		t:SetOn(tab == form.tab)
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
local function CustomRow(parent, label, tip, onClick)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb:SetSize(26, 26)
	cb:SetPoint("TOPLEFT", parent, "TOPLEFT", -3, 0)
	local text = W.Text(parent, W.FONT_BODY, nil, label)
	text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
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
				form.layout = { new = true, from = from, fromLabel = label }
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
					form.layout = { new = true, template = t.data, bars = t.bars, fromLabel = t.name }
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

local function CreateLayoutBody(width)
	local body = CreateFrame("Frame", nil, np)
	body:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	body:SetSize(width, BODY_H)
	np.layoutBody = body

	-- Blizzard's two, side by side
	np.blizzard = {}
	local half = (width - 6) / 2
	for i = 1, 2 do
		local c = Cell(body, half, BLIZZARD_TINT)
		c:SetPoint("TOPLEFT", (i - 1) * (half + 6), 0)
		np.blizzard[i] = c
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
	local full, max = ns.AccountLayoutsFull()
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
						form.layout = { new = true, from = "current", fromLabel = L.CURRENT_LAYOUT }
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
	np.customModules = CustomRow(body, L.FORM_CUSTOM_MODULES, L.FORM_CUSTOM_MODULES_DESC, ns.SetFormModules)

	local listW = width - 22
	local scroll = CreateFrame("ScrollFrame", nil, body, ScrollTemplate())
	scroll:SetPoint("TOPLEFT", 0, -ROW_H)
	scroll:SetSize(listW, BODY_H - ROW_H)
	if scroll.ScrollBar and scroll.ScrollBar.SetHideIfUnscrollable then
		scroll.ScrollBar:SetHideIfUnscrollable(true)
	end
	local list = CreateFrame("Frame", nil, scroll)
	list:SetSize(listW, 10)
	scroll:SetScrollChild(list)
	np.moduleScroll, np.moduleList = scroll, list

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
			row.title = W.Text(row, W.FONT_HEADER, listW - 80, L[m.title])
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
	-- unticked: nothing can be changed
	np.moduleBlock = CreateFrame("Frame", nil, body)
	np.moduleBlock:SetPoint("TOPLEFT", scroll, "TOPLEFT")
	np.moduleBlock:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT")
	np.moduleBlock:EnableMouse(true)
	np.moduleBlock:EnableMouseWheel(true)
	np.moduleBlock:SetFrameLevel(scroll:GetFrameLevel() + 30)
	W.TipScripts(np.moduleBlock, L.FORM_CUSTOM_MODULES, L.FORM_MODULES_OFF)
end

local function RefreshModulesBody()
	local on = form.customModules
	np.customModules:SetChecked(on)
	np.moduleBlock:SetShown(not on)
	np.moduleList:SetAlpha(on and 1 or 0.45)
	local y = 0
	for _, row in ipairs(np.moduleRows) do
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
	np.moduleList:SetHeight(math.max(y, 10))
end

--------------------------------------------------------------------------------
-- The Options tab: Apply own settings, over the box the option pages show in
-- (UI.lua places them)
--------------------------------------------------------------------------------

local function CreateOptionsRow(rightPage, width)
	local row = CreateFrame("Frame", nil, rightPage)
	row:SetPoint("TOPLEFT", U.PAD, -BODY_TOP)
	row:SetSize(width, BODY_H)
	row:SetFrameLevel(rightPage:GetFrameLevel() + 20)
	row:EnableMouse(false)
	np.optionsRow = row
	np.custom = CustomRow(row, L.FORM_CUSTOM, L.FORM_CUSTOM_DESC, ns.SetFormCustom)
	-- the box
	local box = CreateFrame("Frame", nil, row)
	box:SetPoint("TOPLEFT", 0, -(ns.FORM_BOX.top - BODY_TOP))
	box:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
	U.Card(box)
	box:Look(0.03, 0.4, false)
	box:EnableMouse(false)
	-- under the pages it frames
	box:SetFrameLevel(rightPage:GetFrameLevel())
	row:Hide()
end

--------------------------------------------------------------------------------

function ns.RefreshNewPreset()
	if not (np and ns.creating and form.layout) then
		return
	end
	local modules = form.tab == "modules"
	np.layoutBody:SetShown(not modules)
	np.modulesBody:SetShown(modules)
	if modules then
		RefreshModulesBody()
	else
		RefreshLayoutBody()
	end
end

-- the Options tab's row and box (shown with the option pages)
function ns.RefreshFormOptions(shown)
	if not np then
		return
	end
	np.optionsRow:SetShown(shown and true or false)
	if shown then
		np.custom:SetChecked(form.custom and true or false)
	end
end

-- built with the window (UI.lua)
function ns.CreateProfileForm()
	local rightPage = U.rightPage
	local width = U.PAGE_W - U.PAD * 2
	np = CreateFrame("Frame", nil, rightPage)
	np:SetAllPoints()
	rightPage.newpreset = np
	CreateLayoutBody(width)
	CreateModulesBody(width)
	CreateOptionsRow(rightPage, width)
	CreateHead(rightPage, width)
	CreateFoot(rightPage, width)
end
