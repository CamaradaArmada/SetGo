local _, ns = ...
local L, W = ns.L, ns.Widgets
local Try = ns.Try

--------------------------------------------------------------------------------
-- The window: Blizzard's portrait frame, as its collections. On the left a
-- narrow column: the player's profiles as cards, + New (a menu: Blizzard's
-- layouts, SetGo!'s presets, a copy, an import, an empty one), and the
-- backup at the bottom. On the right, what is chosen: a profile (its form is
-- in ProfileForm.lua: Layout, Addons, Interface Tweaks), or a page the gear
-- opens (SetGo!'s, a module's, the backups).
--------------------------------------------------------------------------------

local COL_W = 200 -- the profiles' column
local PAGE_W = 538 -- the right panel
local PANEL_H = 564
local PANELS_TOP = 60 -- under the portrait, as Blizzard's insets
local FRAME_W = 8 + COL_W + 6 + PAGE_W + 8
local FRAME_H = PANELS_TOP + PANEL_H + 8
local PAD = 14
local PAD_TOP = 10
local CW = PAGE_W - PAD * 2 - 24 -- content width on the right panel
local LW = COL_W - 12 -- content width in the column

local frame, book, leftPage, rightPage
-- hiding it: keeping (combat, a Blizzard window: nothing asked, the place
-- kept) or leaving (the player chose in the unsaved changes popup)
local keeping, leaving, resumeAfterCombat = false, false, false

-- something not saved: the profile's form, or changes waiting
local function HasChanges()
	return (ns.FormHasChanges and ns.FormHasChanges()) or ns.CountStaged() > 0
end

-- Esc belongs to something else first: a popup
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
	return false
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

-- a dark inset, as Blizzard's panels (its template where the client has it)
local function Inset(parent)
	local template = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("InsetFrameTemplate")
		and "InsetFrameTemplate" or nil
	local f = CreateFrame("Frame", nil, parent, template)
	if not template then
		local bg = f:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.05, 0.04, 0.03, 0.9)
	end
	return f
end

local function CreateBook()
	book = CreateFrame("Frame", nil, frame)
	book:SetAllPoints()

	-- what is open, in the band next to the portrait
	book.crumb = book:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	book.crumb:SetPoint("LEFT", book, "TOPLEFT", 70, -40)
	-- the old Home button, kept for the code that hides it
	book.home = CreateFrame("Frame", nil, book)
	book.home:Hide()

	-- the gear: SetGo!'s page, the modules' pages, the backups
	book.gear = CreateFrame("Button", nil, book)
	book.gear:SetSize(26, 26)
	book.gear:SetPoint("RIGHT", book, "TOPRIGHT", -14, -40)
	book.gear.icon = book.gear:CreateTexture(nil, "ARTWORK")
	book.gear.icon:SetAllPoints()
	book.gear.icon:SetTexture(ns.ICON)
	book.gear.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	book.gear:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	book.gear:SetScript("OnClick", function(self)
		ns.GearMenu(self)
	end)
	W.TipScripts(book.gear, L.GEAR, L.GEAR_DESC)

	-- the column: a plain dark ground, see-through
	local left = CreateFrame("Frame", nil, book)
	left:SetPoint("TOPLEFT", 8, -PANELS_TOP)
	left:SetSize(COL_W, PANEL_H)
	local shade = left:CreateTexture(nil, "BACKGROUND")
	shade:SetAllPoints()
	shade:SetColorTexture(0, 0, 0, 0.45)
	-- the right: the collections' ground (stone, shadowed corners), as the
	-- transmog's; else an inset
	local right
	if C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("CollectionsBackgroundTemplate") then
		right = CreateFrame("Frame", nil, book, "CollectionsBackgroundTemplate")
	else
		right = Inset(book)
	end
	right:ClearAllPoints()
	right:SetPoint("TOPLEFT", left, "TOPRIGHT", 6, 0)
	right:SetSize(PAGE_W, PANEL_H)
	-- the stone and its shadows, without the ornaments in the corners
	for _, key in ipairs({ "BGCornerTopLeft", "BGCornerTopRight", "BGCornerBottomLeft", "BGCornerBottomRight" }) do
		if right[key] then
			right[key]:Hide()
		end
	end

	leftPage = CreateFrame("Frame", nil, book)
	leftPage:SetAllPoints(left)
	rightPage = CreateFrame("Frame", nil, book)
	rightPage:SetAllPoints(right)
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
		elseif kind == "cbslider" then
			-- the box and its slider on one line, as Blizzard's
			y = W.CheckSlider(pf, y, CW, item.indent, Label(item), item.tooltip, Getter(item.setting), Setter(item.setting),
				item.secondName, item.secondTooltip, item.options, Getter(item.second), Setter(item.second))
		elseif kind == "cbdropdown" then
			y = W.Checkbox(pf, y, CW, item.indent, Label(item), item.tooltip, Getter(item.setting), Setter(item.setting))
			y = W.Dropdown(pf, y, CW, true, item.secondName, item.secondTooltip, item.options, Getter(item.second), Setter(item.second))
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
			y = W.Keybind(pf, y, CW, item.indent, Label(item), item.tooltip, item.action, item.store)
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

