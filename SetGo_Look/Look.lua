local ADDON, ns = ...

local L = {
	TITLE = "Look!",
	SEC_CONTROLS = "Controls",
	KEY = "Look! key",
	KEY_DESC = "Turns Look! on and off. Click, then press a key; right click clears it.",
	RELEASE_KEY = "Hold to free the mouse",
	RELEASE_KEY_DESC = "While this key is held, Look! lets go of the mouse so you can click the interface. Keybinds that use the same modifier still work, but the mouse is freed while you press them.",
	NONE = "None",
	SEC_TARGETING = "Targeting",
	SOFT = "Soft targeting",
	SOFT_DESC = "What the game picks for you from what is in front of you. All: every type below. Enemies: left click targets the enemy nearest the middle of the view. Friends: out of combat, the friend in front of you gets a tooltip and an icon. NPCs and objects: right click talks to, loots or uses what the game highlights in front of you. A button whose type is off keeps its usual click.",
	SOFT_ENEMY = "Enemies",
	SOFT_FRIEND = "Friends",
	SOFT_INTERACT = "NPCs and objects",
	ICONS = "Soft target icons",
	ICONS_DESC = "Icons over what soft targeting picks, for the types switched on above.",
	SEC_CAMERA = "Camera",
	CAMERA = "Over the shoulder camera",
	CAMERA_DESC = "Moves the camera over the shoulder while Look! is on. Uses the game's experimental camera settings; the game's warning about them is not shown.",
	HOW = "Left click targets the enemy nearest the middle of the view. Right click talks to, loots or uses what the game highlights in front of you. The mouse is freed while a window is open, a spell waits for a ground target or an item is on the cursor.",
	BINDING = "Toggle Look!",
	OFF_IN_SETGO = "Look! is switched off for this character. Switch it on in SetGo!, Modules.",
}
if GetLocale() == "ptBR" then
	L.SEC_CONTROLS = "Controlos"
	L.KEY = "Tecla do Look!"
	L.KEY_DESC = "Liga e desliga o Look!. Clica e carrega numa tecla; clique direito para a limpar."
	L.RELEASE_KEY = "Manter para soltar o rato"
	L.RELEASE_KEY_DESC = "Enquanto carregas nesta tecla, o Look! larga o rato para poderes clicar na interface. As teclas de atalho com o mesmo modificador continuam a funcionar, mas o rato fica solto enquanto as usas."
	L.NONE = "Nenhuma"
	L.SEC_TARGETING = "Alvos"
	L.SOFT = "Soft targeting"
	L.SOFT_DESC = "O que o jogo escolhe por ti a partir do que está à tua frente. Tudo: todos os tipos em baixo. Inimigos: o clique esquerdo selecciona o inimigo mais perto do centro da vista. Aliados: fora de combate, o aliado à tua frente tem tooltip e ícone. NPCs e objectos: o clique direito fala, apanha o saque ou usa o que o jogo destaca à tua frente. Um botão cujo tipo está desligado mantém o clique normal."
	L.SOFT_ENEMY = "Inimigos"
	L.SOFT_FRIEND = "Aliados"
	L.SOFT_INTERACT = "NPCs e objectos"
	L.ICONS = "Ícones de soft target"
	L.ICONS_DESC = "Ícones por cima do que o soft targeting escolhe, para os tipos ligados acima."
	L.SEC_CAMERA = "Câmara"
	L.CAMERA = "Câmara por cima do ombro"
	L.CAMERA_DESC = "Põe a câmara por cima do ombro enquanto o Look! está ligado. Usa as opções experimentais de câmara do jogo; o aviso do jogo sobre elas não aparece."
	L.HOW = "O clique esquerdo selecciona o inimigo mais perto do centro da vista. O clique direito fala, apanha o saque ou usa o que o jogo destaca à tua frente. O rato fica solto enquanto há uma janela aberta, um feitiço à espera de alvo no chão ou um item no cursor."
	L.BINDING = "Ligar ou desligar o Look!"
	L.OFF_IN_SETGO = "O Look! está desligado nesta personagem. Liga-o no SetGo!, em Módulos."
