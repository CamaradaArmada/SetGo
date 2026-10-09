local ADDON, ns = ...

local mains = {}
ns.mains = mains
local bar

local PAD = 0 -- inner padding of the flyout (none: the art frames the buttons, as on bar 1)
local STRIP_SCALE = 0.9
local STRIP_ALPHA = 0.85

-- Where a flyout (and the cooldown strip) grows from its main button.
local DIRS = {
	UP = { point = "BOTTOM", rel = "TOP", dx = 0, dy = 1 },
	DOWN = { point = "TOP", rel = "BOTTOM", dx = 0, dy = -1 },
	LEFT = { point = "RIGHT", rel = "LEFT", dx = -1, dy = 0 },
	RIGHT = { point = "LEFT", rel = "RIGHT", dx = 1, dy = 0 },
}

local function Entry(i)
	return ns.db.buttons[i]
end

local function HasFlyContent(i)
	local fly = Entry(i).fly
	for f = 1, ns.MAX_FLY do
		if fly[f] then
			return true
		end
	end
	return false
end
ns.HasFlyContent = HasFlyContent

--------------------------------------------------------------------------------
-- Native flyout arrow (inherited from Blizzard's flyout button template)
--------------------------------------------------------------------------------

local ARROW = {
	UP = { "TOP", 0, 1, 0 },
	DOWN = { "BOTTOM", 0, -1, 180 },
	LEFT = { "LEFT", -1, 0, 270 },
	RIGHT = { "RIGHT", 1, 0, 90 },
}

-- Out of combat only: it changes only when content, layout or open state do.
function ns.UpdateArrow(main)
	local arrow = main.Arrow
	if not arrow or InCombatLockdown() then
		return
	end
	local has = HasFlyContent(main.fpIndex) and main:IsShown()
	arrow:SetShown(has)
	local open = main.fpFlyout:IsShown()
	if main.BorderShadow then
		main.BorderShadow:SetShown(has and open)
	end
	if not has then
		return
	end
	local a = ARROW[ns.FlyDir(ns.Layout())]
	local offset = open and (main.openArrowOffset or 3) or (main.closedArrowOffset or 5)
	arrow:SetSize(main.arrowMainAxisSize or 15, main.arrowCrossAxisSize or 6)
	arrow:ClearAllPoints()
	arrow:SetPoint(a[1], main, a[1], a[2] * offset, a[3] * offset)
	arrow:SetAtlas(main.arrowNormalTexture or "UI-HUD-ActionBar-Flyout", false)
	local rotation = a[4]
	if open then
		rotation = (rotation + 180) % 360
	end
	if SetClampedTextureRotation then
		SetClampedTextureRotation(arrow, rotation)
	end
end

function ns.UpdateArrows()
	for i = 1, ns.MAX_BUTTONS do
		ns.UpdateArrow(mains[i])
	end
end

--------------------------------------------------------------------------------
-- Updates (coalesced to once per frame)
--------------------------------------------------------------------------------

local updatePending = false

function ns.RequestUpdate()
	if updatePending then
		return
	end
	updatePending = true
	C_Timer.After(0, function()
		updatePending = false
		ns.UpdateAll()
	end)
end

-- "Show empty buttons" off: empty buttons are see-through (alpha, so it
-- works in combat) unless in Edit Mode or while carrying an action to drop.
local function UpdateEmpty(main)
	local layout = ns.Layout()
	local entry = Entry(main.fpIndex)
	-- with the bar art on, empty slots show their background, as on
	-- Blizzard's main bar
	local show = layout.showEmpty ~= false or ns.inEditMode or entry.action ~= nil or ns.ArtOn(layout)
		or HasFlyContent(main.fpIndex) or ns.CursorAction() ~= nil
	main:SetAlpha(show and 1 or 0)
end

function ns.UpdateAll()
	-- hidden (the bar's visibility setting): nothing to draw; it all
	-- updates once when the bar shows again
	if not bar or not bar:IsVisible() then
		return
	end
	for i = 1, ns.MAX_BUTTONS do
		local main = mains[i]
		UpdateEmpty(main)
		if main:IsShown() then
			ns.UpdateButton(main)
			if main.fpFlyout:IsShown() then
				for f = 1, ns.MAX_FLY do
					ns.UpdateButton(main.fpFlyout.buttons[f])
				end
			end
		end
		ns.UpdateStrip(main)
	end
end

function ns.UpdateRanges()
	for i = 1, ns.MAX_BUTTONS do
		if mains[i]:IsShown() then
			ns.UpdateRange(mains[i])
		end
	end
end

-- Range has no event for buttons that aren't action slots, so while there is
-- a target and the bar can be seen it is checked five times a second, as the
-- native bars used to. With no target, or the bar hidden, nothing runs.
local rangeTicker
function ns.WatchRange()
	local need = bar and bar:IsVisible() and UnitExists("target")
	if need and not rangeTicker then
		rangeTicker = C_Timer.NewTicker(0.2, ns.UpdateRanges)
	elseif not need and rangeTicker then
		rangeTicker:Cancel()
		rangeTicker = nil
	end
end

function ns.UpdateHotkeys()
	for i = 1, ns.MAX_BUTTONS do
		ns.UpdateHotkey(mains[i])
	end
end

--------------------------------------------------------------------------------
-- Placing and removing actions (out of combat only, like native bars)
--------------------------------------------------------------------------------

function ns.SetSlot(btn, action)
	local entry = Entry(btn.fpIndex)
	if btn.fpFly then
		entry.fly[btn.fpFly] = action
	else
		entry.action = action
	end
	btn.fpAction = action
	ns.ApplyAttributes(btn)
	ns.UpdateButton(btn)
	local main = mains[btn.fpIndex]
	if main.fpFlyout:IsShown() then
		ns.LayoutFlyout(main)
	end
	ns.UpdateStrip(main)
	ns.UpdateArrow(main)
end

-- Dropping on a filled slot swaps: the old action goes to the cursor.
function ns.DropOn(btn)
	if InCombatLockdown() then
		return
	end
	local new = ns.CursorAction()
	if not new then
		return
	end
	local old = btn.fpAction
	ClearCursor()
	ns.SetSlot(btn, new)
	if old then
		ns.Pickup(old)
	end
end

-- Same rule as the Blizzard bars: free drag when "Lock Action Bars" is off,
-- otherwise only with the pick up modifier (Shift by default).
function ns.DragFrom(btn)
	if InCombatLockdown() or not btn.fpAction then
		return
	end
	if GetCVarBool("lockActionBars") and not IsModifiedClick("PICKUPACTION") then
		return
	end
	local old = btn.fpAction
	ns.SetSlot(btn, nil)
	ns.Pickup(old)
end

--------------------------------------------------------------------------------
-- Flyouts
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Flyout frame: bar 1's art, always on (Art.lua). Falls back to a plain dark
-- backdrop if the art is missing.
--------------------------------------------------------------------------------

function ns.CreateFlyoutArt(fly)
	return ns.FlyoutFrameArt(fly)
end

function ns.LayoutFlyout(main)
	if InCombatLockdown() then
		return
	end
	local layout = ns.Layout()
	local d = DIRS[ns.FlyDir(layout)]
	local size, spacing = ns.SIZE, 2
	local fly = main.fpFlyout

	-- Filled slots only, packed together. All six while an action is on the
	-- cursor, while in Edit Mode, or when the flyout is still empty.
	local grid = ns.CursorAction() ~= nil or ns.inEditMode or not HasFlyContent(main.fpIndex)
	local n = 0
	fly.visible = {}
	for f = 1, ns.MAX_FLY do
		local fb = fly.buttons[f]
		if grid or fb.fpAction then
			n = n + 1
			fly.visible[n] = fb
			local offset = PAD + (n - 1) * (size + spacing)
			fb:ClearAllPoints()
			fb:SetPoint(d.point, fly, d.point, d.dx * offset, d.dy * offset)
			fb:Show()
		else
			fb:Hide()
		end
	end

	local along = n * size + math.max(n - 1, 0) * spacing + 2 * PAD
	local across = size + 2 * PAD
	if d.dx ~= 0 then
		fly:SetSize(along, across)
	else
		fly:SetSize(across, along)
	end
	local gap = 12
	fly:ClearAllPoints()
	fly:SetPoint(d.point, main, d.rel, d.dx * gap, d.dy * gap)
	ns.ApplyFlyoutArt(fly, ns.FlyDir(layout))
end

function ns.CloseFlyout(main)
	local fly = main.fpFlyout
	if not fly:IsShown() or InCombatLockdown() then
		return
	end
	if fly.how == "key" then
		ns.ReleaseChoiceKeys(main)
	end
	if fly.how ~= "hover" then
		ns.PlayFlyoutSound(false)
	end
	fly:Hide()
	fly.how = nil
	ns.UpdateStrip(main)
	ns.UpdateArrow(main)
end

function ns.PlayFlyoutSound(open)
	if ns.Behavior().mute or not SOUNDKIT then
		return
	end
	local id = open and SOUNDKIT.IG_BACKPACK_OPEN or SOUNDKIT.IG_BACKPACK_CLOSE
	if id then
		PlaySound(id)
	end
end

function ns.CloseAll()
	if not bar then
		return
	end
	for i = 1, ns.MAX_BUTTONS do
		ns.CloseFlyout(mains[i])
	end
end

--------------------------------------------------------------------------------
-- "Stays open" mode closes itself after some seconds without activity (Edit
-- Mode setting, 0 = never). Activity: choosing a slot, the key still held, or
-- the mouse over the flyout or button.
--------------------------------------------------------------------------------

function ns.TouchSticky(main)
	local fly = main.fpFlyout
	local layout = ns.Behavior()
	if not fly:IsShown() or fly.how ~= "key" or layout.holdMode ~= "STICKY" then
		return
	end
	local idle = tonumber(layout.stickyClose) or 0
	main.fpIdleGen = (main.fpIdleGen or 0) + 1
	if idle <= 0 then
		return
	end
	local gen = main.fpIdleGen
	C_Timer.After(idle, function()
		if gen ~= main.fpIdleGen or not fly:IsShown() or fly.how ~= "key" then
			return
		end
		if main.fpKeyDown or main:IsMouseOver() or fly:IsMouseOver() then
			ns.TouchSticky(main)
		else
			ns.CloseFlyout(main)
		end
	end)
end

function ns.OpenFlyout(main, how)
	if InCombatLockdown() or not main:IsShown() then
		return
	end
	for i = 1, ns.MAX_BUTTONS do
		if mains[i] ~= main then
			ns.CloseFlyout(mains[i])
		end
	end
	local fly = main.fpFlyout
	ns.LayoutFlyout(main)
	for f = 1, ns.MAX_FLY do
		ns.UpdateButton(fly.buttons[f])
	end
	fly.how = how
	fly:Show()
	-- opened on purpose (click or key): a bag sound, so you know without
	-- looking; mouseover opens stay silent
	if how ~= "hover" then
		ns.PlayFlyoutSound(true)
	end
	ns.UpdateStrip(main)
	ns.UpdateArrow(main)
	ns.TouchSticky(main)
end

function ns.ToggleFlyout(main)
	if main.fpFlyout:IsShown() then
		ns.CloseFlyout(main)
	else
		ns.OpenFlyout(main, "click")
	end
end

local function HoverAllowed()
	local layout = ns.Behavior()
	if not layout.hover then
		return false
	end
	local modifier = layout.modifier
	if modifier == "SHIFT" then
		return IsShiftKeyDown()
	elseif modifier == "CTRL" then
		return IsControlKeyDown()
	elseif modifier == "ALT" then
		return IsAltKeyDown()
	end
	return true
end

local function MaybeHoverOpen(main)
	if InCombatLockdown() or ns.inEditMode or ns.InQuickKeybind() or main.fpFlyout:IsShown() then
		return
	end
	-- Carrying an action always opens it, so the flyout slots can be filled.
	if ns.CursorAction() or HoverAllowed() then
		ns.OpenFlyout(main, "hover")
	end
end

local function KeepOpen(main)
	main.fpGen = (main.fpGen or 0) + 1
end

local function ScheduleClose(main)
	main.fpGen = (main.fpGen or 0) + 1
	local gen = main.fpGen
	C_Timer.After(0.25, function()
		if gen ~= main.fpGen then
			return
		end
		local fly = main.fpFlyout
		if fly:IsShown() and fly.how == "hover" and not main:IsMouseOver() and not fly:IsMouseOver() then
			ns.CloseFlyout(main)
		end
	end)
end

--------------------------------------------------------------------------------
-- Cooldown strip: flyout actions on cooldown, shown next to the main button
--------------------------------------------------------------------------------

local function StripIcon(main, n)
	local strip = main.fpStrip
	local icon = strip[n]
	if not icon then
		icon = CreateFrame("Frame", nil, bar)
		icon:SetFrameLevel(main:GetFrameLevel() + 2)
		icon:SetAlpha(STRIP_ALPHA)
		icon.tex = icon:CreateTexture(nil, "ARTWORK")
		icon.tex:SetAllPoints()
		-- full icon, uncropped, exactly like Blizzard's buff icons
		icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
		icon.cd:SetAllPoints()
		icon.cd:SetScript("OnCooldownDone", function()
			ns.RequestUpdate()
		end)
		-- "x6" when several flyout actions share this cooldown
		local holder = CreateFrame("Frame", nil, icon)
		holder:SetAllPoints()
		holder:SetFrameLevel(icon.cd:GetFrameLevel() + 1)
		icon.count = holder:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
		strip[n] = icon
	end
	return icon
end

-- Plain frames, not secure: safe to show, hide and move during combat.
function ns.UpdateStrip(main)
	local strip = main.fpStrip
	local n = 0
	-- off by default: it checks every flyout cooldown on each update
	if ns.Behavior().preview and main:IsShown() and not main.fpFlyout:IsShown() then
		local layout = ns.Layout()
		local d = DIRS[ns.FlyDir(layout)]
		local spacing = layout.spacing
		local size = ns.SIZE * STRIP_SCALE
		local fly = Entry(main.fpIndex).fly

		-- collect, merging actions that report the very same cooldown
		local entries, byKey = {}, {}
		for f = 1, ns.MAX_FLY do
			local a = fly[f]
			if a then
				local kind, id = ns.Resolve(a)
				local cd = kind and ns.GetCooldown(kind, id)
				if ns.IsCoolingDown(cd) then
					-- secret cooldowns can't be compared: never merged
					local key = cd.start and ("%.2f:%.2f"):format(cd.start, cd.duration)
					local e = key and byKey[key]
					if e then
						e.count = e.count + 1
					else
						e = { action = a, cd = cd, count = 1 }
						entries[#entries + 1] = e
						if key then
							byKey[key] = e
						end
					end
				end
			end
		end

		for _, e in ipairs(entries) do
			n = n + 1
			local icon = StripIcon(main, n)
			local offset = spacing + (n - 1) * (size + spacing)
			icon:SetScale(main:GetScale())
			icon:SetSize(size, size)
			icon:ClearAllPoints()
			icon:SetPoint(d.point, main, d.rel, d.dx * offset, d.dy * offset)
			icon.tex:SetTexture(ns.GetIcon(e.action) or ns.QUESTION_MARK)
			icon.count:SetText(e.count > 1 and ("\195\151" .. e.count) or "")
			ns.ApplyCooldown(icon.cd, e.cd)
			icon:Show()
		end
	end
	for k = n + 1, #strip do
		strip[k]:Hide()
	end
end

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

-- Errors here were silent in 0.2.0; report them in chat instead.
local reported = {}
function ns.Report(err)
	err = tostring(err)
	ns.lastError = err
	if not reported[err] then
		reported[err] = true
		print("|cffff4040Fetch!:|r " .. err)
	end
end

local DoApplyLayout

function ns.ApplyLayout()
	if not bar then
		return
	end
	if InCombatLockdown() then
		ns.pendingLayout = true
		return
	end
	local ok, err = pcall(DoApplyLayout)
	if not ok then
		ns.Report(err)
	end
end

-- Bar visibility, like Blizzard's bars. The state driver shows and hides
-- the bar from secure code, so it works in combat.
local VISIBILITY = {
	ALWAYS = "show",
	COMBAT = "[combat] show; hide",
	NOCOMBAT = "[combat] hide; show",
	HIDDEN = "hide",
}

function ns.ApplyVisibility()
	if ns.UpdateKeyToggle then
		ns.UpdateKeyToggle()
	end
	if not bar or InCombatLockdown() then
		return
	end
	if ns.inEditMode then
		-- always visible while editing
		UnregisterStateDriver(bar, "visibility")
		bar:Show()
		return
	end
	local layout = ns.Layout()
	if (ns.bagPeek or ns.bagOnCursor) and ns.Anchored(layout) then
		-- put away with a right click on the keyring, or while a bag is on
		-- the cursor, to reach the bags
		RegisterStateDriver(bar, "visibility", "hide")
		return
	end
	RegisterStateDriver(bar, "visibility", VISIBILITY[layout.visibility] or "show")
end

function DoApplyLayout()
	local layout = ns.Layout()
	if not layout.bagAnchor then
		ns.bagPeek = false
	end
	-- Anchored to the bag bar: one button per bag, on top of it. The bar's
	-- own place, size and button count stay saved for when it is undone.
	local slots, _, pos = nil, nil, nil
	if layout.bagAnchor then
		slots, _, pos = ns.BagSlots()
	end
	if slots then
		ns.ApplyBagLayout(bar, mains, slots, pos)
		ns.ApplyArt(bar, mains)
		ns.ApplyVisibility()
		ns.UpdateArrows()
		ns.RequestUpdate()
		return
	end
	ns.ResetBagLevels(bar, mains)
	-- As on Blizzard's bars: Icon Size scales each button (and its flyout),
	-- Icon Padding stays the same at any size, and the bar itself isn't scaled.
	local scale = (tonumber(layout.scale) or 100) / 100
	local size, spacing = ns.SIZE * scale, layout.spacing
	local count = math.max(1, math.min(ns.MAX_BUTTONS, layout.numButtons))
	local vertical = layout.orientation == "VERTICAL"
	-- rows (columns on a vertical bar), filled like Blizzard's bars
	local lines = math.max(1, math.min(count, tonumber(layout.rows) or 1))
	local perLine = math.ceil(count / lines)
	local step = size + spacing

	bar:SetScale(1)
	bar:ClearAllPoints()
	bar:SetPoint(layout.point, UIParent, layout.point, layout.x, layout.y)
	local long = perLine * size + (perLine - 1) * spacing
	local short = lines * size + (lines - 1) * spacing
	if vertical then
		bar:SetSize(short, long)
	else
		bar:SetSize(long, short)
	end

	for i = 1, ns.MAX_BUTTONS do
		local main = mains[i]
		ns.CloseFlyout(main)
		main:ClearAllPoints()
		local along, across = (i - 1) % perLine, math.floor((i - 1) / perLine)
		-- a scaled frame's offsets are in its own scale: divide back
		main:SetScale(scale)
		main.fpFlyout:SetScale(scale)
		if vertical then
			main:SetPoint("TOPLEFT", bar, "TOPLEFT", across * step / scale, -along * step / scale)
		else
			main:SetPoint("TOPLEFT", bar, "TOPLEFT", along * step / scale, -across * step / scale)
		end
		-- Hidden buttons keep their contents but lose their action, so a
		-- keybind can't fire something you can't see.
		local enabled = i <= count
		main.fpDisabled = not enabled
		main:SetShown(enabled)
		ns.ApplyAttributes(main)
	end
	ns.ApplyArt(bar, mains)
	ns.ApplyVisibility()
	ns.UpdateArrows()
	ns.RequestUpdate()
end

--------------------------------------------------------------------------------
-- Building
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Tooltip: beside the bar, never over a flyout.
-- Right half of the screen: left of the bar; left half: right of it.
-- Bottom half: bottoms aligned, grows up; top half: tops aligned, grows down.
--------------------------------------------------------------------------------

local TIP_GAP = 4

function ns.AnchorTooltip(owner)
	local tip = GameTooltip
	tip:SetOwner(owner, "ANCHOR_NONE")
	tip:ClearAllPoints()

	local layout = ns.Layout()
	local count = ns.Count(layout)
	local first, last = mains[1], mains[count]
	local bx, by = bar:GetCenter()
	local ux, uy = UIParent:GetCenter()
	if not bx or not ux then
		tip:SetPoint("BOTTOMRIGHT", owner, "TOPLEFT")
		return
	end
	local bs, us = bar:GetEffectiveScale(), UIParent:GetEffectiveScale()
	local onRight = bx * bs > ux * us
	local onBottom = by * bs < uy * us

	local v = onBottom and "BOTTOM" or "TOP"
	local tipPoint = v .. (onRight and "RIGHT" or "LEFT")
	local relPoint = v .. (onRight and "LEFT" or "RIGHT")
	local x = onRight and -TIP_GAP or TIP_GAP

	local anchor
	if ns.Orientation(layout) == "VERTICAL" then
		-- a sideways flyout or cooldown strip may sit on the tooltip's side
		local main = mains[owner.fpIndex]
		local dir = ns.FlyDir(layout)
		local towardTip = (onRight and dir == "LEFT") or (not onRight and dir == "RIGHT")
		if towardTip and main.fpFlyout:IsShown() then
			anchor = main.fpFlyout
		elseif towardTip then
			local strip = main.fpStrip
			for k = #strip, 1, -1 do
				if strip[k]:IsShown() then
					anchor = strip[k]
					break
				end
			end
		end
		anchor = anchor or (onBottom and last or first)
	else
		anchor = onRight and first or last
	end
	tip:SetPoint(tipPoint, anchor, relPoint, x, 0)
end

--------------------------------------------------------------------------------
-- Hold a keybind to open the flyout; keys 1 to 6 pick a slot meanwhile.
--------------------------------------------------------------------------------

local keyOwner = CreateFrame("Frame")
local cancel = CreateFrame("Button", "SetGoFetchKeyCancel", UIParent)
cancel:SetScript("OnClick", function()
	ns.CloseAll()
end)

function ns.BindChoiceKeys(main)
	if InCombatLockdown() then
		return
	end
	ClearOverrideBindings(keyOwner)
	local list = main.fpFlyout.visible or {}
	for n = 1, math.min(6, #list) do
		local fb = list[n]
		if fb.fpAction then
			SetOverrideBindingClick(keyOwner, true, tostring(n), fb:GetName(), "LeftButton")
			if fb.fpHotKey then
				fb.fpHotKey:SetText(tostring(n))
				fb.fpHotKey:Show()
			end
		end
	end
	SetOverrideBindingClick(keyOwner, true, "ESCAPE", "SetGoFetchKeyCancel", "LeftButton")
end

function ns.ReleaseChoiceKeys(main)
	if InCombatLockdown() then
		return
	end
	ClearOverrideBindings(keyOwner)
	for f = 1, ns.MAX_FLY do
		local hk = main.fpFlyout.buttons[f].fpHotKey
		if hk then
			hk:SetText("")
			hk:Hide()
		end
	end
end

local function IsKeyPress()
	return not IsMouseButtonDown("LeftButton")
end

-- Called from PreClick of a main button. Returns true when the click must
-- not fire its action.
local function HandleHold(main, down)
	local mode = ns.Behavior().holdMode
	if mode ~= "HOLD" and mode ~= "STICKY" then
		return false
	end
	local fly = main.fpFlyout
	if down then
		if not IsKeyPress() then
			return false
		end
		if fly:IsShown() and fly.how == "key" then
			-- pressing the key again closes a flyout left open
			main.fpCloseOnUp = true
			return false
		end
		if not HasFlyContent(main.fpIndex) then
			return false
		end
		main.fpHoldGen = (main.fpHoldGen or 0) + 1
		local gen = main.fpHoldGen
		main.fpKeyDown = true
		C_Timer.After((ns.Behavior().holdDelay or 250) / 1000, function()
			if gen == main.fpHoldGen and main.fpKeyDown and not InCombatLockdown() then
				main.fpHeld = true
				ns.OpenFlyout(main, "key")
				ns.BindChoiceKeys(main)
			end
		end)
		return false
	end
	-- key released
	main.fpKeyDown = false
	main.fpHoldGen = (main.fpHoldGen or 0) + 1
	if main.fpCloseOnUp then
		main.fpCloseOnUp = nil
		ns.CloseFlyout(main)
		return true
	end
	if main.fpHeld then
		main.fpHeld = nil
		if mode == "HOLD" then
			ns.CloseFlyout(main)
		end
		return true
	end
	return false
end

local function Suppress(self)
	self.fpSuppress = true
	self:SetAttribute("*type1", nil)
	-- safety net in case the button up never reaches us
	C_Timer.After(1, function()
		if self.fpSuppress and not InCombatLockdown() then
			self.fpSuppress = nil
			ns.ApplyAttributes(self)
		end
	end)
end

--------------------------------------------------------------------------------
-- Button scripts
--------------------------------------------------------------------------------

local function OnEnter(self)
	local main = mains[self.fpIndex]
	if self.fpIsMain and ns.InQuickKeybind() and self.QuickKeybindButtonOnEnter then
		self:QuickKeybindButtonOnEnter()
		return
	end
	ns.ShowTooltip(self)
	KeepOpen(main)
	ns.TouchSticky(main)
	if self == main then
		MaybeHoverOpen(main)
	end
end

local function OnLeave(self)
	if self.fpIsMain and self.QuickKeybindButtonOnLeave then
		self:QuickKeybindButtonOnLeave()
	end
	GameTooltip:Hide()
	ScheduleClose(mains[self.fpIndex])
	ns.TouchSticky(mains[self.fpIndex])
end

local function PreClick(self, button, down)
	if down then
		-- remember whether this click came from the mouse or a key
		self.fpMouseClick = IsMouseButtonDown("LeftButton")
	end
	if InCombatLockdown() or self.fpSuppress then
		return
	end
	if button ~= "LeftButton" then
		return
	end
	-- Quick Keybind mode: clicks bind keys, they never cast.
	if ns.InQuickKeybind() then
		Suppress(self)
		return
	end
	-- Carrying an action: place it instead of casting.
	if ns.CursorAction() then
		Suppress(self)
		ns.DropOn(self)
		return
	end
	if self.fpIsMain and HandleHold(self, down) then
		Suppress(self)
	end
end

local function PostClick(self, button, down)
	ns.UpdateChecked(self)
	if down and self.fpIsMain and self.QuickKeybindButtonOnClick and ns.InQuickKeybind() then
		self:QuickKeybindButtonOnClick(button, down)
	end
	if down then
		return
	end
	if self.fpSuppress then
		self.fpSuppress = nil
		ns.ApplyAttributes(self)
		return
	end
	if InCombatLockdown() or ns.InQuickKeybind() then
		return
	end
	local main = mains[self.fpIndex]
	if self == main then
		if button == "RightButton" then
			ns.ToggleFlyout(main)
		end
	elseif button == "LeftButton" then
		local fly = main.fpFlyout
		if fly.how ~= "key" then
			ns.CloseFlyout(main)
		elseif self.fpMouseClick and ns.Behavior().holdMode == "STICKY" then
			-- opened by a key: keys 1 to 6 keep it open, a mouse click closes it
			ns.CloseFlyout(main)
		else
			-- a slot chosen with a key counts as activity
			ns.TouchSticky(main)
		end
	end
end

local function OnReceiveDrag(self)
	ns.DropOn(self)
end

local function OnDragStart(self)
	ns.DragFrom(self)
end

local function Hook(btn)
	btn:SetScript("OnEnter", OnEnter)
	btn:SetScript("OnLeave", OnLeave)
	btn:SetScript("PreClick", PreClick)
	btn:SetScript("PostClick", PostClick)
	btn:SetScript("OnReceiveDrag", OnReceiveDrag)
	btn:SetScript("OnDragStart", OnDragStart)
end

function ns.BuildBar()
	bar = CreateFrame("Frame", "SetGoFetchBar", UIParent)
	bar:SetClampedToScreen(true)
	bar:SetSize(1, 1)
	ns.bar = bar
	bar:SetScript("OnShow", function()
		ns.RequestUpdate()
		ns.WatchRange()
	end)
	bar:SetScript("OnHide", function()
		ns.WatchRange()
	end)

	for i = 1, ns.MAX_BUTTONS do
		local main = ns.CreateActionButton("SetGoFetchButton" .. i, bar, true)
		main.fpIndex = i
		Hook(main)

		local fly = CreateFrame("Frame", "SetGoFetchFlyout" .. i, bar, "BackdropTemplate")
		-- above every bar, and kept there: a parent's strata change (the bar
		-- anchoring to the bags) would otherwise carry it along
		fly:SetFrameStrata("DIALOG")
		if fly.SetFixedFrameStrata then
			fly:SetFixedFrameStrata(true)
		end
		fly:EnableMouse(true)
		fly:Hide()
		if not ns.CreateFlyoutArt(fly) and fly.SetBackdrop then
			fly:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				edgeSize = 8,
				insets = { left = 2, right = 2, top = 2, bottom = 2 },
			})
			fly:SetBackdropColor(0, 0, 0, 0.8)
			fly:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
		end
		fly:SetScript("OnEnter", function()
			KeepOpen(main)
			ns.TouchSticky(main)
		end)
		fly:SetScript("OnLeave", function()
			ScheduleClose(main)
			ns.TouchSticky(main)
		end)
		fly.buttons = {}
		for f = 1, ns.MAX_FLY do
			local fb = ns.CreateActionButton("SetGoFetchFlyout" .. i .. "Button" .. f, fly, false)
			fb.fpIndex = i
			fb.fpFly = f
			Hook(fb)
			fly.buttons[f] = fb
		end

		main.fpFlyout = fly
		main.fpStrip = {}
		mains[i] = main
	end

	local size = mains[1]:GetWidth()
	ns.SIZE = (size and size >= 1) and size or 45
	-- where the bar sits among other frames, for when it leaves the bag bar
	ns.baseStrata, ns.baseLevel = bar:GetFrameStrata(), bar:GetFrameLevel()

	if EventRegistry and QuickKeybindButtonTemplateMixin then
		local function ModeChanged(enabled)
			if enabled then
				ns.CloseAll()
			end
			for i = 1, ns.MAX_BUTTONS do
				local main = mains[i]
				if main.DoModeChange then
					pcall(main.DoModeChange, main, enabled)
				end
				if main.UpdateMouseWheelHandler then
					pcall(main.UpdateMouseWheelHandler, main)
				end
			end
		end
		EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeEnabled", function()
			ModeChanged(true)
		end, ns)
		EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeDisabled", function()
			ModeChanged(false)
		end, ns)
	end
