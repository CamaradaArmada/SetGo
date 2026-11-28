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
	CHANNELS = "Chat Board",
	TAB_NEW = "Tab %d",
	TAB_CREATE = "Create New",
	TAB_HISTORY = "Keep history",
	SIDE_CHANNELS = "Channels",
	MENU_PIN = "When pinned",
	PIN_FADE = "Messages fade after",
	PIN_SECS = "%d seconds",
	PIN_NEVER = "Never",
	PIN_SOUND = "Alert sound",
	PIN_SOUND_NONE = "None",
	PIN_SOUND_WHISPER = "Whisper",
	PIN_SOUND_RAID = "Raid warning",
	PIN_SOUND_READY = "Ready check",
	PIN_FLASH = "Flash the game's icon on the task bar",
	SIDE_WHISPERS = "Whispers",
	NO_WHISPERS = "No whispers yet.",
	CONV_TO = "To %s",
	CONV_FAV = "Keep (favourite)",
	CONV_UNFAV = "Stop keeping",
	CONV_CLOSE = "Close",
	NOWHERE = "Nowhere to write",
	MENU_SETTINGS = "Speak! settings",
	DOT_DESC = "Choose where the box writes: the channels and chats this tab shows. Enter sends; a line starting with / goes to the chat as a command.",
	HEAD_TIP = "Write in",
	MENU_HIDE = "Hide from the main chat",
	HIDE_NONE = "No addon has written in the chat this session.",
	PRINT_COMMANDS = "Commands (/dump, /run)",
	PIN = "Pin this tab",
	UNPIN = "Unpin this tab",
	PIN_HIDE = "Hide the window",
	PIN_SHOW = "Show the window",
	PIN_OPACITY = "Background opacity",
	PIN_LOCK = "Lock the window",
	PIN_CLOSE = "Close (unpins the tab)",
	PIN_JUSTIFY = "Text alignment",
	PIN_LEFT = "Left",
	PIN_CENTER = "Centre",
	PIN_RIGHT = "Right",
	PIN_DESC = "With the Board closed, this tab stays on screen where the window is: only its new messages, over the game, each fading after a while (the cog, When pinned, sets the time, a sound and the task bar flash). Drag it anywhere; the grip at its bottom right resizes it; its cog, top right with the mouse over it, sets the background opacity and the text alignment and locks it; the eye at its bottom left (struck through while shown) hides it and shows it again. One tab at a time: pinning another unpins this one.",
	CHANNELS_OFF = "Speak!: the Chat Board is switched off. Switch it on in Speak!'s page in SetGo!.",
	SET_CHANNELS = "Chat Board",
	SET_CHANNELS_DESC = "Keeps the messages for the Chat Board and shows it in the settings button's menu and on its key. Off, nothing is kept.",
	SET_FONT = "Chat Board text size",
	SET_FONT_DESC = "The size of the messages in the Chat Board and in a pinned tab. The font is the chat's.",
	TAB_RENAME = "Rename...",
	NAME_PROMPT = "Name of the tab:",
	COG_TIP = "What this tab shows",
	COG_TIP_DESC = "Its channels and the kinds of message. A right click on the main tab makes a new tab; drag a tab to move it.",
	EMPTY_PICK = "This tab shows nothing yet. Choose its channels and messages in the cog, top right.",
	NO_MENU = "Speak!: this game client has no menus for this.",
	MENU_CHANNELS = "Channels",
	ALL_CHANNELS = "All channels",
	MENU_GAME = "Game messages",
	MENU_PLAYERS = "Player chat",
	KIND_SYSTEM = "System",
	KIND_PRINT = "Commands and addons",
	KIND_LOOT = "Loot",
	KIND_MONEY = "Money",
	KIND_CURRENCY = "Currency",
	KIND_COMBAT_XP_GAIN = "Experience",
	KIND_COMBAT_HONOR_GAIN = "Honor",
	KIND_COMBAT_FACTION_CHANGE = "Reputation",
	KIND_SKILL = "Skill ups",
	KIND_TRADESKILLS = "Crafting",
	KIND_OPENING = "Opening",
	KIND_ACHIEVEMENT = "Achievements",
	KIND_GUILD_ACHIEVEMENT = "Guild achievements",
	KIND_PET_INFO = "Pet info",
	KIND_BG = "Battlegrounds",
	KIND_MONSTER = "Creatures",
	KIND_SAY = "Say",
	KIND_YELL = "Yell",
	KIND_EMOTE = "Emote",
	KIND_PARTY = "Party",
	KIND_RAID = "Raid",
	KIND_INSTANCE_CHAT = "Instance",
	KIND_GUILD = "Guild",
	KIND_OFFICER = "Officer",
	KIND_WHISPER = "Whispers",
	KIND_BN_WHISPER = "Battle.net",
	TAB_DELETE = "Delete",
	FILTER = "Filter",
	EMPTY = "No messages here yet.",
	SELECT_ALL = "All",
	SELECT_NONE = "None",
	COPY_N = "Copy (%d)",
	BACK = "Back",
	COPY_HINT = "Ctrl+C to copy, Esc to go back.",
	BINDING = "Open or close the Chat Board",
	SEC_CHANNELS = "Chat Board",
	CHANNELS_NOTE = "The Chat Board: a window for everything that isn\'t players talking to you: the public channels, system messages, loot, the output of commands and addons, and more. Speak! keeps them even when you take them out of the chat windows in Blizzard\'s menu, so the chat can stay for talking. Tabs work as in the chat (a right click on the main tab makes a new one, a right click renames); the cog in the window picks what each shows. Tick messages (or drag over them) to copy them; write in the box under it.",
	KEY = "Key",
	KEY_DESC = "Opens or closes the Chat Board. It is also in the menu of the settings button. While it is open, the chat's Enter key writes in its box.",
	OFF_IN_SETGO = "Speak! is switched off for this character. Switch it on in SetGo!, Modules.",
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
	L.CHANNELS = "Quadro"
	L.TAB_NEW = "Separador %d"
	L.TAB_CREATE = "Criar novo"
	L.TAB_HISTORY = "Guardar histórico"
	L.SIDE_CHANNELS = "Canais"
	L.MENU_PIN = "Quando fixado"
	L.PIN_FADE = "As mensagens desaparecem após"
	L.PIN_SECS = "%d segundos"
	L.PIN_NEVER = "Nunca"
	L.PIN_SOUND = "Som de alerta"
	L.PIN_SOUND_NONE = "Nenhum"
	L.PIN_SOUND_WHISPER = "Sussurro"
	L.PIN_SOUND_RAID = "Aviso de raide"
	L.PIN_SOUND_READY = "Ready check"
	L.PIN_FLASH = "Piscar o ícone do jogo na barra de tarefas"
	L.SIDE_WHISPERS = "Sussurros"
	L.NO_WHISPERS = "Ainda não há sussurros."
	L.CONV_TO = "Para %s"
	L.CONV_FAV = "Guardar (favorito)"
	L.CONV_UNFAV = "Deixar de guardar"
	L.CONV_CLOSE = "Fechar"
	L.NOWHERE = "Sem onde escrever"
	L.MENU_SETTINGS = "Definições do Speak!"
	L.DOT_DESC = "Escolhe onde a caixa escreve: os canais e as conversas que este separador mostra. Enter envia; uma linha começada por / vai para o chat como comando."
	L.HEAD_TIP = "Escrever em"
	L.MENU_HIDE = "Esconder do chat principal"
	L.HIDE_NONE = "Nenhum addon escreveu no chat nesta sessão."
	L.PRINT_COMMANDS = "Comandos (/dump, /run)"
	L.PIN = "Fixar este separador"
	L.UNPIN = "Soltar este separador"
	L.PIN_HIDE = "Esconder a janela"
	L.PIN_SHOW = "Mostrar a janela"
	L.PIN_OPACITY = "Opacidade do fundo"
	L.PIN_LOCK = "Trancar a janela"
	L.PIN_CLOSE = "Fechar (solta o separador)"
	L.PIN_JUSTIFY = "Alinhamento do texto"
	L.PIN_LEFT = "À esquerda"
	L.PIN_CENTER = "Ao centro"
	L.PIN_RIGHT = "À direita"
	L.PIN_DESC = "Com o Quadro fechado, este separador fica no ecrã onde a janela está: só as mensagens novas, por cima do jogo, cada uma a desaparecer passado um tempo (o cog, Quando fixado, escolhe o tempo, um som e o piscar na barra de tarefas). Arrasta-o para onde quiseres; a pega no canto de baixo à direita muda o tamanho; o cog, em cima à direita com o rato por cima, escolhe a opacidade do fundo e o alinhamento do texto e tranca-o; o olho no canto de baixo à esquerda (riscado enquanto se vê) esconde-o e volta a mostrá-lo. Um separador de cada vez: fixar outro solta este."
	L.CHANNELS_OFF = "Speak!: o Quadro está desligado. Liga-o na página do Speak!, no SetGo!."
	L.SET_CHANNELS = "Quadro"
	L.SET_CHANNELS_DESC = "Guarda as mensagens para o Quadro e mostra-o no menu do botão de definições e na sua tecla. Desligado, não guarda nada."
	L.SET_FONT = "Tamanho da letra do Quadro"
	L.SET_FONT_DESC = "O tamanho das mensagens no Quadro e num separador fixado. A fonte é a do chat."
	L.TAB_RENAME = "Renomear..."
	L.NAME_PROMPT = "Nome do separador:"
	L.COG_TIP = "O que este separador mostra"
	L.COG_TIP_DESC = "Os canais e os tipos de mensagem. O clique direito no separador principal cria um separador novo; arrasta um separador para o mudar de sítio."
	L.EMPTY_PICK = "Este separador ainda não mostra nada. Escolhe os canais e as mensagens no cog, em cima à direita."
	L.NO_MENU = "Speak!: este cliente do jogo não tem menus para isto."
	L.MENU_CHANNELS = "Canais"
	L.ALL_CHANNELS = "Todos os canais"
	L.MENU_GAME = "Mensagens do jogo"
	L.MENU_PLAYERS = "Conversas de jogadores"
	L.KIND_SYSTEM = "Sistema"
	L.KIND_PRINT = "Comandos e addons"
	L.KIND_LOOT = "Saque"
	L.KIND_MONEY = "Dinheiro"
	L.KIND_CURRENCY = "Moedas"
	L.KIND_COMBAT_XP_GAIN = "Experiência"
	L.KIND_COMBAT_HONOR_GAIN = "Honra"
	L.KIND_COMBAT_FACTION_CHANGE = "Reputação"
	L.KIND_SKILL = "Perícias"
	L.KIND_TRADESKILLS = "Profissões"
	L.KIND_OPENING = "Abrir"
	L.KIND_ACHIEVEMENT = "Conquistas"
	L.KIND_GUILD_ACHIEVEMENT = "Conquistas da guilda"
	L.KIND_PET_INFO = "Animais"
	L.KIND_BG = "Campos de batalha"
	L.KIND_MONSTER = "Criaturas"
	L.KIND_SAY = "Dizer"
	L.KIND_YELL = "Gritar"
	L.KIND_EMOTE = "Emote"
	L.KIND_PARTY = "Grupo"
	L.KIND_RAID = "Raide"
	L.KIND_INSTANCE_CHAT = "Instância"
	L.KIND_GUILD = "Guilda"
	L.KIND_OFFICER = "Oficial"
	L.KIND_WHISPER = "Sussurros"
	L.KIND_BN_WHISPER = "Battle.net"
	L.TAB_DELETE = "Apagar"
	L.FILTER = "Filtro"
	L.EMPTY = "Ainda não há mensagens aqui."
	L.SELECT_ALL = "Todas"
	L.SELECT_NONE = "Nenhuma"
	L.COPY_N = "Copiar (%d)"
	L.BACK = "Voltar"
	L.COPY_HINT = "Ctrl+C para copiar, Esc para voltar."
	L.BINDING = "Abrir ou fechar o Quadro"
	L.SEC_CHANNELS = "Quadro"
	L.CHANNELS_NOTE = "O Quadro: uma janela para tudo o que não são jogadores a falar contigo: os canais públicos, as mensagens de sistema, o saque, o que os comandos e os addons escrevem, e mais. O Speak! guarda-os mesmo quando os tiras das janelas de chat no menu da Blizzard, para o chat ficar para as conversas. Os separadores funcionam como no chat (o clique direito no separador principal cria um novo, o clique direito muda o nome); o cog na janela escolhe o que cada um mostra. Marca mensagens (ou arrasta por cima delas) para as copiar; escreve na caixa por baixo dela."
	L.KEY = "Tecla"
	L.KEY_DESC = "Abre ou fecha o Quadro. Também está no menu do botão de definições. Enquanto está aberto, a tecla Enter do chat escreve na caixa dele."
	L.OFF_IN_SETGO = "O Speak! está desligado nesta personagem. Liga-o no SetGo!, Módulos."
	L.POPUP_RELOAD = "Recarregar a interface para repor os botões do chat da Blizzard?"
	L.OLD_CHAT = "SetGo! Speak!: o antigo SetGo_Chat ainda está instalado. As definições dele foram copiadas. Apaga a pasta SetGo_Chat e recarrega; até lá o Speak! fica desligado."
end

