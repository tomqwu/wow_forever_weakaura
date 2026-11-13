# ForeverHUD · Class Combat HUD

<p align="center"><img src="assets/curseforge/logo-256.png" width="160" alt="ForeverHUD logo: the nine class seals"></p>

## English

**Version 0.10.0 — rotation suggestions for every class and spec (prerelease).** Suggestions now follow your spec: each of the nine classes has a list per spec (see *Spell suggestions*), and Warlocks without talents keep the 0.9 list. Update your class in `/fa`, choosing **Update Auras**. **0.9.7 — suggestions stay right above your DoTs.** Spell suggestions no longer jump up when you have left-side (Essential) cooldowns; those cooldowns now sit above the suggestions instead. Update your class in `/fa`, choosing **Update Auras**. **0.9.6 — suggestions on the damage side.** Spell suggestions now sit on the left, centred over Health, right above your DoTs. Update your class in `/fa`, choosing **Update Auras**. **0.9.5 — tray icons really match.** The Soul Shards tray icon now uses the same tight frame as the reminder icons beside it, so the frames no longer differ in size or overlap. The tray row also has a little more spacing. Update your class in `/fa`, choosing **Update Auras**. **0.9.4 — hover to peek.** Hovering the folded seal out of combat shows the whole HUD as a faint ghost, inviting a click. Click to open it fully; move away and it folds straight back. Entering combat drops the ghost to full opacity. **0.9.3 — matching tray icons.** Soul Shards now has the same dark inner ring as the reminder icons beside it, so every tray icon looks alike. ForeverAuras draws reminders with the game's own aura button, which can't be restyled. Update your class in `/fa`, choosing **Update Auras**. **0.9.2 — one-row tray.** The retracted tray is a single centred horizontal row under the seal, with every icon in the same style. Soul Shards show one count in the corner, like the other icons. **0.9.1:** the tray no longer shows health % and mana %. It keeps only Soul Shards, missing upkeep buffs and food, drink or Well Fed. Update your class in `/fa`, choosing **Update Auras**. **0.9.0 — spell suggestions.** Warlocks get a row of suggestions above the seal, in priority order from left to right:
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

**One Core plus your class.** ForeverHUD ships its auras inside the addon:
- `ForeverHUD | Core`: health, resource, cast bar, native cooldown rows and tracked buffs, shared by every class.
- `ForeverHUD | <Class>`: your class's art, spells and effects.

Install or update both from `/fa`, or with `/fhud install`.

