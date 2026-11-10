# Eclipse · Class Combat HUD

An original ForeverAuras HUD for WoW Forever, with a Warlock-focused layout and **automatic switching across all nine classes**. Import once; the character's class chooses the active module. Each class keeps independent controls and layout preferences.

**Version 0.3.2 — native cooldown categories and maintenance placement (prerelease).** The default follows learned Essential entries in Forever's manager order, keeps Utility/item cooldowns separate and respects hidden entries. Health is crimson, mana blue, energy gold and rage orange. Long-duration upkeep has a separate side area; the class caption is removed. The [persistent checklist](docs/feature-parity-plan.md) records implementation and evidence. In-game acceptance remains open.

**The live placeholder defect was found:** v0.2.0 saved `secretFallback` on the display instead of inside `triggers`. ForeverAuras then followed the always-true visibility trigger when an aura was absent. Its actual fallback selector reproduces the old behavior and accepts the correction. **Update both the addon and the imported top-level group** to receive this fix.

## All nine class previews

**One import includes every class below.** In-game, the HUD automatically loads your current character's class. Each class has its own emblem, spell catalog and saved settings.

Click an image to enlarge it. These are behavior previews with sample values and spell thumbnails, not live game screenshots. Warlock uses an explicitly mocked level-23 learned list; the other images use declared learned fixtures. The interactive preview includes mock native-category and class-plan layouts, idle, hostile-target, combat-without-target and five-second target-loss close. Mock categories are not a capture of the user’s native manager.

| Warlock · 术士 | Warrior · 战士 | Mage · 法师 |
| :---: | :---: | :---: |
| [<img src="preview/classes/warlock.png" width="280" alt="Warlock HUD preview">](preview/classes/warlock.png) | [<img src="preview/classes/warrior.png" width="280" alt="Warrior HUD preview">](preview/classes/warrior.png) | [<img src="preview/classes/mage.png" width="280" alt="Mage HUD preview">](preview/classes/mage.png) |

| Priest · 牧师 | Rogue · 盗贼 | Druid · 德鲁伊 |
| :---: | :---: | :---: |
| [<img src="preview/classes/priest.png" width="280" alt="Priest HUD preview">](preview/classes/priest.png) | [<img src="preview/classes/rogue.png" width="280" alt="Rogue HUD preview">](preview/classes/rogue.png) | [<img src="preview/classes/druid.png" width="280" alt="Druid HUD preview">](preview/classes/druid.png) |

| Hunter · 猎人 | Shaman · 萨满祭司 | Paladin · 圣骑士 |
| :---: | :---: | :---: |
| [<img src="preview/classes/hunter.png" width="280" alt="Hunter HUD preview">](preview/classes/hunter.png) | [<img src="preview/classes/shaman.png" width="280" alt="Shaman HUD preview">](preview/classes/shaman.png) | [<img src="preview/classes/paladin.png" width="280" alt="Paladin HUD preview">](preview/classes/paladin.png) |

The preview also includes Druid caster/bear/cat forms and independent resource/pet controls. Bar labels identify health and the current resource; class colors remain on the artwork.

For interactive controls, download the repository and open [`preview/index.html`](preview/index.html) in a browser; use the class tabs across the top. GitHub displays the static gallery above.

## Install

