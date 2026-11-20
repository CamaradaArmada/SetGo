local _, ns = ...

--------------------------------------------------------------------------------
-- The changelog SetGo!'s settings show (its Changelog tab), newest first.
-- Written by the optimization conversation at each public version, from the
-- CurseForge changelog. Plain text: "|cffffd100...|r" for a heading.
--------------------------------------------------------------------------------

ns.CHANGELOG = {
	{
		version = "1.3.0",
		title = "SetGo! 1.3.0",
		text = [[
|cffffd100New features|r
• Speak! Chat Board (replaces Copy chat): a window for everything that isn't players talking to you, so the chat can stay for talking: public channels, system messages, what commands and addons print, loot, money, experience, reputation, achievements and more. Tabs work as in the chat, each with its own channels and kinds of message, and can keep their history after a reload. A Whispers side has a tab per conversation. It has a typing box, a search, and Copy for the messages you tick. Pin a tab to see its new messages over the game while the Board is closed, with an alert sound if you want one. Opens from the chat settings button's menu or a key in Key Bindings.
• Share tracked quests: in a group, a button next to the quest filter shares each tracked quest that someone in the group hasn't got.

|cffffd100Improvements|r
• Quest filter: in a zone with no quests in your log, it keeps the quests you already track, and a filter that would leave nothing to track is skipped, shown in grey in the tooltip instead of a chat message. Arriving in a new zone no longer empties the tracker.
• Quest filter with an empty tracker: the filter button stays where it was, so you can always bring quests back.
• Highlight Shared Quests (was Shared Quests in Blue): a soft blue glow behind the titles of the quests your group is on too, since this client can't recolour the titles.
• Live preview: on the profile in use, action bars and Blizzard's frames show or hide on the Layout tab as you tick them, so you see them before applying.
• Hide! Rules: each card is now a rule with its own frames (picked by kind), conditions, Show or Hide, delay and cooldown icons, so frames that show and hide together are set up once. Your cards carry over.

|cffffd100Fixes|r
• 5 performance improvements or bug fixes.]],
	},
	{
		version = "1.2.0",
		title = "SetGo! 1.2.0",
		text = [[
|cffffd100New features|r
• New SetGo! window: Blizzard's portrait frame with a narrow column of profile cards (drag or use the arrows to reorder them), + New to start a profile at once, and three tabs per profile: Layout, Addons and Interface Tweaks. It opens where Blizzard's windows open.
• Settings page: the gear opens SetGo!'s settings: minimap icon, addon compartment, sounds, window size and keybinds; which chat messages show; switching all modules off; the last 20 errors, ready to copy for a report; and About, with this Changelog.
• Hidden Buffs Icon: a new Interface Tweak. While the buffs' arrow hides the long buffs, an icon next to it shows how many there are; mouse over it for the list with the time left on each.
• Shared Quests in Blue: a new Interface Tweak. In the objective tracker, the titles of the quests someone in your group is on too show in the party's blue.
• Hide! In an instance: a new condition for dungeons, raids, battlegrounds, arenas and scenarios.
• What's new: new features show Blizzard's "New" or blue dot until you've seen them.

|cffffd100Improvements|r
• A profile from the start: every character gets a profile at once, with nothing changed in the game, so there is always somewhere to keep your settings. The welcome window and first profile guide are gone.
• Quest filter button: combine a zone, Untrack High Level and the new Track Shared Quests, then Completed or Not Completed over all of them; a left click applies the kept filter again after changing zone.
• Hide! cards: the page shows a card only for each frame you hide, each with its own conditions, out of combat delay, cooldown icons and an Anchored frames dropdown to choose which frames follow it.
• Hide! In a group: In a party and In a raid are now one condition, so the list stays short.
• SetGo! Tracker: now drawn like the minimap's day and night indicator and placed opposite it, so it looks like part of Blizzard's minimap.

|cffffd100Fixes|r
• 10 performance improvements or bug fixes.]],
	},
	{
		version = "1.1.0",
		title = "SetGo! 1.1.0",
		text = [[
|cffffd100New features|r
• SetGo! Tracker: a new UI Tweak. A round minimap button for your tracking skills (herbs, minerals, treasure and others), in colour while on and grey while off. Left click turns it on or off, even in combat; right click picks which one.
• Open All Bags with Right Click: a new UI Tweak. A right click on the backpack button opens or closes all your bags at once; a left click still opens only the backpack.
• Quest filter button: a new UI Tweak, next to the objective tracker's minimize button. Left click tracks only the quests of your current zone; right click offers All, each zone in your quest log, and Untrack High Level.
• Simplified Minimized Tracker: a new UI Tweak. While the objective tracker is minimized, only its minimize button shows.

|cffffd100Improvements|r
• Action bar art: the bars are now chosen in one dropdown, instead of a checkbox each, so the UI Tweaks page stays short.
• Speak! Copy chat: the copied text keeps the chat's own colours, with a blank line between messages, so it reads like the chat.

|cffffd100Fixes|r
• 4 performance improvements or bug fixes.]],
	},
	{
		version = "1.0.0",
		title = "SetGo! 1.0.0",
		text = [[
|cffffd100New features|r
• UI Tweaks: experimental changes to Blizzard's interface. Each profile keeps its own set, switched with the profile; a new profile starts with all of them off.
   - Quest item sparkles: quest items on the ground always show the game's loot sparkle, even after a graphics preset turns it off.
   - Action bar art: action bar 1's art (the frame, the slot behind each button and the dividers) on any of action bars 2 to 8.
   - Better XP bar: the experience and reputation bars can be made narrower than Blizzard allows, from 25% to 100% of their width. With Unified Bar, a tracked reputation shares one bar with experience, and a right click switches between them.
• Hide! Buffs and Debuffs: your buffs and debuffs can now be shown or hidden with macro conditions, each with its own rule.
• Speak! Copy chat: in the settings button's menu, opens the selected chat window's text in a large window, ready for Ctrl+C.

|cffffd100Improvements|r
• Profiles keep your addon list: addons switched on or off in the game's addon list are saved to the profile in use when you close it with Okay (if the profile has Change addons ticked).
• All keybinds in one place: SetGo!, Fetch! and Look! keybinds sit together in their own "SetGo!" section of Blizzard's Key Bindings.
• Hide! Cooldown icons: the icons over hidden bars now have the action buttons' frame and rounded corners.

|cffffd100Fixes|r
• 10 performance improvements or bug fixes.]],
	},
}

