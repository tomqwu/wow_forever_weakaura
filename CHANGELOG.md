# Changelog

## 0.8.0 — 2026-11-12 (prerelease)

- **Retracted seal and tray** ([design](docs/hud-design-0.8.md)): the user asked for a compact retracted state like Forever Classmate's; ForeverHUD's own version uses no code or art from it. Out of combat with no hostile target (the existing fold), the HUD shows a larger seal (132 px instead of 104) with a tray under it.
  - **Tray, row 1:** health % and resource % flanking the Warlock Soul Shards count (native Item Count).
  - **Tray, row 2:** a centred Modern Aura Group with missing-upkeep reminders (Demon Armor, Arcane Intellect, Fortitude, Mark of the Wild), plus Food, Drink and Well Fed. These three are matched by aura name: ForeverAuras expands a name to every spell ID with that name.
  - **Folded:** the buff, upkeep and tracked-buff rows give way to the tray.
- New `/fhud` module **Retracted tray** (on by default). With it off, folding behaves as before.
- Not included yet: the painted tray plate (needs image generation), and combo points for Rogue and Druid (usually 0 out of combat).
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.7.3 — 2026-11-12 (prerelease)

- Warlock Demon Armor reminders, asked for by the user ("missing demon armor alert?"). Two native displays sit in the Maintenance row to the right of the resource bar:
  - **missing:** Show On: Aura(s) Missing, when none of Demon Skin, Demon Armor or Fel Armor is up;
  - **expiring:** its last 15 seconds.
  - They use the same reminder generator as the other classes' upkeep buffs. The existing active Demon Armor icon stays.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.7.2 — 2026-11-12 (prerelease)

- Rim icons on both sides are a bit larger: 24 → 28 px, spacing 26 → 30 px (user: "can both side icon a bit larger? a bit is fine"). This covers the DoT row and Rend reminder over Health, and the buff row, Battle Shout reminders, native tracked buffs and weapon coatings over the resource bar. They still clear the cooldown cradles above.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.7.1 — 2026-11-12 (prerelease)

- The Cooldown Manager's tracked buffs mirror the DoT row: centred on the rim over the resource bar (138, 40), 24 px like the DoTs, with the same frame. In 0.7.0 they sat above the Utility cradle and floated whenever no Utility cooldown was running (reported in game; the user asked for the "similar position of the dps cdm but on the right side, art works should be unified").
- One buff row per mode, so the two never overlap at that spot:
  - **Forever** (Cooldown Manager) layout: the curated class buff icons unload, and the native row shows every tracked buff, procs such as Backlash included.
  - **Class plan** layout: the curated class buff rail shows, and the native buff row stays empty.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.7.0 — 2026-11-12 (prerelease)

- **Rows centred on each bar.** Every row starts at the middle of its bar (x=±138) and grows evenly both ways, as the user chose ("balance in the middle, then expand to both sides"). This is the layout half of [the 0.7 design](docs/hud-design-0.7.md).
  - **DoT and buff rails** (y=40) are ForeverAuras **Modern Aura Groups** with *Centered Horizontal* growth. The client chains the icons and keeps the row centred in combat, without any Lua reading aura state. The Warrior Rend and Battle Shout reminders join their rails.
  - **Cooldown cradles** (y=80): the Essential and Utility wings are centred dynamic groups at x=±138. Class-plan icons are centred the same way.
  - **Native tracked buffs** from the Cooldown Manager now sit centred above the Utility cradle (138, 116) instead of floating.
  - Weapon coatings are not Modern auras, so they keep fixed slots on the rim just past the resource bar.
- Still to come: the painted groove, cradle and socket-bezel art. Its prompts are in `assets/ai/`, pending generation.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.6.2 — 2026-11-12 (prerelease)

- Apply "damage left, everything else right" to every row, not only the wings, DoTs and Maintenance (the user asked why it was not done all together):
  - **Right:**
    - The player-effects (buff) row is seated over the resource bar, mirroring the DoT row over Health. Before, it was centred 116 px above.
    - Warrior Battle Shout reminders and Shaman/Rogue weapon coatings take the next slots in that row.
    - The Core native buff row sits right, above the Utility wing (y=116), instead of centred 151 px above.
    - Utility and item overflow rows sit under the resource bar. Shaman totems sit lower right.
    - In class-plan mode, the Defense row is on the right.
  - **Left:**
    - Warrior Rend reminder takes the next slot in the DoT row.
    - Warrior usable-proc cues sit under the Health bar.
    - Essential overflow sits under the Health bar, moved up from below the cast bar.
    - In class-plan mode, the Offense row is on the left.
