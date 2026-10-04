local ADDON, ns = ...

local L = {
	TITLE = "Quick!",
	HOW = "A small menu by the minimap for the settings you change in the moment. Open it with its key or from the SetGo! minimap button menu. What you change there applies at once and never goes into your SetGo! profiles: applying a profile puts its own values back. It closes in combat.",
	SEC_CONTROLS = "Controls",
	KEY = "Quick! key",
	KEY_DESC = "Opens and closes Quick!. Click, then press a key; right click clears it. It does nothing in combat.",
	BINDING = "Open or close Quick!",
	ENEMY = "Enemy nameplates",
	ENEMY_DESC = "Shows nameplates over enemies.",
	FRIEND = "Friendly player nameplates",
	FRIEND_DESC = "Shows nameplates over friendly players.",
	NPC_NAMES = "NPC names",
	MASTER = "Master volume",
	MUSIC = "Music volume",
	QUIET = "Quiet!",
	QUIET_DESC = "Hides the world channels (General, Trade, Local Defense and the rest) from your chat windows. You stay in them. Click again and they come back to the windows they were in. Channels you made or joined yourself are left alone.",
	QUIET_ON = "Channels hidden",
	QUIET_OFF = "Channels shown",
	OFF_IN_SETGO = "Quick! is switched off. Switch it on in SetGo!, Modules.",
}
if GetLocale() == "ptBR" then
	L.HOW = "Um menu pequeno junto do minimapa para as definições que mudas no momento. Abre-se com a tecla ou no menu do botão do SetGo! no minimapa. O que mudares lá aplica-se logo e nunca vai para os perfis do SetGo!: aplicar um perfil repõe os valores dele. Fecha em combate."
	L.SEC_CONTROLS = "Controlos"
	L.KEY = "Tecla do Quick!"
	L.KEY_DESC = "Abre e fecha o Quick!. Clica e carrega numa tecla; clique direito para a limpar. Em combate não faz nada."
	L.BINDING = "Abrir ou fechar o Quick!"
	L.ENEMY = "Placas de nome dos inimigos"
	L.ENEMY_DESC = "Mostra as placas de nome por cima dos inimigos."
	L.FRIEND = "Placas de nome dos jogadores aliados"
	L.FRIEND_DESC = "Mostra as placas de nome por cima dos jogadores aliados."
	L.NPC_NAMES = "Nomes dos NPCs"
	L.MASTER = "Volume geral"
	L.MUSIC = "Volume da música"
	L.QUIET_DESC = "Esconde os canais do mundo (Geral, Comércio, Defesa Local e os outros) das tuas janelas de chat. Continuas neles. Clica outra vez e voltam às janelas onde estavam. Os canais que criaste ou onde entraste por conta própria ficam como estão."
	L.QUIET_ON = "Canais escondidos"
	L.QUIET_OFF = "Canais visíveis"
	L.OFF_IN_SETGO = "O Quick! está desligado. Liga-o no SetGo!, em Módulos."
end
BINDING_HEADER_SETGO = "SetGo!"
BINDING_NAME_SETGO_QUICK = L.BINDING

