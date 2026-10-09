local _, ns = ...

--------------------------------------------------------------------------------
-- /fetch dump: writes down how Blizzard's action bar 1 is drawn (its frame,
-- dividers and the button background), so the same assets can be written
-- into Fetch! by hand. Runs only when typed. The text opens in a window to
-- copy (Ctrl+A, Ctrl+C) and is also kept in SetGoFetchLayoutDB.dump.
-- Best with bar 1's art on and its padding at the minimum, so the dividers
-- show.
--------------------------------------------------------------------------------

local function KeyOf(parent, region)
	if type(parent) ~= "table" then
		return nil
	end
	for k, v in pairs(parent) do
		if v == region and type(k) == "string" then
			return k
		end
	end
end

local function Num(v)
	if type(v) == "number" then
		return ("%.1f"):format(v)
	end
	return tostring(v)
end

local function Points(r)
	local out = {}
	for i = 1, (r.GetNumPoints and r:GetNumPoints() or 0) do
		local point, rel, relPoint, x, y = r:GetPoint(i)
		local relName = rel and (rel.GetName and rel:GetName() or KeyOf(r:GetParent(), rel) or "?") or "nil"
		out[#out + 1] = ("%s>%s.%s(%s,%s)"):format(tostring(point), tostring(relName), tostring(relPoint), Num(x), Num(y))
	end
	return table.concat(out, " ")
end

local function Texture(lines, indent, parent, r)
	local key = KeyOf(parent, r) or (r.GetName and r:GetName()) or "-"
	local layer, sub = r:GetDrawLayer()
	local atlas = r.GetAtlas and ns.Try(r.GetAtlas, r)
	local file = r.GetTexture and ns.Try(r.GetTexture, r)
	local w, h = r:GetSize()
	local line = ("%s%s [%s %s] atlas=%s file=%s size=%sx%s alpha=%s shown=%s pts=%s"):format(
		indent, key, tostring(layer), tostring(sub), tostring(atlas), tostring(file),
		Num(w), Num(h), Num(r:GetAlpha()), tostring(r:IsShown()), Points(r))
	if r.GetTextureSliceMargins then
		local l, t, rr, b = ns.Try(r.GetTextureSliceMargins, r)
		if type(l) == "number" and (l + t + rr + b) > 0 then
			line = line .. (" slice=%s,%s,%s,%s mode=%s"):format(Num(l), Num(t), Num(rr), Num(b),
				tostring(r.GetTextureSliceMode and ns.Try(r.GetTextureSliceMode, r)))
		end
	end
	if r.GetTexCoord then
		local a, b, c, d, e, f, g, h2 = r:GetTexCoord()
		if a and not (a == 0 and b == 0 and c == 0 and d == 1 and e == 1 and f == 0 and g == 1 and h2 == 1) then
			line = line .. (" coords=%s,%s,%s,%s,%s,%s,%s,%s"):format(Num(a), Num(b), Num(c), Num(d), Num(e), Num(f), Num(g), Num(h2))
		end
	end
	if r.GetRotation then
		local rot = ns.Try(r.GetRotation, r)
		if type(rot) == "number" and rot ~= 0 then
			line = line .. " rotation=" .. Num(rot)
		end
	end
	lines[#lines + 1] = line
end

local function Frame(lines, indent, parent, f, depth, skip)
	local key = (f.GetName and f:GetName()) or KeyOf(parent, f) or "-"
	local w, h = f:GetSize()
	lines[#lines + 1] = ("%sFRAME %s (%s) size=%sx%s scale=%s shown=%s level=%s pts=%s"):format(
		indent, key, f:GetObjectType(), Num(w), Num(h), Num(f:GetScale()), tostring(f:IsShown()),
		tostring(f:GetFrameLevel()), Points(f))
	for _, r in ipairs({ f:GetRegions() }) do
		if r:GetObjectType() == "Texture" then
			Texture(lines, indent .. "  ", f, r)
		end
	end
	if depth <= 0 then
		return
	end
	for _, child in ipairs({ f:GetChildren() }) do
		local name = child.GetName and child:GetName() or ""
		if not (skip and skip(name)) then
			Frame(lines, indent .. "  ", f, child, depth - 1, skip)
		end
	end
end

local window
local function Show(text)
	if not window then
		window = CreateFrame("Frame", "SetGoFetchDump", UIParent, "BasicFrameTemplateWithInset")
		window:SetSize(640, 440)
		window:SetPoint("CENTER")
		window:SetFrameStrata("DIALOG")
		window:SetMovable(true)
		window:EnableMouse(true)
		window:RegisterForDrag("LeftButton")
		window:SetScript("OnDragStart", window.StartMoving)
		window:SetScript("OnDragStop", window.StopMovingOrSizing)
		tinsert(UISpecialFrames, "SetGoFetchDump")
		if window.TitleText then
			window.TitleText:SetText("Fetch! dump (Ctrl+A, Ctrl+C)")
		end
		local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
		scroll:SetPoint("TOPLEFT", 12, -30)
		scroll:SetPoint("BOTTOMRIGHT", -30, 10)
		local edit = CreateFrame("EditBox", nil, scroll)
		edit:SetMultiLine(true)
		edit:SetAutoFocus(false)
		edit:SetFontObject(ChatFontNormal)
		edit:SetWidth(590)
		edit:SetScript("OnEscapePressed", function()
			window:Hide()
		end)
		scroll:SetScrollChild(edit)
		window.edit = edit
	end
	window.edit:SetText(text)
	window:Show()
	window.edit:SetFocus()
	window.edit:HighlightText()
end

function ns.Dump()
	local lines = {}
	local version = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("SetGo_Fetch", "Version")
	lines[#lines + 1] = "Fetch! " .. tostring(version) .. " / " .. tostring((GetBuildInfo()))
	local bar = _G.MainActionBar or _G.MainMenuBar
	if bar then
		lines[#lines + 1] = "== " .. (bar:GetName() or "?")
		-- the buttons are dumped once, below
		Frame(lines, "", UIParent, bar, 2, function(name)
			return name:match("^ActionButton%d+$") ~= nil
		end)
	else
		lines[#lines + 1] = "== no MainActionBar / MainMenuBar"
	end
	local b1, b2 = _G.ActionButton1, _G.ActionButton2
	if b1 then
		lines[#lines + 1] = "== ActionButton1"
		Frame(lines, "", bar, b1, 1)
		if b2 then
			local l1, l2 = b1:GetLeft(), b2:GetLeft()
			lines[#lines + 1] = ("gap 1>2 left=%s right1=%s left2=%s"):format(Num(l2 and l1 and (l2 - l1)), Num(b1:GetRight()), Num(l2))
		end
	end
	local text = table.concat(lines, "\n")
	if ns.layoutDB then
		ns.layoutDB.dump = text
	end
	Show(text)
end
