local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- The tour: Blizzard's own help tips (HelpTip, the yellow boxes with an
-- arrow the game's tutorials use), one at a time, pointing at what SetGo!
-- and its modules put on the screen. Next goes on; the last one is Got it.
-- It starts once, after the first profile is applied (when Edit Mode, which
-- opens after that reload, closes), and again from SetGo!'s page.
--
-- A module adds its own tips when it registers (SetGo.RegisterModule):
--   tour = { text = "...", frame = <frame> or function() return frame end,
--            point = "left" | "right" | "top" | "bottom" (optional) }
--   or a list of those, or a function that returns either. Only modules
--   that are on are shown. No frame (or one not on screen): the tip shows in
--   the middle of the screen, without an arrow.
--------------------------------------------------------------------------------

local SYSTEM = "SetGoTour"
local steps, index = nil, 0
local centre -- the anchor for tips without a frame

local function Resolve(v)
	if type(v) == "function" then
		local ok, r = pcall(v)
		return ok and r or nil
	end
	return v
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

-- the tips, in order: the Quick Menu's (the minimap button), then each
-- module that is on, in the list's order
local function Collect()
	local list = {}
	local button = _G.LibDBIcon10_SetGo
	list[1] = { text = L.TOUR_QUICK, frame = button }
	for _, m in ipairs(ns.KNOWN_MODULES) do
		local def = ModuleDef(m.key)
		if def and def.tour and ns.ModuleOn(m.key) then
			for _, step in ipairs(StepsOf(def.tour)) do
				list[#list + 1] = step
			end
		end
	end
	return list
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

local function Centre()
	if not centre then
		centre = CreateFrame("Frame", nil, UIParent)
		centre:SetSize(1, 1)
		centre:SetPoint("CENTER", 0, 120)
	end
	return centre
end

local ShowStep -- below

local function Finish()
	steps, index = nil, 0
	if ns.charDB then
		ns.charDB.tourPending = nil
	end
end

function ShowStep(i)
	local step = steps and steps[i]
	if not step then
		Finish()
		return
	end
	index = i
	local frame = Resolve(step.frame)
	local target, point, arrow = frame, nil, true
	if not Shown(frame) then
		target, arrow = Centre(), false
		point = "TopEdgeCenter"
	else
		point = POINTS[step.point] or POINTS[AutoPoint(frame)]
	end
	local last = i == #steps
	local info = {
		-- the text is also the tip's key: the step number keeps it unique
		text = step.text .. "\n\n|cff9d9d9d" .. L.TOUR_STEP:format(i, #steps) .. "|r",
		buttonStyle = last and HelpTip.ButtonStyle.GotIt or HelpTip.ButtonStyle.Next,
		targetPoint = HelpTip.Point[point],
		hideArrow = not arrow,
		system = SYSTEM,
		onAcknowledgeCallback = function()
			C_Timer.After(0, function()
				if steps then
					ShowStep(index + 1)
				end
			end)
		end,
	}
	Try(HelpTip.Show, HelpTip, target, info, target)
end

local function Stop()
	if HelpTip and HelpTip.HideAllSystem then
		Try(HelpTip.HideAllSystem, HelpTip, SYSTEM)
	end
	steps, index = nil, 0
end

-- the tour from its first tip (nothing to show without Blizzard's help tips)
function ns.StartTour()
	if not (HelpTip and HelpTip.Show) or InCombatLockdown() then
		return false
	end
	Stop()
	steps = Collect()
	if #steps == 0 then
		Finish()
		return false
	end
	ShowStep(1)
	return true
end

-- after the first profile's reload: once Edit Mode (which opens after it)
-- closes, else a moment after login
local function StartWhenReady()
	if not (ns.charDB and ns.charDB.tourPending) or InCombatLockdown() then
		return
	end
	local editMode = EditModeManagerFrame
	if editMode and editMode:IsShown() then
		if not editMode.setgoTourHooked then
			editMode.setgoTourHooked = true
			editMode:HookScript("OnHide", function()
				if ns.charDB and ns.charDB.tourPending then
					C_Timer.After(1, StartWhenReady)
				end
			end)
		end
		return
	end
	ns.StartTour()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		-- Edit Mode opens 1.5 s after a reload that asks for it
		C_Timer.After(3, StartWhenReady)
	elseif steps then
		-- combat: the tips go; the tour comes back on the next login
		Stop()
	end
end)
