# Validation for 0.14.27

Sections below 0.4.0 describe releases made under the Eclipse name and keep the names those releases used.

## 0.14.27 (prerelease) — Hellfire range for Warlocks

- **Request:** "10 yard range?" The user chose a Warlock-only Hellfire marker.
- **Change:** the Warlock Target distance display gets one more native `range` condition, `<= 10` yd, which turns it purple. It comes after the 20 yd orange condition and before the 5 yd red one, so melee stays red. The custom text passes 10 to `E.RangeText`. At or within that distance, the text leads with the client's own name for Hellfire (`GetSpellInfo(1949)`, with a locale fallback).
- **Tests:** `tests/test_pack.py` (Warlock condition order and custom text; other classes unchanged), `tests/state.lua` (text format with and without the Hellfire band).
- **Not yet checked in game.** Whether LibRangeCheck reports a 10 yd step depends on the client.

## 0.14.26 (prerelease) — target distance on the seal

- **Request:** "can we add a distance track on the addon, somewhere you think fit? e.g. hunter and warlock range for hellfire (safest)".
- **Data:** ForeverAuras' native **Range Check** trigger (`Prototypes.lua`), which uses its bundled LibRangeCheck-3.0. It gives `minRange`/`maxRange` estimates for the target. The library treats secret results as unknown and allows hostile units in combat.
- **Display:** a text display per ranged class (Hunter, Warlock, Mage, Priest, Druid, Shaman) on the lower part of the seal (seal y - 31). `E.PlaceHandle` keeps it on whichever seal shows: folded, Bars or the raised Globes seal. The text is "min-max yd", or "N+ yd" past the last known range. It is a new module, `range`, on by default and listed under Display for those classes.
- **Colour:** each colour is one native `range` condition, in this order:
  - green by default;
  - orange at 20 yd or less;
  - red at the class danger distance (5 yd; 8 yd for the Hunter dead zone) or less;
  - grey at the class spell reach (30 yd; Hunter 35 yd) or more.
- **Tests:**
  - `tests/test_pack.py`: trigger, gate, offset and conditions for each class; melee classes have no display.
  - `tests/state.lua`: the text follows the folded and raised seals; text format.
  - `tests/bridge.lua`: the text callback is safe without the companion.
- **Not yet checked in game.** Range estimates and their steps depend on the client and on known spells.

## 0.14.25 (prerelease) — no stray overflow icons while folded

- **Game evidence:** a user screenshot (Warlock, Stay folded, in combat, 0.14.24). A lone 1:27 cooldown icon sat far below and left of the folded seal. Its place matches the Native cooldowns overflow row's expanded spot (x=-138, y=-110).
- **Cause:** the overflow rows use the `primary` and `utility` gates. The mini layout passes `primary`, and `utility` has no expanded check, so a cooldown in those rows drew at its expanded-HUD position while the HUD was folded.
- **Change:** the entries of the three overflow rows (Native cooldowns, Native utility, Native items) add `ForeverHUD.LayoutVisible()` to their gate. They show only while the HUD is expanded or previewed.
- **Also in the screenshot, unchanged:**
  - The three timed icons above-left of the seal are the DoT row on the target.
  - The small 1:43 icon is the mini damage wing.
- **Tests:** `tests/test_pack.py` checks the gate on all three rows.
- **Not yet checked in game.**

## 0.14.24 (prerelease) — Ctrl-drag to move

- **Request:** "can we make ctrl+click is movable?"
- **Change:**
  - With Ctrl held, the seal's `OnDragStart` moves the HUD even while the position is locked. It still refuses in combat.
  - A Ctrl-click without a drag does nothing.
  - Both seal tooltips add "Ctrl-drag to move."
- **Tests:** `tests/state.lua` checks the cases below.
  - A locked plain drag does nothing.
  - A Ctrl-click changes nothing.
  - A locked Ctrl-drag moves the HUD and saves the position.
- **ForeverAuras 1.4.6:** the user's ForeverAuras updated to 1.4.6 on 2026-11-21. It wraps handlers with `Private.ProfiledEvent`, so `tests/native-schema.lua` now stubs it like `Profiled`. The combined import and every class import pass against 1.4.6.
- **Not yet checked in game.**

## 0.14.23 (prerelease) — folded by default; Shift-click to switch

- **Request:** "make an option can be easier stay folded or expanded?" and "make fold by default, and give hint to user it can be expanded".
- **Change:**
  - Stay folded defaults to on. `fill` switches existing profiles once (`foldDefault`); after that the saved choice is kept.
  - Shift-click on the seal (either button) and `/fhud fold` call `E.ToggleStayFolded`. It sets the option (queued in combat), refreshes the settings window and shows an on-screen line.
  - The first start each session with Stay folded on prints a chat line saying how to let the HUD expand. The click hint and the seal tooltip say Shift-click lets it expand.
- **Tests:**
  - `tests/state.lua` checks the default, the one-time switch and kept choice, the single intro line, and Shift-click both ways.
  - `tests/core.lua` checks `/fhud fold` both ways.
  - Older tests now set Stay folded off explicitly.
- **Not yet checked in game.**

## 0.14.22 (prerelease) — folded combat view: damage wing only, full-size suggestion

- **Game evidence:** two user screenshots (Warlock, Stay folded, in combat, 0.14.21). Death Coil sat alone right of the folded seal ("same problem again, Death coil why it's there?"), and the suggestion above the seal was 22 px ("recommendation is too small").
- **Cause:** the right wing shows the Cooldown Manager's Utility list in combat. With Howl of Terror and Shadow Ward skipped, Death Coil was the only Utility entry left. The mini layout drew it beside the seal. The mini suggestion row was scaled to 70%.
- **Decision:** the user chose "Hide right wing when folded".
- **Change:**
  - Native slots 5-8 use `Gate("rightWing")`, which fails while `E.Mini()` is true.
  - Class-plan spells add `ForeverHUD.WingShown(id)`, which hides an icon placed on the right (`Selection.RightWing`) in the mini layout.
  - The mini suggestion row is full size (scale 1). Its first icon is centred over the seal, 4 px above the seal art (centre y=86).
  - The expanded HUD is unchanged.
- **Tests:**
  - `tests/state.lua`: the right wing is hidden in the mini layout and shows once the HUD is open.
  - `tests/selection.lua`: suggestion position and `RightWing`.
  - `tests/test_pack.py`: the gates on slots 5-8 and on class-plan spells, and the mini constants.
- **Not yet checked in game.**

## 0.14.21 (prerelease) — Stay folded ignores clicks, with a hint

- **Request:** "click shouldn't expand it, and you should hint the option is turned off".
- **Change:**
  - With Stay folded on and the HUD folded, `State.ToggleInspect` refuses. Every toggle uses it: the seal, the minimap and the broker.
  - Instead it calls `E.StayFoldedHint`, which puts a localized line in `UIErrorsFrame`. The seal tooltip shows the same hint.
  - An HUD that is already open still folds on a click.
- **Tests:** `tests/state.lua` checks the cases below.
  - A click does not expand and shows the hint.
  - `ToggleInspect` refuses with the hint.
  - `/fhud inspect` still opens the HUD, and a click folds it with no hint.
- **Not yet checked in game.**

## 0.14.20 (prerelease) — seal click and Stay folded hover fixes

- **Game evidence:** the user reported that with Stay folded the seal still opened on hover, and that a single click did not fold the HUD (settings screenshot, Globes style, 0.14.19).
- **Cause found in the code:** `E.ApplyLayout` placed the click button at y=13. That is the folded seal; the Globes open seal has been at y=76 since 0.14.17.
- **Change:**
  - `E.PlaceHandle` puts the button at `E.HandleY()`: 13 while folded or peeking, otherwise the seal height that Selection set (`S.sealY`). It runs on every notify.
  - `E.SetPeek` refuses to open with Stay folded on.
- **Tests:** `tests/state.lua` checks the button height folded, peeking, opened and folded by one click, and that Stay folded has no peek while clicks still open and fold.
- **Not yet checked in game.**

## 0.14.19 (prerelease) — mini combat layout for Stay folded

- **Request:** "when foldable combat, make mini CDM and recommendation engine minimize around it".
- **Change:**
  - `E.Mini()` is true with Stay folded on, the HUD folded, combat, and the mini layout in place. The `primary` and `suggest` gates then pass and `cue` fails.
  - `Selection.ApplyLayout` scales the wings to 0.6 (first centres ±71, y=13) and the suggestion row to 0.7 (lead edge x=11, y=81), out of combat only.
  - Motion leaves the wings out of the fold animation while the mini layout is in place.
  - A folded combat edge re-runs the gates.
- **Tests:**
  - `tests/selection.lua`: positions, scales, the in-combat freeze, and the restore when the option is off or the HUD is open.
  - `tests/state.lua`: the gates in and out of combat, and the notify on the combat edge.
  - `test_pack.py`: every threshold cue uses `Gate("cue")`, and the Lua constants match the generator.
- **Illustrative only:** `docs/images/mock-0.14.19-stay-folded.png` is drawn at the generated coordinates; it is not a game capture.
- **Not yet checked in game:** in particular whether the client accepts `SetScale` on the wing groups and the suggestion row. It is applied only out of combat.

## 0.14.18 (prerelease) — Stay folded option

- **Request:** "option to not expand in combat, just retracted model".
- **Change:** profile key `stayFolded` (default off; per class). `State.Update` ignores combat and the hostile target while it is on. Inspection, the hover peek and the settings preview still open the HUD.
- **Tests:** `tests/state.lua` checks that combat plus a hostile target keep the HUD folded with the tray gate on and the primary gate off, that a seal click still opens it and folds back, and that turning the option off restores automatic expansion.
- **Not yet checked in game.**

## 0.14.17 (prerelease) — globes 20% closer

