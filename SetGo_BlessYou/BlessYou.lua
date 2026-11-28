local ADDON, ns = ...
local D = ns.D

local L = {
	TITLE = "BlessYou!",
	HOW = "One button shows the next buff to cast: yours first, then your group's, then a buff back for whoever buffed you. Left click casts it. Right click opens your party's buffs, to change them for as long as you're in that party. Shift + right click dismisses it until you enter an instance or reload, or until that buff is on that person and wears off again. Ctrl + drag moves it (it snaps to the middle of the screen).",
	SEC_WHAT = "What to remind",
	SELF = "Your own buffs",
	SELF_DESC = "Buffs you keep on yourself, and your group buffs while you're missing them.",
	GROUP = "Your group",
	GROUP_DESC = "Your buffs on your party or raid. The group version (Gift of the Wild, Prayer of Fortitude and the like) is used when 3 or more in one party need it and you have the reagent; a greater blessing when 2 or more of one class need the same blessing and you have a Symbol of Kings.",
	RETURN = "Buff back",
	RETURN_DESC = "Someone outside your group who gives you a buff of 5 minutes or more is offered one of yours for the next 10 minutes.",
	SEC_BUFFS = "Reminders",
	REMIND_DESC = "Reminded when less than this is left.",
	MINUTES = "%d min",
	BUFF_DESC = "When it's reminded: never, only while you're in a group, or always.",
	MODE_NEVER = "Never",
	MODE_GROUP = "In a group",
	MODE_ALWAYS = "Always",
	STONE = "Weapon stones",
	FLASK = "Flasks",
	MAIN_HAND = "Main hand",
	OFF_HAND = "Off hand",
	BLESSINGS = "Blessings",
	AURA = "Aura",
	AURA_DESC = "The aura put up when none is on.",
	SEC_BLESS = "Blessing priority: %s",
	BLESS_DESC = "Left to right: the first goes first. When it's already on someone (from another paladin) or you don't know it yet, the second goes, then the third. Blank: nothing.",
	MELEE = "Melee",
	CASTER = "Casters",
	HYBRID = "Hybrids",
	MENU_TITLE = "This party only",
	MENU_BUTTON = "BlessYou! Menu",
	MACRO_DRAG = "Drag to an action bar: a macro that casts the next buff (not stones or flasks). With the mouse over a player, it casts the buff that player is missing.",
	MACRO_FULL = "No free slot for an account macro. Delete one in /macro and try again.",
	VIEW_DEFAULTS = "Defaults",
	SCOPE = "Show reminders for",
	SCOPE_DESC = "Whose missing buffs the button and the macro offer you.",
	SCOPE_SELF = "Just me",
	SCOPE_GROUP = "Me and my group",
	SCOPE_ALL = "Everyone I can buff",
	VIEW_PARTY = "Party",
	CLASS_BUFF = "Buff",
	MANAGER_DESC = "Opens BlessYou!'s settings in SetGo!.",
	MENU_BUTTON_DESC = "A small window with your party and the buff each one gets. Right click a buff to change it, for as long as you're in that party.",
	GRID_TIP = "Right click: change, for this party only",
	GRID_SKIP = "No buff",
	GRID_PRIO = "Blessing priority",
	GRID_PRIO_TIP = "Click: pick the blessing for this place. Left to right: the first goes first; when it's already on someone (from another paladin) or you don't know it yet, the next one goes.",
	EMPTY = "Nothing",
	AUTO_GRID = "Open buff menu automatically",
	AUTO_GRID_DESC = "Shows your party and the buff each one gets as soon as you join a party.",
	SETTINGS = "Settings",
	MENU_DEFAULT = "Default",
	MENU_SKIP = "Don't buff",
	SEC_THANKS = "Thanks",
	THANKS = "Say /thanks",
	THANKS_DESC = "Does /thank at whoever gives you a buff of 5 minutes or more: once every 5 minutes per person, only out of combat, and not for buffs you already had when you logged in, reloaded or changed zone.",
	THANKS_OFF = "Never",
	THANKS_OUT = "Outside your group",
	THANKS_ALL = "Everyone",
	ON_YOU = "On you",
	ON = "On %s",
	ON_PARTY = "On %s's party",
	ON_CLASS = "On every %s",
	BACK = "A buff back for %s",
	NOTE_ACTIVE = "%s already active",
	NOTE_UNKNOWN = "%s not learned yet",
	TIP_CLICKS = "Left click: cast   Right click: dismiss\nCtrl + drag: move",
	OFF_IN_SETGO = "BlessYou! is switched off for this character. Switch it on in SetGo!, Modules.",
	DEBUG_ON = "BlessYou! debug on: who buffs you, and why the button goes away, show here.",
	DEBUG_OFF = "BlessYou! debug off.",
	DEBUG_BUFFED = "%s buffed you with %s (%s, %d min, unit %s)",
	DEBUG_HIDE = "Button hidden (%s): it showed %s, %s",
	DEBUG_THANK = "Thanks: %s",
	THANK_EMOTE = "thanks %s.",
}
if GetLocale() == "ptBR" then
	L.HOW = "Um botão mostra o próximo buff a lançar: primeiro os teus, depois os do grupo, depois um buff de volta para quem te deu um. O clique esquerdo lança-o. O clique direito abre os buffs da tua party, para os mudares enquanto estiveres nessa party. Shift + clique direito dispensa-o até entrares numa instance ou fazeres reload, ou até esse buff estar nessa pessoa e voltar a acabar. Ctrl + arrastar muda-o de sítio (encaixa no centro do ecrã)."
	L.SEC_WHAT = "O que lembrar"
	L.SELF = "Os teus buffs"
	L.SELF_DESC = "Os buffs que manténs em ti, e os teus buffs de grupo enquanto te faltam."
	L.GROUP = "O teu grupo"
	L.GROUP_DESC = "Os teus buffs na party ou na raid. A versão de grupo (Gift of the Wild, Prayer of Fortitude e afins) é usada quando 3 ou mais da mesma party precisam e tens o reagente; uma greater blessing quando 2 ou mais da mesma classe precisam da mesma blessing e tens um Symbol of Kings."
	L.RETURN = "Buff de volta"
	L.RETURN_DESC = "Quem estiver fora do teu grupo e te der um buff de 5 minutos ou mais recebe a oferta de um dos teus durante os 10 minutos seguintes."
	L.SEC_BUFFS = "Lembretes"
	L.REMIND_DESC = "Lembrado quando falta menos do que isto."
	L.BUFF_DESC = "Quando é lembrado: nunca, só quando estás num grupo, ou sempre."
	L.MODE_NEVER = "Nunca"
	L.MODE_GROUP = "Em grupo"
	L.MODE_ALWAYS = "Sempre"
	L.STONE = "Pedras de arma"
	L.FLASK = "Flasks"
	L.MAIN_HAND = "Mão principal"
	L.OFF_HAND = "Mão secundária"
	L.BLESSINGS = "Blessings"
	L.AURA = "Aura"
	L.AURA_DESC = "A aura que é posta quando não há nenhuma ligada."
	L.SEC_BLESS = "Prioridade das blessings: %s"
	L.BLESS_DESC = "Da esquerda para a direita: a primeira vai primeiro. Se já estiver na pessoa (de outro paladin) ou ainda não a souberes, vai a segunda, e depois a terceira. Em branco: nada."
	L.MELEE = "Melee"
	L.CASTER = "Casters"
	L.HYBRID = "Híbridos"
	L.MENU_TITLE = "Só nesta party"
	L.MENU_BUTTON = "BlessYou! Menu"
	L.MACRO_DRAG = "Arrasta para uma barra: uma macro que lança o próximo buff (sem pedras nem flasks). Com o rato em cima de um jogador, lança o buff que falta a esse jogador."
	L.MACRO_FULL = "Não há espaço para mais macros de conta. Apaga uma em /macro e tenta outra vez."
	L.VIEW_DEFAULTS = "Por defeito"
	L.SCOPE = "Mostrar lembretes para"
	L.SCOPE_DESC = "De quem são os buffs em falta que o botão e a macro te oferecem."
	L.SCOPE_SELF = "Só para mim"
	L.SCOPE_GROUP = "Para mim e o meu grupo"
	L.SCOPE_ALL = "Todos os que posso buffar"
	L.VIEW_PARTY = "Party"
	L.CLASS_BUFF = "Dar buff"
	L.MANAGER_DESC = "Abre as definições do BlessYou! no SetGo!."
	L.MENU_BUTTON_DESC = "Uma janela pequena com a tua party e o buff que cada um recebe. Clique direito num buff para o mudar, enquanto estiveres nessa party."
	L.GRID_TIP = "Clique direito: mudar, só para esta party"
	L.GRID_SKIP = "Sem buff"
	L.GRID_PRIO = "Prioridade das blessings"
	L.GRID_PRIO_TIP = "Clique: escolhe a blessing deste lugar. Da esquerda para a direita: a primeira vai primeiro; se já estiver na pessoa (de outro paladin) ou ainda não a souberes, vai a seguinte."
	L.EMPTY = "Nada"
	L.AUTO_GRID = "Abrir o menu de buffs automaticamente"
	L.AUTO_GRID_DESC = "Mostra a tua party e o buff que cada um recebe assim que entras numa party."
	L.SETTINGS = "Definições"
	L.MENU_DEFAULT = "Por defeito"
	L.MENU_SKIP = "Não dar buffs"
	L.SEC_THANKS = "Agradecer"
	L.THANKS = "Dizer /thanks"
	L.THANKS_DESC = "Faz /thank a quem te der um buff de 5 minutos ou mais: uma vez a cada 5 minutos por pessoa, só fora de combate, e não pelos buffs que já tinhas ao entrar, fazer reload ou mudar de zona."
	L.THANKS_OFF = "Nunca"
	L.THANKS_OUT = "Fora do teu grupo"
	L.THANKS_ALL = "Toda a gente"
	L.ON_YOU = "Em ti"
	L.ON = "Em %s"
	L.ON_PARTY = "Na party de %s"
	L.ON_CLASS = "Em todos: %s"
	L.BACK = "De volta para %s"
	L.NOTE_ACTIVE = "%s já está activa"
	L.NOTE_UNKNOWN = "%s ainda não aprendida"
	L.TIP_CLICKS = "Clique esquerdo: lançar   Clique direito: dispensar\nCtrl + arrastar: mudar de sítio"
	L.OFF_IN_SETGO = "O BlessYou! está desligado nesta personagem. Liga-o no SetGo!, em Módulos."
	L.DEBUG_ON = "Debug do BlessYou! ligado: quem te dá buffs, e porque é que o botão desaparece, aparecem aqui."
	L.DEBUG_OFF = "Debug do BlessYou! desligado."
	L.DEBUG_BUFFED = "%s deu-te %s (%s, %d min, unidade %s)"
	L.DEBUG_HIDE = "Botão escondido (%s): mostrava %s, %s"
	L.DEBUG_THANK = "Agradecer: %s"
	L.THANK_EMOTE = "agradece a %s."
