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
