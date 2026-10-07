NILS = { LibStub = true }
dofile(arg[1] .. "/mock_pre.lua")
-- Generic WoW mock: unknown globals and methods return permissive mocks.
local Mock
local mockMT = {}
mockMT.__index = function(t, k)
	if k == "IsForbidden" or k == "IsShown" or k == "IsVisible" or k == "IsMouseOver" or k == "GetChecked" then
		return function() return false end
	end
	local v = Mock()
	rawset(t, k, v)
	return v
end
mockMT.__call = function(self, ...)
	return Mock()
end
function Mock()
	return setmetatable({}, mockMT)
end
MOCK = Mock

-- frames with scripts, hooks and real state
local frames = {}
FRAMES = frames
local function NewFrame(kind, name, parent)
	local f = Mock()
	f._scripts, f._hooks, f._events, f._shown, f._alpha = {}, {}, {}, true, 1
	f.SetScript = function(self, s, fn) self._scripts[s] = fn end
	f.GetScript = function(self, s) return self._scripts[s] end
	f.HookScript = function(self, s, fn) self._hooks[s] = self._hooks[s] or {}; table.insert(self._hooks[s], fn) end
	f.RegisterEvent = function(self, e) self._events[e] = true end
	f.RegisterUnitEvent = function(self, e) self._events[e] = true end
	f.UnregisterEvent = function(self, e) self._events[e] = nil end
	f.Show = function(self) if not self._shown then self._shown = true; FIRE_SCRIPT(self, "OnShow") end end
	f.Hide = function(self) if self._shown then self._shown = false; FIRE_SCRIPT(self, "OnHide") end end
	f.SetShown = function(self, v) if v then self:Show() else self:Hide() end end
	f.IsShown = function(self) return self._shown end
	f.IsVisible = function(self) return self._shown and (not self._parent or self._parent == UIParent or self._parent:IsVisible()) end
	f.SetAlpha = function(self, a) self._alpha = a end
	f.GetAlpha = function(self) return self._alpha end
	f.GetParent = function(self) return self._parent end
	f.SetParent = function(self, p) self._parent = p end
	f.GetName = function(self) return self._name end
	f.GetStringHeight = function() return 14 end
	f.GetStringWidth = function() return 40 end
	f.GetText = function(self) return self._text end
	f.SetText = function(self, t) self._text = t end
	f.GetNumChildren = function() return 0 end
	f.GetWidth = function() return 45 end
	f.GetFrameLevel = function() return 1 end
	f._enabled = true
	f.SetEnabled = function(self, v) self._enabled = v and true or false end
	f.IsEnabled = function(self) return self._enabled end
	f.GetHeight = function() return 45 end
	local function Child(self) return NewFrame("Region", nil, self) end
	f.CreateFontString, f.CreateTexture, f.CreateMaskTexture, f.CreateAnimationGroup, f.CreateAnimation = Child, Child, Child, Child, Child
	f._name, f._parent = name, parent
	if name then _G[name] = f end
	frames[#frames + 1] = f
	return f
end
NEWFRAME = NewFrame
function FIRE_SCRIPT(f, s, ...)
	if f._scripts[s] then f._scripts[s](f, ...) end
	for _, fn in ipairs(f._hooks[s] or {}) do fn(f, ...) end
end
function FIRE_EVENT(e, ...)
	for _, f in ipairs(frames) do
		if f._events[e] and f._scripts.OnEvent then f._scripts.OnEvent(f, e, ...) end
	end
end
CreateFrame = function(kind, name, parent) return NewFrame(kind, name, parent) end
UIParent = NewFrame("Frame", "UIParent")
UIParent._parent = nil

local hooks = {}
function hooksecurefunc(a, b, c)
	local t, name, fn = _G, a, b
	if type(a) == "table" then t, name, fn = a, b, c end
	local orig = t[name]
	t[name] = function(...)
		local r = { orig(...) }
		fn(...)
		return unpack(r)
	end
end

C_Timer = {
	After = function(_, fn) TIMERS = TIMERS or {}; table.insert(TIMERS, fn) end,
	NewTicker = function(d, fn) TICKERS = TICKERS or {}; local t = { fn = fn, Cancel = function(self) self.dead = true end }; table.insert(TICKERS, t); return t end,
}
function RUN_TIMERS()
	local list = TIMERS or {}
	TIMERS = {}
	for _, fn in ipairs(list) do fn() end
end
function RUN_TICKERS()
	for _, t in ipairs(TICKERS or {}) do if not t.dead then t.fn() end end
end

GetLocale = function() return "ptBR" end
InCombatLockdown = function() return COMBAT == true end
wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
strtrim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
unpack = unpack or table.unpack
time = os.time
print = print
UISpecialFrames = {}
UIPanelWindows = {}
StaticPopupDialogs = {}
POPUPS = {}
StaticPopup_Show = function(which, text, _, data) table.insert(POPUPS, { which = which, text = text, data = data }) end
C_Texture = { GetAtlasInfo = function(a) return ATLASES and ATLASES[a] and {} or nil end }
PlaySound = function() end
ReloadUI = function() RELOADED = (RELOADED or 0) + 1 end

setmetatable(_G, { __index = function(t, k)
	if NILS[k] or (type(k) == "string" and (k:match("^[A-Z_][A-Z0-9_]*$") or k:match("DB$"))) then
		return nil -- global strings / constants: let code fall back
	end
	local v = Mock()
	rawset(t, k, v)
	return v
end })

function LOAD(folder, files, addon, ns)
	for _, f in ipairs(files) do
		local chunk, err = loadfile(folder .. "/" .. f)
		assert(chunk, err)
		chunk(addon, ns)
	end
end
