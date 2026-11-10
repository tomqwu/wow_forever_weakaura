# Eclipse feature-parity plan

## Working state — 2026-11-09

**Current phase: plan and source audit. Runtime implementation has not started.**

The released version is **0.2.0**. Its pictures, import decoding, schema checks
and mocked settings tests do not establish feature parity or correct live spell
tracking. The user's live screenshots take precedence over the earlier preview.

The user requested: list every feature first, review the original source fully,
then implement and verify one item at a time. New artwork and README promotion
are secondary to working behavior.

### Confirmed live problems to reproduce

- Level-23 Warlock: the main ability row can be empty despite the native cooldown
  manager showing many spells. Eclipse has only six hardcoded primary candidates.
- Player effects show placeholder/question-mark icons with the FA editor closed.
  The exact native-rendering cause is **not yet established**; do not describe
  them as harmless editor samples or claim an eligibility fix resolves all causes.
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

`[x]` below means the audit artifact exists. All runtime items are pending.
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

- [ ] **11.1** Preview idle, hostile-target, combat, delayed close and leveling
  states. Show only scenario-appropriate spell candidates; label sample values.
  A static maximum-level gallery is not runtime evidence. **U/A**
- [ ] **11.2** Test behavior using mocked public/restricted values, plus native
  FA trigger/appearance validators. Add focused regressions for the reported
  level-23 Warlock and the position/idle failures. **A**
- [ ] **11.3** Perform live validation before marking runtime parity verified:
  learned spells, combat cooldowns, target auras, movement, animation, cast-bar
  restoration, audio, reload and normal logout persistence. **A**
- [ ] **11.4** Update version/package/docs coherently, verify CI and published
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

**Next item:** 01.1–01.2. First reproduce the live spell eligibility and
placeholder behavior. Do not skip directly to another generated preview.
