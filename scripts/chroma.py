"""Key a flat green generation background into real alpha (0.14.6 globe art).

Figma's image generator cannot return transparent PNGs, so the globe-style
masters were generated on flat #00FF00 and keyed once with this script. The
raw downloads are kept next to the keyed masters in assets/ai/ as *-source.png.

    python scripts/chroma.py assets/ai/globe-ring-source.png assets/ai/globe-ring.png

A pixel's "greenness" is how far green exceeds the stronger of red and blue.
Clearly green pixels become transparent, clearly non-green pixels stay
opaque, and the soft edge between ramps linearly. Green spill on the kept
edge is removed by clamping green to the stronger of red and blue.
"""
import sys
from PIL import Image

LOW, HIGH = 40, 140   # greenness: <= LOW opaque, >= HIGH fully transparent

def key(image):
    image = image.convert('RGBA')
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            other = max(r, b)
            green = g - other
            if green <= LOW:
                continue
            if green >= HIGH:
                pixels[x, y] = (0, 0, 0, 0)
                continue
            keep = 1 - (green - LOW) / (HIGH - LOW)
            pixels[x, y] = (r, min(g, other), b, round(a * keep))
    return image

def dehaze(image, low=60, high=200):
    """0.14.9: the rail came back with real alpha plus a wide soft dark haze.
    Alpha at or under low drops out, at or over high is solid, linear between;
    colours are untouched."""
    image = image.convert('RGBA')
    alpha = image.getchannel('A').point(lambda a: 0 if a <= low else 255 if a >= high else round((a - low) * 255 / (high - low)))
    image.putalpha(alpha)
    return image

if __name__ == '__main__':
    # python scripts/chroma.py SOURCE TARGET          key a flat green background
    # python scripts/chroma.py --dehaze SOURCE TARGET  clean an alpha haze instead
    args = sys.argv[1:]
    mode = dehaze if args[0] == '--dehaze' else key
    source, target = args[-2], args[-1]
    mode(Image.open(source)).save(target)
    print('keyed' if mode is key else 'dehazed', source, '->', target)
