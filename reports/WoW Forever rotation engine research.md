# Client data rewrites ForeverHUD's suggestion lists

World of Warcraft: Forever is an official Blizzard game (the "Classic+" project, launched 2026-11-04 on client 1.60.1, interface 16001), not a private server, and that single correction changes where ForeverHUD's data must come from: the client's own spell table and Blizzard's patch notes, not remembered Wrath-era IDs ([Warcraft Wiki][wiki-main]). Checked against spell-name data scanned from the Forever client, **eight IDs in the current lists are wrong** (Hot Streak 44445, Fingers of Frost 44544, Missile Barrage 44401, Maelstrom Weapon 53817, Surge of Light 33151, Avenging Wrath 31884, Molten Armor 30482, Water Shield 24398), Druid Nature's Swiftness uses the Shaman ID, and the Nightfall rank 18095 does not exist on this client (SND:1862, 1383, 2483, 2319, 3896, 276, 2493, 4310, 2569; SAR:43). One rule has the wrong type: Shadowburn is a 15-second cooldown nuke on Forever, not an execute ([MetaBot Warlock][mb-lock]). At least a dozen Forever spells that drive the guides' priority lists are absent: Demonic Brand, Decimation, Incinerate, Holy Strike, Seal of Fury, Shank, Death Mark, Summon Hawk, Sniper Shot, Shifting Power, Primal Bite and Shadow Word: Death. The engine's one-check-per-rule model fits about four fifths of the guide rules as written; the rest are stack thresholds (Maelstrom Weapon at 5, Unsealed Wrath at 3, Heating Up at 3, Improved Scorch at 5), combo-point finishers and fight-length rules, for which this report gives the closest single check and names the loss. The blocking gap is aura identity: no source, web or local, records which ID a proc shows as on the player, so a `/fhud dump` command is the first deliverable. Every rotation here is nine days old, mostly written for a level-30 beta, and Blizzard has scheduled tuning for when raids open on December 9, so each rule carries a source and a confidence level and the low-confidence ones should ship off by default.

## Forever is a Blizzard game, and that changes the ground rules

**World of Warcraft: Forever** was announced at BlizzCon on 2026-09-12 and released on 2026-11-04; its internal name is "Camelot" and the community calls it "Classic+" ([Warcraft Wiki][wiki-main], [Game Informer][gi]). It is a separate continuity set in the first year of WoW with a level cap fixed at 60, one mega-realm per ruleset per region, a new race (Skyborne), dual spec at level 40, new zones and dungeons, and raids opening on December 9 ([Warcraft Wiki][wiki-main]). It is not Season of Discovery: no source describes a rune system, and new abilities arrive through trainers and reworked three-tree talents ([Warcraft Tavern classes][t-classes]). The installed client confirms the version directly: product `wowf`, version **1.60.1.70938**, with addon TOCs declaring interface 16001 (`F:\World of Warcraft\.build.info` line 6; `ForeverHUD.toc` lines 1 and 6).

The client shares retail's UI architecture, including most 12.1.5 APIs, and Midnight's addon restrictions ("secret" values) are active in it ([Warcraft Wiki API notes][wiki-api]). ForeverAuras, the WeakAuras fork this project builds on, states the practical result in its README: addons cannot read combat data directly and instead tell Blizzard's Cooldown Manager how to display it ([ForeverAuras on GitHub][fa-gh]). The engine constraint in this project (one native check per rule, no combat-log inference, no computed "next spell") is therefore Blizzard platform policy, not a quirk of one server, and it will not be lifted by a server operator.

The correction from "private server" to "official game" changes six things for ForeverHUD. First, there are no "server spells": the spells in question are Forever client spells, identical for every player in every region on a given build, so one verified ID table serves everyone. Second, the authority for mechanics is Blizzard's own development-notes thread, whose November 2 post is the last full class pass before launch ([Blizzard dev notes][bz-notes]); anything dated earlier is suspect. Third, the game will be patched on Blizzard's schedule: class power was raised across the board on November 2 and Blizzard said major tuning waits until raids open ([Blizzard dev notes, Nov 2][bz-nov2]), so rule data needs a build stamp and a re-verification step per client build. Fourth, a public database exists (Wowhead has a Forever spell section), which gives a second check on IDs once the URL pattern is confirmed ([Wowhead Forever spells][wh-spells]). Fifth, the client ships in several languages and this machine runs a Chinese locale pack, so rules must bind to spell IDs or Cooldown Manager entries, never to English aura names. Sixth, project text that says "server" (README, design notes, validation notes) should say "game" or "client", and release packaging stays keyed to the interface number Blizzard sets.

The kits are vanilla baselines with later-era and brand-new additions. Blizzard's notes and the per-class coverage name, among others, Banes and Wrack and Demonic Brand for Warlock, Arcane Blast and Heating Up and Ice Lance for Mage, Penance and Prayer of Mending and Shadow Word: Death for Priest, Victory Rush and Spearing Strike for Warrior, Shank and Mutilate and Death Mark for Rogue, Summon Hawk and Sniper Shot and a melee Survival tree for Hunter, Eclipse and Primal Bite and Shifting Power for Druid, Maelstrom Weapon and Riptide and Rage of the Farseer for Shaman, and Holy Strike, Seal of Fury and Unsealed Wrath for Paladin ([games.gg][gg], [Warcraft Tavern Nov 2 coverage][t-nov2]). Several beta additions were removed before launch: the November 2 notes removed Shaman Lava Burst (replaced by Call of Thunder), Druid Berserk, Rogue Thousand Cuts, Cutthroat and Quietus, and Paladin Twist of Light and Voice of Truth, and the October 1 notes removed Tiger's Fury and renamed Mage Hot Streak to Heating Up ([Warcraft Tavern Nov 2 coverage][t-nov2], [Blizzard dev notes][bz-notes]). Those removals matter below because several local data files and guides still carry the removed names.

## Client-derived files outrank every guide for spell IDs

No web source read for this research printed a reliable spell ID list, and web summaries should not be used as an ID source. The ranking below orders sources by how directly they derive from the client, and the per-spec tables cite them by the short names in the second column.

