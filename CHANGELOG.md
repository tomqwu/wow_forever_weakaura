# Changelog

## 0.14.17 — 2026-11-20 (prerelease)

User: "didn't I tell you to make it a bit shorter? Maybe 20%", then chose "Seal above the rail".

- **Globes 20% closer.** The globes sit at x=±240 instead of ±285: 360 px of rail between the rings instead of 450. The rail, shade, class frames, pet globe, Soul Shards text and upkeep row follow.
- **Seal above the rail.** In the Globes style the companion lifts the in-combat class seal to y=76, just over the rail spells, and moves both cooldown wings 48 px towards the centre, so four 40 px spells per side still end at the liquid edge. The folded seal stays on the rail. The Bars style is unchanged.
- Update your class and Core in `/fa`, choosing **Update Auras**.

## 0.14.16 — 2026-11-19 (prerelease)

User: in-game screenshot of the folded HUD with an empty pet bar reading "Pet … inf" and no pet out.

- **Pet health only with a pet.** The pet health bar (Bars style) and the pet globe (Globes style) each get one more native trigger, Conditions "Has Pet", before the module gate, so neither shows while the pet is dismissed, dead or sacrificed. The module gate stays the last trigger.
- Update your class in `/fa`, choosing **Update Auras**. (The screenshot was from 0.14.12 auras; 0.14.13 replaced that bar with the pet globe.)

## 0.14.15 — 2026-11-19 (prerelease)

User: "can width a bit shorter between both globe?"

- **Globes closer together.** Centred at x=+-285 instead of +-305, and 120 px (110 px liquid) instead of 130 (120): 450 px between the rings instead of 480. The class frames are 166 px (from 180), the rail 472x118, the shade 560x230, and the pet globe, upkeep row (y=99) and Soul Shards line (y=-93) follow. A fourth spell per side now reaches the liquid edge (x=233 against 230).
- Update your class and **ForeverHUD | Core** in `/fa`, choosing **Update Auras**.

## 0.14.14 — 2026-11-19 (prerelease)

User: "can you have class related texture around globe?", then "All nine classes".

- **Class globe frames.** Each class has a painted ornament (`globe-ornament-<class>`) behind both globes in the Globes style, 180 px across: its open centre hides under the liquid and about 25 px of class art shows round each ring. The resource side is the same art mirrored. Warlock: shadowflame, horns and chains. Warrior: crossed swords, riveted steel and an axe. Mage: silver filigree, runes and frost. Priest: marble, gold, wings and a sunburst. Rogue: leather, daggers and rope. Druid: oak, leaves, antlers and acorns. Hunter: longbow, arrows and feathers. Shaman: carved stone, lightning, beads and feathers. Paladin: gilded wings, plate and a hammer.
- They load with the class's Globes art (`FOREVERHUD_<CLASS>_globeArt`), draw after the rail and before the seal, and slide with the globes when the HUD unfolds.
- The upkeep row (now at y=106) and the Soul Shards line (y=-100) sit just outside the frame.
- Art: generated with Figma's image generator on flat green (Druid on magenta, because of its green leaves) and keyed with `scripts/chroma.py` (new `--magenta` mode); prompts and raw downloads are in `assets/ai/`.
- The textures are new files: **fully restart the game** once, then update your class in `/fa`, choosing **Update Auras**.

## 0.14.13 — 2026-11-19 (prerelease)

User, with an in-game screenshot of the shorter 0.14.12 bar: "pet bar is invisiable to me, too small, maybe a smaller globe under big globe? left bottom corner?"

- **Pet globe.** In the Globes style the pet's health is a small globe (60 px ring, 55 px liquid) against the lower left of the Health globe, centred at (-365, -60), with the pet's health percentage inside. It is the same native vertical fill, liquid, shine and slim ring as the big globes, in the pet health colour, and keeps the display ID of the 0.14.6 short pet bar it replaces.
- The big globes now share one `globe()` recipe in `scripts/build.py`; their data is unchanged.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.14.12 — 2026-11-19 (prerelease)

User, with an in-combat screenshot showing Howl of Terror alone on the bar: "why howl of horror still there!!!!" (asked before at 0.14.3).

- **Howl of Terror left out.** The game's Cooldown Manager files Howl of Terror under Utility, so it showed in the Utility wing (in combat since 0.14.4) and, in the Globes style, alone on the skill bar. Both ranks (5484, 17928) join Shadow Ward in `S.SKIP_UTILITY`, so neither the Utility wing nor the Utility row shows it; the next Utility entry takes its slot.
- The change is in the companion. The auras only carry the new version number, but update your class and **ForeverHUD | Core** in `/fa` so the update cue clears.

## 0.14.11 — 2026-11-19 (prerelease)

User: in-game screenshot of 0.14.10 (round globes, both values, Soul Shards under the mana globe), "it's too long".

