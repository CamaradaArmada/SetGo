# Tests

Not part of the addon: `.pkgmeta` leaves this folder out of the packages,
and it must never go into the AddOns folder or a release zip.

Run from the repository: `tests/run.sh`

1. Builds Lua 5.1 (the game's version) from `lua-5.1/` the first time
   (needs gcc and make).
2. Checks the syntax of every `.lua` file of the addons.
3. Runs `core_test.lua`: the core loaded against a mock of the game's API
   (`mock_pre.lua`, `mock.lua`). It covers the profiles (migration, Global
   or Profile for settings, keybinds and action bars, copying, applying,
   export and import), the window (tabs, the form, closing with unsaved
   changes, combat) and the minimap button. It ends with `ALL PASSED`.

The mock is only as good as what it imitates: passing here is not testing
in the game. Modules are only syntax checked.

When a change in the core changes what the test expects, update the test
in the same commit.
