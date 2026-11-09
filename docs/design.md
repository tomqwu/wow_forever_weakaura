# Design and reference notes

## Reference audit

The supplied Guos Warrior Combat HUD v1.2.4 decodes as a transmission-v2000 group, exported with ForeverAuras 1.3.0 and internal schema 91. It contains 135 descendants. The local companion folder contains class artwork and MP3 voice assets.

The useful behavioral patterns are a strong central emblem, resource bars near the character, prominent primary abilities, secondary utility abilities, native aura tracking, a separate cast bar, optional effects, and settings that reduce clutter. The reference also includes weapon-dependent swing layouts, talent selection and voice alerts.

Eclipse implements its own art, module catalog, controls and grouping. It does not transplant the reference's custom selection scripts, assets or voice files. This first version uses learned-spell filtering across talent trees rather than recommending a rotation or inferring a spec. Voice recordings and a talent-specific priority system are outside v0.1.0.

## Architecture

- `EclipseHUD`: small companion for original media, SavedVariables, class profiles, UI anchor, settings and load-flag dispatch. It never reads combat aura/cooldown/resource values.
- `Eclipse | Class Combat HUD`: one imported root anchored to `EclipseHUDAnchor`.
- Nine nested class groups. Every descendant has an explicit class load condition and a module load flag.
- Native modern aura icons for player effects, target effects and opt-in nameplate effects. Fixed slots avoid combat-time reflow of protected native displays.
- Native ordinary triggers for cooldowns, resources, item count, casting, totems and swing timers. Dynamic rows contain ordinary cooldown icons only.
- `ECLIPSE_HUD_UPDATE`: event-based visibility checks. No every-frame polling. The only helper timer is a cancellable hover grace timer.
- Preferences are changed outside combat. Edits made during combat are queued and flushed after combat, before refreshing the native ancestry's layout.

## Layout

All dimensions are UI units at 100% scale. The 512×128 decorative chassis centers on the saved anchor. The seal centers 13 units above it. Health/resource bars are 161×13 at x ±130, y +13; primary icons are 42×42 at y −45; target effects are 32×32 at y −100; casting is 300×13 at y −148; utility icons are 30×30 at y −195. Player effects sit above the seal. The minimum artwork texture dimensions are powers of two, with uncompressed RGBA TGA output.

## Compatibility evidence

- Public ForeverAuras source inspected at `f55acae0eeda4a4d11b3fa3d09121dc1c4be3faa` (public TOC 1.3.2).
- Installed ForeverAuras TOC reports 1.3.5. Both versions' actual native aura schema validators are exercised with a mocked frame environment.
- `Transmission.lua` establishes the `!WA:2!` / LibSerialize / LibDeflate export envelope.
- `Prototypes.lua` establishes class/learned-spell/module load conditions and built-in trigger schemas.
- `BlizzardAuraDisplay.lua`, `SecretAuraAppearance.lua`, `SecretAuraSingle.lua`, `SecretAuraConditions.lua`, and `SecretAuraFlow.lua` validate native effect displays.
- Forever API declarations were checked against the local `Gethe/wow-ui-source` Forever tree and its public mirror. Native helper UI uses the installed client interface version `16001`.
- The installed DungeonsForeverSpell bilingual spell catalog supplied additional seed cross-checks. Conflagrate's level-25 seed is `1293817`; Wrack is `1316697`; Penance's first rank is `402174`; Riptide's first rank is `408521`; Holy Shock's first rank is `1311606`. These remain candidates gated by the live learned-spell check, not a substitute for client evidence.

## Boundaries

The HTML/PNG preview uses actual Eclipse decorative media with representative spell tiles and sample values. It does not show a running WoW client. Mock tests establish serialization, schema acceptance and addon logic; they cannot establish combat readability, visual stacking, secure-widget behavior, or real SavedVariables persistence.
