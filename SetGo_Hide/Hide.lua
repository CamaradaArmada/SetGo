local ADDON, ns = ...

local L = {
	TITLE = "Hide!",
	NOTE = "Make a rule and choose its frames. Each rule works like a macro: pick one or more conditions (any of them is enough) and Show or Hide.\nShow: the frame is only seen while a condition is on. Hide: it is only seen while none is on.\nNone with Show leaves the frame to Blizzard. None with Hide always hides it.\nAction bars with a rule are always shown while the cursor holds something or the spellbook is open (out of combat).",
	NOTE_BLIZZARD = "Blizzard's own visibility still counts: a frame shows only when Blizzard and Hide! both allow it. For action bars, keep Blizzard's visibility on Always in Edit Mode. In Edit Mode and in Quick Keybind mode every frame is shown.",
	SEC_UNITS = "Unit frames",
	SEC_HUD = "Interface",
	SEC_BARS = "Action bars",
	WHEN = "Conditions",
	WHEN_DESC = "Any of the chosen conditions is enough. None can't be mixed with the others.",
	MODE = "Show or Hide",
	MODE_DESC = "Show: seen only while a condition is on. Hide: seen only while none is on.",
	MODE_SHOW = "Show",
	MODE_HIDE = "Hide",
	MSG_COMBAT = "Hide! changes apply when combat ends.",
	NEW_RULE = "New rule",
	NEW_RULE_DESC = "A rule: its frames, the conditions and Show or Hide.",
	RULES_FULL = "Up to 10 rules.",
	RULE = "Rule %d",
	REMOVE = "Remove rule",
	REMOVE_DESC = "The rule goes; its frames go back to Blizzard.",
	FRAMES = "Frames",
	FRAMES_DESC = "The frames this rule shows or hides. A frame can be in one rule only: the ones in another rule are greyed.",
	FRAMES_NONE = "No frames",
	FRAMES_COUNT = "%d frames",
	CHECK_ALL = "Check all",
	UNCHECK_ALL = "Uncheck all",
	DELAY = "Out of combat delay",
	DELAY_DESC = "Shown in combat, the frame stays visible for this long after combat ends.",
	DELAY_OFF = "Only for a rule with In combat and Show.",

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
	C_party = "In a group",
	C_instance = "In an instance",
	C_target = "Has a target",
	C_harm = "Target is hostile",
	C_help = "Target is friendly",
	C_pet = "Has a pet",
	C_vehicle = "In a vehicle",
	C_form = "In a form or stance",

	F_player = "Player",
	F_pet = "Pet",
	F_target = "Target",
	F_tot = "Target of target",
	F_focus = "Focus",
	F_focustot = "Focus target",
	F_minimap = "Minimap",
	F_buffs = "Buffs",
	F_debuffs = "Debuffs",
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
	L.NOTE = "Cria uma regra e escolhe as frames dela. Cada regra funciona como uma macro: escolhe uma ou mais condições (basta uma delas) e Mostrar ou Esconder.\nMostrar: a frame só se vê enquanto uma condição estiver activa. Esconder: só se vê enquanto nenhuma estiver activa.\nNenhuma com Mostrar deixa a frame com a Blizzard. Nenhuma com Esconder esconde-a sempre.\nAs barras de acção com regra aparecem sempre que o cursor segura alguma coisa ou o livro de feitiços está aberto (fora de combate)."
	L.NOTE_BLIZZARD = "A visibilidade da própria Blizzard continua a contar: uma frame só aparece quando a Blizzard e o Hide! deixam. Nas barras de acção, deixa a visibilidade da Blizzard em Sempre no Edit Mode. No Edit Mode e no modo de atalhos rápidos (Quick Keybind) todas as frames aparecem."
	L.SEC_UNITS = "Unit frames"
	L.SEC_HUD = "Interface"
	L.SEC_BARS = "Barras de acção"
	L.WHEN = "Condições"
	L.WHEN_DESC = "Basta uma das condições escolhidas. Nenhuma não se junta com as outras."
	L.MODE = "Mostrar ou Esconder"
	L.MODE_DESC = "Mostrar: só se vê enquanto uma condição estiver activa. Esconder: só se vê enquanto nenhuma estiver activa."
	L.MODE_SHOW = "Mostrar"
	L.MODE_HIDE = "Esconder"
	L.MSG_COMBAT = "As alterações do Hide! aplicam-se quando o combate acabar."
	L.NEW_RULE = "Nova regra"
	L.NEW_RULE_DESC = "Uma regra: as frames dela, as condições e Mostrar ou Esconder."
	L.RULES_FULL = "No máximo 10 regras."
	L.RULE = "Regra %d"
	L.REMOVE = "Apagar regra"
	L.REMOVE_DESC = "A regra desaparece e as frames dela voltam à Blizzard."
	L.FRAMES = "Frames"
	L.FRAMES_DESC = "As frames que esta regra mostra ou esconde. Uma frame só pode estar numa regra: as que estão noutra aparecem a cinzento."
	L.FRAMES_NONE = "Nenhuma frame"
	L.FRAMES_COUNT = "%d frames"
	L.CHECK_ALL = "Marcar todas"
	L.UNCHECK_ALL = "Desmarcar todas"
	L.DELAY = "Atraso depois do combate"
	L.DELAY_DESC = "Se aparece em combate, a frame fica visível durante este tempo depois do combate."
	L.DELAY_OFF = "Só numa regra com Em combate e Mostrar."

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
	L.C_instance = "Numa instância"
	L.C_target = "Tem alvo"
	L.C_harm = "Alvo hostil"
	L.C_help = "Alvo amigável"
	L.C_pet = "Tem pet"
	L.C_vehicle = "Num veículo"
	L.C_form = "Numa forma ou postura"

	L.F_player = "Jogador"
	L.F_pet = "Pet"
	L.F_target = "Alvo"
	L.F_tot = "Alvo do alvo"
	L.F_focus = "Foco"
	L.F_focustot = "Alvo do foco"
	L.F_minimap = "Minimapa"
	L.F_buffs = "Buffs"
	L.F_debuffs = "Debuffs"
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
--   Nothing changes in combat: changes wait for it to end. In Edit Mode (and
--   Blizzard's Quick Keybind mode) every
--   parent is shown so the frames can be moved.
--   The rules (below) say which frames go with which conditions; frames
--   shown in combat can stay a while after it (the delay).
-- SetGoHideDB: rules = { [1 to 10] = { on = true, seq = order made,
--   when = bitmask of CONDS, mode = "show"/"hide", delay = seconds,
--   cd = true } }, frameRule = { [frame key] = rule }, version = 5;
--   migrateFollow until the old Anchored frames are read (ResolveFollow)
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
	-- in a party or a raid
	{ key = "party", macro = "group" },
	-- "In a raid" (until 1.1.0): read as "In a group" now, never listed
	{ key = "raid" },
	{ key = "target", macro = "@target,exists" },
	{ key = "harm", macro = "@target,harm" },
	{ key = "help", macro = "@target,help" },
	{ key = "pet", macro = "pet" },
	{ key = "vehicle", macro = "vehicleui" },
	{ key = "form", macro = "form" },
	-- "health below 100%" (removed in 0.7.0): kept out of every rule, so old
	-- rules and profiles that still have it don't read as anything else
	{ key = "_health", reserved = true },
	-- no macro conditional for it: worked out by Hide! (Driver)
	{ key = "instance" },
}
local NONE = 1
local GROUP_BIT, RAID_BIT, INSTANCE_BIT = 11, 12, 20
-- the order of the list (the bits above never move, so saved rules stay)
local ORDER = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 20, 13, 14, 15, 16, 17, 18 }
-- the bits a rule can use
local KNOWN_BITS = 0
for i, c in ipairs(CONDS) do
	if not c.reserved and i ~= RAID_BIT then
		KNOWN_BITS = bit.bor(KNOWN_BITS, bit.lshift(1, i - 1))
	end
