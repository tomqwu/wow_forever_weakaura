# Validation for 0.13.3

Sections below 0.4.0 describe releases made under the Eclipse name and keep the names those releases used.

## 0.13.3 (prerelease) — install icon under the folded seal

- **Change (companion, `Core.lua`):** a plain `Button` on `UIParent`, not in any native aura ancestry. It's shown when `E.AuraProblems()` is non-empty, the profile is enabled, the world is live, out of combat, and the HUD is folded or no root is installed. It sits at the anchor's x and y − 109 (tray row −67, 34 px icon, 8 px gap), scaled with the profile. Dark ring, `Trade_Engineering` icon, `Media/icon-frame` (an existing texture, so no restart), and a looping alpha 1 → 0.4 → 1 over 2.4 s. A click runs `E.InstallBundled()` out of combat. The installed builds are read again on entering the world, after each import (`finishBind`) and every 3 s while shown.
- **`tests/core.lua`:** shown with its reason for an older class group, its position, the click import, hidden in combat and back after, cleared once current, a missing Core, and hidden on world leave.
- **Not yet checked in game.**

## 0.13.2 (prerelease) — smaller folded seal

- **Game evidence (user screenshot, 0.13.1, folded):** the retracted Warlock seal with the Soul Shard count under it; the user asked for the class icon 10% smaller.
- **Change:** `RETRACTED_SEAL` 132 → 118 (even, so it stays centred on whole pixels). `TRAY_ROW1_Y` is now derived, 13 − 59 − 4 − 17 = −67, keeping the 4 px gap. The 68 px companion click handle is unchanged and still inside the seal.
- **CDM expiry fade-out, not built:** `BlizzardAuraDisplay.lua:1810–1816` offers only Start (aura assigned) and Main (aura shown) animations, with no hook for an aura ending.
- **`tests/test_pack.py`:** the seal width, the row offset and the 4 px gap.
- **Not yet checked in game.**

## 0.13.1 (prerelease) — missing upkeep breathes; suggestion row at 70%

- **Game evidence (user screenshot, 0.13.0, folded):** the tray's missing Demon Armor icon sits beside the Soul Shard count, as still as the count.
- **ForeverAuras source (installed addon, read only):**
  - `BlizzardAuraDisplay.lua:1816`: Aura Main types include `pulse`; `:1870` builds it as a looping alpha 1 → 0.4 → 1 over the set duration.
  - `:1825`: a Gained flash suppresses Pulse; `GainedSeconds` (`:1747`) is 0 for Show On Missing, so it plays.
  - `SecretAuraSingle.lua:1010` and `:584`: the Missing look is a sample button styled by `Display.StyleNative`, which adds the Main animation; `SecretAuraPreview.lua:43` plays it at once and again on show.
- **Change:** `blizzardAuraDisplay.auraMain = {type="pulse", duration=2.4}` on every `… Upkeep reminder | <name> missing` display (tray and HUD).
- **`tests/test_pack.py`:** the four missing reminders in the tray and Warlock's HUD reminder breathe; only Show On Missing displays without a Gained flash do; expiring reminders don't.
- **Suggestion row at 70% (user request, same release):** every display in `<Class> | Suggest` gets `alpha=0.7`; the Shadowburn cue starts at 0 and its threshold condition sets 0.7. ForeverAuras applies a display's `alpha` to Aura (Modern) containers (`BlizzardAuraDisplay.lua:2821`, `instance.baseAlpha = … data.alpha`), and stand-ins in a Modern Aura Group forward `SetAlpha` to their copies (`SecretAuraStand.lua:31`). Covered by `test_suggestion_row_is_translucent`.
- **Not yet checked in game.**

## 0.13.0 (prerelease) — absorb overlay on the Health bar

- **ForeverAuras source (installed addon, read only):**
  - `Prototypes.lua:3412`: the Health trigger has `showAbsorb` (hidden when `UnitGetTotalAbsorbs` is nil), `absorbMode` and `absorb = UnitGetTotalAbsorbs(unit)`.
  - `Prototypes.lua:3614`: the overlay accepts secret values.
  - `RegionTypes/AuraBar.lua:512`: the `fromMax` overlay sets a secret width on native status bars.
  - `SecretAuraStand.lua:782`: a fix notes an absorb overlay on a health bar copy "seen in game".
- **Change:** the Core Health trigger gets `use_showAbsorb=true` and `absorbMode=OVERLAY_FROM_END_REVERSE`. The bar gets one overlay colour (0.82, 0.93, 1.0, 0.6) and `overlayclip=true`.
- **`tests/test_pack.py`:** the trigger fields, no heal-absorb, clipping, one translucent overlay colour, and only the player Health bar.
- **`tests/native-schema.lua` against the installed ForeverAuras:** passes.
- **Not yet checked in game:** whether the server counts Ice Barrier, Mana Shield, Power Word: Shield and Shadow Ward toward `UnitGetTotalAbsorbs`, and how the overlay looks on the frame.

## 0.12.1 (prerelease) — shelf lines

- **Game evidence (user screenshot, 0.12.0, out of combat):** three grey rectangles: over each rim row and over the suggestion row. Nothing was in them, and they covered part of the rim art.
- **Change:** the `groove` media and displays are removed, and `shelf` (256×8, gradient line) is added. `Shelf | Left` (mirrored) and `Shelf | Right` sit at (±142, 54), 184×8, tinted with the class colour. They're gated on art, layout visible, `InCombat()` and not retracted; the gate trigger already listens for `PLAYER_REGEN_DISABLED` and `PLAYER_REGEN_ENABLED`.
- **`tests/test_pack.py`:** no groove displays; shelf position, size, mirror, texture, draw order over the chassis, and the combat and folded gate. The texture count stays 24.
- **Not yet checked in game.**