end

local db -- SetGoBlessDB (account)

--------------------------------------------------------------------------------
-- BlessYou!: one secure button with the next buff to cast. Out of combat
-- it looks at you, your group and whoever buffed you lately, and sets the
-- button to cast the first thing missing; in combat it hides (its
-- attributes can't change then).
-- Right click dismisses what it shows, per buff and per person. The list
-- lives in memory only, so a reload clears it; entering an instance clears
-- it too, and so does that buff being seen fresh on that person (it comes
-- back when it wears off). A cast refused because something stronger is
-- already there (camp benefits) dismisses it by itself.
-- Who buffed you comes from the combat log when Forever lets addons read
-- it, else from the aura's caster (only known while a unit token points at
-- them: target, mouseover, nameplate, group). Someone outside the group is
-- buffed back with a macro (/targetexact), since there is no unit for them.
--------------------------------------------------------------------------------

local KEY = "bless"
local function CoreKnows()
	for _, m in ipairs(SetGo.KNOWN_MODULES or {}) do
		if m.key == KEY then
			return true
		end
	end
	return false
end
-- until SetGo! lists the module, it's on
local ON = SetGo.ModuleOn(KEY) or not CoreKnows()

local SECRET = type(issecretvalue) == "function" and issecretvalue or nil
local SECRET_TABLE = type(issecrettable) == "function" and issecrettable or nil
local CAN_ACCESS = type(canaccesstable) == "function" and canaccesstable or nil
local function Clean(v)
	if v == nil or (SECRET and SECRET(v)) then
		return nil
	end
	if type(v) == "table" and ((SECRET_TABLE and SECRET_TABLE(v)) or (CAN_ACCESS and not CAN_ACCESS(v))) then
		return nil
	end
	return v
end

-- known spells and bag counts only change when you learn, level or move
-- items, so they're kept until then (SPELLS_CHANGED, BAG_UPDATE_DELAYED)
local knownCache, itemCache = {}, {}

local function Known(id)
	local k = knownCache[id]
	if k ~= nil then
		return k
	end
	k = false
	if C_SpellBook and C_SpellBook.IsSpellKnown then
		local ok, known = pcall(C_SpellBook.IsSpellKnown, id)
		k = ok and known and true or false
	end
	if not k and IsPlayerSpell then
		k = IsPlayerSpell(id) and true or false
	end
	knownCache[id] = k
	return k
end

local function ItemCount(id)
	if not id then
		return 1
	end
	local n = itemCache[id]
	if n then
		return n
	end
	local f = (C_Item and C_Item.GetItemCount) or GetItemCount
	n = tonumber(f and f(id)) or 0
	itemCache[id] = n
	return n
end

-- the next moment something is worth a look again (a buff reaching its
-- reminder, someone coming back in range); worked out by each look
local wake = 0
local function Soon(t)
	if t < wake then
		wake = t
	end
end

local function SpellName(id)
	if C_Spell and C_Spell.GetSpellName then
		return C_Spell.GetSpellName(id)
	end
	return GetSpellInfo and (GetSpellInfo(id))
end

local function SpellIcon(id)
	if C_Spell and C_Spell.GetSpellTexture then
		return C_Spell.GetSpellTexture(id)
	end
	return 134400
end

-- "Name(Rank 3)", for macros
local function SpellWithRank(id)
	local name = SpellName(id)
	local sub = C_Spell and C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(id)
	if name and type(sub) == "string" and sub ~= "" then
		return name .. "(" .. sub .. ")"
	end
	return name
end

-- the best known rank for a target of this level (no level: the best)
local function BestRank(list, level)
	if not list then
		return nil
	end
	level = tonumber(level) or 0
	for i = #list, 1, -1 do
		local r = list[i]
		if Known(r[1]) and (level <= 0 or r[2] - 10 <= level) then
			return r
		end
	end
end

--------------------------------------------------------------------------------
-- Auras
--------------------------------------------------------------------------------

-- [spellId] = { exp, dur, mine }. When the game hides them (secret, as in
-- some instances and right around combat) the list is marked secret:
-- nothing is suggested for that unit, and it's read again in a moment
local function Auras(unit)
	local out = {}
	if not (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then
		return out
	end
	for i = 1, 80 do
		local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, "HELPFUL")
		if not ok or (a ~= nil and Clean(a) == nil) then
			out.__secret = true
			return out
		end
		if not a then
			break
		end
		local id = Clean(a.spellId)
		if id then
			local src = Clean(a.sourceUnit)
			out[id] = {
				exp = tonumber(Clean(a.expirationTime)) or 0,
				dur = tonumber(Clean(a.duration)) or 0,
				mine = src and Clean(UnitIsUnit(src, "player")) and true or false,
			}
		end
	end
	return out
end

-- each group member's buffs, read once and kept until UNIT_AURA says they
-- changed (by guid, so the roster can reshuffle)
local auraCache = {}
local function CachedAuras(unit, guid)
	if not guid then
		return Auras(unit)
	end
	local a = auraCache[guid]
	if not a then
		a = Auras(unit)
		if a.__secret then
			-- not kept: read again soon
			Soon(GetTime() + 5)
		else
			auraCache[guid] = a
		end
	end
	return a
end

-- the longest of these ids on the unit: seconds left (huge: no end), aura
local function Has(auras, ids)
	local best, bestAura
	local now = GetTime()
	for id in pairs(ids) do
		local a = auras[id]
		if a then
			local left = a.exp > 0 and (a.exp - now) or math.huge
			if not best or left > best then
				best, bestAura = left, a
			end
		end
	end
	return best, bestAura
end

-- when to remind, in seconds left: the page's slider, else 10% of the buff
local function Remind(key, duration)
	local m = key and db.remind and tonumber(db.remind[key])
	if m then
		return m * 60
	end
	return D.Threshold(duration)
end

-- missing, or about to run out
local function Needs(auras, ids, key)
	if auras.__secret then
		return false
	end
	local left, a = Has(auras, ids)
	if not left then
		return true
	end
	local remind = Remind(key, a.dur)
	if left < remind then
		return true
	end
	if left ~= math.huge then
		Soon(GetTime() + left - remind)
	end
	return false
end

--------------------------------------------------------------------------------
-- Who's around
--------------------------------------------------------------------------------

local function Roster()
	local list = {}
	local seen = {}
	local function Add(unit, sub)
		if not UnitExists(unit) then
			return
		end
		local guid = Clean(UnitGUID(unit))
		if not guid or seen[guid] then
			return
		end
		seen[guid] = true
		local _, class = UnitClass(unit)
		list[#list + 1] = {
			unit = unit, guid = guid, name = Clean(UnitName(unit)), class = Clean(class),
			level = tonumber(Clean(UnitLevel(unit))) or 0, sub = sub or 1,
			isPlayer = UnitIsUnit(unit, "player") and true or false,
		}
	end
	Add("player", 1)
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local _, _, sub = GetRaidRosterInfo(i)
			local unit = "raid" .. i
			if UnitIsUnit(unit, "player") then
				list[1].sub = sub or 1
			else
				Add(unit, sub)
			end
		end
	elseif IsInGroup() then
		for i = 1, 4 do
			Add("party" .. i, 1)
		end
	end
	return list
end

local function InGroup(guid)
	if IsGUIDInGroup then
		local ok, r = pcall(IsGUIDInGroup, guid)
		if ok then
			return Clean(r) and true or false
		end
	end
	for _, m in ipairs(Roster()) do
		if m.guid == guid then
			return true
		end
	end
	return false
end

local function Reachable(unit, spellId)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) or not UnitCanAssist("player", unit) then
		return false
	end
	if not UnitIsVisible(unit) then
		Soon(GetTime() + 5)
		return false
	end
	if UnitIsUnit(unit, "player") then
		return true
	end
	if C_Spell and C_Spell.IsSpellInRange then
		local r = Clean(C_Spell.IsSpellInRange(spellId, unit))
		if r == false or r == 0 then
			-- range has no event: look again in a moment
			Soon(GetTime() + 2)
			return false
		end
	end
	return true
end

--------------------------------------------------------------------------------
-- What to cast
--------------------------------------------------------------------------------

local dismissed = {} -- ["guid:BUFF"] = true, memory only
local strangers = {} -- [guid] = { t, name, full, class }, who buffed you from outside the group
local thanked = {} -- [guid] = time

local function DKey(guid, key)
	return guid .. ":" .. key
end

local function MyBuffs()
	local _, class = UnitClass("player")
	return D.BUFFS[class] or {}
end

-- "NEVER", "GROUP" or "ALWAYS" (the old on/off ticks carry over)
local function Mode(buff)
	local m = db.mode and db.mode[buff.key]
	if m == nil and db.buffs and db.buffs[buff.key] ~= nil then
		m = db.buffs[buff.key] and "ALWAYS" or "NEVER"
	end
	return m or buff.default or (buff.off and "NEVER" or "ALWAYS")
end

local function BuffOn(buff)
	local m = Mode(buff)
	return m == "ALWAYS" or (m == "GROUP" and IsInGroup())
end

local overrides = {} -- [guid] = blessing key or "SKIP", for this party only