end

function ns.LoadActions()
	for i = 1, ns.MAX_BUTTONS do
		local entry = Entry(i)
		local main = mains[i]
		main.fpAction = entry.action
		ns.ApplyAttributes(main)
		for f = 1, ns.MAX_FLY do
			local fb = main.fpFlyout.buttons[f]
			fb.fpAction = entry.fly[f]
			ns.ApplyAttributes(fb)
		end
	end
	ns.UpdateHotkeys()
	ns.UpdateArrows()
	ns.RequestUpdate()
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local events = CreateFrame("Frame")

-- pcall: an event the Forever client doesn't know would otherwise error
local function Register(event, unit)
	if unit then
		pcall(events.RegisterUnitEvent, events, event, unit)
	else
		pcall(events.RegisterEvent, events, event)
	end
end

local handlers = {}

function handlers.PLAYER_REGEN_DISABLED()
	-- Last moment before the lockdown: flyouts are secure, close them now.
	ns.CloseAll()
end

function handlers.PLAYER_REGEN_ENABLED()
	-- a bag picked up or dropped in combat
	ns.CheckBagOnCursor()
	if ns.pendingLayout then
		ns.pendingLayout = false
		ns.ApplyLayout()
	end
	if ns.pendingAttributes then
		ns.pendingAttributes = false
		for i = 1, ns.MAX_BUTTONS do
			ns.ApplyAttributes(mains[i])
			for f = 1, ns.MAX_FLY do
				ns.ApplyAttributes(mains[i].fpFlyout.buttons[f])
			end
		end
	end
	ns.RequestUpdate()