- **Shorter bar.** The globes are 130 px (liquid 120 px) instead of 150 (138), centred at x=+-305 instead of +-400: about 22% narrower overall. Four 40 px spells per side (to x=+-233) still end inside each liquid edge (+-245). The rail is 512x128 and the shade 600x230.
- **Upkeep reminders above the resource globe.** Their row (x=286 in the data, beside the resource bar) would now sit on the globe, so in the Globes style the companion moves it to (305, 89), above the globe. It holds native aura buttons, so it is moved only out of combat; Bars puts it back.
- Soul Shards follows the globe to (305, -77). Bars style is unchanged.
- Update your class and **ForeverHUD | Core** in `/fa`, choosing **Update Auras**.

## 0.14.10 — 2026-11-19 (prerelease)

User: in-game screenshot of 0.14.9 (square liquid, upkeep icon on the mana globe), "lmao", then "just make it like latest diablo".

- **Action-RPG layout in the Globes style.** The globes sit at the ends of one skill bar: the companion lowers both cooldown wings from y=80 onto the rail at y=0 (`S.ApplyLayout`, the same runtime offset it already used to lift the left wing), so up to eight spells sit in one row between the globes. Target effects, buffs and suggestions stay above the bar. Original art; no assets or layout copied from any game.
- **Room for everything.** The globes moved from x=+-312 to +-400 and down to the bar (y=0), the rail is longer, and the shade covers the bar and the rows above. The upkeep reminder row (from x=286) now sits between the bar and the resource globe instead of on it, and the Soul Shards line moves under the resource globe, like the pet bar under the Health globe.
- **Round liquid.** ForeverAuras scales progress-texture coordinates by sqrt(2) and divides by 1 + crop, so its default crop 0.41 shows the whole texture. The globes used 1, which showed only the middle 71% of the liquid: a square of swirl with no round edge. They now use 0.41.
- Bars style is unchanged. Update your class and **ForeverHUD | Core** in `/fa`, choosing **Update Auras**.

## 0.14.9 — 2026-11-19 (prerelease)

User: in-game screenshot of the 0.14.6 globes, "can you redesign it? looks ugly", then chose "Slim dark rail".

- **Slimmer Globes style.** A slim blackened-iron ring replaces the heavy ornate ring, so the liquid grows from 100 to 138 px inside the same 150 px ring. A thin iron rail with a central boss replaces the wide band behind the seal; its ends tuck under the rings, and the Soul Shards line no longer sits on the art.
- **Liquid depth.** The liquid darkens toward the rim so the fill reads as a sphere.
- **Easier to read** (user: "no color theme, all stacking together hard to see with background"). A soft dark shade (`globe-shade`, an SVG accent) sits behind the icons between the globes. Stacked icon rows now have 8 px gaps instead of 4 in both styles: the suggestion row sits 4 px higher and the lifted left cooldown wing 8 px higher (`S.WING_LIFT` 42).
- The shade is a new texture file: **fully restart the game** once.
- **Values back on the globes.** In game the 0.14.6 globes showed only the Health percentage and the resource name: a text holding a lone `%p` stayed blank on the globe, while the Health bar's combined `%percenthealth%%  %p` text shows both values. Each globe now has one combined two-line text: Health shows percentage over value, the resource globe value over type.
- Art: ring and rail generated with Figma's image generator; the ring keyed from green with `scripts/chroma.py`, the rail (returned with real alpha and a soft haze) cleaned with the new `scripts/chroma.py --dehaze`. Prompts and raw downloads are in `assets/ai/`. The exported file names (`globe-frame`, `globe-band`) are unchanged.
- Update your class and **ForeverHUD | Core** in `/fa`, choosing **Update Auras**.

## 0.14.8 — 2026-11-19 (prerelease)

User: "I am missing this buff, why I don't see it from notification" (Demonic Sacrifice tooltip).