-- the kind of class's three choices, "NONE" for an empty one
-- a class's three choices, "NONE" for an empty one. Set per class in the
-- menu's defaults; until then its kind of class's (melee, caster, hybrid)
local function ClassChoices(class)
	local saved = db.classPrio and db.classPrio[class]
	local group = D.BLESS_GROUP[class] or "HYBRID"
	local old = db.blessPrio and db.blessPrio[group]
	local default = D.BLESS_DEFAULT[group]
	local list = {}
	for i = 1, 3 do
		list[i] = saved and saved[i] or old and old[i] or default[i]
	end
	return list
end

-- the blessings for this player, first to last
local function BlessingOrder(class, guid)
	local list, seen = {}, {}
	local function Add(k)
		if k and D.BLESSINGS[k] and not seen[k] then
			seen[k] = true
			list[#list + 1] = k
		end
	end
	Add(guid and overrides[guid])
	for _, k in ipairs(ClassChoices(class)) do
		Add(k)
	end
	return list
end

-- the blessing this unit should get from you, or nil (yours is on and
-- fresh, or every one is taken)
local function BlessingFor(auras, class, level, guid)
	if auras and auras.__secret then
		return nil
	end
	local now = GetTime()
	for key, b in pairs(D.BLESSINGS) do
		for id in pairs(D.AllIds(b)) do
			local a = auras and auras[id]
			if a and a.mine then
				local left = a.exp > 0 and (a.exp - now) or math.huge
				local remind = Remind("BLESSING", a.dur)
				if left < remind then
					return key
				end
				if left ~= math.huge then
					Soon(now + left - remind)
				end
				return nil
			end
		end
	end
	-- the first one free; when it isn't the first choice, why
	local order = BlessingOrder(class, guid)
	for i, key in ipairs(order) do
		local b = D.BLESSINGS[key]
		if b and BestRank(b.ranks, level) and not (auras and Has(auras, D.AllIds(b))) then
			local note
			if i > 1 then
				local first = D.BLESSINGS[order[1]]
				local name = SpellName(first.ranks[1][1]) or order[1]
				if auras and Has(auras, D.AllIds(first)) then
					note = L.NOTE_ACTIVE:format(name)
				elseif not BestRank(first.ranks, level) then
					note = L.NOTE_UNKNOWN:format(name)
				end
			end
			return key, note
		end
	end
end

local function Allowed(m)
	if not m.isPlayer and db.scope == "SELF" then
		return false
	end
	if overrides[m.guid] == "SKIP" or (m.class and db.classSkip and db.classSkip[m.class]) then
		return false
	end
	if m.isPlayer then
		return db.self ~= false
	end
	return db.group ~= false
end

-- order: 1 you, 2 your group, 3 a buff back
local function Push(out, order, c)
	c.order = order
	c.n = #out + 1
	out[#out + 1] = c
end

-- one cast for many (group version, greater blessing) or one each
local function Cast(out, list, single, multi, min, key, note)
	if multi and #list >= min and ItemCount(multi[3]) > 0 then
		local keys, order = {}, 2
		for _, m in ipairs(list) do
			keys[#keys + 1] = DKey(m.guid, key)
			if m.isPlayer then
				order = 1
			end
		end
		for _, m in ipairs(list) do
			if Reachable(m.unit, multi[1]) then
				Push(out, order, { unit = m.unit, name = m.name, spell = multi[1], keys = keys, multi = true, isPlayer = m.isPlayer,
					greater = key == "BLESSING", class = m.class, note = note })
				return
			end
		end
	end
	for _, m in ipairs(list) do
		local r = BestRank(single, m.level)
		if r and Reachable(m.unit, r[1]) then
			Push(out, m.isPlayer and 1 or 2, { unit = m.unit, name = m.name, spell = r[1], keys = { DKey(m.guid, key) }, isPlayer = m.isPlayer, note = note })
		end
	end
end

local function GroupBuff(out, roster, buff)
	local ids = D.AllIds(buff)
	local need = {}
	for _, m in ipairs(roster) do
		local k = DKey(m.guid, buff.key)
		if m.auras.__secret then
			-- hidden for now: left alone
			k = nil
		elseif not Needs(m.auras, ids, buff.key) then
			dismissed[k] = nil
		elseif not dismissed[k] and Allowed(m) and not (buff.skip and m.class and buff.skip[m.class]) then
			need[m.sub] = need[m.sub] or {}
			table.insert(need[m.sub], m)
		end
	end
	local group = BestRank(buff.group)
	for _, list in pairs(need) do
		Cast(out, list, buff.ranks, group, D.GROUP_MIN, buff.key)
	end
end

local function Blessings(out, roster)
	local byClass = {}
	for _, m in ipairs(roster) do
		local k = DKey(m.guid, "BLESSING")
		if m.class and Allowed(m) and not m.auras.__secret then
			local key, note = BlessingFor(m.auras, m.class, m.level, m.guid)
			if not key then
				dismissed[k] = nil
			elseif not dismissed[k] then
				local id = m.class .. ":" .. key
				byClass[id] = byClass[id] or { key = key, list = {}, note = note }
				table.insert(byClass[id].list, m)
			end
		end
	end
	for _, e in pairs(byClass) do
		local b = D.BLESSINGS[e.key]
		Cast(out, e.list, b.ranks, BestRank(b.greater), D.GREATER_MIN, "BLESSING", e.note)
	end
end

-- your target, when it's a player outside your group: the buff the addon
-- picks for them (their class's blessing, or your buff they're missing).
-- Targeting someone says you mean to buff them, so it goes first
-- (anyone: group members too, for the mouseover)
local function TargetBuff(buffs, u, anyone)
	u = u or "target"
	-- "Just me": nobody else; "Me and my group": only group members
	local scope = db.scope or "ALL"
	if scope == "SELF" or (scope == "GROUP" and not (UnitInParty(u) or UnitInRaid(u))) then
		return nil
	end
	if not UnitExists(u) or not UnitIsPlayer(u) or UnitIsUnit(u, "player") or not UnitCanAssist("player", u)
		or UnitIsDeadOrGhost(u) or (not anyone and (UnitInParty(u) or UnitInRaid(u))) then
		return nil
	end
	local guid = Clean(UnitGUID(u))
	local _, class = UnitClass(u)
	class = Clean(class)
	if not guid or overrides[guid] == "SKIP" or (class and db.classSkip and db.classSkip[class]) then
		return nil
	end
	local level = tonumber(Clean(UnitLevel(u)))
	local auras = Auras(u)
	for _, buff in ipairs(buffs) do
		if BuffOn(buff) and not buff.self and not buff.stance then
			local key = buff.blessing and "BLESSING" or buff.key
			local k = DKey(guid, key)
			local spell, note
			if dismissed[k] then
				spell = nil
			elseif buff.blessing then
				local bkey
				if class then
					bkey, note = BlessingFor(auras, class, level, guid)
				end
				local r = bkey and BestRank(D.BLESSINGS[bkey].ranks)
				spell = r and r[1]
			elseif not (buff.skip and class and buff.skip[class]) and Needs(auras, D.AllIds(buff), buff.key) then
				local r = BestRank(buff.ranks)
				spell = r and r[1]
			end
			if spell and Reachable(u, spell) then
				return { unit = u, name = Clean(UnitName(u)), spell = spell, keys = { k }, note = note }
			end
		end
	end
end

-- the last aura you switched on, else devotion, else the first one known
local function AuraRank()
	local want = db.lastAura or "DEVOTION"
	for _, a in ipairs(D.PALADIN_AURAS) do
		if a.key == want then
			local r = BestRank(a.ranks)
			if r then
				return r
			end
		end
	end
	for _, a in ipairs(D.PALADIN_AURAS) do
		local r = BestRank(a.ranks)
		if r then
			return r
		end
	end
end

local function ItemName(id)
	return C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id) or ("item:" .. id)
end

local function ItemIcon(id)
	return C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(id) or 134400
end

-- the oil or stone on a hand (Enum.WeaponSlot): enchant, or nil; secret: true
local function TempEnchant(weaponSlot)
	local list = C_Item.GetWeaponEnchantInfo(weaponSlot)
	if list ~= nil and Clean(list) == nil then
		return nil, true
	end
	if type(list) ~= "table" then
		return nil
	end
	local wanted = Enum.ItemEnchantType and Enum.ItemEnchantType.Temporary or 2
	for _, e in ipairs(list) do
		local has, kind = Clean(e.hasEnchant), Clean(e.enchantType)
		if has == nil or kind == nil then
			return nil, true
		end
		if has and kind == wanted then
			return e
		end
	end
end

local function Stones(out, me, buff)
	if not (C_Item and C_Item.GetWeaponEnchantInfo and C_Item.GetItemInfoInstant) then
		return
	end
	local hands = {
		{ slot = 16, weapon = Enum.WeaponSlot and Enum.WeaponSlot.MainHand or 0, where = L.MAIN_HAND },
		{ slot = 17, weapon = Enum.WeaponSlot and Enum.WeaponSlot.OffHand or 1, where = L.OFF_HAND },
	}
	for _, hand in ipairs(hands) do
		local itemId = GetInventoryItemID("player", hand.slot)
		local classId, subId
		if itemId then
			classId, subId = select(6, C_Item.GetItemInfoInstant(itemId))
		end
		local kind = classId == 2 and D.WEAPON_KIND[subId]
		local k = DKey(me.guid, buff.key .. hand.slot)
		if kind then
			local e, secret = TempEnchant(hand.weapon)
			local left = e and (tonumber(Clean(e.timeLeft)) or 0) / 1000
			local remind = Remind(buff.key, D.STONE_DURATION)
			if not secret and e and left >= remind then
				dismissed[k] = nil
				Soon(GetTime() + left - remind)
			elseif not secret and not dismissed[k] then
				for _, stone in ipairs(D.STONES[kind]) do
					if ItemCount(stone) > 0 then
						Push(out, 1, { item = stone, keys = { k }, isPlayer = true, where = hand.where,
							macro = "/use item:" .. stone .. "\n/use " .. hand.slot })
						break
					end
				end
			end
		end
	end
end

local function Flask(out, me, buff)
	local k = DKey(me.guid, buff.key)
	local now = GetTime()
	local on
	if me.auras.__secret then
		return
	end
	for _, f in ipairs(D.FLASKS) do
		local a = me.auras[f[2]]
		if a then
			on = f
			local left = a.exp > 0 and (a.exp - now) or math.huge
			local remind = Remind(buff.key, D.FLASK_DURATION)
			if left >= remind then
				dismissed[k] = nil
				if left ~= math.huge then
					Soon(now + left - remind)
				end
				return
			end
		end
	end
	if dismissed[k] then
		return
	end
	-- the one running out first, else the first in the bags
	local pick = on and ItemCount(on[1]) > 0 and on[1]
	if not pick then
		for _, f in ipairs(D.FLASKS) do
			if ItemCount(f[1]) > 0 then
				pick = f[1]
				break
			end
		end
	end
	if pick then
		Push(out, 1, { item = pick, keys = { k }, isPlayer = true, macro = "/use item:" .. pick })
	end
end

local function Candidates()
	local out = {}
	wake = GetTime() + 60
	local buffs = MyBuffs()
	local roster = Roster()
	for _, m in ipairs(roster) do
		m.auras = CachedAuras(m.unit, m.guid)
	end
	local me = roster[1]
	-- you can't be read yet (loading in, or hidden by the game): later
	if not me or not me.isPlayer then
		Soon(GetTime() + 2)
		return out
	end
	for _, buff in ipairs(buffs) do
		if BuffOn(buff) then
			if buff.stance then
				local k = DKey(me.guid, buff.key)
				local form = tonumber(Clean(GetShapeshiftForm())) or -1
				if form > 0 then
					dismissed[k] = nil
				elseif form == 0 and db.self ~= false and not dismissed[k] then
					local r = AuraRank()
					if r then
						Push(out, 1, { unit = "player", name = me.name, spell = r[1], keys = { k }, isPlayer = true })
					end
				end
			elseif buff.blessing then
				Blessings(out, roster)
			elseif buff.self then
				local k = DKey(me.guid, buff.key)
				if me.auras.__secret then
					k = nil
				elseif not Needs(me.auras, D.AllIds(buff), buff.key) then
					dismissed[k] = nil
				elseif db.self ~= false and not dismissed[k] then
					local r = BestRank(buff.ranks)
					if r then
						Push(out, 1, { unit = "player", name = me.name, spell = r[1], keys = { k }, isPlayer = true })
					end
				end
			else
				GroupBuff(out, roster, buff)
			end
		end
	end
	-- stones and flasks: on you, out of combat
	if db.self ~= false then
		for _, buff in ipairs(D.CONSUMABLES) do
			if BuffOn(buff) then
				if buff.stone then
					Stones(out, me, buff)
				elseif buff.flask then
					Flask(out, me, buff)
				end
			end
		end
	end
	local t = TargetBuff(buffs)
	if t then
		Push(out, 0, t)
	end
	table.sort(out, function(a, b)
		if a.order ~= b.order then
			return a.order < b.order
		end
		return a.n < b.n
	end)
	return out
end

--------------------------------------------------------------------------------
-- The button
--------------------------------------------------------------------------------

local ATLAS = "LootToast-LessAwesome"
local btn, icon, box, title, target, note, count, pad
local current, lastClick
local dirty, since = true, 0

local function Request()
	dirty = true
end

local function KeyDown()
	return C_CVar and C_CVar.GetCVarBool and C_CVar.GetCVarBool("ActionButtonUseKeyDown") or false
end

-- the "BlessYou!" macro: clicks the button, so it can live on any bar and
-- use the bar's key; its icon follows what the button shows
local MACRO = "BlessYou!"
local MACRO_ICON = "INV_MISC_QUESTIONMARK"

-- what the macro does: the same cast as the button, written out
local function MacroCast(c)
	if not c then
		return ""
	end
	if c.macro then
		return c.macro
	end
	-- the plain name (best rank): "Name(Rank n)" isn't sure to work on
	-- Forever's macros
	return "/cast [@" .. (c.unit or "player") .. "] " .. (SpellName(c.spell) or "")
end

local lastBody, macroCand, macroError, mouseCand
local function SetMacro(c)
	if InCombatLockdown() or not GetMacroIndexByName then
		return
	end
	local idx = GetMacroIndexByName(MACRO) or 0
	if idx == 0 then
		return
	end
	local body = "#showtooltip\n" .. MacroCast(c)
	if body ~= lastBody then
		-- name and icon left as they are; remembered only once it worked
		local _, icon = GetMacroInfo(idx)
		local ok, err = pcall(EditMacro, idx, MACRO, icon or MACRO_ICON, body)
		if ok then
			lastBody, macroError = body, nil
		else
			macroError = tostring(err)
		end
	end
end

-- /blessyou macro: what the macro holds, what it should hold, and why not
local function MacroReport()
	local idx = GetMacroIndexByName and GetMacroIndexByName(MACRO) or 0
	if idx == 0 then
		SetGo.Print("BlessYou! macro: not found (drag it from the BlessYou! page first).")
		return
	end
	local body = GetMacroBody and GetMacroBody(idx) or "?"
	SetGo.Print(("BlessYou! macro #%d holds: %s"):format(idx, (body or ""):gsub("\n", " | ")))
	SetGo.Print("Should hold: " .. ("#showtooltip\n" .. MacroCast(macroCand)):gsub("\n", " | "))
	SetGo.Print("Last error: " .. (macroError or "none"))
	local shown = "nothing (button hidden)"
	if current then
		shown = (current.item and ("item " .. ItemName(current.item)) or (SpellName(current.spell) or "?"))
			.. " / " .. (current.where or current.name or "you") .. (btn and btn:IsShown() and "" or " (button hidden)")
	end
	SetGo.Print("Button shows: " .. shown)
end

local function EnsureMacro()
	if InCombatLockdown() or not GetMacroIndexByName then
		return nil
	end
	local idx = GetMacroIndexByName(MACRO) or 0
	if idx == 0 then
		local ok, r = pcall(CreateMacro, MACRO, MACRO_ICON, "#showtooltip\n" .. MacroCast(macroCand), false)
		idx = ok and tonumber(r) or 0
		if idx == 0 then
			SetGo.Print(L.MACRO_FULL)
		end
		lastBody = nil
	end
	SetMacro(mouseCand or macroCand)
	return idx > 0 and idx or nil
end

local function TargetText(c)
	if c.where then
		return c.where
	end
	if c.item then
		return L.ON_YOU
	end
	if c.stranger then
		return L.BACK:format(c.name or "?")
	end
	if c.multi then
		if c.greater then
			local class = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[c.class] or c.class
			return L.ON_CLASS:format(class or "?")
		end
		return L.ON_PARTY:format(c.name or "?")
	end
	if c.isPlayer then
		return L.ON_YOU
	end
	return L.ON:format(c.name or "?")
end

local function Show(c, total)
	if InCombatLockdown() then
		return
	end
	current = c
	if not c then
		btn:SetAttribute("type1", nil)
		btn:Hide()
		SetMacro(nil)
		return
	end
	if c.macro then
		btn:SetAttribute("type1", "macro")
		btn:SetAttribute("macrotext1", c.macro)
		btn:SetAttribute("spell1", nil)
		btn:SetAttribute("unit1", nil)
	else
		btn:SetAttribute("type1", "spell")
		btn:SetAttribute("spell1", c.spell)
		btn:SetAttribute("unit1", c.unit)
		btn:SetAttribute("macrotext1", nil)
	end
	if c.item then
		icon:SetTexture(ItemIcon(c.item))
		title:SetText(ItemName(c.item))
	else
		icon:SetTexture(SpellIcon(c.spell))
		title:SetText(SpellName(c.spell) or "")
	end
	target:SetText(TargetText(c))
	note:SetText(c.note or "")
	-- two lines in the middle of the box, three with a note
	local hasNote = c.note ~= nil
	title:ClearAllPoints()
	target:ClearAllPoints()
	note:ClearAllPoints()
	if hasNote then
		title:SetPoint("TOPLEFT", box, "TOPLEFT", pad, -2)
		target:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -1)
		note:SetPoint("TOPLEFT", target, "BOTTOMLEFT", 0, -1)
	else
		title:SetPoint("BOTTOMLEFT", box, "LEFT", pad, 1)
		target:SetPoint("TOPLEFT", box, "LEFT", pad, -1)
	end
	note:SetShown(hasNote)
	count:SetText(total and total > 1 and ("+" .. (total - 1)) or "")
	btn:Show()
	if GameTooltip:IsOwned(btn) then
		btn:GetScript("OnEnter")(btn)
	end
end

-- /blessyou debug: a line each time the button goes away, and why
local function Hidden(why)
	if db.debug and current then
		SetGo.Print(L.DEBUG_HIDE:format(why, current.item and ItemName(current.item) or SpellName(current.spell) or "?",
			TargetText(current)))
	end
end

local RefreshGrid, OpenSettings

local function Update()
	if InCombatLockdown() then
		return
	end
	if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
		Hidden(UnitOnTaxi("player") and "taxi" or "dead")
		Show(nil)
		return
	end
	local list = Candidates()
	if not list[1] then
		Hidden("nothing left")
	end
	Show(list[1], #list)
	-- the macro: buffs only, no stones or flasks
	macroCand = nil
	for _, c in ipairs(list) do
		if not c.item then
			macroCand = c
			break
		end
	end
	SetMacro(mouseCand or macroCand)
	RefreshGrid()
end

local function Dismiss()
	if not current then
		return
	end
	for _, k in ipairs(current.keys) do
		dismissed[k] = true
	end
	Update()
end

-- the party's members, for the right click menu
local function PartyMembers()
	local list = {}
	for i = 1, 4 do
		local unit = "party" .. i
		if UnitExists(unit) then
			local guid = Clean(UnitGUID(unit))
			local _, class = UnitClass(unit)
			if guid then
				list[#list + 1] = { guid = guid, name = Clean(UnitName(unit)) or "?", class = Clean(class) }
			end
		end
	end
	return list
end

-- right click: what each party member gets, until they or you leave
-- one member's choices (radios) under a menu entry
local function MemberChoices(sub, m)
	local _, myClass = UnitClass("player")
	local function Is(v)
		return function()
			return overrides[m.guid] == v
		end
	end
	local function Set(v)
		return function()
			overrides[m.guid] = v
			Request()
		end
	end
	sub:CreateRadio(L.MENU_DEFAULT, Is(nil), Set(nil))
	if myClass == "PALADIN" then
		for _, key in ipairs(D.BLESSING_ORDER) do
			sub:CreateRadio(SpellName(D.BLESSINGS[key].ranks[1][1]) or key, Is(key), Set(key))
		end
	end
	sub:CreateRadio(L.MENU_SKIP, Is("SKIP"), Set("SKIP"))
end

local function ClassColored(m)
	local color = RAID_CLASS_COLORS and m.class and RAID_CLASS_COLORS[m.class]
	return color and color.WrapTextInColorCode and color:WrapTextInColorCode(m.name) or m.name
end

local function OpenMenu(owner)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	local members = PartyMembers()
	if #members == 0 then
		return
	end
	MenuUtil.CreateContextMenu(owner or btn, function(_, root)
		root:CreateTitle(L.MENU_TITLE)
		for _, m in ipairs(members) do
			MemberChoices(root:CreateButton(ClassColored(m)), m)
		end
	end)
end

--------------------------------------------------------------------------------
-- The party's buffs: a small window, one row per member (you first): class
-- icon, name, and the buff they get. Right click the buff to change it for
-- as long as you're in that party.
--------------------------------------------------------------------------------

local grid

-- the blessing this member is down for: the party's choice, else the first
-- not taken by another paladin (yours counts as theirs)
local function AssignedBlessing(m)
	local o = overrides[m.guid]
	if o and o ~= "SKIP" then
		return o
	end
	local auras = CachedAuras(m.unit, m.guid)
	for _, key in ipairs(BlessingOrder(m.class, m.guid)) do
		local b = D.BLESSINGS[key]
		local ids = D.AllIds(b)
		local taken, mine = false, false
		for id in pairs(ids) do
			local a = auras[id]
			if a then
				if a.mine then
					mine = true
				else
					taken = true
				end
			end
		end
		if mine then
			return key
		end
		if not taken and BestRank(b.ranks, m.level) then
			return key
		end
	end
end

-- what the member's buff icon shows: spell id, or nil for none
local function AssignedSpell(m)
	if overrides[m.guid] == "SKIP" or (m.class and db.classSkip and db.classSkip[m.class]) then
		return nil
	end
	for _, buff in ipairs(MyBuffs()) do
		if not buff.self and not buff.stance and BuffOn(buff) then
			if buff.blessing then
				local key = m.class and AssignedBlessing(m)
				if key then
					return D.BLESSINGS[key].ranks[1][1]
				end
			elseif not (buff.skip and m.class and buff.skip[m.class]) then
				return buff.ranks[1][1]
			end
		end
	end
end

local function GridMembers()
	local list = {}
	local function Add(unit)
		local guid = Clean(UnitGUID(unit))
		local _, class = UnitClass(unit)
		if guid then
			list[#list + 1] = { unit = unit, guid = guid, name = Clean(UnitName(unit)) or "?", class = Clean(class),
				level = tonumber(Clean(UnitLevel(unit))) or 0 }
		end
	end
	Add("player")
	for i = 1, 4 do
		if UnitExists("party" .. i) then
			Add("party" .. i)
		end
	end
	return list
end

local ROW = 26
local SLOT = 22
local _, MY_CLASS = UnitClass("player")

-- every class, melee then casters then hybrids, for the defaults
local ALL_CLASSES = {}
for _, group in ipairs(D.BLESS_GROUPS) do
	for _, class in ipairs(D.BLESS_GROUP_CLASSES[group]) do
		ALL_CLASSES[#ALL_CLASSES + 1] = class
	end
end

local function ClassName(class)
	local name = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[class] or class
	local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
	return color and color.WrapTextInColorCode and color:WrapTextInColorCode(name) or name
end

-- a non paladin's buff for a class by default (nil: switched off for it)
local function ClassSpell(class)
	if db.classSkip and db.classSkip[class] then
		return nil
	end
	for _, buff in ipairs(MyBuffs()) do
		if not buff.self and not buff.stance and not buff.blessing and BuffOn(buff)
			and not (buff.skip and buff.skip[class]) then
			return buff.ranks[1][1]
		end
	end
end

-- a click on a slot: the choices for what it stands for
local function SlotMenu(slot)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	MenuUtil.CreateContextMenu(slot, function(_, root)
		if slot.kind == "member" then
			root:CreateTitle(ClassColored(slot.member))
			MemberChoices(root, slot.member)
		elseif slot.kind == "prio" then
			local class, i = slot.class, slot.i
			root:CreateTitle(ClassName(class) .. " " .. i)
			local function Pick(v)
				db.classPrio = db.classPrio or {}
				db.classPrio[class] = ClassChoices(class)
				db.classPrio[class][i] = v
				Request()
				RefreshGrid()
			end
			root:CreateRadio(L.EMPTY, function()
				return ClassChoices(class)[i] == "NONE"
			end, function()
				Pick("NONE")
			end)
			for _, key in ipairs(D.BLESSING_ORDER) do
				root:CreateRadio(SpellName(D.BLESSINGS[key].ranks[1][1]) or key, function()
					return ClassChoices(class)[i] == key
				end, function()
					Pick(key)
				end)
			end
		else
			local class = slot.class
			root:CreateTitle(ClassName(class))
			local function Set(skip)
				db.classSkip = db.classSkip or {}
				db.classSkip[class] = skip or nil
				Request()
				RefreshGrid()
			end
			root:CreateRadio(L.CLASS_BUFF, function()
				return not (db.classSkip and db.classSkip[class])
			end, function()
				Set(false)
			end)
			root:CreateRadio(L.MENU_SKIP, function()
				return db.classSkip and db.classSkip[class] and true or false
			end, function()
				Set(true)
			end)
		end
	end)
end

local function Slot(parent)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(SLOT, SLOT)
	b.tex = b:CreateTexture(nil, "ARTWORK")
	b.tex:SetAllPoints()
	local hl = b:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints()
	hl:SetColorTexture(1, 1, 1, 0.2)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	b:SetScript("OnClick", SlotMenu)
	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.spell then
			GameTooltip:SetSpellByID(self.spell)
		else
			GameTooltip:SetText(self.kind == "prio" and L.EMPTY or L.GRID_SKIP, 1, 1, 1)
		end
		GameTooltip:AddLine(self.kind == "prio" and L.GRID_PRIO_TIP or L.GRID_TIP, 0.6, 0.6, 0.6, true)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return b
end

-- a row: class icon, name, and up to three slots on the right
local function GridRow(i)
	local row = grid.rows[i]
	if row then
		return row
	end
	row = CreateFrame("Frame", nil, grid.content)
	row:SetSize(grid.content:GetWidth(), ROW)
	row:SetPoint("TOPLEFT", grid.content, "TOPLEFT", 0, -(i - 1) * ROW)
	row.class = row:CreateTexture(nil, "ARTWORK")
	row.class:SetSize(18, 18)
	row.class:SetPoint("LEFT", row, "LEFT", 2, 0)
	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	row.name:SetPoint("LEFT", row.class, "RIGHT", 6, 0)
	row.name:SetPoint("RIGHT", row, "RIGHT", -(3 * (SLOT + 4) + 2), 0)
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)
	row.slots = {}
	for j = 1, 3 do
		local b = Slot(row)
		b:SetPoint("RIGHT", row, "RIGHT", -2 - (3 - j) * (SLOT + 4), 0)
		row.slots[j] = b
	end
	grid.rows[i] = row
	return row
end

local function SetSlot(b, kind, spell, empty)
	b.kind, b.spell = kind, spell
	if spell then
		b.tex:SetTexture(SpellIcon(spell))
		b.tex:SetAlpha(1)
	elseif empty then
		b.tex:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
		b.tex:SetAlpha(0.8)
	else
		b.tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		b.tex:SetAlpha(1)
	end
	b:Show()
end

local function SetClassIcon(row, class)
	local coords = CLASS_ICON_TCOORDS and class and CLASS_ICON_TCOORDS[class]
	if coords then
		row.class:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
		row.class:SetTexCoord(unpack(coords))
	else
		row.class:SetTexture(nil)
	end
end

-- in a party: its members and what each gets (or the defaults, with the
-- button); alone: every class and its defaults
function RefreshGrid()
	if not (grid and grid:IsShown()) then
		return
	end
	local inGroup = IsInGroup()
	if not inGroup then
		grid.view = "defaults"
	end
	local n = 0
	if grid.view == "party" then
		for _, m in ipairs(GridMembers()) do
			n = n + 1
			local row = GridRow(n)
			SetClassIcon(row, m.class)
			row.name:SetText(ClassColored(m))
			row.slots[1]:Hide()
			row.slots[2]:Hide()
			SetSlot(row.slots[3], "member", AssignedSpell(m))
			row.slots[3].member = m
			row:Show()
		end
	else
		for _, class in ipairs(ALL_CLASSES) do
			n = n + 1
			local row = GridRow(n)
			SetClassIcon(row, class)
			row.name:SetText(ClassName(class))
			if MY_CLASS == "PALADIN" then
				local choices = ClassChoices(class)
				for j = 1, 3 do
					local b = D.BLESSINGS[choices[j]]
					SetSlot(row.slots[j], "prio", b and b.ranks[1][1], true)
					row.slots[j].class, row.slots[j].i = class, j
				end
			else
				row.slots[1]:Hide()
				row.slots[2]:Hide()
				SetSlot(row.slots[3], "class", ClassSpell(class))
				row.slots[3].class = class
			end
			row:Show()
		end
	end
	for i = n + 1, #grid.rows do
		grid.rows[i]:Hide()
	end
	local h = n * ROW
	-- the two views: the one showing is greyed; Party only in a party
	grid.partyBtn:SetEnabled(inGroup and grid.view ~= "party")
	grid.defaultsBtn:SetEnabled(grid.view ~= "defaults")
	grid:SetHeight(grid.top + h + grid.bottom)
end

-- the window: Blizzard's frame, as SetGo!'s own window
local function EnsureGrid()
	if grid then
		return grid
	end
	local ok, f = pcall(CreateFrame, "Frame", "SetGoBlessParty", UIParent, "ButtonFrameTemplate")
	if not ok or not f then
		f = CreateFrame("Frame", "SetGoBlessParty", UIParent, "BackdropTemplate")
		if f.SetBackdrop then
			f:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				edgeSize = 14, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
			f:SetBackdropColor(0, 0, 0, 0.85)
		end
		local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 2, 2)
	end
	grid = f
	if ButtonFrameTemplate_HidePortrait and grid.PortraitContainer then
		ButtonFrameTemplate_HidePortrait(grid)
	end
	if ButtonFrameTemplate_HideButtonBar and grid.Inset then
		ButtonFrameTemplate_HideButtonBar(grid)
	end
	grid:SetSize(250, 120)
	-- below the menus (FULLSCREEN_DIALOG), so the right click choices show
	-- over it
	grid:SetFrameStrata("DIALOG")
	grid:SetMovable(true)
	grid:EnableMouse(true)
	grid:SetClampedToScreen(true)
	grid:RegisterForDrag("LeftButton")
	grid:SetScript("OnDragStart", grid.StartMoving)
	grid:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, rel, x, y = self:GetPoint()
		db.gridPos = { point, rel, x, y }
	end)
	local pos = db.gridPos
	if type(pos) == "table" and pos[1] then
		grid:SetPoint(pos[1], UIParent, pos[2] or pos[1], tonumber(pos[3]) or 0, tonumber(pos[4]) or 0)
	else
		grid:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
	end
	if grid.SetTitle then
		grid:SetTitle(L.MENU_BUTTON)
	else
		local title = grid.TitleText or grid:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		if not grid.TitleText then
			title:SetPoint("TOP", grid, "TOP", 0, -5)
		end
		title:SetText(L.MENU_BUTTON)
	end
	-- the content sits in the template's inset, wherever the template puts it
	grid.top, grid.bottom = 30, 12
	if grid.Inset then
		for i = 1, grid.Inset:GetNumPoints() do
			local point, _, _, _, y = grid.Inset:GetPoint(i)
			if point == "TOPLEFT" then
				grid.top = -y + 8
			elseif point == "BOTTOMRIGHT" then
				grid.bottom = y + 8
			end
		end
	end
	grid.content = CreateFrame("Frame", nil, grid)
	grid.content:SetPoint("TOPLEFT", grid, "TOPLEFT", 12, -grid.top)
	grid.content:SetSize(250 - 24, 10)
	grid.rows = {}
	grid.view = "party"
	-- the two views, in the frame's band between the title and the inset
	local function ViewButton(text, view)
		local b = CreateFrame("Button", nil, grid, "UIPanelButtonTemplate")
		b:SetSize(100, 22)
		b:SetText(text)
		b:SetScript("OnClick", function()
			grid.view = view
			RefreshGrid()
		end)
		return b
	end
	grid.partyBtn = ViewButton(L.VIEW_PARTY, "party")
	grid.defaultsBtn = ViewButton(L.VIEW_DEFAULTS, "defaults")
	local band = -math.floor((24 + grid.top - 8) / 2 - 11 + 0.5)
	grid.partyBtn:SetPoint("TOPRIGHT", grid, "TOP", -2, band)
	grid.defaultsBtn:SetPoint("TOPLEFT", grid, "TOP", 2, band)
	tinsert(UISpecialFrames, "SetGoBlessParty")
	grid:Hide()
	return grid
end

local function OpenGrid()
	EnsureGrid()
	if not grid:IsShown() then
		grid.view = "party"
	end
	grid:Show()
	grid:Raise()
	RefreshGrid()
end

local function ToggleGrid()
	if EnsureGrid():IsShown() then
		grid:Hide()
	else
		OpenGrid()
	end
end

-- Blizzard's right click menu on a unit frame: the same choices, for a
-- member of your party
local function HookUnitMenus()
	if not (Menu and Menu.ModifyMenu) then
		return
	end
	local function Modify(_, root, context)
		local unit = context and context.unit
		local guid = unit and Clean(UnitGUID(unit))
		if not guid then
			return
		end
		root:CreateDivider()
		local sub = root:CreateButton(L.TITLE)
		for _, m in ipairs(PartyMembers()) do
			if m.guid == guid then
				MemberChoices(sub, m)
				sub:CreateDivider()
				break
			end
		end
		sub:CreateButton(L.MENU_BUTTON, function()
			OpenGrid()
		end)
		sub:CreateButton(L.SETTINGS, function()
			OpenSettings()
		end)
	end
	for _, tag in ipairs({ "MENU_UNIT_SELF", "MENU_UNIT_PARTY", "MENU_UNIT_RAID_PLAYER", "MENU_UNIT_RAID", "MENU_UNIT_PLAYER", "MENU_UNIT_FRIEND" }) do
		pcall(Menu.ModifyMenu, tag, Modify)
	end
end

-- SetGo! open on this module's page
function OpenSettings()
	if InCombatLockdown() or not SetGo.Open then
		return
	end
	SetGo.Open()
	local pages = SetGo.BuildPath and SetGo.BuildPath("modules") or {}
	for i, page in ipairs(pages) do
		if page.key == "module_" .. KEY then
			SetGo.Select("modules", i)
			return
		end
	end
end

-- a button under Blizzard's party and raid panel (the one on the left of
-- the screen), for the settings
local function HookRaidManager()
	local manager = CompactRaidFrameManager
	local display = manager and (manager.displayFrame or CompactRaidFrameManagerDisplayFrame)
	if not display then
		return
	end
	local b = CreateFrame("Button", nil, display, "UIPanelButtonTemplate")
	b:SetText(L.TITLE)
	b:SetHeight(22)
	b:SetPoint("TOPLEFT", display, "BOTTOMLEFT", 8, -2)
	b:SetPoint("TOPRIGHT", display, "BOTTOMRIGHT", -8, -2)
	b:SetScript("OnClick", function()
		ToggleGrid()
	end)
	if SetGo.Widgets and SetGo.Widgets.TipScripts then
		SetGo.Widgets.TipScripts(b, L.MENU_BUTTON, L.MENU_BUTTON_DESC)
	end
