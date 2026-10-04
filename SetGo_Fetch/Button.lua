local _, ns = ...
local Try, IsSecret, Yes = ns.Try, ns.IsSecret, ns.Yes

-- Every attribute a button may carry. Clearing all of them is what makes an
-- empty button really empty (the 0.1 bug left "type1" and friends behind).
local ATTRIBUTES = {
	"type", "type1", "*type1",
	"spell", "spell1", "*spell1",
	"item", "item1", "*item1",
	"macro", "macro1", "*macro1",
}

local function Region(btn, key, suffix)
	local region = btn[key]
	if not region and btn:GetName() then
		region = _G[btn:GetName() .. suffix]
	end
	return region
end

function ns.CreateActionButton(name, parent, isMain)
	-- Native art first, secure template last. ActionButtonTemplate inherits
	-- FlyoutButtonTemplate, whose OnClick replaces the secure one if it comes
	-- second; Blizzard's own bar buttons use this same order.
	local btn = CreateFrame("CheckButton", name, parent, "ActionButtonTemplate, SecureActionButtonTemplate")
	btn.fpIsMain = isMain
	btn.fpIcon = Region(btn, "icon", "Icon")
	btn.fpCount = Region(btn, "Count", "Count")
	btn.fpHotKey = Region(btn, "HotKey", "HotKey")
	btn.fpName = Region(btn, "Name", "Name")
	btn.fpCooldown = Region(btn, "cooldown", "Cooldown")
	btn.fpBorder = Region(btn, "Border", "Border")

	-- Up and down, so keybinds honour "Cast on key press" like native bars.
	btn:RegisterForClicks("AnyUp", "AnyDown")
	btn:RegisterForDrag("LeftButton")

	if btn.fpHotKey then
		btn.fpHotKeyColor = { btn.fpHotKey:GetTextColor() }
		if not isMain then
			btn.fpHotKey:Hide()
		end
	end
	if btn.fpCount then
		btn.fpCount:SetText("")
		if not isMain then
			-- flyout slots: the count goes bottom left, clear of the slot key
			btn.fpCount:ClearAllPoints()
			btn.fpCount:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 4, 4)
			btn.fpCount:SetJustifyH("LEFT")
		end
	end
	if btn.fpHotKey and not isMain and NumberFontNormal then
		-- the 1 to 6 slot keys, a size up from the main buttons' keys
		btn.fpHotKey:SetFontObject(NumberFontNormal)
	end
	if btn.fpName then
		btn.fpName:SetText("")
	end
	if btn.fpBorder then
		btn.fpBorder:Hide()
	end

	-- The inherited flyout template brings the native arrow. Point its
	-- questions at our flyout so its own hover and press handling stays right.
	btn.HasPopup = function(self)
		return self.fpIsMain and ns.HasFlyContent(self.fpIndex) or false
	end
	btn.IsPopupOpen = function(self)
		return self.fpFlyout ~= nil and self.fpFlyout:IsShown()
	end
	btn.GetPopupDirection = function()
		return ns.FlyDir(ns.Layout())
	end
	btn.ClosePopup = function() end
	btn.TogglePopup = function() end

	if isMain and QuickKeybindButtonTemplateMixin then
		Mixin(btn, QuickKeybindButtonTemplateMixin)
		btn.commandName = "CLICK " .. name .. ":LeftButton"
		local qk = btn:CreateTexture(nil, "OVERLAY", nil, 2)
		qk:SetAllPoints()
		qk:SetAtlas("UI-HUD-ActionBar-IconFrame-Mouseover")
		qk:SetBlendMode("ADD")
		qk:SetAlpha(0.5)
		qk:Hide()
		btn.QuickKeybindHighlightTexture = qk
	end
	return btn
end

function ns.InQuickKeybind()
	return KeybindFrames_InQuickKeybindMode ~= nil and KeybindFrames_InQuickKeybindMode() == true
end

-- Only the left button carries an action; the right button stays free for
-- opening the flyout, so right clicks never cast anything.
function ns.ApplyAttributes(btn)
	if InCombatLockdown() then
		ns.pendingAttributes = true
		return
	end
	for _, key in ipairs(ATTRIBUTES) do
		btn:SetAttribute(key, nil)
	end
	if btn.fpIsMain then
		-- Hold to open needs the keybind to fire on release, so a hold can
		-- be told apart from a tap. Only these buttons change.
		local hold = ns.Behavior and ns.Behavior().holdMode or "OFF"
		if hold ~= "OFF" then
			btn:SetAttribute("useOnKeyDown", false)
		else
			btn:SetAttribute("useOnKeyDown", nil)
		end
	end
	local a = btn.fpAction
	-- fpSuppress: a drop is being handled by this very click, so the click
	-- must not fire; the attributes come back in PostClick.
	if not a or btn.fpDisabled or btn.fpSuppress then
		return
	end
	btn:SetAttribute("*type1", a.type)
	if a.type == "spell" then
		btn:SetAttribute("*spell1", a.id)
	elseif a.type == "item" then
		btn:SetAttribute("*item1", "item:" .. a.id)
	elseif a.type == "macro" then
		btn:SetAttribute("*macro1", a.name)
	end
