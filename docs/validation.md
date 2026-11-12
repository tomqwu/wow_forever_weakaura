# Validation for 0.4.0

Sections below 0.4.0 describe releases made under the Eclipse name and keep the names those releases used.

## 0.4.0 (prerelease) — renamed to ForeverHUD

Automated only; nothing here is game-client evidence.

- Mechanical rename of every runtime, generator, test, workflow and documentation identifier. Afterwards, `git grep -i eclipse` outside the history docs finds only the deliberate legacy checks (`EclipseHUD`, `Eclipse | `) and the migration notes.
- `tests/bundle.lua` now has 21 checks. The new ones: the old addon and old displays each warn once, the warnings name what to delete, and the legacy displays are never modified.
- `python scripts/build.py`, `python scripts/check.py` and `git diff --check` pass in WSL; CI repeats them with the pinned ForeverAuras checkout and the native-schema test.
- Not verified in game: the folder swap, the login warnings, or a fresh ForeverHUD install beside deleted Eclipse auras.
- Preview PNGs were renamed only; their pixels are 0.3.x illustrative captures.

## 0.3.5 (prerelease) — auras bundled in the addon

Automated only; nothing here is game-client evidence.

- `tests/bundle.lua` (18 checks) loads the actual Core, Catalog, Locale and Options code. It covers:
  - all nine bundled strings, each byte-identical to its published class file;
  - install, update, installed-without-tag, current and unsupported-class registration states, registered once per session, with separate install and update tables;
  - the detached-display count, which excludes the standalone root and other classes;
  - `/eclipse install`, which is refused over detached displays, opens with `force` or once clean, and is reachable through the slash command;
  - the Chinese warning, which keeps the English placeholder order.
- `tests/test_pack.py` asserts every class display's update tag matches FA's `wago.io/<slug>/<number>` pattern and the current build, that the combined root has no tag, and that the manifest slug/build match.
- FA source review (`ForeverAuras.lua` `AddCompanionData`/`PostAddCompanion`/`CountWagoUpdates`; `ForeverAurasOptions.lua` pending install/update lists and their buttons): the registered fields (`name`, `author`, `encoded`, `wagoVersion`, `versionNote`) are the ones FA reads. Clicking either calls FA's `Import`. Not yet seen in the client.
- Published: the immutable [v0.3.5 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.5) targets `0094fa25833b34c46a61aab6dc73175793fefe6d`, and [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/43091139641) passed on it. ZIP SHA-256: `8742a94f7f8392ca66433333788ff2ac086f3660ae9fd1dc17f5bbcb1d0d0287`. All 13 downloaded assets match the local build, and the 38 runtime files in the ZIP match the source. Installed on 2026-11-11 at the user's request: all 38 file hashes match the package, with 5 changed. The v0.3.4 backup is verified at `F:\WoW-addon-backups\EclipseHUD\20261111-152210\before\EclipseHUD`. SavedVariables were not changed. Installing files is not live-client evidence.
- Pending live checks: after installing 0.3.5 and `/reload`, `/fa` lists the class under ready to install or updates; the window imports or updates cleanly; after a `/reload` it is no longer listed; the detached warning appears only when parentless displays exist.

# Validation for 0.3.4

## 0.3.4 (prerelease) — aura structure and import safety

Automated only; nothing here is game-client evidence.

- `tests/test_pack.py` asserts each class root lists exactly the eight sections plus Cast, sections at `(0,0)` hold children, no empty groups remain, depth is at most three below the class root, and Warrior proc cues keep their former screen offset inside Primary. Class-file scopes are compared against the class root's reachable subtree, not the generator's own load predicate. Parent/child links are checked both ways, exactly once.
- `scripts/codec.lua verify` now fails on an unlisted child, a child listed twice or a second root, and compiles custom text, custom sort and custom trigger logic. The combined import is round-tripped against its source table, like the class files.
- FA's updater treats child `xOffset`/`yOffset` as Group Arrangement (default on), so an Update applies the moved proc offsets (`OptionsFrames/Update.lua` category mapping; source review, not a live update).
- Companion import safety: layout, CDM sync and ability binding defer while `IsImporting()` is true; root show/hide hooks are installed once and ignore import-time show/hide. A live interrupted Warlock update (21 parentless roots, stopped in phase 2 before `Primary | Native 4 | Entry`) is recorded in the plan's work log. Its triggering error has not been captured; the review found no companion path that raises into, or calls `Add` within, the import coroutine.
- Pending live checks: a fresh class import and an Update from 0.3.3 both finish with every display inside its section; dragging moves the whole HUD; FX stays behind the seal.

## Published v0.3.4