## 0.12.0 (prerelease) — one spine from the seal

- **Game evidence (user screenshot, 0.11.0):** the DoT icon sat centred over Health while the suggestions started at the seal. Both floated over the frame art.
- **ForeverAuras source (installed addon, read only):** `RegionTypes/DynamicGroup.lua` grows `LEFT`/`RIGHT` from x=0 with the children's `selfPoint` (CENTER), so the first icon is centred on the group origin. `SecretAuraFlow.lua` starts LEFT and RIGHT rows at the first display's inner corner.
- **Change:**
  - The DoT and buff rows grow `LEFT`/`RIGHT` from ±66 (inner edge ±52), and the Core native buff row grows `RIGHT` from 66.
  - The wings grow out from ±72, and class-plan slots use `Selection.FromSeal`.
  - Three drawn `groove` textures sit in each class Frame.
- **Tests:**
  - `tests/test_pack.py`: rail positions and growth, the native buff row, groove placement and draw order, the hidden-while-folded gate, and wing growth.
  - `tests/selection.lua`: both sides start at the seal edge, and slots step 47 px outward.
  - `scripts/check.py`: 24 textures.
  - `tests/native-schema.lua` against the installed ForeverAuras: 253 modern displays.
- **Not yet checked in game:** how the grooves sit on the frame art, and the wing alignment with live cooldowns.

## 0.11.0 (prerelease) — clearer suggestion row

- **Game evidence (user screenshot, 0.10.0):** two suggestions sat in fixed slots with gaps, off centre. Health Funnel, a pet cue, was mixed in with the rotation spells.
- **ForeverAuras source (installed addon, read only):**
  - `SecretAuraFlow.lua` supports `LEFT` growth, which starts at the first display's top-right corner.
  - A legacy row starts at its first shown member's own frame.
  - Only shown members join the row.
  - Ordinary icons join a row through stand-ins, in group order.
- **Change:**
  - The Suggest group is a LEFT Modern Aura Group at (-68, 74) with spacing 4, so the lead edge is at -52.
  - Every action sits at the group origin.
  - Threshold cues move to `Suggest cues`: mana at (218, -28), pet at (-218, -28), both 22 px, and execute at (-212, 74).
  - That group exists only for classes with a cue.
- **`tests/test_pack.py`:**
  - The row's flow, growth, spacing and lead edge.
  - Each spec's actions in priority order at the origin, fitting over the Health bar.
  - Only curve cues leave the row.
  - The Life Tap, Health Funnel and Shadowburn positions.
  - Destruction's row never reaches the execute slot.
- **`tests/native-schema.lua` against the installed ForeverAuras:** the native schema validator passed 253 modern displays.
- **Not yet checked in game:**
  - the live order;
  - whether `Action Usable` icons keep their list order in the row;
  - the cue positions against the frame art.

## 0.10.0 (prerelease) — rotation suggestions per spec

- **Request:** suggestions should follow class and spec; review every class.
- **Change:**
  - `SUGGESTIONS` holds one list per spec for all nine classes, with at most five rules each.
  - Each display's catalog entry carries `spec`.
  - `Selection.SuggestSpec` resolves the current school, falling back to `Leveling`.
  - `Selection.Allowed` gates suggestion flags by that spec.
  - New rule kinds are `ready` (Action Usable, combat with a hostile target) and `buff` (own buff missing).
  - Druid Innervate tests mana explicitly (`powertype=0`).
- **`tests/test_pack.py`:**
  - The Warlock per-spec lists and their order, and that the Leveling list keeps the 0.9 IDs.
  - Every list is centred and has at most five rules.
  - The Conflagrate and Shadowburn triggers and gates.
  - Every class has a list for each spec, with spec, seeds and suggest load flags.
  - The Innervate power type, and the own-buff check.
- **`tests/selection.lua`:**
  - The Leveling fallback, and that a spec loads only its own list.
  - A class without a Leveling list shows nothing and keeps its wing down.
  - The Mage Fire list.
- **IDs:** all except Mend Pet (136) come from the existing catalog. A rule loads only once the client reports its spell or talent as learned.
- **Not yet checked in game:** any rule, including whether the target-health curve and Action Usable checks behave in this client.

## 0.9.7 (prerelease) — suggestions stay above the DoTs

- **Game evidence (user screenshot, 0.9.6):** the two suggestions showed well above the DoT icon, with an empty gap. The 0.9.6 lift had fired because the left wing had entries, but none were visible: native Essential cooldowns can show only while on cooldown.
- **Change:** the Suggest group stays at its imported spot (-138, 74). `Selection.LeftLift` gives left-side primary positions a y offset of 34 when the class has suggestions and they're on, so 40 px wing icons centre at y=114. Their bottom is 94, 4 px above the suggestions' top (90).
- **`tests/test_pack.py`:** asserts the lift against the generator geometry.
- **`tests/selection.lua`:** asserts the left wing lift, the unmoved right wing, the untouched suggestion row, and no lift with suggestions off.
- **Not yet checked in game.**

## 0.9.6 (prerelease) — suggestions on the damage side

