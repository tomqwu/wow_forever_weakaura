# ForeverHUD feature-parity plan

The project was named Eclipse (`EclipseHUD`) through 0.3.5 and is ForeverHUD from 0.4.0. Work-log entries keep the names in use at the time.

## Working state — 2026-11-10

**Current phase: 0.3.3 per-class import packaging requested; retain the combined import and preserve class IDs/preferences. Live acceptance remains pending.**

The previous **0.2.0** release exposed the live failures below. The **0.3.0** behavior implementation and **0.3.1** resource/module follow-up
have targeted regressions and native-source checks. Pictures,
import decoding and mocks still do not establish live feature parity. The user's
actual client evidence takes precedence over an illustrative preview.

The user requested: list every feature first, review the original source fully,
then implement and verify one item at a time. New artwork and README promotion
are secondary to working behavior.

### Confirmed live problems to reproduce

- Level-23 Warlock: the main ability row can be empty despite the native cooldown
  manager showing many spells. Eclipse has only six hardcoded primary candidates.
- Player effects show placeholder/question-mark icons with the FA editor closed.
  **Generator defect reproduced in native FA code:** v0.2.0 put `secretFallback`
  on the display rather than `display.triggers`. FA therefore followed the
  always-true custom gate when no aura was active. Correct nesting returns no
  fallback in the actual selector. Live confirmation after reimport is pending.
- Fear, Unending Breath and Ritual of Summoning were arbitrarily mixed together.
  Preparation spells should not occupy the default combat HUD.
- The default placement is unsuitable. `/eclipse` opens and unlocked dragging
  works; the initial location and layout still need correction.
- The HUD remains too expanded out of combat and lacks the reference's unfolding
  behavior. The simple rotating rune is not equivalent to the original effects.

### Source evidence and limits

- Original: **Guos Warrior Combat HUD v1.2.4**, supplied as a ForeverAuras import
  and companion media folder. Import SHA-256:
  `6db57aad73c5e8b2fea2033a240e9c3c7c46831f73e6b8b3ebb78f358483f5fd`.
- Decoded: transmission 2000, export version 1.3.0, internal schema 91; one root
  and **135 descendants**. See [the full inventory](reference-inventory.md).
- Descendants: 78 icons, 6 progress bars, 15 groups, 4 dynamic groups, 23 empty
  controller/alert displays and 9 textures. Custom actions: 84 init, 21 start,
  4 finish. Repeated shared scripts were compared by role and configuration.
- Source controllers reviewed: Ability Selection, HUD Animation, shared primary
  unfold/countdown setup, Resource Flow, Combat Animation, Default Cast Bar
  Control, Voice Playback, plus trigger/load/condition configuration of the
  remaining displays.
- Additional references: Mage, Priest, Rogue, Paladin and Hunter layout sheets,
  plus a Mage in-game screenshot. These establish visual organization; they do
  **not** prove the underlying scripts, live detection or spell availability.
- Only Warrior runtime source was supplied. Do not claim exact source parity
  for the other class packs or infer their hidden logic from promotional sheets.
- Keep the original scripts/media private. Implement equivalent behavior with
  Eclipse code and assets; do not repackage Guos art, scripts or voice recordings.

### Lessons from the six new image references

- Core skills sit **above the two resource bars**, split around the central
  character/emblem; auxiliary cooldowns are smaller and grouped below.
- The casting bar uses matching class-specific framing and has its own clear
  line. It is not just an unrelated plain rectangle below a large empty area.
- The same class artwork supports three visibly different specialization
  arrangements. A different emblem alone is not a specialization implementation.
- Class identity extends through the bar ends, icon borders and cast frame:
  feathers/fire/ice for Mage, hood/shadow for Priest, poison/steel for Rogue,
  gold/light for Paladin, and antlers/beast/arrow motifs for Hunter.
- Rogue's five resource sockets and Mage's resource/proc counters show that
  class mechanics need a deliberate visual home. Actual counts/capacities must
  come from verified client mechanics; do not infer them from a poster.
- The live Mage image tests readability against a busy world background and
  shows larger surrounding effects. It establishes appearance only, not which
  hidden aura or event drives each effect.
- These are visual acceptance references for later parity work. Do not create
  another promotional gallery while the functional checklist remains untested.

## Execution rules

1. Publish this complete checklist before runtime changes.
2. Work on **one numbered item at a time**, following the order below. Record
   the item, files, evidence, checks and unresolved limits in the work log.
3. Mark an item done only after its stated checks pass. Separate source review,
   mocked verification and live-client verification; never merge their status.
4. A broken or unverified item stays visible. Do not silently omit a feature,
   replace it with cosmetic artwork, or call a partial build a complete mirror.
5. Preserve all nine classes, aura IDs, user settings, native secret-value rules,
   and disabled-module cleanup. Do not alter the game install without a request.
6. Runtime work follows `AGENTS.md`: version/package updates, meaningful
   regression checks, native schema checks, and honest release notes.

## Complete feature checklist

`[x]` below means the stated acceptance is complete. Runtime code status and
automated evidence are recorded in the work log; live-dependent checkboxes stay
open until their client acceptance passes. Open does not mean unimplemented.
**R** = confirmed in original Warrior source. **U** = an explicit user request.
**A** = adaptation needed for Eclipse's nine-class scope.

### 00. Source audit and memory

- [x] **00.1** Inventory all 135 descendants and their triggers/custom-action phases. **R**
- [x] **00.2** Review selection, unfolding, resource motion, combat effects,
  casting ownership and voice scheduling; identify the shipped gaps. **R**
- [x] **00.3** Persist the full checklist and execution rules in the repository. **U**

### 01. Spell eligibility — fix before adding more displayed spells

- [ ] **01.1** Discover actual learned spells/ranks and overrides from the live
  client. Never treat a catalog seed or a sufficient level as proof of training.
  The original checks its complete rank sets, rather than just spell metadata. **R/U**
- [ ] **01.2** Verify localized names, icons and learned status; reject missing,
  restricted or placeholder metadata. Diagnose the live `?` separately from the
  learned-spell filter. A proc aura needs its real learned source or native CDM
  identity; the proc aura ID itself need not be a spellbook ability. **R/U**
- [ ] **01.3** Refresh on login, spell learning, talent/config changes,
  specialization and relevant equipment changes. Coalesce work; cancel pending
  work on disable/world leave. **R**

**Acceptance:** reproduce a level-23 Warlock spellbook/native CDM list; no
unlearned or unresolved icons in live mode; a newly learned rank updates without
reimporting; English and Chinese mocked paths plus live confirmation.

### 02. Ability selection and coverage

- [ ] **02.1** Match the original's functional two-sided hierarchy: up to four
  main cooldowns on the left and four main attacks on the right, with priority
  fallbacks, no duplicates and stable learned-slot ordering. **R**
- [ ] **02.2** Auto-select the talent school from invested points; support manual
  selection. Match Leveling, early Arms/Fury and mature Arms/Fury/Protection
  fallback behavior for Warrior before adapting other class plans. **R/A**
- [ ] **02.3** Provide useful low-level fallback spells instead of an empty
  primary row. For Warlock this must be checked against the user's actual
  spellbook and native CDM, not another speculative maximum-level list. **R/U/A**