-- what the Modules and SetGo! tabs list; group = the right page
local function Entries(tab)
	if tab == "modules" then
		local list = {}
		for i, page in ipairs(ns.BuildPath("modules")) do
			list[#list + 1] = { label = page.title, group = "modules", index = i }
		end
		return list
	end
	-- SetGo!'s page, the UI Tweaks (Tweaks.lua), then the Backup page
	-- (Backup.lua)
	return {
		{ label = L.SETGO_TITLE, group = "setgo", index = 1 },
		{ label = L.TWEAKS_TITLE, group = "setgo", index = 2 },
		{ label = L.BACKUP_TITLE, group = "setgo", index = 3 },
	}
end

-- the tab a group lives in
local TAB_OF = {
	newpreset = "presets", modules = "modules", setgo = "settings", settings = "settings",
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

--------------------------------------------------------------------------------
-- Profile cards, in the column: the player's profiles in their order (up to
-- ns.MAX_PROFILES), then + New while there is room. The one this character
-- uses is marked; the one open on the right is highlighted.
--------------------------------------------------------------------------------

local OPTION_H, GAP = 52, 4 -- the character select card, scaled
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
		if b.datesText and b.datesText ~= "" then
			GameTooltip:AddLine(b.datesText, 0.8, 0.8, 0.8, true)
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

-- The cards of Blizzard's character select: its ground, the hover, the
-- selected frame and the empty card (+ New); scaled to the column
local CARD_ART = {
	normal = "glues-characterselect-card-singles",
	hover = "glues-characterselect-card-singles-hover",
	selected = "glues-characterselect-card-selected",
	empty = "glues-characterselect-card-empty",
	emptyHover = "glues-characterselect-card-empty-hover",
	move = "glues-characterselect-button-card",
	movePressed = "glues-characterselect-button-card-pressed",
	moveHover = "glues-characterselect-button-card-hover",
	moveUpOff = "glues-characterSelect-button-card-up-disabled",
	moveDownOff = "glues-characterselect-button-card-down-disabled",
	-- the arrow drawn over the button
	arrowUp = "glues-characterselect-icon-arrowup",
	arrowDown = "glues-characterselect-icon-arrowdown",
}

local function CardArt(b)
	b.ground = b:CreateTexture(nil, "BACKGROUND")
	b.ground:SetAllPoints()
	if not Atlas(b.ground, CARD_ART.normal) then
		b.ground:SetColorTexture(0.1, 0.08, 0.06, 0.9)
	end
	-- the hover under the text (the art is opaque: on the highlight layer it
	-- would cover the name)
	b.hover = b:CreateTexture(nil, "BACKGROUND", nil, 1)
	b.hover:SetAllPoints()
	if not Atlas(b.hover, CARD_ART.hover) then
		b.hover:SetColorTexture(1, 1, 1, 0.08)
	end
	b.hover:Hide()
	b:HookScript("OnEnter", function(self)
		self.hover:Show()
	end)
	b:HookScript("OnLeave", function(self)
		self.hover:Hide()
	end)
	b.selected = b:CreateTexture(nil, "BACKGROUND", nil, 2)
	b.selected:SetAllPoints()
	if not Atlas(b.selected, CARD_ART.selected) then
		b.selected:SetColorTexture(1, 0.82, 0, 0.15)
	end
	b.selected:Hide()
	-- empty (+ New) or a profile's
	function b:SetEmpty(empty)
		if empty then
			if not Atlas(self.ground, CARD_ART.empty) then
				self.ground:SetColorTexture(0.05, 0.05, 0.05, 0.6)
			end
			Atlas(self.hover, CARD_ART.emptyHover)
		else
			if not Atlas(self.ground, CARD_ART.normal) then
				self.ground:SetColorTexture(0.1, 0.08, 0.06, 0.9)
			end
			Atlas(self.hover, CARD_ART.hover)
		end
	end
end

-- the character select's move buttons: its box, its arrow over it, inside
-- the card's border. Disabled: the same, greyed (Blizzard's disabled art is
-- another size). Else Blizzard's plain arrows.
local function MoveButton(parent, down, onClick)
	local a = CreateFrame("Button", nil, parent)
	a:SetSize(21, 21)
	local function Tex(layer, atlas, sub)
		local t = a:CreateTexture(nil, layer, nil, sub)
		t:SetAllPoints()
		if Atlas(t, atlas) then
			return t
		end
		t:Hide()
	end
	local box = Tex("ARTWORK", CARD_ART.move, 0)
	local pressed = Tex("ARTWORK", CARD_ART.movePressed, 0)
	if pressed then
		pressed:Hide()
	end
	local hover = Tex("HIGHLIGHT", CARD_ART.moveHover)
	local base = down and "glues-characterselect-icon-arrowdown" or "glues-characterselect-icon-arrowup"
	local arrow = a:CreateTexture(nil, "ARTWORK", nil, 2)
	arrow:SetSize(15, 15)
	arrow:SetPoint("CENTER")
	if not Atlas(arrow, base) then
		arrow:SetTexture(down and "Interface\\Buttons\\Arrow-Down-Up" or "Interface\\Buttons\\Arrow-Up-Up")
	end
	if not hover then
		a:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	end
	if box and pressed then
		a:SetScript("OnMouseDown", function(self)
			if self:IsEnabled() then
				box:Hide()
				pressed:Show()
			end
		end)
		a:SetScript("OnMouseUp", function()
			pressed:Hide()
			box:Show()
		end)
	end
	hooksecurefunc(a, "SetEnabled", function(self, on)
		for _, t in ipairs({ box, arrow }) do
			if t then
				t:SetDesaturated(not on)
				t:SetAlpha(on and 1 or 0.4)
			end
		end
	end)
	a:SetScript("OnClick", onClick)
	return a
