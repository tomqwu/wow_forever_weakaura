"""CurseForge logo for ForeverHUD: all nine painted class seals on one plate.

Composed from the project's own painted seal sprites (src/ForeverHUD/Media/
crest-<class>.png, extracted from assets/ai by scripts/media.py). No new art
is generated here.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / 'src/ForeverHUD/Media'
OUT = ROOT / 'assets/curseforge'
OUT.mkdir(parents=True, exist_ok=True)
# 3x3, Warlock in the centre (the original painted seal).
GRID = [['warrior', 'mage', 'priest'],
        ['rogue', 'warlock', 'druid'],
        ['hunter', 'shaman', 'paladin']]

SIZE = 400
PAD = 22
CELL = (SIZE - 2 * PAD) // 3
canvas = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
plate = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
ImageDraw.Draw(plate).rounded_rectangle((0, 0, SIZE - 1, SIZE - 1), radius=56,
    fill=(14, 11, 22, 255), outline=(92, 66, 132, 255), width=6)
canvas.alpha_composite(plate)
glow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
ImageDraw.Draw(glow).ellipse((60, 60, SIZE - 60, SIZE - 60), fill=(120, 60, 200, 90))
canvas.alpha_composite(glow.filter(ImageFilter.GaussianBlur(45)))
for row, names in enumerate(GRID):
    for col, name in enumerate(names):
        seal = Image.open(MEDIA / f'crest-{name}.png').convert('RGBA')
        box = seal.getchannel('A').point(lambda a: 255 if a > 8 else 0).getbbox()
        seal = seal.crop(box)
        # The centre seal is a touch larger so the mark still reads at 64 px.
        size = int(CELL * (1.04 if name == 'warlock' else 0.92))
        seal.thumbnail((size, size), Image.LANCZOS)
        x = PAD + col * CELL + (CELL - seal.width) // 2
        y = PAD + row * CELL + (CELL - seal.height) // 2
        canvas.alpha_composite(seal, (x, y))
canvas.save(OUT / 'logo-400.png', optimize=True)
canvas.resize((256, 256), Image.LANCZOS).save(OUT / 'logo-256.png', optimize=True)
print('written', OUT / 'logo-400.png', OUT / 'logo-256.png')