- **Request (user screenshot, 0.9.5):** the suggestion icon showed above the seal; the user asked for it on the left, lower, right above the damage icons. In that screenshot the left cooldown wing is empty and the DoT row sits on the Health rim.
- **Change:** the Suggest group sits at x=-138, y=74, 4 px above the DoT row, which spans y 26–54. `Selection.PlaceSuggestions` moves it to y=120 when the left wing has entries; the wing's 40 px icons at y=80 span 60–100. It runs out of combat only.
- **`tests/test_pack.py`:** asserts the position against the DoT row and that the companion constants match the generator.
- **`tests/selection.lua`:** asserts the lift with a left wing, the low position without one, no move in combat, and the lift after combat.
- **Not yet checked in game:** the new position and the lift.

## 0.9.5 (prerelease) — tray icons match

- **Game evidence (user screenshot, auras at build 904):** the icons still differed, so the 0.9.3 claim that the ring would match them was wrong. Zooming the screenshot ×4 showed the Soul Shards art with its dark ring.
  - **Frame sizes:** about 56 px (Soul Shards) against about 43 px (Demon Armor). The native button carries our frame without the 8 px outset.
  - **Art sizes:** about 38 against 36 px, much closer.
  - **Spacing:** the two frames overlapped at a spacing of 2.
- **Change:** the counter's frame outset is now 3 px, and the tray spacing is 8.
- **`tests/test_pack.py`:** asserts the outset and the spacing.
- **Not verified in game:** this match is inferred from the measurement; it needs a screenshot to confirm.

## 0.9.4 (prerelease) — hover to peek

- **`tests/state.lua`** (8 new checks, 41 in total), using the real Core and State code:
  - Hovering the folded seal opens the HUD with root alpha at opacity × 0.35.
  - The ghost lasts through the leave grace, then folds immediately at full opacity, with no close timer.
  - Clicking the ghost opens the HUD for real at full opacity, and a second click folds it.
  - Combat start drops the ghost to full opacity, and there's no peek in combat.
- **Game evidence (user, 0.9.4):** "hover works". Hovering the folded seal shows the ghost HUD in the client.
- **Not verified in game:** whether every native aura child dims with the root.
- **Tray ring follow-up:** the user's "not working" screenshot was taken while the saved Warlock auras still carried build 902 (0.9.2, no ring). After the user updated, the saved data shows build 904 with the 3 px `subborder` on Soul Shards. Measured: `icon-frame.png`'s opening starts about 2.9 px outside the icon edge, so the frame doesn't hide the ring. Its look after the update isn't confirmed yet.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.9.3, with all 38 files verified (4 changed). The 0.9.3 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.9.3 (prerelease) — matching tray icons

- **Game evidence (user screenshot, 0.9.2):** the Soul Shards counter and the Demon Armor missing reminder sit side by side in one row. This confirms that an ordinary display chains into the Modern Aura Group. The two icons looked different: the reminder's art was inset inside a dark ring.
- **Source review:** a missing Modern aura is a stand-in copy of the native button (`CreateSampleNative`, `MissingLayout` in `SecretAuraSingle.lua`). `blizzardAuraDisplay` has no option for its inset or ring, though zoom does apply. So the counter copies the ring instead.
- **`tests/test_pack.py`:** the counter has a 3 px subborder at offset 0 below the frame subtexture, and one visible count (`%s`).
- **Not verified in game:** how closely the copied ring matches.

## 0.9.2 (prerelease) — one-row tray

- **Game evidence (user screenshot, Warlock, 0.9.0, folded):** the larger seal shows with the tray under it: health and resource percentages, the Soul Shards icon (18), and the Demon Armor missing reminder on a second row. This is the first in-game confirmation of the retracted mode, the larger seal, the tray gate and the Demon Armor missing reminder. It also showed the Soul Shards count twice (centre and corner).
- **Change:** the counter joins the centred row as its first member, and its centre number is hidden.
- **`tests/test_pack.py`:**
  - The tray holds only the row.
  - The row is at y = −74 with a single icon size.
  - Soul Shards lead the row and show only the corner count.
- **Not verified in game:** the ordinary counter chaining inside the Modern Aura Group.
- **Published 2026-11-12 as v0.9.2,** including 0.9.1: all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.9.0, with all 38 files verified (3 changed). The 0.9.0 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.9.1 (prerelease) — minimal tray

- `tests/test_pack.py` now asserts, for all nine classes:
  - there are no tray Health or Resource text displays;
  - the icon row is at y = −116 under the Warlock Soul Shards counter, and y = −74 for classes without a counter.
- Not verified in game.

## 0.9.0 (prerelease) — spell suggestions

Automated only; nothing here is game-client evidence.

- **Source review** (`Conditions.lua`):
  - The power curve supports `<=`.
  - It can AND only with readable (non-curve) checks, and one curve trigger is chosen per display.
  - So mana and health can't be combined. The user's example (Life Tap at 30% mana) is implemented on mana alone.
- **`tests/test_pack.py` (`test_warlock_spell_suggestions`):**
  - The order and centring of the row, and its clearance from the seal.
  - Life Tap: Power trigger, alpha 0, and a `percentpower <= 30` condition setting alpha 1.
  - Health Funnel: the pet Health curve.
  - DoT rules: Show On Missing with the `SuggestTarget` gate.
  - Shadow Trance: eligible once Nightfall (18094, 18095) is learned.
  - Every suggestion has a suggest load flag.
- **`tests/bundle.lua`:** suggestions hide while folded, and DoT rules need combat and a hostile target.
- **`tests/options.lua`** (aura status in the real panel code):
  - Missing Core and class: red text naming both, with the install button.
  - Older class and current Core: only the class is reported.
  - Both current: localized all-clear, no button.
  - The new modules have controls.