- **Request:** the user's screenshot of the 0.14.15+ globes: "make it a bit shorter? Maybe 20%". They chose to move the seal above the rail.
- **Change:** globes at x=±240 (360 px between the rings, was 450); rail 382x95; shade 470x230; pet globe (-297, -57); companion spots: Soul Shards (240, -93), upkeep row (240, 99). In the Globes style the companion moves the seal to (0, 76) and the wings 48 px inward (first spell centres ±24).
- **Tests:** `test_globe_frame_style` checks the numbers, that four spells per side stay out of the liquid and that the seal clears them; `tests/selection.lua` checks the seal and wing moves and that Bars restores them.
- **Illustrative only:** `docs/images/mock-0.14.17-globes.png` (Warlock) is drawn from the exported textures at the generated coordinates; it is not a game capture.
- **Not yet checked in game.**

## 0.14.16 (prerelease) — pet health only with a pet

- **Game evidence:** the user's screenshot showed the folded HUD with the 0.14.12 short pet bar visible and reading "inf" with no pet out; the saved ForeverAuras data (read only) still held 0.14.12 (build 1412) auras.
- **Change:** a native Conditions trigger with Has Pet on both pet displays, before the gate.
- **Tests:** `test_globe_frame_style` checks the trigger order (pet Health, Has Pet, gate) and the "all" combination on both pet displays for Warlock and Hunter.
- **Not yet checked in game:** the displays hiding without a pet, and why the 0.14.12 bar showed while the HUD was folded (its module gate hides the pet module while folded).

## 0.14.15 (prerelease) — globes closer together

- **Change:** globes 120/110 px at x=+-285; class frames 166 px; rail 472x118; shade 560x230; pet globe (-342, -57); companion spots: Soul Shards (285, -93), upkeep row (285, 99).
- **Tests:** `test_globe_frame_style` checks the new sizes and positions and that a fourth spell per side reaches no more than 3 px into the liquid; `tests/selection.lua` checks the companion spots.
- **Illustrative only:** the 0.14.15 mock (since replaced by the 0.14.17 one) was drawn from the exported textures at the generated coordinates; it is not a game capture.
- **Not yet checked in game.**

## 0.14.14 (prerelease) — class globe frames

- **Art:** nine ornaments generated and keyed; each keyed master has a transparent centre (measured opening radius 246–340 of 1024 px). `scripts/media.py` cuts each as a square centred on its opening.
- **Tests:** `test_globe_frame_style` checks both ornaments for every class (texture file present, position, 180 px, art strata, `globeArt` flag, mirrored on the resource side, drawn after the rail and before the seal); the texture count is 39; `tests/selection.lua` checks the new upkeep and Soul Shards spots.
- **Illustrative only:** `docs/images/mock-0.14.14-globes.png` (Warlock) is drawn from the exported textures at the generated coordinates; it is not a game capture.
- **Not yet checked in game:** the frames in any class, their overlap with the fourth spell slot on each side, the upkeep row and the Soul Shards line.

## 0.14.13 (prerelease) — pet globe

- **Game evidence (0.14.12):** the user's screenshot showed the shorter bar working (both groups updated) and the 112x7 pet bar under the Health globe, which the user could not see.
- **Change:** `Pet health | Globe` is now a progress texture (pet Health trigger, vertical fill, crop 0.41, shine and ring sub-textures, `%percenthealth%%` text) at (-365, -60), 55 px with a 60 px ring.
- **Tests:** `test_globe_frame_style` checks the pet globe's type, trigger, position, size, crop, text and art for Warlock and Hunter.
- **Illustrative only:** `docs/images/mock-0.14.13-globes.png` is drawn from the exported textures at the generated coordinates; it is not a game capture.
- **Not yet checked in game:** the pet globe's fill, text and placement.

## 0.14.12 (prerelease) — Howl of Terror left out

- **Game evidence:** the user's in-combat 0.14.10 screenshot showed Howl of Terror alone in the right wing on the rail. The earlier `/fhud dump` listed it first in Cooldown Manager Utility; `SpellNameData.lua` gives its ranks as 5484 and 17928.
- **Change:** both ranks added to `S.SKIP_UTILITY` (Selection.lua), which already leaves Shadow Ward out of the Utility wing and row.
- **Tests:** `tests/selection.lua` puts both Howl of Terror ranks first in Utility and checks that neither takes a wing slot or appears in the Utility row.
- **Not yet checked in game.**

## 0.14.11 (prerelease) — shorter Globes bar

- **Game evidence (0.14.10):** the user's screenshot, after reinstalling the Warlock group under its own name, showed round liquid, both values, the pet bar and Soul Shards under the globes, and an empty rail between globes at +-400, which the user called too long.
- **Change:** globes 130/120 px at x=+-305; rail 512x128; shade 600x230; Soul Shards (305, -77); in the Globes style the upkeep group moves to (305, 89), out of combat only.
- **Tests:** `test_globe_frame_style` checks the new sizes and positions, that four spells per side end inside the liquid edge, and that the companion's upkeep spots match the generator; `tests/selection.lua` checks the upkeep row moving with the style and staying put in combat while the spell wings still move.
- **Illustrative only:** `docs/images/mock-0.14.11-globes.png` is drawn from the exported textures at the generated coordinates; it is not a game capture.
- **Not yet checked in game:** the shorter bar, the upkeep row above the resource globe, and the skill bar in combat.

## 0.14.10 (prerelease) — action-RPG Globes layout

- **Game evidence (0.14.9):** the user's screenshot showed the new slim ring and both values on the globes, but the liquid filled a square past the ring with no rim darkening, and the upkeep reminder sat on the mana globe. The installed `globe-liquid.tga` has transparent black corners, so the swirl in the corners meant the texture was shown zoomed in: `BaseRegions/TextureCoords.lua` multiplies coordinates by 1.4142 and divides by the region's crop, which `RegionTypes/ProgressTexture.lua` sets to 1 + crop (default 0.41).
- **Change:** crop 0.41 on both globes; globes at x=+-400, y=0; rail 676x169; shade 720x230 at y=55; in the Globes style `S.ApplyLayout` sets both wings' y offset to -80 (onto the rail) and moves the Soul Shards text to (400, -87); `E.ApplyLayout` runs it so a style change applies at once.
- **Tests:** `test_globe_frame_style` checks the crop, the new positions, that the companion's constants match the generator, and that the upkeep row clears the resource ring; `tests/selection.lua` checks both wings on the rail and the shard text moving in the Globes style and coming back in Bars.
- **Illustrative only:** `docs/images/mock-0.14.10-globes.png` is drawn from the exported textures at the generated coordinates; it is not a game capture.
- **Not yet checked in game:** the round liquid, the skill bar on the rail, the shard text position, and the slide when the HUD unfolds.

## 0.14.9 (prerelease) — slimmer Globes style

- **Game evidence (0.14.6):** the user's screenshot showed the Health globe with only "100%" and the resource globe with only "Mana"; the separate `%p` texts were blank, while the Health bar's combined text showed "97% 1414".
- **Change:** each globe has one combined two-line text with the bar's number format; the slim ring opening (91% of the trimmed ring, measured on the keyed master) sets the 138 px liquid; the rail replaces the band at the same texture path.
- **Tests:** `test_globe_frame_style` checks the liquid size, the ring outset (6 px), the single combined text on each globe, and the shade (size, strata, flag, drawn before the rail); the texture count is 30; the wing lift test checks `S.WING_LIFT` 42.
- **Illustrative only:** `docs/images/mock-0.14.9-globes.png` is drawn from the exported textures at the generated coordinates; it is not a game capture.
- **Not yet checked in game:** whether the combined texts show both values on the globes, the new ring and rail, and the liquid shading.

## 0.14.8 (prerelease) — Demonic Sacrifice reminder

- **Game evidence:** the user's `/fhud dump` lists Demonic Sacrifice 18788 as a learned Demonology spell and as a Cooldown Manager TrackedBuff entry linking 18792, 18789, 18790 and 18791.
- **Tests:** `test_missing_upkeep_breathes` checks both Demonic Sacrifice reminders (four buff IDs, Show On Missing, any caster, learned-spell eligibility on 18788, no "expiring" twin) and the extra "no sacrifice buff" trigger on both Warlock pet reminders, with the gate still last; Hunter's pet reminder is unchanged.
- **Not yet checked in game:** the reminder appearing with no sacrifice buff, and the pet reminder staying quiet after a sacrifice.

## 0.14.7 (prerelease) — class import fix

- **Game evidence:** BugSack after the stalled Warlock update recorded `attempt to perform numeric conversion on a secret number value` in `SetAnimAlpha` (`RegionPrototype.lua:885`), reached from `CancelAnimation` (`Animations.lua:435`) during `Add` in the import's `UpdatePhase2`. Only the Globe danger texture combined an alpha condition on a restricted value with an alpha animation.
- **Fix:** the danger ring has no main animation; the existing resource-intensity texture uses the same condition-only pattern without error.
- **Tests:** `test_globe_frame_style` asserts the danger ring has no alpha animation.
- **Not yet checked in game:** the re-import of the class group and the steady ring.

## 0.14.6 (prerelease) — Globes frame style

- **Evidence:** these ForeverAuras files support the globes:
  - `RegionTypes/ProgressTexture.lua` (VERTICAL orientation, `foregroundColor` condition property) and `ProgressTextureNative.lua` hand restricted values to a native StatusBar;
  - `Prototypes.lua` provides the `percenthealth` and `powertype` conditions the bars already use.
- **Tests:**
  - `test_globe_frame_style` checks the globe displays, their textures, load flags, draw order, resource-colour conditions, danger ring condition, band gate, and the chassis, shelf and pet-bar flags for every class.
  - `tests/core.lua` checks the companion's style flags (Bars, Globes, artwork and pet toggles, reset of an unknown style).
  - `tests/options.lua` checks the Display button and `/fhud style`.