end

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
	{ group = "hud", key = "buffs", names = { "BuffFrame" } },
	{ group = "hud", key = "debuffs", names = { "DebuffFrame" } },
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
local reveal = false -- the cursor holds something or the spellbook is open

-- a saved bitmask as it reads now: "In a raid" becomes "In a group", and
-- the bits no longer used go
local function Clean(when)
	when = tonumber(when) or DEFAULT_WHEN
	local raid = bit.lshift(1, RAID_BIT - 1)
	if bit.band(when, raid) ~= 0 then
		when = bit.bor(bit.band(when, bit.bnot(raid)), bit.lshift(1, GROUP_BIT - 1))
	end
	when = bit.band(when, KNOWN_BITS)
	if when == 0 then
		when = NONE
	end
	return when
end

-- a frame's rule before the rules (build 25 and older), for the migration
local function OldRule(key)
	local r = db and db[key]
	local when = type(r) == "table" and tonumber(r.when) or DEFAULT_WHEN
	local mode = type(r) == "table" and (r.mode == "hide" and "hide" or "show") or DEFAULT_MODE
	when = Clean(when)
	if when == 0 then
		when = NONE
	end
	return when, mode
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
-- Before the rules (build 25 and older), only read by the migration:
--   Hide! only dealt with the frames in its list (SetGoHideDB.listed). A
--   frame out of the list that is anchored in Edit Mode to one of the list
--   (directly or through other frames out of the list) follows its rule when
--   it is ticked in that frame's "Anchored frames" (.follows). The nearest
--   frame of the list, going up the anchors, is the one it can follow.
--   The anchor is read from the frame itself (GetPoint), so it is always the
--   current layout's. A frame anchored to something that is not one of these
--   frames (or a child of one) counts as not anchored.
--------------------------------------------------------------------------------

local anchorCache, anchorStamp = nil, nil

local function ReadAnchors()
	local owner = {} -- [Blizzard frame] = frame key
	for _, e in ipairs(FRAMES) do
		for _, f in ipairs(Resolve(e)) do
			owner[f] = e.key
		end
	end
	local anchors = {}
	for _, e in ipairs(FRAMES) do
		local f = Resolve(e)[1]
		local n = f and f.GetNumPoints and f:GetNumPoints() or 0
		for i = 1, n do
			local ok, _, rel = pcall(f.GetPoint, f, i)
			-- the frame anchored to, or the first of its parents on the list
			local hops = 0
			while ok and type(rel) == "table" and rel ~= UIParent and hops < 8 do
				local k = owner[rel]
				if k then
					if k ~= e.key then
						anchors[e.key] = k
					end
					break
				end
				local okp, p = pcall(rel.GetParent, rel)
				rel = okp and p or nil
				hops = hops + 1
			end
			if anchors[e.key] then
				break
			end
		end
	end
	return anchors
end

-- read once per frame drawn at most
local function Anchors()
	local now = GetTime()
	if not anchorCache or anchorStamp ~= now then
		anchorCache, anchorStamp = ReadAnchors(), now
	end
	return anchorCache
end

