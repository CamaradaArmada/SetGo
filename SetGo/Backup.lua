local _, ns = ...
local L = ns.L
local Try = ns.Try

--------------------------------------------------------------------------------
-- Backup: one code with the account's setup, to keep in a file of the
-- player's own (an addon can't write or read files) and to bring back later.
-- The game keeps the last five (SetGoDB.backups, newest first); the Backup
-- page (SetGo!'s tab) makes, applies, exports, imports and deletes them.
--   profiles: every profile, the order, the shared set (Global)
--   options:  SetGo!'s own options and the Quick Menu's
--   account:  Blizzard's account-wide settings (not graphics or sound:
--             SetGo! doesn't read those pages, they belong to the computer)
--   layouts:  the account's Edit Mode layouts
--   macros:   the account's macros and this character's
-- What sits on the action bars stays with the player; other addons' data
-- isn't in it. Restoring replaces what is there now, part by part (the
-- player ticks which), after asking; the interface reloads.
--------------------------------------------------------------------------------

local PREFIX = "SGB1:"
ns.BACKUP_PARTS = { "profiles", "options", "account", "layouts", "macros" }

-- what isn't an option of SetGo!'s (the profiles' part, what it keeps for
-- itself, the copy)
local NOT_OPTIONS = {
	profiles = true, order = true, shared = true, lastPreset = true, version = true,
	backupCopy = true, backups = true, tourSeen = true, guideSeen = true, wizardSkipped = true,
}

local function Copy(t)
	if type(t) ~= "table" then
		return t
	end
	local c = {}
	for k, v in pairs(t) do
		c[k] = Copy(v)
	end
	return c
end

local function Coder()
	local E = C_EncodingUtil
	if not (E and E.SerializeCBOR and E.DeserializeCBOR and E.CompressString and E.EncodeBase64) then
		return nil
	end
	local method = Enum and Enum.CompressionMethod and Enum.CompressionMethod.Deflate
	return E, method
end

local function AccountLayoutType()
	return Enum and Enum.EditModeLayoutType and Enum.EditModeLayoutType.Account or 1
end

--------------------------------------------------------------------------------
-- Making one
--------------------------------------------------------------------------------