- **Not verified in game:**
  - curve-driven alpha on the icons;
  - the Nightfall talent IDs on Forever;
  - the row's spacing against the cradles and the class name.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.8.1, with all 38 files verified (5 changed). The 0.8.1 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.8.1 (prerelease) — no icon for an active upkeep buff

- **Game evidence (user screenshot):** the folded seal at normal size with the active Demon Armor icon to its right. That looks like the 0.7.3 companion: 0.8.0 was installed while the game ran, and needs a `/reload` and Update Auras. The user asked not to show the armor while it's up.
- **`tests/test_pack.py`:**
  - The Warlock active armor display and the Mage, Priest and Druid active upkeep icons are gone, and their missing reminders exist.
  - Mage Armor, Inner Fire, Aspect and Blessing keep their active icons.
- **`tests/selection.lua`:** the armor family is still kept out of the native buff row, through its reminder's catalog entry.
- **Not verified in game.**
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.8.0, with all 38 files verified (3 changed). The 0.8.0 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.8.0 (prerelease) — retracted seal and tray

Automated only; nothing here is game-client evidence.

- **Source review:** ForeverAuras' Modern trigger expands a name in `auraRankSpellIDs` to every spell ID with that name (`BlizzardAuraDisplay.lua` 428–432), and its validator accepts names. So Food, Drink and Well Fed need no ID list.
- **`tests/test_pack.py` (`test_retracted_seal_and_tray`), for all nine classes:**
  - The normal seal is gated `not Retracted()` and the larger one `Retracted()`.
  - Every tray member has a tray load flag and a tray gate, and hangs below the larger seal.
  - The second row is a centred Modern Aura Group, with Food, Drink and Well Fed matched by name.
  - The health and resource texts use native percent formats.
  - Warlock has Soul Shards and a Demon Armor missing reminder.
  - Name-matched icons skip spell discovery.
- **`tests/bundle.lua`:**
  - Folded: the tray shows and the buff and upkeep rows give way.
  - Open: no tray.
  - Tray off: the old behaviour.
- **`tests/state.lua`:** updated, because buffs no longer show while folded with the tray on.
- **ForeverAuras native schema:** passes (installed ForeverAuras 1.3.9).
- **Not verified in game:**
  - the fold and seal swap;
  - tray contents and spacing;
  - name matching against Forever's food and drink.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.7.3, with all 38 files verified (4 changed). The 0.7.3 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.7.3 (prerelease) — Demon Armor reminder

- Requested by the user ("missing demon armor alert?").
- `tests/test_pack.py` asserts that both Warlock reminders:
  - sit in Maintenance;
  - use `secretAura` with Show On Missing, and Active with remaining time;
  - cover the three armor spell IDs;
  - carry a maintenance load flag.
- The ForeverAuras native schema validator accepts them.
- Not verified in game.
- **Published 2026-11-12 as v0.7.3,** including 0.7.2: all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.7.1, with all 38 files verified (3 changed). The 0.7.1 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.7.2 (prerelease) — larger rim icons

- Requested by the user after 0.7.1. Rim icons are now 28 px with a 30 px step.
- The pack tests still pass:
  - centred rail members stay within their bar span;
  - weapon coatings stay past the resource bar and inside the frame;
  - the cradle above clears the rail.
- Not verified in game.

## 0.7.1 (prerelease) — buff row mirrors the DoT row

- **Game evidence (user screenshot, Warlock, 0.7.0):**
  - The Immolate DoT is centred on the Health-side rim.
  - Demon Armor shows past the Mana bar.
  - The native tracked buff (1:57) hangs above the empty Utility cradle, about 116 px up.
- **Change:**
  - Native buffs move to (138, 40) at 24 px.
  - In Forever mode the curated class buffs unload (`effect` catalog flag, `Selection.Allowed`) and the native row includes them.
  - In Class plan mode the native row is synced empty.
- **Tests:**
  - `tests/selection.lua`: Backlash unloads in Forever mode and appears in the native row. Class plan mode allows the curated buff and leaves the native row empty. Earlier native-row checks now run explicitly in Forever mode.
  - `tests/test_pack.py`: the native row's position, growth and size match the DoT row, and every curated class buff carries `effect`.
- **Not verified in game.**
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.7.0, with all 38 files verified (4 changed). The 0.7.0 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.7.0 (prerelease) — rows centred on each bar

Automated only; nothing here is game-client evidence.

- **Source review** of the installed ForeverAuras (`SecretAuraFlow.lua`):
  - A normal group with `blizzardFlow` is a Modern Aura Group.
  - `CENTER_HORIZONTAL` keeps the row centred with half-size shadow frames.
  - `FlowProblem` accepts Icon displays, and rejects a Remaining Time window only in grids. The Battle Shout "expiring" reminder uses one, but outside a grid.
  - Non-Modern displays in a screen-mode flow are chained as ordinary displays. Weapon coatings are therefore kept out of the rail.
- **`tests/test_pack.py`:**
  - Both rails sit at (±138, 40) as centred flow groups.
  - Every rail member has offset 0 and a `secretAura` trigger.
  - Every row keeps its side.
  - Buff-row members lie within the resource bar, and coatings sit past its end.
- **`tests/selection.lua`:** class-plan sides average exactly ±138, and the step between consecutive ranks is 47.
- **ForeverAuras native schema:** the installed ForeverAuras 1.3.9 accepts the combined, Core and nine class files.
- **Not verified in game:**
  - rows staying centred in and out of combat;
  - the Modern Aura Group chain with the class and module load flags;
  - wing centring and the unfold motion.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.6.2, with all 38 files verified (4 changed). The 0.6.2 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.6.2 (prerelease) — every row on its side

