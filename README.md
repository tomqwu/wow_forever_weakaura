# ForeverHUD · Class Combat HUD

<p align="center"><img src="assets/curseforge/logo-256.png" width="160" alt="ForeverHUD logo: the nine class seals"></p>

## English

**Version 0.14.14 — class globe frames (prerelease).** In the Globes style each class gets its own painted frame around both globes: shadowflame and horns for Warlocks, crossed blades for Warriors, frost and runes for Mages, wings and a sunburst for Priests, daggers and leather for Rogues, oak and antlers for Druids, a bow and feathers for Hunters, stone and lightning for Shamans, gilded wings and a hammer for Paladins. The new textures need a **full game restart** once; then update your class in `/fa`, choosing **Update Auras**. **0.14.13 — pet globe.** In the Globes style your pet's health is a small globe against the lower left of the Health globe, with its percentage inside, instead of the thin bar under it. Update your class in `/fa`, choosing **Update Auras**. **0.14.12 — Howl of Terror left out.** Howl of Terror no longer appears in the Utility wing or the Utility row, like Shadow Ward; the game still lists it under Utility in its Cooldown Manager. Type `/reload`, then update your class and **ForeverHUD | Core** in `/fa` (only their version number changes). **0.14.11 — shorter Globes bar.** The Globes style is about 22% narrower: smaller globes sit closer to the seal, four spells per side still fit between them, and the upkeep reminders move above the resource globe (out of combat). Bars style is unchanged. Update your class and **ForeverHUD | Core** in `/fa`, choosing **Update Auras**. **0.14.10 — action-RPG Globes layout.** In the Globes style the globes now sit at the two ends of one skill bar: both cooldown wings rest on the rail between them, with target effects, buffs and suggestions above. The globes moved out to make room, the Soul Shards line sits under the resource globe, and the liquid is round (0.14.9 showed a square). Bars style is unchanged. Update your class and **ForeverHUD | Core** in `/fa`, choosing **Update Auras**. **0.14.9 — slimmer Globes style.** The Globes frame style is redesigned: a slim iron ring around a larger liquid, darker toward the rim, and a thin rail joining the globes behind the seal instead of the wide band. Each globe shows its amount again (Health: percentage and value; resource: value and type). A soft dark shade sits behind the icons between the globes, and stacked icon rows have 8 px gaps instead of 4 in both styles. The shade is a new texture, so **fully restart the game** once. Update your class in `/fa`, choosing **Update Auras**, and update **ForeverHUD | Core** too. **0.14.8 — Demonic Sacrifice reminder.** Warlocks with Demonic Sacrifice see a breathing reminder in the upkeep row and the folded tray while none of its four buffs is up, and the "pet missing" reminder stays quiet while a sacrifice buff is up. Update Warlock in `/fa`, choosing **Update Auras**. **0.14.7 — class import fix.** Updating a class in `/fa` to 0.14.6 stopped part way: the Globes style's low-health ring pulsed, and ForeverAuras errors when it stops a pulse on a display whose brightness follows the protected health value. The ring is now steady. If an earlier update stopped part way, ForeverHUD says so in chat: in `/fa` delete every top-level "ForeverHUD | <class>" entry, then type `/fhud install`. **0.14.6 — Globes frame style.** A second frame style: health and your resource fill round painted globes either side of a band, with the seal, suggestions, cooldown wings and aura rows between them. Pick it in `/fhud` → **Display → Frame style**, or type `/fhud style globes` (`/fhud style bars` returns). Each class keeps its own choice; Bars stays the default. Update your class in `/fa`, choosing **Update Auras**. **0.14.5 — Titan Panel launcher.** With Titan Panel (or any LibDataBroker display) installed, a ForeverHUD launcher with your class crest appears in it: left-click opens settings, right-click expands or folds the HUD. ForeverHUD ships no library; without a Broker display nothing changes. Companion only: copy the addon and `/reload`. **0.14.4 — Utility wing in combat only.** In the Forever layout, the right-hand Utility cooldown wing and its overflow row now appear only in combat, so a newly learned ability such as Howl of Terror no longer sits above the seal out of combat. ForeverAuras loads them natively when combat starts. Update your class in `/fa`, choosing **Update Auras**. **0.14.3 — low Soul Shard warning.** Warlocks carrying fewer than 10 Soul Shards see the HUD shard count turn red and the tray shard icon glow red. ForeverAuras counts the shards natively. Update your class in `/fa`, choosing **Update Auras**. **0.14.2 — low-health flash.** At 30% health or less, a red glow races around the Health bar until you heal above 30%. ForeverAuras checks the threshold natively; nothing is guessed. Update your class in `/fa`, choosing **Update Auras**. **0.14.1 — redesigned settings window.** The `/fhud` window now has a header with your class crest and the version, and a sidebar of six categories with icons: **General**, **Display**, **Reminders**, **Combat**, **Layout** and **Minimap**. Each page has a title, a one-line description and grouped controls; the reminders and alert sounds now have their own page. Your settings carry over unchanged. Copy the new `ForeverHUD/` folder and `/reload`, then update your class in `/fa`, choosing **Update Auras** (the auras carry the new version). **0.14.0 — minimap button tray.** ForeverHUD now has its own minimap button, showing your class crest. Hover over it to open a framed tray holding the other addons' minimap buttons, so it is the only icon around the map; see **Minimap button tray** below. Copy the new `ForeverHUD/` folder and `/reload`. The auras' content is unchanged, but they carry the new version, so update your class in `/fa`, choosing **Update Auras**. **0.13.24 — Soul Link reminder.** With the Soul Link talent learned, a breathing reminder shows in the upkeep row and the folded tray while Soul Link is missing, like Demon Armor. It has no duration, so there is no "expiring" reminder. With no pet out, the pet reminder shows too. Update your class in `/fa`, choosing **Update Auras**. **0.13.23 — fuller spell lists for every class.** Each spec gains the cooldowns and debuffs its guides rank, such as Holy Strike for Paladins, Bestial Wrath and Rapid Fire for Hunters, Thunder Clap and Demoralizing Shout for Protection Warriors, and Swiftmend for Restoration Druids; the table below lists them. Every new rule loads only once you have learned the spell. Protection Warriors no longer get Overpower or Execute, and Searing Pain for Demonic Brand stays with Demonology, to fit five slots. Only the Warlock lists have been checked against a dump; the rest are not yet checked in game. Update your class in `/fa`, choosing **Update Auras**. **0.13.22 — Searing Pain when Demonic Brand is down.** With the Demonic Brand talent learned, the Warlock suggestion row shows Searing Pain whenever your Brand is missing from your hostile target, ahead of the DoTs. Update your class in `/fa`, choosing **Update Auras**. **0.13.21 — threshold cues no longer cover the Pet bar.** The low-pet-health cue (Health Funnel, Mend Pet) sat on the Pet bar's end, its frame covering the bar and its label. It now sits just past the bar's outer end, below it; the low-mana cue (Life Tap, Evocation, Innervate) moves the same way on the right. Update your class in `/fa`, choosing **Update Auras**. **0.13.20 — charges in the middle, a burst when a buff runs out.** On the buff row to the right of the seal, the big centre number is now the buff's charges or stacks (the hits it has left), and the remaining time sits small in the corner. When a buff ends, its icon throbs twice and then bursts to over twice its size as it fades, so you notice it needs renewing. Update the Core in `/fa`, choosing **Update Auras**. **0.13.19 — less work while looting and targeting.** ForeverHUD rechecked your whole spellbook on events that fire constantly while looting, trading, opening bags or changing buffs, up to ten times a second. It now ignores those events, waits for a burst to settle before one recheck, and skips the HUD update when a target or unit change leaves the HUD exactly as it was. New: **`/fhud perf`** prints ForeverHUD's and ForeverAuras' CPU time per frame from the game's add-on profiler, plus how often ForeverHUD rechecked spells and updated the HUD since the last report. No aura update is needed: copy the addon and `/reload`. **0.13.18 — reminder icons match your spells.** The Firestone, Shaman imbue, Rogue poison and pet reminders now show the icon of the spell that fixes them (Create Firestone, Rockbiter Weapon, Poisons, Summon Imp or Call Pet), taken from the game, so they look like the button on your action bar. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.13.17 — Shadow Ward leaves the Utility wing.** Shadow Ward only absorbs shadow damage, so it is cast when a shadow caster shows up, not watched as a cooldown. The game's Cooldown Manager files it under Utility; ForeverHUD now leaves it out of the Utility wing over the resource bar, and the next Utility spell takes its place. It stays on your action bar. No aura update is needed: copy the addon and `/reload`. **0.13.16 — wand shots no longer pop up icons.** In the Forever cooldown layout, the Utility cooldowns over the resource bar (for a Warlock: Shadow Ward, Healthstone, Soulstone and the like) used to appear only while on cooldown. Every wand shot puts your spells on a short shared lockout, which counted as a cooldown, so an icon popped up on each shot. Those Utility icons are now always shown: nothing appears or disappears when you shoot, and a real cooldown still shows its countdown. The damage cooldowns over Health are unchanged. No aura update is needed: copy the addon and `/reload`. **0.13.15 — Demonic Brand is back on the right.** Demonic Brand sits on your target, but it makes your pet hit harder, so it stays in the buff row on the right with your own buffs. Curses, Fear and Banish stay out. No aura update is needed: copy the addon and `/reload`. **0.13.14 — only your buffs on the right.** In the Forever cooldown layout, the buff row on the right now shows only buffs on you. The game's Cooldown Manager also tracks debuffs you put on your target (Demonic Brand from wand shots, curses, Fear, Banish), and those no longer appear there; your DoTs stay in the row on the left. No aura update is needed: copy the addon and `/reload`. **0.13.13 — Well Fed reminder.** An opt-in reminder breathes in the upkeep row and the folded tray when you aren't Well Fed. It's the **Well Fed reminder** checkbox under **Modules** in the settings, off by default for every class. The Food, Drink and Well Fed icons that show while those buffs are on you are unchanged. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.13.12 — pet reminder.** Warlocks and Hunters now get a breathing reminder in the upkeep row and the folded tray when they have no pet or their pet is dead. It stays quiet while you're mounted, and appears only once you know Summon Imp or Call Pet. It's the **Pet reminder** checkbox under **Modules** in the settings, on by default for both classes; turn it off if you sacrifice your demon. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.13.11 — buffs flash as they end.** When a buff in the Cooldown Manager row on the right ends (Demonic Brand, for example), its icon flashes twice and fades out instead of vanishing, in under a second. Folding the HUD still hides the row at once. The weapon enchant reminders from 0.13.10 now breathe slowly, like a missing buff, instead of flickering. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.13.10 — weapon enchant reminders, and a minimap entry.** A missing weapon enchant now shows in the upkeep row and the folded tray, breathing like a missing buff. There are two separate reminders, because one weapon can carry both: **Weapon imbue** (Firestone or Spellstone for Warlocks, a weapon imbue for Shamans) and **Oil, stone or poison** (any class; main- and off-hand poison for Rogues). Each is a checkbox under **Modules** in the settings. The imbue reminder is on by default for Warlocks and Shamans and the poison reminder for Rogues; turn on the oil/stone reminder yourself if you use wizard oil or sharpening stones. A reminder appears only once you know the spell that makes the enchant. ForeverHUD is also in the **minimap's addon list** now: left-click for settings, right-click to expand or fold. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.13.9 — spell IDs from the game, and `/fhud dump`.** Several suggestion and buff rules used spell IDs from older WoW versions that this game does not use, so they may never have shown: Hot Streak (now **Heating Up**), Fingers of Frost, Missile Barrage, Maelstrom Weapon, Surge of Light, Avenging Wrath, Water Shield and Molten Armor. They now use the IDs in the game client's own spell-name table. Shadowburn is suggested when usable instead of as an execute, and Hammer of Wrath is suggested for Retribution only. New: **`/fhud dump`** records your spellbook, talents, current auras and Cooldown Manager lists to the addon's saved settings, so the lists can be rebuilt from the real game; see *Help improve the spell lists* below. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.13.8 — lighter install check.** Players reported lag. While the install gear showed, the addon rescanned every saved ForeverAuras display every 3 seconds; with many auras that could hitch out of combat until the auras were updated. It now compares two build numbers every 10 seconds instead. `/reload` is enough. If you still see lag, please report your class, whether it is in or out of combat, and the output of `/fa pstart`, a minute of play, `/fa pstop`, then `/fa pprint`. **0.13.7 — cast bar size, Chinese on any client, lower default.** `/fhud` → Position has a **Cast bar size** slider (60% to 200%) for the ForeverHUD cast bar, and a **Language / 语言** button: Auto, 简体中文 or English (`/fhud zh` and `/fhud en` work too; `/reload` applies it everywhere). A Traditional Chinese client now gets the Chinese text as well. Targeting an enemy outside combat now shows the HUD at 20% opacity; it turns fully visible the moment combat starts, and when you click the seal to inspect it. The default position is lower (y −235, was −160); if you never moved the HUD it moves down once, and a position you chose is kept. `/reload` is enough for these; update the Core in `/fa` so the cast bar keeps its size after ForeverAuras rebuilds it. **0.13.6 — Warrior strikes prompt you.** Overpower, Revenge, Execute and Victory Rush now show in the suggestion row with the gold "press me" glow the moment they become usable, for every Warrior spec and for a Warrior without talents. Before, they were small unlit icons under the Health bar, and a Warrior without talents had no suggestion row. The folded class seal is another 10% smaller (106 px, was 118); spell and tray icons keep their size. ForeverHUD now has a page in the game's **Options → AddOns** list with a **HUD size** slider (60% to 160%), the same setting as **Scale** in `/fhud`; typing `/fhud 80` or `/fhud 80%` sets it too. In every class's suggestion list, condition-triggered spells (procs and reactive strikes, including talent ones) now come first. Update your class in `/fa`, choosing **Update Auras** (or click the gear). **0.13.5 — the install icon joins the tray row.** The gear that says your auras need installing or updating now sits in the tray row itself, on the same line as the Soul Shard count and missing buffs, instead of on a line of its own. Hover or click anywhere on the row for the reason and the install window. This first update still shows the gear beside the row, because your installed class group predates the row icon; once you update, it is part of the row. **0.13.4 — every class reminds you of its missing self-buff.** A missing upkeep buff now also has a gentle gold glow circling it, on top of the breathing, so it is easier to spot. Mage armor, Inner Fire, Hunter aspects, Paladin blessings and the Shaman's Lightning or Water Shield now remind you when missing, like Demon Armor; before, they only showed an icon while up. Greater Blessings and the other aspects (Cheetah, Pack and so on) count as present. Suggested spells now wear the game's gold "press me" button glow, inviting a click. Click the gear under the seal, or update the Core and your class in `/fa`, choosing **Update Auras**. **0.13.3 — an install icon under the seal.** When your ForeverHUD auras are missing or older than the addon, a breathing gear icon now sits under the folded seal, on its own line below the tray, out of combat. Hover it to see what needs doing; click it to open the install or update window, then choose **Update Auras**. It goes away once both groups are current. `/reload` is enough; no aura update is needed for the icon itself. **0.13.2 — a smaller folded seal.** Out of combat, the folded class seal is 10% smaller (118 px, was 132), and the tray under it moved up to keep the same gap. Update your class in `/fa`, choosing **Update Auras**. **0.13.1 — a missing buff breathes.** When an upkeep buff such as Demon Armor, Arcane Intellect, Fortitude or Mark of the Wild is missing, its reminder icon now slowly fades down and back, like breathing, in the folded tray and on the HUD. It catches the eye without flashing. The suggestion row above your DoTs is now drawn at 70% opacity, so it reads as advice without covering the frame. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.13.0 — see your shield.** Your remaining absorb shield (Ice Barrier, Mana Shield, Power Word: Shield, Shadow Ward and the like) now shows as a pale ice-white segment on your Health bar. It shrinks as the shield takes hits. Update the Core in `/fa`, choosing **Update Auras**. **0.12.1 — shelf lines instead of grey boxes.** The 0.12.0 grooves showed as empty grey boxes over the frame. They are replaced by a thin class-coloured line under the suggestions (left) and the utility cooldowns (right), bright at the seal and fading outward, shown only in combat. Restart the game for the new texture, then update the Core and your class in `/fa`, choosing **Update Auras**. **0.12.0 — one spine from the seal.** Every row now starts at the seal and grows outward: DoTs, suggestions and damage cooldowns to the left, your buffs and utility cooldowns to the right. They line up with each other and read as part of the frame. Drawn grooves seat the DoT and buff rows in the rim, with a cradle under the suggestions. Painted versions follow when the art is generated. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.11.0 — a clearer suggestion row.** Rotation suggestions now line up from the seal outward with no gaps: the slot next to the seal is always the top action. Mana cues (Life Tap, Evocation, Innervate, Mana Tide) appear under the Mana bar, pet cues (Health Funnel, Mend Pet) under the Pet bar, and Shadowburn takes a fixed slot at the far end of the row. Update your class in `/fa`, choosing **Update Auras**. **0.10.0 — rotation suggestions for every class and spec.** Suggestions now follow your spec: each of the nine classes has a list per spec (see *Spell suggestions*), and Warlocks without talents keep the 0.9 list. Update your class in `/fa`, choosing **Update Auras**. **0.9.7 — suggestions stay right above your DoTs.** Spell suggestions no longer jump up when you have left-side (Essential) cooldowns; those cooldowns now sit above the suggestions instead. Update your class in `/fa`, choosing **Update Auras**. **0.9.6 — suggestions on the damage side.** Spell suggestions now sit on the left, centred over Health, right above your DoTs. Update your class in `/fa`, choosing **Update Auras**. **0.9.5 — tray icons really match.** The Soul Shards tray icon now uses the same tight frame as the reminder icons beside it, so the frames no longer differ in size or overlap. The tray row also has a little more spacing. Update your class in `/fa`, choosing **Update Auras**. **0.9.4 — hover to peek.** Hovering the folded seal out of combat shows the whole HUD as a faint ghost, inviting a click. Click to open it fully; move away and it folds straight back. Entering combat drops the ghost to full opacity. **0.9.3 — matching tray icons.** Soul Shards now has the same dark inner ring as the reminder icons beside it, so every tray icon looks alike. ForeverAuras draws reminders with the game's own aura button, which can't be restyled. Update your class in `/fa`, choosing **Update Auras**. **0.9.2 — one-row tray.** The retracted tray is a single centred horizontal row under the seal, with every icon in the same style. Soul Shards show one count in the corner, like the other icons. **0.9.1:** the tray no longer shows health % and mana %. It keeps only Soul Shards, missing upkeep buffs and food, drink or Well Fed. Update your class in `/fa`, choosing **Update Auras**. **0.9.0 — spell suggestions.** Warlocks get a row of suggestions above the seal, in priority order from left to right:
- **Life Tap** at 30% mana or less;
- **Corruption** or **Immolate** when missing from your hostile target in combat;
- **Shadow Trance** when the proc is up (cast Shadow Bolt);
- **Health Funnel** when your pet is at 35% health or less.

