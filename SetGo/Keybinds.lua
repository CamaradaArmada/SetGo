local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- Key bindings, as a preset keeps them: { [key] = command }. Read and written
-- through Blizzard's own binding functions, never in combat (a preset can't
-- be applied in combat anyway).
--------------------------------------------------------------------------------

-- Keys addons bind to their own buttons (CLICK Button:LeftButton: Bartender,
-- Dominos) aren't in Blizzard's list: looked for key by key, with each
-- modifier
local KEYS
local function AllKeys()
	if KEYS then
		return KEYS
	end
	local base = {}
	for c in ("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):gmatch(".") do
		base[#base + 1] = c
	end
	for i = 1, 12 do
		base[#base + 1] = "F" .. i
	end
	for i = 0, 9 do
		base[#base + 1] = "NUMPAD" .. i
	end
	for i = 3, 15 do
		base[#base + 1] = "BUTTON" .. i
	end
	for _, k in ipairs({ "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS", "NUMPADPLUS", "NUMPADDECIMAL",
		"`", "-", "=", "[", "]", "\\", ";", "'", ",", ".", "/", "TAB", "SPACE", "ENTER", "BACKSPACE",
		"INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN", "UP", "DOWN", "LEFT", "RIGHT",
		"MOUSEWHEELUP", "MOUSEWHEELDOWN", "CAPSLOCK" }) do
		base[#base + 1] = k
	end
	KEYS = {}
	for _, mod in ipairs({ "", "SHIFT-", "CTRL-", "ALT-", "CTRL-SHIFT-", "ALT-SHIFT-", "ALT-CTRL-", "ALT-CTRL-SHIFT-" }) do
		for _, k in ipairs(base) do
			KEYS[#KEYS + 1] = mod .. k
		end
	end
	return KEYS
end

-- an addon's command: a click on one of its buttons, or one it declared
-- (the AddOns part of Blizzard's list; its name is the addon's, not one of
-- Blizzard's own strings)
local function IsAddonCommand(command, category)
	if type(command) ~= "string" then
		return false
	end
	if command:find("^CLICK ") or category == "ADDONS" then
		return true
	end
	local var = "BINDING_NAME_" .. command
	return _G[var] ~= nil and issecurevariable and not issecurevariable(var) or false
end

-- every key bound to a command in Blizzard's key binding list (and to an
-- addon's button), the commands this client has, and which are addons'
local function Current()
	local keys, commands, addon = {}, {}, {}
	for i = 1, GetNumBindings() do
		local binding = { GetBinding(i) }
		local command = binding[1]
		if type(command) == "string" then
			commands[command] = true
			if IsAddonCommand(command, binding[2]) then
				addon[command] = true
			end
			for j = 3, #binding do
				local key = binding[j]
				if type(key) == "string" and key ~= "" then
					keys[key] = command
				end
			end
		end
	end
	if GetBindingAction then
		for _, key in ipairs(AllKeys()) do
			local action = keys[key] == nil and GetBindingAction(key)
			if type(action) == "string" and action:find("^CLICK ") then
				keys[key] = action
				commands[action] = true
				addon[action] = true
			end
		end
	end
	return keys, commands, addon
end

-- a command this client can bind: in Blizzard's list, or a click on a button
-- that is there
local function Known(command, commands)
	if commands[command] then
		return true
	end
	local button = type(command) == "string" and command:match("^CLICK ([^:]+)")
	return button ~= nil and _G[button] ~= nil
end

local function IsClick(command)
	return type(command) == "string" and command:find("^CLICK ") ~= nil
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
		if Known(command, commands) and current[key] ~= command then
			n = n + 1
		end
	end
	-- an addon's button keys the set doesn't hold (saved before they were
	-- read) are left as they are
	for key, command in pairs(current) do
		if keys[key] == nil and not IsClick(command) then
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
		if not Known(command, commands) and keys[key] == nil then
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

-- a set of keys (a profile's own, or the shared one) becomes this
-- character's, as they are now
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
	for key, command in pairs(current) do
		-- an addon's button keys stay unless the set says otherwise
		if not IsClick(command) or keys[key] ~= nil then
			SetBinding(key)
		end
	end
	local skipped = 0
	for key, command in pairs(keys) do
		if Known(command, commands) then
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

-- Key bindings saved: what changed goes into the set the profile in use
-- takes its keys from (its own, or the shared one). Only the changes: a key
-- changed on another character using the shared set stays. Saved from
-- Blizzard's menus (Key Bindings, Quick Keybind Mode): every change. Saved
-- by another addon (its own menu): only its own keys (its buttons, its
-- commands), not Blizzard's.
local function OnSaveBindings(byAddon)
	if ns.applyingKeys or not ns.db then
		return
	end
	local name = ns.ActivePreset and ns.ActivePreset()
	local p = name and ns.db.profiles[name]
	local keys, _, addon = Current()
	if not baseline then
		-- before login finished: nothing to compare with yet
		baseline = keys
		return
	end
	if Same(baseline, keys) then
		return
	end
	local before = baseline
	baseline = ns.CopyKeys(keys)
	if type(p) ~= "table" then
		return
	end
	local function Counts(key)
		return not byAddon or addon[keys[key]] or addon[before[key]] or IsClick(before[key])
	end
	local any = false
	for key, command in pairs(keys) do
		if before[key] ~= command and Counts(key) then
			any = true
		end
	end
	for key in pairs(before) do
		if keys[key] == nil and Counts(key) then
			any = true
		end
	end
	if not any then
		return
	end
	local holder = ns.KeysHolder(p)
	if type(holder.keys) ~= "table" then
		holder.keys = ns.CopyKeys(keys)
	else
		for key, command in pairs(keys) do
			if before[key] ~= command and Counts(key) then
				holder.keys[key] = command
			end
		end
		for key in pairs(before) do
			if keys[key] == nil and Counts(key) then
				holder.keys[key] = nil
			end
		end
	end
	holder.keysBy = ns.CharName()
	holder.keysAt = time()
	ns.Print((holder == p and L.MSG_KEYS_IN_PRESET or L.MSG_KEYS_SHARED):format(name))
	if ns.Refresh then
		ns.Refresh()
	end
end

-- the first addon file in the call stack that isn't SetGo!'s: one of
-- Blizzard's (Blizzard_...) or another addon's
function ns.SavedByAddon()
	local stack = debugstack and debugstack(2) or ""
	for folder in stack:gmatch("Interface[/\\]AddOns[/\\]([^/\\]+)") do
		if folder ~= "SetGo" then
			return folder:find("^Blizzard_") == nil
		end
	end
	return false
end

-- at login, once the bindings are loaded
function ns.WatchKeys()
	baseline = Current()
	if ns.db and ns.db.shared and not ns.db.shared.keys then
		ns.StoreKeys(ns.db.shared)
	end
	if SaveBindings and hooksecurefunc and not ns.keysHooked then
		ns.keysHooked = true
		hooksecurefunc("SaveBindings", function()
			-- who saved: Blizzard's code, or another addon's
			local byAddon = ns.SavedByAddon()
			-- after the call, outside Blizzard's own code path
			C_Timer.After(0, function()
				OnSaveBindings(byAddon)
			end)
		end)
	end
end
