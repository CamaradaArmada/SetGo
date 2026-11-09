local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- UI Tweaks: small changes to Blizzard's interface, still experimental.
-- One page in the SetGo! tab, between SetGo!'s own page and the Backup.
--   Kept per profile but not part of it: SetGoDB.tweaks[profile id], or
--   ["none"] while this character has no profile in use. Not on the profile
--   form, not copied, exported or in presets. A new profile starts with all
--   of them off. Changing one saves it at once into the profile in use;
--   switching profiles applies the other set at once (no reload).
--   Each option is a SetGo.Pseudo with a plain value, so one that stops
--   being experimental can move into the profile under the same name.
--------------------------------------------------------------------------------

local T = {
	TITLE = "UI Tweaks",
	DESC = "Experimental changes to Blizzard's interface. Each profile keeps its own.",
	NOTE = "Saved in the profile in use, but not part of it: they aren't copied, exported or in presets. A new profile starts with all of them off.",
	LOOT = "Loot",
	SPARKLES = "Quest item sparkles",
	SPARKLES_DESC = "Quest items on the ground always show the game's loot sparkle, even after a graphics preset turns it off. Switching it off takes effect after restarting the game (/reload is not enough). Forever Loot Sparkles does the same: you don't need both.",
	SPARKLES_MISSING = "This client doesn't have the setting.",
	SPARKLES_RESTART = "Restart the game to remove the quest item sparkles. /reload is not enough.",
	BARS = "Action bars",
	BARS_NOTE = "Action bar 1's art on other bars: the frame around the bar, the slot behind each button and, at the smallest padding, the dividers.",
	BAR = "Action Bar %d",
	BAR_DESC = "Draws action bar 1's art on this bar.",
	XP = "Experience bar",
	XP_BETTER = "Better XP bar",
	XP_BETTER_DESC = "The experience and reputation bars with the options below. Off: as Blizzard has them.",
	XP_WIDTH = "Width",
	XP_WIDTH_DESC = "How wide the bars are, from a quarter of Blizzard's width to all of it, in 1% steps. Edit Mode's Size still changes their scale.",
	XP_UNIFIED = "Unified Bar",
	XP_UNIFIED_DESC = "While you track a reputation, one bar instead of two: right click it to switch between experience and reputation. It starts on experience every time you log in.",
	MINIMAP = "Minimap",
	TRACK = "SetGo! Tracker",
	BARS_LABEL = "Bar 1's art on",
	BARS_NONE = "None",
	BARS_SOME = "Bars %s",
	BAGS = "Bags",
	BAGS_ALL = "Open All Bags with Right Click",
	BAGS_ALL_DESC = "A right click on the backpack button opens or closes all your bags at once. A left click still opens only the backpack.",
	QUESTS = "Objective tracker",
	QFILTER = "Quest filter button",
	QFILTER_DESC = "A button next to the objective tracker's minimize button. Left click: track only the quests of the zone you are in. Right click: All, or one zone of your quest log.",
	QFILTER_TITLE = "Quest filter",
	QFILTER_ALL = "All",
	QFILTER_NOW = "Last filter: %s",
	QFILTER_HINT_ZONE = "Left click: this zone's quests",
	QFILTER_HINT_MENU = "Right click: choose",
	QFILTER_NONE = "Your quest log has no quests for %s.",
	QFILTER_HIGH = "Untrack High Level",
	QFILTER_HIGH_DESC = "Stops tracking the quests the game shows in orange or red: 3 or more levels above yours.",
	QFILTER_HIGH_DONE = "%d high level quests untracked.",
	QMIN = "Simplified Minimized Tracker",
	QMIN_DESC = "While the objective tracker is minimized, only its minimize button shows: no title, no background, no other buttons.",
	TRACK_DESC = "A button next to the minimap's day and night button for your tracking skills (herbs, minerals, treasure, beasts and others). In colour while one is on, in grey while it is off; none, while you have no tracking skill. Left click: on or off. Right click: choose which.",
	TRACK_HINT_TOGGLE = "Left click: on or off",
	TRACK_HINT_CHOOSE = "Right click: choose",
	TRACK_OFF = "Off",
	TRACK_COMBAT = "The tracking skill can't be chosen in combat.",
	TRACK_UNLOCK = "Unlock frame",
	TRACK_UNLOCK_DESC = "Drag the button to move it (out of combat). Untick to lock it where it is.",
}
if GetLocale() == "ptBR" then
	T.DESC = "Alterações experimentais à interface da Blizzard. Cada perfil tem as suas."
	T.NOTE = "Guardadas no perfil em uso, mas não fazem parte dele: não são copiadas, exportadas nem vão nos presets. Um perfil novo começa com todas desligadas."
	T.LOOT = "Saque"
	T.SPARKLES = "Brilho nos objectos de missão"
	T.SPARKLES_DESC = "Os objectos de missão no chão mostram sempre o brilho de saque do jogo, mesmo depois de um preset de gráficos o desligar. Desligar só faz efeito depois de reiniciar o jogo (/reload não chega). O Forever Loot Sparkles faz o mesmo: não precisas dos dois."
	T.SPARKLES_MISSING = "Este cliente não tem esta definição."
	T.SPARKLES_RESTART = "Reinicia o jogo para tirar o brilho dos objectos de missão. /reload não chega."
	T.BARS = "Barras de acção"
	T.BARS_NOTE = "A arte da barra de acção 1 noutras barras: a moldura à volta da barra, o fundo de cada botão e, com o espaçamento mínimo, os separadores."
	T.BAR = "Barra de acção %d"
	T.BAR_DESC = "Desenha a arte da barra de acção 1 nesta barra."
	T.XP = "Barra de experiência"
	T.XP_BETTER = "Better XP bar"
	T.XP_BETTER_DESC = "As barras de experiência e de reputação com as opções abaixo. Desligada: como a Blizzard as tem."
	T.XP_WIDTH = "Largura"
	T.XP_WIDTH_DESC = "A largura das barras, de um quarto da largura da Blizzard até à largura toda, em passos de 1%. O Tamanho do Edit Mode continua a mudar a escala."
	T.XP_UNIFIED = "Unified Bar"
	T.XP_UNIFIED_DESC = "Enquanto segues uma reputação, uma barra em vez de duas: clique direito para trocar entre experiência e reputação. Começa sempre na experiência quando entras no jogo."
	T.MINIMAP = "Minimapa"
	T.TRACK = "SetGo! Tracker"
	T.BARS_LABEL = "Arte da barra 1 em"
	T.BARS_NONE = "Nenhuma"
	T.BARS_SOME = "Barras %s"
	T.BAGS = "Sacos"
	T.BAGS_ALL = "Abrir todos os sacos com clique direito"
	T.BAGS_ALL_DESC = "Um clique direito no botão da mochila abre ou fecha todos os teus sacos de uma vez. O clique esquerdo continua a abrir só a mochila."
	T.QUESTS = "Tracker de objectivos"
	T.QFILTER = "Botão de filtro das missões"
	T.QFILTER_DESC = "Um botão ao lado do botão de minimizar do tracker de objectivos. Clique esquerdo: seguir só as missões da zona onde estás. Clique direito: Todas, ou uma zona do diário de missões."
	T.QFILTER_TITLE = "Filtro das missões"
	T.QFILTER_ALL = "Todas"
	T.QFILTER_NOW = "Último filtro: %s"
	T.QFILTER_HINT_ZONE = "Clique esquerdo: missões desta zona"
	T.QFILTER_HINT_MENU = "Clique direito: escolher"
	T.QFILTER_NONE = "O teu diário não tem missões de %s."
	T.QFILTER_HIGH = "Deixar de seguir as de nível alto"
	T.QFILTER_HIGH_DESC = "Deixa de seguir as missões que o jogo mostra a laranja ou a vermelho: 3 ou mais níveis acima do teu."
	T.QFILTER_HIGH_DONE = "%d missões de nível alto deixaram de ser seguidas."
	T.QMIN = "Tracker minimizado simplificado"
	T.QMIN_DESC = "Com o tracker de objectivos minimizado, só se vê o botão de minimizar: sem título, sem fundo e sem outros botões."
	T.TRACK_DESC = "Um botão ao lado do botão do dia e da noite do minimapa para as tuas habilidades de tracking (ervas, minérios, tesouros, bestas e outras). A cores com uma ligada, a cinzento com ela desligada; não aparece se não tiveres nenhuma. Clique esquerdo: ligar ou desligar. Clique direito: escolher qual."
	T.TRACK_HINT_TOGGLE = "Clique esquerdo: ligar ou desligar"
	T.TRACK_HINT_CHOOSE = "Clique direito: escolher"
	T.TRACK_OFF = "Desligado"
	T.TRACK_COMBAT = "Não é possível escolher a habilidade de tracking em combate."
	T.TRACK_UNLOCK = "Desbloquear"
	T.TRACK_UNLOCK_DESC = "Arrasta o botão para o mudar de sítio (fora de combate). Desmarca para o fixar onde está."
