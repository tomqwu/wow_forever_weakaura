# CurseForge listing kit

Everything for the ForeverHUD project on CurseForge, project ID **1801711** ([author dashboard](https://authors.curseforge.com/#/projects/1801711/)). Uploads go through CI (see *Uploading a file*).

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
| Other categories | Buffs & Debuffs; HUDs; Unit Frames; every class category (all nine classes are supported) |
| License | As in [`LICENSE`](../LICENSE) |
| Source | https://github.com/tomqwu/wow_forever_weakaura |
| Issues | https://github.com/tomqwu/wow_forever_weakaura/issues |

The GitHub social preview, [`assets/curseforge/social-preview.png`](../assets/curseforge/social-preview.png) (1280×640), is built from the logo by `python scripts/social_preview.py`. Upload it by hand under **Settings → General → Social preview**. Regenerate the logo with `python scripts/curseforge_logo.py`. It's a 3×3 grid of all nine painted class seals (`src/ForeverHUD/Media/crest-<class>.png`), Warlock in the centre, because ForeverHUD supports every class. No new art is generated.

## Description

The project description is [`assets/curseforge/description.md`](../assets/curseforge/description.md): features, then how to install, update, use and configure the addon, plus troubleshooting. It's a shortened form of the README's *Features*, *Install or update*, *Expand, fold and move* and cooldown sections, so update it with them.

The upload API can't change the project description, so paste it by hand: on the author dashboard, open the project's description. If the editor offers Markdown, choose it and paste the file's contents. Otherwise paste the rendered text from the file's GitHub page.

Screenshots: `docs/images/game-0.7.0-warlock-hud.png` (in game) and the gallery in `preview/classes/` (illustrative, labelled as such).

## Uploading a file

The **Publish ForeverHUD to CurseForge** workflow (`.github/workflows/curseforge.yml`, script `scripts/curseforge.py`) uploads an existing GitHub release. It's run by hand:

1. One-time setup: the GitHub environment **curseforge** (Settings → Environments) holds the secret `CURSE_FORGE`, a CurseForge API token from https://legacy.curseforge.com/account/api-tokens, and the variable `CURSEFORGE_PROJECT_ID` = `1801711`. Only `main` may use the environment, so a run from an unreviewed branch never gets the token. Rotate the token there.
2. Run it with the release tag and **dry run** on (the default). That downloads `ForeverHUD-vX.Y.Z.zip`, checks the TOC version against the tag and the interface (1.60 family), and finds exactly one CurseForge game version named after the interface (`16001` → `1.60.1`). Nothing is uploaded.
3. Run it again with **dry run** off. It uploads as **Beta**, named `ForeverHUD X.Y.Z`, with the GitHub release notes as the changelog.

```bash
gh workflow run curseforge.yml -f tag=v0.9.5 -f dry_run=true
```

The release ZIP also has `imports/`, `docs/`, `preview/` and the README for GitHub users. The CurseForge app would unpack those into `Interface/AddOns`, so the upload is a repacked ZIP holding only `ForeverHUD/`. After an upload, the script stores `curseforge-vX.Y.Z.json` on the GitHub release. A rerun sees that receipt and skips, so a file is never uploaded twice. The upload itself isn't retried. If a run fails after the upload started, check the project's **Files** tab before running it again. CurseForge may hold the file for review. Archive older files on the dashboard once a new one is approved.
