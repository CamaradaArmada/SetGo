local _, ns = ...
local L = ns.L

-- Rows built from Blizzard's own templates, stacked top to bottom on a book
-- page. Each builder takes the page, the current y offset and the content
-- width, and returns the new y offset. Rows with values register a refresh
-- function on page.refreshers.

local W = {}
ns.Widgets = W

local ROW_GAP = 10
local INDENT = 22

-- dark ink on the parchment, like the spellbook
local function Ink()
	if SPELLBOOK_FONT_COLOR and SPELLBOOK_FONT_COLOR.GetRGB then
		return SPELLBOOK_FONT_COLOR:GetRGB()
	end
	return 0.23, 0.13, 0.05
end
W.Ink = Ink

W.FONT_TITLE = "SystemFont_Huge2"
W.FONT_HEADER = "SystemFont_Large"
W.FONT_BODY = "SystemFont_Med1"
W.FONT_SMALL = "SystemFont_Small"

function W.Text(parent, font, width, text, alpha)
	local fs = parent:CreateFontString(nil, "OVERLAY", _G[font] and font or "GameFontNormal")
	fs:SetJustifyH("LEFT")
	if width then
		fs:SetWidth(width)
	end
	fs:SetText(text or "")
	local r, g, b = Ink()
	fs:SetTextColor(r, g, b, alpha or 1)
	fs:SetShadowColor(0, 0, 0, 0)
	return fs, (text and text ~= "") and fs:GetStringHeight() or 0
end

--------------------------------------------------------------------------------
-- Tooltips, in Blizzard's style: the option name, then its explanation
--------------------------------------------------------------------------------

local function TipText(tip)
	if type(tip) == "function" then
		local ok, text = pcall(tip)
		return ok and text or nil
	end
	return tip
end

local function ShowTip(owner, title, tip)
	local text = TipText(tip)
	if not text or text == "" then
		return
	end
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	-- the title, like the text, may be worked out when shown
	GameTooltip:SetText(TipText(title) or "", 1, 1, 1)
	GameTooltip:AddLine(text, nil, nil, nil, true)
	GameTooltip:Show()
end

local function HideTip()
	GameTooltip:Hide()
end

local function TipScripts(frame, title, tip, hook)
	local enter = function(self)
		ShowTip(self, title, tip)
	end
	if hook then
		frame:HookScript("OnEnter", enter)
		frame:HookScript("OnLeave", HideTip)
	else
		frame:SetScript("OnEnter", enter)
		frame:SetScript("OnLeave", HideTip)
	end
end
W.TipScripts = TipScripts

-- label at (x, y) with a hover area for the tooltip; returns the height used
local function Label(parent, x, y, width, label, tip)
	local l, lh = W.Text(parent, W.FONT_BODY, width, label)
	l:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
	if TipText(tip) then
		local hover = CreateFrame("Frame", nil, parent)
		hover:SetPoint("TOPLEFT", l, "TOPLEFT", -2, 2)
		hover:SetSize(math.min(width, (l:GetStringWidth() or width) + 4), lh + 4)
		hover:EnableMouse(true)
		TipScripts(hover, label, tip)
	end
	return lh
end

--------------------------------------------------------------------------------
-- Text rows
--------------------------------------------------------------------------------

function W.Paragraph(page, y, width, text, font)
	local fs, h = W.Text(page, font or W.FONT_BODY, width, text)
	fs:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
	return y + h + ROW_GAP, fs
end

-- section header with a thin rule, as in Blizzard's settings list
function W.Header(page, y, width, text)
	if y > 0 then
		y = y + 8
	end
	local fs, h = W.Text(page, W.FONT_HEADER, width, text)
	fs:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
	local line = page:CreateTexture(nil, "ARTWORK")
	line:SetHeight(1)
	local r, g, b = Ink()
	line:SetColorTexture(r, g, b, 0.35)
	line:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -4)
	line:SetPoint("RIGHT", page, "LEFT", width, 0)
	return y + h + 5 + ROW_GAP
end

-- a second category merged into a page: bigger title with the book's divider
function W.Title(page, y, width, text)
	if y > 0 then
		y = y + 14
	end
	local fs, h = W.Text(page, W.FONT_TITLE, width, text)
	fs:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
	return y + h + ROW_GAP
end

--------------------------------------------------------------------------------
-- Controls
--------------------------------------------------------------------------------