end
L.TWEAKS_TITLE = T.TITLE
L.TWEAKS_DESC = T.DESC
ns.TWEAKS_ICON = "Interface\\Icons\\INV_Misc_Wrench_01"

--------------------------------------------------------------------------------
-- Where they are kept
--------------------------------------------------------------------------------

local function Key()
	local name = ns.ActivePreset and ns.ActivePreset()
	local p = name and ns.ProfileOf(name)
	if p then
		return p.id or name
	end
	return "none"
end

local function Store()
	if type(ns.db.tweaks) ~= "table" then
		ns.db.tweaks = {}
	end
	local key = Key()
	if type(ns.db.tweaks[key]) ~= "table" then
		ns.db.tweaks[key] = {}
	end
	return ns.db.tweaks[key]
end

local function On(var)
	return ns.db ~= nil and Store()[var] == true
end

local function Keep(var, on)
	Store()[var] = on and true or nil
end

-- a number (nil: the default)
local function Value(var, default)
	local v = ns.db and tonumber(Store()[var])
	return v or default
end

local function KeepValue(var, value, default)
	value = tonumber(value)
	Store()[var] = (value and value ~= default) and value or nil
end

-- a deleted profile takes its tweaks with it
local DeleteProfile = ns.DeleteProfile
function ns.DeleteProfile(name)
	local p = ns.ProfileOf and ns.ProfileOf(name)
	DeleteProfile(name)
	if p and p.id and type(ns.db.tweaks) == "table" then
		ns.db.tweaks[p.id] = nil
	end
end

local pendingCombat = false
local events = CreateFrame("Frame")

--------------------------------------------------------------------------------
-- Quest item sparkles: one hidden setting the graphics presets put back to
-- 0, so it is set again when they change it. Out of combat. Switching it
-- off writes 0 once (only if SetGo! turned it on); the sparkles stay until
-- the game restarts.
--------------------------------------------------------------------------------

local SPARKLE_CVAR = "outlineModeShowLootEffectWhenDisabled"
local SPARKLE_WATCH = {
	graphicsquality = true,
	raidgraphicsquality = true,
	[SPARKLE_CVAR:lower()] = true,
}
local VAR_SPARKLES = "SETGO_TWEAK_SPARKLES"
local sparklesShown = false
local writing = false

local function SparkleCVarExists()
	return C_CVar and C_CVar.GetCVar and C_CVar.GetCVar(SPARKLE_CVAR) ~= nil
end

local function WriteSparkles(value)
	if C_CVar.GetCVar(SPARKLE_CVAR) == value then
		return
	end
	writing = true
	Try(C_CVar.SetCVar, SPARKLE_CVAR, value)
	writing = false
end

-- byPlayer: the box was clicked (the restart note)
local function ApplySparkles(byPlayer)
	if not SparkleCVarExists() then
		return
	end
	if InCombatLockdown() then
		pendingCombat = true
		return
	end
	if On(VAR_SPARKLES) then
		WriteSparkles("1")
		ns.db.tweakSparkles = true
		sparklesShown = true
	elseif ns.db.tweakSparkles then
		-- only what SetGo! turned on is turned off
		ns.db.tweakSparkles = nil
		WriteSparkles("0")
		if sparklesShown and byPlayer then
			ns.Print(T.SPARKLES_RESTART)
		end
	end
end

--------------------------------------------------------------------------------
-- Action bar 1's art on Blizzard's bars 2 to 8 (ns.Art, shared with
-- Fetch!). Textures and plain frames only, out of combat; follows each
-- bar's Edit Mode layout (hooked after Blizzard lays it out). Off: the
-- buttons look as Blizzard draws these bars (no slot art, the wider frame).
--------------------------------------------------------------------------------

local Art = ns.Art
local BARS = {
	{ n = 2, frame = "MultiBarBottomLeft" },
	{ n = 3, frame = "MultiBarBottomRight" },
	{ n = 4, frame = "MultiBarRight" },
	{ n = 5, frame = "MultiBarLeft" },
	{ n = 6, frame = "MultiBar5" },
	{ n = 7, frame = "MultiBar6" },
	{ n = 8, frame = "MultiBar7" },
}
local function BarVar(n)
	return "SETGO_TWEAK_BARART_" .. n
end

local art = {} -- [bar frame] = { n, frame (texture), dividers = {}, on }
local queued = {}

local function SetButtonLook(b, on)
	if not (b.SlotArt and b.SlotBackground) then
		return
	end
	b.SlotArt:SetShown(on)
	b.SlotBackground:SetShown(not on)
	-- the border bar 1 has, or the one the other bars have (as Blizzard's
	-- UpdateButtonArt sets them)
	local normal = on and "UI-HUD-ActionBar-IconFrame" or "UI-HUD-ActionBar-IconFrame-AddRow"
	local pushed = on and "UI-HUD-ActionBar-IconFrame-Down" or "UI-HUD-ActionBar-IconFrame-AddRow-Down"
	local w, h = 46, 45
	if not on then
		w, h = 51, 51
	end
	if Art.AtlasExists(normal) and b.SetNormalAtlas and b.NormalTexture then
		Try(b.SetNormalAtlas, b, normal)
		b.NormalTexture:SetDrawLayer("OVERLAY")
		b.NormalTexture:SetSize(w, h)
	end
	if Art.AtlasExists(pushed) and b.SetPushedAtlas and b.PushedTexture then
		Try(b.SetPushedAtlas, b, pushed)
		b.PushedTexture:SetDrawLayer("OVERLAY")
		b.PushedTexture:SetSize(w, h)
	end
end

local function ButtonScale(bar)
	local b = bar.actionButtons and bar.actionButtons[1]
	local c = b and b.container
	return c and tonumber(c:GetScale()) or 1
end

