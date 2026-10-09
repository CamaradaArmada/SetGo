local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- A profile's Edit Mode layout lives inside the profile, as Blizzard's export
-- text (p.layoutText), with a number that goes up each time it changes
-- (p.layoutRev). On each character, SetGo! keeps one character layout of its
-- own, "SetGo!: <profile>", and writes the profile in use into it: the
-- account's layout slots are left alone.
--   SetGoCharDB.slotName: the name of that layout here
--   SetGoCharDB.slotApplied = { id, rev }: the profile and version in it
-- What the player changes in Edit Mode goes back into the profile when Edit
-- Mode closes. On another character with that profile, SetGo! asks before
-- putting the newer version on (at login).
-- Profiles from before point at a layout (p.layout); its text is read the
-- first time it is needed.
--------------------------------------------------------------------------------

local PREFIX = "SetGo!: "

local function CharType()
	return Enum and Enum.EditModeLayoutType and Enum.EditModeLayoutType.Character or 2
end

local function MaxPerType()
	return tonumber(Constants and Constants.EditModeConsts and Constants.EditModeConsts.EditModeMaxLayoutsPerType) or 5
end

function ns.SlotName(name)
	return PREFIX .. tostring(name)
end

-- the profile's layout as text (read from the layout it points at, for a
-- profile from before)
function ns.ProfileLayoutText(p)
	if type(p) ~= "table" then
		return nil
	end
	if not p.layoutText and type(p.layout) == "table" then
		local text = ns.LayoutText(p.layout)
		if text then
			p.layoutText = text
			p.layoutFromName = p.layoutFromName or ns.LayoutName(p.layout)
			p.layoutRev = p.layoutRev or 1
		end
	end
	return p.layoutText
end

-- Sets the profile's layout text; the version goes up when it changed
function ns.SetProfileLayout(p, text, fromName)
	if type(text) ~= "string" or text == "" then
		return
	end
	if p.layoutText ~= text then
		p.layoutText = text
		p.layoutRev = (p.layoutRev or 0) + 1
	end
	if fromName then
		p.layoutFromName = fromName
	end
	p.layout = nil
end

-- this character's SetGo! layout: its position in the saved layouts
local function FindSlot(layouts)
	local name = ns.charDB and ns.charDB.slotName
	if not name then
		return nil
	end
	for i, layout in ipairs(layouts or {}) do
		if layout.layoutName == name and layout.layoutType == CharType() then
			return i
		end
	end
end

local function PresetCount()
	local n = 0
	for _, l in ipairs((ns.GetLayouts())) do
		if l.preset then
			n = n + 1
		end
	end
	return n
end

-- The profile is what this character's layout holds, and that layout is the
-- one in use
function ns.SlotCurrent(name, p)
	local applied = ns.charDB and ns.charDB.slotApplied
	if not (applied and p and applied.id == p.id and applied.rev == (p.layoutRev or 1)) then
		return false
	end
	if ns.charDB.slotName ~= ns.SlotName(name) then
		return false
	end
	local info = C_EditMode and Try(C_EditMode.GetLayouts)
	if type(info) ~= "table" then
		return false
	end
	local pos = FindSlot(info.layouts)
	return pos ~= nil and info.activeLayout == PresetCount() + pos
end