end

function handlers.PLAYER_ENTERING_WORLD()
	-- the bag buttons have their place on screen by now
	if ns.Layout().bagAnchor then
		ns.ApplyLayout()
	end
	ns.UpdateHotkeys()
	ns.RequestUpdate()
end

-- the bag bar's place on screen changes with the UI scale
function handlers.UI_SCALE_CHANGED()
	ns.BagRelayout()
end
handlers.DISPLAY_SIZE_CHANGED = handlers.UI_SCALE_CHANGED

function handlers.UPDATE_BINDINGS()
	ns.UpdateHotkeys()
end

function handlers.PLAYER_TARGET_CHANGED()
	ns.UpdateRanges()
	ns.WatchRange()
end

function handlers.MODIFIER_STATE_CHANGED()
	for i = 1, ns.MAX_BUTTONS do
		local main = mains[i]
		if main:IsShown() and main:IsMouseOver() then
			MaybeHoverOpen(main)
		end
	end
end

-- Only a left click outside closes an open flyout. The right button never
-- does (holding it turns the camera); a right click on the flyout's own
-- button still toggles it, through PostClick. "While held" ignores the
-- mouse; only releasing the key closes it.
function handlers.GLOBAL_MOUSE_DOWN(button)
	if button ~= "LeftButton" then
		return
	end
	local sticky = ns.Behavior().holdMode == "STICKY"
	for i = 1, ns.MAX_BUTTONS do
		local main = mains[i]
		local fly = main.fpFlyout
		if fly:IsShown() then
			if fly.how == "click" then
				if not main:IsMouseOver() and not fly:IsMouseOver() then
					ns.CloseFlyout(main)
				end
			elseif fly.how == "key" and sticky then
				if not fly:IsMouseOver() then
					ns.CloseFlyout(main)
				end
			end
		end
	end