-- the dividers as bar 1 has them: one row, the smallest padding, between
-- buttons shown side by side
local function Dividers(bar, st, on)
	local keep = {}
	local rows = tonumber(bar.numRows) or 1
	local pad = tonumber(bar.buttonPadding) or Art.MIN_SPACING
	local min = tonumber(bar.minButtonPadding) or Art.MIN_SPACING
	if on and rows <= 1 and pad <= min then
		local side = bar.isHorizontal == false and "TOP" or "LEFT"
		local scale = ButtonScale(bar)
		local lastShown = false
		for i, b in ipairs(bar.actionButtons or {}) do
			if b:IsShown() then
				if lastShown then
					local d = Art.PlaceDivider(st.dividers, bar, i, b, side)
					if d then
						d:SetScale(scale)
						keep[d] = true
					end
				end
				lastShown = true
			else
				lastShown = false
			end
		end
	end
	Art.HideAll(st.dividers, keep)
end

local HookBar

local function ApplyBar(bar, n)
	if InCombatLockdown() then
		pendingCombat = true
		return
	end
	local on = On(BarVar(n))
	local st = art[bar]
	if not st then
		if not on then
			-- never touched: Blizzard's own look stays
			return
		end
		st = { n = n, dividers = {} }
		st.frame = Art.FrameTexture(bar)
		art[bar] = st
		HookBar(bar, st)
	end
	if st.frame then
		st.frame:SetScale(ButtonScale(bar))
		st.frame:SetShown(on)
	end
	if on or st.on then
		for _, b in ipairs(bar.actionButtons or {}) do
			SetButtonLook(b, on)
		end
	end
	st.on = on
	Dividers(bar, st, on)
end

-- once per frame at most, after Blizzard is done laying the bar out
local function Queue(bar)
	local st = art[bar]
	if not st or queued[bar] then
		return
	end
	queued[bar] = true
	C_Timer.After(0, function()
		queued[bar] = nil
		Try(ApplyBar, bar, st.n)
	end)
end

HookBar = function(bar, st)
	local function Again()
		Queue(bar)
	end
	for _, method in ipairs({ "UpdateGridLayout", "UpdateShownButtons", "UpdateSystemSettingIconSize", "UpdateSystemSettingIconPadding" }) do
		if type(bar[method]) == "function" then
			hooksecurefunc(bar, method, Again)
		end
	end
	bar:HookScript("OnShow", Again)
	for _, b in ipairs(bar.actionButtons or {}) do
		-- empty buttons come and go (dragging, the grid)
		b:HookScript("OnShow", Again)
		b:HookScript("OnHide", Again)
		-- Blizzard redrawing the button puts its own look back
		if type(b.UpdateButtonArt) == "function" then
			hooksecurefunc(b, "UpdateButtonArt", function(self)
				if st.on then
					SetButtonLook(self, true)
				end
			end)
		end
	end
end

local function ApplyBars()
	for _, def in ipairs(BARS) do
		local bar = _G[def.frame]
		if bar and bar.actionButtons then
			Try(ApplyBar, bar, def.n)
		end
	end
end


--------------------------------------------------------------------------------
-- Better XP bar: Blizzard's experience and reputation bars
-- (StatusTrackingBarManager: the main container has experience, the second
-- one reputation; at max level reputation moves to the main one).
--   Width: only the bars inside each container and its frame art get
--   narrower, centred. The containers keep their size: Blizzard lays the
--   action bars out around them, and changing that from here would taint it.
--   Unified Bar: while both show, the second one's bars go invisible (not
--   hidden: the layout stays as it is) and its reputation bar sits over the
--   main one; a right click switches which of the two shows. Each container
--   keeps updating its own bar as Blizzard has it. Back to experience at
--   every login.
--------------------------------------------------------------------------------

local VAR_XP = "SETGO_TWEAK_XPBAR"
local VAR_XP_WIDTH = "SETGO_TWEAK_XPBAR_WIDTH"
local VAR_XP_UNIFIED = "SETGO_TWEAK_XPBAR_UNIFIED"
local XP_MIN, XP_MAX, XP_STEP = 0.25, 1, 0.01
local showRep = false
local xpHooked = false
local xpQueued = false

local function Enum_()
	return StatusTrackingBarInfo and StatusTrackingBarInfo.BarsEnum
end

local function Containers()
	local m = StatusTrackingBarManager
	return m and m.MainStatusTrackingBarContainer, m and m.SecondaryStatusTrackingBarContainer
end

local function XPWidth()
	if not On(VAR_XP) then
		return 1
	end
	local w = Value(VAR_XP_WIDTH, 1)
	return math.max(XP_MIN, math.min(XP_MAX, w))
end

