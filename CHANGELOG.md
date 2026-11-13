# Changelog

## 0.13.1 — 2026-11-13 (prerelease)

- **A missing buff breathes** (user, with a screenshot of the folded tray: "if armor is not on, the reminder here should flash? not crazy flash"; "like breathing").
  - Missing upkeep reminders, in the tray and on the HUD, play ForeverAuras' native **Pulse** (Aura Main) over 2.4 seconds: the icon fades to 40% and back, in a loop, while it's shown.
  - This covers Demon Armor, Arcane Intellect, Fortitude and Mark of the Wild. The "expiring" reminders and every other icon stay still.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.13.0 — 2026-11-13 (prerelease)

- **See your shield** (user: "for mage ice shield left over amount we should have visualization to show?"; "can you check if foreveraura supports this type?"; "Yes, build it").
  - The Core Health bar uses ForeverAuras' native **Fetch Absorb**. Your remaining absorb (Ice Barrier, Mana Shield, Power Word: Shield, Shadow Ward and the like) is a pale ice-white segment at the bar's full end, growing back over the fill. It shows at full health and shrinks as the shield is hit.
  - It's checked in the installed ForeverAuras source:
    - The option is offered only when the client has `UnitGetTotalAbsorbs`.
    - The overlay passes the hidden combat value straight to the client's status bars.
    - A ForeverAuras fix records the absorb overlay as already seen in game.
  - There's no number. Hiding a "0" when no shield is up would need a comparison the client doesn't allow in combat.
  - Whether this server counts each shield toward the total absorb is still to be confirmed in game. If it doesn't, nothing shows and nothing breaks.
- Update the Core in `/fa`, choosing **Update Auras**.

## 0.12.1 — 2026-11-13 (prerelease)

- **Shelf lines instead of grey boxes** (user screenshot on 0.12.0: "bugged?"; fix chosen: "Yes, fix it").
  - The 0.12.0 grooves weren't failing, but they read as three empty grey slabs. They showed over empty rows, covered the frame's rim art, and the class tint turned the dark fill flat grey.
  - Each is replaced by a thin class-coloured line (media `shelf`) under the rows that float above the frame: the suggestions on the left and the utility cooldowns on the right. The line is bright at the seal and fades outward.
  - Shelves show only in combat, when the rows are in use, and never while folded. The rim rows sit on the frame's own edge and get no line.
- Restart the game for the new texture, then update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.12.0 — 2026-11-12 (prerelease)

- **One spine from the seal** (user screenshot on 0.11.0: "help me design how better incorporate dps cdm into the frame itself, still raw". Chosen: one spine from the seal, with code-drawn grooves now and painted art later).
  - **Left (damage):** the DoT row, the suggestion row and the cooldown wing all start at the seal (inner edge x=-52) and grow left. In 0.11.0 the DoT row was centred on Health while the suggestions started at the seal, so they never lined up.
  - **Right:** your buffs, the tracked-buff row and the utility wing mirror the left side. Class-plan ability slots step outward from the seal too.
  - **Grooves:** a recessed channel tinted with the class colour now sits in the rim under the DoT and buff rows, with a cradle under the suggestions. They're drawn by code (`media.py`) and hidden while folded; the painted rail-groove, cradle and socket-bezel art is still to be generated from the prompts in `assets/ai/`.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.11.0 — 2026-11-12 (prerelease)

- **A clearer suggestion row** (user screenshot on 0.10.0: "can you design something make it better for recommendation?"; the design was approved before building).
  - **Rotation row:** actions now form a ForeverAuras Modern Aura Group that grows left from the seal. Whatever shows closes up with no gaps, and the slot next to the seal is always the top action.
  - **Cues by their bars:** mana cues (Life Tap, Evocation, Innervate, Mana Tide) sit under the Mana bar's outer end, and pet cues (Health Funnel, Mend Pet) under the Pet bar's. A threshold cue can't join the row, because it's shown at zero opacity until it fires.
  - **Execute slot:** Shadowburn under 25% has a fixed slot at the row's far end, so Destruction's row holds four actions.
  - **Not done:** an icon's size belongs to its rule, not its slot, so the top slot can't be drawn larger. It's marked by its fixed position.
- `tests/native-schema.lua` passes against the installed ForeverAuras.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.10.0 — 2026-11-12 (prerelease)

- **Rotation suggestions per class and spec** (user: "recommendation engine should optimize the rotation based on the class->spec" and "review other class").
  - Each class has one suggestion list per spec. It follows your talents, or the spec chosen in `/fhud`.
  - **Warlock:** Affliction (Corruption, Bane of Agony, Siphon Life, Shadow Trance), Demonology (Corruption, Immolate, Bane of Agony, Health Funnel) and Destruction (Immolate, Conflagrate, Backlash, Shadowburn under 25%). All three add Life Tap. Without talents the 0.9 list stays, with the same aura IDs.
  - **The other eight classes** get their first lists: DoTs to keep up, procs, core spells when usable, and resource cues such as Evocation, Innervate and Mana Tide. The full table is in the README.
  - **New rule types:** *ready* (the spell is usable now) and *buff* (your own buff is missing).
  - Rules still use one native check each, and load only once you know the spell. Mend Pet (136) is the one ID not already in the catalog.
- The left cooldown wing lifts above the suggestions only while your spec has a list.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.9.7 — 2026-11-12 (prerelease)

