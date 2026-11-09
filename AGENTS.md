# Eclipse HUD working conventions

This repository builds a ForeverAuras import and the EclipseHUD companion addon.
It is separate from Forever Classmate / ForeverUtilities. Do not apply that
project's folder names, SavedVariables, installation script or release tags here.

- Read `README.md`, `docs/design.md` and `docs/validation.md` before runtime edits.
- Edit `src/catalog.py`, `scripts/build.py`, or `src/EclipseHUD/`; regenerate
  `dist/` instead of hand-editing an encoded import.
- Keep all nine classes in one import. Every descendant needs a class load
  condition and a module load flag. Disabled modules must unload their trackers.
- Delegate aura/resource/cooldown data and restricted rendering to native
  ForeverAuras triggers. Do not add combat-log inference or guessed timers.
- Use the companion's locale boundary for authored runtime labels; retain native
  client spell names. Keep per-class preferences and existing aura IDs stable.
- Root layout belongs to the companion anchor. Defer native ancestry changes
  until combat ends. Keep mock verification distinct from game-client evidence.
- Original art sources are SVG. Regenerate power-of-two, uncompressed RGBA TGA
  assets with `scripts/media.py` through the build. Do not copy Guos media/code.
- Run `python scripts/build.py` and `python scripts/check.py`, plus
  `git diff --check`. If a ForeverAuras checkout is available, run
  `lua tests/native-schema.lua /path/to/ForeverAuras`.
- Runtime releases must update the TOC, generator, package checks, workflow
  artifact name, README and changelog together. Existing releases are immutable.
- Do not modify the user's game installation or SavedVariables unless requested.
