local ADDON = ...

--------------------------------------------------------------------------------
-- LAYOUT: every size and distance in pixels, in one place, to fine tune by
-- hand. Change a number, save, /reload.
--
-- Margins are { left, right, top, bottom }: how far a frame reaches past what
-- it surrounds. A bigger number pushes that side out, a negative one pulls it
-- in.
--------------------------------------------------------------------------------

local LAYOUT = {
	-- Look "Soft": the damage meter's soft background
	soft = {
		body = { 12, 12, 6, 8 }, -- around the messages
		editBox = { 0, 0, -4, -4 }, -- around the typing box
		-- the typing box without and with the cursor in it
		editBoxAlpha = { rest = 0.25, focus = 0.5 },
		-- where the tabs sit: x sideways (negative to the left), y up
		-- (negative down)
		tabs = { x = -8, y = 0 },
	},
	-- Look "Bordered": the tooltip's border
	bordered = {
		body = { 6, 2, 2, 0 }, -- around the messages
		editBox = { -4, -4, -4, -4 }, -- around the typing box
		-- around each tab. The bottom number sets the gap between the tabs
		-- and the messages: lower it to open the gap, raise it to close it.
		tab = { -2, -2, -10, 0 },
		-- the typing box without and with the cursor in it
		editBoxAlpha = { rest = 0.6, focus = 0.85 },
		-- where the tabs sit: x sideways (negative to the left), y up
		-- (negative down)
		tabs = { x = -6, y = 4 },
	},
	-- (tabs, in both looks: higher than about 28 and Blizzard stops counting
	-- the tabs as part of the chat for its hover)
	-- the settings button, above the scroll bar of the main chat window
	button = {
		size = 20,
		x = 0, -- sideways from the middle of the scroll bar
		y = 2, -- up from the top of the scroll bar
	},
	-- top of the main window's scroll bar, down from the top of the chat (it
	-- leaves room for the button)
	scrollBarTop = -22,
	-- Bordered look: the border of the tabs that are not selected and of the
	-- typing box without the cursor (0 black, 1 full colour)
	dimBorder = 0.5,
}

--------------------------------------------------------------------------------

local L = {
	TITLE = "Speak!",
	SEC_LOOK = "Look",
	LOOK = "Style",
	LOOK_DESC = "Soft: the damage meter's soft background. Bordered: the tooltip's border around the messages, each tab and the typing box.",
	LOOK_SOFT = "Soft",
	LOOK_BORDERED = "Bordered",
	FONT = "Chat font",
	FONT_DESC = "The font of the chat messages, the typing box and the tab names. Only the game's own fonts. The size of the messages stays with Blizzard's chat settings.",
	FONT_BLIZZARD = "Blizzard default",
	SPACING = "Space between lines",
	SPACING_DESC = "Extra space between every line of chat, in pixels. Blizzard's chat has no way to space only whole messages.",
	SEC_BACKGROUND = "Background",
	BG_NOTE = "With the mouse over the chat, the background is Blizzard's: its Opacity, in the menu of each chat window, or 25% if that is lower.",
	BG_ALPHA = "Background with the mouse away",
	BG_ALPHA_DESC = "How visible the background is while the mouse is away from the chat. 100% is Blizzard's Opacity, in the menu of each chat window; 0% is fully transparent.",
	SEC_TABS = "Tabs",
	TABS_NOTE = "How visible the tabs are while the mouse is away from the chat. Over the chat they are always fully visible.",
	TAB_SELECTED = "Selected tab",
	TAB_OTHER = "Other tabs",
	TAB_SIZE = "Tab text size",
	TAB_SIZE_DESC = "The size of the tab names. The tabs grow with it.",
	GLOW = "Blizzard's glow on new messages",
	GLOW_DESC = "A tab with an unread message flashes its name. This adds Blizzard's glow behind it.",
	SEC_BUTTONS = "Buttons",
	BUTTONS = "One settings button",
	BUTTONS_DESC = "The main chat window keeps a single settings button inside the frame. Channels, social, text to speech and voice move into its menu. Turning this off reloads the interface.",
	BUTTON_ALPHA = "Settings button",
	BUTTON_ALPHA_DESC = "How visible the settings button is while the mouse is away from the chat.",
	LEATRIX = "Leatrix Plus is hiding the chat buttons, so this is left to it. Turn off \"Hide chat buttons\" in Leatrix Plus to use this.",
	MENU_CHANNELS = "Channels",
	MENU_SOCIAL = "Social",
	MENU_TTS = "Text to speech",
	MENU_MUTE = "Mute microphone",
	MENU_DEAFEN = "Mute voice chat",
	POPUP_RELOAD = "Reload the interface to put Blizzard's chat buttons back?",
	OLD_CHAT = "SetGo! Speak!: the old SetGo_Chat is still installed. Its settings were copied. Delete the SetGo_Chat folder and reload; until then Speak! stays off.",
}
if GetLocale() == "ptBR" then
	L.SEC_LOOK = "Aspecto"
	L.LOOK = "Estilo"
	L.LOOK_DESC = "Esbatido: o fundo esbatido do damage meter. Com moldura: a moldura das tooltips à volta das mensagens, de cada separador e da caixa de escrita."
	L.LOOK_SOFT = "Esbatido"
	L.LOOK_BORDERED = "Com moldura"
	L.FONT = "Fonte do chat"
	L.FONT_DESC = "A fonte das mensagens, da caixa de escrita e dos nomes dos separadores. Só as fontes do jogo. O tamanho das mensagens continua nas definições de chat da Blizzard."
	L.FONT_BLIZZARD = "A da Blizzard"
	L.SPACING = "Espaço entre linhas"
	L.SPACING_DESC = "Espaço extra entre todas as linhas do chat, em píxeis. O chat da Blizzard não permite espaçar só as mensagens inteiras."
	L.SEC_BACKGROUND = "Fundo"
	L.BG_NOTE = "Com o rato por cima do chat, o fundo é o da Blizzard: a Opacidade, no menu de cada janela de chat, ou 25% se esta for menor."
	L.BG_ALPHA = "Fundo com o rato fora"
	L.BG_ALPHA_DESC = "Quão visível fica o fundo com o rato fora do chat. 100% é a Opacidade da Blizzard, no menu de cada janela de chat; 0% é totalmente transparente."
	L.SEC_TABS = "Separadores"
	L.TABS_NOTE = "Quão visíveis ficam os separadores com o rato fora do chat. Por cima do chat ficam sempre totalmente visíveis."
	L.TAB_SELECTED = "Separador seleccionado"
	L.TAB_OTHER = "Outros separadores"
	L.TAB_SIZE = "Tamanho da letra dos separadores"
	L.TAB_SIZE_DESC = "O tamanho dos nomes dos separadores. Os separadores crescem com ele."
	L.GLOW = "Brilho da Blizzard nas mensagens novas"
	L.GLOW_DESC = "Um separador com uma mensagem por ler faz piscar o nome. Isto junta o brilho da Blizzard por trás."
	L.SEC_BUTTONS = "Botões"
	L.BUTTONS = "Um só botão de definições"
	L.BUTTONS_DESC = "A janela principal do chat fica com um só botão de definições, dentro da moldura. Canais, social, texto para fala e voz passam para o menu dele. Desligar isto recarrega a interface."
	L.BUTTON_ALPHA = "Botão de definições"
	L.BUTTON_ALPHA_DESC = "Quão visível fica o botão de definições com o rato fora do chat."
	L.LEATRIX = "O Leatrix Plus está a esconder os botões do chat, por isso isto fica com ele. Desliga \"Hide chat buttons\" no Leatrix Plus para usares isto."
	L.MENU_CHANNELS = "Canais"
	L.MENU_SOCIAL = "Social"
	L.MENU_TTS = "Texto para fala"
	L.MENU_MUTE = "Silenciar o microfone"
	L.MENU_DEAFEN = "Silenciar o chat de voz"
	L.POPUP_RELOAD = "Recarregar a interface para repor os botões do chat da Blizzard?"
	L.OLD_CHAT = "SetGo! Speak!: o antigo SetGo_Chat ainda está instalado. As definições dele foram copiadas. Apaga a pasta SetGo_Chat e recarrega; até lá o Speak! fica desligado."