- **Illustrative only:** `docs/images/mock-0.14.6-globes.png` is drawn from the exported textures at the generated coordinates; it is not a game capture.
- **Not yet checked in game:** the globes' fill and colours, text placement, the unfold slide, and the danger ring.

## 0.14.5 (prerelease) — Titan Panel launcher

- **Evidence:** LibDataBroker-1.1 is the data-object API that Titan Panel reads; Titan bundles it behind LibStub. Titan Panel is not installed in the test client, so the launcher is mock-tested only.
- **Test:** `tests/broker.lua` (12 checks) covers:
  - no launcher without LibDataBroker;
  - registration at login as a `launcher` labelled ForeverHUD with the class crest;
  - left-click opens settings and right-click expands or folds the HUD;
  - the tooltip and its Chinese line;
  - reusing an already registered name.
- **Not yet checked in game:** with Titan Panel installed.

## 0.14.4 (prerelease) — Utility wing in combat only

- **Evidence:** the user's `/fhud dump` (Warlock) lists Howl of Terror (5484) first in the Cooldown Manager Utility category, after Shadow Ward, which the wing skips. ForeverAuras `Prototypes.lua` defines the `combat` load option (In Combat, tristate).
- **Test:** `test_utility_wing_combat_only` checks:
  - every class's right-wing slots 5 to 8 and the Core Utility overflow row carry `use_combat = true`;
  - the damage wing slots 1 to 4, the Essential overflow row and the item row do not.
- **Not yet checked in game:** that the wing is empty out of combat and fills when combat starts.

## 0.14.3 (prerelease) — low Soul Shard warning

- **Evidence:** ForeverAuras `Prototypes.lua` Item Count stores `stacks` as a number condition; `RegionTypes/Text.lua` exposes `color` as a condition property; `SubRegionTypes/Glow.lua` toggles `sub.N.glow`.
- **Test:** `test_low_shard_warning` checks:
  - the Warlock HUD shard text turns red through one `stacks < 10` condition on its Item Count trigger;
  - the tray shard icon has one glow, off by default, turned on by the same condition;
  - no other class carries the warning.
- **Not yet checked in game:** the look, and that both clear at 10 shards.

## 0.14.2 (prerelease) — low-health flash

- **Evidence:** ForeverAuras `SubRegionTypes/Glow.lua` supports Pixel glows on aurabars, anchored by `anchor_area`. The curve cues already use `percenthealth` conditions.
- **Test:** `test_low_health_flash` checks:
  - a single glow on the Core Health bar, off by default;
  - its red Pixel style, anchored to the bar;
  - one condition, `percenthealth <= 30` on the player trigger, that turns it on.
- **Not yet checked in game:** the look, and that the glow turns off above 30%.

## 0.14.1 (prerelease) — redesigned settings window

- **Test:** `tests/options.lua` gains 16 checks:
  - every category has a sidebar tab with a native icon, a page and a Chinese label;
  - choosing a category shows only its page;
  - controls sit on the right page;
  - the header shows the crest and the version.

  The existing settings checks pass unchanged.
- **Not yet checked in game:** the look, and that the native icons resolve on this client.

## 0.14.0 (prerelease) — minimap button tray

- **Basis:** the user's own Forever Classmate `MinimapTray.lua`, ported to ForeverHUD names. The Warlock that showed the crowded minimap has ForeverUtilities disabled in its `AddOns.txt` (read only), so no tray was active there.
- **Test:** `tests/minimap.lua` (61 checks, mock frames):
  - which buttons are borrowed;
  - the 34 px grid;
  - opening, closing and dragging;
  - combat deferral;
  - exact return of points, strata, level and drag handlers;
  - Classmate precedence;
  - Chinese labels.
- **Not yet checked in game:** that the tray collects the buttons in the user's screenshot, and how it looks.

## 0.13.24 (prerelease) — Soul Link reminder

- **Evidence:** ForeverAuras `SpellNameData.lua` (client build 70374) lists Soul Link as 19028 and 25228. `Discovery.lua` `D.Resolve` makes an aura entry eligible only when its spell is in the spellbook or known.
- **Change and test:** `upkeep_reminders(SOUL_LINK,'Soul Link',False)` and a tray reminder. `test_missing_upkeep_breathes` checks both triggers, their seeds, and that there is no expiring twin.
- **Not yet checked in game:** that the buff on the Warlock carries one of these IDs.

## 0.13.23 (prerelease) — fuller spell lists

- **Evidence:** the research report's per-spec tables. Shared-name IDs (Arcane Power, Combustion, Thunder Clap, Demoralizing Shout, Blade Flurry, Bestial Wrath, Rapid Fire, Sniper Shot, Insect Swarm, Nature's Swiftness, Wild Growth, Holy Strike, Swift Judgement, Light's Vigil) were checked in ForeverAuras `SpellNameData.lua` (client build 70374). Single-name IDs come from the report's sources.
- **Change and test:** new `ready` and `missing` rules in `SUGGESTIONS`. `test_research_rules_added` checks each trigger, its load and its gate; the existing order tests cover the new lists.
- **Not yet checked in game:** every class except the Warlock lacks a dump. Healer cooldowns test usability while you target an enemy, as Riptide and Holy Shock already did.

## 0.13.22 (prerelease) — Searing Pain for Demonic Brand

- **Evidence:** the first `/fhud dump` (Warlock) lists the Cooldown Manager entry Demonic Brand 1293695 linked to 1293696, and the user's 0.13.15 screenshot shows the debuff on the target.
- **Change and test:** `missing('Searing Pain',1293696,talent=[1293695],cast=5676)` in the three Warlock spec lists. `test_warlock_spell_suggestions` checks the target HARMFUL Show On Missing trigger, the talent seed, the Searing Pain load and icon.
- **Not yet checked in game:** that the target debuff ID is 1293696 at every talent rank, and that the debuff counts as cast by you (not by the pet).

## 0.13.21 (prerelease) — threshold cues clear the Pet bar

- **Evidence:** the user's screenshot shows the Health Funnel cue's frame over the Pet bar's left end and its label.
- **Change and test:** `PET_CUE` (-246, -36) and `MANA_CUE` (246, -36). `test_warlock_spell_suggestions` checks that the cue's frame box (icon plus 8 px) ends at the Pet bar's outer end and below its row, measured from the generated displays.
- **Not yet checked in game:** that nothing else sits in the new spot.

## 0.13.20 (prerelease) — charges in the centre, expiry burst

- **Evidence:** the user's screenshot of a right-side buff icon shows the remaining time (0) in the centre and the count (2) in the corner.
- **Change and tests:** `stacks_centre` swaps the two texts on the buff-row icons; `test_buff_row_stacks_in_centre` checks every such icon has `%s` in the centre and `%p` in the corner, and that a primary icon keeps `%p` in the centre. `EXPIRE_FLASH` gains a custom scale curve (`Animations.lua:307-313`); `test_cdm_buffs_flash_then_fade` evaluates it in Lua: 1.0, 1.3, 1.0, 1.3, 1.0, 2.05, 2.4, and 1.0 when the row is closing.
- **Not yet checked in game:** the burst's look, and where it grows from inside the dynamic row.

## 0.13.19 (prerelease) — fewer rechecks and HUD updates, `/fhud perf`

- **Evidence:** a static read of the companion (no in-game measurement). It has no `OnUpdate` or repeating timer. `Discovery.lua` refreshed on four noisy events with a 0.1 s window; `State.lua` `S.Goal` ran `E.Notify()` on every silent call, so each folded-HUD `UNIT_FLAGS`, `UNIT_FACTION` or `PLAYER_TARGET_CHANGED` re-ran the 751-entry flag pass and `ScanEvents("FOREVERHUD_UPDATE")`.
- **Change and tests:** `tests/discovery.lua` checks that a burst gives one refresh after `D.DELAY`, a stream cannot postpone it past `D.MAX_WAIT`, the three events are not registered, and only requested spell data rescans (32 checks). `tests/state.lua` checks that 21 unchanged events skip the update, while a settings change, a target turning hostile and explicit silent updates still notify (46 checks). `tests/options.lua` checks `/fhud perf` output and that each report resets the counters (43 checks).
- **Not yet checked in game:** the CPU numbers, and that the profiler metrics exist on this client.

## 0.13.18 (prerelease) — reminder icons from the spell

- **Evidence:** the user's screenshots show the Firestone reminder with the black `INV_Ammo_FireTar` art and the game's own Firestone art (a red swirl, with reagent counts) on the action bar.
- **Change:** `class_reminder` adds a Cooldown Progress (Spell) trigger, Show: Always, for the learned spell as trigger 2 and sets Icon Source to it; the gate moves to trigger 3. `test_weapon_enchant_reminders` and `test_pet_missing_reminder` check the trigger, spell and icon source; the native schema test accepts the displays.
- **Not yet checked in game:** that the icons show the spells' art.

## 0.13.17 (prerelease) — Shadow Ward left out of the Utility wing

- **Evidence:** the user's screenshot shows Shadow Ward alone in the always-shown Utility wing; the first `/fhud dump` lists it first in the Utility set (cdmID 199743). `SpellNameData.lua:3204` gives its ranks 6229, 11739, 11740 and 28610.
- **Change and test:** `Selection.lua` `S.SKIP_UTILITY` skips entries with any of those IDs in the Utility wing and the Native utility row; `tests/selection.lua` checks it stays out and the next Utility entry takes slot 5 (112 checks).
- **Not yet checked in game.**

## 0.13.16 (prerelease) — Utility cooldowns always shown

