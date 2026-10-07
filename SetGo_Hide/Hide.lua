local ADDON, ns = ...

local L = {
	TITLE = "Hide!",
	NOTE = "Each frame works like a macro. Pick one or more conditions (any of them is enough) and Show or Hide.\nShow: the frame is only seen while a condition is on. Hide: it is only seen while none is on.\nNone with Show leaves the frame to Blizzard. None with Hide always hides it.\nHealth below 100% is only checked out of combat: in combat it stays as it was when combat started.\nAction bars with a rule are always shown while the cursor holds something or the spellbook is open (out of combat).",
	NOTE_BLIZZARD = "Blizzard's own visibility still counts: a frame shows only when Blizzard and Hide! both allow it. For action bars, keep Blizzard's visibility on Always in Edit Mode. In Edit Mode every frame is shown so you can move it.",
	SEC_UNITS = "Unit frames",
	SEC_HUD = "Interface",
	SEC_BARS = "Action bars",
	WHEN = "Conditions",
	WHEN_DESC = "Any of the chosen conditions is enough. None can't be mixed with the others.",
	MODE = "Show or Hide",
	MODE_DESC = "Show: seen only while a condition is on. Hide: seen only while none is on.",
	MODE_SHOW = "Show",
	MODE_HIDE = "Hide",
	MISSING = "not found",
	MSG_COMBAT = "Hide! changes apply when combat ends.",

	C_none = "None",
	C_combat = "In combat",
	C_shift = "Shift held",
	C_ctrl = "Ctrl held",
	C_alt = "Alt held",
	C_mounted = "Mounted",
	C_stealth = "Stealthed",
	C_indoors = "Indoors",
	C_outdoors = "Outdoors",
	C_swimming = "Swimming",
	C_party = "In a party",
	C_raid = "In a raid",
	C_target = "Has a target",
	C_harm = "Target is hostile",
	C_help = "Target is friendly",
	C_pet = "Has a pet",
	C_vehicle = "In a vehicle",
	C_form = "In a form or stance",
	C_hurt = "Health below 100% (out of combat)",

	F_player = "Player",
	F_pet = "Pet",
	F_target = "Target",
	F_tot = "Target of target",
	F_focus = "Focus",
	F_focustot = "Focus target",
	F_minimap = "Minimap",
	F_objectives = "Quest tracker",
	F_micro = "Micro menu",
	F_bags = "Bag bar",
	F_xp = "Experience and reputation bars",
	F_bar1 = "Action bar 1",
	F_bar2 = "Action bar 2",
	F_bar3 = "Action bar 3",
	F_bar4 = "Action bar 4",
	F_bar5 = "Action bar 5",
	F_bar6 = "Action bar 6",
	F_bar7 = "Action bar 7",
	F_bar8 = "Action bar 8",
	F_petbar = "Pet bar",
	F_stance = "Stance bar",
}
if GetLocale() == "ptBR" then
	L.NOTE = "Cada frame funciona como uma macro. Escolhe uma ou mais condições (basta uma delas) e Mostrar ou Esconder.\nMostrar: a frame só se vê enquanto uma condição estiver activa. Esconder: só se vê enquanto nenhuma estiver activa.\nNenhuma com Mostrar deixa a frame com a Blizzard. Nenhuma com Esconder esconde-a sempre.\nVida abaixo de 100% só é vista fora de combate: em combate fica como estava quando o combate começou.\nAs barras de acção com regra aparecem sempre que o cursor segura alguma coisa ou o livro de feitiços está aberto (fora de combate)."
	L.NOTE_BLIZZARD = "A visibilidade da própria Blizzard continua a contar: uma frame só aparece quando a Blizzard e o Hide! deixam. Nas barras de acção, deixa a visibilidade da Blizzard em Sempre no Edit Mode. No Edit Mode todas as frames aparecem, para as poderes mover."
	L.SEC_UNITS = "Unit frames"
	L.SEC_HUD = "Interface"
	L.SEC_BARS = "Barras de acção"
	L.WHEN = "Condições"
	L.WHEN_DESC = "Basta uma das condições escolhidas. Nenhuma não se junta com as outras."
	L.MODE = "Mostrar ou Esconder"
	L.MODE_DESC = "Mostrar: só se vê enquanto uma condição estiver activa. Esconder: só se vê enquanto nenhuma estiver activa."
	L.MODE_SHOW = "Mostrar"
	L.MODE_HIDE = "Esconder"
	L.MISSING = "não encontrada"
	L.MSG_COMBAT = "As alterações do Hide! aplicam-se quando o combate acabar."

	L.C_none = "Nenhuma"
	L.C_combat = "Em combate"
	L.C_shift = "Shift carregado"
	L.C_ctrl = "Ctrl carregado"
	L.C_alt = "Alt carregado"
	L.C_mounted = "Montado"
	L.C_stealth = "Em stealth"
	L.C_indoors = "Em interiores"
	L.C_outdoors = "Ao ar livre"
	L.C_swimming = "A nadar"
	L.C_party = "Em grupo"
	L.C_raid = "Em raid"
	L.C_target = "Tem alvo"
	L.C_harm = "Alvo hostil"
	L.C_help = "Alvo amigável"
	L.C_pet = "Tem pet"
	L.C_vehicle = "Num veículo"
	L.C_form = "Numa forma ou postura"
	L.C_hurt = "Vida abaixo de 100% (fora de combate)"

	L.F_player = "Jogador"
	L.F_pet = "Pet"
	L.F_target = "Alvo"
	L.F_tot = "Alvo do alvo"
	L.F_focus = "Foco"
	L.F_focustot = "Alvo do foco"
	L.F_minimap = "Minimapa"
	L.F_objectives = "Quest tracker"
	L.F_micro = "Micro menu"
	L.F_bags = "Barra dos sacos"
	L.F_xp = "Barras de experiência e reputação"
	L.F_bar1 = "Barra de acção 1"
	L.F_bar2 = "Barra de acção 2"
	L.F_bar3 = "Barra de acção 3"
	L.F_bar4 = "Barra de acção 4"
	L.F_bar5 = "Barra de acção 5"
	L.F_bar6 = "Barra de acção 6"
	L.F_bar7 = "Barra de acção 7"
	L.F_bar8 = "Barra de acção 8"
	L.F_petbar = "Barra do pet"
	L.F_stance = "Barra de posturas"