- **Game evidence (user screenshot, Warlock, 0.6.0):** a tracked buff appeared centred about 170 px above the HUD, in the Core's native player-effects row. The user asked why non-damage elements were not all moved right together.
- **Audit:** every positioned row of the combined import was listed and given a side by role.
- **Tests:** `test_damage_left_everything_else_right` computes each display's screen x through its parents for all nine classes.
  - Damage displays must be left, and everything else right.
  - The buff row and the Rend reminder must be at y=40, within their bar spans.
- **Previous release:** 0.6.1 was published (14 assets verified) and installed over 0.6.0, with all 38 files verified (3 changed), after a verified backup.
- **Not verified in game:** any 0.6.1 or 0.6.2 position.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.6.1, with all 38 files verified (3 changed). The 0.6.1 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.6.1 (prerelease) — DoT row seated over Health

- **Game evidence (user screenshot, Warlock, 0.6.0):**
  - The Immolate DoT shows in its fixed left slot, roughly 98 px above the anchor and away from the frame.
  - Demon Armor shows to the right of the Mana bar, as designed.
  - The user asked for these icons to be part of the frame, attached to the Health bar.
- **Change:** the DoT row moves to y=40 (24 px icons, 26 px steps, from x=−60). The wings move to y=80. Weapon coatings move to y=130.
- **Tests:** `tests/test_pack.py` now asserts:
  - every DoT icon lies within the Health bar's x span;
  - the row is at y=40;
  - the wing icons clear the row.
- **Not verified in game:** the row against the frame art, and the wing spacing.

## 0.6.0 (prerelease) — damage left, everything else right

Automated only; nothing here is game-client evidence.

- **Requested layout:** the user asked for "dps dots on the left bar (health) attach to the frame, and right group … other non dps CD", and for Demon Armor on the right.
- **`tests/selection.lua` (now 85 checks):**
  - The left wing takes the first four Essential entries in Cooldown Manager order.
  - The right wing takes the first four Utility entries, skipping preparation spells.
  - Overflow goes to the Essential and Utility rows without repeating wing entries.
  - With Utility abilities off, the right wing is empty.
  - Wing x offsets: left is negative, right is positive.
  - An empty Essential list leaves only the right wing; empty lists invent nothing.
  - Class plans put attacks left and support right.
- **`tests/test_pack.py`:**
  - Maintenance is at x > 250 and grows right.
  - Each class's DoT row is at y = 92 with distinct fixed slots inside the chassis (−256 < x < −60).
  - Core tracked bars are at x < −250.
- **Preview page:** mirrors the moved rows and class-plan sides. Captures in `preview/` and `docs/images` predate 0.6.0 and remain illustrative.
- **Not verified in game:**
  - wing contents and sides;
  - DoT row spacing against the left wing;
  - Maintenance beside the resource bar;
  - the update in `/fa`.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.5.1, with all 38 files verified (4 changed). The 0.5.1 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.5.1 (prerelease) — DoTs stay in the HUD's target row

- **Game evidence (user screenshots, Warlock, 0.5.0):**
  - The Core health, mana and pet bars draw above the Warlock chassis.
  - Both groups line up on one anchor.
  - A DoT with its countdown appeared about 170 px above the HUD centre, near the target. The user's `nameplates` setting is off, so this is consistent with the Core's native player-effects row (y = 151), which shows the Cooldown Manager's tracked list.
  - The saved aura data had not been written since the install, so the exact display was not read from it.
- **Fix:** `S.SyncCDM` now treats catalogued `dots` auras like tracked buffs. A native entry that matches one by name or spell ID is left out of the native player-effects row while the target-effects module is on.
- **Tests:** two new `tests/selection.lua` checks, 79 in total. Immolate is left out of the row while the target-effects module is on, and kept when it is off.
- **Not verified in game:** the DoT gone from the row above the HUD.
- **Published 2026-11-12:** all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.5.0, with all 38 files verified (4 changed). The 0.5.0 folder was backed up and verified first, and SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.5.0 (prerelease) — shared Core plus class groups

Automated only; nothing here is game-client evidence.

- `tests/test_pack.py` (15 tests) checks:
  - Core displays load for all nine classes behind `FOREVERHUD_CORE_` flags.
  - The Core and each class import are exactly their root's subtree, and the subtrees are disjoint.
  - Every standalone root follows `ForeverHUDAnchor`.
  - Shared displays exist only in Core.
  - Every texture is class art in the LOW strata, and every other display inherits its strata.
  - Update tags use `forever-hud-core` and `forever-hud-<class>`.
- `tests/bundle.lua` checks:
  - The Core bundle is byte-identical to `ForeverHUD-Core.txt`.
  - Core and class registration states.
  - Install order: Core first, an older Core before a current class, and the message naming the next step.
  - Root resolution for standalone and combined installs.
  - Detached Core displays.
  - The once-per-session warning about a 0.4 class group, and the install refusal over it.
  - Core load flags mirror the current class; shutdown clears them.
  - The cast-bar tint.
  - The new Chinese strings.
- `tests/selection.lua` and `tests/motion.lua` now look up the native rows and the Health and Resource bars in Core, and the wings and chassis in the class group.
- `tests/native-schema.lua` ran against the installed ForeverAuras 1.3.9 source, and the combined import, the Core and all nine class files pass. Each file is checked only for the displays it carries:
  - Core has the shared Resource colour conditions and the one tracked-bar renderer.
  - Class files have their auras, the FX curve and the custom-sorted wings.
