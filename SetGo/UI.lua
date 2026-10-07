local _, ns = ...
local L, W = ns.L, ns.Widgets
local Try = ns.Try

--------------------------------------------------------------------------------
-- The window: a book. Left page: three tabs (Profiles, Modules, SetGo!);
-- Profiles holds the player's profiles as cards, Modules a button per
-- module, SetGo! a list of pages. Right page: what is chosen (a profile's form is in
-- ProfileForm.lua).
--------------------------------------------------------------------------------

local FRAME_W, FRAME_H = 980, 640
local TOP_BAR = 51
local PAD = 46
local PAD_TOP = 30
local PAGE_W = (FRAME_W - 6) / 2
local CW = PAGE_W - PAD * 2 - 24 -- content width on the right page
local LW = PAGE_W - PAD * 2 -- content width on the left page

local frame, book, leftPage, rightPage
-- hiding it: keeping (combat, a Blizzard window: nothing asked, the place
-- kept) or leaving (the player chose in the unsaved changes popup)
local keeping, leaving, resumeAfterCombat = false, false, false

-- something not saved: the profile's form, or changes waiting
local function HasChanges()
	return (ns.FormHasChanges and ns.FormHasChanges()) or ns.CountStaged() > 0
end

-- Esc belongs to something else first: a popup, the icon picker
local function EscapeBusy()
	if StaticPopup_Visible and StaticPopup_Visible("SETGO_UNSAVED") then
		return true
	end
	for i = 1, 4 do
		local dialog = _G["StaticPopup" .. i]
		if dialog and dialog:IsShown() then
			return true
		end
	end
	local picker = _G.SetGoIconPicker
	return picker and picker:IsShown() or false
end

-- In combat SetGo! can't take Esc: the game's own list closes it then
local function EscapeInCombat(on)
	for i = #UISpecialFrames, 1, -1 do
		if UISpecialFrames[i] == "SetGoFrame" then
			table.remove(UISpecialFrames, i)
		end
	end
	if on then
		table.insert(UISpecialFrames, "SetGoFrame")
	end
end


local state = { index = 1, last = {} }
ns.state = state

-- what ProfileForm.lua shares (the frames once made)
local U = { PAD = PAD, PAD_TOP = PAD_TOP, PAGE_W = PAGE_W, state = state }
ns.ui = U

local UpdateChrome -- forward


