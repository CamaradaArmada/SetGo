local ADDON, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Minimap button (LibDBIcon, so minimap button collectors pick it up) and the
-- menu it shares with the addon menu by the minimap. Left click: a module's
-- own window when one asks for it (Quick!, with minimapClick) and is on,
-- else SetGo!; Shift+click: SetGo! always; right click: the menu.
--------------------------------------------------------------------------------

-- the module that takes the minimap button's click (on), if any
local function ClickModule()
	for _, def in ipairs(ns.modules or {}) do
		if type(def.minimapClick) == "function" and ns.ModuleOn(def.key) then
			return def
		end
	end
end

local function Click(button)
	local def = ClickModule()
	if def and not IsShiftKeyDown() then
		ns.Try(def.minimapClick)
	else
		ns.Toggle()
	end
end

function ns.ContextMenu(owner)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		ns.Toggle()
		return
	end
	MenuUtil.CreateContextMenu(owner, function(_, root)
		root:CreateTitle(L.ADDON)
		-- the favourite profiles: apply, after asking
		local favorites = ns.Favorites()
		local active = ns.ActivePreset()
		for _, name in ipairs(favorites) do
			local label = name == active and L.MENU_FAVORITE_ACTIVE:format(name) or name
			root:CreateButton(label, function()
				ns.ConfirmApply(name)
			end)
		end
		if #favorites == 0 then
			local none = root:CreateButton(L.MENU_NO_FAVORITES)
			if none.SetEnabled then
				none:SetEnabled(false)
			end
		end
		root:CreateDivider()
		-- the modules: on and off (the interface reloads after asking)
		local modules = root:CreateButton(L.MODULES)
		for _, m in ipairs(ns.KNOWN_MODULES) do
			if ns.AddonInstalled(m.addon) then
				modules:CreateCheckbox(L[m.title], function()
					return ns.ModuleOn(m.key)
				end, function()
					ns.SetModuleOn(m.key, not ns.ModuleOn(m.key))
					ns.OnModuleToggled()
				end)
			end
		end
		-- SetGo! itself
		root:CreateDivider()
		root:CreateButton(L.MENU_CONFIGURE, function()
			ns.Open()
		end)
	end)
end

-- the addon menu by the minimap (## AddonCompartmentFunc in the .toc)
function SetGo_Open(_, button)
	if button == "RightButton" then
		ns.ContextMenu(AddonCompartmentFrame or UIParent)
	else
		Click(button)
	end
end

function ns.SetupMinimapButton()
	local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
	local icon = LibStub and LibStub("LibDBIcon-1.0", true)
	if not (LDB and icon) then
		return
	end
	ns.db.minimap = type(ns.db.minimap) == "table" and ns.db.minimap or {}
	local object = LDB:NewDataObject(ADDON, {
		type = "launcher",
		text = L.ADDON,
		icon = ns.ICON,
		OnClick = function(self, button)
			if button == "RightButton" then
				ns.ContextMenu(self)
			else
				Click(button)
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(L.ADDON)
			local def = ClickModule()
			if def then
				tooltip:AddLine(L.MINIMAP_TIP_MODULE:format(def.title or def.key), 1, 1, 1)
			else
				tooltip:AddLine(L.MINIMAP_TIP, 1, 1, 1)
			end
		end,
	})
	icon:Register(ADDON, object, ns.db.minimap)
end