end

--------------------------------------------------------------------------------
-- Hides Blizzard frames with macro conditionals, without taking them over.
--   Each Blizzard frame with a rule is given a parent of ours: a secure frame
--   over the whole screen whose visibility is driven by the game's own state
--   driver ("[combat][mounted] show; hide"). Blizzard keeps showing and hiding
--   its frame as before; it is only seen while our parent is shown too. No
--   alpha, no Show or Hide on Blizzard's frames, no polling.
--   Frames with the same rule share one parent, so one driver. A frame with
--   no rule (None + Show) is never touched; None + Hide is a parent that is
--   simply hidden, with no driver.
--   Nothing changes in combat: changes wait for it to end. In Edit Mode every
--   parent is shown so the frames can be moved.
-- SetGoHideDB: [frame key] = { when = bitmask of CONDS, mode = "show"/"hide" }
--------------------------------------------------------------------------------

-- the conditions, in the order they are listed; bit i - 1 of "when"
local CONDS = {
	{ key = "none" },
	{ key = "combat", macro = "combat" },
	{ key = "shift", macro = "mod:shift" },
	{ key = "ctrl", macro = "mod:ctrl" },
	{ key = "alt", macro = "mod:alt" },
	{ key = "mounted", macro = "mounted" },
	{ key = "stealth", macro = "stealth" },
	{ key = "indoors", macro = "indoors" },
	{ key = "outdoors", macro = "outdoors" },
	{ key = "swimming", macro = "swimming" },
	-- [group:party] is also true in a raid: party here is a party only
	{ key = "party", macro = "group:party,nogroup:raid" },
	{ key = "raid", macro = "group:raid" },
	{ key = "target", macro = "@target,exists" },
	{ key = "harm", macro = "@target,harm" },
	{ key = "help", macro = "@target,help" },
	{ key = "pet", macro = "pet" },
	{ key = "vehicle", macro = "vehicleui" },
	{ key = "form", macro = "form" },
	-- not a macro conditional: read by us out of combat (see Health)
	{ key = "hurt", health = true },
}
local NONE = 1
-- the order of the list (the bits above never move, so saved rules stay)
local ORDER = { 1, 2, 19, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }

-- names: every frame of the entry that exists; alt: used only when none of
-- names exists (older names)
local FRAMES = {
	{ group = "units", key = "player", names = { "PlayerFrame" } },
	{ group = "units", key = "pet", names = { "PetFrame" } },
	{ group = "units", key = "target", names = { "TargetFrame" } },
	{ group = "units", key = "tot", names = { "TargetFrameToT" } },
	{ group = "units", key = "focus", names = { "FocusFrame" } },
	{ group = "units", key = "focustot", names = { "FocusFrameToT" } },
	{ group = "hud", key = "minimap", names = { "MinimapCluster" }, alt = { "Minimap" } },
	{ group = "hud", key = "objectives", names = { "ObjectiveTrackerFrame" } },
	{ group = "hud", key = "micro", names = { "MicroMenu" }, alt = { "MicroMenuContainer" } },
	{ group = "hud", key = "bags", names = { "BagsBar" } },
	{ group = "hud", key = "xp", names = { "StatusTrackingBarManager" } },
	{ group = "bars", key = "bar1", names = { "MainActionBar" }, alt = { "MainMenuBar" } },
	{ group = "bars", key = "bar2", names = { "MultiBarBottomLeft" } },
	{ group = "bars", key = "bar3", names = { "MultiBarBottomRight" } },
	{ group = "bars", key = "bar4", names = { "MultiBarRight" } },
	{ group = "bars", key = "bar5", names = { "MultiBarLeft" } },
	{ group = "bars", key = "bar6", names = { "MultiBar5" } },
	{ group = "bars", key = "bar7", names = { "MultiBar6" } },
	{ group = "bars", key = "bar8", names = { "MultiBar7" } },
	{ group = "bars", key = "petbar", names = { "PetActionBar" } },
	{ group = "bars", key = "stance", names = { "StanceBar" } },
}
local GROUPS = {
	{ key = "units", title = "SEC_UNITS" },
	{ key = "hud", title = "SEC_HUD" },
	{ key = "bars", title = "SEC_BARS" },
}

local db
local DEFAULT_WHEN, DEFAULT_MODE = NONE, "show"
local hurt = false -- the player's health below 100%, as last read out of combat
local reveal = false -- the cursor holds something or the spellbook is open

local function Rule(key)
	local r = db and db[key]
	local when = type(r) == "table" and tonumber(r.when) or DEFAULT_WHEN
	local mode = type(r) == "table" and (r.mode == "hide" and "hide" or "show") or DEFAULT_MODE
	if when == 0 then
		when = NONE
	end
	return when, mode
end

local function Store(key, field, value)
	db[key] = type(db[key]) == "table" and db[key] or {}
	db[key][field] = value
	-- back to the default: nothing kept
	local when, mode = Rule(key)
	if when == DEFAULT_WHEN and mode == DEFAULT_MODE then
		db[key] = nil
	end
end

local function Bit(i)
	return bit.lshift(1, i - 1)
end

-- None is on its own: picking it clears the rest, picking another clears it,
-- and clearing the last one brings it back
local function Toggle(current, bitValue)
	if bitValue == NONE then
		return NONE
	end
	local value = bit.bxor(bit.band(current, bit.bnot(NONE)), bitValue)
	if value == 0 then
		value = NONE
	end
	return value
end

