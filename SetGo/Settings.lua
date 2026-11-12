local _, ns = ...
local L, W = ns.L, ns.Widgets
local Try = ns.Try

--------------------------------------------------------------------------------
-- SetGo!'s settings: one page on the window's right (the gear), with two of
-- Blizzard's tabs, Settings and Changelog. Settings: cards with a bronze
-- edge, as the Interface Tweaks: General, Chat messages, Modules (and each
-- module's own keys), Errors and About.
-- Also here: the chat messages' switches (ns.Print), the errors log
-- (SetGo!'s own, with or without BugGrabber) and the addon compartment.
--------------------------------------------------------------------------------

local T = {
	TITLE = "Settings",
	TAB_SETTINGS = "Settings",
	TAB_CHANGELOG = "Changelog",
	GENERAL = "General",
	COMPARTMENT = "Show in the addon compartment *",
	COMPARTMENT_DESC = "SetGo! in Blizzard's addon menu next to the minimap. Changes after a reload.",
	MUTE = "Mute SetGo!'s sounds",
	MUTE_DESC = "No sounds from SetGo!'s own windows: opening, turning pages, ticking boxes. Blizzard's sounds stay.",
	CHAT = "Chat messages",
	CHAT_AUTOSAVE = "Automatic saving",
	CHAT_AUTOSAVE_DESC = "When settings, keybinds, the layout or the addons are saved into the profile on their own.",
	CHAT_PROFILES = "Profiles",
	CHAT_PROFILES_DESC = "A profile applied, saved, deleted or imported; the bars put back.",
	CHAT_BACKUP = "Backups",
	CHAT_BACKUP_DESC = "A backup made, restored or imported.",
	CHAT_TWEAKS = "Interface Tweaks",
	CHAT_TWEAKS_DESC = "The Tracker's place, a quest filter that finds nothing.",
	CHAT_NOTE = "Warnings (in combat, not ready yet, no room, something failed) always show.",
	MODULES = "Modules",
	MODULES_ON = "Use SetGo!'s modules *",
	MODULES_ON_DESC = "Off: Fetch!, Look!, Speak! and Hide! are switched off and leave the profiles' Addons tab. Changes after a reload.",
	ERRORS = "Errors",
	ERRORS_COUNT = "%d errors kept (the last 20, from SetGo! and its modules).",
	ERRORS_NONE = "No errors kept.",
	ERRORS_SHOW = "Show",
	ERRORS_SHOW_DESC = "All the errors kept, as text, to copy and send in a report on GitHub (Issues).",
	ERRORS_CLEAR = "Clear",
	ERRORS_POPUP = "SetGo!'s errors. Copy them (Ctrl+C) and open an issue on GitHub:\n%s",
	ABOUT = "About",
	VERSION = "Version %s (build %s)",
	CURSEFORGE = "CurseForge",
	CURSEFORGE_DESC = "SetGo!'s page on CurseForge, to copy.",
	POPUP_CURSEFORGE = "SetGo! on CurseForge. Copy the address (Ctrl+C):",
	RELOAD_LEGEND = "* These changes require a reload.",
	POPUP_RELOAD = "Reload the interface now?",
	NO_CHANGELOG = "No changelog in this version.",
	NEW_WINDOW_TIP = "SetGo!'s window has changed: your profiles are on the left, each with its tabs, and SetGo!'s settings are under the gear.",
}

if GetLocale() == "ptBR" then
	T.TITLE = "Definições"
	T.TAB_SETTINGS = "Definições"
	T.TAB_CHANGELOG = "Changelog"
	T.GENERAL = "Geral"
	T.COMPARTMENT = "Mostrar no compartimento de addons *"
	T.COMPARTMENT_DESC = "O SetGo! no menu de addons da Blizzard ao lado do minimapa. Muda depois de recarregar."
	T.MUTE = "Silenciar os sons do SetGo!"
	T.MUTE_DESC = "Sem os sons das janelas do SetGo!: abrir, virar páginas, marcar caixas. Os sons da Blizzard ficam."
	T.CHAT = "Mensagens no chat"
	T.CHAT_AUTOSAVE = "Gravação automática"
	T.CHAT_AUTOSAVE_DESC = "Quando as definições, os atalhos, o layout ou os addons ficam gravados no perfil sozinhos."
	T.CHAT_PROFILES = "Perfis"
	T.CHAT_PROFILES_DESC = "Um perfil aplicado, guardado, apagado ou importado; as barras repostas."
	T.CHAT_BACKUP = "Backups"
	T.CHAT_BACKUP_DESC = "Um backup criado, restaurado ou importado."
	T.CHAT_TWEAKS = "Interface Tweaks"
	T.CHAT_TWEAKS_DESC = "O sítio do Tracker, um filtro de missões que não encontra nada."
	T.CHAT_NOTE = "Os avisos (em combate, ainda a carregar, sem lugar, algo falhou) aparecem sempre."
	T.MODULES = "Módulos"
	T.MODULES_ON = "Usar os módulos do SetGo! *"
	T.MODULES_ON_DESC = "Desligado: o Fetch!, o Look!, o Speak! e o Hide! ficam desligados e saem da aba Addons dos perfis. Muda depois de recarregar."
	T.ERRORS = "Erros"
	T.ERRORS_COUNT = "%d erros guardados (os últimos 20, do SetGo! e dos módulos)."
	T.ERRORS_NONE = "Nenhum erro guardado."
	T.ERRORS_SHOW = "Ver"
	T.ERRORS_SHOW_DESC = "Todos os erros guardados, em texto, para copiar e mandar num relatório no GitHub (Issues)."
	T.ERRORS_CLEAR = "Limpar"
	T.ERRORS_POPUP = "Os erros do SetGo!. Copia-os (Ctrl+C) e abre um issue no GitHub:\n%s"
	T.ABOUT = "Sobre"
	T.VERSION = "Versão %s (build %s)"
	T.CURSEFORGE = "CurseForge"
	T.CURSEFORGE_DESC = "A página do SetGo! no CurseForge, para copiar."
	T.POPUP_CURSEFORGE = "O SetGo! no CurseForge. Copia o endereço (Ctrl+C):"
	T.RELOAD_LEGEND = "* Estas alterações obrigam a recarregar."
	T.POPUP_RELOAD = "Recarregar a interface agora?"
	T.NO_CHANGELOG = "Sem changelog nesta versão."
	T.NEW_WINDOW_TIP = "A janela do SetGo! mudou: os teus perfis estão à esquerda, cada um com as suas abas, e as definições do SetGo! estão na engrenagem."
end
ns.SETTINGS_L = T

-- The address on CurseForge (nil: the button stays out)
ns.CURSEFORGE = nil

--------------------------------------------------------------------------------
-- Chat messages: each category can be switched off. A message is matched
-- by its text against the strings of its category; warnings aren't in any
-- and always show.
--------------------------------------------------------------------------------

local CHAT = {
	autosave = { "MSG_SETTINGS_IN_PROFILE", "MSG_SETTINGS_SHARED", "MSG_KEYS_IN_PRESET", "MSG_KEYS_SHARED",
		"MSG_LAYOUT_RECORDED", "MSG_ADDONS_IN_PROFILE", "MSG_SAVED_MODULES" },
	profiles = { "MSG_APPLIED", "MSG_SAVED", "MSG_DELETED", "MSG_PROFILE_IMPORTED", "MSG_PRESET_ACTIVE",
		"MSG_UI_REAPPLIED", "MSG_SKILLS_RESTORED", "MSG_LAYOUT_DELETED" },
	backup = { "MSG_BACKUP_CREATED", "MSG_BACKUP_RESTORED", "MSG_BACKUP_IMPORTED" },
	tweaks = {},
}
local CHAT_ORDER = { "autosave", "profiles", "backup", "tweaks" }

-- a format string as a Lua pattern ("%s saved" -> "^.-saved$")
local function Pattern(text)
	local p = text:gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1")
	p = p:gsub("%%%%[%d%.]*[sdf]", ".-")
	return "^" .. p .. "$"
end

local patterns
local function Patterns()
	if patterns then
		return patterns
	end
	patterns = {}
	for cat, keys in pairs(CHAT) do
		for _, key in ipairs(keys) do
			if type(L[key]) == "string" then
				patterns[#patterns + 1] = { cat = cat, p = Pattern(L[key]) }
			end
		end
	end
	for _, text in ipairs(ns.TWEAK_MESSAGES or {}) do
		patterns[#patterns + 1] = { cat = "tweaks", p = Pattern(text) }
	end
	return patterns
end

local function ChatOn(cat)
	local db = ns.db and ns.db.chat
	return not (db and db[cat] == false)
end

local print_ = ns.Print
function ns.Print(msg)
	if type(msg) == "string" and ns.db then
		for _, e in ipairs(Patterns()) do
			if msg:match(e.p) then
				if not ChatOn(e.cat) then
					return
				end
				break
			end
		end
	end
	print_(msg)
end

--------------------------------------------------------------------------------
-- Errors: SetGo!'s and its modules', the last 20, kept for the account.
-- With BugGrabber, from its callback; else from the game's error handler
-- (its handler goes on as before). Errors Try caught quietly come too, when
-- they come from SetGo!'s own code. Blocked actions (taint) too.
--------------------------------------------------------------------------------

local MAX_ERRORS = 20

local function Build()
	local get = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
	return (get and get("SetGo", "Version") or "?"), (get and get("SetGo", "X-Build") or "?")
end

local function Ours(text)
	return type(text) == "string" and text:find("SetGo", 1, true) ~= nil
end

local logging = false
function ns.LogError(msg, stack, quiet)
	if logging or not (ns.db and (Ours(msg) or Ours(stack))) then
		return
	end
	logging = true
	if type(ns.db.errors) ~= "table" then
		ns.db.errors = {}
	end
	local list = ns.db.errors
	local last = list[#list]
	if last and last.msg == msg then
		last.count = (last.count or 1) + 1
		last.at = time()
		logging = false
		return
	end
	local version, build = Build()
	list[#list + 1] = {
		at = time(), msg = tostring(msg), stack = stack and tostring(stack) or nil,
		version = version, build = build, quiet = quiet or nil, count = 1,
	}
	while #list > MAX_ERRORS do
		table.remove(list, 1)
	end
	if ns.RefreshSettingsPage then
		pcall(ns.RefreshSettingsPage)
	end
	logging = false
end

local function HookErrors()
	local grabber = _G.BugGrabber
	if grabber and grabber.RegisterCallback then
		local listener = {}
		grabber.RegisterCallback(listener, "BugGrabber_BugGrabbed", function(_, err)
			if type(err) == "table" then
				ns.LogError(err.message, err.stack)
			end
		end)
		return
	end
	local previous = geterrorhandler and geterrorhandler()
	if previous and seterrorhandler then
		seterrorhandler(function(msg, ...)
			pcall(ns.LogError, msg, debugstack and debugstack(3) or nil)
			return previous(msg, ...)
		end)
	end
end

local blocked = CreateFrame("Frame")
blocked:RegisterEvent("ADDON_ACTION_BLOCKED")
blocked:RegisterEvent("ADDON_ACTION_FORBIDDEN")
blocked:SetScript("OnEvent", function(_, event, addon, func)
	if Ours(addon) then
		ns.LogError(("%s: %s tried to call %s"):format(event, tostring(addon), tostring(func)),
			debugstack and debugstack(2) or nil)
	end
end)

local function ErrorsText()
	local lines = {}
	local version, build = Build()
	lines[#lines + 1] = ("SetGo! %s (build %s)"):format(version, build)
	for _, e in ipairs(ns.db.errors or {}) do
		lines[#lines + 1] = ""
		lines[#lines + 1] = ("[%s] %s%s"):format(date("%d/%m/%Y %H:%M", e.at or 0), e.msg or "?",
			(e.count or 1) > 1 and (" (x%d)"):format(e.count) or "")
		if e.stack then
			lines[#lines + 1] = e.stack
		end
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- The addon compartment: SetGo! registers itself there (no longer by its
-- .toc) while the option is on; off, after a reload it isn't there
--------------------------------------------------------------------------------

local function Compartment()
	local f = AddonCompartmentFrame
	if not (f and f.RegisterAddon) or (ns.db and ns.db.compartment == false) then
		return
	end
	Try(f.RegisterAddon, f, {
		text = "SetGo!",
		icon = ns.ICON,
		notCheckable = true,
		registerForAnyClick = true,
		func = function(_, inputData)
			if SetGo_Open then
				SetGo_Open(nil, inputData and inputData.buttonName)
			end
		end,
	})
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function()
	HookErrors()
	Compartment()
end)

--------------------------------------------------------------------------------
-- The page
--------------------------------------------------------------------------------

local function Confirm(text, onAccept)
	StaticPopup_Show("SETGO_CONFIRM", text, nil, { onAccept = onAccept })
end

local items
local function Items()
	if items then
		return items
	end
	local groups = {}
	-- General: the minimap icon, the window size and the keys (from SetGo!'s
	-- old page), the compartment and the sounds
	local general = { { kind = "header", name = T.GENERAL } }
	local keys = {}
	local scale
	for _, item in ipairs(ns.SetGoItems()) do
		if item.kind == "checkbox" and item.name ~= L.SETGO_MUTE then
			general[#general + 1] = item
		elseif item.kind == "cbslider" then
			scale = item
		elseif item.kind == "keybind" then
			keys[#keys + 1] = item
		end
	end
	local compartment = ns.Pseudo("SETGO_COMPARTMENT", T.COMPARTMENT, T.COMPARTMENT_DESC, true, function()
		return not (ns.db and ns.db.compartment == false)
	end, function(on)
		ns.db.compartment = on and true or false
		Confirm(T.POPUP_RELOAD, ReloadUI)
	end)
	general[#general + 1] = { kind = "checkbox", setting = compartment, settings = { compartment }, name = T.COMPARTMENT, tooltip = T.COMPARTMENT_DESC }
	local mute = ns.Pseudo("SETGO_MUTE_SOUNDS", T.MUTE, T.MUTE_DESC, false, function()
		return ns.db.mute == true
	end, function(on)
		ns.db.mute = on and true or nil
	end)
	general[#general + 1] = { kind = "checkbox", setting = mute, settings = { mute }, name = T.MUTE, tooltip = T.MUTE_DESC }
	if scale then
		general[#general + 1] = scale
	end
	for _, item in ipairs(keys) do
		general[#general + 1] = item
	end
	groups[#groups + 1] = general

	-- Chat messages
	local chat = { { kind = "header", name = T.CHAT } }
	for _, cat in ipairs(CHAT_ORDER) do
		local name, tip = T["CHAT_" .. cat:upper()], T["CHAT_" .. cat:upper() .. "_DESC"]
		local s = ns.Pseudo("SETGO_CHAT_" .. cat:upper(), name, tip, true, function()
			return ChatOn(cat)
		end, function(on)
			ns.db.chat = ns.db.chat or {}
			ns.db.chat[cat] = on and true or false
		end)
		chat[#chat + 1] = { kind = "checkbox", setting = s, settings = { s }, name = name, tooltip = tip }
	end
	chat[#chat + 1] = { kind = "note", name = T.CHAT_NOTE }
	groups[#groups + 1] = chat

	-- Modules: all of them on or off, then each module's own keys (and what
	-- a profile doesn't keep)
	local modulesOn = ns.Pseudo("SETGO_MODULES_ON", T.MODULES_ON, T.MODULES_ON_DESC, true, function()
		return not (ns.db and ns.db.modulesOff)
	end, function(on)
		ns.db.modulesOff = not on or nil
		Confirm(T.POPUP_RELOAD, ReloadUI)
	end)
	groups[#groups + 1] = {
		{ kind = "header", name = T.MODULES },
		{ kind = "checkbox", setting = modulesOn, settings = { modulesOn }, name = T.MODULES_ON, tooltip = T.MODULES_ON_DESC },
	}
	if not (ns.db and ns.db.modulesOff) then
		for _, def in ipairs(ns.modules or {}) do
			local ok, list = pcall(def.items or function() end)
			local own = { { kind = "header", name = def.title or def.key } }
			for _, item in ipairs(ok and type(list) == "table" and list or {}) do
				if item.kind == "keybind" or (item.pageOnly and item.kind ~= "note") then
					own[#own + 1] = item
				end
			end
			if #own > 1 then
				groups[#groups + 1] = own
			end
		end
	end

	-- Errors
	groups[#groups + 1] = {
		{ kind = "header", name = T.ERRORS },
		{ kind = "custom", build = function(page, y, width)
			local fs = W.Text(page, W.FONT_BODY, width - 200, "", 0.9)
			fs:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -(y + 6))
			local show = W.Button(page, 90, T.ERRORS_SHOW, function()
				ns.ui.Popup("SETGO_EXPORT", T.ERRORS_POPUP:format(ns.GITHUB .. "/issues"), { text = ErrorsText() })
			end, 22)
			show:SetPoint("TOPRIGHT", page, "TOPLEFT", width - 96, -(y + 2))
			W.TipScripts(show, T.ERRORS_SHOW, T.ERRORS_SHOW_DESC)
			local clear = W.Button(page, 90, T.ERRORS_CLEAR, function()
				ns.db.errors = {}
				ns.RefreshSettingsPage()
			end, 22)
			clear:SetPoint("LEFT", show, "RIGHT", 4, 0)
			table.insert(page.refreshers, function()
				local n = #(ns.db.errors or {})
				fs:SetText(n > 0 and T.ERRORS_COUNT:format(n) or T.ERRORS_NONE)
				show:SetEnabled(n > 0)
				clear:SetEnabled(n > 0)
			end)
			return y + 30
		end },
	}

	-- About: the version, the addresses to copy, the tour
	groups[#groups + 1] = {
		{ kind = "header", name = T.ABOUT },
		{ kind = "custom", build = function(page, y, width)
			local version, build = Build()
			local fs = W.Text(page, W.FONT_BODY, width, T.VERSION:format(version, build), 0.9)
			fs:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -(y + 4))
			y = y + 26
			local bw, gap = 150, 6
			local tour = W.Button(page, bw, L.TOUR_BUTTON, function()
				if InCombatLockdown() then
					ns.Print(L.MSG_COMBAT)
					return
				end
				ns.PlayTour()
			end, 24)
			tour:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
			W.TipScripts(tour, L.TOUR_BUTTON, L.TOUR_BUTTON_DESC)
			local git = W.Button(page, bw, L.SETGO_GITHUB, function()
				ns.ui.Popup("SETGO_EXPORT", L.POPUP_GITHUB, { text = ns.GITHUB })
			end, 24)
			git:SetPoint("LEFT", tour, "RIGHT", gap, 0)
			W.TipScripts(git, L.SETGO_GITHUB, L.SETGO_GITHUB_DESC)
			if ns.CURSEFORGE then
				local cf = W.Button(page, bw, T.CURSEFORGE, function()
					ns.ui.Popup("SETGO_EXPORT", T.POPUP_CURSEFORGE, { text = ns.CURSEFORGE })
				end, 24)
				cf:SetPoint("LEFT", git, "RIGHT", gap, 0)
				W.TipScripts(cf, T.CURSEFORGE, T.CURSEFORGE_DESC)
			end
			return y + 24 + 6
		end },
	}
	items = groups
	return items
end

local BRONZE = { 0.72, 0.53, 0.3 }

-- the groups in boxes with a bronze edge, one under the other
local function Boxes(page, groups, width)
	local backdrop = BackdropTemplateMixin and "BackdropTemplate" or nil
	local y, PAD_IN = 0, 10
	for _, group in ipairs(groups) do
		local box = CreateFrame("Frame", nil, page, backdrop)
		box:SetPoint("TOPLEFT", 0, -y)
		box:SetWidth(width)
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
		inner:SetWidth(width - PAD_IN * 2)
		inner.refreshers = page.refreshers
		local h = ns.ui.RenderItems(inner, group, 0, width - PAD_IN * 2)
		inner:SetHeight(h)
		box:SetHeight(h + PAD_IN * 2 - 6)
		y = y + h + PAD_IN * 2 - 6 + 10
	end
	return y
end

local page

local function ScrollTemplate()
	return C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("ScrollFrameTemplate")
		and "ScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
end

local function NewScroll(parent, width, height)
	local scroll = CreateFrame("ScrollFrame", nil, parent, ScrollTemplate())
	scroll:SetSize(width, height)
	if scroll.ScrollBar and scroll.ScrollBar.SetHideIfUnscrollable then
		scroll.ScrollBar:SetHideIfUnscrollable(true)
	end
	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(width, 10)
	child.refreshers = {}
	scroll:SetScrollChild(child)
	return scroll, child
end

local function ShowTab(tab)
	page.tab = tab
	for key, t in pairs(page.tabs) do
		if t.SetOn then
			t:SetOn(key == tab)
		end
	end
	page.settings:SetShown(tab == "settings")
	page.changelog:SetShown(tab == "changelog")
	page.legend:SetShown(tab == "settings")
end

function ns.CreateSettingsPage()
	local U = ns.ui
	local rightPage = U.rightPage
	page = CreateFrame("Frame", nil, rightPage)
	page:SetAllPoints()
	page:Hide()
	rightPage.settings = page
	local PAD, TOP = U.PAD, U.PAD_TOP
	local width = U.PAGE_W - PAD * 2
	local listW = width - 22

	page.title = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
	Try(page.title.SetFont, page.title, "Fonts\\FRIZQT__.TTF", 20, "")
	page.title:SetPoint("TOPLEFT", PAD + 4, -(TOP + 4))
	page.title:SetText(T.TITLE)

	-- the tabs: Blizzard's top tabs
	local HEAD_H, TAB_H = 50, 28
	page.tabs = {}
	local prev
	for _, tab in ipairs({ "settings", "changelog" }) do
		local t = CreateFrame("Button", nil, page, "PanelTopTabButtonTemplate")
		t:SetText(T["TAB_" .. tab:upper()])
		t:SetScript("OnClick", function()
			ns.Sound("IG_CHARACTER_INFO_TAB", 841)
			ShowTab(tab)
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
			t:SetPoint("BOTTOMLEFT", page, "TOPLEFT", PAD + 6, -(TOP + HEAD_H + TAB_H))
		end
		page.tabs[tab] = t
		prev = t
	end
	local rule = page:CreateTexture(nil, "ARTWORK")
	rule:SetHeight(1)
	rule:SetColorTexture(1, 1, 1, 0.25)
	rule:SetPoint("TOPLEFT", PAD, -(TOP + HEAD_H + TAB_H))
	rule:SetPoint("TOPRIGHT", -PAD, -(TOP + HEAD_H + TAB_H))

	local bodyTop = TOP + HEAD_H + TAB_H + 18
	local bodyH = 564 - bodyTop - 30

	-- Settings: the cards
	local scroll, child = NewScroll(page, listW, bodyH)
	scroll:SetPoint("TOPLEFT", PAD, -bodyTop)
	child:SetHeight(Boxes(child, Items(), listW - 2) + 4)
	page.settings, page.settingsChild = scroll, child
	page.legend = W.Text(page, W.FONT_SMALL, width, T.RELOAD_LEGEND, 0.8)
	page.legend:SetPoint("TOPLEFT", PAD, -(bodyTop + bodyH + 8))

	-- Changelog: the text of each version, newest first
	local cscroll, cchild = NewScroll(page, listW, bodyH + 22)
	cscroll:SetPoint("TOPLEFT", PAD, -bodyTop)
	local text = W.Text(cchild, W.FONT_BODY, listW - 8, "")
	text:SetPoint("TOPLEFT", 0, 0)
	local parts = {}
	for _, v in ipairs(ns.CHANGELOG or {}) do
		parts[#parts + 1] = "|cffffd100" .. (v.title or v.version or "") .. "|r\n\n" .. (v.text or "")
	end
	text:SetText(#parts > 0 and table.concat(parts, "\n\n\n") or T.NO_CHANGELOG)
	cchild:SetHeight((tonumber(text:GetStringHeight()) or 100) + 10)
	page.changelog = cscroll

	ShowTab("settings")
end

function ns.RefreshSettingsPage()
	if not (page and page:IsShown()) then
		return
	end
	for _, refresh in ipairs(page.settingsChild.refreshers) do
		refresh()
	end
end

-- the window size applies at once on this page (no Apply button here)
hooksecurefunc(ns, "Set", function(setting)
	if page and page:IsShown() and ns.ScaleWaiting and ns.ScaleWaiting() and ns.ApplyScaleDraft then
		C_Timer.After(0, function()
			Try(ns.ApplyScaleDraft)
		end)
	end
end)