BINDING_HEADER_SETGO = BINDING_HEADER_SETGO or "SetGo!"
BINDING_NAME_SETGO_SPEAK_CHANNELS = L.BINDING

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
--   Channels: a big window with the public channels, kept by Speak! even
--     when they are out of the chat windows. In the cog's menu and on a key.
-- SetGoSpeakDB: look, font, spacing, bgAlpha, tabSelected, tabOther,
--   tabSize, glow, buttons, buttonAlpha
-- SetGoSpeakCharDB: history (the Channels window's messages)
-- SetGoSpeakDB.tabs: the Channels window's tabs
--------------------------------------------------------------------------------

-- the module's switch in SetGo! (kept from SetGo_Chat, so profiles still work)
local KEY = "chat"
local OpenSettings -- forward: Speak!'s page, from the chat's menu

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
	look = "bordered", font = "BLIZZARD", spacing = 0, bgAlpha = 0.5,
	tabSelected = 0.5, tabOther = 0.25, tabSize = 12, glow = true,
	buttons = true, buttonAlpha = 0.5, channels = true, channelsFont = 14,
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
-- Channels: a window for everything that isn't players talking to the
-- player: the public channels, system messages, loot, money, the output of
-- commands and addons, and the rest. The chat windows stay for talking.
--   Speak! keeps every message of these kinds it hears, also the ones taken
--   out of the chat windows in Blizzard's menu. Nothing polls: each message
--   arrives as an event (or, for commands and addons, as a line written to
--   the main chat window outside an event) and goes into a list with a
--   maximum size. The last ones go to the character's saved variables.
--   Tabs are the player's (SetGoSpeakDB.tabs), as in the chat: a right click
--   on the main tab makes a new one; the cog picks what each shows.
--   A search, and a box per message to copy the ones ticked (click,
--   Shift+click or drag). Addons can't write to the clipboard: they open as
--   text, already selected, for Ctrl+C.
-- SetGoSpeakCharDB.history: the messages kept between sessions
--------------------------------------------------------------------------------

local Channels = {}
-- everything else of the Board stays inside this block (Lua allows only so
-- many locals in one file's main body)
do
local ICON = "Interface\\Icons\\ui_chat" -- the module's icon, as in its .toc
local KEEP_SESSION = 500 -- per kind (or channel) while playing
local KEEP_SAVED = 100 -- per kind (or channel) between sessions
local KEEP_AGE = 3600 -- older than this (seconds) is dropped at login

-- the kinds of message, in the cog's order, with their chat events. The
-- game's go in a new main tab; the players' are there to choose.
local GAME = {
	{ key = "SYSTEM", events = { "CHAT_MSG_SYSTEM" } },
	{ key = "PRINT" }, -- commands and addons: lines written to the chat
	{ key = "LOOT", events = { "CHAT_MSG_LOOT" } },
	{ key = "MONEY", events = { "CHAT_MSG_MONEY" } },
	{ key = "CURRENCY", events = { "CHAT_MSG_CURRENCY" } },
	{ key = "COMBAT_XP_GAIN", events = { "CHAT_MSG_COMBAT_XP_GAIN" } },
	{ key = "COMBAT_HONOR_GAIN", events = { "CHAT_MSG_COMBAT_HONOR_GAIN" } },
	{ key = "COMBAT_FACTION_CHANGE", events = { "CHAT_MSG_COMBAT_FACTION_CHANGE" } },
	{ key = "SKILL", events = { "CHAT_MSG_SKILL" } },
	{ key = "TRADESKILLS", events = { "CHAT_MSG_TRADESKILLS" } },
	{ key = "OPENING", events = { "CHAT_MSG_OPENING" } },
	{ key = "ACHIEVEMENT", events = { "CHAT_MSG_ACHIEVEMENT" } },
	{ key = "GUILD_ACHIEVEMENT", events = { "CHAT_MSG_GUILD_ACHIEVEMENT" } },
	{ key = "PET_INFO", events = { "CHAT_MSG_PET_INFO" } },
	{ key = "BG", events = { "CHAT_MSG_BG_SYSTEM_HORDE", "CHAT_MSG_BG_SYSTEM_ALLIANCE", "CHAT_MSG_BG_SYSTEM_NEUTRAL" } },
	{ key = "MONSTER", events = { "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_EMOTE",
		"CHAT_MSG_MONSTER_WHISPER", "CHAT_MSG_RAID_BOSS_EMOTE", "CHAT_MSG_RAID_BOSS_WHISPER" } },
}
local PLAYERS = {
	{ key = "SAY", events = { "CHAT_MSG_SAY" } },
	{ key = "YELL", events = { "CHAT_MSG_YELL" } },
	{ key = "EMOTE", events = { "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE" } },
	{ key = "PARTY", events = { "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER" } },
	{ key = "RAID", events = { "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING" } },
	{ key = "INSTANCE_CHAT", events = { "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER" } },
	{ key = "GUILD", events = { "CHAT_MSG_GUILD" } },
	{ key = "OFFICER", events = { "CHAT_MSG_OFFICER" } },
	{ key = "WHISPER", events = { "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM" } },
	{ key = "BN_WHISPER", events = { "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM" } },
}
local GROUP_OF = {} -- [event] = kind
for _, list in ipairs({ GAME, PLAYERS }) do
	for _, g in ipairs(list) do
		for _, event in ipairs(g.events or {}) do
			GROUP_OF[event] = g.key
		end
	end
end
-- the player types: a name to click and the class colour
local SPOKEN = {
	SAY = true, YELL = true, EMOTE = true, PARTY = true, PARTY_LEADER = true, RAID = true, RAID_LEADER = true,
	RAID_WARNING = true, INSTANCE_CHAT = true, INSTANCE_CHAT_LEADER = true, GUILD = true, OFFICER = true,
	WHISPER = true, WHISPER_INFORM = true, CHANNEL = true, ACHIEVEMENT = true, GUILD_ACHIEVEMENT = true,
}
-- the game leaves a %s in the line for the name
local NAMED = {
	ACHIEVEMENT = true, GUILD_ACHIEVEMENT = true, MONSTER_EMOTE = true, RAID_BOSS_EMOTE = true,
	RAID_BOSS_WHISPER = true,
}
-- the game writes the whole line itself: no "Name says:" in front
local WHOLE = {
	SYSTEM = true, LOOT = true, MONEY = true, CURRENCY = true, COMBAT_XP_GAIN = true, COMBAT_HONOR_GAIN = true,
	COMBAT_FACTION_CHANGE = true, SKILL = true, TRADESKILLS = true, OPENING = true, PET_INFO = true,
	BG_SYSTEM_HORDE = true, BG_SYSTEM_ALLIANCE = true, BG_SYSTEM_NEUTRAL = true, TEXT_EMOTE = true, PRINT = true,
}

local history = {} -- [source] = { entries, oldest first }; a source is a kind or "C:<channel>"
local everything = {} -- every entry, oldest first
local order = {} -- channel names, in the order they were first heard
local seq = 0

-- whispers: one conversation per person ("with": the name, or "BN:" and the
-- Battle.net id). Favourites (not Battle.net: its ids change between
-- sessions) keep their messages; the others go at logout.
local convs = {} -- [with] = { with, name, short, class, bn, fav, unread, at, closed }
local function Conversation(with, name, class, bn)
	local c = convs[with]
	if not c then
		c = { with = with }
		convs[with] = c
	end
	if name and name ~= "" then
		c.name = name
		c.short = (not bn and Ambiguate) and Ambiguate(name, "short") or name
	end
	c.class = class or c.class
	c.bn = bn or c.bn
	c.closed = nil
	return c
end

local function Plain(text)
	text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
	text = text:gsub("|cn[^:|]*:", "")
	text = text:gsub("|r", "")
	text = text:gsub("|H.-|h(.-)|h", "%1")
	text = text:gsub("|T.-|t", "")
	text = text:gsub("|A.-|a", "")
	text = text:gsub("|K.-|k", "?")
	text = text:gsub("|n", " ")
	text = text:gsub("||", "|")
	return text
end

local function Hex(r, g, b)
	return ("%02x%02x%02x"):format((r or 1) * 255, (g or 1) * 255, (b or 1) * 255)
end

local function ClassHex(class)
	local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
	if c then
		return Hex(c.r, c.g, c.b)
	end
end

local function AddChannel(name)
	for _, n in ipairs(order) do
		if n == name then
			return
		end
	end
	order[#order + 1] = name
end

local function Remove(list, entry)
	for i = 1, #list do
		if list[i] == entry then
			table.remove(list, i)
			return i
		end
	end
end

-- the zone channels come as "General - Elwynn Forest": one name for every
-- zone ("General"). The player's own channels can't have spaces, so " - "
-- is only ever a zone.
local function ChannelKey(name)
	return name:match("^(.-) %- ") or name
end

-- forward: the window, when it is open, takes the new message
local OnNew
local Alert -- forward: the pinned tab's sound

local function Add(entry, live)
	seq = seq + 1
	entry.seq = seq
	if entry.chan then
		AddChannel(entry.chan)
	end
	local list = history[entry.src]
	if not list then
		list = {}
		history[entry.src] = list
	end
	list[#list + 1] = entry
	everything[#everything + 1] = entry
	local dropped
	if #list > KEEP_SESSION then
		dropped = table.remove(list, 1)
		Remove(everything, dropped)
	end
	if live and OnNew then
		OnNew(entry, dropped)
	end
end

local function Secret(...)
	local secret = issecretvalue
	if not secret then
		return false
	end
	for i = 1, select("#", ...) do
		if secret((select(i, ...))) then
			return true
		end
	end
	return false
end

local function ClassOf(guid)
	if guid and guid ~= "" and GetPlayerInfoByGUID then
		local _, class = GetPlayerInfoByGUID(guid)
		return class
	end
end

local function Colour(kind)
	local info = ChatTypeInfo and ChatTypeInfo[kind]
	if info then
		return info.r, info.g, info.b
	end
	return 1, 1, 1
end

local function OnChannelMessage(text, author, _, _, _, _, _, index, base, _, _, guid)
	if type(text) ~= "string" or Secret(text, author, base) then
		return
	end
	if author and C_FriendList and C_FriendList.IsIgnored and C_FriendList.IsIgnored(author) then
		return
	end
	local chan = ChannelKey((base and base ~= "") and base or ("#" .. (index or "?")))
	local r, g, b = Colour("CHANNEL" .. (index or ""))
	Add({
		t = time(), text = text, author = author or "", class = ClassOf(guid), kind = "CHANNEL",
		src = "C:" .. chan, chan = chan, index = index, r = r, g = g, b = b,
	}, true)
end

local function OnMessage(event, text, author, _, _, _, _, _, _, _, _, _, guid, bnID)
	local group = GROUP_OF[event]
	if not group or type(text) ~= "string" or Secret(text, author) then
		return
	end
	local kind = event:sub(10)
	if SPOKEN[kind] and author and author ~= "" and C_FriendList and C_FriendList.IsIgnored
		and C_FriendList.IsIgnored(author) then
		return
	end
	local r, g, b = Colour(kind)
	local entry = {
		t = time(), text = text, author = type(author) == "string" and author or "", class = SPOKEN[kind] and ClassOf(guid) or nil,
		kind = kind, src = group, r = r, g = g, b = b,
	}
	-- a whisper, to or from someone: their conversation
	local conv
	if group == "WHISPER" or group == "BN_WHISPER" then
		local bn = group == "BN_WHISPER" and type(bnID) == "number" and bnID or nil
		local with = bn and ("BN:" .. bn) or entry.author
		if with ~= "" then
			conv = Conversation(with, entry.author, entry.class, bn)
			conv.at = time()
			if kind == "WHISPER" or kind == "BN_WHISPER" then
				conv.unread = true
			end
			entry.with = with
		end
	end
	Add(entry, true)
	if conv and Channels.Heard then
		Channels.Heard(conv)
	end
end

-- a line written to the main chat window outside a chat event: print, /dump
-- and the like (the chat's own lines come with their type's id). Which
-- addon wrote it is read from the call stack: the first addon that isn't
-- Blizzard's; none (the game's /dump, a /run) is the player's commands.
local COMMANDS = "\001commands"
local printers = {} -- [source] = true, the ones that wrote this session

local function PrintSource()
	local stack = debugstack and debugstack(2, 30, 0) or ""
	for addon in stack:gmatch("AddOns[/\\]([^/\\]+)[/\\]") do
		if addon ~= ADDON and not addon:find("^Blizzard_") then
			return addon
		end
	end
	return COMMANDS
end

local function Printed(text, r, g, b)
	if not Channels.on or type(text) ~= "string" or Secret(text) or text == "" then
		return
	end
	local ok, from = pcall(PrintSource)
	from = ok and from or COMMANDS
	printers[from] = true
	Add({ t = time(), text = text, author = "", kind = "PRINT", src = "PRINT", r = r or 1, g = g or 1, b = b or 1 }, true)
	return from
end

local function OnPrint(_, text, r, g, b, id)
	if id == nil then
		Printed(text, r, g, b)
	end
end

-- hiding an addon's lines from the main chat: its AddMessage goes through
-- Speak! first, only once the player hides one (the lines still come here)
local wrapped = false
local function Hidden(from)
	return type(db.hidePrint) == "table" and db.hidePrint[from] and true or false
end

local function WrapChat()
	local frame = DEFAULT_CHAT_FRAME or ChatFrame1
	if wrapped or not (frame and frame.AddMessage) then
		return
	end
	wrapped = true
	local original = frame.AddMessage
	frame.AddMessage = function(self, text, r, g, b, id, ...)
		if id == nil and Channels.on and type(text) == "string" and not Secret(text) then
			local ok, from = pcall(PrintSource)
			if ok and Hidden(from) then
				printers[from] = true
				Add({ t = time(), text = text, author = "", kind = "PRINT", src = "PRINT", r = r or 1, g = g or 1, b = b or 1 }, true)
				return
			end
		end
		return original(self, text, r, g, b, id, ...)
	end
end

-- the messages kept from the last session, the old ones left out
local function Load(saved)
	if type(saved) ~= "table" then
		return
	end
	local now = time()
	local all = {}
	for _, list in pairs(saved) do
		if type(list) == "table" then
			for _, e in ipairs(list) do
				if type(e) == "table" and type(e.text) == "string" and type(e.t) == "number" and now - e.t <= KEEP_AGE then
					-- kept before the other kinds: a channel
					if not e.src then
						e.chan = ChannelKey(type(e.chan) == "string" and e.chan or "?")
						e.src, e.kind = "C:" .. e.chan, "CHANNEL"
					end
					all[#all + 1] = e
				end
			end
		end
	end
	table.sort(all, function(a, b)
		if a.t ~= b.t then
			return a.t < b.t
		end
		return (a.seq or 0) < (b.seq or 0)
	end)
	for _, e in ipairs(all) do
		Add(e, false)
	end
end

local function Save(wanted)
	local out = {}
	for src, list in pairs(history) do
		local first = math.max(1, #list - KEEP_SAVED + 1)
		local keep = {}
		for i = first, #list do
			local e = list[i]
			keep[#keep + 1] = (not wanted or wanted(e)) and {
				t = e.t, seq = e.seq, text = e.text, author = e.author, class = e.class, kind = e.kind,
				src = e.src, chan = e.chan, index = e.index, r = e.r, g = e.g, b = e.b, with = e.with,
			} or nil
		end
		if #keep > 0 then
			out[src] = keep
		end
	end
	return out
end

--------------------------------------------------------------------------------
-- How a message reads, in Blizzard's colours: [time] [channel] [name]: text,
-- or the game's own line
--------------------------------------------------------------------------------

-- words separated by commas; a link (Shift+click) counts by its name
local function Terms(filter)
	local terms = {}
	for word in (filter or ""):gmatch("[^,]+") do
		word = strtrim(Plain(word)):lower()
		if word ~= "" then
			terms[#terms + 1] = word
		end
	end
	return terms
end

local function Matches(entry, terms)
	if #terms == 0 then
		return true
	end
	local text = Plain(entry.text):lower()
	local name = (entry.author or ""):lower()
	for _, term in ipairs(terms) do
		if text:find(term, 1, true) or name:find(term, 1, true) then
			return true
		end
	end
	return false
end

-- the words found, in gold; only in text without links or colours, where
-- adding colour can't break anything
local MARK = "|cffffd100"
local function Mark(text, terms, line)
	if #terms == 0 or text:find("|", 1, true) then
		return text
	end
	local lower = text:lower()
	local out, pos = {}, 1
	while pos <= #text do
		local best, bestEnd
		for _, term in ipairs(terms) do
			local s, e = lower:find(term, pos, true)
			if s and (not best or s < best) then
				best, bestEnd = s, e
			end
		end
		if not best then
			break
		end
		out[#out + 1] = text:sub(pos, best - 1)
		out[#out + 1] = MARK .. text:sub(best, bestEnd) .. "|r" .. line
		pos = bestEnd + 1
	end
	out[#out + 1] = text:sub(pos)
	return table.concat(out)
end

local function Name(entry)
	local author = entry.author or ""
	if author == "" then
		return ""
	end
	if not SPOKEN[entry.kind] then
		return author
	end
	local short = Ambiguate and Ambiguate(author, "short") or author
	local hex = ClassHex(entry.class)
	local shown = hex and ("|cff" .. hex .. short .. "|r") or short
	return "|Hplayer:" .. author .. "|h" .. shown .. "|h"
end

local function Line(entry, terms)
	local line = "|cff" .. Hex(entry.r, entry.g, entry.b)
	local parts = {}
	if CHAT_TIMESTAMP_FORMAT and BetterDate then
		parts[#parts + 1] = BetterDate(CHAT_TIMESTAMP_FORMAT, entry.t)
	end
	local text = Mark(entry.text, terms or {}, line)
	local name = Name(entry)
	if entry.kind == "CHANNEL" then
		parts[#parts + 1] = entry.index and ("[%d. %s] "):format(entry.index, entry.chan) or ("[" .. entry.chan .. "] ")
		parts[#parts + 1] = "[" .. name .. "]: "
		parts[#parts + 1] = text
	elseif NAMED[entry.kind] and name ~= "" and text:find("%s", 1, true) then
		-- achievements, emotes of creatures: the name goes in the line
		parts[#parts + 1] = (text:gsub("%%s", (name:gsub("%%", "%%%%")), 1))
	else
		local fmt = name ~= "" and not WHOLE[entry.kind] and _G["CHAT_" .. entry.kind .. "_GET"]
		if type(fmt) == "string" then
			local ok, head = pcall(string.format, fmt, SPOKEN[entry.kind] and ("[" .. name .. "]") or name)
			if ok then
				parts[#parts + 1] = head
			end
		end
		parts[#parts + 1] = text
	end
	local full = table.concat(parts)
	-- in a font string |r goes back to white, not to the message's colour
	full = full:gsub("|r", "|r" .. line)
	return line .. full .. "|r"
end

--------------------------------------------------------------------------------
-- The window
--------------------------------------------------------------------------------

local function GameKinds()
	local set = {}
	for _, g in ipairs(GAME) do
		set[g.key] = true
	end
	return set
end

-- the player's tabs (SetGoSpeakDB.tabs): a name, the channels (nil: all of
-- them), the kinds of message and words a message must have
local function TabList()
	local tabs = db.tabs
	if type(tabs) ~= "table" or #tabs == 0 then
		tabs = { { name = GENERAL or "General", types = GameKinds() } }
		db.tabs = tabs
	end
	for i, t in ipairs(tabs) do
		-- tabs made before one name served every zone
		if type(t.channels) == "table" and not t.zoneFree then
			local set = {}
			for name in pairs(t.channels) do
				set[ChannelKey(name)] = true
			end
			t.channels = set
		end
		t.zoneFree = true
		-- tabs made before the other kinds: the main one gets the game's
		if type(t.types) ~= "table" then
			t.types = i == 1 and GameKinds() or {}
		end
	end
	return tabs
end

local W = {
	tab = 1, -- the tab shown
	filter = {}, -- [tab] = the search, this session only
	selected = {}, -- [entry] = true
	heights = {}, -- [entry] = { width, height }
}

local function Button(parent, text, width)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(width or 110, 22)
	b:SetText(text)
	return b
end

local EDIT_COG = "common-dropdown-a-button-settings-%sshadowless"
-- the pin: Blizzard's lock (the action bars'), shut while the tab is pinned
local LOCK_ON = "Interface\\Buttons\\LockButton-Locked-Up"
local LOCK_OFF = "Interface\\Buttons\\LockButton-Unlocked-Up"
local LOCK_HIGHLIGHT = "Interface\\Buttons\\LockButton-Border"
-- the raid tools plain eye; the first one the game has
local ART = {
	eye = { "GM-icon-visible", "RaidFrame-Icon-Visible", "UI-HUD-RaidFrame-Visible" },
	-- the same eye struck through: shown while the window is (a click hides it)
	eyeOff = { "GM-icon-visibleDis", "GM-icon-invisible", "RaidFrame-Icon-Hidden", "UI-HUD-RaidFrame-Hidden" },
	-- the friends list's pin; grey while not pinned
	pin = "friends-icon-pinned",
}
local EYE_REST = 0.4
local EYE_FILE = "Interface\\LFGFrame\\LFG-Eye"
local ROW_PAD = 4
local CHECK = 20
local FRAME_W, FRAME_H, BOX_H = 420, 516, 36
local HEAD_W = 120 -- the channel's dropdown

local function CurrentTab()
	local tabs = TabList()
	if not tabs[W.tab] then
		W.tab = 1
	end
	return tabs[W.tab]
end

local function InTab(tab, entry)
	if entry.kind == "CHANNEL" then
		return not tab.channels or tab.channels[entry.chan] and true or false
	end
	return tab.types[entry.src] and true or false
end

-- shows nothing at all: no channel and no kind ticked
local function Nothing(tab)
	if not tab.channels or next(tab.channels) then
		return false
	end
	return next(tab.types) == nil
end

local function FontSize()
	return Get("channelsFont")
end

local channelFont = CreateFont("SetGoSpeakChannelsFont")

local function SetupFont()
	local file, _, flags = ChatFontNormal:GetFont()
	channelFont:CopyFontObject(ChatFontNormal)
	channelFont:SetFont(FontFile() or file, FontSize(), flags)
	channelFont:SetJustifyH("LEFT")
	W.heights = {}
end

local function TextWidth()
	local box = W.frame and W.frame.list
	return math.max(100, (box and box:GetWidth() or 380) - CHECK - ROW_PAD * 3)
end

-- the height of a message once wrapped, measured on a hidden font string
local function Height(entry)
	local width = TextWidth()
	local h = W.heights[entry]
	if h and h[1] == width then
		return h[2]
	end
	local measure = W.frame.measure
	measure:SetWidth(width)
	measure:SetText(Line(entry))
	local height = math.max(CHECK, math.ceil(measure:GetStringHeight()) + ROW_PAD * 2)
	W.heights[entry] = { width, height }
	return height
end

local function Count()
	local n = 0
	for _ in pairs(W.selected) do
		n = n + 1
	end
	return n
end

local function UpdateCount()
	local f = W.frame
	if f then
		local n = Count()
		f.copy:SetText(L.COPY_N:format(n))
		f.copy:SetEnabled(n > 0)
	end
end

local function AtEnd(box)
	if box.IsAtEnd then
		return box:IsAtEnd()
	end
	return (box:GetScrollPercentage() or 1) >= 0.999
end

local function ToEnd(box)
	box:ScrollToEnd(ScrollBoxConstants and ScrollBoxConstants.NoScrollInterpolation)
end

local function ShowEmpty()
	local f = W.frame
	local show = f.provider:GetSize() == 0 and not f.copyView:IsShown()
	f.empty:SetText(W.mode == "whispers" and (W.conv and L.EMPTY or L.NO_WHISPERS)
		or Nothing(CurrentTab()) and L.EMPTY_PICK or L.EMPTY)
	f.empty:SetShown(show)
end

-- the search: a message needs one of its words (when there are any), marked
-- in gold
local function Wanted(entry)
	return Matches(entry, W.terms)
end

-- the list for the tab and the search
-- what the list shows: the conversation open, else the tab
local function Shows(entry)
	if W.mode == "whispers" then
		return W.conv ~= nil and entry.with == W.conv
	end
	return InTab(CurrentTab(), entry)
end

-- each tab and each conversation keeps its own search
local function FilterKey()
	return W.conv or W.tab
end

local function Fill()
	local f = W.frame
	W.terms = Terms(W.filter[FilterKey()])
	W.marks = W.terms
	local list = {}
	for _, e in ipairs(everything) do
		if Shows(e) and Wanted(e) then
			list[#list + 1] = e
		end
	end
	f.provider = CreateDataProvider(list)
	f.list:SetDataProvider(f.provider)
	ToEnd(f.list)
	ShowEmpty()
	if Channels.Dots then
		Channels.Dots()
	end
end

local function RefreshTicks()
	local f = W.frame
	f.list:ForEachFrame(function(row)
		row.check:SetChecked(W.selected[row.entry] and true or false)
		row.mark:SetShown(W.selected[row.entry] and true or false)
	end)
	UpdateCount()
end

-- a new message on the pinned tab: its sound (not more than one every 10
-- seconds) and, if chosen, the game's icon flashing on the task bar
local SOUNDS = {
	{ key = "whisper", kit = "TELL_MESSAGE" },
	{ key = "raid", kit = "RAID_WARNING" },
	{ key = "ready", kit = "READY_CHECK" },
}
local lastAlert = 0
function Alert(tab)
	local now = GetTime()
	if tab.sound and now - lastAlert >= 10 and SOUNDKIT then
		for _, sound in ipairs(SOUNDS) do
			if sound.key == tab.sound and SOUNDKIT[sound.kit] then
				PlaySound(SOUNDKIT[sound.kit], "Master")
				lastAlert = now
			end
		end
	end
	if tab.flash and FlashClientIcon then
		FlashClientIcon()
	end
end

function OnNew(entry, dropped)
	local f = W.frame
	if dropped then
		W.selected[dropped] = nil
		W.heights[dropped] = nil
	end
	local view = W.view
	if view and view:IsShown() and view.tab and InTab(view.tab, entry) then
		view.text:AddMessage(Line(entry))
		if not db.pinHidden then
			Alert(view.tab)
		end
	end
	if not (f and f:IsShown() and f.provider) then
		return
	end
	if dropped then
		local i = f.provider:FindIndex(dropped)
		if i then
			f.provider:RemoveIndex(i)
		end
		UpdateCount()
	end
	if Shows(entry) and Wanted(entry) then
		local follow = AtEnd(f.list)
		f.provider:Insert(entry)
		if follow then
			ToEnd(f.list)
		end
	end
	ShowEmpty()
end

-- every message between two (in the list shown) set to one value
local function SetRange(a, b, on)
	local f = W.frame
	local from, to = f.provider:FindIndex(a), f.provider:FindIndex(b)
	if not (from and to) then
		return
	end
	if from > to then
		from, to = to, from
	end
	for i = from, to do
		W.selected[f.provider:Find(i)] = on or nil
	end
end

-- tick or untick; with Shift, everything from the last one ticked
local function Toggle(entry)
	if IsShiftKeyDown() and W.last and W.last ~= entry then
		SetRange(W.last, entry, not W.selected[entry])
	else
		W.selected[entry] = (not W.selected[entry]) or nil
	end
	W.last = entry
	RefreshTicks()
end

-- click and drag: the messages passed over take the first one's new value
local function DragStart(row)
	W.drag = { start = row.entry, on = not W.selected[row.entry] }
end

local function DragOver(row)
	local d = W.drag
	if not (d and IsMouseButtonDown("LeftButton")) or row.entry == d.start then
		return
	end
	d.moved = true
	SetRange(d.start, row.entry, d.on)
	W.last = row.entry
	RefreshTicks()
end

local function DragEnd()
	if W.drag and W.drag.moved then
		W.dragEnded = GetTime()
	end
	W.drag = nil
end

local function InitRow(row, entry)
	if not row.text then
		row:RegisterForClicks("LeftButtonUp")
		row.mark = row:CreateTexture(nil, "BACKGROUND")
		row.mark:SetAllPoints()
		row.mark:SetColorTexture(1, 0.82, 0, 0.15)
		row.hover = row:CreateTexture(nil, "HIGHLIGHT")
		row.hover:SetAllPoints()
		row.hover:SetColorTexture(1, 1, 1, 0.06)
		row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
		row.check:SetSize(CHECK, CHECK)
		row.check:SetPoint("TOPLEFT", 2, -1)
		row.check:SetScript("OnClick", function(self)
			Toggle(self:GetParent().entry)
		end)
		row.text = row:CreateFontString(nil, "ARTWORK")
		row.text:SetFontObject(channelFont)
		row.text:SetPoint("TOPLEFT", row.check, "TOPRIGHT", ROW_PAD, -ROW_PAD + 2)
		row.text:SetJustifyH("LEFT")
		row.text:SetWordWrap(true)
		-- long words and links break too, instead of being cut
		if row.text.SetNonSpaceWrap then
			row.text:SetNonSpaceWrap(true)
		end
		-- names and items work as in the chat: a name opens a whisper (right
		-- click: Blizzard's menu), an item its tooltip
		row:SetHyperlinksEnabled(true)
		row:SetScript("OnHyperlinkClick", function(self, link, text, button)
			self.linkAt = GetTime()
			if SetItemRef then
				SetItemRef(link, text, button)
			end
		end)
		row:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				DragStart(self)
			end
		end)
		row:SetScript("OnMouseUp", DragEnd)
		row:SetScript("OnEnter", DragOver)
		-- a click ticks it, unless it was on a name or an item, or ended a drag
		row:SetScript("OnClick", function(self)
			C_Timer.After(0, function()
				local now = GetTime()
				if self.linkAt and now - self.linkAt < 0.1 then
					return
				end
				if W.dragEnded and now - W.dragEnded < 0.1 then
					return
				end
				Toggle(self.entry)
			end)
		end)
	end
	row.entry = entry
	-- the very width its height was measured at
	row.text:SetWidth(TextWidth())
	row.text:SetText(Line(entry, W.marks))
	local on = W.selected[entry] and true or false
	row.check:SetChecked(on)
	row.mark:SetShown(on)
end

--------------------------------------------------------------------------------
-- Tabs and their menus: as in the chat, a right click on the main tab makes a
-- new one; the cog picks what the tab shows
--------------------------------------------------------------------------------

local Menus = {}
local Input -- the typing box under the window, below
local TabDragStart, TabDragStop

-- a name or words, in Blizzard's pop-up with a box
StaticPopupDialogs["SETGO_SPEAK_TEXT"] = {
	text = "%s",
	button1 = ACCEPT or OKAY,
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = 200,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	OnShow = function(self, data)
		local box = self.editBox or self.EditBox
		if box and data then
			box:SetText(data.value or "")
			box:HighlightText()
			box:SetFocus()
		end
	end,
	OnAccept = function(self, data)
		local box = self.editBox or self.EditBox
		if box and data then
			data.apply(strtrim(box:GetText() or ""))
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local dialog = self:GetParent()
		local data = dialog and dialog.data
		if data then
			data.apply(strtrim(self:GetText() or ""))
		end
		dialog:Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
}

local function Ask(question, value, apply)
	StaticPopup_Show("SETGO_SPEAK_TEXT", question, nil, { value = value, apply = apply })
end

-- the channels to choose from: the ones joined now, then any other heard
local function ChannelChoices()
	if GetChannelList then
		local list = { GetChannelList() }
		for i = 1, #list, 3 do
			local name = list[i + 1]
			if type(name) == "string" and name ~= "" then
				AddChannel(ChannelKey(name))
			end
		end
	end
	return order
end

local function Changed()
	Channels.Tabs()
	Fill()
end

local function Rename(i)
	local tab = TabList()[i]
	Ask(L.NAME_PROMPT, tab.name, function(text)
		if text ~= "" then
			tab.name = text
			Changed()
		end
	end)
end

local function Delete(i)
	local tabs = TabList()
	if i <= 1 or not tabs[i] then
		return
	end
	table.remove(tabs, i)
	W.filter = {}
	if W.tab >= i then
		W.tab = W.tab - 1
	end
	Channels.Select(W.tab)
end

local function Create()
	Ask(L.NAME_PROMPT, L.TAB_NEW:format(#TabList() + 1), function(text)
		local tabs = TabList()
		tabs[#tabs + 1] = { name = text ~= "" and text or L.TAB_NEW:format(#tabs + 1), channels = {}, types = {}, zoneFree = true }
		Channels.Select(#tabs)
	end)
end

local function MenuRefresh()
	return MenuResponse and MenuResponse.Refresh
end

-- the kinds of message as boxes in a submenu
local function KindBoxes(parent, list, tab)
	for _, g in ipairs(list) do
		parent:CreateCheckbox(L["KIND_" .. g.key], function()
			return tab.types[g.key] and true or false
		end, function()
			tab.types[g.key] = (not tab.types[g.key]) or nil
			Fill()
			return MenuRefresh()
		end)
	end
end

local function CogMenu(_, root)
	local tab = CurrentTab()
	local index = W.tab
	root:CreateTitle(tab.name)
	local chans = root:CreateButton(L.MENU_CHANNELS)
	chans:CreateCheckbox(L.ALL_CHANNELS, function()
		return tab.channels == nil
	end, function()
		tab.channels = tab.channels == nil and {} or nil
		Fill()
		return MenuRefresh()
	end)
	chans:CreateDivider()
	for _, name in ipairs(ChannelChoices()) do
		chans:CreateCheckbox(name, function()
			return tab.channels == nil or tab.channels[name] and true or false
		end, function()
			if tab.channels == nil then
				-- from "all": every one but this
				local set = {}
				for _, other in ipairs(ChannelChoices()) do
					set[other] = other ~= name or nil
				end
				tab.channels = set
			else
				tab.channels[name] = (not tab.channels[name]) or nil
			end
			Fill()
			return MenuRefresh()
		end)
	end
	KindBoxes(root:CreateButton(L.MENU_GAME), GAME, tab)
	KindBoxes(root:CreateButton(L.MENU_PLAYERS), PLAYERS, tab)
	-- when this tab is pinned
	local pin = root:CreateButton(L.MENU_PIN)
	local fade = pin:CreateButton(L.PIN_FADE)
	for _, secs in ipairs({ 30, 60, 120, 0 }) do
		fade:CreateRadio(secs == 0 and L.PIN_NEVER or L.PIN_SECS:format(secs), function()
			return (tab.fade or 60) == secs
		end, function()
			tab.fade = secs
			return MenuRefresh()
		end)
	end
	local sound = pin:CreateButton(L.PIN_SOUND)
	for _, choice in ipairs({ { key = nil, label = L.PIN_SOUND_NONE }, { key = "whisper", label = L.PIN_SOUND_WHISPER },
		{ key = "raid", label = L.PIN_SOUND_RAID }, { key = "ready", label = L.PIN_SOUND_READY } }) do
		sound:CreateRadio(choice.label, function()
			return tab.sound == choice.key
		end, function()
			tab.sound = choice.key
			return MenuRefresh()
		end)
	end
	pin:CreateCheckbox(L.PIN_FLASH, function()
		return tab.flash and true or false
	end, function()
		tab.flash = (not tab.flash) or nil
		return MenuRefresh()
	end)
	root:CreateCheckbox(L.TAB_HISTORY, function()
		return tab.history ~= false
	end, function()
		tab.history = tab.history == false and nil or false
		return MenuRefresh()
	end)
	-- for every tab: which addons' lines leave the main chat
	local hide = root:CreateButton(L.MENU_HIDE)
	local sources = {}
	for from in pairs(printers) do
		sources[#sources + 1] = from
	end
	for from in pairs(type(db.hidePrint) == "table" and db.hidePrint or {}) do
		if not printers[from] then
			sources[#sources + 1] = from
		end
	end
	table.sort(sources, function(x, y)
		if x == COMMANDS or y == COMMANDS then
			return x == COMMANDS
		end
		return x:lower() < y:lower()
	end)
	if #sources == 0 then
		hide:CreateTitle(L.HIDE_NONE)
	end
	for _, from in ipairs(sources) do
		hide:CreateCheckbox(from == COMMANDS and L.PRINT_COMMANDS or from, function()
			return Hidden(from)
		end, function()
			db.hidePrint = type(db.hidePrint) == "table" and db.hidePrint or {}
			db.hidePrint[from] = (not db.hidePrint[from]) or nil
			if db.hidePrint[from] then
				WrapChat()
			end
			return MenuRefresh()
		end)
	end
	root:CreateDivider()
	root:CreateButton(L.TAB_RENAME, function()
		Rename(index)
	end)
	if index > 1 then
		root:CreateButton(L.TAB_DELETE, function()
			Delete(index)
		end)
	end
end

local function TabMenu(owner, root)
	local index = owner:GetID()
	if index == 1 then
		root:CreateButton(L.TAB_CREATE, Create)
	end
	root:CreateButton(L.TAB_RENAME, function()
		Rename(index)
	end)
	if index > 1 then
		root:CreateButton(L.TAB_DELETE, function()
			Delete(index)
		end)
	end
end

function Menus.Open(owner, builder)
	if MenuUtil and MenuUtil.CreateContextMenu then
		MenuUtil.CreateContextMenu(owner, builder)
	else
		SetGo.Print(L.NO_MENU)
	end
end

-- move a tab to another place; the main tab stays first. The search and the
-- tab shown go with their tabs.
local function MoveTab(from, to)
	local tabs = TabList()
	local was = {}
	for i = 1, #tabs do
		was[i] = i
	end
	table.insert(was, to, table.remove(was, from))
	table.insert(tabs, to, table.remove(tabs, from))
	local filters, shown = {}, 1
	for i, old in ipairs(was) do
		filters[i] = W.filter[old]
		if old == W.tab then
			shown = i
		end
	end
	W.filter = filters
	Channels.Select(shown)
end

-- the tab under the cursor (past the last one: the last one)
local function TabAt(x)
	local f = W.frame
	local last
	for i, b in ipairs(f.Tabs) do
		if b:IsShown() then
			local scale = b:GetEffectiveScale()
			if x >= b:GetLeft() * scale and x <= b:GetRight() * scale then
				return i
			end
			if x > b:GetRight() * scale then
				last = i
			end
		end
	end
	return last
end

-- while a tab is held: the place it would go, marked in gold (only while
-- the button is down)
local function DragWatch(f)
	local d = W.tabDrag
	if not (d and IsMouseButtonDown("LeftButton")) then
		f.dropMark:Hide()
		f:SetScript("OnUpdate", nil)
		return
	end
	local x = GetCursorPosition()
	local to = math.abs(x - d.x) >= 10 and TabAt(x)
	if to and to >= 2 and to ~= d.from then
		-- moving right it lands after the tab under the cursor, left before it
		local target = f.Tabs[to]
		local side = to > d.from and "RIGHT" or "LEFT"
		f.dropMark:ClearAllPoints()
		f.dropMark:SetPoint("TOP", target, "TOP" .. side, side == "RIGHT" and 1 or -1, -4)
		f.dropMark:SetPoint("BOTTOM", target, "BOTTOM" .. side, side == "RIGHT" and 1 or -1, 2)
		f.dropMark:Show()
	else
		f.dropMark:Hide()
	end
end

-- press on a tab, let go over another: it moves there
function TabDragStart(self, button)
	if button == "LeftButton" and self:GetID() > 1 then
		W.tabDrag = { from = self:GetID(), x = GetCursorPosition() }
		self:SetAlpha(0.6)
		W.frame:SetScript("OnUpdate", DragWatch)
	end
end

function TabDragStop(self, button)
	if button == "RightButton" then
		if self:IsMouseOver() then
			Menus.Open(self, TabMenu)
		end
		return
	end
	local d = W.tabDrag
	W.tabDrag = nil
	self:SetAlpha(1)
	W.frame.dropMark:Hide()
	W.frame:SetScript("OnUpdate", nil)
	if not d then
		return
	end
	local x = GetCursorPosition()
	if math.abs(x - d.x) < 10 then
		return
	end
	local to = TabAt(x)
	if to and to >= 2 and to ~= d.from then
		W.tabMovedAt = GetTime()
		MoveTab(d.from, to)
	end
end

function Channels.Tabs()
	local f = W.frame
	local tabs = TabList()
	-- our own list: the tab template adds every tab to f.Tabs on its own, so
	-- f.Tabs is rebuilt below with only the player's tabs, in order, for
	-- Blizzard's tab functions
	local buttons = f.tabButtons
	for i, t in ipairs(tabs) do
		local tab = buttons[i]
		if not tab then
			tab = CreateFrame("Button", nil, f, "PanelTopTabButtonTemplate")
			tab:SetID(i)
			tab:RegisterForClicks("LeftButtonUp")
			tab:SetScript("OnClick", function(self)
				if W.tabMovedAt == GetTime() then
					return
				end
				Channels.Select(self:GetID())
			end)
			-- Blizzard switches the selected tab off, so it has no clicks: the
			-- right click and the drag come from the mouse itself, on any tab
			tab:SetScript("OnMouseDown", TabDragStart)
			tab:SetScript("OnMouseUp", TabDragStop)
			if tab.SetMotionScriptsWhileDisabled then
				tab:SetMotionScriptsWhileDisabled(true)
			end
			buttons[i] = tab
		end
		tab:SetText(t.name ~= "" and t.name or "?")
		if PanelTemplates_TabResize then
			PanelTemplates_TabResize(tab, 0)
		end
	end
	for i = #tabs + 1, #buttons do
		buttons[i]:Hide()
	end
	f.Tabs = {}
	for i = 1, #tabs do
		f.Tabs[i] = buttons[i]
	end
	PanelTemplates_SetNumTabs(f, #tabs)
	CurrentTab()
	PanelTemplates_SetTab(f, W.tab)
	Channels.LayTabs()
end

-- the tabs that fit between the arrows, from the first one shown; the arrows
-- slide them (the mouse wheel over them too), and the tab open stays in view
local TABS_LEFT, ARROW, TAB_GAP = 52, 22, 4
function Channels.LayTabs(keepOffset)
	local f = W.frame
	local tabs = f.Tabs
	local room = f.ground:GetWidth() - TABS_LEFT - ARROW * 2 - TAB_GAP * 2
	local function Fits(first, last)
		local width = 0
		for i = first, last do
			width = width + tabs[i]:GetWidth() + (i > first and TAB_GAP or 0)
		end
		return width <= room
	end
	-- whispers: the conversations' tabs, with their own place in the strip
	local key = W.mode == "whispers" and "convFirst" or "tabFirst"
	local sel = W.mode == "whispers" and (W.convSel or 1) or W.tab
	if #tabs == 0 then
		f.prevTabs:Hide()
		f.nextTabs:Hide()
		return
	end
	local first = math.max(1, math.min(W[key] or 1, #tabs))
	if not keepOffset then
		if sel < first then
			first = sel
		end
		while first < sel and not Fits(first, sel) do
			first = first + 1
		end
	end
	local last = first
	while last < #tabs and Fits(first, last + 1) do
		last = last + 1
	end
	W[key] = first
	for i, tab in ipairs(tabs) do
		tab:ClearAllPoints()
		if i < first or i > last then
			tab:Hide()
		else
			if i == first then
				tab:SetPoint("BOTTOMLEFT", f.ground, "TOPLEFT", TABS_LEFT + ARROW + TAB_GAP, -2)
			else
				tab:SetPoint("LEFT", tabs[i - 1], "RIGHT", TAB_GAP, 0)
			end
			tab:Show()
		end
	end
	-- the arrows only when the tabs don't all fit, always at the two ends
	local more = first > 1 or last < #tabs
	f.prevTabs:SetShown(more)
	f.nextTabs:SetShown(more)
	f.prevTabs:SetEnabled(first > 1)
	f.nextTabs:SetEnabled(last < #tabs)
end

local function Slide(step)
	local f = W.frame
	local key = W.mode == "whispers" and "convFirst" or "tabFirst"
	local first = (W[key] or 1) + step
	if first < 1 or first > #f.Tabs then
		return
	end
	W[key] = first
	Channels.LayTabs(true)
end

function Channels.Select(i)
	local f = W.frame
	W.tab = i
	W.conv = nil
	W.mode = "channels"
	f.cog:Show()
	f.pin:Show()
	f.convTitle:Hide()
	for _, b in ipairs(f.convButtons) do
		b:Hide()
	end
	Channels.Tabs()
	f.search:SetText(W.filter[W.tab] or "")
	Fill()
	if Channels.Side then
		Channels.Side()
	end
	if Channels.PinButton then
		Channels.PinButton()
	end
end

--------------------------------------------------------------------------------
-- Copy: the ticked messages, as plain text, all selected for Ctrl+C
--------------------------------------------------------------------------------

local function ShowCopy(on)
	local f = W.frame
	f.copyView:SetShown(on)
	f.list:SetShown(not on)
	f.bar:SetShown(not on)
	f.search:SetShown(not on)
	f.all:SetShown(not on)
	f.none:SetShown(not on)
	f.copy:SetShown(not on)
	f.cog:SetShown(not on)
	f.pin:SetShown(not on)
	f.back:SetShown(on)
	f.hint:SetShown(on)
	for _, tab in ipairs(f.Tabs) do
		tab:SetEnabled(not on)
	end
	if not on then
		f.box:ClearFocus()
		PanelTemplates_SetTab(f, W.tab)
		ShowEmpty()
		return
	end
	f.empty:Hide()
	local picked = {}
	for entry in pairs(W.selected) do
		picked[#picked + 1] = entry
	end
	table.sort(picked, function(a, b)
		return a.seq < b.seq
	end)
	local lines = {}
	for _, entry in ipairs(picked) do
		lines[#lines + 1] = Plain(Line(entry))
	end
	f.copyText = table.concat(lines, "\n")
	f.box:SetWidth(f.copyView:GetWidth())
	f.box:SetText(f.copyText)
	f.box:SetFocus()
	f.box:HighlightText()
	f.copyView:SetVerticalScroll(0)
end

--------------------------------------------------------------------------------
-- Building the window: SetGo!'s (Blizzard's frame with the portrait, the
-- collections' stone inside), narrow to play with it open, on the left like
-- Blizzard's windows
--------------------------------------------------------------------------------

function Channels.Frame()
	if W.frame then
		return W.frame
	end
	local f = CreateFrame("Frame", "SetGoSpeakChannels", UIParent, "ButtonFrameTemplate")
	W.frame = f
	f:SetSize(FRAME_W, FRAME_H)
	f:SetFrameStrata("HIGH")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		-- kept until the next reload, not in the game's layout file
		if self.SetUserPlaced then
			self:SetUserPlaced(false)
		end
		self.moved = true
	end)
	f:Hide()
	tinsert(UISpecialFrames, f:GetName())
	if f.SetTitle then
		f:SetTitle(L.CHANNELS)
	end
	if f.SetPortraitToAsset then
		f:SetPortraitToAsset(ICON)
	end
	if type(f.Inset) == "table" then
		f.Inset:Hide()
	end
	local ground
	if C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("CollectionsBackgroundTemplate") then
		ground = CreateFrame("Frame", nil, f, "CollectionsBackgroundTemplate")
		for _, key in ipairs({ "BGCornerTopLeft", "BGCornerTopRight", "BGCornerBottomLeft", "BGCornerBottomRight" }) do
			if ground[key] then
				ground[key]:Hide()
			end
		end
	elseif C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("InsetFrameTemplate") then
		ground = CreateFrame("Frame", nil, f, "InsetFrameTemplate")
	else
		ground = CreateFrame("Frame", nil, f)
		local bg = ground:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.05, 0.04, 0.03, 0.9)
	end
	ground:ClearAllPoints()
	ground:SetPoint("TOPLEFT", 8, -60)
	ground:SetPoint("BOTTOMRIGHT", -8, 30 + BOX_H)
	f.ground = ground
	f.tabButtons = {}
	f.Tabs = {}
	local function Arrow(dir, step)
		local b = CreateFrame("Button", nil, f)
		b:SetSize(ARROW, ARROW)
		b:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. dir .. "Page-Up")
		b:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. dir .. "Page-Down")
		b:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. dir .. "Page-Disabled")
		b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
		b:SetScript("OnClick", function()
			Slide(step)
		end)
		b:Hide()
		return b
	end
	f.prevTabs = Arrow("Prev", -1)
	f.prevTabs:SetPoint("BOTTOMLEFT", ground, "TOPLEFT", TABS_LEFT, 2)
	f.nextTabs = Arrow("Next", 1)
	f.nextTabs:SetPoint("BOTTOMRIGHT", ground, "TOPRIGHT", -2, 2)
	-- the wheel over the tabs slides them too
	local strip = CreateFrame("Frame", nil, f)
	strip:SetPoint("BOTTOMLEFT", ground, "TOPLEFT", TABS_LEFT, 0)
	strip:SetPoint("BOTTOMRIGHT", ground, "TOPRIGHT", 0, 0)
	strip:SetHeight(28)
	strip:SetFrameLevel(f:GetFrameLevel() + 1)
	strip:EnableMouseWheel(true)
	strip:SetScript("OnMouseWheel", function(_, delta)
		Slide(delta > 0 and -1 or 1)
	end)
	f.dropMark = f:CreateTexture(nil, "OVERLAY", nil, 7)
	f.dropMark:SetColorTexture(1, 0.82, 0, 1)
	f.dropMark:SetWidth(3)
	f.dropMark:Hide()

	-- the cog: what this tab shows
	f.cog = CreateFrame("Button", nil, f)
	f.cog:SetSize(22, 22)
	f.cog:SetPoint("TOPRIGHT", ground, "TOPRIGHT", -8, -6)
	f.cog:SetFrameLevel(ground:GetFrameLevel() + 30)
	if HasAtlas(EDIT_COG:format("")) then
		f.cog:SetNormalAtlas(EDIT_COG:format(""))
		f.cog:SetPushedAtlas(EDIT_COG:format("pressed-"))
		f.cog:SetHighlightAtlas(EDIT_COG:format("hover-"), "BLEND")
	else
		local icon = f.cog:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()
		icon:SetTexture("Interface\\Icons\\inv_misc_gear_01")
	end
	f.cog:SetScript("OnClick", function(self)
		Menus.Open(self, CogMenu)
	end)
	f.cog:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L.COG_TIP)
		GameTooltip:AddLine(L.COG_TIP_DESC, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	f.cog:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- the pin: this tab stays on screen, as text only, while the window is
	-- closed
	f.pin = CreateFrame("Button", nil, f)
	f.pin:SetSize(20, 20)
	f.pin:SetPoint("RIGHT", f.cog, "LEFT", -6, 0)
	f.pin:SetFrameLevel(ground:GetFrameLevel() + 30)
	f.pin.icon = f.pin:CreateTexture(nil, "ARTWORK")
	f.pin.icon:SetAllPoints()
	if HasAtlas(ART.pin) then
		f.pin:SetHighlightAtlas(ART.pin, "ADD")
	else
		f.pin:SetHighlightTexture(LOCK_HIGHLIGHT, "ADD")
	end
	f.pin:SetScript("OnClick", function(self)
		local tab = CurrentTab()
		local on = not tab.pinned
		for _, t in ipairs(TabList()) do
			t.pinned = nil
		end
		tab.pinned = on or nil
		Channels.PinButton()
		if GameTooltip:IsOwned(self) then
			self:GetScript("OnEnter")(self)
		end
	end)
	f.pin:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(CurrentTab().pinned and L.UNPIN or L.PIN)
		GameTooltip:AddLine(L.PIN_DESC, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	f.pin:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- a conversation open: its name where the tabs are
	f.convTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.convTitle:SetPoint("BOTTOMLEFT", ground, "TOPLEFT", 60, 10)
	f.convTitle:Hide()
	-- outside the window's right edge: Channels, then one per conversation
	f.sideTabs = {}
	f.convButtons = {}

	-- the messages, under the tabs
	local list = CreateFrame("Frame", nil, f, "WowScrollBoxList")
	list:SetPoint("TOPLEFT", ground, "TOPLEFT", 6, -32)
	list:SetPoint("BOTTOMRIGHT", ground, "BOTTOMRIGHT", -20, 6)
	local bar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
	bar:SetPoint("TOPLEFT", list, "TOPRIGHT", 5, 0)
	bar:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT", 5, 0)
	local view = CreateScrollBoxListLinearView()
	view:SetElementExtentCalculator(function(_, entry)
		return Height(entry)
	end)
	view:SetElementInitializer("Button", InitRow)
	ScrollUtil.InitScrollBoxListWithScrollBar(list, bar, view)
	f.list, f.bar = list, bar
	f.provider = CreateDataProvider()
	list:SetDataProvider(f.provider)

	local measure = f:CreateFontString(nil, "BACKGROUND")
	measure:SetFontObject(channelFont)
	measure:SetWordWrap(true)
	if measure.SetNonSpaceWrap then
		measure:SetNonSpaceWrap(true)
	end
	measure:SetJustifyH("LEFT")
	measure:SetAlpha(0)
	measure:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 100, -100)
	f.measure = measure

	local empty = f:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	empty:SetPoint("LEFT", list, "LEFT", 20, 0)
	empty:SetPoint("RIGHT", list, "RIGHT", -20, 0)
	empty:SetText(L.EMPTY)
	f.empty = empty

	-- the bottom row: the search, then All, None and Copy
	local search = CreateFrame("EditBox", nil, f, "SearchBoxTemplate")
	search:SetSize(150, 20)
	search:SetPoint("BOTTOMLEFT", 12, 5 + BOX_H)
	search:SetAutoFocus(false)
	if search.Instructions then
		search.Instructions:SetText(L.FILTER)
	end
	search:HookScript("OnTextChanged", function(self)
		local text = self:GetText() or ""
		if (W.filter[FilterKey()] or "") ~= text then
			W.filter[FilterKey()] = text
			Fill()
		end
	end)
	f.search = search
	f.copy = Button(f, L.COPY_N:format(0), 92)
	f.copy:SetPoint("BOTTOMRIGHT", -6, 4 + BOX_H)
	f.copy:SetScript("OnClick", function()
		ShowCopy(true)
	end)
	f.none = Button(f, L.SELECT_NONE, 66)
	f.none:SetPoint("RIGHT", f.copy, "LEFT", -2, 0)
	f.none:SetScript("OnClick", function()
		wipe(W.selected)
		W.last = nil
		RefreshTicks()
	end)
	f.all = Button(f, L.SELECT_ALL, 56)
	f.all:SetPoint("RIGHT", f.none, "LEFT", -2, 0)
	f.all:SetScript("OnClick", function()
		for _, entry in f.provider:Enumerate() do
			W.selected[entry] = true
		end
		RefreshTicks()
	end)
	f.back = Button(f, L.BACK, 92)
	f.back:SetPoint("BOTTOMRIGHT", -6, 4 + BOX_H)
	f.back:SetScript("OnClick", function()
		ShowCopy(false)
	end)
	f.back:Hide()
	f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.hint:SetPoint("BOTTOMLEFT", 12, 10 + BOX_H)
	f.hint:SetText(L.COPY_HINT)
	f.hint:Hide()

	-- the copy view: a read only box over the list
	local scroll = CreateFrame("ScrollFrame", nil, f)
	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(self, delta)
		local v = self:GetVerticalScroll() - delta * 40
		self:SetVerticalScroll(math.max(0, math.min(v, self:GetVerticalScrollRange())))
	end)
	scroll:SetPoint("TOPLEFT", ground, "TOPLEFT", 10, -10)
	scroll:SetPoint("BOTTOMRIGHT", ground, "BOTTOMRIGHT", -10, 8)
	local box = CreateFrame("EditBox", nil, scroll)
	box:SetMultiLine(true)
	box:SetAutoFocus(false)
	box:SetFontObject(channelFont)
	box:SetWidth(380)
	scroll:SetScrollChild(box)
	box:SetScript("OnTextChanged", function(self, user)
		if user then
			self:SetText(f.copyText or "")
			self:HighlightText()
		end
	end)
	box:SetScript("OnEscapePressed", function()
		ShowCopy(false)
	end)
	box:SetScript("OnEditFocusGained", function(self)
		self:HighlightText()
	end)
	scroll:Hide()
	f.copyView, f.box = scroll, box

	-- under the window: the typing box, with where it writes
	Input.Build(f)

	f:SetScript("OnShow", function()
		if PlaySound and SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_OPEN then
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
		end
		Channels.UpdatePin()
		Channels.TakeEnter(true)
		-- the cursor in the box (a moment later: the key that opened it
		-- would be typed in)
		C_Timer.After(0, function()
			if f:IsShown() and not f.search:HasFocus() then
				f.input:SetFocus()
			end
		end)
	end)
	f:SetScript("OnHide", function()
		if PlaySound and SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_CLOSE then
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
		end
		if f.copyView:IsShown() then
			ShowCopy(false)
		end
		f.search:ClearFocus()
		f.input:ClearFocus()
		W.drag = nil
		Channels.UpdatePin()
		Channels.TakeEnter(false)
	end)
	return f
end

-- the chats a dot can write in, after the channels: how the game sends to
-- it (whispers go through /w, which needs a name)
local WRITE = {
	{ kind = "SAY", send = "SAY" }, { kind = "YELL", send = "YELL" }, { kind = "EMOTE", send = "EMOTE" },
	{ kind = "PARTY", send = "PARTY" }, { kind = "RAID", send = "RAID" }, { kind = "INSTANCE_CHAT", send = "INSTANCE_CHAT" },
	{ kind = "GUILD", send = "GUILD" }, { kind = "OFFICER", send = "OFFICER" }, { kind = "WHISPER", slash = "/w " },
}
-- a line starting with / goes to Blizzard's chat as if typed there: its
-- commands, /dump and the rest (not the protected ones, such as /cast)
local function Slash(text)
	local box = DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox
	if box and ChatEdit_SendText then
		box:SetText(text)
		ChatEdit_SendText(box, 1)
		box:SetText("")
	elseif ChatFrame_OpenChat then
		ChatFrame_OpenChat(text, DEFAULT_CHAT_FRAME)
	end
end

local function Send(text, dest)
	local send = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
	if not (send and dest) then
		return
	end
	if dest.bn then
		if BNSendWhisper then
			BNSendWhisper(dest.bn, text)
		end
	elseif dest.whisper then
		send(text, "WHISPER", nil, dest.whisper)
	elseif dest.index then
		send(text, "CHANNEL", nil, dest.index)
	elseif dest.send then
		send(text, dest.send)
	end
end

Input = {}

-- the header's text: where the box sends, in its colour
function Input.Look()
	local box = W.frame and W.frame.input
	if not box then
		return
	end
	local dest = W.dest
	local head = box.head
	local label = dest and dest.label or L.NOWHERE
	if head.isDropdown and head.OverrideText then
		head:OverrideText(label)
	else
		head.sgText:SetText(label)
	end
	head.sgText:SetTextColor(dest and dest.r or 0.6, dest and dest.g or 0.6, dest and dest.b or 0.6)
	box:SetTextColor(dest and dest.r or 1, dest and dest.g or 1, dest and dest.b or 1)
	-- a fixed width: a long name is cut
	head:SetWidth(HEAD_W)
end

-- where the box sends
local function Pick(dest)
	W.dest = dest
	if W.mode ~= "whispers" then
		CurrentTab().dest = dest and dest.key or nil
	end
	Input.Look()
end

-- every place the tab can write in: its channels open here, then its chats
local function Destinations()
	local tab = CurrentTab()
	local list = {}
	if GetChannelList then
		local channels = { GetChannelList() }
		for i = 1, #channels, 3 do
			local index, name, off = channels[i], channels[i + 1], channels[i + 2]
			if type(name) == "string" and not off then
				local key = ChannelKey(name)
				if not tab.channels or tab.channels[key] then
					local r, g, b = Colour("CHANNEL" .. index)
					list[#list + 1] = { key = "C:" .. key, label = index .. ". " .. key, index = index, r = r, g = g, b = b }
				end
			end
		end
	end
	for _, w in ipairs(WRITE) do
		if tab.types[w.kind] then
			local r, g, b = Colour(w.kind)
			list[#list + 1] = { key = w.kind, label = L["KIND_" .. w.kind], send = w.send, slash = w.slash, r = r, g = g, b = b }
		end
	end
	return list
end

-- the tab shown: its last place, else its first
-- the conversation open: only to that person
local function ConvDest()
	local c = W.conv and convs[W.conv]
	if not c then
		return
	end
	local r, g, b = Colour(c.bn and "BN_WHISPER" or "WHISPER")
	return { key = "W:" .. c.with, label = L.CONV_TO:format(c.short or "?"), whisper = not c.bn and c.name or nil,
		bn = c.bn, r = r, g = g, b = b }
end

function Channels.Dots()
	local f = W.frame
	if not (f and f.input) then
		return
	end
	if W.mode == "whispers" then
		Pick(ConvDest())
		return
	end
	local tab = CurrentTab()
	local list = Destinations()
	local picked
	for _, d in ipairs(list) do
		if d.key == tab.dest then
			picked = d
		end
	end
	Pick(picked or list[1])
end

local function HeadMenu(_, root)
	for _, d in ipairs(W.mode == "whispers" and { ConvDest() } or Destinations()) do
		root:CreateRadio(d.label, function()
			return W.dest and W.dest.key == d.key
		end, function()
			Pick(d)
			local box = W.frame.input
			if d.slash and strtrim(box:GetText() or "") == "" then
				box:SetText(d.slash)
			end
			box:SetFocus()
		end)
	end
end

local function OnEnterPressed(box)
	local text = strtrim(box:GetText() or "")
	box:SetText("")
	if text == "" then
		box:ClearFocus()
		return
	end
	box:AddHistoryLine(text)
	if text:sub(1, 1) == "/" then
		Slash(text)
	else
		Send(text, W.dest)
	end
end

-- the strip at the bottom of the window: the window goes on around it (its
-- own border is the box's), on a darker ground; the header (where it
-- sends) at its start, as the chat's typing box
function Input.Build(f)
	local panel = CreateFrame("Frame", nil, f)
	panel:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 6, 4)
	panel:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
	panel:SetHeight(BOX_H - 4)
	panel:EnableMouse(true)
	local bg = panel:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.6)
	-- the edge between the window and the box: the bank's divider (else the
	-- options' one; else the tooltips')
	local edge = panel:CreateTexture(nil, "BORDER")
	edge:SetPoint("LEFT", panel, "TOPLEFT", -2, 0)
	edge:SetPoint("RIGHT", panel, "TOPRIGHT", 0, 0)
	local bank = C_Texture.GetAtlasInfo("bank-divider")
	if bank then
		edge:SetAtlas("bank-divider")
		-- the same shape as Blizzard's: as tall as its width allows
		local width = FRAME_W - 8
		edge:SetHeight(math.floor((bank.height or 32) * width / (bank.width or 864) + 0.5))
	elseif HasAtlas("Options_HorizontalDivider") then
		edge:SetAtlas("Options_HorizontalDivider")
		edge:SetHeight(4)
	else
		edge:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
		edge:SetHeight(8)
	end
	f.inputPanel = panel

	-- where it sends: on a plate of its own (Blizzard's dropdown button, else
	-- a darker plate), in Friz Quadrata
	-- Blizzard's own dropdown (its art, its arrow, its sizes), else a plain
	-- button of ours
	local head
	if C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("WowStyle1DropdownTemplate") then
		local ok, dropdown = pcall(CreateFrame, "DropdownButton", nil, panel, "WowStyle1DropdownTemplate")
		if ok and dropdown and dropdown.SetupMenu then
			head = dropdown
			head.isDropdown = true
			-- its own field: Blizzard's dropdown keeps its text (a string) in
			-- head.text
			head.sgText = head.Text
			head:SetupMenu(HeadMenu)
		end
	end
	if not head then
		head = CreateFrame("Button", nil, panel)
		head.plate = head:CreateTexture(nil, "BACKGROUND")
		head.plate:SetAllPoints()
		head.plate:SetColorTexture(0.16, 0.12, 0.08, 0.95)
		head.sgText = head:CreateFontString(nil, "OVERLAY")
		head.sgText:SetPoint("LEFT", 10, 0)
		head.sgText:SetPoint("RIGHT", -24, 0)
		head.sgText:SetJustifyH("LEFT")
		head.arrow = head:CreateTexture(nil, "OVERLAY")
		head.arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
		head.arrow:SetSize(12, 12)
		head.arrow:SetPoint("RIGHT", -8, -1)
		head:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
		head:SetScript("OnClick", function(self)
			Menus.Open(self, HeadMenu)
		end)
	end
	head:SetPoint("LEFT", panel, "LEFT", 2, 0)
	head:SetHeight(BOX_H - 10)
	head:SetWidth(HEAD_W)
	if head.sgText then
		head.sgText:SetWordWrap(false)
		if head.sgText.SetMaxLines then
			head.sgText:SetMaxLines(1)
		end
		local _, chatSize = ChatFontNormal:GetFont()
		head.sgText:SetFont("Fonts\\FRIZQT__.TTF", math.max(12, chatSize or 13), "")
	end
	head:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(L.HEAD_TIP)
		GameTooltip:AddLine(L.DOT_DESC, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	head:HookScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local box = CreateFrame("EditBox", "SetGoSpeakChannelsInput", panel)
	box:SetPoint("LEFT", head, "RIGHT", 4, 0)
	box:SetHeight(BOX_H - 10)
	box:SetTextInsets(8, 4, 0, 0)
	box:SetPoint("RIGHT", 0, 0)
	box:SetAutoFocus(false)
	box:SetFontObject(ChatFontNormal)
	do
		local _, chatSize = ChatFontNormal:GetFont()
		box:SetFont("Fonts\\FRIZQT__.TTF", math.max(12, chatSize or 13), "")
	end
	box:SetMaxLetters(255)
	box:SetHistoryLines(30)
	if box.SetAltArrowKeyMode then
		box:SetAltArrowKeyMode(false)
	end
	box:SetScript("OnEnterPressed", OnEnterPressed)
	box:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	box.head = head
	f.input = box
	-- a click anywhere on the panel puts the cursor in the box
	panel:SetScript("OnMouseDown", function()
		box:SetFocus()
	end)
end

-- the chat's open key (Enter) puts the cursor in the Board's box while the
-- Board is open. Keys can't change in combat: then the chat keeps it, and a
-- key taken before combat goes back when combat ends.
local enterButton = CreateFrame("Button", "SetGoSpeakBoardEnter", UIParent)
enterButton:SetScript("OnClick", function()
	local f = W.frame
	if f and f:IsShown() and f.input then
		f.input:SetFocus()
	elseif ChatFrame_OpenChat then
		ChatFrame_OpenChat("", DEFAULT_CHAT_FRAME)
	end
end)
local keyOwner = CreateFrame("Frame")
local keyWanted, keyTaken = false, false

local function ApplyEnter()
	if InCombatLockdown() then
		keyOwner:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	keyOwner:UnregisterEvent("PLAYER_REGEN_ENABLED")
	if keyWanted == keyTaken then
		return
	end
	ClearOverrideBindings(keyOwner)
	if keyWanted then
		local keys = { GetBindingKey("OPENCHAT") }
		if #keys == 0 then
			keys = { "ENTER" }
		end
		for _, key in ipairs(keys) do
			SetOverrideBindingClick(keyOwner, true, key, "SetGoSpeakBoardEnter")
		end
	end
	keyTaken = keyWanted
end
keyOwner:SetScript("OnEvent", ApplyEnter)

function Channels.TakeEnter(on)
	keyWanted = on and true or false
	ApplyEnter()
end

-- the side tabs: Channels (the tabs on top), then the conversations,
-- favourites first, then the latest; as many as fit along the window
-- Blizzard's side tabs (the character window's): 55 x 55, the art 55 x 60
local SIDE = 55

local function SideMenu(owner, root)
	local c = convs[owner.with]
	if not c then
		return
	end
	if not c.bn then
		root:CreateButton(c.fav and L.CONV_UNFAV or L.CONV_FAV, function()
			c.fav = (not c.fav) or nil
			if W.mode == "whispers" then
				Channels.ConvTabs()
			end
		end)
	end
	root:CreateButton(L.CONV_CLOSE, function()
		c.closed, c.fav, c.unread = true, nil, nil
		if W.lastConv == c.with then
			W.lastConv = nil
		end
		if W.mode == "whispers" then
			Channels.OpenConv(W.conv ~= c.with and W.conv or nil)
		else
			Channels.Side()
		end
	end)
end

-- the conversations, favourites first, then the latest
local function ConvList()
	local list = {}
	for _, c in pairs(convs) do
		if not c.closed then
			list[#list + 1] = c
		end
	end
	table.sort(list, function(a, b)
		if (a.fav and true or false) ~= (b.fav and true or false) then
			return a.fav and true or false
		end
		return (a.at or 0) > (b.at or 0)
	end)
	return list
end

-- whispers: the conversations along the top, as the channels' tabs (first
-- name, class colour, gold while unread, * for a favourite)
function Channels.ConvTabs()
	local f = W.frame
	local list = ConvList()
	for _, b in ipairs(f.tabButtons) do
		b:Hide()
	end
	local buttons = f.convButtons
	W.convSel = nil
	for i, c in ipairs(list) do
		local b = buttons[i]
		if not b then
			b = CreateFrame("Button", nil, f, "PanelTopTabButtonTemplate")
			b:SetID(i)
			b:RegisterForClicks("LeftButtonUp")
			b:SetScript("OnClick", function(self)
				Channels.OpenConv(self.with)
			end)
			b:SetScript("OnMouseUp", function(self, button)
				if button == "RightButton" and self:IsMouseOver() then
					Menus.Open(self, SideMenu)
				end
			end)
			if b.SetMotionScriptsWhileDisabled then
				b:SetMotionScriptsWhileDisabled(true)
			end
			buttons[i] = b
		end
		b.with = c.with
		local hex = ClassHex(c.class)
		local name = c.short or "?"
		if c.unread then
			name = "|cffffd100" .. name .. "|r"
		elseif hex then
			name = "|cff" .. hex .. name .. "|r"
		end
		b:SetText((c.fav and "* " or "") .. name)
		if PanelTemplates_TabResize then
			PanelTemplates_TabResize(b, 0)
		end
		if c.with == W.conv then
			W.convSel = i
		end
	end
	for i = #list + 1, #buttons do
		buttons[i]:Hide()
	end
	f.Tabs = {}
	for i = 1, #list do
		f.Tabs[i] = buttons[i]
	end
	PanelTemplates_SetNumTabs(f, #list)
	if W.convSel then
		PanelTemplates_SetTab(f, W.convSel)
	end
	Channels.LayTabs()
end

-- the Whispers side tab: a conversation (the one asked, else the last one
-- open, else the first)
function Channels.OpenConv(with)
	local f = W.frame
	if not f then
		return
	end
	local list = ConvList()
	if not (with and convs[with] and not convs[with].closed) then
		with = (W.lastConv and convs[W.lastConv] and not convs[W.lastConv].closed) and W.lastConv
			or (list[1] and list[1].with)
	end
	W.mode = "whispers"
	W.conv = with
	W.lastConv = with or W.lastConv
	if with then
		convs[with].unread = nil
	end
	f.cog:Hide()
	f.pin:Hide()
	f.convTitle:Hide()
	Channels.ConvTabs()
	f.search:SetText(W.filter[with or "\001none"] or "")
	Fill()
	Channels.Side()
end

local function SideButton(f, i, size)
	local b = f.sideTabs[i]
	if b then
		return b
	end
	b = CreateFrame("Button", nil, f)
	b:SetSize(size, size)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	-- Blizzard's art (55 x 60 for a 55 tab), at this tab's scale
	local scale = size / SIDE
	local function Art(layer, atlas)
		local t = b:CreateTexture(nil, layer)
		t:SetPoint("CENTER")
		t:SetSize(SIDE * scale, (SIDE + 5) * scale)
		if HasAtlas(atlas) then
			t:SetAtlas(atlas)
		else
			t:SetColorTexture(0.1, 0.08, 0.06, layer == "BACKGROUND" and 0.95 or 0)
		end
		return t
	end
	b.bg = Art("BACKGROUND", "common-sidetab")
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetSize(size - 5 * scale, size - 5 * scale)
	b.icon:SetPoint("CENTER")
	if HasAtlas("common-sidetab-mask") then
		local mask = b:CreateMaskTexture()
		mask:SetAtlas("common-sidetab-mask")
		mask:SetSize(SIDE * scale, (SIDE + 5) * scale)
		mask:SetPoint("CENTER")
		b.icon:AddMaskTexture(mask)
	end
	b.selected = Art("OVERLAY", "common-sidetab-selected")
	b.selected:Hide()
	local hover = Art("HIGHLIGHT", "common-sidetab-hover")
	hover:SetBlendMode("ADD")
	-- unread: the hover's light, breathing
	b.unread = Art("OVERLAY", "common-sidetab-hover")
	b.unread:SetBlendMode("ADD")
	b.unread:Hide()
	local pulse = b.unread:CreateAnimationGroup()
	pulse:SetLooping("BOUNCE")
	local fade = pulse:CreateAnimation("Alpha")
	fade:SetFromAlpha(0.2)
	fade:SetToAlpha(1)
	fade:SetDuration(0.8)
	b.pulse = pulse
	b:SetScript("OnEnter", SideTip)
	b:SetScript("OnLeave", GameTooltip_Hide)
	f.sideTabs[i] = b
	return b
end

-- two side tabs: Channels and Whispers (lit while a conversation has
-- something unread)
local WHISPER_ICON = "Interface\\Icons\\INV_Misc_GroupNeedMore"
function Channels.Side()
	local f = W.frame
	if not f then
		return
	end
	local top = SideButton(f, 1, SIDE)
	top:ClearAllPoints()
	top:SetPoint("TOPLEFT", f, "TOPRIGHT", -2, -40)
	top.icon:SetTexture(ICON)
	top.tip = L.SIDE_CHANNELS
	top:SetScript("OnClick", function()
		if W.mode == "whispers" then
			Channels.Select(W.tab)
		end
	end)
	top.selected:SetShown(W.mode ~= "whispers")
	top:Show()
	local whisper = SideButton(f, 2, SIDE)
	whisper:ClearAllPoints()
	whisper:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, 0)
	whisper.icon:SetTexture(WHISPER_ICON)
	whisper.tip = L.SIDE_WHISPERS
	whisper:SetScript("OnClick", function()
		if W.mode ~= "whispers" then
			Channels.OpenConv(W.lastConv)
		end
	end)
	whisper.selected:SetShown(W.mode == "whispers")
	local unread = false
	for _, c in pairs(convs) do
		if c.unread and not c.closed then
			unread = true
		end
	end
	whisper.unread:SetShown(unread)
	if unread then
		whisper.pulse:Play()
	else
		whisper.pulse:Stop()
	end
	whisper:Show()
	for i = 3, #f.sideTabs do
		f.sideTabs[i]:Hide()
	end
end

-- a whisper came or went: its tab (and the Whispers side tab), lit until it
-- is opened
function Channels.Heard(conv)
	local f = W.frame
	if not (f and f:IsShown()) then
		return
	end
	if W.mode == "whispers" then
		if W.conv == conv.with then
			conv.unread = nil
		elseif not W.conv then
			Channels.OpenConv(conv.with)
			return
		end
		Channels.ConvTabs()
	end
	Channels.Side()
end

-- the pin button: lit while this tab is pinned
function Channels.PinButton()
	local f = W.frame
	if not f then
		return
	end
	local on = CurrentTab().pinned and true or false
	if HasAtlas(ART.pin) then
		f.pin.icon:SetAtlas(ART.pin)
		f.pin.icon:SetDesaturated(not on)
		f.pin:SetAlpha(on and 1 or 0.6)
	else
		f.pin.icon:SetTexture(on and LOCK_ON or LOCK_OFF)
		f.pin:SetAlpha(on and 1 or 0.7)
	end
end

local function PinnedTab()
	for _, t in ipairs(TabList()) do
		if t.pinned then
			return t
		end
	end
end

-- the pinned view: the pinned tab's messages, text only over Speak!'s look,
-- where the window is; clicks go through to the game
-- where the pinned view is: kept between sessions
local function SaveView(view)
	db.pinBox = { x = view:GetLeft(), y = view:GetTop(), w = view:GetWidth(), h = view:GetHeight() }
end

-- the saved place, or the window's own the first time
local function PlaceView(view)
	local box = type(db.pinBox) == "table" and db.pinBox
	if not (box and box.x and box.y) then
		local g = W.frame.ground
		local k = g:GetEffectiveScale() / UIParent:GetEffectiveScale()
		local l, t = g:GetLeft(), g:GetTop()
		if not (l and t) then
			return
		end
		box = { x = l * k, y = t * k, w = g:GetWidth() * k, h = g:GetHeight() * k }
		db.pinBox = box
	end
	view:ClearAllPoints()
	view:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", box.x, box.y)
	view:SetSize(box.w or 300, box.h or 200)
end

function Channels.View()
	if W.view then
		return W.view
	end
	Channels.Frame()
	local view = CreateFrame("Frame", "SetGoSpeakChannelsPin", UIParent)
	view:SetFrameStrata("LOW")
	view:SetClampedToScreen(true)
	view:SetMovable(true)
	view:SetResizable(true)
	if view.SetResizeBounds then
		view:SetResizeBounds(200, 80, 900, 700)
	elseif view.SetMinResize then
		view:SetMinResize(200, 80)
		view:SetMaxResize(900, 700)
	end
	view:EnableMouse(true)
	view:RegisterForDrag("LeftButton")
	-- Speak!'s look (soft or bordered), only while the mouse is over it
	view.skin = Skin.New(view, "BACKGROUND", -8)
	view.skin:SetColor(0, 0, 0)
	view.skin:SetBorderColor(1, 1, 1)
	view.skin:Place(view, { 0, 0, 0, 0 }, { 0, 0, 0, 0 })
	local text = CreateFrame("ScrollingMessageFrame", nil, view)
	text:SetPoint("TOPLEFT", 14, -12)
	text:SetPoint("BOTTOMRIGHT", -14, 30)
	text:SetFontObject(channelFont)
	text:SetJustifyH(db.pinJustify or "LEFT")
	text:SetFading(false)
	text:SetMaxLines(300)
	text:EnableMouse(false)
	if text.EnableMouseWheel then
		text:EnableMouseWheel(false)
	end
	view.text = text
	local level = text:GetFrameLevel() + 5

	-- the cog, top right, only with the mouse over it: the options
	local tab = CreateFrame("Button", nil, view)
	tab:SetSize(22, 22)
	tab:SetPoint("TOPRIGHT", -6, -6)
	tab:SetFrameLevel(level)
	if HasAtlas(EDIT_COG:format("")) then
		tab:SetNormalAtlas(EDIT_COG:format(""))
		tab:SetPushedAtlas(EDIT_COG:format("pressed-"))
		tab:SetHighlightAtlas(EDIT_COG:format("hover-"), "BLEND")
	else
		local icon = tab:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()
		icon:SetTexture("Interface\\Icons\\inv_misc_gear_01")
	end
	tab:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	NewFade(tab)
	view.tabButton = tab

	-- the eye: hides the window or shows it again; it stays, fainter
	local eye = CreateFrame("Button", nil, view)
	eye:SetSize(28, 28)
	eye:SetPoint("BOTTOMLEFT", 4, 4)
	eye:SetFrameLevel(level)
	local icon = eye:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	local function First(list)
		for _, name in ipairs(list) do
			if HasAtlas(name) then
				return name
			end
		end
	end
	local atlasOn, atlasOff = First(ART.eye), First(ART.eyeOff)
	-- hidden: the eye; shown: the eye struck through (or the eye in red)
	function eye.Update(hidden)
		icon:SetVertexColor(1, 1, 1)
		if hidden and atlasOn or not hidden and atlasOff then
			icon:SetTexCoord(0, 1, 0, 1)
			icon:SetDesaturated(false)
			icon:SetAtlas(hidden and atlasOn or atlasOff)
			return
		end
		if atlasOn then
			icon:SetAtlas(atlasOn)
		else
			icon:SetTexture(EYE_FILE)
			icon:SetTexCoord(0, 0.125, 0, 0.25)
			icon:SetDesaturated(true)
		end
		if not hidden then
			icon:SetVertexColor(1, 0.4, 0.4)
		end
	end
	NewFade(eye)
	eye:SetAlpha(EYE_REST)
	view.eye = eye

	-- the chat's own grip, bottom right: makes it bigger or smaller
	local grip = CreateFrame("Button", nil, view)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", -4, 4)
	grip:SetFrameLevel(level)
	grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	NewFade(grip)
	view.grip = grip

	-- fading in and out; the eye stays, fainter
	local function Hover(on, now)
		local d = now and 0 or 0.25
		local hidden = db.pinHidden
		local alpha = tonumber(db.pinAlpha) or 1
		local skinOn = on and not hidden
		view.skin:FadeTo(skinOn and alpha or 0, d, skinOn and 1 or 0)
		FadeTo(tab, skinOn and 1 or 0, d)
		tab:EnableMouse(skinOn)
		local gripOn = skinOn and not db.pinLocked
		FadeTo(grip, gripOn and 1 or 0, d)
		grip:EnableMouse(gripOn)
		FadeTo(eye, on and 1 or EYE_REST, d)
	end
	view.Hover = Hover

	local function Over()
		return view.moving or (view.menu and view.menu.IsShown and view.menu:IsShown())
			or view:IsMouseOver() or tab:IsMouseOver() or eye:IsMouseOver()
	end
	local function Enter()
		Hover(true)
		view:SetScript("OnUpdate", function(v)
			if not Over() then
				v:SetScript("OnUpdate", nil)
				Hover(false)
			end
		end)
	end
	view:SetScript("OnEnter", Enter)
	tab:SetScript("OnEnter", Enter)
	eye:SetScript("OnEnter", function(self)
		Enter()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(db.pinHidden and L.PIN_SHOW or L.PIN_HIDE)
		GameTooltip:Show()
	end)
	eye:SetScript("OnLeave", GameTooltip_Hide)

	-- hidden: only the eye, faint; clicks go through everywhere else
	function view.ApplyHidden()
		local hidden = db.pinHidden and true or false
		text:SetShown(not hidden)
		tab:SetShown(not hidden)
		view:EnableMouse(not hidden)
		eye.Update(hidden)
		Hover(Over() and true or false, true)
	end
	eye:SetScript("OnClick", function(self)
		db.pinHidden = not db.pinHidden or nil
		view.ApplyHidden()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(db.pinHidden and L.PIN_SHOW or L.PIN_HIDE)
		GameTooltip:Show()
	end)

	-- moving: by the window or its tab, unless locked
	local function DragStart()
		if db.pinLocked then
			return
		end
		view.moving = true
		view:StartMoving()
	end
	local function DragStop()
		if not view.moving then
			return
		end
		view:StopMovingOrSizing()
		view.moving = nil
		SaveView(view)
	end
	view:SetScript("OnDragStart", DragStart)
	view:SetScript("OnDragStop", DragStop)
	grip:SetScript("OnMouseDown", function()
		if db.pinLocked then
			return
		end
		view.moving = true
		view:StartSizing("BOTTOMRIGHT")
	end)
	grip:SetScript("OnMouseUp", DragStop)

	-- right click on the tab: the ground's opacity, locked or not
	tab:SetScript("OnClick", function(self)
		view.menu = MenuUtil.CreateContextMenu(self, function(_, root)
			root:CreateTitle(view.tab and view.tab.name or "")
			local opacity = root:CreateButton(L.PIN_OPACITY)
			for _, a in ipairs({ 0.25, 0.5, 0.75, 1 }) do
				opacity:CreateRadio(("%d%%"):format(a * 100), function()
					return (tonumber(db.pinAlpha) or 1) == a
				end, function()
					db.pinAlpha = a
					Hover(true, true)
					return MenuRefresh()
				end)
			end
			local justify = root:CreateButton(L.PIN_JUSTIFY)
			for _, j in ipairs({ { "LEFT", L.PIN_LEFT }, { "CENTER", L.PIN_CENTER }, { "RIGHT", L.PIN_RIGHT } }) do
				justify:CreateRadio(j[2], function()
					return (db.pinJustify or "LEFT") == j[1]
				end, function()
					db.pinJustify = j[1]
					text:SetJustifyH(j[1])
					return MenuRefresh()
				end)
			end
			root:CreateCheckbox(L.PIN_LOCK, function()
				return db.pinLocked and true or false
			end, function()
				db.pinLocked = not db.pinLocked or nil
				Hover(true, true)
			end)
			-- closing it unpins the tab
			root:CreateDivider()
			root:CreateButton(L.PIN_CLOSE, function()
				for _, t in ipairs(TabList()) do
					t.pinned = nil
				end
				Channels.PinButton()
				Channels.UpdatePin()
			end)
		end)
	end)

	view:SetScript("OnHide", function(self)
		self:SetScript("OnUpdate", nil)
		self.moving = nil
		Hover(false, true)
	end)
	Hover(false, true)
	view:Hide()
	W.view = view
	return view
end

-- shown while a tab is pinned and the window is closed
function Channels.UpdatePin()
	local f = W.frame
	local tab = Channels.on and f and PinnedTab()
	if not tab or f:IsShown() then
		if W.view then
			W.view:Hide()
		end
		return
	end
	local view = Channels.View()
	view.tab = tab
	-- no ground, no border: only the messages, over the game. It starts
	-- empty: only what comes from now on, gone after the tab's time.
	PlaceView(view)
	view.skin:Show(Look())
	view.ApplyHidden()
	local fade = tab.fade or 60
	view.text:SetFading(fade > 0)
	if fade > 0 then
		view.text:SetTimeVisible(fade)
		view.text:SetFadeDuration(3)
	end
	view.text:Clear()
	view:Show()
end

-- the window where Blizzard opens its own, unless moved since the last reload
local function Place(f)
	if SetGo and SetGo.ScaleFrame then
		SetGo.ScaleFrame(f)
	end
	if not f.moved then
		f:ClearAllPoints()
		f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -116)
	end
end

-- Shift+click on an item, a recipe or a spell while the search has the
-- cursor: the link goes into the search, as it would into the chat
local function InsertLink(link)
	local f = W.frame
	local box = f and f:IsShown() and (f.search:HasFocus() and f.search or f.input:HasFocus() and f.input)
	if type(link) ~= "string" or not box then
		return
	end
	local now = GetTime()
	-- the game's two names for this call can both run for one click
	if W.linked == link and W.linkedAt == now then
		return
	end
	W.linked, W.linkedAt = link, now
	box:Insert(link)
end

-- Blizzard puts a quest's link in its own typing box when that is open;
-- else Shift+click takes the quest off the tracker. With the cursor in a
-- Board box the quest goes back on (a moment later, outside Blizzard's
-- click) and its link goes into the box.
local function BoardBox()
	local f = W.frame
	if not (f and f:IsShown()) then
		return
	end
	if f.search:HasFocus() then
		return f.search
	end
	if f.input:HasFocus() then
		return f.input
	end
end

-- the click went through to the tracker: undone (tracked again, or taken
-- off again), and the link goes into the box
local busy = false
local function QuestClicked(questID, undo)
	local box = BoardBox()
	if busy or not (box and questID and IsShiftKeyDown()) then
		return
	end
	C_Timer.After(0, function()
		busy = true
		if undo then
			pcall(undo, questID)
		end
		busy = false
		local link = GetQuestLink and GetQuestLink(questID)
		-- Blizzard may have sent it through the chat's own way already
		if link and W.linked ~= link then
			box:Insert(link)
		end
		W.linked = nil
	end)
end

local function OnQuestUntracked(questID)
	QuestClicked(questID, C_QuestLog.AddQuestWatch)
end

local function OnQuestTracked(questID)
	QuestClicked(questID, C_QuestLog.RemoveQuestWatch)
end

function Channels.Toggle()
	local f = Channels.Frame()
	if f:IsShown() then
		f:Hide()
		return
	end
	Place(f)
	SetupFont()
	f:Show()
	Channels.Select(W.tab)
	Channels.PinButton()
	UpdateCount()
end

-- the text size changed in Speak!'s page
function Channels.FontChanged()
	SetupFont()
	if W.frame and W.frame:IsShown() then
		Fill()
	end
	Channels.UpdatePin()
end

-- kept between sessions: what a tab with its history on shows
local function KeepSaved(entry)
	if entry.with then
		local c = convs[entry.with]
		return c and c.fav and not c.bn and true or false
	end
	for _, t in ipairs(TabList()) do
		if t.history ~= false and InTab(t, entry) then
			return true
		end
	end
	return false
end

local listener
function Channels.Start()
	if Channels.on then
		return
	end
	Channels.on = true
	if not listener then
		listener = CreateFrame("Frame")
		listener:SetScript("OnEvent", function(_, event, ...)
			if event == "CHAT_MSG_CHANNEL" then
				OnChannelMessage(...)
			elseif event == "CHANNEL_UI_UPDATE" then
				-- channels joined or left (a new zone): the dots follow
				if W.frame and W.frame:IsShown() then
					Channels.Dots()
				end
			else
				OnMessage(event, ...)
			end
		end)
		-- the hooks stay; with the window off they do nothing
		local main = DEFAULT_CHAT_FRAME or ChatFrame1
		if main and main.AddMessage then
			hooksecurefunc(main, "AddMessage", OnPrint)
		end
		if ChatEdit_InsertLink then
			hooksecurefunc("ChatEdit_InsertLink", InsertLink)
		end
		if ChatFrameUtil and ChatFrameUtil.InsertLink then
			hooksecurefunc(ChatFrameUtil, "InsertLink", InsertLink)
		end
		if C_QuestLog and C_QuestLog.RemoveQuestWatch and C_QuestLog.AddQuestWatch then
			hooksecurefunc(C_QuestLog, "RemoveQuestWatch", OnQuestUntracked)
			hooksecurefunc(C_QuestLog, "AddQuestWatch", OnQuestTracked)
		end
	end
	listener:RegisterEvent("CHAT_MSG_CHANNEL")
	pcall(listener.RegisterEvent, listener, "CHANNEL_UI_UPDATE")
	for event in pairs(GROUP_OF) do
		pcall(listener.RegisterEvent, listener, event)
	end
	if type(db.hidePrint) == "table" and next(db.hidePrint) then
		WrapChat()
	end
	-- a pinned tab shows from the start
	if PinnedTab() then
		local f = Channels.Frame()
		Place(f)
		SetupFont()
		Channels.UpdatePin()
	end
end

-- the window switched off in Speak!'s page: nothing is kept or shown
function Channels.Stop()
	if not Channels.on then
		return
	end
	Channels.on = false
	if listener then
		listener:UnregisterAllEvents()
	end
	if W.frame then
		W.frame:Hide()
	end
	Channels.UpdatePin()
end

-- the favourite conversations, kept with the character
function Channels.Load(saved)
	local favs = SetGoSpeakCharDB and SetGoSpeakCharDB.favs
	if type(favs) == "table" then
		for with, c in pairs(favs) do
			if type(with) == "string" and type(c) == "table" then
				Conversation(with, c.name, c.class).fav = true
			end
		end
	end
	Load(saved)
end
function Channels.Save()
	if SetGoSpeakCharDB then
		local favs = {}
		for with, c in pairs(convs) do
			if c.fav and not c.bn then
				favs[with] = { name = c.name, class = c.class }
			end
		end
		SetGoSpeakCharDB.favs = favs
	end
	return Save(KeepSaved)
end

-- the key in Blizzard's Key Bindings, SetGo! section
function SetGo_SpeakChannels()
	if not SetGo.ModuleOn(KEY) then
		SetGo.Print(L.OFF_IN_SETGO)
		return
	end
	if not Channels.on then
		SetGo.Print(L.CHANNELS_OFF)
		return
	end
	Channels.Toggle()
end

end -- the Board

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

-- Speak!'s page in SetGo!
function OpenSettings()
	if not (SetGo and SetGo.Open and SetGo.Select and SetGo.BuildPath) then
		if SetGo_Toggle then
			SetGo_Toggle()
		end
		return
	end
	SetGo.Open()
	for i, page in ipairs(SetGo.BuildPath("modules") or {}) do
		if page.key == "module_" .. KEY then
			SetGo.Select("modules", i)
			return
		end
	end
end

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
			if Channels.on then
				root:CreateButton(L.CHANNELS, Channels.Toggle)
			end
			root:CreateButton(L.MENU_SETTINGS, OpenSettings)
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
	local channels = Setting("channels", L.SET_CHANNELS, L.SET_CHANNELS_DESC, function(on)
		if on then
			Channels.Start()
		else
			Channels.Stop()
		end
	end)
	local channelsFont = Setting("channelsFont", L.SET_FONT, L.SET_FONT_DESC, Channels.FontChanged)
	items[#items + 1] = { kind = "header", name = L.SEC_CHANNELS }
	items[#items + 1] = { kind = "note", name = L.CHANNELS_NOTE }
	items[#items + 1] = { kind = "checkbox", setting = channels, settings = { channels }, name = L.SET_CHANNELS, tooltip = L.SET_CHANNELS_DESC, newKey = "board" }
	items[#items + 1] = { kind = "slider", setting = channelsFont, settings = { channelsFont }, name = L.SET_FONT, tooltip = L.SET_FONT_DESC, options = Formatted(10, 20, 10, Whole) }
	items[#items + 1] = { kind = "keybind", action = "SETGO_SPEAK_CHANNELS", name = L.KEY, tooltip = L.KEY_DESC, profileOnly = true }
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
events:RegisterEvent("PLAYER_LOGOUT")
events:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == ADDON then
			SetGoSpeakDB = type(SetGoSpeakDB) == "table" and SetGoSpeakDB or {}
			db = SetGoSpeakDB
			SetGoSpeakCharDB = type(SetGoSpeakCharDB) == "table" and SetGoSpeakCharDB or {}
			Channels.Load(SetGoSpeakCharDB.history)
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
	elseif event == "PLAYER_LOGOUT" then
		-- only when it listened this session; otherwise what was kept stays
		if Channels.on and SetGoSpeakCharDB then
			SetGoSpeakCharDB.history = Channels.Save()
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
		if Get("channels") then
			Channels.Start()
		end
		-- after Blizzard has set up the chat windows
		C_Timer.After(0, Start)
	end
end)
