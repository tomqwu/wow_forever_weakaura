"""CurseForge logo for ForeverHUD, composed from the project's own painted seal
master (assets/ai/warlock-seal.png). No new art is generated here."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'assets/ai/warlock-seal.png'
OUT = ROOT / 'assets/curseforge'
OUT.mkdir(parents=True, exist_ok=True)

seal = Image.open(SRC).convert('RGBA')
print('seal master', seal.size)
# Trim transparent margins.
box = seal.getchannel('A').point(lambda a: 255 if a > 8 else 0).getbbox()
seal = seal.crop(box)

SIZE = 400
canvas = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
# Rounded dark plate in the HUD's palette.
plate = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
d = ImageDraw.Draw(plate)
d.rounded_rectangle((0, 0, SIZE - 1, SIZE - 1), radius=56, fill=(14, 11, 22, 255), outline=(92, 66, 132, 255), width=6)
canvas.alpha_composite(plate)
# Soft violet glow behind the seal.
glow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
ImageDraw.Draw(glow).ellipse((70, 70, SIZE - 70, SIZE - 70), fill=(120, 60, 200, 120))
glow = glow.filter(ImageFilter.GaussianBlur(40))
canvas.alpha_composite(glow)
# The painted seal, centred.
target = 320
seal.thumbnail((target, target), Image.LANCZOS)
canvas.alpha_composite(seal, ((SIZE - seal.width) // 2, (SIZE - seal.height) // 2))
canvas.save(OUT / 'logo-400.png', optimize=True)
canvas.resize((256, 256), Image.LANCZOS).save(OUT / 'logo-256.png', optimize=True)
print('written', OUT / 'logo-400.png', OUT / 'logo-256.png')