-- Each bar as Blizzard placed it in its container (its anchor and width,
-- read the first time): only the width changes, and the bar moves right by
-- half of what it lost, so it stays centred. rel: the container it is
-- drawn against (the main one, for the Unified Bar's reputation bar).
local function BarBase(bar)
	if not bar.sgBase then
		local point, relTo, relPoint, x, y = bar:GetPoint(1)
		local w = bar:GetWidth()
		if not (point and w and w > 0) then
			return nil
		end
		bar.sgBase = { point = point, relPoint = relPoint, x = x or 0, y = y or 0, w = w, home = relTo }
	end
	return bar.sgBase
end

local function PlaceBar(bar, c, pct)
	local b = BarBase(bar)
	if not b then
		return
	end
	local w = b.w * pct
	bar:SetWidth(w)
	if bar.StatusBar then
		bar.StatusBar:SetWidth(w)
	end
	-- against its own container, or the one it is shown over
	local rel = c
	if b.home and b.home ~= bar:GetParent() and c == bar:GetParent() then
		rel = b.home
	end
	bar:ClearAllPoints()
	bar:SetPoint(b.point, rel, b.relPoint, b.x + (b.w - w) / 2, b.y)
end

-- the frame art: narrower, sliced so its ends keep their shape. It keeps
-- Blizzard's own anchor (only its width changes), so it stays exactly
-- where it was against the bar; an anchor on one side only (it would not
-- stay centred) is replaced by its top edge, in whole pixels.
local function PlaceFrameArt(c, pct)
	local tex = c.BarFrameTexture
	if not tex then
		return
	end
	if not tex.sgBase then
		local w, h = tex:GetWidth(), tex:GetHeight()
		if not (w and w > 0) then
			return
		end
		local points = {}
		for i = 1, tex:GetNumPoints() do
			points[i] = { tex:GetPoint(i) }
		end
		local base = { w = w, h = h, points = points }
		-- one centred anchor keeps the art centred as it narrows
		local p1 = points[1] and points[1][1]
		base.keep = #points == 1 and (p1 == "CENTER" or p1 == "TOP" or p1 == "BOTTOM")
		if not base.keep then
			local tx, ty = tex:GetCenter()
			local cx, cy = c:GetCenter()
			local top, ctop = tex:GetTop(), c:GetTop()
			if not (tx and cx and top and ctop) then
				return
			end
			base.x = math.floor(tx - cx + 0.5)
			base.top = math.floor(top - ctop + 0.5)
		end
		tex.sgBase = base
	end
	local b = tex.sgBase
	if pct < 1 and not tex.sgSliced and tex.SetTextureSliceMargins then
		tex.sgSliced = pcall(tex.SetTextureSliceMargins, tex, 24, 0, 24, 0)
		if tex.sgSliced and tex.SetTextureSliceMode then
			pcall(tex.SetTextureSliceMode, tex, 0)
		end
	end
	if b.keep then
		-- Blizzard's anchor, as it was
		tex:ClearAllPoints()
		for _, pt in ipairs(b.points) do
			tex:SetPoint(unpack(pt))
		end
	elseif pct < 1 or #b.points == 0 then
		tex:ClearAllPoints()
		tex:SetPoint("TOP", c, "TOP", b.x, b.top)
	else
		-- full width: Blizzard's anchors back
		tex:ClearAllPoints()
		for _, pt in ipairs(b.points) do
			tex:SetPoint(unpack(pt))
		end
	end
	tex:SetSize(b.w * pct, b.h)
end

local function ShowBar(bar, on)
	bar:SetAlpha(on and 1 or 0)
	bar:EnableMouse(on)
end

-- the bar a container shows: Blizzard's index, read from the container,
-- its own method, or the bar shown (clients differ)
local function ShownIndex(c)
	if c.shownBarIndex ~= nil then
		return c.shownBarIndex
	end
	local shown
	if c.GetShownBar then
		local ok, bar = pcall(c.GetShownBar, c)
		shown = ok and bar or nil
	end
	for index, bar in pairs(c.bars or {}) do
		if (shown and bar == shown) or (not shown and bar:IsShown()) then
			return index
		end
	end
end

-- While one container shows experience and the other reputation (either
-- way round: the clients differ): the main container's bar, the second
-- one's, and the main one's index. nil otherwise.
local function Pair()
	local E = Enum_()
	local main, second = Containers()
	if not (E and main and second and On(VAR_XP) and On(VAR_XP_UNIFIED) and second:IsShown()) then
		return nil
	end
	local mi, si = ShownIndex(main), ShownIndex(second)
	if (mi == E.Experience and si == E.Reputation) or (mi == E.Reputation and si == E.Experience) then
		return main.bars[mi], second.bars[si], mi
	end
end

local function UnifiedActive()
	return Pair() ~= nil
end

local HookXP

-- the right click: our own invisible button over the main bar (the bars
-- don't take the mouse on every client). It passes the mouse over on to
-- the bar showing, for its tooltip and text.
local catcher
local function VisibleBar()
	local mainBar, otherBar = Pair()
	if not mainBar then
		return nil
	end
	return mainBar:GetAlpha() > 0 and mainBar or otherBar
end

local function Catcher(main)
	if catcher then
		return catcher
	end
	catcher = CreateFrame("Button", nil, main)
	catcher:SetAllPoints(main)
	catcher:SetFrameStrata("MEDIUM")
	catcher:SetFrameLevel(main:GetFrameLevel() + 20)
	catcher:RegisterForClicks("RightButtonUp")
	if catcher.SetPassThroughButtons then
		pcall(catcher.SetPassThroughButtons, catcher, "LeftButton")
	end
	catcher:SetScript("OnClick", function(self)
		if UnifiedActive() then
			local bar = VisibleBar()
			local leave = bar and bar:GetScript("OnLeave")
			if leave then
				pcall(leave, bar)
			end
			showRep = not showRep
			Try(ns.ApplyXPBarNow)
			bar = VisibleBar()
			local enter = bar and bar:GetScript("OnEnter")
			if enter and self:IsMouseOver() then
				pcall(enter, bar)
			end
		end
	end)
	catcher:SetScript("OnEnter", function()
		local bar = VisibleBar()
		local enter = bar and bar:GetScript("OnEnter")
		if enter then
			pcall(enter, bar)
		end
	end)
	catcher:SetScript("OnLeave", function()
		local bar = VisibleBar()
		local leave = bar and bar:GetScript("OnLeave")
		if leave then
			pcall(leave, bar)
		elseif GameTooltip then
			GameTooltip:Hide()
		end
	end)
	catcher:Hide()
	return catcher
end

local function ApplyXPBar()
	local E = Enum_()
	local main, second = Containers()
	if not (E and main and second and main.bars and second.bars) then
		return
	end
	local on = On(VAR_XP)
	if not on and not xpHooked then
		-- never touched: Blizzard's own look stays
		return
	end
	HookXP()
	local pct = XPWidth()
	-- what the Unified Bar made invisible besides the bars (this client's
	-- dividers): back as it was
	for _, f in ipairs({ second:GetChildren() }) do
		if f.sgAlpha then
			f:SetAlpha(f.sgAlpha)
			f.sgAlpha = nil
		end
	end
	for _, c in ipairs({ main, second }) do
		for _, bar in pairs(c.bars) do
			PlaceBar(bar, c, pct)
			ShowBar(bar, true)
		end
		PlaceFrameArt(c, pct)
		if c.BarFrameTexture then
			c.BarFrameTexture:SetAlpha(1)
		end
		Try(c.UpdateBarTick, c)
	end
	local mainBar, otherBar, mi = Pair()
	if mainBar and otherBar then
		-- the second container: nothing of it shows
		for _, bar in pairs(second.bars) do
			ShowBar(bar, false)
		end
		if second.BarFrameTexture then
			second.BarFrameTexture:SetAlpha(0)
		end
		-- and the rest of what it draws (this client adds dividers of its
		-- own), but Edit Mode's selection
		local isBar = {}
		for _, bar in pairs(second.bars) do
			isBar[bar] = true
		end
		for _, f in ipairs({ second:GetChildren() }) do
			if not isBar[f] and f ~= second.Selection then
				f.sgAlpha = f:GetAlpha()
				f:SetAlpha(0)
			end
		end
		-- its bar over the main one; experience or reputation shows
		PlaceBar(otherBar, main, pct)
		otherBar:SetFrameLevel(math.max(mainBar:GetFrameLevel(), 1) + 1)
		local mainIsRep = mi == E.Reputation
		local showMain = showRep == mainIsRep
		ShowBar(mainBar, showMain)
		ShowBar(otherBar, not showMain)
		Catcher(main):Show()
	elseif catcher then
		catcher:Hide()
	end
end
ns.ApplyXPBarNow = ApplyXPBar

local function QueueXP()
	if xpQueued then
		return
	end
	xpQueued = true
	C_Timer.After(0, function()
		xpQueued = false
		Try(ApplyXPBar)
	end)
end

HookXP = function()
	if xpHooked then
		return
	end
	xpHooked = true
	local E = Enum_()
	local main, second = Containers()
	if StatusTrackingBarManager and StatusTrackingBarManager.UpdateBarsShown then
		hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", QueueXP)
	end
	for _, c in ipairs({ main, second }) do
		if type(c.ApplyPendingBarToShow) == "function" then
			hooksecurefunc(c, "ApplyPendingBarToShow", QueueXP)
		end
		c:HookScript("OnShow", QueueXP)
		c:HookScript("OnHide", QueueXP)
	end
end

--------------------------------------------------------------------------------
-- Tracking button: a minimap button like the other addons' (on the edge,
-- dragged around it), shaped as they are. Only while the character has a
-- tracking skill. Its icon: the one on, in colour; else the last one used
-- (SetGoCharDB.tracking, per character), in grey.
--   Left click: Blizzard's secure button casts it, or cancels its buff (as a
--   right click on the buff does), in combat too. What it does is set out of
--   combat only; a change during combat is caught up when it ends.
--   Right click: a menu to choose which one (out of combat; a menu can't
--   cast, so the left click then turns it on).
--------------------------------------------------------------------------------

local VAR_TRACK = "SETGO_TWEAK_TRACKING"
-- the tracking skills, as spell IDs (the ones this character knows show)
local TRACKING = {
	2383, -- Find Herbs
	2580, -- Find Minerals
	2481, -- Find Treasure
	1494, -- Track Beasts
	19883, -- Track Humanoids (hunter)
	5225, -- Track Humanoids (druid)
	19884, -- Track Undead
	19885, -- Track Hidden
	19880, -- Track Elementals
	19878, -- Track Demons
	19882, -- Track Giants
	19879, -- Track Dragonkin
	5502, -- Sense Undead
	5500, -- Sense Demons
	43308, -- Find Fish
}