- **Suggestions stay right above your DoTs** (user screenshot on 0.9.6: the suggestions had jumped up, leaving a gap; "just above the dps spell is fine").
  - In 0.9.6 the row moved above the left cooldown wing whenever that wing had entries. Native Essential cooldowns can show only while on cooldown, so the gap was usually empty.
  - The suggestions now stay at y=74. For a class with suggestions turned on, the left wing rises 34 px instead, above the suggestions. The right wing doesn't move.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.9.6 — 2026-11-12 (prerelease)

- **Suggestions on the damage side** (user: "recommendation can be on the left? a bit lower, right above normal dps spell"). The spell suggestion row moves from above the seal to the left, centred over Health at y=74, 4 px above the DoT row.
  - When the left cooldown wing is showing (Essential cooldowns or class-plan attacks), the companion lifts the row to y=120, just above the wing, so they never overlap.
  - The row moves only out of combat. A change during combat applies when it ends.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.9.5 — 2026-11-12 (prerelease)

- **Tray icons really match** (user: "you never fixed", with a screenshot after updating to 0.9.4). The 0.9.3 ring wasn't the visible difference. Measured in game, ForeverAuras puts our frame tight around a native button's art (about 43 px on screen). The ordinary Soul Shards icon drew it 8 px outside the art (about 56 px), so it looked bigger and overlapped its neighbour.
  - The counter's frame outset is now 3 px, like the native buttons.
  - The tray row's spacing goes from 2 to 8, so frames don't overlap.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.9.4 — 2026-11-12 (prerelease)

- **Hover to peek** (user: "when mouseover to the foldable class image, can you have an effect where the whole bar in a faded out? so it will encourage/invite people to click?"). Hovering the folded seal out of combat opens the HUD as a ghost at 35% of your opacity setting.
  - **Leaving:** folds straight back after the existing 0.7 s grace, with no 5 s hold.
  - **Clicking:** the ghost opens for real at full opacity.
  - **Combat starting** (`PLAYER_REGEN_DISABLED`, before lockdown) restores full opacity.
  - Only the companion root's alpha changes, out of combat.

## 0.9.3 — 2026-11-12 (prerelease)

- **Matching tray icons** (user, 0.9.2 screenshot: "why they look different?"; chose to make the counter match). Out of combat, ForeverAuras draws a missing Modern aura (such as Demon Armor) as a stand-in copy of the game's own aura button. Its art sits inset inside a dark ring that no ForeverAuras option restyles. The ordinary Soul Shards icon now copies that ring: a 3 px dark border inside the icon edge, under the ornate frame.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.9.2 — 2026-11-12 (prerelease)

- **One-row tray, one style** (user, with a 0.9.0 in-game screenshot: "bottom spells should be horizontal", "style should be the same too"). The Soul Shards counter now leads the centred tray row instead of sitting in its own row above it. ForeverAuras chains ordinary displays into a screen-mode Modern Aura Group. Every tray icon is 34 px, and Soul Shards show a single count in the corner instead of a large centre number plus a corner number.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.9.1 — 2026-11-12 (prerelease)

- **Minimal retracted tray** (user: "I don't need 100% on both sides, make it minimlism"; chose the tray, not the bar text). The health % and resource % readouts beside the seal are removed. The tray keeps the Warlock Soul Shards count, missing-upkeep reminders, and Food, Drink and Well Fed. Classes without a counter get the icon row right under the seal.
- Update your class in `/fa`, choosing **Update Auras**; the removed displays are deleted.

## 0.9.0 — 2026-11-12 (prerelease)

- **Spell suggestions** (user: "add spell recommendation? based on certain condition? e.g. low mana 30% then life tap"). Warlock gets a fixed row of 32 px icons above the seal (y=112), in priority order. Every rule is native:
  - **Life Tap:** the Power curve ≤ 30% sets alpha (`Conditions.lua` PowerCurve).
  - **Corruption, Immolate:** Show On Missing on the target, gated to combat with a living hostile target (`E.SuggestTarget`).
  - **Shadow Trance:** the proc aura is active; shown once Nightfall is learned.
  - **Health Funnel:** the pet Health curve ≤ 35%.
- ForeverAuras evaluates one protected curve per display (`Conditions.lua` 1285–1297), so "mana low and health high" can't be combined; Life Tap checks mana only.
- New `/fhud` module **Spell suggestions** (on by default). Suggestions give way to the tray while retracted. Other classes have no rules yet.
- **Aura install status** (user: "if people installed the addon, but not WA aura or imported/updated, we should alert it"):
  - A one-time chat reminder at login when the Core or class auras are missing or older than the addon.
  - A status line at the bottom of `/fhud`: red with an **Install / update auras** button, or "Auras up to date".
  - Both read the update tags and saved data only (`E.AuraProblems`), and also report an old 0.4 class group or a half-finished import.
- Settings panel fixes: the title still read "E C L I P S E" (a rename leftover), now "F O R E V E R H U D". Module checkboxes are tighter, so the 16 modules no longer overlap the note under them.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.8.1 — 2026-11-12 (prerelease)

- No icon for an upkeep buff that's up (user: "If armor is up, you don't have to show it here"). These buffs now show only through their native missing and expiring reminders:
  - Warlock Demon Skin, Demon Armor and Fel Armor;
  - Mage Arcane Intellect;
  - Priest Fortitude;
  - Druid Mark of the Wild.
- Their always-on displays are removed, so **Update Auras** deletes them in `/fa`. Upkeep buffs with no reminder (Mage Armor, Inner Fire, Aspect, Blessing) keep their active icon as their only cue.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

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
