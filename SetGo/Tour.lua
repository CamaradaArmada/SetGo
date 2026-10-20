local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- Blizzard's own help tips (HelpTip, the yellow boxes with an arrow the
-- game's tutorials use), in three places:
--   The guide: the first profile, made on the form itself. Each tip waits
--     for what it points at; a tip on a button goes when it is clicked, the
--     others have Next. The X stops the guide. It starts the first time
--     SetGo! opens with no profile, and from Show the tour (SetGo!'s page).
--   After the first profile is applied: the minimap button's tip.
--   A module's tips, once, the first time it is on (after the first
--     profile). A module adds them when it registers:
--       tour = { text = "...", frame = <frame> or function() return frame end,
--                point = "left" | "right" | "top" | "bottom" (optional),
--                wait = function() return <frame shown> end (optional: the
--                tip waits until it returns a frame on screen) }
--       or a list of those. No frame (or one not on screen): the tip shows
--       in the middle of the screen, without an arrow.
--------------------------------------------------------------------------------

local SYSTEM = "SetGoTour"
local GUIDE = "SetGoGuide"
local centre -- the anchor for tips without a frame

local function Resolve(v)
	if type(v) == "function" then
		local ok, r = pcall(v)
		return ok and r or nil
	end
	return v
end

local function Shown(frame)
	return type(frame) == "table" and frame.IsVisible and Try(frame.IsVisible, frame) == true
end

-- where the tip goes: the side of the frame with room on the screen
local POINTS = {
	left = "LeftEdgeCenter", right = "RightEdgeCenter",
	top = "TopEdgeCenter", bottom = "BottomEdgeCenter",
}

local function AutoPoint(frame)
	local x, y = Try(frame.GetCenter, frame)
	local w, h = UIParent:GetWidth(), UIParent:GetHeight()
	if not (x and y and w and h) then
		return "right"
	end
	local fw = Try(frame.GetWidth, frame) or 0
	if fw > w * 0.3 then
		-- wide (a bar): above it or under it
		return y < h / 2 and "top" or "bottom"
	end
	return x > w / 2 and "left" or "right"
end