function W.Checkbox(page, y, width, indent, label, tip, get, set)
	local x = indent and INDENT or 0
	local cb = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
	cb:SetSize(26, 26)
	cb:SetPoint("TOPLEFT", page, "TOPLEFT", x - 3, -(y - 5))
	local h = Label(page, x + 26, y, width - x - 26, label, tip)
	TipScripts(cb, label, tip)
	cb:SetScript("OnClick", function(self)
		ns.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		set(self:GetChecked() and true or false)
	end)
	table.insert(page.refreshers, function()
		cb:SetChecked(get() and true or false)
	end)
	return y + math.max(h, 18) + ROW_GAP, cb
end

local function IsCheckboxOption(opt)
	return Settings and Settings.ControlType and opt.controlType == Settings.ControlType.Checkbox
end

-- options: Blizzard's option list, or a function that returns it
-- ({ value, label, text, tooltip, controlType })
function W.Dropdown(page, y, width, indent, label, tip, options, get, set)
	local x = indent and INDENT or 0
	if label then
		y = y + Label(page, x, y, width - x, label, tip) + 5
	end
	local dd = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
	TipScripts(dd, label, tip, true)
	dd:SetPoint("TOPLEFT", page, "TOPLEFT", x + 2, -y)
	dd:SetWidth(math.min(260, width - x - 4))
	local function List()
		local list = options
		if type(list) == "function" then
			local ok, result = pcall(list)
			list = ok and result or {}
		end
		return type(list) == "table" and list or {}
	end
	local function Setup()
		dd:SetupMenu(function(_, root)
			for _, opt in ipairs(List()) do
				local text = opt.label or opt.text or tostring(opt.value)
				local desc
				if IsCheckboxOption(opt) then
					-- bitmask, as Blizzard's Settings.CreateDropdownOptionInserter
					local bitValue = bit.lshift(1, opt.value - (opt.enumValueOffset or 1))
					desc = root:CreateCheckbox(text, function()
						return bit.band(tonumber(get()) or 0, bitValue) ~= 0
					end, function()
						set(bit.bxor(tonumber(get()) or 0, bitValue))
					end)
				else
					desc = root:CreateRadio(text, function()
						return ns.Same(get(), opt.value)
					end, function()
						set(opt.value)
					end)
				end
				if opt.tooltip and desc and desc.SetTooltip then
					desc:SetTooltip(function(tooltip)
						GameTooltip_SetTitle(tooltip, text)
						GameTooltip_AddNormalLine(tooltip, opt.tooltip)
					end)
				end
			end
		end)
	end
	table.insert(page.refreshers, Setup)
	return y + 26 + ROW_GAP, dd
end

local function DarkenSliderText(slider)
	local r, g, b = Ink()
	for _, key in ipairs({ "LeftText", "RightText", "TopText", "MinText", "MaxText" }) do
		local fs = slider[key]
		if type(fs) == "table" and fs.SetTextColor then
			fs:SetTextColor(r, g, b)
			fs:SetShadowColor(0, 0, 0, 0)
		end
	end
end

-- options: Blizzard's slider options { minValue, maxValue, steps, formatters }
function W.Slider(page, y, width, indent, label, tip, options, get, set)
	local x = indent and INDENT or 0
	if label then
		y = y + Label(page, x, y, width - x, label, tip) + 4
	end
	local slider = CreateFrame("Frame", nil, page, "MinimalSliderWithSteppersTemplate")
	slider:SetPoint("TOPLEFT", page, "TOPLEFT", x + 4, -y)
	slider:SetSize(math.min(250, width - x - 60), 20)
	local min, max = options.minValue or 0, options.maxValue or 1
	local steps = options.steps or 100
	local busy = false
	slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
		if not busy then
			set(value)
		end
	end, slider)
	table.insert(page.refreshers, function()
		busy = true
		local value = tonumber(get()) or min
		value = math.max(min, math.min(max, value))
		slider:Init(value, min, max, steps, options.formatters)
		DarkenSliderText(slider)
		busy = false
	end)
	return y + 20 + ROW_GAP, slider
end

-- key binding button: click, then press a key; right click clears
local MODIFIER_KEYS = { LSHIFT = true, RSHIFT = true, LCTRL = true, RCTRL = true, LALT = true, RALT = true, UNKNOWN = true }
local MOUSE_KEYS = { MiddleButton = "BUTTON3", Button4 = "BUTTON4", Button5 = "BUTTON5" }

