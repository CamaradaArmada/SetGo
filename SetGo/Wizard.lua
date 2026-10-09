local _, ns = ...
local L, W = ns.L, ns.Widgets
local Try = ns.Try

--------------------------------------------------------------------------------
-- The first profile: a book of one page, step by step, shown while the
-- account has no profile yet (the first time, or when SetGo! opens). After
-- that, a new profile is made on the book's form, with every option.
--   1 Welcome: what a profile keeps. Create profile, or Skip (SetGo!
--     itself, and the guide doesn't come back on its own).
--   2 Presets: the ones that come with SetGo! (one is applied at once, after
--     asking: the game reloads), or Custom. Skipped while there are none.
--   3 Name, icon and the screen: action bars and Blizzard's elements,
--     switched on and off at once to be seen. Leaving without saving puts
--     them back (and reloads, when action bars were touched).
--   4 Modules: each one with what it does, on or off, and its options.
--     Save and apply: a layout of its own (copied from the one in use), the
--     reload, then Edit Mode.
-- Global for settings, keybinds and bar slots: with one profile there is
-- nothing to choose yet.
--------------------------------------------------------------------------------

local FRAME_W, FRAME_H = 493, 640
local TOP_BAR = 51
local PAD, PAD_TOP = 46, 30
local CW = FRAME_W - 6 - PAD * 2
local FOOT_H = 70
local STEPS = 4
local ICON = 64
local NAME_MAX = 24
local DEFAULT_ICON = 134400 -- the question mark

local frame, page
local pages = {}
local wf -- the profile being made
local leaving = false -- closing after the player chose (nothing asked)

local function Atlas(tex, atlas, useSize)
	if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
		tex:SetAtlas(atlas, useSize and true or false)
		return true
	end
	return false
end

local function Copy(t)
	local out = {}
	for k, v in pairs(t or {}) do
		out[k] = v
	end
	return out
end

local function Popup(text, onAccept)
	ns.ui.Confirm(text, onAccept)
end

--------------------------------------------------------------------------------
-- The profile being made
--------------------------------------------------------------------------------

local function Fresh()
	wf = {
		step = 1,
		icon = nil,
		ui = ns.UILive(),
		modules = ns.ModuleStates(),
		customModules = true,
	}
	wf.origUI = Copy(wf.ui)
	-- the module pages change these, not the game (Core.lua: ModuleDraft)
	function wf:OnChanged()
		ns.RefreshWizard()
	end
	if ns.SettingsReady() then
		wf.moduleSettings = ns.ModuleSnapshot()
	end
	if page and page.name then
		page.name:SetText("")
	end
end

local function NameText()
	return page and page.name and strtrim(page.name:GetText() or "") or ""
end

-- the screen changed on step 3, or anything else filled in
local function HasChanges()
	if not wf then
		return false
	end
	if NameText() ~= "" or wf.icon then
		return true
	end
	for key, on in pairs(wf.ui) do
		if (wf.origUI[key] and true or false) ~= (on and true or false) then
			return true
		end
	end
	for key, on in pairs(wf.modules) do
		if ns.ModuleOn(key) ~= on then
			return true
		end
	end
	return false
end

-- Through Blizzard's own settings, as its Options window does: the bars
-- redraw and the elements show at once. What this touches stays tainted
-- until the next reload: saving reloads, and so does leaving after a
-- change (wf.touched).
local function SetElement(e, on)
	local setting = Settings and Settings.GetSetting and Try(Settings.GetSetting, e.var or e.cvar)
	if setting and setting.SetValue then
		Try(setting.SetValue, setting, on and true or false)
	elseif e.cvar then
		Try(C_CVar.SetCVar, e.cvar, on and "1" or "0")
	elseif e.bar and SetActionBarToggles then
		local bars = { GetActionBarToggles() }
		bars[e.bar] = on and true or false
		Try(SetActionBarToggles, unpack(bars, 1, select("#", GetActionBarToggles())))
	end
end

local function ElementOf(key)
	for _, e in ipairs(ns.UIElements()) do
		if e.key == key then
			return e
		end
	end
end

-- the screen as it was before the guide
local function PutBack()
	if not wf or wf.saved or InCombatLockdown() then
		return
	end
	for _, e in ipairs(ns.UIElements()) do
		local was = wf.origUI[e.key] and true or false
		if (wf.ui[e.key] and true or false) ~= was then
			SetElement(e, was)
			wf.ui[e.key] = was
		end
	end
end

--------------------------------------------------------------------------------
-- Saving
--------------------------------------------------------------------------------

local function CheckName()
	local name = NameText()
	if name == "" then
		ns.Print(L.MSG_NAME_EMPTY)
		ns.ShowWizardStep(3)
		page.name:SetFocus()
		return nil
	end
	if ns.ProfileOf(name) then
		ns.Print(L.MSG_NAME_TAKEN:format(name))
		ns.ShowWizardStep(3)
		page.name:SetFocus()
		return nil
	end
	return name
end

-- its layout: a copy of the one in use (kept in the profile; Layouts.lua)
local function NewLayout()
	local ref = ns.CurrentLayoutRef()
	local data = ref and ns.LayoutText(ref)
	if not data then
		return { use = ns.GetLayout() }
	end
	return { template = data, from = ns.LayoutName(ref) }
end

local function Create(opts)
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return
	end
	ns.moduleDraft = nil
	-- Edit Mode after the reload, to place everything
	ns.charDB.openEditMode = true
	wf.saved = true
	-- the tour, once Edit Mode closes after the reload (Tour.lua)
	ns.charDB.tourPending = true
	if not ns.CreateProfile(opts) then
		wf.saved = nil
		ns.charDB.openEditMode = nil
		ns.charDB.tourPending = nil
		return
	end
	leaving = true
	frame:Hide()
	leaving = false
end

local function SaveAndApply()
	local name = CheckName()
	if not name then
		return
	end
	if not ns.SettingsReady() then
		ns.Print(L.MSG_NOT_READY)
		return
	end
	Popup(L.WIZ_POPUP_SAVE:format(name), function()
		Create({
			name = name,
			icon = wf.icon,
			ui = Copy(wf.ui),
			modules = Copy(wf.modules),
			customModules = true,
			moduleSettings = wf.moduleSettings,
			scope = ns.SharedScope(),
			layout = NewLayout(),
		})
	end)
end

-- a preset that comes with SetGo! (Profiles.lua): made and applied at
-- once, with its own name and icon, over the screen as it was before the
-- preview
local function ApplyPreset(entry)
	if not ns.SettingsReady() then
		ns.Print(L.MSG_NOT_READY)
		return
	end
	Popup(L.WIZ_POPUP_PRESET:format(entry.name), function()
		Create(ns.PresetOpts(entry, wf.origUI))
	end)
end

--------------------------------------------------------------------------------
-- Pieces
--------------------------------------------------------------------------------

local function Head(parent, icon, title, desc)
	local h = CreateFrame("Frame", nil, parent)
	h:SetSize(CW, ICON)
	h:SetPoint("TOPLEFT", 0, 0)
	h.icon = ns.RoundIcon(h, ICON)
	h.icon:SetPoint("TOPLEFT", 0, 0)
	h.icon:SetTexture(icon)
	h.name = W.Text(h, W.FONT_TITLE, CW - ICON - 14, title)
	h.name:SetPoint("TOPLEFT", ICON + 14, -2)
	h.desc = W.Text(h, W.FONT_SMALL, CW - ICON - 14, desc, 0.85)
	h.desc:SetPoint("TOPLEFT", h.name, "BOTTOMLEFT", 0, -6)
	local divider = parent:CreateTexture(nil, "ARTWORK")
	if not Atlas(divider, "spellbook-divider") then
		divider:SetColorTexture(0, 0, 0, 0)
	end
	divider:SetHeight(12)
	divider:SetPoint("TOPLEFT", -6, -(ICON + 10))
	divider:SetPoint("TOPRIGHT", 6, -(ICON + 10))
	return h, ICON + 30
end

-- a toggle in the cards' style: on in full ink, off faded
local function Toggle(parent, width, height, text)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(width, height)
	ns.ui.Card(b)
	b.text = W.Text(b, W.FONT_BODY, width - 6, text)
	b.text:SetJustifyH("CENTER")
	b.text:SetPoint("CENTER")
	Try(b.text.SetWordWrap, b.text, false)
	function b:SetOn(on, locked)
		if on then
			self:Look(0.22, 0.9, false)
			self.text:SetAlpha(locked and 0.8 or 1)
		else
			self:Look(0.03, 0.25, false)
			self.text:SetAlpha(0.45)
		end
	end
	return b
end

local function Section(parent, y, text)
	return W.Header(parent, y, CW, text)
end

local function ScrollTemplate()
	return C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("ScrollFrameTemplate")
		and "ScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
end

--------------------------------------------------------------------------------
-- Step 1: Profiles
--------------------------------------------------------------------------------

local KEEPS = {
	{ icon = "Interface\\Icons\\INV_Misc_Map_01", title = "WIZ_KEEP_LAYOUT", desc = "WIZ_KEEP_LAYOUT_DESC" },
	{ icon = "Interface\\Icons\\Trade_Engineering", title = "WIZ_KEEP_SETTINGS", desc = "WIZ_KEEP_SETTINGS_DESC" },
	{ icon = "Interface\\Icons\\INV_Misc_Key_03", title = "WIZ_KEEP_KEYS", desc = "WIZ_KEEP_KEYS_DESC" },
	{ icon = "Interface\\Icons\\INV_Misc_Book_09", title = "WIZ_KEEP_BARS", desc = "WIZ_KEEP_BARS_DESC" },
	{ icon = "Interface\\Icons\\INV_Misc_Bag_08", title = "WIZ_KEEP_MODULES", desc = "WIZ_KEEP_MODULES_DESC" },
}

local function BuildIntro(p)
	local _, y = Head(p, ns.ICON, L.WIZ_INTRO_TITLE, L.WIZ_INTRO_SUB)
	local body, h = W.Text(p, W.FONT_BODY, CW, L.WIZ_INTRO_BODY)
	body:SetPoint("TOPLEFT", 0, -y)
	y = y + h + 14
	local SIZE = 30
	for _, k in ipairs(KEEPS) do
		local row = CreateFrame("Frame", nil, p)
		row:SetPoint("TOPLEFT", 0, -y)
		row:SetSize(CW, SIZE)
		local icon = ns.RoundIcon(row, SIZE)
		icon:SetPoint("TOPLEFT", 0, 0)
		icon:SetTexture(k.icon)
		local title = W.Text(row, W.FONT_BODY, CW - SIZE - 12, L[k.title])
		title:SetPoint("TOPLEFT", SIZE + 12, 0)
		local desc, dh = W.Text(row, W.FONT_SMALL, CW - SIZE - 12, L[k.desc], 0.8)
		desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
		y = y + math.max(SIZE, 16 + dh) + 8
	end
end

--------------------------------------------------------------------------------
-- Step 2: the presets (skipped while there are none)
--------------------------------------------------------------------------------

local function BuildPresets(p)
	local _, y = Head(p, ns.ICON, L.WIZ_PRESETS_TITLE, L.WIZ_PRESETS_SUB)
	page.presetCards = {}
	local CARD_H, SIZE = 56, 42
	for i, entry in ipairs(ns.PresetList()) do
		local c = CreateFrame("Button", nil, p)
		c:SetSize(CW, CARD_H)
		c:SetPoint("TOPLEFT", 0, -(y + (i - 1) * (CARD_H + 6)))
		ns.ui.Card(c)
		c:Look(0.07, 0.35, false)
		local pic = ns.RoundIcon(c, SIZE)
		pic:SetPoint("LEFT", 7, 0)
		pic:SetTexture(entry.icon or DEFAULT_ICON)
		local t = W.Text(c, W.FONT_HEADER, CW - SIZE - 26, entry.name)
		t:SetPoint("TOPLEFT", pic, "TOPRIGHT", 10, 0)
		Try(t.SetWordWrap, t, false)
		local d = W.Text(c, W.FONT_SMALL, CW - SIZE - 26, entry.desc or "", 0.8)
		d:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -3)
		Try(d.SetMaxLines, d, 2)
		c.entry = entry
		c:SetScript("OnClick", function()
			ApplyPreset(entry)
		end)
		W.TipScripts(c, entry.name, L.WIZ_PRESET_TIP)
		page.presetCards[i] = c
	end
