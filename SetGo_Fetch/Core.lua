local _, ns = ...
local L = ns.L

ns.MAX_BUTTONS = 12
ns.MAX_FLY = 6
ns.QUESTION_MARK = 134400

BINDING_HEADER_SETGO_FETCH = L.ADDON
for i = 1, ns.MAX_BUTTONS do
	_G["BINDING_NAME_CLICK SetGoFetchButton" .. i .. ":LeftButton"] = L.BUTTON:format(i)
end

--------------------------------------------------------------------------------
-- Helpers. Forever uses the Midnight rules: some values can come back "secret".
-- Secret values may be handed to Blizzard widgets, but never tested or compared,
-- so every check below asks IsSecret first.
--------------------------------------------------------------------------------

function ns.IsSecret(value)
	return issecretvalue ~= nil and issecretvalue(value) == true
end

local function pass(ok, ...)
	if ok then
		return ...
	end
end

function ns.Try(func, ...)
	if type(func) ~= "function" then
		return
	end
	return pass(pcall(func, ...))
end

local Try, IsSecret = ns.Try, ns.IsSecret

-- true only when the value is readable and truthy
function ns.Yes(value)
	if IsSecret(value) then
		return false
	end
	return value and true or false
end

--------------------------------------------------------------------------------
-- Actions: { type = "spell", id = n } | { type = "item", id = n } | { type = "macro", name = s }
--------------------------------------------------------------------------------

local function Normalize(a)
	if type(a) ~= "table" then
		return nil
	end
	if a.type == "spell" and type(a.id) == "number" then
		return { type = "spell", id = a.id }
	elseif a.type == "item" and type(a.id) == "number" then
		return { type = "item", id = a.id }
	elseif a.type == "macro" then
		local name = a.name
		if type(name) ~= "string" and type(a.id) == "number" then
			name = Try(GetMacroInfo, a.id)
		end
		if type(name) == "string" and name ~= "" then
			return { type = "macro", name = name }
		end
	end
	return nil
end
ns.Normalize = Normalize

function ns.CursorAction()
	local kind, a, _, c = GetCursorInfo()
	if kind == "spell" then
		-- Forever: "spell", spellbook index, book type, spell ID
		if type(c) == "number" then
			return { type = "spell", id = c }
		end
	elseif kind == "item" then
		if type(a) == "number" then
			return { type = "item", id = a }
		end
	elseif kind == "macro" then
		local name = Try(GetMacroInfo, a)
		if type(name) == "string" and name ~= "" then
			return { type = "macro", name = name }
		end
	end
	return nil
end

function ns.Pickup(a)
	if not a then
		return
	end
	if a.type == "spell" then
		if C_Spell and C_Spell.PickupSpell then
			Try(C_Spell.PickupSpell, a.id)
		else
			Try(PickupSpell, a.id)
		end
	elseif a.type == "item" then
		if C_Item and C_Item.PickupItem then
			Try(C_Item.PickupItem, a.id)
		else
			Try(PickupItem, a.id)
		end
	elseif a.type == "macro" then
		Try(PickupMacro, a.name)
	end
end

-- What the action does right now: a spell or an item. Macros resolve to
-- whatever spell or item their current conditions point at, like native bars.
function ns.Resolve(a)
	if not a then
		return nil
	end
	if a.type == "spell" or a.type == "item" then
		return a.type, a.id
	end
	if a.type == "macro" and a.name then
		local spellID = Try(GetMacroSpell, a.name)
		if not IsSecret(spellID) and type(spellID) == "number" then
			return "spell", spellID
		end
		local itemName, itemLink = Try(GetMacroItem, a.name)
		local ref
		if not IsSecret(itemLink) and itemLink then
			ref = itemLink
		elseif not IsSecret(itemName) and itemName then
			ref = itemName
		end
		if ref and C_Item and C_Item.GetItemInfoInstant then
			local itemID = Try(C_Item.GetItemInfoInstant, ref)
			if not IsSecret(itemID) and type(itemID) == "number" then
				return "item", itemID
			end
		end
	end
	return nil
end

function ns.GetIcon(a)
	if not a then
		return nil
	end
	local icon
	if a.type == "spell" then
		icon = Try(C_Spell.GetSpellTexture, a.id)
	elseif a.type == "item" then
		icon = Try(C_Item.GetItemIconByID, a.id)
	elseif a.type == "macro" then
		local name, macroIcon = Try(GetMacroInfo, a.name)
		if name then
			icon = macroIcon
		end
	end
	return icon
end

--------------------------------------------------------------------------------
-- Saved data
--   SetGoFetchDB (per character): button contents
--   SetGoFetchLayoutDB (account): bar layout per Edit Mode layout
--------------------------------------------------------------------------------