end

--------------------------------------------------------------------------------
-- A cleaner chat built on Blizzard's own pieces. Nothing polls: everything
-- follows Blizzard's chat functions through hooks.
--   Looks: our own textures, drawn around Blizzard's (hidden) art. Blizzard's
--     chat colour and Opacity still apply.
--   Font: the same way Blizzard sets the chat size (a font file on each
--     window), with one of the game's fonts.
--   Tabs: the tab art is hidden and each name (and, in the Bordered look, its
--     border) is drawn by a frame of ours, so its visibility doesn't touch
--     Blizzard's tab values (Blizzard keeps those away from addons to avoid
--     taint). Hover follows Blizzard's own chat fade. The text size goes
--     through a font object on the tab, so Blizzard sizes the tab itself.
--   Buttons: Blizzard's chat menu button becomes a settings cog, and the other
--     buttons move into its menu through Blizzard's menu API.
-- SetGoSpeakDB: look, font, spacing, bgAlpha, tabSelected, tabOther,
--   tabSize, glow, buttons, buttonAlpha
--------------------------------------------------------------------------------

-- the module's switch in SetGo! (kept from SetGo_Chat, so profiles still work)
local KEY = "chat"

local db
local FONTS = {
	{ value = "FRIZ", file = "Fonts\\FRIZQT__.TTF", label = "Friz Quadrata" },
	{ value = "ARIALN", file = "Fonts\\ARIALN.TTF", label = "Arial Narrow" },
	{ value = "MORPHEUS", file = "Fonts\\MORPHEUS.TTF", label = "Morpheus" },
	{ value = "SKURRI", file = "Fonts\\SKURRI.TTF", label = "Skurri" },
}

-- Blizzard's tab text size, read from the font the tabs use
local function BlizzardTabSize()
	local _, size = GameFontNormalSmall:GetFont()
	return math.floor((size or 10) + 0.5)
end

local DEFAULTS = {
	look = "soft", font = "FRIZ", spacing = 0, bgAlpha = 1,
	tabSelected = 0.4, tabOther = 0.2, tabSize = BlizzardTabSize(), glow = true,
	buttons = true, buttonAlpha = 0.4,
}

local function Get(key)
	local v = db and db[key]
	if v == nil then
		return DEFAULTS[key]
	end
	return v
end

local function Look()
	-- "tooltip": the Bordered look's first name
	local look = Get("look")
	return (look == "bordered" or look == "tooltip") and "bordered" or "soft"
end

local function FontFile()
	local key = Get("font")
	for _, f in ipairs(FONTS) do
		if f.value == key then
			return f.file
		end
	end
end

-- Blizzard's own list (read only, never changed here), or the default
-- windows before it exists
local DEFAULT_NAMES = {}
for i = 1, NUM_CHAT_WINDOWS or 10 do
	DEFAULT_NAMES[i] = "ChatFrame" .. i
end

local function ChatNames()
	if CHAT_FRAMES and #CHAT_FRAMES > 0 then
		return CHAT_FRAMES
	end
	return DEFAULT_NAMES
end

local function HasAtlas(atlas)
	return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) ~= nil
end

--------------------------------------------------------------------------------
-- Fades
--------------------------------------------------------------------------------

local function NewFade(region)
	region.fade = region:CreateAnimationGroup()
	region.fadeAlpha = region.fade:CreateAnimation("Alpha")
	region.fade:SetScript("OnFinished", function()
		region:SetAlpha(region.fadeTarget or region:GetAlpha())
	end)
end

local function FadeTo(region, target, duration)
	region.fade:Stop()
	region.fadeTarget = target
	local from = region:GetAlpha()
	if math.abs(from - target) < 0.01 or (duration or 0) <= 0 then
		region:SetAlpha(target)
		return
	end
	region.fadeAlpha:SetFromAlpha(from)
	region.fadeAlpha:SetToAlpha(target)
	region.fadeAlpha:SetDuration(duration)
	region.fade:Play()
end

--------------------------------------------------------------------------------
-- Skins: the textures of both looks around one thing (the messages, a tab or
-- the typing box), drawn on a host frame under its text.
--   Soft: one texture, the damage meter's soft background.
--   Bordered: Blizzard's tooltip nine slice, built by hand so it can hang off
--     any region with our margins.
--------------------------------------------------------------------------------

