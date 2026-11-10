# Eclipse feature-parity plan

## Working state — 2026-11-10

**Current phase: 0.3.2 correction in progress: native cooldown categories, maintenance placement and missing-helper guard. Live acceptance remains pending.**

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

**Implementation status:** 01/02/03/05/06/10 corrections implemented;
then 02.3–02.6 follow the native manager's learned Essential/Utility/Items and
hidden placement without cooldown arithmetic; then 06/10 move maintenance and
remove the redundant caption. Preserve IDs and all nine classes. No live
spell-name/learned list is inferred from grayscale configuration icons.

**Next required evidence:** 11.3 game-client acceptance. Code and automated
checks are implemented; the detailed runtime acceptance checkboxes remain open
until the corresponding live checks pass. Do not restart the audit or claim that
the user's actual spellbook was captured by the mock fixture.