local function Macros()
	local out = { account = {}, char = {} }
	if not (GetNumMacros and GetMacroInfo) then
		return out
	end
	local numAccount, numChar = GetNumMacros()
	local maxAccount = MAX_ACCOUNT_MACROS or 120
	for i = 1, numAccount or 0 do
		local name, icon, body = GetMacroInfo(i)
		if name then
			out.account[#out.account + 1] = { name = name, icon = icon, body = body or "" }
		end
	end
	for i = 1, numChar or 0 do
		local name, icon, body = GetMacroInfo(maxAccount + i)
		if name then
			out.char[#out.char + 1] = { name = name, icon = icon, body = body or "" }
		end
	end
	return out
end

local function Layouts()
	local list = {}
	local all = C_EditMode and Try(C_EditMode.GetLayouts)
	for _, layout in ipairs(type(all) == "table" and all.layouts or {}) do
		if layout.layoutType == AccountLayoutType() then
			local text = Try(C_EditMode.ConvertLayoutInfoToString, layout)
			if type(text) == "string" then
				list[#list + 1] = { name = layout.layoutName, text = text }
			end
		end
	end
	return list
end

local function AccountSettings()
	local out = {}
	if not ns.SettingsReady() then
		return out
	end
	for _, setting in ipairs(ns.PathSettings("account")) do
		local var = Try(setting.GetVariable, setting)
		local value = var and ns.SteadyValue(setting)
		if value ~= nil and type(value) ~= "table" then
			out[var] = value
		end
	end
	return out
end

function ns.MakeBackup()
	local db = ns.db
	local options = {}
	for k, v in pairs(db) do
		if not NOT_OPTIONS[k] then
			options[k] = Copy(v)
		end
	end
	return {
		v = 1, dbVersion = db.version, at = time(), by = ns.CharName and ns.CharName() or UnitName("player"),
		profiles = { profiles = Copy(db.profiles), order = Copy(db.order), shared = Copy(db.shared), lastPreset = db.lastPreset },
		options = options,
		quick = Copy(type(SetGoQuickDB) == "table" and SetGoQuickDB or {}),
		account = AccountSettings(),
		layouts = Layouts(),
		macros = Macros(),
	}
end

function ns.PackBackup(data)
	local E, method = Coder()
	if not E then
		return nil
	end
	local raw = Try(E.SerializeCBOR, data)
	local packed = raw and Try(E.CompressString, raw, method)
	local encoded = packed and Try(E.EncodeBase64, packed)
	return type(encoded) == "string" and (PREFIX .. encoded) or nil
end

function ns.UnpackBackup(text)
	local body = type(text) == "string" and strtrim(text):match("^" .. PREFIX .. "(.+)$")
	local E, method = Coder()
	if not (body and E) then
		return nil
	end
	local decoded = Try(E.DecodeBase64, (body:gsub("%s+", "")))
	local plain = decoded and Try(E.DecompressString, decoded, method)
	local data = plain and Try(E.DeserializeCBOR, plain)
	if type(data) ~= "table" or data.v ~= 1 then
		return nil
	end
	return data
end

-- The backups kept in the game, newest first (the old single copy joins
-- them)
local MAX_KEPT = 5
function ns.Backups()
	local db = ns.db
	if type(db.backups) ~= "table" then
		db.backups = {}
	end
	if type(db.backupCopy) == "table" then
		table.insert(db.backups, db.backupCopy)
		db.backupCopy = nil
	end
	table.sort(db.backups, function(a, b)
		return (a.at or 0) > (b.at or 0)
	end)
	for i = #db.backups, MAX_KEPT + 1, -1 do
		table.remove(db.backups, i)
	end
	return db.backups
end

function ns.BackupLabel(data)
	return L.BACKUP_ENTRY:format(data.at and date("%d-%m-%Y %H:%M", data.at) or "?", tostring(data.by or "?"))
end

local function Keep(data)
	table.insert(ns.Backups(), data)
	ns.Backups()
end

-- Create backup: kept in the game (export it to have the code)
function ns.CreateBackup()
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return
	end
	if not Coder() then
		ns.Print(L.MSG_BACKUP_FAILED)
		return
	end
	local data = ns.MakeBackup()
	Keep(data)
	ns.Print(L.MSG_BACKUP_CREATED:format(ns.BackupLabel(data)))
end

-- Export backup: the code of one of them, to copy
function ns.ExportBackup(data)
	local code = data and ns.PackBackup(data)
	if not code then
		ns.Print(L.MSG_BACKUP_FAILED)
		return
	end
	ns.ui.Popup("SETGO_EXPORT", L.POPUP_BACKUP_CODE:format(ns.BackupLabel(data)), { text = code })
end

function ns.DeleteBackup(data)
	local list = ns.Backups()
	for i, b in ipairs(list) do
		if b == data then
			table.remove(list, i)
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Restoring
--------------------------------------------------------------------------------

local function Count(t)
	local n = 0
	for _ in pairs(type(t) == "table" and t or {}) do
		n = n + 1
	end
	return n
end

-- Macros by name: one with the same name is changed in place (the action
-- bars that hold it keep it), the rest made; the ones not in the backup go.
-- Returns how many didn't fit.
local function RestoreMacros(list, perChar)
	if not (GetNumMacros and GetMacroIndexByName and CreateMacro and EditMacro and DeleteMacro) then
		return 0
	end
	local maxAccount = MAX_ACCOUNT_MACROS or 120
	local max = perChar and (MAX_CHARACTER_MACROS or 18) or maxAccount
	local wanted = {}
	for _, m in ipairs(list or {}) do
		wanted[m.name] = true
	end
	-- the ones not in the backup go first (room for the rest)
	local numAccount, numChar = GetNumMacros()
	local first = perChar and maxAccount + 1 or 1
	local last = perChar and maxAccount + (numChar or 0) or (numAccount or 0)
	for i = last, first, -1 do
		local name = GetMacroInfo(i)
		if name and not wanted[name] then
			Try(DeleteMacro, i)
		end
	end
	local skipped = 0
	for _, m in ipairs(list or {}) do
		local index = GetMacroIndexByName(m.name)
		local mine = index and index > 0 and ((perChar and index > maxAccount) or (not perChar and index <= maxAccount))
		if mine then
			Try(EditMacro, index, m.name, m.icon, m.body)
		else
			local a, c = GetNumMacros()
			if (perChar and c or a) < max then
				Try(CreateMacro, m.name, m.icon, m.body, perChar)
			else
				skipped = skipped + 1
			end
		end
	end
	return skipped
end

-- The account's layouts from the backup in place of the ones here (this
-- character's own, SetGo!'s among them, stay); the one in use stays in use
local function RestoreLayouts(list)
	local all = C_EditMode and Try(C_EditMode.GetLayouts)
	if type(all) ~= "table" then
		return false
	end
	local activeName
	local layouts = all.layouts or {}
	local presets = #ns.GetLayouts() - #layouts
	local active = all.activeLayout or 1
	if active > presets and layouts[active - presets] then
		activeName = layouts[active - presets].layoutName
	end
	local saved = {}
	for _, item in ipairs(list or {}) do
		local info = Try(C_EditMode.ConvertStringToLayoutInfo, item.text)
		if type(info) == "table" then
			info.layoutName = item.name
			info.layoutType = AccountLayoutType()
			saved[#saved + 1] = info
		end
	end
	for _, layout in ipairs(layouts) do
		if layout.layoutType ~= AccountLayoutType() then
			saved[#saved + 1] = layout
		end
	end
	local pos
	for i, layout in ipairs(saved) do
		if activeName and layout.layoutName == activeName then
			pos = i
		end
	end
	if pos then
		return ns.SaveLayoutsWith(saved, pos) ~= nil
	end
	-- a Blizzard layout in use (or the one in use isn't there any more)
	return ns.SaveLayoutsWith(saved, 1, active <= presets and active or 1) ~= nil
end

-- parts: { profiles = true, ... } (what was ticked)
function ns.RestoreBackup(data, parts)
	if InCombatLockdown() then
		ns.Print(L.MSG_COMBAT)
		return
	end
	local db = ns.db
	ns.LeaveForm()
	if parts.profiles and data.profiles then
		db.profiles = Copy(data.profiles.profiles) or {}
		db.order = Copy(data.profiles.order)
		db.shared = Copy(data.profiles.shared) or {}
		db.lastPreset = data.profiles.lastPreset
		-- an older backup: brought up to date on the reload
		if (tonumber(data.dbVersion) or 0) < (tonumber(db.version) or 0) then
			db.version = data.dbVersion
		end
		if ns.charDB.profile and not db.profiles[ns.charDB.profile] then
			ns.charDB.profile = nil
		end
	end
	if parts.options and data.options then
		for k, v in pairs(data.options) do
			if not NOT_OPTIONS[k] then
				db[k] = Copy(v)
			end
		end
		if type(SetGoQuickDB) == "table" and type(data.quick) == "table" then
			wipe(SetGoQuickDB)
			for k, v in pairs(data.quick) do
				SetGoQuickDB[k] = Copy(v)
			end
		end
	end
	local skipped = 0
	if parts.macros and data.macros then
		skipped = RestoreMacros(data.macros.account, false) + RestoreMacros(data.macros.char, true)
	end
	if parts.layouts and data.layouts then
		if not RestoreLayouts(data.layouts) then
			ns.Print(L.MSG_LAYOUT_FAILED)
		end
	end
	local missing = 0
	if parts.account and data.account then
		ns.PathSettings("account")
		for var, value in pairs(data.account) do
			if ns.known[var] then
				ns.staged[var] = value
			else
				missing = missing + 1
			end
		end
		ns.ApplyStaged()
	end
	if skipped > 0 then
		ns.Print(L.MSG_BACKUP_MACROS_SKIPPED:format(skipped))
	end
	if missing > 0 then
		ns.Print(L.MSG_IMPORT_SKIPPED:format(missing))
	end
	ns.Print(L.MSG_BACKUP_RESTORED)
	ReloadUI()
end

-- what the backup holds, for the question before restoring
local function Summary(data, parts)
	local lines = {}
	local function Add(part, text)
		if parts[part] then
			lines[#lines + 1] = text
		end
	end
	Add("profiles", L.BACKUP_HAS_PROFILES:format(Count(data.profiles and data.profiles.profiles)))
	Add("options", L.BACKUP_PART_OPTIONS)
	Add("account", L.BACKUP_HAS_ACCOUNT:format(Count(data.account)))
	Add("layouts", L.BACKUP_HAS_LAYOUTS:format(#(data.layouts or {})))
	Add("macros", L.BACKUP_HAS_MACROS:format(#(data.macros and data.macros.account or {}) + #(data.macros and data.macros.char or {})))
	return table.concat(lines, "\n")
end

function ns.AskRestoreBackup(data, parts)
	local any = false
	for _, part in ipairs(ns.BACKUP_PARTS) do
		any = any or parts[part] == true
	end
	if not any then
		return
	end
	local when = data.at and date("%d-%m-%Y %H:%M", data.at) or "?"
	local text = L.POPUP_BACKUP_RESTORE:format(when, tostring(data.by or "?"), Summary(data, parts))
	ns.ui.Confirm(text, function()
		ns.RestoreBackup(data, parts)
	end)
end

-- Import code: a backup code pasted, kept with the others
StaticPopupDialogs.SETGO_BACKUP_PASTE = {
	text = "%s",
	button1 = ACCEPT or "Accept",
	button2 = CANCEL or "Cancel",
	hasEditBox = true,
	maxLetters = 0,
	editBoxWidth = 320,
	OnAccept = function(self)
		local text = ns.ui.EditBoxOf(self):GetText()
		C_Timer.After(0, function()
			local backup = ns.UnpackBackup(text)
			if not backup then
				ns.Print(L.MSG_BACKUP_BAD)
				return
			end
			Keep(backup)
			ns.Print(L.MSG_BACKUP_IMPORTED:format(ns.BackupLabel(backup)))
			if ns.Refresh then
				ns.Refresh()
			end
		end)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

--------------------------------------------------------------------------------
-- The Backup page: Create, Apply (a backup, the parts), Export and Import,
-- Delete
--------------------------------------------------------------------------------

local function Find(data)
	for _, b in ipairs(ns.Backups()) do
		if b == data then
			return b
		end
	end
end

-- a dropdown of the backups kept; get/set the one picked (the newest when
-- none, or when the one picked went)
local function BackupDropdown(page, x, y, width, state)
	local dd = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate")
	dd:SetPoint("TOPLEFT", page, "TOPLEFT", x, -y)
	dd:SetWidth(width)
	Try(dd.SetDefaultText, dd, L.BACKUP_NONE)
	dd:SetupMenu(function(_, root)
		for _, b in ipairs(ns.Backups()) do
			root:CreateRadio(ns.BackupLabel(b), function()
				return state.pick == b
			end, function()
				state.pick = b
			end)
		end
	end)
	table.insert(page.refreshers, function()
		if not Find(state.pick) then
			state.pick = ns.Backups()[1]
		end
		Try(dd.GenerateMenu, dd)
	end)
	return dd
end

local function Picked(state)
	if not Find(state.pick) then
		state.pick = ns.Backups()[1]
	end
	return state.pick
end

local items
function ns.BackupItems()
	if items then
		return items
	end
	local W = ns.Widgets
	local applyState, exportState, deleteState = {}, {}, {}
	local parts = {}
	for _, part in ipairs(ns.BACKUP_PARTS) do
		parts[part] = true
	end
	local function Row(page, y, width, label, tip, onClick)
		local b = W.Button(page, 150, label, onClick, 24)
		b:SetPoint("TOPLEFT", page, "TOPLEFT", width - 150, -y)
		W.TipScripts(b, label, tip)
		return b
	end
	items = {
		{ kind = "header", name = L.BACKUP_CREATE },
		{ kind = "custom", build = function(page, y, width)
			local last = W.Text(page, W.FONT_SMALL, width - 160, "", 0.8)
			last:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -(y + 6))
			table.insert(page.refreshers, function()
				local newest = ns.Backups()[1]
				last:SetText(newest and L.BACKUP_LAST:format(ns.BackupLabel(newest)) or L.BACKUP_NONE)
			end)
			Row(page, y, width, L.BACKUP_CREATE, L.BACKUP_CREATE_DESC, function()
				ns.CreateBackup()
				ns.Refresh()
			end)
			return y + 24 + 12
		end },
		{ kind = "header", name = L.BACKUP_APPLY },
		{ kind = "custom", build = function(page, y, width)
			BackupDropdown(page, 0, y, width - 160, applyState)
			Row(page, y, width, L.BACKUP_APPLY, L.BACKUP_APPLY_DESC, function()
				local data = Picked(applyState)
				if not data then
					ns.Print(L.BACKUP_NONE)
					return
				end
				if InCombatLockdown() then
					ns.Print(L.MSG_COMBAT)
					return
				end
				ns.AskRestoreBackup(data, parts)
			end)
			y = y + 26 + 8
			for _, part in ipairs(ns.BACKUP_PARTS) do
				y = W.Checkbox(page, y, width, false, L["BACKUP_PART_" .. part:upper()], nil, function()
					return parts[part]
				end, function(on)
					parts[part] = on
				end)
			end
			return y
		end },
		{ kind = "header", name = L.BACKUP_EXPORT },
		{ kind = "custom", build = function(page, y, width)
			BackupDropdown(page, 0, y, width - 160, exportState)
			Row(page, y, width, L.BACKUP_EXPORT, L.BACKUP_EXPORT_DESC, function()
				ns.ExportBackup(Picked(exportState))
			end)
			y = y + 26 + 8
			local import = Row(page, y, width, L.BACKUP_IMPORT, L.BACKUP_IMPORT_DESC, function()
				ns.ui.Popup("SETGO_BACKUP_PASTE", L.POPUP_BACKUP_PASTE)
			end)
			import:ClearAllPoints()
			import:SetPoint("TOPLEFT", page, "TOPLEFT", width - 150, -y)
			return y + 24 + 12
		end },
		{ kind = "header", name = L.BACKUP_DELETE },
		{ kind = "custom", build = function(page, y, width)
			BackupDropdown(page, 0, y, width - 160, deleteState)
			Row(page, y, width, L.BACKUP_DELETE, L.BACKUP_DELETE_DESC, function()
				local data = Picked(deleteState)
				if not data then
					return
				end
				ns.ui.Confirm(L.POPUP_BACKUP_DELETE:format(ns.BackupLabel(data)), function()
					ns.DeleteBackup(data)
					ns.Refresh()
				end)
			end)
			return y + 26 + 12
		end },
	}
	return items
end
