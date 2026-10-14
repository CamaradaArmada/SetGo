local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- Other addons' profiles: the addons made with Ace3 keep theirs in AceDB, a
-- library they share, which lists every database it made. A profile can
-- say which profile each of those addons uses (p.aceProfiles = { [addon] =
-- profile name }); nothing listed: left as it is. Only the name goes: what
-- the addon's profile holds stays with the addon, and a name that addon
-- doesn't have here is skipped (AceDB would make an empty one).
--------------------------------------------------------------------------------

local function AceDB()
	return LibStub and LibStub("AceDB-3.0", true)
end

-- the addon a database belongs to: AceAddon's name for the addon that keeps
-- it as .db, else the name of its saved variables
local function Owners()
	local owners = {}
	local AceAddon = LibStub and LibStub("AceAddon-3.0", true)
	for name, addon in pairs(AceAddon and AceAddon.addons or {}) do
		local db = type(addon) == "table" and rawget(addon, "db")
		if type(db) == "table" and owners[db] == nil then
			owners[db] = name
		end
	end
	return owners
end

-- the global name of a saved variables table (looked for once each)
local svNames = setmetatable({}, { __mode = "k" })
local function SavedName(sv)
	if type(sv) ~= "table" then
		return nil
	end
	if svNames[sv] == nil then
		svNames[sv] = false
		for k, v in pairs(_G) do
			if v == sv and type(k) == "string" then
				svNames[sv] = k
				break
			end
		end
	end
	return svNames[sv] or nil
end

