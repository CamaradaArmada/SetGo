local _, ns = ...
local LEM = ns.LibEditMode

local L = {
	NAME = "Action bar art",
	HEADER = "Action bar art (temporary)",
	TOGGLE = "Show a copy of the action bar art",
	TOGGLE_DESC = "A loose copy of the art behind action bar 1, to place in Edit Mode with its own scale and width. Blizzard's own art is not touched. It shows while action bar 1 is shown.",
	MISSING = "The action bar art was not found in this version of the game.",
	SCALE = "Scale",
	WIDTH = "Width",
}
if GetLocale() == "ptBR" then
	L.NAME = "Arte da barra de acção"
	L.HEADER = "Arte da barra de acção (temporário)"
	L.TOGGLE = "Mostrar uma cópia da arte da barra de acção"
	L.TOGGLE_DESC = "Uma cópia solta da arte por trás da barra de acção 1, para pores no Edit Mode com escala e largura próprias. A arte da Blizzard não é tocada. Aparece enquanto a barra de acção 1 estiver visível."
	L.MISSING = "A arte da barra de acção não foi encontrada nesta versão do jogo."
	L.SCALE = "Escala"
	L.WIDTH = "Largura"
end
ns.ArtL = L

--------------------------------------------------------------------------------
-- A loose copy of MainActionBar.BorderArt. Its pieces (left cap, middle, right
-- cap) are read once from Blizzard's art, only read, never changed, and drawn
-- on a frame of ours that Edit Mode can move. The caps keep their width, the
-- middle stretches with Width. It shows while action bar 1 is visible (our
-- frame isn't protected, so this works in combat too) and always in Edit Mode.
-- Not in profiles: the switch is the account's, the place, scale and width
-- are per Edit Mode layout.
-- SetGoHideDB._art = { on, layouts = { [layout] = { point, x, y, scale, width } } }
--------------------------------------------------------------------------------

local DEFAULTS = { point = "BOTTOM", x = 0, y = 140, scale = 100, width = 100 }
local FALLBACK = "__default"

local frame, pieces, base
local hooked, registered = false, false

local function Store()
	local db = ns.hideDB
	if type(db) ~= "table" then
		return { layouts = {} }
	end
	db._art = type(db._art) == "table" and db._art or {}
	local a = db._art
	a.layouts = type(a.layouts) == "table" and a.layouts or {}
	return a
end

function ns.ArtOn()
	return Store().on == true
end

local function ActiveName()
	local name = LEM and LEM.GetActiveLayoutName and LEM:GetActiveLayoutName()
	return name or FALLBACK
end

local function GetLayout(name)
	local layouts = Store().layouts
	name = name or ActiveName()
	local t = layouts[name]
	if type(t) ~= "table" then
		t = {}
		layouts[name] = t
	end
	for k, v in pairs(DEFAULTS) do
		if t[k] == nil then
			t[k] = v
		end
	end
	return t
end

-- Blizzard's bar and its art
local function Source()
	local bar = _G.MainActionBar or _G.MainMenuBar
	return bar and bar.BorderArt, bar
end

function ns.ArtExists()
	return Source() ~= nil
end

-- the look of one of Blizzard's textures on one of ours
local function CopyLook(src, dst)
	local atlas = src.GetAtlas and src:GetAtlas()
	if atlas and atlas ~= "" then
		dst:SetAtlas(atlas, false)
	else
		dst:SetTexture(src:GetTexture())
		dst:SetTexCoord(src:GetTexCoord())
	end
	if src.GetTextureSliceMargins and dst.SetTextureSliceMargins then
		local l, t, r, b = src:GetTextureSliceMargins()
		if l and (l + t + r + b) > 0 then
			dst:SetTextureSliceMargins(l, t, r, b)
			if src.GetTextureSliceMode and dst.SetTextureSliceMode then
				dst:SetTextureSliceMode(src:GetTextureSliceMode())
			end
		end
	end
	dst:SetVertexColor(src:GetVertexColor())
	dst:SetBlendMode(src:GetBlendMode())
	dst:SetAlpha(src:GetAlpha())
	local layer, sub = src:GetDrawLayer()
	dst:SetDrawLayer(layer or "ARTWORK", sub or 0)
end

-- Where each piece sits in Blizzard's art, in UIParent's units. A narrow
-- piece near the left or right edge is a cap (keeps its width); anything else
-- stretches between its two edges. nil until the art has been laid out.
local function Capture()
	local src = Source()
	if not src then
		return nil
	end
	local sl, sr, st, sb = src:GetLeft(), src:GetRight(), src:GetTop(), src:GetBottom()
	if not (sl and sr and st and sb) or sr - sl < 1 then
		return nil
	end
	local k = src:GetEffectiveScale() / UIParent:GetEffectiveScale()
	local W, H = (sr - sl) * k, (st - sb) * k
	local regions = {}
	if src:IsObjectType("Texture") then
		regions[1] = src
	else
		for _, r in ipairs({ src:GetRegions() }) do
			if r:IsObjectType("Texture") then
				regions[#regions + 1] = r
			end
		end
	end
	local parts = {}
	for _, r in ipairs(regions) do
		local l, rr, t, b = r:GetLeft(), r:GetRight(), r:GetTop(), r:GetBottom()
		if l and rr and t and b and rr > l then
			local p = {
				src = r,
				left = (l - sl) * k,
				right = (sr - rr) * k,
				top = (st - t) * k,
				bottom = (b - sb) * k,
				w = (rr - l) * k,
			}
			if p.w < W * 0.5 and p.left < W * 0.25 then
				p.anchor = "LEFT"
			elseif p.w < W * 0.5 and p.right < W * 0.25 then
				p.anchor = "RIGHT"
			else
				p.anchor = "BOTH"
			end
			parts[#parts + 1] = p
		end
	end
	if #parts == 0 then
		return nil
	end
	return { w = W, h = H, parts = parts }
end

local function UpdateShown()
	if not frame then
		return
	end
	local _, bar = Source()
	local editing = LEM and LEM.IsInEditMode and LEM:IsInEditMode()
	local show = ns.ArtOn() and (editing or (bar and bar:IsVisible()))
	frame:SetShown(show and true or false)
end

local function ApplyLayout()
	if not frame then
		return
	end
	local t = GetLayout()
	local s = (tonumber(t.scale) or 100) / 100
	local ws = (tonumber(t.width) or 100) / 100
	-- the caps keep their size: the extra width goes to the middle
	local capW = 0
	for _, pc in ipairs(pieces) do
		if pc.part.anchor ~= "BOTH" then
			capW = capW + pc.part.w
		end
	end
	local W = math.max(capW * s, base.w * s * ws)
	frame:SetSize(W, base.h * s)
	frame:ClearAllPoints()
	frame:SetPoint(t.point, UIParent, t.point, t.x, t.y)
	for _, pc in ipairs(pieces) do
		local p, tex = pc.part, pc.tex
		tex:ClearAllPoints()
		if p.anchor == "LEFT" then
			tex:SetPoint("TOPLEFT", frame, "TOPLEFT", p.left * s, -p.top * s)
			tex:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", p.left * s, p.bottom * s)
			tex:SetWidth(p.w * s)
		elseif p.anchor == "RIGHT" then
			tex:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -p.right * s, -p.top * s)
			tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -p.right * s, p.bottom * s)
			tex:SetWidth(p.w * s)
		else
			tex:SetPoint("TOPLEFT", frame, "TOPLEFT", p.left * s, -p.top * s)
			tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -p.right * s, p.bottom * s)
		end
	end
	UpdateShown()