end

--------------------------------------------------------------------------------
-- Cooldowns
--------------------------------------------------------------------------------

-- Returns a table describing the cooldown, or nil when there is none to show.
--   numeric: { start, duration, enabled, modRate, gcd }
--   secret spell: { object = durationObject, active, gcd }
function ns.GetCooldown(kind, id)
	if kind == "spell" then
		local info = Try(C_Spell.GetSpellCooldown, id)
		if type(info) ~= "table" then
			return nil
		end
		local gcd = info.isOnGCD
		if IsSecret(gcd) then
			gcd = nil
		end
		local start, duration = info.startTime, info.duration
		if not IsSecret(start) and not IsSecret(duration) then
			local enabled = info.isEnabled
			if IsSecret(enabled) or enabled == nil then
				enabled = true
			end
			local modRate = info.modRate
			if IsSecret(modRate) then
				modRate = nil
			end
			return { start = start or 0, duration = duration or 0, enabled = enabled, modRate = modRate, gcd = gcd }
		end
		-- Secret numbers: hand an opaque duration object to the widget instead.
		local active = info.isActive
		if IsSecret(active) then
			active = nil
		end
		return { object = Try(C_Spell.GetSpellCooldownDuration, id), active = active, gcd = gcd }
	elseif kind == "item" then
		local getter = (C_Container and C_Container.GetItemCooldown) or (C_Item and C_Item.GetItemCooldown)
		local start, duration, enable = Try(getter, id)
		if IsSecret(start) or IsSecret(duration) then
			return nil
		end
		if type(start) ~= "number" then
			return nil
		end
		local enabled = true
		if not IsSecret(enable) and (enable == 0 or enable == false) then
			enabled = false
		end
		return { start = start, duration = duration or 0, enabled = enabled }
	end
	return nil
end

-- Is this a real cooldown (not the global cooldown) that is still running?
function ns.IsCoolingDown(cd)
	if not cd or cd.gcd then
		return false
	end
	if cd.start then
		return cd.enabled and cd.start > 0 and cd.duration > 2 and (cd.start + cd.duration) > GetTime()
	end
	return cd.active == true and cd.object ~= nil
end

function ns.ApplyCooldown(frame, cd)
	if not frame then
		return
	end
	if cd and cd.start then
		if CooldownFrame_Set then
			CooldownFrame_Set(frame, cd.start, cd.duration, cd.enabled, false, cd.modRate)
		elseif cd.enabled and cd.start > 0 and cd.duration > 0 then
			frame:SetCooldown(cd.start, cd.duration, cd.modRate)
		else
			frame:Clear()
		end
	elseif cd and cd.object and frame.SetCooldownFromDurationObject then
		if not pcall(frame.SetCooldownFromDurationObject, frame, cd.object) then
			frame:Clear()
		end
	else
		frame:Clear()
	end
end

--------------------------------------------------------------------------------
-- Visual state (mirrors the native action button behaviour)
--------------------------------------------------------------------------------

local function Shown(n)
	if IsSecret(n) then
		return n
	end
	if type(n) ~= "number" then
		return ""
	end
	if n > 9999 then
		return "*"
	end
	return n
end

local function CountValue(kind, id)
	if kind == "item" then
		local consumable = Yes(Try(C_Item.IsConsumableItem, id))
		local stack = Try(C_Item.GetItemMaxStackSizeByID, id)
		local stacks = not IsSecret(stack) and type(stack) == "number" and stack > 1
		if consumable or stacks then
			return Shown(Try(C_Item.GetItemCount, id, false, true))
		end
	elseif kind == "spell" then
		local charges = Try(C_Spell.GetSpellCharges, id)
		if type(charges) == "table" then
			local max = charges.maxCharges
			if not IsSecret(max) and type(max) == "number" and max > 1 then
				return Shown(charges.currentCharges)
			end
		end
		if Yes(Try(C_Spell.IsConsumableSpell, id)) then
			return Shown(Try(C_Spell.GetSpellCastCount, id))
		end
		-- Ranged attacks show the ammo left, like the classic action bar.
		local ranged = Yes(Try(C_Spell.IsRangedWeaponSpell, id)) or Yes(Try(C_Spell.IsAutoRepeatSpell, id))
		if ranged and GetInventoryItemID then
			local ammo = Try(GetInventoryItemID, "player", 0)
			if Yes(ammo) then
				return Shown(Try(GetInventoryItemCount, "player", 0))
			end
		end
	end
	return ""
end

function ns.UpdateCount(btn)
	if not btn.fpCount then
		return
	end
	-- no "x and y or z" here: y may be secret and cannot be tested
	if btn.fpKind then
		btn.fpCount:SetText(CountValue(btn.fpKind, btn.fpID))
	else
		btn.fpCount:SetText("")
	end
end