[PR #5](https://github.com/tomqwu/wow_forever_weakaura/pull/5) (structure, import safety, tooling) and [PR #7](https://github.com/tomqwu/wow_forever_weakaura/pull/7) (changelog date) merged; [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/43076439748) passed on the release commit `9508b4db6ed2e5f109df62ef1f47cd4fbecf11c6`. The immutable [v0.3.4 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.4) targets that commit. ZIP SHA-256: `b82d838fbdf36febd28c5bcbcfbef03f20c610446ebca9de15f2f8e7a4dabf65`. All 13 downloaded assets match the local build, and the 38 runtime files in the ZIP match the source.

Installed on 2026-11-11 at the user's request into `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD`. All 38 file hashes match the package, with 6 changed. The v0.3.3 backup is verified at `F:\WoW-addon-backups\EclipseHUD\20261111-132331\before\EclipseHUD`, and the receipt is stored beside it. SavedVariables were not changed. The running client still needs `/reload` and a fresh Warlock import, because the earlier interrupted update left parentless displays. Installing files is not live-client evidence.

## Automated evidence

`python scripts/build.py`, `python scripts/check.py` and `git diff --check` are the required build/package checks. Twelve Python test groups and the check script validate Lua syntax, focused behavior regressions, class/module loading, own media, import decoding/hierarchy, synchronized versions and ZIP source/media/hash bytes.

The Lua suites currently cover 330 assertions across companion preferences, actual settings callbacks/localization, discovery, selection, state, motion, formatting/equipment, casting, audio and ordinary effect lifecycle. They include:

- English/Chinese learned ranks, reversed spellbook order, learned bases/overrides, passive and placeholder rejection, learning events and stop cleanup.
- Native provider order and saved placement, uncatalogued learned entries, hidden/unlearned/invisible exclusion, full Essential overflow, separate Utility/items, mode switching, no-op writes and module cleanup. Generated bridge callbacks also run against missing/old helpers in two scenarios.
- Explicit level-23 Warlock fixture; source Warrior stages, all 27 school controls, duplicate/preparation exclusion, native CDM overflow/counters and cached Druid combat-form switching.
- Idle/enemy/combat/no-target, five-second hold/reacquisition, inspection, editor return, death/loading, native motion reversal and cleanup.
- Anchor repair, scale-independent coordinates, preserved profiles, position-only reset and combat deferral. Per-class roots preserve combined parents or use a standalone companion anchor; native import-phase binding waits/coalesces/cancels correctly. Existing v0.3.2 guards retain compatibility.
- Equipment-qualified off-hand, native formatter restoration, retained flow masks, localized resource identities, cast ownership/stop/success ordering and alert priority/TTL/cleanup.
- Independently disabled cast/resource effects, missing hosts, bounded retries, reused decoration frames and combat-deferred reparenting; native resource-trim dependency unloading.

`lua tests/native-schema.lua /path/to/ForeverAuras [CLASS_EXPORT.lua]` loads actual FA validators, fallback selection and condition-curve code. It reproduces the old misplaced fallback setting and verifies the correction, rather than relying on schema success alone. It exercises the actual native resource-curve path with restricted values and compiles/evaluates the real FA color conditions through mana → energy → rage → mana. Unknown/restricted identities restore the neutral base; resource amounts stay restricted throughout. Both the installed 1.3.7 source and public checkout are checked; this remains a mocked client environment.

`python scripts/preview.py` regenerates the illustrative HTML. `python scripts/check_preview.py` runs browser regressions for nine classes, the leveling fixture, idle/target/combat/delayed close, reacquisition, artwork stacking, semantic bar colors, Druid caster/cat/bear transitions and independent preview settings. `--capture` updates gallery images. Set `ECLIPSE_CHROMIUM` only when using a nondefault local Chromium executable. The native dynamic-group sort wrapper also executes our identity-only comparison with restricted state objects; the helper never reads those states. Browser evidence is separate from game-client evidence.

## Published v0.3.3 and installation

[PR #4](https://github.com/tomqwu/wow_forever_weakaura/pull/4), branch/PR CI and [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/42925051342) passed. The immutable [v0.3.3 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.3) targets `9fc7c6036e90429c01d5d31987ac4d89eed15c8a`. Downloaded ZIP SHA-256 is `9a09d84d355759dfebc95c83ba07861d7c76bf1d9f308e50d0fd4ccd51d5a306`; ZIP, combined/class assets and all runtime files match the checked local bytes. All 38 addon files are installed and verified at `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD` (9 changed). Prior v0.3.2 backup: `F:\WoW-addon-backups\EclipseHUD\20261110-183934\before\EclipseHUD`. SavedVariables and other addons were not changed. The running client still needs `/reload` and a class/combined import update.

A post-release documentation correction supersedes the ZIP README’s native Visibility → Hidden recommendation: native `CooldownViewerMixin:OnHide` / `CooldownViewerCooldownMixin:OnHide` unregister update events. Keep all native viewers Always. Use native displays with duplicate Eclipse modules off, or enable Eclipse tracked bars and FA global opacity hide. The release assets remain immutable; the current online README records this correction. No live-client acceptance follows from installing files.

## Required game-client acceptance — pending

No game files were modified during implementation. On 2026-11-10, at the user's request, the published v0.3.1 companion was installed into the running client's `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD`. All 38 addon files match the release; the previous v0.2.0 folder was backed up and verified outside AddOns. SavedVariables remain untouched. Subsequently the v0.3.2 companion was installed with all 38 file hashes verified (8 changed); the prior v0.3.1 folder is backed up at `F:\WoW-addon-backups\EclipseHUD\20261110-095502\before\EclipseHUD`. Load or `/reload` the companion, then update the matching class import (or the combined top-level group) before testing the changes below. New 0.3.1 screenshots establish the native manager grouping mismatch, armor placement and caption complaints. General.log captured old-helper import errors and a later independent AckisRecipeList health-prediction taint flood. These are failure evidence, not validation of 0.3.2.

1. Update the companion and `/reload`. In a fresh profile, import one class file through `/fa` and verify its anchor, scale, caption, modules and settings. Import a second class file and confirm the first is untouched. In an existing combined setup, update only its class subgroup using the matching class file, confirm the parent/other classes/preferences survive, and verify no duplicate IDs. Existing v0.3.2 class imports should remain usable with the new companion. The optional full file still updates the combined **top-level** group. Reload before importing so the correct companion is in memory; an old helper should emit one instruction and cause no missing-helper flood. Check no duplicate groups or import errors. An addon-only update cannot repair the old saved fallback nesting.
2. On the actual level-23 Warlock, run `/eclipse spells` out of combat and compare the printed learned ranks/native CDM with the spellbook and default manager. Verify new training updates without reimport. No unresolved proc/question-mark or preparation icon should appear in live mode.
3. Check idle → hostile living target → target loss → five-second close, friendly/dead/restricted targets, combat without target, reacquisition during animation, death/loading and editor open/close. Combat entry must start motion immediately; combat exit must begin folding in that event when no hostile target/inspection keeps it open. Only target loss keeps the five-second hold. Verify first center-click expands and second folds immediately with the same target, then new target/combat clears the fold latch. Verify visible intermediate motion survives layout refresh/late binding rather than snapping. Check animation-off mode and no idle Lua clock.
4. Check physical anchor, frame/bar clearance, role labels and text contrast at 60%, 100% and 160% scale. Verify crimson health, blue mana, gold energy and orange rage, including Druid form changes and native combo current/maximum values. **Reset position** should preserve scale/modules; old saved positions should survive upgrades. Drag/settings changes in combat must defer root changes without blocked actions.
5. Exercise each actual learned cooldown, charges, GCD, usability/range/proc/queue feedback and extra native CDM entries. Compare learned native identities/order and category placement. Trigger a real cooldown and a GCD-only action separately: only the former should occupy the default cooldown row. Confirm native wing compaction, overflow beyond eight, separate Utility/items, hidden placement and changes after combat. Check the optional Class plan mode and absence of duplicates. Test all Warrior stages/Cleave/stance/shield/off-hand cases.
6. Apply/remove/expire actual player/target auras, including another caster's effects. Check qualified Shadow Trance/Backlash, Warlock armor in the side maintenance area with no above-emblem duration, maintenance-module unloading, native buff deduplication, armor uncertainty, native upkeep missing/≤15s filters, nameplate removal and disabled-module unloading.
7. Test pet absence/death, carried shards, native totems/coatings, Hunter actual melee/ranged swings, Rogue combo points and Druid combat form changes.
8. Test Default/Eclipse/Both choices, legacy migration, module checkbox synchronization and the loaded-aura fallback. Test native casting/channels, default standard/gamepad bar restoration, late loading, crafting/edit mode and another cast-bar owner. Interrupted casts must not play successful completion effects; stopping a cast/channel must stop the loop even when no success arrives.
9. Keep the game’s tracked bars with FA global hide off and native viewers Always (native Hidden unregisters updates); disable duplicate Eclipse modules if using the native icon rows. Then test the optional Eclipse native tracked-bar stack with global FA hide. Apply/remove Corruption/Immolate/Bane, control effects and tracked procs; confirm native remaining duration/stack rendering and no duplicate icon overflow when bars are enabled. Check native effect stacking, resource masks/curves, real-swing pulses and stop/restoration at every lifecycle edge. Disable Resources with Cast enabled, then Cast with Resources enabled; each remaining effect must keep working and disabled native trackers must unload. Confirm no protected-frame/taint errors. Verify activation sound timing, ready alert priorities, login/editor silence and combat-end cleanup.
10. Verify English/Chinese native fonts, settings tabs, Escape, hover/inspection, per-class controls and all switches. Log out normally and back in to verify saved preferences. Test at least one additional class, then each class adaptation before calling nine-class runtime parity verified.

Record client build, ForeverAuras version and Lua/taint errors. The detailed acceptance checkboxes in [feature-parity-plan.md](feature-parity-plan.md) remain open until these client checks pass.