--------------------------------------------------------------------------------
-- What is new in this version: a blue dot on each one (its key, as the
-- page's item says it with newKey), and Blizzard's "New" on the tab that
-- holds them while any dot is still unseen. Reviewed with César at each
-- public version: a feature stays new in the version it comes out and the
-- next one.
--------------------------------------------------------------------------------

-- key = where its mark is: "tweaks" (a dot on the Interface Tweaks tab, and
-- "New" on the tab), "gear" ("New" beside the gear until the settings page
-- opens), "hide" ("New" beside the condition in Hide!'s menu until it is
-- pointed at), "module" (a dot on a module's option, its newKey, and on the
-- module's icon on the Addons tab, until its options are opened)
ns.NEW_FEATURES = {
	qshare = "tweaks", -- Interface Tweaks: quest filter, with Share tracked quests (1.3.0; was qfilter in 1.2.0)
	tracker = "tweaks", -- Interface Tweaks: the minimap Tracker, as the day and night indicator
	hiddenbuffs = "tweaks", -- Interface Tweaks: hidden buffs icon
	qshared = "tweaks", -- Interface Tweaks: shared quests in blue
	settings = "gear", -- SetGo!'s settings page
	instance = "hide", -- Hide!: the "In an instance" condition
	board = "module", -- Speak!: the Chat Board (a dot on its option and on Speak!'s icon, Addons tab)
}

-- new and not seen yet by this account
function ns.IsNew(key)
	if not (key and ns.NEW_FEATURES and ns.NEW_FEATURES[key]) then
		return false
	end
	local seen = ns.db and ns.db.newSeen
	return not (seen and seen[key])
end

function ns.SeeNew(key)
	if ns.db and key then
		ns.db.newSeen = ns.db.newSeen or {}
		ns.db.newSeen[key] = true
	end
end
