#!/usr/bin/env python3
"""Build the 1280x640 GitHub social preview from the CurseForge logo (no new art).

Upload it by hand in GitHub: Settings > General > Social preview.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / 'assets/curseforge/logo-400.png'
OUT = ROOT / 'assets/curseforge/social-preview.png'


def font(size):
    for name in ('DejaVuSerif-Bold.ttf', 'DejaVuSans-Bold.ttf'):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


def main():
    canvas = Image.new('RGBA', (1280, 640), (14, 11, 20, 255))
    draw = ImageDraw.Draw(canvas)
    for y in range(640):  # Soft vertical vignette.
        shade = int(10 * (1 - abs(y - 320) / 320))
        draw.line([(0, y), (1280, y)], fill=(14 + shade, 11 + shade, 24 + shade * 2, 255))
    logo = Image.open(LOGO).convert('RGBA').resize((440, 440), Image.LANCZOS)
    canvas.alpha_composite(logo, (90, 100))
    lines = [((600, 230), 'ForeverHUD', 92, (236, 214, 160, 255)),
             ((604, 350), 'Class combat HUD', 40, (200, 196, 214, 255)),
             ((604, 402), 'for WoW Forever · all nine classes', 28, (150, 142, 170, 255))]
    for (x, y), text, size, colour in lines:
        while size > 12 and draw.textlength(text, font=font(size)) > 1280 - 60 - x:
            size -= 2  # Keep every line inside the canvas.
        draw.text((x, y), text, font=font(size), fill=colour)
    canvas.convert('RGB').save(OUT, optimize=True)
    print(OUT.relative_to(ROOT))


if __name__ == '__main__':
    main()