Each rule is a native ForeverAuras check, so it works in combat. Protected values can't be combined, so Life Tap checks mana only, not your health. Turn suggestions off with **Spell suggestions** in `/fhud`. ForeverHUD now also warns at login, and in red at the bottom of `/fhud`, when your Core or class auras are missing or older than the addon, with an **Install / update auras** button. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.8.1 — no icon for a buff that's up.** Demon Armor, Arcane Intellect, Fortitude and Mark of the Wild now show only when missing or about to expire, never while active. Upkeep buffs without a reminder (Mage Armor, Inner Fire, Aspect, Blessing) keep their active icon. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.8.0 — retracted seal and tray.** Out of combat with no hostile target, the HUD folds to a larger seal with a tray under it:
- health and resource percentages;
- your Soul Shards (Warlock);
- missing upkeep buffs such as Demon Armor;
- Food, Drink and Well Fed while active.

Click the seal to open the full HUD; combat or a hostile target opens it too. Turn the tray off with **Retracted tray** in `/fhud`. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.7.3 — Demon Armor reminder.** Warlocks now get a reminder beside the resource bar when no Demon Skin, Demon Armor or Fel Armor is up, and in its last 15 seconds. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.7.2 — larger rim icons.** The DoT and buff icons on both rims grow from 24 to 28 px. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.7.1 — your buffs mirror your DoTs.** The Cooldown Manager's tracked buffs now sit on the rim over the resource bar, centred, the same size as the DoTs over Health. In the default *Forever* cooldown layout that row is the buff row; *Class plan* layout shows ForeverHUD's own class buffs there instead, so the two never overlap. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.7.0 — rows centred on each bar.** Every row now starts at the middle of its own bar and grows evenly both ways: DoTs and Essential cooldowns over Health, your buffs, Utility cooldowns and the Cooldown Manager's tracked buffs over the resource bar. The tracked-buff row is now attached above the Utility cooldowns. The DoT and buff rows use ForeverAuras' own *Modern Aura Group* centring, so they stay centred in combat. Painted rail art follows in a later release (see [design](docs/hud-design-0.7.md)). Update the Core and your class in `/fa`, choosing **Update Auras**. **0.6.2 — every row follows damage left, everything else right.** Your buffs now sit on the frame over the resource bar, mirroring the DoTs over Health. The native buff row, Utility and item overflow, Battle Shout, weapon coatings and totems are on the right. Rend, Warrior procs and Essential overflow are on the left. Update the Core and your class in `/fa`, choosing **Update Auras**. **0.6.1** seated the DoT row over the Health bar. **0.6.0 — damage left, everything else right.** Essential cooldowns and your DoTs sit on the left over Health, and Utility cooldowns and upkeep buffs such as Demon Armor on the right (see *Configure cooldowns*). After updating the addon, `/reload` and update the Core and your class in `/fa`. **0.5.1** showed DoTs only in the HUD's target row. **0.5.0 — one shared Core plus a small group per class.** The health and resource bars, cast bar and the native Cooldown Manager rows now live in one **`ForeverHUD | Core`** group that every class uses. Each class group keeps only its own spells, effects and art, so class updates are smaller. Coming from 0.4: delete your `ForeverHUD | <Class>` group in `/fa`, then install the Core and your class (see below). One companion supports all nine classes, with independent preferences and automatic class loading. The addon carries every import: install it, and ForeverAuras offers the Core and your class in `/fa`. No string to paste. Manual files remain available: [Core](dist/classes/ForeverHUD-Core.txt) plus [Warlock only](dist/classes/ForeverHUD-Warlock.txt) is roughly 75% smaller than the combined import; [exact sizes](dist/classes/README.md) are generated with each build.

### Features

<img src="docs/images/game-0.7.0-warlock-hud.png" width="795" alt="ForeverHUD in game: Warlock HUD with a DoT centred on the Health rim">

*In game, Warlock, 0.7.0 (cropped to the HUD). Immolate sits centred on the Health rim. Health, Mana, pet health and Soul Shards are on the frame, and Demon Armor is past the Mana bar. Later versions moved the buff row onto the Mana rim and added the tray and suggestions; the gallery further down shows the current layout as illustrative browser previews.*

<img src="docs/images/mock-0.14.14-globes.png" width="760" alt="Illustrative mock of the Globes frame style">

*Illustrative mock, not a game capture: the 0.14.14 Globes frame style (Warlock) drawn from the exported textures at the generated coordinates. Coloured squares stand in for suggestions, aura rows and cooldown wings.*

**One Core plus your class.** ForeverHUD ships its auras inside the addon:
- `ForeverHUD | Core`: health, resource, cast bar, native cooldown rows and tracked buffs, shared by every class.
- `ForeverHUD | <Class>`: your class's art, spells and effects.

Install or update both from `/fa`, or with `/fhud install`.

**Damage left, everything else right, growing out from the seal.**
- **Left (over Health):** your DoTs on the target, with the first four **Essential** cooldowns above them.
- **Right (over Mana):** your buffs, or the Cooldown Manager's tracked buffs, with the first four **Utility** cooldowns above them. Upkeep reminders sit past the bar.
- **One spine:** every row starts at the seal and grows outward, so the rows line up and the newest DoT, top suggestion and first cooldown sit by the seal. The rows reflow natively in combat (ForeverAuras Modern Aura Groups). In combat, a thin class-coloured shelf line runs under the rows that float above the frame.

**Native, combat-safe tracking.** Auras, cooldowns, resources and casts come from ForeverAuras' own triggers. The addon never reads combat values in Lua or guesses timers.

**Shields on the Health bar.** Your remaining absorb (Ice Barrier, Mana Shield, Power Word: Shield, Shadow Ward and the like) is a pale ice-white segment at the full end of the Health bar, growing back over the fill, so it shows even at full health. It's ForeverAuras' native absorb overlay: the client draws the amount, which stays hidden from addon code, so it works in combat. It shows only shields the server counts toward your total absorb.

