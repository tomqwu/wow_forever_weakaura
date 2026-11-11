# Changelog

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
