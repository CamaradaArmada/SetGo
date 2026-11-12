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
	XP_WIDTH_DESC = "How wide the bars are, from 80% to 100% of Blizzard's width, in 1% steps; the dividers follow. Edit Mode's Size still changes their scale.",
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
	QFILTER_DESC = "A button next to the objective tracker's minimize button. Right click: choose which quests to track (completed or not, a zone, high level, shared with your group). Left click: apply that filter again, for example after changing zone.",
	QFILTER_TITLE = "Quest filter",
	QFILTER_ALL = "All",
	QFILTER_DONE = "Completed",
	QFILTER_OPEN = "Not Completed",
	QFILTER_HERE = "Current Zone",
	QFILTER_NOW = "Filter: %s",
	QFILTER_HINT_APPLY = "Left click: apply the filter",
	QFILTER_HINT_MENU = "Right click: choose",
	QFILTER_EMPTY = "No quest in your log matches this filter: the tracker stays as it was.",
	QFILTER_HIGH = "Untrack High Level",
	QFILTER_HIGH_DESC = "Leaves out the quests the game shows in orange or red: 3 or more levels above yours.",
	QFILTER_SHARED = "Track Shared Quests",
	QFILTER_SHARED_DESC = "Also tracks the quests someone in your group is on too, whatever the zone or level (Completed and Not Completed still apply). Out of a group, it adds none.",
	BUFFS = "Buffs",
	HIDDEN_BUFFS = "Hidden Buffs Icon",
	HIDDEN_BUFFS_DESC = "While the buffs' arrow keeps the long buffs hidden, an icon next to it shows how many there are, as in Cataclysm. Mouse over it for the list, with the time left on each.",
	HIDDEN_BUFFS_TITLE = "Hidden buffs",
	HIDDEN_BUFFS_HINT = "Click the arrow to show them.",
	QMIN = "Simplified Minimized Tracker",
	QMIN_DESC = "While the objective tracker is minimized, only its minimize button shows: no title, no background, no other buttons.",
	TRACK_DESC = "A button next to the minimap's day and night button for your tracking skills (herbs, minerals, treasure, beasts and others). In colour while one is on, in grey while it is off; none, while you have no tracking skill. Left click: on or off. Right click: choose which.",
	TRACK_HINT_TOGGLE = "Left click: on or off",
	TRACK_HINT_CHOOSE = "Right click: choose",
	TRACK_OFF = "Off",
	TRACK_COMBAT = "The tracking skill can't be chosen in combat.",
	TRACK_AT = "SetGo! Tracker: x %.1f, y %.1f from the minimap's middle.",
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
	T.XP_WIDTH_DESC = "A largura das barras, de 80% a 100% da largura da Blizzard, em passos de 1%; os tracinhos acompanham. O Tamanho do Edit Mode continua a mudar a escala."
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
	T.QFILTER_DESC = "Um botão ao lado do botão de minimizar do tracker de objectivos. Clique direito: escolher que missões seguir (acabadas ou não, uma zona, de nível alto, partilhadas com o grupo). Clique esquerdo: aplicar outra vez esse filtro, por exemplo depois de mudar de zona."
	T.QFILTER_TITLE = "Filtro das missões"
	T.QFILTER_ALL = "Todas"
	T.QFILTER_DONE = "Acabadas"
	T.QFILTER_OPEN = "Por acabar"
	T.QFILTER_HERE = "Zona actual"
	T.QFILTER_NOW = "Filtro: %s"
	T.QFILTER_HINT_APPLY = "Clique esquerdo: aplicar o filtro"
	T.QFILTER_HINT_MENU = "Clique direito: escolher"
	T.QFILTER_EMPTY = "Nenhuma missão do diário passa neste filtro: o tracker fica como estava."
	T.QFILTER_HIGH = "Deixar de seguir as de nível alto"
	T.QFILTER_HIGH_DESC = "Deixa de fora as missões que o jogo mostra a laranja ou a vermelho: 3 ou mais níveis acima do teu."
	T.QFILTER_SHARED = "Seguir as missões partilhadas"
	T.QFILTER_SHARED_DESC = "Segue também as missões que alguém do teu grupo também tem, seja qual for a zona ou o nível (Acabadas e Por acabar continuam a contar). Fora de um grupo, não junta nenhuma."
	T.BUFFS = "Buffs"
	T.HIDDEN_BUFFS = "Ícone dos buffs escondidos"
	T.HIDDEN_BUFFS_DESC = "Enquanto a seta dos buffs esconde os buffs longos, um ícone ao lado mostra quantos são, como no Cataclysm. Passa o rato por cima para ver a lista, com o tempo que falta a cada um."
	T.HIDDEN_BUFFS_TITLE = "Buffs escondidos"
	T.HIDDEN_BUFFS_HINT = "Clica na seta para os mostrar."
	T.QMIN = "Tracker minimizado simplificado"
	T.QMIN_DESC = "Com o tracker de objectivos minimizado, só se vê o botão de minimizar: sem título, sem fundo e sem outros botões."
	T.TRACK_DESC = "Um botão ao lado do botão do dia e da noite do minimapa para as tuas habilidades de tracking (ervas, minérios, tesouros, bestas e outras). A cores com uma ligada, a cinzento com ela desligada; não aparece se não tiveres nenhuma. Clique esquerdo: ligar ou desligar. Clique direito: escolher qual."
	T.TRACK_HINT_TOGGLE = "Clique esquerdo: ligar ou desligar"
	T.TRACK_HINT_CHOOSE = "Clique direito: escolher"
	T.TRACK_OFF = "Desligado"
	T.TRACK_COMBAT = "Não é possível escolher a habilidade de tracking em combate."
	T.TRACK_AT = "SetGo! Tracker: x %.1f, y %.1f a partir do meio do minimapa."