- Source review of `ForeverAuras.lua` `FixGroupChildrenOrderForGroup`: frame levels start at 0 for every root. This is why class art uses strata rather than levels to stay below the Core bars.
- Not verified in game:
  - the two-step install from `/fa` or `/fhud install`;
  - Core bars drawing above the class chassis;
  - Core displays loading per class and per module;
  - the cast-bar tint;
  - the 0.4 class-group warning.
- Published 2026-11-12: all 14 downloaded release assets match the build, and the 38 runtime files match the source. Installed over 0.4.1 with all 38 files verified (9 changed); the 0.4.1 folder was backed up and verified first. SavedVariables were not touched. This is file evidence, not game-client evidence.

## 0.4.1 (prerelease) — import fix for group Init actions

Automated only; nothing here is game-client evidence.

- Reported in game with ForeverAuras 1.3.9: importing 0.4.0 stopped at `AuraEnvironment.lua:524: attempt to index field '?'`. Source review of the installed ForeverAuras: `LoadCustomActionFunctions` runs only for non-group displays, while `ActivateAuraEnvironment` runs a group's custom Init action through that missing table. The native wing's dynamic-group custom sort activated the wing during import.
- The generator now refuses custom actions on any group. The root and wing Init actions moved to the `Class name` text display and the wing entry icons.
- `tests/native-schema.lua` no longer stubs `ActivateAuraEnvironment` as a no-op: the mock fails like ForeverAuras on a group Init action, every group's actions are checked, and every custom-sorted dynamic group runs its sort. Against the 0.4.0 generator it fails on `Native left`.
- Not verified in game: the import completing, or the companion binding from the new location.
- Published 2026-11-12: all 13 downloaded release assets match the build, and the 38 runtime files match the source. Not installed. This is file evidence, not game-client evidence.

## 0.4.0 (prerelease) — renamed to ForeverHUD

Automated only; nothing here is game-client evidence.

- Mechanical rename of every runtime, generator, test, workflow and documentation identifier. Afterwards, `git grep -i eclipse` outside the history docs finds only the deliberate legacy checks (`EclipseHUD`, `Eclipse | `) and the migration notes.
- `tests/bundle.lua` now has 21 checks. The new ones: the old addon and old displays each warn once, the warnings name what to delete, and the legacy displays are never modified.
- `python scripts/build.py`, `python scripts/check.py` and `git diff --check` pass in WSL; CI repeats them with the pinned ForeverAuras checkout and the native-schema test.
- Not verified in game: the folder swap, the login warnings, or a fresh ForeverHUD install beside deleted Eclipse auras.
- Preview PNGs were renamed only; their pixels are 0.3.x illustrative captures.
- Published 2026-11-12: all 13 downloaded release assets match the build. Installed into the `_forever_` client with all 38 files verified. EclipseHUD was removed only after a verified backup. This is file evidence, not game-client evidence.

## 0.3.5 (prerelease) — auras bundled in the addon

Automated only; nothing here is game-client evidence.

- `tests/bundle.lua` (18 checks) loads the actual Core, Catalog, Locale and Options code. It covers:
  - all nine bundled strings, each byte-identical to its published class file;
  - install, update, installed-without-tag, current and unsupported-class registration states, registered once per session, with separate install and update tables;
  - the detached-display count, which excludes the standalone root and other classes;
  - `/eclipse install`, which is refused over detached displays, opens with `force` or once clean, and is reachable through the slash command;
  - the Chinese warning, which keeps the English placeholder order.
- `tests/test_pack.py` asserts every class display's update tag matches FA's `wago.io/<slug>/<number>` pattern and the current build, that the combined root has no tag, and that the manifest slug/build match.
- FA source review (`ForeverAuras.lua` `AddCompanionData`/`PostAddCompanion`/`CountWagoUpdates`; `ForeverAurasOptions.lua` pending install/update lists and their buttons): the registered fields (`name`, `author`, `encoded`, `wagoVersion`, `versionNote`) are the ones FA reads. Clicking either calls FA's `Import`. Not yet seen in the client.
- Published: the immutable [v0.3.5 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.5) targets `0094fa25833b34c46a61aab6dc73175793fefe6d`, and [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/43091139641) passed on it. ZIP SHA-256: `8742a94f7f8392ca66433333788ff2ac086f3660ae9fd1dc17f5bbcb1d0d0287`. All 13 downloaded assets match the local build, and the 38 runtime files in the ZIP match the source. Installed on 2026-11-11 at the user's request: all 38 file hashes match the package, with 5 changed. The v0.3.4 backup is verified at `F:\WoW-addon-backups\EclipseHUD\20261111-152210\before\EclipseHUD`. SavedVariables were not changed. Installing files is not live-client evidence.
- Pending live checks: after installing 0.3.5 and `/reload`, `/fa` lists the class under ready to install or updates; the window imports or updates cleanly; after a `/reload` it is no longer listed; the detached warning appears only when parentless displays exist.

# Validation for 0.3.4

## 0.3.4 (prerelease) — aura structure and import safety

Automated only; nothing here is game-client evidence.

