# ForeverHUD 0.7 design: icons seated in the frame

Status: approved by the user on 2026-11-12. The layout (build order step 1) is implemented in 0.7.0. The art (step 2) is waiting on an image-generation session. Nothing in this document is game evidence.

## What the user asked for

- "Blending both art/border as one": the icons should look like part of the frame, not ornaments placed on top of it.
- "The non dps one still not attached": the native tracked-buff row floated about 116 px above the HUD in 0.6.2.
- "Balance in the middle, than expand to both sides": each row starts centred on its own bar and grows evenly both ways. The user chose "Centred on each bar" over "From the seal outward" and "One row centred on seal".
- Art: "Paint new art" (not assembled from existing chassis pieces).

## Layout

Every row is centred on its bar: x = −138 for Health, +138 for the resource bar. The damage-left, everything-else-right rule from 0.6.x stays.

| Tier (y) | Left, over Health | Right, over the resource bar |
| --- | --- | --- |
| Rim rail (40) | DoTs on the target, and the Warrior Rend reminder | Your own buffs, Battle Shout reminders, weapon coatings |
| Cradle (80) | Essential cooldowns, up to 4 | Utility cooldowns, up to 4 |
| Upper rail (116) | Tracked bars stay at the far left (x −410) | Empty since 0.7.1: native tracked buffs moved to the rim rail, which they share by mode with your own buffs (see below) |
| Below the bars | Essential overflow, Warrior procs | Utility and item overflow, totems |

## How centring works without reading combat state

- **Rim rails** (protected Modern auras) become ForeverAuras **Modern Aura Groups**: a normal group with `blizzardFlow = true`, `blizzardFlowGrowth = "CENTER_HORIZONTAL"` and `blizzardFlowSpacing`. ForeverAuras chains each child to the end of the previous child's Blizzard aura container and keeps the row centred with half-size shadow frames (`SecretAuraFlow.lua`, lines 2–21 and 139–147). This is native: no Lua reads which aura is present, so it works in combat. The children's own offsets become 0. Displays with ordinary (not Modern) triggers, such as weapon coatings, keep fixed slots at the outer end of the right rail.
- **Cradles** (native Cooldown Manager clones) are already dynamic groups. They change from grow LEFT/RIGHT at x = ±83 to grow HORIZONTAL, align CENTER at x = ±138. `Selection.lua` sets the wing offsets to match, and the unfold motion slides each wing from the seal to its bar centre.
- **Native buffs** (Core) were a centred dynamic group at (138, 116) in 0.7.0. That row floated whenever no Utility cooldown filled the cradle under it. Since 0.7.1 they sit on the right rim at (138, 40), at the DoT row's 24 px size.
  - The curated class buff rail uses the same spot, so the cooldown layout chooses one row.
  - **Forever:** the class buff displays carry `effect` in the catalog and `Selection.Allowed` unloads them; the native row shows every tracked buff.
  - **Class plan:** the native row is synced empty and the class buffs show.

## Art: one shared set, tinted per class

- Icons on rails and in cradles drop the generic `icon-frame` border.
- A matching **socket bezel** travels with each icon. It's a subregion texture on the icon, so it stays aligned however the row reflows.
- A continuous **recessed groove** is painted into the rim under each rail and cradle. Fixed painted sockets can't line up with a row that re-centres, so the groove must work at any icon count.

| Asset | Size (texture) | Use |
| --- | --- | --- |
| `rail-groove` | 256×32 | Recessed channel behind a 24 px icon row, length ≈ one bar (180 px) |
| `cradle-groove` | 256×64 | Raised cradle behind the 40 px cooldown wing |
| `socket-bezel` | 64×64 | Bezel replacing `icon-frame` on rail and cradle icons; transparent centre |

The generation prompts are in `assets/ai/*.prompt.txt` (marked *pending generation*). They follow the existing `resource-frame` prompt: the same dark iron, aged silver and violet inlay, so the pieces read as part of the chassis. `scripts/media.py` then extracts, resizes and exports power-of-two RGBA TGA, as for the other masters. The class tint uses each texture's vertex colour, like the runes.

## Build order

1. **Layout** (can ship before the art):
   - flow groups for both rails;
   - centred cradles and the upper-right rail;
   - `Selection.lua` wing offsets and motion;
   - tests that the rows are centred on their bars, and that every rail member has offset 0 and an allowed trigger type.
2. **Art** (needs image generation): generate the three masters from the prompts, export them through `media.py`, then switch rail and cradle icons from `icon-frame` to `socket-bezel` and add the grooves to the Frame (LOW strata, under the icons).
3. In game: check that rows stay centred in and out of combat, that the grooves line up with the frame, and that the bezel and frame read as one piece.

## Risks

- Modern Aura Group chaining is ForeverAuras' own feature. ForeverAuras attaches a stand-in for protected buttons, and it hasn't been tried with this HUD's class load and module flags. Acceptance needs a live combat check.
- A rail longer than its bar (Warlock has 7 DoT slots, 7 × 26 = 182 px) overhangs the bar by at most a pixel when all seven are up at once.