--------------------------------------------------------------------------------
-- Quick!: a small window by the minimap with a few settings that apply at
-- once (nameplates, NPC names, volume) and Quiet!, which hides the world
-- channels from the chat windows. It closes in combat and doesn't come back
-- by itself; its key does nothing in combat.
-- Nothing changed here goes into a SetGo! profile. Profiles compare and save
-- the value a module holds (RestoreValue), as with Look!: the first time
-- Quick! changes a setting a profile keeps, the value before is held, and the
-- profile keeps seeing that one. The hold ends when a profile is applied,
-- when Quick! puts the setting back where it was, or when the setting is
-- changed anywhere else (that change is the player's). Holds are kept in
-- SetGoQuickCharDB.holds for settings stored per character, and in
-- SetGoQuickDB.holds for the rest. Quiet! remembers the channels it took out
-- of each chat window in SetGoQuickCharDB.quiet.
-- Switched off in SetGo!: only the settings page is here (and anything left
-- hidden or held is undone at login).
--------------------------------------------------------------------------------

local KEY = "quick"
local ON = SetGo.ModuleOn(KEY)
local Try, Same = SetGo.Try, SetGo.Same

local db, charDB -- SetGoQuickDB (account), SetGoQuickCharDB (character)

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

-- Blizzard's own setting objects, found once they exist
local found = {}
local function BlizzardSetting(var)
	if found[var] then
		return found[var]
	end
	local s = Settings and Settings.GetSetting and Try(Settings.GetSetting, var)
	if type(s) == "table" and type(s.GetValue) == "function" then
		found[var] = s
		return s
	end
end

local ENEMY_CVAR = "nameplateShowEnemies"
-- older clients call it nameplateShowFriends
local function FriendCVar()
	if C_CVar.GetCVar("nameplateShowFriendlyPlayers") ~= nil then
		return "nameplateShowFriendlyPlayers"
	end
	return "nameplateShowFriends"
end
local NPC_NAMES = "PROXY_NPC_NAMES"

-- the settings a profile can keep: the ones Quick! holds
local function Holdable(var)
	return var == ENEMY_CVAR or var == FriendCVar() or var == NPC_NAMES
end

-- the value now, as text: the proxy setting's or the CVar's
local function Live(var)
	if var == NPC_NAMES then
		local s = BlizzardSetting(var)
		local v = s and Try(s.GetValue, s)
		return v ~= nil and tostring(v) or nil
	end
	return C_CVar.GetCVar(var)
end

--------------------------------------------------------------------------------
-- Holds
--------------------------------------------------------------------------------

local function PerCharacter(var)
	if C_CVar.GetCVarInfo then
		local ok, value, _, _, perCharacter = pcall(C_CVar.GetCVarInfo, var)
		if ok and value ~= nil then
			return perCharacter and true or false
		end
	end
	-- a proxy setting writes several CVars: kept with the character
	return true
end

local function Holds(var)
	local store = PerCharacter(var) and charDB or db
	if type(store.holds) ~= "table" then
		store.holds = {}
	end
	return store.holds
end

local function FindHold(var)
	if type(var) ~= "string" or not db then
		return
	end
	local lower = var:lower()
	for _, store in ipairs({ charDB, db }) do
		if type(store.holds) == "table" then
			for name, hold in pairs(store.holds) do
				if type(name) == "string" and name:lower() == lower and type(hold) == "table" then
					return name, store.holds, hold
				end
			end
		end
	end
end

-- a hold whose setting changed since Quick! wrote it ends: that change came
-- from somewhere else
local function ValidHold(var)
	local name, holds, hold = FindHold(var)
	if not name then
		return
	end
	local live = Live(name)
	if live ~= nil and not Same(live, hold.wrote) then
		holds[name] = nil
		return
	end
	return name, holds, hold
end

-- Quick! wrote a setting: before and after, as text
local function Remember(var, before, after)
	if not Holdable(var) or after == nil then
		return
	end
	local name, holds, hold = ValidHold(var)
	if not name then
		if before == nil or Same(before, after) then
			return
		end
		Holds(var)[var] = { base = tostring(before), wrote = tostring(after) }
	elseif Same(hold.base, after) then
		-- back where it was
		holds[name] = nil
	else
		hold.wrote = tostring(after)
	end
end

-- the core asks: the value profiles compare and save
local function RestoreValue(var)
	if not ON then
		return nil
	end
	local _, _, hold = ValidHold(var)
	return hold and hold.base or nil
end

-- the core applied a profile with this setting: the hold ends
local function SetRestoreValue(var)
	local name, holds = FindHold(var)
	if name then
		holds[name] = nil
		return true
	end
	return false
end

local function ClearHolds()
	if db then
		db.holds = nil
	end
	if charDB then
		charDB.holds = nil
	end
end

--------------------------------------------------------------------------------
-- Reading and writing
--------------------------------------------------------------------------------

local function GetBool(var)
	if C_CVar.GetCVarBool then
		return C_CVar.GetCVarBool(var) and true or false
	end
	return C_CVar.GetCVar(var) == "1"
end

local function SetBool(var, on)
	local before = C_CVar.GetCVar(var)
	if before == nil then
		return
	end
	C_CVar.SetCVar(var, on and "1" or "0")
	Remember(var, before, C_CVar.GetCVar(var))
end

local function GetNumber(var, fallback)
	return tonumber(C_CVar.GetCVar(var)) or fallback
end

local function SetNumber(var, value)
	if C_CVar.GetCVar(var) ~= nil then
		C_CVar.SetCVar(var, tostring(value))
	end
end

-- NPC names: Blizzard's proxy setting, written straight to its own writer
-- (as SetGo! applies), so Blizzard's value changed callbacks don't run
-- tainted by us
local function GetNpcNames()
	local s = BlizzardSetting(NPC_NAMES)
	return s and tonumber(Try(s.GetValue, s))
end

local function SetNpcNames(value)
	local s = BlizzardSetting(NPC_NAMES)
	if not s then
		return
	end
	local before = Live(NPC_NAMES)
	if type(s.SetValueDerived) == "function" then
		pcall(s.SetValueDerived, s, value)
	else
		pcall(s.SetValue, s, value, true)
	end
	Remember(NPC_NAMES, before, Live(NPC_NAMES))
end

-- Blizzard's own words for the options, in Blizzard's order
local function NpcOptions()
	local G = SetGo.G
	return {
		{ value = 1, label = G("NPC_NAMES_DROPDOWN_TRACKED", "Tracked"), tooltip = G("NPC_NAMES_DROPDOWN_TRACKED_TOOLTIP") },
		{ value = 2, label = G("NPC_NAMES_DROPDOWN_HOSTILE", "Hostile"), tooltip = G("NPC_NAMES_DROPDOWN_HOSTILE_TOOLTIP") },
		{ value = 3, label = G("NPC_NAMES_DROPDOWN_INTERACTIVE", "Interactive"), tooltip = G("NPC_NAMES_DROPDOWN_INTERACTIVE_TOOLTIP") },
		{ value = 4, label = G("NPC_NAMES_DROPDOWN_ALL", "All"), tooltip = G("NPC_NAMES_DROPDOWN_ALL_TOOLTIP") },
		{ value = 5, label = G("NPC_NAMES_DROPDOWN_NONE", "None"), tooltip = G("NPC_NAMES_DROPDOWN_NONE_TOOLTIP") },
	}
end

--------------------------------------------------------------------------------
-- Quiet!: the world channels out of the chat windows (the player stays in
-- them), and back into the same windows
--------------------------------------------------------------------------------

local WORLD_CHANNELS = { "General", "Trade", "LocalDefense", "WorldDefense", "LookingForGroup", "GuildRecruitment", "Services", "NewcomerChat" }

local function GameChannels()
	local set = {}
	for _, name in ipairs(WORLD_CHANNELS) do
		set[name:lower()] = true
	end
	if EnumerateServerChannels then
		for _, name in ipairs({ EnumerateServerChannels() }) do
			if type(name) == "string" then
				set[name:lower()] = true
			end
		end
	end
	return set
end

local function ChatWindow(id)
	local f = _G["ChatFrame" .. id]
	return f and type(f.channelList) == "table" and f or nil
end

local function InWindow(f, name)
	for _, v in pairs(f.channelList) do
		if type(v) == "string" and v:lower() == name:lower() then
			return true
		end
	end
	return false
end

local function RemoveFrom(f, name)
	local fn = f.RemoveChannel or ChatFrame_RemoveChannel
	if fn then
		pcall(fn, f, name)
	end
end

local function AddTo(f, name)
	local fn = f.AddChannel or ChatFrame_AddChannel
	if fn then
		pcall(fn, f, name)
	end
end

local function IsQuiet()
	return charDB and type(charDB.quiet) == "table" and charDB.quiet.on == true
end

local function QuietOn()
	local game = GameChannels()
	local windows = {}
	for id = 1, NUM_CHAT_WINDOWS or 10 do
		local f = ChatWindow(id)
		if f then
			local names = {}
			for _, v in pairs(f.channelList) do
				if type(v) == "string" and game[v:lower()] then
					names[#names + 1] = v
				end
			end
			for _, name in ipairs(names) do
				RemoveFrom(f, name)
			end
			if #names > 0 then
				windows[id] = names
			end
		end
	end
	charDB.quiet = { on = true, windows = windows }
end

local function QuietOff()
	local quiet = charDB and charDB.quiet
	if type(quiet) == "table" and type(quiet.windows) == "table" then
		for id, names in pairs(quiet.windows) do
			local f = ChatWindow(tonumber(id) or 0)
			if f and type(names) == "table" then
				for _, name in ipairs(names) do
					if not InWindow(f, name) then
						AddTo(f, name)
					end
				end
			end
		end
	end
	if charDB then
		charDB.quiet = nil
	end
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

local FRAME_W = 260
local PAD = 14
local CW = FRAME_W - 2 * PAD - 10
local TOP = 30

local frame
local refreshers, fullRefreshers = {}, {}

local function Sound(kit, fallback)
	if SetGo.Sound then
		SetGo.Sound(kit, fallback)
	end
end

local function TipScripts(region, title, text, hook)
	local function Enter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(title, 1, 1, 1)
		if text then
			GameTooltip:AddLine(text, 1, 0.82, 0, true)
		end
		GameTooltip:Show()
	end
	local function Leave()
		GameTooltip:Hide()
	end
	if hook then
		region:HookScript("OnEnter", Enter)
		region:HookScript("OnLeave", Leave)
	else
		region:SetScript("OnEnter", Enter)
		region:SetScript("OnLeave", Leave)
	end
end

local function Refresh(full)
	for _, f in ipairs(refreshers) do
		pcall(f)
	end
	if full then
		for _, f in ipairs(fullRefreshers) do
			pcall(f)
		end
	end
end

local function Checkbox(y, label, tip, get, set)
	local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	cb:SetSize(26, 26)
	cb:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -y)
	if cb.text then
		cb.text:SetText("")
	end
	local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	fs:SetPoint("LEFT", cb, "RIGHT", 2, 1)
	fs:SetWidth(CW - 28)
	fs:SetJustifyH("LEFT")
	fs:SetText(label)
	TipScripts(cb, label, tip)
	cb:SetScript("OnClick", function(self)
		Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		set(self:GetChecked() and true or false)
		Refresh()
	end)
	refreshers[#refreshers + 1] = function()
		cb:SetChecked(get() and true or false)
	end
	return y + 28
end

local function Label(y, text)
	local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fs:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD + 4, -y)
	fs:SetWidth(CW)
	fs:SetJustifyH("LEFT")
	fs:SetText(text)
	return y + math.max(fs:GetStringHeight(), 12) + 5
end

local function Dropdown(y, label, tip, options, get, set)
	y = Label(y, label)
	local dd = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
	dd:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD + 4, -y)
	dd:SetWidth(CW - 4)
	TipScripts(dd, label, tip, true)
	refreshers[#refreshers + 1] = function()
		dd:SetupMenu(function(_, root)
			for _, opt in ipairs(options()) do
				local desc = root:CreateRadio(opt.label, function()
					return Same(get(), opt.value)
				end, function()
					set(opt.value)
				end)
				if opt.tooltip and desc and desc.SetTooltip then
					desc:SetTooltip(function(tooltip)
						GameTooltip_SetTitle(tooltip, opt.label)
						GameTooltip_AddNormalLine(tooltip, opt.tooltip)
					end)
				end
			end
		end)
	end
	frame.dropdowns = frame.dropdowns or {}
	frame.dropdowns[#frame.dropdowns + 1] = dd
	return y + 30
end

local function Percent(value)
	return ("%d%%"):format(math.floor((tonumber(value) or 0) * 100 + 0.5))
end

local function Slider(y, label, var, fallback)
	y = Label(y, label)
	local slider = CreateFrame("Frame", nil, frame, "MinimalSliderWithSteppersTemplate")
	slider:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD + 4, -y)
	slider:SetSize(CW - 50, 20)
	local formatters
	if MinimalSliderWithSteppersMixin and MinimalSliderWithSteppersMixin.Label then
		formatters = { [MinimalSliderWithSteppersMixin.Label.Right] = Percent }
	end
	local busy = false
	slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
		if not busy then
			SetNumber(var, value)
		end
	end, slider)
	-- only when the window opens: refreshing while dragging would fight it
	fullRefreshers[#fullRefreshers + 1] = function()
		busy = true
		local value = math.max(0, math.min(1, GetNumber(var, fallback)))
		slider:Init(value, 0, 1, 100, formatters)
		busy = false
	end
	return y + 28
end

local function QuietRow(y)
	y = y + 6
	local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	b:SetSize(110, 24)
	b:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD + 2, -y)
	b:SetText(L.QUIET)
	TipScripts(b, L.QUIET, L.QUIET_DESC)
	local status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	status:SetPoint("LEFT", b, "RIGHT", 10, 0)
	status:SetJustifyH("LEFT")
	b:SetScript("OnClick", function()
		Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		if IsQuiet() then
			QuietOff()
		else
			QuietOn()
		end
		Refresh()
	end)
	refreshers[#refreshers + 1] = function()
		local quiet = IsQuiet()
		status:SetText(quiet and L.QUIET_ON or L.QUIET_OFF)
		if quiet then
			b:LockHighlight()
		else
			b:UnlockHighlight()
		end
	end
	return y + 24
end

-- By the minimap, on the side with room (Edit Mode can move it): open to
-- its right when it sits in the left half of the screen, and level with its
-- top or bottom edge, whichever is nearer the screen edge.
local function Place()
	frame:ClearAllPoints()
	local mm = Minimap
	local mx, my
	if mm and mm:IsVisible() then
		mx, my = mm:GetCenter()
	end
	if not mx then
		frame:SetPoint("CENTER")
		return
	end
	local scale = mm:GetEffectiveScale() / UIParent:GetEffectiveScale()
	mx, my = mx * scale, my * scale
	local ux, uy = UIParent:GetCenter()
	local v = my >= uy and "TOP" or "BOTTOM"
	if mx < ux then
		frame:SetPoint(v .. "LEFT", mm, v .. "RIGHT", 10, 0)
	else
		frame:SetPoint(v .. "RIGHT", mm, v .. "LEFT", -10, 0)
	end
end

local function CloseMenus()
	for _, dd in ipairs(frame and frame.dropdowns or {}) do
		if dd.CloseMenu then
			pcall(dd.CloseMenu, dd)
		end
	end
end

local function Build()
	frame = CreateFrame("Frame", "SetGoQuickFrame", UIParent, "ButtonFrameTemplate")
	frame:SetFrameStrata("HIGH")
	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	Try(ButtonFrameTemplate_HidePortrait, frame)
	Try(ButtonFrameTemplate_HideButtonBar, frame)
	Try(frame.SetTitle, frame, L.TITLE)
	if type(frame.Inset) == "table" then
		frame.Inset:ClearAllPoints()
		frame.Inset:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -24)
		frame.Inset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 4)
	end

	local y = TOP
	y = Checkbox(y, L.ENEMY, L.ENEMY_DESC, function()
		return GetBool(ENEMY_CVAR)
	end, function(on)
		SetBool(ENEMY_CVAR, on)
	end)
	y = Checkbox(y, L.FRIEND, L.FRIEND_DESC, function()
		return GetBool(FriendCVar())
	end, function(on)
		SetBool(FriendCVar(), on)
	end)
	-- only when this client has Blizzard's NPC names setting
	if BlizzardSetting(NPC_NAMES) then
		y = y + 4
		y = Dropdown(y, SetGo.G("SHOW_NPC_NAMES", L.NPC_NAMES), SetGo.G("OPTION_TOOLTIP_NPC_NAMES_DROPDOWN"), NpcOptions, GetNpcNames, function(value)
			SetNpcNames(value)
			Refresh()
		end)
	end
	y = y + 4
	y = Slider(y, SetGo.G("MASTER_VOLUME", L.MASTER), "Sound_MasterVolume", 1)
	y = Slider(y, SetGo.G("MUSIC_VOLUME", L.MUSIC), "Sound_MusicVolume", 0.4)
	y = QuietRow(y)
	frame:SetSize(FRAME_W, y + 16)

	-- Esc, the X, the key and the menu close it
	if UISpecialFrames then
		tinsert(UISpecialFrames, "SetGoQuickFrame")
	end
	local close = frame.CloseButton or _G.SetGoQuickFrameCloseButton
	if close then
		close:SetScript("OnClick", function()
			frame:Hide()
		end)
	end

	-- the game's own keys (nameplates) or menus change these while open
	local waiting = false
	frame:SetScript("OnEvent", function()
		if waiting then
			return
		end
		waiting = true
		C_Timer.After(0.1, function()
			waiting = false
			if frame:IsShown() then
				Refresh()
			end
		end)
	end)
	frame:SetScript("OnShow", function(self)
		Sound("IG_MAINMENU_OPEN", 850)
		pcall(self.RegisterEvent, self, "CVAR_UPDATE")
		Refresh(true)
	end)
	frame:SetScript("OnHide", function(self)
		CloseMenus()
		pcall(self.UnregisterEvent, self, "CVAR_UPDATE")
		Sound("IG_MAINMENU_CLOSE", 851)
	end)
	frame:Hide()
