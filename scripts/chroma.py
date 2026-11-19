"""Key a flat green generation background into real alpha (0.14.6 globe art).

Figma's image generator cannot return transparent PNGs, so the globe-style
masters were generated on flat #00FF00 and keyed once with this script. The
raw downloads are kept next to the keyed masters in assets/ai/ as *-source.png.

    python scripts/chroma.py assets/ai/globe-frame-source.png assets/ai/globe-frame.png

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

if __name__ == '__main__':
    source, target = sys.argv[1], sys.argv[2]
    key(Image.open(source)).save(target)
    print('keyed', source, '->', target)
