local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- Skills: what sits on the action bars, kept per character, per profile and
-- per talent group (SetGoCharDB.skills[profile id][group] = { [slot] = entry }),
-- for a profile that keeps its own (its bars scope is profile).
-- Recorded as the player arranges them; put back when this character
-- applies the profile again or switches talent group. Only out of combat.
-- An entry: "spell:<id>", "item:<id>", "macro:<name>", "mount:<spell id>",
-- "set:<name>"; "x:..." is something SetGo! can't place (left alone).
--------------------------------------------------------------------------------

local MAX_SLOT = 180 -- bars 1 to 8 (bars 6 to 8 use pages 13 to 15)

local function Group()
	if C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup then
		return tonumber(Try(C_SpecializationInfo.GetActiveSpecGroup)) or 1
	end
	if GetActiveTalentGroup then
		return tonumber(Try(GetActiveTalentGroup)) or 1
	end
	return 1
end

local function Encode(slot)
	local kind, id, subType = GetActionInfo(slot)
	if not kind then
		return nil
	end
	if kind == "spell" and id and subType ~= "pet" then
		return "spell:" .. id
	elseif kind == "item" and id then
		return "item:" .. id
	elseif kind == "macro" then
		local name = GetActionText and GetActionText(slot)
		if name and name ~= "" then
			return "macro:" .. name
		end
	elseif kind == "summonmount" and id and C_MountJournal and C_MountJournal.GetMountInfoByID then
		local _, spellID = C_MountJournal.GetMountInfoByID(id)
		if spellID then
			return "mount:" .. spellID
		end
	elseif kind == "equipmentset" and id then
		return "set:" .. tostring(id)
	end
	return "x:" .. tostring(kind) .. ":" .. tostring(id)
end

-- puts an entry on the cursor; true when something is there
local function Pickup(entry)
	local kind, value = entry:match("^(%a+):(.*)$")
	-- the spell and item functions live in C_Spell and C_Item now; the
	-- globals only in older clients
	if kind == "spell" or kind == "mount" then
		Try((C_Spell and C_Spell.PickupSpell) or PickupSpell, tonumber(value))
	elseif kind == "item" then
		Try((C_Item and C_Item.PickupItem) or PickupItem, tonumber(value))
	elseif kind == "macro" then
		local index = GetMacroIndexByName and GetMacroIndexByName(value)
		if index and index > 0 then
			Try(PickupMacro, index)
		end
	elseif kind == "set" and C_EquipmentSet then
		local setID = Try(C_EquipmentSet.GetEquipmentSetID, value)
		if setID then
			Try(C_EquipmentSet.PickupEquipmentSet, setID)
		end
	end
	return GetCursorInfo() ~= nil
end

local function Snapshot()
	local bars, any = {}, false
	for slot = 1, MAX_SLOT do
		local entry = Encode(slot)
		if entry then
			bars[slot] = entry
			any = true
		end
	end
	return bars, any
end

local function StoreOf(p, create)
	if not (p and p.id and ns.charDB) then
		return nil
	end
	local byProfile = ns.charDB.skills[p.id]
	if not byProfile and create then
		byProfile = {}
		ns.charDB.skills[p.id] = byProfile
	end
	return byProfile
end

local function ActiveProfile()
	local name = ns.ActivePreset and ns.ActivePreset()
	local p = name and ns.db.profiles[name]
	-- Global: the bars are the player's, SetGo! leaves them alone
	if type(p) == "table" and ns.ScopeOf(p, "bars") == "profile" then
		return p
	end
end

-- After a restore the server confirms each slot a moment later; until then
-- the bars read half old, half new, so nothing is recorded meanwhile.
local quietUntil = 0

local function Now()
	return GetTime and GetTime() or 0
end

-- the bars as they are now, kept for the profile in use (talent group now)
function ns.SaveSkills()
	local p = ActiveProfile()
	if not p then
		return
	end
	-- its bars are waiting to be put back (after a reload): what shows now
	-- still belongs to the profile it left
	-- or bars copied from another profile wait for Apply: what shows now
	-- isn't them
	if ns.charDB.pendingSkills == p.id or ns.charDB.copiedSkills == p.id or Now() < quietUntil then
		return
	end
	local bars, any = Snapshot()
	if not any then
		-- still loading: empty bars would replace the real ones
		return
	end
	StoreOf(p, true)[Group()] = bars
end

-- how many slots differ from what a profile keeps here (0: nothing kept)
function ns.SkillsDiff(p)
	local byProfile = StoreOf(p)
	local stored = byProfile and byProfile[Group()]
	if not stored or ns.charDB.pendingSkills == p.id then
		return 0
	end
	local n = 0
	for slot = 1, MAX_SLOT do
		local want, have = stored[slot], Encode(slot)
		if want ~= have and not (want and want:find("^x:")) and not (have and have:find("^x:") and want == nil) then
			n = n + 1
		end
	end
	return n
