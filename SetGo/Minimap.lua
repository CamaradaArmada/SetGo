local ADDON, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Minimap button (LibDBIcon, so minimap button collectors pick it up) and the
-- menu it shares with the addon menu by the minimap: left click opens
-- SetGo!, right click lists where to go (and Quick!, when it is on).
--------------------------------------------------------------------------------

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
		-- Quick! (the module, when on): the small menu by the minimap; the
		-- book itself opens with a left click
		if ns.ModuleOn("quick") and type(SetGo_ToggleQuick) == "function" then
			root:CreateDivider()
			root:CreateButton(L.MENU_QUICK, function()
				SetGo_ToggleQuick()
			end)
		end
	end)
end

-- the addon menu by the minimap (## AddonCompartmentFunc in the .toc)
function SetGo_Open(_, button)
	if button == "RightButton" then
		ns.ContextMenu(AddonCompartmentFrame or UIParent)
	else
		ns.Toggle()
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
		icon = "Interface\\Icons\\Ability_Rogue_Sprint",
		OnClick = function(self, button)
			if button == "RightButton" then
				ns.ContextMenu(self)
			else
				ns.Toggle()
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(L.ADDON)
			tooltip:AddLine(L.MINIMAP_TIP, 1, 1, 1)
		end,
	})
	icon:Register(ADDON, object, ns.db.minimap)
end
