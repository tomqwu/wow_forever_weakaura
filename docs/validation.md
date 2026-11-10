# Validation

## Automated

`python scripts/check.py` runs Lua syntax checks, 45 companion behavior assertions (including its actual settings source), structural/compatibility and painted-media checks, import decoding and hierarchy validation, and ZIP content/hash verification. The optional `tests/native-schema.lua` runs ForeverAuras' actual native validators against all 91 modern displays in a mocked frame environment.

The local browser preview is exercised for all nine class choices, independent per-class module preferences, scaling and reset. This tests the visual review tool, not the in-game controls.

## Required in-game checks

These have not been performed for v0.2.0:

- Import on the installed ForeverAuras build without errors. Verify the companion addon is loaded and its media appear.
- Check painted-frame bar alignment, seal clearance and spell-border alpha at 60%, 100% and 160% scale. Confirm the center of each spell border is transparent and no opaque backing covers the world or spell icon.
- Login on Warlock and at least one other class. Only the current class should appear. No unknown/unlearned cooldown icon should appear. Learn/change a talent and check its native learned-spell load behavior.
- On Warlock, test Shadowburn, Conflagrate, Bane/Wrack effects, player ownership with a second Warlock, Shadow Trance/Backlash, demon dismissal/death, carried Soul Shard changes and channel casting.
- Test target changes, no target, another player's same-name DoT, and readable/restricted states. Confirm native armor behaves without any fabricated missing warning.
- Enable nameplate effects. Test adding/removing nameplates and leaving range; old plates must not retain icons. Disable the module and inspect native tracker unloading.
- Check Shaman totem slots, Rogue combo points, Druid form changes, Hunter ranged swing and Warrior off-hand absence.
- Drag/scale/reset outside combat. Try changes during combat and confirm they wait until combat ends. Confirm no blocked-action or taint errors. Test `/reload` during combat.
- Verify helper and native settings on English and Simplified Chinese clients. Check fonts, tooltips, close/Escape, hovering and pinning utility, and all switches.
- Log out normally, log back in, and confirm position, scale and module preferences persist independently by class. Saved data is `EclipseHUDDB`; the imported auras remain in ForeverAuras' own SavedVariables.
- Disable the whole HUD and individual modules; no orphaned decoration, invisible click target or active animation should remain. Check world leave, death and return.

Record client build, ForeverAuras version and any Lua/taint error when reporting a failure. Do not label v0.2.0 production-verified until this checklist has been completed.