end

local function Build()
	if frame then
		return true
	end
	local ok, cap = pcall(Capture)
	if not ok or not cap then
		return false
	end
	base = cap
	frame = CreateFrame("Frame", "SetGoHideArt", UIParent)
	frame:SetFrameStrata("LOW")
	frame:EnableMouse(false)
	frame:SetClampedToScreen(true)
	frame.editModeName = L.NAME
	pieces = {}
	for i, p in ipairs(cap.parts) do
		local tex = frame:CreateTexture(nil, "ARTWORK")
		CopyLook(p.src, tex)
		p.src = nil
		pieces[i] = { tex = tex, part = p }
	end
	return true
end

local function Slider(key, name, min, max)
	return {
		kind = LEM.SettingType.Slider,
		name = name,
		default = DEFAULTS[key],
		minValue = min,
		maxValue = max,
		valueStep = 1,
		get = function(layoutName)
			return GetLayout(layoutName)[key]
		end,
		set = function(layoutName, value)
			GetLayout(layoutName)[key] = math.floor(value + 0.5)
			ApplyLayout()
		end,
	}
end

-- once: Edit Mode knows the frame, its two sliders and the layouts
local function Register()
	if registered or not (frame and LEM and LEM.AddFrame) then
		return
	end
	registered = true
	LEM:AddFrame(frame, function(_, layoutName, point, x, y)
		local t = GetLayout(layoutName)
		t.point, t.x, t.y = point, x, y
		ApplyLayout()
	end, { point = DEFAULTS.point, x = DEFAULTS.x, y = DEFAULTS.y }, L.NAME)
	LEM:AddFrameSettings(frame, {
		Slider("scale", L.SCALE, 50, 200),
		Slider("width", L.WIDTH, 50, 300),
	})
	LEM:RegisterCallback("layout", ApplyLayout)
	LEM:RegisterCallback("enter", UpdateShown)
	LEM:RegisterCallback("exit", UpdateShown)
	LEM:RegisterCallback("create", function(layoutName, _, sourceName)
		local layouts = Store().layouts
		if sourceName and type(layouts[sourceName]) == "table" and layouts[layoutName] == nil then
			layouts[layoutName] = CopyTable(layouts[sourceName])
		end
	end)
	LEM:RegisterCallback("rename", function(oldName, newName)
		local layouts = Store().layouts
		if layouts[oldName] ~= nil then
			layouts[newName] = layouts[oldName]
			layouts[oldName] = nil
		end
	end)
	LEM:RegisterCallback("delete", function(layoutName)
		Store().layouts[layoutName] = nil
	end)
end

-- switched on: build it (once Blizzard's art is laid out), then show it
function ns.ArtStart()
	local _, bar = Source()
	if bar and not hooked then
		hooked = true
		-- only listening: action bar 1 shown or hidden (by Blizzard or Hide!)
		bar:HookScript("OnShow", function()
			if ns.ArtOn() and not frame then
				ns.ArtStart()
			else
				UpdateShown()
			end
		end)
		bar:HookScript("OnHide", UpdateShown)
	end
	if not ns.ArtOn() then
		UpdateShown()
		return
	end
	if Build() then
		Register()
		ApplyLayout()
	else
		-- not laid out yet: try again in a moment
		C_Timer.After(1, function()
			if ns.ArtOn() and not frame then
				if Build() then
					Register()
					ApplyLayout()
				end
			end
		end)
	end
end

function ns.ArtSetOn(on)
	Store().on = on and true or nil
	if ns.hideStarted then
		ns.ArtStart()
	end
end