- [ ] **02.4** Account for all appropriate learned combat cooldowns shown by
  Forever's default manager. Define how native CDM entries feed primary versus
  secondary slots, including entries outside the curated main selection. **U**
- [ ] **02.5** Move learned skills unused by the primary plan into secondary
  offensive/control/defensive groups. Match the original's small **on-cooldown**
  displays instead of showing every utility icon ready all the time. **R/U**
- [ ] **02.6** Exclude Unending Breath and summoning from default combat slots.
  Keep any optional preparation group separate from combat control such as Fear. **U/A**
- [ ] **02.7** Match Warrior's manual Fury Cleave-versus-Heroic-Strike selection
  and queued next-swing indicators; avoid presenting them as rotation commands. **R**
- [ ] **02.8** Match native cooldown/usability feedback: desaturate a confirmed
  cooling-down or unusable skill, highlight verified activation/usable procs,
  and apply the out-of-range tint only from native confirmed range failure.
  Preserve the primary row's deliberate global-cooldown feedback. **R**

**Acceptance:** inspect low-level and talent-trained loadouts, compare the full
eligible cooldown set with native CDM, and verify primary/overflow grouping.
No unrelated preparation spells or duplicated main/secondary icons.

### 03. Idle, target, combat and lifecycle state machine

- [ ] **03.1** Match the original's compact idle state. Its resource assemblies
  and primary skills fold away; the central emblem remains. Casting and valid
  effect/maintenance displays retain their own visibility rules. **R/U**
- [ ] **03.2** Expand on a readable, living, attackable hostile target. A friendly,
  dead, absent or unreadable target must not be treated as a live enemy. **R**
- [ ] **03.3** Add the user's requested combat-entry expansion explicitly.
  **Source distinction:** the original unfold predicate tests hostile target,
  not combat alone. Preserve this distinction in configuration and tests. **U**
- [ ] **03.4** Match the **five-second close delay** after losing the open
  condition. Reacquiring a target cancels the scheduled close. **R**
- [ ] **03.5** Support out-of-combat inspection/expansion without permanently
  pinning all rows. Keep editor preview separate from live state. **U/A**
- [ ] **03.6** Handle world leave, loading screens, death, resurrection, hidden
  frames and late class-module loading. No orphan timers or animations. **R**

**Acceptance:** test idle → enemy target → target loss → five-second close,
combat without a target, reacquisition during close delay, death/loading and
editor open/close. No question-mark samples remain after returning to live mode.

### 04. Unfold/fold animation

- [ ] **04.1** Animate primary skills out from the center in slot order;
  reverse the stagger on close. Source timing: **65 ms** slot stagger with
  **280 ms** smoothstep movement, within the roughly **500 ms** transition. **R**
- [ ] **04.2** Match resource-assembly slide behavior: visible while sliding
  open, fading while closing. Do not animate live native aura buttons or inspect
  their protected visibility/alpha to drive the transition. **R**
- [ ] **04.3** Reverse an interrupted transition from its current visual state;
  avoid snaps, stale offsets and stacking animation groups. Restore the ordinary
  region's normal offsets/alpha on stop. **R**
- [ ] **04.4** Optional unfold sound only on a real closed → open transition;
  suppress it at initial load, editor entry and restoration. **R**

**Acceptance:** repeated open/close/reverse sequences; animation-off mode;
zero continuous Lua work once settled; clean disable/reload.

### 05. Resources, swings and readable numbers

- [ ] **05.1** Health and the class's current resource use native progress and
  text rendering. Match readable percentage/current-value formatting; remove
  unintended decimals such as `624.0`. Restricted readings stay native. **R/U/A**
- [ ] **05.2** Add inward resource-paint flow while retaining the native fill
  mask. The source uses an **8-second, 480-frame FlipBook**; reproduce the
  behavior with our own asset/animation, not the original painted atlas. **R**
- [ ] **05.3** Match Warrior automatic single/dual swing layout from actual
  off-hand equipment, plus manual single/dual overrides. A shield, two-handed
  weapon or empty off-hand must not create a fake off-hand timer. **R**
- [ ] **05.4** Keep swing timers and queued-swing states native; separate
  main/off-hand indicators and real-swing decorative pulses. **R**
- [ ] **05.5** Adapt native class resources: Warlock demon health/carried shards,
  Hunter pet/ranged swing, Rogue/Druid combo points, Shaman totems and form-aware
  Druid power. Each needs learned/unit availability checks and clear labels. **A**
- [ ] **05.6** Match native countdown readability: hide zero, tenths below one
  second, rounded-up seconds, minute/second formatting and urgency colors.
  Compact secondary timers sit below the icon. Configure the client formatter;
  do not read restricted remaining times into Lua to format them. **R**

**Acceptance:** no invented numeric state, percentage, off-hand swing, pet or
resource. Check equipment swaps, pet absence/death, Druid forms and totem slots.

### 06. Auras, procs and maintenance alerts

- [ ] **06.1** Native active-buff tracking with rank-aware identities and
  eligibility gating. Unknown or unlearned entries must not show placeholders. **R/U**
- [ ] **06.2** Player-owned current-target effects, durations and stacks;
  distinguish another player's effect. Match the Warrior reference's Rend,
  Sunder Armor, Demoralizing Shout, Thunder Clap, Hamstring and Piercing Howl
  coverage before defining equivalent class-specific catalogs. **R/A**
- [ ] **06.3** Native usable/activation-overlay cues for Overpower, Revenge,
  Execute and Victory Rush; exclude duplicates already selected in main slots. **R**
- [ ] **06.4** Conditional missing Rend reminder; require the learned spell and
  appropriate live target/selection context. No warning from an unknown scan. **R**
- [ ] **06.5** Battle Shout missing and **≤15-second** expiring reminders;
  translate to verified class upkeep only where native observation supports it.
  Warlock armor uncertainty must never become a fabricated missing warning. **R/A**
- [ ] **06.6** Retain optional native nameplate tracking as an Eclipse extension;
  unload it when disabled and clear removed plates. **A**

**Acceptance:** apply/remove/expire each effect; test foreign ownership, no
target, restricted values, unknown metadata and all relevant player levels.

### 07. Casting and default cast-bar ownership

- [ ] **07.1** Native player casts and channels, spell text and readable progress;
  show actual casting independently of the idle combat layout. **R**
- [ ] **07.2** Add the original's optional default-cast-bar suppression. Preserve
  the original state and restore it when disabled/unloaded. Account for standard
  and gamepad bars without stripping Blizzard events or scripts. **R**
- [ ] **07.3** Safe ownership when another addon also controls the cast bar;
  handle bars loaded late and edit-mode/crafting re-enabling. **R**
- [ ] **07.4** Cast-bar decorative motion and successful-cast completion pulse;
  interrupted/failed casts do not produce a successful completion effect. **R**

### 08. Combat effects

- [ ] **08.1** Separate low/medium/major offensive and defensive visual states;
  define compositing priority so weaker layers do not obscure stronger ones. **R**
- [ ] **08.2** Bind effect lifetimes to native aura containers, not combat-log
  guesses or cached buff presence. Include reference effects for enrage, blood
  activation, eyes, burst release/sustain and defensive trim where applicable. **R/A**