Requires **[ForeverAuras](https://github.com/neroxrw/foreverauras)** with native modern-aura animation, CDM and resource-curve support. The current installed build is 1.3.7; native schemas and resource-curve behavior are also checked against the public source. WoW Forever interface: `16001`.

1. Download the ZIP from this repository's [Releases](https://github.com/tomqwu/wow_forever_weakaura/releases), or build it from source.
2. Copy **`EclipseHUD/`** into your active Forever client's `Interface/AddOns/` folder. `EclipseHUD.toc` must be directly inside that folder.
3. Enable **Eclipse | Class Combat HUD** and ForeverAuras. Use `/reload` after updating an already discovered addon. On a first install, make sure the client lists the new addon before importing.
4. Out of combat, enter **`/fa` → Import** and paste the entire contents of **`dist/Eclipse-Class-Combat-HUD.txt`** (the ZIP puts this text file at its root).
5. Import the **top-level group**. For later updates, update the existing group to preserve IDs and avoid duplicates.
6. Enter **`/eclipse`** or **`/ehud`** for settings. For the corrected default anchor, use **Position → Reset position**. Upgrades preserve your existing coordinates and preferences.

The ZIP contains the companion addon and the import. It does **not** bundle ForeverAuras. Both parts of Eclipse are needed. Importing does not replace your other auras or default UI; disable overlapping HUDs yourself if desired.

中文：先安装 ForeverAuras，将 `EclipseHUD` 文件夹放入当前无限服客户端的 `Interface/AddOns/`，然后通过 `/fa` 导入完整字符串。输入 `/eclipse` 调整界面。九职业自动切换，分别保存设置。当前版本仍需游戏内实测。

## Controls

- **`/eclipse`**: Modules, Behavior and Position tabs. Each class keeps its own settings. Behavior includes Forever/class-plan cooldown layouts, automatic/manual talent school, combat expansion, unfolding, resource flow, optional default-cast-bar suppression, Warrior swing mode and Fury Cleave preference.
- **Unlock**, then drag the center seal to move the HUD. Right-click the seal to open settings.
- Idle keeps the central emblem. A readable living hostile target or combat opens the main rows; combat exit starts closing immediately when no hostile target/inspection keeps it open. Losing only the target starts a five-second close delay. Settings or **`/eclipse inspect`** allow temporary inspection. Left-click the seal also inspects and pins/unpins optional hover utility.
- **`/fa`**: edit individual spells, size, placement, typography, colors and other ForeverAuras display settings. Prefer `/eclipse` for overall position, scale and opacity; those are restored from its per-class profile.
- Overall layout and preference changes made in combat wait until combat ends. **Reset position** changes only X/Y; **Reset this class** restores every preference for that class.
- Nameplate effects are **off by default**. Enable them explicitly to attach native player-owned effect icons to live nameplates.

Modules: resources, primary abilities, secondary combat cooldowns, target effects, player effects/procs, maintenance buffs, cast bar, pet/class resource, artwork, rune animation, nameplate effects, combat effects and audible alerts. Turning off a module clears its load flag so ForeverAuras unloads its trackers. An inactive class does not load its displays.

## Class coverage

| Class | Main resources and extra | Examples of tracked effects or cooldowns |
| --- | --- | --- |
| Warlock | Health, mana, demon health, carried Soul Shards | Corruption, Immolate, Bane of Agony/Doom, Siphon Life, Wrack, Bane of Havoc; Shadowburn, Conflagrate, Death Coil, Amplify Curse, Fel Domination; armor, Shadow Trance, Backlash |
| Warrior | Health, current power, main/off-hand swing | Mortal Strike, Bloodthirst, Shield Slam, Whirlwind; Rend, Sunder Armor; Flurry, Shield Block |
| Mage | Health, mana | Fire Blast, Arcane Power, Combustion; Pyroblast, Improved Scorch; Hot Streak, Fingers of Frost, Missile Barrage |
| Priest | Health, mana | Mind Blast, Power Infusion, Penance, Prayer of Mending; Shadow Word: Pain, Devouring Plague |
| Rogue | Health, energy, combo points | Adrenaline Rush, Blade Flurry, Evasion, Kick; Garrote, Rupture, Slice and Dice |
| Druid | Health, current form's power, combo points | Swiftmend, Barkskin, Innervate; Moonfire, Rake, Rip, Faerie Fire |
| Hunter | Health, mana, pet health, ranged swing | Aimed Shot, Multi-Shot, Rapid Fire, Bestial Wrath; stings and Hunter's Mark |
| Shaman | Health, mana, four native totem slots | Stormstrike, shocks, Elemental Mastery, Riptide; shields, Maelstrom Weapon |
| Paladin | Health, mana | Holy Shock, Divine Favor, Holy Shield, Consecration; Judgements and defensive cooldowns |

These are catalog candidates, **not proof that a particular character trained them**. Actual learned spellbook ranks/bases, localized metadata and learned native CDM identities qualify the displays. Passive abilities cannot become action slots. By default, up to eight learned native Essential entries occupy the two wings in manager order; additional Essential entries remain visible in an overflow row. Native Utility and equipped-item cooldowns have separate on-cooldown rows. Saved hidden placement is respected, and learned entries outside the authored catalog are included. Behavior → Cooldown layout → Class plan restores the optional school-based four-support/four-attack plans and their on-cooldown secondary groups. Native tracked buffs/counters remain separate from active maintenance buffs. Unending Breath and summoning are excluded from the combat slots. Modern aura icons show only native matching effects. Actual spell names and textures come from the client. English and Simplified Chinese control labels are included.

## Combat data

All aura presence, ownership, durations, stacks, resources, casting and cooldown rendering are delegated to ForeverAuras' built-in triggers. Modern aura slots are fixed during combat. There are no guessed refresh windows, combat-log reconstruction, rotation automation, or estimates of offscreen DoT timers. Armor is a native effect display; Eclipse does not infer that an unreadable armor aura is missing. The Blizzard cast bar remains available by default. Optional suppression preserves its latest show request and restores it on release. Audible alerts use original chimes, including client-owned aura Added sounds; no reference recordings are bundled.

A newer import detects an older in-memory companion and prints one install/reload instruction instead of calling missing helpers. Always `/reload` after installing the addon and before updating the import.

For spell problems, run **`/eclipse spells`** out of combat to print actual learned identities and native attachment/fallback diagnostics. The level-23 fixture is not a substitute for your real spellbook.

Read [the design and reference notes](docs/design.md) and [live validation checklist](docs/validation.md) for the precise scope and remaining checks.

## Develop

Python 3.11+ and Lua 5.1 are required. Artwork builds require the packages in `requirements-dev.txt` and a working Cairo installation. Preview screenshots additionally use Playwright Chromium.

```bash
python -m pip install -r requirements-dev.txt
python scripts/build.py
python scripts/check.py
python scripts/preview.py
# Optional: validate with a local ForeverAuras checkout's own native validators:
lua tests/native-schema.lua /path/to/ForeverAuras
```

The import is generated from `src/catalog.py` and `scripts/build.py`. AI-generated PNG masters and their exact prompts live in [`assets/ai/`](assets/ai/). Exported PNG previews and uncompressed RGBA TGA game assets live in `src/EclipseHUD/Media/`; small geometric rune accents retain SVG sources. The editable Lua/JSON export and import text live in `dist/`. Builds reuse the checked-in masters and do not call a paid generation API. The ZIP and its SHA-256 are produced locally and in CI. Do not hand-edit the encoded import.

## Credits and license

Inspired by the feature organization of the locally supplied **Guos Warrior Combat HUD v1.2.4**. Its import was inspected as a design reference. **No Guos scripts, artwork, sounds, names, or branding are included in this pack.** Eclipse's painted artwork was generated specifically for this project with the built-in image generation tool; exact prompts and source PNGs are included. Code and small geometric accents are authored for Eclipse.

[ForeverAuras](https://github.com/neroxrw/foreverauras), [Blizzard's Forever API source mirror](https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated), and the installed DungeonsForever spell catalog informed compatibility checks. The client remains the authority for actual learned spells.

GPL-2.0; see [LICENSE](LICENSE). Build-only serialization libraries retain their individual notices in [vendor/README.md](vendor/README.md). Game-provided spell artwork remains Blizzard's property and is not bundled here.