function W.Keybind(page, y, width, indent, label, tip, action)
	local x = indent and INDENT or 0
	local h = Label(page, x, y, width - x, label, tip)
	y = y + h + 5
	local b = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	b:SetSize(180, 22)
	b:SetPoint("TOPLEFT", page, "TOPLEFT", x + 2, -y)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	TipScripts(b, label, tip)

	local listening = false
	local function Update()
		if listening then
			b:SetText(L.PRESS_KEY)
			return
		end
		local key = GetBindingKey(action)
		b:SetText(key and (GetBindingText and GetBindingText(key) or key) or L.NOT_BOUND)
	end
	local function Bind(key)
		listening = false
		b:EnableKeyboard(false)
		if b.SetPropagateKeyboardInput and not InCombatLockdown() then
			pcall(b.SetPropagateKeyboardInput, b, true)
		end
		if InCombatLockdown() then
			ns.Print(L.MSG_COMBAT)
		elseif key then
			for _, old in ipairs({ GetBindingKey(action) }) do
				SetBinding(old)
			end
			if key ~= "" then
				SetBinding(key, action)
			end
			SaveBindings(GetCurrentBindingSet and GetCurrentBindingSet() or 1)
		end
		Update()
	end
	local function WithModifiers(key)
		local prefix = ""
		if IsAltKeyDown() then
			prefix = prefix .. "ALT-"
		end
		if IsControlKeyDown() then
			prefix = prefix .. "CTRL-"
		end
		if IsShiftKeyDown() then
			prefix = prefix .. "SHIFT-"
		end
		return prefix .. key
	end

	b:SetScript("OnClick", function(self, button)
		if listening then
			local key = MOUSE_KEYS[button]
			if key then
				Bind(WithModifiers(key))
			end
			return
		end
		if button == "RightButton" then
			Bind("")
			return
		end
		listening = true
		self:EnableKeyboard(true)
		if self.SetPropagateKeyboardInput then
			pcall(self.SetPropagateKeyboardInput, self, false)
		end
		Update()
	end)
	b:SetScript("OnKeyDown", function(_, key)
		if not listening or MODIFIER_KEYS[key] then
			return
		end
		if key == "ESCAPE" then
			Bind(nil)
			return
		end
		Bind(WithModifiers(key))
	end)
	b:SetScript("OnMouseDown", function(_, button)
		if listening and MOUSE_KEYS[button] then
			Bind(WithModifiers(MOUSE_KEYS[button]))
		end
	end)
	-- Setting OnKeyDown switches the keyboard on for the button, which would
	-- swallow every key while the page is open. Off until it listens.
	b:EnableKeyboard(false)
	b:SetScript("OnHide", function()
		if listening then
			Bind(nil)
		end
	end)
	table.insert(page.refreshers, Update)
	return y + 22 + ROW_GAP, b
end

local function HasAtlas(atlas)
	return atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) ~= nil
end

-- A flat icon button from Blizzard's own art. atlas = { normal, hover,
-- pressed }. When the client doesn't have the art, a text button instead.
function W.IconButton(parent, size, atlas, fallback, onClick)
	if not HasAtlas(atlas.normal) then
		return W.Button(parent, 70, fallback, onClick, 24)
	end
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(size, size)
	b:SetNormalAtlas(atlas.normal)
	if HasAtlas(atlas.pressed) then
		b:SetPushedAtlas(atlas.pressed)
	end
	if HasAtlas(atlas.hover) then
		b:SetHighlightAtlas(atlas.hover, "BLEND")
	else
		b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	end
	b:SetScript("OnClick", onClick)
	return b
end

-- Blizzard's spellbook page arrows; dir = "Prev" or "Next"
function W.PageArrow(parent, dir, onClick)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(32, 32)
	local path = "Interface\\Buttons\\UI-SpellbookIcon-" .. dir .. "Page-"
	b:SetNormalTexture(path .. "Up")
	b:SetPushedTexture(path .. "Down")
	b:SetDisabledTexture(path .. "Disabled")
	b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	b:SetScript("OnClick", onClick) -- the page turn plays its own sound
	return b
end

function W.Button(parent, width, text, onClick, height)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(width, height or 22)
	b:SetText(text)
	b:SetScript("OnClick", onClick)
	return b
end

function W.EditBox(parent, width)
	local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	e:SetSize(width, 22)
	e:SetAutoFocus(false)
	e:SetScript("OnEscapePressed", e.ClearFocus)
	e:SetScript("OnEnterPressed", e.ClearFocus)
	return e
end