end
BINDING_HEADER_SETGO = "SetGo!"
BINDING_NAME_SETGO_LOOK = L.BINDING

local db, charDB -- SetGoLookDB (account), SetGoLookCharDB (character)

--------------------------------------------------------------------------------
-- Look!: a key turns mouselook on, which hides the cursor, and a dot
-- marks the middle of the screen. Targets come from the game's soft
-- targeting (what is in front of you), not from the cursor, for the types the
-- player picks: left click picks the enemy nearest the middle of the view,
-- right click interacts with the highlighted NPC, object or loot. A button
-- whose type is off keeps its usual click. The cursor is never centred: the
-- game turns the camera by that jump, and there is no way to centre it on its
-- own. (The gamepad's free look hover, C_GamePad.SetAllowHoverEventsWithFreeLook,
-- would let the dot aim, but tested on Forever the mouseover stays empty while
-- the mouse turns the camera.)
-- It lets go of the mouse while a window is open, a spell waits for a ground
-- target, an item is on the cursor or the release key is held (the loot
-- window doesn't count while auto loot is taking the loot).
-- Nothing polls the interface: Blizzard's windows report showing and hiding
-- through hooks, the keys, cursor and loot through events. Only one call runs
-- ten times a second, to notice the game ending mouselook by itself, and a
-- full check once a second catches any window the hooks missed.
-- While it is on, the soft targeting picked, its tooltips and icons (and
-- optionally the over the shoulder camera) are on, and the rest of soft
-- targeting is off; the previous values are kept in
-- SetGoLookDB.restore (SetGoLookCharDB.restore for CVars stored per
-- character) and put back when it goes off, at logout, or at the next login
-- if the game closed while it was on. Each time it lets go of the mouse, a
-- ping shows where the cursor is.
--------------------------------------------------------------------------------

local AM = {}
ns.AM = AM

local ANY = (Enum and Enum.SoftTargetEnableFlags and Enum.SoftTargetEnableFlags.Any) or 3
-- "off" for keyboard and mouse, as Blizzard's own options write it
local GAMEPAD = (Enum and Enum.SoftTargetEnableFlags and Enum.SoftTargetEnableFlags.Gamepad) or 1
-- the soft targeting types, bits in db.soft; SOFT_ALL is its own choice in
-- the menu (exclusive: picking a type clears it), and the default
local SOFT_ENEMY, SOFT_FRIEND, SOFT_INTERACT = 1, 2, 4
local SOFT_ALL = 8
local SHOULDER = "1" -- test_cameraOverShoulder offset
-- 0 = straight ahead only, 1 = the front arc, 2 = anywhere in the tab
-- targeting area (the enemy default)
local FRIEND_ARC = "1"

-- The game's experimental feature warning (the over the shoulder camera) is
-- never shown. Blizzard looks the handler up in GameEvent each time the event
-- fires, so replacing it is enough; not showing it is the same as Accept.
-- Switched off in SetGo!: the module sleeps (settings page only).
-- the module key is kept from SetGo_Adventure, so the switch in SetGo! and
-- presets carry over
local KEY = "adventure"
local ON = SetGo.ModuleOn(KEY)

if ON and type(GameEvent) == "table" and GameEvent.HandleExperimentalCVarConfirmationNeeded then
	GameEvent.HandleExperimentalCVarConfirmationNeeded = function() end
end

local function Soft(flag)
	local soft = db and tonumber(db.soft) or SOFT_ALL
	return soft == SOFT_ALL or bit.band(soft, flag) ~= 0
end

-- mouse buttons while mouselook is on (nil: the usual click)
local BUTTONS = { "BUTTON1", "BUTTON2" }
local function Clicks()
	return {
		BUTTON1 = Soft(SOFT_ENEMY) and "TARGETSCANENEMY" or nil,
		BUTTON2 = Soft(SOFT_INTERACT) and "INTERACTTARGET" or nil,
	}
end

-- windows that need the cursor, on top of every window the game itself
-- manages (UIPanelWindows) or closes with Escape (UISpecialFrames)
local WINDOWS = {
	-- game menu, options, popups
	"GameMenuFrame", "SettingsPanel", "SetGoFrame", "SetGoWelcome", "StaticPopup1", "StaticPopup2", "StaticPopup3",
	-- micro menu
	"CharacterFrame", "PlayerSpellsFrame", "SpellBookFrame", "ProfessionsBookFrame", "ProfessionsFrame",
	"TalentFrame", "ClassTalentFrame", "PlayerTalentFrame", "AchievementFrame", "QuestLogFrame",
	"CommunitiesFrame", "GuildFrame", "FriendsFrame", "PVEFrame", "LFGParentFrame", "PVPUIFrame",
	"CollectionsJournal", "EncounterJournal", "HelpFrame", "WeeklyRewardsFrame",
	"HousingDashboardFrame", "MacroFrame", "AddonList", "ChatConfigFrame",
	-- map and loot
	"WorldMapFrame", "LootFrame", "GroupLootContainer",
	-- bags and bank
	"ContainerFrameCombinedBags", "BankFrame", "AccountBankPanel", "GuildBankFrame",
	-- NPCs
	"GossipFrame", "QuestFrame", "MerchantFrame", "ClassTrainerFrame", "TaxiFrame", "FlightMapFrame",
	"MailFrame", "AuctionHouseFrame", "TradeFrame", "ItemTextFrame", "PetStableFrame",
	"PlayerChoiceFrame", "ItemUpgradeFrame", "ItemInteractionFrame", "TabardFrame",
	"GuildRegistrarFrame", "PetitionFrame", "BarberShopFrame", "TransmogFrame", "WardrobeFrame",
	"ProfessionsCustomerOrdersFrame",
}
local NUM_BAG_FRAMES = 13

local active = false
local ticker
local reticle
local ours = false -- mouselook started here (the player's right button is left alone)
local overridesPending = false -- couldn't change in combat: done when it ends
local locked = false -- the camera follows the mouse right now
local lootAuto = false -- the loot window is open only while auto loot works

-- IsVisible, not IsShown: a child like InboxFrame stays "shown" while its
-- parent window is closed
-- Some Blizzard frames (the Shop) are forbidden to addons: skip them
-- instead of erroring on every check.
local function Visible(name)
	local f = _G[name]
	if type(f) ~= "table" or not f.IsVisible then
		return false
	end
	if f.IsForbidden and f:IsForbidden() then
		return false
	end
	local ok, visible = pcall(f.IsVisible, f)
	return ok and visible
end

local HELD = {
	ALT = function() return IsAltKeyDown() end,
	CTRL = function() return IsControlKeyDown() end,
	SHIFT = function() return IsShiftKeyDown() end,
}

-- a window that needs the cursor
local function Needs(name)
	if lootAuto and name == "LootFrame" then
		return false
	end
	return Visible(name)
end

local function Windowed()
	-- the release key, held down
	local held = HELD[db.releaseKey or "NONE"]
	if held and held() then
		return true
	end
	for _, name in ipairs(WINDOWS) do
		if Needs(name) then
			return true
		end
	end
	if type(UIPanelWindows) == "table" then
		for name in pairs(UIPanelWindows) do
			if Needs(name) then
				return true
			end
		end
	end
	if type(UISpecialFrames) == "table" then
		for _, name in ipairs(UISpecialFrames) do
			if Needs(name) then
				return true
			end
		end
	end
	for i = 1, NUM_BAG_FRAMES do
		if Visible("ContainerFrame" .. i) then
			return true
		end
	end
	if GetCursorInfo and GetCursorInfo() then
		return true
	end
	-- ground targeted spells: the cursor comes back on the dot to place them
	if SpellIsTargeting and SpellIsTargeting() then
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- The dot in the middle of the screen
--------------------------------------------------------------------------------

local function PlaceReticle()
	if not reticle then
		return
	end
	reticle:ClearAllPoints()
	reticle:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

local function Reticle()
	if reticle then
		return reticle
	end
	reticle = CreateFrame("Frame", nil, UIParent)
	reticle:SetSize(8, 8)
	reticle:SetFrameStrata("LOW")
	reticle:EnableMouse(false)
	local mask = reticle:CreateMaskTexture()
	mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetAllPoints()
	local outline = reticle:CreateTexture(nil, "BACKGROUND")
	outline:SetAllPoints()
	outline:SetColorTexture(0, 0, 0, 0.8)
	outline:AddMaskTexture(mask)
	local dotMask = reticle:CreateMaskTexture()
	dotMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	dotMask:SetPoint("CENTER")
	dotMask:SetSize(5, 5)
	local dot = reticle:CreateTexture(nil, "ARTWORK")
	dot:SetPoint("CENTER")
	dot:SetSize(5, 5)
	dot:SetColorTexture(1, 1, 1, 1)
	dot:AddMaskTexture(dotMask)
	reticle:Hide()
	PlaceReticle()
	return reticle
end

--------------------------------------------------------------------------------
-- The ping: a circle that closes in on the cursor each time Look!
-- lets go of the mouse, so it is easy to find
--------------------------------------------------------------------------------

local PING_TIME = 0.45
local ping

local function FollowCursor(self)
	local x, y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	self:ClearAllPoints()
	self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
end

local function Ping()
	if not ping then
		ping = CreateFrame("Frame", nil, UIParent)
		ping:SetSize(40, 40)
		ping:SetFrameStrata("TOOLTIP")
		ping:EnableMouse(false)
		local mask = ping:CreateMaskTexture()
		mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetAllPoints()
		local disc = ping:CreateTexture(nil, "ARTWORK")
		disc:SetAllPoints()
		disc:SetColorTexture(1, 0.82, 0, 1)
		disc:AddMaskTexture(mask)
		local anim = ping:CreateAnimationGroup()
		local grow = anim:CreateAnimation("Scale")
		if grow.SetScaleFrom then
			grow:SetScaleFrom(3, 3)
			grow:SetScaleTo(0.4, 0.4)
		else
			grow:SetFromScale(3, 3)
			grow:SetToScale(0.4, 0.4)
		end
		grow:SetDuration(PING_TIME)
		grow:SetSmoothing("OUT")
		local fade = anim:CreateAnimation("Alpha")
		fade:SetFromAlpha(0.7)
		fade:SetToAlpha(0)
		fade:SetDuration(PING_TIME)
		fade:SetSmoothing("IN")
		anim:SetScript("OnFinished", function()
			ping:Hide()
		end)
		ping.anim = anim
		ping:SetScript("OnUpdate", FollowCursor)
		ping:Hide()
	end
	ping.anim:Stop()
	FollowCursor(ping)
	ping:Show()
	ping.anim:Play()
end

--------------------------------------------------------------------------------
-- CVars and bindings changed while active
--------------------------------------------------------------------------------

-- Where the value to put back is kept. CVars the game stores per character go
-- to SetGoLookCharDB; everything else (account wide or kept on this
-- computer) goes to SetGoLookDB, so that if the game closes while
-- Look! is on, the next character to log in puts them back, not only
-- the one that was playing.
local function Store(cvar)
	if C_CVar.GetCVarInfo then
		local ok, _, _, _, perCharacter = pcall(C_CVar.GetCVarInfo, cvar)
		if ok and perCharacter then
			charDB.restore = charDB.restore or {}
			return charDB.restore
		end
	end
	db.restore = db.restore or {}
	return db.restore
end

-- Soft targeting CVars are protected in combat: the game blocks an addon
-- writing them then. Which ones exactly isn't something the game reports
-- reliably, so in combat every write waits here and is made when combat
-- ends. Mouselook and the dot still change at once.
local pending = {}

local function Write(cvar, value)
	if InCombatLockdown() then
		pending[cvar] = value
		return
	end
	pending[cvar] = nil
	C_CVar.SetCVar(cvar, value)
end

local function FlushPending()
	for cvar, value in pairs(pending) do
		pending[cvar] = nil
		C_CVar.SetCVar(cvar, value)
	end
end

local function Save(cvar, value)
	if C_CVar.GetCVar(cvar) == nil then
		return
	end
	local restore = Store(cvar)
	if restore[cvar] == nil then
		-- a value still waiting to be put back is the real original
		local waiting = pending[cvar]
		restore[cvar] = waiting ~= nil and waiting or C_CVar.GetCVar(cvar)
	end
	Write(cvar, value)
end

-- always written (cheap), so a change of type takes effect at once
local function SetOverrides(on)
	if not SetMouselookOverrideBinding then
		return
	end
	if InCombatLockdown() then
		overridesPending = true -- retried when combat ends
		return
	end
	overridesPending = false
	local clicks = Clicks()
	for _, key in ipairs(BUTTONS) do
		pcall(SetMouselookOverrideBinding, key, on and clicks[key] or nil)
	end
end

local function Engage()
	local enemy, friend, interact = Soft(SOFT_ENEMY), Soft(SOFT_FRIEND), Soft(SOFT_INTERACT)
	-- types not picked are off, as Blizzard's own options switch them off
	Save("SoftTargetEnemy", tostring(enemy and ANY or GAMEPAD))
	Save("SoftTargetInteract", tostring(interact and ANY or GAMEPAD))
	-- the game's cursor centring makes the camera jump: keep it off
	Save("CursorFreelookCentering", "0")
	-- friends: out of combat only, and only straight ahead (enemies keep the
	-- whole tab targeting area)
	Save("SoftTargetFriend", (friend and not InCombatLockdown()) and tostring(ANY) or "0")
	if friend then
		Save("SoftTargetFriendArc", FRIEND_ARC)
	end
	-- tooltips for what soft targeting picks
	local icons = db.icons ~= false
	if enemy then
		Save("SoftTargetTooltipEnemy", "1")
		if icons then
			Save("SoftTargetIconEnemy", "1")
		end
	end
	if friend then
		Save("SoftTargetTooltipFriend", "1")
		if icons then
			Save("SoftTargetIconFriend", "1")
		end
	end
	if interact then
		Save("SoftTargetTooltipInteract", "1")
		if icons then
			Save("SoftTargetIconInteract", "1")
			Save("SoftTargetIconGameObject", "1")
			-- also over quest and loot sparkles
			Save("SoftTargetLowPriorityIcons", "1")
		end
	end
	if db.camera then
		-- the game shows its experimental feature warning; close it by hand
		-- (its Disable button resets the camera settings)
		Save("test_cameraOverShoulder", SHOULDER)
	end
	SetOverrides(true)
end

local function PutBack(restore)
	if type(restore) ~= "table" then
		return
	end
	for cvar, value in pairs(restore) do
		if value ~= false then
			Write(cvar, value)
		end
	end
end

-- account values first, then the character's (0.5.0 kept everything there)
local function Restore()
	if db then
		PutBack(db.restore)
		db.restore = nil
	end
	if charDB then
		PutBack(charDB.restore)
		charDB.restore = nil
	end
end
AM.Restore = Restore

-- For SetGo!: the value a CVar goes back to when Look! stops (nil
-- when Look! doesn't hold it), so presets compare and save that one
-- instead of Look!'s own.
local function Held(cvar)
	cvar = cvar:lower()
	for i = 1, 2 do
		local restore = i == 1 and charDB and charDB.restore or i == 2 and db and db.restore
		if type(restore) == "table" then
			for name, value in pairs(restore) do
				if name:lower() == cvar and value ~= false then
					return name, restore
				end
			end
		end
	end
end

function AM.RestoreValue(cvar)
	local name, restore = Held(cvar)
	return name and restore[name] or nil
end

-- SetGo! changed a CVar Look! holds: that becomes the value to
-- put back
function AM.SetRestoreValue(cvar, value)
	local name, restore = Held(cvar)
	if name then
		restore[name] = tostring(value)
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Watching for windows
--------------------------------------------------------------------------------

local Evaluate -- forward
local requested = false

-- coalesced: many shows and hides in one frame make one check
local function Request()
	if requested or not active then
		return
	end
	requested = true
	C_Timer.After(0, function()
		requested = false
		Evaluate()
	end)
end

local hooked = {}
local function Hook(frame)
	if type(frame) ~= "table" or hooked[frame] or not frame.HookScript then
		return
	end
	if frame.IsForbidden and frame:IsForbidden() then
		return
	end
	hooked[frame] = true
	pcall(frame.HookScript, frame, "OnShow", Request)
	pcall(frame.HookScript, frame, "OnHide", Request)
end

-- cheap to repeat: frames already hooked are skipped
local function HookAll()
	for _, name in ipairs(WINDOWS) do
		Hook(_G[name])
	end
	if type(UIPanelWindows) == "table" then
		for name in pairs(UIPanelWindows) do
			Hook(_G[name])
		end
	end
	if type(UISpecialFrames) == "table" then
		for _, name in ipairs(UISpecialFrames) do
			Hook(_G[name])
		end
	end
	for i = 1, NUM_BAG_FRAMES do
		Hook(_G["ContainerFrame" .. i])
	end
end

Evaluate = function()
	if not active then
		return
	end
	local ok, windowed = pcall(Windowed)
	local lock = ok and not windowed
	if lock then
		if not IsMouselooking() then
			MouselookStart()
		end
		ours = true
	elseif ours then
		if IsMouselooking() then
			MouselookStop()
			Ping()
		end
		ours = false
	end
	locked = lock and IsMouselooking()
	Reticle():SetShown(locked)
end

--------------------------------------------------------------------------------
-- On and off
--------------------------------------------------------------------------------

local ticks = 0
local function Tick()
	ticks = ticks + 1
	if ticks >= 10 then
		-- once a second: windows the hooks can't see (new ones, other addons')
		ticks = 0
		HookAll()
		Evaluate()
	elseif locked ~= IsMouselooking() then
		-- the game started or ended mouselook by itself
		Evaluate()
	end
end

local function Start()
	if active then
		return
	end
	active = true
	Engage()
	Reticle()
	PlaceReticle()
	HookAll()
	ticks = 0
	ticker = C_Timer.NewTicker(0.1, Tick)
	Evaluate()
end

local function Stop()
	if not active then
		return
	end
	active = false
	if ticker then
		ticker:Cancel()
		ticker = nil
	end
	if ours and IsMouselooking() then
		MouselookStop()
		Ping()
	end
	ours = false
	locked = false
	Reticle():Hide()
	SetOverrides(false)
	Restore()
end
AM.Stop = Stop

function AM.IsActive()
	return active
end

function AM.Toggle()
	if active then
		Stop()
	else
		Start()
	end
end

-- after the options change
function AM.Refresh()
	if active then
		Stop()
		Start()
	end
end

function SetGo_ToggleLook()
	if not ON then
		SetGo.Print(L.OFF_IN_SETGO)
		return
	end
	AM.Toggle()
end

-- the SetGo! minimap menu turns it on and off
if ON then
	SetGo.look = { IsActive = AM.IsActive, Toggle = AM.Toggle }
end

--------------------------------------------------------------------------------
-- Page in SetGo!
--------------------------------------------------------------------------------

local items
local function Items()
	if items then
		return items
	end
	local Pseudo = SetGo.Pseudo
	local release = Pseudo("SETGO_ADV_RELEASE", L.RELEASE_KEY, L.RELEASE_KEY_DESC, "NONE", function()
		return db.releaseKey or "NONE"
	end, function(key)
		db.releaseKey = key
	end)
	local soft = Pseudo("SETGO_ADV_SOFT", L.SOFT, L.SOFT_DESC, SOFT_ALL, function()
		return tonumber(db.soft) or SOFT_ALL
	end, function(value)
		value = tonumber(value) or SOFT_ALL
		-- a type ticked while All was on: that type alone
		if value ~= SOFT_ALL and bit.band(value, SOFT_ALL) ~= 0 then
			value = value - SOFT_ALL
		end
		db.soft = value
		AM.Refresh()
	end)
	-- All on its own (a radio), or any of the types (checkboxes, a bit each)
	local function SoftOptions()
		local check = Settings and Settings.ControlType and Settings.ControlType.Checkbox
		return {
			{ value = SOFT_ALL, label = SetGo.G("ALL", "All") },
			{ value = 1, label = L.SOFT_ENEMY, controlType = check },
			{ value = 2, label = L.SOFT_FRIEND, controlType = check },
			{ value = 3, label = L.SOFT_INTERACT, controlType = check },
		}
	end
	local icons = Pseudo("SETGO_ADV_ICONS", L.ICONS, L.ICONS_DESC, true, function()
		return db.icons ~= false
	end, function(on)
		db.icons = on
		AM.Refresh()
	end)
	local camera = Pseudo("SETGO_ADV_CAMERA", L.CAMERA, L.CAMERA_DESC, false, function()
		return db.camera == true
	end, function(on)
		db.camera = on
		AM.Refresh()
	end)
	local function ReleaseOptions()
		return {
			{ value = "NONE", label = L.NONE },
			{ value = "ALT", label = SetGo.G("ALT_KEY", "Alt") },
			{ value = "CTRL", label = SetGo.G("CTRL_KEY", "Ctrl") },
			{ value = "SHIFT", label = SetGo.G("SHIFT_KEY", "Shift") },
		}
	end
	items = {
		{ kind = "note", name = L.HOW },
		{ kind = "header", name = L.SEC_CONTROLS },
		{ kind = "keybind", action = "SETGO_LOOK", name = L.KEY, tooltip = L.KEY_DESC },
		{ kind = "dropdown", setting = release, settings = { release }, name = L.RELEASE_KEY, tooltip = L.RELEASE_KEY_DESC, options = ReleaseOptions },
		{ kind = "header", name = L.SEC_TARGETING },
		{ kind = "dropdown", setting = soft, settings = { soft }, name = L.SOFT, tooltip = L.SOFT_DESC, options = SoftOptions },
		{ kind = "checkbox", setting = icons, settings = { icons }, name = L.ICONS, tooltip = L.ICONS_DESC },
		{ kind = "header", name = L.SEC_CAMERA },
		{ kind = "checkbox", setting = camera, settings = { camera }, name = L.CAMERA, tooltip = L.CAMERA_DESC },
	}
	return items
end

SetGo.RegisterModule({ key = KEY, title = L.TITLE, items = Items,
	RestoreValue = AM.RestoreValue, SetRestoreValue = AM.SetRestoreValue })

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_LOGOUT")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("DISPLAY_SIZE_CHANGED")
events:RegisterEvent("MODIFIER_STATE_CHANGED")
events:RegisterEvent("CURSOR_CHANGED")
events:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
events:RegisterEvent("LOOT_OPENED")
events:RegisterEvent("LOOT_CLOSED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("UI_SCALE_CHANGED")
events:SetScript("OnEvent", function(_, event, arg1)
	if event == "MODIFIER_STATE_CHANGED" or event == "CURSOR_CHANGED" or event == "CURRENT_SPELL_CAST_CHANGED"
		or event == "PLAYER_ENTERING_WORLD" then
		Request()
	elseif event == "LOOT_OPENED" then
		-- arg1: auto loot is taking everything, the window closes by itself
		lootAuto = arg1 and true or false
		Request()
	elseif event == "LOOT_CLOSED" then
		lootAuto = false
		Request()
	elseif event == "ADDON_LOADED" then
		if arg1 == ADDON then
			SetGoLookDB = type(SetGoLookDB) == "table" and SetGoLookDB or {}
			SetGoLookCharDB = type(SetGoLookCharDB) == "table" and SetGoLookCharDB or {}
			db, charDB = SetGoLookDB, SetGoLookCharDB
		elseif active then
			-- windows of an addon that just loaded
			HookAll()
		end
	elseif event == "PLAYER_LOGIN" then
		-- the game closed while Look! was on
		Restore()
	elseif event == "PLAYER_LOGOUT" then
		if active then
			Stop()
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		-- friends are soft targeted out of combat only
		if active and Soft(SOFT_FRIEND) and C_CVar.GetCVar("SoftTargetFriend") ~= nil then
			C_CVar.SetCVar("SoftTargetFriend", "0")
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- CVars that were protected during combat
		FlushPending()
		if active and Soft(SOFT_FRIEND) and C_CVar.GetCVar("SoftTargetFriend") ~= nil then
			C_CVar.SetCVar("SoftTargetFriend", tostring(ANY))
		end
		-- toggled during combat: bindings could not change then
		if overridesPending then
			SetOverrides(active)
		end
	else
		PlaceReticle()
	end
end)