end

-- Ctrl + drag: lines through the middle of the screen while moving, and
-- the button snaps to them when let go close enough
local SNAP = 24
local guides
local function Guides(show)
	if not guides then
		local v = UIParent:CreateTexture(nil, "OVERLAY")
		v:SetColorTexture(1, 0.82, 0, 0.4)
		v:SetWidth(2)
		v:SetPoint("TOP", UIParent, "TOP")
		v:SetPoint("BOTTOM", UIParent, "BOTTOM")
		local h = UIParent:CreateTexture(nil, "OVERLAY")
		h:SetColorTexture(1, 0.82, 0, 0.4)
		h:SetHeight(2)
		h:SetPoint("LEFT", UIParent, "LEFT")
		h:SetPoint("RIGHT", UIParent, "RIGHT")
		guides = { v, h }
	end
	for _, t in ipairs(guides) do
		t:SetShown(show)
	end
end

local function SnapAndSave()
	local cx, cy = btn:GetCenter()
	local ux, uy = UIParent:GetCenter()
	local scale = btn:GetEffectiveScale() / UIParent:GetEffectiveScale()
	local dx, dy = cx * scale - ux, cy * scale - uy
	if math.abs(dx) < SNAP then
		dx = 0
	end
	if math.abs(dy) < SNAP then
		dy = 0
	end
	dx, dy = math.floor(dx / scale + 0.5), math.floor(dy / scale + 0.5)
	btn:ClearAllPoints()
	btn:SetPoint("CENTER", UIParent, "CENTER", dx, dy)
	db.pos = { "CENTER", "CENTER", dx, dy }