end

local function HasPresets()
	return page.presetCards and #page.presetCards > 0
end

--------------------------------------------------------------------------------
-- Step 3: name, icon and the screen
--------------------------------------------------------------------------------

local BuildScreen -- below

local function BuildSetup(p)
	local r, g, bl = W.Ink()
	-- the icon, round: the game's icons to choose from
	local icon = CreateFrame("Button", nil, p)
	icon:SetSize(ICON, ICON)
	icon:SetPoint("TOPLEFT", 0, 0)
	icon.tex = ns.RoundIcon(icon, ICON)
	icon.tex:SetPoint("TOPLEFT")
	local ihl = icon:CreateTexture(nil, "HIGHLIGHT")
	ihl:SetAllPoints()
	ihl:SetColorTexture(1, 1, 1, 0.15)
	icon:SetScript("OnClick", function()
		ns.PickIcon(function(id)
			wf.icon = id
			ns.RefreshWizard()
		end, frame, page)
	end)
	W.TipScripts(icon, L.NP_ICON, L.NP_ICON_DESC)
	page.icon = icon

	-- the name: a headline you can write in
	local x = ICON + 14
	local name = CreateFrame("EditBox", nil, p)
	name:SetSize(CW - x, 32)
	name:SetPoint("TOPLEFT", x, 0)
	name:SetAutoFocus(false)
	Try(name.SetMaxLetters, name, NAME_MAX)
	name:SetFontObject(GameFontNormalHuge or GameFontNormalLarge)
	Try(name.SetFont, name, "Fonts\\FRIZQT__.TTF", 20, "")
	name:SetTextColor(r, g, bl)
	Try(name.SetShadowColor, name, 0, 0, 0, 0)
	name:SetTextInsets(8, 8, 0, 0)
	local bg = name:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(r, g, bl, 0.12)
	name:SetScript("OnEditFocusGained", function()
		bg:SetColorTexture(r, g, bl, 0.2)
	end)
	name:SetScript("OnEditFocusLost", function()
		bg:SetColorTexture(r, g, bl, 0.12)
	end)
	name:SetScript("OnEscapePressed", name.ClearFocus)
	name:SetScript("OnEnterPressed", name.ClearFocus)
	name.hint = W.Text(name, W.FONT_BODY, CW - x - 16, L.WIZ_NAME_HINT, 0.45)
	name.hint:SetPoint("LEFT", 8, 0)
	name:HookScript("OnTextChanged", function(self)
		self.hint:SetShown((self:GetText() or "") == "")
	end)
	W.TipScripts(name, L.NP_NAME, L.NP_NAME_DESC, true)
	page.name = name
	local under = W.Text(p, W.FONT_SMALL, CW - x, L.WIZ_NAME_NOTE, 0.8)
	under:SetPoint("TOPLEFT", x + 2, -40)

	BuildScreen(p, ICON + 14)
