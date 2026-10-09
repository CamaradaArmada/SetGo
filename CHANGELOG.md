# Changelog

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