-- { { addon, db } }, by name; SetGo! and its modules left out
function ns.AceAddons()
	local lib = AceDB()
	local list = {}
	if not (lib and type(lib.db_registry) == "table") then
		return list
	end
	local owners = Owners()
	local seen = {}
	for db in pairs(lib.db_registry) do
		-- namespaces belong to their parent's profile
		if type(db) == "table" and not rawget(db, "parent") and db.SetProfile and db.GetProfiles then
			local sv = SavedName(rawget(db, "sv"))
			local name = owners[db] or sv
			if name and not name:find("^SetGo") and not seen[name] then
				seen[name] = true
				list[#list + 1] = { addon = name, db = db, sv = sv }
			end
		end
	end
	table.sort(list, function(a, b)
		return a.addon:lower() < b.addon:lower()
	end)
	return list
end

local function Find(addon)
	for _, a in ipairs(ns.AceAddons()) do
		if a.addon == addon then
			return a.db
		end
	end
end

-- the profiles an addon has here, sorted
function ns.AceProfileNames(db)
	local names = {}
	if type(db) ~= "table" then
		return names
	end
	local list = Try(db.GetProfiles, db)
	for _, name in ipairs(type(list) == "table" and list or {}) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end

local function Has(db, name)
	for _, n in ipairs(ns.AceProfileNames(db)) do
		if n == name then
			return true
		end
	end
	return false
end

-- the addons whose profile differs from the one the profile says:
-- { { addon, db, want } }; missing: the addons here without that profile
-- (an addon not here is left out)
function ns.AceDiff(p)
	local out, missing = {}, {}
	for addon, want in pairs(type(p) == "table" and p.aceProfiles or {}) do
		local db = Find(addon)
		if db and Has(db, want) then
			if Try(db.GetCurrentProfile, db) ~= want then
				out[#out + 1] = { addon = addon, db = db, want = want }
			end
		elseif db then
			-- the addon is here, that profile isn't
			missing[#missing + 1] = addon
		end
	end
	return out, missing
end

-- puts them on (live: the addons follow their own profile change)
function ns.ApplyAceProfiles(p)
	local diff, missing = ns.AceDiff(p)
	for _, d in ipairs(diff) do
		Try(d.db.SetProfile, d.db, d.want)
	end
	for _, addon in ipairs(missing) do
		ns.Print(L.MSG_ACE_MISSING:format(addon, p.aceProfiles[addon]))
	end
	return #diff
end

--------------------------------------------------------------------------------
-- Which addons are on: a profile can keep it (p.customAddons, p.addonStates =
-- { [addon folder] = true/false }), for this character, as the game's addon
-- list does. Addons it doesn't list (installed later) are left as they are.
-- SetGo! and its modules are left out (the Modules tab has them). It takes
-- a reload, as in the game's list.
--------------------------------------------------------------------------------

local function Me()
	return UnitName("player")
end

local function Plain(text)
	text = tostring(text or "")
	text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", "")
	return strtrim and strtrim(text) or text
end

local function Ours(name)
	return name == "SetGo" or name:find("^SetGo_") ~= nil
end

local function Meta(i, field)
	local get = C_AddOns.GetAddOnMetadata
	local v = get and Try(get, i, field)
	return type(v) == "string" and v ~= "" and Plain(v) or nil
end

-- { { name, title, deps = { ... }, version, author, outdated, group, icon,
--   atlas } }, by title
-- (outdated: made for an older version of the game, as the game's list
-- says)
function ns.AddonList()
	local list = {}
	if not (C_AddOns and C_AddOns.GetNumAddOns) then
		return list
	end
	for i = 1, C_AddOns.GetNumAddOns() do
		local name, title, _, _, reason = C_AddOns.GetAddOnInfo(i)
		if type(name) == "string" and not Ours(name) then
			local deps = { Try(C_AddOns.GetAddOnDependencies, i) }
			list[#list + 1] = {
				name = name, title = Plain(title ~= "" and title or name), deps = deps,
				version = Meta(i, "Version"), author = Meta(i, "Author"),
				outdated = reason == "INTERFACE_VERSION",
				-- the game's group (the main addon's name; set by the game for
				-- addons with like names and dependencies) and the icon
				group = Meta(i, "Group"), partOf = Meta(i, "X-Part-Of"),
				icon = Meta(i, "IconTexture"), atlas = Meta(i, "IconAtlas"),
			}
		end
	end
	table.sort(list, function(a, b)
		return a.title:lower() < b.title:lower()
	end)
	return list
end

function ns.AddonOn(name)
	local state = Try(C_AddOns.GetAddOnEnableState, name, Me())
	return (tonumber(state) or 0) > 0
end

-- every addon, on or off here now
function ns.AddonStates()
	local states = {}
	for _, a in ipairs(ns.AddonList()) do
		states[a.name] = ns.AddonOn(a.name)
	end
	return states
end

-- the addons the profile switches differently: { { name, on } }
function ns.AddonsDiff(p)
	local out = {}
	if not (type(p) == "table" and p.customAddons and type(p.addonStates) == "table") then
		return out
	end
	local here = {}
	for _, a in ipairs(ns.AddonList()) do
		here[a.name] = true
	end
	for name, on in pairs(p.addonStates) do
		if here[name] and ns.AddonOn(name) ~= (on and true or false) then
			out[#out + 1] = { name = name, on = on and true or false }
		end
	end
	return out
end

-- switches them (they follow on the reload); returns how many
function ns.ApplyAddonStates(p)
	local diff = ns.AddonsDiff(p)
	for _, d in ipairs(diff) do
		if d.on then
			Try(C_AddOns.EnableAddOn, d.name, Me())
		else
			Try(C_AddOns.DisableAddOn, d.name, Me())
		end
	end
	if #diff > 0 and C_AddOns.SaveAddOns then
		Try(C_AddOns.SaveAddOns)
	end
	return #diff
end

-- Which addon each Ace3 database belongs to: { [addon folder] = ace }.
-- A database is known by its AceAddon name or by its saved variables'
-- name (SpokenDB, Spoken_QuestsDB): the addon whose name (or title) it
-- starts with, the longest one (Spoken_QuestsDB goes to Spoken_Quests, not
-- to Spoken).
local function Key(s)
	return (tostring(s or ""):lower():gsub("[^%w]", ""))
end

-- how alike two keys are: the whole of b at the start of a counts most;
-- else the letters they start with in common (6 at least)
local function Score(a, b)
	if b == "" or a == "" then
		return 0
	end
	if a:sub(1, #b) == b then
		return 1000 + #b
	end
	local n = 0
	for i = 1, math.min(#a, #b) do
		if a:sub(i, i) ~= b:sub(i, i) then
			break
		end
		n = i
	end
	return n >= 6 and n or 0
end

function ns.AceMap(addons)
	local map = {}
	for _, ace in ipairs(ns.AceAddons()) do
		-- known by its AceAddon name and by its saved variables' name
		-- (AccWideUIAceAddon, AccWideUIAceDB: AccWideUILayoutSelection)
		local keys = { Key(ace.addon), Key(ace.sv) }
		local best, bestScore = nil, 0
		for _, a in ipairs(addons) do
			for _, k in ipairs(keys) do
				for _, n in ipairs({ Key(a.name), Key(a.title) }) do
					local s = Score(k, n)
					if s > bestScore then
						best, bestScore = a.name, s
					end
				end
			end
		end
		if best and not map[best] then
			map[best] = ace
		end
	end
	return map
end

function ns.AceOfAddon(name, title)
	return ns.AceMap({ { name = name, title = title } })[name]
end

-- After a reload: the Ace3 profiles of addons the profile switched on (they
-- weren't loaded when it was applied)
local pending = CreateFrame("Frame")
pending:RegisterEvent("PLAYER_ENTERING_WORLD")
pending:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	local id = ns.charDB and ns.charDB.acePending
	if not id then
		return
	end
	ns.charDB.acePending = nil
	C_Timer.After(2, function()
		local name = ns.ActivePreset and ns.ActivePreset()
		local p = name and ns.ProfileOf(name)
		if p and p.id == id and not InCombatLockdown() then
			ns.ApplyAceProfiles(p)
		end
	end)
end)