- [ ] **08.3** Resource-intensity effects through client-native curves, including
  restricted values; no Lua resource arithmetic/threshold reconstruction. **R**
- [ ] **08.4** Resource/frame/swing/cast coordinated effects, a master switch,
  bounded attachment retries, and complete stop/restoration on all lifecycle edges. **R**

**Acceptance:** native effect ownership remains intact in combat; no protected
frame mutations, hidden-state inspection, overlapping release spam or idle leaks.

### 09. Audible alerts

- [ ] **09.1** Master alert switch and original-equivalent ready/activation
  event coverage. Use our own audio or a supported client facility; do not ship
  the supplied author's voice recordings. **R/A**
- [ ] **09.2** Ready alerts only for learned skills in combat, with the correct
  stance/equipment-dependent interrupt source. **R**
- [ ] **09.3** Activation alerts driven by native aura Added events; use verified
  successful casts only for effects whose source genuinely calls for it. **R**
- [ ] **09.4** Match coalescing, priority, de-duplication and stale-queue cleanup:
  source collection window **60 ms**, queued lifetime **4 seconds**, ready
  de-duplication **2 seconds**, and initial suppression **1 second**. **R**

**Acceptance:** simultaneous cooldowns do not overlap noisily; login/editor,
unlearned skills, leaving combat and world leave do not generate stale alerts.

### 10. Position, settings and nine-class adaptation

- [ ] **10.1** Correct the default below-character placement using actual UI
  scale/anchor behavior. Source root offset is `(0, -160)`; our existing `-150`
  value alone does not prove correct physical placement. **R/U**
- [ ] **10.2** Separate position reset from resetting all preferences. Preserve
  current user placement on upgrade; apply layout changes outside combat. **U/A**
- [ ] **10.3** Preserve unlock/drag, X/Y, scale, opacity, module switches,
  per-class saved settings and stable aura IDs. **A**
- [ ] **10.4** Provide the reference's school, swing mode, Cleave preference,
  default cast-bar, combat-effects and alert controls in coherent settings. **R/A**
- [ ] **10.5** Keep one import with automatic class loading; no inactive-class
  trackers, animations or timers. Validate English and Simplified Chinese. **A**
- [ ] **10.6** **Warrior:** verify the supplied source's leveling/early/mature
  three-school selection, queue/proc cues, maintenance and equipment-dependent
  swings before declaring the reference implementation matched. **R/A**
- [ ] **10.7** **Warlock:** validate the actual level-23 learned list, offensive
  cooldowns, control/defense, Bane/DoTs, demon health, shards and qualified procs.
  Keep preparation outside the default combat layout. **U/A**
- [ ] **10.8** **Mage:** separate Arcane/Fire/Frost learned plans, mana,
  applicable procs/counters, defense and casting. The supplied sheet establishes
  three arrangements, not a license to assume spell IDs or counter mechanics. **A**
- [ ] **10.9** **Priest:** separate Discipline/Holy/Shadow learned plans,
  healing/control/defense and target effects; qualify racial/talent-dependent
  entries using the client. **A**
- [ ] **10.10** **Rogue:** separate Assassination/Combat/Subtlety learned plans,
  energy/combo points, finishers, poison/bleed effects and control/defense. **A**
- [ ] **10.11** **Paladin:** separate Holy/Protection/Retribution learned plans,
  mana, healing/tank/offense slots, relevant upkeep and defensive cooldowns. **A**
- [ ] **10.12** **Hunter:** separate Beast Mastery/Marksmanship/Survival learned
  plans, pet state, ranged versus actual melee swings, stings and control. **A**
- [ ] **10.13** **Druid:** validate learned talent plans and current forms,
  mana/rage/energy, applicable combo points, bleeds, healing and defensive cues.
  No Druid runtime source was supplied. **A**
- [ ] **10.14** **Shaman:** validate learned elemental/enhancement/restoration
  plans, mana, live totems, shields/imbues, qualified procs and healing/control.
  No Shaman runtime source was supplied. **A**

Static images alone never establish specialization logic. Use actual source
if subsequently supplied; never describe these adaptations as audited copies of
class source that was not provided.

### 11. Preview, verification and delivery

- [x] **11.1** Preview idle, hostile-target, combat, delayed close and leveling
  states. Show only scenario-appropriate spell candidates; label sample values.
  A static maximum-level gallery is not runtime evidence. **U/A**
- [x] **11.2** Test behavior using mocked public/restricted values, plus native
  FA trigger/appearance validators. Add focused regressions for the reported
  level-23 Warlock and the position/idle failures. **A**
- [ ] **11.3** Perform live validation before marking runtime parity verified:
  learned spells, combat cooldowns, target auras, movement, animation, cast-bar
  restoration, audio, reload and normal logout persistence. **A**
- [x] **11.4** Update version/package/docs coherently, verify CI and published
  ZIP bytes, and list any remaining gaps explicitly. Never overwrite a release. **A**

## Implementation order

1. **01** — eligibility and the live placeholder diagnosis.
2. **02** — leveling/talent selection, complete cooldown coverage and grouping.
3. **03**, then **04** — the actual visibility state machine, then its animation.
4. **10.1–10.3** — correct initial position/reset without losing user settings.
5. **05**, **06**, **07** — resources/swings, aura alerts and casting ownership.
6. **08**, **09** — coordinated effects and audible alerts.
7. Remaining **10**, then **11** — all class adaptations, preview and release.

This order replaces the previous artwork-first approach. A documentation-only
plan update does not create a new runtime release.

## Work log / handoff memory

