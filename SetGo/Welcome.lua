local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- The welcome shown the first time each character logs in with SetGo!: a
-- parchment like Blizzard's season notices. With no profile yet, one button
-- opens the guide to the first one. With profiles, a list of them and New
-- profile: picking one applies it at once.
--------------------------------------------------------------------------------

local W, H = 520, 470
local HEADLINE_FONT = "Fonts\\MORPHEUS.TTF"
local BODY_FONT = "Fonts\\FRIZQT__.TTF"
local INK = { 0.2824, 0.0157, 0.0157 } -- Blizzard's parchment text colour

local popup

local function HasAtlas(atlas)
	return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) ~= nil
end

local function Tex(layer, sub, atlas, w, h)
	local t = popup:CreateTexture(nil, layer, nil, sub)
	if HasAtlas(atlas) then
		t:SetAtlas(atlas)
	end
	if w then
		t:SetSize(w, h)
	end
	return t
end

-- Blizzard's parchment popup, piece by piece (Blizzard_ChallengesUI)
local function Parchment()
	local bg = Tex("BACKGROUND", 0, "parchmentpopup-background")
	bg:SetPoint("TOPLEFT", 20, -20)
	bg:SetPoint("BOTTOMRIGHT", -20, 20)
	if not HasAtlas("parchmentpopup-background") then
		bg:SetColorTexture(0.86, 0.79, 0.64, 1)
		return
	end
	local tl = Tex("ARTWORK", 2, "parchmentpopup-topleft", 167, 167)
	tl:SetPoint("TOPLEFT")
	local tr = Tex("ARTWORK", 2, "parchmentpopup-topright", 167, 167)
	tr:SetPoint("TOPRIGHT", -1, 0)
	local bl = Tex("ARTWORK", 2, "parchmentpopup-bottomleft", 167, 167)
	bl:SetPoint("BOTTOMLEFT")
	local br = Tex("ARTWORK", 2, "parchmentpopup-bottomright", 167, 167)
	br:SetPoint("BOTTOMRIGHT")
	local top = Tex("ARTWORK", 3, "parchmentpopup-top", 256, 167)
	top:SetPoint("TOPLEFT", tl, "TOPRIGHT", 0, -1)
	top:SetPoint("TOPRIGHT", tr, "TOPLEFT", 0, -1)
	local bottom = Tex("ARTWORK", 3, "parchmentpopup-bottom", 256, 167)
	bottom:SetPoint("BOTTOMLEFT", bl, "BOTTOMRIGHT", 0, 2)
	bottom:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT", 0, 2)
	local left = Tex("ARTWORK", 3, "parchmentpopup-left", 167, 256)
	left:SetPoint("TOPLEFT", tl, "BOTTOMLEFT", 2, 0)
	left:SetPoint("BOTTOMLEFT", bl, "TOPLEFT", 2, 0)
	local right = Tex("ARTWORK", 3, "parchmentpopup-right", 167, 256)
	right:SetPoint("TOPRIGHT", tr, "BOTTOMRIGHT")
	right:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT")
	local fl = Tex("ARTWORK", 5, "parchmentpopup-filigree")
	fl:SetAtlas("parchmentpopup-filigree", true)
	fl:SetPoint("TOPLEFT", 5, 2)
	fl:SetBlendMode("ADD")
	fl:SetAlpha(0.45)
	local fr = Tex("ARTWORK", 5, "parchmentpopup-filigree")
	fr:SetAtlas("parchmentpopup-filigree", true)
	fr:SetPoint("TOPRIGHT", -5, 2)
	fr:SetTexCoord(1, 0, 0, 1)
	fr:SetBlendMode("ADD")
	fr:SetAlpha(0.45)
end