end

local function Build()
	btn = CreateFrame("Button", "SetGoBlessButton", UIParent, "SecureActionButtonTemplate")
	-- the loot toast's size; the icon square sits where the toast has it
	-- (Blizzard's loot toast: 276x96, a 52 icon 23 from the left)
	local w, h = 276, 96
	local info = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(ATLAS)
	if info and tonumber(info.width) and info.width > 0 then
		w, h = info.width, info.height
	end
	local sx, sy = w / 276, h / 96
	btn:SetSize(w, h)
	btn:SetFrameStrata("MEDIUM")
	btn:RegisterForClicks("AnyUp", "AnyDown")
	btn:RegisterForDrag("LeftButton")
	btn:SetMovable(true)
	btn:SetClampedToScreen(true)
	-- ctrl + left click does nothing, so dragging doesn't cast
	btn.noop = function() end
	btn:SetAttribute("ctrl-type1", "noop")
	local pos = db.pos
	if type(pos) == "table" and pos[1] then
		btn:SetPoint(pos[1], UIParent, pos[2] or pos[1], tonumber(pos[3]) or 0, tonumber(pos[4]) or 0)
	else
		btn:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
	end

	local bg = btn:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	if not bg:SetAtlas(ATLAS) then
		bg:SetColorTexture(0, 0, 0, 0.7)
	end
	local size = 52 * sy
	icon = btn:CreateTexture(nil, "ARTWORK")
	icon:SetSize(size, size)
	icon:SetPoint("LEFT", btn, "LEFT", 23 * sx, 0)
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	local hl = btn:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints(icon)
	hl:SetColorTexture(1, 1, 1, 0.15)
	-- the toast's dark box right of the icon, measured against the icon
	-- (in game: 10 right of it, 5 below its top, 3.8 icons wide, 0.85 high)
	box = CreateFrame("Frame", nil, btn)
	box:SetPoint("TOPLEFT", icon, "TOPRIGHT", size * 10 / 46, -size * 5 / 46)
	box:SetSize(size * 3.78, size * 0.85)
	pad = math.floor(size * 6 / 46 + 0.5)
	local textWidth = size * 3.78 - pad * 2
	title = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetWidth(textWidth - 22)
	title:SetJustifyH("LEFT")
	title:SetWordWrap(false)
	target = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	target:SetWidth(textWidth)
	target:SetJustifyH("LEFT")
	target:SetWordWrap(false)
	note = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	note:SetWidth(textWidth)
	note:SetJustifyH("LEFT")
	note:SetWordWrap(false)
	note:SetTextColor(1, 0.55, 0.2)
	-- how many more wait behind this one
	count = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	count:SetPoint("TOPRIGHT", box, "TOPRIGHT", -pad, -3)

	btn:SetScript("OnDragStart", function(self)
		if IsControlKeyDown() and not InCombatLockdown() then
			self:StartMoving()
			Guides(true)
		end
	end)
	btn:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		Guides(false)
		SnapAndSave()
	end)
	btn:SetScript("PostClick", function(_, button, down)
		if down ~= KeyDown() then
			return
		end
		if button == "RightButton" then
			Dismiss()
		elseif button == "LeftButton" and current and not IsControlKeyDown() then
			lastClick = { keys = current.keys, t = GetTime(), spell = current.spell, stranger = current.stranger }
		end
	end)
	btn:SetScript("OnEnter", function(self)
		if not current then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if current.item then
			GameTooltip:SetItemByID(current.item)
		else
			GameTooltip:SetSpellByID(current.spell)
		end
		GameTooltip:AddLine(L.TIP_CLICKS, 0.6, 0.6, 0.6)
		GameTooltip:Show()
	end)
	btn:SetScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)
	btn:Hide()

	local ticker = CreateFrame("Frame")
	ticker:SetScript("OnUpdate", function(_, elapsed)
		since = since + elapsed
		-- changes within half a second; otherwise only when something is due
		if since < 0.5 or (not dirty and GetTime() < wake) then
			return
		end
		since, dirty = 0, false
		Update()
	end)