| Rank | Source | Short name | What it is | Reliability and limits |
|---|---|---|---|---|
| 1 | In-game reads on the live build (spellbook, talents, auras, Cooldown Manager sets) | dump | Does not exist yet; produced by the proposed `/fhud dump` | The only source that can settle aura IDs on build 70938 |
| 2 | `ForeverAuras\SpellNameData.lua` | SND | Every spell name that has two or more IDs, scanned with `C_Spell.GetSpellName` on client build 70374 (31,854 spells, highest ID 1325997) (SND:2-11) | Client-derived. An ID missing from a name's list is not called that name on 70374. Cannot confirm single-ID names or anything above ID 1325997; the installed client is 70938 |
| 3 | `ForeverAuras\SecretAuraRanks.lua` | SAR | Class, spell and rank IDs from talentsforever.com, generated 2026-09-24 (SAR:2-4) | Best local per-class list of learnable spells and rank families, but third-party beta data; still lists spells removed later (Tiger's Fury, Binding Heal) |
| 4 | `DungeonsForeverClass\...\Data_TalentTrees.lua` and `DungeonsForeverSpell\...\Data_SpellBook.lua` | TT, SB | Every talent node with spell ID, passive flag and new/changed status; trainer spells with learn level. SB is dated 2026-11-13 (SB:9) | Third-party but current; tooltips are Chinese and mostly rank 1 values |
| 5 | Blizzard development notes thread, November 2 post | Blizzard | Final pre-launch class pass ([Blizzard dev notes, Nov 2][bz-nov2]) | Authoritative for mechanics; no IDs; read here through summaries |
| 6 | Warcraft Wiki "(Forever)" ability pages | Wiki | Launch talent and trainer lists ([Warcraft Wiki][wiki-main]) | Reliable for what exists at launch; no IDs |
| 7 | MetaBot change lists | MetaBot | Data-mined tooltips for build 1.60.1.70790 ([MetaBot Warlock][mb-lock]) | Close to live; one Wrack entry is mislabelled as Destruction |
| 8 | Warcraft Tavern spec guides | Tavern | Ordered priorities for all specs ([Warcraft Tavern classes][t-classes]) | Warlock guides are dated November 1 to 11; Paladin and Druid are framed for level 60; Shaman guides are level-30 beta builds; Mage and Priest are undated |
| 9 | `DungeonsForeverClass\...\Data_ClassCombat.lua` rotation table | CC | Ordered priority list for all 27 specs (CC:634) | Level-30 guide data, machine-adapted, some rows scrambled; ordering hints only |
| 10 | wowtbc.gg, Zockify, Kami Labs, EZG, RankedBoost | as named | Secondary guides and talent lists | Undated or beta-era; useful second opinions |
| 11 | games.gg BlizzCon demo article; `ForeverUtilities` name catalog | games.gg, FU | Demo-build kit list; hand-authored names without IDs | Superseded in places (Twist of Light, Mangle, Hot Streak) |
| 12 | The repo's own IDs written from Wrath-era memory; general Classic knowledge | repo, GK | | Lowest. Every contradicted ID in the repo came from here |

Two findings from the local files shape the engine. Forever's custom spells sit in two ID ranges: roughly 399,000 to 470,000, which reuse Season of Discovery records, and 1,213,000 to 1,330,000, which are new to Forever. The client's name table also contains Chaos Bolt, Metamorphosis, Lava Lash, Kill Command, Crusader Strike, Divine Storm and other names that no Forever class list teaches (SND:573, 2431, 2196, 2155, 800, 1026), so "the name resolves in the client" proves nothing about whether a player can learn the spell. Only SAR, SB and TT entries count as player abilities. Second, multi-rank talents appear to use one spell ID per talent under the Traits system: "Nightfall" lists only 18094 and 23653, and "Arcane Concentration" has no multi-ID entry at all (SND:2569; SPEC:73-78), so vanilla per-rank talent IDs such as 18095 and 12574 to 12577 are most likely dead on this client.

The Icy Veins Forever rotation pages returned HTTP 403 and were not read, and they are probably the most detailed guides available. That is the largest single hole in the guide evidence.

## What the current lists get wrong

The audit below compares `SUGGESTIONS` in `scripts/build.py` (lines 149 to 208 of the ForeverHUD 0.13.8 checkout) and `src/catalog.py` against the sources above. The Warrior lists and nearly all vanilla IDs are confirmed against SAR and need no ID changes (SAR:494-529).

### Wrong or outdated IDs and names

| Class | Current entry | Problem | Replacement | Evidence |
|---|---|---|---|---|
| Mage | `active('Hot Streak',44445)` | 44445 is not Hot Streak on this client (the name maps to 48108 and 401724), and the Forever talent is **Heating Up**: Fireball, Frostfire Bolt, Fire Blast and Scorch crits cut the next Pyroblast cast by 25%, stacking to 3 for 20 s. It never makes Pyroblast instant | Talent 400624; aura is one of 400625 or 460878, to be read in game | SND:1862, 1796; TT:154; [MetaBot Mage][mb-mage] |
| Mage | `active('Fingers of Frost',44544)` | Wrong ID | Talent 400647; aura one of 400669, 400670, 401741 | SND:1383; TT:177 |
| Mage | `active('Missile Barrage',44401)` | Wrong ID | Talent 400588; aura one of 400589, 401736, 467409 | SND:2483; TT:129 |
| Mage | Clearcasting talent list 12574 to 12577 | Per-rank talent IDs are probably invalid | Keep 11213 only | SND (no multi-ID entry); TT:128 |
| Mage | Molten Armor 30482 in the armor upkeep list | Wrong ID, and Molten Armor is in no Forever Mage list | Remove | SND:2493 |
| Shaman | `active('Maelstrom Weapon',53817)` | Wrong ID | Talent 408498; aura one of 408505, 409946 | SND:2319; TT:399 |
| Shaman | Water Shield 24398 in shield upkeep | Wrong ID | 408510 | SND:4310; SAR:415 |
| Shaman | "Elemental Mastery" 16166 | ID is right, name and effect changed: it is **Lightning Mastery** (Lightning Bolt cast faster and Chain Lightning without cooldown for 15 s) | Rename | SB:1718; TT:380 |
| Shaman | Earth Shield 974 | Absent from the Shaman spell list and from every guide | Hold until dumped | SAR:364-419 |
| Priest | `active('Surge of Light',33151)` leading Discipline and Holy | Wrong ID (the name maps to 431664, 431666, 431668), and no Surge of Light talent node or guide mention was found | Remove | SND:3896 |
| Paladin | Avenging Wrath 31884 | Wrong ID and not in the Paladin spell list | Remove | SND:276; SAR:215-267 |
| Druid | Nature's Swiftness 16188 | That is the Shaman spell; the Druid one is 17116 | 17116 | SAR:43, 398; TT:56 |
| Druid | Frenzied Regeneration 22845 | SAR lists only 22842 | Accept both until dumped | SAR:29; CC:63 |
| Druid | Tiger's Fury 5217 | Removed in the October 1 notes; SAR predates that | Remove unless the dump shows it | [Blizzard dev notes][bz-notes]; SAR:63 |
| Warlock | Shadow Trance talent list `[18094,18095]` | 18095 is not Nightfall on this client | 18094 only | SND:2569; TT:434 |
| Warlock | `active('Backlash',34936)` | Not in SND, SAR or the talent tree extract, and in no Forever guide | Remove | local data notes |
| Warlock | Shadow Trance aura 17941, Improved Scorch debuff 22959 | Cannot be verified locally (aura-only IDs) | Keep, verify by dump | local data notes |

### Wrong rule types and orderings

**Shadowburn** is written as a target-health curve at 25%, an execute. On Forever it has a 15-second cooldown, needs a Soul Shard that 5/5 Shadow and Flame refunds, grants a 20-second Fire damage buff, and the Destruction guide uses it on cooldown ([MetaBot Warlock][mb-lock], [Tavern Destruction][t-destro]). It should be a "spell usable" rule in the cooldown tier. Only the leveling list keeps a finisher flavour ("when the mob is below one Shadowburn hit"), which "usable" also covers ([Tavern Warlock leveling][t-lock-lvl]).

**Hammer of Wrath** leads all three Paladin lists. No Forever guide places it in a priority list; one talent note says Champion of the Light makes it usable in PvE for Retribution ([Tavern Retribution][t-ret]). It should stay for Retribution and leave Holy and Protection. **Vampiric Embrace** is a "missing on target" rule, but on Forever it is a 30-second effect on a 30-second cooldown and no source says whether the aura sits on the target or the player ([MetaBot Priest][mb-priest]); "spell usable" is the safe form. **Hot Streak** is treated as a proc that means "cast now", but Heating Up is a stack counter whose payoff comes at 3 stacks. **Maelstrom Weapon** has the same flaw at 5 stacks. Paladin seal logic inherited from vanilla is also wrong: Judgement no longer consumes the Seal, and Seals last 30 seconds, so seal upkeep is a plain timer ([Tavern Paladin leveling][t-pal-lvl]). The Warrior Protection list carries Overpower and Execute, which the Protection priority lists do not use ([wowtbc Protection][w-prot]), while Thunder Clap and Demoralizing Shout upkeep are absent.

### Missing Forever spells

Demonology has neither of its two defining rules: **Demonic Brand** upkeep and Soul Fire during **Decimation**. Destruction has no Incinerate, no Bane and no Corruption. Affliction lacks Amplify Curse and uses a 30% Life Tap threshold where its guide says about 40% ([Tavern Affliction][t-aff]). Mage has no Ice Lance, Fire Blast, Arcane Wrath or Pyroblast rule. Shadow lacks **Shadow Word: Death**. All three Rogue specs lack **Shank**; Assassination lacks Mutilate and Subtlety lacks Death Mark. The three Hunter lists are identical and omit Summon Hawk, Sniper Shot and Strider Kick. Druid lacks Insect Swarm, Eclipse, Shifting Power, Primal Bite, Lacerate, Swiftmend and Wild Growth. Shaman lacks Rage of the Farseer and Lightning Mastery. Paladin lacks **Holy Strike** (trained at level 6 and present in every Paladin priority list), Seal upkeep, Seal of Fury, Unsealed Wrath, Swift Judgement, Infusion of Light, Oath of Light and Light's Vigil. Warrior suggestions lack Spearing Strike, Reckless Swings and Slam.

## The engine: one check per rule, four classes, fixed order

### What Demonic Brand is

Demonic Brand is a passive Demonology talent with 3 ranks (talent spell 1293695; five same-name IDs 1293695 to 1293699). Searing Pain generates less threat and marks the target for 10 seconds; the pet's next attacks on the marked target deal extra Fire or Shadow damage with high threat (TT:455; SND:931; [MetaBot Warlock][mb-lock]). It has no button and no cooldown. The guides treat it as a debuff kept on the main target by recasting Searing Pain, and one local priority list says the mark drops "roughly every 6 seconds", which fits the pet consuming its charges before the timer ends (CG:1046, 1054; CC:973-975; [Tavern Demonology][t-demo]). The rule is "Demonic Brand missing on target, suggest Searing Pain", loaded only when talent 1293695 is known. The debuff ID is probably one of 1293696 to 1293699 and must be read in game.

### Rule model

Each rule is one native ForeverAuras check and carries metadata the current tuples lack. The existing kinds map onto the allowed checks as follows: `active` (a proc or buff aura of yours is up), `react` and `ready` (spell usable), `missing` (your aura missing on target), `buff` (aura missing on player), `curve` (one health or power threshold). One kind is missing and should be added: **`expiring`** (aura remaining time at or below N seconds, treating "missing" as true), for cast-time DoTs and stacking debuffs. Each rule should also record its class (condition, maintenance, cooldown, resource), the unit it tests (player, target, pet, focus), the spell or talent that gates loading, the full rank family for aura matching, a source tag and a confidence level.

Display order is fixed and derives from class: **condition-triggered first** (procs, reactive strikes, executes), then **maintenance** (DoT, debuff, short self-buff), then **cooldown-gated**. The stable sort already in `build.py` does this for reactive rules; it should extend to the other two tiers. Resource cues (Life Tap, Evocation, Innervate, Mana Tide, Mend Pet, rage dumps) live outside the five-row list, as they effectively do today. Long self-buffs and forms (Shadowform, Moonkin Form, aspects, blessings, armors, Battle Shout) belong with the existing upkeep reminders, which frees suggestion rows for combat decisions.

Three design rules follow from the constraint. Priority order substitutes for a second condition whenever that condition is "a higher rule is not firing": Lava Burst after Flame Shock, Wrath after Eclipse Starfire, Eviscerate below Slice and Dice. "Spell usable" is the best proxy for any spell whose own requirements encode the condition: Conflagrate needs Immolate, Shadowburn needs a shard, Overpower and Revenge and Riposte need their trigger, Exorcism needs a valid target type. Where a rule depends on a talent rank or a raid assignment the engine cannot see (Bane of Doom versus Agony, which Curse, whether Shadow and Flame is 5/5), it becomes a per-class option, not a guess.

Aura identity should come from the Cooldown Manager where possible. ForeverAuras builds its catalog at run time from `C_CooldownViewer`, resolves each entry through linked and override spell IDs, accepts every rank of a family because the viewer names one rank while a lower rank applies its own aura ID, and special-cases Banes because "a Bane's cast spell is not its aura's" (CDM:362-455, 569-581, 692-695). Binding a proc rule to a Cooldown Manager entry plus its rank family is sturdier than a hard-coded aura ID.

### Guide rules that need more than one check

| Guide rule | Real condition | Closest single check | What is lost |
|---|---|---|---|
| Lightning Bolt at Maelstrom Weapon 5 ([Tavern Enhancement][t-enh]) | Stacks = 5, ideally with the Stormstrike debuff up | Maelstrom Weapon aura active | Fires from 1 stack; each stack is only 20% off the cast. Show the stack count on the icon and treat the glow as "building" unless the native trigger can test stacks |
| Seal swap at Unsealed Wrath 3 ([Tavern Retribution][t-ret]) | Stacks = 3, then swap Seal for one swing and swap back | Unsealed Wrath aura active | Fires early and cannot express the two-step action. Best shipped as a stack tracker, with the suggestion optional |
| Pyroblast at Heating Up 3 ([Tavern Fire][t-fire]) | Stacks = 3 | Heating Up aura active | Fires at 1 or 2 stacks, when Pyroblast is still slow |
| Scorch to 5 Improved Scorch ([Tavern Fire][t-fire]) | Stacks < 5 or about to expire | Improved Scorch remaining <= N s on target | Stops prompting after the first Scorch; the build-up to 5 is on the player |
| Arcane Wrath at 3 to 4 Arcane Blast stacks ([Tavern Arcane][t-arc]) | Stack count plus cooldown | Arcane Wrath usable | Suggests it at low stacks |
| Sunder Armor and Lacerate to 5 ([wowtbc Arms][w-arms], [Tavern Feral][t-feral]) | Stacks < 5 or expiring | Remaining <= 4 to 5 s | Under-suggests while stacking |
| Slice and Dice, Rupture, Rip ([wowtbc Combat][w-combat], [Tavern Feral][t-feral]) | Aura missing and enough combo points | Aura missing or expiring | Prompts at 0 to 4 combo points |
| Eviscerate at 5 points if Slice and Dice is safe | Combo points and an aura | Combo points >= 5 as a power threshold, placed below Slice and Dice | Needs combo points to be readable as a power type; unverified |
| Shank below 55 to 70 energy ([wowtbc Assassination][w-assa]) | Off cooldown and energy below a cap | Shank usable | May prompt near full energy, wasting part of the refund |
| Death Mark at 5 points with pooled energy ([wowtbc Subtlety][w-sub]) | Combo points, energy, cooldown | Death Mark usable | Prompts at low points |
| Shifting Power below 50 energy ([Tavern Feral][t-feral]) | Off cooldown and energy < 50 | Shifting Power usable | Slightly early use |
| Summon Hawk when fewer than two are out ([wowtbc Beast Mastery][w-bm]) | Pet-count state | Summon Hawk usable | Over-suggests; it shares a cooldown with Arcane Shot |
| Bane of Doom with a minute or more left ([Tavern Destruction][t-destro]) | Time to die | None; user option choosing Doom or Agony | The engine never switches by itself |
| Any Bane missing (Agony, Doom or Havoc) | Three auras | The chosen Bane missing | Prompts Agony on a Havoc target |
| Bane of Havoc on a second enemy | Off-target debuff | None; show as a tracker only | No suggestion |
| Life Tap under 40% mana at the end of a Wrack channel ([Tavern Affliction][t-aff]) | Mana and channel state | Mana <= 40% | Can prompt mid-channel |
| Lava Burst with Flame Shock up | Cooldown and target aura | Lava Burst usable, ordered below Flame Shock missing | Nothing material |
| Spearing Strike versus Giants and Dragonkin for Fury ([wowtbc Fury][w-fury]) | Creature type | Spell usable, low priority | Prompts on all targets |
| Litany of Light alternating heals; healer triage | Last spell cast; raid health | None | Omitted |

Whether the native ForeverAuras aura trigger can compare a stack count as part of one check was not researched and is the most valuable engine question to answer: if it can, the first six rows become exact.

## Recommended lists for all 27 specs

Class codes: **C** condition-triggered, **M** maintenance, **CD** cooldown-gated. Confidence: **High** means a Forever source gives the mechanic and local client-derived data confirms the ID; **Medium** means the mechanic is sourced but the aura ID, aura location or level-60 placement is unconfirmed; **Low** means conflicting sources, general Classic knowledge, or a spell whose launch status is in doubt. Low rows should ship disabled by default. "ID?" marks an ID the notes do not contain. Forms, aspects, blessings, armors and other long buffs are left to the upkeep reminders.

### Warlock

Sources: [Tavern Affliction][t-aff], [Tavern Demonology][t-demo], [Tavern Destruction][t-destro], [MetaBot Warlock][mb-lock], local CG:1054 and CC:954-990. All three specs open with Bane, optional Curse, then DoTs. A Warlock keeps one Bane and one Curse of their own on a target; Banes exclude each other ([Tavern Warlock][t-lock]).

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Affliction | 1 | Shadow Bolt on Shadow Trance | C | Aura active on player | 17941 (talent 18094) | Tavern | Medium (aura ID unverified) |
| | 2 | Bane of Agony | M | Missing on target | 980 family | Tavern, SAR:421 | High |
| | 3 | Corruption | M | Missing on target | 172 | Tavern | High |
| | 4 | Siphon Life | M | Missing on target | 18265 | Tavern, SAR:473 | High |
| | 5 | Amplify Curse | CD | Spell usable | 18288 | Tavern, SAR:420 | High |
| | cue | Life Tap | resource | Mana <= 40% | 1454 | Tavern | Medium |
| Demonology | 1 | Soul Fire during Decimation | C | Decimation aura active | 6353; talent 440870, aura ID? | MetaBot, CG:1054 | Medium (Shadow build skips it) |
| | 2 | Searing Pain for Demonic Brand | M | Brand missing on target | 17923; debuff one of 1293696-1293699 | Tavern, TT:455 | Medium |
| | 3 | Bane of Agony (or Doom by option) | M | Missing on target | 980 / 603 | Tavern | High |
| | 4 | Immolate | M | Remaining <= 2 s | 348 | Tavern | Medium (duration unpublished) |
| | 5 | Corruption | M | Missing on target | 172 | Tavern | High |
| | cue | Life Tap; Health Funnel | resource | Mana <= user value; pet health <= 35% | 1454; 755 | Tavern (no number) | Low on thresholds |
| Destruction | 1 | Conflagrate | C | Spell usable (needs Immolate) | 1293817 family | Tavern, SAR:426 | High with 5/5 Shadow and Flame; see note |
| | 2 | Immolate | M | Remaining <= 2 s | 348 | Tavern | Medium |
| | 3 | Bane of Agony (or Doom by option) | M | Missing on target | 980 / 603 | Tavern | High |
| | 4 | Corruption | M | Missing on target | 172 | Tavern | High |
| | 5 | Shadowburn | CD | Spell usable | 17877 | Tavern, MetaBot | High |
| | cue | Life Tap | resource | Mana <= user value | 1454 | Tavern (no number) | Low on threshold |

Below 5/5 Shadow and Flame, Conflagrate still consumes Immolate, so a leveling option should change its rule to "Immolate remaining <= 3 s" ([Tavern Warlock leveling][t-lock-lvl]). Incinerate (412758, 1293812, 1293813) and Wrack (1316697) are fillers and need no rule. Bane of Havoc (1225228) is a tracker. The Curse is raid-assigned and should be an optional, user-selected row. Sources conflict on Wrack's effect (double tick speed per Tavern, 10% more periodic Shadow damage per the local tooltip at TT:439), which does not affect any rule.

### Mage

Sources: [Tavern Fire][t-fire], [Tavern Arcane][t-arc], [Tavern Frost][t-frost], [MetaBot Mage][mb-mage]. The Mage guides are undated.

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Arcane | 1 | Arcane Missiles on Missile Barrage | C | Aura active | talent 400588; aura one of 400589, 401736, 467409 | Tavern, SND:2483 | Medium |
| | 2 | Arcane Blast on Clearcasting | C | Aura active | 12536 (talent 11213) | Tavern, SND:615 | Medium |
| | 3 | Arcane Wrath | CD | Spell usable | 1326079 (name inferred from Chinese) | Tavern, TT:136 | Medium |
| | 4 | Fire Blast (hybrid builds) | CD | Spell usable | ID? | Tavern | Low |
| | 5 | Arcane Power | CD | Spell usable | 12042 | Tavern, SAR:163 | Medium |
| | cue | Evocation | resource | Mana <= 20% | 12051 | Tavern (no number) | Low on threshold |
| Fire | 1 | Pyroblast on Heating Up | C | Aura active (stack count lost) | talent 400624; aura 400625 or 460878 | Tavern, MetaBot | Medium |
| | 2 | Arcane Missiles on Missile Barrage (if talented) | C | Aura active | as above | Tavern | Medium |
| | 3 | Scorch for Improved Scorch | M | Remaining <= 5 s on target | 22959 unverified | Tavern | Low (ID and duration unknown) |
| | 4 | Fire Blast | CD | Spell usable | ID? | Tavern, MetaBot | Medium |
| | 5 | Combustion | CD | Spell usable | 11129 | Tavern, SAR:168 | Medium |
| | cue | Evocation | resource | Mana <= 20% | 12051 | Tavern | Low on threshold |
| Frost | 1 | Ice Lance on Fingers of Frost | C | Aura active | 1312002 / 400640; aura one of 400669, 400670, 401741 | Tavern, SND:1383 | Medium |
| | 2 | Frostbolt on Clearcasting | C | Aura active | 12536 | Tavern | Medium |
| | 3 | Arcane Missiles on Missile Barrage (if talented) | C | Aura active | as above | Tavern | Medium |
| | 4 | Ice Barrier | M | Missing on player | ID? | Tavern, MetaBot | Medium |
| | cue | Evocation | resource | Mana <= 20% | 12051 | Tavern | Low on threshold |

Ice Lance must not be a bare "usable" rule: its damage only pays off against frozen targets, and it has an 8-second cooldown shared with Fire Blast ([Warcraft Tavern Nov 2 coverage][t-nov2]). The Arcane Blast stack buff belongs on a tracker with its count, not in the list.

### Priest

Sources: [Tavern Shadow][t-shadow], [Tavern Discipline][t-disc], [Tavern Holy Priest][t-holyp], [MetaBot Priest][mb-priest]. Healer lists are a cooldown and proc strip, because ranking heals needs raid health the engine cannot see.

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Shadow | 1 | Shadow Word: Pain | M | Missing on target | 589 | Tavern | High |
| | 2 | Devouring Plague | M | Missing on target | 2944 | Tavern, MetaBot | High |
| | 3 | Vampiric Embrace | M | Spell usable | 15286 | Tavern, MetaBot | Medium (aura location unknown) |
| | 4 | Mind Blast | CD | Spell usable | 8092 | Tavern | High |
| | 5 | Shadow Word: Death | CD | Spell usable | 1309595 family | Tavern, SAR:315 | Medium (costs 30% of your health if the target lives) |
| Discipline | 1 | Power Word: Shield | C | Weakened Soul missing on friendly target | ID? | Tavern, MetaBot | Medium |
| | 2 | Renew | M | Missing on friendly target | ID? | Tavern | Medium |
| | 3 | Penance | CD | Spell usable | 402174 | Tavern, SAR:301 | High |
| | 4 | Inner Focus | CD | Spell usable | 14751 | Tavern | High |
| | 5 | Power Infusion | CD | Spell usable | 10060 | Tavern | High |
| Holy | 1 | Power Word: Shield | C | Weakened Soul missing on friendly target | ID? | Tavern | Medium |
| | 2 | Renew | M | Missing on friendly target | ID? | Tavern | Medium |
| | 3 | Prayer of Mending | CD | Spell usable | 401859 | Tavern, SAR:307 | High |
| | 4 | Inner Focus | CD | Spell usable | 14751 | Tavern | High |

No Priest mana cooldown with a threshold appears in any source, so there is no resource cue. Devouring Plague's cooldown equals its 24-second duration, so the debuff check and the cooldown never disagree on one target.

### Warrior

Sources: [wowtbc Arms][w-arms], [wowtbc Fury][w-fury], [wowtbc Protection][w-prot], [Tavern Arms][t-arms], [Tavern Fury][t-fury], local CC:636-695. Battle Shout and Rend keep their existing reminders.

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Arms | 1 | Overpower (dodge or Bloodthrill) | C | Spell usable | 7384 | wowtbc, SAR:511 | High |
| | 2 | Execute | C | Spell usable | 5308 | wowtbc | High |
| | 3 | Victory Rush | C | Spell usable | 402927 | Kami Labs, SAR:529 | High |
| | 4 | Mortal Strike | CD | Spell usable | 12294 | wowtbc | High |
| | 5 | Spearing Strike | CD | Spell usable | 1310222 | wowtbc, SAR:523 | High |
| | cue | Heroic Strike or Cleave | resource | Rage >= user value | 78 / 845 | wowtbc (no number) | Low on threshold |
| Fury | 1 | Execute | C | Spell usable | 5308 | Tavern | High |
| | 2 | Overpower | C | Spell usable (Battle Stance only) | 7384 | wowtbc | Medium |
| | 3 | Victory Rush | C | Spell usable | 402927 | SAR:529 | High |
| | 4 | Bloodthirst | CD | Spell usable | 23881 | wowtbc | High |
| | 5 | Whirlwind | CD | Spell usable | 1680 | wowtbc | High |
| | cue | Heroic Strike or Cleave | resource | Rage >= user value | 78 / 845 | wowtbc | Low on threshold |
| Protection | 1 | Revenge | C | Spell usable | 6572 | wowtbc | High |
| | 2 | Victory Rush | C | Spell usable | 402927 | SAR:529 | High |
| | 3 | Thunder Clap | M | Missing on target | 6343 | wowtbc, Kami Labs | Medium |
| | 4 | Demoralizing Shout | M | Missing on target | 1160 | wowtbc | Medium |
| | 5 | Shield Slam | CD | Spell usable | 23922 | wowtbc | High |
| | cue | Heroic Strike; Last Stand | resource | Rage >= user value; player health <= user value | 78; 12975 | wowtbc | Low on thresholds |

Slam (1240193, 1464 and ranks) now has a 15-second cooldown and Improved Slam makes it close to instant, so it can be a sixth, optional "usable" row for Arms ([Warcraft Tavern Nov 2 coverage][t-nov2], [Kami Labs][kami]). Reckless Swings (1329555), Death Wish (12328), Recklessness and Sweeping Strikes belong on a cooldown strip. Sunder Armor is omitted because its rule is a stack count. Sources disagree on where Execute sits relative to Mortal Strike; placing it in the condition tier is consistent with the engine's ordering and with the Fury list that puts it first.

### Rogue

Sources: [wowtbc Assassination][w-assa], [wowtbc Combat][w-combat], [wowtbc Subtlety][w-sub], [Tavern Rogue][t-rogue], [EZG][ezg]. Poisons are weapon enchants, not auras, and fall outside the aura checks.

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Assassination | 1 | Slice and Dice | M | Missing on player | 5171 | wowtbc | High |
| | 2 | Rupture (optional) | M | Missing on target | 1943 | CC:782-790 | Low (wowtbc omits it) |
| | 3 | Shank | CD | Spell usable | 1329283 (web link only) | wowtbc, EZG | Medium |
| | 4 | Cold Blood | CD | Spell usable | 14177 | wowtbc | Medium |
| | cue | Eviscerate | resource | Combo points >= 5 | ID? | wowtbc | Low (needs combo points as a power type) |
| Combat | 1 | Riposte | C | Spell usable | 14251 | Tavern | High |
| | 2 | Slice and Dice | M | Missing on player | 5171 | wowtbc | High |
| | 3 | Rupture | M | Missing on target | 1943 | wowtbc | Medium |
| | 4 | Shank | CD | Spell usable | 1329283 | wowtbc | Medium |
| | 5 | Blade Flurry | CD | Spell usable | 13877 | wowtbc | High |
| | cue | Eviscerate | resource | Combo points >= 5 | ID? | wowtbc | Low |
| Subtlety | 1 | Garrote (Stealth or Ghostly Strike window) | C | Spell usable | 703 | wowtbc, Tavern | Medium |
| | 2 | Slice and Dice | M | Missing on player | 5171 | wowtbc | High |
| | 3 | Rupture | M | Missing on target | 1943 | wowtbc | Medium |
| | 4 | Death Mark | CD | Spell usable | 1316709 | wowtbc, TT:360 | Medium |
| | 5 | Shank | CD | Spell usable | 1329283 | wowtbc | Medium |

Shank's launch form is 5 energy, a 10-second cooldown and a 15-energy refund, and with the Venom talent each Shank raises poison damage for 6 seconds ([EZG][ezg]). Once the Venom buff ID is known, "Venom missing on player" is a better Assassination rule than "Shank usable". Shank's ID 1329283 comes only from a guide link and sits above the highest ID in the local name scan, so it is unconfirmed locally; the two IDs SND lists under "Shank" (15248, 15617) look unrelated. Hemorrhage (16511) is Subtlety's builder and keeps its own debuff up, so it needs no row. Adrenaline Rush (13750), Premeditation (14183) and Ghostly Strike (14278) fit a cooldown strip.

### Hunter

Sources: [wowtbc Beast Mastery][w-bm], [wowtbc Marksmanship][w-mm], [wowtbc Survival][w-sv], [Tavern Hunter leveling][t-hunt-lvl], [Zockify Hunter][z-hunt], local CC:747-776.

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Beast Mastery | 1 | Hunter's Mark | M | Missing on target | 1130 | wowtbc | High |
| | 2 | Serpent Sting | M | Missing on target | 1978 family | wowtbc | High |
| | 3 | Summon Hawk | CD | Spell usable | 1293241 (ranks 1293525-1293527) | wowtbc, SAR:137 | Medium (hawk count lost) |
| | 4 | Bestial Wrath | CD | Spell usable | 19574 | wowtbc | High |
| | 5 | Rapid Fire | CD | Spell usable | 3045 | wowtbc | High |
| | cue | Mend Pet | resource | Pet health <= 40% | 136 | repo default | Low on threshold |
| Marksmanship | 1 | Mongoose Bite (melee range) | C | Spell usable | 1495 | repo, SAR:118 | Medium |
| | 2 | Hunter's Mark | M | Missing on target | 1130 | wowtbc | High |
| | 3 | Serpent Sting | M | Missing on target | 1978 | wowtbc | High |
| | 4 | Sniper Shot | CD | Spell usable | 1310687 family | wowtbc, SAR:135 | Medium |
| | 5 | Rapid Fire | CD | Spell usable | 3045 | wowtbc | High |
| Survival | 1 | Mongoose Bite (dodge or Expose Prey) | C | Spell usable | 1495 | wowtbc, TT:114 | High |
| | 2 | Counterattack (after parry) | C | Spell usable | 19306 | Zockify, SAR:86 | High |
| | 3 | Hunter's Mark (enables Expose Prey) | M | Missing on target | 1130 | wowtbc | High |
| | 4 | Serpent Sting | M | Missing on target | 1978 | wowtbc | High |
| | 5 | Strider Kick | CD | Spell usable | 1317257 | wowtbc, SAR:136 | High |
| | cue | Mend Pet | resource | Pet health <= 40% | 136 | repo default | Low on threshold |

Marksmanship with Lone Wolf has no pet, so Mend Pet should load only when a pet exists. Sources disagree on Sniper Shot's effect (range extension for three shots versus a 4-second cast on a 15-second cooldown), which does not change the "usable" rule ([Zockify Hunter][z-hunt]).

### Druid

Sources: [Tavern Balance][t-bal], [Tavern Feral][t-feral], [Tavern Restoration Druid][t-rdru], [RankedBoost][rb], local CC:996-1044. The Balance and Feral guides say not to clip DoTs, so those rules use "missing", not "expiring".

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Balance | 1 | Starfire on Clearcasting | C | Aura active | 16870 | Tavern, SND:615 | High |
| | 2 | Starfire on Eclipse charges | C | Aura active | talent 408248; aura one of 408255, 409813, 441260, 1286115 | RankedBoost, TT:18 | Medium |
| | 3 | Moonfire | M | Missing on target | 8921 | Tavern | High |
| | 4 | Insect Swarm | M | Missing on target | 5570 family | Tavern, SAR:36 | High |
| | 5 | Faerie Fire | M | Missing on target | 770 | Tavern | High |
| | cue | Innervate | resource | Mana <= 30% | 29166 | Tavern (no number) | Low on threshold |
| Feral (cat) | 1 | Shred on Clearcasting | C | Aura active | 16870 | general knowledge | Low |
| | 2 | Faerie Fire | M | Missing on target | 770 | Tavern | High |
| | 3 | Rake | M | Missing on target | 1822 | Tavern | High |
| | 4 | Rip | M | Missing on target | 1079 | Tavern | Medium (5-point condition lost) |
| | 5 | Shifting Power | CD | Spell usable | 1322605 | Tavern, TT:42 | Medium |
| Feral (bear) | 1 | Faerie Fire | M | Missing on target | 770 | Tavern | High |
| | 2 | Demoralizing Roar | M | Missing on target | ID? | Tavern | Medium |
| | 3 | Lacerate | M | Remaining <= 4 s on target | talent 1328617; ranks 414644, 1235826, 1235827 | Tavern, RankedBoost | Medium |
| | 4 | Primal Bite | CD | Spell usable | 407995 family | Tavern, SAR:46 | High |
| | cue | Frenzied Regeneration | resource | Player health <= user value | 22842 / 22845 | Tavern (no number) | Low on threshold |
| Restoration | 1 | Expensive heal on Clearcasting | C | Aura active | 16870 | Tavern | High |
| | 2 | Rejuvenation | M | Missing on friendly target | ID? | Tavern | Medium |
| | 3 | Swiftmend | CD | Spell usable | 18562 | Tavern | High |
| | 4 | Nature's Swiftness | CD | Spell usable | 17116 | Tavern, SAR:43 | High |
| | 5 | Wild Growth | CD | Spell usable | 408120 family | Tavern, SAR:67 | Medium (3 s cast since Nov 2) |
| | cue | Innervate | resource | Mana <= 30% | 29166 | Tavern | Low on threshold |

Eclipse on Forever is not the Wrath-era damage proc: one Wrath shortens the next two Starfires, banking up to four charges for 15 seconds ([RankedBoost][rb]). "Eclipse active means Starfire, otherwise Wrath" reproduces the guide's two-to-one pattern with one check. The guide calls Ferocious Bite not worth its energy, so it has no rule. The HUD has one Feral key for two forms; cat and bear rows should load on form.

### Shaman

Sources: [Tavern Enhancement][t-enh], [Tavern Elemental][t-ele], [Tavern Restoration Shaman][t-rsham], [RankedBoost][rb]. All three Tavern Shaman guides are level-30 beta builds, so every placement here is at most Medium. Weapon imbues and damage totems are not player auras and need the native weapon-enchant and totem triggers, or no rule.

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Elemental | 1 | Any spell on Clearcasting (Elemental Focus) | C | Aura active | ID? | Tavern | Medium |
| | 2 | Flame Shock | M | Missing on target | 8050 | Tavern | High |
| | 3 | Lightning Shield | M | Missing on player | 324 | Tavern | High |
| | 4 | Lightning Mastery | CD | Spell usable | 16166 | SB:1718, TT:380 | Medium (not placed by any guide) |
| | 5 | Lava Burst, only if known | CD | Spell usable, below Flame Shock | 408490 family | Tavern, SAR:390 | Low (removed per Nov 2 notes) |
| Enhancement | 1 | Lightning Bolt on Maelstrom Weapon | C | Aura active (stack count lost) | talent 408498; aura 408505 or 409946 | Tavern, SND:2319 | Medium |
| | 2 | Lightning Shield | M | Missing on player | 324 | Tavern | High |
| | 3 | Flame Shock | M | Remaining <= 2 s on target | 8050 | Tavern | Medium |
| | 4 | Stormstrike | CD | Spell usable | 17364 | Tavern, SAR:409 | High |
| | 5 | Rage of the Farseer | CD | Spell usable | 425336 | RankedBoost, SAR:401 | Medium (not placed by any guide) |
| Restoration | 1 | Water Shield | M | Missing on player | 408510 | Tavern, SAR:415 | High |
| | 2 | Riptide | CD | Spell usable | 408521 family | Tavern, SAR:403 | High |
| | 3 | Nature's Swiftness | CD | Spell usable | 16188 | Tavern, SAR:398 | High |
| | cue | Mana Tide Totem | resource | Mana <= 30% | 16190 | Tavern (no number) | Low on threshold |

Lava Burst is the sharpest conflict in the research. The beta guide builds Elemental around it, the September beta data lists it, and ForeverAuras uses it as its Elemental spec marker (SAR:390; SPEC:25), but the November 2 notes removed it and replaced it with Call of Thunder ([Warcraft Tavern Nov 2 coverage][t-nov2]). The rule should load only when the spell is known, which makes it disappear harmlessly if Blizzard's removal stands. The same notes cut Stormstrike to a 6-second cooldown, doubled Maelstrom Weapon's proc chance, and made Riptide a heal-over-time with a 12-second cooldown. Only one elemental shield can be active, so the Lightning Shield and Water Shield reminders must be exclusive per spec.

### Paladin

Sources: [Tavern Retribution][t-ret], [Tavern Protection Paladin][t-ppal], [Tavern Holy Paladin][t-hpal], [RankedBoost][rb], local CC:698-741. Blessings, auras and Righteous Fury go to the upkeep reminders.

| Spec | # | Suggestion | Class | Single check | ID | Source | Confidence |
|---|---|---|---|---|---|---|---|
| Retribution | 1 | Hammer of Wrath | C | Spell usable | 24275 | Tavern (talent note) | Medium (not in the priority list) |
| | 2 | Seal swap on Unsealed Wrath | C | Aura active (stack count lost) | talent 1310735; aura ID? | Tavern, TT:238 | Low as a suggestion; Medium as a tracker |
| | 3 | Seal of Command | M | Remaining <= 3 s on player | ID? | Tavern | Medium |
| | 4 | Judgement | CD | Spell usable | 20271 | Tavern, SAR:247 | High |
| | 5 | Holy Strike | CD | Spell usable | 679 family | Tavern, SAR:245 | High |
| Protection | 1 | Seal of Fury | M | Remaining <= 3 s on player | 1311649 family | Tavern, SAR:256 | Medium |
| | 2 | Holy Shield | M | Missing on player | 20925 | Tavern | High |
| | 3 | Judgement | CD | Spell usable | 20271 | Tavern | High |
| | 4 | Swift Judgement | CD | Spell usable | 1310994 | Tavern, SAR:264 | Medium |
| | 5 | Holy Strike | CD | Spell usable | 679 family | Tavern | High |
| | cue | Templar's Bulwark | resource | Player health <= user value | 1311015 | RankedBoost (no number) | Low on threshold |
| Holy | 1 | Holy Light on Infusion of Light | C | Aura active | talent 426065; aura ID? | Tavern, TT:194 | Medium |
| | 2 | Oath of Light on the tank | M | Missing on focus | 1328548 | Tavern, TT:195 | Medium (needs a focus-unit rule) |
| | 3 | Judgement of Wisdom on the boss | M | Missing on target | 20186 unverified | Tavern | Low |
| | 4 | Holy Shock | CD | Spell usable | 1311606 family | Tavern, SAR:244 | High |
| | 5 | Light's Vigil | CD | Spell usable | 1310911 family | Tavern, SAR:249 | Medium |

Consecration (26573) is baseline but described as heavily nerfed, and the local list reserves it for multiple enemies, so it moves to an optional sixth row for Retribution and Protection ([Tavern Paladin leveling][t-pal-lvl]; CC:731-741). Exorcism stays Undead-only and works as a "usable" rule if usability respects target type. Sacred Arbiter makes Holy Strike refresh Judgement debuffs, so a Judgement of the Crusader "missing on target" rule would fire only at the pull, which is the wanted behaviour ([Tavern Retribution][t-ret]). Sources conflict on Swift Judgement (unleashes the Seal on a separate cooldown per RankedBoost; resets Judgement's cooldown per the local tooltip at TT:212); "usable" is right under both readings.

## IDs that must be read in game, and the `/fhud dump` that collects them

The unknowns fall into four groups. **Proc and buff auras on the player** where only the talent ID and same-name candidates are known: Heating Up (400625 or 460878), Fingers of Frost (400669, 400670 or 401741), Missile Barrage (400589, 401736 or 467409), Maelstrom Weapon (408505 or 409946), Eclipse (408255, 409813, 441260 or 1286115), Decimation (talent 440870), Unsealed Wrath (talent 1310735), Infusion of Light (talent 426065), Venom (talent 1310703), the two Shadow and Flame buffs (talent 426316), the Arcane Blast stack buff, Elemental Focus Clearcasting, Shadow Trance (17941 unverified), and whether Bloodthrill and Expose Prey show an aura at all. **Debuffs on the target**: Demonic Brand (1293696 to 1293699), Improved Scorch (22959 unverified), Lacerate, the Stormstrike debuff, Death Mark, the Lacerating Strikes bleed, Judgement of the Crusader, Wisdom, Light and Fury, Weakened Soul, and where Vampiric Embrace sits. **Castable spells without a local ID**: Shank (1329283 from a guide link only), Seal of Command, Fire Blast, Ice Barrier, Renew, Rejuvenation, Demoralizing Roar, Eviscerate, plus the name of 1326079 (Arcane Wrath or Arcane Fury) and which Summon Hawk ID is the cast. **Existence questions**: Lava Burst, Earth Shield, Tiger's Fury, Berserk, Thousand Cuts, Surge of Light, Backlash, Avenging Wrath, Binding Heal versus Holy Binding, Lightwell, and any Fel Armor.

The proposed command writes one record per run into a new ForeverHUD saved variable (the addon's own file, created only when the user runs the command) and prints a one-line summary. It must run out of combat, because aura data is secret in combat (CDM:234-241). The API names below follow the retail 12.1.5 surface that Forever is documented to share and have not been tested on interface 16001.

| Subcommand | Records | Purpose |
|---|---|---|
| `/fhud dump` | Client build and interface (`GetBuildInfo`), locale, class, race, level, detected spec; then all sections below | One complete snapshot per character |
| `/fhud dump spells` | Every spellbook entry: spell ID, name, rank or subtext, passive flag, plus pet spells | Confirms castable IDs and existence questions |
| `/fhud dump talents` | Every talent node of the class tree: node position, definition spell ID, name, ranks taken and maximum | Replaces the Chinese third-party talent table and settles launch talent lists |
| `/fhud dump auras` | Auras on player, target, pet and focus: spell ID, name, stack count, duration, source unit, helpful or harmful | Resolves which candidate ID a proc or debuff really is |
| `/fhud dump watch` | Arms an automatic aura snapshot at the moment combat ends | Catches short procs (Heating Up 20 s, Maelstrom Weapon 30 s, Unsealed Wrath 15 s, Eclipse 15 s) that cannot be read during combat |
| `/fhud dump names <text>` | Scans the spell-name table for a name fragment and lists every matching ID | Regenerates the SND answer on build 70938, including IDs above 1325997 |
| `/fhud dump cdm` | Each Cooldown Manager category set with its entries, linked and override spell IDs | Shows which Forever spells the client places in Essential, Utility, Tracked Buffs and Tracked Bars per class, which no local file stores (CDM:362-436) |

The output should be plain data keyed by build and class so that `scripts/check.py` can fail the build when a rule references an ID that no dump has confirmed for that class. Nine dumps (one per class, ideally near level 60 with a deep talent build in each tree) close most of the list above; the short procs need a few fights with `watch` armed.

## A five-phase plan that fixes proven errors first

**Phase 0, collect.** Add `/fhud dump` with no behaviour change, document it in the bilingual README, and gather dumps for the classes the user plays first. Record the outputs as game evidence in the validation notes, separate from mock checks.

**Phase 1, correct what local data already proves.** These need no new in-game data. Change Shadowburn to a "usable" cooldown rule. Remove Backlash, Surge of Light, Avenging Wrath, Molten Armor and the Nightfall and Arcane Concentration per-rank IDs. Fix Druid Nature's Swiftness to 17116 and Water Shield to 408510, and rename Elemental Mastery to Lightning Mastery. Take Hammer of Wrath out of the Holy and Protection lists. Add the rules whose IDs are confirmed: Holy Strike, Spearing Strike, Shadow Word: Death, Amplify Curse, Summon Hawk, Sniper Shot, Strider Kick, Death Mark, Primal Bite, Shifting Power, Insect Swarm, Wild Growth, Swiftmend, Rage of the Farseer, Swift Judgement, Seal of Fury, Light's Vigil, Thunder Clap and Demoralizing Shout. Extend the stable sort to condition, then maintenance, then cooldown, and move forms and long buffs to upkeep. Raise the Affliction Life Tap threshold to 40%.

**Phase 2, rebind procs from the dumps.** Replace the three Mage proc IDs and Maelstrom Weapon with the dumped aura IDs or Cooldown Manager entries, rename Hot Streak to Heating Up everywhere including the locale tables, and add Demonic Brand, Decimation, Eclipse, Unsealed Wrath, Infusion of Light, Venom and Shank once their IDs are read. Until then those rules stay out of the build; a wrong ID is silent, which is worse than an absent rule.

**Phase 3, extend the engine.** Add the `expiring` kind, rule metadata (class, unit, source, confidence), a focus-unit rule for Oath of Light, form-scoped loading for Feral, and per-class options: Bane choice, optional Curse row, Shadow and Flame leveling toggle, resource thresholds. Determine whether the native aura trigger can test stack counts; if so, upgrade the stack rules, and if not, show stack numbers on tracker icons and keep those suggestions off by default.

**Phase 4, validate at level 60 and after tuning.** Re-read the guides after raids open on December 9, obtain the Icy Veins rotations by hand, and re-run the dumps on each new client build. Each runtime release updates the TOC, generator, package checks, workflow artifact name, README and changelog together, as the repository conventions require.

## Open questions and unverified items

The following are unresolved and should not be presented to users as settled.

- **Stack-count checks.** Whether one native ForeverAuras check can compare aura stacks is unknown. It decides how good the Maelstrom Weapon, Unsealed Wrath, Heating Up, Improved Scorch, Sunder Armor and Lacerate rules can be.
- **Combo points as a threshold.** Whether combo points are readable as a single power threshold in combat is unverified; the Eviscerate cue depends on it.
- **Spec detection may be stale.** ForeverAuras 1.3.9 detects spec from final-tier talents and still names Thousand Cuts for Subtlety, Berserk for Feral, Lava Burst for Elemental and "Twist of Light" for Retribution (SPEC:10-36), all of which the November 2 notes removed or renamed. If the HUD relies on that table, those four specs could fall back to the leveling list. The talent dump answers this; CurseForge lists a newer ForeverAuras 1.4.0 ([CurseForge ForeverAuras][fa-cf]).
- **Launch status of specific spells.** Lava Burst, Tiger's Fury, Berserk, Earth Shield, Binding Heal, Lightwell, Thousand Cuts, Cutthroat, Quietus and Hammer of the Righteous each appear in at least one source and are absent or removed in another.
- **Conflicting mechanics.** Wrack (double tick speed versus 10% more periodic damage), Venom (passive on Shank at launch versus a beta finisher), Swift Judgement, Combustion (three crits versus four), Fingers of Frost (one charge versus two), Sniper Shot, Victory Rush's 30-second cooldown (one source), and several percentages where a guide quotes max rank and the local tooltip quotes rank 1.
- **Unpublished numbers.** No Forever source gives durations for Immolate, Shadow Word: Pain, Moonfire, Insect Swarm, Rake, Rip, Flame Shock, Slice and Dice, Rupture, Sunder Armor, Hunter's Mark or Serpent Sting, nor cooldowns for Holy Strike at launch, Judgement, Mind Blast, Lava Burst, Primal Bite, Shifting Power or Swiftmend. Rules here avoid hard-coded durations for that reason; every "remaining <= N" value is a placeholder.
- **Unpublished thresholds.** No source gives a rage-dump threshold, a mana percentage for Innervate, Mana Tide, Evocation or Demonology and Destruction Life Tap, or a health percentage for defensive cues. All such values are design defaults and should be user-adjustable.
- **Level-60 validity.** The Shaman guides, the local priority table and several Warrior and Rogue guides were written for a level-30 beta. No AoE priority list exists for most specs. Nobody had level-60 raid data nine days after launch.
- **Usability semantics.** The lists assume "spell usable" reflects target requirements (Conflagrate needing Immolate, Exorcism needing Undead, Swiftmend needing a HoT, melee abilities needing range) and shard-free Soul Fire under Decimation. Each needs one in-game check.
- **Friendly-target rules.** Healer rows that test auras on a friendly target will misfire when the target is hostile; they need a load condition or a focus unit.
- **Unread sources.** Icy Veins rotation pages (HTTP 403), Mobalytics, the Wowhead Forever spell pages (URL pattern unconfirmed), forever.warcraftdb.com (lookup failed), hotfix threads after November 5, and the ForeverAuras changelog and trigger files were not read. Most web pages were read through an automated summariser, so quoted numbers should be re-checked against the Blizzard thread before they are encoded.
- **Two checkouts differ.** The suggestion lists audited here come from the ForeverHUD 0.13.8 checkout under WSL; the working tree at the OneDrive path has an older catalog without a `SUGGESTIONS` table. Confirm which is canonical before editing.

## Conclusion

The engine's constraint turns out to be less of a handicap than the data. Forever's reactive mechanics are mostly "a button becomes usable" windows (Overpower through Bloodthrill, Mongoose Bite through Expose Prey, Conflagrate through Immolate), and those map exactly onto a single native check. The rules that suffer are the handful of stacking procs Blizzard added, and even there the honest answer is a stack number on a tracker icon, not a suggestion that fires too early. A fixed-order list of independent checks suits this game well.

What does not suit it is authoring spell data from memory of other versions of WoW. Every wrong ID found came from that habit, and the client's own name table refuted each one in seconds. Treating Forever as a Blizzard product with its own spell table, a build number and a patch cadence implies a different workflow: dump from the client, generate the lists from verified data, stamp them with the build, and let the package check refuse any ID no dump has seen. With raids and a tuning pass due on December 9, the lists will need that loop again within a month.

[wiki-main]: https://warcraft.wiki.gg/wiki/Patch_1.60.1
[wiki-api]: https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes
[gi]: https://gameinformer.com/blizzcon-2026/2026/09/12/blizzard-announces-world-of-warcraft-forever-expanding-vanilla-wow-with
[bz-notes]: https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-development-notes-%E2%80%93-updated-october-15/2360696
[bz-nov2]: https://us.forums.blizzard.com/en/wow/t/2360696/9
[wh-spells]: https://www.wowhead.com/forever/spells
[fa-gh]: https://github.com/neroxrw/foreverauras
[fa-cf]: https://www.curseforge.com/wow/addons/foreverauras
[gg]: https://games.gg/world-of-warcraft/guides/wow-forever-every-class-new-ability-and-talent-change/
[t-nov2]: https://www.warcrafttavern.com/forever/news/wow-forever-pre-launch-class-changes-bug-fixes/
[t-classes]: https://www.warcrafttavern.com/forever/guides/classes/
[mb-lock]: https://metabot.gg/en/wow-forever/changes/warlock
[mb-mage]: https://metabot.gg/en/wow-forever/changes/mage
[mb-priest]: https://metabot.gg/en/wow-forever/changes/priest
[t-lock]: https://www.warcrafttavern.com/forever/guides/warlock/
[t-lock-lvl]: https://www.warcrafttavern.com/forever/guides/warlock-leveling/
[t-aff]: https://www.warcrafttavern.com/forever/guides/affliction-warlock/
[t-demo]: https://www.warcrafttavern.com/forever/guides/demonology-warlock/
[t-destro]: https://www.warcrafttavern.com/forever/guides/destruction-warlock/
[t-fire]: https://www.warcrafttavern.com/forever/guides/fire-mage/
[t-arc]: https://www.warcrafttavern.com/forever/guides/arcane-mage/
[t-frost]: https://www.warcrafttavern.com/forever/guides/frost-mage/
[t-shadow]: https://www.warcrafttavern.com/forever/guides/shadow-priest/
[t-disc]: https://www.warcrafttavern.com/forever/guides/discipline-priest/
[t-holyp]: https://www.warcrafttavern.com/forever/guides/holy-priest/
[t-arms]: https://www.warcrafttavern.com/forever/guides/arms-warrior/
[t-fury]: https://www.warcrafttavern.com/forever/guides/fury-warrior/
[t-rogue]: https://www.warcrafttavern.com/forever/guides/rogue/
[t-hunt-lvl]: https://www.warcrafttavern.com/forever/guides/hunter-leveling/
[t-bal]: https://www.warcrafttavern.com/forever/guides/balance-druid/
[t-feral]: https://www.warcrafttavern.com/forever/guides/feral-druid/
[t-rdru]: https://www.warcrafttavern.com/forever/guides/restoration-druid/
[t-enh]: https://www.warcrafttavern.com/forever/guides/enhancement-shaman/
[t-ele]: https://www.warcrafttavern.com/forever/guides/elemental-shaman/
[t-rsham]: https://www.warcrafttavern.com/forever/guides/restoration-shaman/
[t-ret]: https://www.warcrafttavern.com/forever/guides/retribution-paladin/
[t-ppal]: https://www.warcrafttavern.com/forever/guides/protection-paladin/
[t-hpal]: https://www.warcrafttavern.com/forever/guides/holy-paladin/
[t-pal-lvl]: https://www.warcrafttavern.com/forever/guides/paladin-leveling/
[w-arms]: https://wowtbc.gg/warcraftforever/class-guides/arms-warrior/
[w-fury]: https://wowtbc.gg/warcraftforever/class-guides/fury-warrior/
[w-prot]: https://wowtbc.gg/warcraftforever/class-guides/protection-warrior/
[w-assa]: https://wowtbc.gg/warcraftforever/class-guides/assassination-rogue/
[w-combat]: https://wowtbc.gg/warcraftforever/class-guides/combat-rogue/
[w-sub]: https://wowtbc.gg/warcraftforever/class-guides/subtlety-rogue/
[w-bm]: https://wowtbc.gg/warcraftforever/class-guides/beast-mastery-hunter/
[w-mm]: https://wowtbc.gg/warcraftforever/class-guides/marksmanship-hunter/
[w-sv]: https://wowtbc.gg/warcraftforever/class-guides/survival-hunter/
[z-hunt]: https://www.zockify.com/forever/hunter/
[kami]: https://kami-labs.fr/en/wow-forever/guerrier-wow-forever-sorts-et-talents-modifies/
[ezg]: https://www.ezg.com/blog/wow-forever-rogue-changes-before-launch
[rb]: https://rankedboost.com/world-of-warcraft/forever/whats-new/talents/

Local file aliases used in citations (alias:line): SND = `F:\World of Warcraft\_forever_\Interface\AddOns\ForeverAuras\SpellNameData.lua`; SAR = `...\ForeverAuras\SecretAuraRanks.lua`; SPEC = `...\ForeverAuras\PlayerSpecialization.lua`; CDM = `...\ForeverAuras\CooldownViewerCatalog.lua`; TT = `...\DungeonsForeverClass\Core\Data\Data_TalentTrees.lua`; CC = `...\DungeonsForeverClass\Core\Data\enUS\Data_ClassCombat.lua`; CG = `...\DungeonsForeverClass\Core\Data\enUS\Data_ClassGuide.lua`; SB = `...\DungeonsForeverSpell\Core\Data\enUS\Data_SpellBook.lua`; FU = `...\ForeverUtilities\StandardClasses.lua`.
