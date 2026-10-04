local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- Key bindings, as a preset keeps them: { [key] = command }. Read and written
-- through Blizzard's own binding functions, never in combat (a preset can't
-- be applied in combat anyway).
--------------------------------------------------------------------------------

-- every key bound to a command in Blizzard's key binding list, and the
-- commands this client has
local function Current()
	local keys, commands = {}, {}
	for i = 1, GetNumBindings() do
		local binding = { GetBinding(i) }
		local command = binding[1]
		if type(command) == "string" then
			commands[command] = true
			for j = 3, #binding do
				local key = binding[j]
				if type(key) == "string" and key ~= "" then
					keys[key] = command
				end
			end
		end
	end
	return keys, commands
end

ns.CurrentKeybinds = Current

function ns.CopyKeys(keys)
	local out = {}
	for key, command in pairs(type(keys) == "table" and keys or {}) do
		out[key] = command
	end
	return out
end

-- How many keys differ between the game and a preset's keys. Keys for
-- commands this client doesn't have (an addon that isn't installed) can't
-- match, so they don't count.
function ns.KeysDiff(keys)
	if type(keys) ~= "table" then
		return 0
	end
	local current, commands = Current()
	local n = 0
	for key, command in pairs(keys) do
		if commands[command] and current[key] ~= command then
			n = n + 1
		end
	end
	for key in pairs(current) do
		if keys[key] == nil then
			n = n + 1
		end
	end
	return n
end

-- Saving a preset on a character without some addon: its keys stay in the
-- preset (not bound here, so not in the game's list), unless the key is now
-- bound to something else.
function ns.KeepUnknownKeys(old, keys)
	if type(old) ~= "table" then
		return keys
	end
	local _, commands = Current()
	for key, command in pairs(old) do
		if not commands[command] and keys[key] == nil then
			keys[key] = command
		end
	end
	return keys
end

-- The keys this character had when it logged in, or when SetGo! last put a
-- profile's keys on it. Blizzard saves the bindings whenever its Options
-- window closes, changed or not: only a save that really changed them goes
-- into the profile.
local baseline

local function Same(a, b)
	for key, command in pairs(a) do
		if b[key] ~= command then
			return false
		end
	end
	for key in pairs(b) do
		if a[key] == nil then
			return false
		end
	end
	return true
end

-- the profile's keys become this character's, as they are now
function ns.StoreKeys(p)
	local keys = Current()
	p.keys = ns.KeepUnknownKeys(p.keys, keys)
	p.keysBy = ns.CharName()
	p.keysAt = time()
	baseline = ns.CopyKeys(keys)
end

-- Replaces every binding with the preset's. Returns how many were skipped.
function ns.ApplyKeys(keys)
	if type(keys) ~= "table" or InCombatLockdown() then
		return 0
	end
	local current, commands = Current()
	for key in pairs(current) do
		SetBinding(key)
	end
	local skipped = 0
	for key, command in pairs(keys) do
		if commands[command] then
			SetBinding(key, command)
		else
			skipped = skipped + 1
		end
	end
	ns.applyingKeys = true
	SaveBindings(GetCurrentBindingSet and GetCurrentBindingSet() or 1)
	ns.applyingKeys = nil
	baseline = Current()
	if skipped > 0 then
		ns.Print(L.MSG_KEYS_SKIPPED:format(skipped))
	end
	return skipped
end

-- The player saved key bindings (Blizzard's menu, Quick Keybind Mode):
-- when they changed, they go into the profile this character uses.
local function OnSaveBindings()
	if ns.applyingKeys or not ns.db then
		return
	end
	local name = ns.ActivePreset and ns.ActivePreset()
	local p = name and ns.db.profiles[name]
	local keys = Current()
	if not baseline then
		-- before login finished: nothing to compare with yet
		baseline = keys
		return
	end
	if Same(baseline, keys) then
		return
	end
	baseline = ns.CopyKeys(keys)
	if type(p) ~= "table" or p.applyKeys == false then
		return
	end
	p.keys = ns.KeepUnknownKeys(p.keys, keys)
	p.keysBy = ns.CharName()
	p.keysAt = time()
	ns.Print(L.MSG_KEYS_IN_PRESET:format(name))
	if ns.Refresh then
		ns.Refresh()
	end
end

-- at login, once the bindings are loaded
function ns.WatchKeys()
	baseline = Current()
	if SaveBindings and hooksecurefunc and not ns.keysHooked then
		ns.keysHooked = true
		hooksecurefunc("SaveBindings", function()
			-- after the call, outside Blizzard's own code path
			C_Timer.After(0, OnSaveBindings)
		end)
	end
end