end

--------------------------------------------------------------------------------
-- Who buffed you: thanks and a buff back
--------------------------------------------------------------------------------

local playerGUID

local function FullName(name, realm)
	if not name then
		return nil
	end
	if realm and realm ~= "" then
		return name .. "-" .. realm
	end
	return name
end

-- buffs seen right after a login, reload or loading screen were already
-- there: no thanks for those
local quietUntil = 0

local function BuffedBy(guid, spellId, unit, how)
	if not guid or guid == playerGUID or not guid:find("^Player%-") then
		return
	end
	local a = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID and C_UnitAuras.GetPlayerAuraBySpellID(spellId)
	local dur = a and tonumber(Clean(a.duration)) or 0
	local _, class, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
	name, class, realm = Clean(name), Clean(class), Clean(realm)
	if not name then
		return
	end
	unit = unit or (UnitTokenFromGUID and Clean(UnitTokenFromGUID(guid)))
	if db.debug then
		SetGo.Print(L.DEBUG_BUFFED:format(name, SpellName(spellId) or spellId, how, math.floor(dur / 60), unit or "-"))
	end
	local function Why(text)
		if db.debug then
			SetGo.Print(L.DEBUG_THANK:format(text))
		end
	end
	if dur < D.MIN_DURATION then
		Why("shorter than 5 min")
		return
	end
	local inGroup = InGroup(guid)
	local now = GetTime()
	if db.thanksOn == false then
		Why("thanks switched off")
	elseif now < quietUntil then
		Why("just logged in, reloaded or changed zone")
	elseif InCombatLockdown() then
		Why("in combat")
	elseif thanked[guid] and now - thanked[guid] <= D.THANK_EVERY then
		Why("already thanked in the last 5 min")
	else
		thanked[guid] = now
		-- DoEmote takes the person's name (as typing /thank Name), not a unit
		local who = FullName(name, realm)
		local ok, err = pcall(DoEmote, "THANK", who)
		Why(ok and ("/thank " .. who) or ("failed: " .. tostring(err)))
	end
