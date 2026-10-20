# Changelog

## 0.10.2

SetGo! (build 12)
- A module's tips (Fetch!) count as seen once they start, so they no
  longer show again on every login when the last one, which waits for a
  flyout to open, was never reached. Nothing shows while the help tips
  can't show (combat).

## 0.10.1

SetGo! (builds 9 to 11)
- Presets retuned (Retail UI's layout and module options), with
  descriptions by width: two bars, one and a half, one.
- The first profile's guide (Wizard.lua) is gone: Blizzard's help tips
  walk through the profile form itself (Tour.lua, ns.StartGuide), and Show
  the tour replays them.
- Current configuration preset: a profile of the interface as it is now,
  named My Profile 1 with the class icon.
- Presets menu: pick one, then Apply (at once) or Customize (the form,
  filled in from it).
- Profile form: tabs Layout, Settings, Modules, Addons; Back and Next at
  the bottom, Save and Apply always in the middle.
- Info buttons next to the harder options, with a longer explanation; their
  tooltips are one short line.
- After the first profile, a tip on the minimap button: Quick Menu,
  favourites, Shift+click.
- Help tips inside the SetGo! window are no longer covered by its buttons.
- The guide's strings and ns.FormModuleItems, used by nothing, gone.

Fetch! (build 2)
- Three tips the first time it is on: dragging onto a button, opening a
  flyout, keys 1 to 6 in a flyout.

Hide! (build 6), Speak! (build 2)
- No tip in the tour any more.

## 0.10.0

SetGo! (builds 4 to 8)
- Window size: a checkbox and slider (75% to 150%) on the SetGo! page;
  the SetGo! window, the guide and the Quick Menu follow it
  (ns.ScaleFrame), applied with the page's Apply button.
- GitHub button on the SetGo! page: a popup with the address to copy.
- SetGo! page grouped under General, Window size, Keybinds and Help; the
  tour and GitHub buttons side by side at the bottom.
- Options with a checkbox and a slider show both on one line.
- Import is a menu, as Export: Character settings and Keybindings (off
  each time), then Import.
- Import: when the layout in the code doesn't load in this game,
  everything else is still imported and the Layout tab asks for one.
- Tour: a tip next to a frame at the edge of the screen moves to the side
  with room, so its button stays on screen.
- ns.AceOfAddon, called by nothing, gone again (it came back with a build
  made from an older copy).

## 0.9.3

New version numbering: one public version for the whole package (SetGo!
and its modules), 0.x while in beta. 0.9.3 follows 0.34.3. Each addon's
own build is in its toc as X-Build.

SetGo! (build 3)
- Addons tab cards: the Ace3 profile field sits on the first line, next to
  the checkbox; the "+ N addons" button sits centred under a thin rule.
- Change addons switches the other addons on and off for this character
  (by its GUID, as the game's addon list does), so applying the profile no
  longer keeps asking to apply again.
- ns.AceOfAddon, called by nothing, gone.

Hide! (build 5)
- Names out of combat and the hidden buffs icon, tried in test builds and
  taken out: the names they hid go back to the player's values, and their
  saved data goes.

## 0.30.0 to 0.34.3

- Addons tab in a profile (Addons.lua), shown while there are other addons:
  - Change addons: the profile switches the other addons on or off on this
    character, as the game's addon list does (a reload). Addons installed
    later are left as they are; SetGo! and its modules stay on the Modules
    tab. Each addon shows its icon, version (red when out of date), author
    and the addons that go with it.
  - Ace3 addons: the profile each one switches to when the profile is
    applied, or Don't change. Only the name: a profile the addon doesn't
    have here is skipped. Addons switched on by the profile get theirs
    after the reload.
- Export: character settings and keybinds can go too, ticked in the
  Export menu (off each time). Import puts them in the profile's own set;
  settings this game doesn't have are left out, and said so.
- The code is compressed with Blizzard's own functions (SGP2:); older
  codes (SGP1) are still read.
- Apply counts the addons and Ace3 profiles to change.

## 0.29.1, Fetch! 0.12.2, Hide! 0.7.2

Cleanup only: nothing changes in the game.

- Code nothing calls any more, gone: the old Quick settings page, account
  layouts made by SetGo!, and functions and aliases left from earlier
  versions.
- Strings nothing shows, gone (EN and PT), and older copies of strings a
  later version replaced.
- The author's tools are no longer in the addon: /setgo template, /setgo
  find, /setgo report, /fetch dump and /fetch debug.

## 0.29.0

- A new profile starts on a presets menu: Blizzard's two layouts, side by
  side, then SetGo!'s presets. Picking one applies it at once, after asking
  (the interface reloads). Custom opens the profile's tabs; Back on the
  first tab returns to the menu. The guide's Presets step uses the same
  menu.
- A Blizzard layout as a preset: its layout only, the modules off, and
  settings, keybinds and bar slots on Global.
- The presets are gone from SetGo!'s page and from Copy from.
- Layout tab: no "This profile" cell. A profile keeps its own layout, with
  nothing picked, until another is picked.
- Edit Mode opens after the reload only for a layout made with + New, never
  for a preset or an import.
- The guide's texts no longer say Edit Mode opens after saving: they say
  to open it once the profile is applied.
- Quick Menu: Show silhouette when obscured (when the client has it); Quiet!
  with its short name.

## 0.28.0, Fetch! 0.12.1

- The Fetch! bar (place, size, buttons, art) goes with the profile's
  layout: saved in the profile when Edit Mode closes, put on when the
  profile is applied, and carried by Copy from, export, import and the
  presets (a new F part in the code; older versions read past it).
- Modules can keep data per layout with GetLayoutData(name) and
  SetLayoutData(name, data) in SetGo.RegisterModule.
- Profiles from before take their bar from their layout the first time it
  is written.
- The three presets exported again, with their bar (Battle for Azeroth UI,
  "for" in lower case).

## 0.27.1

- The SetGo! layout is made the one in use (as Edit Mode does: announced,
  then switched to), not Blizzard's.
- Edit Mode opens after the reload only for a layout made with + New. The
  guide and the presets don't open it.

## 0.27.0

- A profile keeps its Edit Mode layout inside it, as text. Each character
  has one SetGo! character layout, "SetGo!: <profile>", rewritten when the
  profile changes: the account's layout slots are no longer used.
- What you change in Edit Mode goes back into the profile in use when Edit
  Mode closes. On another character with that profile, SetGo! asks before
  putting the newer layout on.
- Profiles from before read their layout's text the first time it is
  needed. The account layouts SetGo! made before stay where they are.
- Profile form, Layout tab: "This profile" keeps its layout; picking
  another starts it again from that one.
- /setgo tour.
- Preset Battle For Azeroth UI updated.

## Fetch! 0.11.0 to 0.12.0

- From the Fetch! conversation: bar art (Art.lua), snapping (Snap.lua) and
  /fetch dump (Dump.lua).

## Fetch! 0.10.1, Hide! 0.7.1, Speak! 1.0.3

- Their tips in SetGo!'s tour: Fetch! at its bar, Speak! at the chat,
  Hide! in the middle of the screen.

## 0.26.0

- The tour: Blizzard's help tips, one at a time, over the minimap button
  (the Quick Menu) and the modules that are on. It starts once after the
  first profile (when Edit Mode closes after the reload), and from
  SetGo!'s page (Show the tour). Modules add their tips with a "tour"
  field in SetGo.RegisterModule.

## 0.25.1

- The presets: Forever UI, Battle For Azeroth UI and Retail UI (in place
  of the test one).

## 0.25.0

- Quick! is part of SetGo!: the Quick Menu, on the minimap button's click
  (Shift+click: SetGo!). Its key is on SetGo!'s page. The SetGo_Quick
  folder is switched off if it is still there, and can be deleted.
- The guide: a welcome page with what a profile keeps; a Presets page
  (Custom goes on; skipped while there are none); name, icon and the screen
  on one page; then the modules. Leaving reloads only when action bars
  were switched.
- Presets (PresetData.lua): on SetGo!'s page (each makes a profile of its
  own and applies it) and in Copy from on a new profile. A test one:
  Minimal.
- Export and import carry the layout, what it shows and the modules only:
  character settings, keybinds and bar slots stay with the player.
- "Bar Slots" for what sits on the action bars.

## 0.24.1

- The guide's screen step switches the action bars and Blizzard's
  elements through Blizzard's own settings, so they show at once. Leaving
  after such a change puts the screen back and reloads (from Blizzard's
  popup), to clear what the preview touched.
- Import on a profile already made replaces it (asked first; its name
  stays, nothing is kept until saved). On a new profile, as before.
- New profile form: Back, next to Next.
- Copy from on the header: a field a little darker, with Blizzard's arrow.
- The reload note sits under the module list.

## 0.24.0

- The first profile has its own guide, a book of one page in four steps:
  what a profile is (or Skip, straight to SetGo!), name and icon (and the
  presets that come with SetGo!, applied at once), the screen (action bars
  and Blizzard's elements switch on at once, and go back if you leave
  without saving) and the modules, each with what it does. Settings,
  keybinds and action bars start on Global. Shown while the account has no
  profile; new profiles after that use the form.
- Presets: PresetData.lua lists exported profiles (none yet); the guide
  shows them when there are any.
- Profile form: Import profile on the header, next to Copy from.
- Module switches carry an asterisk; changing one shows "These changes
  require a reload."

## 0.23.1

- Quick! first in the module list, and on until switched off.

## 0.23.0

- Module pages (and SetGo!'s) open with a header: round icon, name and
  what it does.
- Settings tab: Copy from is Blizzard's dropdown, on Global too (it asks
  first: the shared set changes for every profile on Global). Global
  action bars have none.
- Action bars copied into the profile in use wait for Apply; moving a
  button meanwhile doesn't overwrite them.
- Closing with unsaved changes: Apply and Exit saves and applies.
- Minimap button: click opens Quick! when it is on (Shift+click: SetGo!);
  the menu's Configure opens SetGo!.
- Quick! 1.1.0: Open SetGo! on top, Always Show Nameplates, Quiet! as a
  checkbox.
- Look!: new icon.

## Speak! 1.0.2

- New defaults: Bordered style, Blizzard's font, background with the mouse
  away at 50%, selected tab 50%, other tabs 25%, tab text size 12, settings
  button 50%. Settings already saved keep their values.

## Hide! 0.6.1

- Cooldown icons show the whole icon, borders included.
- "Show abilities on cooldown" is now first in the Action bars section.

## Hide! 0.6.0

- New in Action bars: "Show abilities on cooldown". While Hide! hides an
  action bar, its abilities on cooldown still show where their button is,
  with the cooldown swipe and the charges left. The global cooldown doesn't
  count.
- The action bar art copy is gone.

## 0.22.0

- Profiles have a Settings tab in place of Options: character settings,
  keybinds and action bars, each Global (shared) or the profile's own, with
  Copy from.
- Changes made in Blizzard's Options window are saved into the profile in
  use (or the shared set), like keybinds and action bars.
- The Game Settings tab, the search and the Blizzard defaults page are gone.
- Module buttons show each module's icon. SetGo! uses a game icon; the
  logo files are gone.

## 0.21.0

First version on GitHub.

- Profiles with three tabs: Layout, Modules and Options.
- Modules: Fetch!, Look!, Speak!, Hide! and Quick!.
- Profiles exported and imported as text, with their settings and modules.
- Closing with unsaved changes asks first; combat closes the window and
  brings it back where it was.