end

-- Makes the bars as given (slot = entry; a slot missing is emptied).
-- Returns how many slots changed and how many could not be placed.
local function PutBars(stored)
	ns.restoringSkills = true
	ClearCursor()
	local changed, failed = 0, 0
	for slot = 1, MAX_SLOT do
		local want, have = stored[slot], Encode(slot)
		if want ~= have then
			if want == nil then
				if not have:find("^x:") then
					Try(PickupAction, slot)
					ClearCursor()
					changed = changed + 1
				end
			elseif not want:find("^x:") then
				if Pickup(want) then
					Try(PlaceAction, slot)
					changed = changed + 1
				else
					-- a spell not known here, a macro or item gone
					failed = failed + 1
				end
				ClearCursor()
			end
		end
	end
	ns.restoringSkills = nil
	if changed > 0 then
		-- recorded again once the server has confirmed them
		quietUntil = Now() + 3
		C_Timer.After(3.5, function()
			ns.SaveSkills()
		end)
	end
	if failed > 0 then
		ns.Print(L.MSG_SKILLS_FAILED:format(failed))
	end
	return changed, failed
end

-- Puts back what a profile keeps for this talent group. Nothing kept yet:
-- the bars as they are now become its own. Returns how many slots changed.
function ns.RestoreSkills(p)
	if InCombatLockdown() then
		return 0
	end
	local byProfile = StoreOf(p, true)
	local group = Group()
	local stored = byProfile and byProfile[group]
	if not stored then
		local bars, any = Snapshot()
		if any and byProfile then
			byProfile[group] = bars
		end
		return 0
	end
	local changed = PutBars(stored)
	if changed > 0 then
		ns.Print(L.MSG_SKILLS_RESTORED:format(changed))
	end
	return changed
end

-- Applying a profile: its bars are put back at once, and checked again
-- after the reload that follows (or a moment later, when nothing reloads):
-- a slot the server didn't take is put back then. Until that check, nothing
-- records over the profile's bars.
function ns.QueueSkills(p)
	ns.charDB.pendingSkills = p and p.id or nil
end

local pendingResume = false

function ns.ResumeSkills()
	local id = ns.charDB and ns.charDB.pendingSkills
	if not id then
		return
	end
	if InCombatLockdown() then
		pendingResume = true
		return
	end
	pendingResume = false
	ns.charDB.pendingSkills = nil
	local p = ActiveProfile()
	if p and p.id == id then
		ns.RestoreSkills(p)
		if ns.Refresh then
			ns.Refresh()
		end
	end
end

--------------------------------------------------------------------------------
-- Recording
--------------------------------------------------------------------------------

local ready = false -- after login (or a reload) settles
local paused = false -- a talent group switch is being handled
local token = 0
local pendingSwitch = false

local function SaveSoon()
	token = token + 1
	local mine = token
	C_Timer.After(1, function()
		if mine == token and ready and not paused and not ns.restoringSkills then
			ns.SaveSkills()
		end
	end)
end

-- a new talent group: its own bars back (or the ones it has now, kept)
local function OnSwitched()
	if InCombatLockdown() then
		pendingSwitch = true
		return
	end
	pendingSwitch = false
	local p = ActiveProfile()
	if p then
		ns.RestoreSkills(p)
	end
	paused = false
	if ns.Refresh then
		ns.Refresh()
	end
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("PLAYER_LOGOUT")
watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
pcall(watcher.RegisterEvent, watcher, "ACTIONBAR_SLOT_CHANGED")
pcall(watcher.RegisterEvent, watcher, "ACTIVE_TALENT_GROUP_CHANGED")
watcher:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		if ns.OpenEditModeAfterReload then
			ns.OpenEditModeAfterReload()
		end
		-- a login or a reload (applying a profile reloads)
		if not ready then
			-- whatever the reload left behind, put back at once; recording
			-- starts once the bars have settled
			C_Timer.After(1, ns.ResumeSkills)
			C_Timer.After(5, function()
				ready = true
			end)
		end
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		if ready and not paused and not ns.restoringSkills then
			SaveSoon()
		end
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		paused = true
		token = token + 1 -- a save waiting would go to the wrong group
		C_Timer.After(1.5, OnSwitched)
	elseif event == "PLAYER_REGEN_ENABLED" then
		if pendingSwitch then
			OnSwitched()
		end
		if pendingResume then
			ns.ResumeSkills()
		end
	elseif event == "PLAYER_LOGOUT" then
		if ready and not paused then
			ns.SaveSkills()
		end
	end
end)
