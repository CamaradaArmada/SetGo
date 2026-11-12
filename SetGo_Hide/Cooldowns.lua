local _, ns = ...

local L = {
	TOGGLE = "Show abilities on cooldown",
	TOGGLE_DESC = "While Hide! hides this bar (and the bars that follow it), the abilities on it that are on cooldown still show: their icon, the cooldown swipe and the charges left, right where the button is. They can't be clicked; keys still use the real buttons. The global cooldown doesn't count.",
}
if GetLocale() == "ptBR" then
	L.TOGGLE = "Mostrar habilidades em recarga"
	L.TOGGLE_DESC = "Enquanto o Hide! esconde esta barra (e as barras que a seguem), as habilidades dela que estão em recarga continuam à vista: o ícone, a espiral da recarga e as cargas que faltam, no sítio do botão. Não se clicam; as teclas continuam a usar os botões reais. A recarga global não conta."
end
ns.CooldownL = L

--------------------------------------------------------------------------------
-- Cooldown icons over hidden action bars (bars 1 to 8).
--   Over each button of a bar that Hide! is hiding right now, a frame of ours
--   (not protected, so it can show and hide in combat): the button's icon in
--   Blizzard's button frame, a cooldown swipe and the charges. It shows while the ability has a real
--   cooldown (over 2 s, so the global cooldown doesn't count, as in Fetch!) or
--   while a charge is coming back. It takes no clicks.
--   Blizzard's buttons are only read (their action slot), never changed.
--   Nothing polls: the game's cooldown and action bar events, coalesced to
--   one update per frame, and each swipe's own end. Only the bars with a
--   Hide! rule that are hidden at that moment are looked at.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- ADJUSTMENTS: the look of the cooldown icons, all in one place.
--   Sizes are in pixels on a 45 px button (Blizzard's size); they grow or
--   shrink with the button. Offsets: x positive = right, y negative = down.
--   After a change: /reload in the game.
--------------------------------------------------------------------------------
local TUNE = {
	-- the spell icon: its size and where it sits (centred, then moved)
	ICON_SIZE = 44, -- 45 = as on Blizzard's buttons
	ICON_X = 0,
	ICON_Y = -0,

	-- the rounded corners (mask): Blizzard's is 64 for a 45 icon; it grows
	-- with the icon by itself, so this rarely needs a change
	MASK_SIZE = 64,

	-- the frame: from the top left corner (its shadow comes out right and
	-- below), then moved
	FRAME_SIZE = 44, -- Blizzard's
	FRAME_X = 0,
	FRAME_Y = 0,

	-- the cooldown swipe: Blizzard's is 39 (3 px inside the icon); it grows
	-- with the icon and follows it when the icon moves
	SWIPE_SIZE = 39,

	-- the charges number: from the bottom right corner
	COUNT_X = -2,
	COUNT_Y = 2,

	-- the cooldown time written on the icon: 0 = the same font and size as
	-- on Blizzard's buttons; another number = that size
	COUNTDOWN_SIZE = 0,
}
--------------------------------------------------------------------------------

local BUTTON = 45 -- Blizzard's button, the base of all the sizes above

local BARS = {
	{ frame = "MainActionBar", alt = "MainMenuBar", button = "ActionButton" },
	{ frame = "MultiBarBottomLeft", button = "MultiBarBottomLeftButton" },
	{ frame = "MultiBarBottomRight", button = "MultiBarBottomRightButton" },
	{ frame = "MultiBarRight", button = "MultiBarRightButton" },
	{ frame = "MultiBarLeft", button = "MultiBarLeftButton" },
	{ frame = "MultiBar5", button = "MultiBar5Button" },
	{ frame = "MultiBar6", button = "MultiBar6Button" },
	{ frame = "MultiBar7", button = "MultiBar7Button" },
}
local MIN_COOLDOWN = 2 -- seconds; anything shorter is the global cooldown

-- Blizzard's action button art: the frame and the icon's mask. Without the
-- art, the plain square icon of before.
local FRAME_ATLAS = "UI-HUD-ActionBar-IconFrame"
local MASK_ATLAS = "UI-HUD-ActionBar-IconFrame-Mask"
local Fit

local function HasAtlas(atlas)
	return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) ~= nil
end

local on = false
local overlays = {} -- [Blizzard button] = our frame
local hookedBars = {}
local events = CreateFrame("Frame")
local queued = false

local function Secret(v)
	return issecretvalue and issecretvalue(v) or false
end

local function Try(func, ...)
	if type(func) ~= "function" then
		return
	end
	local ok, a, b, c, d, e = pcall(func, ...)
	if ok then
		return a, b, c, d, e
	end
end

local function BarFrame(def)
	return _G[def.frame] or (def.alt and _G[def.alt])
end

local function Buttons(def, bar)
	if type(bar.actionButtons) == "table" and #bar.actionButtons > 0 then
		return bar.actionButtons
	end
	local list = {}
	for i = 1, 12 do
		local b = _G[def.button .. i]
		if b then
			list[#list + 1] = b
		end
	end
	return list
end

-- the bar is Blizzard's to show (IsShown) but Hide! keeps it out of sight
local function Hidden(bar)
	return ns.HideManaged and ns.HideManaged(bar) and bar:IsShown() and not bar:IsVisible()
		and UIParent:IsVisible()
		-- the bar's rule (or the one of the bar it follows) has them on
		and ns.HideCooldownsFor and ns.HideCooldownsFor(bar)
end

local function Slot(button)
	local action = button.action
	if type(action) ~= "number" then
		action = Try(button.GetAttribute, button, "action")
	end
	return type(action) == "number" and action or nil
end

local Update


function Fit(ov)
	local ow, oh = ov:GetSize()
	if not ow or ow <= 0 or not oh or oh <= 0 then
		return
	end
	local sx, sy = ow / BUTTON, oh / BUTTON
	-- the icon's growth, applied to its mask and swipe too
	local grow = TUNE.ICON_SIZE / BUTTON
	ov.icon:ClearAllPoints()
	ov.icon:SetPoint("CENTER", ov, "CENTER", TUNE.ICON_X * sx, TUNE.ICON_Y * sy)
	ov.icon:SetSize(TUNE.ICON_SIZE * sx, TUNE.ICON_SIZE * sy)
	if ov.mask then
		ov.mask:ClearAllPoints()
		ov.mask:SetPoint("CENTER", ov.icon, "CENTER")
		ov.mask:SetSize(TUNE.MASK_SIZE * sx * grow, TUNE.MASK_SIZE * sy * grow)
	end
	ov.cd:ClearAllPoints()
	if ov.framed then
		ov.border:ClearAllPoints()
		ov.border:SetPoint("TOPLEFT", ov, "TOPLEFT", TUNE.FRAME_X * sx, TUNE.FRAME_Y * sy)
		ov.border:SetSize(TUNE.FRAME_SIZE * sx, TUNE.FRAME_SIZE * sy)
		ov.cd:SetPoint("CENTER", ov.icon, "CENTER")
		ov.cd:SetSize(TUNE.SWIPE_SIZE * sx * grow, TUNE.SWIPE_SIZE * sy * grow)
	else
		ov.cd:SetAllPoints(ov.icon)
	end
	-- the time written on the swipe: the font of the button's own, its size
	-- scaled to ours (read once; the button is only read)
	local text = Try(ov.cd.GetCountdownFontString, ov.cd)
	if text then
		if not ov.cdFont then
			local real = ov.button and ov.button.cooldown
			local rt = real and Try(real.GetCountdownFontString, real)
			local font, size, flags
			if rt then
				font, size, flags = Try(rt.GetFont, rt)
			end
			if not font or not size then
				font, size, flags = Try(text.GetFont, text)
			end
			if font and size then
				ov.cdFont = { font, size, flags or "" }
			end
		end
		local f = ov.cdFont
		if f then
			local size = TUNE.COUNTDOWN_SIZE > 0 and TUNE.COUNTDOWN_SIZE or f[2]
			Try(text.SetFont, text, f[1], size * sy, f[3])
		end
	end
	if not ov.count then
		return
	end
	ov.count:ClearAllPoints()
	ov.count:SetPoint("BOTTOMRIGHT", ov, "BOTTOMRIGHT", TUNE.COUNT_X * sx, TUNE.COUNT_Y * sy)
end

local function Overlay(button, def)
	local ov = overlays[button]
	if ov then
		return ov
	end
	ov = CreateFrame("Frame", nil, UIParent)
	ov:SetFrameStrata("MEDIUM")
	ov:EnableMouse(false)
	ov:SetAllPoints(button)
	ov:Hide()
	ov.icon = ov:CreateTexture(nil, "ARTWORK")
	ov.icon:SetAllPoints()
	ov.icon:SetTexCoord(0, 1, 0, 1)
	local framed = HasAtlas(FRAME_ATLAS)
	-- the button's rounded corners, as Blizzard's
	if HasAtlas(MASK_ATLAS) and ov.CreateMaskTexture then
		ov.mask = ov:CreateMaskTexture()
		ov.mask:SetAtlas(MASK_ATLAS, false)
		ov.icon:AddMaskTexture(ov.mask)
	end
	ov.cd = CreateFrame("Cooldown", nil, ov, "CooldownFrameTemplate")
	ov.cd:SetDrawEdge(false)
	-- the frame and the charges over the swipe
	ov.top = CreateFrame("Frame", nil, ov)
	ov.top:SetAllPoints()
	ov.top:SetFrameLevel(ov.cd:GetFrameLevel() + 1)
	if framed then
		ov.border = ov.top:CreateTexture(nil, "OVERLAY")
		ov.border:SetAtlas(FRAME_ATLAS, false)
	end
	ov.framed = framed
	ov.button = button
	-- the button can change size (Edit Mode): the art follows
	ov:SetScript("OnSizeChanged", Fit)
	ov.cd:SetScript("OnCooldownDone", function()
		local bar = BarFrame(def)
		Update(button, on and bar and Hidden(bar) or false, def)
	end)
	ov.count = ov.top:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	ov.count:SetPoint("BOTTOMRIGHT", -2, 2)
	overlays[button] = ov
	return ov
end

-- what to show for an action: start, duration, modRate, charges text; nil = nothing
local function State(action)
	if not action or not Try(HasAction, action) then
		return nil
	end
	local now = GetTime()
	-- a charge coming back (with charges left or not)
	local ch = C_ActionBar and Try(C_ActionBar.GetActionCharges, action)
	if type(ch) == "table" then
		local cur, max = ch.currentCharges, ch.maxCharges
		local cs, cd = ch.cooldownStartTime, ch.cooldownDuration
		if not (Secret(cur) or Secret(max) or Secret(cs) or Secret(cd))
			and type(max) == "number" and max > 1 and type(cur) == "number" and cur < max
			and type(cs) == "number" and type(cd) == "number" and cs > 0 and cs + cd > now then
			return cs, cd, ch.chargeModRate, cur
		end
	end
	-- a real cooldown
	local info = C_ActionBar and Try(C_ActionBar.GetActionCooldown, action)
	local start, duration, enabled, modRate
	if type(info) == "table" then
		start, duration, enabled, modRate = info.startTime, info.duration, info.isEnabled, info.modRate
	elseif GetActionCooldown then
		start, duration, enabled, modRate = Try(GetActionCooldown, action)
	end
	if Secret(start) or Secret(duration) then
		-- unreadable: nothing shown rather than a guess
		return nil
	end
	if Secret(enabled) or enabled == nil then
		enabled = true
	end
	if Secret(modRate) then
		modRate = nil
	end
	if enabled and enabled ~= 0 and type(start) == "number" and type(duration) == "number"
		and start > 0 and duration > MIN_COOLDOWN and start + duration > now then
		return start, duration, modRate, nil
	end
	return nil
end

function Update(button, hidden, def)
	local ov = overlays[button]
	local start, duration, modRate, charges
	-- a button the bar doesn't use (fewer buttons set in Edit Mode) is hidden
	-- by Blizzard and has no place on the screen: nothing for it
	if on and hidden and button:IsShown() then
		start, duration, modRate, charges = State(Slot(button))
	end
	if not start then
		if ov and ov:IsShown() then
			ov.cd:Clear()
			ov:Hide()
		end
		return
	end
	ov = ov or Overlay(button, def)
	ov.icon:SetTexture(Try(GetActionTexture, Slot(button)))
	if modRate then
		ov.cd:SetCooldown(start, duration, modRate)
	else
		ov.cd:SetCooldown(start, duration)
	end
	ov.count:SetText(charges and tostring(charges) or "")
	Fit(ov)
	ov:Show()
end

local function UpdateBar(def)
	local bar = BarFrame(def)
	if not bar then
		return
	end
	local hidden = on and Hidden(bar) or false
	for _, button in ipairs(Buttons(def, bar)) do
		Update(button, hidden, def)
	end
end

local function UpdateAll()
	queued = false
	for _, def in ipairs(BARS) do
		UpdateBar(def)
	end
end

-- many events can come in one frame: one update for all of them
local function Queue()
	if not queued then
		queued = true
		C_Timer.After(0, UpdateAll)
	end
end

local EVENTS = {
	"ACTIONBAR_UPDATE_COOLDOWN", "SPELL_UPDATE_COOLDOWN", "SPELL_UPDATE_CHARGES",
	"ACTIONBAR_SLOT_CHANGED", "ACTIONBAR_PAGE_CHANGED", "UPDATE_BONUS_ACTIONBAR",
	"PLAYER_ENTERING_WORLD",
}

events:SetScript("OnEvent", Queue)

-- Called by Hide.lua whenever its rules are applied, and when the option
-- changes. wanted: the option is on.
function ns.CooldownsRefresh(wanted)
	on = wanted and true or false
	for _, def in ipairs(BARS) do
		local bar = BarFrame(def)
		if bar and not hookedBars[bar] then
			hookedBars[bar] = true
			-- only listening: the bar seen or not (Hide!, Edit Mode, the cursor)
			bar:HookScript("OnShow", function()
				UpdateBar(def)
			end)
			bar:HookScript("OnHide", function()
				UpdateBar(def)
			end)
		end
	end
	for _, event in ipairs(EVENTS) do
		if on then
			pcall(events.RegisterEvent, events, event)
		else
			pcall(events.UnregisterEvent, events, event)
		end
	end
	UpdateAll()
end