end

-- the aura's caster, only known while a unit token points at them
local function NewAuras(info)
	-- in combat these come secret: nothing to read then
	if type(info) ~= "table" then
		return
	end
	local full = info.isFullUpdate
	if full ~= nil and (Clean(full) == nil or full == true) then
		return
	end
	local added = Clean(info.addedAuras)
	if type(added) ~= "table" then
		return
	end
	-- whatever the game still hides, nothing breaks
	pcall(function()
	for _, a in ipairs(added) do
		local id, src, helpful = Clean(a.spellId), Clean(a.sourceUnit), Clean(a.isHelpful)
		if id and src and helpful then
			local guid = Clean(UnitGUID(src))
			if guid then
				-- after this event, so the aura reads fully
				C_Timer.After(0.2, function()
					BuffedBy(guid, id, src, "aura")
				end)
			end
		end
	end
	end)
end

local function CombatLog()
	local _, sub, _, src, _, _, _, dst, _, _, _, spellId, _, _, auraType = CombatLogGetCurrentEventInfo()
	if dst == playerGUID and auraType == "BUFF" and (sub == "SPELL_AURA_APPLIED" or sub == "SPELL_AURA_REFRESH") then
		C_Timer.After(0.2, function()
			BuffedBy(src, spellId, nil, "log")
		end)
	end
end

--------------------------------------------------------------------------------
-- Page in SetGo!
--------------------------------------------------------------------------------