- A pack test now checks every row's side across all nine classes, and that both seated rows stay within their bars.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.6.1 — 2026-11-12 (prerelease)

- The DoT row now sits on the frame directly over the Health bar, within its width. In 0.6.0 it floated about 80 px above, away from the frame (reported in game). The icons are 24 px, 26 px apart, starting at the seal end of the bar.
- The ability wings (Essential left, Utility right) move up to y=80 so they clear the DoT row. Shaman and Rogue weapon-coating icons move up to y=130 to stay clear of the right wing.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.6.0 — 2026-11-12 (prerelease)

- **Damage left, everything else right.** The left wing over Health shows up to four **Essential** Cooldown Manager entries (damage cooldowns); the right wing over the resource bar shows up to four **Utility** entries (defensives, control, support). The game's own Essential/Utility split decides the side: drag a spell between them in Cooldown Settings to move it. Further entries stay in the rows below. With Utility abilities off, the right wing stays empty. Before, the wings held Essential entries 1–4 and 5–8.
- Your **DoTs on the target** move from below the seal to a fixed row above the left wing.
- **Maintenance** upkeep buffs such as Demon Armor move to the right, beyond the resource bar. Optional **tracked bars** (DoT and proc durations) move to the left.
- **Class plan** mode follows the same rule: attacks left, cooldowns and support right.
- Display positions changed: after updating the addon, `/reload`, then update the Core and your class in `/fa` (or `/fhud install` twice).

## 0.5.1 — 2026-11-12 (prerelease)

- Your DoTs on the target show only in the HUD's **Target effects** row under the seal. The Cooldown Manager's tracked list includes them, so 0.5.0 also put them in the native player-effects row 151 px above the HUD, near the target (reported in game). DoTs the HUD tracks are now left out of that row, the same way tracked player buffs already were. With the target-effects module off, the native row keeps them.
- Companion-only change: the imports are unchanged apart from their version tags.

## 0.5.0 — 2026-11-12 (prerelease)

- Split the auras into one shared **`ForeverHUD | Core`** group and one group per class. Core holds what every class uses: health, the current resource, the cast bar, the native Cooldown Manager rows (overflow cooldowns, utility, items), native player effects and the tracked bars. It loads for all nine classes (`FOREVERHUD_CORE_<module>` load flags) and follows the current class's `/fhud` settings. Class groups keep their spells, effects, art, pet health and class extras. Warlock: 126 → 112 displays; Core: 17.
- Class art (chassis, runes, seal, FX) now draws in the LOW strata, so the Core bars stay above it although the two groups are separate roots with their own frame levels.
- The companion anchors, scales and fades the Core and class roots together, or the combined root. It registers both with ForeverAuras' companion interface (`wago.io/forever-hud-core/<build>` for the Core), and `/fhud install` opens the first one that is missing or older, Core first, then says to run it again for the class.
- Import API 2: 0.5 imports need the 0.5.0 companion, and the companion paints the Core cast bar in the class accent.
- Moving from 0.4: the displays that moved to Core have new names, so an old class group would draw them twice. At login ForeverHUD warns once while a 0.4 class group is installed, and `/fhud install` waits until it is deleted. Delete `ForeverHUD | <Class>` in `/fa`, then install the Core and the class. `/fhud` settings are kept.
- Files: `dist/classes/ForeverHUD-Core.txt` joins the nine class files; the combined import holds the Core and all nine classes.

## 0.4.1 — 2026-11-12 (prerelease)

- Fix the import error `AuraEnvironment.lua:524: attempt to index field '?' (a nil value)` with ForeverAuras 1.3.9. ForeverAuras prepares custom actions only for non-group displays, but 0.4.0 put Init actions on the root and on the native cooldown wings; the wings' custom sort activated them during import.
- Move the companion bind and the "companion update required" guard to each class's `Class name` display, and each wing's layout bind to its entry icons. Groups no longer carry custom actions, and the build refuses them.
- The native-schema test now fails, as ForeverAuras does, on a group Init action and sorts every custom-sorted dynamic group.
- If a 0.4.0 import stopped partway, delete the half-imported ForeverHUD group in `/fa`, `/reload`, then install from `/fa` or `/fhud install`.

## 0.4.0 — 2026-11-12 (prerelease)