function ns.InitDB()
	if type(SetGoFetchDB) ~= "table" then
		SetGoFetchDB = {}
	end
	local db = SetGoFetchDB

	if (tonumber(db.version) or 1) < 2 then
		-- version 0.1: db.slots[1..6] = { type, id, name, fly = { up to 8 } }
		local buttons = {}
		if type(db.slots) == "table" then
			for i = 1, ns.MAX_BUTTONS do
				local old = db.slots[i]
				local entry = { action = Normalize(old), fly = {} }
				if type(old) == "table" and type(old.fly) == "table" then
					local n = 0
					for f = 1, 8 do
						local a = Normalize(old.fly[f])
						if a and n < ns.MAX_FLY then
							n = n + 1
							entry.fly[n] = a
						end
					end
				end
				buttons[i] = entry
			end
		end
		wipe(db)
		db.buttons = buttons
		db.version = 2
	end

	if type(db.buttons) ~= "table" then
		db.buttons = {}
	end
	for i = 1, ns.MAX_BUTTONS do
		local entry = db.buttons[i]
		if type(entry) ~= "table" then
			entry = {}
			db.buttons[i] = entry
		end
		entry.action = Normalize(entry.action)
		if type(entry.fly) ~= "table" then
			entry.fly = {}
		end
		for f = 1, ns.MAX_FLY do
			entry.fly[f] = Normalize(entry.fly[f])
		end
	end
	ns.db = db

	if type(SetGoFetchLayoutDB) ~= "table" then
		SetGoFetchLayoutDB = {}
	end
	if type(SetGoFetchLayoutDB.layouts) ~= "table" then
		SetGoFetchLayoutDB.layouts = {}
	end
	ns.layoutDB = SetGoFetchLayoutDB
end

-- How the flyouts behave: one set for the whole account, edited in SetGo!.
-- (Before 0.5 these lived in each Edit Mode layout; the first layout found
-- gives the starting values.)
local BEHAVIOR = {
	hover = false,
	modifier = "NONE",
	holdMode = "OFF",
	holdDelay = 250,
	stickyClose = 6,
	mute = false,
	preview = false,
}

function ns.Behavior()
	local db = ns.layoutDB
	local b = db.behavior
	if type(b) ~= "table" then
		b = {}
		for _, old in pairs(db.layouts or {}) do
			if type(old) == "table" then
				b.hover, b.modifier = old.hover, old.modifier
				b.holdMode, b.holdDelay, b.stickyClose = old.holdMode, old.holdDelay, old.stickyClose
				if old.sounds == false then
					b.mute = true
				end
				break
			end
		end
		db.behavior = b
	end
	for key, value in pairs(BEHAVIOR) do
		if b[key] == nil then
			b[key] = value
		end
	end
	return b
end

--------------------------------------------------------------------------------
-- Slash command
--------------------------------------------------------------------------------

SLASH_SETGOFETCH1 = "/fetch"
SlashCmdList.SETGOFETCH = function(msg)
	local cmd = (msg or ""):lower():match("^%s*(%S*)")
	if cmd == "edit" then
		if InCombatLockdown() then
			print("|cffedd57fFetch!:|r " .. L.COMBAT)
			return
		end
		if EditModeManagerFrame then
			ShowUIPanel(EditModeManagerFrame)
		end
	elseif cmd == "dump" then
		ns.Dump()
	elseif cmd == "debug" then
		local layout = ns.Layout and ns.Layout()
		local behavior = ns.Behavior()
		print("|cffedd57fFetch! debug|r layout=" .. tostring(ns.ActiveLayoutName and ns.ActiveLayoutName())
			.. " stored=" .. tostring(ns.activeLayout))
		if layout then
			print(("buttons=%s orientation=%s dir=%s spacing=%s scale=%s hover=%s"):format(
				tostring(layout.numButtons), tostring(layout.orientation), tostring(layout.flyDir),
				tostring(layout.spacing), tostring(layout.scale), tostring(behavior.hover)))
		end
		local b = _G.SetGoFetchButton1
		if b then
			print("button1 type=" .. tostring(b:GetAttribute("*type1")) .. " secureclick="
				.. tostring(b:GetScript("OnClick") == SecureActionButton_OnClick))
		end
		local slots = ns.BagSlots and ns.BagSlots()
		local names = {}
		for _, slot in ipairs(slots or {}) do
			names[#names + 1] = slot:GetName() or "?"
		end
		local _, keyring = ns.FindKeyring()
		print("bagAnchor=" .. tostring(layout and layout.bagAnchor) .. " bags=" .. (#names > 0 and table.concat(names, ", ") or "none")
			.. " keyring=" .. tostring(keyring) .. " hidden=" .. tostring(ns.bagPeek == true))
		print("keyring sign=" .. tostring(ns.keySignSource))
		print("showEmpty=" .. tostring(layout and layout.showEmpty) .. " barArt=" .. tostring(layout and layout.barArt))
		print("last error=" .. tostring(ns.lastError))
	else
		print("|cffedd57fFetch!|r " .. L.HELP1)
		print("|cffedd57fFetch!|r " .. L.HELP2)
	end
end
