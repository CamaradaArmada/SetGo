# SetGo!

Quick setup for the Blizzard UI, made for World of Warcraft Forever.

SetGo! keeps your setup in **profiles** you can put on any character with
two clicks:

- an **Edit Mode layout**, kept inside the profile (each character gets one
  SetGo! layout of its own, so your account's layout slots are left alone),
  the action bars it shows and the UI elements it switches on (cooldown
  manager, resource display, damage meter, swing timer);
- the **modules** it switches on, with their options;
- your **character settings**, **keybinds** and **bar slots**. Each one is
  either **Global** (one set shared by every profile that uses it; for the
  action bars, Blizzard's own behaviour) or the profile's own. Changes you
  make in the game are saved into whichever set the profile uses. Action
  bars are kept per character and specialization.

Profiles can be exported as text and imported on another account (layout,
what it shows and modules; settings, keybinds and bar slots stay with you).
A guide makes the first profile, from scratch or from one of the presets
that come with SetGo!, and a short tour shows what each part does.

The **Quick Menu** opens from the minimap button: nameplates, NPC names,
volume and Quiet!, which hides the world channels from the chat.

## Modules

Each module is a separate addon folder. They are switched on and off inside
SetGo!, not in the game's addon list.

| Module | What it does |
| --- | --- |
| **Fetch!** | A bar of up to 12 buttons, each with a six slot flyout for spells, items and macros. It can sit right on top of the bag bar. |
| **Look!** | A key turns the mouse into camera control, with a dot in the middle of the screen and soft targeting, like an action game. |
| **Speak!** | A cleaner chat in the style of the new interface: Blizzard fonts, fading tabs and one settings button. |
| **Hide!** | Hides Blizzard frames like a macro: always, or only when (or except when) you are in combat, mounted, holding a key and more. |

## Install

Copy the folder `SetGo` and the `SetGo_*` modules you want into the
game's `Interface\AddOns` folder. `SetGo` is required; the
modules are optional.

## Development

`tests/` holds the tests (`tests/run.sh`); it is not part of the addon and
never goes into the AddOns folder or a release.

## Languages

English and Portuguese.

## License

MIT. The bundled libraries keep their own licenses.