end

--------------------------------------------------------------------------------
-- Step 3, under the name: the screen
--------------------------------------------------------------------------------

local function Switch(key)
	local e = ElementOf(key)
	if not e or InCombatLockdown() then
		return
	end
	wf.ui[key] = not wf.ui[key]
	wf.touched = true
	-- the action bars: what the preview touched needs a reload to clear
	if e.bar then
		wf.barsTouched = true
	end
	SetElement(e, wf.ui[key])
	ns.RefreshWizard()
end

function BuildScreen(p, y)
	local sub, sh = W.Text(p, W.FONT_SMALL, CW, L.WIZ_SCREEN_SUB, 0.85)
	sub:SetPoint("TOPLEFT", 0, -(y + 6))
	y = y + 6 + sh
	y = Section(p, y, L.NP_BARS)
	page.bars = {}
	local sq = 32
	local gap = math.floor((CW - 8 * sq) / 7)
	for n = 1, 8 do
		local b = Toggle(p, sq, sq, tostring(n))
		b:SetPoint("TOPLEFT", (n - 1) * (sq + gap), -y)
		if n == 1 then
			W.TipScripts(b, L.UI_BAR_SHORT:format(1), L.BAR1_LOCKED)
		else
			b:SetScript("OnClick", function()
				Switch("bar" .. n)
			end)
			W.TipScripts(b, function()
				return ns.G("OPTION_SHOW_ACTION_BAR", L.UI_BAR):format(n)
			end, function()
				return wf and wf.ui["bar" .. n] and L.STATE_ON or L.STATE_OFF
			end)
		end
		page.bars[n] = b
	end
	y = y + sq + 4
	y = Section(p, y, L.NP_UI)
	page.elements = {}
	local colW, rowH, i = (CW - 6) / 2, 26, 0
	for _, e in ipairs(ns.UIElements()) do
		if not e.bar then
			local label = ns.UILabel(e)
			local b = Toggle(p, colW, rowH, label)
			b:SetPoint("TOPLEFT", (i % 2) * (colW + 6), -(y + math.floor(i / 2) * (rowH + 6)))
			i = i + 1
			b.element = e
			b:SetScript("OnClick", function()
				Switch(e.key)
			end)
			W.TipScripts(b, label, function()
				return wf and wf.ui[e.key] and L.STATE_ON or L.STATE_OFF
			end)
			page.elements[#page.elements + 1] = b
		end
	end
	y = y + math.ceil(i / 2) * (rowH + 6) + 10
	local note = W.Text(p, W.FONT_SMALL, CW, L.WIZ_SCREEN_NOTE, 0.8)
	note:SetPoint("TOPLEFT", 0, -y)
end

local function RefreshScreen()
	for n, b in ipairs(page.bars) do
		if n == 1 then
			b:SetOn(true, true)
		else
			b:SetOn(wf.ui["bar" .. n] and true or false)
		end
	end
	for _, b in ipairs(page.elements) do
		b:SetOn(wf.ui[b.element.key] and true or false)
	end
end

--------------------------------------------------------------------------------
-- Step 4: modules
--------------------------------------------------------------------------------

local function BuildModules(p)
	local _, y = Head(p, "Interface\\Icons\\INV_Misc_Bag_08", L.WIZ_MODULES_TITLE, L.WIZ_MODULES_SUB)
	local listW = CW - 22
	local scroll = CreateFrame("ScrollFrame", nil, p, ScrollTemplate())
	scroll:SetPoint("TOPLEFT", 0, -y)
	scroll:SetSize(listW, FRAME_H - TOP_BAR - PAD_TOP - y - FOOT_H - 40)
	if scroll.ScrollBar and scroll.ScrollBar.SetHideIfUnscrollable then
		scroll.ScrollBar:SetHideIfUnscrollable(true)
	end
	local list = CreateFrame("Frame", nil, scroll)
	list:SetSize(listW, 10)
	scroll:SetScrollChild(list)
	page.moduleList = list
	page.moduleRows = {}
	local ROW, PIC = 78, 44
	for _, m in ipairs(ns.KNOWN_MODULES) do
		if ns.AddonInstalled(m.addon) then
			local row = CreateFrame("Button", nil, list)
			row:SetSize(listW, ROW)
			ns.ui.Card(row)
			row.key = m.key
			row.pic = ns.RoundIcon(row, PIC)
			row.pic:SetPoint("TOPLEFT", 10, -10)
			row.pic:SetTexture(ns.ModuleIcon(m.addon))
			local textW = listW - 10 - PIC - 12 - 40
			-- the asterisk: switching a module on or off reloads the game
			row.title = W.Text(row, W.FONT_HEADER, textW, L[m.title] .. " *")
			row.title:SetPoint("TOPLEFT", row.pic, "TOPRIGHT", 12, -2)
			row.desc = W.Text(row, W.FONT_SMALL, textW, L[m.desc], 0.8)
			row.desc:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -4)
			Try(row.desc.SetMaxLines, row.desc, 3)
			row.on = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
			row.on:SetSize(26, 26)
			row.on:SetPoint("TOPRIGHT", -8, -8)
			W.TipScripts(row.on, L[m.title], L.WIZ_MODULE_SWITCH)
			row.on:SetScript("OnClick", function(self)
				ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
				wf.modules[m.key] = self:GetChecked() and true or false
				ns.RefreshWizard()
			end)
			row.arrow = W.Text(row, W.FONT_HEADER, nil, "+", 0.7)
			row.arrow:SetPoint("BOTTOMRIGHT", -14, 8)
			row:SetScript("OnClick", function()
				page.openModule = page.openModule ~= m.key and m.key or nil
				ns.RefreshWizard()
			end)
			W.TipScripts(row, L[m.title], L.WIZ_MODULE_OPEN)
			-- its options, built once (the profile's, not the game's)
			local panel = CreateFrame("Frame", nil, list)
			panel:SetWidth(listW)
			panel.refreshers = {}
			local items = ns.FormModuleItems and ns.FormModuleItems(m.key) or {}
			local h = 8
			if #items > 0 then
				h = ns.ui.RenderItems(panel, items, 8, listW - 20)
			else
				local fs, th = W.Text(panel, W.FONT_SMALL, listW - 20, L.MODULE_NO_PROFILE, 0.8)
				fs:SetPoint("TOPLEFT", 10, -8)
				h = 8 + th
			end
			panel:SetHeight(h + 8)
			panel:Hide()
			row.panel = panel
			page.moduleRows[#page.moduleRows + 1] = row
		end
	end
	if #page.moduleRows == 0 then
		local note = W.Text(list, W.FONT_SMALL, listW, L.NO_MODULES, 0.8)
		note:SetPoint("TOPLEFT")
	end
	page.openModule = page.moduleRows[1] and page.moduleRows[1].key
end

local function RefreshModules()
	local y = 0
	for _, row in ipairs(page.moduleRows) do
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", page.moduleList, "TOPLEFT", 0, -y)
		row.on:SetChecked(wf.modules[row.key] and true or false)
		local open = page.openModule == row.key
		row:Look(open and 0.16 or 0.07, open and 0.8 or 0.35, open)
		row.arrow:SetText(open and "-" or "+")
		y = y + row:GetHeight() + 4
		if open then
			row.panel:ClearAllPoints()
			row.panel:SetPoint("TOPLEFT", page.moduleList, "TOPLEFT", 0, -y)
			row.panel:Show()
			for _, refresh in ipairs(row.panel.refreshers) do
				refresh()
			end
			y = y + row.panel:GetHeight() + 4
		else
			row.panel:Hide()
		end
	end
	page.moduleList:SetHeight(math.max(y, 10))
end

-- a module switched differently from now: the game reloads to follow
local function ModulesChanged()
	for key, on in pairs(wf.modules) do
		if ns.ModuleOn(key) ~= on then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- The page and its bottom
--------------------------------------------------------------------------------

function ns.RefreshWizard()
	if not (frame and frame:IsShown() and wf) then
		return
	end
	local step = wf.step
	for i, p in ipairs(pages) do
		p:SetShown(i == step)
	end
	page.icon.tex:SetTexture(wf.icon or DEFAULT_ICON)
	if step == 3 then
		RefreshScreen()
	elseif step == 4 then
		RefreshModules()
	end
	local foot = page.foot
	-- no presets: their step isn't counted
	local has = HasPresets()
	foot.step:SetText(L.WIZ_STEP:format((not has and step > 2) and step - 1 or step, has and STEPS or STEPS - 1))
	foot.back:SetText(step == 1 and L.WIZ_SKIP or L.WIZ_BACK)
	foot.reload:SetShown(step == 4 and ModulesChanged())
	if step == 1 then
		foot.main:SetText(L.WIZ_CREATE)
	elseif step == 2 then
		foot.main:SetText(L.WIZ_CUSTOM)
	elseif step == STEPS then
		foot.main:SetText(L.SAVE_AND_APPLY)
	else
		foot.main:SetText(L.GUIDE_NEXT)
	end
end

function ns.ShowWizardStep(step)
	if not wf then
		return
	end
	local turning = step ~= wf.step
	wf.step = math.max(1, math.min(STEPS, step))
	-- the module options show and change the profile's while step 4 is open
	if wf.step == 4 then
		if ns.ModuleVars and not ns.moduleVars then
			ns.ModuleVars()
		end
		wf.moduleSettings = wf.moduleSettings or ns.ModuleSnapshot()
		ns.moduleDraft = wf
	else
		ns.moduleDraft = nil
	end
	if turning then
		ns.Sound("IG_ABILITY_PAGE_TURN", 836)
	end
	ns.RefreshWizard()
end

-- Skip: SetGo! itself; the guide only comes back from Welcome or New profile
local function Skip()
	ns.db.wizardSkipped = true
	leaving = true
	frame:Hide()
	leaving = false
	ns.Open()
end

local function Main()
	local step = wf.step
	if step == 3 and NameText() == "" then
		ns.Print(L.MSG_NAME_EMPTY)
		page.name:SetFocus()
		return
	end
	if step == 1 and not HasPresets() then
		ns.ShowWizardStep(3)
	elseif step < STEPS then
		ns.ShowWizardStep(step + 1)
	else
		SaveAndApply()
	end
end

local TryClose -- below

local function Back()
	if wf.step == 1 then
		if HasChanges() or wf.touched then
			TryClose()
			return
		end
		Skip()
	elseif wf.step == 3 and not HasPresets() then
		ns.ShowWizardStep(1)
	else
		ns.ShowWizardStep(wf.step - 1)
	end
end

local function CreateFoot(parent)
	local foot = CreateFrame("Frame", nil, parent)
	foot:SetPoint("BOTTOMLEFT", PAD, 0)
	foot:SetSize(CW, FOOT_H)
	foot:SetFrameLevel(parent:GetFrameLevel() + 20)
	foot.main = W.Button(foot, 150, L.GUIDE_NEXT, Main, 24)
	foot.main:SetPoint("BOTTOM", foot, "BOTTOM", 0, 17)
	foot.back = W.Button(foot, 90, L.WIZ_BACK, Back, 22)
	foot.back:SetPoint("BOTTOMLEFT", foot, "BOTTOMLEFT", 0, 18)
	local rule = ns.ui.Rule(foot, 0, FOOT_H - 48, CW)
	rule:SetAlpha(1)
	foot.step = W.Text(foot, W.FONT_SMALL, CW, "", 0.8)
	foot.step:SetJustifyH("CENTER")
	foot.step:SetPoint("BOTTOM", foot, "BOTTOM", 0, 52)
	-- shown when a choice marked * will reload the game
	foot.reload = W.Text(parent, W.FONT_SMALL, CW, L.RELOAD_LEGEND, 0.8)
	foot.reload:SetJustifyH("LEFT")
	foot.reload:SetPoint("BOTTOMLEFT", foot, "TOPLEFT", 0, 2)
	foot.reload:Hide()
	return foot
end

--------------------------------------------------------------------------------
-- The window
--------------------------------------------------------------------------------

-- Leaving: the screen goes back; after a change on it, the game reloads
-- (from Blizzard's popup) to clear what the preview touched
StaticPopupDialogs.SETGO_WIZARD_LEAVE = {
	text = "%s",
	button1 = L.WIZ_LEAVE,
	button2 = CANCEL or "Cancel",
	OnAccept = function()
		local reload = wf and wf.barsTouched
		PutBack()
		leaving = true
		frame:Hide()
		leaving = false
		if reload then
			ReloadUI()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
}

-- X or Esc: with something filled in, asked first
function TryClose()
	if not InCombatLockdown() and (HasChanges() or wf.touched) then
		StaticPopup_Show("SETGO_WIZARD_LEAVE", wf.barsTouched and L.WIZ_POPUP_LEAVE_RELOAD or L.WIZ_POPUP_LEAVE)
		return
	end
	leaving = true
	frame:Hide()
	leaving = false
end

local function EscapeBusy()
	for i = 1, 4 do
		local dialog = _G["StaticPopup" .. i]
		if dialog and dialog:IsShown() then
			return true
		end
	end
	local picker = _G.SetGoIconPicker
	return picker and picker:IsShown() or false
end

local resumeAfterCombat = false

local function CreateWindow()
	frame = CreateFrame("Frame", "SetGoWizard", UIParent, "ButtonFrameTemplate")
	frame:SetSize(FRAME_W, FRAME_H)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	Try(frame.SetTitle, frame, L.ADDON)
	Try(frame.SetPortraitToAsset, frame, ns.ICON)
	if type(frame.Inset) == "table" then
		frame.Inset:Hide()
	end
	Try(ButtonFrameTemplate_HideButtonBar, frame)

	-- one page of the book
	local book = CreateFrame("Frame", nil, frame)
	book:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -22)
	book:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)
	local top = book:CreateTexture(nil, "BACKGROUND", nil, 1)
	if not Atlas(top, "spellbook-background-evergreen-header") then
		top:SetColorTexture(0.18, 0.12, 0.07, 1)
	end
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")
	top:SetHeight(54)
	local bg = book:CreateTexture(nil, "BACKGROUND", nil, 1)
	if not Atlas(bg, "spellbook-background-evergreen-right") then
		bg:SetColorTexture(0.86, 0.79, 0.64, 1)
	end
	bg:SetPoint("TOPLEFT", 0, -TOP_BAR)
	bg:SetPoint("BOTTOMRIGHT")
	local crumb = book:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	crumb:SetPoint("LEFT", book, "TOPLEFT", 64, -26)
	crumb:SetText(L.WIZ_CRUMB)

	page = CreateFrame("Frame", nil, book)
	page:SetPoint("TOPLEFT", 0, -TOP_BAR)
	page:SetPoint("BOTTOMRIGHT")
	for i, build in ipairs({ BuildIntro, BuildPresets, BuildSetup, BuildModules }) do
		local p = CreateFrame("Frame", nil, page)
		p:SetPoint("TOPLEFT", PAD, -PAD_TOP)
		p:SetSize(CW, FRAME_H - TOP_BAR - PAD_TOP - FOOT_H - 22)
		p:Hide()
		pages[i] = p
		build(p)
	end
	page.foot = CreateFoot(page)

	frame:SetScript("OnShow", function()
		ns.Sound("IG_SPELLBOOK_OPEN", 829)
	end)
	frame:SetScript("OnHide", function()
		ns.Sound("IG_SPELLBOOK_CLOSE", 830)
		ns.moduleDraft = nil
		if resumeAfterCombat then
			return
		end
		-- closed any other way (logging out, another window): the screen
		-- goes back unless saved
		if not leaving then
			PutBack()
		end
		local picker = _G.SetGoIconPicker
		if picker and picker:IsShown() then
			picker:Hide()
		end
	end)
	-- Esc asks, like the X
	frame:EnableKeyboard(true)
	Try(frame.SetPropagateKeyboardInput, frame, true)
	frame:SetScript("OnKeyDown", function(self, key)
		if InCombatLockdown() then
			return
		end
		local mine = key == "ESCAPE" and not EscapeBusy()
		Try(self.SetPropagateKeyboardInput, self, not mine)
		if mine then
			TryClose()
		end
	end)
	local close = frame.CloseButton or _G.SetGoWizardCloseButton
	if close then
		close:SetScript("OnClick", TryClose)
	end
	frame:Hide()
end

-- Combat: it closes at once and comes back where it was
local combatWatch = CreateFrame("Frame")
combatWatch:RegisterEvent("PLAYER_REGEN_DISABLED")
combatWatch:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWatch:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_REGEN_DISABLED" then
		if frame and frame:IsShown() then
			StaticPopup_Hide("SETGO_WIZARD_LEAVE")
			resumeAfterCombat = true
			frame:Hide()
		end
	elseif resumeAfterCombat then
		frame:Show()
		resumeAfterCombat = false
		ns.ShowWizardStep(wf and wf.step or 1)
	end
end)

function ns.WizardShown()
	return frame ~= nil and frame:IsShown()
end

-- The guide, from its first step (already open: it stays where it is)
function ns.ShowWizard()
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return
	end
	if not frame then
		CreateWindow()
	end
	if frame:IsShown() then
		return
	end
	ns.HideKeep()
	Fresh()
	frame:Show()
	ns.ShowWizardStep(1)
end