end
L.TWEAKS_TITLE = T.TITLE
L.TWEAKS_DESC = T.DESC
ns.TWEAKS_ICON = "Interface\\Icons\\INV_Misc_Wrench_01"

--------------------------------------------------------------------------------
-- Where they are kept
--------------------------------------------------------------------------------

-- the messages SetGo!'s settings can switch off (Settings.lua)
ns.TWEAK_MESSAGES = { T.TRACK_AT, T.QFILTER_EMPTY }

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
local XP_MIN, XP_MAX, XP_STEP = 0.8, 1, 0.01
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

-- The dividers this client draws over the bars: small frames of one
-- texture, anchored to the container's left at fixed places. Their places
-- are scaled around the container's middle, as the bars are.
local function PlaceDividers(c, pct)
	local cw = c:GetWidth()
	if not (cw and cw > 0) then
		return
	end
	local isBar = {}
	for _, bar in pairs(c.bars or {}) do
		isBar[bar] = true
	end
	for _, f in ipairs({ c:GetChildren() }) do
		if not isBar[f] and f ~= c.Selection and f:GetNumChildren() == 0 and f:GetNumRegions() == 1 then
			if not f.sgX then
				local point, rel, relPoint, x, y = f:GetPoint(1)
				if point == "LEFT" and rel == c and relPoint == "LEFT" then
					f.sgX, f.sgY = x or 0, y or 0
				end
			end
			if f.sgX then
				f:ClearAllPoints()
				f:SetPoint("LEFT", c, "LEFT", cw / 2 + (f.sgX - cw / 2) * pct, f.sgY)
			end
		end
	end
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
			-- its own size back (the Unified Bar scales the second one)
			if bar:GetScale() ~= 1 then
				bar:SetScale(1)
			end
			PlaceBar(bar, c, pct)
			ShowBar(bar, true)
		end
		PlaceFrameArt(c, pct)
		Try(PlaceDividers, c, pct)
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
		-- at the main bar's size and place, whatever size Edit Mode gives
		-- the second container
		local me, se = main:GetEffectiveScale(), second:GetEffectiveScale()
		if me and se and se > 0 then
			otherBar:SetScale(me / se)
		end
		local mb = BarBase(mainBar)
		if mb then
			local w = mb.w * pct
			otherBar:SetWidth(w)
			if otherBar.StatusBar then
				otherBar.StatusBar:SetWidth(w)
			end
			if otherBar.sgBase then
				otherBar.sgBase.home = otherBar.sgBase.home or second
			end
			otherBar:ClearAllPoints()
			otherBar:SetPoint(mb.point, main, mb.relPoint, mb.x + (mb.w - w) / 2, mb.y)
		else
			PlaceBar(otherBar, main, pct)
		end
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

-- the one the left click uses: the one chosen in the menu (or last turned
-- on elsewhere), else the one on, else the first
local function Chosen(list, active)
	local last = ns.charDB and tonumber(ns.charDB.tracking)
	for _, t in ipairs(list) do
		if t.id == last then
			return t
		end
	end
	return active or list[1]
end

-- the one on when last looked: one turned on elsewhere (the spellbook, a
-- macro) becomes the chosen one; the menu's choice stands otherwise
local seenActive

local function UpdateTrack()
	local b = trackButton
	if not b then
		return
	end
	local list = KnownTracking()
	local active = ActiveTracking(list)
	local activeID = active and active.id or nil
	if activeID and activeID ~= seenActive and ns.charDB then
		ns.charDB.tracking = activeID
	end
	seenActive = activeID
	local t = Chosen(list, active)
	-- on: the chosen one is the one on
	local on = t and active and t.id == active.id
	b.current, b.active = t, on and active or nil
	if t then
		b.icon:SetTexture(t.icon)
		b.icon:SetDesaturated(not on)
		b.icon:SetVertexColor(on and 1 or 0.7, on and 1 or 0.7, on and 1 or 0.7)
	end
	if InCombatLockdown() then
		trackPending = true
		return
	end
	local show = On(VAR_TRACK) and t ~= nil
	if show then
		if on then
			b:SetAttribute("type1", "cancelaura")
			b:SetAttribute("unit1", "player")
			b:SetAttribute("spell1", active.name)
		else
			-- casting it replaces the one on, if another is
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
	end)