- `tests/test_pack.py` asserts each class root lists exactly the eight sections plus Cast, sections at `(0,0)` hold children, no empty groups remain, depth is at most three below the class root, and Warrior proc cues keep their former screen offset inside Primary. Class-file scopes are compared against the class root's reachable subtree, not the generator's own load predicate. Parent/child links are checked both ways, exactly once.
- `scripts/codec.lua verify` now fails on an unlisted child, a child listed twice or a second root, and compiles custom text, custom sort and custom trigger logic. The combined import is round-tripped against its source table, like the class files.
- FA's updater treats child `xOffset`/`yOffset` as Group Arrangement (default on), so an Update applies the moved proc offsets (`OptionsFrames/Update.lua` category mapping; source review, not a live update).
- Companion import safety: layout, CDM sync and ability binding defer while `IsImporting()` is true; root show/hide hooks are installed once and ignore import-time show/hide. A live interrupted Warlock update (21 parentless roots, stopped in phase 2 before `Primary | Native 4 | Entry`) is recorded in the plan's work log. Its triggering error has not been captured; the review found no companion path that raises into, or calls `Add` within, the import coroutine.
- Pending live checks: a fresh class import and an Update from 0.3.3 both finish with every display inside its section; dragging moves the whole HUD; FX stays behind the seal.

## Published v0.3.4