-- The nearest frame of the list going up a frame's anchors (frames out of
-- the list don't stop the chain), or nil
local function Parent(key, listed)
	local anchors = Anchors()
	local seen = { [key] = true }
	local k = anchors[key]
	while k and not seen[k] do
		if listed(k) then
			return k
		end
		seen[k] = true
		k = anchors[k]
	end
	return nil
end

--------------------------------------------------------------------------------
-- The rules (SetGoHideDB.rules, up to MAX_RULES): each has its conditions,
-- Show or Hide, its out of combat delay and, for action bars 1 to 8, the
-- cooldown icons; the frames it deals with are kept per frame
-- (SetGoHideDB.frameRule), so a frame is in one rule at most. A rule is
-- there while .on; .seq is the order it was made in (the page's order).
--------------------------------------------------------------------------------
local MAX_RULES = 10
local COMBAT_BIT = 2 -- CONDS[2]
-- the bars that can show cooldown icons while hidden (Cooldowns.lua)
local COOLDOWN_BARS = { bar1 = true, bar2 = true, bar3 = true, bar4 = true, bar5 = true, bar6 = true, bar7 = true, bar8 = true }

local function RuleData(n)
	local r = db and type(db.rules) == "table" and db.rules[n]
	return type(r) == "table" and r.on and r or nil
end

local function RuleOf(r)
	local when = Clean(r and r.when)
	local mode = r and r.mode == "hide" and "hide" or "show"
	return when, mode
end

-- the rule a frame is in (one that is there), or nil
local function FrameRule(key)
	local t = db and db.frameRule
	local n = type(t) == "table" and tonumber(t[key]) or nil
	return n and RuleData(n) and n or nil
end

local function DelaySeconds(n)
	local r = RuleData(n)
	local d = r and tonumber(r.delay) or 0
	return d > 0 and d or 0
end

local function Cooldowns(n)
	local r = RuleData(n)
	return r and r.cd == true or false
end

-- Out of combat delay, per rule: while it is "held" (from the start of
-- combat until its delay after it is over), a rule that shows its frames in
-- combat shows them always. In combat that is the same thing; after it, the
-- frames stay a while.
local held = {} -- [rule] = true

-- "In an instance" has no macro conditional: read when the rules are applied
-- (out of combat; a loading screen comes before any change)
local function InInstance()
	local ok, inside = pcall(IsInInstance)
	return ok and inside and true or false
end

-- the state driver of a frame; nil = leave the frame alone, "hide" = always
local function Driver(key)
	local n = FrameRule(key)
	if not n then
		return nil
	end
	local when, mode = RuleOf(RuleData(n))
	if bit.band(when, NONE) ~= 0 then
		return mode == "hide" and "hide" or nil
	end
	-- a condition known to be on: the rule's choice, all the time
	local always = (held[n] and mode == "show" and bit.band(when, Bit(COMBAT_BIT)) ~= 0)
		or (bit.band(when, Bit(INSTANCE_BIT)) ~= 0 and InInstance())
	if always then
		return mode == "show" and "show" or "hide"
	end
	local parts = {}
	for i, c in ipairs(CONDS) do
		if c.macro and bit.band(when, Bit(i)) ~= 0 then
			parts[#parts + 1] = "[" .. c.macro .. "]"
		end
	end
	-- no condition can be on (only "In an instance", outside one)
	if #parts == 0 then
		return mode == "show" and "hide" or nil
	end
	local conds = table.concat(parts)
	if mode == "show" then
		return conds .. " show; hide"
	end
	return conds .. " hide; show"
end

--------------------------------------------------------------------------------
-- Applying
--------------------------------------------------------------------------------

local started, editing = false, false
-- Blizzard's Quick Keybind mode is open: everything shows, as in Edit Mode
local keybinding = false
local containers = {} -- [driver] = our parent frame
local moved = {} -- [Blizzard frame] = its own parent

-- a Blizzard frame Hide! has a rule for (Cooldowns.lua asks)
function ns.HideManaged(f)
	return moved[f] ~= nil
end
local events = CreateFrame("Frame")
local DropOldOptions, Migrate

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
	-- the anchors as they are now
	anchorCache = nil
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
		local want = (used[c] and not editing and not keybinding) and driver or false
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
	WatchReveal(bars)
	if ns.CooldownsRefresh then
		local any = false
		for key in pairs(COOLDOWN_BARS) do
			local n = FrameRule(key)
			if n and Cooldowns(n) then
				any = true
			end
		end
		ns.CooldownsRefresh(any)
	end
	return true
end

local function Changed()
	if started and Apply() == false then
		SetGo.Print(L.MSG_COMBAT)
	end
end

-- Quick Keybind mode: only listening to its window opening and closing (it
-- opens out of combat only). It can come with an addon of Blizzard's that
-- loads later, so this is tried again as addons load.
local keybindHooked = false
local function HookQuickKeybind()
	local f = _G.QuickKeybindFrame
	if keybindHooked or type(f) ~= "table" or not f.HookScript then
		return
	end
	keybindHooked = true
	f:HookScript("OnShow", function()
		keybinding = true
		Apply()
	end)
	f:HookScript("OnHide", function()
		keybinding = false
		Apply()
	end)
	if f:IsShown() then
		keybinding = true
	end
end

local function Start()
	started = true
	HookQuickKeybind()
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
	-- combat start and end: the out of combat delay (and changes waiting)
	events:RegisterEvent("PLAYER_REGEN_DISABLED")
	events:RegisterEvent("PLAYER_REGEN_ENABLED")
	-- Blizzard places the frames of a layout (at login, or a new layout):
	-- the anchors are read again
	pcall(events.RegisterEvent, events, "EDIT_MODE_LAYOUTS_UPDATED")
	-- into or out of an instance (always after a loading screen)
	events:RegisterEvent("PLAYER_ENTERING_WORLD")
	Apply()
end

-- the delay: begun at the start of combat (before the lockdown, so nothing
-- flickers when combat ends), counted from its end; a new combat starts over
local holdGen = 0

local function HoldStart()
	holdGen = holdGen + 1
	local any = false
	for n = 1, MAX_RULES do
		if DelaySeconds(n) > 0 then
			held[n] = true
			any = true
		end
	end
	if any then
		Apply()
	end
end

local function HoldEnd()
	local gen = holdGen
	for key in pairs(held) do
		C_Timer.After(DelaySeconds(key), function()
			if gen == holdGen and held[key] then
				held[key] = nil
				Apply()
			end
		end)
	end
end

-- the cooldown icons of a bar (Cooldowns.lua asks): its rule's
function ns.HideCooldownsFor(bar)
	for _, e in ipairs(FRAMES) do
		if COOLDOWN_BARS[e.key] then
			for _, f in ipairs(Resolve(e)) do
				if f == bar then
					local n = FrameRule(e.key)
					return n and Cooldowns(n) or false
				end
			end
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Page in SetGo!
--   A card per rule, in the order they were made (Blizzard's tooltip border
--   in bronze, on a dark ground), then a lighter card, "New rule". Each
--   card: its frames (a menu with a box for each, by kind; the ones in
--   another rule greyed) and an X that removes the rule, the conditions and
--   Show or Hide, the out of combat delay and, with action bars 1 to 8 in
--   it, the cooldown icons.
--------------------------------------------------------------------------------

local PAD, GAP, ADD_H = 10, 10, 40

-- Blizzard's tooltip border in bronze (the frame is made with
-- BackdropTemplate), on a dark see-through ground; else SetGo!'s own card
local CARD_BACKDROP = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 14,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local function CardLook(c, alpha)
	if c.SetBackdrop then
		c:SetBackdrop(CARD_BACKDROP)
		c:SetBackdropColor(0, 0, 0, alpha or 0.45)
		c:SetBackdropBorderColor(0.80, 0.55, 0.30, 1)
		return
	end
	local ui = SetGo.ui
	if ui and ui.Card then
		ui.Card(c)
		if c.Look then
			c:Look(alpha or 0.07, 0.35, false)
		end
	end
end

-- After a change on the page: the cards follow (the page is laid out
-- again on the next frame, once, whatever changed)
local redrawQueued = false
local function Redraw()
	if redrawQueued or not SetGo.Refresh then
		return
	end
	redrawQueued = true
	C_Timer.After(0, function()
		redrawQueued = false
		SetGo.Refresh()
	end)
end

local function Put(setting, value)
	SetGo.Set(setting, value)
	Redraw()
end

local function Seconds(v)
	return ("%.1f s"):format(math.floor(v * 2 + 0.5) / 2)
end

local function SliderFormatters()
	if MinimalSliderWithSteppersMixin and CreateMinimalSliderFormatter then
		local right = MinimalSliderWithSteppersMixin.Label.Right
		return { [right] = CreateMinimalSliderFormatter(right, Seconds) }
	end
end

-- Blizzard's "New" beside a menu entry (as its dungeon finder does), until
-- the mouse goes over it (SetGo!'s NEW_FEATURES)
local function NewMark(item, key)
	if not (item and item.AddInitializer and SetGo.IsNew and SetGo.IsNew(key)) then
		return
	end
	item:AddInitializer(function(button)
		if not SetGo.IsNew(key) or not (MenuTemplates and MenuTemplates.AttachNewFeatureFrame) then
			return
		end
		local ok, label = pcall(MenuTemplates.AttachNewFeatureFrame, button)
		if ok and label and button.fontString then
			local w = label.GetTextWidth and label:GetTextWidth() or 30
			label:SetPoint("LEFT", button.fontString, "RIGHT", w / 2 + 5, 0)
		end
	end)
	if item.SetOnEnter then
		item:SetOnEnter(function()
			SetGo.SeeNew(key)
		end)
	end
end

-- the names of some frames, for a closed dropdown: all of them while they
-- fit, else how many
local function FrameNames(keys)
	if #keys == 0 then
		return L.FRAMES_NONE
	end
	local names = {}
	for _, key in ipairs(keys) do
		names[#names + 1] = L["F_" .. key] or key
	end
	local text = table.concat(names, ", ")
	if #keys > 3 then
		text = L.FRAMES_COUNT:format(#keys)
	end
	return text
end

-- one rule's card, built once (for each of the MAX_RULES) and shown while
-- the rule is there
local function BuildCard(parent, n, set, frames, shown, width)
	local W = SetGo.Widgets
	local inner = width - 2 * PAD
	local half = math.floor(inner / 2)
	local r, g, b = W.Ink()
	local c = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	CardLook(c)
	local y = PAD

	-- the frames of this rule; the ones in another rule are greyed
	local function Mine()
		local list = {}
		for _, e in ipairs(FRAMES) do
			if shown.rule(e.key) == n then
				list[#list + 1] = e.key
			end
		end
		return list
	end
	local function Free(key)
		local other = shown.rule(key)
		return other == 0 or other == n or not shown.on(other)
	end
	local fd = CreateFrame("DropdownButton", nil, c, "WowStyle1DropdownTemplate")
	fd:SetPoint("TOPLEFT", c, "TOPLEFT", PAD + 2, -y)
	fd:SetWidth(math.min(300, inner - 34))
	W.TipScripts(fd, L.FRAMES, L.FRAMES_DESC, true)
	fd:SetupMenu(function(_, root)
		local function All(on)
			return function()
				for _, e in ipairs(FRAMES) do
					if #Resolve(e) > 0 and Free(e.key) then
						SetGo.Set(frames[e.key], on and n or 0)
					end
				end
				Redraw()
				return MenuResponse and MenuResponse.Refresh
			end
		end
		root:CreateButton(L.CHECK_ALL, All(true))
		root:CreateButton(L.UNCHECK_ALL, All(false))
		root:CreateDivider()
		for _, grp in ipairs(GROUPS) do
			root:CreateTitle(L[grp.title])
			for _, e in ipairs(FRAMES) do
				if e.group == grp.key and #Resolve(e) > 0 then
					local key = e.key
					local item = root:CreateCheckbox(L["F_" .. key] or key, function()
						return shown.rule(key) == n
					end, function()
						Put(frames[key], shown.rule(key) == n and 0 or n)
						return MenuResponse and MenuResponse.Refresh
					end)
					if item and item.SetEnabled and not Free(key) then
						item:SetEnabled(false)
					end
				end
			end
		end
	end)

	-- the rule goes, and its frames are free again
	local x = CreateFrame("Button", nil, c, "UIPanelCloseButton")
	x:SetSize(24, 24)
	x:SetPoint("TOPRIGHT", c, "TOPRIGHT", -4, -4)
	x:SetFrameLevel(c:GetFrameLevel() + 10)
	x:SetScript("OnClick", function()
		SetGo.Sound("IG_MAINMENU_OPTION_CHECKBOX_OFF", 857)
		for _, key in ipairs(Mine()) do
			SetGo.Set(frames[key], 0)
		end
		Put(set.on, false)
	end)
	W.TipScripts(x, L.REMOVE, L.REMOVE_DESC)
	y = y + 26 + 8

	-- the conditions, and Show or Hide
	local MODE_W = 110
	local dd = CreateFrame("DropdownButton", nil, c, "WowStyle1DropdownTemplate")
	dd:SetPoint("TOPLEFT", c, "TOPLEFT", PAD + 2, -y)
	dd:SetWidth(math.max(120, math.min(250, inner - MODE_W - 12)))
	W.TipScripts(dd, L.WHEN, L.WHEN_DESC, true)
	local function Current()
		return Clean(SetGo.Get(set.when))
	end
	dd:SetupMenu(function(_, root)
		for _, i in ipairs(ORDER) do
			local cond = CONDS[i]
			local bitValue = Bit(i)
			local item = root:CreateCheckbox(L["C_" .. cond.key], function()
				return bit.band(Current(), bitValue) ~= 0
			end, function()
				Put(set.when, Toggle(Current(), bitValue))
				-- the list stays open to pick more than one
				return MenuResponse and MenuResponse.Refresh
			end)
			if cond.key == "instance" then
				NewMark(item, "instance")
			end
		end
	end)
	local md = CreateFrame("DropdownButton", nil, c, "WowStyle1DropdownTemplate")
	md:SetPoint("LEFT", dd, "RIGHT", 8, 0)
	md:SetWidth(MODE_W)
	W.TipScripts(md, L.MODE, L.MODE_DESC, true)
	md:SetupMenu(function(_, root)
		for _, opt in ipairs({ { "show", L.MODE_SHOW }, { "hide", L.MODE_HIDE } }) do
			root:CreateRadio(opt[2], function()
				return SetGo.Get(set.mode) == opt[1]
			end, function()
				Put(set.mode, opt[1])
			end)
		end
	end)
	y = y + 26 + 8

	-- the out of combat delay (only for a rule with In combat and Show) and,
	-- when the rule has one of action bars 1 to 8, the cooldown icons beside it
	local delayText = W.Text(c, W.FONT_SMALL, half, L.DELAY)
	delayText:SetPoint("TOPLEFT", c, "TOPLEFT", PAD, -y)
	local slider = CreateFrame("Frame", nil, c, "MinimalSliderWithSteppersTemplate")
	slider:SetPoint("TOPLEFT", c, "TOPLEFT", PAD + 4, -(y + 16))
	slider:SetSize(math.min(250, half - 50), 20)
	local formatters = SliderFormatters()
	local busy = false
	slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
		if not busy then
			SetGo.Set(set.delay, value)
		end
	end, slider)
	local function Usable()
		local when = Current()
		return SetGo.Get(set.mode) == "show" and bit.band(when, NONE) == 0
			and bit.band(when, Bit(COMBAT_BIT)) ~= 0
	end
	W.TipScripts(slider, L.DELAY, function()
		return Usable() and L.DELAY_DESC or (L.DELAY_DESC .. "\n\n" .. L.DELAY_OFF)
	end, true)
	local CL = ns.CooldownL
	local cool = CreateFrame("CheckButton", nil, c, "UICheckButtonTemplate")
	cool:SetSize(24, 24)
	cool:SetPoint("TOPLEFT", c, "TOPLEFT", PAD - 2 + half, -(y + 12))
	local coolText = W.Text(c, W.FONT_SMALL, inner - half - 28, CL.TOGGLE)
	coolText:SetPoint("LEFT", cool, "RIGHT", 2, 0)
	coolText:SetWordWrap(false)
	W.TipScripts(cool, CL.TOGGLE, CL.TOGGLE_DESC)
	cool:SetScript("OnClick", function(self)
		SetGo.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
		Put(set.cooldowns, self:GetChecked() and true or false)
	end)
	y = y + 16 + 20 + PAD
	c:SetSize(width, y)

	c.refresh = function()
		fd:GenerateMenu()
		dd:GenerateMenu()
		md:GenerateMenu()
		local mine = Mine()
		local text = FrameNames(mine)
		if fd.OverrideText then
			fd:OverrideText(text)
		elseif fd.SetDefaultText then
			fd:SetDefaultText(text)
		end
		busy = true
		local value = math.max(0, math.min(10, tonumber(SetGo.Get(set.delay)) or 0))
		slider:Init(value, 0, 10, 20, formatters)
		for _, key in ipairs({ "LeftText", "RightText", "TopText", "MinText", "MaxText" }) do
			local fs = slider[key]
			if type(fs) == "table" and fs.SetTextColor then
				fs:SetTextColor(r, g, b)
				fs:SetShadowColor(0, 0, 0, 0)
			end
		end
		busy = false
		local usable = Usable()
		if slider.SetEnabled then
			pcall(slider.SetEnabled, slider, usable)
		end
		slider:SetAlpha(usable and 1 or 0.5)
		delayText:SetAlpha(usable and 1 or 0.5)
		-- the cooldown icons: only with an action bar 1 to 8 in the rule
		local bars = false
		for _, key in ipairs(mine) do
			if COOLDOWN_BARS[key] then
				bars = true
			end
		end
		cool:SetShown(bars)
		coolText:SetShown(bars)
		cool:SetChecked(SetGo.Get(set.cooldowns) and true or false)
	end
	return c
end

local function CardsBuilder(rules, frames)
	return function(page, y, width)
		local W = SetGo.Widgets
		local holder = CreateFrame("Frame", nil, page)
		holder:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
		holder:SetWidth(width)

		-- read as the page shows them (staged in a profile being edited)
		local shown = {
			on = function(n)
				return rules[n] and SetGo.Get(rules[n].on) and true or false
			end,
			rule = function(key)
				return tonumber(SetGo.Get(frames[key])) or 0
			end,
		}

		local cards = {}
		for n = 1, MAX_RULES do
			cards[n] = BuildCard(holder, n, rules[n], frames, shown, width)
		end

		-- the last card: New rule, in the first free place
		local add = CreateFrame("Button", nil, holder, BackdropTemplateMixin and "BackdropTemplate" or nil)
		add:SetSize(width, ADD_H)
		CardLook(add, 0.25)
		local hl = add:CreateTexture(nil, "HIGHLIGHT")
		hl:SetPoint("TOPLEFT", 4, -4)
		hl:SetPoint("BOTTOMRIGHT", -4, 4)
		hl:SetColorTexture(1, 1, 1, 0.06)
		local addText = W.Text(add, W.FONT_BODY, width - 20, "+ " .. L.NEW_RULE)
		addText:SetPoint("CENTER")
		addText:SetJustifyH("CENTER")
		W.TipScripts(add, L.NEW_RULE, function()
			for n = 1, MAX_RULES do
				if not shown.on(n) then
					return L.NEW_RULE_DESC
				end
			end
			return L.RULES_FULL
		end)
		add:SetScript("OnClick", function()
			for n = 1, MAX_RULES do
				if not shown.on(n) then
					SetGo.Sound("IG_MAINMENU_OPTION_CHECKBOX_ON", 856)
					local set = rules[n]
					SetGo.Set(set.when, DEFAULT_WHEN)
					SetGo.Set(set.mode, DEFAULT_MODE)
					SetGo.Set(set.delay, 0)
					SetGo.Set(set.cooldowns, false)
					Put(set.on, true)
					return
				end
			end
		end)

		-- the rules there, in the order they were made, then New rule; the
		-- page grows or shrinks with them
		local function Layout()
			local list = {}
			for n = 1, MAX_RULES do
				if shown.on(n) then
					list[#list + 1] = n
				else
					cards[n]:Hide()
				end
			end
			local function Seq(n)
				local d = db and type(db.rules) == "table" and db.rules[n]
				return type(d) == "table" and tonumber(d.seq) or (1000 + n)
			end
			table.sort(list, function(a, b2)
				return Seq(a) < Seq(b2)
			end)
			local yy = 0
			for _, n in ipairs(list) do
				local card = cards[n]
				card:ClearAllPoints()
				card:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, -yy)
				card:Show()
				card.refresh()
				yy = yy + card:GetHeight() + GAP
			end
			add:ClearAllPoints()
			add:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, -yy)
			add:SetAlpha(#list < MAX_RULES and 1 or 0.5)
			yy = yy + ADD_H
			holder:SetHeight(math.max(yy, 1))
			return yy
		end

		local height = Layout()
		local queued = false
		table.insert(page.refreshers, function()
			local before = holder:GetHeight()
			Layout()
			local delta = holder:GetHeight() - before
			if delta ~= 0 then
				page:SetHeight(page:GetHeight() + delta)
				-- the page (or the profile's list) lays itself out again
				if SetGo.Refresh and not queued then
					queued = true
					C_Timer.After(0, function()
						queued = false
						SetGo.Refresh()
					end)
				end
			end
		end)
		return y + height + 10
	end
end

-- a rule's data, made when a setting of it comes (a profile's, in any order)
local function RuleTable(n)
	db.rules = type(db.rules) == "table" and db.rules or {}
	db.rules[n] = type(db.rules[n]) == "table" and db.rules[n] or {}
	return db.rules[n]
end

local items
local function Items()
	if items then
		return items
	end
	local Pseudo = SetGo.Pseudo
	local CL = ns.CooldownL
	local all, rules, frames = {}, {}, {}
	local function On(value)
		return value and value ~= 0 and value ~= "0" and true or false
	end
	for n = 1, MAX_RULES do
		local var = "SETGO_HIDE_RULE" .. n
		local name = L.RULE:format(n)
		local set = {}
		-- the rule is there
		set.on = Pseudo(var .. "_ON", name, L.NEW_RULE_DESC, false, function()
			return RuleData(n) ~= nil
		end, function(value)
			if On(value) then
				local r = RuleTable(n)
				if not r.on then
					-- after the others, on the page
					local last = 0
					for _, other in pairs(db.rules) do
						if type(other) == "table" and other.on then
							last = math.max(last, tonumber(other.seq) or 0)
						end
					end
					r.on, r.seq = true, last + 1
				end
			else
				if type(db.rules) == "table" then
					db.rules[n] = nil
					if not next(db.rules) then
						db.rules = nil
					end
				end
				-- its frames are free again
				if type(db.frameRule) == "table" then
					for key, rule in pairs(db.frameRule) do
						if tonumber(rule) == n then
							db.frameRule[key] = nil
						end
					end
				end
				held[n] = nil
			end
			Changed()
		end)
		set.when = Pseudo(var .. "_WHEN", name .. ": " .. L.WHEN, L.WHEN_DESC, DEFAULT_WHEN, function()
			return (RuleOf(RuleData(n)))
		end, function(value)
			RuleTable(n).when = Clean(value)
			Changed()
		end)
		set.mode = Pseudo(var .. "_MODE", name .. ": " .. L.MODE, L.MODE_DESC, DEFAULT_MODE, function()
			return select(2, RuleOf(RuleData(n)))
		end, function(value)
			RuleTable(n).mode = value == "hide" and "hide" or "show"
			Changed()
		end)
		-- seconds its frames stay after combat (0 = none)
		set.delay = Pseudo(var .. "_DELAY", name .. ": " .. L.DELAY, L.DELAY_DESC, 0, function()
			return DelaySeconds(n)
		end, function(value)
			local d = math.floor((tonumber(value) or 0) * 2 + 0.5) / 2
			d = math.max(0, math.min(10, d))
			RuleTable(n).delay = d > 0 and d or nil
			-- turned off while waiting: the frames go back now
			if d == 0 and held[n] then
				held[n] = nil
				Changed()
			end
		end)
		-- its action bars 1 to 8: cooldown icons while hidden (Cooldowns.lua)
		set.cooldowns = Pseudo(var .. "_COOLDOWNS", name .. ": " .. CL.TOGGLE, CL.TOGGLE_DESC, false, function()
			return Cooldowns(n)
		end, function(value)
			RuleTable(n).cd = On(value) or nil
			Changed()
		end)
		rules[n] = set
		for _, k in ipairs({ "on", "when", "mode", "delay", "cooldowns" }) do
			all[#all + 1] = set[k]
		end
	end
	-- each frame: the rule it is in (0 = none)
	for _, e in ipairs(FRAMES) do
		local key = e.key
		frames[key] = Pseudo("SETGO_HIDE_" .. key:upper() .. "_RULE", L["F_" .. key] .. ": " .. L.FRAMES, L.FRAMES_DESC, 0, function()
			local t = db and db.frameRule
			return type(t) == "table" and tonumber(t[key]) or 0
		end, function(value)
			local v = math.floor(tonumber(value) or 0)
			db.frameRule = type(db.frameRule) == "table" and db.frameRule or {}
			db.frameRule[key] = (v >= 1 and v <= MAX_RULES) and v or nil
			if not next(db.frameRule) then
				db.frameRule = nil
			end
			Changed()
		end)
		all[#all + 1] = frames[key]
	end
	items = {
		{ kind = "note", name = L.NOTE },
		{ kind = "note", name = L.NOTE_BLIZZARD },
		-- every rule's settings and each frame's rule, so profiles keep them
		{ kind = "custom", name = L.TITLE, settings = all, build = CardsBuilder(rules, frames) },
	}
	return items
end

SetGo.RegisterModule({ key = "hide", title = L.TITLE, items = Items })

-- Names out of combat and the hidden buffs icon were tried for a few builds
-- and taken out: the names they hid for a while go back to the player's
-- values (only those still as they left them), and their data goes.
DropOldOptions = function()
	if type(db) ~= "table" then
		return
	end
	local n = db.names
	if type(n) == "table" and type(n.base) == "table" and type(n.wrote) == "table" and next(n.wrote) then
		if InCombatLockdown() then
			events:RegisterEvent("PLAYER_REGEN_ENABLED")
			return
		end
		for var, base in pairs(n.base) do
			local wrote = n.wrote[var]
			if wrote ~= nil and C_CVar.GetCVar(var) == wrote then
				pcall(C_CVar.SetCVar, var, base)
			end
		end
	end
	db.names, db.buffIcon = nil, nil
	db.enemyNames, db.enemyNamesKey, db.friendNames, db.friendNamesKey = nil, nil, nil, nil
end

-- a per frame switch kept as { [frame key] = true } (before the rules)
local function Flag(field, key, on)
	db[field] = type(db[field]) == "table" and db[field] or {}
	db[field][key] = on or nil
	if not next(db[field]) then
		db[field] = nil
	end
end

-- Before the list (1.1.0 and older): every frame had a row and the anchors
-- had a switch of their own. The frames with a rule go in the list; with the
-- anchors switched on, each of them passes its rule on. The accordions' open
-- or closed state goes.
function Migrate()
	if (tonumber(db.version) or 1) >= 2 then
		return
	end
	for _, e in ipairs(FRAMES) do
		if type(db[e.key]) == "table" then
			Flag("listed", e.key, true)
			if db.anchors then
				Flag("anchored", e.key, true)
			end
		end
	end
	db.anchors, db.nofollow, db._ui = nil, nil, nil
	db.version = 2
end

-- Before the cards (build 19 and older): the out of combat delay and the
-- cooldown icons were one setting for every frame. The delay goes to every
-- frame in the list; the cooldown icons to the action bars in the list
-- with a rule of their own.
local function MigrateCards()
	if (tonumber(db.version) or 1) >= 3 then
		return
	end
	local delay = tonumber(db.delay)
	for _, e in ipairs(FRAMES) do
		if type(db.listed) == "table" and db.listed[e.key] then
			if delay and delay > 0 then
				db.delays = type(db.delays) == "table" and db.delays or {}
				db.delays[e.key] = delay
			end
			if db.cooldowns == true and COOLDOWN_BARS[e.key] and type(db[e.key]) == "table" then
				Flag("cdbars", e.key, true)
			end
		end
	end
	db.delay, db.cooldowns = nil, nil
	db.version = 3
end

-- Before the rules (build 25 and older): a card per frame. Each card becomes
-- a rule with its frame; cards with the very same rule (conditions, Show or
-- Hide, delay, cooldown icons) become one. The frames that followed a card
-- (its Anchored frames) join its rule once the frames are placed
-- (ResolveFollow, at the first loading screen): until then their anchors
-- can't be read.
local function MigrateRules()
	if (tonumber(db.version) or 1) >= 5 then
		return
	end
	local listed = type(db.listed) == "table" and db.listed or {}
	local delays = type(db.delays) == "table" and db.delays or {}
	local cdbars = type(db.cdbars) == "table" and db.cdbars or {}
	local rules, frameRule, ruleOf, bySig, count = {}, {}, {}, {}, 0
	for _, e in ipairs(FRAMES) do
		local key = e.key
		if listed[key] then
			local when, mode = OldRule(key)
			local delay = tonumber(delays[key]) or 0
			local cd = cdbars[key] == true
			local sig = table.concat({ when, mode, delay, cd and 1 or 0 }, ":")
			local n = bySig[sig]
			if not n and count < MAX_RULES then
				count = count + 1
				n = count
				bySig[sig] = n
				rules[n] = { on = true, seq = n, when = when, mode = mode, delay = delay > 0 and delay or nil, cd = cd or nil }
			end
			if n then
				frameRule[key] = n
				ruleOf[key] = n
			end
		end
	end
	if next(listed) then
		db.migrateFollow = { listed = listed, follows = db.follows, anchored = db.anchored, ruleOf = ruleOf }
	end
	for _, e in ipairs(FRAMES) do
		db[e.key] = nil
	end
	db.listed, db.follows, db.anchored, db.delays, db.cdbars = nil, nil, nil, nil, nil
	db.rules = next(rules) and rules or nil
	db.frameRule = next(frameRule) and frameRule or nil
	db.version = 5
end

-- the frames that followed a card before the rules, now that the frames are
-- placed and their anchors can be read
local function ResolveFollow()
	local m = db and db.migrateFollow
	if type(m) ~= "table" then
		return
	end
	db.migrateFollow = nil
	local listed = type(m.listed) == "table" and m.listed or {}
	local follows = type(m.follows) == "table" and m.follows or {}
	local anchored = type(m.anchored) == "table" and m.anchored or {}
	local ruleOf = type(m.ruleOf) == "table" and m.ruleOf or {}
	local function WasListed(key)
		return listed[key] == true
	end
	for _, e in ipairs(FRAMES) do
		local key = e.key
		local has = type(db.frameRule) == "table" and db.frameRule[key]
		if not listed[key] and not has then
			local parent = Parent(key, WasListed)
			local follow
			if parent then
				if follows[key] ~= nil then
					follow = follows[key] == true
				else
					follow = anchored[parent] == true
				end
			end
			if follow and ruleOf[parent] then
				db.frameRule = type(db.frameRule) == "table" and db.frameRule or {}
				db.frameRule[key] = ruleOf[parent]
			end
		end
	end
	Changed()
end

events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == ADDON then
			SetGoHideDB = type(SetGoHideDB) == "table" and SetGoHideDB or {}
			db = SetGoHideDB
			-- the action bar art copy is gone (0.6.0)
			db._art = nil
			Migrate()
			MigrateCards()
			MigrateRules()
		else
			if revealing then
				-- the spellbook can be an addon of Blizzard's that loads later
				HookSpellbooks()
			end
			if started then
				HookQuickKeybind()
			end
		end
	elseif event == "PLAYER_LOGIN" then
		DropOldOptions()
		-- switched off in SetGo!: only the settings page is here
		if SetGo.ModuleOn("hide") then
			Start()
		end
	elseif event == CURSOR_EVENT then
		RevealChanged()
	elseif event == "PLAYER_REGEN_DISABLED" then
		HoldStart()
	elseif event == "PLAYER_REGEN_ENABLED" then
		-- kept while Hide! runs (the delay); otherwise only for the clean-up
		if not started then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
		DropOldOptions()
		HoldEnd()
		Apply()
	elseif event == "EDIT_MODE_LAYOUTS_UPDATED" or event == "PLAYER_ENTERING_WORLD" then
		-- after Blizzard has placed the frames
		C_Timer.After(0, Apply)
		if db and db.migrateFollow then
			C_Timer.After(0.5, ResolveFollow)
		end
	end
end)