-- a reminder with a length: its name, then when (dropdown) and how long
-- before it ends (slider, greyed while Never) on one line
-- a reminder: its name, then on one line when (dropdown) and, for buffs
-- with a length, how long before the end (slider, greyed while Never).
-- extras: checkboxes after the dropdown instead ({ label, tip, setting })
local function RemindRow(buff, name, mode, ModeOptions, extras)
	return { kind = "custom", build = function(page, y, width)
		local W = SetGo.Widgets
		local label, lh = W.Text(page, W.FONT_BODY, width, name)
		label:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
		y = y + lh + 5
		local dd = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
		dd:SetPoint("TOPLEFT", page, "TOPLEFT", 2, -y)
		dd:SetWidth(140)
		W.TipScripts(dd, name, L.BUFF_DESC, true)
		local refreshers = {}
		local height = 26
		local slider
		if buff.dur then
			slider = CreateFrame("Frame", nil, page, "MinimalSliderWithSteppersTemplate")
			slider:SetPoint("LEFT", dd, "RIGHT", 16, 0)
			slider:SetSize(math.max(100, math.min(220, width - 140 - 16 - 70)), 20)
			W.TipScripts(slider, name, L.REMIND_DESC, true)
			local max = math.min(buff.dur, 60)
			local auto = math.max(1, math.floor(D.Threshold(buff.dur * 60) / 60 + 0.5))
			local busy = false
			slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
				if busy then
					return
				end
				db.remind = db.remind or {}
				db.remind[buff.key] = math.floor(value + 0.5)
				Request()
			end, slider)
			local formatters = MinimalSliderWithSteppersMixin.Label and {
				[MinimalSliderWithSteppersMixin.Label.Right] = function(v)
					return L.MINUTES:format(math.floor(v + 0.5))
				end,
			}
			refreshers[#refreshers + 1] = function()
				busy = true
				local m = db.remind and tonumber(db.remind[buff.key])
				slider:Init(math.max(0, math.min(max, m or auto)), 0, max, max, formatters)
				if slider.SetEnabled then
					slider:SetEnabled(mode:GetValue() ~= "NEVER")
				end
				busy = false
			end
		elseif extras then
			-- checkboxes on the same line; the next one drops below if there's
			-- no room left
			local x, line = 140 + 18, 0
			for _, e in ipairs(extras) do
				local cb = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
				cb:SetSize(24, 24)
				local text = W.Text(page, W.FONT_BODY, 260, e.label)
				local need = 24 + 2 + math.ceil(text:GetStringWidth()) + 14
				if x + need > width and x > 140 + 18 then
					x, line = 140 + 18, line + 1
				end
				cb:SetPoint("TOPLEFT", page, "TOPLEFT", x, -(y + line * 26) + 1)
				text:ClearAllPoints()
				text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
				text:SetWidth(math.ceil(text:GetStringWidth()) + 4)
				W.TipScripts(cb, e.label, e.tip)
				cb:SetScript("OnClick", function(self)
					e.setting:SetValue(self:GetChecked() and true or false)
				end)
				refreshers[#refreshers + 1] = function()
					cb:SetChecked(e.setting:GetValue() and true or false)
				end
				x = x + need
			end
			height = 26 + line * 26
		end
		local function Refresh()
			for _, f in ipairs(refreshers) do
				f()
			end
			dd:SetupMenu(function(_, root)
				for _, opt in ipairs(ModeOptions()) do
					root:CreateRadio(opt.label, function()
						return mode:GetValue() == opt.value
					end, function()
						mode:SetValue(opt.value)
						if slider and slider.SetEnabled then
							slider:SetEnabled(opt.value ~= "NEVER")
						end
					end)
				end
			end)
		end
		Refresh()
		if type(page.refreshers) == "table" then
			table.insert(page.refreshers, Refresh)
		end
		return y + height + 10
	end }
end

local items
local function Items()
	if items then
		return items
	end
	local Pseudo = SetGo.Pseudo
	local thanks = Pseudo("SETGO_BLESS_THANKS_ON", L.THANKS, L.THANKS_DESC, true, function()
		return db.thanksOn ~= false
	end, function(on)
		db.thanksOn = on and true or false
	end)
	local autoGrid = Pseudo("SETGO_BLESS_AUTO_GRID", L.AUTO_GRID, L.AUTO_GRID_DESC, true, function()
		return db.autoGrid ~= false
	end, function(on)
		db.autoGrid = on and true or false
	end)
	local scope = Pseudo("SETGO_BLESS_SCOPE", L.SCOPE, L.SCOPE_DESC, "ALL", function()
		return db.scope or "ALL"
	end, function(v)
		db.scope = v
		Request()
	end)
	local function ScopeOptions()
		return {
			{ value = "SELF", label = L.SCOPE_SELF },
			{ value = "GROUP", label = L.SCOPE_GROUP },
			{ value = "ALL", label = L.SCOPE_ALL },
		}
	end
	-- the macro to drag to a bar, and the two switches beside it
	local extras = {
		{ label = L.AUTO_GRID, tip = L.AUTO_GRID_DESC, setting = autoGrid },
		{ label = L.THANKS, tip = L.THANKS_DESC, setting = thanks },
	}
	items = {
		{ kind = "custom", build = function(page, y, width)
			local W = SetGo.Widgets
			local b = CreateFrame("Button", nil, page)
			b:SetSize(36, 36)
			b:SetPoint("TOPLEFT", page, "TOPLEFT", 2, -(y + 4))
			local tex = b:CreateTexture(nil, "ARTWORK")
			tex:SetAllPoints()
			tex:SetTexture("Interface\\Icons\\Spell_Magic_GreaterBlessingofKings")
			local hl = b:CreateTexture(nil, "HIGHLIGHT")
			hl:SetAllPoints()
			hl:SetColorTexture(1, 1, 1, 0.2)
			local function Pick()
				local idx = EnsureMacro()
				if idx then
					PickupMacro(idx)
				end
			end
			b:RegisterForDrag("LeftButton")
			b:SetScript("OnDragStart", Pick)
			b:SetScript("OnClick", Pick)
			W.TipScripts(b, MACRO, L.MACRO_DRAG)
			-- the checkboxes, one under the other, right of the icon
			local refreshers = {}
			for i, e in ipairs(extras) do
				local cb = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
				cb:SetSize(24, 24)
				cb:SetPoint("TOPLEFT", page, "TOPLEFT", 50, -(y + (i - 1) * 22))
				local text = W.Text(page, W.FONT_BODY, width - 80, e.label)
				text:ClearAllPoints()
				text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
				W.TipScripts(cb, e.label, e.tip)
				cb:SetScript("OnClick", function(self)
					e.setting:SetValue(self:GetChecked() and true or false)
				end)
				refreshers[#refreshers + 1] = function()
					cb:SetChecked(e.setting:GetValue() and true or false)
				end
			end
			local function Refresh()
				for _, f in ipairs(refreshers) do
					f()
				end
			end
			Refresh()
			if type(page.refreshers) == "table" then
				table.insert(page.refreshers, Refresh)
			end
			return y + 4 + 44 + 10
		end },
		{ kind = "dropdown", setting = scope, settings = { scope }, name = L.SCOPE, tooltip = L.SCOPE_DESC, options = ScopeOptions },
	}
	-- each suggestion: never, in a group, always
	local function ModeOptions()
		return {
			{ value = "NEVER", label = L.MODE_NEVER },
			{ value = "GROUP", label = L.MODE_GROUP },
			{ value = "ALWAYS", label = L.MODE_ALWAYS },
		}
	end
	local list = {}
	for _, buff in ipairs(MyBuffs()) do
		list[#list + 1] = buff
	end
	for _, buff in ipairs(D.CONSUMABLES) do
		list[#list + 1] = buff
	end
	items[#items + 1] = { kind = "header", name = L.SEC_BUFFS }
	for _, buff in ipairs(list) do
		local name = buff.blessing and L.BLESSINGS or buff.stance and L.AURA or buff.stone and L.STONE
			or buff.flask and L.FLASK or SpellName(buff.ranks[1][1]) or buff.key
		local s = Pseudo("SETGO_BLESS_MODE_" .. buff.key, name, L.BUFF_DESC, buff.default or (buff.off and "NEVER" or "ALWAYS"), function()
			return Mode(buff)
		end, function(v)
			db.mode = db.mode or {}
			db.mode[buff.key] = v
			Request()
		end)
		items[#items + 1] = RemindRow(buff, name, s, ModeOptions)
	end
	return items
end

-- shortcut: the buff menu, from the minimap button's right click menu
SetGo.RegisterModule({ key = KEY, title = L.TITLE, items = Items, shortcut = function()
	if ON then
		ToggleGrid()
	end
end })

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

SLASH_SETGOBLESS1 = "/blessyou"
SlashCmdList.SETGOBLESS = function(msg)
	if not ON then
		SetGo.Print(L.OFF_IN_SETGO)
		return
	end
	if strtrim(msg or ""):lower() == "macro" then
		lastBody = nil
		SetMacro(macroCand)
		MacroReport()
		return
	end
	if strtrim(msg or ""):lower() == "debug" then
		db.debug = not db.debug or nil
		SetGo.Print(db.debug and L.DEBUG_ON or L.DEBUG_OFF)
	end
end

-- the macro and the mouseover: hovering a player (in the world or on a
-- unit frame) who misses a buff of yours turns the macro into that buff on
-- them, until the mouse leaves; the big button doesn't change
local mouseWatch = CreateFrame("Frame")
mouseWatch:Hide()
local function MouseoverMacro()
	if InCombatLockdown() or not ON then
		return
	end
	local c = UnitExists("mouseover") and TargetBuff(MyBuffs(), "mouseover", true) or nil
	mouseCand = c
	SetMacro(mouseCand or macroCand)
	mouseWatch:SetShown(c ~= nil)
end
do
	local since = 0
	mouseWatch:SetScript("OnUpdate", function(self, elapsed)
		since = since + elapsed
		if since < 0.2 then
			return
		end
		since = 0
		if not UnitExists("mouseover") then
			self:Hide()
			mouseCand = nil
			if not InCombatLockdown() then
				SetMacro(macroCand)
			end
		end
	end)
end

local lastInstance, wasInGroup

-- remembers the aura you switch on, to put that one back
local function NoteAura()
	local form = tonumber(Clean(GetShapeshiftForm())) or 0
	if form <= 0 or not GetShapeshiftFormInfo then
		return
	end
	local spellId = Clean(select(4, GetShapeshiftFormInfo(form)))
	for _, a in ipairs(D.PALADIN_AURAS) do
		for _, r in ipairs(a.ranks) do
			if r[1] == spellId then
				db.lastAura = a.key
				return
			end
		end
	end
end

-- the combat log fires hundreds of times a second in a fight. Forever
-- doesn't let addons unregister it, so it's registered once and every event
-- in combat stops at the first line
local inFight = false
local logOn = false
local function CombatLogOn(frame)
	if not logOn and CombatLogGetCurrentEventInfo then
		logOn = pcall(frame.RegisterEvent, frame, "COMBAT_LOG_EVENT_UNFILTERED")
	end
end

-- only you and your group's buffs matter (not target, mouseover, nameplates)
local function GroupUnit(unit)
	return unit == "player" or unit == "target"
		or (type(unit) == "string" and (unit:find("^party%d") or unit:find("^raid%d"))) and true or false
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
	if event == "ADDON_LOADED" then
		if arg1 ~= ADDON then
			return
		end
		SetGoBlessDB = type(SetGoBlessDB) == "table" and SetGoBlessDB or {}
		db = SetGoBlessDB
		-- the old "What to remind" switches are gone: each reminder has its own
		db.self, db.group, db.returnBuffs = nil, nil, nil
		-- thanks used to be Never / Outside your group / Everyone
		if db.thanksOn == nil and db.thanks ~= nil then
			db.thanksOn = db.thanks ~= "OFF"
		end
		db.thanks = nil
		if not ON then
			return
		end
		Build()
		HookUnitMenus()
		for _, e in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", "UNIT_AURA",
			"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "BAG_UPDATE_DELAYED", "SPELLS_CHANGED",
			"UNIT_INVENTORY_CHANGED", "PLAYER_EQUIPMENT_CHANGED",
			"PLAYER_LEVEL_UP", "UI_ERROR_MESSAGE", "PLAYER_TARGET_CHANGED", "PLAYER_UNGHOST", "PLAYER_ALIVE",
			"UPDATE_SHAPESHIFT_FORM", "UPDATE_SHAPESHIFT_FORMS", "UPDATE_MOUSEOVER_UNIT" }) do
			self:RegisterEvent(e)
		end
		self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
		-- the combat log, where Forever still gives it to addons; only out of
		-- combat (thanks and buffs back are out of combat things anyway)
		inFight = InCombatLockdown() and true or false
		CombatLogOn(self)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		if not inFight then
			CombatLog()
		end
	elseif event == "UNIT_AURA" then
		if not GroupUnit(arg1) then
			return
		end
		if arg1 == "player" then
			NewAuras(arg2)
		end
		local guid = Clean(UnitGUID(arg1))
		if guid then
			auraCache[guid] = nil
		end
		Request()
	elseif event == "PLAYER_LOGIN" then
		playerGUID = UnitGUID("player")
		wasInGroup = IsInGroup()
		HookRaidManager()
		Request()
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- entering an instance brings dismissed buffs back
		local inside = IsInInstance()
		local id = inside and select(8, GetInstanceInfo()) or nil
		if inside and id ~= lastInstance then
			wipe(dismissed)
		end
		lastInstance = id
		quietUntil = GetTime() + 5
		wipe(auraCache)
		Request()
	elseif event == "GROUP_ROSTER_UPDATE" then
		wipe(auraCache)
		-- joining a party: the party window, if wanted
		local inGroup = IsInGroup()
		if inGroup and not wasInGroup and db.autoGrid ~= false and not InCombatLockdown() then
			OpenGrid()
		end
		wasInGroup = inGroup
		-- the party's own choices end with the party
		if not IsInGroup() then
			wipe(overrides)
		else
			for guid in pairs(overrides) do
				if not InGroup(guid) then
					overrides[guid] = nil
				end
			end
		end
		Request()
	elseif event == "PLAYER_REGEN_DISABLED" then
		-- the last moment the button can still change
		Hidden("combat")
		Show(nil)
		inFight = true
	elseif event == "PLAYER_REGEN_ENABLED" then
		inFight = false
		-- buffs changed in combat may have come secret: read everyone again
		wipe(auraCache)
		Request()
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		MouseoverMacro()
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
		NoteAura()
		Request()
	elseif event == "SPELLS_CHANGED" or event == "PLAYER_LEVEL_UP" then
		wipe(knownCache)
		Request()
	elseif event == "BAG_UPDATE_DELAYED" then
		wipe(itemCache)
		Request()
	elseif event == "UI_ERROR_MESSAGE" then
		-- refused for something stronger already there (camp benefits)
		if lastClick and GetTime() - lastClick.t < D.REFUSAL_WINDOW and SPELL_FAILED_AURA_BOUNCED
			and Clean(arg2) == SPELL_FAILED_AURA_BOUNCED then
			for _, k in ipairs(lastClick.keys) do
				dismissed[k] = true
			end
			lastClick = nil
			Request()
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		-- a buff back went out: that's done
		local spellId = Clean(arg3)
		if lastClick and lastClick.stranger and spellId == lastClick.spell then
			strangers[lastClick.stranger] = nil
			lastClick = nil
		end
		Request()
	else
		Request()
	end
end)