[PR #5](https://github.com/tomqwu/wow_forever_weakaura/pull/5) (structure, import safety, tooling) and [PR #7](https://github.com/tomqwu/wow_forever_weakaura/pull/7) (changelog date) merged; [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/43076439748) passed on the release commit `9508b4db6ed2e5f109df62ef1f47cd4fbecf11c6`. The immutable [v0.3.4 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.4) targets that commit. ZIP SHA-256: `b82d838fbdf36febd28c5bcbcfbef03f20c610446ebca9de15f2f8e7a4dabf65`. All 13 downloaded assets match the local build, and the 38 runtime files in the ZIP match the source.

Installed on 2026-11-11 at the user's request into `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD`. All 38 file hashes match the package, with 6 changed. The v0.3.3 backup is verified at `F:\WoW-addon-backups\EclipseHUD\20261111-132331\before\EclipseHUD`, and the receipt is stored beside it. SavedVariables were not changed. The running client still needs `/reload` and a fresh Warlock import, because the earlier interrupted update left parentless displays. Installing files is not live-client evidence.

## Automated evidence

`python scripts/build.py`, `python scripts/check.py` and `git diff --check` are the required build/package checks. Twelve Python test groups and the check script validate Lua syntax, focused behavior regressions, class/module loading, own media, import decoding/hierarchy, synchronized versions and ZIP source/media/hash bytes.

The Lua suites currently cover 330 assertions across companion preferences, actual settings callbacks/localization, discovery, selection, state, motion, formatting/equipment, casting, audio and ordinary effect lifecycle. They include:

- English/Chinese learned ranks, reversed spellbook order, learned bases/overrides, passive and placeholder rejection, learning events and stop cleanup.
- Native provider order and saved placement, uncatalogued learned entries, hidden/unlearned/invisible exclusion, full Essential overflow, separate Utility/items, mode switching, no-op writes and module cleanup. Generated bridge callbacks also run against missing/old helpers in two scenarios.
- Explicit level-23 Warlock fixture; source Warrior stages, all 27 school controls, duplicate/preparation exclusion, native CDM overflow/counters and cached Druid combat-form switching.
- Idle/enemy/combat/no-target, five-second hold/reacquisition, inspection, editor return, death/loading, native motion reversal and cleanup.
- Anchor repair, scale-independent coordinates, preserved profiles, position-only reset and combat deferral. Per-class roots preserve combined parents or use a standalone companion anchor; native import-phase binding waits/coalesces/cancels correctly. Existing v0.3.2 guards retain compatibility.
- Equipment-qualified off-hand, native formatter restoration, retained flow masks, localized resource identities, cast ownership/stop/success ordering and alert priority/TTL/cleanup.
- Independently disabled cast/resource effects, missing hosts, bounded retries, reused decoration frames and combat-deferred reparenting; native resource-trim dependency unloading.

`lua tests/native-schema.lua /path/to/ForeverAuras [CLASS_EXPORT.lua]` loads actual FA validators, fallback selection and condition-curve code. It reproduces the old misplaced fallback setting and verifies the correction, rather than relying on schema success alone. It exercises the actual native resource-curve path with restricted values and compiles/evaluates the real FA color conditions through mana → energy → rage → mana. Unknown/restricted identities restore the neutral base; resource amounts stay restricted throughout. Both the installed 1.3.7 source and public checkout are checked; this remains a mocked client environment.

`python scripts/preview.py` regenerates the illustrative HTML. `python scripts/check_preview.py` runs browser regressions for nine classes, the leveling fixture, idle/target/combat/delayed close, reacquisition, artwork stacking, semantic bar colors, Druid caster/cat/bear transitions and independent preview settings. `--capture` updates gallery images. Set `ECLIPSE_CHROMIUM` only when using a nondefault local Chromium executable. The native dynamic-group sort wrapper also executes our identity-only comparison with restricted state objects; the helper never reads those states. Browser evidence is separate from game-client evidence.

## Published v0.3.3 and installation

[PR #4](https://github.com/tomqwu/wow_forever_weakaura/pull/4), branch/PR CI and [main CI](https://github.com/tomqwu/wow_forever_weakaura/actions/runs/42925051342) passed. The immutable [v0.3.3 prerelease](https://github.com/tomqwu/wow_forever_weakaura/releases/tag/v0.3.3) targets `9fc7c6036e90429c01d5d31987ac4d89eed15c8a`. Downloaded ZIP SHA-256 is `9a09d84d355759dfebc95c83ba07861d7c76bf1d9f308e50d0fd4ccd51d5a306`; ZIP, combined/class assets and all runtime files match the checked local bytes. All 38 addon files are installed and verified at `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD` (9 changed). Prior v0.3.2 backup: `F:\WoW-addon-backups\EclipseHUD\20261110-183934\before\EclipseHUD`. SavedVariables and other addons were not changed. The running client still needs `/reload` and a class/combined import update.

A post-release documentation correction supersedes the ZIP README’s native Visibility → Hidden recommendation: native `CooldownViewerMixin:OnHide` / `CooldownViewerCooldownMixin:OnHide` unregister update events. Keep all native viewers Always. Use native displays with duplicate Eclipse modules off, or enable Eclipse tracked bars and FA global opacity hide. The release assets remain immutable; the current online README records this correction. No live-client acceptance follows from installing files.

## Required game-client acceptance — pending

No game files were modified during implementation. On 2026-11-10, at the user's request, the published v0.3.1 companion was installed into the running client's `F:\World of Warcraft\_forever_\Interface\AddOns\EclipseHUD`. All 38 addon files match the release; the previous v0.2.0 folder was backed up and verified outside AddOns. SavedVariables remain untouched. Subsequently the v0.3.2 companion was installed with all 38 file hashes verified (8 changed); the prior v0.3.1 folder is backed up at `F:\WoW-addon-backups\EclipseHUD\20261110-095502\before\EclipseHUD`. Load or `/reload` the companion, then update the matching class import (or the combined top-level group) before testing the changes below. New 0.3.1 screenshots establish the native manager grouping mismatch, armor placement and caption complaints. General.log captured old-helper import errors and a later independent AckisRecipeList health-prediction taint flood. These are failure evidence, not validation of 0.3.2.

1. Update the companion and `/reload`. In a fresh profile, import one class file through `/fa` and verify its anchor, scale, caption, modules and settings. Import a second class file and confirm the first is untouched. In an existing combined setup, update only its class subgroup using the matching class file, confirm the parent/other classes/preferences survive, and verify no duplicate IDs. Existing v0.3.2 class imports should remain usable with the new companion. The optional full file still updates the combined **top-level** group. Reload before importing so the correct companion is in memory; an old helper should emit one instruction and cause no missing-helper flood. Check no duplicate groups or import errors. An addon-only update cannot repair the old saved fallback nesting.
2. On the actual level-23 Warlock, run `/eclipse spells` out of combat and compare the printed learned ranks/native CDM with the spellbook and default manager. Verify new training updates without reimport. No unresolved proc/question-mark or preparation icon should appear in live mode.
3. Check idle → hostile living target → target loss → five-second close, friendly/dead/restricted targets, combat without target, reacquisition during animation, death/loading and editor open/close. Combat entry must start motion immediately; combat exit must begin folding in that event when no hostile target/inspection keeps it open. Only target loss keeps the five-second hold. Verify first center-click expands and second folds immediately with the same target, then new target/combat clears the fold latch. Verify visible intermediate motion survives layout refresh/late binding rather than snapping. Check animation-off mode and no idle Lua clock.
4. Check physical anchor, frame/bar clearance, role labels and text contrast at 60%, 100% and 160% scale. Verify crimson health, blue mana, gold energy and orange rage, including Druid form changes and native combo current/maximum values. **Reset position** should preserve scale/modules; old saved positions should survive upgrades. Drag/settings changes in combat must defer root changes without blocked actions.
5. Exercise each actual learned cooldown, charges, GCD, usability/range/proc/queue feedback and extra native CDM entries. Compare learned native identities/order and category placement. Trigger a real cooldown and a GCD-only action separately: only the former should occupy the default cooldown row. Confirm native wing compaction, overflow beyond eight, separate Utility/items, hidden placement and changes after combat. Check the optional Class plan mode and absence of duplicates. Test all Warrior stages/Cleave/stance/shield/off-hand cases.
6. Apply/remove/expire actual player/target auras, including another caster's effects. Check qualified Shadow Trance/Backlash, Warlock armor in the side maintenance area with no above-emblem duration, maintenance-module unloading, native buff deduplication, armor uncertainty, native upkeep missing/≤15s filters, nameplate removal and disabled-module unloading.
7. Test pet absence/death, carried shards, native totems/coatings, Hunter actual melee/ranged swings, Rogue combo points and Druid combat form changes.
8. Test Default/Eclipse/Both choices, legacy migration, module checkbox synchronization and the loaded-aura fallback. Test native casting/channels, default standard/gamepad bar restoration, late loading, crafting/edit mode and another cast-bar owner. Interrupted casts must not play successful completion effects; stopping a cast/channel must stop the loop even when no success arrives.
9. Keep the game’s tracked bars with FA global hide off and native viewers Always (native Hidden unregisters updates); disable duplicate Eclipse modules if using the native icon rows. Then test the optional Eclipse native tracked-bar stack with global FA hide. Apply/remove Corruption/Immolate/Bane, control effects and tracked procs; confirm native remaining duration/stack rendering and no duplicate icon overflow when bars are enabled. Check native effect stacking, resource masks/curves, real-swing pulses and stop/restoration at every lifecycle edge. Disable Resources with Cast enabled, then Cast with Resources enabled; each remaining effect must keep working and disabled native trackers must unload. Confirm no protected-frame/taint errors. Verify activation sound timing, ready alert priorities, login/editor silence and combat-end cleanup.
10. Verify English/Chinese native fonts, settings tabs, Escape, hover/inspection, per-class controls and all switches. Log out normally and back in to verify saved preferences. Test at least one additional class, then each class adaptation before calling nine-class runtime parity verified.

Record client build, ForeverAuras version and Lua/taint errors. The detailed acceptance checkboxes in [feature-parity-plan.md](feature-parity-plan.md) remain open until these client checks pass.