- **Evidence read (installed ForeverAuras 1.3.9, read only):** `WandCooldown.lua:1-93` holds each spell's earlier timer during Shoot's (5019) shared cooldown for its countdown and desaturation only. `SpellCooldown.lua:205-244` keeps the logical `onCooldown` from the client and adds `wandAppearanceDuration` for the look. `CooldownViewerTrigger.lua:989` shows a Show: Cooldown entry when `state.onCooldown == true`. `GenericTrigger.lua:2798-2830` marks a wand-only stretch only to suppress the ready event; `detail.ready` stays false. `CooldownViewerTrigger.lua:2094-2096` leaves an unreadable remaining time shown, so a Remaining Time filter cannot skip the lockout in combat. No native check separates a wand lockout from a real cooldown.
- **Change and test:** `Selection.lua` syncs native slots 5 to 8 and the Native utility row with Show: Always; `tests/selection.lua` checks the Utility wing and row are always shown and the damage wing and item row stay cooldown-only (111 checks).
- **Not yet checked in game:** that no icon pops up on a wand shot and the always-shown icons keep their ready look during it.

## 0.13.15 (prerelease) — Demonic Brand kept in the right-hand row

- **Evidence:** the user's screenshot shows Demonic Brand on the target's frame (2 stacks) with the tooltip "Magic ... the caster's pet deals an additional 35 to 38 damage with its next 2 attacks": a target debuff, which the 0.13.14 rule removed as intended, but one the user watches as a buff. The dump's CDM entry is 1293695 linked 1293696.
- **Change and test:** `S.KEEP_TARGET` keeps entries with either ID; `tests/selection.lua` checks Brand stays and another target debuff (Fear) stays out (109 checks).
- **Not yet checked in game.**

## 0.13.14 (prerelease) — only the player's buffs in the right-hand row

- **Evidence:** the first `/fhud dump` (Warlock) lists Demonic Brand (1293695, linked 1293696), Curses, Fear (linked 1324451, 1324453) and Banish among the Cooldown Manager's Tracked Buffs. `CDMSetup.lua:33-39` (ForeverAuras) moves every tracked category into Tracked Buffs. `CooldownViewerCatalog.lua:784-810` decides a CDM aura's unit from `C_Spell.IsSpellHarmful` over its spell IDs; `Selection.lua` `S.TargetAura` applies the same rule to each entry's spell, override and linked IDs.
- **Tests:** `tests/selection.lua` checks that harmful entries stay out of the row even with the DoT row off, that a player buff stays, and that the answer is cached (108 checks).
- **Not yet checked in game:** that `C_Spell.IsSpellHarmful` answers true for Demonic Brand's linked ID on this client, and that the wand-applied icon is gone from the right.

## 0.13.13 (prerelease) — Well Fed reminder, and the first `/fhud dump`

- **Change:** `test_well_fed_reminder` checks the trigger (name, Show On Missing, no caster filter), the `fedMissing` switch, no discovery entry, the gates and the breath, for every class; `tests/core.lua` the default (off) and turning it on (119 checks).
- **First dump (Warlock, read only from SavedVariables, 2026-11-14):** client 1.60.1 build 70938, interface 16001, level 32 Demonology. `stackGate = true`: the client has `C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions`, so ForeverAuras' native Stack Count gate can be used for stack rules. The Cooldown Manager's Tracked Buffs hold Bane of Agony, Curses, Demonic Brand (1293695), Corruption, Fear, Immolate, Banish, Demon Skin, Demon Armor, Detect Invisibility, Shadow Ward, Subjugate Demon and Shatter Curse: target debuffs as well as player buffs, which the right-hand buff row mirrors apart from the DoTs the left row shows. No item buff is in the list.
- **Not yet checked in game:** the Well Fed reminder showing and clearing.

## 0.13.12 (prerelease) — pet reminder

- **Evidence read (installed ForeverAuras 1.3.9, read only):** `Prototypes.lua:10069-10122` registers pet unit events and watches `pet` when `use_HasPet` is set; `10173-10177` defines Has Pet as `UnitExists('pet') and not UnitIsDead('pet')`, a tristate, so `use_HasPet = false` means "no living pet"; `10167-10171` defines Mounted the same way. `SpellNameData.lua:531` (Call Pet 883) and `3795` (Summon Imp 688).
- **Tests:** `test_pet_missing_reminder` (trigger fields, gates, learned-spell eligibility, breath) and the tray test; `tests/core.lua` checks the defaults and the checkbox (118 checks). The native schema test accepts the trigger.
- **Not yet checked in game:** the reminder on dismissing or losing a pet, staying hidden while mounted, and the icons (Spell_Shadow_SummonImp, Ability_Hunter_BeastCall).

## 0.13.11 (prerelease) — CDM buffs flash as they end

- **Evidence read (installed ForeverAuras 1.3.9, read only):** `RegionPrototype.lua:1543-1544` and `1600-1601` run `Private.Animate(..., "finish", data.animation.finish, ...)` before hiding a display or clone. `Animations.lua:209-300` accepts a custom animation with `use_alpha` and `alphaType = "custom"`, loading `alphaFunc` as `return <function>` and calling it with (progress, start alpha, delta). `BlizzardAuraDisplay.lua:1848-1853` offers only Start and Main for native aura buttons, so the class-plan buff icons cannot take a finish animation.
- **Preset fix:** `Animations.lua:214-215` replaces a preset animation with `Private.anim_presets[preset]`, and `Prototypes.lua:649-655` defines `alphaPulse` as 0.5 s to 50%, so the 0.13.10 breath was a quick flicker. It is now a custom animation with `alphaType = "alphaPulse"`, 2.4 s, to 40%.
- **Tests:** `test_cdm_buffs_flash_then_fade` checks the animation fields, that only that display has a finish animation, and evaluates the curve in Lua (1, 0.2, 1, 0.2, 1, 0.5, 0; 0 at once when the gate is closed). `test_weapon_enchant_reminders` checks the breath fields.
- **Not yet checked in game:** the flash on a real buff ending, and that the dynamic group's re-layout looks right while an icon fades.

## 0.13.10 (prerelease) — weapon enchant reminders and minimap entry

- **Evidence read (installed ForeverAuras 1.3.9, read only):** `Prototypes.lua:7320-7511` defines the Weapon Enchant trigger (type `item`; `weapon` main/off; `enchantKind` any/imbue/temporary; `showOn` showOnActive/showOnMissing/showAlways). `Types.lua:4181-4191` labels the kinds "Imbue (Firestones, Mage Scrolls, Shaman Imbues)" and "Oil, Stone or Poison". `ItemStatus.lua:62-93` reads both kinds per hand from `C_Item.GetWeaponEnchantInfo` and treats secret values as unreadable. The user's tooltip shows Minor Wizard Oil and Firestone on one weapon, matching the two kinds.
- **Learned spells** (`SpellNameData.lua`): Create Firestone 6366 (742), Rockbiter Weapon 8017 (2999), Poisons 2842 (2717).
- **Minimap entry:** BetterLootGlimmer and Baganator, installed for this client, register through `## AddonCompartmentFunc`, and LibDBIcon in ForeverAuras uses `AddonCompartmentFrame`, so the client has the addon list. ForeverHUD did not register before.
- **Tests:** `tests/test_pack.py` `test_weapon_enchant_reminders` (trigger fields, module flags, gates, learned-spell eligibility, names per class) and the tray test; `tests/core.lua` covers class defaults, an existing profile gaining them, turning one off, the settings checkboxes and the three compartment handlers named in the TOC (117 checks).
- **Not yet checked in game:** the reminders showing and hiding as enchants are applied and expire, the icon art (standard `Interface/Icons` paths: INV_Ammo_FireTar, Spell_Nature_RockBiter, Ability_Poisons, INV_Potion_100), and the minimap entry.

## 0.13.9 (prerelease) — client spell IDs and `/fhud dump`

