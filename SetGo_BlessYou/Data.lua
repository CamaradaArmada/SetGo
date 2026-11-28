local _, ns = ...

--------------------------------------------------------------------------------
-- The buffs Bless You! knows, Forever's (Classic style: ranks, reagents,
-- group versions). Ids checked against Missing Class Buff's data (2026-11).
--
-- ranks = {{spellId, spellLevel}, ...} the single target spell, lowest first
-- group = {{spellId, spellLevel, reagentItemId}, ...} the group version: hits
--   the target's party (its raid subgroup), costs a reagent
-- alt = other spells that count as having it (mage armor vs frost armor)
-- self = only ever on the player
-- skip = classes that don't need it (no mana)
-- off = not reminded until set on the page
-- dur = how long it usually lasts, in minutes (the page's slider)
--------------------------------------------------------------------------------

local D = {}
ns.D = D

local NO_MANA = { WARRIOR = true, ROGUE = true }

D.BUFFS = {
	DRUID = {
		{ key = "MARK", dur = 30, ranks = { { 1126, 1 }, { 5232, 10 }, { 6756, 20 }, { 5234, 30 }, { 8907, 40 }, { 9884, 50 }, { 9885, 60 } },
			group = { { 21849, 50, 17021 }, { 21850, 60, 17026 } } }, -- Mark / Gift of the Wild
		{ key = "THORNS", dur = 10, self = true, ranks = { { 467, 6 }, { 782, 14 }, { 1075, 24 }, { 8914, 34 }, { 9756, 44 }, { 9910, 54 } } },
	},
	MAGE = {
		{ key = "INTELLECT", dur = 30, skip = NO_MANA, ranks = { { 1459, 1 }, { 1460, 14 }, { 1461, 28 }, { 10156, 42 }, { 10157, 56 } },
			group = { { 23028, 56, 17020 } } }, -- Arcane Intellect / Brilliance
		{ key = "ARMOR", dur = 30, self = true, ranks = { { 168, 1 }, { 7300, 10 }, { 7301, 20 }, { 7302, 30 }, { 7320, 40 }, { 10219, 50 }, { 10220, 60 } },
			alt = { 6117, 22782, 22783 } }, -- Frost / Ice Armor, Mage Armor counts
	},
	PRIEST = {
		{ key = "FORTITUDE", dur = 30, ranks = { { 1243, 1 }, { 1244, 12 }, { 1245, 24 }, { 2791, 36 }, { 10937, 48 }, { 10938, 60 } },
			group = { { 21562, 48, 17028 }, { 21564, 60, 17029 } } },
		{ key = "INNER_FIRE", dur = 10, self = true, ranks = { { 588, 12 }, { 7128, 20 }, { 602, 30 }, { 1006, 40 }, { 10951, 50 }, { 10952, 60 } } },
		{ key = "SPIRIT", dur = 30, skip = NO_MANA, ranks = { { 14752, 30 }, { 14818, 40 }, { 14819, 50 }, { 27841, 60 } },
			group = { { 27681, 60, 17029 } } },
		{ key = "SHADOW", dur = 10, off = true, ranks = { { 976, 30 }, { 10957, 42 }, { 10958, 56 } },
			group = { { 27683, 56, 17029 } } },
	},
	SHAMAN = {
		{ key = "SHIELD", dur = 10, self = true, ranks = { { 324, 8 }, { 325, 16 }, { 905, 24 }, { 945, 32 }, { 8134, 40 }, { 10431, 48 }, { 10432, 56 } },
			alt = { 408510 } }, -- Lightning Shield, Water Shield counts
	},
	WARLOCK = {
		{ key = "DEMON", dur = 30, self = true, ranks = { { 687, 1 }, { 696, 10 }, { 706, 20 }, { 1086, 30 }, { 11733, 40 }, { 11734, 50 }, { 11735, 60 } } },
	},
	WARRIOR = {
		-- hits the group around the warrior, so only the warrior is checked
		{ key = "SHOUT", dur = 2, self = true, ranks = { { 6673, 1 }, { 5242, 12 }, { 6192, 22 }, { 11549, 32 }, { 11550, 42 }, { 11551, 52 }, { 25289, 60 } } },
	},
	HUNTER = {
		{ key = "TRUESHOT", self = true, ranks = { { 1299346, 25 }, { 1299348, 32 }, { 19506, 40 }, { 20905, 50 }, { 20906, 60 } } },
	},
	PALADIN = {
		-- an aura on the stance bar: reminded while none is on
		{ key = "AURA", stance = true },
		{ key = "BLESSING", dur = 60, blessing = true },
	},
	ROGUE = {},
}

-- Blessings: one per paladin on each player. A greater blessing hits every
-- player of the target's class in the group, needs a Symbol of Kings.
D.BLESSINGS = {
	MIGHT = { ranks = { { 19740, 4 }, { 19834, 12 }, { 19835, 22 }, { 19836, 32 }, { 19837, 42 }, { 19838, 52 }, { 25291, 60 } },
		greater = { { 25782, 52, 21177 }, { 25916, 60, 21177 } } },
	WISDOM = { ranks = { { 19742, 14 }, { 19850, 24 }, { 19852, 34 }, { 19853, 44 }, { 19854, 54 }, { 25290, 60 } },
		greater = { { 25894, 54, 21177 }, { 25918, 60, 21177 } } },
	KINGS = { ranks = { { 20217, 20 } }, greater = { { 25898, 60, 21177 } } },
}
D.BLESSING_ORDER = { "KINGS", "MIGHT", "WISDOM" }

-- the blessing priority is set per kind of class; the right click menu can
-- change it for one player of the party, while in that party
D.BLESS_GROUP = {
	WARRIOR = "MELEE", ROGUE = "MELEE",
	WARLOCK = "CASTER", PRIEST = "CASTER", MAGE = "CASTER",
	DRUID = "HYBRID", HUNTER = "HYBRID", PALADIN = "HYBRID", SHAMAN = "HYBRID",
}
D.BLESS_GROUPS = { "MELEE", "CASTER", "HYBRID" }
D.BLESS_GROUP_CLASSES = {
	MELEE = { "WARRIOR", "ROGUE" },
	CASTER = { "WARLOCK", "PRIEST", "MAGE" },
	HYBRID = { "DRUID", "HUNTER", "PALADIN", "SHAMAN" },
}
D.BLESS_DEFAULT = {
	MELEE = { "MIGHT", "KINGS", "NONE" },
	CASTER = { "WISDOM", "KINGS", "NONE" },
	HYBRID = { "KINGS", "MIGHT", "WISDOM" },
}

-- paladin auras (they sit on the stance bar on Forever); the page picks one
D.PALADIN_AURAS = {
	{ key = "DEVOTION", ranks = { { 465, 1 }, { 10290, 10 }, { 643, 20 }, { 10291, 30 }, { 1032, 40 }, { 10292, 50 }, { 10293, 60 } } },
	{ key = "RETRIBUTION", ranks = { { 7294, 16 }, { 10298, 26 }, { 10299, 36 }, { 10300, 46 }, { 10301, 56 } } },
	{ key = "CONCENTRATION", ranks = { { 19746, 22 } } },
	{ key = "SHADOW", dur = 10, ranks = { { 19876, 28 }, { 19895, 40 }, { 19896, 52 } } },
	{ key = "FROST", ranks = { { 19888, 32 }, { 19897, 44 }, { 19898, 56 } } },
	{ key = "FIRE", ranks = { { 19891, 36 }, { 19899, 48 }, { 19900, 60 } } },
}

-- Consumables, for every class: on you only, by item
-- stones go on a weapon's temporary enchant slot (an oil or stone; poisons
-- and imbues have their own slot on Forever); best first
D.STONES = {
	-- edged weapons: axes, swords, polearms, daggers
	EDGED = { 18262, 12404, 7964, 2871, 2863, 2862 }, -- elemental, dense, solid, heavy, coarse, rough sharpening stone
	-- blunt weapons: maces and staves
	BLUNT = { 18262, 12643, 7965, 3241, 3240, 3239 }, -- elemental sharpening stone (any weapon), dense, solid, heavy, coarse, rough weightstone
	ANY = { 18262 },
}
-- weapon subclass -> which stones
D.WEAPON_KIND = {
	[0] = "EDGED", [1] = "EDGED", [6] = "EDGED", [7] = "EDGED", [8] = "EDGED", [15] = "EDGED",
	[4] = "BLUNT", [5] = "BLUNT", [10] = "BLUNT",
	[13] = "ANY", -- fist weapons
}
D.STONE_DURATION = 1800
-- flask item -> the buff it gives (all 2 hours); petrification left out
D.FLASKS = {
	{ 13510, 17626 }, -- Flask of the Titans
	{ 13511, 17627 }, -- Distilled Wisdom
	{ 13512, 17628 }, -- Supreme Power
	{ 13513, 17629 }, -- Chromatic Resistance
	{ 274273, 1293740 }, -- Natural Accuracy
	{ 274274, 1293741 }, -- Natural Aggression
	{ 274275, 1293742 }, -- Natural Precision
	{ 274276, 1293743 }, -- Natural Swiftness
}
D.FLASK_DURATION = 7200
D.CONSUMABLES = {
	{ key = "STONE", dur = 30, stone = true, default = "ALWAYS" },
	{ key = "FLASK", dur = 120, flask = true, default = "GROUP" },
}