- **Demonic Sacrifice reminder.** Once Demonic Sacrifice (18788) is learned, a breathing reminder shows in the upkeep row and the folded tray while none of its four buffs (18789, 18790, 18791, 18792, linked to 18788 by the client's own Cooldown Manager entry) is up. Missing only: the buff lasts two hours and ends when a demon is summoned.
- **Pet missing stays quiet after a sacrifice.** The Warlock "pet missing" reminder has one more native trigger, "no sacrifice buff", so sacrificing the demon is not reported as a missing pet.
- Update Warlock in `/fa`, choosing **Update Auras**.

## 0.14.7 — 2026-11-19 (prerelease)

User: screenshot of `/fa` stuck at "Importing...." while updating ForeverHUD | Warlock to 0.14.6.

- **Fixed: class imports stopped part way.** The Globes style's danger ring took its alpha from a condition on the protected health percentage and also pulsed. When ForeverAuras cancels an alpha animation with `/fa` open, `SetAnimAlpha` calls `max()` on the region's alpha (`RegionPrototype.lua:885`), which is a secret value there, so the import coroutine errored and the progress bar stayed put. The ring is now steady: it appears at 30% health or less without pulsing.
- If an earlier update stopped part way, ForeverHUD reports the stray displays in chat. In `/fa`, delete every top-level "ForeverHUD | <class>" entry, then type `/fhud install`.

## 0.14.6 — 2026-11-19 (prerelease)

User: "design a 2nd style of frame like diablo, with globe types , make sure redesign spell/icon/recommendation/buff/cdm integration too on left and right", then "Build this layout"

- **Globes frame style.** Health fills a round globe on the left and your resource (mana, rage or energy, coloured by the client's power type) one on the right, either side of a painted band that holds the class seal. Each globe has its value; Health also shows its percentage. Suggestions, target and player aura rows, and the Essential and Utility cooldown wings stay between the globes, inside their rings.
- The fills are ForeverAuras' native vertical progress textures, driven by the same Health and Power triggers as the bars, including restricted values. At 30% health or less a red danger ring pulses around the Health globe (one native condition).
- Pets: a short pet health bar sits under the Health globe. Soul Shards, combo points and swing bars keep their places.
- Choose it in `/fhud` → **Display → Frame style**, or `/fhud style globes` / `/fhud style bars`. Per class; Bars stays the default. The bars, bar chassis and shelves unload in the Globes style, and the globes unload in the Bars style.
- Art: ring, band and liquid generated with Figma's image generator on a flat green background and keyed into alpha with the new `scripts/chroma.py`; prompts and raw downloads are in `assets/ai/`. The glass shine and danger ring are small SVG accents.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.14.5 — 2026-11-19 (prerelease)

User: "integration with titan panel"

- **Titan Panel launcher.** New `Broker.lua` registers a LibDataBroker-1.1 launcher named ForeverHUD with your class crest. Titan Panel bundles LibDataBroker and lists it; other Broker displays (ChocolateBar, Bazooka) do too.
- Left-click opens settings; right-click expands or folds the HUD, as on the minimap button. Titan may show its own plugin menu on right-click instead.
- ForeverHUD ships no library: without a Broker display loaded, nothing is created.
- Companion only: copy the addon and `/reload`; no aura update needed.

## 0.14.4 — 2026-11-19 (prerelease)

User, with a screenshot of Howl of Terror above the seal out of combat: "why howl of error shows here in non combat?", then "Wing combat-only"

- **Utility wing in combat only.** Since 0.13.16 the right-hand Utility wing (Cooldown Manager Utility entries 1 to 4) and its overflow row are always shown. A newly learned Howl of Terror went to the top of the Utility list, so it sat above the seal out of combat. Those displays now carry ForeverAuras' native **In Combat** load, so they appear when combat starts and leave when it ends.
- The damage wing over Health and the item row are unchanged (cooldown-only, in or out of combat). Your Cooldown Manager settings are not changed.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.14.3 — 2026-11-19 (prerelease)

User: "shard warning when it's lower than 10"

- **Low Soul Shard warning (Warlock).** With fewer than 10 Soul Shards in your bags, the HUD shard count turns red and the tray shard icon glows red. Both return to normal at 10 or more.
- Each is one native condition on the existing Item Count trigger (`stacks < 10`); bank shards are not counted.
- Includes the unreleased 0.14.2 low-health flash.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.14.2 — 2026-11-18 (prerelease)

User: "when 30% below health, you should flash"

- **Low-health flash.** At 30% health or less, a red Pixel glow races around the Core Health bar, and it stops once you are above 30%.
- It is one native condition on the bar's own health trigger (`percenthealth <= 30` turns the glow on), so the protected percentage is never read in Lua.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.14.1 — 2026-11-18 (prerelease)

User: "can you make the addon config UI a better better? layout/categories/icon?"

- **Redesigned settings window.** A header shows the class crest, the class and the version. A sidebar lists six categories with native icons:
  - **General:** enable, lock, language, aura status, install and the aura editor.
  - **Display:** HUD modules.
  - **Reminders:** reminders and alert sounds.
  - **Combat:** behavior, talent school, cooldown layout, cast bar and swing mode.
  - **Layout:** size, opacity, position, reset and inspection.
  - **Minimap:** the minimap button and tray.
- Each page has a title, a one-line description and grouped controls with headings. **Reset this class** stays in the footer.
- Preference keys and control names are unchanged, so saved settings carry over.
- The auras carry the new version: update your class in `/fa`, choosing **Update Auras**.

## 0.14.0 — 2026-11-18 (prerelease)

User: "add addon manager to include all addon into a box around map, it's too crowded, similarly to what I've done in classmate addon"

- **Minimap button tray.** ForeverHUD now has a minimap button with the class crest. Hovering it opens a framed tray of the other addons' minimap buttons, in name order, after a ForeverHUD settings cell. Left-click opens settings, right-click expands or folds the HUD, and dragging moves it around the map.
- Only named, unprotected addon launchers (LibDBIcon, ForeverCore and similar) are collected. Blizzard controls, map pins and protected frames are never touched, and nothing moves in combat. Turning grouping off or hiding the button returns every button to its spot, strata and dragging.
- **Settings:** **Position → Minimap button** and **Group addon minimap buttons**, or `/fhud minimap on|off` and `/fhud buttons on|off`. They are account-wide.
- With Forever Classmate loaded, its own tray does the grouping and the ForeverHUD button joins it.
- The auras' content is unchanged, but they carry the new version: update your class in `/fa`, choosing **Update Auras**.

## 0.13.24 — 2026-11-16 (prerelease)

User: "is Soul Link part of the notification too if missing?"; "Yes, add it"

- **Soul Link reminder.** A breathing Soul Link reminder shows in the upkeep row and the folded tray while the buff is missing, like Demon Armor. It is a native Show On Missing aura trigger on 19028 and 25228, the two IDs named Soul Link in `SpellNameData.lua`. It loads only once the talent puts Soul Link in your spellbook. It has no duration, so there is no "expiring" reminder.
- With no pet out, the pet reminder shows too; a reminder tests one thing, so it cannot also test for the pet.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.13.23 — 2026-11-16 (prerelease)

User, after a list of spells the research report found missing: "Yes, add them"

- **Fuller spell lists.** From the research report (`reports/WoW Forever rotation engine research.md`), each spec gains the single-check rules it was missing. Each is an Action Usable or Show On Missing rule, loaded only once the spell is learned:
  - Warlock: Amplify Curse (Affliction); Bane of Agony and Corruption (Destruction).
  - Mage: Arcane Power; Combustion.
  - Priest: Inner Focus and Power Infusion (Discipline); Inner Focus (Holy).
  - Rogue: Cold Blood; Blade Flurry; Death Mark.
  - Druid: Insect Swarm (Balance); Shifting Power (Feral); Swiftmend, Nature's Swiftness and Wild Growth (Restoration).
  - Hunter: Bestial Wrath and Rapid Fire (Beast Mastery); Sniper Shot and Rapid Fire (Marksmanship); Strider Kick (Survival). The three Hunter lists now differ.
  - Shaman: Rage of the Farseer (Enhancement); Nature's Swiftness (Restoration).
  - Paladin: Light's Vigil (Holy); Swift Judgement and Holy Strike (Protection); Holy Strike (Retribution).
  - Warrior: Spearing Strike (Arms); Thunder Clap and Demoralizing Shout missing on the target (Protection).
- **Five slots per list.** Protection Warriors no longer get Overpower or Execute, and Searing Pain for Demonic Brand (0.13.22) stays with Demonology only.
- **Left out on purpose:** Shadow Word: Death, because the Shadow list is full. Lightning Mastery, because its research ID is another spell. Arcane Wrath, because its ID is past the client's known range. Summon Hawk, because it over-suggests. Procs whose aura IDs need a class dump.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.13.22 — 2026-11-16 (prerelease)

User: "let's say Demonic brand is not up, and I have this spec, you shoudl recommend this spell (searing pain?)"

- **Searing Pain for Demonic Brand.** A new Warlock suggestion shows Searing Pain when your Demonic Brand debuff (1293696, from the first `/fhud dump`) is missing on your hostile target. It is one native check (Show On Missing, cast by you), loads only once the Demonic Brand talent (1293695) and Searing Pain are learned, and sits ahead of the DoTs in all three Warlock specs.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.13.21 — 2026-11-15 (prerelease)

User, with a screenshot of the Health Funnel cue over the Pet bar: "seems like recommendation for pet healing is too close and overlapping with frame?"

- **Threshold cues clear their bar.** The 22 px cue wears a painted frame 8 px past the icon, so at (-218, -28) it covered the Pet bar's outer end and the "Pet" label. The pet cue now sits at (-246, -36), the frame's box just past the bar's outer end and below its row; the mana cue moves to (246, -36) to match. Applies to every class with a threshold cue (Warlock, Mage, Druid, Hunter, Shaman).
- Update your class in `/fa`, choosing **Update Auras**.

## 0.13.20 — 2026-11-15 (prerelease)

User, with a screenshot of a buff icon showing 0 in the middle and 2 in the corner: "middle number should be the count down of the hit number, not count down of the remaining time, both number should be swapped?", then "disappearing effect when hit count is 0 should be a bit more visible, maybe like explosive effect and enlarge it, to let player know you need to renew this".

- **Charges in the middle.** On the player's buff row (the Cooldown Manager row and the class buff row), the centre text is now the stack or charge count (`%s`) and the corner text the remaining time (`%p`). Other icons keep the time in the centre.
- **A burst when a buff ends.** The native finish animation on the Cooldown Manager buff row now also scales: the icon throbs to 1.3x on each of its two dips, then grows to 2.4x as it fades, over 1.1 s (was 0.9 s, fade only). A row that is closing (fold, HUD off) still just disappears.
- Update the Core in `/fa`, choosing **Update Auras**.

## 0.13.19 — 2026-11-14 (prerelease)

User: "can we do a perference analysis and see our addon slows GUI down", then "Fix and add /fhud perf". The analysis read the code; nothing was measured in game.

- **Fewer spell rechecks.** Spell discovery rescanned the spellbook and Cooldown Manager, re-resolved the class catalog and re-applied every load flag on `SPELL_TEXT_UPDATE`, `GET_ITEM_INFO_RECEIVED` and `UNIT_INVENTORY_CHANGED`, which fire constantly while looting, trading, opening bags and changing buffs, and on every `SPELL_DATA_LOAD_RESULT`, including other addons' requests. Those three events are dropped (equipment stays on `PLAYER_EQUIPMENT_CHANGED`), and spell data results count only for spells discovery asked for. A refresh now waits until its events have been quiet for 0.5 s (at most 2 s after the first request), where it used to run every 0.1 s during a stream.
- **Fewer HUD updates.** A unit-flag, faction or target event that leaves the HUD's state unchanged no longer re-runs the full update (load flags, alerts, effects and the gate trigger of every loaded display). Settings, preview and loading changes still update.
- **`/fhud perf`.** Prints ForeverHUD's and ForeverAuras' recent, average and worst-frame CPU time from the client's add-on profiler (`C_AddOnProfiler`), and since the last report: spell rechecks, HUD updates, skipped updates and the events behind the rechecks. Counters are integer increments; nothing is polled.
- Companion only: copy the addon and `/reload`; no aura update needed.

## 0.13.18 — 2026-11-14 (prerelease)

User, showing the game's Firestone art beside the reminder: "this should be firestone icon?"

- **Reminder icons come from the spell.** The weapon and pet reminders used fixed icon paths from older WoW (the Firestone one showed a black tar pot, not this client's Firestone art). A reminder tied to a learned spell now takes that spell's own icon from a native, always-active spell trigger (trigger 2; the gate stays last): Create Firestone, Rockbiter Weapon, Poisons, Summon Imp, Call Pet. The generic oil/stone reminder keeps its path.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.13.17 — 2026-11-14 (prerelease)

User, about Shadow Ward sitting in the always-shown Utility wing: "why shadow ward to be here? what's the playing logic here", then "yes hide it, it's very dumb".

- **Shadow Ward leaves the Utility wing.** It only absorbs shadow damage and is cast when a shadow caster appears, so it is not a cooldown to watch. The game's Cooldown Manager files it under Utility; ForeverHUD now skips it (all ranks: 6229, 11739, 11740, 28610) in the Utility wing and its overflow row, and the next Utility entry takes the slot. The player's Cooldown Manager settings are not changed.
- Companion only: copy the addon and `/reload`; no aura update needed.

## 0.13.16 — 2026-11-14 (prerelease)

User: "Shooting a wand should never spin up a buff icon", then "Always show the wing".

- **Utility cooldowns are always shown.** In the Forever layout, the right-hand cooldown wing (Cooldown Manager Utility entries 1 to 4) and its overflow row showed an entry only while on cooldown. A wand Shoot puts spells on a shared lockout that ForeverAuras reports as on cooldown (its `WandCooldown.lua` keeps only the ready look; its spell trigger's wand detection only suppresses the ready alert), so Shadow Ward appeared on every shot. Those Utility entries now use Show: Always; a real cooldown still shows its countdown, and the wand hold keeps them looking ready. The damage wing over Health and the item row stay cooldown-only.
- Companion only: copy the addon and `/reload`; no aura update needed.

## 0.13.15 — 2026-11-14 (prerelease)

User, with a tooltip of Demonic Brand on the target ("Magic: the caster's pet deals an additional 35 to 38 damage with its next 2 attacks"): "why you taking off the brand buff from CDM?"

- **Demonic Brand is back in the right-hand row.** 0.13.14 left out every target debuff from the Cooldown Manager tracked list, Demonic Brand included. It powers up the Warlock's pet, so it is watched like a buff: entries carrying Demonic Brand (1293695, debuff 1293696) are kept (`S.KEEP_TARGET`). Curses, Fear and Banish stay out.
- Companion only: copy the addon and `/reload`; no aura update needed.

## 0.13.14 — 2026-11-14 (prerelease)

User: "why throwing wand giving this buff? on the right? bug", then "Only my buffs".

- **Only your buffs on the right.** In the Forever layout, the companion picks which Cooldown Manager tracked entries the right-hand buff row shows. The tracked list also holds debuffs the player puts on the target; ForeverAuras' class-pack setup moves every tracked aura there. An entry with any harmful spell among its IDs (spell, override, linked), by the game's spell data (`C_Spell.IsSpellHarmful`, the rule ForeverAuras uses for a CDM aura's unit), now stays out. The first `/fhud dump` showed Demonic Brand (linked 1293696), Curses, Fear and Banish in that list. DoTs stay in the left-hand target row as before.
- Companion only: copy the addon and `/reload`; no aura update needed.

## 0.13.13 — 2026-11-14 (prerelease)

User: "you are no longer alerting food status?", then "Yes, opt-in" to a Well Fed missing reminder.

- **Well Fed reminder** (module `fedMissing`, every class, off by default). The native aura trigger by name (`Well Fed`, every ID with that name, any caster) with Show On Missing, in the expanded upkeep row and the folded tray, breathing like the upkeep reminders. The Food, Drink and Well Fed icons shown while those buffs are up are unchanged since 0.8.0.
- The settings' module rows are a little tighter to fit the extra checkbox.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.13.12 — 2026-11-14 (prerelease)

User: "pet missing notification too?"

- **Pet reminder** (module `petMissing`, Warlock and Hunter). ForeverAuras' native Conditions trigger with Has Pet = false (no pet, or a dead one) and Mounted = false, in the expanded upkeep row and the folded tray, with the same breath and glow as the other reminders. Shown once Summon Imp (688) or Call Pet (883) is learned. On by default for both classes; the checkbox appears only for them. A Destruction Warlock who sacrifices the demon can turn it off.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.13.11 — 2026-11-14 (prerelease)

User: "when CDm on the right side goes out, it can flash then fade out, such as Demonic Brand etc."

- **Buffs flash as they end.** The Cooldown Manager buff icons on the right (`Core | Native player effects | Entries`) have a native Finish animation: two quick dips to 20%, then a fade to nothing, 0.9 s in all. ForeverAuras plays it whenever the icon hides; the curve checks the row's own gate first, so a fold, combat-only mode or turning the HUD off still hides the row at once. The class-plan buff icons are native aura buttons, which have no finish animation, and the tracked bars and cooldowns are unchanged.
- **Fix (0.13.10):** the weapon enchant reminders used ForeverAuras' Pulse *preset*, which replaces the given 2.4 s with its own 0.5 s flash. They now use a custom Main animation, 100% to 40% and back over 2.4 s, like the missing-buff breath.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.13.10 — 2026-11-14 (prerelease)

User: "such as firestone enchant should be notified if it's not applied, similarly to oil, but optional configurable", with a tooltip showing Minor Wizard Oil and Firestone on one weapon; and "I still don't see addon on the map slider".

- **Weapon enchant reminders.** ForeverAuras' native Weapon Enchant trigger with Show On: Enchant Missing, in the expanded upkeep row and the folded tray, breathing like a missing buff (Main animation Pulse 2.4 s and the gold glow). The trigger tells an imbue from a temporary enchant on the same hand, so there are two reminders:
  - **Weapon imbue** (module `imbue`): Warlock Firestone or Spellstone (shown once Create Firestone is learned), Shaman weapon imbue (once Rockbiter Weapon is learned). On by default for both classes; the checkbox shows only for them.
  - **Oil, stone or poison** (module `oil`): every class, main hand; Rogues get main- and off-hand poison reminders once Poisons is learned. On by default for Rogues only.
  - Each class keeps its own choice. Profiles from earlier versions get the class default.
  - Every class now has the upkeep row, which holds these reminders.
- **Minimap addon list.** The TOC registers `AddonCompartmentFunc` (with OnEnter/OnLeave), as other Forever addons do: left-click toggles the settings, right-click expands or folds the HUD.
- The module list in the settings uses slightly tighter rows to fit the two new checkboxes.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.13.9 — 2026-11-13 (prerelease)

Follows the research in `reports/WoW Forever rotation engine research.md` (user: "do a full research on forever ... and come up with a recommendation engine"; "Yes, build it"). World of Warcraft: Forever is a Blizzard game (client `wowf` 1.60.1), not a private server, and its spell IDs differ from the Wrath-era ones these lists were first written with.

- **Spell IDs from the client.** Checked against ForeverAuras' `SpellNameData.lua`, a scan of the client's spell names (build 70374):
  - Mage: Hot Streak 44445 becomes **Heating Up** (400624, 400625, 460878); Fingers of Frost and Missile Barrage use their Forever IDs. A proc lists every ID that shares its name, because no file records which one is the aura on the player.
  - Shaman: Maelstrom Weapon (408498, 408505, 409946); Water Shield 408510 in the shield reminder.
  - Priest and Paladin: Surge of Light and Avenging Wrath use the IDs that carry those names. Surge of Light leaves the Discipline and Holy suggestions (no talent node on Forever).
  - Druid: Nature's Swiftness is 17116 (16188 is the Shaman spell).
  - Removed: Molten Armor 30482 from the Mage armor reminder; Nightfall rank ID 18095 and Arcane Concentration rank IDs 12574 to 12577 (one spell per talent on this client).
- **Rule types.** Shadowburn is a cooldown nuke on Forever, so it is suggested when usable, in the row, not as a target-health execute. Backlash leaves the Destruction list (in no Forever spell list). Hammer of Wrath is suggested for Retribution only.
- **`/fhud dump`.** Records the client build, spellbook, talent nodes, auras on player, target, pet and focus (outside combat), and Cooldown Manager sets into `ForeverHUDDB.dump[class]`. `watch` snapshots auras after each fight, `names <text>` scans spell names. It reads only, stores no character name, and every client call is guarded. It also records whether the client has the function ForeverAuras needs for "at N stacks" rules.
- **Not yet:** stack rules (Heating Up at 3, Maelstrom Weapon at 5), Demonic Brand, Holy Strike, Shank and the other Forever spells. They need the dumped aura IDs first; a wrong ID fails silently.
- Update the Core and your class in `/fa`, choosing **Update Auras**.

## 0.13.8 — 2026-11-13 (prerelease)

- **Lighter install check** (user: "there is a bug players reporting lagging"). While the install gear was shown, the companion ran the full aura check every 3 seconds, and that check walks every saved ForeverAuras display twice. A player with many auras who hadn't updated yet got a repeating hitch out of combat. The timer now only compares the two installed build numbers, every 10 seconds, and runs the full check once when they stop being older. Login, the end of an import, and a click still run the full check.
- This is the one periodic cost found by reading the code; it is not confirmed in game as the cause of the reports.
- `/reload` is enough; no aura update is needed.

## 0.13.7 — 2026-11-13 (prerelease)

- **Cast bar size** (user: "casting bar should be able to customized in size too"). `/fhud` → Position has a **Cast bar size** slider, 60% to 200%, per class. It scales the ForeverHUD cast bar on top of the HUD size. The game's own cast bar isn't touched; it is sized in the game's Edit Mode.
- **Chinese on any client** (user: "add chinese zh client Language"). A **Language / 语言** button in `/fhud` → Position cycles Auto, 简体中文 and English, and `/fhud zh` / `/fhud en` / `/fhud auto` do the same. The choice is account-wide; `/reload` applies it to every label. Auto now also shows Chinese on a zhTW client. Spell names stay the client's own.
- **Faint until combat** (user: "when clicking the mob, the whole framework should be 20% visible, only 100% visible entering combat"). Opened by a hostile target outside combat (and during the 5 s hold after losing it), the whole HUD is at 20% of your opacity setting. It is fully visible in combat, from the moment combat starts, and while inspected: a seal click, `/fhud inspect`, the settings panel or the `/fa` editor. The folded seal and tray are unchanged. Companion only.
- **Lower default position** (user: "overall default position can be a bit lower, let's say 10%"). The default is y −235 (was −160), about 10% of the screen lower. A profile still at the old default (x 0, y −160) moves once; a position you set is kept.
- `/reload` is enough. Update the Core in `/fa` (choose **Update Auras**) so the cast bar reapplies its size whenever ForeverAuras rebuilds it.

## 0.13.6 — 2026-11-13 (prerelease)

- **Warrior strikes prompt you** (user: "战士压制出现的时候，没有提示", no prompt when the Warrior's Overpower comes up).
  - Overpower, Revenge, Execute and Victory Rush are now suggestions: the same native Action Usable checks, shown in the suggestion row with the Action Button Glow.
  - Every Warrior spec lists them (Arms leads with Overpower, Fury with Execute, Protection with Revenge), and a new `Leveling` list covers a Warrior without talents, who had no suggestion row before.
  - The old `Usable proc` row is removed: four unlit 28 px icons under the Health bar. Updating the class group deletes them.
- **Condition-triggered spells lead every list** (user: "any spell triggers by conditions we should add the top priority of the skill engines by any class", "including coming from spec/talents").
  - Every `active` proc rule and every `react` rule (a strike usable only once something happens) is sorted to the front of its list, so it takes the slot next to the seal. Moved up: Shadow Trance, Backlash, Conflagrate, Hot Streak, Clearcasting (Druid), Maelstrom Weapon, Counterattack, Mongoose Bite.
  - Added: Mage Clearcasting for Arcane (loads with the Arcane Concentration talent), Rogue Riposte for Combat, Mongoose Bite for every Hunter spec, Hammer of Wrath for Holy and Protection Paladins.
  - A test keeps it true for future lists: no ordinary rule may precede a reactive one.
- **`/fhud 80` sets the size** (user, with a screenshot: "doesn't work when I type /fhud 60 or /fhud 60%"). A number from 60 to 160, with or without `%`, sets the HUD size in steps of 5 and says so in chat; before, any argument just opened the panel.
- **A size setting in the game's addon options** (user: "ideally add an option ... to resize the UI and make everything still readable?"; "also add addon setting, allowing size changes there"). ForeverHUD registers a page in **Options → AddOns** with a **HUD size** slider, 60% to 160%, and a button to the full `/fhud` panel. It edits the existing per-class Scale preference; the whole HUD scales together, so text keeps its proportion to the art.
- **The folded seal shrinks another 10%** (user: "shrink another 10%, don't change spell icon size as it's already small enough"; read as the class seal, following the 0.13.2 request). The retracted seal is 106 px (was 118); the tray row moves from y=-67 to y=-61 to keep its 4 px gap, and the companion's install cue follows. Spell, suggestion and tray icons are unchanged.
- Update your class in `/fa`, choosing **Update Auras** (or click the gear).

## 0.13.5 — 2026-11-13 (prerelease)

- **The install icon is in the tray row** (user, with a screenshot of the gear on its own line under the shard count: "all notification should be aligned horizontally, why you kept reinventing new things").
  - The gear is now a display in each class's tray row (`… | Tray | Row | Install`), the row's last icon, so the native row centres it on the same line as the Soul Shard count, missing buffs and food. It has the tray icons' ring and frame and the missing reminders' gold glow.
  - The companion only answers `ForeverHUD.NeedsAuras()` and lays an invisible strip over the row, so hovering or clicking anywhere on the row shows the reasons and opens the install window.
  - A class group older than 0.13.5 (or none) can't draw the row icon, so the companion draws the same gear on the row's line: centred when there is no tray, otherwise just right of the row. The second line is gone.
- Update the Core and your class in `/fa`, choosing **Update Auras** (or click the gear).

## 0.13.4 — 2026-11-13 (prerelease)

- **Missing upkeep is easier to see** (user: "missing armor can be a bit more visible"). Missing reminders, in the tray and on the HUD, keep the 2.4 s breath and add a gentle gold Pixel glow: six thin lines circling the icon once every five seconds. The "expiring" reminders stay plain.
- **Every class reviewed** (user: "let's review all class and see if everything is up to date"). Always-on self-buffs that only had an "it's up" icon now remind when missing, in the tray and on the HUD, like Demon Armor:
  - Mage: Frost, Ice, Mage or Molten Armor.
  - Priest: Inner Fire.
  - Hunter: an aspect, missing only (aspects have no duration). Cheetah, Pack, Wild, Beast and Viper count as present.
  - Paladin: a blessing. Greater Blessings, Salvation, Light, Sanctuary and another paladin's blessing count.
  - Shaman (new): Lightning Shield or Water Shield.
  - Unchanged: Warlock armor, Arcane Intellect, Fortitude, Mark of the Wild, Warrior Battle Shout. Rogue poisons are weapon enchants, not auras, so ForeverAuras' aura trigger can't see them.
  - The old `… | Upkeep | Mage armor`, `Inner Fire`, `Aspect` and `Blessing` "it's up" icons are removed; updating the class group deletes them.
- **Suggestions invite a click** (user, with an in-game screenshot of the suggestion row: "recommendation can be a bit more flashing, inviting people to click"). Every suggestion, in the row and the mana, pet and execute cues, wears the game's Action Button Glow: the gold border with crawling ants that marks a spell to press. The row stays at 70% opacity.
- Update the Core and your class in `/fa`, choosing **Update Auras** (or click the gear under the seal).

## 0.13.3 — 2026-11-13 (prerelease)

- **An install icon under the folded seal** (user: "the class icon should have an additional icon along side of other missing spells if aura needs to be installed/updated").
  - While the Core or class group is missing, older than the addon, or left detached by a stopped import, a gear icon sits on its own line under the tray. It's shown only out of combat, while the HUD is folded (or when no ForeverHUD group is installed yet).
  - It has the tray icons' ring and frame and breathes like a missing buff (2.4 s, 40%). Hover for the same reasons `/fhud` lists; click to run `/fhud install`.
  - The companion draws it, since an aura can't show that it is itself missing or old. It checks the installed builds again every 3 seconds while shown and after every import, so it goes away once both groups are current.
- `/reload` is enough. The icon needs no aura update; update the Core and your class when it asks.

## 0.13.2 — 2026-11-13 (prerelease)

- **A smaller folded seal** (user, with a screenshot of the folded seal and tray: "smaller 10%"; "the class icon"). The retracted class seal is 118 px, down from 132. The tray row moved from y=-74 to y=-67, so it keeps its 4 px gap under the seal.
- Not changed: a fade-out when a Cooldown Manager aura ends (user: "whenever a spell from CDM expires, it should flash fade out?"). ForeverAuras' native aura buttons offer animations only when an aura is assigned and while it's shown (`BlizzardAuraDisplay.lua:1810`: "there is no Finish"), and reading the end time in Lua is not allowed here.
- Update your class in `/fa`, choosing **Update Auras**.

## 0.13.1 — 2026-11-13 (prerelease)

- **A missing buff breathes** (user, with a screenshot of the folded tray: "if armor is not on, the reminder here should flash? not crazy flash"; "like breathing").
  - Missing upkeep reminders, in the tray and on the HUD, play ForeverAuras' native **Pulse** (Aura Main) over 2.4 seconds: the icon fades to 40% and back, in a loop, while it's shown.
  - This covers Demon Armor, Arcane Intellect, Fortitude and Mark of the Wild. The "expiring" reminders and every other icon stay still.
- **The suggestion row is 70% opaque** (user: "recommended spell on top can be 70% visibility?"). Every icon in the rotation row over the DoTs, and the execute cue (Shadowburn) at its end, is drawn at 70%. The mana and pet cues under their bars stay fully opaque.
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