- **Evidence read (installed ForeverAuras 1.3.9, read only):** `SpellNameData.lua:2-11` describes the table (every name with two or more IDs, scanned with `C_Spell.GetSpellName` on client build 70374). Lines 276 (Avenging Wrath), 615 (Clearcasting), 931 (Demonic Brand), 1383 (Fingers of Frost), 1796 (Heating Up), 1862 (Hot Streak = 48108, 401724), 2319 (Maelstrom Weapon), 2483 (Missile Barrage), 2493 (Molten Armor), 2553 (Nature's Swiftness), 2569 (Nightfall = 18094, 23653), 3896 (Surge of Light) and 4310 (Water Shield) were read directly. None of 44445, 44544, 44401, 53817, 33151, 31884, 24398 or 30482 appears under those names.
- **Stack Count:** `SecretAuraSingle.lua:2329-2374` implements a native "at least n" gate but returns "This client can't check Stack Count." without `C_AuraContainerUtil.ProcessCustomAuraButtonApplicationBarOptions`. Whether the live client has it is unknown, so no rule sets it; the generator supports `stacks=` and the dump records the answer.
- **Change:** as listed in the changelog. `tests/test_pack.py` `test_proc_ids_come_from_the_client_name_table` checks the new ID lists and that none of the dead IDs is referenced by any trigger, load condition or eligibility seed, and that no display uses the stack gate.
- **`/fhud dump`:** `tests/core.lua` covers a client with none of the APIs (header and empty sections, no error), aura recording with stacks, a secret value never being stored, no aura read in combat, `watch`, `names` and invalid input. The API names (`C_SpellBook`, `C_Traits`, `C_ClassTalents`, `C_UnitAuras`, `C_CooldownViewer`) follow the retail surface Forever is reported to share and are **not verified on interface 16001**; each call is wrapped so a missing one leaves its section empty.
- **Research basis:** `reports/WoW Forever rotation engine research.md` and its notes. Web guides were read through summaries; only the items above were re-checked here against local files.
- **Not yet checked in game:** that the corrected rules load and show, and what `/fhud dump` records.

## 0.13.8 (prerelease) — lighter install check

- **Report (user, relayed from players, no details):** lag.
- **Read in the code:** `E.Notify` has no frequent caller (login and combat edges, target and fold changes, settings). The only repeating work added recently was the install cue's 3 s timer, which called `E.AuraProblems()`; that calls `E.DetachedDisplays` per bundle, a `pairs` over all of `ForeverAurasSaved.displays` with a `string.sub` per entry. It ran whenever the cue was shown: out of combat, folded, auras missing or older, which is the normal state after every addon update until the auras are updated. ForeverAuras' glow mirroring (`SecretAuraStand.lua` `MirrorGlow`) runs on show, size and visibility changes only, not per event.
- **Change:** the timer calls `RefreshInstallCue("light")` every 10 s; it compares installed and bundled build numbers and runs the full check only when they are no longer behind.
- **`tests/core.lua`:** a timer tick with the builds still behind never iterates the saved displays; the cue still clears when the build catches up.
- **Not established:** that this was the reported lag. Other candidates need in-game profiling (`/fa pstart`, `/fa pstop`, `/fa pprint`): reactive Warrior suggestions entering and leaving the suggestion row as rage changes, and the glows added in 0.13.4.

## 0.13.7 (prerelease) — cast bar size, language choice, lower default

- **Cast bar size:** new per-class `castScale` (default 1, clamped 0.6 to 2). `E.ApplyCastScale()` sets the region scale of `ForeverHUD | Core | Cast` outside combat and outside an import, from `ApplyLayout` and from the cast display's init action (guarded, so an older companion ignores it).
- **Language:** `Locale.lua` decides at call time: `ForeverHUDDB.language` (`zhCN`/`enUS`) if set, else the client locale, with zhTW now counted as Chinese. `E.SetLanguage` backs the panel button and `/fhud zh|en|auto`. Labels built before the change need `/reload`.
- **Default position:** `defaults.y` −160 → −235. `InitDB` version 2 moves only profiles with x 0 and y −160.
- **Faint until combat:** `E.AlphaFactor()` returns 0.2 when the HUD is open outside combat and not inspected, previewed or peeked, else 1 (0.35 for the hover peek, unchanged). It feeds `ApplyLayout` and `rootAlpha`; `Notify` reapplies it outside combat, and `PLAYER_REGEN_DISABLED` sets `E.combatEdge` and applies full opacity before lockdown, as the peek already did.
- **`tests/core.lua`:** cast scale applied and clamped without touching the root scale; zhTW; `/fhud zh` and `/fhud en`; the button cycle; the one-time position migration (moved and untouched profiles); reset position −235.
- **Not yet checked in game.** The game's default cast bar (the default cast mode) is not resized by this.

## 0.13.6 (prerelease) — Warrior reactive strikes as suggestions

- **Game report (user, no screenshot):** nothing prompts when Overpower becomes usable.
- **Read in the code:** the old cue was `Warrior | Usable proc | Overpower`, a 28 px icon at (−74, −23) with no glow, in the Primary group. A Warrior without talents and without Mortal Strike, Bloodthirst or Shield Slam resolved to `Leveling`, which had no Warrior list, so `SuggestSpec` returned nil and no suggestion row loaded (`Selection.lua:20–29, 206–211`). ForeverAuras' Action Usable trigger (`Prototypes.lua:5968–6059`) is `IsUsableSpell and ready and IsSpellInRange(target)`; whether the old icon showed at all in game is not known.
- **Change:** the four checks move into `SUGGESTIONS['WARRIOR']` as `ready` rules, in a new `Leveling` list and in Arms, Fury and Protection; the `Usable proc` displays are removed. They inherit the row's 70% opacity and Action Button Glow.
- **`tests/test_pack.py`:** no `Usable proc` display; each list's leading rule; the four displays' trigger, parent, spec and glow.
- **Folded seal (same release):** `RETRACTED_SEAL` 118 → 106, still larger than the 104 px open seal; `TRAY_ROW1_Y` −67 → −61 (derived); `E.INSTALL_CUE.y` −61 in `Core.lua`, now asserted equal to the row offset by `tests/test_pack.py`. No icon size changed.
- **Game options page (same release):** `Options.lua` `E.RegisterGameOptions()` runs at `PLAYER_LOGIN` and uses `Settings.RegisterCanvasLayoutCategory` and `Settings.RegisterAddOnCategory`, the calls other addons installed on this client use (e.g. Baganator, Syndicator); both are type-checked and wrapped in `pcall`, so a client without them simply has no page. The slider writes `E.Set("scale")`, clamped 0.6 to 1.6 as before (`Core.lua` `limit("scale", 0.6, 1.6)`). `tests/core.lua` covers no API, single registration, showing the current size and resizing.
- **Reactive first (same release):** `active` rules and the new `react()` rules carry `reactive=True`; `SUGGESTIONS` is stably sorted reactive-first after it is declared, and the row is built in list order. New rules: Mage `Clearcasting` 12536 with talent seeds 11213, 12574–12577; Rogue Combat `Riposte` 14251; Hunter `Mongoose Bite` 1495 in all specs; Paladin `Hammer of Wrath` 24275 in all specs. `test_reactive_suggestions_lead_every_list` checks every list and the row order.
- **`/fhud <number>` (same release; user screenshot of the panel opening for `/fhud 60%`):** `E.SetSize` accepts 60 to 160 with an optional `%`, rounds to 5 and calls `E.Set("scale")`; other numbers print the range. Covered in `tests/core.lua`.
- **Not yet checked in game:** that Overpower lights up after a dodge on this client; the smaller seal; the Options → AddOns page; whether the Mage Clearcasting, Riposte and Hammer of Wrath IDs match this client (an unknown one never loads).

## 0.13.5 (prerelease) — install icon in the tray row

- **Game evidence (user screenshot, 0.13.4 addon over 0.13.3 auras, folded):** the gear sat on a second line under the Soul Shard count, with its tooltip listing the Core and class as older. The user asked for every notification on one horizontal line.
- **Change (generator):** `… | Tray | Row | Install` in every class's row: an ordinary icon (like the shard counter, so ForeverAuras chains it into the Modern Aura Group by a stand-in), gear icon, ring, tight frame, the gold Pixel glow, and a gate of `Gate("tray")` and `ForeverHUD.NeedsAuras()`.
- **Change (companion, `Core.lua`):** `E.NeedsAuras()` reports the cached problems. `RefreshInstallCue` now places the button on the row line (y −67). If the installed class group has the row icon and the tray is on, the button is an invisible 230 × 34 strip (tooltip and click only); otherwise it draws the gear, centred when there is no class group or tray, else 84 px right (clear of a three-icon row). It rescans `FOREVERHUD_UPDATE` when the answer flips.
- **`tests/test_pack.py`:** the row icon is last in every class's row, same size, gated on `NeedsAuras`, one glow, no spell eligibility. **`tests/core.lua`:** row-line position, the beside-the-row fallback, the invisible strip when the row icon exists, the centred fallback with the tray off, and the rescan when cleared.
- **Not yet checked in game:** that the stand-in for the row icon appears and hides with `NeedsAuras()`, and the strip's hit area.

## 0.13.4 (prerelease) — every class's missing self-buff, with a glow; suggestions glow

- **ForeverAuras source (installed addon, read only):** `SecretAuraGlow.lua:2–9`: Glow elements on Aura (Modern) displays, including "the Missing icon", are built from textures and animation groups registered with `AddAuraShownAnimation`; `:391–399` Pixel Glow takes `glowLines`, `glowFrequency` (lap = 1/frequency s) and `glowThickness`; `:154` honours `useGlowColor`.
- **Change:** every `… Upkeep reminder | <name> missing` display (tray and HUD) gets one `subglow` (Pixel, 6 lines, frequency 0.2, thickness 2, gold 1/0.82/0.3/0.9) next to the 0.13.1 Pulse. `UPKEEP` now gives Mage armor (adds Molten Armor 30482), Inner Fire, Aspect (missing only; adds 5118, 13159, 20043, 13161, 34074) and Blessing (adds Salvation, Light, Sanctuary and the six Greater Blessings) missing reminders, and adds Shaman Shield (324, 24398). No class keeps a plain `… | Upkeep | …` icon.
- **Suggestion glow (same release; user screenshot of the 0.13.3 row, in game):** every `… | Suggest | …` display gets one `subglow` of type `buttonOverlay` (Action Button Glow). `SecretAuraGlow.lua:371–389` builds it natively on Aura (Modern) icons; ordinary icons in the Modern Aura Group are drawn by stand-ins, which mirror Glow elements (`SecretAuraStand.lua:24`, `MirrorGlow`); the cues are ordinary icons with the ordinary glow. `test_suggestion_row_is_translucent` checks one glow on every suggestion.
- **Not built:** Rogue poisons (weapon enchants are not auras).
- **`tests/test_pack.py`:** reminders and tray icons for all eight buffs, no expiring Aspect reminder, the extra Aspect and Blessing IDs, one glow on every missing reminder and none on expiring ones.
- **Not yet checked in game:** the glow on the tray and HUD icons, and whether Molten Armor (30482) and Water Shield (24398) exist on this client (an unknown ID only never matches).

## 0.13.3 (prerelease) — install icon under the folded seal

- **Change (companion, `Core.lua`):** a plain `Button` on `UIParent`, not in any native aura ancestry. It's shown when `E.AuraProblems()` is non-empty, the profile is enabled, the world is live, out of combat, and the HUD is folded or no root is installed. It sits at the anchor's x and y − 109 (tray row −67, 34 px icon, 8 px gap), scaled with the profile. Dark ring, `Trade_Engineering` icon, `Media/icon-frame` (an existing texture, so no restart), and a looping alpha 1 → 0.4 → 1 over 2.4 s. A click runs `E.InstallBundled()` out of combat. The installed builds are read again on entering the world, after each import (`finishBind`) and every 3 s while shown.
- **`tests/core.lua`:** shown with its reason for an older class group, its position, the click import, hidden in combat and back after, cleared once current, a missing Core, and hidden on world leave.
- **Not yet checked in game.**

## 0.13.2 (prerelease) — smaller folded seal

- **Game evidence (user screenshot, 0.13.1, folded):** the retracted Warlock seal with the Soul Shard count under it; the user asked for the class icon 10% smaller.
- **Change:** `RETRACTED_SEAL` 132 → 118 (even, so it stays centred on whole pixels). `TRAY_ROW1_Y` is now derived, 13 − 59 − 4 − 17 = −67, keeping the 4 px gap. The 68 px companion click handle is unchanged and still inside the seal.
- **CDM expiry fade-out, not built:** `BlizzardAuraDisplay.lua:1810–1816` offers only Start (aura assigned) and Main (aura shown) animations, with no hook for an aura ending.
- **`tests/test_pack.py`:** the seal width, the row offset and the 4 px gap.
- **Not yet checked in game.**

## 0.13.1 (prerelease) — missing upkeep breathes; suggestion row at 70%

- **Game evidence (user screenshot, 0.13.0, folded):** the tray's missing Demon Armor icon sits beside the Soul Shard count, as still as the count.
- **ForeverAuras source (installed addon, read only):**
  - `BlizzardAuraDisplay.lua:1816`: Aura Main types include `pulse`; `:1870` builds it as a looping alpha 1 → 0.4 → 1 over the set duration.
  - `:1825`: a Gained flash suppresses Pulse; `GainedSeconds` (`:1747`) is 0 for Show On Missing, so it plays.
  - `SecretAuraSingle.lua:1010` and `:584`: the Missing look is a sample button styled by `Display.StyleNative`, which adds the Main animation; `SecretAuraPreview.lua:43` plays it at once and again on show.
- **Change:** `blizzardAuraDisplay.auraMain = {type="pulse", duration=2.4}` on every `… Upkeep reminder | <name> missing` display (tray and HUD).
- **`tests/test_pack.py`:** the four missing reminders in the tray and Warlock's HUD reminder breathe; only Show On Missing displays without a Gained flash do; expiring reminders don't.
- **Suggestion row at 70% (user request, same release):** every display in `<Class> | Suggest` gets `alpha=0.7`; the Shadowburn cue starts at 0 and its threshold condition sets 0.7. ForeverAuras applies a display's `alpha` to Aura (Modern) containers (`BlizzardAuraDisplay.lua:2821`, `instance.baseAlpha = … data.alpha`), and stand-ins in a Modern Aura Group forward `SetAlpha` to their copies (`SecretAuraStand.lua:31`). Covered by `test_suggestion_row_is_translucent`.
- **Not yet checked in game.**

## 0.13.0 (prerelease) — absorb overlay on the Health bar

- **ForeverAuras source (installed addon, read only):**
  - `Prototypes.lua:3412`: the Health trigger has `showAbsorb` (hidden when `UnitGetTotalAbsorbs` is nil), `absorbMode` and `absorb = UnitGetTotalAbsorbs(unit)`.
  - `Prototypes.lua:3614`: the overlay accepts secret values.
  - `RegionTypes/AuraBar.lua:512`: the `fromMax` overlay sets a secret width on native status bars.
  - `SecretAuraStand.lua:782`: a fix notes an absorb overlay on a health bar copy "seen in game".
- **Change:** the Core Health trigger gets `use_showAbsorb=true` and `absorbMode=OVERLAY_FROM_END_REVERSE`. The bar gets one overlay colour (0.82, 0.93, 1.0, 0.6) and `overlayclip=true`.
- **`tests/test_pack.py`:** the trigger fields, no heal-absorb, clipping, one translucent overlay colour, and only the player Health bar.
- **`tests/native-schema.lua` against the installed ForeverAuras:** passes.
- **Not yet checked in game:** whether the server counts Ice Barrier, Mana Shield, Power Word: Shield and Shadow Ward toward `UnitGetTotalAbsorbs`, and how the overlay looks on the frame.

## 0.12.1 (prerelease) — shelf lines

- **Game evidence (user screenshot, 0.12.0, out of combat):** three grey rectangles: over each rim row and over the suggestion row. Nothing was in them, and they covered part of the rim art.
- **Change:** the `groove` media and displays are removed, and `shelf` (256×8, gradient line) is added. `Shelf | Left` (mirrored) and `Shelf | Right` sit at (±142, 54), 184×8, tinted with the class colour. They're gated on art, layout visible, `InCombat()` and not retracted; the gate trigger already listens for `PLAYER_REGEN_DISABLED` and `PLAYER_REGEN_ENABLED`.
- **`tests/test_pack.py`:** no groove displays; shelf position, size, mirror, texture, draw order over the chassis, and the combat and folded gate. The texture count stays 24.
- **Not yet checked in game.**

## 0.12.0 (prerelease) — one spine from the seal

- **Game evidence (user screenshot, 0.11.0):** the DoT icon sat centred over Health while the suggestions started at the seal. Both floated over the frame art.
- **ForeverAuras source (installed addon, read only):** `RegionTypes/DynamicGroup.lua` grows `LEFT`/`RIGHT` from x=0 with the children's `selfPoint` (CENTER), so the first icon is centred on the group origin. `SecretAuraFlow.lua` starts LEFT and RIGHT rows at the first display's inner corner.
- **Change:**
  - The DoT and buff rows grow `LEFT`/`RIGHT` from ±66 (inner edge ±52), and the Core native buff row grows `RIGHT` from 66.
  - The wings grow out from ±72, and class-plan slots use `Selection.FromSeal`.
  - Three drawn `groove` textures sit in each class Frame.
- **Tests:**
  - `tests/test_pack.py`: rail positions and growth, the native buff row, groove placement and draw order, the hidden-while-folded gate, and wing growth.
  - `tests/selection.lua`: both sides start at the seal edge, and slots step 47 px outward.
  - `scripts/check.py`: 24 textures.
  - `tests/native-schema.lua` against the installed ForeverAuras: 253 modern displays.
- **Not yet checked in game:** how the grooves sit on the frame art, and the wing alignment with live cooldowns.

## 0.11.0 (prerelease) — clearer suggestion row

- **Game evidence (user screenshot, 0.10.0):** two suggestions sat in fixed slots with gaps, off centre. Health Funnel, a pet cue, was mixed in with the rotation spells.
- **ForeverAuras source (installed addon, read only):**
  - `SecretAuraFlow.lua` supports `LEFT` growth, which starts at the first display's top-right corner.
  - A legacy row starts at its first shown member's own frame.
  - Only shown members join the row.
  - Ordinary icons join a row through stand-ins, in group order.
- **Change:**
  - The Suggest group is a LEFT Modern Aura Group at (-68, 74) with spacing 4, so the lead edge is at -52.
  - Every action sits at the group origin.
  - Threshold cues move to `Suggest cues`: mana at (218, -28), pet at (-218, -28), both 22 px, and execute at (-212, 74).
  - That group exists only for classes with a cue.
- **`tests/test_pack.py`:**
  - The row's flow, growth, spacing and lead edge.
  - Each spec's actions in priority order at the origin, fitting over the Health bar.
  - Only curve cues leave the row.
  - The Life Tap, Health Funnel and Shadowburn positions.
  - Destruction's row never reaches the execute slot.
- **`tests/native-schema.lua` against the installed ForeverAuras:** the native schema validator passed 253 modern displays.
- **Not yet checked in game:**
  - the live order;
  - whether `Action Usable` icons keep their list order in the row;
  - the cue positions against the frame art.

## 0.10.0 (prerelease) — rotation suggestions per spec

- **Request:** suggestions should follow class and spec; review every class.
- **Change:**
  - `SUGGESTIONS` holds one list per spec for all nine classes, with at most five rules each.
  - Each display's catalog entry carries `spec`.
  - `Selection.SuggestSpec` resolves the current school, falling back to `Leveling`.
  - `Selection.Allowed` gates suggestion flags by that spec.
  - New rule kinds are `ready` (Action Usable, combat with a hostile target) and `buff` (own buff missing).
  - Druid Innervate tests mana explicitly (`powertype=0`).
- **`tests/test_pack.py`:**
  - The Warlock per-spec lists and their order, and that the Leveling list keeps the 0.9 IDs.
  - Every list is centred and has at most five rules.
  - The Conflagrate and Shadowburn triggers and gates.
  - Every class has a list for each spec, with spec, seeds and suggest load flags.
  - The Innervate power type, and the own-buff check.
- **`tests/selection.lua`:**
  - The Leveling fallback, and that a spec loads only its own list.
  - A class without a Leveling list shows nothing and keeps its wing down.
  - The Mage Fire list.
- **IDs:** all except Mend Pet (136) come from the existing catalog. A rule loads only once the client reports its spell or talent as learned.
- **Not yet checked in game:** any rule, including whether the target-health curve and Action Usable checks behave in this client.

## 0.9.7 (prerelease) — suggestions stay above the DoTs

- **Game evidence (user screenshot, 0.9.6):** the two suggestions showed well above the DoT icon, with an empty gap. The 0.9.6 lift had fired because the left wing had entries, but none were visible: native Essential cooldowns can show only while on cooldown.
- **Change:** the Suggest group stays at its imported spot (-138, 74). `Selection.LeftLift` gives left-side primary positions a y offset of 34 when the class has suggestions and they're on, so 40 px wing icons centre at y=114. Their bottom is 94, 4 px above the suggestions' top (90).
- **`tests/test_pack.py`:** asserts the lift against the generator geometry.
- **`tests/selection.lua`:** asserts the left wing lift, the unmoved right wing, the untouched suggestion row, and no lift with suggestions off.
- **Not yet checked in game.**

## 0.9.6 (prerelease) — suggestions on the damage side

- **Request (user screenshot, 0.9.5):** the suggestion icon showed above the seal; the user asked for it on the left, lower, right above the damage icons. In that screenshot the left cooldown wing is empty and the DoT row sits on the Health rim.
- **Change:** the Suggest group sits at x=-138, y=74, 4 px above the DoT row, which spans y 26–54. `Selection.PlaceSuggestions` moves it to y=120 when the left wing has entries; the wing's 40 px icons at y=80 span 60–100. It runs out of combat only.
- **`tests/test_pack.py`:** asserts the position against the DoT row and that the companion constants match the generator.
- **`tests/selection.lua`:** asserts the lift with a left wing, the low position without one, no move in combat, and the lift after combat.
- **Not yet checked in game:** the new position and the lift.

## 0.9.5 (prerelease) — tray icons match

- **Game evidence (user screenshot, auras at build 904):** the icons still differed, so the 0.9.3 claim that the ring would match them was wrong. Zooming the screenshot ×4 showed the Soul Shards art with its dark ring.
  - **Frame sizes:** about 56 px (Soul Shards) against about 43 px (Demon Armor). The native button carries our frame without the 8 px outset.
  - **Art sizes:** about 38 against 36 px, much closer.
  - **Spacing:** the two frames overlapped at a spacing of 2.
- **Change:** the counter's frame outset is now 3 px, and the tray spacing is 8.
- **`tests/test_pack.py`:** asserts the outset and the spacing.
- **Not verified in game:** this match is inferred from the measurement; it needs a screenshot to confirm.

## 0.9.4 (prerelease) — hover to peek

- **`tests/state.lua`** (8 new checks, 41 in total), using the real Core and State code:
  - Hovering the folded seal opens the HUD with root alpha at opacity × 0.35.
  - The ghost lasts through the leave grace, then folds immediately at full opacity, with no close timer.
  - Clicking the ghost opens the HUD for real at full opacity, and a second click folds it.
  - Combat start drops the ghost to full opacity, and there's no peek in combat.
- **Game evidence (user, 0.9.4):** "hover works". Hovering the folded seal shows the ghost HUD in the client.
- **Not verified in game:** whether every native aura child dims with the root.
- **Tray ring follow-up:** the user's "not working" screenshot was taken while the saved Warlock auras still carried build 902 (0.9.2, no ring). After the user updated, the saved data shows build 904 with the 3 px `subborder` on Soul Shards. Measured: `icon-frame.png`'s opening starts about 2.9 px outside the icon edge, so the frame doesn't hide the ring. Its look after the update isn't confirmed yet.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.9.3, with all 38 files verified (4 changed). The 0.9.3 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.9.3 (prerelease) — matching tray icons

- **Game evidence (user screenshot, 0.9.2):** the Soul Shards counter and the Demon Armor missing reminder sit side by side in one row. This confirms that an ordinary display chains into the Modern Aura Group. The two icons looked different: the reminder's art was inset inside a dark ring.
- **Source review:** a missing Modern aura is a stand-in copy of the native button (`CreateSampleNative`, `MissingLayout` in `SecretAuraSingle.lua`). `blizzardAuraDisplay` has no option for its inset or ring, though zoom does apply. So the counter copies the ring instead.
- **`tests/test_pack.py`:** the counter has a 3 px subborder at offset 0 below the frame subtexture, and one visible count (`%s`).
- **Not verified in game:** how closely the copied ring matches.

## 0.9.2 (prerelease) — one-row tray

- **Game evidence (user screenshot, Warlock, 0.9.0, folded):** the larger seal shows with the tray under it: health and resource percentages, the Soul Shards icon (18), and the Demon Armor missing reminder on a second row. This is the first in-game confirmation of the retracted mode, the larger seal, the tray gate and the Demon Armor missing reminder. It also showed the Soul Shards count twice (centre and corner).
- **Change:** the counter joins the centred row as its first member, and its centre number is hidden.
- **`tests/test_pack.py`:**
  - The tray holds only the row.
  - The row is at y = −74 with a single icon size.
  - Soul Shards lead the row and show only the corner count.
- **Not verified in game:** the ordinary counter chaining inside the Modern Aura Group.
- **Published 2026-11-12 as v0.9.2,** including 0.9.1: all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.9.0, with all 38 files verified (3 changed). The 0.9.0 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.9.1 (prerelease) — minimal tray

- `tests/test_pack.py` now asserts, for all nine classes:
  - there are no tray Health or Resource text displays;
  - the icon row is at y = −116 under the Warlock Soul Shards counter, and y = −74 for classes without a counter.
- Not verified in game.

## 0.9.0 (prerelease) — spell suggestions

Automated only; nothing here is game-client evidence.

- **Source review** (`Conditions.lua`):
  - The power curve supports `<=`.
  - It can AND only with readable (non-curve) checks, and one curve trigger is chosen per display.
  - So mana and health can't be combined. The user's example (Life Tap at 30% mana) is implemented on mana alone.
- **`tests/test_pack.py` (`test_warlock_spell_suggestions`):**
  - The order and centring of the row, and its clearance from the seal.
  - Life Tap: Power trigger, alpha 0, and a `percentpower <= 30` condition setting alpha 1.
  - Health Funnel: the pet Health curve.
  - DoT rules: Show On Missing with the `SuggestTarget` gate.
  - Shadow Trance: eligible once Nightfall (18094, 18095) is learned.
  - Every suggestion has a suggest load flag.
- **`tests/bundle.lua`:** suggestions hide while folded, and DoT rules need combat and a hostile target.
- **`tests/options.lua`** (aura status in the real panel code):
  - Missing Core and class: red text naming both, with the install button.
  - Older class and current Core: only the class is reported.
  - Both current: localized all-clear, no button.
  - The new modules have controls.
- **Not verified in game:**
  - curve-driven alpha on the icons;
  - the Nightfall talent IDs on Forever;
  - the row's spacing against the cradles and the class name.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.8.1, with all 38 files verified (5 changed). The 0.8.1 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.8.1 (prerelease) — no icon for an active upkeep buff

- **Game evidence (user screenshot):** the folded seal at normal size with the active Demon Armor icon to its right. That looks like the 0.7.3 companion: 0.8.0 was installed while the game ran, and needs a `/reload` and Update Auras. The user asked not to show the armor while it's up.
- **`tests/test_pack.py`:**
  - The Warlock active armor display and the Mage, Priest and Druid active upkeep icons are gone, and their missing reminders exist.
  - Mage Armor, Inner Fire, Aspect and Blessing keep their active icons.
- **`tests/selection.lua`:** the armor family is still kept out of the native buff row, through its reminder's catalog entry.
- **Not verified in game.**
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.8.0, with all 38 files verified (3 changed). The 0.8.0 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.8.0 (prerelease) — retracted seal and tray

Automated only; nothing here is game-client evidence.

- **Source review:** ForeverAuras' Modern trigger expands a name in `auraRankSpellIDs` to every spell ID with that name (`BlizzardAuraDisplay.lua` 428–432), and its validator accepts names. So Food, Drink and Well Fed need no ID list.
- **`tests/test_pack.py` (`test_retracted_seal_and_tray`), for all nine classes:**
  - The normal seal is gated `not Retracted()` and the larger one `Retracted()`.
  - Every tray member has a tray load flag and a tray gate, and hangs below the larger seal.
  - The second row is a centred Modern Aura Group, with Food, Drink and Well Fed matched by name.
  - The health and resource texts use native percent formats.
  - Warlock has Soul Shards and a Demon Armor missing reminder.
  - Name-matched icons skip spell discovery.
- **`tests/bundle.lua`:**
  - Folded: the tray shows and the buff and upkeep rows give way.
  - Open: no tray.
  - Tray off: the old behaviour.
- **`tests/state.lua`:** updated, because buffs no longer show while folded with the tray on.
- **ForeverAuras native schema:** passes (installed ForeverAuras 1.3.9).
- **Not verified in game:**
  - the fold and seal swap;
  - tray contents and spacing;
  - name matching against Forever's food and drink.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.7.3, with all 38 files verified (4 changed). The 0.7.3 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.7.3 (prerelease) — Demon Armor reminder

- Requested by the user ("missing demon armor alert?").
- `tests/test_pack.py` asserts that both Warlock reminders:
  - sit in Maintenance;
  - use `secretAura` with Show On Missing, and Active with remaining time;
  - cover the three armor spell IDs;
  - carry a maintenance load flag.
- The ForeverAuras native schema validator accepts them.
- Not verified in game.
- **Published 2026-11-12 as v0.7.3,** including 0.7.2: all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.7.1, with all 38 files verified (3 changed). The 0.7.1 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.7.2 (prerelease) — larger rim icons

- Requested by the user after 0.7.1. Rim icons are now 28 px with a 30 px step.
- The pack tests still pass:
  - centred rail members stay within their bar span;
  - weapon coatings stay past the resource bar and inside the frame;
  - the cradle above clears the rail.
- Not verified in game.

## 0.7.1 (prerelease) — buff row mirrors the DoT row

- **Game evidence (user screenshot, Warlock, 0.7.0):**
  - The Immolate DoT is centred on the Health-side rim.
  - Demon Armor shows past the Mana bar.
  - The native tracked buff (1:57) hangs above the empty Utility cradle, about 116 px up.
- **Change:**
  - Native buffs move to (138, 40) at 24 px.
  - In Forever mode the curated class buffs unload (`effect` catalog flag, `Selection.Allowed`) and the native row includes them.
  - In Class plan mode the native row is synced empty.
- **Tests:**
  - `tests/selection.lua`: Backlash unloads in Forever mode and appears in the native row. Class plan mode allows the curated buff and leaves the native row empty. Earlier native-row checks now run explicitly in Forever mode.
  - `tests/test_pack.py`: the native row's position, growth and size match the DoT row, and every curated class buff carries `effect`.
- **Not verified in game.**
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.7.0, with all 38 files verified (4 changed). The 0.7.0 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.7.0 (prerelease) — rows centred on each bar

Automated only; nothing here is game-client evidence.

- **Source review** of the installed ForeverAuras (`SecretAuraFlow.lua`):
  - A normal group with `blizzardFlow` is a Modern Aura Group.
  - `CENTER_HORIZONTAL` keeps the row centred with half-size shadow frames.
  - `FlowProblem` accepts Icon displays, and rejects a Remaining Time window only in grids. The Battle Shout "expiring" reminder uses one, but outside a grid.
  - Non-Modern displays in a screen-mode flow are chained as ordinary displays. Weapon coatings are therefore kept out of the rail.
- **`tests/test_pack.py`:**
  - Both rails sit at (±138, 40) as centred flow groups.
  - Every rail member has offset 0 and a `secretAura` trigger.
  - Every row keeps its side.
  - Buff-row members lie within the resource bar, and coatings sit past its end.
- **`tests/selection.lua`:** class-plan sides average exactly ±138, and the step between consecutive ranks is 47.
- **ForeverAuras native schema:** the installed ForeverAuras 1.3.9 accepts the combined, Core and nine class files.
- **Not verified in game:**
  - rows staying centred in and out of combat;
  - the Modern Aura Group chain with the class and module load flags;
  - wing centring and the unfold motion.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.6.2, with all 38 files verified (4 changed). The 0.6.2 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.6.2 (prerelease) — every row on its side

- **Game evidence (user screenshot, Warlock, 0.6.0):** a tracked buff appeared centred about 170 px above the HUD, in the Core's native player-effects row. The user asked why non-damage elements were not all moved right together.
- **Audit:** every positioned row of the combined import was listed and given a side by role.
- **Tests:** `test_damage_left_everything_else_right` computes each display's screen x through its parents for all nine classes.
  - Damage displays must be left, and everything else right.
  - The buff row and the Rend reminder must be at y=40, within their bar spans.
- **Previous release:** 0.6.1 was published (14 assets verified) and installed over 0.6.0, with all 38 files verified (3 changed), after a verified backup.
- **Not verified in game:** any 0.6.1 or 0.6.2 position.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.6.1, with all 38 files verified (3 changed). The 0.6.1 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.6.1 (prerelease) — DoT row seated over Health

- **Game evidence (user screenshot, Warlock, 0.6.0):**
  - The Immolate DoT shows in its fixed left slot, roughly 98 px above the anchor and away from the frame.
  - Demon Armor shows to the right of the Mana bar, as designed.
  - The user asked for these icons to be part of the frame, attached to the Health bar.
- **Change:** the DoT row moves to y=40 (24 px icons, 26 px steps, from x=−60). The wings move to y=80. Weapon coatings move to y=130.
- **Tests:** `tests/test_pack.py` now asserts:
  - every DoT icon lies within the Health bar's x span;
  - the row is at y=40;
  - the wing icons clear the row.
- **Not verified in game:** the row against the frame art, and the wing spacing.

## 0.6.0 (prerelease) — damage left, everything else right

Automated only; nothing here is game-client evidence.

- **Requested layout:** the user asked for "dps dots on the left bar (health) attach to the frame, and right group … other non dps CD", and for Demon Armor on the right.
- **`tests/selection.lua` (now 85 checks):**
  - The left wing takes the first four Essential entries in Cooldown Manager order.
  - The right wing takes the first four Utility entries, skipping preparation spells.
  - Overflow goes to the Essential and Utility rows without repeating wing entries.
  - With Utility abilities off, the right wing is empty.
  - Wing x offsets: left is negative, right is positive.
  - An empty Essential list leaves only the right wing; empty lists invent nothing.
  - Class plans put attacks left and support right.
- **`tests/test_pack.py`:**
  - Maintenance is at x > 250 and grows right.
  - Each class's DoT row is at y = 92 with distinct fixed slots inside the chassis (−256 < x < −60).
  - Core tracked bars are at x < −250.
- **Preview page:** mirrors the moved rows and class-plan sides. Captures in `preview/` and `docs/images` predate 0.6.0 and remain illustrative.
- **Not verified in game:**
  - wing contents and sides;
  - DoT row spacing against the left wing;
  - Maintenance beside the resource bar;
  - the update in `/fa`.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.5.1, with all 38 files verified (4 changed). The 0.5.1 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.5.1 (prerelease) — DoTs stay in the HUD's target row

- **Game evidence (user screenshots, Warlock, 0.5.0):**
  - The Core health, mana and pet bars draw above the Warlock chassis.
  - Both groups line up on one anchor.
  - A DoT with its countdown appeared about 170 px above the HUD centre, near the target. The user's `nameplates` setting is off, so this is consistent with the Core's native player-effects row (y = 151), which shows the Cooldown Manager's tracked list.
  - The saved aura data had not been written since the install, so the exact display was not read from it.
- **Fix:** `S.SyncCDM` now treats catalogued `dots` auras like tracked buffs. A native entry that matches one by name or spell ID is left out of the native player-effects row while the target-effects module is on.
- **Tests:** two new `tests/selection.lua` checks, 79 in total. Immolate is left out of the row while the target-effects module is on, and kept when it is off.
- **Not verified in game:** the DoT gone from the row above the HUD.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.5.0, with all 38 files verified (4 changed). The 0.5.0 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.5.0 (prerelease) — shared Core plus class groups

Automated only; nothing here is game-client evidence.

- `tests/test_pack.py` (15 tests) checks:
  - Core displays load for all nine classes behind `FOREVERHUD_CORE_` flags.
  - The Core and each class import are exactly their root's subtree, and the subtrees are disjoint.
  - Every standalone root follows `ForeverHUDAnchor`.
  - Shared displays exist only in Core.
  - Every texture is class art in the LOW strata, and every other display inherits its strata.
  - Update tags use `forever-hud-core` and `forever-hud-<class>`.
- `tests/bundle.lua` checks:
  - The Core bundle is byte-identical to `ForeverHUD-Core.txt`.
  - Core and class registration states.
  - Install order: Core first, an older Core before a current class, and the message naming the next step.
  - Root resolution for standalone and combined installs.
  - Detached Core displays.
  - The once-per-session warning about a 0.4 class group, and the install refusal over it.
  - Core load flags mirror the current class; shutdown clears them.
  - The cast-bar tint.
  - The new Chinese strings.
- `tests/selection.lua` and `tests/motion.lua` now look up the native rows and the Health and Resource bars in Core, and the wings and chassis in the class group.
- `tests/native-schema.lua` ran against the installed ForeverAuras 1.3.9 source, and the combined import, the Core and all nine class files pass. Each file is checked only for the displays it carries:
  - Core has the shared Resource colour conditions and the one tracked-bar renderer.
  - Class files have their auras, the FX curve and the custom-sorted wings.
- Source review of `ForeverAuras.lua` `FixGroupChildrenOrderForGroup`: frame levels start at 0 for every root. This is why class art uses strata rather than levels to stay below the Core bars.
- Not verified in game:
  - the two-step install from `/fa` or `/fhud install`;
  - Core bars drawing above the class chassis;
  - Core displays loading per class and per module;
  - the cast-bar tint;
  - the 0.4 class-group warning.
- Published 2026-11-12: all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.4.1 with all 38 files verified (9 changed); the 0.4.1 folder was backed up and verified first. SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.4.1 (prerelease) — import fix for group Init actions

Automated only; nothing here is game-client evidence.

- Reported in game with ForeverAuras 1.3.9: importing 0.4.0 stopped at `AuraEnvironment.lua:524: attempt to index field '?'`. Source review of the installed ForeverAuras: `LoadCustomActionFunctions` runs only for non-group displays, while `ActivateAuraEnvironment` runs a group's custom Init action through that missing table. The native wing's dynamic-group custom sort activated the wing during import.
- The generator now refuses custom actions on any group. The root and wing Init actions moved to the `Class name` text display and the wing entry icons.
- `tests/native-schema.lua` no longer stubs `ActivateAuraEnvironment` as a no-op: the mock fails like ForeverAuras on a group Init action, every group's actions are checked, and every custom-sorted dynamic group runs its sort. Against the 0.4.0 generator it fails on `Native left`.
- Not verified in game: the import completing, or the companion binding from the new location.
- Published 2026-11-12: all 13 downloaded release assets match the build, and the 38 runtime files match the source. Not installed. This is file evidence, not game-client evidence.

## 0.4.0 (prerelease) — renamed to ForeverHUD

Automated only; nothing here is game-client evidence.

- Mechanical rename of every runtime, generator, test, workflow and documentation identifier. Afterwards, `git grep -i eclipse` outside the history docs finds only the deliberate legacy checks (`EclipseHUD`, `Eclipse | `) and the migration notes.
- `tests/bundle.lua` now has 21 checks. The new ones: the old addon and old displays each warn once, the warnings name what to delete, and the legacy displays are never modified.
- `python scripts/build.py`, `python scripts/check.py` and `git diff --check` pass in WSL; CI repeats them with the pinned ForeverAuras checkout and the native-schema test.
- Not verified in game: the folder swap, the login warnings, or a fresh ForeverHUD install beside deleted Eclipse auras.
- Preview PNGs were renamed only; their pixels are 0.3.x illustrative captures.
- Published 2026-11-12: all 13 downloaded release assets match the build. Installed into the `_forever_` client with all 38 files verified. EclipseHUD was removed only after a verified backup. This is file evidence, not game-client evidence.

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