local function Text(font, size, width, text, justify)
	local fs = popup:CreateFontString(nil, "OVERLAY")
	-- a font object first, in case the file can't be set
	fs:SetFontObject(GameFontNormal)
	fs:SetFont(font, size, "")
	fs:SetTextColor(INK[1], INK[2], INK[3])
	fs:SetShadowColor(0, 0, 0, 0)
	fs:SetJustifyH(justify or "CENTER")
	if width then
		fs:SetWidth(width)
	end
	fs:SetText(text or "")
	return fs
end

-- one of the player's profiles: applied at once (a reload follows when
-- something changes)
local function ApplyChosen(name)
	if not ns.ProfileOf(name) then
		return
	end
	popup:Hide()
	ns.ApplyProfile(name)
end

-- SetGo! on a new profile (the guide when there is none)
local function NewProfile()
	popup:Hide()
	-- the first one: the guide
	if #ns.ProfileSlots() == 0 and ns.ShowWizard then
		ns.ShowWizard()
		return
	end
	ns.Open(true)
	ns.LeaveForm(function()
		ns.OpenForm(nil)
	end)
end

local function Create()
	popup = CreateFrame("Frame", "SetGoWelcome", UIParent)
	popup:SetSize(W, H)
	popup:SetPoint("CENTER", 0, 60)
	popup:SetFrameStrata("DIALOG")
	popup:SetToplevel(true)
	popup:EnableMouse(true)
	popup:SetMovable(true)
	popup:SetClampedToScreen(true)
	popup:RegisterForDrag("LeftButton")
	popup:SetScript("OnDragStart", popup.StartMoving)
	popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
	table.insert(UISpecialFrames, "SetGoWelcome")
	Parchment()

	local close = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -28, -28)

	local inner = W - 120
	local headline = Text(HEADLINE_FONT, 36, inner, L.WELCOME_HEADLINE)
	headline:SetPoint("TOP", 0, -64)
	local sub = Text(BODY_FONT, 15, inner, L.WELCOME_SUB)
	sub:SetPoint("TOP", headline, "BOTTOM", 0, -10)

	-- no profile yet: the guide
	popup.start = ns.Widgets.Button(popup, 200, L.WELCOME_START, NewProfile, 26)
	popup.start:SetPoint("TOP", sub, "BOTTOM", 0, -60)
	ns.Widgets.TipScripts(popup.start, L.WELCOME_START, L.WELCOME_START_DESC)

	-- the player's profiles, and a new one
	popup.pickLabel = Text(BODY_FONT, 13, inner, L.WELCOME_PICK)
	popup.pickLabel:SetPoint("TOP", sub, "BOTTOM", 0, -40)
	local dd = CreateFrame("DropdownButton", nil, popup, "WowStyle1DropdownTemplate")
	dd:SetPoint("TOP", popup.pickLabel, "BOTTOM", 0, -10)
	dd:SetWidth(240)
	Try(dd.SetDefaultText, dd, L.WELCOME_CHOOSE)
	popup.dd = dd

	-- SetGo! itself
	local open = ns.Widgets.Button(popup, 200, L.OPEN, function()
		popup:Hide()
		ns.Open(true)
	end, 26)
	open:SetPoint("BOTTOM", 0, 58)
	ns.Widgets.TipScripts(open, L.OPEN, L.HELLO_FULL_DESC)
end

local function Refresh()
	local names = ns.ProfileSlots()
	local any = #names > 0
	popup.start:SetShown(not any)
	popup.pickLabel:SetShown(any)
	popup.dd:SetShown(any)
	if not any then
		return
	end
	popup.dd:SetupMenu(function(_, root)
		for _, name in ipairs(names) do
			root:CreateButton(name, function()
				ApplyChosen(name)
			end)
		end
		root:CreateDivider()
		root:CreateButton(L.NEW_PRESET, NewProfile)
	end)
end

function ns.ShowWelcome()
	-- no profile yet: the guide to the first one
	if #ns.ProfileSlots() == 0 and ns.ShowWizard and not ns.db.wizardSkipped then
		ns.ShowWizard()
		return
	end
	if not popup then
		Create()
	end
	Refresh()
	popup:Show()
end