- Rename the project from Eclipse to **ForeverHUD**. Addon folder and TOC `ForeverHUD`, global `ForeverHUD`, settings `ForeverHUDDB`, anchor `ForeverHUDAnchor`, slash commands `/fhud` and `/foreverhud`, load flags `FOREVERHUD_<CLASS>_<module>`, event `FOREVERHUD_UPDATE`, cast-bar choice "ForeverHUD bar".
- Aura names become `ForeverHUD` (combined root) and `ForeverHUD | <Class> | …`; update tags become `wago.io/forever-hud-<class>/<build>` (0.4.0 = build 400). UIDs derive from names, so these are new auras: old `Eclipse | …` auras are not updated or deleted.
- Files: `ForeverHUD-All-Classes.txt`, `dist/classes/ForeverHUD-<Class>.txt`, release `ForeverHUD-v0.4.0.zip`.
- Not migrated: the old `EclipseHUD` folder and its `EclipseHUDDB` settings (WoW loads saved settings only for the addon that owns them), and the old auras. At login ForeverHUD warns once if the old addon is loaded or `Eclipse | …` auras remain (read-only scan). The README gives the one-time cleanup.
- Preview captures are file-renamed only; their pixels still show the old Eclipse wordmark until the next capture.

### Post-release documentation correction — 2026-11-10

The current README supersedes the v0.3.3 ZIP’s native Essential/Utility → Hidden guidance: native OnHide unregisters update events. Keep viewers Always. Choose native displays with duplicate Eclipse modules off, or Eclipse tracked bars with FA global opacity hide. No runtime/version change or release-asset overwrite.

## 0.3.5 — 2026-11-11 (prerelease)

- Bundle all nine class imports inside the addon. EclipseHUD registers the current class with ForeverAuras' companion interface: `/fa` lists it as ready to install when the class group is missing or predates update tags, or as an update when the installed group carries an older build. ForeverAuras runs its own import window and the player confirms; the companion writes no aura data. `/eclipse install` opens the same window.
- Every class display carries a `wago.io/eclipse-hud-<class>/<build>` update tag (0.3.5 = build 305). ForeverAuras parses only the number and never contacts wago.io. The combined root carries no tag.
- Detect displays left parentless by an interrupted import: one login warning (EN/ZH) with recovery steps, and `/eclipse install` refuses to import over them unless `force` is given. Read-only scan of ForeverAuras' saved table.
- The imports live in the generated `Catalog.lua`, so the TOC file list is unchanged and `/reload` picks up the update. New bundle test suite; manifest records each class's update slug and build.

## 0.3.4 — 2026-11-11 (prerelease)

- Organise each class group into sections (Frame, Resources, Primary, Utility, Native rows, Auras, Nameplates, Alerts) plus the cast bar; no loose displays at the class root. IDs/UIDs and screen positions are unchanged; Warrior usable-proc cues move into Primary with an equivalent offset. Remove the eight empty v0.3.2 "Native N" slot groups and the empty Maintenance rows of Warrior, Rogue and Shaman.
- Companion never mutates displays during a ForeverAuras import: layout, CDM selection sync, ability binding and root show/hide hooks wait for the import to finish. A long import no longer stops the bind retry; it continues slowly instead of leaving the layout unapplied.
- Reorder native rows/wings after a Cooldown Manager reorder (the previous re-sort call moved nothing). Guard user-edited CDM triggers; hook root and cooldown regions once; keep resource-bar hooks from raising into FA; fix a nil-class error on UI hide; keep acquiring remaining cast bars when one is unreadable.
- Build: deterministic release ZIP, UTF-8/LF output, stale class files cleared, explicit generator outputs. Checks verify the hierarchy in both directions, compile custom text/sort/trigger logic, round-trip the combined import, and assert one version/import API/TOC interface across files. CI fails when committed imports are out of date.
- Document the aura structure and recovery from an interrupted import (EN/ZH). Game-client acceptance remains pending.

## 0.3.3 — 2026-11-10 (prerelease)