-- the room around a frame, in UIParent's units: left, right, below, above,
-- and its middle (nil when it isn't placed)
local TIP_W, TIP_H = 330, 170 -- about a tip's size, with its button
local function Room(frame)
	local l, r = Try(frame.GetLeft, frame), Try(frame.GetRight, frame)
	local t, b = Try(frame.GetTop, frame), Try(frame.GetBottom, frame)
	local w, h = UIParent:GetWidth(), UIParent:GetHeight()
	if not (l and r and t and b and w and h) then
		return nil
	end
	local k = (Try(frame.GetEffectiveScale, frame) or 1) / (UIParent:GetEffectiveScale() or 1)
	l, r, t, b = l * k, r * k, t * k, b * k
	return { left = l, right = w - r, below = b, above = h - t, midY = (t + b) / 2, h = h }
end

local OPPOSITE = { left = "right", right = "left", top = "bottom", bottom = "top" }

-- the side asked for (or worked out), unless the tip wouldn't fit there:
-- then the other side; at the left or right of a frame near the bottom
-- (or top) of the screen, the tip goes up (or down) from the arrow, so its
-- button stays on the screen. Returns the side and the alignment.
local function FitSide(frame, side)
	local room = Room(frame)
	if not room then
		return side, nil
	end
	local function Fits(s)
		if s == "bottom" then
			return room.below >= TIP_H
		elseif s == "top" then
			return room.above >= TIP_H
		elseif s == "left" then
			return room.left >= TIP_W
		end
		return room.right >= TIP_W
	end
	if not Fits(side) and Fits(OPPOSITE[side]) then
		side = OPPOSITE[side]
	end
	local align
	if side == "left" or side == "right" then
		if room.midY - TIP_H / 2 < 0 then
			align = HelpTip.Alignment.Bottom
		elseif room.midY + TIP_H / 2 > room.h then
			align = HelpTip.Alignment.Top
		end
	end
	return side, align
end

local function Centre()
	if not centre then
		centre = CreateFrame("Frame", nil, UIParent)
		centre:SetSize(1, 1)
		centre:SetPoint("CENTER", 0, 120)
	end
	return centre
end

-- One tip at a frame (no frame on screen: the middle, no arrow).
-- opts: { button = "next" | "gotit" | "close", step, of, onDone, onClose,
-- system }
local function ShowTip(frame, text, point, opts)
	local target, tpoint, arrow, align, side = frame, nil, true, nil, nil
	if not Shown(frame) then
		target, arrow = Centre(), false
		tpoint = "TopEdgeCenter"
	else
		side = POINTS[point] and point or AutoPoint(frame)
		side, align = FitSide(frame, side)
		tpoint = POINTS[side]
	end
	local style = HelpTip.ButtonStyle.Next
	if opts.button == "gotit" then
		style = HelpTip.ButtonStyle.GotIt
	elseif opts.button == "close" then
		style = HelpTip.ButtonStyle.Close
	end
	if opts.step then
		-- the step number also keeps the text (the tip's key) unique
		text = text .. "\n\n|cff9d9d9d" .. L.TOUR_STEP:format(opts.step, opts.of) .. "|r"
	end
	local info = {
		text = text,
		buttonStyle = style,
		targetPoint = HelpTip.Point[tpoint],
		alignment = align,
		-- above or under a frame: slid sideways to stay on the screen
		autoHorizontalSlide = (side == "top" or side == "bottom") or nil,
		hideArrow = not arrow,
		-- over everything in the window it points into (its buttons too)
		useParentStrata = true,
		system = opts.system or SYSTEM,
		onAcknowledgeCallback = function()
			C_Timer.After(0, function()
				if opts.button == "close" then
					if opts.onClose then
						opts.onClose()
					end
				elseif opts.onDone then
					opts.onDone()
				end
			end)
		end,
	}
	Try(HelpTip.Show, HelpTip, target, info, target)
end

local function HideSystem(system)
	if HelpTip and HelpTip.HideAllSystem then
		Try(HelpTip.HideAllSystem, HelpTip, system)
	end
end

local function CanShow()
	return HelpTip and HelpTip.Show and not InCombatLockdown()
end

--------------------------------------------------------------------------------
-- Tips one after another: the minimap button's, then the modules'
--------------------------------------------------------------------------------

local queue, playing, waiter = {}, false, nil

local function StopQueue()
	HideSystem(SYSTEM)
	if waiter then
		waiter:Cancel()
		waiter = nil
	end
	wipe(queue)
	playing = false
end

local PlayNext -- below

local function ShowQueued(step)
	local last = #queue == 0
	ShowTip(Resolve(step.frame), step.text, step.point, {
		button = last and "gotit" or "next",
		onDone = function()
			if step.onDone then
				step.onDone()
			end
			PlayNext()
		end,
	})
end

function PlayNext()
	local step = table.remove(queue, 1)
	if not step then
		playing = false
		return
	end
	playing = true
	if not step.wait then
		ShowQueued(step)
		return
	end
	-- waits for its frame (a flyout opened, say)
	local ticker
	ticker = C_Timer.NewTicker(0.5, function()
		local frame = Resolve(step.wait)
		if Shown(frame) then
			ticker:Cancel()
			waiter = nil
			step.frame = frame
			ShowQueued(step)
		end
	end)
	waiter = ticker
end

local function Play(list)
	if not CanShow() or #list == 0 then
		return false
	end
	for _, step in ipairs(list) do
		queue[#queue + 1] = step
	end
	if not playing then
		PlayNext()
	end
	return true
end

-- one step, or a list of steps, as a list
local function StepsOf(tour)
	tour = Resolve(tour)
	if type(tour) ~= "table" then
		return {}
	end
	if tour.text then
		return { tour }
	end
	local list = {}
	for _, step in ipairs(tour) do
		if type(step) == "table" and step.text then
			list[#list + 1] = step
		end
	end
	return list
end

local function ModuleDef(key)
	for _, def in ipairs(ns.modules or {}) do
		if def.key == key then
			return def
		end
	end
end

-- the modules that are on and haven't shown their tips yet (once there is
-- a profile)
local function ModuleTips()
	local list = {}
	if #ns.ProfileSlots() == 0 then
		return list
	end
	ns.db.tourSeen = ns.db.tourSeen or {}
	for _, m in ipairs(ns.KNOWN_MODULES) do
		local def = ModuleDef(m.key)
		if def and def.tour and ns.ModuleOn(m.key) and not ns.db.tourSeen[m.key] then
			local steps = StepsOf(def.tour)
			if #steps > 0 then
				local key = m.key
				-- seen once its last tip is
				local copy = {}
				for i, step in ipairs(steps) do
					copy[i] = setmetatable({}, { __index = step })
				end
				copy[#copy].onDone = function()
					ns.db.tourSeen[key] = true
				end
				for _, step in ipairs(copy) do
					list[#list + 1] = step
				end
			end
		end
	end
	return list
end

-- After the first profile (its reload, then Edit Mode closing, if it
-- opens): the minimap button's tip, then the modules'
function ns.TourAfterFirst()
	if not (ns.charDB and ns.charDB.tourPending) or not CanShow() then
		return
	end
	local editMode = EditModeManagerFrame
	if editMode and editMode:IsShown() then
		if not editMode.setgoTourHooked then
			editMode.setgoTourHooked = true
			editMode:HookScript("OnHide", function()
				if ns.charDB and ns.charDB.tourPending then
					C_Timer.After(1, ns.TourAfterFirst)
				end
			end)
		end
		return
	end
	ns.charDB.tourPending = nil
	local list = { { text = L.TOUR_QUICK, frame = _G.LibDBIcon10_SetGo } }
	for _, step in ipairs(ModuleTips()) do
		list[#list + 1] = step
	end
	Play(list)
end

local function AfterLogin()
	if ns.charDB and ns.charDB.tourPending then
		ns.TourAfterFirst()
	elseif not playing then
		Play(ModuleTips())
	end
end

--------------------------------------------------------------------------------
-- The guide: the first profile, on the form
--------------------------------------------------------------------------------

local guide -- { i = step, shown = step shown }

local function Form()
	return ns.FormFrames and ns.FormFrames() or {}
end

local function OnForm()
	return ns.creating ~= nil and ns.form and ns.form.layout ~= nil
end

local function Choosing()
	return OnForm() and not ns.creating.edit and ns.form.choosing
end

local function OnTab(tab)
	return OnForm() and not ns.creating.edit and not ns.form.choosing and ns.form.tab == tab
end

local function HasAddonsTab()
	for _, tab in ipairs(ns.FormTabs and ns.FormTabs() or {}) do
		if tab == "addons" then
			return true
		end
	end
	return false
end

-- kind: "click" (the tip goes when done() is true; X stops the guide) or
-- "info" (Next)
local STEPS = {
	{ text = "GUIDE_SLOT", kind = "click", point = "right",
		at = function() return ns.creating == nil or ns.creating.edit ~= nil end,
		frame = function() return ns.NewProfileSlot and ns.NewProfileSlot() end,
		done = Choosing },
	{ text = "GUIDE_PRESETS", kind = "click", point = "left", at = Choosing,
		frame = function() return Form().customize end,
		done = function() return OnTab("layout") end },
	{ text = "GUIDE_NAME", kind = "info", point = "bottom", at = function() return OnTab("layout") end,
		frame = function() return Form().name end },
	{ text = "GUIDE_LAYOUT", kind = "info", point = "left", at = function() return OnTab("layout") end,
		frame = function() return Form().layout end },
	{ text = "GUIDE_BARS", kind = "info", point = "left", at = function() return OnTab("layout") end,
		frame = function() return Form().bars end },
	{ text = "GUIDE_FRAMES", kind = "info", point = "left", at = function() return OnTab("layout") end,
		frame = function() return Form().frames end },
	{ text = "GUIDE_TO_SETTINGS", kind = "click", point = "bottom", at = function() return OnTab("layout") end,
		frame = function() return Form().next end,
		done = function() return OnTab("settings") end },
	{ text = "GUIDE_SETTINGS", kind = "info", point = "left", at = function() return OnTab("settings") end,
		frame = function() return Form().settings end },
	{ text = "GUIDE_TO_MODULES", kind = "click", point = "bottom", at = function() return OnTab("settings") end,
		frame = function() return Form().next end,
		done = function() return OnTab("modules") end },
	{ text = "GUIDE_MODULES", kind = "info", point = "left", at = function() return OnTab("modules") end,
		frame = function() return Form().modules end },
	{ text = "GUIDE_TO_ADDONS", kind = "click", point = "bottom", addons = true,
		at = function() return OnTab("modules") end,
		frame = function() return Form().next end,
		done = function() return OnTab("addons") end },
	{ text = "GUIDE_ADDONS", kind = "info", point = "left", addons = true,
		at = function() return OnTab("addons") end,
		frame = function() return Form().addons end },
}

local function GuideSteps()
	local list = {}
	local addons = HasAddonsTab()
	for _, step in ipairs(STEPS) do
		if addons or not step.addons then
			list[#list + 1] = step
		end
	end
	return list
end

local function StopGuide()
	guide = nil
	HideSystem(GUIDE)
end

local function GuideShow()
	local steps = GuideSteps()
	local step = steps[guide.i]
	if not step then
		StopGuide()
		return
	end
	if guide.shown == guide.i then
		return
	end
	-- not where it points yet (the form on another tab, say): later
	if not step.at() then
		return
	end
	local frame = Resolve(step.frame)
	if not Shown(frame) then
		return
	end
	HideSystem(GUIDE)
	guide.shown = guide.i
	local last = guide.i == #steps
	ShowTip(frame, L[step.text], step.point, {
		system = GUIDE,
		step = guide.i, of = #steps,
		button = step.kind == "click" and "close" or (last and "gotit" or "next"),
		onDone = function()
			if guide and guide.shown == guide.i then
				guide.i, guide.shown = guide.i + 1, nil
				ns.GuideUpdate()
			end
		end,
		onClose = StopGuide,
	})
end

-- after every refresh of the window: the step done goes on; the form left
-- (or the window closed) ends it
function ns.GuideUpdate()
	if not guide then
		return
	end
	if not CanShow() then
		StopGuide()
		return
	end
	local frame = _G.SetGoFrame
	if not (frame and frame:IsShown()) then
		StopGuide()
		return
	end
	local steps = GuideSteps()
	-- steps already done (or the first one, when the presets menu is open
	-- already) go by
	while steps[guide.i] do
		local step = steps[guide.i]
		if step.kind == "click" and step.done and step.done() then
			guide.i, guide.shown = guide.i + 1, nil
		elseif guide.i == 1 and not step.at() and Choosing() then
			guide.i, guide.shown = 2, nil
		else
			break
		end
	end
	-- past the presets menu, a new profile no longer on the form: made (Apply)
	-- or left
	if guide.i >= 2 and not (OnForm() and not ns.creating.edit) then
		StopGuide()
		return
	end
	GuideShow()
end

-- From the start: SetGo! on Profiles (the presets menu when there is no
-- profile yet)
function ns.StartGuide()
	if not CanShow() then
		ns.Print(L.MSG_TOUR_NONE)
		return false
	end
	if ns.ProfilesFull() then
		ns.Print(L.MSG_GUIDE_FULL)
		return false
	end
	StopQueue()
	ns.db.guideSeen = true
	ns.Open()
	ns.LeaveForm()
	if ns.SelectTab then
		ns.SelectTab("presets")
	end
	guide = { i = 1 }
	ns.GuideUpdate()
	return true
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		-- Edit Mode opens 1.5 s after a reload that asks for it
		C_Timer.After(3, AfterLogin)
	else
		-- combat: the tips go (the modules' come back on the next login)
		StopQueue()
		StopGuide()
	end
end)