function ns.UpdateUsable(btn)
	local icon = btn.fpIcon
	if not icon then
		return
	end
	local usable, noMana
	if btn.fpKind == "spell" then
		usable, noMana = Try(C_Spell.IsSpellUsable, btn.fpID)
	elseif btn.fpKind == "item" then
		usable, noMana = Try(C_Item.IsUsableItem, btn.fpID)
	else
		icon:SetVertexColor(1, 1, 1)
		return
	end
	if IsSecret(usable) or IsSecret(noMana) then
		icon:SetVertexColor(1, 1, 1)
	elseif usable then
		icon:SetVertexColor(1, 1, 1)
	elseif noMana then
		icon:SetVertexColor(0.5, 0.5, 1)
	else
		icon:SetVertexColor(0.4, 0.4, 0.4)
	end
end

function ns.UpdateChecked(btn)
	local checked = false
	if btn.fpKind == "spell" then
		checked = Yes(Try(C_Spell.IsCurrentSpell, btn.fpID))
	elseif btn.fpKind == "item" then
		checked = Yes(Try(C_Item.IsCurrentItem, btn.fpID))
	end
	btn:SetChecked(checked)
end

function ns.UpdateEquipped(btn)
	local border = btn.fpBorder
	if not border then
		return
	end
	if btn.fpKind == "item" and Yes(Try(C_Item.IsEquippedItem, btn.fpID)) then
		border:SetVertexColor(0, 1, 0, 0.35)
		border:Show()
	else
		border:Hide()
	end
end

function ns.UpdateHotkey(btn)
	local hotkey = btn.fpHotKey
	if not hotkey or not btn.fpIsMain then
		return
	end
	local key = GetBindingKey("CLICK " .. btn:GetName() .. ":LeftButton")
	if key then
		hotkey:SetText(GetBindingText(key, true))
		hotkey:Show()
	else
		hotkey:SetText(RANGE_INDICATOR)
		hotkey:Hide()
	end
	ns.UpdateRange(btn)
end

-- Native behaviour: the keybind turns red out of range; with no keybind a
-- dot shows only while the range can be checked.
-- Spells only. Item range (C_Item.IsItemInRange) is protected in combat: a
-- call there is blocked (ADDON_ACTION_BLOCKED), and pcall can't stop that,
-- so items never show range.
function ns.UpdateRange(btn)
	local hotkey = btn.fpHotKey
	if not hotkey or not btn.fpIsMain then
		return
	end
	local inRange
	if btn.fpAction and UnitExists("target") then
		if btn.fpKind == "spell" then
			inRange = Try(C_Spell.IsSpellInRange, btn.fpID, "target")
		end
		if IsSecret(inRange) then
			inRange = nil
		end
	end
	local color = btn.fpHotKeyColor or { 0.6, 0.6, 0.6 }
	if hotkey:GetText() == RANGE_INDICATOR then
		if inRange == nil then
			hotkey:Hide()
		else
			hotkey:Show()
			if inRange then
				hotkey:SetTextColor(color[1], color[2], color[3])
			else
				hotkey:SetTextColor(1, 0.1, 0.1)
			end
		end
	elseif inRange == false then
		hotkey:SetTextColor(1, 0.1, 0.1)
	else
		hotkey:SetTextColor(color[1], color[2], color[3])
	end
end

function ns.UpdateButton(btn)
	local a = btn.fpAction
	local icon = btn.fpIcon
	if not a then
		btn.fpKind, btn.fpID = nil, nil
		if icon then
			icon:Hide()
		end
		ns.ApplyCooldown(btn.fpCooldown, nil)
		if btn.fpCount then
			btn.fpCount:SetText("")
		end
		if btn.fpName then
			btn.fpName:SetText("")
		end
		if btn.fpBorder then
			btn.fpBorder:Hide()
		end
		btn:SetChecked(false)
		ns.UpdateRange(btn)
		return
	end

	btn.fpKind, btn.fpID = ns.Resolve(a)
	if icon then
		icon:SetTexture(ns.GetIcon(a) or ns.QUESTION_MARK)
		icon:Show()
	end
	if btn.fpName then
		btn.fpName:SetText(a.type == "macro" and a.name or "")
	end
	ns.UpdateCount(btn)
	ns.UpdateUsable(btn)
	ns.UpdateChecked(btn)
	ns.UpdateEquipped(btn)
	if btn.fpKind then
		ns.ApplyCooldown(btn.fpCooldown, ns.GetCooldown(btn.fpKind, btn.fpID))
	else
		ns.ApplyCooldown(btn.fpCooldown, nil)
	end
	ns.UpdateRange(btn)
end

function ns.ShowTooltip(btn)
	local a = btn.fpAction
	if not a then
		return
	end
	ns.AnchorTooltip(btn)
	local kind, id = ns.Resolve(a)
	if kind == "spell" then
		GameTooltip:SetSpellByID(id)
	elseif kind == "item" then
		GameTooltip:SetItemByID(id)
	else
		GameTooltip:SetText(a.name or "")
	end
	GameTooltip:Show()
end