end

-- Where it sits on the minimap's edge: an angle (SetGoDB.trackingAngle,
-- for the account), round or square minimap, as the other minimap buttons
local TRACK_ANGLE = 200
local SQUARE = { SQUARE = true, CORNER = true }
--------------------------------------------------------------------------------
-- As the minimap's day and night indicator, when there is one (a frame of
-- MinimapCluster.MinimapContainer with no name: the sun or the moon,
-- UI-HUD-Minimap-DayCycle, under a gold ring, UI-HUD-Minimap-Frame-Cycle,
-- 42 wide): the same ring at the same size, with the tracking icon cut round
-- where the sun is. It sits opposite the sun, as far left of the minimap's
-- middle as the sun is right of it, at the same height, until it is moved:
-- unlocked (its menu), dragged or with the arrow keys over it (1 pixel,
-- Shift: 5). Kept in SetGoDB.trackerAt, from the minimap's middle, in the
-- indicator's pixels; locking it again prints the numbers.
-- TUNE: in the indicator's pixels (its ring is 42 wide, its sun 33).
--------------------------------------------------------------------------------
local TUNE = {
	SIZE = 42, -- the ring
	ICON_SIZE = 33, -- the icon, where the sun is
	ICON_X = 0,
	ICON_Y = 0,
}
local RING_ATLAS = "UI-HUD-Minimap-Frame-Cycle"

-- the day and night indicator: the frame whose ring is RING_ATLAS
local cycleFrame
local function Cycle()
	if cycleFrame then
		return cycleFrame
	end
	local container = MinimapCluster and MinimapCluster.MinimapContainer
	if not (container and container.GetChildren) then
		return nil
	end
	for _, f in ipairs({ container:GetChildren() }) do
		for _, r in ipairs({ Try(f.GetRegions, f) }) do
			local atlas = r.GetAtlas and Try(r.GetAtlas, r)
			if type(atlas) == "string" and atlas:lower() == RING_ATLAS:lower() then
				cycleFrame = f
				return f
			end
		end
	end
	return nil
end

local function HasAtlas(atlas)
	return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) ~= nil
end

-- the button as the day and night indicator (or back to a minimap button's
-- look)
local function TrackArt(b, byCycle)
	if byCycle and HasAtlas(RING_ATLAS) then
		local u = 31 / TUNE.SIZE -- the button's units for one of the indicator's pixels
		b.ring:SetAtlas(RING_ATLAS)
		b.ring:SetAllPoints()
		b.ring:Show()
		b.background:Hide()
		b.border:Hide()
		b.icon:ClearAllPoints()
		b.icon:SetPoint("CENTER", b, "CENTER", TUNE.ICON_X * u, TUNE.ICON_Y * u)
		b.icon:SetSize(TUNE.ICON_SIZE * u, TUNE.ICON_SIZE * u)
		b.icon:SetTexCoord(0, 1, 0, 1)
		if b.iconMask and not b.masked then
			b.icon:AddMaskTexture(b.iconMask)
			b.masked = true
		end
		local hl = b:GetHighlightTexture()
		hl:ClearAllPoints()
		hl:SetPoint("CENTER", b.icon, "CENTER")
		hl:SetSize(TUNE.ICON_SIZE * u, TUNE.ICON_SIZE * u)
	else
		b.ring:Hide()
		b.background:Show()
		b.border:Show()
		b.icon:ClearAllPoints()
		b.icon:SetPoint("CENTER")
		b.icon:SetSize(18, 18)
		b.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		if b.iconMask and b.masked then
			b.icon:RemoveMaskTexture(b.iconMask)
			b.masked = nil
		end
		local hl = b:GetHighlightTexture()
		hl:ClearAllPoints()
		hl:SetAllPoints()
	end
end