local trackButton
local trackPending = false
local PlaceTrackButton

local function SpellName(id)
	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(id)
		if info then
			return info.name, info.iconID
		end
	end
end

local function Knows(id)
	if IsPlayerSpell then
		return IsPlayerSpell(id) == true
	end
	return IsSpellKnown and IsSpellKnown(id) == true
end

-- { { id, name, icon } } the character knows
local function KnownTracking()
	local list = {}
	for _, id in ipairs(TRACKING) do
		if Knows(id) then
			local name, icon = SpellName(id)
			if name then
				list[#list + 1] = { id = id, name = name, icon = icon }
			end
		end
	end
	return list
end

local function ActiveTracking(list)
	if not (C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then
		return nil
	end
	for _, t in ipairs(list) do
		if C_UnitAuras.GetPlayerAuraBySpellID(t.id) then
			return t
		end
	end
end

-- the one the left click uses: the one on, else the last one, else the first
local function Chosen(list, active)
	if active then
		return active
	end
	local last = ns.charDB and tonumber(ns.charDB.tracking)
	for _, t in ipairs(list) do
		if t.id == last then
			return t
		end
	end
	return list[1]
end

local function UpdateTrack()
	local b = trackButton
	if not b then
		return
	end
	local list = KnownTracking()
	local active = ActiveTracking(list)
	if active and ns.charDB then
		ns.charDB.tracking = active.id
	end
	local t = Chosen(list, active)
	b.current, b.active = t, active
	if t then
		b.icon:SetTexture(t.icon)
		b.icon:SetDesaturated(not active)
		b.icon:SetVertexColor(active and 1 or 0.7, active and 1 or 0.7, active and 1 or 0.7)
	end
	if InCombatLockdown() then
		trackPending = true
		return
	end
	local show = On(VAR_TRACK) and t ~= nil
	if show then
		if active then
			b:SetAttribute("type1", "cancelaura")
			b:SetAttribute("unit1", "player")
			b:SetAttribute("spell1", active.name)
		else
			b:SetAttribute("type1", "spell")
			b:SetAttribute("unit1", nil)
			b:SetAttribute("spell1", t.name)
		end
	end
	b:SetShown(show)
end

local function TrackTooltip(self)
	local t = self.current
	if not t then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(t.name, 1, 1, 1)
	if not self.active then
		GameTooltip:AddLine(T.TRACK_OFF, 0.6, 0.6, 0.6)
	end
	GameTooltip:AddLine(T.TRACK_HINT_TOGGLE, 0.8, 0.8, 0.8)
	GameTooltip:AddLine(T.TRACK_HINT_CHOOSE, 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

local function TrackMenu(self)
	if InCombatLockdown() then
		ns.Print(T.TRACK_COMBAT)
		return
	end
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	local list = KnownTracking()
	MenuUtil.CreateContextMenu(self, function(_, root)
		for _, t in ipairs(list) do
			local function IsSelected()
				return self.current and self.current.id == t.id
			end
			local function SetSelected()
				ns.charDB.tracking = t.id
				UpdateTrack()
			end
			-- the skill's icon in its name, as Blizzard's menus show them
			local label = t.icon and ("|T" .. t.icon .. ":16:16:0:0|t " .. t.name) or t.name
			root:CreateRadio(label, IsSelected, SetSelected)
		end
		-- moving it (next to the calendar, where it sits by default)
		if self.byClock then
			if root.CreateDivider then
				root:CreateDivider()
			end
			local unlock = root:CreateCheckbox(T.TRACK_UNLOCK, function()
				return self.unlocked == true
			end, function()
				self.unlocked = not self.unlocked
			end)
			if unlock and unlock.SetTooltip then
				unlock:SetTooltip(function(tooltip)
					GameTooltip_SetTitle(tooltip, T.TRACK_UNLOCK)
					GameTooltip_AddNormalLine(tooltip, T.TRACK_UNLOCK_DESC)
				end)
			end
		end
	end)
end

-- Where it sits on the minimap's edge: an angle (SetGoDB.trackingAngle,
-- for the account), round or square minimap, as the other minimap buttons
local TRACK_ANGLE = 200
local SQUARE = { SQUARE = true, CORNER = true }
-- Placed from the calendar button (GameTimeFrame) when there is one, as
-- set by hand with /setgo tracker (SetGo_Dev), in the calendar's pixels:
-- GAP from its right edge, DROP below its top, SIZE the button's size (its
-- 31 scaled). Else on the minimap's edge.
local CLOCK_GAP, CLOCK_DROP, TRACK_SIZE = -29, 78, 43
PlaceTrackButton = function(b)
	if InCombatLockdown() then
		return
	end
	local clock = GameTimeFrame
	if clock and clock.GetWidth and (tonumber(clock:GetWidth()) or 0) > 0 then
		-- TRACK_SIZE of the clock's pixels on screen, whatever the minimap's
		-- own scale
		local ce = clock:GetEffectiveScale()
		local pe = b:GetParent():GetEffectiveScale()
		local s = (TRACK_SIZE * ce) / (31 * pe)
		b.byClock = true
		b:SetScale(s)
		-- offsets in the button's own units, as the clock's pixels
		local k = ce / b:GetEffectiveScale()
		b:ClearAllPoints()
		-- where the player moved it (unlocked), else the default
		local pos = ns.db and ns.db.trackerPos
		local gap = tonumber(pos and pos.gap) or CLOCK_GAP
		local drop = tonumber(pos and pos.drop) or CLOCK_DROP
		b:SetPoint("TOPLEFT", clock, "TOPRIGHT", gap * k, -drop * k)
		return
	end
	b.byClock = nil
	b:SetScale(1)
	local angle = tonumber(ns.db and ns.db.trackingAngle) or TRACK_ANGLE
	local rad = math.rad(angle)
	local x, y = math.cos(rad), math.sin(rad)
	local w = (Minimap:GetWidth() / 2) + 5
	local h = (Minimap:GetHeight() / 2) + 5
	local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
	if SQUARE[shape] or (type(shape) == "string" and shape:find("^SIDE")) then
		-- along the square's edge
		local diag = math.sqrt(2)
		x = math.max(-1, math.min(x * diag, 1))
		y = math.max(-1, math.min(y * diag, 1))
	end
	b:ClearAllPoints()
	b:SetPoint("CENTER", Minimap, "CENTER", x * w, y * h)
end

local function MakeTrackButton()
	if trackButton or not Minimap then
		return trackButton
	end
	-- no global name: minimap button collectors (Leatrix Plus's button bag)
	-- take named buttons into their bag, hide them for good and click a copy,
	-- which can't cast. SetGo.trackButton for the author's tools.
	local b = CreateFrame("Button", nil, Minimap, "SecureActionButtonTemplate")
	ns.trackButton = b
	b:SetSize(31, 31)
	b:SetFrameStrata("MEDIUM")
	b:SetFrameLevel(Minimap:GetFrameLevel() + 8)
	-- down and up: Blizzard's secure buttons act on one or the other, as the
	-- player's "cast on key down" option says
	b:RegisterForClicks("AnyUp", "AnyDown")
	-- it acts when the mouse button is released, whatever the game's "cast
	-- on key down" option says
	b:SetAttribute("useOnKeyDown", false)
	b:SetHighlightTexture(136477) -- Interface\Minimap\UI-Minimap-ZoomButton-Highlight
	-- as the other minimap buttons draw (LibDBIcon's, Blizzard's art)
	local background = b:CreateTexture(nil, "BACKGROUND")
	background:SetTexture(136467) -- Interface\Minimap\UI-Minimap-Background
	background:SetSize(24, 24)
	background:SetPoint("CENTER")
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetSize(18, 18)
	b.icon:SetPoint("CENTER")
	b.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	local border = b:CreateTexture(nil, "OVERLAY")
	border:SetTexture(136430) -- Interface\Minimap\MiniMap-TrackingBorder
	border:SetSize(50, 50)
	border:SetPoint("TOPLEFT")
	-- on the minimap's edge, dragged around it as the other addons'
	-- buttons (out of combat: a secure button can't move in combat)
	PlaceTrackButton(b)
	b:RegisterForDrag("LeftButton")
	b:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then
			return
		end
		-- next to the calendar: moved freely while unlocked (its menu)
		if self.byClock then
			if self.unlocked then
				self:SetMovable(true)
				self:StartMoving()
				self.moving = true
			end
			return
		end
		self:LockHighlight()
		self:SetScript("OnUpdate", function()
			local mx, my = Minimap:GetCenter()
			local px, py = GetCursorPosition()
			local scale = Minimap:GetEffectiveScale()
			if mx and px then
				ns.db.trackingAngle = math.deg(math.atan2(py / scale - my, px / scale - mx)) % 360
				PlaceTrackButton(self)
			end
		end)
	end)
	b:SetScript("OnDragStop", function(self)
		if self.moving then
			self.moving = nil
			self:StopMovingOrSizing()
			-- kept from the calendar, in its pixels (for the account), and
			-- anchored to it again
			local clock = GameTimeFrame
			if clock and self:GetLeft() and clock:GetRight() then
				local k = self:GetEffectiveScale() / clock:GetEffectiveScale()
				ns.db.trackerPos = {
					gap = self:GetLeft() * k - clock:GetRight(),
					drop = clock:GetTop() - self:GetTop() * k,
				}
			end
			PlaceTrackButton(self)
			return
		end
		self:SetScript("OnUpdate", nil)
		self:UnlockHighlight()
	end)
	b:SetScript("OnEnter", TrackTooltip)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	b:HookScript("PostClick", function(self, button, down)
		if button == "RightButton" and not down then
			TrackMenu(self)
		end
	end)
	b:Hide()
	trackButton = b
	local watch = CreateFrame("Frame")
	watch:RegisterEvent("SPELLS_CHANGED")
	watch:RegisterEvent("PLAYER_REGEN_ENABLED")
	watch:RegisterUnitEvent("UNIT_AURA", "player")
	watch:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_REGEN_ENABLED" then
			if trackPending then
				trackPending = false
				Try(UpdateTrack)
			end
			return
		end
		Try(UpdateTrack)
	end)
	return b
end

local function ApplyTracking()
	if not On(VAR_TRACK) and not trackButton then
		return
	end
	if not trackButton then
		if InCombatLockdown() then
			trackPending = true
			return
		end
		MakeTrackButton()
	end
	UpdateTrack()
end

--------------------------------------------------------------------------------
-- Open All Bags with Right Click: on a right click on the backpack button,
-- all the bags open, or close if any was open (as it was before the
-- click, whatever Blizzard's own click does with the backpack). Not with an
-- item on the cursor (that click puts it in the bag), nor with a modifier
-- (Blizzard's own).
--------------------------------------------------------------------------------

local VAR_BAGS = "SETGO_TWEAK_BAGS_ALL"
local bagsHooked = false
local bagCursor = false
local bagsWereOpen = false

local function AnyBagOpen()
	if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsShown() then
		return true
	end
	local last = NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4
	for bag = 0, last do
		if IsBagOpen and IsBagOpen(bag) then
			return true
		end
	end
	return false
end

local function HookBags()
	local b = MainMenuBarBackpackButton
	if bagsHooked or not b then
		return
	end
	bagsHooked = true
	b:HookScript("PreClick", function()
		bagCursor = GetCursorInfo() ~= nil
		bagsWereOpen = AnyBagOpen()
	end)
	b:HookScript("OnClick", function(_, button)
		if button ~= "RightButton" or not On(VAR_BAGS) or bagCursor or IsModifiedClick() then
			return
		end
		if bagsWereOpen then
			Try(CloseAllBags)
		else
			Try(OpenAllBags)
		end
	end)
end

local function ApplyBags()
	if On(VAR_BAGS) then
		HookBags()
	end
end

--------------------------------------------------------------------------------
-- Quest filter button: next to the objective tracker's minimize button.
-- The tracker shows the quests being watched, so the filter changes which
-- are (C_QuestLog's own watch calls; Questie follows them). Zones are the
-- quest log's headers. Each click filters once: nothing follows the player.
--   Left click: only the quests of the zone you are in.
--   Right click: All (every quest in the log, as far as the game allows),
--   or one zone. The last one chosen is kept per character (the tooltip).
--------------------------------------------------------------------------------

local VAR_QFILTER = "SETGO_TWEAK_QUESTFILTER"
local qButton
local Q = C_QuestLog

-- { { zone, ids = { questID, ... } } } in the log's order
local function QuestZones()
	local zones, current = {}, nil
	if not (Q and Q.GetNumQuestLogEntries and Q.GetInfo) then
		return zones
	end
	for i = 1, Q.GetNumQuestLogEntries() do
		local info = Q.GetInfo(i)
		if info then
			if info.isHeader then
				current = { zone = info.title, ids = {} }
				zones[#zones + 1] = current
			elseif info.questID and not info.isHidden and current then
				current.ids[#current.ids + 1] = info.questID
				current.levels = current.levels or {}
				current.levels[info.questID] = tonumber(info.level)
			end
		end
	end
	for i = #zones, 1, -1 do
		if #zones[i].ids == 0 then
			table.remove(zones, i)
		end
	end
	return zones
end

local function Watched(id)
	if Q.GetQuestWatchType then
		return Q.GetQuestWatchType(id) ~= nil
	end
	return Q.IsQuestWatched and Q.IsQuestWatched(id) or false
end

-- the zone's names to look for among the headers: the zone of the map you
-- are on, and the game's zone name
local function HereNames()
	local names = {}
	local add = function(n)
		if type(n) == "string" and n ~= "" then
			names[n] = true
		end
	end
	add(GetRealZoneText and GetRealZoneText())
	add(GetZoneText and GetZoneText())
	if C_Map and C_Map.GetBestMapForUnit then
		local id = C_Map.GetBestMapForUnit("player")
		local zoneType = Enum and Enum.UIMapType and Enum.UIMapType.Zone or 3
		local guard = 0
		while id and guard < 10 do
			local info = C_Map.GetMapInfo(id)
			if not info then
				break
			end
			add(info.name)
			if info.mapType and info.mapType <= zoneType then
				break
			end
			id, guard = info.parentMapID, guard + 1
		end
	end
	return names
end

-- zone: a header's name, or nil for all
local function FilterTo(zone)
	local zones = QuestZones()
	local found = zone == nil
	for _, z in ipairs(zones) do
		local want = zone == nil or z.zone == zone
		found = found or want
		for _, id in ipairs(z.ids) do
			local on = Watched(id)
			if want and not on then
				Try(Q.AddQuestWatch, id)
			elseif not want and on then
				Try(Q.RemoveQuestWatch, id)
			end
		end
	end
	if not found then
		return false
	end
	if ns.charDB then
		ns.charDB.questFilter = zone or false
	end
	return true
end

-- quests 3 or more levels above yours (orange and red in the game)
local HIGH_LEVEL = 3
local function UntrackHigh()
	local me = UnitLevel("player") or 0
	local n = 0
	for _, z in ipairs(QuestZones()) do
		for _, id in ipairs(z.ids) do
			local level = z.levels and z.levels[id]
			if level and level - me >= HIGH_LEVEL and Watched(id) then
				Try(Q.RemoveQuestWatch, id)
				n = n + 1
			end
		end
	end
	ns.Print(T.QFILTER_HIGH_DONE:format(n))
end

local function FilterHere()
	local names = HereNames()
	for _, z in ipairs(QuestZones()) do
		if names[z.zone] then
			FilterTo(z.zone)
			return
		end
	end
	ns.Print(T.QFILTER_NONE:format(GetRealZoneText and GetRealZoneText() or "?"))
end

local function QFilterTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(T.QFILTER_TITLE, 1, 1, 1)
	local last = ns.charDB and ns.charDB.questFilter
	if last ~= nil then
		GameTooltip:AddLine(T.QFILTER_NOW:format(last or T.QFILTER_ALL), 1, 0.82, 0)
	end
	GameTooltip:AddLine(T.QFILTER_HINT_ZONE, 0.8, 0.8, 0.8)
	GameTooltip:AddLine(T.QFILTER_HINT_MENU, 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

local function QFilterMenu(self)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	MenuUtil.CreateContextMenu(self, function(_, root)
		local last = ns.charDB and ns.charDB.questFilter
		root:CreateRadio(T.QFILTER_ALL, function()
			return last == false
		end, function()
			FilterTo(nil)
		end)
		for _, z in ipairs(QuestZones()) do
			root:CreateRadio(("%s (%d)"):format(z.zone, #z.ids), function()
				return last == z.zone
			end, function()
				FilterTo(z.zone)
			end)
		end
		if root.CreateDivider then
			root:CreateDivider()
		end
		local high = root:CreateButton(T.QFILTER_HIGH, UntrackHigh)
		if high and high.SetTooltip then
			high:SetTooltip(function(tooltip)
				GameTooltip_SetTitle(tooltip, T.QFILTER_HIGH)
				GameTooltip_AddNormalLine(tooltip, T.QFILTER_HIGH_DESC)
			end)
		end
	end)
end

-- the look: Blizzard's tracker filter button where the game has it, else
-- another of its filter pieces, else the minimap's tracking magnifier
local QFILTER_ATLASES = {
	{ "ui-questtrackerbutton-filter", "ui-questtrackerbutton-filter-pressed" },
	{ "questlog-icon-filter" },
	{ "Map-Filter-Button" },
}

local function MakeQFilterButton()
	local header = ObjectiveTrackerFrame and ObjectiveTrackerFrame.Header
	local minimize = header and header.MinimizeButton
	if qButton or not minimize then
		return qButton
	end
	local b = CreateFrame("Button", nil, header)
	local w, h = minimize:GetSize()
	b:SetSize(w or 16, h or 16)
	b:SetPoint("RIGHT", minimize, "LEFT", -2, 0)
	b:SetFrameLevel(minimize:GetFrameLevel())
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local done = false
	for _, set in ipairs(QFILTER_ATLASES) do
		if Art.AtlasExists(set[1]) then
			b:SetNormalAtlas(set[1])
			if set[2] and Art.AtlasExists(set[2]) then
				b:SetPushedAtlas(set[2])
			end
			b:SetHighlightAtlas(set[1], "ADD")
			done = true
			break
		end
	end
	if not done then
		b:SetNormalTexture("Interface\\Minimap\\Tracking\\None")
		b:SetHighlightTexture("Interface\\Minimap\\Tracking\\None", "ADD")
	end
	b:SetScript("OnClick", function(self, button)
		if button == "RightButton" then
			QFilterMenu(self)
		else
			FilterHere()
		end
	end)
	b:SetScript("OnEnter", QFilterTooltip)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	b:Hide()
	qButton = b
	return b
end

local function ApplyQuestFilter()
	if not On(VAR_QFILTER) and not qButton then
		return
	end
	local b = MakeQFilterButton()
	if b then
		b:SetShown(On(VAR_QFILTER))
	end
end

--------------------------------------------------------------------------------
-- Simplified Minimized Tracker: while the objective tracker is minimized,
-- only its minimize button shows. The rest (title, background, the header's
-- other buttons, ours) goes invisible, not hidden, and comes back when the
-- tracker opens or the option is off. After each of Blizzard's updates.
--------------------------------------------------------------------------------

local VAR_QMIN = "SETGO_TWEAK_TRACKERMIN"
local qminHooked = false
local qminFaded = {}

local function TrackerParts()
	local tracker = ObjectiveTrackerFrame
	local header = tracker and tracker.Header
	if not header then
		return nil
	end
	local parts = { header.Background, header.Text, header.FilterButton, tracker.NineSlice, qButton }
	return tracker, header, parts
end

local function ApplyTrackerMin()
	local tracker, header, parts = TrackerParts()
	if not tracker then
		return
	end
	local simple = On(VAR_QMIN) and tracker.IsCollapsed and tracker:IsCollapsed()
	-- some may be missing (nil): every slot, not ipairs
	for i = 1, 5 do
		local part = parts[i]
		if part then
			if simple then
				if qminFaded[part] == nil then
					qminFaded[part] = part:GetAlpha()
				end
				part:SetAlpha(0)
				if part.EnableMouse and part ~= tracker.NineSlice then
					part:EnableMouse(false)
				end
			elseif qminFaded[part] ~= nil then
				part:SetAlpha(qminFaded[part])
				qminFaded[part] = nil
				if part.EnableMouse and part ~= tracker.NineSlice then
					part:EnableMouse(true)
				end
			end
		end
	end
end

local function HookTrackerMin()
	local tracker = ObjectiveTrackerFrame
	if qminHooked or not tracker then
		return
	end
	qminHooked = true
	for _, method in ipairs({ "SetCollapsed", "Update" }) do
		if type(tracker[method]) == "function" then
			hooksecurefunc(tracker, method, function()
				Try(ApplyTrackerMin)
			end)
		end
	end
end

local function ApplyTrackerMinTweak()
	if On(VAR_QMIN) then
		HookTrackerMin()
	end
	ApplyTrackerMin()
end

--------------------------------------------------------------------------------
-- All of them, as the profile in use has them
--------------------------------------------------------------------------------

function ns.ApplyTweaks()
	if not ns.db then
		return
	end
	Try(ApplySparkles)
	ApplyBars()
	Try(ApplyXPBar)
	Try(ApplyTracking)
	Try(ApplyBags)
	Try(ApplyQuestFilter)
	Try(ApplyTrackerMinTweak)
end

-- another profile in use here: its tweaks
if ns.SetActiveProfile then
	hooksecurefunc(ns, "SetActiveProfile", function()
		ns.ApplyTweaks()
		if ns.Refresh then
			Try(ns.Refresh)
		end
	end)
end

events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
pcall(events.RegisterEvent, events, "CVAR_UPDATE")
events:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_LOGIN" then
		-- after the bars are laid out, and again once the graphics settle
		C_Timer.After(1, ns.ApplyTweaks)
		C_Timer.After(5, function()
			Try(ApplySparkles)
		end)
	elseif event == "PLAYER_REGEN_ENABLED" then
		if pendingCombat then
			pendingCombat = false
			ns.ApplyTweaks()
		end
	elseif event == "CVAR_UPDATE" and not writing and ns.db and type(arg1) == "string"
		and SPARKLE_WATCH[arg1:lower()] and On(VAR_SPARKLES) then
		C_Timer.After(1, function()
			Try(ApplySparkles)
		end)
	end
end)

--------------------------------------------------------------------------------
-- The page
--------------------------------------------------------------------------------

local items
function ns.TweaksItems()
	if items then
		return items
	end
	local sparkles = ns.Pseudo(VAR_SPARKLES, T.SPARKLES, T.SPARKLES_DESC, false, function()
		return On(VAR_SPARKLES)
	end, function(on)
		Keep(VAR_SPARKLES, on)
		ApplySparkles(true)
	end)
	items = {
		{ kind = "note", name = T.NOTE },
		{ kind = "header", name = T.LOOT },
	}
	if SparkleCVarExists() then
		items[#items + 1] = { kind = "checkbox", setting = sparkles, settings = { sparkles }, name = T.SPARKLES, tooltip = T.SPARKLES_DESC }
	else
		items[#items + 1] = { kind = "note", name = T.SPARKLES .. ": " .. T.SPARKLES_MISSING }
	end
	items[#items + 1] = { kind = "header", name = T.BARS }
	items[#items + 1] = { kind = "note", name = T.BARS_NOTE }
	-- one dropdown, a box per bar
	local shown = {}
	for _, def in ipairs(BARS) do
		if _G[def.frame] then
			shown[#shown + 1] = def
		end
	end
	local function Summary()
		local on = {}
		for _, def in ipairs(shown) do
			if On(BarVar(def.n)) then
				on[#on + 1] = tostring(def.n)
			end
		end
		return #on > 0 and T.BARS_SOME:format(table.concat(on, ", ")) or T.BARS_NONE
	end
	items[#items + 1] = { kind = "custom", build = function(page, y, width)
		local W = ns.Widgets
		local label = W.Text(page, W.FONT_BODY, width, T.BARS_LABEL)
		label:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -y)
		y = y + (label:GetStringHeight() or 14) + 5
		local dd = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
		dd:SetPoint("TOPLEFT", page, "TOPLEFT", 2, -y)
		dd:SetWidth(math.min(260, width - 4))
		local function ShowText()
			local text = Summary()
			if dd.OverrideText then
				dd:OverrideText(text)
			elseif dd.SetDefaultText then
				dd:SetDefaultText(text)
			end
		end
		dd:SetupMenu(function(_, root)
			for _, def in ipairs(shown) do
				local var = BarVar(def.n)
				local name = ns.G("OPTION_SHOW_ACTION_BAR", T.BAR):format(def.n)
				local box = root:CreateCheckbox(name, function()
					return On(var)
				end, function()
					Keep(var, not On(var))
					if InCombatLockdown() then
						ns.Print(L.MSG_COMBAT)
					end
					ApplyBars()
					ShowText()
				end)
				if box and box.SetTooltip then
					box:SetTooltip(function(tooltip)
						GameTooltip_SetTitle(tooltip, name)
						GameTooltip_AddNormalLine(tooltip, T.BAR_DESC)
					end)
				end
			end
		end)
		ShowText()
		if page.refreshers then
			table.insert(page.refreshers, ShowText)
		end
		return y + 26 + 10
	end }
	-- Better XP bar: the box and the width on one line, Unified Bar under it
	items[#items + 1] = { kind = "header", name = T.XP }
	local xpOn = ns.Pseudo(VAR_XP, T.XP_BETTER, T.XP_BETTER_DESC, false, function()
		return On(VAR_XP)
	end, function(on)
		Keep(VAR_XP, on)
		showRep = false
		Try(ApplyXPBar)
	end)
	local xpWidth = ns.Pseudo(VAR_XP_WIDTH, T.XP_WIDTH, T.XP_WIDTH_DESC, 1, function()
		return Value(VAR_XP_WIDTH, 1)
	end, function(value)
		value = tonumber(value) or 1
		value = math.floor(value / XP_STEP + 0.5) * XP_STEP
		KeepValue(VAR_XP_WIDTH, math.max(XP_MIN, math.min(XP_MAX, value)), 1)
		Try(ApplyXPBar)
	end)
	local xpUnified = ns.Pseudo(VAR_XP_UNIFIED, T.XP_UNIFIED, T.XP_UNIFIED_DESC, false, function()
		return On(VAR_XP_UNIFIED)
	end, function(on)
		Keep(VAR_XP_UNIFIED, on)
		showRep = false
		Try(ApplyXPBar)
	end)
	local widthOptions = {
		minValue = XP_MIN, maxValue = XP_MAX,
		steps = math.floor((XP_MAX - XP_MIN) / XP_STEP + 0.5),
		formatters = MinimalSliderWithSteppersMixin and MinimalSliderWithSteppersMixin.Label and FormatPercentageRounded
			and { [MinimalSliderWithSteppersMixin.Label.Right] = FormatPercentageRounded } or nil,
	}
	items[#items + 1] = { kind = "cbslider", setting = xpOn, second = xpWidth, settings = { xpOn, xpWidth }, options = widthOptions,
		name = T.XP_BETTER, tooltip = T.XP_BETTER_DESC, secondName = T.XP_WIDTH, secondTooltip = T.XP_WIDTH_DESC }
	items[#items + 1] = { kind = "checkbox", indent = true, setting = xpUnified, settings = { xpUnified }, name = T.XP_UNIFIED, tooltip = T.XP_UNIFIED_DESC }
	-- the tracking button
	items[#items + 1] = { kind = "header", name = T.MINIMAP }
	local track = ns.Pseudo(VAR_TRACK, T.TRACK, T.TRACK_DESC, false, function()
		return On(VAR_TRACK)
	end, function(on)
		Keep(VAR_TRACK, on)
		if InCombatLockdown() then
			ns.Print(L.MSG_COMBAT)
		end
		Try(ApplyTracking)
	end)
	items[#items + 1] = { kind = "checkbox", setting = track, settings = { track }, name = T.TRACK, tooltip = T.TRACK_DESC }
	-- bags
	items[#items + 1] = { kind = "header", name = T.BAGS }
	local bagsAll = ns.Pseudo(VAR_BAGS, T.BAGS_ALL, T.BAGS_ALL_DESC, false, function()
		return On(VAR_BAGS)
	end, function(on)
		Keep(VAR_BAGS, on)
		Try(ApplyBags)
	end)
	items[#items + 1] = { kind = "checkbox", setting = bagsAll, settings = { bagsAll }, name = T.BAGS_ALL, tooltip = T.BAGS_ALL_DESC }
	-- the quest filter button
	items[#items + 1] = { kind = "header", name = T.QUESTS }
	local qfilter = ns.Pseudo(VAR_QFILTER, T.QFILTER, T.QFILTER_DESC, false, function()
		return On(VAR_QFILTER)
	end, function(on)
		Keep(VAR_QFILTER, on)
		Try(ApplyQuestFilter)
	end)
	items[#items + 1] = { kind = "checkbox", setting = qfilter, settings = { qfilter }, name = T.QFILTER, tooltip = T.QFILTER_DESC }
	local qmin = ns.Pseudo(VAR_QMIN, T.QMIN, T.QMIN_DESC, false, function()
		return On(VAR_QMIN)
	end, function(on)
		Keep(VAR_QMIN, on)
		Try(ApplyTrackerMinTweak)
	end)
	items[#items + 1] = { kind = "checkbox", setting = qmin, settings = { qmin }, name = T.QMIN, tooltip = T.QMIN_DESC }
	return items
end