**Upkeep reminders.** Each class's always-on buffs show only when missing or in their last 15 seconds:
- Warlock: Demon Skin, Demon Armor or Fel Armor; Soul Link (missing only, once the talent is learned).
- Mage: Arcane Intellect; Frost, Ice, Mage or Molten Armor.
- Priest: Fortitude; Inner Fire.
- Druid: Mark of the Wild.
- Hunter: an aspect (missing only, as aspects don't expire). Cheetah, Pack and the others count.
- Paladin: a blessing. Greater Blessings and another paladin's blessing count.
- Shaman: Lightning Shield or Water Shield.
- Warrior: Battle Shout, on the HUD only.

A missing one breathes, slowly fading to 40% and back every 2.4 seconds, with a gentle gold glow circling it, in the tray and on the HUD. Rogue poisons are weapon enchants, not auras, so they have no reminder.

**Spell suggestions (every class, per spec).** Rotation actions line up right above your DoTs at 70% opacity, each wearing the game's gold "press me" button glow, growing left from the seal, so the slot next to the seal is always the top action and there are no gaps. Mana cues show under the Mana bar, pet cues under the Pet bar, and an execute cue (Shadowburn) in a fixed slot at the row's far end. Left-side cooldowns sit above the row. Each spec has its own list, highest priority on the left. The list follows your talents, or the spec you pick in `/fhud`. Every rule is a single native ForeverAuras check (missing DoT or buff, proc up, spell usable, or a health/mana threshold), and a rule only loads once you know its spell.

| Class | Spec | Suggestions (left to right; **bold** = triggered by a condition, always first) |
| --- | --- | --- |
| Warlock | Leveling (no talents) | **Shadow Trance**, Corruption, Immolate; cues: Life Tap ≤30% mana, Health Funnel (pet ≤35%) |
| | Affliction | **Shadow Trance**, Corruption, Bane of Agony, Siphon Life, Amplify Curse usable; cue: Life Tap |
| | Demonology | Searing Pain (Demonic Brand missing, talent only), Corruption, Immolate, Bane of Agony; cues: Life Tap, Health Funnel |
| | Destruction | **Conflagrate** (usable), Immolate, Bane of Agony, Corruption, Shadowburn usable; cue: Life Tap |
| Mage | Arcane | **Missile Barrage**, **Clearcasting**, Arcane Power usable; cue: Evocation ≤20% mana |
| | Fire | **Heating Up**, Improved Scorch, Combustion usable; cue: Evocation |
| | Frost | **Fingers of Frost**; cue: Evocation |
| Priest | Discipline | Penance, Inner Focus, Power Infusion usable |
| | Holy | Prayer of Mending, Inner Focus usable |
| | Shadow | Shadowform, Shadow Word: Pain, Vampiric Embrace, Devouring Plague, Mind Blast usable |
| Rogue | Assassination | Slice and Dice, Rupture, Cold Blood usable |
| | Combat | **Riposte** (after a parry), Slice and Dice, Rupture, Blade Flurry usable |
| | Subtlety | Slice and Dice, Hemorrhage, Death Mark usable |
| Druid | Balance | **Clearcasting**, Moonfire, Insect Swarm, Faerie Fire; cue: Innervate ≤30% mana |
| | Feral | **Clearcasting**, Faerie Fire, Rake, Rip, Shifting Power usable |
| | Restoration | **Clearcasting**, Swiftmend, Nature's Swiftness, Wild Growth usable; cue: Innervate |
| Hunter | Beast Mastery | **Mongoose Bite** (after a dodge), Hunter's Mark, Serpent Sting, Bestial Wrath, Rapid Fire usable; cue: Mend Pet (pet ≤40%) |
| | Marksmanship | **Mongoose Bite**, Hunter's Mark, Serpent Sting, Sniper Shot, Rapid Fire usable; cue: Mend Pet |
| | Survival | **Counterattack** (after a parry), **Mongoose Bite**, Hunter's Mark, Serpent Sting, Strider Kick usable; cue: Mend Pet |
| Shaman | Elemental | Flame Shock, Lightning Shield |
| | Enhancement | **Maelstrom Weapon**, Lightning Shield, Stormstrike usable, Flame Shock, Rage of the Farseer usable |
| | Restoration | Riptide, Nature's Swiftness usable; cue: Mana Tide Totem ≤30% mana |
| Paladin | Holy | Holy Shock, Light's Vigil usable |
| | Protection | Holy Shield, Judgement, Swift Judgement, Holy Strike, Consecration |
| | Retribution | **Hammer of Wrath** (target low), Judgement, Holy Strike, Consecration |
| Warrior | Leveling (no talents) | **Overpower**, **Revenge**, **Execute**, **Victory Rush** |
| | Arms | **Overpower**, **Execute**, **Victory Rush**, Mortal Strike, Spearing Strike |
| | Fury | **Execute**, **Overpower**, **Victory Rush**, Bloodthirst, Whirlwind |
| | Protection | **Revenge**, **Victory Rush**, Thunder Clap and Demoralizing Shout (missing on the target), Shield Slam (Rend and Battle Shout keep their own reminders) |

**Help improve the spell lists (`/fhud dump`).** World of Warcraft: Forever has its own spells and talents, and the IDs of the buffs that procs put on you are not published anywhere. Out of combat, type **`/fhud dump`**, then **`/reload`**. It records, for your class only: the client version, your spellbook, your talent tree, the auras currently on you, your target, pet and focus, and the Cooldown Manager lists. Nothing is sent anywhere and no character name is stored; it is saved in `WTF/Account/<account>/SavedVariables/ForeverHUD.lua` under `dump`. Extras: `/fhud dump watch` toggles an aura snapshot after each fight (for short procs), `/fhud dump names <text>` lists every spell ID whose name contains the text, and `/fhud dump spells`, `talents`, `auras` or `cdm` refresh one part.

**Condition-triggered spells lead.** A proc that is up (Shadow Trance, Hot Streak, Clearcasting, Maelstrom Weapon and the like) or a strike that only becomes usable once something happens (Overpower after a dodge, Revenge, Execute, Riposte, Counterattack, Hammer of Wrath) always takes the slot next to the seal, ahead of DoT upkeep and ordinary cooldowns. Talent procs load once you have the talent.

The client hides combat values from addon code, so the list can't rank rules against each other or pick one "next spell". Every rule that applies shows at once.

The 0.9 Warlock list, still used without talents:
- Life Tap at 30% mana or less;
- Corruption or Immolate missing from your target in combat;
- the Shadow Trance proc;
- Health Funnel when your pet is at 35% health or less.

**Retracted seal and tray.** Out of combat with no hostile target, the HUD folds to a larger seal with a minimal tray:
- Soul Shards;
- missing upkeep buffs;
- Food, Drink and Well Fed.

Hover the seal to see the whole HUD as a faint ghost, then click it to open the full HUD.

**Install check.** If the addon is newer than your auras, or they're missing, ForeverHUD says so at login. `/fhud` also shows it in red, with an **Install / update auras** button. Out of combat, a glowing gear icon also joins the tray row under the folded seal, on the same line as the other notifications: hover or click the row for the reason and the install window.

**Settings per class (`/fhud`):** modules, cooldown layout (Forever or Class plan), cast bar choice, position, scale and opacity. Everything is in English and Simplified Chinese. **Resize the HUD** with **Scale** under `/fhud` → Position, with **HUD size** on the ForeverHUD page in the game's **Options → AddOns** list, or by typing `/fhud 80` (or `/fhud 80%`): 60% to 160%, and the whole HUD, text included, scales together.

### Install or update

1. Install **[ForeverAuras](https://github.com/neroxrw/foreverauras)**. The current source checked here is 1.3.7; the Forever interface is `16001`. ForeverHUD declares it as a dependency and does not load without it.
2. Download the [release ZIP](https://github.com/tomqwu/wow_forever_weakaura/releases) and copy **`ForeverHUD/`** into your current client's `Interface/AddOns/`. The TOC belongs directly inside that folder.
3. Enable ForeverHUD and ForeverAuras, then **`/reload`**.
4. Out of combat, open **`/fa`**. **ForeverHUD | Core** and your class appear under **ready to be installed** (first install) or under **updates** (an older ForeverHUD group). Click each one: ForeverAuras opens its own import window, and you confirm **Import** or **Update** there. Install the Core first. **`/fhud install`** opens the next one that is missing or older (Core, then your class); after it finishes, run **`/fhud install`** again for the second.
5. Choose **Update** for an existing group; it preserves the combined parent and other classes. Avoid **Import as Copy** for updates. In the update window, under *What do you want to do?*, select **Update Auras**. After a fresh install, ForeverAuras pre-selects **Create a Copy**, which adds a second group such as `ForeverHUD | Warlock 2`. After one Update it pre-selects Update. If you got a copy, delete that whole `… 2` group in `/fa` and update again.
6. Use **`/fhud`** or **`/foreverhud`** for controls. Positions/preferences survive ForeverHUD updates; **Position → Reset position** changes only X/Y.

**Moving from 0.4 to 0.5.** The bars and native rows moved from each class group into the Core, so an old class group would draw them twice. ForeverHUD warns at login while a 0.4 class group is installed, and `/fhud install` waits until it is gone. In **`/fa`**, delete **`ForeverHUD | <Class>`**, then install the Core and your class as in step 4. Your `/fhud` settings are kept.

**Moving from Eclipse (0.3.5 and earlier).** The addon folder, settings and aura names all changed, so nothing carries over and the old pieces must be removed once:

1. Exit the game, delete **`Interface/AddOns/EclipseHUD`**, and copy in **`ForeverHUD/`**.
2. Log in. ForeverHUD warns if the old addon or any `Eclipse | …` aura is still present.
3. In **`/fa`**, delete every **`Eclipse | …`** group (the combined `Eclipse | Class Combat HUD` and any loose `Eclipse | <Class> | …` entries). ForeverHUD never uses them.
4. Install your class as in step 4 above. Settings start from defaults: set position, scale and modules again in `/fhud`.

The bundled imports always match the installed companion. Only the Core and the class you are playing are offered; log in on another class to install or update it (the Core is shared, so install it once). ForeverAuras recognises updates through a `wago.io/forever-hud-<core|class>/<build>` tag on each display. It reads only the build number and never connects to wago.io, so ignore that link if `/fa` shows it.

**Manual import** still works: paste **`ForeverHUD-Core.txt`**, then a class file, from **`imports/`** in the ZIP into **`/fa` → Import**. The optional **`ForeverHUD-All-Classes.txt`** installs or updates a combined group holding the Core and all nine classes. 0.5 imports need the 0.5.0 companion (import API 2); older strings and old Eclipse strings do not work with it. The ZIP includes the Core file, nine class files, the combined file, and a size/SHA-256 manifest.

### Aura structure

**`ForeverHUD | Core`** holds what every class shares. It loads for all nine classes and follows the current class's `/fhud` settings:

| Core section | Contents |
| --- | --- |
| Resources | Health and the current resource (mana, rage, energy; colour follows the resource type) |
| Native rows | Overflow cooldowns, utility and equipped items from the Cooldown Manager |
| Native auras | Native player-effect icons and the optional tracked bars |
| Cast | Optional ForeverHUD cast bar, painted in the class accent |

Each class is one group whose direct children are organising sections, with nothing loose beside them:

| Class section | Contents |
| --- | --- |
| Frame | Chassis, living runes, combat effects, seal, caption (drawn in a lower layer, behind the Core bars) |
| Resources | Pet health, shards/combo points/swing timers/totems (only classes that have them) |
| Primary | Ability wings: Essential (damage) left, Utility right |
| Utility | Small on-cooldown Defense/Offense/Control rows |
| Auras | Target effects (DoT row on the frame over Health), player effects, maintenance (right of the resource bar), reminders, weapon coatings |
| Nameplates | Optional nameplate debuff icons |
| Alerts | Invisible ready-alert triggers |

Both groups attach to the same ForeverHUD anchor, so dragging, scale and opacity move them together. Sections sit at `(0,0)`, so every display keeps its position. Display names and IDs are stable across ForeverHUD updates; 0.5.0 gave the moved Core displays new names.

**If an import or update stops part way** (loose `ForeverHUD | <Class> | …` entries at the top of the `/fa` list, bars at screen centre that ignore dragging): ForeverAuras stopped its import before it restored those parents, so updating again cannot reattach them. ForeverHUD detects this at login (for the Core and your class) and prints a warning, and `/fhud install` refuses to import over it (`/fhud install force` overrides). Delete every top-level `ForeverHUD | <Class>` (or `ForeverHUD | Core`) entry it names, run `/fhud install` (or import the file again), and wait for the import window to finish before any `/reload`. Your `/fhud` settings live separately and are kept. If it stops again, turn on Lua errors with `/console scriptErrors 1` and report the error text.

| Group | Smaller import |
| --- | --- |
| Core (every class) | [Core import](dist/classes/ForeverHUD-Core.txt) |
| Warlock | [Warlock import](dist/classes/ForeverHUD-Warlock.txt) |
| Warrior | [Warrior import](dist/classes/ForeverHUD-Warrior.txt) |
| Mage | [Mage import](dist/classes/ForeverHUD-Mage.txt) |
| Priest | [Priest import](dist/classes/ForeverHUD-Priest.txt) |
| Rogue | [Rogue import](dist/classes/ForeverHUD-Rogue.txt) |
| Druid | [Druid import](dist/classes/ForeverHUD-Druid.txt) |
| Hunter | [Hunter import](dist/classes/ForeverHUD-Hunter.txt) |
| Shaman | [Shaman import](dist/classes/ForeverHUD-Shaman.txt) |
| Paladin | [Paladin import](dist/classes/ForeverHUD-Paladin.txt) |

### Configure cooldowns and preserve tracked bars

Open **`/fhud` → Behavior → Cooldown layout → Forever**. ForeverHUD follows your learned native Essential/Utility/item categories and order, but shows cooldown icons **only while a real cooldown is running**, with GCD-only feedback excluded. The cooldown row is empty when no real cooldown is active. Ready, no-cooldown fillers such as Life Tap/Corruption do not occupy persistent cooldown slots. Instant-cast spells can still have genuine cooldowns. Native dynamic wings compact the shown icons. **Class plan** is an optional ability-row layout with its own priorities.

In the game's **Cooldown Settings**, arrange Essential, Utility, Items and Not Displayed as desired. ForeverHUD follows learned entries, not every gray entry shown by the configuration window. Changes made during combat apply after combat.

**Damage left, everything else right.** That split decides the side:
- **Left, over Health:** your **DoTs on the target** in a row seated on the frame directly over the Health bar, with the first four **Essential** entries (your damage cooldowns) above them. Optional tracked bars (DoT and proc durations) also sit on the left.
- **Right, over the resource bar:** your **own buffs** in a row seated over the bar (with Battle Shout reminders and weapon coatings), the first four **Utility** entries (defensives, control, support) above them, then the native buff row. Upkeep buffs such as **Demon Armor** sit beside the bar.
- **Below the HUD:** Essential overflow on the left, Utility and item overflow (and Shaman totems) on the right.
- To move a spell to the other side, drag it between Essential and Utility in Cooldown Settings.
- Further entries fall into the rows below the HUD.
- With **Utility abilities** off in `/fhud`, the right wing stays empty.
- **Class plan** follows the same rule: attacks left, cooldowns and support right.

**CDM guide correction:** the v0.3.3 ZIP README's recommendation to set native Essential/Utility to Hidden is superseded by this guide. Keep them Always so their native event updates continue. The release assets remain unchanged.

**To keep the game's right-hand Tracked Bars:**

1. In **`/fa`**, leave the top-toolbar **Hide Blizzard's CDM** checkbox **off**. It hides all four viewers, including Tracked Bars.
2. Keep the game's cooldown manager enabled. In **Game menu → Edit Mode**, keep **Essential, Utility, Tracked Buffs and Tracked Bars → Visibility → Always**. Native **Hidden** unregisters viewer update events and can break mirrored tracking.
3. If you prefer the native cooldown icons too, disable duplicate **ForeverHUD Primary abilities / Utility abilities** modules. FA's global checkbox cannot hide only icon viewers while preserving the original native bars. Keeping native bars alongside ForeverHUD icons may leave duplicate native icons.
4. Leave **`/fhud` → Modules → Tracked bars (ForeverHUD)** off if you want only the game's bars.

**To replace native bars with ForeverHUD bars:** enable **Tracked bars (ForeverHUD)** first. It uses native CDM aura progress for active entries from your Tracked Bars category, including DoTs/control/procs, in a stack to the right. Then you may use **Hide Blizzard's CDM** to hide the default viewers while keeping tracking enabled. Keep the native tracking viewers configured to Always for this route. ForeverHUD does not change these global settings automatically. To return to the default CDM later, clear the global hide and restore the relevant native viewer Visibility to Always.

Optional **`/fa cdmsetup`** / **Set Up CDM** asks to back up/copy the native layouts, track catalog entries, restore hidden spell cooldowns, set viewers to Always, hide all four default viewers and reload. It changes the layout/visibility choices above; use it deliberately rather than just to hide one row.

User-provided native configuration references (not ForeverHUD runtime validation):

| Cooldown categories | Tracked Bars |
| :---: | :---: |
| [<img src="docs/images/native-warlock-cooldowns.png" width="300" alt="Native Warlock cooldown configuration">](docs/images/native-warlock-cooldowns.png) | [<img src="docs/images/native-warlock-tracked-bars.png" width="300" alt="Native Warlock tracked bars">](docs/images/native-warlock-tracked-bars.png) |

### DoT duration versus spell cooldown

Corruption/Immolate can be active on a target while their ability is ready. Their **remaining effect duration** belongs in **Target effects** or **Tracked Bars**, not a fabricated spell cooldown. Enable **Display → Target effects**, target an enemy and apply the learned spell. This row shows native player-owned target effects; missing/unreadable effects are not assigned guessed timers. You can use native bars, ForeverHUD's optional tracked-bar stack, or the compact target-effect icons. Disable a duplicate display if you only want one presentation.

### Choose a casting bar

Open **`/fhud` → Behavior → Cast bar display**. Click the control to cycle:

| Choice | ForeverHUD casting | Game casting |
| --- | --- | --- |
| Default game bar | Off; trackers unload | Available normally |
| ForeverHUD bar | On | Suppressed while the ForeverHUD display is loaded/enabled |
| Both bars | On | Available normally |

The safe default is the **game bar only**. Old overlapping defaults migrate to it; an existing explicit ForeverHUD-suppression choice is retained. **Display → ForeverHUD cast bar** also enables/disables the ForeverHUD choice. Disabling ForeverHUD or an unavailable imported cast display releases its ownership of the game bar. Another addon can retain its own ownership. Changes requested in combat wait until combat ends.

Illustrative mode previews, using sample values rather than the game client:

| Game bar only | ForeverHUD bar only | Both (explicit) |
| :---: | :---: | :---: |
| [<img src="preview/casting/warlock-default.png" width="260" alt="Game bar sample">](preview/casting/warlock-default.png) | [<img src="preview/casting/warlock-foreverhud.png" width="260" alt="ForeverHUD bar sample">](preview/casting/warlock-foreverhud.png) | [<img src="preview/casting/warlock-both.png" width="260" alt="Both bars sample">](preview/casting/warlock-both.png) |

### Expand, fold and move

- **Left-click the seal:** expand for inspection; **click again to fold** out of combat, including with the same target selected. A new target/combat edge restores automatic behavior. Click inspection remains pinned until cancelled; `/fhud inspect` and the settings inspection button are temporary.
- Combat events start motion immediately; the slide/fade takes about half a second. Enable **Combat → Unfold animation** for smooth motion. Layout refreshes preserve an in-progress transition. Combat exit folds immediately if no independent target/inspection condition holds; target loss alone has a five-second hold.
- Folding affects the main HUD. Active effects, tracked bars and casting keep independent rules.
- **Right-click:** settings. Unlock there, then drag the seal. X/Y, scale, opacity and module choices are per class; root changes defer in combat. **Reset position** preserves other preferences.
- Health is crimson, mana blue, energy gold and rage orange; labels provide another cue. Maintenance buffs sit beside the bar. Nameplate effects are off by default. Disabled modules unload their trackers.

**Minimap button tray:** ForeverHUD puts one button, showing your class crest, on the edge of the minimap. Drag it to move it around the map.

- **Hover:** opens a framed tray of the other addons' minimap buttons, in name order. The first cell opens ForeverHUD settings.
- **Buttons in the tray** keep their own clicks and tooltips. Clicking one closes the tray, which also closes two seconds after the pointer leaves, or with Escape.
- **Left-click** the ForeverHUD button for settings; **right-click** to expand or fold the HUD.
- **What is collected:** only named, unprotected addon launchers (LibDBIcon, ForeverCore and similar). Blizzard minimap controls, map pins and protected frames are never touched, and nothing moves during combat.
- **Turning it off:** use **Minimap → Group addon minimap buttons** or `/fhud buttons off` to return every button to its original spot, with its own dragging restored. **Minimap → Minimap button** or `/fhud minimap off` hides the ForeverHUD button and returns the buttons too. Both settings are shared by all your characters.
- **With Forever Classmate:** if Forever Classmate is enabled on a character, its tray groups the buttons, and the ForeverHUD button joins that tray instead of opening a second one.

Illustrative interaction/animation previews:

| Folded | During opening | Click-expanded | Optional tracked bars |
| :---: | :---: | :---: | :---: |
| [<img src="preview/states/warlock-idle.png" width="220" alt="Folded sample">](preview/states/warlock-idle.png) | [<img src="preview/states/warlock-opening.png" width="220" alt="Intermediate animation sample">](preview/states/warlock-opening.png) | [<img src="preview/states/warlock-click-open.png" width="220" alt="Expanded sample">](preview/states/warlock-click-open.png) | [<img src="preview/states/warlock-tracked-bars.png" width="220" alt="Tracked bars sample">](preview/states/warlock-tracked-bars.png) |

### Nine-class gallery and evidence

These are labelled browser fixtures with sample learned spells, active cooldowns/auras and values. They are not game-client screenshots or proof of full parity. They were re-captured for 0.9.0 and show the current layout: damage left, everything else right, rows centred on each bar. The preview does not model the retracted tray or spell suggestions; see *Features* above for an in-game capture. The interactive [preview](https://github.com/tomqwu/wow_forever_weakaura/blob/main/preview/index.html) includes a leveling fixture with no invented real cooldowns, category/class-plan modes, bar choices, click toggling and resource-form colors.

| Warlock | Warrior | Mage |
| :---: | :---: | :---: |
| [<img src="preview/classes/warlock.png" width="260" alt="Warlock">](preview/classes/warlock.png) | [<img src="preview/classes/warrior.png" width="260" alt="Warrior">](preview/classes/warrior.png) | [<img src="preview/classes/mage.png" width="260" alt="Mage">](preview/classes/mage.png) |

| Priest | Rogue | Druid |
| :---: | :---: | :---: |
| [<img src="preview/classes/priest.png" width="260" alt="Priest">](preview/classes/priest.png) | [<img src="preview/classes/rogue.png" width="260" alt="Rogue">](preview/classes/rogue.png) | [<img src="preview/classes/druid.png" width="260" alt="Druid">](preview/classes/druid.png) |

| Hunter | Shaman | Paladin |
| :---: | :---: | :---: |
| [<img src="preview/classes/hunter.png" width="260" alt="Hunter">](preview/classes/hunter.png) | [<img src="preview/classes/shaman.png" width="260" alt="Shaman">](preview/classes/shaman.png) | [<img src="preview/classes/paladin.png" width="260" alt="Paladin">](preview/classes/paladin.png) |

Actual aura ownership, durations, stacks, cooldowns, charges, resource values and rendering belong to native ForeverAuras triggers. There is no combat-log reconstruction or guessed refresh window. Warlock armor is observed natively; an unknown armor aura never becomes a fabricated missing warning. [Live validation](docs/validation.md) remains pending; [the durable checklist](docs/feature-parity-plan.md) records source facts, implementations and evidence separately.

For problems, run **`/fhud spells`** out of combat to print learned identities and native CDM categories/attachment diagnostics. This client's Lua errors are recorded in **`_forever_/Logs/General.log`**. The earlier mass-error popup also identified an independent AckisRecipeList health-prediction taint error; that addon is unchanged.

If the game feels slower with ForeverHUD, type **`/fhud perf`**, play for a minute (loot, tab-target, fight), then type it again. The second report shows ForeverHUD's and ForeverAuras' CPU time per frame (from the game's add-on profiler, where the client has one), how many times ForeverHUD rechecked your spells and updated the HUD, and which events asked for the rechecks. The HUD's icons and bars are drawn by ForeverAuras, so their cost shows under ForeverAuras; `/fa pstart`, `/fa pstop` and `/fa pprint` break it down by aura.

### Build and credits

Python 3.11+, Lua 5.1 and the build dependencies are required:

```bash
python -m pip install -r requirements-dev.txt
python scripts/build.py
python scripts/check.py
python scripts/preview.py
lua tests/native-schema.lua /path/to/ForeverAuras
```

CurseForge listing kit (logo, summary, description, upload steps and policy check): [docs/curseforge.md](docs/curseforge.md). Source: `src/catalog.py`, `scripts/build.py`, `src/ForeverHUD/`. Generated class files: `dist/classes/`; the combined export stays in `dist/`. CI verifies versions, codec/graphs/IDs, native schemas, package bytes and browser behavior. Every release updates the docs, relevant captures and changelog; published assets are immutable. See [design notes](docs/design.md) and [CHANGELOG](CHANGELOG.md).

Inspired by the supplied Guos Warrior HUD's feature organization. No Guos scripts, artwork, sounds or branding are bundled. Original AI-painted masters/prompts are in [assets/ai](https://github.com/tomqwu/wow_forever_weakaura/tree/main/assets/ai); builds reuse them. Game spell artwork remains Blizzard's property. GPL-2.0; see [LICENSE](LICENSE) and [vendor notices](https://github.com/tomqwu/wow_forever_weakaura/blob/main/vendor/README.md).

## 简体中文

**版本 0.14.14：职业球框（预发布）。** 球形样式中，每个职业的两个球体都有专属彩绘框饰：术士为暗影烈焰与恶魔角，战士为交叉利刃，法师为冰霜与符文，牧师为羽翼与日芒，盗贼为匕首与皮革，德鲁伊为橡枝与鹿角，猎人为长弓与羽毛，萨满祭司为石雕与闪电，圣骑士为镀金羽翼与战锤。新贴图需要**完全重启游戏**一次，然后在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.14.13：宠物球。** 球形样式中，宠物生命值改为生命球左下方的一个小球，内含百分比，取代原先球下方的细条。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.14.12：不再显示恐惧嚎叫。** 与暗影防护一样，恐惧嚎叫不再出现在辅助翼和辅助行中；游戏的冷却管理器仍将其归为辅助技能。输入 `/reload`，然后在 `/fa` 中更新当前职业与 **ForeverHUD | Core**（只有版本号变化）。**0.14.11：更短的球形技能栏。** 球形样式缩窄约 22%：球体更小并更靠近徽记，两侧仍可各放四个技能，维持提醒移到资源球上方（仅在非战斗中移动）。条形样式不变。请在 `/fa` 中更新当前职业与 **ForeverHUD | Core**，并选择 **Update Auras（更新光环）**。**0.14.10：动作角色扮演式球形布局。** 球形样式中，两个球体现在位于同一条技能栏的两端：两侧冷却翼都落在两球之间的横杆上，目标效果、增益与技能建议位于其上方。球体向外移动以腾出空间，灵魂碎片显示移到资源球下方，液体恢复为圆形（0.14.9 显示为方形）。条形样式不变。请在 `/fa` 中更新当前职业与 **ForeverHUD | Core**，并选择 **Update Auras（更新光环）**。**0.14.9：更纤细的球形样式。** 球形框架样式重新设计：纤细的铁环包围更大的液体（边缘更暗），徽记后方由一条细横杆连接两球，取代原来的宽徽带。每个球体重新显示数值（生命：百分比与数值；资源：数值与类型）。两球之间的图标后方新增柔和的暗色底影，两种样式中上下相叠的图标行间距由 4 像素增至 8 像素。底影是新贴图，请**完全重启游戏**一次。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**，同时更新 **ForeverHUD | Core**。**0.14.8：恶魔牺牲提醒。** 学会恶魔牺牲的术士，在其四种增益都不存在时，会在维持行和收起的托盘中看到“呼吸”提醒；身上有牺牲增益时，“宠物缺失”提醒不再出现。请在 `/fa` 中更新术士，并选择 **Update Auras（更新光环）**。**0.14.7：职业导入修复。** 在 `/fa` 中把职业更新到 0.14.6 会中途停止：球形样式的低血量光环带有脉动，而 ForeverAuras 在停止一个亮度随受保护生命值变化的显示的脉动时会报错。光环现在保持常亮。若之前的更新中途停止，ForeverHUD 会在聊天框提示：请在 `/fa` 中删除所有顶层的 "ForeverHUD | <职业>" 条目，然后输入 `/fhud install`。**0.14.6：球形框架样式。** 第二种框架样式：生命值与当前资源分别填充徽带两侧的彩绘球体，徽记、技能建议、冷却翼与光环行位于两球之间。在 `/fhud` → **显示 → 框架样式** 中选择，或输入 `/fhud style globes`（`/fhud style bars` 恢复条形）。每个职业单独保存；默认仍为条形。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.14.5：Titan Panel 启动按钮。** 安装 Titan Panel（或任何 LibDataBroker 显示插件）后，其中会出现带有职业徽记的 ForeverHUD 按钮：左键打开设置，右键展开或收起 HUD。ForeverHUD 不附带任何库；没有 Broker 显示插件时一切照旧。仅更新插件：复制插件并 `/reload` 即可。**0.14.4：通用冷却翼仅在战斗中显示。** 在 Forever 布局中，右侧的通用（Utility）冷却翼及其溢出行现在只在战斗中出现，新学会的技能（例如恐惧嚎叫）不会再在非战斗时停留在徽记上方。进入战斗时由 ForeverAuras 原生加载。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.14.3：灵魂碎片不足警告。** 术士携带的灵魂碎片少于 10 个时，HUD 上的碎片数字变红，收起栏中的碎片图标出现红色光效。碎片数量由 ForeverAuras 原生统计。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.14.2：低血量闪烁。** 生命值不高于 30% 时，生命条周围会出现快速流动的红色光效，回到 30% 以上后消失。阈值由 ForeverAuras 原生判断，不做任何推测。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.14.1：重新设计的设置窗口。** `/fhud` 窗口顶部显示你的职业徽记和版本号，左侧是带图标的六个分类：**常规**、**显示**、**提醒**、**战斗**、**布局** 和 **小地图**。每个页面都有标题、一句说明和分组的选项；提醒与提示音现在有单独的页面。原有设置全部保留。复制新的 `ForeverHUD/` 文件夹并输入 `/reload`，然后在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**（光环带有新版本号）。**0.14.0：小地图按钮收纳盒。** ForeverHUD 现在有自己的小地图按钮，显示你的职业徽记。鼠标移到按钮上会打开一个带边框的收纳盒，里面放着其他插件的小地图按钮，小地图周围只剩这一个图标；详见下方 **小地图按钮收纳盒**。复制新的 `ForeverHUD/` 文件夹并输入 `/reload`。光环内容没有变化，但版本号已更新，请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.13.24：灵魂链接提醒。** 学会灵魂链接天赋后，若身上没有灵魂链接，常驻增益行和收起时的托盘中会像恶魔护甲一样出现“呼吸”提醒。它没有持续时间，因此没有“即将结束”提醒。没有召唤宠物时，宠物提醒也会同时显示。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.13.23：各职业技能建议更完整。** 每个专精都加入了攻略推荐的冷却和减益，例如圣骑士的神圣打击、猎人的狂野怒火和急速射击、防护战士的雷霆一击和挫志怒吼、恢复德鲁伊的迅捷治愈。每条新规则只有在学会该法术后才会加载。为容纳五个位置，防护战士不再提示压制和斩杀，Demonic Brand 的灼热之痛提示只保留在恶魔学识专精。目前只有术士的列表经过 dump 核对，其他职业尚未在游戏中检查。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.13.22：Demonic Brand 消失时提示灼热之痛。** 学会 Demonic Brand 天赋后，只要敌对目标身上没有你的 Brand，术士技能建议行就会在持续伤害法术之前显示灼热之痛。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.13.21：阈值提示不再遮住宠物血条。** 宠物低血量提示（生命通道、治疗宠物）原先压在宠物血条末端，边框盖住了血条和标签。现在它位于血条外端稍外、略低的位置；右侧的低法力提示（生命分流、唤醒、激活）也同样移动。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.13.20：层数居中，增益结束时爆开。** 徽记右侧的增益行中，图标中间的大数字现在是该增益的剩余次数或层数，剩余时间改为显示在角落的小字。增益结束时，图标会跳动两下，然后放大到两倍多并淡出，提醒你需要重新施放。请在 `/fa` 中更新 Core，并选择 **Update Auras（更新光环）**。**0.13.19：拾取和切换目标时更省资源。** ForeverHUD 以前会在拾取、交易、打开背包或增益变化时不断触发的事件上重新检查整本法术书，最多每秒十次。现在这些事件会被忽略，一连串事件结束后才检查一次；切换目标或单位变化若不改变界面显示，也不再更新整个界面。新增 **`/fhud perf`**：根据游戏自带的插件性能分析器，显示 ForeverHUD 和 ForeverAuras 每帧占用的 CPU 时间，以及自上次报告以来 ForeverHUD 重新检查技能和更新界面的次数。无需更新光环：复制插件后 `/reload` 即可。**0.13.18：提醒图标与技能一致。** 火焰石、萨满祭司武器灌注、盗贼毒药和宠物提醒现在显示能解决问题的那个技能的图标（制造火焰石、石化武器、毒药、召唤小鬼或召唤宠物），图标直接取自游戏，与你动作条上的按钮一致。请在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.13.17：暗影防护结界移出辅助技能区。** 暗影防护结界只吸收暗影伤害，是遇到暗影施法者时才施放的技能，而不是需要盯着看的冷却。游戏的冷却管理器把它归入辅助类；ForeverHUD 现在不再把它放在资源条上方的辅助技能区，下一个辅助技能会补上它的位置。它仍在你的动作条上。无需更新光环：复制插件后 `/reload` 即可。**0.13.16：魔杖射击不再弹出图标。** 在系统冷却布局下，资源条上方的辅助冷却（术士为暗影防护结界、治疗石、灵魂石等）以前只在冷却时显示。每次魔杖射击都会让技能进入短暂的共享锁定，这被当作冷却，于是每次射击都会弹出图标。现在这些辅助图标始终显示：射击时不会有图标出现或消失，真正的冷却仍显示倒计时。生命条上方的伤害技能冷却不变。无需更新光环：复制插件后 `/reload` 即可。**0.13.15：Demonic Brand 回到右侧。** Demonic Brand 虽然作用在目标身上，但它会让你的宠物造成更高伤害，因此与你自己的增益一起保留在右侧增益行中。诅咒、恐惧和放逐仍不显示在该行。无需更新光环：复制插件后 `/reload` 即可。**0.13.14：右侧只显示你自己的增益。** 在系统冷却布局下，右侧增益行现在只显示你身上的增益。游戏的冷却管理器也会追踪你施加在目标身上的减益（例如魔杖攻击带来的 Demonic Brand、诅咒、恐惧、放逐），这些不再出现在该行；你的持续伤害效果仍显示在左侧行。无需更新光环：复制插件后 `/reload` 即可。**0.13.13：进食充分提醒。** 新增可选提醒：没有“进食充分”效果时，常驻增益行和收起时的托盘中会出现“呼吸”提示。可在设置的 **显示模块** 中勾选 **进食充分提醒**，所有职业默认关闭。进食、饮水和进食充分效果存在时显示的图标不变。请在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.13.12：宠物提醒。** 术士和猎人没有宠物或宠物死亡时，常驻增益行和收起时的托盘中会出现“呼吸”提醒。骑乘时不会提示，并且只有学会召唤小鬼或召唤宠物后才会出现。可在设置的 **显示模块** 中勾选 **宠物提醒**，两个职业默认开启；如果你会献祭恶魔，可以将其关闭。请在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.13.11：增益结束时闪烁。** 右侧冷却管理器增益行中的增益结束时（例如 Demonic Brand），图标会闪烁两次后淡出，而不是直接消失，全程不到一秒。收起界面时该行仍会立即隐藏。0.13.10 的武器附魔提醒现在会像缺少增益一样缓慢“呼吸”，而不是快速闪烁。请在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.13.10：武器附魔提醒，以及小地图入口。** 武器上缺少附魔时，会在常驻增益行和收起时的托盘中像缺少增益一样“呼吸”提示。提醒分为两个，因为同一把武器可以同时拥有两种附魔：**武器灌注**（术士的火焰石或法术石、萨满祭司的武器灌注）和**武器油/磨刀石/毒药**（所有职业；盗贼分主手和副手毒药）。两者都可在设置的 **显示模块** 中勾选。术士和萨满祭司默认开启灌注提醒，盗贼默认开启毒药提醒；如果你使用巫师之油或磨刀石，请自行开启武器油/磨刀石提醒。只有学会制作该附魔的法术后才会提示。ForeverHUD 现在也出现在**小地图的插件列表**中：左键打开设置，右键展开或收起。请在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.13.9：使用游戏内的法术 ID，并新增 `/fhud dump`。** 部分技能建议和增益规则使用了旧版魔兽的法术 ID，而本游戏并不使用它们，因此可能从未显示过：法术连击（现为 **Heating Up**）、寒冰指、飞弹弹幕、漩涡武器、圣光涌动、复仇之怒、水之护盾和熔岩护甲。现在改用游戏客户端自身法术名称表中的 ID。暗影灼烧改为“可用时”提示而不是斩杀提示，愤怒之锤只对惩戒提示。新增 **`/fhud dump`**：脱战时输入，然后 `/reload`，它会把你的法术书、天赋、当前光环和冷却管理器列表记录到插件的保存文件（`dump` 项）中，用于按真实游戏数据重建技能列表；不会发送任何数据，也不记录角色名。`/fhud dump watch` 可在每场战斗后记录一次光环，`/fhud dump names <文字>` 列出名称包含该文字的所有法术 ID。请在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.13.8：更轻量的安装检查。** 有玩家反馈卡顿。安装齿轮显示期间，插件每 3 秒会重新扫描全部已保存的 ForeverAuras 显示；光环很多时，在更新光环之前脱战状态下可能出现周期性卡顿。现在改为每 10 秒只比较两个版本号。只需 `/reload`。如果仍然卡顿，请反馈职业、是否在战斗中，以及 `/fa pstart`、游玩一分钟、`/fa pstop` 后 `/fa pprint` 的输出。**0.13.7：施法条大小、任意客户端可用中文、默认位置下移。** `/fhud` → 位置与缩放 中新增 **施法条大小** 滑块（60% 到 200%，针对 ForeverHUD 施法条），以及 **Language / 语言** 按钮：自动、简体中文或 English（也可输入 `/fhud zh` 或 `/fhud en`；`/reload` 后全部生效）。繁体中文客户端现在也显示中文。脱战时选中敌人，界面只以 20% 不透明度显示；进入战斗的瞬间变为完全可见，点击印记查看时也是完全可见。默认位置下移（y −235，原为 −160）；如果从未移动过界面，它会自动下移一次，自己设定的位置保持不变。只需 `/reload`；请在 `/fa` 中更新 Core，使施法条在 ForeverAuras 重建后仍保持大小。**0.13.6：战士的触发技能会提示。** 压制、复仇、斩杀和乘胜追击在可用的瞬间会出现在技能建议栏中，并带有金色“按我”光效；战士的每个专精以及没有天赋的战士都适用。之前它们只是生命条下方不发光的小图标，而且没有天赋的战士没有建议栏。收起时的职业印记再缩小 10%（106 像素，原为 118）；技能和托盘图标大小不变。ForeverHUD 现在在游戏的 **选项 → 插件** 列表中有自己的页面，带 **界面大小** 滑块（60% 到 160%），与 `/fhud` 中的 **缩放** 是同一个设置；也可以直接输入 `/fhud 80` 或 `/fhud 80%`。各职业的技能建议中，由条件触发的技能（触发效果和反应技能，包括天赋带来的）现在排在最前面。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**（或点击齿轮）。**0.13.5：安装图标并入托盘一行。** 提示光环需要安装或更新的齿轮图标现在位于托盘这一行内，与灵魂碎片计数和缺失增益排成一条水平线，不再另起一行。悬停或点击这一行即可查看原因并打开安装窗口。本次更新时齿轮仍显示在这一行的旁边，因为已安装的职业分组还没有这个图标；更新之后它就在行内。**0.13.4：各职业缺失的自身增益都会提醒。** 缺失的维持类增益除了“呼吸”之外，还会有一圈柔和的金色光点环绕，更容易看到。法师护甲、心灵之火、猎人守护、圣骑士祝福以及萨满祭司的闪电之盾/水之护盾现在也会像恶魔护甲一样在缺失时提醒；之前它们只在生效时显示图标。强效祝福和其他守护（猎豹、豹群等）也算作已有。技能建议现在带有游戏自带的金色“按我”按钮光效，提示点击。点击印记下方的齿轮，或在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.13.3：印记下方的安装图标。** 当 ForeverHUD 光环缺失或比插件旧时，脱战收起的印记下方（托盘下一行）会出现一个“呼吸”的齿轮图标。鼠标悬停可查看原因，点击会打开安装或更新窗口，然后选择 **Update Auras（更新光环）**。核心和职业都更新后图标会消失。只需 `/reload`，图标本身不需要更新光环。**0.13.2：收起时的印记缩小。** 脱战收起时的职业印记缩小 10%（118 像素，原为 132），下方托盘随之上移，间距不变。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.13.1：缺失的增益会“呼吸”。** 恶魔护甲、奥术智慧、真言术：韧或野性印记等维持类增益缺失时，提醒图标会缓慢变暗再恢复，像呼吸一样，在收起的托盘和 HUD 上都会如此。足够醒目，但不会闪烁。DoT 上方的技能建议栏现在以 70% 不透明度显示，作为提示而不遮挡边框。请在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.13.0：显示护盾剩余量。** 你剩余的吸收护盾（寒冰护体、法力护盾、真言术：盾、暗影防护等）现在以淡冰白色片段显示在生命条上，随着护盾承受伤害而缩短。请在 `/fa` 中更新 Core，并选择 **Update Auras（更新光环）**。**0.12.1：用细线托架替换灰色方块。** 0.12.0 的凹槽在边框上显示为空的灰色方块，现已改为技能建议（左）和功能冷却（右）下方的一条职业色细线：靠近印记处最亮、向外渐隐，仅在战斗中显示。请重启游戏以载入新材质，然后在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.12.0：从印记延伸的统一主轴。** 所有行现在都从印记出发向外延伸：DoT、技能建议和伤害冷却在左，增益和功能冷却在右，彼此对齐，看起来是边框的一部分。DoT 行和增益行嵌在边框的凹槽中，建议栏下方有托架（目前为绘制版本，手绘美术生成后替换）。请在 `/fa` 中更新 Core 和当前职业，并选择 **Update Auras（更新光环）**。**0.11.0：更清晰的建议栏。** 输出建议现在从印记向外依次排列、没有空位：紧挨印记的位置永远是最优先的动作。法力提示（生命分流、唤醒、激活、法力之潮）显示在法力条下方，宠物提示（生命通道、治疗宠物）显示在宠物条下方，暗影灼烧固定在建议栏最外侧。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.10.0：所有职业与专精的输出建议。** 技能建议现在跟随专精：九个职业的每个专精都有自己的列表；没有天赋的术士继续使用 0.9 的列表。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.7：技能建议始终紧贴 DoT 上方。** 有左侧（Essential）冷却技能时，技能建议不再上移；改为由这些冷却技能显示在建议上方。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.6：技能建议移到伤害一侧。** 技能建议现在位于左侧、生命条正上方居中，紧贴在 DoT 图标之上。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.5：托盘图标真正一致。** 灵魂碎片托盘图标现在与旁边的提醒图标使用相同的紧凑边框，不再大小不同或互相重叠；托盘这一行的间距也略微加大。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.4：悬停预览。** 脱离战斗时把鼠标悬停在收起的印记上，整个界面会以淡淡的虚影显示，提示可以点击。点击即可完全展开；移开鼠标则立即收回。进入战斗时虚影会恢复为完全不透明。**0.9.3：托盘图标风格一致。** 灵魂碎片现在与旁边的提醒图标一样带有深色内圈，托盘中所有图标外观一致（ForeverAuras 用游戏自带的光环按钮绘制提醒，无法另行修改样式）。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.2：单行托盘。** 收起时的托盘是印记下方居中的一行横排图标，所有图标风格一致；灵魂碎片与其他图标一样只在角落显示一个数字。**0.9.1：** 托盘不再显示生命与法力百分比，只保留灵魂碎片、缺失的维持类增益以及进食、饮水或进食充分。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.0：技能建议。** 术士在印记上方获得一行建议，从左到右按优先级排列：
- 法力不高于 30% 时建议**生命分流**；
- 战斗中敌对目标身上缺少你的**腐蚀术**或**献祭**时提示；
- **暗影冥思**触发时提示（施放暗影箭）；
- 宠物生命不高于 35% 时建议**生命通道**。

每条规则都是 ForeverAuras 的原生判断，战斗中也能生效。受保护的数值无法组合判断，因此生命分流只检查法力，不检查你的生命。可在 `/fhud` 中用 **技能建议** 关闭。当核心或职业光环缺失、或比插件旧时，ForeverHUD 会在登录时提示，并在 `/fhud` 底部以红字显示，附 **安装/更新光环** 按钮。请在 `/fa` 中更新核心和当前职业，并选择 **Update Auras（更新光环）**。**0.8.1：增益生效时不再显示图标。** 恶魔护甲、奥术智慧、真言术：韧与野性印记现在只在缺失或即将结束时显示，生效期间不显示。没有提醒的维持类增益（法师护甲、心灵之火、守护、祝福）仍显示生效图标。请在 `/fa` 中更新核心和当前职业，并选择 **Update Auras（更新光环）**。**0.8.0：收起时的印记与托盘。** 脱离战斗且没有敌对目标时，界面收起为更大的印记，下方挂着托盘：
- 生命与资源百分比；
- 灵魂碎片（术士）；
- 缺失的维持类增益（如恶魔护甲）；
- 生效中的进食、饮水与进食充分。

点击印记可展开完整界面，进入战斗或选中敌对目标也会展开。可在 `/fhud` 中用 **收起时的托盘** 关闭。请在 `/fa` 中更新核心和当前职业，并选择 **Update Auras（更新光环）**。**0.7.3：恶魔护甲提醒。** 术士在没有恶魔皮肤、恶魔护甲或邪甲时，以及在其最后 15 秒内，会在资源条旁看到提醒。请在 `/fa` 中更新核心和当前职业，并选择 **Update Auras（更新光环）**。**0.7.2：框架上的图标略微放大。** 两侧框架上的 DoT 与增益图标由 24 像素增大到 28 像素。请在 `/fa` 中更新核心和当前职业，并选择 **Update Auras（更新光环）**。**0.7.1：增益与 DoT 对称。** 冷却管理器的追踪增益现在居中贴在资源条上方的框架上，大小与生命条上方的 DoT 相同。默认的 *Forever* 冷却排列下，这一行就是增益行；*职业方案* 排列则在同一位置显示 ForeverHUD 自带的职业增益，两者不会重叠。请在 `/fa` 中更新核心和当前职业，并选择 **Update Auras（更新光环）**。**0.7.0：每行以各自的条为中心。** 每一行都从所在条的中点开始，向两侧均匀扩展：DoT 与 Essential 冷却在生命条上方，你的增益、Utility 冷却以及冷却管理器的追踪增益在资源条上方。追踪增益行现已贴在 Utility 冷却上方。DoT 与增益行使用 ForeverAuras 自带的 *Modern Aura Group* 居中排列，战斗中也保持居中。手绘的槽位美术将在后续版本加入（见[设计](docs/hud-design-0.7.md)）。请在 `/fa` 中更新核心和当前职业，并选择 **Update Auras（更新光环）**。**0.6.2：所有行都遵循“伤害在左，其余在右”。** 你的增益现在贴在资源条上方的框架上，与生命条上方的 DoT 对称。原生增益行、Utility 与物品溢出行、战斗怒吼、武器涂层和图腾在右侧；撕裂、战士触发提示和 Essential 溢出行在左侧。请在 `/fa` 中更新核心和当前职业，并选择 **Update Auras（更新光环）**。**0.6.1** 把 DoT 行贴在生命条上方。**0.6.0：伤害在左，其余在右。** Essential 冷却与你的 DoT 位于左侧生命条上方，Utility 冷却与恶魔护甲等维持类增益位于右侧（见“配置冷却管理器”）。更新插件后输入 `/reload`，并在 `/fa` 中更新核心和当前职业。**0.5.1** 让 DoT 只显示在界面的目标效果行。**0.5.0：一个通用核心加每职业一个小组。** 生命条、资源条、施法条以及原生冷却管理器行，现在都放在所有职业共用的 **`ForeverHUD | Core`** 组中。各职业组只保留自己的技能、特效和美术，因此职业更新更小。从 0.4 升级：请在 `/fa` 中删除 `ForeverHUD | <职业>` 组，然后安装核心和当前职业（见下文）。一套配套插件支持九职业，按当前角色自动加载，并分别保存设置。插件附带全部导入：安装后，ForeverAuras 会在 `/fa` 中提供核心和当前职业，无需粘贴字符串。手动文件仍可使用：[核心](dist/classes/ForeverHUD-Core.txt)加[术士独立导入](dist/classes/ForeverHUD-Warlock.txt)比合并文件约小 75%；[精确大小](dist/classes/README.md)由构建自动生成。

### 功能

<img src="docs/images/game-0.7.0-warlock-hud.png" width="795" alt="游戏内的 ForeverHUD：术士界面，DoT 居中贴在生命条上方">

*游戏内截图，术士，0.7.0（已裁剪为界面区域）。献祭居中贴在生命条上方，生命、法力、宠物生命与灵魂碎片位于框架上，恶魔护甲在法力条外侧。之后的版本把增益行移到法力条上方，并加入托盘与技能建议；下方的浏览器预览图以示意方式展示当前布局。*

<img src="docs/images/mock-0.14.14-globes.png" width="760" alt="球形框架样式示意图">

*示意图，并非游戏截图：0.14.14 球形框架样式（术士），按生成坐标使用导出的贴图绘制。彩色方块代表技能建议、光环行与冷却翼。*

**一个核心加你的职业。** ForeverHUD 的光环随插件附带：
- `ForeverHUD | Core`：生命、资源、施法条、原生冷却行与追踪增益，所有职业共用。
- `ForeverHUD | <职业>`：该职业的美术、技能与特效。

可在 `/fa` 中安装或更新两者，或输入 `/fhud install`。

**伤害在左，其余在右，从印记向外延伸。**
- **左侧（生命条上方）：** 你在目标身上的 DoT，其上方是前四个 **Essential** 冷却。
- **右侧（法力条上方）：** 你的增益（或冷却管理器的追踪增益），其上方是前四个 **Utility** 冷却。维持类提醒位于条外侧。
- **统一主轴：** 每一行都从印记出发向外延伸，彼此对齐；最新的 DoT、最优先的建议和第一个冷却都紧挨印记。战斗中由 ForeverAuras 原生 Modern Aura Group 重新排列。战斗中，浮在边框上方的行下有一条职业色细线托住。

**原生、战斗安全的追踪。** 光环、冷却、资源与施法都来自 ForeverAuras 自身的触发器。插件从不在 Lua 中读取战斗数值，也不猜测计时。

**生命条上的护盾。** 剩余吸收量（寒冰护体、法力护盾、真言术：盾、暗影防护等）以淡冰白色片段显示在生命条满值一端并向回延伸，满血时也能看到。这是 ForeverAuras 原生的吸收覆盖层：数值由客户端绘制、插件代码读取不到，因此战斗中也可用。只显示服务器计入总吸收量的护盾。

**维持类提醒。** 各职业常驻的自身增益只在缺失或最后 15 秒时显示：术士的恶魔皮肤/恶魔护甲/邪甲术，以及灵魂链接（学会天赋后，仅缺失时）；法师的奥术智慧，以及霜甲术/冰甲术/魔甲术/熔岩护甲；牧师的真言术：韧与心灵之火；德鲁伊的野性印记；猎人的守护（仅缺失时，守护没有持续时间，猎豹、豹群等守护也算）；圣骑士的祝福（强效祝福和其他圣骑士的祝福也算）；萨满祭司的闪电之盾或水之护盾；战士的战斗怒吼（仅在 HUD 上）。缺失时图标会缓慢“呼吸”，并有一圈柔和的金色光点环绕。盗贼的毒药是武器附魔而非光环，因此没有提醒。

**技能建议（所有职业，按专精）。** 输出动作紧贴 DoT 图标上方、从印记向左排列，紧挨印记的位置永远是最优先的动作，且没有空位。法力提示在法力条下方，宠物提示在宠物条下方，斩杀提示（暗影灼烧）固定在建议栏最外侧。左侧冷却技能位于其上方。每个专精都有自己的建议列表，优先级从左到右递减。列表跟随你的天赋，或你在 `/fhud` 中选择的专精。每条规则都是一个 ForeverAuras 原生判断（DoT 或增益缺失、触发效果、技能可用、或生命/法力阈值），并且只有学会对应技能后才会载入。上表（英文部分）列出了全部九个职业的规则。客户端不允许插件读取战斗中的数值，因此无法在规则之间比较并只给出“下一个技能”；所有满足条件的建议会同时显示。

0.9 的术士列表（无天赋时仍使用）：
- 法力不高于 30% 时建议生命分流；
- 战斗中目标缺少腐蚀术或献祭时提示；
- 暗影冥思触发时提示；
- 宠物生命不高于 35% 时建议生命通道。

**收起时的印记与托盘。** 脱离战斗且无敌对目标时，界面收起为更大的印记，下方的精简托盘显示：
- 灵魂碎片；
- 缺失的维持类增益；
- 进食、饮水与进食充分。

鼠标悬停在印记上会以淡淡的虚影预览整个界面，点击即可展开。

**安装检查。** 插件比光环新、或光环缺失时，ForeverHUD 会在登录时提示。`/fhud` 中也会以红字显示，并附 **安装/更新光环** 按钮。脱战收起时，印记下方的托盘一行内还会出现一个发光的齿轮图标，与其他提示排成一条水平线：悬停或点击这一行即可查看原因并安装或更新。

**按职业保存的设置（`/fhud`）：** 模块、冷却排列（Forever 或职业方案）、施法条、位置、缩放与透明度。全部支持英文与简体中文。**调整界面大小：** 使用 `/fhud` → 位置与缩放 中的 **缩放**，游戏 **选项 → 插件** 列表中 ForeverHUD 页面的 **界面大小**，或直接输入 `/fhud 80`（或 `/fhud 80%`）：60% 到 160%，整个界面（包括文字）一起缩放。

### 安装与更新

1. 先安装 **[ForeverAuras](https://github.com/neroxrw/foreverauras)**。当前校验的安装源码版本为 1.3.7，无限服接口版本为 `16001`。ForeverHUD 将其声明为依赖，未安装时不会加载。
2. 下载[发布 ZIP](https://github.com/tomqwu/wow_forever_weakaura/releases)，把 **`ForeverHUD/`** 放入当前客户端的 `Interface/AddOns/`，TOC 文件应直接位于该文件夹中。
3. 启用 ForeverHUD 与 ForeverAuras，然后输入 **`/reload`**。
4. 脱离战斗后打开 **`/fa`**。**ForeverHUD | Core** 和当前职业会出现在 **待安装（ready to be installed）**（首次安装）或 **更新** 列表中（旧版 ForeverHUD 组）。逐个点击后，ForeverAuras 会打开自己的导入窗口，由你确认 **导入** 或 **更新**。请先安装核心。**`/fhud install`** 会打开下一个缺失或较旧的导入（先核心，后职业）；完成后再输入一次 **`/fhud install`** 安装第二个。
5. 已有分组请选择 **更新（Update）**，不要导入为副本。更新仅涉及该分组，保留其原有合并父组及其他职业。在更新窗口的 *What do you want to do?* 下选择 **Update Auras（更新光环）**。首次安装后，ForeverAuras 会默认选中 **Create a Copy（创建副本）**，这会多出一个 `ForeverHUD | Warlock 2` 之类的分组；更新一次后会默认选中更新。如果已生成副本，请在 `/fa` 中删除整个 `… 2` 分组后重新更新。
6. 输入 **`/fhud`** 或 **`/foreverhud`** 配置。ForeverHUD 版本之间升级保留位置和偏好；**位置与缩放 → 重置位置** 只重置 X/Y。

**从 0.4 升级到 0.5。** 条形和原生行已从各职业组移入核心，旧职业组会让它们显示两次。安装了 0.4 职业组时，ForeverHUD 会在登录时提示，`/fhud install` 也会等待其删除。请在 **`/fa`** 中删除 **`ForeverHUD | <职业>`**，然后按第 4 步安装核心和当前职业。`/fhud` 设置保持不变。

**从 Eclipse（0.3.5 及更早）迁移。** 插件文件夹、设置和光环名称都已更改，旧内容不会自动迁移，需要清理一次：

1. 退出游戏，删除 **`Interface/AddOns/EclipseHUD`**，再放入 **`ForeverHUD/`**。
2. 登录游戏。若旧插件或任何 `Eclipse | …` 光环仍存在，ForeverHUD 会提示。
3. 在 **`/fa`** 中删除所有 **`Eclipse | …`** 组（合并组 `Eclipse | Class Combat HUD` 以及散放的 `Eclipse | <职业> | …` 条目）。ForeverHUD 不会使用它们。
4. 按上面第 4 步安装当前职业。设置恢复为默认值：请在 `/fhud` 中重新设置位置、缩放与模块。

随附的导入始终与已安装的配套插件一致。只提供核心和当前所玩的职业；如需安装或更新其他职业，请登录该职业的角色（核心为共用，只需安装一次）。ForeverAuras 通过每个显示上的 `wago.io/forever-hud-<core|职业>/<构建号>` 标记识别更新：它只读取构建号，不会连接 wago.io；若 `/fa` 中显示该链接，可忽略。

**手动导入**仍然可用：把 ZIP 内 **`imports/`** 中的 **`ForeverHUD-Core.txt`**、再把职业文件粘贴到 **`/fa` → 导入**。可选的 **`ForeverHUD-All-Classes.txt`** 用于安装或更新包含核心与九职业的合并组。0.5 导入需要 0.5.0 配套插件（导入接口 2）；旧字符串和 Eclipse 字符串都不适用。ZIP 同时包含核心文件、九份职业文件、合并文件，以及大小和 SHA-256 清单。

### 光环结构

**`ForeverHUD | Core`** 存放所有职业共用的内容，对九职业都加载，并遵循当前职业的 `/fhud` 设置：

| 核心分区 | 内容 |
| --- | --- |
| Resources（资源） | 生命值与当前资源（法力、怒气、能量；颜色随资源类型变化） |
| Native rows（原生行） | 冷却管理器中的溢出冷却、辅助技能与装备物品 |
| Native auras（原生光环） | 原生自身效果图标与可选的持续时间条 |
| Cast（施法条） | 可选的 ForeverHUD 施法条，使用职业强调色 |

每个职业是一个组，其直接子项只有分区组，没有散放的显示：

| 职业分区 | 内容 |
| --- | --- |
| Frame（框架） | 底座、流动符文、战斗特效、徽记、标题（绘制在较低层，位于核心条形之下） |
| Resources（资源） | 宠物生命、灵魂碎片/连击点/挥击计时/图腾（仅限拥有这些的职业） |
| Primary（主技能） | 技能两翼：左侧 Essential（伤害），右侧 Utility |
| Utility（辅助） | 仅冷却中显示的防御/进攻/控制小图标行 |
| Auras（光环） | 目标效果（生命条上方框架上的 DoT 行）、自身效果、维持类光环（资源条右侧）、提醒、武器涂层 |
| Nameplates（姓名板） | 可选的姓名板减益图标 |
| Alerts（提示） | 不可见的就绪提示触发器 |

两个组都挂在同一个 ForeverHUD 锚点上，拖动、缩放和透明度会一起生效。分区位于 `(0,0)`，因此每个显示的位置不变；ForeverHUD 版本之间显示名称与 ID 保持稳定，0.5.0 为移入核心的显示使用了新名称。

**如果导入或更新中途停止**（`/fa` 列表顶层出现散放的 `ForeverHUD | <职业> | …` 条目，条形停在屏幕中央且无法拖动）：说明 ForeverAuras 在恢复这些父组之前停止了导入，再次更新也无法重新挂回。ForeverHUD 会在登录时检测到这种情况（核心和当前职业）并提示，`/fhud install` 也会拒绝在此状态下导入（`/fhud install force` 可强制）。请删除提示中列出的所有顶层 `ForeverHUD | <职业>`（或 `ForeverHUD | Core`）条目，输入 `/fhud install`（或重新导入文件），并等导入窗口完成后再 `/reload`。`/fhud` 设置单独保存，不受影响。如果再次停止，请用 `/console scriptErrors 1` 打开 Lua 错误提示，并报告错误内容。

| 分组 | 独立导入 |
| --- | --- |
| 核心（所有职业） | [核心导入](dist/classes/ForeverHUD-Core.txt) |
| 术士 | [术士独立导入](dist/classes/ForeverHUD-Warlock.txt) |
| 战士 | [战士独立导入](dist/classes/ForeverHUD-Warrior.txt) |
| 法师 | [法师独立导入](dist/classes/ForeverHUD-Mage.txt) |
| 牧师 | [牧师独立导入](dist/classes/ForeverHUD-Priest.txt) |
| 盗贼 | [盗贼独立导入](dist/classes/ForeverHUD-Rogue.txt) |
| 德鲁伊 | [德鲁伊独立导入](dist/classes/ForeverHUD-Druid.txt) |
| 猎人 | [猎人独立导入](dist/classes/ForeverHUD-Hunter.txt) |
| 萨满祭司 | [萨满祭司独立导入](dist/classes/ForeverHUD-Shaman.txt) |
| 圣骑士 | [圣骑士独立导入](dist/classes/ForeverHUD-Paladin.txt) |

### 配置冷却管理器，并保留右侧持续时间条

打开 **`/fhud` → 战斗行为 → 冷却排列 → 系统冷却管理器（Forever）**。ForeverHUD 沿用系统中已学技能的主要、辅助、装备分组与顺序，但默认**只在真实冷却运行时显示冷却图标，排除仅有公共冷却的情况**；没有真实冷却在运行时，该行为空。Life Tap、Corruption 等没有独立冷却的填充技能不会常驻占位；瞬发技能也可能有真实冷却，不能仅凭“瞬发”判断。原生动态组会紧凑排列当前显示的图标。可选的 **职业方案（Class plan）** 是另一种有固定优先级的技能展示布局。

在游戏的 **Cooldown Settings（冷却设置）** 中调整 Essential、Utility、Items 与 Not Displayed。配置窗口中的灰色条目不代表角色已学会；战斗中提出的修改在脱战后应用。

**伤害在左，其余在右。** 由上述分组决定左右：
- **左侧（生命条上方）：** 你在目标身上的 **DoT** 排成一行，直接贴在生命条上方的框架上；其上方是前四个 **Essential** 条目（伤害冷却）。可选的持续时间条（DoT 与触发剩余时间）也在左侧。
- **右侧（资源条上方）：** 你的**自身增益**排成一行贴在资源条上方（含战斗怒吼提醒与武器涂层），其上方是前四个 **Utility** 条目（防御、控制、辅助），再上方是原生增益行。**恶魔护甲**等维持类增益位于资源条旁。
- **界面下方：** Essential 溢出行在左，Utility 与物品溢出行（及萨满图腾）在右。
- 要把技能移到另一侧，请在冷却设置中把它在 Essential 与 Utility 之间拖动。
- 更多条目进入界面下方的行。
- 在 `/fhud` 中关闭 **辅助技能** 时，右翼为空。
- **职业方案** 遵循同样规则：攻击在左，冷却与辅助在右。

**CDM 指南更正：** v0.3.3 ZIP 内 README 中把系统 Essential/Utility 设为 Hidden 的建议已被本页取代。请保持 Always，保证原生更新事件继续工作。已发布的文件保持不变。

**保留游戏原有右侧 Tracked Bars：**

1. 在 **`/fa`** 顶部工具栏，**不要勾选 Hide Blizzard's CDM**。这个总开关会隐藏四类系统窗口，也包括持续时间条。
2. 保持游戏冷却管理器启用。在 **游戏菜单 → 编辑模式** 中，把 **Essential、Utility、Tracked Buffs、Tracked Bars → Visibility（可见性）** 保持为 **Always（始终）**。系统 **Hidden** 会注销窗口更新事件，可能使镜像追踪失效。
3. 如果也使用系统冷却图标，可关闭重复的 **ForeverHUD 主要技能 / 辅助技能** 模块。FA 总隐藏开关不能单独隐藏图标而保留系统持续时间条；同时保留系统条与 ForeverHUD 图标时，可能仍有重复的系统图标。
4. 使用系统持续时间条时，可让 **`/fhud` → 显示模块 → 持续时间条（ForeverHUD）** 保持关闭。

**改用 ForeverHUD 持续时间条：** 先启用 **持续时间条（ForeverHUD）**。它通过 ForeverAuras 原生 CDM 光环进度，在右侧显示你配置的 Tracked Bars 中当前激活的 DoT、控制效果和触发效果。确认启用后，才使用 **Hide Blizzard's CDM** 隐藏系统窗口；原生追踪继续开启，此方案下系统追踪窗口保持 Always。ForeverHUD 不会自动修改这些全局设置。之后返回系统 CDM 时，取消全局隐藏，并把相应系统窗口的可见性恢复为 Always。

可选命令 **`/fa cdmsetup`** 或 **Set Up CDM** 会先询问确认，再备份/复制布局、追踪目录条目、恢复隐藏的技能冷却、设为 Always、隐藏四类系统窗口并重载。它会改变前面的布局与可见性选择，不要把它当成“只隐藏某一排”的开关。

用户提供的游戏内配置参考图，**不代表 ForeverHUD 当前版本已通过游戏实测**：

| 冷却分组 | 持续时间条 |
| :---: | :---: |
| [<img src="docs/images/native-warlock-cooldowns.png" width="300" alt="术士系统冷却配置">](docs/images/native-warlock-cooldowns.png) | [<img src="docs/images/native-warlock-tracked-bars.png" width="300" alt="术士系统持续时间条">](docs/images/native-warlock-tracked-bars.png) |

### DoT 剩余时间与技能冷却是两回事

Corruption、Immolate 在目标身上持续生效时，技能本身可以已经可用。**效果剩余时间** 应在 **目标持续效果** 或 **持续时间条** 中显示，不应伪造成技能冷却。启用 **显示 → 目标持续效果**，选中敌对目标并施放已学技能；该行只显示原生观测到的自身施加效果，不会为缺失或不可读状态估算时间。你可以保留系统条、使用 ForeverHUD 条，或使用紧凑图标；只需要一种展示时，关闭重复的一项即可。

### 选择施法条

打开 **`/fhud` → 战斗行为 → 施法条显示**，点击按钮循环选择：

| 选择 | ForeverHUD 施法条 | 系统施法条 |
| --- | --- | --- |
| 系统施法条 | 关闭并卸载追踪 | 正常保留 |
| ForeverHUD 施法条 | 启用 | 仅在 ForeverHUD 施法显示已加载且启用时抑制 |
| 同时显示 | 启用 | 正常保留 |

安全默认是**只保留系统施法条**。旧版默认同时显示的配置会迁移到此选项；之前明确启用 ForeverHUD 抑制系统条的设置会保留。**显示 → ForeverHUD 施法条** 也可启用或关闭 ForeverHUD 选项。禁用 ForeverHUD 或导入的施法显示不可用时，会释放对系统施法条的控制；其他插件可能仍有自己的控制。战斗中修改会等脱战后应用。

以下为使用样例数据的浏览器预览，不是游戏截图：

| 仅系统条 | 仅 ForeverHUD 条 | 明确同时显示 |
| :---: | :---: | :---: |
| [<img src="preview/casting/warlock-default.png" width="260" alt="系统施法条样例">](preview/casting/warlock-default.png) | [<img src="preview/casting/warlock-foreverhud.png" width="260" alt="ForeverHUD 施法条样例">](preview/casting/warlock-foreverhud.png) | [<img src="preview/casting/warlock-both.png" width="260" alt="同时显示样例">](preview/casting/warlock-both.png) |

### 展开、收起与移动

- **左键点击徽记：** 脱战时展开检查；**再点一次收起**，即使仍选中同一敌对目标也能收起。更换目标或进入战斗后恢复自动规则。点击展开会保持，直到取消；`/fhud inspect` 和设置中的预览按钮则是临时展开。
- 战斗事件立即开始动画，滑动和淡入淡出约半秒完成。启用 **战斗 → 展开与收拢动画** 保留平滑效果；布局刷新不会跳到动画终点。脱战且没有目标/检查条件时立即开始收起，单独丢失目标则保留五秒延迟。
- 收起主要 HUD 时，生效中的持续效果、追踪条和施法条仍遵循各自规则。
- **右键打开设置。** 解锁后拖动徽记；X/Y、缩放、透明度与模块按职业保存。战斗中延迟根布局修改；重置位置保留其他选项。
- 生命为深红，法力为蓝色，能量为金色，怒气为橙色，并保留文字标签。常驻增益位于侧边；姓名板效果默认关闭。关闭模块会卸载其追踪。

**小地图按钮收纳盒：** ForeverHUD 在小地图边缘放一个显示职业徽记的按钮，可拖动它沿小地图移动。

- **鼠标悬停：** 打开带边框的收纳盒，按名称顺序列出其他插件的小地图按钮。第一格打开 ForeverHUD 设置。
- **收纳盒中的按钮**保留各自的点击和提示。点击其中一个会关闭收纳盒；鼠标离开两秒或按 Esc 也会关闭。
- **左键**点击 ForeverHUD 按钮打开设置，**右键**展开或收起界面。
- **收纳范围：** 只收纳有名称、未受保护的插件按钮（LibDBIcon、ForeverCore 等）。系统小地图控件、地图标记和受保护框体不会被改动，战斗中也不会移动任何按钮。
- **关闭方法：** 取消 **小地图 → 收纳其他插件的小地图按钮** 或输入 `/fhud buttons off`，所有按钮会回到原位并恢复拖动。取消 **小地图 → 小地图按钮** 或输入 `/fhud minimap off` 会隐藏 ForeverHUD 按钮，同样会归还所有按钮。这两项设置由你的所有角色共用。
- **与永恒战友同时使用：** 如果某个角色启用了永恒战友（Forever Classmate），由它的收纳盒收纳按钮，ForeverHUD 按钮也会放进那个收纳盒，不会再打开第二个。

交互与动画的示意预览：

| 收起 | 展开过程 | 点击展开 | 可选持续时间条 |
| :---: | :---: | :---: | :---: |
| [<img src="preview/states/warlock-idle.png" width="220" alt="收起样例">](preview/states/warlock-idle.png) | [<img src="preview/states/warlock-opening.png" width="220" alt="动画中间帧">](preview/states/warlock-opening.png) | [<img src="preview/states/warlock-click-open.png" width="220" alt="展开样例">](preview/states/warlock-click-open.png) | [<img src="preview/states/warlock-tracked-bars.png" width="220" alt="持续时间条样例">](preview/states/warlock-tracked-bars.png) |

### 九职业预览与验证范围

以下均为明确标注的浏览器样例，使用模拟已学技能、当前冷却、光环与数值，不是游戏截图，也不是完整功能对齐的证明。它们已为 0.9.0 重新截取，展示当前布局：伤害在左、其余在右、每行以各自的条为中心。预览不包含收起托盘与技能建议；游戏内截图见上方“功能”。[交互预览](https://github.com/tomqwu/wow_forever_weakaura/blob/main/preview/index.html)包含无伪造真实冷却的升级样例、分组/职业方案、施法条选择、重复点击开合与形态资源颜色。

| 术士 | 战士 | 法师 |
| :---: | :---: | :---: |
| [<img src="preview/classes/warlock.png" width="260" alt="术士">](preview/classes/warlock.png) | [<img src="preview/classes/warrior.png" width="260" alt="战士">](preview/classes/warrior.png) | [<img src="preview/classes/mage.png" width="260" alt="法师">](preview/classes/mage.png) |

| 牧师 | 盗贼 | 德鲁伊 |
| :---: | :---: | :---: |
| [<img src="preview/classes/priest.png" width="260" alt="牧师">](preview/classes/priest.png) | [<img src="preview/classes/rogue.png" width="260" alt="盗贼">](preview/classes/rogue.png) | [<img src="preview/classes/druid.png" width="260" alt="德鲁伊">](preview/classes/druid.png) |

| 猎人 | 萨满祭司 | 圣骑士 |
| :---: | :---: | :---: |
| [<img src="preview/classes/hunter.png" width="260" alt="猎人">](preview/classes/hunter.png) | [<img src="preview/classes/shaman.png" width="260" alt="萨满祭司">](preview/classes/shaman.png) | [<img src="preview/classes/paladin.png" width="260" alt="圣骑士">](preview/classes/paladin.png) |

光环归属、持续时间、层数、冷却、充能、资源与受限数值渲染均交给 ForeverAuras 原生触发器；不使用战斗记录重建或猜测刷新时间。术士护甲按原生状态显示，不把未知状态当作“缺失”。[游戏内验证](docs/validation.md)仍待完成；[持久清单](docs/feature-parity-plan.md)分别记录源码事实、实现与证据。

排查时可脱战运行 **`/fhud spells`**，打印已学技能、原生 CDM 分组及挂接诊断。此客户端的 Lua 错误位于 **`_forever_/Logs/General.log`**。此前大量错误弹窗还涉及独立的 AckisRecipeList 生命预测污染错误，本项目未修改该插件。

如果觉得装了 ForeverHUD 后游戏变慢，输入 **`/fhud perf`**，玩一分钟（拾取、Tab 切换目标、战斗）后再输入一次。第二次报告会显示 ForeverHUD 和 ForeverAuras 每帧占用的 CPU 时间（取自游戏自带的插件性能分析器，若客户端提供），ForeverHUD 重新检查技能和更新界面的次数，以及触发重新检查的事件。界面上的图标和条由 ForeverAuras 绘制，其开销计在 ForeverAuras 名下；`/fa pstart`、`/fa pstop` 和 `/fa pprint` 可按光环细分。

### 构建与版权

需要 Python 3.11+、Lua 5.1 和构建依赖：

```bash
python -m pip install -r requirements-dev.txt
python scripts/build.py
python scripts/check.py
python scripts/preview.py
lua tests/native-schema.lua /path/to/ForeverAuras
```

源码位于 `src/catalog.py`、`scripts/build.py` 和 `src/ForeverHUD/`；职业文件位于 `dist/classes/`，合并导出仍在 `dist/`。CI 校验版本、编码内容、图结构/ID、原生规则、包字节与浏览器行为。每次发布同步文档、相关截图和更新日志，已发布文件不可覆盖。详见[设计说明](docs/design.md)与[更新日志](CHANGELOG.md)。

功能组织参考用户提供的 Guos 战士 HUD，但不包含其脚本、图片、声音或品牌素材。原创 AI 绘画源图和提示词保存在 [assets/ai](https://github.com/tomqwu/wow_forever_weakaura/tree/main/assets/ai)，构建复用现有源图。游戏技能图标归暴雪所有。采用 GPL-2.0，见 [LICENSE](LICENSE)和[第三方声明](https://github.com/tomqwu/wow_forever_weakaura/blob/main/vendor/README.md)。