-- Writes the profile into this character's SetGo! layout (made the first
-- time) and makes it the one in use. Returns true when written. The
-- interface reloads after (the caller's), so every element follows.
function ns.WriteSlot(name, p)
	local text = ns.ProfileLayoutText(p)
	local data = text and C_EditMode and Try(C_EditMode.ConvertStringToLayoutInfo, text)
	local all = C_EditMode and Try(C_EditMode.GetLayouts)
	if type(data) ~= "table" or type(all) ~= "table" then
		ns.Print(L.MSG_LAYOUT_FAILED)
		return false
	end
	local saved = {}
	for i, layout in ipairs(all.layouts or {}) do
		saved[i] = layout
	end
	local newName = ns.SlotName(name)
	local oldName = ns.charDB.slotName
	local pos = FindSlot(saved)
	data.layoutName = newName
	data.layoutType = CharType()
	if pos then
		saved[pos] = data
	else
		-- a new one, after this character's others
		local count, last = 0, #saved
		for i, layout in ipairs(saved) do
			if layout.layoutType == CharType() then
				count = count + 1
				last = i
			end
		end
		if count >= MaxPerType() then
			ns.Print(L.MSG_SLOT_FULL:format(MaxPerType()))
			return false
		end
		pos = last + 1
		table.insert(saved, pos, data)
	end
	if not ns.SaveLayoutsWith(saved, pos) then
		ns.Print(L.MSG_LAYOUT_FAILED)
		return false
	end
	local applied = ns.charDB.slotApplied
	ns.charDB.slotName = newName
	ns.charDB.slotApplied = { id = p.id, rev = p.layoutRev or 1 }
	ns.charDB.layoutDeclined = nil
	-- module data kept by layout name (the Fetch! bar): a renamed profile
	-- takes its own along; a new one starts from the layout it was made from
	if oldName and oldName ~= newName and applied and applied.id == p.id then
		ns.CopyLayoutData(oldName, newName)
	elseif not p.layoutSeeded and p.layoutFromName then
		ns.CopyLayoutData(p.layoutFromName, newName)
	end
	p.layoutSeeded = true
	return true
end

-- Edit Mode closed: what changed in this character's SetGo! layout goes
-- into the profile in use
local function Capture()
	local name = ns.ActivePreset and ns.ActivePreset()
	local p = name and ns.ProfileOf(name)
	local applied = ns.charDB and ns.charDB.slotApplied
	if not (p and applied and applied.id == p.id) then
		return
	end
	local info = C_EditMode and Try(C_EditMode.GetLayouts)
	if type(info) ~= "table" then
		return
	end
	local pos = FindSlot(info.layouts)
	if not pos or info.activeLayout ~= PresetCount() + pos then
		return
	end
	local text = Try(C_EditMode.ConvertLayoutInfoToString, info.layouts[pos])
	if type(text) == "string" and text ~= "" and text ~= p.layoutText then
		ns.SetProfileLayout(p, text)
		ns.charDB.slotApplied.rev = p.layoutRev
		ns.Print(L.MSG_LAYOUT_RECORDED:format(name))
		if ns.Refresh then
			ns.Refresh()
		end
	end
end
ns.CaptureSlot = Capture

-- At login: the profile in use changed on another character since this one
-- got it: asked first (Blizzard's popup: the interface reloads)
StaticPopupDialogs.SETGO_LAYOUT_UPDATE = {
	text = "%s",
	button1 = L.LAYOUT_UPDATE_BUTTON,
	button2 = NOT_NOW or CANCEL or "Not now",
	OnAccept = function(_, data)
		if InCombatLockdown() then
			ns.Print(L.MSG_COMBAT)
			return
		end
		local p = data and ns.ProfileOf(data.name)
		if p and ns.WriteSlot(data.name, p) then
			ReloadUI()
		end
	end,
	OnCancel = function(_, data)
		-- not again for this version
		if data then
			ns.charDB.layoutDeclined = data.rev
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

local function CheckNewer()
	local name = ns.ActivePreset and ns.ActivePreset()
	local p = name and ns.ProfileOf(name)
	local applied = ns.charDB and ns.charDB.slotApplied
	if not (p and applied and applied.id == p.id and p.layoutText) then
		return
	end
	local rev = p.layoutRev or 1
	if rev > (applied.rev or 0) and ns.charDB.layoutDeclined ~= rev and not InCombatLockdown() then
		StaticPopup_Show("SETGO_LAYOUT_UPDATE", L.POPUP_LAYOUT_UPDATE:format(name), nil, { name = name, rev = rev })
	end
end
ns.CheckNewerLayout = CheckNewer

local hooked = false
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:SetScript("OnEvent", function(_, _, login, reload)
	if not hooked and EditModeManagerFrame then
		hooked = true
		EditModeManagerFrame:HookScript("OnHide", function()
			-- once Blizzard has saved the layouts
			C_Timer.After(0.5, Capture)
		end)
	end
	if login or reload then
		C_Timer.After(4, CheckNewer)
	end
end)