--------------------------------------------------------------------------------
-- Popups (Blizzard's own StaticPopup dialogs)
--------------------------------------------------------------------------------

local function EditBoxOf(dialog)
	return dialog.editBox or dialog.EditBox or (dialog.GetEditBox and dialog:GetEditBox())
end

local function Popup(which, text, data)
	return StaticPopup_Show(which, text, nil, data)
end

StaticPopupDialogs.SETGO_CONFIRM = {
	text = "%s",
	button1 = YES or "Yes",
	button2 = NO or "No",
	OnAccept = function(_, data)
		if data and data.onAccept then
			data.onAccept()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
}

StaticPopupDialogs.SETGO_NAME = {
	text = "%s",
	button1 = ACCEPT or "Accept",
	button2 = CANCEL or "Cancel",
	hasEditBox = true,
	maxLetters = 40,
	OnShow = function(self, data)
		data = data or self.data
		local box = EditBoxOf(self)
		if box then
			box:SetText(data and data.default or "")
			box:HighlightText()
		end
	end,
	OnAccept = function(self, data)
		local name = strtrim(EditBoxOf(self):GetText() or "")
		if name ~= "" and data and data.onName then
			data.onName(name)
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local dialog = self:GetParent()
		local accept = dialog.button1 or (dialog.GetButton1 and dialog:GetButton1())
		if accept then
			accept:Click()
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

StaticPopupDialogs.SETGO_CONTINUE = {
	text = "%s",
	button1 = CONTINUE or "Continue",
	button2 = CANCEL or "Cancel",
	OnAccept = function(_, data)
		if data and data.onAccept then
			data.onAccept()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

local function Confirm(text, onAccept)
	Popup("SETGO_CONFIRM", text, { onAccept = onAccept })
end

-- The player closes it (X, Esc, the key binding): with something not
-- saved, asked first; the window stays until they choose
function ns.TryClose()
	if not (frame and frame:IsShown()) then
		return
	end
	if not InCombatLockdown() and HasChanges() then
		Popup("SETGO_UNSAVED", L.POPUP_UNSAVED)
		return
	end
	frame:Hide()
end

--------------------------------------------------------------------------------
-- Book art
--------------------------------------------------------------------------------

local function Atlas(tex, atlas, useSize)
	if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
		tex:SetAtlas(atlas, useSize and true or false)
		return true
	end
	return false
end

local function PageTurn()
	ns.Sound("IG_ABILITY_PAGE_TURN", 836)
end

local function CreateBook()
	book = CreateFrame("Frame", nil, frame)
	book:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -22)
	book:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)

	local top = book:CreateTexture(nil, "BACKGROUND", nil, 1)
	if not Atlas(top, "spellbook-background-evergreen-header") then
		top:SetColorTexture(0.18, 0.12, 0.07, 1)
	end
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")
	top:SetHeight(54)

	local left = book:CreateTexture(nil, "BACKGROUND", nil, 1)
	local right = book:CreateTexture(nil, "BACKGROUND", nil, 1)
	if not (Atlas(left, "spellbook-background-evergreen-left") and Atlas(right, "spellbook-background-evergreen-right")) then
		left:SetColorTexture(0.86, 0.79, 0.64, 1)
		right:SetColorTexture(0.86, 0.79, 0.64, 1)
	end
	left:SetPoint("TOPLEFT", 0, -TOP_BAR)
	left:SetPoint("BOTTOMRIGHT", book, "BOTTOM")
	right:SetPoint("TOPLEFT", book, "TOP", 0, -TOP_BAR)
	right:SetPoint("BOTTOMRIGHT")

	-- back to the first page, right side of the banner
	book.home = W.IconButton(book, 30, {
		normal = "gamepad-switch-128x-home-normal",
		hover = "gamepad-switch-128x-home-hover",
		pressed = "gamepad-switch-128x-home-pressed",
	}, L.HOME_SHORT, function()
		ns.GoHome()
	end)
	book.home:SetPoint("RIGHT", book, "TOPRIGHT", -20, -26)
	W.TipScripts(book.home, L.HOME, L.HOME_DESC)
	book.crumb = book:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	-- clear of the portrait in the window's corner
	book.crumb:SetPoint("LEFT", book, "TOPLEFT", 64, -26)

	leftPage = CreateFrame("Frame", nil, book)
	leftPage:SetPoint("TOPLEFT", 0, -TOP_BAR)
	leftPage:SetPoint("BOTTOMRIGHT", book, "BOTTOM")
	rightPage = CreateFrame("Frame", nil, book)
	rightPage:SetPoint("TOPLEFT", book, "TOP", 0, -TOP_BAR)
	rightPage:SetPoint("BOTTOMRIGHT")
	U.frame, U.leftPage, U.rightPage = frame, leftPage, rightPage
end

--------------------------------------------------------------------------------
-- Option rows
--------------------------------------------------------------------------------

local function Getter(setting)
	return function()
		return ns.Get(setting)
	end
end

local function Setter(setting)
	return function(value)
		ns.Set(setting, value)
		UpdateChrome()
	end
end

-- a global option among character ones: marked, it isn't kept in presets
local function Label(item)
	if item.account and item.name then
		return item.name .. "  |cff8c7a5b" .. L.GLOBAL_TAG .. "|r"
	end
	return item.name
end

local function RenderItems(pf, items, y, width)
	local CW = width or CW
	for _, item in ipairs(items) do
		local kind = item.kind
		if kind == "header" then
			y = W.Header(pf, y, CW, item.name)
		elseif kind == "title" then
			y = W.Title(pf, y, CW, item.name)
		elseif kind == "checkbox" then
			y = W.Checkbox(pf, y, CW, item.indent, Label(item), item.tooltip, Getter(item.setting), Setter(item.setting))
		elseif kind == "dropdown" then
			y = W.Dropdown(pf, y, CW, item.indent, Label(item), item.tooltip, item.options, Getter(item.setting), Setter(item.setting))
		elseif kind == "slider" then
			y = W.Slider(pf, y, CW, item.indent, Label(item), item.tooltip, item.options, Getter(item.setting), Setter(item.setting))
		elseif kind == "cbslider" or kind == "cbdropdown" then
			y = W.Checkbox(pf, y, CW, item.indent, Label(item), item.tooltip, Getter(item.setting), Setter(item.setting))
			local build = kind == "cbslider" and W.Slider or W.Dropdown
			y = build(pf, y, CW, true, item.secondName, item.secondTooltip, item.options, Getter(item.second), Setter(item.second))
		elseif kind == "blizzard" then
			y = y + 8
			local b = W.Button(pf, 260, item.name, function()
				if InCombatLockdown() then
					ns.Print(L.MSG_COMBAT)
					return
				end
				Popup("SETGO_CONTINUE", L.POPUP_BLIZZARD, {
					onAccept = function()
						ns.OpenBlizzardAndReturn(item.cat)
					end,
				})
			end, 26)
			b:SetPoint("TOPLEFT", pf, "TOPLEFT", 2, -y)
			W.TipScripts(b, item.name, item.tooltip)
			y = y + 26 + 10
		elseif kind == "note" then
			local fs, h = W.Text(pf, W.FONT_SMALL, CW - 26, item.name, 0.8)
			-- tucked under the row above; the first one on a page stays inside it
			fs:SetPoint("TOPLEFT", pf, "TOPLEFT", 26, -math.max(y - 6, 0))
			y = y + h + 6
		elseif kind == "button" then
			y = y + 4
			local b = W.Button(pf, 240, item.name, item.func, 24)
			b:SetPoint("TOPLEFT", pf, "TOPLEFT", 2, -y)
			W.TipScripts(b, item.name, item.tooltip)
			y = y + 24 + 6
		elseif kind == "keybind" then
			y = W.Keybind(pf, y, CW, item.indent, Label(item), item.tooltip, item.action)
		elseif kind == "custom" and type(item.build) == "function" then
			-- a module's own rows (Hide!): build(page, y, width) returns the new y
			local ok, newY = pcall(item.build, pf, y, CW)
			if ok and type(newY) == "number" then
				y = newY
			elseif not ok then
				-- shown by BugSack, not swallowed
				geterrorhandler()(newY)
			end
		end
	end
	return y
end

local function NewPage(width)
	local pf = CreateFrame("Frame", nil, rightPage.scroll)
	pf:SetWidth(width or CW)
	pf.refreshers = {}
	pf:Hide()
	return pf
end

local function LayoutOptions()
	local list = {}
	for _, l in ipairs((ns.GetLayouts())) do
		local label = l.preset and ns.G("HUD_EDIT_MODE_PRESET_LAYOUT", "%s"):format(l.name) or l.name
		list[#list + 1] = { value = l.index, label = label }
	end
	return list
end

local function BuildSettingsPage(page)
	local pf = NewPage(CW)
	local y = 0
	if page.layout then
		y = W.Header(pf, y, CW, L.SEC_EDITMODE)
		y = W.Dropdown(pf, y, CW, false, L.EDITMODE_LAYOUT, L.EDITMODE_LAYOUT_DESC, LayoutOptions, ns.GetLayout, function(index)
			ns.SetLayout(index)
			UpdateChrome()
		end)
		if page.items[1] and page.items[1].kind ~= "header" then
			y = W.Header(pf, y, CW, ns.CategoryLabel("actionbars"))
		end
	end
	y = RenderItems(pf, page.items, y, CW)
	pf:SetHeight(y + 10)
	return pf
end

--------------------------------------------------------------------------------
-- Left page: tabs, then the chosen tab's list (Profiles: cards)
--------------------------------------------------------------------------------

local TAB_H, ROW_H = 26, 22
local LIST_TOP = PAD_TOP + TAB_H + 16

-- what the Modules and SetGo! tabs list; group = the right page
local function Entries(tab)
	if tab == "modules" then
		local list = {}
		for i, page in ipairs(ns.BuildPath("modules")) do
			list[#list + 1] = { label = page.title, group = "modules", index = i }
		end
		return list
	end
	return { { label = L.SETGO_TITLE, group = "setgo" } }
end

-- the tab a group lives in
local TAB_OF = {
	newpreset = "presets", modules = "modules", setgo = "settings",
}

-- groups paged with the arrows (none now: the game's option pages are
-- Blizzard's own again)
local PAGED = {}

-- a text tab with a line under it when chosen
local function MakeTab(parent, label, width, onClick, font)
	local r, g, bl = W.Ink()
	local t = CreateFrame("Button", nil, parent)
	t:SetSize(width, TAB_H)
	t.text = W.Text(t, font or W.FONT_HEADER, nil, label)
	t.text:SetJustifyH("CENTER")
	t.text:SetPoint("CENTER", 0, 2)
	Try(t.text.SetWordWrap, t.text, false)
	t.line = t:CreateTexture(nil, "ARTWORK")
	t.line:SetHeight(2)
	t.line:SetPoint("BOTTOMLEFT", 6, 0)
	t.line:SetPoint("BOTTOMRIGHT", -6, 0)
	t.line:SetColorTexture(r, g, bl, 0.9)
	local hl = t:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	hl:SetColorTexture(r, g, bl, 0.08)
	t:SetScript("OnClick", onClick)
	function t:SetOn(on)
		self.text:SetAlpha(on and 1 or 0.6)
		self.line:SetShown(on)
	end
	function t:TextWidth()
		return (self.text:GetStringWidth() or 40) + 16
	end
	return t
end

-- tabs side by side over width, each as wide as its text, the room left
-- shared out
local function PlaceTabs(parent, tabs, x, y, width)
	local need = 0
	for _, t in ipairs(tabs) do
		need = need + t:TextWidth()
	end
	local extra = math.max(0, width - need) / #tabs
	local scale = need > width and width / need or 1
	for _, t in ipairs(tabs) do
		local w = t:TextWidth() * scale + extra
		t:SetWidth(w)
		t:ClearAllPoints()
		t:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
		x = x + w
	end
end

local function Rule(parent, x, y, width)
	local r, g, bl = W.Ink()
	local rule = parent:CreateTexture(nil, "ARTWORK")
	rule:SetHeight(1)
	rule:SetColorTexture(r, g, bl, 0.35)
	rule:SetPoint("TOPLEFT", x, -y)
	rule:SetPoint("TOPRIGHT", parent, "TOPLEFT", x + width, -y)
	return rule
end

local rows = {}

local function Row(i)
	if rows[i] then
		return rows[i]
	end
	local b = CreateFrame("Button", nil, leftPage.nav)
	b:SetSize(LW, ROW_H)
	b.text = W.Text(b, W.FONT_BODY, LW - 30, "")
	b.text:SetPoint("LEFT", 10, 0)
	local hl = b:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	local r, g, bl = W.Ink()
	hl:SetColorTexture(r, g, bl, 0.12)
	b.mark = b:CreateTexture(nil, "ARTWORK")
	b.mark:SetSize(3, 16)
	b.mark:SetPoint("LEFT", 2, 0)
	b.mark:SetColorTexture(r, g, bl, 0.9)
	rows[i] = b
	return b
end

--------------------------------------------------------------------------------
-- Profile cards: as many as fit on the page (ns.MAX_PROFILES), like Edit
-- Mode's layouts: the player's profiles in their order, + New profile on
-- the first free one, the rest empty. The one this character uses is
-- marked; the one open on the right page is highlighted.
--------------------------------------------------------------------------------

local OPTION_H, GAP = 68, 4
local SLOT_W = LW
local slots = { options = {} }

local function Stamp(stamp, withTime)
	return type(stamp) == "number" and date(withTime and "%d/%m/%Y %H:%M" or "%d/%m/%Y", stamp) or nil
end

local function SlotTip(b)
	if not b:IsEnabled() then
		return
	end
	GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
	local name = b.profile
	if not name then
		GameTooltip:SetText(L.NEW_PRESET, 1, 1, 1)
		GameTooltip:AddLine(L.NEW_PRESET_DESC, nil, nil, nil, true)
	else
		GameTooltip:SetText(name, 1, 1, 1)
		if b.active then
			GameTooltip:AddLine(L.SLOT_IN_USE, 0.4, 0.8, 0.4, true)
		end
		GameTooltip:AddLine(L.PRESET_OPEN_DESC, nil, nil, nil, true)
		GameTooltip:AddLine(L.SLOT_MENU_HINT, 0.6, 0.6, 0.6, true)
	end
	GameTooltip:Show()
end


-- a rectangle with a thin ink border, like a card on the page
local function Card(b, tint)
	local r, g, bl = W.Ink()
	if tint then
		r, g, bl = tint[1], tint[2], tint[3]
	end
	b.bg = b:CreateTexture(nil, "BACKGROUND")
	b.bg:SetAllPoints()
	b.edges = {}
	for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
		local e = b:CreateTexture(nil, "BORDER")
		e:SetColorTexture(r, g, bl, 1)
		if side == "TOP" or side == "BOTTOM" then
			e:SetHeight(1)
			e:SetPoint(side .. "LEFT")
			e:SetPoint(side .. "RIGHT")
		else
			e:SetWidth(1)
			e:SetPoint("TOP" .. side)
			e:SetPoint("BOTTOM" .. side)
		end
		b.edges[#b.edges + 1] = e
	end
	b.accent = b:CreateTexture(nil, "ARTWORK")
	b.accent:SetWidth(3)
	b.accent:SetPoint("TOPLEFT", 1, -1)
	b.accent:SetPoint("BOTTOMLEFT", 1, 1)
	b.accent:SetColorTexture(r, g, bl, 0.9)
	local hl = b:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	hl:SetColorTexture(r, g, bl, 0.06)
	function b:Look(bgAlpha, edgeAlpha, accent)
		self.bg:SetColorTexture(r, g, bl, bgAlpha)
		for _, e in ipairs(self.edges) do
			e:SetAlpha(edgeAlpha)
		end
		self.accent:SetShown(accent)
	end
end


-- a texture made round, with a gold ring (the profile's icon)
local function RoundIcon(parent, size)
	local tex = parent:CreateTexture(nil, "ARTWORK")
	tex:SetSize(size, size)
	if parent.CreateMaskTexture then
		local mask = parent:CreateMaskTexture()
		mask:SetAllPoints(tex)
		mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		tex:AddMaskTexture(mask)
	end
	local ring = parent:CreateTexture(nil, "OVERLAY")
	if Atlas(ring, "communities-ring-gold") then
		ring:SetPoint("CENTER", tex, "CENTER")
		ring:SetSize(size + 8, size + 8)
	end
	tex.ring = ring
	function tex:SetRoundShown(on)
		self:SetShown(on)
		self.ring:SetShown(on)
	end
	return tex
end
ns.RoundIcon = RoundIcon

local function SlotButton(parent)
	local b = CreateFrame("Button", nil, parent)
	b.kind = "options"
	b:SetSize(SLOT_W, OPTION_H)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	Card(b)
	-- a profile: its icon (round), the favourite star and the name on one
	-- line, the dates under them; the book's page arrows to order the list
	local size = OPTION_H - 10
	b.icon = RoundIcon(b, size)
	b.icon:SetPoint("LEFT", 8, 0)
	b.star = CreateFrame("Button", nil, b)
	b.star:SetSize(18, 18)
	b.star:SetPoint("TOPLEFT", b.icon, "TOPRIGHT", 10, -8)
	b.star.tex = b.star:CreateTexture(nil, "ARTWORK")
	b.star.tex:SetAllPoints()
	b.star:SetScript("OnClick", function()
		if b.profile then
			local p = ns.db.profiles[b.profile]
			ns.SetFavorite(b.profile, not (p and p.favorite))
			ns.Refresh()
		end
	end)
	W.TipScripts(b.star, L.FAVORITE, L.FAVORITE_DESC)
	local textW = SLOT_W - size - 70
	b.name = W.Text(b, W.FONT_HEADER, textW - 24, "")
	b.name:SetPoint("LEFT", b.star, "RIGHT", 4, 0)
	Try(b.name.SetWordWrap, b.name, false)
	b.dates = W.Text(b, W.FONT_SMALL, textW, "", 0.75)
	b.dates:SetPoint("TOPLEFT", b.star, "BOTTOMLEFT", 0, -8)
	Try(b.dates.SetWordWrap, b.dates, false)
	b.new = W.Text(b, W.FONT_HEADER, SLOT_W - 20, "", 0.6)
	b.new:SetJustifyH("CENTER")
	b.new:SetPoint("CENTER")
	-- the spellbook's page arrows, turned to point up and down
	local function Arrow(dir, delta)
		local a = W.PageArrow(b, dir, function()
			if b.profile and ns.MoveProfile(b.profile, delta) then
				ns.Refresh()
			end
		end)
		for _, get in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetDisabledTexture", "GetHighlightTexture" }) do
			local t = a[get] and a[get](a)
			if t and t.SetRotation then
				t:SetRotation(-math.pi / 2)
			end
		end
		return a
	end
	b.up = Arrow("Prev", -1)
	b.up:SetPoint("TOPRIGHT", -4, -2)
	b.down = Arrow("Next", 1)
	b.down:SetPoint("BOTTOMRIGHT", -4, 2)

	b:SetScript("OnClick", function(self, button)
		GameTooltip:Hide()
		if button == "RightButton" then
			ns.SlotMenu(self)
		else
			ns.SlotClick(self.kind, self.profile)
		end
	end)
	b:SetScript("OnEnter", SlotTip)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return b
end

-- the card at position i (made when first needed)
local function Slot(i)
	local b = slots.options[i]
	if not b then
		local parent = leftPage.nav.optionsList
		b = SlotButton(parent)
		b.index = i
		b:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((i - 1) * (OPTION_H + GAP)))
		slots.options[i] = b
	end
	return b
end

local function FillSlots()
	local names = ns.ProfileSlots()
	local store = ns.db.profiles
	local active = ns.ActivePreset()
	-- the one open on the right page
	local chosen = ns.creating and ns.creating.edit or nil
	local full = #names >= ns.MAX_PROFILES
	for i = 1, math.max(#names, ns.MAX_PROFILES) do
		local b = Slot(i)
		local name = names[i]
		b.profile = name
		b.active = name ~= nil and name == active
		if name then
			local p = type(store[name]) == "table" and store[name] or {}
			b.name:SetText(name)
			local created, saved = Stamp(p.created), Stamp(p.saved, true)
			if created and saved then
				b.dates:SetText(L.SLOT_DATES:format(created, saved))
			else
				b.dates:SetText(created or saved or "")
			end
			b.name:Show()
			b.dates:Show()
			b.new:Hide()
			b.icon:SetTexture(p.icon or 134400)
			b.icon:SetRoundShown(true)
			-- the star in blue: the yellow one is hard to see on the page
			if not Atlas(b.star.tex, "auctionhouse-icon-favorite") then
				b.star.tex:SetTexture("Interface\\Common\\ReputationStar")
				b.star.tex:SetTexCoord(0, 0.5, 0, 0.5)
			end
			Try(b.star.tex.SetDesaturated, b.star.tex, true)
			if p.favorite then
				b.star.tex:SetVertexColor(0.3, 0.6, 1)
				b.star.tex:SetAlpha(1)
			else
				b.star.tex:SetVertexColor(0.45, 0.4, 0.35)
				b.star.tex:SetAlpha(0.45)
			end
			b.star:Show()
			b.up:Show()
			b.down:Show()
			b.up:SetEnabled(i > 1)
			b.down:SetEnabled(i < #names)
			b:Look(name == chosen and 0.16 or 0.07, name == chosen and 0.8 or 0.35, b.active)
			b:SetEnabled(true)
			b:Show()
		elseif i == #names + 1 and not full then
			-- the first free card makes a new one; the rest stay hidden
			local making = ns.creating ~= nil and not ns.creating.edit
			b.name:Hide()
			b.dates:Hide()
			b.icon:SetRoundShown(false)
			b.star:Hide()
			b.up:Hide()
			b.down:Hide()
			b.new:SetText("+  " .. L.NEW_PRESET)
			b.new:Show()
			b:Look(making and 0.16 or 0.03, making and 0.8 or 0.2, false)
			b:SetEnabled(true)
			b:Show()
		else
			-- an empty slot
			b.name:Hide()
			b.dates:Hide()
			b.icon:SetRoundShown(false)
			b.star:Hide()
			b.up:Hide()
			b.down:Hide()
			b.new:Hide()
			b:Look(0.01, 0.12, false)
			-- a free slot: a new profile, or right click to import one
			b:SetEnabled(true)
			b:Show()
		end
	end
end

local function RefreshList()
	local nav = leftPage.nav
	for tab, t in pairs(nav.tabs) do
		t:SetOn(tab == state.tab)
	end
	local presets = state.tab == "presets"
	local modules = state.tab == "modules"
	nav.presetsBox:SetShown(presets)
	nav.modulesBox:SetShown(modules)
	if presets then
		FillSlots()
	elseif modules then
		ns.RefreshModuleButtons()
	end
	local n = 0
	if not (presets or modules) then
		local y = LIST_TOP
		for _, entry in ipairs(Entries(state.tab)) do
			local open = entry.group == state.group and (not entry.index or entry.index == state.index)
			n = n + 1
			local b = Row(n)
			b:ClearAllPoints()
			b:SetPoint("TOPLEFT", nav, "TOPLEFT", PAD, -y)
			b.text:SetText(entry.label)
			b.text:SetAlpha(open and 1 or 0.7)
			b.mark:SetShown(open)
			b:SetScript("OnClick", function()
				ns.Select(entry.group, entry.index)
			end)
			b:Show()
			y = y + ROW_H + 2
		end
	end
	for i = n + 1, #rows do
		rows[i]:Hide()
	end
end

local function CreateNav()
	local nav = CreateFrame("Frame", nil, leftPage)
	nav:SetAllPoints()
	nav.refreshers = {}
	leftPage.nav = nav

	nav.tabs = {}
	local list = {}
	for _, tab in ipairs(ns.TABS) do
		local t = MakeTab(nav, L["TAB_" .. tab:upper()], 60, function()
			ns.SelectTab(tab)
		end)
		nav.tabs[tab] = t
		list[#list + 1] = t
	end
	PlaceTabs(nav, list, PAD, PAD_TOP, LW)
	Rule(nav, PAD, PAD_TOP + TAB_H + 1, LW)

	local box = CreateFrame("Frame", nil, nav)
	box:SetPoint("TOPLEFT", PAD, -LIST_TOP)
	box:SetSize(LW, 470)
	nav.presetsBox = box
	local y = W.Header(box, 0, LW, L.YOUR_PRESETS)
	local cards = CreateFrame("Frame", nil, box)
	cards:SetPoint("TOPLEFT", 0, -y)
	cards:SetSize(SLOT_W, ns.MAX_PROFILES * (OPTION_H + GAP))
	nav.optionsList = cards

	-- Modules: a big button per module (its picture, name and a few words),
	-- with its switch on the right; the button opens its options
	-- in a list that scrolls (mouse wheel or the bar) when they don't fit
	local scrollTemplate = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("ScrollFrameTemplate")
		and "ScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
	local mbox = CreateFrame("Frame", nil, nav)
	mbox:SetPoint("TOPLEFT", PAD, -LIST_TOP)
	mbox:SetSize(LW, 468)
	nav.modulesBox = mbox
	local BW = LW - 22 -- room for the scroll bar
	local mscroll = CreateFrame("ScrollFrame", nil, mbox, scrollTemplate)
	mscroll:SetPoint("TOPLEFT")
	mscroll:SetSize(BW, 468)
	if mscroll.ScrollBar and mscroll.ScrollBar.SetHideIfUnscrollable then
		mscroll.ScrollBar:SetHideIfUnscrollable(true)
	end
	local mlist = CreateFrame("Frame", nil, mscroll)
	mlist:SetSize(BW, 10)
	mscroll:SetScrollChild(mlist)
	nav.moduleButtons = {}
	local MOD_H, PIC = 112, 72
	local y = 0
	for _, m in ipairs(ns.KNOWN_MODULES) do
		if ns.AddonInstalled(m.addon) then
			local b = CreateFrame("Button", nil, mlist)
			b:SetSize(BW, MOD_H)
			b:SetPoint("TOPLEFT", 0, -y)
			Card(b)
			b.key = m.key
			-- its icon (the one its .toc gives the addon list), round
			b.pic = RoundIcon(b, PIC)
			b.pic:SetPoint("LEFT", 16, 0)
			b.pic:SetTexture(ns.ModuleIcon(m.addon))
			-- clear of the switch on the right
			local textW = BW - 16 - PIC - 12 - 48
			b.title = W.Text(b, W.FONT_HEADER, textW, L[m.title])
			b.title:SetPoint("TOPLEFT", b.pic, "TOPRIGHT", 12, -6)
			b.desc = W.Text(b, W.FONT_SMALL, textW, L[m.desc], 0.8)
			b.desc:SetPoint("TOPLEFT", b.title, "BOTTOMLEFT", 0, -6)
			Try(b.desc.SetMaxLines, b.desc, 4)
			b.on = CreateFrame("CheckButton", nil, b, "UICheckButtonTemplate")
			b.on:SetSize(26, 26)
			b.on:SetPoint("RIGHT", -10, 0)
			W.TipScripts(b.on, L[m.title], L.MODULE_SWITCH_DESC)
			b.on:SetScript("OnClick", function(self)
				ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
				ns.SetModuleOn(m.key, self:GetChecked() and true or false)
				ns.OnModuleToggled()
				ns.Refresh()
			end)
			b:SetScript("OnClick", function()
				for i, page in ipairs(ns.BuildPath("modules")) do
					if page.key == "module_" .. m.key then
						ns.Select("modules", i)
						return
					end
				end
			end)
			nav.moduleButtons[#nav.moduleButtons + 1] = b
			y = y + MOD_H + 8
		end
	end
	mlist:SetHeight(math.max(y - 8, 10))
	if #nav.moduleButtons == 0 then
		local note = W.Text(mbox, W.FONT_BODY, LW, L.NO_MODULES, 0.8)
		note:SetPoint("TOPLEFT")
	end
end

-- the module buttons: on or off, and the one open on the right page
function ns.RefreshModuleButtons()
	local nav = leftPage and leftPage.nav
	if not nav then
		return
	end
	local page = state.group == "modules" and state.pages and state.pages[state.index]
	for _, b in ipairs(nav.moduleButtons) do
		b.on:SetChecked(ns.ModuleOn(b.key))
		local open = page and page.key == "module_" .. b.key
		b:Look(open and 0.16 or 0.06, open and 0.8 or 0.35, open)
	end
end


--------------------------------------------------------------------------------
-- Right page: title (with the page arrows and Defaults on its line),
-- scrolling options, and at the bottom the buttons: Apply (changes
-- waiting, on the game; only when there are some) and Save to active
-- profile (the Modules tab).
--------------------------------------------------------------------------------

-- a square button in the style of Apply, with an icon on it (the first of
-- the atlases the client has; else the text)
local function IconBox(parent, atlases, text, onClick)
	local b = W.Button(parent, 28, "", onClick, 26)
	local icon = b:CreateTexture(nil, "OVERLAY")
	icon:SetSize(18, 18)
	icon:SetPoint("CENTER")
	local found = false
	for _, atlas in ipairs(atlases) do
		if not found and Atlas(icon, atlas) then
			found = true
		end
	end
	if not found then
		b:SetText(text)
		icon:Hide()
	end
	b.icon = icon
	hooksecurefunc(b, "SetEnabled", function(self, on)
		icon:SetDesaturated(not on)
		icon:SetAlpha(on and 1 or 0.5)
	end)
	return b
end
U.IconBox = IconBox

local function CreatePages()
	local rp = CreateFrame("Frame", nil, rightPage)
	rp:SetAllPoints()
	rightPage.pages = rp
	local width = PAGE_W - PAD * 2

	rp.title = W.Text(rp, W.FONT_TITLE, width - 140, "")
	-- a module's page (and SetGo!'s): its icon, round, its name and what it
	-- does, like a profile's header
	local HEAD_ICON = 64
	rp.head = CreateFrame("Frame", nil, rp)
	rp.head:SetSize(width, HEAD_ICON)
	rp.head.icon = RoundIcon(rp.head, HEAD_ICON)
	rp.head.icon:SetPoint("TOPLEFT", 0, 0)
	rp.head.name = W.Text(rp.head, W.FONT_TITLE, width - HEAD_ICON - 14 - 34, "")
	rp.head.name:SetPoint("TOPLEFT", HEAD_ICON + 14, -2)
	Try(rp.head.name.SetWordWrap, rp.head.name, false)
	rp.head.desc = W.Text(rp.head, W.FONT_SMALL, width - HEAD_ICON - 14, "", 0.85)
	rp.head.desc:SetPoint("TOPLEFT", rp.head.name, "BOTTOMLEFT", 0, -6)
	Try(rp.head.desc.SetMaxLines, rp.head.desc, 3)
	rp.head:Hide()
	Try(rp.title.SetWordWrap, rp.title, false)
	-- over the title of the option pages: a list of the pages
	rp.jump = CreateFrame("Button", nil, rp)
	rp.jump:SetAllPoints(rp.title)
	rp.jump:SetScript("OnClick", function(self)
		if not (MenuUtil and MenuUtil.CreateContextMenu and state.pages) then
			return
		end
		MenuUtil.CreateContextMenu(self, function(_, root)
			for i, page in ipairs(state.pages) do
				root:CreateRadio(page.title, function()
					return i == state.index
				end, function()
					ns.ShowIndex(i)
				end)
			end
		end)
	end)
	W.TipScripts(rp.jump, L.CONTENTS, L.CONTENTS_DESC)
	rp.divider = rp:CreateTexture(nil, "ARTWORK")
	if not Atlas(rp.divider, "spellbook-divider") then
		rp.divider:SetColorTexture(0, 0, 0, 0)
	end
	rp.divider:SetHeight(12)

	local template = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("ScrollFrameTemplate")
		and "ScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
	local scroll = CreateFrame("ScrollFrame", nil, rp, template)
	rightPage.scroll = scroll
	-- Blizzard's own switch: the bar only shows when the page is longer
	if scroll.ScrollBar and scroll.ScrollBar.SetHideIfUnscrollable then
		scroll.ScrollBar:SetHideIfUnscrollable(true)
	end

	rp.defaults = W.IconButton(rp, 24, { normal = "common-icon-undo" }, L.DEFAULTS_BUTTON, function(self)
		ns.DefaultsMenu(self)
	end)
	W.TipScripts(rp.defaults, L.DEFAULTS_BUTTON, L.DEFAULTS_BUTTON_DESC)
	rp.prev = W.PageArrow(rp, "Prev", function()
		ns.ShowIndex(state.index - 1)
	end)
	rp.next = W.PageArrow(rp, "Next", function()
		ns.ShowIndex(state.index + 1)
	end)
	-- at the bottom: Apply and Save to active profile, the changes waiting
	-- over them, Discard on the right
	rp.main = W.Button(rp, 140, L.APPLY, function()
		ns.ApplyAndSave()
	end, 24)
	W.TipScripts(rp.main, L.APPLY, L.APPLY_NOTE)
	rp.save = IconBox(rp, { "decor-controls-save-default", "common-icon-checkmark" }, "S", function()
		ns.SaveToActiveProfile()
	end)
	W.TipScripts(rp.save, L.SAVE_TO_PROFILE, function()
		local name = ns.ActivePreset()
		if not name then
			return L.SAVE_TO_PROFILE_NONE
		end
		return L.SAVE_MODULES_DESC:format(name)
	end)
	rp.pending = W.Text(rp, W.FONT_SMALL, width, "", 0.8)
	rp.pending:SetJustifyH("CENTER")
	rp.pending:SetPoint("BOTTOM", rp, "BOTTOM", 0, 48)
	rp.discard = IconBox(rp, { "common-icon-undo" }, "X", function()
		local n = ns.CountStaged()
		if n > 0 then
			Confirm(L.POPUP_DISCARD:format(n), function()
				ns.ClearStaged()
				ns.Refresh()
			end)
		end
	end)
	rp.discard:SetPoint("BOTTOMRIGHT", rp, "BOTTOMRIGHT", -PAD, 17)
	W.TipScripts(rp.discard, L.DISCARD, L.DISCARD_DESC)
	-- mode: nil (a plain page) or "paged" (the page arrows)
	-- head: { icon, name, desc } shows the header in place of the title
	function rp:Place(mode, head)
		local left, top, right, bottom = PAD, PAD_TOP, PAD, 76
		self.title:ClearAllPoints()
		self.title:SetPoint("TOPLEFT", left, -top)
		self.title:SetShown(not head)
		self.head:ClearAllPoints()
		self.head:SetPoint("TOPLEFT", left, -top)
		self.head:SetShown(head and true or false)
		local line = top + 30
		if head then
			self.head.icon:SetTexture(head.icon)
			self.head.name:SetText(head.name or "")
			self.head.desc:SetText(head.desc or "")
			line = top + math.max(HEAD_ICON, 30 + (self.head.desc:GetStringHeight() or 0)) + 8
		end
		self.divider:ClearAllPoints()
		self.divider:SetPoint("TOPLEFT", left - 6, -line)
		self.divider:SetPoint("TOPRIGHT", -(right - 6), -line)
		scroll:ClearAllPoints()
		scroll:SetPoint("TOPLEFT", left, -(line + 16))
		-- in the box, the arrows go under the pages, on the right
		scroll:SetPoint("BOTTOMRIGHT", -(right + 14), bottom)
		self.defaults:ClearAllPoints()
		self.defaults:SetPoint("TOPRIGHT", self, "TOPRIGHT", -right, -(top + 2))
		self.jump:SetShown(mode ~= nil)
		self.prev:ClearAllPoints()
		self.next:ClearAllPoints()
		self.next:SetPoint("RIGHT", self.defaults, "LEFT", -4, 0)
		self.prev:SetPoint("RIGHT", self.next, "LEFT", 2, 0)
	end
	rp:Place(nil)
end


-- shared with ProfileForm.lua
U.Card, U.Popup, U.Confirm, U.EditBoxOf, U.Atlas = Card, Popup, Confirm, EditBoxOf, Atlas
U.MakeTab, U.PlaceTabs, U.Rule = MakeTab, PlaceTabs, Rule
U.RenderItems = RenderItems


--------------------------------------------------------------------------------
-- Blizzard windows: Quick Keybind mode, the key bindings menu, the Cooldown
-- Manager. SetGo! closes while they are open and comes back after, like the
-- nameplates menu. None of them opens in combat.
--------------------------------------------------------------------------------

local returnTo -- the Blizzard frame SetGo! waits on
local hooked = {}

local function ReturnAfter(blizzardFrame)
	if not blizzardFrame then
		return
	end
	if not hooked[blizzardFrame] then
		hooked[blizzardFrame] = true
		blizzardFrame:HookScript("OnHide", function(self)
			if returnTo == self then
				returnTo = nil
				C_Timer.After(0, function()
					ns.Resume()
				end)
			end
		end)
	end
	returnTo = blizzardFrame
	ns.HideKeep()
end

local function NotInCombat()
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return false
	end
	return true
end

function ns.OpenQuickKeybind()
	if not NotInCombat() or not QuickKeybindFrame then
		return
	end
	ReturnAfter(QuickKeybindFrame)
	QuickKeybindFrame:Show()
end

function ns.OpenEditMode()
	if not NotInCombat() or not EditModeManagerFrame then
		return
	end
	ReturnAfter(EditModeManagerFrame)
	ShowUIPanel(EditModeManagerFrame)
end

function ns.OpenKeybindings()
	if not NotInCombat() or not (Settings and Settings.OpenToCategory and Settings.KEYBINDINGS_CATEGORY_ID) then
		return
	end
	ReturnAfter(SettingsPanel)
	Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID)
end

function ns.OpenCooldownManager()
	if not NotInCombat() then
		return
	end
	if not CooldownViewerSettings and C_AddOns and C_AddOns.LoadAddOn then
		Try(C_AddOns.LoadAddOn, "Blizzard_CooldownViewer")
	end
	if not (CooldownViewerSettings and CooldownViewerSettings.TogglePanel) then
		ns.Print(L.MSG_NO_CDM)
		return
	end
	ReturnAfter(CooldownViewerSettings)
	CooldownViewerSettings:TogglePanel()
end

-- the nameplates menu (a "blizzard" row)
function ns.OpenBlizzardAndReturn(cat)
	if not NotInCombat() then
		return
	end
	ReturnAfter(SettingsPanel)
	ns.OpenBlizzardCategory(cat)
end

--------------------------------------------------------------------------------
-- Groups and pages
--------------------------------------------------------------------------------

-- pages of a group: the game's options, the modules, or ours
local function PagesOf(group)
	if group == "setgo" then
		return { { key = "setgo", title = L.SETGO_TITLE, items = ns.SetGoItems(), own = true } }
	end
	return ns.BuildPath(group)
end

-- the header of a module's page, or SetGo!'s
local function PageHead(page)
	if page.own then
		return { icon = ns.ICON, name = L.SETGO_TITLE, desc = L.SETGO_PAGE_DESC }
	end
	local key = type(page.key) == "string" and page.key:match("^module_(.+)$")
	for _, m in ipairs(key and ns.KNOWN_MODULES or {}) do
		if m.key == key then
			return { icon = ns.ModuleIcon(m.addon), name = L[m.title], desc = L[m.desc] }
		end
	end
end

local GROUP_NAMES = {
	modules = "MODULES", setgo = "SETGO_TITLE",
}

-- the right page's own frames, one per mode
local MODES = { "pages", "newpreset" }
local SPECIAL = { newpreset = true }

-- the profile form shows on the right page (any of its tabs)
local function OnForm()
	return state.group == "newpreset"
end
ns.OnForm = OnForm

local function Crumb()
	local group = state.group
	if OnForm() and ns.creating then
		return ns.creating.edit and L.CRUMB_PRESET:format(ns.creating.edit) or L.NEW_PRESET
	end
	return L[GROUP_NAMES[group]] or L.ADDON
end

-- The profile's own module options are what the module rows show and
-- change, while its Modules tab is open with Change modules ticked;
-- everywhere else they show the game.
local function SyncDraft()
	local f = ns.form
	local open = frame and frame:IsShown() and ns.creating and f
	ns.optionsDraft = nil
	if open and state.group == "newpreset" and f.tab == "modules" and f.customModules then
		if ns.ModuleVars and not ns.moduleVars then
			ns.ModuleVars()
		end
		ns.moduleDraft = f
	else
		ns.moduleDraft = nil
	end
end
ns.SyncDraft = SyncDraft

local pageFrames = {}

local function PageFrame(index)
	local page = state.pages[index]
	local key = state.group .. "/" .. page.key .. "/" .. (page.variant or "")
	if not pageFrames[key] then
		pageFrames[key] = BuildSettingsPage(page, state.group)
	end
	return pageFrames[key]
end

local function PageCount()
	return state.pages and #state.pages or 0
end

local function Refreshers(list)
	for _, refresh in ipairs(list or {}) do
		refresh()
	end
end

UpdateChrome = function()
	if not frame then
		return
	end
	local rp = rightPage.pages
	-- Changes waiting (a module page's Blizzard setting): Apply puts them on
	-- this character. The Modules tab: Save to active profile.
	local group = state.group
	local staging = state.mode == "pages" and ns.CountStaged() > 0
	local saving = group == "modules"
	rp.main:SetShown(staging)
	rp.save:SetShown(saving)
	rp.pending:SetShown(staging)
	rp.discard:SetShown(staging)
	-- Apply in the middle; on the right, Save (and Discard, when there's
	-- something to discard)
	rp.main:ClearAllPoints()
	rp.main:SetPoint("BOTTOM", rp, "BOTTOM", 0, 17)
	rp.save:ClearAllPoints()
	if staging then
		rp.save:SetPoint("RIGHT", rp.discard, "LEFT", -4, 0)
	else
		rp.save:SetPoint("BOTTOMRIGHT", rp, "BOTTOMRIGHT", -PAD, 17)
	end
	rp.save:SetEnabled(ns.ActivePreset() ~= nil)
	if not staging then
		return
	end
	local n = ns.CountStaged()
	rp.pending:SetText(n > 0 and L.PENDING:format(n) or L.NO_PENDING)
	rp.main:SetText(L.APPLY)
	rp.main:SetEnabled(n > 0)
	rp.discard:SetEnabled(n > 0)
end

function ns.Refresh()
	if not frame or not frame:IsShown() then
		return
	end
	SyncDraft()
	Refreshers(leftPage.nav.refreshers)
	RefreshList()
	if ns.RefreshFormHead then
		ns.RefreshFormHead(OnForm())
	end
	if state.mode == "pages" and state.current then
		Refreshers(state.current.refreshers)
	elseif state.mode == "newpreset" then
		ns.RefreshNewPreset()
	end
	book.crumb:SetText(Crumb())
	UpdateChrome()
end

local function ShowMode(mode, quiet)
	local turning = mode ~= state.mode
	state.mode = mode
	for _, m in ipairs(MODES) do
		rightPage[m]:SetShown(m == mode)
	end
	if mode ~= "pages" and state.current then
		state.current:Hide()
		state.current = nil
	end
	book.home:Hide()
	book.crumb:SetText(Crumb())
	if turning and not quiet then
		PageTurn()
	end
end

function ns.ShowIndex(index, quiet)
	index = math.max(1, math.min(PageCount(), index))
	local turning = index ~= state.index or not state.current
	state.index = index
	state.last[state.group] = index
	if state.current then
		state.current:Hide()
	end
	local page = state.pages[index]
	local pf = PageFrame(index)
	state.current = pf
	rightPage.scroll:SetScrollChild(pf)
	pf:Show()
	rightPage.scroll:SetVerticalScroll(0)
	SyncDraft()

	local rp = rightPage.pages
	local paged = PAGED[state.group]
	rp:Place(paged and "paged" or nil, PageHead(page))
	rp.title:SetText(page.title or "")
	local arrows = paged and PageCount() > 1
	rp.prev:SetShown(arrows)
	rp.next:SetShown(arrows)
	rp.prev:SetEnabled(index > 1)
	rp.next:SetEnabled(index < PageCount())
	-- our own pages apply at once and have no Blizzard defaults
	rp.defaults:SetShown(not page.own)
	if turning and not quiet then
		PageTurn()
	end
	ns.Refresh()
end

-- Show a group on the right page (index: which page). Staged changes stay
-- until applied or discarded.
function ns.Select(group, index, quiet)
	-- pages that are gone (the game's option pages, the search, Blizzard
	-- defaults): back to the profiles
	if not (group == "newpreset" or TAB_OF[group]) then
		ns.SelectTab("presets")
		return
	end
	if PAGED[group] and not ns.SettingsReady() then
		ns.Print(L.MSG_NOT_READY)
		return
	end
	local special = SPECIAL[group]
	local pages = not special and PagesOf(group)
	if pages and #pages == 0 then
		ns.Print(L.MSG_NOT_READY)
		return
	end
	if TAB_OF[group] then
		state.tab = TAB_OF[group]
	end
	local sameGroup = group == state.group
	state.group = group
	if special then
		state.pages = nil
		if group == "newpreset" and not ns.creating then
			ns.OpenForm(nil)
			return
		end
		SyncDraft()
		ShowMode(group, quiet)
		ns.Refresh()
		return
	end
	state.pages = pages
	-- each group opens on the page it was left on
	index = index or state.last[group] or 1
	ShowMode("pages", true)
	if not sameGroup then
		state.index = nil -- the page turns
	end
	ns.ShowIndex(index, quiet)
end

-- a tab: its list, with the first entry open (the right page follows).
-- Profiles: the form that is open, else the profile in use (or the first),
-- else a new one (the guide, when there is none yet).
function ns.SelectTab(tab)
	state.tab = tab
	if tab == "presets" then
		if ns.creating then
			ns.OpenForm(ns.creating.edit)
			return
		end
		ns.OpenForm(ns.ActivePreset() or ns.ProfileSlots()[1])
		return
	end
	local first = Entries(tab)[1]
	if first then
		ns.Select(first.group, first.index)
	else
		RefreshList()
	end
end

-- the first page of the book: the tab SetGo! opens on (Profiles unless the
-- player chose another)
function ns.GoHome(quiet)
	ns.SelectTab(ns.DefaultTab and ns.DefaultTab() or "presets")
end

--------------------------------------------------------------------------------
-- Profiles: open, rename, copy, export, delete
--------------------------------------------------------------------------------

local function AskName(text, onName)
	C_Timer.After(0, function()
		Popup("SETGO_NAME", text, { onName = onName })
	end)
end

-- a new name must be free
local function FreeName(store, name, retry)
	if store[name] then
		ns.Print(L.MSG_NAME_TAKEN:format(name))
		retry()
		return false
	end
	return true
end

-- a card: a profile's form (nil: a new one)
function ns.SlotClick(_, key)
	ns.LeaveForm(function()
		ns.OpenForm(key)
	end)
end

local function Rename(old)
	local function Ask()
		AskName(L.POPUP_RENAME:format(old), function(new)
			if new == old or not FreeName(ns.db.profiles, new, Ask) then
				return
			end
			ns.RenameProfile(old, new)
			if ns.creating and ns.creating.edit == old then
				ns.creating = nil
				ns.OpenForm(new)
			end
			ns.Refresh()
		end)
	end
	Ask()
end

local function Delete(name)
	local layout = ns.PresetLayoutToDelete(name)
	local text = layout and L.POPUP_DELETE_LAYOUT:format(name, layout) or L.POPUP_DELETE:format(name)
	Confirm(text, function()
		if layout then
			if InCombatLockdown() then
				ns.Print(L.MSG_COMBAT)
				return
			end
			ns.DeleteLayout(layout)
		end
		local open = ns.creating and ns.creating.edit == name
		if open then
			ns.creating = nil
		end
		ns.DeleteProfileAll(name)
		ns.Print(L.MSG_DELETED:format(name))
		if open then
			ns.SelectTab("presets")
		else
			ns.Refresh()
		end
	end)
end

function ns.SlotMenu(b)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	MenuUtil.CreateContextMenu(b, function(_, root)
		local name = b.profile
		if name then
			local p = ns.db.profiles[name]
			root:CreateTitle(name)
			root:CreateButton(L.PRESET_APPLY, function()
				ns.ConfirmApply(name)
			end)
			root:CreateCheckbox(L.FAVORITE, function()
				return p and p.favorite and true or false
			end, function()
				ns.SetFavorite(name, not (p and p.favorite))
				ns.Refresh()
			end)
			root:CreateDivider()
			root:CreateButton(L.RENAME, function()
				Rename(name)
			end)
			root:CreateButton(L.COPY, function()
				local copy = ns.CopyProfile(name)
				if copy then
					ns.Print(L.MSG_SAVED:format(copy))
					ns.LeaveForm(function()
						ns.OpenForm(copy)
					end)
				end
			end)
			root:CreateButton(L.EXPORT, function()
				ns.ExportProfileText(name)
			end)
			root:CreateButton(L.DELETE, function()
				Delete(name)
			end)
			root:CreateDivider()
		end
		local full = ns.ProfilesFull()
		local new = root:CreateButton(L.NEW_PRESET, function()
			ns.SlotClick("options", nil)
		end)
		local import = root:CreateButton(L.IMPORT_PROFILE, function()
			ns.AskImportProfile()
		end)
		if full then
			for _, b in ipairs({ new, import }) do
				if b and b.SetEnabled then
					b:SetEnabled(false)
				end
			end
		end
	end)
end

-- Apply: every change waiting, after asking: the
-- reload must come from Blizzard's own popup
function ns.ApplyAndSave()
	local n = ns.CountStaged()
	if n == 0 then
		ns.Print(L.NO_CHANGES)
		return
	end
	Confirm(L.POPUP_APPLY_GAME:format(n), function()
		if InCombatLockdown() then
			ns.Print(L.MSG_COMBAT)
			return
		end
		ns.FinishApply(ns.ApplyStaged())
	end)
end

-- Save to active profile (the Modules tab): which modules are on, and their
-- options
function ns.SaveToActiveProfile()
	local name = ns.ActivePreset()
	if not name then
		ns.Print(L.SAVE_TO_PROFILE_NONE)
		return
	end
	ns.SaveModulesToProfile(name)
	ns.Print(L.MSG_SAVED_MODULES:format(name))
	ns.Refresh()
end
ns.MainButton = ns.ApplyAndSave

-- a module was switched on or off
function ns.AskReload()
	Confirm(L.POPUP_RELOAD_MODULES, ReloadUI)
end

-- Defaults button: this page or every page. The values are only staged (or
-- go into the profile, on its Options tab); Apply makes them happen.
function ns.DefaultsMenu(owner)
	local page = state.pages and state.pages[state.index]
	local function ResetPage()
		ns.StageDefaults(page.items, false)
		ns.Refresh()
	end
	local function ResetAll()
		local items = {}
		for _, p in ipairs(state.pages or {}) do
			for _, item in ipairs(p.items) do
				items[#items + 1] = item
			end
		end
		ns.StageDefaults(items, false)
		ns.Refresh()
	end
	if MenuUtil and MenuUtil.CreateContextMenu then
		MenuUtil.CreateContextMenu(owner, function(_, root)
			if page then
				root:CreateButton(L.RESET_PAGE, ResetPage)
			end
			if PAGED[state.group] then
				root:CreateButton(L.RESET_ALL, ResetAll)
			end
		end)
	elseif page then
		ResetPage()
	end
end


--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

local function CreateWindow()
	frame = CreateFrame("Frame", "SetGoFrame", UIParent, "ButtonFrameTemplate")
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
	CreateBook()
	CreateNav()
	CreatePages()
	ns.CreateProfileForm()

	-- keys or Edit Mode layouts changed elsewhere: the preset's differences
	-- follow, while the book is open
	local WATCH = { "UPDATE_BINDINGS", "EDIT_MODE_LAYOUTS_UPDATED", "ACTIONBAR_SLOT_CHANGED", "CVAR_UPDATE" }
	frame:SetScript("OnShow", function(self)
		-- opened in combat: Esc closes it the game's way (SetGo! can't take
		-- the key then)
		EscapeInCombat(InCombatLockdown())
		ns.Sound("IG_SPELLBOOK_OPEN", 829)
		for _, event in ipairs(WATCH) do
			pcall(self.RegisterEvent, self, event)
		end
	end)
	frame:SetScript("OnHide", function(self)
		-- closed clean (nothing was left unsaved): it opens on its first page
		-- next time; in combat everything is kept as it is
		if not keeping and not leaving and not InCombatLockdown() then
			ns.LeaveForm()
		end
		EscapeInCombat(false)
		ns.Sound("IG_SPELLBOOK_CLOSE", 830)
		-- closed: the option pages show the game again for anything else
		ns.optionsDraft = nil
		for _, event in ipairs(WATCH) do
			pcall(self.UnregisterEvent, self, event)
		end
	end)
	-- Esc: SetGo! takes it (out of combat), to ask before closing; every
	-- other key goes on to the game
	frame:EnableKeyboard(true)
	Try(frame.SetPropagateKeyboardInput, frame, true)
	frame:SetScript("OnKeyDown", function(self, key)
		if InCombatLockdown() then
			return
		end
		local mine = key == "ESCAPE" and not EscapeBusy()
		Try(self.SetPropagateKeyboardInput, self, not mine)
		if mine then
			ns.TryClose()
		end
	end)
	-- the window's X asks too
	local close = frame.CloseButton or (frame.GetName and _G[(frame:GetName() or "") .. "CloseButton"])
	if close then
		close:SetScript("OnClick", function()
			ns.TryClose()
		end)
	end
	-- a preset's keys come in hundreds of bindings at once: one refresh
	-- after they settle
	local waiting = false
	frame:SetScript("OnEvent", function()
		if waiting then
			return
		end
		waiting = true
		C_Timer.After(0.2, function()
			waiting = false
			ns.Refresh()
		end)
	end)
	frame:Hide()
end

-- The book always opens on its first page (the tab SetGo! opens on; on
-- Profiles, the profile in use). Already open: it stays where it is.
function ns.Open()
	if not frame then
		CreateWindow()
	end
	if frame:IsShown() then
		return
	end
	resumeAfterCombat = false
	keeping = true
	frame:Show()
	keeping = false
	ns.LeaveForm()
	ns.GoHome(true)
end

-- Back where it was (after combat, or a Blizzard window it waited on)
function ns.Resume()
	if not frame or frame:IsShown() then
		return
	end
	keeping = true
	frame:Show()
	keeping = false
	if ns.OnForm() and ns.creating then
		ns.ShowFormTab(ns.form.tab or "layout")
	elseif state.group and state.group ~= "newpreset" then
		ns.Select(state.group, state.index, true)
	else
		ns.GoHome(true)
	end
end

-- Closes it keeping everything as it is (combat, a Blizzard window)
function ns.HideKeep()
	if frame and frame:IsShown() then
		keeping = true
		frame:Hide()
		keeping = false
	end
end

-- Closes it after the player chose (the unsaved changes popup)
local function Leave()
	leaving = true
	frame:Hide()
	leaving = false
	ns.LeaveForm()
end

StaticPopupDialogs.SETGO_UNSAVED = {
	text = "%s",
	button1 = L.SAVE_AND_EXIT,
	button2 = CANCEL or "Cancel",
	button3 = L.EXIT_NO_SAVE,
	selectCallbackByIndex = true,
	-- Apply and exit: the profile saved and applied (the interface reloads
	-- when it needs to); changes waiting applied too
	OnAccept = function()
		if ns.FormHasChanges() and not ns.FormSaveAndApply() then
			return
		end
		local staged = ns.CountStaged() > 0
		Leave()
		if staged and not InCombatLockdown() then
			ns.FinishApply(ns.ApplyStaged())
		end
	end,
	OnCancel = function() end,
	-- Exit without saving: everything not saved goes
	OnButton3 = function()
		ns.ClearStaged()
		Leave()
	end,
	OnAlt = function()
		ns.ClearStaged()
		Leave()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- Combat: the book closes at once (nothing asked) and comes back where it
-- was when combat ends
local combatWatch = CreateFrame("Frame")
combatWatch:RegisterEvent("PLAYER_REGEN_DISABLED")
combatWatch:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWatch:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_REGEN_DISABLED" then
		if frame and frame:IsShown() then
			if StaticPopup_Hide then
				StaticPopup_Hide("SETGO_UNSAVED")
			end
			resumeAfterCombat = true
			ns.HideKeep()
		end
	elseif resumeAfterCombat then
		resumeAfterCombat = false
		ns.Resume()
	end
end)

function ns.Toggle()
	if frame and frame:IsShown() then
		ns.TryClose()
	else
		ns.Open()
	end
end

-- the key binding (Bindings.xml)
function SetGo_Toggle()
	ns.Toggle()
end