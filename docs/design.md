# Eclipse implementation and reference notes

Version 0.3.0 implements the numbered work in [feature-parity-plan.md](feature-parity-plan.md). The reference inventory and work log distinguish source facts, Eclipse adaptations, mocks and outstanding game-client checks. Only the Warrior runtime source was supplied; the other eight class plans are original adaptations.

## Identity and selection

`src/catalog.py` declares candidates, school plans, original-equivalent Warrior stages and verified upkeep families. `scripts/build.py` generates the import and the companion's `Catalog.lua`; neither a seed nor a learning level proves training.

`Discovery.lua` scans actual learned spellbook entries outside combat. It matches localized names, complete configured ranks and learned bases/overrides, preferring the highest learned level independent of spellbook order. Missing, restricted and question-mark metadata fail closed. Proc aura IDs can qualify through learned native CDM identities without being castable spellbook actions. Learned passives cannot become action slots. Documented spell/talent/equipment/data events coalesce; disable/world leave cancels discovery and clears flags.

`Selection.lua` chooses up to four cooldown/support slots left and four attack/heal slots right, with ordered fallbacks and no duplicate learned identity. Warrior has the source's Leveling, ArmsEarly/Arms, FuryEarly/Fury and Protection plans, plus Cleave preference. Invested native talent-tree points choose a school; controls also allow manual selection. Druid form changes can reuse cached learned identities and update ordinary spell slots in combat, without rescanning spellbooks/CDM or changing root ancestry.

Unused learned combat skills occupy smaller on-cooldown offense/control/defense groups. Native CDM entries beyond these visible candidates feed a native cooldown clone row. Additional native tracked buffs/bars feed player-effect clones, including native stack/counter rendering. Preparation spells are excluded. Synchronization changes only Eclipse's two CDM templates through the public FA API, outside combat, and skips unchanged selections. All descendants retain class and module eligibility flags; disabled modules unload their trackers.

## Native combat boundary and the placeholder fix

Aura presence, ownership, duration, stacks, resources, cooldowns, usability, range, casts, swings, totems and coatings belong to ForeverAuras' built-in triggers. Fixed Aura (Modern) slots never depend on helper scans of private aura-button visibility. Ordinary CDM clones use FA's own CDM renderer. There is no combat-log inference or guessed ability timer.

The v0.2.0 placeholder defect was a misplaced setting: FA reads **`display.triggers.secretFallback`**, not `display.secretFallback`. With the old layout, `SecretAuraSingle.FoundFollow` selected the always-true custom gate as a fallback when an aura was absent. The corrected import explicitly selects `none`; a regression executes the actual FA selector for both configurations. A general schema pass alone did not catch this semantic bug. A full top-level reimport is required to update existing saved aura configurations.

Warrior reminders use native missing/remaining-time filters for Rend and Battle Shout. Verified Intellect/Fortitude/Mark families have equivalent native upkeep reminders. Unknown Warlock armor never becomes a fabricated missing warning. Other class player effects, shields, aspects, blessings and weapon coatings show native observed states.

## State, motion and coordinates

Idle leaves the emblem while primary/resource assemblies fold. A readable living attackable target opens them. Optional combat-entry expansion is an explicit Eclipse extension; the supplied unfold predicate itself checked a hostile target. Target/combat loss starts a five-second close timer; reacquisition cancels it. Settings and temporary inspection expand without permanent pinning. Casts and valid effects keep independent visibility rules.

Ordinary FA regions use native translation/alpha groups: 65ms forward/reverse stagger, 280ms smoothstep movement and an approximately 500ms transition. Reversal samples the current trajectory. Resources remain visible sliding open and fade closed. No continuous Lua frame loop runs. Death/loading/world leave, editor restoration and disable stop or silently reconcile motion. Native aura-button lifetimes/animations remain client-owned.

`EclipseHUDAnchor` owns the root position in UIParent units. Outside combat, the companion explicitly repairs a root that FA created before the anchor was available. Scale applies to the imported root, not the saved position anchor. New/reset position is `(0,-160)`; existing coordinates survive upgrades. Overall preference/root ancestry edits queue in combat. A position-only reset preserves every other preference.

At 100% scale: seal 104×104 at `(0,13)`; chassis 512×128 at `(0,20)`; health/resource 180×13 at `(±138,13)`; main icons 40×40 at y=52, x=±(83+47×slotIndex). Secondary categories use centered four-column grids at y=-57, target effects y=-130, swings y=-153, combo bar y=-155, cast y=-178 and additional native cooldowns y=-214. Modern player effects stay fixed; native CDM player effects have a separate row. Actual client spacing/stacking remains an acceptance check.

## Resources, casting, effects and sound

Native numeric rules hide zero countdowns, show tenths below one second, round seconds up, use minutes/seconds and urgency colors. Secondary countdowns sit below icons; prior formatting/points restore when disabled. Health/current resource text has integer precision. Original geometric 480-frame, eight-second inward flow accents retain the native foreground progress masks. Actual off-hand equipment determines single/dual Warrior swings; manual Dual cannot invent a weapon. Hunter melee/ranged swings, native combo points, carried shards, pets and totem slots retain their actual client sources.

Default cast-bar suppression is optional. `EclipseHUD.casting.Acquire(owner)` / `Release(owner)` support cooperative ownership. The implementation preserves Blizzard scripts/events, watches late bars and setters, and restores the latest external show request on final release. It cannot identify a foreign private owner that bypasses all setters/ownership interfaces. Completion decoration requires a matching observed start and successful cast; failed/interrupted casts cancel it, including channel-stop races.

Native modern-aura Start/Main settings supply low/blood/eyes/medium/major/defensive effect release/sustain. FA computes actual frame levels from **controlled-child order**: layers ascend in priority and sit behind foreground bars/icons. Resource intensity uses native Power conditions and FA's own curve path, including restricted values. Ordinary cast/real-swing accents have a master switch, bounded attachment retries and cleanup.

Original PCM chimes replace the private reference's MP3 voice recordings. Ready alerts are learned/native-event driven, combat-qualified and scheduled with 60ms coalescing, priority, two-second deduplication, four-second TTL and one-second startup suppression. Queue timing uses the known lengths of our own audio, never an estimated ability duration. Buff activation sounds register with native aura Added; two no-self-buff Warrior shouts use actual successful casts. Native Added playback is client-owned, as in the source; it is not a Lua aura callback and cannot be routed through a fabricated aura-state queue.

## Artwork and evidence

The AI-painted masters and exact prompts remain in `assets/ai/`. Own emblems/frame/borders are reused; no Guos media, scripts or voice files are bundled. Small geometric flow/rune accents remain SVG. Runtime textures are power-of-two RGBA TGA; audio is original mono PCM WAV.

The HTML/PNG previews show explicit sample learned lists, auras and values. They do not run WoW or establish protected-widget behavior. Actual FA validators/fallback/curve code runs in a mocked client environment. Live spellbook comparison, combat taint, physical position, native sound timing and normal logout persistence remain required; see [validation.md](validation.md).