-- a group version once this many in one party need it
D.GROUP_MIN = 3
-- a greater blessing once this many of one class need the same blessing
D.GREATER_MIN = 2
-- someone who buffed you is offered a buff back for this long (seconds)
D.RETURN_WINDOW = 600
-- buffs shorter than this aren't thanked for nor returned (heals over time,
-- shields)
D.MIN_DURATION = 300
-- one /thank per person in this time
D.THANK_EVERY = 300
-- a cast refused for a stronger buff (camp benefits): the error comes
-- within this time of the click
D.REFUSAL_WINDOW = 1.5

-- refresh when less than this is left: 10% of the buff's length, between
-- 30 seconds and 5 minutes
function D.Threshold(duration)
	duration = tonumber(duration) or 0
	if duration <= 0 then
		return 0
	end
	return math.max(30, math.min(300, duration * 0.1))
end

-- every id that counts as having the buff
function D.AllIds(buff)
	if buff.ids then
		return buff.ids
	end
	local ids = {}
	for _, r in ipairs(buff.ranks or {}) do ids[r[1]] = true end
	for _, r in ipairs(buff.group or {}) do ids[r[1]] = true end
	for _, id in ipairs(buff.alt or {}) do ids[id] = true end
	for _, r in ipairs(buff.greater or {}) do ids[r[1]] = true end
	buff.ids = ids
	return ids
end