- Add nine smaller class imports alongside the combined file. Class-group IDs/UIDs stay stable; class-only updates preserve existing parents/other classes, and standalone roots use the companion anchor. The stable import API preserves v0.3.2 compatibility.
- Fix center-click toggling: click to inspect, click again to fold out of combat, including with the same target. New target/combat edges restore automatic behavior.
- Preserve smooth slide/fade during layout/root-show/late-binding refreshes; start on combat events without snapping to the end state.
- Default native cooldown rows show real running cooldowns with GCD excluded, rather than persistent no-cooldown filler abilities. Native dynamic wings compact shown icons; Class plan remains an optional ability layout.
- Add an optional native CDM tracked-bar stack on the right. Keep DoT durations distinct from ability cooldowns; preserve the option to retain the game's tracked bars instead of globally hiding them.
- Add Default game bar / Eclipse bar / Both bars choices. Legacy overlapping defaults migrate to the game bar only; explicit previous Eclipse suppression is retained. Release game-bar ownership when Eclipse is disabled or unavailable.
- Rewrite README as English followed by Simplified Chinese, including CDM viewer/visibility and casting configuration. Refresh gallery, interaction/animation/casting/tracked-bar previews, and label supplied native screenshots separately.
- Native in-game import/update, animation playback, timer/taint and ownership acceptance remains pending. Existing releases are immutable.

## 0.3.2 — 2026-11-10 (prerelease)

- Guard imports against an old or missing in-memory companion, with one reload instruction.
- Follow native learned Essential/Utility/item categories and ordering by default; retain class plans as an option.
- Use crimson health, muted crimson pet health, blue mana, gold energy and orange rage with labels.
- React immediately to combat entry/exit; retain the five-second hold for target loss alone.
- Move long-duration upkeep into a separate maintenance module and remove HUD class captions while preserving aura IDs.
- Client acceptance of the updated cooldown layout remains pending.

## 0.3.1 — 2026-11-10 (prerelease)

- Use shared semantic bar colors: jade health, blue mana, gold energy, red rage and amber focus. Native resource-type conditions follow Druid forms; unknown resource types keep a neutral color.
- Add localized health/resource/pet/shard labels and native current/maximum combo text. Class colors remain on artwork and accents.
- Stop cast decoration on observed cast end and module disable. Bind ordinary FX independently, reuse frames across reimport, and unload native resource trim when Resources is off.
- Refresh all nine gallery images and add Druid caster/bear/cat palette previews. Record 267 Lua assertions, nine Python groups and actual native condition-compiler coverage in the durable log; live-client acceptance remains pending.

## 0.3.0 — 2026-11-09 (prerelease)

- Fix the native placeholder bug: store `secretFallback = "none"` inside the trigger combination. Regression reproduces v0.2.0 using ForeverAuras' actual fallback selector.
- Discover learned ranks/bases and localized names/icons, qualify proc identities through the client, reject placeholders, and refresh after learning/talent/equipment changes. Add `/eclipse spells` diagnostics.
- Implement four cooldown/support and four attack/heal slots, audited Warrior leveling/early/mature plans, nine class school adaptations, low-level Warlock fallbacks, native CDM overflow and separate on-cooldown combat groups. Exclude preparation spells.
- Fold the main layout at idle; expand for living hostile targets or optional combat entry. Add five-second close delay, temporary inspection, staggered native animation and interrupted-transition reversal.
- Repair late anchor binding; preserve old coordinates; add position-only reset and tabbed English/Chinese controls.
- Add native countdown rules, integer resource text, original inward flow accents, equipment-qualified swing layouts, Druid form switching, weapon coatings and native upkeep reminders.
- Add optional reversible default cast-bar ownership, native aura-driven effect layers/resource curves, verified cast/swing pulses and original audible chimes with ready-alert scheduling.
- Replace the static preview with labelled state/training scenarios and update all nine gallery images.

Update the companion **and reimport the top-level group**. Live-client acceptance, native audio timing, combat taint checks and logout persistence are still pending; this is not a production-verified parity release.

## 0.2.0 — 2026-11-09

- Replace the flat class seals with AI-painted, sculpted emblems for all nine classes.
- Add a carved metal resource frame and an AI-painted border around spell icons.
- Fit live bars to the new frame and increase spacing around the larger centerpiece.
- Replace preview glyph placeholders with spell thumbnails and remove crowded labels.
- Preserve AI masters, exact prompts, transparent exports and class-specific loading.

Live-client validation remains pending.

## 0.1.0 — 2026-11-09

- One ForeverAuras import with nine automatically selected class modules.
- Original class-specific seals and resource frames; cosmetic rune animation.
- Warlock demon health, carried Soul Shards, Bane/Wrack effects, armor and procs.
- Native aura rendering, learned-spell cooldowns, casting, form-aware power, class extras and optional nameplate effects.
- English and Simplified Chinese settings; independent class layouts, module switches, combat-only mode, dragging and deferred combat edits.
- Source generator, import codec, behavioral/schema checks, illustrative preview and packaged companion addon.

Initial build; live-client validation remains pending.
