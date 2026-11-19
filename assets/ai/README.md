# AI-painted HUD artwork

Generated on 2026-11-09 with the built-in `image_gen` tool and real transparent
backgrounds. These four PNGs are the unmodified generation masters. Each has a
neighboring `.prompt.txt` containing the exact prompt and generation mode.

- `warlock-seal.png`: horned skull in engraved iron, bone, violet gems and fel fire.
- `resource-frame.png`: shared sculpted resource frame with two empty channels.
- `class-seals-atlas.png`: a 4×2 atlas of Warrior, Mage, Priest, Rogue, Druid,
  Hunter, Shaman and Paladin seals, in reading order.
- `icon-frame.png`: an engraved square border, transparent inside and outside.

`scripts/media.py` extracts the atlas cells, trims transparent margins,
proportionally fits artwork into transparent power-of-two canvases and exports
PNG previews and uncompressed 32-bit TGA assets. It preserves the generated
alpha; it does not invent a background, recolor classes, or redraw the art.

The live addon uses the exported art. Its spell icons and live bar fills still
come from the client through ForeverAuras. The HTML preview references Blizzard
spell icon thumbnails hosted by Wowhead's CDN; these thumbnails are not bundled
inside the addon.

## Globe style (0.14.6)

Generated on 2026-11-19 with Figma's image generator (the built-in `image_gen`
tool was not available in that session), with the user's approval to spend
Figma AI credits. Figma returns no transparency, so each frame was generated on
flat `#00FF00` and keyed once by `scripts/chroma.py` into real alpha. The raw
downloads are kept as `*-source.png`; the prompts are in the `.prompt.txt` files.

- `globe-liquid.png`: a greyscale swirling liquid, tinted in game; `scripts/media.py` gives it a round alpha and, since 0.14.9, a darker rim.

0.14.9 (user: "looks ugly", then "Slim dark rail"), also generated with the
Figma image generator on 2026-11-19 with the user's approval. They replace the
0.14.6 ornate ring and wide band, which are removed from this folder (they stay
in git history). The exported file names stay `globe-frame` and `globe-band`.

- `globe-ring.png`: a slim blackened-iron ring with four small gems, keyed from green.
- `globe-rail.png`: a thin iron rail with a central boss. Figma returned this one with real alpha but a wide soft dark haze, so it was cleaned with `scripts/chroma.py --dehaze` instead of keyed.

The glass highlight (`globe-shine`) and the low-health danger ring
(`globe-danger`) are small geometric SVG accents drawn in `scripts/media.py`.
