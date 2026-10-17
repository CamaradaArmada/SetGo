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
	local target, point, arrow, align = frame, nil, true, nil
	local side
	if not Shown(frame) then
		target, arrow = Centre(), false
		point = "TopEdgeCenter"
	else
		side = POINTS[step.point] and step.point or AutoPoint(frame)
		side, align = FitSide(frame, side)
		point = POINTS[side]
	end
	local last = i == #steps
	local info = {
		-- the text is also the tip's key: the step number keeps it unique
		text = step.text .. "\n\n|cff9d9d9d" .. L.TOUR_STEP:format(i, #steps) .. "|r",
		buttonStyle = last and HelpTip.ButtonStyle.GotIt or HelpTip.ButtonStyle.Next,
		targetPoint = HelpTip.Point[point],
		alignment = align,
		-- above or under a frame: slid sideways to stay on the screen
		autoHorizontalSlide = (side == "top" or side == "bottom") or nil,
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
