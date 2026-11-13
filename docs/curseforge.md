# CurseForge listing kit

Everything needed to create the ForeverHUD project on CurseForge. Creating the project, signing in and uploading need the owner's CurseForge account, so those steps are manual.

## Check first

- **Private-server policy.** ForeverHUD targets the WoW Forever client (interface `16001`) and its ForeverAuras fork. CurseForge doesn't allow projects made for private or unofficial servers, and Forever isn't one of its game versions. Read CurseForge's current project guidelines before listing; if Forever counts as unofficial, keep GitHub Releases as the only channel.
- **Dependency.** ForeverHUD needs **ForeverAuras**. If ForeverAuras isn't on CurseForge, link its GitHub page in the description, as below.

## Project details

| Field | Value |
| --- | --- |
| Name | ForeverHUD |
| Summary (≤ 255 characters) | A class combat HUD for WoW Forever: one shared Core plus your class, damage left and everything else right, native combat-safe tracking, a retracted seal and tray, and spell suggestions. |
| Logo | [`assets/curseforge/logo-400.png`](../assets/curseforge/logo-400.png) (400×400). A 256 px copy is alongside it. |
| Primary category | Combat |
| Other categories | Buffs & Debuffs; HUDs; Class: Warlock (and the other classes); Unit Frames |
| License | As in [`LICENSE`](../LICENSE) |
| Source | https://github.com/tomqwu/wow_forever_weakaura |
| Issues | https://github.com/tomqwu/wow_forever_weakaura/issues |

Regenerate the logo with `python scripts/curseforge_logo.py`. It's composed from the painted seal master `assets/ai/warlock-seal.png`; no new art is generated.

## Description

Paste this as the project description; it's a shortened form of the README *Features* section.

> **ForeverHUD** is a class combat HUD for WoW Forever, built on **ForeverAuras** (required). The addon carries its own auras, so `/fa` offers them for install. No import string to paste.
>
> - **One Core plus your class:** health, resource, cast bar and native cooldown rows are shared, and your class adds its spells, effects and art.
> - **Damage left, everything else right:** DoTs and damage cooldowns over Health; your buffs, utility cooldowns and upkeep over Mana. Rows are centred on each bar and stay centred in combat.
> - **Native and combat-safe:** auras, cooldowns, resources and casts come from ForeverAuras' own triggers. No combat-log guessing.
> - **Retracted seal and tray:** out of combat it folds to a seal with Soul Shards, missing buffs and food. Hover to peek, click to open.
> - **Reminders and suggestions:** a missing or expiring Demon Armor (and other upkeep), plus Warlock spell suggestions such as Life Tap at low mana.
> - **Install check, settings per class (`/fhud`), English and Simplified Chinese.**

Screenshots: `docs/images/game-0.7.0-warlock-hud.png` (in game) and the gallery in `preview/classes/` (illustrative, labelled as such).

## Uploading a file

1. Download `ForeverHUD-vX.Y.Z.zip` from the matching [GitHub release](https://github.com/tomqwu/wow_forever_weakaura/releases). Its SHA-256 is in the `.sha256` asset.
2. On the project's **Files** tab, choose **Upload file**, select the ZIP, set the release type (**Beta** for prereleases), and paste the changelog section for that version from [`CHANGELOG.md`](../CHANGELOG.md).
3. Game version: pick the closest available client version, and say in the file notes that it's for WoW Forever (interface 16001).

Automated uploads (a GitHub Action with a CurseForge API token) can come later. That needs the owner to create a token and add it as a repository secret.
