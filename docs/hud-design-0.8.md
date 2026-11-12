# ForeverHUD 0.8 design: retracted seal and tray

Status: proposed on 2026-11-12, not implemented. Nothing here is game evidence.

## Request

The user showed a compact "retracted" state from another addon (Forever Classmate): a seal with a small panel of icons under it. Per the repository rules, ForeverHUD builds its own version without copying that addon's code or art. The user chose:

- **When:** retract when out of combat with no hostile target; a click on the seal still opens the HUD.
- **Tray:** class resource count, missing upkeep buffs, food/drink/well fed, and health and mana numbers.
- **Size:** the seal and tray can be larger than in the example.

## What already exists

`State.lua` already opens the HUD in combat (`expandCombat`), with a hostile target, or on a seal click. It closes 5 s later. While closed, `Gate` hides the `primary`, `resources` and `pet` modules, and the chassis follows `LayoutVisible()`. So the retract timing is already right. What's missing is the tray, and tidying the rows that still show while closed: the buff rail, Maintenance and the native buffs.

## Design

- **Retracted seal.** While closed, the seal (and its runes) scales up about 1.25× through the Motion layer (an ordinary texture, out of combat only). Everything else that isn't tray content fades out:
  - the buff rail, Maintenance and the native tracked buffs gain the closed-state gate the resource rows already use;
  - the DoT rail only matters with a target, so it's already hidden.
- **Tray**, a new class section `Tray` under the seal (y ≈ −70), visible only while closed (module `tray`, gate `not Visible()`). It's a centred row of 32 px icons, each a native display:

| Tray item | How it is shown (native) | Classes |
| --- | --- | --- |
| Class resource count | Soul Shards: Item Count trigger (as today). Combo points: Power, power type 4. | Warlock; Rogue and Druid (cat) |
| Missing upkeep | The existing Show On: Aura(s) Missing reminders, duplicated into the tray | Warlock, Mage, Priest, Druid |
| Food, drink, Well Fed | Aura (Modern) player buffs | All |
| Health and mana | Text displays with `%percenthealth%` and `%percentpower%` from native unit triggers | All |

- **Tray art:** a painted plate hanging from the seal. The prompt goes in `assets/ai/seal-tray.prompt.txt`, pending generation, like the 0.7 rail art. Until then the tray icons use the current icon frame, and there's no plate.
- **Settings:** `/fhud` gets a **Retracted tray** toggle (module `tray`, on by default).

## Open technical points

- **Food, drink and Well Fed** buffs come in hundreds of spell IDs. The Aura (Modern) trigger matches rank spell IDs, so a reliable list is needed: either confirm in the ForeverAuras source that the native trigger can match by aura name, or ship a curated ID list for the foods and drinks on Forever. This needs checking before implementation.
- **The seal scale-up** must not touch protected regions. The seal is an ordinary texture, so a Motion scale animation out of combat is allowed.
- **Classes without a counter** (Mage, Priest, Paladin, Hunter, Shaman, Warrior) show only the other tray items.

## Build order

1. The tray section and gate, the health/mana text, the resource count, and the missing-upkeep copies.
2. Hide the remaining rows while retracted; seal scale-up.
3. Food, drink and Well Fed, after the ID question is settled.
4. Painted tray plate, which needs image generation.
