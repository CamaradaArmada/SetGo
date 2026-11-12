local ADDON, ns = ...
local L = ns.L

-- Slash commands (the minimap button and its menu are in Minimap.lua)
SLASH_SETGO1 = "/setgo"
SLASH_SETGO2 = "/sgo"
SlashCmdList.SETGO = function(msg)
	local raw = strtrim(msg or "")
	msg = raw:lower()
	if msg == "tour" then
		-- the minimap button's and the modules' tips (Tour.lua)
		ns.PlayTour()
	else
		ns.Toggle()
	end
end

-- Entry in Options > AddOns with a button that opens the window
local function RegisterOptionsEntry()
	if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then
		return
	end
	local panel = CreateFrame("Frame")
	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(L.ADDON)
	local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
	desc:SetWidth(520)
	desc:SetJustifyH("LEFT")
	desc:SetText(L.PANEL_DESC)
	local button = ns.Widgets.Button(panel, 200, L.OPEN, function()
		if SettingsPanel and SettingsPanel:IsShown() then
			HideUIPanel(SettingsPanel)
		end
		ns.Open(true)
	end)
	button:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
	local category = Settings.RegisterCanvasLayoutCategory(panel, L.ADDON)
	Settings.RegisterAddOnCategory(category)
end

-- Once per character (a new one, or every character after installing):
-- the welcome, when the game's settings are ready. Not during the intro
-- movie or a cinematic (the interface is hidden then), nor in combat: it
-- waits for them to end, and only counts as seen once it is on screen.
-- A character without a profile in use gets one, nothing applied (nothing
-- changes in the game): on an account without profiles, one of the game as
-- it is now, named after the character; else the favourite (or the first),
-- only marked as in use
local function AutoProfile()
	if ns.ActivePreset() then
		return
	end
	local names = ns.ProfileSlots()
	local name
	if #names == 0 then
		local opts = ns.PresetOpts(ns.CurrentPreset())
		if not opts then
			return
		end
		local base = UnitName("player") or opts.name
		name = base
		local n = 2
		while ns.ProfileOf(name) do
			name = base .. " " .. n
			n = n + 1
		end
		opts.name = name
		opts.noApply = true
		if not ns.CreateProfile(opts) then
			return
		end
		-- the tweaks kept without a profile go with it
		local p = ns.ProfileOf(name)
		local key = p and (p.id or name)
		if key and type(ns.db.tweaks) == "table" and ns.db.tweaks.none and not ns.db.tweaks[key] then
			ns.db.tweaks[key] = ns.db.tweaks.none
		end
		ns.charDB.tourPending = true
		C_Timer.After(3, function()
			ns.Try(ns.TourAfterFirst)
		end)
	else
		for _, n in ipairs(names) do
			local p = ns.ProfileOf(n)
			if not name and p and p.favorite then
				name = n
			end
		end
		name = name or names[1]
	end
	ns.charDB.profile = name
	if ns.ApplyTweaks then
		ns.Try(ns.ApplyTweaks)
	end
	if ns.Refresh then
		ns.Try(ns.Refresh)
	end
end

local pending = false
local retries = 0
local waiter = CreateFrame("Frame")

local function Blocked()
	if InCombatLockdown() then
		return true
	end
	if InCinematic and InCinematic() then
		return true
	end
	if MovieFrame and MovieFrame:IsShown() then
		return true
	end
	return not UIParent:IsVisible()
end

local function TryShow()
	if not pending then
		return
	end
	if Blocked() then
		-- the events below try again; a few quiet retries cover the moment
		-- the interface takes to come back after them
		retries = retries + 1
		if retries <= 10 then
			C_Timer.After(3, TryShow)
		end
		return
	end
	pending = false
	waiter:UnregisterAllEvents()
	ns.Try(AutoProfile)
end

waiter:SetScript("OnEvent", function()
	-- let the game finish putting the interface back first
	retries = 0
	C_Timer.After(2, TryShow)
end)

local function FirstTimePopup()
	if pending or ns.ActivePreset() then
		return
	end
	pending = true
	for _, event in ipairs({ "CINEMATIC_STOP", "STOP_MOVIE", "PLAYER_REGEN_ENABLED" }) do
		pcall(waiter.RegisterEvent, waiter, event)
	end
	C_Timer.After(2, TryShow)
end

-- the settings as they are now, to record what the player changes in
-- Blizzard's Options window (once, when the game's settings are ready)
local settingsWatched = false
local function WatchSettings()
	if not settingsWatched and ns.db then
		settingsWatched = ns.Try(ns.WatchSettings) == true
	end
end

local watching = false
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LOGIN")
if not C_EventUtils or not C_EventUtils.IsEventValid or C_EventUtils.IsEventValid("SETTINGS_LOADED") then
	pcall(events.RegisterEvent, events, "SETTINGS_LOADED")
end
events:SetScript("OnEvent", function(self, event, arg1, arg2)
	if event == "ADDON_LOADED" and arg1 == ADDON then
		ns.InitDB()
		ns.Try(ns.RetireQuickModule)
		ns.Try(RegisterOptionsEntry)
		ns.Try(ns.SetupMinimapButton)
	elseif event == "PLAYER_LOGIN" then
		ns.Try(ns.SetupModules)
	elseif event == "SETTINGS_LOADED" then
		WatchSettings()
		FirstTimePopup()
	elseif event == "PLAYER_ENTERING_WORLD" and not watching then
		-- the keys as they are now, to tell a real change from Blizzard
		-- saving them unchanged
		watching = true
		ns.Try(ns.WatchKeys)
		if arg1 then
			ns.Try(ns.ReapplyAccountUI)
		end
	end
	if event == "PLAYER_ENTERING_WORLD" and (arg1 or arg2) then
		-- fallback if the settings event never comes (at login and after a
		-- reload)
		C_Timer.After(5, function()
			WatchSettings()
			if ns.SettingsReady() then
				FirstTimePopup()
			end
		end)
	end
end)
