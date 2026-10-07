#!/bin/bash
# SetGo! tests: a syntax check of every Lua file of the addons, then the
# core test (tests/core_test.lua) against a mock of the game's API.
# Usage: tests/run.sh   (from anywhere; builds Lua 5.1 the first time)
set -e
TESTS="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$TESTS")"
LUA="$TESTS/lua-5.1/lua"
if [ ! -x "$LUA" ]; then
	echo "Building Lua 5.1 (the game's version)..."
	(cd "$TESTS/lua-5.1" && make -s lua >/dev/null 2>&1) || { echo "Lua build failed (needs gcc and make)"; exit 1; }
fi
echo "== Syntax"
fail=0
for f in $(find "$ROOT" -path "$TESTS" -prune -o -name "*.lua" -path "*SetGo*" -print); do
	if ! "$LUA" -e "local f, e = loadfile('$f') if not f then print(e) os.exit(1) end"; then
		fail=1
	fi
done
[ $fail -eq 0 ] && echo "all files ok" || { echo "SYNTAX ERRORS"; exit 1; }
echo "== Core test"
cd "$TESTS"
"$LUA" core_test.lua "$TESTS" "$ROOT" | grep -v "^ok " | grep -v "|cff69ccf0SetGo!|r" || true
"$LUA" core_test.lua "$TESTS" "$ROOT" | tail -1 | grep -q "ALL PASSED" || { echo "CORE TEST FAILED"; exit 1; }