| Date | Item | Result | Evidence / next action |
| --- | --- | --- | --- |
| 2026-11-09 | 00.1–00.3 | Source audit and plan recorded; no runtime changes | Full 135-region inventory; primary controllers reviewed; user live failures recorded above. |
| 2026-11-09 | 01.1–01.3 | Learned identity discovery and eligibility unloading implemented; mocked checks pass; live acceptance pending | `Discovery.lua` scans actual spellbook ranks/bases and learned CDM identities outside combat, rejects placeholder/restricted metadata, coalesces documented learning/talent/equipment events and cancels on stop. 14 focused English/Chinese mock checks. `/eclipse spells` prints learned IDs and native attachment/suppression existence without inspecting protected visibility. The live `?` cause remains unproven; proc entries lacking learned evidence now unload rather than guess. |
| 2026-11-09 | 02.1–02.8 | Selection/grouping implementation and 43 mock checks; live CDM comparison pending | Four slots per side, invested-tree/manual school choice, source Warrior leveling/early/mature plans, manual Cleave, native queue/proc/usability/range cues. Learned unused candidates appear only on cooldown in offense/control/defense groups. Additional learned native CDM entries feed a native on-cooldown clone row, without cooldown reads. Preparation unloads. All nine classes have separate declared school adaptations; these are not audited Guos class source. Low-level Warlock fixture is a regression scenario, not the user's captured spellbook. Settings controls and live acceptance remain pending. |
| 2026-11-09 | 03.1–03.6 | Idle/target/combat state implemented; 21 focused mock checks pass | Emblem remains at idle; primary/resources/class resource fold. Readable living attackable target opens; optional combat expansion is separate. Five-second loss delay, cancellation on reacquisition, ten-second inspection, silent editor restoration, death/loading/world cleanup. Cast/effects remain independent. Live transition/hidden-frame behavior still needs client confirmation. |
| 2026-11-09 | 04.1–04.4 | Native unfold/fold implementation; 12 focused mock checks pass | Native translation/alpha groups sample 280ms smoothstep with 65ms forward/reverse stagger over 500ms. Reversal samples the current trajectory; resource slide-in remains opaque, closing fades. No Lua OnUpdate. Stop restores offsets/alpha and cancels finish timer. Optional supported-client unfold sound is silent on initial/editor restoration. Actual client animation playback still pending. |
| 2026-11-09 | 10.1–10.3 | Explicit anchor repair, new-profile offset and position-only reset implemented | Late-created root is parented/anchored to `EclipseHUDAnchor` outside combat. Fresh/reset position uses source `(0,-160)`; existing saved coordinates remain untouched. Position reset preserves scale/modules. Core suite now 47 assertions, including scale-independent coordinates and combat deferral. Physical client position remains unverified; the numeric default alone is not acceptance. |
| 2026-11-09 | 01.2 follow-up | Native placeholder cause reproduced and fixed in generator | Actual `SecretAuraSingle.lua` `FoundFollow` returns `next` for the old misplaced setting and `nil` for the corrected `triggers.secretFallback = "none"`. Added regression to native validator, separate from learned filtering. New import required; actual game display still awaits confirmation. |
| 2026-11-09 | 05.1–05.6 | Native formatting/resource flow/equipment checks implemented | Integer native health/power text; own geometric 480-frame/eight-second inward flow atlases retain FA foreground masks. Native numeric countdown formatter hides zero, uses tenths under one second, rounded seconds, urgency colors and minutes; secondary text sits below icon and previous styling restores. Actual off-hand weapon gates second swing; manual Single/Dual cannot invent equipment. Druid combo display qualifies energy form. Existing native demon/pet/shards/totems retained. 18 presentation/equipment mock checks; client flow/masks, all class-resource edge cases and coordinated real-swing pulses still require validation/08 work. |
| 2026-11-09 | 06.1–06.6 | Native effect coverage and source reminders implemented; native validation pending below | Learned/CDM-qualified procs and fixed native owned-aura slots; full six-effect Warrior target set; native usable proc indicators exclude selected main entries; native missing Rend requires hostile target and Arms context; Battle Shout missing/≤15s uses native filters, including another Warrior's shout. No Warlock armor missing warning. Nameplate eligibility/module flags unload trackers. Ownership, restrictions and duration gates are delegated to FA, with live apply/expire/foreign-caster checks still pending. |
| 2026-11-09 | 07.1–07.4 | Native casting retained; reversible ownership and verified cast-event observer implemented | `Casting.lua` preserves Blizzard scripts/events; supports standard/gamepad/late bars, cooperative owners and latest external setter requests. Default suppression starts only with an imported Eclipse cast bar and an enabled visible module. 14 ownership/event mock checks pass, including interruption and matching GUID. Ordinary cast motion and completion pulse connect in 08. Foreign addons that bypass all setters/ownership APIs cannot be inferred. |
| 2026-11-09 | 08.1–08.4 | Native effect layers and ordinary coordination implemented | Separate low/blood/eyes/medium/major/defense layers, ascending compositing levels; native Aura Start/Main provide release/sustain without helper hooks on protected buttons. Resource trim follows bar visibility. Native FA Power conditions generate the resource-intensity curve; actual `Conditions.lua` tested with restricted state (no helper arithmetic). Ordinary cast and real PLAYER_SWING pulses have a master switch and bounded eight-attachment retry. Native validators accept 163 modern displays. Actual appearance/overlap/taint and hidden-frame cleanup still need game-client validation. |
| 2026-11-09 | 09.1–09.4 | Native activation chimes and event-driven ready queue implemented; 12 focused mock checks pass | Own PCM chimes replace the reference's private MP3 recordings. Native Added registrations qualify learned identities. Ready events use native FA cooldown-ready triggers, confirmed combat, Warrior stance/shield interrupt selection, 60ms coalescing, priorities, 2s dedupe, 4s TTL and 1s startup suppression; queue cleanup and known chime duration prevent overlapping queued ready alerts. Two no-self-buff shouts use verified cast success. As in source, native Added playback is client-owned (not a Lua aura callback); successful casts reserve its chime interval. Live native-audio timing and audibility remain pending. |
| 2026-11-09 | 10.4–10.5 | Settings and class lifecycle implemented | Three settings tabs: modules, behavior, position. Manual/auto school, source swing/Cleave choices, independent unfold/resource motion/default-cast/FX/audio controls, temporary inspection and position-only reset. English/Chinese boundary covers all controls/school labels. Inactive class/module flags unload native trackers. |
| 2026-11-09 | 10.6–10.14 | Nine declared school adaptations implemented; live class verification pending | Source Warrior stages; Warlock leveling/control/demon/shards/qualified procs; Mage Arcane/Fire/Frost and native CDM counters; Priest healing/shadow and native class/racial cooldown overflow; Rogue builders/finishers/native coatings; Paladin school plans/blessings; Hunter pet plus actual ranged/melee swings; Druid cached learned Cat/Bear/caster switching and native form power; Shaman school plans/totems/shields/native imbue. Added verified Intellect/Fortitude/Mark upkeep families with native missing/≤15s gates; no guessed Warlock armor warning. Native learned CDM player-effect overflow captures additional buffs/stacks. 47 selection mock checks cover class plans and combat form changes. No other class's runtime Guos source was supplied; adaptation is not proof of live parity. |
| 2026-11-09 | 11.1–11.2 | Automated verification passed | 241 focused Lua assertions; eight package/schema/media test groups; import round trip with 830 descendants; actual FA validators/fallback selection and restricted resource-curve path pass on installed and public source (176 modern displays). Browser regressions pass across nine classes, explicit level-23 fixture, idle/enemy/combat/delayed close/reacquisition, stacking and settings. All nine preview images regenerated. Full build/package bytes and `git diff --check` pass. |
| 2026-11-09 | 11.3 | Pending game-client acceptance | No game installation or SavedVariables modified. Requires installing the new companion and updating the existing top-level import; `/eclipse spells` supplies actual learned/native diagnostics. Live spellbook comparison, placement, native audio, combat/taint, ownership and persistence remain open in `docs/validation.md`. |
| 2026-11-09 | 11.2 final lifecycle review | Added late-binding/world-leave regressions | Newly eligible ordinary regions may be created after load flags change, so their init callbacks coalesce a layout pass after registration; fresh slots cannot remain stacked at center. Late layout/notifications cannot re-enable world-leave controls or native flags. FX ordering follows FA's actual controlled-child ordering behind foreground UI. Selection/state suites now 50/22 assertions. |
| 2026-11-09 | 11.2 visual/audio follow-up | Sparse learned slots and controller gates corrected | Compact each wing by visible learned rank while retaining logical priority order; browser captures wait for loaded artwork. Ready observers ignore the HUD's combat-only visual gate so combat entry cannot announce every already-ready skill. Native buff overflow also excludes breathing/summoning. Initial branch CI passed; final follow-up reruns CI before merge. |
| 2026-11-09 | 11.4 | Merged and published; bytes verified | [PR #1](https://github.com/tomqwu/wow_forever_weakaura/pull/1) merged as `edb0f1d9eb91e7ac6cca17d2d6a11e1c3bc9f126`. Final PR CI and [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/42743959052) passed. [Immutable v0.3.0 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.0) published with ZIP/import/receipt; downloaded bytes match the checked local package and every runtime source/media file. ZIP SHA-256: `f79200752e02bcb8fc7784950f98fde5a326a50299cca34f1f7a21da04516a97`. TOC, generator, checks, artifact, README and changelog agree on 0.3.0. |
| 2026-11-09 | 05.1/05.5 continuation | Semantic resource colors/labels implemented; automated checks pass | Jade health/pet health, blue mana, gold energy, red rage, amber focus, neutral unknown identity. Native FA `powertype` conditions follow forms; actual FA condition compiler/evaluator tested through mana→energy→rage→mana with restricted amounts and unknown identity. Added localized role labels and native combo current/max text. Eight new label/guard assertions and nine Python groups pass. Client colors/readability still need acceptance. |
| 2026-11-09 | 00.3 integrity correction | Reference hash restored from actual file | Previous broad test-count replacement changed `a240` inside the original digest to `a241`. Recomputed SHA-256 from the supplied TXT and restored the exact digest above. Future counts must be edited contextually. |
| 2026-11-09 | 07.4 continuation | Observed cast-stop and disable cleanup fixed; 17 cast checks pass | Cast/channel stop immediately cancels looping decoration even if success is absent or late. A subsequent matching success may pulse; module disable clears both record and motion. Restricted unit tokens are rejected before comparison. Actual event order still needs client acceptance. |
| 2026-11-10 | 08.4 continuation | Independent FX binding and cleanup implemented; targeted checks pass | Ordinary resource FX no longer require Cast/Seal hosts when Cast is disabled; cast effects work without resource hosts. Disabled widgets allocate no frames/retries, stop and hide existing decorations, and remove unneeded swing listeners. Reimport reuses bounded owned frames; ancestry replacement defers in combat and old host hooks become dormant. Native resource trim now has a Resources eligibility dependency and unloads when that module is off. 25 FX and 18 discovery assertions pass. |
| 2026-11-10 | 11.1–11.2 continuation | 0.3.1 implementation and automated verification passed | 267 focused Lua assertions, nine Python groups, 830-descendant import round trip and ZIP source/media/hash verification pass. Installed/public FA validate 176 modern displays and execute the real color compiler through mana→energy→rage→mana with restricted amounts. Chromium verifies all nine classes, Druid form palette transitions, native-value fixtures and independent resource/pet controls; all gallery captures refreshed. `git diff --check` passes. Mock/native-source tests remain separate from game-client acceptance. |
| 2026-11-10 | 11.4 continuation | 0.3.1 merged, published and downloaded bytes verified | [PR #2](https://github.com/tomqwu/wow_forever_weakaura/pull/2) merged as `4411e3e83bb7aab30d3fa70dc0f9d58ccf177320`; PR CI and [release-commit main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/42760550177) passed. [Immutable v0.3.1 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.1) has ZIP/import/receipt; all downloaded bytes and 38 runtime files match the checked local build. ZIP SHA-256: `c9ca4b6927fbfc489e66e5de711a8a507aa9429b40fb4e1d4ff382e1273eea51`. Versions and README gallery agree on 0.3.1. v0.3.0 remains unchanged. |
| 2026-11-10 | 11.3 installation preparation (user requested) | Companion v0.3.1 installed; live acceptance still pending | Running `Wow.exe` confirmed the active `_forever_` product. Replaced companion v0.2.0 in `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD` using the published v0.3.1 package; all 38 file hashes verified (4 replaced, 13 added, 21 unchanged). Previous addon backed up and verified at `F:\WoW-addon-backups\EclipseHUD\20261110-091740\before\EclipseHUD`; receipt and matching import retained alongside it. SavedVariables untouched; no game restart. User still needs `/reload` and an in-game top-level import update through `/fa`; installation is not evidence that live spellbook/layout/combat checks pass. |
| 2026-11-10 | 01.2/02.3–02.6 live review reopened | Concrete failures recorded before edits | Native Warlock manager screenshot distinguishes Essential, Utility, Items and Not Displayed; v0.3.1 instead prefers authored plans, merges category overflow and filters it to on-cooldown only. It also ignores the manager's saved ordering/placement. A separate live image shows the redundant Warlock caption and an armor buff's 9:21 duration above the emblem. General.log records v0.3.1 imports calling helpers absent from the old in-memory companion at 09:19–09:21; the subsequent 09:27 error flood identifies AckisRecipeList taint in Blizzard health prediction. Do not attribute that external error to Eclipse or change unrelated addons. |
| 2026-11-10 | 01.2 guard correction | Generated bridge regression passes | All authored import callbacks require the matching companion version. Executing 2,684 generated callbacks with a missing helper or a v0.2-style table produces no missing-function calls; old helpers cannot open trackers. The root emits one install/reload instruction. This reproduces the error shape from General.log in a mock, not a new live-client pass. |
| 2026-11-10 | 02.3–02.6 native grouping correction | Focused discovery/selection/settings tests pass | Default mode reads the native provider's learned order and saved category placement, with public category-set fallback. Up to eight Essential entries occupy native CDM slots; remaining Essential entries stay visible in overflow, Utility and equipped items have separate on-cooldown rows, hidden entries stay out. Uncatalogued learned native entries no longer depend on authored priority lists. Explicit Class plan mode retains source plans. Native settings edits coalesce outside combat; bounded empty-login retries and callback cleanup are tested. 24 discovery, 62 selection and 35 settings checks pass; live comparison still pending. |
| 2026-11-10 | 03.3/03.4 combat-edge correction | Immediate event transitions tested | Combat entry uses the event's confirmed state immediately, including a test where the lockdown getter has not changed yet. Combat exit starts closing in that same callback when no hostile target/inspection is keeping it open; only target loss keeps the source five-second hold. 27 state and 12 motion checks pass, including hold cancellation and reversal from current position. Native client playback still needs acceptance. |
| 2026-11-10 | 05.1 palette revision (user requested) | Shared palette changed; generated resource tests pass | Health crimson `#D94A5A`, pet health muted crimson `#B95766`, mana blue `#438DFF`, energy gold `#F4C747`, rage orange `#F27A32`; resource labels remain. Native form-color conditions and restricted amounts stay client-owned. No new art generation or copied media. |
| 2026-11-10 | 06.1/10.5 presentation correction | Maintenance and caption changes pass package assertions | Stable Demon armor ID now belongs to a separate 20px maintenance area beside the left bar, with no long-duration number above the emblem. Native active-only observation is retained; no missing-armor inference. Other verified long-duration upkeep uses the independently switchable module. Native buff overflow excludes represented maintenance identities/family names. Existing class-caption IDs remain as empty displays. Ten Python groups pass; actual placement remains a live check. |
| 2026-11-10 | 02 ordering follow-up | Native sort wrapper and armor dedup regressions pass | FA multi-entry pickers sort by numeric ID, so ordinary overflow/utility/item groups now compare public clone identity ranks from the saved manager order. No aura values/visibility/timers are inspected. Actual installed/public FA dynamic-group wrappers execute that comparison with restricted state objects. Added armor-family exclusion so moving maintenance cannot recreate armor above the emblem via native buff overflow. Selection suite now 65 assertions. |
| 2026-11-10 | 11.1–11.2 correction checks | Local verification passed; delivery next | 294 focused Lua assertions, two old/missing-helper scenarios executing 3,422 generated callbacks, ten Python groups, 1,019-descendant import round trip and package checks pass. Both installed 1.3.7 and public FA validate 176 modern displays, native color conditions and actual dynamic-group sort invocation. Chromium verifies all nine classes, native-category/class-plan fixtures, empty captions, maintenance placement/timer absence, crimson/blue/gold/orange colors and independent switches; gallery refreshed. These remain mock/native-source checks, not a live cooldown comparison. |

| 2026-11-10 | 11.4/11.3 correction delivery | v0.3.2 merged, published, downloaded and installed with verified bytes | [PR #3](https://github.com/tomqwu/wow_forever_weakaura/pull/3) merged as `355fdb26d3989a573cde0e2a7ca97e36889afd07`. PR and [release-commit main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/42838759841) passed. [Immutable v0.3.2 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.2) downloaded ZIP/import/receipt match local bytes and all 38 runtime files. ZIP SHA-256: `6700989db47018618e3098137f350d15f6d3e2aa2b444ccee4c916734bae4452`. Installed into the same `_forever_/Interface/AddOns/EclipseHUD` (8 files replaced, 30 unchanged); v0.3.1 backup verified at `F:\WoW-addon-backups\EclipseHUD\20261110-095502\before\EclipseHUD`. No SavedVariables edits or game restart. `/reload` and the new top-level import are required before live comparison; no further runtime validation is claimed. |

| 2026-11-10 | 10.5/11.4 per-class import request | Scope and native-import behavior reviewed before edits | User requested smaller per-class strings. Native FA updater defaults Remove Obsolete Auras to true; exporting a partial shared root could delete omitted classes. Export each stable class group as the import root instead, so an update matches only that class and native update preserves its existing parent. Fresh standalone class groups need companion anchor/root resolution. Retain the combined nine-class export. Add graph/UID/codec/package checks and document the choice; do not alter installed SavedVariables. |

| 2026-11-10 | 10.5 per-class implementation | Scoped graph and root/bridge checks pass | Nine class files export only their stable class root/descendants; combined import retained. Warlock is 14,485 versus 85,992 characters (~83% smaller). Eleven Python groups verify closed/disjoint graphs, complete union, unchanged IDs/load flags, no mutation of the combined export and ZIP/manifests. Core suite now 57 assertions, including standalone anchoring/scale, existing combined-parent resolution, combat deferral, v0.3.2 bridge compatibility and native import-phase wait/coalescing/cleanup. Stable import API permits independent class updates. Live install/update UI evidence remains pending. |

| 2026-11-10 | 11.1–11.2 per-class verification | Local checks pass | Full build; 304 focused Lua assertions plus bridge scenarios; eleven Python groups; exact encoded-content/graph/UID verification for the combined import and all nine class files; manifest size/hash/ZIP byte checks; native validators, resource conditions and sort wrappers for all ten exports on installed/public source; and nine-class Chromium regression/captures pass. Native updater source review establishes preservation of the existing class parent; actual in-game update UI remains pending. |

| 2026-11-10 | 03.5 click toggle reopened (user live report) | Concrete click defect found before edits | Center clicks always called temporary Inspect(), extending its timer and never retracting. User explicitly wants a second click to fold back out of combat, including with the same target selected. Add a toggle with an out-of-combat manual-fold latch, reset on new target/combat/lifecycle; preserve slash/settings temporary inspection separately. |

| 2026-11-10 | 03.5 click toggle correction | Actual button callback regressions pass | First click pins an out-of-combat inspection; second click cancels inspection/hold timers and folds immediately, including with the same hostile target. A new target/combat edge restores automatic behavior. Slash/settings inspection remains temporary. 33 state and 12 reversal/motion checks pass. |
| 2026-11-10 | 07.2 casting choice / documentation request | Duplication and configuration requirements recorded before edits | User reports duplicate Eclipse/default casting bars and requests an explicit choice. Add Default/Eclipse/Both display mode; migrate overlapping defaults to the game bar, preserve existing explicit Eclipse suppression, restore game ownership if Eclipse is disabled/unavailable. README must have a full English section followed by Simplified Chinese, each documenting CDM setup/visibility and casting choices. Installed FA 1.3.7 toolbar source verifies Hide Blizzard's CDM, Always visibility, Set Up CDM and /fa cdmsetup behavior. |

| 2026-11-10 | 07.2 cast choice | Focused ownership/options tests pass | Explicit Default game bar / Eclipse bar / Both bars selector; overlapping legacy defaults migrate to the game bar, explicit prior suppression is preserved. Eclipse suppression requires the native aura to be loaded; disable/unavailable releases ownership and another cooperating owner remains respected. 21 cast and 37 localized settings assertions pass. |
| 2026-11-10 | 04.3 live snap report reopened / 06 tracked-bar request | Source causes recorded before edits | User wants smooth retract/unfold, not an instant visual jump. Layout/late-binding/root-show paths currently call motion.Change(...,true), silently finishing active transitions; newly created entries also seed from the already-open goal. Saved unfold=true confirms the animation switch is enabled. Separately the user's native Tracked Bars image includes Corruption, Bane of Agony, Immolate, Fear and procs; FA global CDM hide hides all four viewers. Preserve native bars via manual viewer settings and offer a separate native CDM bar renderer as an optional replacement. Keep all restricted duration rendering in native FA. |

| 2026-11-10 | 04.3 smooth motion correction | Reconciliation/reversal regressions pass | Root show, selection refresh and late binding now reconcile without silently completing active motion. Late ordinary entries start from the closed/open baseline and animate in; existing trajectories are not restarted. 16 motion assertions pass. |
| 2026-11-10 | 06 native tracked bars | Optional native renderer implemented | A separate, off-by-default native CDM aurabar stack can mirror Tracked Bars to the right; durations/stacks stay in FA's native CDM aura-progress path. Existing native bars remain available; docs will distinguish global hide from selective native viewer controls. Native aura-progress configuration checks pass. |
| 2026-11-10 | 02.4 cooldown semantics clarified (user screenshot) | GCD-only filler defect identified and corrected | Essential membership does not prove a real cooldown. Default native icons/overflow now use FA Show On Cooldown with GCD excluded; no inferred base-CD timer/list. New dynamic wings let native shown cooldown clones compact without helper inspection of cooldown state. Stable old slot UIDs remain, and v0.3.2 class layouts use a compatible fallback until individually updated. Instant-cast skills with a real cooldown still qualify while unavailable; DoT lifetimes belong to Target effects/Tracked Bars. |

| 2026-11-10 | 11 documentation/screenshot scope | English/Chinese sections and verified configuration paths authored | README now has one complete English section followed by Simplified Chinese. Both explain selective native viewer visibility (keep Tracked Bars), optional Eclipse bars, FA global hide/setup side effects, casting modes/migration, click toggle, smooth motion, cooldown-versus-DoT semantics and per-class updates. Supplied native configuration screenshots are labelled separately from browser fixtures. New capture paths cover casting choices, intermediate opening and optional right-hand bars. All late requests remain in one unreleased v0.3.3; v0.3.2 is untouched. |

| 2026-11-10 | 11.1–11.2 final v0.3.3 verification | Automated checks passed | Full build: 1,056 displays/1,055 descendants; Warlock 14,860 characters versus combined 88,402 (83% smaller). 330 focused Lua assertions, twelve Python groups, all ten codec round trips and ZIP byte/hash checks pass. Installed FA 1.3.7 and the public checkout validate combined plus all nine class files, including native aura-progress bars and identity-only dynamic sorting. Chromium passes nine classes, no fabricated leveling cooldowns, click folding, intermediate animation and three casting modes; captures refreshed. `git diff --check` passes. |

| 2026-11-10 | 11.4 v0.3.3 delivery | Merged, published and installed; bytes verified | PR #4 merged as `9fc7c6036e90429c01d5d31987ac4d89eed15c8a`; branch, PR and main run 42925051342 passed. Immutable v0.3.3 contains ZIP/hash, combined plus nine class files and manifest. Downloaded ZIP SHA-256 `9a09d84d355759dfebc95c83ba07861d7c76bf1d9f308e50d0fd4ccd51d5a306` and every runtime/import asset match. Installed all 38 files (9 changed) to the active `_forever_/Interface/AddOns/EclipseHUD`; previous files backed up at `F:\WoW-addon-backups\EclipseHUD\20261110-183934\before\EclipseHUD`. No SavedVariables or other addon edits. |
| 2026-11-10 | 11 documentation correction | Native Hidden guidance superseded | Final native UI source review shows `CooldownViewerMixin:OnHide` and cooldown subclass unregister events. Therefore native Essential/Utility Hidden is not a reliable selective opacity substitute. Current EN/ZH README keeps all viewers Always, offers native displays with duplicate Eclipse modules off or Eclipse tracked bars with FA global opacity hide, and explicitly supersedes the immutable v0.3.3 ZIP README recommendation. Runtime bytes/version unchanged; game-client validation remains pending. |

| 2026-11-10 | 10.3 live drag/position failure (user report) | Saved hierarchy diagnosed read-only; no runtime or SavedVariables change | The Warlock import is frozen in FA's mid-update state. `OptionsFrames/Update.lua` phase 1 re-adds every display with `parent=nil`/empty children in root-first preorder; phase 2 restores parents walking that list backwards. The generated preorder is root, Chassis, Living runes, FX layers, Seal, Class name, Health, Resource, Primary, Native left, Native 1–4 Entry, Native right, …; exactly those first 20 displays are still parentless and everything from Native right onward is restored, so phase 2 stopped before `Primary \| Native 4 \| Entry`. FA's `Async.lua` kills the import coroutine on any error, and a `/reload` also ends it; either leaves this state. `ForeverAuras.lua.bak` (18:42:06) already shows the same 21 roots, so the stop predates that reload and a reload does not heal it (FA only rebuilds the child lists from the surviving parent pointers: root 26 children, Primary 33). The companion moves only the class root, so the parentless SCREEN-anchored bars/art stay at screen centre while Soul Shards and the handle follow the saved offset. **Not established:** whether an error or an early reload stopped phase 2. `General.log` stops at 18:23:08 at ~1 MiB, before the v0.3.3 import, so it holds no evidence; the 18:22–18:23 CooldownViewer taint lines predate v0.3.3 and remain uninvestigated. A native Update over this state would not repair it: the detached displays sit outside the matched group, so FA assigns the incoming ones new UIDs/names. Next: delete all top-level `Eclipse \| Warlock…` entries in `/fa`, import the Warlock file fresh, let the progress window finish before any reload, and record any Lua error text. Decide on a companion-side detached-hierarchy warning after that evidence. |

| 2026-11-10 | 10.5/11.2 repository review (user requested: best practices incl. aura structure) | 0.3.4 unreleased; automated checks pass | User asked for "a single group with sub groups". Each class root now holds eight sections (Frame, Resources, Primary, Utility, Native rows, Auras, Nameplates, Alerts) plus Cast; no loose leaves, no empty groups (removed 72 empty v0.3.2 slot groups and 3 empty Maintenance rows), depth ≤3. IDs/UIDs and screen positions unchanged; Warrior procs moved into Primary with y=-75. FA Update maps child offsets to Group Arrangement (default on), source-reviewed. Companion review found no path that raises into or calls `Add` inside the import coroutine; it did find import-time mutations, now deferred (ApplyLayout, SyncCDM via Druid form, BindAbility timer, root show/hide hooks), plus a no-op native re-sort (now a reload on rank change), unguarded CDM trigger indexing, stacked hooks, a nil-class Alt-Z error and an early `return` that skipped remaining cast bars. Tooling: UTF-8/LF writes, deterministic ZIP (two builds identical), stale class files cleared, codec checks both hierarchy directions plus customText/customSort/customTriggerLogic, combined round trip, regex version/importAPI/TOC checks, CI SHA-pinned actions and FA commit, pip cache and a committed-import drift gate. New regressions: 2 core, 6 selection, 2 casting, 1 motion, 1 Python structure test. Local build also rewrote the gitignored local v0.3.3 ZIP (published asset unaffected). Chromium preview checks and captures were not run locally (no browser in this environment); CI runs them. Live import/update acceptance pending. |

| 2026-11-11 | 11.4 0.3.4 delivery (user requested: always PR and merge) | Merged to main; not released or installed | [PR #5](https://github.com/tomqwu/wow_forever_weakaura/pull/5) merged as `7e6b5e861b15f1128134b66a343f4e008cf205ce`. The first PR/push CI attempt failed in apt (runner DNS: `Temporary failure resolving security.ubuntu.com`), not in project code; the re-run passed every step, including Chromium preview checks and the committed-import drift gate. [Main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/43074945050) passed on the merge commit. Working copy moved, at the user's request, from the OneDrive checkout to WSL `/home/ubuntu/forever-gui-aura` (fresh clone at the merge commit; tracked files identical). There, build, check, native schema (installed FA 1.3.7, combined plus nine class files) and `git diff --check` pass, and a fresh build leaves the tree clean. The OneDrive checkout is left untouched. No GitHub release, game install or SavedVariables change. |

| 2026-11-11 | 11.4 v0.3.4 publication (user requested) | Published prerelease; downloaded bytes verified; not installed | [PR #7](https://github.com/tomqwu/wow_forever_weakaura/pull/7) dated the changelog and merged as `9508b4db6ed2e5f109df62ef1f47cd4fbecf11c6`; [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/43076439748) passed on it. Built and checked at that commit in the WSL clone, with the tree still clean afterwards. [Immutable v0.3.4 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.4) targets that commit with 13 assets: ZIP, its SHA-256, the combined import, nine class files and the manifest. All 13 downloaded assets match the local build; the receipt verifies; all 38 runtime files in the downloaded ZIP match the source. ZIP SHA-256: `b82d838fbdf36febd28c5bcbcfbef03f20c610446ebca9de15f2f8e7a4dabf65`. The game installation (still v0.3.3) and SavedVariables were not changed. |

| 2026-11-11 | 11.3 v0.3.4 installation (user requested) | Companion installed; bytes verified; live acceptance pending | Running `Wow.exe` confirmed the active `_forever_` product. Installed from the downloaded v0.3.4 release ZIP, whose SHA-256 matches the published receipt, into `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD`. All 38 file hashes match the package: 6 replaced (Casting, Core, Motion, Presentation, Selection, TOC), none added or removed. The previous v0.3.3 folder is backed up and verified at `F:\WoW-addon-backups\EclipseHUD\20261111-132331\before\EclipseHUD`, with the installation receipt, ZIP hash and Warlock import alongside it. SavedVariables were not touched and the game was not restarted (the TOC file list is unchanged, so `/reload` suffices). Next: `/reload`, delete the loose top-level `Eclipse \| Warlock…` entries in `/fa`, import `Eclipse-Warlock.txt` fresh, then confirm that the import finishes, every display sits inside its section, and dragging moves the whole HUD. |

| 2026-11-11 | 10.5/11.4 bundled imports (user request: "make the whole thing an addon, aura as dependent") | 0.3.5 implemented; automated checks pass; live acceptance pending | The user also reported that the v0.3.4 Warlock string fails to import; the pasted string is byte-identical to the release, and the error text has been requested but not yet received. ForeverAuras already supports addon-supplied auras via `AddCompanionData` (stash = ready to install, slugs = update when a display's `url` build is older), and EclipseHUD already declares `## Dependencies: ForeverAuras`. Implemented: generator update tags (build 305) on every class display; all nine encoded class imports embedded in the generated `Catalog.lua` (no new TOC file, so `/reload` suffices); current-class registration at `ADDON_LOADED`; `/eclipse install [force]`; a read-only detached-display check with a once-per-session EN/ZH warning that blocks unforced installs. Rejected: writing aura data directly into FA's database, which would bypass FA's import window and the player's confirmation. New `tests/bundle.lua` (18 checks) and a Python tag/manifest test; build, check and native schema for all ten imports pass in WSL. |

| 2026-11-11 | 11.4 v0.3.5 publication (user requested) | Published prerelease; downloaded bytes verified; not installed | [PR #10](https://github.com/tomqwu/wow_forever_weakaura/pull/10) merged the bundled-import feature as `51d9711`. [PR #11](https://github.com/tomqwu/wow_forever_weakaura/pull/11) dated the changelog and fixed the generated `imports/README.md`, which still described manual pasting only; the user's "doc updated?" check caught this before publication. PR #11 merged as `0094fa25833b34c46a61aab6dc73175793fefe6d`, and [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/43091139641) passed. Built and checked at that commit in WSL; the tree stayed clean. [Immutable v0.3.5 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.5) targets that commit with 13 assets. All 13 downloads match the local build, the receipt verifies, and all 38 runtime files in the ZIP match the source. ZIP SHA-256: `8742a94f7f8392ca66433333788ff2ac086f3660ae9fd1dc17f5bbcb1d0d0287`. The game still runs v0.3.4; SavedVariables were not touched. |

| 2026-11-11 | 11.3 v0.3.5 installation (user requested) | Companion installed; bytes verified; live acceptance pending | `Wow.exe` was running (started 13:05). Installed from the downloaded v0.3.5 release ZIP (SHA-256 matches the published receipt) into `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD`. All 38 file hashes match the package: 5 replaced (Catalog, Core, Locale, Options, TOC), none added or removed. The previous v0.3.4 folder is backed up and verified at `F:\WoW-addon-backups\EclipseHUD\20261111-152210\before\EclipseHUD`, with the receipt, ZIP hash and Warlock import beside it. SavedVariables were not touched. No restart is needed because the TOC file list is unchanged. Next in game: `/reload`; expect the detached-display warning for the earlier stalled Warlock update; delete the loose top-level `Eclipse \| Warlock…` entries; then install from `/fa` (ready to install) or `/eclipse install`. If the import still fails, capture the error with `/console scriptErrors 1`. |

| 2026-11-11 | Rename to ForeverHUD (user request: "Eclipse is not what we want", name "ForeverHUD") | 0.4.0 implemented; automated checks pass; not released or installed | Every identifier was renamed mechanically: folder/TOC/global `ForeverHUD`, `ForeverHUDDB`, `ForeverHUDAnchor`, `/fhud` and `/foreverhud`, `FOREVERHUD_*` load flags and event, aura names `ForeverHUD \| <Class> \| …`, `forever-hud-<class>` update slugs (build 400), and `ForeverHUD-*` files. History entries keep their Eclipse names. The user did not answer whether to rename the aura IDs; renaming everything was chosen because they asked for no Eclipse at all. Because UIDs derive from names, ForeverHUD auras are new and the old ones are not touched. Old settings cannot migrate, since WoW loads `EclipseHUDDB` only for the EclipseHUD addon; a read-only login check warns about a loaded EclipseHUD addon or leftover `Eclipse \| …` auras, and `tests/bundle.lua` covers it. Preview PNGs are renamed but still show the old wordmark. |

| 2026-11-12 | 11.4 v0.4.0 publication and 11.3 installation (user requested: "Publish and install") | Published prerelease; companion installed; bytes verified; live acceptance pending | [PR #14](https://github.com/tomqwu/wow_forever_weakaura/pull/14) merged the rename, including #13's docs commit. [PR #15](https://github.com/tomqwu/wow_forever_weakaura/pull/15) dated the changelog; it merged as `92b67a844137d704c6ec7950f1d4aaa2b3b7f773`, and main CI passed. The build dependencies, previously lost from `/tmp` when WSL restarted, now live in `~/.cache/foreverhud-deps`. Built and checked at that commit with the tree clean. The [v0.4.0 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.4.0) has 13 assets; all 13 downloads match the build, the ZIP's `.sha256` verifies, and the 38 runtime files match the source. ZIP SHA-256: `f94c43ce56015b64e8ecc9d18c26b30890e1e83d79011797a899898e70f6ac77`. Installed into `_forever_\Interface\AddOns\ForeverHUD` (38 files verified) while `Wow.exe` was running. The old `EclipseHUD` folder was backed up and verified (38 files) at `F:\WoW-addon-backups\ForeverHUD\20261112-091617\before\EclipseHUD`, with the receipt beside it, and only then removed. SavedVariables were not touched. A full game restart is required because the addon folder is new. Next in game: restart; expect the leftover-aura warning; delete every `Eclipse \| …` group in `/fa`; install from `/fa` or `/fhud install`; set `/fhud` preferences again; check that dragging moves the whole HUD. |

**Implementation status:** v0.4.0 (ForeverHUD) published as a prerelease and installed; EclipseHUD removed from the client (backup kept). In-game import and live acceptance are pending, and no live runtime acceptance is claimed. The reported drag/position failure is a half-finished native import in the saved data, pending a clean re-import.

**Next required evidence:** 11.3 game-client acceptance. Code and automated
checks are implemented; the detailed runtime acceptance checkboxes remain open
until the corresponding live checks pass. Do not restart the audit or claim that
the user's actual spellbook was captured by the mock fixture.