end

local function SlotButton(parent)
	local b = CreateFrame("Button", nil, parent)
	b.kind = "options"
	b:SetSize(SLOT_W, OPTION_H)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	CardArt(b)
	-- a profile: the favourite star and its name, In use under it; the
	-- move buttons on the right order the list
	b.star = CreateFrame("Button", nil, b)
	b.star:SetSize(16, 16)
	b.star:SetPoint("LEFT", 12, 0)
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
	b.name = W.Text(b, W.FONT_BODY, SLOT_W - 12 - 16 - 6 - 40, "")
	b.name:SetPoint("LEFT", b.star, "RIGHT", 6, 0)
	Try(b.name.SetWordWrap, b.name, false)
	b.use = W.Text(b, W.FONT_SMALL, SLOT_W - 70, L.IN_USE)
	b.use:SetTextColor(0.4, 0.85, 0.4)
	b.use:SetPoint("TOPLEFT", b.name, "BOTTOMLEFT", 0, -2)
	b.new = W.Text(b, W.FONT_BODY, SLOT_W - 20, "", 0.8)
	b.new:SetJustifyH("CENTER")
	b.new:SetPoint("CENTER")
	b.up = MoveButton(b, false, function()
		if b.profile and ns.MoveProfile(b.profile, -1) then
			ns.Refresh()
		end
	end)
	b.up:SetPoint("RIGHT", b, "RIGHT", -10, 11)
	b.down = MoveButton(b, true, function()
		if b.profile and ns.MoveProfile(b.profile, 1) then
			ns.Refresh()
		end
	end)
	b.down:SetPoint("RIGHT", b, "RIGHT", -10, -11)

	-- drag a profile to another place in the list
	b:RegisterForDrag("LeftButton")
	b:SetScript("OnDragStart", function(self)
		if self.profile then
			ns.StartProfileDrag(self)
		end
	end)
	b:SetScript("OnDragStop", function(self)
		ns.StopProfileDrag(self)
	end)

	b:SetScript("OnClick", function(self, button)
		GameTooltip:Hide()
		if button == "RightButton" then
			ns.SlotMenu(self)
		elseif not self.profile then
			-- + New: its name, then its form (its layout, a preset or a copy
			-- are picked on its tabs)
			ns.AskNewProfile()
		else
			ns.SlotClick(self.kind, self.profile)
		end
	end)
	b:HookScript("OnEnter", SlotTip)
	b:HookScript("OnLeave", function()
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
	-- the one open on the right
	local chosen = ns.creating and ns.creating.edit or nil
	local full = #names >= ns.MAX_PROFILES
	for i = 1, math.max(#names + 1, #slots.options) do
		local b = Slot(i)
		local name = names[i]
		b.profile = name
		b.active = name ~= nil and name == active
		if name then
			local p = type(store[name]) == "table" and store[name] or {}
			b:SetEmpty(false)
			b.name:SetText(name)
			-- In use under the name: the name moves up to make room
			b.name:ClearAllPoints()
			b.name:SetPoint(b.active and "BOTTOMLEFT" or "LEFT", b.star, b.active and "RIGHT" or "RIGHT", 6, b.active and 1 or 0)
			b.use:SetShown(b.active)
			local created, saved = Stamp(p.created), Stamp(p.saved, true)
			if created and saved then
				b.datesText = L.SLOT_DATES:format(created, saved)
			else
				b.datesText = created or saved or ""
			end
			b.name:Show()
			b.new:Hide()
			if not Atlas(b.star.tex, "auctionhouse-icon-favorite") then
				b.star.tex:SetTexture("Interface\\Common\\ReputationStar")
				b.star.tex:SetTexCoord(0, 0.5, 0, 0.5)
			end
			Try(b.star.tex.SetDesaturated, b.star.tex, not p.favorite)
			if p.favorite then
				b.star.tex:SetVertexColor(1, 1, 1)
				b.star.tex:SetAlpha(1)
			else
				b.star.tex:SetVertexColor(0.6, 0.6, 0.6)
				b.star.tex:SetAlpha(0.4)
			end
			b.star:Show()
			b.up:Show()
			b.down:Show()
			b.up:SetEnabled(i > 1)
			b.down:SetEnabled(i < #names)
			b.selected:SetShown(name == chosen)
			b:Show()
		elseif i == #names + 1 and not full then
			-- + New: a menu of what the new one starts from
			b.datesText = nil
			local making = ns.creating ~= nil and not ns.creating.edit
			b:SetEmpty(true)
			b.use:Hide()
			b.name:Hide()
			b.star:Hide()
			b.up:Hide()
			b.down:Hide()
			b.new:SetText("+  " .. L.NEW_PRESET)
			b.new:Show()
			b.selected:SetShown(making)
			b:Show()
		else
			b:Hide()
		end
	end
end

-- Dragging a profile: the card fades, a gold line shows where it goes, and
-- it is moved there when dropped
local drag

local function DropIndex()
	local list = leftPage.nav.optionsList
	local names = ns.ProfileSlots()
	local top = list:GetTop()
	if not (top and drag) then
		return drag and drag.from
	end
	local _, cy = GetCursorPosition()
	local rel = top - cy / list:GetEffectiveScale()
	local i = math.floor(rel / (OPTION_H + GAP)) + 1
	return math.max(1, math.min(#names, i))
end

function ns.StartProfileDrag(b)
	local list = leftPage.nav.optionsList
	local from
	for i, name in ipairs(ns.ProfileSlots()) do
		if name == b.profile then
			from = i
		end
	end
	if not from then
		return
	end
	GameTooltip:Hide()
	drag = { card = b, from = from }
	if not list.dropLine then
		list.dropLine = list:CreateTexture(nil, "OVERLAY")
		list.dropLine:SetHeight(2)
		list.dropLine:SetColorTexture(1, 0.82, 0, 1)
	end
	b:SetAlpha(0.5)
	b:SetScript("OnUpdate", function()
		local to = DropIndex()
		local line = list.dropLine
		line:ClearAllPoints()
		-- over the card it goes before, under the one it goes after
		local edge = to > drag.from and to or to - 1
		local y = -(edge * (OPTION_H + GAP) - GAP / 2)
		line:SetPoint("TOPLEFT", list, "TOPLEFT", 0, y + 1)
		line:SetPoint("TOPRIGHT", list, "TOPLEFT", SLOT_W, y + 1)
		line:SetShown(to ~= drag.from)
	end)
end

function ns.StopProfileDrag(b)
	b:SetScript("OnUpdate", nil)
	b:SetAlpha(1)
	local list = leftPage.nav.optionsList
	if list.dropLine then
		list.dropLine:Hide()
	end
	if not drag then
		return
	end
	local to, from, name = DropIndex(), drag.from, drag.card.profile
	drag = nil
	if to and name and to ~= from then
		local step = to > from and 1 or -1
		for _ = 1, math.abs(to - from) do
			ns.MoveProfile(name, step)
		end
		ns.Refresh()
	end
end

-- the backup card at the bottom of the column: when the last one was made
local function FillBackup()
	local card = leftPage.nav.backup
	if not card then
		return
	end
	local list = ns.Backups and ns.Backups() or {}
	local last = list[1] and list[1].at
	card.when:SetText(last and L.BACKUP_LAST:format(date("%d/%m/%Y", last)) or L.BACKUP_NONE_YET)
	local open = state.group == "setgo" and state.index == 3 and not ns.creating
	card.selected:SetShown(open)
end

local function RefreshList()
	FillSlots()
	FillBackup()
end

local function CreateNav()
	local nav = CreateFrame("Frame", nil, leftPage)
	nav:SetAllPoints()
	nav.refreshers = {}
	nav.tabs = {}
	nav.moduleButtons = {}
	leftPage.nav = nav

	-- no title of its own: the band next to the portrait says Profiles
	local cards = CreateFrame("Frame", nil, nav)
	cards:SetPoint("TOPLEFT", 6, -6)
	cards:SetSize(SLOT_W, (ns.MAX_PROFILES + 1) * (OPTION_H + GAP))
	nav.optionsList = cards

	-- the backups, at the bottom: when the last one was made
	local card = CreateFrame("Button", nil, nav)
	card:SetSize(SLOT_W, OPTION_H)
	card:SetPoint("BOTTOMLEFT", 6, 6)
	CardArt(card)
	card.title = W.Text(card, W.FONT_BODY, SLOT_W - 20, L.BACKUP_TITLE)
	card.title:SetPoint("BOTTOMLEFT", card, "LEFT", 14, 1)
	card.when = W.Text(card, W.FONT_SMALL, SLOT_W - 20, "", 0.8)
	card.when:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -3)
	card:SetScript("OnClick", function()
		ns.LeaveForm(function()
			ns.Select("setgo", 3)
		end)
	end)
	W.TipScripts(card, L.BACKUP_TITLE, L.BACKUP_NOTE, true)
	nav.backup = card
end

-- The gear: SetGo!'s settings page (Settings.lua), on the right
function ns.GearMenu()
	ns.LeaveForm(function()
		ns.Select("settings")
	end)
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
		local n = ns.CountStaged() + ((ns.ScaleWaiting and ns.ScaleWaiting()) and 1 or 0)
		if n > 0 then
			Confirm(L.POPUP_DISCARD:format(n), function()
				ns.ClearStaged()
				if ns.DiscardScale then
					ns.DiscardScale()
				end
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
		return {
			{ key = "setgo", title = L.SETGO_TITLE, items = ns.SetGoItems(), own = true },
			{ key = "tweaks", title = L.TWEAKS_TITLE, items = ns.TweaksItems(), own = true },
			{ key = "backup", title = L.BACKUP_TITLE, items = ns.BackupItems(), own = true },
		}
	end
	return ns.BuildPath(group)
end

-- the header of a module's page, or SetGo!'s
local function PageHead(page)
	if page.own and page.key == "tweaks" then
		return { icon = ns.TWEAKS_ICON, name = L.TWEAKS_TITLE, desc = L.TWEAKS_DESC }
	elseif page.own and page.key == "backup" then
		return { icon = ns.ICON, name = L.BACKUP_TITLE, desc = L.BACKUP_NOTE }
	elseif page.own then
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

-- the gear's pages: their own name in the band
local function PageName()
	local page = state.pages and state.index and state.pages[state.index]
	return page and page.title
end

-- the right page's own frames, one per mode
local MODES = { "pages", "newpreset", "settings" }
local SPECIAL = { newpreset = true, settings = true }

-- the profile form shows on the right page (any of its tabs)
local function OnForm()
	return state.group == "newpreset"
end
ns.OnForm = OnForm

local function Crumb()
	local group = state.group
	if OnForm() then
		return L.YOUR_PRESETS
	end
	if group == "settings" then
		return ns.SETTINGS_L and ns.SETTINGS_L.TITLE or L.SETGO_TITLE
	end
	if PageName() then
		return PageName()
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
	if open and state.group == "newpreset" and f.tab == "addons" and f.customModules then
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
	-- SetGo!'s page: the window size waiting counts as one
	local extra = (group == "setgo" and ns.ScaleWaiting and ns.ScaleWaiting()) and 1 or 0
	local staging = state.mode == "pages" and ns.CountStaged() + extra > 0
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
	local n = ns.CountStaged() + extra
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
	elseif state.mode == "settings" and ns.RefreshSettingsPage then
		ns.RefreshSettingsPage()
	end
	book.crumb:SetText(Crumb())
	UpdateChrome()
	-- the guide's tips follow (Tour.lua)
	if ns.GuideUpdate then
		ns.GuideUpdate()
	end
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
	-- leaving SetGo!'s page: a window size not applied is dropped
	if not sameGroup and ns.DiscardScale then
		ns.DiscardScale()
	end
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
	ns.SelectTab("presets")
end

--------------------------------------------------------------------------------
-- Profiles: open, rename, copy, export, delete
--------------------------------------------------------------------------------

local function AskName(text, onName, default)
	C_Timer.After(0, function()
		Popup("SETGO_NAME", text, { onName = onName, default = default })
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

-- the card that makes a new profile (the guide points at it), if shown
function ns.NewProfileSlot()
	for _, b in ipairs(slots.options) do
		if b:IsShown() and b.profile == nil and b.new:IsShown() then
			return b
		end
	end
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
		end, old)
	end
	Ask()
end

-- Rename, from the header: a profile of the list now; a new one (not saved
-- yet) gets the name on its form
function ns.AskRename()
	local edit = ns.creating and ns.creating.edit
	if edit then
		Rename(edit)
		return
	end
	local function Ask()
		AskName(L.POPUP_NEW_NAME, function(name)
			if not FreeName(ns.db.profiles, name, Ask) then
				return
			end
			ns.SetFormName(name)
		end, ns.FormName and ns.FormName() or nil)
	end
	Ask()
end

-- + New: its name first (as a new macro), then its form
function ns.AskNewProfile()
	if ns.ProfilesFull() then
		ns.Print(L.MSG_PROFILES_FULL:format(ns.MAX_PROFILES))
		return
	end
	local function Ask()
		AskName(L.POPUP_NEW_NAME, function(name)
			if not FreeName(ns.db.profiles, name, Ask) then
				return
			end
			ns.LeaveForm(function()
				ns.OpenForm(nil)
			end)
			if ns.FormStartEmpty then
				ns.FormStartEmpty()
			end
			ns.SetFormName(name)
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
			-- Rename, Delete, then Export (what goes too, off until ticked)
			root:CreateTitle(name)
			root:CreateButton(L.RENAME, function()
				Rename(name)
			end)
			root:CreateButton(L.DELETE, function()
				Delete(name)
			end)
			root:CreateDivider()
			local export = root:CreateButton(L.EXPORT)
			local with = { keys = false, settings = false }
			local function Box(label, key)
				local box = export:CreateCheckbox(label, function()
					return with[key]
				end, function()
					with[key] = not with[key]
				end)
				if box and box.SetResponse and MenuResponse then
					box:SetResponse(MenuResponse.Refresh)
				end
			end
			Box(L.SCOPE_SETTINGS, "settings")
			Box(ns.G("KEY_BINDINGS", L.SCOPE_KEYS), "keys")
			export:CreateDivider()
			export:CreateButton(L.EXPORT .. "...", function()
				ns.ExportProfileText(name, with)
			end)
			return
		end
		-- + New: a new one, or one from a code
		local full = ns.ProfilesFull()
		local new = root:CreateButton(L.NEW_PRESET, function()
			ns.AskNewProfile()
		end)
		local import = root:CreateButton(L.IMPORT_PROFILE)
		ns.ImportMenuItems(import, function(opts)
			ns.AskImportProfile(opts)
		end)
		if full then
			for _, d in ipairs({ new, import }) do
				if d and d.SetEnabled then
					d:SetEnabled(false)
				end
			end
		end
	end)
end

-- Apply: every change waiting, after asking: the
-- reload must come from Blizzard's own popup
function ns.ApplyAndSave()
	-- the window size (SetGo!'s page): at once, no reload
	if ns.ScaleWaiting and ns.ScaleWaiting() then
		ns.ApplyScaleDraft()
		if ns.CountStaged() == 0 then
			ns.Refresh()
			return
		end
	end
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
	ns.ScaleFrame(frame)
	-- closed: a window size not applied is dropped, the guide ends
	frame:HookScript("OnHide", function()
		if ns.DiscardScale then
			ns.DiscardScale()
		end
		if ns.GuideUpdate then
			ns.GuideUpdate()
		end
	end)
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
	ns.CreateSettingsPage()

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
-- Where Blizzard's windows open (its panels' place: 16 from the left, 116
-- from the top), or on the right of the ones open there
local function PlaceWindow()
	local ui = UIParent:GetEffectiveScale()
	local x = 16
	if GetUIPanel then
		for _, key in ipairs({ "left", "center", "doublewide", "right" }) do
			local panel = GetUIPanel(key)
			local right = panel and panel:IsShown() and panel:GetRight()
			if right then
				x = math.max(x, right * panel:GetEffectiveScale() / ui + 8)
			end
		end
	end
	local s = frame:GetScale()
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x / s, -116 / s)
end

-- Once, for players coming from the old window: where things are now
local function NewWindowTip()
	if ns.db.newWindowSeen or not (HelpTip and HelpTip.Show) then
		return
	end
	ns.db.newWindowSeen = true
	-- only for players who knew the old one
	if not (ns.db.guideSeen or ns.db.tourSeen) then
		return
	end
	local L2 = ns.SETTINGS_L or {}
	HelpTip:Show(frame, {
		text = L2.NEW_WINDOW_TIP or L.NEW_WINDOW_TIP,
		buttonStyle = HelpTip.ButtonStyle and HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point and HelpTip.Point.RightEdgeCenter,
		alignment = HelpTip.Alignment and HelpTip.Alignment.Center,
		offsetX = -10,
	})
end

function ns.Open()
	if not frame then
		CreateWindow()
	end
	if frame:IsShown() then
		return
	end
	resumeAfterCombat = false
	PlaceWindow()
	keeping = true
	frame:Show()
	keeping = false
	ns.LeaveForm()
	ns.GoHome(true)
	Try(NewWindowTip)
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