-- the state driver of a rule; nil = leave the frame alone, "hide" = always
local function Driver(key)
	local when, mode = Rule(key)
	if bit.band(when, NONE) ~= 0 then
		return mode == "hide" and "hide" or nil
	end
	local parts, health = {}, false
	for i, c in ipairs(CONDS) do
		if bit.band(when, Bit(i)) ~= 0 then
			if c.macro then
				parts[#parts + 1] = "[" .. c.macro .. "]"
			elseif c.health then
				health = true
			end
		end
	end
	-- health below 100% is on: one condition is enough, so the rest don't count
	if health and hurt then
		return mode
	end
	if #parts == 0 then
		-- no condition can be on
		return health and (mode == "show" and "hide" or "show") or (mode == "hide" and "hide" or nil)
	end
	local conds = table.concat(parts)
	if mode == "show" then
		return conds .. " show; hide"
	end
	return conds .. " hide; show"
end

-- some rule uses health below 100%
local HURT_BIT
for i, c in ipairs(CONDS) do
	if c.health then
		HURT_BIT = Bit(i)
	end
end
local function UsesHealth()
	for _, e in ipairs(FRAMES) do
		local when = Rule(e.key)
		if bit.band(when, NONE) == 0 and bit.band(when, HURT_BIT) ~= 0 then
			return true
		end
	end
	return false
end

-- the Blizzard frames of an entry that exist
local function Resolve(e)
	local list = {}
	for _, name in ipairs(e.names) do
		local f = _G[name]
		if type(f) == "table" and f.SetParent then
			list[#list + 1] = f
		end
	end
	if #list == 0 and e.alt then
		for _, name in ipairs(e.alt) do
			local f = _G[name]
			if type(f) == "table" and f.SetParent then
				list[#list + 1] = f
			end
		end
	end
	return list
end

--------------------------------------------------------------------------------
-- Applying
--------------------------------------------------------------------------------

local started, editing = false, false
local containers = {} -- [driver] = our parent frame
local moved = {} -- [Blizzard frame] = its own parent

-- a Blizzard frame Hide! has a rule for (Cooldowns.lua asks)
function ns.HideManaged(f)
	return moved[f] ~= nil
end
local events = CreateFrame("Frame")

local function Container(driver)
	local c = containers[driver]
	if not c then
		c = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
		-- the size and place of UIParent, so frames anchored to their parent
		-- stay where they were
		c:SetAllPoints(UIParent)
		c:SetFrameStrata(UIParent:GetFrameStrata())
		c:SetFrameLevel(UIParent:GetFrameLevel())
		containers[driver] = c
	end
	return c
end

-- Health below 100%: only the player's health events, only out of combat,
-- and only while a rule uses it. A frame moves only when the health goes from
-- full to not full or back.
local watching = false

local function ReadHurt()
	local h, m = UnitHealth("player"), UnitHealthMax("player")
	-- in combat the values can be secret: never compared
	if issecretvalue and (issecretvalue(h) or issecretvalue(m)) then
		return hurt
	end
	return (tonumber(h) or 0) < (tonumber(m) or 0)
end

local function Watch(on)
	if on == watching then
		return
	end
	watching = on
	if on then
		events:RegisterEvent("PLAYER_REGEN_DISABLED")
		events:RegisterEvent("PLAYER_REGEN_ENABLED")
		if not InCombatLockdown() then
			events:RegisterUnitEvent("UNIT_HEALTH", "player")
			events:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
		end
	else
		events:UnregisterEvent("PLAYER_REGEN_DISABLED")
		events:UnregisterEvent("UNIT_HEALTH")
		events:UnregisterEvent("UNIT_MAXHEALTH")
	end
end

-- Reveal: the action bars with a rule are shown while the cursor holds
-- something (a spell, an item, a macro) or the spellbook is open, whatever
-- their rule, so things can be dragged onto them. Read out of combat only;
-- the bars move only when it changes.
local SPELLBOOKS = { "PlayerSpellsFrame", "SpellBookFrame" }
local hooked = {}
local revealing = false

local function ReadReveal()
	if GetCursorInfo() ~= nil then
		return true
	end
	for _, name in ipairs(SPELLBOOKS) do
		local f = _G[name]
		if type(f) == "table" and f.IsShown and f:IsShown() then
			return true
		end
	end
	return false
end

local Apply

local function RevealChanged()
	if not revealing then
		return
	end
	if InCombatLockdown() then
		-- looked at again when combat ends
		events:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	if ReadReveal() ~= reveal then
		Apply()
	end
end

-- Blizzard's spellbook, hooked once it exists (it can load later)
local function HookSpellbooks()
	for _, name in ipairs(SPELLBOOKS) do
		local f = _G[name]
		if type(f) == "table" and f.HookScript and not hooked[name] then
			hooked[name] = true
			f:HookScript("OnShow", RevealChanged)
			f:HookScript("OnHide", RevealChanged)
		end
	end
end

local CURSOR_EVENT = (not C_EventUtils or not C_EventUtils.IsEventValid or C_EventUtils.IsEventValid("CURSOR_CHANGED"))
	and "CURSOR_CHANGED" or "CURSOR_UPDATE"

local function UsesBars()
	for _, e in ipairs(FRAMES) do
		if e.group == "bars" and Driver(e.key) then
			return true
		end
	end
	return false
end

local function WatchReveal(on)
	if on == revealing then
		return
	end
	revealing = on
	if on then
		pcall(events.RegisterEvent, events, CURSOR_EVENT)
		HookSpellbooks()
	else
		pcall(events.UnregisterEvent, events, CURSOR_EVENT)
	end
end

function Apply()
	if not started then
		return
	end
	if InCombatLockdown() then
		events:RegisterEvent("PLAYER_REGEN_ENABLED")
		return false
	end
	if UsesHealth() then
		hurt = ReadHurt()
	end
	local bars = UsesBars()
	reveal = bars and ReadReveal() or false
	local used = {}
	for _, e in ipairs(FRAMES) do
		local driver = Driver(e.key)
		if driver and reveal and e.group == "bars" then
			driver = "show"
		end
		for _, f in ipairs(Resolve(e)) do
			if driver then
				local c = Container(driver)
				used[c] = true
				if f:GetParent() ~= c then
					if moved[f] == nil then
						moved[f] = f:GetParent() or UIParent
					end
					f:SetParent(c)
				end
			elseif moved[f] then
				f:SetParent(moved[f])
				moved[f] = nil
			end
		end
	end
	for driver, c in pairs(containers) do
		-- an empty parent, or Edit Mode: shown, no driver
		local want = (used[c] and not editing) and driver or false
		if want ~= c.driven then
			if c.driven and c.driven ~= "hide" and c.driven ~= "show" then
				UnregisterStateDriver(c, "visibility")
			end
			if not want or want == "show" then
				c:Show()
			elseif want == "hide" then
				c:Hide()
			else
				RegisterStateDriver(c, "visibility", want)
			end
			c.driven = want
		end
	end
	Watch(UsesHealth())
	WatchReveal(bars)
	if ns.CooldownsRefresh then
		ns.CooldownsRefresh(db and db.cooldowns == true)
	end
	return true
end

local function Changed()
	if started and Apply() == false then
		SetGo.Print(L.MSG_COMBAT)
	end
end

local function Start()
	started = true
	if EventRegistry and EventRegistry.RegisterCallback then
		local owner = {}
		EventRegistry:RegisterCallback("EditMode.Enter", function()
			editing = true
			Apply()
		end, owner)
		EventRegistry:RegisterCallback("EditMode.Exit", function()
			editing = false
			Apply()
		end, owner)
	end
	Apply()
	ns.hideStarted = true
end

--------------------------------------------------------------------------------
-- Page in SetGo!
--------------------------------------------------------------------------------

local function FrameLabel(e)
	local text = L["F_" .. e.key] or e.key
	if #Resolve(e) == 0 then
		text = text .. "  |cff8c7a5b(" .. L.MISSING .. ")|r"
	end
	return text
end

-- the frame's name, then its conditions and Show/Hide side by side
local function RowBuilder(e, when, mode)
	return function(page, y, width)
		local W = SetGo.Widgets
		local fs, h = W.Text(page, W.FONT_BODY, width, FrameLabel(e))
		fs:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
		y = y + h + 5

		local MODE_W = 110
		local dd = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
		dd:SetPoint("TOPLEFT", page, "TOPLEFT", 2, -y)
		dd:SetWidth(math.max(120, math.min(250, width - MODE_W - 16)))
		W.TipScripts(dd, L.WHEN, L.WHEN_DESC, true)
		local function Current()
			return tonumber(SetGo.Get(when)) or DEFAULT_WHEN
		end
		dd:SetupMenu(function(_, root)
			for _, i in ipairs(ORDER) do
				local c = CONDS[i]
				local bitValue = Bit(i)
				root:CreateCheckbox(L["C_" .. c.key], function()
					return bit.band(Current(), bitValue) ~= 0
				end, function()
					SetGo.Set(when, Toggle(Current(), bitValue))
					-- the list stays open to pick more than one
					return MenuResponse and MenuResponse.Refresh
				end)
			end
		end)

		local md = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
		md:SetPoint("LEFT", dd, "RIGHT", 8, 0)
		md:SetWidth(MODE_W)
		W.TipScripts(md, L.MODE, L.MODE_DESC, true)
		md:SetupMenu(function(_, root)
			for _, opt in ipairs({ { "show", L.MODE_SHOW }, { "hide", L.MODE_HIDE } }) do
				root:CreateRadio(opt[2], function()
					return SetGo.Get(mode) == opt[1]
				end, function()
					SetGo.Set(mode, opt[1])
				end)
			end
		end)

		table.insert(page.refreshers, function()
			dd:GenerateMenu()
			md:GenerateMenu()
		end)
		return y + 26 + 10
	end
end

-- Collapsible sections: a header per group (with how many of its frames
-- have a rule) that opens or closes its rows. Open or closed is kept per
-- account, not in profiles.
local function IsOpen(group)
	local ui = db and db._ui
	return type(ui) == "table" and type(ui.open) == "table" and ui.open[group] == true
end

local function SetOpen(group, on)
	db._ui = type(db._ui) == "table" and db._ui or {}
	db._ui.open = type(db._ui.open) == "table" and db._ui.open or {}
	db._ui.open[group] = on or nil
end

-- frames of a group with a rule (as shown: a profile being edited counts)
local function RuleCount(group, settings)
	local n = 0
	for _, e in ipairs(FRAMES) do
		local pair = settings[e.key]
		if e.group == group and pair then
			local when = tonumber(SetGo.Get(pair.when)) or DEFAULT_WHEN
			local mode = SetGo.Get(pair.mode)
			if not (bit.band(when, NONE) ~= 0 and mode ~= "hide") then
				n = n + 1
			end
		end
	end
	return n
end

local HEADER_H = 30

local function SectionsBuilder(settings)
	return function(page, y, width)
		local W = SetGo.Widgets
		local r, g, b = W.Ink()
		local holder = CreateFrame("Frame", nil, page)
		holder:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
		holder:SetWidth(width)
		local sections = {}
		local Layout

		for _, grp in ipairs(GROUPS) do
			local sec = {}
			sections[#sections + 1] = sec
			sec.key = grp.key

			local head = CreateFrame("Button", nil, holder)
			head:SetSize(width, HEADER_H - 6)
			sec.head = head
			head.icon = head:CreateTexture(nil, "ARTWORK")
			head.icon:SetSize(14, 14)
			head.icon:SetPoint("LEFT", 0, 0)
			head.text = W.Text(head, W.FONT_HEADER, width - 24, L[grp.title])
			head.text:SetPoint("LEFT", head.icon, "RIGHT", 6, 0)
			local line = head:CreateTexture(nil, "ARTWORK")
			line:SetHeight(1)
			line:SetColorTexture(r, g, b, 0.35)
			line:SetPoint("TOPLEFT", head, "BOTTOMLEFT", 0, -2)
			line:SetPoint("TOPRIGHT", head, "BOTTOMRIGHT", 0, -2)
			head:SetScript("OnClick", function()
				SetGo.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
				SetOpen(grp.key, not IsOpen(grp.key))
				local before = holder:GetHeight()
				Layout()
				page:SetHeight(page:GetHeight() + (holder:GetHeight() - before))
				-- the page (or the profile's list) lays itself out again
				if SetGo.Refresh then
					SetGo.Refresh()
				end
			end)
			head:SetScript("OnEnter", function(self)
				self.text:SetAlpha(0.7)
			end)
			head:SetScript("OnLeave", function(self)
				self.text:SetAlpha(1)
			end)

			-- the rows, on a frame of their own that shares the page's refreshers
			local body = CreateFrame("Frame", nil, holder)
			body:SetWidth(width)
			body.refreshers = page.refreshers
			local by = 6
			for _, e in ipairs(FRAMES) do
				if e.group == grp.key then
					local pair = settings[e.key]
					by = RowBuilder(e, pair.when, pair.mode)(body, by, width)
				end
			end
			if grp.key == "bars" and settings._cooldowns then
				local s = settings._cooldowns
				by = W.Checkbox(body, by + 4, width, false, ns.CooldownL.TOGGLE, ns.CooldownL.TOGGLE_DESC, function()
					return SetGo.Get(s)
				end, function(value)
					SetGo.Set(s, value)
				end)
			end
			body:SetHeight(by)
			sec.body = body

			sec.update = function()
				local open = IsOpen(grp.key)
				head.icon:SetTexture(open and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
				local n = RuleCount(grp.key, settings)
				head.text:SetText(n > 0 and ("%s  |cff8c7a5b(%d)|r"):format(L[grp.title], n) or L[grp.title])
			end
			table.insert(page.refreshers, sec.update)
		end

		function Layout()
			local yy = 0
			for i, sec in ipairs(sections) do
				if i > 1 then
					yy = yy + 8
				end
				sec.head:ClearAllPoints()
				sec.head:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, -yy)
				yy = yy + HEADER_H
				sec.update()
				if IsOpen(sec.key) then
					sec.body:ClearAllPoints()
					sec.body:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, -yy)
					sec.body:Show()
					yy = yy + sec.body:GetHeight()
				else
					sec.body:Hide()
				end
			end
			holder:SetHeight(math.max(yy, 1))
			return yy
		end

		return y + Layout() + 10
	end
end

local items
local function Items()
	if items then
		return items
	end
	local Pseudo = SetGo.Pseudo
	local all, settings = {}, {}
	for _, e in ipairs(FRAMES) do
		local var = "SETGO_HIDE_" .. e.key:upper()
		local when = Pseudo(var .. "_WHEN", L["F_" .. e.key] .. ": " .. L.WHEN, L.WHEN_DESC, DEFAULT_WHEN, function()
			return (Rule(e.key))
		end, function(value)
			Store(e.key, "when", tonumber(value) or DEFAULT_WHEN)
			Changed()
		end)
		local mode = Pseudo(var .. "_MODE", L["F_" .. e.key] .. ": " .. L.MODE, L.MODE_DESC, DEFAULT_MODE, function()
			return select(2, Rule(e.key))
		end, function(value)
			Store(e.key, "mode", value == "hide" and "hide" or "show")
			Changed()
		end)
		settings[e.key] = { when = when, mode = mode }
		all[#all + 1] = when
		all[#all + 1] = mode
	end
	-- cooldown icons over hidden action bars (Cooldowns.lua), in profiles
	local CL = ns.CooldownL
	local cooldowns = Pseudo("SETGO_HIDE_COOLDOWNS", CL.TOGGLE, CL.TOGGLE_DESC, false, function()
		return db and db.cooldowns == true
	end, function(value)
		db.cooldowns = value and true or nil
		if started then
			ns.CooldownsRefresh(value)
		end
	end)
	all[#all + 1] = cooldowns
	settings._cooldowns = cooldowns
	items = {
		{ kind = "note", name = L.NOTE },
		{ kind = "note", name = L.NOTE_BLIZZARD },
		-- every frame's two settings, so profiles keep them
		{ kind = "custom", name = L.TITLE, settings = all, build = SectionsBuilder(settings) },
	}
	return items
end

SetGo.RegisterModule({ key = "hide", title = L.TITLE, items = Items })

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == ADDON then
			SetGoHideDB = type(SetGoHideDB) == "table" and SetGoHideDB or {}
			db = SetGoHideDB
			ns.hideDB = db
			-- the action bar art copy is gone (0.6.0)
			db._art = nil
		elseif revealing then
			-- the spellbook can be an addon of Blizzard's that loads later
			HookSpellbooks()
		end
	elseif event == "PLAYER_LOGIN" then
		-- switched off in SetGo!: only the settings page is here
		if SetGo.ModuleOn("hide") then
			Start()
		end
	elseif event == CURSOR_EVENT then
		RevealChanged()
	elseif event == "PLAYER_REGEN_ENABLED" then
		if watching then
			self:RegisterUnitEvent("UNIT_HEALTH", "player")
			self:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
		Apply()
	elseif event == "PLAYER_REGEN_DISABLED" then
		-- in combat the rule stays as it is
		self:UnregisterEvent("UNIT_HEALTH")
		self:UnregisterEvent("UNIT_MAXHEALTH")
	elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
		if not InCombatLockdown() and ReadHurt() ~= hurt then
			Apply()
		end
	end
end)