PlaceTrackButton = function(b)
	if InCombatLockdown() then
		return
	end
	local cycle = Cycle()
	-- both values (an "and" chain would keep only the first)
	local cx, cy, mx, my
	if cycle then
		cx, cy = cycle:GetCenter()
	end
	mx, my = Minimap:GetCenter()
	if cycle and cx and cy and mx and my then
		-- the ring's size on screen, whatever the minimap's own scale
		local ce = cycle:GetEffectiveScale()
		local pe = b:GetParent():GetEffectiveScale()
		local me = Minimap:GetEffectiveScale()
		b.byClock = true
		b:SetScale((TUNE.SIZE * ce) / (31 * pe))
		-- from the minimap's middle, in the indicator's pixels: where the
		-- player put it, else opposite the indicator
		-- (it no longer moves: a spot kept from before is forgotten)
		if ns.db then
			ns.db.trackerAt = nil
		end
		local x = -(cx * ce - mx * me) / ce
		local y = (cy * ce - my * me) / ce
		-- offsets in the button's own units
		local k = ce / b:GetEffectiveScale()
		b:ClearAllPoints()
		b:SetPoint("CENTER", Minimap, "CENTER", x * k, y * k)
		TrackArt(b, true)
		return
	end
	TrackArt(b, false)
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
	b.background = background
	-- as the day and night indicator: its gold ring, over the icon
	b.ring = b:CreateTexture(nil, "OVERLAY", nil, 1)
	b.ring:SetAllPoints()
	b.ring:Hide()
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetSize(18, 18)
	b.icon:SetPoint("CENTER")
	b.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	-- the icon cut round, over the day and night art
	if b.CreateMaskTexture then
		b.iconMask = b:CreateMaskTexture()
		b.iconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		b.iconMask:SetAllPoints(b.icon)
	end
	local border = b:CreateTexture(nil, "OVERLAY")
	border:SetTexture(136430) -- Interface\Minimap\MiniMap-TrackingBorder
	border:SetSize(50, 50)
	border:SetPoint("TOPLEFT")
	b.border = border
	-- where it was moved to before it was drawn as the day and night
	-- indicator (once): it goes opposite it
	if ns.db then
		ns.db.trackerPos = nil
		if not ns.db.trackerCycle then
			ns.db.trackerAt = nil
			ns.db.trackerCycle = true
		end
	end
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
			-- kept from the minimap's middle, in the day and night
			-- indicator's pixels (for the account), and placed from it again
			local cycle = Cycle()
			local bx, by = self:GetCenter()
			local mx, my = Minimap:GetCenter()
			if cycle and bx and mx then
				local ce, be, me = cycle:GetEffectiveScale(), self:GetEffectiveScale(), Minimap:GetEffectiveScale()
				ns.db.trackerAt = {
					x = (bx * be - mx * me) / ce,
					y = (by * be - my * me) / ce,
				}
			end
			PlaceTrackButton(self)
			return
		end
		self:SetScript("OnUpdate", nil)
		self:UnlockHighlight()
	end)
	-- unlocked: the arrow keys move it, 1 of the day and night button's
	-- pixels a press (Shift: 5), while the mouse is over it. The keys are
	-- bound only then (override bindings, out of combat), so they and every
	-- other key work as usual the rest of the time.
	local nudge = CreateFrame("Button", "SetGoTrackerNudge", UIParent)
	nudge:Hide()
	nudge:SetScript("OnClick", function(_, key)
		if InCombatLockdown() or not b.unlocked then
			return
		end
		local step = IsShiftKeyDown() and 5 or 1
		local dx = (key == "LEFT" and -1) or (key == "RIGHT" and 1) or 0
		local dy = (key == "DOWN" and -1) or (key == "UP" and 1) or 0
		-- from where it is now (opposite the indicator, when never moved)
		local at = ns.db.trackerAt
		if not at then
			local cycle = Cycle()
			local bx, by = b:GetCenter()
			local mx, my = Minimap:GetCenter()
			if not (cycle and bx and mx) then
				return
			end
			local ce, be, me = cycle:GetEffectiveScale(), b:GetEffectiveScale(), Minimap:GetEffectiveScale()
			at = { x = (bx * be - mx * me) / ce, y = (by * be - my * me) / ce }
		end
		ns.db.trackerAt = { x = (tonumber(at.x) or 0) + dx * step, y = (tonumber(at.y) or 0) + dy * step }
		PlaceTrackButton(b)
	end)
	b.ArrowKeys = function(self, on)
		if InCombatLockdown() then
			return
		end
		ClearOverrideBindings(nudge)
		if on then
			for _, key in ipairs({ "UP", "DOWN", "LEFT", "RIGHT" }) do
				SetOverrideBindingClick(nudge, true, key, "SetGoTrackerNudge", key)
				SetOverrideBindingClick(nudge, true, "SHIFT-" .. key, "SetGoTrackerNudge", key)
			end
		end
	end
	b:SetScript("OnEnter", TrackTooltip)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	-- the arrow keys, while the mouse is over it (after the tooltip's own
	-- scripts, which would replace these)
	b:HookScript("OnEnter", function(self)
		if self.unlocked and self.byClock then
			self:ArrowKeys(true)
		end
	end)
	b:HookScript("OnLeave", function(self)
		self:ArrowKeys(false)
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
	-- combat: the arrow keys go back to the game first
	watch:RegisterEvent("PLAYER_REGEN_DISABLED")
	-- the day and night button is placed after the login: placed from it again
	watch:RegisterEvent("PLAYER_ENTERING_WORLD")
	pcall(watch.RegisterEvent, watch, "EDIT_MODE_LAYOUTS_UPDATED")
	watch:RegisterUnitEvent("UNIT_AURA", "player")
	watch:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_REGEN_DISABLED" then
			b:ArrowKeys(false)
			return
		end
		if event == "PLAYER_ENTERING_WORLD" or event == "EDIT_MODE_LAYOUTS_UPDATED" then
			C_Timer.After(0, function()
				if not b.moving then
					PlaceTrackButton(b)
				end
			end)
			return
		end
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
-- Open All Bags with Right Click: an invisible secure button over the
-- backpack button. Blizzard's bag windows opened from addon code are
-- tainted, and using an item from them is then blocked (UseContainerItem),
-- so the bags are opened by the game's secure code instead:
--   left click: clicks the backpack button itself (Blizzard's own click);
--   right click: a macro of /click on the backpack and each bag button
--   (Blizzard's own clicks, so the windows stay clean): each one opens or
--   closes; an item on the cursor goes into the backpack.
-- Items dropped on it go to the backpack button. Shown and hidden only out
-- of combat (it is protected).
--------------------------------------------------------------------------------

local VAR_BAGS = "SETGO_TWEAK_BAGS_ALL"
local bagButton
-- each bag button clicked in turn (/click is Blizzard's own, secure; /run
-- would mark the bag windows as an addon's): each bag opens or closes
local function BagsMacro()
	local lines = { "/click MainMenuBarBackpackButton" }
	for i = 0, 3 do
		local name = "CharacterBag" .. i .. "Slot"
		if _G[name] then
			lines[#lines + 1] = "/click " .. name
		end
	end
	if _G.CharacterReagentBag0Slot then
		lines[#lines + 1] = "/click CharacterReagentBag0Slot"
	end
	return table.concat(lines, "\n")
end

local function MakeBagButton()
	local pack = MainMenuBarBackpackButton
	if bagButton or not pack then
		return bagButton
	end
	local b = CreateFrame("Button", nil, pack, "SecureActionButtonTemplate")
	b:SetAllPoints(pack)
	b:SetFrameLevel(pack:GetFrameLevel() + 5)
	b:RegisterForClicks("AnyUp", "AnyDown")
	b:SetAttribute("useOnKeyDown", false)
	b:SetAttribute("type1", "click")
	b:SetAttribute("clickbutton1", pack)
	b:SetAttribute("type2", "macro")
	b:SetAttribute("macrotext2", BagsMacro())
	-- the backpack's own tooltip, highlight and drop
	b:SetScript("OnEnter", function()
		pack:LockHighlight()
		local enter = pack:GetScript("OnEnter")
		if enter then
			Try(enter, pack)
		end
	end)
	b:SetScript("OnLeave", function()
		pack:UnlockHighlight()
		local leave = pack:GetScript("OnLeave")
		if leave then
			Try(leave, pack)
		end
	end)
	b:SetScript("OnReceiveDrag", function()
		if GetCursorInfo() then
			Try(PutItemInBackpack)
		end
	end)
	b:Hide()
	bagButton = b
	return b
end

local function ApplyBags()
	if not On(VAR_BAGS) and not bagButton then
		return
	end
	if InCombatLockdown() then
		pendingCombat = true
		return
	end
	local b = MakeBagButton()
	if b then
		b:SetShown(On(VAR_BAGS))
	end
end

--------------------------------------------------------------------------------
-- Quest filter button: next to the objective tracker's minimize button.
-- The tracker shows the quests being watched, so the filter changes which
-- are (C_QuestLog's own watch calls; Questie follows them). Zones are the
-- quest log's headers. Each click filters once: nothing follows the player.
--   Right click: the menu. All; Completed or Not Completed; Current Zone or
--   one zone; Untrack High Level; Track Shared Quests. Each choice is kept
--   per character and applied at once.
--   Left click: applies the kept filter again (Current Zone after moving).
--   A filter that leaves nothing to track leaves the tracker as it was.
--------------------------------------------------------------------------------

local VAR_QFILTER = "SETGO_TWEAK_QUESTFILTER"
local qButton
local Q = C_QuestLog

-- { { zone, ids = { questID, ... }, levels, done } } in the log's order
local function QuestZones()
	local zones, current = {}, nil
	if not (Q and Q.GetNumQuestLogEntries and Q.GetInfo) then
		return zones
	end
	for i = 1, Q.GetNumQuestLogEntries() do
		local info = Q.GetInfo(i)
		if info then
			if info.isHeader then
				current = { zone = info.title, ids = {}, levels = {}, done = {} }
				zones[#zones + 1] = current
			elseif info.questID and not info.isHidden and current then
				local id = info.questID
				current.ids[#current.ids + 1] = id
				current.levels[id] = tonumber(info.level)
				local done = info.isComplete
				if Q.IsComplete then
					done = Try(Q.IsComplete, id)
				end
				current.done[id] = done and true or false
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

-- the kept filter: status (nil, "done", "open"), place (nil, "here" or a
-- zone), high, shared. Builds before 43 kept only a zone name.
local function Filter()
	local db = ns.charDB
	if not db then
		return {}
	end
	if type(db.questFilter) ~= "table" then
		local old = db.questFilter
		db.questFilter = { place = type(old) == "string" and old or nil }
	end
	return db.questFilter
end

local function InGroup()
	return IsInGroup and IsInGroup() or false
end

local function SharedWithGroup(id)
	if not (Q.IsUnitOnQuest and InGroup()) then
		return false
	end
	local raid = IsInRaid and IsInRaid()
	local n = raid and (GetNumGroupMembers and GetNumGroupMembers() or 0) or 4
	for i = 1, n do
		local unit = raid and ("raid" .. i) or ("party" .. i)
		if UnitExists(unit) and not UnitIsUnit(unit, "player") and Try(Q.IsUnitOnQuest, unit, id) then
			return true
		end
	end
	return false
end

-- quests 3 or more levels above yours (orange and red in the game)
local HIGH_LEVEL = 3

local function ApplyFilter()
	local f = Filter()
	local zones = QuestZones()
	local place = f.place
	if place == "here" then
		local names = HereNames()
		place = false -- no header for this zone: no quest passes
		for _, z in ipairs(zones) do
			if names[z.zone] then
				place = z.zone
				break
			end
		end
	end
	local me = UnitLevel("player") or 0
	local want, any = {}, false
	for _, z in ipairs(zones) do
		for _, id in ipairs(z.ids) do
			local ok = place == nil or z.zone == place
			if ok and f.high then
				local level = z.levels[id]
				ok = not (level and level - me >= HIGH_LEVEL)
			end
			-- shared with the group: in, whatever the zone or level (out of a
			-- group, none is)
			if not ok and f.shared then
				ok = SharedWithGroup(id)
			end
			-- Completed or Not Completed: over everything else
			if ok and f.status == "done" then
				ok = z.done[id]
			elseif ok and f.status == "open" then
				ok = not z.done[id]
			end
			want[id] = ok
			any = any or ok
		end
	end
	if not any then
		ns.Print(T.QFILTER_EMPTY)
		return
	end
	for id, ok in pairs(want) do
		local on = Watched(id)
		if ok and not on then
			Try(Q.AddQuestWatch, id)
		elseif not ok and on then
			Try(Q.RemoveQuestWatch, id)
		end
	end
end

local function FilterText()
	local f = Filter()
	local parts = {}
	if f.status == "done" then
		parts[#parts + 1] = T.QFILTER_DONE
	elseif f.status == "open" then
		parts[#parts + 1] = T.QFILTER_OPEN
	end
	if f.place == "here" then
		parts[#parts + 1] = T.QFILTER_HERE
	elseif f.place then
		parts[#parts + 1] = f.place
	end
	if #parts == 0 then
		parts[1] = T.QFILTER_ALL
	end
	if f.high then
		parts[#parts + 1] = T.QFILTER_HIGH
	end
	if f.shared then
		parts[#parts + 1] = T.QFILTER_SHARED
	end
	return table.concat(parts, ", ")
end

local function QFilterTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(T.QFILTER_TITLE, 1, 1, 1)
	GameTooltip:AddLine(T.QFILTER_NOW:format(FilterText()), 1, 0.82, 0, true)
	GameTooltip:AddLine(T.QFILTER_HINT_APPLY, 0.8, 0.8, 0.8)
	GameTooltip:AddLine(T.QFILTER_HINT_MENU, 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

-- the menu stays open, so several choices can be made in one go
local function MenuStay()
	return MenuResponse and MenuResponse.Refresh
end

local function Tip(desc, title, text)
	if desc and desc.SetTooltip then
		desc:SetTooltip(function(tooltip)
			GameTooltip_SetTitle(tooltip, title)
			GameTooltip_AddNormalLine(tooltip, text)
		end)
	end
end

local function QFilterMenu(self)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	local Divider = function(root)
		if root.CreateDivider then
			root:CreateDivider()
		end
	end
	MenuUtil.CreateContextMenu(self, function(_, root)
		local f = Filter()
		-- choosing the one already chosen clears it
		local function Pick(key, value)
			return function()
				if f[key] == value then
					f[key] = nil
				else
					f[key] = value
				end
				ApplyFilter()
				return MenuStay()
			end
		end
		root:CreateRadio(T.QFILTER_ALL, function()
			return f.status == nil and f.place == nil
		end, function()
			f.status, f.place = nil, nil
			ApplyFilter()
			return MenuStay()
		end)
		Divider(root)
		root:CreateRadio(T.QFILTER_DONE, function()
			return f.status == "done"
		end, Pick("status", "done"))
		root:CreateRadio(T.QFILTER_OPEN, function()
			return f.status == "open"
		end, Pick("status", "open"))
		Divider(root)
		root:CreateRadio(T.QFILTER_HERE, function()
			return f.place == "here"
		end, Pick("place", "here"))
		for _, z in ipairs(QuestZones()) do
			root:CreateRadio(("%s (%d)"):format(z.zone, #z.ids), function()
				return f.place == z.zone
			end, Pick("place", z.zone))
		end
		Divider(root)
		local high = root:CreateCheckbox(T.QFILTER_HIGH, function()
			return f.high and true or false
		end, function()
			f.high = not f.high or nil
			ApplyFilter()
			return MenuStay()
		end)
		Tip(high, T.QFILTER_HIGH, T.QFILTER_HIGH_DESC)
		Divider(root)
		local shared = root:CreateCheckbox(T.QFILTER_SHARED, function()
			return f.shared and true or false
		end, function()
			f.shared = not f.shared or nil
			ApplyFilter()
			return MenuStay()
		end)
		Tip(shared, T.QFILTER_SHARED, T.QFILTER_SHARED_DESC)
		if shared and shared.SetEnabled and not Q.IsUnitOnQuest then
			shared:SetEnabled(false)
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
			ApplyFilter()
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

--------------------------------------------------------------------------------
-- Hidden Buffs Icon: while the buff frame's arrow is collapsed, an icon on
-- the outer side of the arrow, with the number of buffs it hides (Blizzard's
-- rule: no duration, or more than BUFF_DURATION_WARNING_TIME left; weapon
-- enchants too), drawn as Cataclysm's consolidated buffs. The tooltip lists
-- them. Only a frame of ours anchored to the arrow, and hooks after
-- Blizzard's own updates: the buff frame isn't touched (its right click to
-- cancel a buff stays Blizzard's).
--------------------------------------------------------------------------------

local VAR_HIDDEN_BUFFS = "SETGO_TWEAK_HIDDENBUFFS"
local hbIcon, hbHooked

local function LongTime(left)
	return left == nil or left > (BUFF_DURATION_WARNING_TIME or 60)
end

local function TimeText(left)
	if not left then
		return ""
	end
	if left >= 3600 then
		return ("%dh"):format(math.floor(left / 3600 + 0.5))
	elseif left >= 60 then
		return ("%dm"):format(math.floor(left / 60 + 0.5))
	end
	return ("%ds"):format(math.floor(left))
end

-- { { name, icon, left } } of the buffs the arrow hides
local function HiddenBuffs()
	local list = {}
	local now = GetTime()
	-- weapon enchants, as Blizzard counts them
	if GetWeaponEnchantInfo then
		local info = { GetWeaponEnchantInfo() }
		local slots = { { info[1], info[2], 16 }, { info[5], info[6], 17 }, { info[9], info[10], 18 } }
		for _, e in ipairs(slots) do
			if e[1] and e[2] then
				local left = e[2] / 1000
				if LongTime(left) then
					local link = GetInventoryItemLink("player", e[3])
					list[#list + 1] = {
						name = link and link:match("%[(.-)%]") or "?",
						icon = GetInventoryItemTexture("player", e[3]),
						left = left,
					}
				end
			end
		end
	end
	for i = 1, 40 do
		local name, icon, duration, expiration
		if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
			local a = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
			if a then
				name, icon, duration, expiration = a.name, a.icon, a.duration, a.expirationTime
			end
		elseif UnitBuff then
			local _
			name, icon, _, _, duration, expiration = UnitBuff("player", i)
		end
		if not name then
			break
		end
		local left = (duration and duration > 0 and expiration and expiration > 0) and (expiration - now) or nil
		if LongTime(left) then
			list[#list + 1] = { name = name, icon = icon, left = left }
		end
	end
	return list
end

local function Collapsed()
	local f = BuffFrame
	local arrow = f and f.CollapseAndExpandButton
	if not (arrow and arrow:IsShown()) then
		return false
	end
	if f.isExpanded ~= nil then
		return not f.isExpanded
	end
	return arrow.GetChecked and not arrow:GetChecked()
end

local function HiddenBuffsTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:SetText(T.HIDDEN_BUFFS_TITLE, 1, 1, 1)
	for _, b in ipairs(HiddenBuffs()) do
		GameTooltip:AddDoubleLine(("|T%s:16:16:0:0:64:64:5:59:5:59|t %s"):format(tostring(b.icon or 134400), b.name),
			TimeText(b.left), 1, 0.82, 0, 0.8, 0.8, 0.8)
	end
	GameTooltip:AddLine(T.HIDDEN_BUFFS_HINT, 0.6, 0.6, 0.6)
	GameTooltip:Show()
end

local function PlaceHiddenBuffs()
	local f = BuffFrame
	local arrow = f and f.CollapseAndExpandButton
	local box = f and f.AuraContainer
	if not (hbIcon and arrow) then
		return
	end
	local size = 30
	local first = f.auraFrames and f.auraFrames[1]
	if first and first.GetWidth and first:GetWidth() > 0 then
		size = first:GetWidth()
	end
	hbIcon:SetSize(size, size)
	hbIcon:SetScale((box and box.iconScale) or 1)
	hbIcon:ClearAllPoints()
	-- on the side of the arrow away from the buffs
	local horizontal = not (box and box.isHorizontal == false)
	if horizontal then
		if box and box.addIconsToRight then
			hbIcon:SetPoint("RIGHT", arrow, "LEFT", -2, 0)
		else
			hbIcon:SetPoint("LEFT", arrow, "RIGHT", 2, 0)
		end
	else
		if box and box.addIconsToTop then
			hbIcon:SetPoint("TOP", arrow, "BOTTOM", 0, -2)
		else
			hbIcon:SetPoint("BOTTOM", arrow, "TOP", 0, 2)
		end
	end
end

local function UpdateHiddenBuffs()
	if not hbIcon then
		return
	end
	local n = 0
	if On(VAR_HIDDEN_BUFFS) and Collapsed() then
		n = #HiddenBuffs()
	end
	if n > 0 then
		hbIcon.count:SetText(n)
		PlaceHiddenBuffs()
		hbIcon:Show()
		if GameTooltip:IsOwned(hbIcon) then
			HiddenBuffsTooltip(hbIcon)
		end
	else
		hbIcon:Hide()
	end
end

local function MakeHiddenBuffs()
	if hbIcon or not (BuffFrame and BuffFrame.CollapseAndExpandButton) then
		return hbIcon
	end
	local b = CreateFrame("Frame", nil, BuffFrame)
	b:SetFrameLevel(BuffFrame.CollapseAndExpandButton:GetFrameLevel() + 1)
	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetAllPoints()
	b.icon:SetTexture("Interface\\Buttons\\BuffConsolidation")
	b.icon:SetTexCoord(0.109375, 0.390625, 0.21875, 0.78125)
	b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	b.count:SetPoint("BOTTOMRIGHT", -1, 1)
	b:EnableMouse(true)
	b:SetScript("OnEnter", HiddenBuffsTooltip)
	b:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	-- the times in the tooltip, once a second while it shows
	local wait = 0
	b:SetScript("OnUpdate", function(self, elapsed)
		wait = wait - elapsed
		if wait <= 0 then
			wait = 1
			if GameTooltip:IsOwned(self) then
				HiddenBuffsTooltip(self)
			end
		end
	end)
	b:Hide()
	hbIcon = b
	return b
end

local function ApplyHiddenBuffs()
	if not On(VAR_HIDDEN_BUFFS) and not hbIcon then
		return
	end
	if MakeHiddenBuffs() and not hbHooked then
		hbHooked = true
		for _, method in ipairs({ "Update", "UpdateAuraButtons", "SetBuffsExpandedState", "UpdateAuraContainerAnchor" }) do
			if type(BuffFrame[method]) == "function" then
				hooksecurefunc(BuffFrame, method, function()
					Try(UpdateHiddenBuffs)
				end)
			end
		end
		local watch = CreateFrame("Frame")
		watch:RegisterUnitEvent("UNIT_AURA", "player")
		watch:SetScript("OnEvent", function()
			Try(UpdateHiddenBuffs)
		end)
	end
	UpdateHiddenBuffs()
end

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
	Try(ApplyHiddenBuffs)
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
	items[#items + 1] = { kind = "checkbox", setting = track, settings = { track }, name = T.TRACK, tooltip = T.TRACK_DESC, newKey = "tracker" }
	-- buffs
	items[#items + 1] = { kind = "header", name = T.BUFFS }
	local hidden = ns.Pseudo(VAR_HIDDEN_BUFFS, T.HIDDEN_BUFFS, T.HIDDEN_BUFFS_DESC, false, function()
		return On(VAR_HIDDEN_BUFFS)
	end, function(on)
		Keep(VAR_HIDDEN_BUFFS, on)
		Try(ApplyHiddenBuffs)
	end)
	items[#items + 1] = { kind = "checkbox", setting = hidden, settings = { hidden }, name = T.HIDDEN_BUFFS, tooltip = T.HIDDEN_BUFFS_DESC, newKey = "hiddenbuffs" }
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
	items[#items + 1] = { kind = "checkbox", setting = qfilter, settings = { qfilter }, name = T.QFILTER, tooltip = T.QFILTER_DESC, newKey = "qfilter" }
	local qmin = ns.Pseudo(VAR_QMIN, T.QMIN, T.QMIN_DESC, false, function()
		return On(VAR_QMIN)
	end, function(on)
		Keep(VAR_QMIN, on)
		Try(ApplyTrackerMinTweak)
	end)
	items[#items + 1] = { kind = "checkbox", setting = qmin, settings = { qmin }, name = T.QMIN, tooltip = T.QMIN_DESC }
	return items
end