**Damage left, everything else right, centred on each bar.**
- **Left (over Health):** your DoTs on the target, with the first four **Essential** cooldowns above them.
- **Right (over Mana):** your buffs, or the Cooldown Manager's tracked buffs, with the first four **Utility** cooldowns above them. Upkeep reminders sit past the bar.
- **Centring:** each row starts at the middle of its bar and grows both ways. The DoT and buff rows stay centred in combat (ForeverAuras' native Modern Aura Groups).

**Native, combat-safe tracking.** Auras, cooldowns, resources and casts come from ForeverAuras' own triggers. The addon never reads combat values in Lua or guesses timers.

**Upkeep reminders.** Demon Armor, Arcane Intellect, Fortitude and Mark of the Wild show only when missing or in their last 15 seconds.

**Spell suggestions (every class, per spec).** Shown on the left over Health, right above your DoTs. Left-side cooldowns sit above them. Each spec has its own list, highest priority on the left. The list follows your talents, or the spec you pick in `/fhud`. Every rule is a single native ForeverAuras check (missing DoT or buff, proc up, spell usable, or a health/mana threshold), and a rule only loads once you know its spell.

| Class | Spec | Suggestions (left to right) |
| --- | --- | --- |
| Warlock | Leveling (no talents) | Life Tap ≤30% mana, Corruption, Immolate, Shadow Trance, Health Funnel (pet ≤35%) |
| | Affliction | Life Tap, Corruption, Bane of Agony, Siphon Life, Shadow Trance |
| | Demonology | Life Tap, Corruption, Immolate, Bane of Agony, Health Funnel |
| | Destruction | Life Tap, Immolate, Conflagrate (usable), Backlash, Shadowburn (target ≤25%) |
| Mage | Arcane / Fire / Frost | Evocation ≤20% mana; Missile Barrage / Improved Scorch, Hot Streak / Fingers of Frost |
| Priest | Discipline / Holy | Surge of Light; Penance / Prayer of Mending usable |
| | Shadow | Shadowform, Shadow Word: Pain, Vampiric Embrace, Devouring Plague, Mind Blast usable |
| Rogue | all | Slice and Dice; Rupture (Assassination, Combat) or Hemorrhage (Subtlety) |
| Druid | Balance | Innervate ≤30% mana, Moonfire, Faerie Fire, Clearcasting |
| | Feral | Faerie Fire, Rake, Rip, Clearcasting |
| | Restoration | Innervate, Clearcasting |
| Hunter | all | Hunter's Mark, Serpent Sting, Mend Pet (pet ≤40%); Survival adds Counterattack and Mongoose Bite |
| Shaman | Elemental | Flame Shock, Lightning Shield |
| | Enhancement | Lightning Shield, Maelstrom Weapon, Stormstrike usable, Flame Shock |
| | Restoration | Mana Tide Totem ≤30% mana, Riptide usable |
| Paladin | Holy | Holy Shock usable |
| | Protection | Holy Shield, Consecration, Judgement |
| | Retribution | Hammer of Wrath, Judgement, Consecration |
| Warrior | Arms / Fury / Protection | Mortal Strike / Bloodthirst, Whirlwind / Shield Slam usable (procs and Rend keep their own rows) |

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

**Install check.** If the addon is newer than your auras, or they're missing, ForeverHUD says so at login. `/fhud` also shows it in red, with an **Install / update auras** button.

**Settings per class (`/fhud`):** modules, cooldown layout (Forever or Class plan), cast bar choice, position, scale and opacity. Everything is in English and Simplified Chinese.

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
| Primary | Ability wings: Essential (damage) left, Utility right; Warrior usable-proc cues |
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
- **Below the HUD:** Essential overflow (and Warrior procs) on the left, Utility and item overflow (and Shaman totems) on the right.
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

Corruption/Immolate can be active on a target while their ability is ready. Their **remaining effect duration** belongs in **Target effects** or **Tracked Bars**, not a fabricated spell cooldown. Enable **Modules → Target effects**, target an enemy and apply the learned spell. This row shows native player-owned target effects; missing/unreadable effects are not assigned guessed timers. You can use native bars, ForeverHUD's optional tracked-bar stack, or the compact target-effect icons. Disable a duplicate display if you only want one presentation.

### Choose a casting bar

Open **`/fhud` → Behavior → Cast bar display**. Click the control to cycle:

| Choice | ForeverHUD casting | Game casting |
| --- | --- | --- |
| Default game bar | Off; trackers unload | Available normally |
| ForeverHUD bar | On | Suppressed while the ForeverHUD display is loaded/enabled |
| Both bars | On | Available normally |

The safe default is the **game bar only**. Old overlapping defaults migrate to it; an existing explicit ForeverHUD-suppression choice is retained. **Modules → ForeverHUD cast bar** also enables/disables the ForeverHUD choice. Disabling ForeverHUD or an unavailable imported cast display releases its ownership of the game bar. Another addon can retain its own ownership. Changes requested in combat wait until combat ends.

Illustrative mode previews, using sample values rather than the game client:

| Game bar only | ForeverHUD bar only | Both (explicit) |
| :---: | :---: | :---: |
| [<img src="preview/casting/warlock-default.png" width="260" alt="Game bar sample">](preview/casting/warlock-default.png) | [<img src="preview/casting/warlock-foreverhud.png" width="260" alt="ForeverHUD bar sample">](preview/casting/warlock-foreverhud.png) | [<img src="preview/casting/warlock-both.png" width="260" alt="Both bars sample">](preview/casting/warlock-both.png) |

### Expand, fold and move

- **Left-click the seal:** expand for inspection; **click again to fold** out of combat, including with the same target selected. A new target/combat edge restores automatic behavior. Click inspection remains pinned until cancelled; `/fhud inspect` and the settings inspection button are temporary.
- Combat events start motion immediately; the slide/fade takes about half a second. Enable **Behavior → Unfold animation** for smooth motion. Layout refreshes preserve an in-progress transition. Combat exit folds immediately if no independent target/inspection condition holds; target loss alone has a five-second hold.
- Folding affects the main HUD. Active effects, tracked bars and casting keep independent rules.
- **Right-click:** settings. Unlock there, then drag the seal. X/Y, scale, opacity and module choices are per class; root changes defer in combat. **Reset position** preserves other preferences.
- Health is crimson, mana blue, energy gold and rage orange; labels provide another cue. Maintenance buffs sit beside the bar. Nameplate effects are off by default. Disabled modules unload their trackers.

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

**版本 0.10.0：所有职业与专精的输出建议（预发布）。** 技能建议现在跟随专精：九个职业的每个专精都有自己的列表；没有天赋的术士继续使用 0.9 的列表。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.7：技能建议始终紧贴 DoT 上方。** 有左侧（Essential）冷却技能时，技能建议不再上移；改为由这些冷却技能显示在建议上方。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.6：技能建议移到伤害一侧。** 技能建议现在位于左侧、生命条正上方居中，紧贴在 DoT 图标之上。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.5：托盘图标真正一致。** 灵魂碎片托盘图标现在与旁边的提醒图标使用相同的紧凑边框，不再大小不同或互相重叠；托盘这一行的间距也略微加大。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.4：悬停预览。** 脱离战斗时把鼠标悬停在收起的印记上，整个界面会以淡淡的虚影显示，提示可以点击。点击即可完全展开；移开鼠标则立即收回。进入战斗时虚影会恢复为完全不透明。**0.9.3：托盘图标风格一致。** 灵魂碎片现在与旁边的提醒图标一样带有深色内圈，托盘中所有图标外观一致（ForeverAuras 用游戏自带的光环按钮绘制提醒，无法另行修改样式）。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.2：单行托盘。** 收起时的托盘是印记下方居中的一行横排图标，所有图标风格一致；灵魂碎片与其他图标一样只在角落显示一个数字。**0.9.1：** 托盘不再显示生命与法力百分比，只保留灵魂碎片、缺失的维持类增益以及进食、饮水或进食充分。请在 `/fa` 中更新当前职业，并选择 **Update Auras（更新光环）**。**0.9.0：技能建议。** 术士在印记上方获得一行建议，从左到右按优先级排列：
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

**一个核心加你的职业。** ForeverHUD 的光环随插件附带：
- `ForeverHUD | Core`：生命、资源、施法条、原生冷却行与追踪增益，所有职业共用。
- `ForeverHUD | <职业>`：该职业的美术、技能与特效。

可在 `/fa` 中安装或更新两者，或输入 `/fhud install`。

**伤害在左，其余在右，以各自的条为中心。**
- **左侧（生命条上方）：** 你在目标身上的 DoT，其上方是前四个 **Essential** 冷却。
- **右侧（法力条上方）：** 你的增益（或冷却管理器的追踪增益），其上方是前四个 **Utility** 冷却。维持类提醒位于条外侧。
- **居中：** 每行从条的中点开始向两侧扩展。DoT 与增益行在战斗中也保持居中（ForeverAuras 原生 Modern Aura Group）。

**原生、战斗安全的追踪。** 光环、冷却、资源与施法都来自 ForeverAuras 自身的触发器。插件从不在 Lua 中读取战斗数值，也不猜测计时。

**维持类提醒。** 恶魔护甲、奥术智慧、真言术：韧与野性印记只在缺失或最后 15 秒时显示。

**技能建议（所有职业，按专精）。** 显示在左侧生命条上方、紧贴 DoT 图标；左侧冷却技能位于其上方。每个专精都有自己的建议列表，优先级从左到右递减。列表跟随你的天赋，或你在 `/fhud` 中选择的专精。每条规则都是一个 ForeverAuras 原生判断（DoT 或增益缺失、触发效果、技能可用、或生命/法力阈值），并且只有学会对应技能后才会载入。上表（英文部分）列出了全部九个职业的规则。客户端不允许插件读取战斗中的数值，因此无法在规则之间比较并只给出“下一个技能”；所有满足条件的建议会同时显示。

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

**安装检查。** 插件比光环新、或光环缺失时，ForeverHUD 会在登录时提示。`/fhud` 中也会以红字显示，并附 **安装/更新光环** 按钮。

**按职业保存的设置（`/fhud`）：** 模块、冷却排列（Forever 或职业方案）、施法条、位置、缩放与透明度。全部支持英文与简体中文。

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
| Primary（主技能） | 技能两翼：左侧 Essential（伤害），右侧 Utility；战士可用触发提示 |
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
- **界面下方：** Essential 溢出行（及战士触发提示）在左，Utility 与物品溢出行（及萨满图腾）在右。
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

Corruption、Immolate 在目标身上持续生效时，技能本身可以已经可用。**效果剩余时间** 应在 **目标持续效果** 或 **持续时间条** 中显示，不应伪造成技能冷却。启用 **显示模块 → 目标持续效果**，选中敌对目标并施放已学技能；该行只显示原生观测到的自身施加效果，不会为缺失或不可读状态估算时间。你可以保留系统条、使用 ForeverHUD 条，或使用紧凑图标；只需要一种展示时，关闭重复的一项即可。

### 选择施法条

打开 **`/fhud` → 战斗行为 → 施法条显示**，点击按钮循环选择：

| 选择 | ForeverHUD 施法条 | 系统施法条 |
| --- | --- | --- |
| 系统施法条 | 关闭并卸载追踪 | 正常保留 |
| ForeverHUD 施法条 | 启用 | 仅在 ForeverHUD 施法显示已加载且启用时抑制 |
| 同时显示 | 启用 | 正常保留 |

安全默认是**只保留系统施法条**。旧版默认同时显示的配置会迁移到此选项；之前明确启用 ForeverHUD 抑制系统条的设置会保留。**显示模块 → ForeverHUD 施法条** 也可启用或关闭 ForeverHUD 选项。禁用 ForeverHUD 或导入的施法显示不可用时，会释放对系统施法条的控制；其他插件可能仍有自己的控制。战斗中修改会等脱战后应用。

以下为使用样例数据的浏览器预览，不是游戏截图：

| 仅系统条 | 仅 ForeverHUD 条 | 明确同时显示 |
| :---: | :---: | :---: |
| [<img src="preview/casting/warlock-default.png" width="260" alt="系统施法条样例">](preview/casting/warlock-default.png) | [<img src="preview/casting/warlock-foreverhud.png" width="260" alt="ForeverHUD 施法条样例">](preview/casting/warlock-foreverhud.png) | [<img src="preview/casting/warlock-both.png" width="260" alt="同时显示样例">](preview/casting/warlock-both.png) |

### 展开、收起与移动

- **左键点击徽记：** 脱战时展开检查；**再点一次收起**，即使仍选中同一敌对目标也能收起。更换目标或进入战斗后恢复自动规则。点击展开会保持，直到取消；`/fhud inspect` 和设置中的预览按钮则是临时展开。
- 战斗事件立即开始动画，滑动和淡入淡出约半秒完成。启用 **战斗行为 → 展开与收拢动画** 保留平滑效果；布局刷新不会跳到动画终点。脱战且没有目标/检查条件时立即开始收起，单独丢失目标则保留五秒延迟。
- 收起主要 HUD 时，生效中的持续效果、追踪条和施法条仍遵循各自规则。
- **右键打开设置。** 解锁后拖动徽记；X/Y、缩放、透明度与模块按职业保存。战斗中延迟根布局修改；重置位置保留其他选项。
- 生命为深红，法力为蓝色，能量为金色，怒气为橙色，并保留文字标签。常驻增益位于侧边；姓名板效果默认关闭。关闭模块会卸载其追踪。

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
