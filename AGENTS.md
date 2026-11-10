# Eclipse HUD working conventions

This repository builds a ForeverAuras import and the EclipseHUD companion addon.
It is separate from Forever Classmate / ForeverUtilities. Do not apply that
project's folder names, SavedVariables, installation script or release tags here.

- Read `docs/feature-parity-plan.md` first. It is the persistent task checklist
  and handoff memory requested by the user. Follow its numbered order, work on
  one item at a time, and update the work log with evidence before advancing.
  Do not treat artwork, an import/schema check, or a mock as live feature parity.

- Read `README.md`, `docs/design.md` and `docs/validation.md` before runtime edits.
- Edit `src/catalog.py`, `scripts/build.py`, or `src/EclipseHUD/`; regenerate
  `dist/` instead of hand-editing an encoded import.
- Keep the combined nine-class import available and also generate per-class
  imports as requested. Scope each class import to its stable class-group root;
  do not export a partial shared root that could delete other installed classes.
  Every descendant needs a class load
  condition and a module load flag. Disabled modules must unload their trackers.
- Delegate aura/resource/cooldown data and restricted rendering to native
  ForeverAuras triggers. Do not add combat-log inference or guessed timers.
- Use the companion's locale boundary for authored runtime labels; retain native
  client spell names. Keep per-class preferences and existing aura IDs stable.
- Root layout belongs to the companion anchor. Defer native ancestry changes
  until combat ends. Keep mock verification distinct from game-client evidence.
- Painted art masters and exact generation prompts are in `assets/ai/`. Use the
  built-in image_gen tool for creative art changes. `scripts/media.py` only
  extracts sprites, resizes and exports power-of-two RGBA TGA assets. Keep
  generated transparency. Small geometric animation accents may remain SVG.
  Do not copy Guos media/code.
- Run `python scripts/build.py` and `python scripts/check.py`, plus
  `git diff --check`. If a ForeverAuras checkout is available, run
  `lua tests/native-schema.lua /path/to/ForeverAuras`.
- Runtime releases must update the TOC, generator, package checks, workflow
  artifact name, README and changelog together. Existing releases are immutable.
- Do not modify the user's game installation or SavedVariables unless requested.
