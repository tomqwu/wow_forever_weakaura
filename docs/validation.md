# Validation for 0.3.0

## Automated evidence

`python scripts/build.py`, `python scripts/check.py` and `git diff --check` are the required build/package checks. The check script validates Lua syntax, focused behavior regressions, class/module loading, own media, import decoding/hierarchy, synchronized versions and ZIP source/media/hash bytes.

The Lua suites currently cover 239 assertions across companion preferences, actual settings callbacks/localization, discovery, selection, state, motion, formatting/equipment, casting, audio and ordinary effect lifecycle. They include:

- English/Chinese learned ranks, reversed spellbook order, learned bases/overrides, passive and placeholder rejection, learning events and stop cleanup.
- Explicit level-23 Warlock fixture; source Warrior stages, all 27 school controls, duplicate/preparation exclusion, native CDM overflow/counters and cached Druid combat-form switching.
- Idle/enemy/combat/no-target, five-second hold/reacquisition, inspection, editor return, death/loading, native motion reversal and cleanup.
- Anchor repair, scale-independent coordinates, preserved profiles, position-only reset and combat deferral.
- Equipment-qualified off-hand, native formatter restoration, retained flow masks, cast ownership/interruptions and alert priority/TTL/cleanup.

`lua tests/native-schema.lua /path/to/ForeverAuras` loads actual FA validators, fallback selection and condition-curve code. It reproduces the old misplaced fallback setting and verifies the correction, rather than relying on schema success alone. It exercises the actual native resource-curve path with restricted values. Both the installed 1.3.5 source and public checkout are checked; this remains a mocked client environment.

`python scripts/preview.py` regenerates the illustrative HTML. `python scripts/check_preview.py` runs browser regressions for nine classes, the leveling fixture, idle/target/combat/delayed close, reacquisition, artwork stacking and independent preview settings. `--capture` updates gallery images. Set `ECLIPSE_CHROMIUM` only when using a nondefault local Chromium executable. Browser evidence is separate from game-client evidence.

## Required game-client acceptance — pending

No new addon files or SavedVariables were installed/edited during implementation. The user's existing 0.2.0 screenshots establish the reported bugs, not validation of 0.3.0.

1. Update the companion, `/reload`, then update the existing **top-level** imported group through `/fa`. Check no duplicate groups or import errors. An addon-only update cannot repair the old saved fallback nesting.
2. On the actual level-23 Warlock, run `/eclipse spells` out of combat and compare the printed learned ranks/native CDM with the spellbook and default manager. Verify new training updates without reimport. No unresolved proc/question-mark or preparation icon should appear in live mode.
3. Check idle → hostile living target → target loss → five-second close, friendly/dead/restricted targets, combat without target, reacquisition during animation, death/loading and editor open/close. Check animation-off mode and no idle Lua clock.
4. Check physical anchor, frame/bar clearance and readability at 60%, 100% and 160% scale. **Reset position** should preserve scale/modules; old saved positions should survive upgrades. Drag/settings changes in combat must defer root changes without blocked actions.
5. Exercise each actual learned cooldown, charges, GCD, usability/range/proc/queue feedback and extra native CDM entries. Compare primary/secondary grouping with the manager. Test all Warrior stages/Cleave/stance/shield/off-hand cases.
6. Apply/remove/expire actual player/target auras, including another caster's effects. Check qualified Shadow Trance/Backlash, Warlock armor uncertainty, native upkeep missing/≤15s filters, nameplate removal and disabled-module unloading.
7. Test pet absence/death, carried shards, native totems/coatings, Hunter actual melee/ranged swings, Rogue combo points and Druid combat form changes.
8. Test native casting/channels, default standard/gamepad bar restoration, late loading, crafting/edit mode and another cast-bar owner. Interrupted casts must not play successful completion effects.
9. Check native effect stacking, resource masks/curves, real-swing pulses and stop/restoration at every lifecycle edge. Confirm no protected-frame/taint errors. Verify activation sound timing, ready alert priorities, login/editor silence and combat-end cleanup.
10. Verify English/Chinese native fonts, settings tabs, Escape, hover/inspection, per-class controls and all switches. Log out normally and back in to verify saved preferences. Test at least one additional class, then each class adaptation before calling nine-class runtime parity verified.

Record client build, ForeverAuras version and Lua/taint errors. The detailed acceptance checkboxes in [feature-parity-plan.md](feature-parity-plan.md) remain open until these client checks pass.