end

local function Open()
	if InCombatLockdown() then
		return
	end
	if not frame then
		Build()
	end
	Place()
	frame:Show()
end

-- the key (Bindings.xml) and the SetGo! minimap button menu
function SetGo_ToggleQuick()
	if not ON then
		SetGo.Print(L.OFF_IN_SETGO)
		return
	end
	if InCombatLockdown() then
		return
	end
	if frame and frame:IsShown() then
		frame:Hide()
	else
		Open()
	end
end

--------------------------------------------------------------------------------
-- Page in SetGo!: only the key. Quick! has no options for profiles.
--------------------------------------------------------------------------------

local items
local function Items()
	if items then
		return items
	end
	items = {
		{ kind = "note", name = L.HOW, pageOnly = true },
		{ kind = "header", name = L.SEC_CONTROLS, pageOnly = true },
		{ kind = "keybind", action = "SETGO_QUICK", name = L.KEY, tooltip = L.KEY_DESC },
	}
	return items
end

SetGo.RegisterModule({ key = KEY, title = L.TITLE, items = Items,
	RestoreValue = RestoreValue, SetRestoreValue = SetRestoreValue })

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == ADDON then
			SetGoQuickDB = type(SetGoQuickDB) == "table" and SetGoQuickDB or {}
			SetGoQuickCharDB = type(SetGoQuickCharDB) == "table" and SetGoQuickCharDB or {}
			db, charDB = SetGoQuickDB, SetGoQuickCharDB
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		-- switched off: nothing stays held or hidden (the chat windows have
		-- their channels a moment after login)
		if not ON then
			ClearHolds()
			if IsQuiet() then
				C_Timer.After(2, QuietOff)
			end
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		-- combat: it closes and stays closed
		if frame and frame:IsShown() then
			frame:Hide()
		end
	end
end)