end

function handlers.CURSOR_CHANGED()
	-- empty buttons show while an action is carried
	ns.RequestUpdate()
	if InCombatLockdown() then
		return
	end
	ns.CheckBagOnCursor()
	for i = 1, ns.MAX_BUTTONS do
		local main = mains[i]
		if main.fpFlyout:IsShown() then
			ns.LayoutFlyout(main)
		elseif main:IsShown() and main:IsMouseOver() then
			MaybeHoverOpen(main)
		end
	end
end

local REFRESH = {
	"SPELL_UPDATE_COOLDOWN", "BAG_UPDATE_COOLDOWN", "ACTIONBAR_UPDATE_COOLDOWN",
	"SPELL_UPDATE_USABLE", "ACTIONBAR_UPDATE_USABLE", "SPELL_UPDATE_CHARGES",
	"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UPDATE_MACROS", "SPELLS_CHANGED",
	"CURRENT_SPELL_CAST_CHANGED", "START_AUTOREPEAT_SPELL", "STOP_AUTOREPEAT_SPELL",
	"UPDATE_SHAPESHIFT_FORM",
}

local function RegisterEvents()
	for event in pairs(handlers) do
		Register(event)
	end
	for _, event in ipairs(REFRESH) do
		Register(event)
	end
	Register("UNIT_INVENTORY_CHANGED", "player")
	events:SetScript("OnEvent", function(_, event, ...)
		local handler = handlers[event]
		if handler then
			handler(...)
		else
			ns.RequestUpdate()
		end
	end)
	ns.WatchRange()
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
	if name ~= ADDON then
		return
	end
	self:UnregisterEvent("ADDON_LOADED")
	ns.InitDB()
	ns.WatchLayouts()
	-- switched off in SetGo!: no bar, only the settings page
	if SetGo and SetGo.ModuleOn and not SetGo.ModuleOn("fetch") then
		return
	end
	ns.BuildBar()
	ns.HookBags()
	ns.SetupEditMode()
	ns.ApplyLayout()
	ns.LoadActions()
	RegisterEvents()
end)