local SOFT = "common-dropdown-bg"
local TOOLTIP_LAYOUT = "TooltipDefaultLayout"
-- the same order and anchors as Blizzard's NineSliceUtil
local SLICES = {
	{ key = "TopLeftCorner", point = "TOPLEFT", corner = true },
	{ key = "TopRightCorner", point = "TOPRIGHT", corner = true },
	{ key = "BottomLeftCorner", point = "BOTTOMLEFT", corner = true },
	{ key = "BottomRightCorner", point = "BOTTOMRIGHT", corner = true },
	{ key = "TopEdge", point = "TOPLEFT", relativePoint = "TOPRIGHT", from = "TopLeftCorner", to = "TopRightCorner" },
	{ key = "BottomEdge", point = "BOTTOMLEFT", relativePoint = "BOTTOMRIGHT", from = "BottomLeftCorner", to = "BottomRightCorner" },
	{ key = "LeftEdge", point = "TOPLEFT", relativePoint = "BOTTOMLEFT", from = "TopLeftCorner", to = "BottomLeftCorner" },
	{ key = "RightEdge", point = "TOPRIGHT", relativePoint = "BOTTOMRIGHT", from = "TopRightCorner", to = "BottomRightCorner" },
}

local function TooltipLayout()
	local layout = NineSliceUtil and NineSliceUtil.GetLayout and NineSliceUtil.GetLayout(TOOLTIP_LAYOUT)
	if layout and layout.TopLeftCorner and HasAtlas(layout.TopLeftCorner.atlas) then
		return layout
	end
end

local function SetSliceAtlas(tex, atlas)
	local info = C_Texture.GetAtlasInfo(atlas)
	tex:SetHorizTile(info and info.tilesHorizontally or false)
	tex:SetVertTile(info and info.tilesVertically or false)
	if info then
		tex:SetAtlas(atlas, true)
	end
end

local Skin = {}
Skin.__index = Skin

-- host: the frame that draws it; sublevel: under the host's other art
function Skin.New(host, layer, sublevel)
	local self = setmetatable({ host = host, all = {}, fill = {} }, Skin)
	self.soft = host:CreateTexture(nil, layer, nil, sublevel)
	self.fill[self.soft] = true
	if HasAtlas(SOFT) then
		self.soft:SetAtlas(SOFT)
	end
	self.all[#self.all + 1] = self.soft
	local layout = TooltipLayout()
	if layout then
		self.tip = {}
		self.center = host:CreateTexture(nil, layer, nil, sublevel)
		self.fill[self.center] = true
		SetSliceAtlas(self.center, layout.Center.atlas)
		self.all[#self.all + 1] = self.center
		for _, s in ipairs(SLICES) do
			local tex = host:CreateTexture(nil, layer, nil, math.min(sublevel + 1, 7))
			SetSliceAtlas(tex, layout[s.key].atlas)
			self.tip[s.key] = tex
			self.all[#self.all + 1] = tex
		end
		self.layout = layout
	end
	for _, tex in ipairs(self.all) do
		NewFade(tex)
	end
	self.shown = true
	return self
end

-- margins = { left, right, top, bottom }, see LAYOUT
function Skin:Place(anchor, soft, tip)
	self.soft:ClearAllPoints()
	if soft then
		self.soft:SetPoint("TOPLEFT", anchor, "TOPLEFT", -soft[1], soft[3])
		self.soft:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", soft[2], -soft[4])
	end
	if not (self.tip and tip) then
		return
	end
	local l, r, t, b = tip[1], tip[2], tip[3], tip[4]
	local corner = { TOPLEFT = { -l, t }, TOPRIGHT = { r, t }, BOTTOMLEFT = { -l, -b }, BOTTOMRIGHT = { r, -b } }
	for _, s in ipairs(SLICES) do
		local tex = self.tip[s.key]
		tex:ClearAllPoints()
		if s.corner then
			tex:SetPoint(s.point, anchor, s.point, corner[s.point][1], corner[s.point][2])
		else
			tex:SetPoint(s.point, self.tip[s.from], s.relativePoint)
			tex:SetPoint(s.relativePoint, self.tip[s.to], s.point)
		end
	end
	local c = self.layout.Center
	self.center:ClearAllPoints()
	self.center:SetPoint("TOPLEFT", self.tip.TopLeftCorner, "BOTTOMRIGHT", c.x or 0, c.y or 0)
	self.center:SetPoint("BOTTOMRIGHT", self.tip.BottomRightCorner, "TOPLEFT", c.x1 or 0, c.y1 or 0)
end

-- which look's textures show; nil hides them all
function Skin:Show(look)
	self.look = look
	local on = self.shown
	self.soft:SetShown(on and look == "soft")
	if self.tip then
		local tip = on and look == "bordered"
		self.center:SetShown(tip)
		for _, tex in pairs(self.tip) do
			tex:SetShown(tip)
		end
	end
end

-- follows Blizzard's own background being shown or hidden
function Skin:SetVisible(on)
	self.shown = on and true or false
	self:Show(self.look)
end

-- the fill: Blizzard's chat colour
function Skin:SetColor(r, g, b)
	self.soft:SetVertexColor(r, g, b)
	if self.center then
		self.center:SetVertexColor(r, g, b)
	end
end

function Skin:SetBorderColor(r, g, b)
	if self.tip then
		for _, tex in pairs(self.tip) do
			tex:SetVertexColor(r, g, b)
		end
	end
end

-- border: the border's own alpha (active: full), or the fill's when nil
function Skin:FadeTo(alpha, duration, border)
	local fill = self.fill
	for _, tex in ipairs(self.all) do
		FadeTo(tex, (fill[tex] or not border) and alpha or border, duration)
	end
end

--------------------------------------------------------------------------------
-- The messages
--------------------------------------------------------------------------------

local BORDER = { "TopLeftTexture", "BottomLeftTexture", "TopRightTexture", "BottomRightTexture",
	"LeftTexture", "RightTexture", "BottomTexture", "TopTexture" }
local bodies = {} -- [chatFrame] = skin
local hovered = {} -- [chatFrame] = true while Blizzard shows it faded in
local typing -- the chat window whose typing box has the cursor
local Refresh -- forward: a window's frames to active or faded

-- active: the mouse over the chat (Blizzard's fade) or the cursor in its
-- typing box. Typing in a docked window counts for every docked window, the
-- way Blizzard's hover does. Only our frames follow it, Blizzard's fade is
-- left alone.
local function Active(chatFrame)
	if hovered[chatFrame] then
		return true
	end
	if not typing then
		return false
	end
	return typing == chatFrame or (typing.isDocked and chatFrame.isDocked and true) or false
end

-- Blizzard's Opacity for the window (what it fades back to)
local function BlizzardAlpha(chatFrame)
	return chatFrame.oldAlpha or DEFAULT_CHATFRAME_ALPHA or 0.25
end

-- mouse away: a share of Blizzard's Opacity
local function RestAlpha(chatFrame)
	return BlizzardAlpha(chatFrame) * Get("bgAlpha")
end

-- mouse over: Blizzard's own (its Opacity, at least 25%)
local function HoverAlpha(chatFrame)
	return math.max(BlizzardAlpha(chatFrame), DEFAULT_CHATFRAME_ALPHA or 0.25)
end

local function BodyAlpha(chatFrame)
	return Active(chatFrame) and HoverAlpha(chatFrame) or RestAlpha(chatFrame)
end

local function PlaceBody(chatFrame)
	local skin = bodies[chatFrame]
	local bg = _G[chatFrame:GetName() .. "Background"]
	if skin and bg then
		skin:Place(bg, LAYOUT.soft.body, LAYOUT.bordered.body)
		skin:Show(Look())
	end
end

local function StyleBody(name)
	local frame = _G[name]
	if not frame or bodies[frame] then
		return
	end
	-- Blizzard's hover fade skips hidden textures
	for _, part in ipairs(BORDER) do
		local tex = _G[name .. part]
		if tex then
			tex:Hide()
		end
		local button = _G[name .. "ButtonFrame" .. part]
		if button then
			button:Hide()
		end
	end
	local buttonBg = _G[name .. "ButtonFrameBackground"]
	if buttonBg then
		buttonBg:Hide()
	end
	-- Blizzard's background stays where it is (the resize button hangs off
	-- it) but draws nothing. Ours is drawn around it in its colour; its
	-- opacity is Blizzard's Opacity, or ours with the mouse over.
	local bg = _G[name .. "Background"]
	if not bg then
		return
	end
	local skin = Skin.New(frame, "BACKGROUND", -8)
	bodies[frame] = skin
	skin:SetColor(bg:GetVertexColor())
	skin:SetBorderColor(1, 1, 1)
	skin.shown = bg:IsShown()
	PlaceBody(frame)
	skin:FadeTo(bg:GetAlpha(), 0)
	bg:SetTexture(nil)
	hooksecurefunc(bg, "SetVertexColor", function(_, r, g, b)
		skin:SetColor(r, g, b)
	end)
	hooksecurefunc(bg, "Show", function()
		skin:SetVisible(true)
	end)
	hooksecurefunc(bg, "Hide", function()
		skin:SetVisible(false)
	end)
end

local function FadeBody(chatFrame, duration)
	local skin = bodies[chatFrame]
	if skin then
		-- mouse over: the border at full, whatever the background is
		skin:FadeTo(BodyAlpha(chatFrame), duration or 0, Active(chatFrame) and 1 or nil)
	end
end

local function StyleCombatLog()
	local tex = _G.CombatLogQuickButtonFrame_CustomTexture
	-- the chat background already reaches over the filter bar, so its own
	-- dark strip goes
	if tex and not tex.setGoSpeak then
		tex.setGoSpeak = true
		tex:SetAlpha(0)
	end
end

--------------------------------------------------------------------------------
-- The typing box
--------------------------------------------------------------------------------

local EDIT_ART = { "Left", "Mid", "Right" }
local edits = {} -- [editBox] = skin

local function UpdateEdit(box)
	local skin = edits[box]
	if not skin then
		return
	end
	local focus = box.setGoFocus
	local alpha = LAYOUT[Look()].editBoxAlpha
	-- with the cursor in it: the border at full, whatever the fill is
	skin:FadeTo(focus and alpha.focus or alpha.rest, 0, focus and 1 or nil)
	if focus and box.setGoColor then
		local c = box.setGoColor
		skin:SetBorderColor(c[1], c[2], c[3])
	else
		local d = LAYOUT.dimBorder
		skin:SetBorderColor(d, d, d)
	end
end

local function PlaceEdit(box)
	local skin = edits[box]
	if skin then
		skin:Place(box, LAYOUT.soft.editBox, LAYOUT.bordered.editBox)
		skin:Show(Look())
	end
end

local function StyleEdit(name)
	local box = _G[name .. "EditBox"]
	if not box or edits[box] then
		return
	end
	-- Blizzard shows and hides its own art; it just can't be seen
	for _, part in ipairs(EDIT_ART) do
		local tex = _G[box:GetName() .. part]
		if tex then
			tex:SetAlpha(0)
		end
	end
	for _, key in ipairs({ "focusLeft", "focusMid", "focusRight" }) do
		if box[key] then
			box[key]:SetAlpha(0)
		end
	end
	local skin = Skin.New(box, "BACKGROUND", -8)
	edits[box] = skin
	skin:SetColor(0, 0, 0)
	PlaceEdit(box)

	-- focus: Blizzard shows its focus art, in the colour of the chat type
	-- at login Blizzard opens and closes the box once; with the classic chat
	-- style the focus art stays marked as shown on the hidden box, so only a
	-- box that is really open counts
	box.setGoFocus = (box:IsVisible() and box.focusLeft and box.focusLeft:IsShown()) and true or false
	if box.focusLeft then
		local r, g, b = box.focusLeft:GetVertexColor()
		box.setGoColor = { r or 1, g or 1, b or 1 }
	end
	if box.SetFocusRegionsShown then
		-- Blizzard shows its focus art when the box opens and hides it when
		-- the box closes; with the classic chat style it just hides the box
		local function Focus(shown)
			shown = shown and true or false
			if box.setGoFocus == shown then
				return
			end
			box.setGoFocus = shown
			UpdateEdit(box)
			-- the chat it types into is active while it has the cursor
			local frame = box.chatFrame or _G[(box:GetName():gsub("EditBox$", ""))]
			if shown then
				typing = frame
			elseif typing == frame then
				typing = nil
			end
			if Refresh then
				local duration = shown and (CHAT_FRAME_FADE_TIME or 0.15) or (CHAT_FRAME_FADE_OUT_TIME or 2)
				for _, name in ipairs(ChatNames()) do
					if _G[name] then
						Refresh(_G[name], duration)
					end
				end
			end
		end
		hooksecurefunc(box, "SetFocusRegionsShown", function(_, shown)
			Focus(shown)
		end)
		box:HookScript("OnHide", function()
			Focus(false)
		end)
	end
	if box.SetFocusRegionVertexColors then
		hooksecurefunc(box, "SetFocusRegionVertexColors", function(_, color)
			if color and color.r then
				local c = box.setGoColor or {}
				c[1], c[2], c[3] = color.r, color.g, color.b
				box.setGoColor = c
				UpdateEdit(box)
			end
		end)
	end
	UpdateEdit(box)
end

--------------------------------------------------------------------------------
-- Font
--------------------------------------------------------------------------------

local original = {} -- [fontInstance] = Blizzard's file, to go back to

local function SetFontOn(object)
	if not object or not object.GetFont then
		return
	end
	local file, size, flags = object:GetFont()
	if not size then
		return
	end
	if original[object] == nil then
		original[object] = file or false
	end
	local want = FontFile() or original[object]
	if want and want ~= file then
		object:SetFont(want, size, flags)
	end
end

local Tabs -- forward

local function ApplyFont(name)
	local frame = _G[name]
	if not frame then
		return
	end
	SetFontOn(frame)
	local box = _G[name .. "EditBox"]
	if box then
		SetFontOn(box)
		if box.header then
			SetFontOn(box.header)
		end
	end
	if Tabs then
		Tabs.Font(name)
	end
end

--------------------------------------------------------------------------------
-- Tabs: a frame of ours over each tab, with its name and its border
--------------------------------------------------------------------------------

local TAB_ART = { "Left", "Middle", "Right", "ActiveLeft", "ActiveMiddle", "ActiveRight",
	"HighlightLeft", "HighlightMiddle", "HighlightRight" }
local GLOW_FILE = "Interface\\ChatFrame\\ChatFrameTab-NewMessage"
local holder = CreateFrame("Frame", "SetGoSpeakTabNames", UIParent)
holder:SetAllPoints()
holder:SetFrameStrata("MEDIUM")
holder:SetFrameLevel(20)

local tabFont = CreateFont("SetGoSpeakTabFont")
local boxes = {} -- [tab] = our frame

local function Selected(chatFrame)
	if not chatFrame.isDocked then
		return true
	end
	return FCFDock_GetSelectedWindow and GENERAL_CHAT_DOCK and FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) == chatFrame
end

local function TabRestAlpha(chatFrame)
	return Selected(chatFrame) and Get("tabSelected") or Get("tabOther")
end

-- Blizzard keeps whisper names secret and gives those tabs a fixed width
local function SecretName(chatFrame)
	return chatFrame.chatTarget and (chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER")
end

Tabs = {}

function Tabs.Get(tab)
	local box = boxes[tab]
	if box then
		return box
	end
	local blizzard = tab.GetFontString and tab:GetFontString()
	if not blizzard then
		return nil
	end
	box = CreateFrame("Frame", nil, holder)
	box:SetFrameLevel(holder:GetFrameLevel() + 1)
	box:SetAllPoints(tab)
	NewFade(box)
	box.skin = Skin.New(box, "BACKGROUND", -8)
	box.skin:SetColor(0, 0, 0)
	box.skin:Place(box, nil, LAYOUT.bordered.tab)

	local label = box:CreateFontString(nil, "OVERLAY")
	label:SetFontObject(blizzard:GetFontObject() or GameFontNormalSmall)
	label:SetPoint("CENTER", blizzard, "CENTER")
	label:SetText(blizzard:GetText() or "")
	label:SetTextColor(blizzard:GetTextColor())
	box.label = label
	-- the flashing copy on top, while the tab has unread messages
	local flash = box:CreateFontString(nil, "OVERLAY")
	flash:SetFontObject(label:GetFontObject())
	flash:SetPoint("CENTER", label, "CENTER")
	flash:SetText(label:GetText())
	flash:SetTextColor(blizzard:GetTextColor())
	flash:Hide()
	local pulse = flash:CreateAnimationGroup()
	pulse:SetLooping("BOUNCE")
	local a = pulse:CreateAnimation("Alpha")
	a:SetFromAlpha(0)
	a:SetToAlpha(1)
	a:SetDuration(0.8)
	box.flash, box.pulse = flash, pulse
	boxes[tab] = box

	-- Blizzard's own name stays, invisible; ours follows it
	blizzard:SetAlpha(0)
	hooksecurefunc(blizzard, "SetText", function(_, text)
		label:SetText(text or "")
		flash:SetText(text or "")
	end)
	hooksecurefunc(blizzard, "SetTextColor", function(_, r, g, b)
		label:SetTextColor(r, g, b)
		flash:SetTextColor(r, g, b)
	end)
	tab:HookScript("OnShow", function()
		box:Show()
	end)
	tab:HookScript("OnHide", function()
		box:Hide()
		flash:Hide()
	end)
	box:SetShown(tab:IsShown())
	for _, key in ipairs(TAB_ART) do
		local tex = tab[key]
		if tex then
			tex:SetAlpha(0)
		end
	end
	return box
end

-- the tab's width, the way Blizzard sizes it
local function Resize(tab, chatFrame)
	if not PanelTemplates_TabResize or SecretName(chatFrame) then
		return
	end
	if chatFrame.isDocked then
		-- the dock sizes the temporary tabs (whispers) to share the room
		if chatFrame.isStaticDocked then
			PanelTemplates_TabResize(tab, tab.sizePadding or 0)
		end
	else
		PanelTemplates_TabResize(tab, tab.sizePadding or 0, nil, nil, nil, tab.textWidth)
	end
end

-- the text size goes on the tab itself, so Blizzard sizes the tab to fit
function Tabs.Size(name)
	local tab = _G[name .. "Tab"]
	local chatFrame = _G[name]
	if not (tab and chatFrame and tab.SetNormalFontObject) then
		return
	end
	local size = Get("tabSize")
	local font = GameFontNormalSmall
	if size ~= BlizzardTabSize() then
		font = tabFont
	end
	if tab:GetNormalFontObject() ~= font then
		tab:SetNormalFontObject(font)
		Resize(tab, chatFrame)
	end
end

function Tabs.Font(name)
	local tab = _G[name .. "Tab"]
	local box = tab and boxes[tab]
	local blizzard = tab and tab.GetFontString and tab:GetFontString()
	if not (box and blizzard) then
		return
	end
	local file, size, flags = blizzard:GetFont()
	local want = FontFile() or file
	if want and size then
		box.label:SetFont(want, size, flags)
		box.flash:SetFont(want, size, flags)
	end
end

function Tabs.SetupFont()
	local file, _, flags = GameFontNormalSmall:GetFont()
	tabFont:CopyFontObject(GameFontNormalSmall)
	tabFont:SetFont(file, Get("tabSize"), flags)
end

function Tabs.Update(chatFrame, duration)
	local tab = _G[chatFrame:GetName() .. "Tab"]
	local box = tab and Tabs.Get(tab)
	if not box then
		return
	end
	box.skin:Show(Look() == "bordered" and "bordered" or nil)
	local c = Selected(chatFrame) and 1 or LAYOUT.dimBorder
	box.skin:SetBorderColor(c, c, c)
	FadeTo(box, Active(chatFrame) and 1 or TabRestAlpha(chatFrame), duration or 0)
end

function Tabs.UpdateAll()
	for _, name in ipairs(ChatNames()) do
		local frame = _G[name]
		if frame then
			Tabs.Update(frame, 0)
		end
	end
end

function Tabs.Glow()
	for tab in pairs(boxes) do
		if tab.glow then
			tab.glow:SetTexture(Get("glow") and GLOW_FILE or nil)
		end
	end
end

local function Alert(chatFrame, on)
	local tab = _G[chatFrame:GetName() .. "Tab"]
	local box = tab and Tabs.Get(tab)
	if not box then
		return
	end
	if on then
		box.flash:Show()
		box.pulse:Play()
	else
		box.pulse:Stop()
		box.flash:Hide()
	end
end

--------------------------------------------------------------------------------
-- Buttons: the cog and its menu
--------------------------------------------------------------------------------

local COG = "common-dropdown-a-button-settings-%sshadowless"
local hidden = CreateFrame("Frame")
hidden:Hide()
local HIDE = { "ChatFrameChannelButton", "ChatFrameToggleVoiceDeafenButton", "ChatFrameToggleVoiceMuteButton",
	"QuickJoinToastButton", "TextToSpeechButtonFrame" }
local buttonsOn = false
local cog -- Blizzard's menu button, once it is ours

local function LeatrixHidesButtons()
	return type(LeaPlusDB) == "table" and LeaPlusDB.NoChatButtons == "On"
end

-- Blizzard puts some of these back on its own parent when the chat goes
-- full screen (the world map) and back
local function HideButtons()
	for _, name in ipairs(HIDE) do
		local b = _G[name]
		if b and not (b.IsProtected and b:IsProtected()) then
			b:SetParent(hidden)
		end
	end
end

local function PlaceCog()
	if not cog then
		return
	end
	local B = LAYOUT.button
	cog:ClearAllPoints()
	cog:SetSize(B.size, B.size)
	local bar = ChatFrame1.ScrollBar
	if bar then
		cog:SetPoint("BOTTOM", bar, "TOP", B.x, B.y)
	else
		cog:SetPoint("TOPLEFT", ChatFrame1, "TOPRIGHT", B.x, B.y)
	end
end

local function SetupButtons()
	if buttonsOn or not Get("buttons") or LeatrixHidesButtons() then
		return
	end
	local button = ChatFrameMenuButton
	if not (button and ChatFrame1 and HasAtlas(COG:format(""))) then
		return
	end
	buttonsOn = true
	cog = button
	cog:SetParent(ChatFrame1)
	-- top of the column: cog, then the scroll bar, then scroll to bottom
	local bar = ChatFrame1.ScrollBar
	if bar then
		local function Column(chatFrame)
			if chatFrame == ChatFrame1 then
				bar:SetPoint("TOPLEFT", ChatFrame1, "TOPRIGHT", 0, LAYOUT.scrollBarTop)
			end
		end
		Column(ChatFrame1)
		if FCF_UpdateScrollbarAnchors then
			hooksecurefunc("FCF_UpdateScrollbarAnchors", Column)
		end
	end
	PlaceCog()
	cog:SetNormalAtlas(COG:format(""))
	cog:SetPushedAtlas(COG:format("pressed-"))
	cog:SetHighlightAtlas(COG:format("hover-"), "BLEND")
	NewFade(cog)
	cog:SetAlpha(Active(ChatFrame1) and 1 or Get("buttonAlpha"))
	HideButtons()
	hooksecurefunc("FCF_SetFullScreenFrame", HideButtons)
	hooksecurefunc("FCF_ClearFullScreenFrame", HideButtons)

	if Menu and Menu.ModifyMenu then
		Menu.ModifyMenu("MENU_CHAT_SHORTCUTS", function(_, root)
			root:CreateDivider()
			root:CreateButton(L.MENU_CHANNELS, function()
				if ToggleChannelFrame then
					ToggleChannelFrame()
				end
			end)
			root:CreateButton(L.MENU_SOCIAL, function()
				if ToggleFriendsFrame then
					ToggleFriendsFrame()
				end
			end)
			if ToggleTextToSpeechFrame then
				root:CreateButton(L.MENU_TTS, function()
					ToggleTextToSpeechFrame()
				end)
			end
			local voice = C_VoiceChat
			if voice and voice.GetActiveChannelID and voice.GetActiveChannelID() then
				root:CreateCheckbox(L.MENU_MUTE, function()
					return voice.IsMuted()
				end, function()
					voice.ToggleMuted()
				end)
				root:CreateCheckbox(L.MENU_DEAFEN, function()
					return voice.IsDeafened()
				end, function()
					voice.ToggleDeafened()
				end)
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- Tab positions: Blizzard anchors the docked tabs through the dock (once, when
-- the main window is set) and a loose window's tab on its own. Both are
-- anchored again here with the look's LAYOUT tabs added, right after Blizzard does it.
--------------------------------------------------------------------------------

local tabsMoved = false -- once moved, a look at 0 puts them back

local function TabOffset()
	local T = LAYOUT[Look()].tabs or { x = 0, y = 0 }
	if T.x ~= 0 or T.y ~= 0 then
		tabsMoved = true
	end
	return T.x, T.y, tabsMoved
end

local function PlaceDock(dock)
	local primary = dock and dock.primary
	local bg = primary and primary.Background
	local x, y, moved = TabOffset()
	if not (bg and moved) then
		return
	end
	dock:SetPoint("BOTTOMLEFT", bg, "TOPLEFT", x, y)
	dock:SetPoint("BOTTOMRIGHT", bg, "TOPRIGHT", x, y)
end

local function PlaceLooseTab(chatFrame, offset)
	local tab = chatFrame and _G[chatFrame:GetName() .. "Tab"]
	local bg = chatFrame and _G[chatFrame:GetName() .. "Background"]
	local x, y, moved = TabOffset()
	if not (tab and bg and moved) then
		return
	end
	tab:ClearAllPoints()
	tab:SetPoint("BOTTOMLEFT", bg, "TOPLEFT", (offset or 0) + 2 + x, y)
end

-- all the tabs where the current look wants them
local function PlaceTabs()
	PlaceDock(GENERAL_CHAT_DOCK)
	for _, name in ipairs(ChatNames()) do
		local frame = _G[name]
		if frame and not frame.isDocked then
			PlaceLooseTab(frame, 0)
		end
	end
end

local function SetupTabPositions()
	PlaceTabs()
	if FCFDock_SetPrimary then
		hooksecurefunc("FCFDock_SetPrimary", PlaceDock)
	end
	if FCF_SetTabPosition then
		hooksecurefunc("FCF_SetTabPosition", PlaceLooseTab)
	end
end

--------------------------------------------------------------------------------
-- Following Blizzard's chat
--------------------------------------------------------------------------------

local function ApplySpacing(name)
	local frame = _G[name]
	if frame and frame.SetSpacing then
		frame:SetSpacing(Get("spacing"))
	end
end

local function SetupWindow(name)
	StyleBody(name)
	StyleEdit(name)
	local tab = _G[name .. "Tab"]
	if tab then
		Tabs.Get(tab)
		Tabs.Size(name)
	end
	ApplyFont(name)
	ApplySpacing(name)
end

-- the look changed: every skin shows the other textures
local function ApplyLook()
	for frame in pairs(bodies) do
		PlaceBody(frame)
	end
	for box in pairs(edits) do
		PlaceEdit(box)
		UpdateEdit(box)
	end
	Tabs.UpdateAll()
	PlaceTabs()
end

function Refresh(chatFrame, duration)
	FadeBody(chatFrame, duration)
	Tabs.Update(chatFrame, duration)
	if cog and chatFrame == ChatFrame1 then
		FadeTo(cog, Active(chatFrame) and 1 or Get("buttonAlpha"), duration)
	end
end

local function Hover(chatFrame, on, duration)
	if not chatFrame or not chatFrame.GetName then
		return
	end
	hovered[chatFrame] = on or nil
	Refresh(chatFrame, duration)
end

local started = false
local function Start()
	if started then
		return
	end
	started = true
	Tabs.SetupFont()
	for _, name in ipairs(ChatNames()) do
		SetupWindow(name)
	end
	StyleCombatLog()
	Tabs.Glow()
	Tabs.UpdateAll()
	SetupButtons()
	SetupTabPositions()

	hooksecurefunc("FCF_FadeInChatFrame", function(chatFrame)
		Hover(chatFrame, true, CHAT_FRAME_FADE_TIME or 0.15)
	end)
	hooksecurefunc("FCF_FadeOutChatFrame", function(chatFrame)
		Hover(chatFrame, false, CHAT_FRAME_FADE_OUT_TIME or 2)
	end)
	-- Blizzard's Opacity
	hooksecurefunc("FCF_SetWindowAlpha", function(chatFrame)
		FadeBody(chatFrame, 0)
	end)
	hooksecurefunc("FCF_StartAlertFlash", function(chatFrame)
		Alert(chatFrame, true)
	end)
	hooksecurefunc("FCF_StopAlertFlash", function(chatFrame)
		Alert(chatFrame, false)
	end)
	if FCFDock_SelectWindow then
		hooksecurefunc("FCFDock_SelectWindow", Tabs.UpdateAll)
	end
	hooksecurefunc("FCF_SetChatWindowFontSize", function(_, chatFrame)
		chatFrame = chatFrame or (FCF_GetCurrentChatFrame and FCF_GetCurrentChatFrame())
		if chatFrame then
			ApplyFont(chatFrame:GetName())
		end
	end)
	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, name in ipairs(ChatNames()) do
			SetupWindow(name)
		end
		Tabs.Glow()
		Tabs.UpdateAll()
	end)
end

--------------------------------------------------------------------------------
-- Page in SetGo!
--------------------------------------------------------------------------------

local function Formatted(minValue, maxValue, steps, format)
	local formatters
	if MinimalSliderWithSteppersMixin and MinimalSliderWithSteppersMixin.Label then
		formatters = { [MinimalSliderWithSteppersMixin.Label.Right] = format }
	end
	return { minValue = minValue, maxValue = maxValue, steps = steps, formatters = formatters }
end

local function Percent(value)
	return ("%d%%"):format(math.floor((tonumber(value) or 0) * 100 + 0.5))
end

local function Pixels(value)
	return ("%d px"):format(math.floor((tonumber(value) or 0) + 0.5))
end

local function Whole(value)
	return ("%d"):format(math.floor((tonumber(value) or 0) + 0.5))
end

local function EachWindow(fn)
	return function()
		for _, name in ipairs(ChatNames()) do
			fn(name)
		end
	end
end

local items
local function Items()
	if items then
		return items
	end
	local Pseudo = SetGo.Pseudo
	local function Setting(key, name, tip, apply)
		return Pseudo("SETGO_SPEAK_" .. key, name, tip, DEFAULTS[key], function()
			return Get(key)
		end, function(value)
			db[key] = value
			-- asleep (switched off in SetGo!): only the value is kept
			if apply and started then
				apply(value)
			end
		end)
	end
	local look = Setting("look", L.LOOK, L.LOOK_DESC, ApplyLook)
	local font = Setting("font", L.FONT, L.FONT_DESC, EachWindow(ApplyFont))
	local spacing = Setting("spacing", L.SPACING, L.SPACING_DESC, EachWindow(ApplySpacing))
	local bgAlpha = Setting("bgAlpha", L.BG_ALPHA, L.BG_ALPHA_DESC, function()
		for frame in pairs(bodies) do
			FadeBody(frame, 0)
		end
	end)
	local selected = Setting("tabSelected", L.TAB_SELECTED, L.TABS_NOTE, Tabs.UpdateAll)
	local other = Setting("tabOther", L.TAB_OTHER, L.TABS_NOTE, Tabs.UpdateAll)
	local tabSize = Setting("tabSize", L.TAB_SIZE, L.TAB_SIZE_DESC, function()
		Tabs.SetupFont()
		for _, name in ipairs(ChatNames()) do
			local tab = _G[name .. "Tab"]
			if tab and tab.SetNormalFontObject then
				-- the font object changed under the tab: set it again
				tab:SetNormalFontObject(GameFontNormalSmall)
			end
			Tabs.Size(name)
			if tab and _G[name] then
				Resize(tab, _G[name])
			end
			Tabs.Font(name)
		end
	end)
	local glow = Setting("glow", L.GLOW, L.GLOW_DESC, Tabs.Glow)
	local buttons = Setting("buttons", L.BUTTONS, L.BUTTONS_DESC, function(on)
		if on then
			SetupButtons()
		elseif buttonsOn then
			StaticPopup_Show("SETGO_CONFIRM", L.POPUP_RELOAD, nil, { onAccept = ReloadUI })
		end
	end)
	local buttonAlpha = Setting("buttonAlpha", L.BUTTON_ALPHA, L.BUTTON_ALPHA_DESC, function()
		if cog and not Active(ChatFrame1) then
			FadeTo(cog, Get("buttonAlpha"), 0)
		end
	end)
	local function LookOptions()
		return { { value = "soft", label = L.LOOK_SOFT }, { value = "bordered", label = L.LOOK_BORDERED } }
	end
	local function FontOptions()
		local list = {}
		for _, f in ipairs(FONTS) do
			list[#list + 1] = { value = f.value, label = f.label }
		end
		list[#list + 1] = { value = "BLIZZARD", label = L.FONT_BLIZZARD }
		return list
	end
	local alpha = Formatted(0, 1, 20, Percent)
	items = {
		{ kind = "header", name = L.SEC_LOOK },
		{ kind = "dropdown", setting = look, settings = { look }, name = L.LOOK, tooltip = L.LOOK_DESC, options = LookOptions },
		{ kind = "dropdown", setting = font, settings = { font }, name = L.FONT, tooltip = L.FONT_DESC, options = FontOptions },
		{ kind = "slider", setting = spacing, settings = { spacing }, name = L.SPACING, tooltip = L.SPACING_DESC, options = Formatted(0, 10, 10, Pixels) },
		{ kind = "header", name = L.SEC_BACKGROUND },
		{ kind = "slider", setting = bgAlpha, settings = { bgAlpha }, name = L.BG_ALPHA, tooltip = L.BG_ALPHA_DESC, options = alpha },
		{ kind = "note", name = L.BG_NOTE },
		{ kind = "header", name = L.SEC_TABS },
		{ kind = "note", name = L.TABS_NOTE },
		{ kind = "slider", setting = selected, settings = { selected }, name = L.TAB_SELECTED, tooltip = L.TABS_NOTE, options = alpha },
		{ kind = "slider", setting = other, settings = { other }, name = L.TAB_OTHER, tooltip = L.TABS_NOTE, options = alpha },
		{ kind = "slider", setting = tabSize, settings = { tabSize }, name = L.TAB_SIZE, tooltip = L.TAB_SIZE_DESC, options = Formatted(8, 18, 10, Whole) },
		{ kind = "checkbox", setting = glow, settings = { glow }, name = L.GLOW, tooltip = L.GLOW_DESC },
		{ kind = "header", name = L.SEC_BUTTONS },
		{ kind = "checkbox", setting = buttons, settings = { buttons }, name = L.BUTTONS, tooltip = L.BUTTONS_DESC },
		{ kind = "slider", setting = buttonAlpha, settings = { buttonAlpha }, name = L.BUTTON_ALPHA, tooltip = L.BUTTON_ALPHA_DESC, options = alpha },
	}
	if LeatrixHidesButtons() then
		items[#items + 1] = { kind = "note", name = L.LEATRIX }
	end
	return items
end

--------------------------------------------------------------------------------
-- Loading
--------------------------------------------------------------------------------

local function OldChatLoaded()
	return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("SetGo_Chat")
end

-- the old module still here: take its settings once and stay off, so the two
-- never style the chat at the same time (it owns the SetGo! page meanwhile).
-- It loads before this one (the AddOns load in name order).
local oldChat = false

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == ADDON then
			SetGoSpeakDB = type(SetGoSpeakDB) == "table" and SetGoSpeakDB or {}
			db = SetGoSpeakDB
			-- the Bordered look was first called Tooltip
			if db.look == "tooltip" then
				db.look = "bordered"
			end
			if not db.copied and type(SetGoChatDB) == "table" then
				for k, v in pairs(SetGoChatDB) do
					if db[k] == nil then
						db[k] = v
					end
				end
				-- the old cog followed the selected tab
				if db.buttonAlpha == nil and SetGoChatDB.tabSelected ~= nil then
					db.buttonAlpha = SetGoChatDB.tabSelected
				end
				db.copied = true
			end
			oldChat = OldChatLoaded() and true or false
			if not oldChat then
				SetGo.RegisterModule({ key = KEY, title = L.TITLE, items = Items })
			end
		elseif arg1 == "Blizzard_CombatLog" and started then
			StyleCombatLog()
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		if oldChat then
			if not events.warned then
				events.warned = true
				print(L.OLD_CHAT)
			end
			return
		end
		-- switched off in SetGo!: only the settings page is here
		if not SetGo.ModuleOn(KEY) then
			return
		end
		-- after Blizzard has set up the chat windows
		C_Timer.After(0, Start)
	end
end)
