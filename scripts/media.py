"""Original vector artwork, rasterized to WoW's uncompressed RGBA TGA format."""
import io
import math
from pathlib import Path
import cairosvg
from PIL import Image

SYMBOLS = {
    "WARLOCK": '<path d="M46 39 38 23 35 47 48 58M82 39 90 23 93 47 80 58M48 48 64 38 80 48 76 72 64 88 52 72Z"/><path d="m52 57 9 5-8 4m23-9-9 5 8 4M60 74h8"/>',
    "WARRIOR": '<path d="m44 36 16 18-7 8-18-16 3-10Zm40 0L68 54l7 8 18-16-3-10ZM48 73l29-29m-26 7 32 32M38 80l10-10m-5 16 8-8m29-4 9 9"/>',
    "MAGE": '<path d="m64 30 18 22-18 47-18-47ZM46 52h36M64 30v69m-9-47 9 23 9-23M34 67l8 5m44-5 8-5"/>',
    "PRIEST": '<path d="M59 33h10v24h23v11H69v26H59V68H36V57h23Z"/><circle cx="64" cy="63" r="29"/>',
    "ROGUE": '<path d="m45 29 14 13 5 25-25 29 8-36ZM83 29 69 42 64 67l25 29-8-36ZM43 70l16 14m10 0 16-14"/>',
    "DRUID": '<path d="M64 91V47m0 23L46 50m18 11 18-17M46 50l-9-15m9 15-16-2m52-4 9-15m-9 15 16-3M64 47 57 30m7 17 7-17"/><path d="M46 76q18 28 36 0"/>',
    "HUNTER": '<path d="M45 30q49 34 0 68l12-34ZM33 64h62m-12-9 12 9-12 9"/>',
    "SHAMAN": '<path d="m72 28-32 42h21l-5 30 32-46H67Z"/><path d="M36 40q-12 25 0 47m56-47q12 25 0 47"/>',
    "PALADIN": '<path d="M64 29 89 40v27q-4 21-25 32-21-11-25-32V40ZM64 43v37M50 59h28"/>',
}

def wrapper(body, width, height, color, accent):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
<defs><linearGradient id="metal" x2="0" y2="1"><stop stop-color="#e5d5ba"/><stop offset=".28" stop-color="#8b7f85"/><stop offset=".5" stop-color="#393343"/><stop offset=".8" stop-color="#b6a38c"/><stop offset="1" stop-color="#514750"/></linearGradient><linearGradient id="energy"><stop stop-color="{color}" stop-opacity=".2"/><stop offset=".5" stop-color="{accent}"/><stop offset="1" stop-color="{color}" stop-opacity=".2"/></linearGradient><radialGradient id="core"><stop stop-color="{color}" stop-opacity=".3"/><stop offset="1" stop-color="#090913"/></radialGradient></defs>{body}</svg>'''

def save(directory, name, body, width, height, color, accent):
    svg = wrapper(body, width, height, color, accent)
    directory.mkdir(parents=True, exist_ok=True)
    (directory / (name + '.svg')).write_text(svg)
    png = cairosvg.svg2png(bytestring=svg.encode(), output_width=width*2, output_height=height*2)
    image = Image.open(io.BytesIO(png)).convert('RGBA').resize((width,height), Image.Resampling.LANCZOS)
    image.save(directory / (name+'.tga'), compression=None)
    image.save(directory / (name+'.png'))

def build(directory, classes):
    for token, cls in classes.items():
        c, a = cls['color'], cls['accent']
        ticks = ''.join(f'<path d="M64 13v{6 if i%3 == 0 else 3}" transform="rotate({i*15} 64 64)"/>' for i in range(24))
        body = f'''<circle cx="64" cy="64" r="54" fill="#080810" stroke="#09070e" stroke-width="5"/>
<circle cx="64" cy="64" r="51" fill="url(#core)" stroke="url(#metal)" stroke-width="3"/>
<circle cx="64" cy="64" r="45" fill="none" stroke="{c}" stroke-width=".7" opacity=".6"/>
<g fill="none" stroke="{a}" stroke-width="1" opacity=".8">{ticks}</g>
<path d="m64 4 5 9-5 6-5-6Zm0 120 5-9-5-6-5 6ZM4 64l9-5 6 5-6 5Zm120 0-9-5-6 5 6 5Z" fill="{c}" stroke="url(#metal)"/>
<g fill="none" stroke="{a}" stroke-width="2.3" stroke-linejoin="round" stroke-linecap="round">{SYMBOLS[token]}</g>'''
        save(directory, 'crest-'+token.lower(), body, 128,128,c,a)
        chassis = f'''<path d="m12 42 12-19 31 6 27 7h116l30-18 28 12 28-12 30 18h116l27-7 31-6 12 19-16 20-29-3-19 12H314l-30 18-28-12-28 12-30-18H82L63 59l-29 3Z" fill="#090911" stroke="#030309" stroke-width="5"/>
<path d="m12 42 12-19 31 6 27 7h116l30-18 28 12 28-12 30 18h116l27-7 31-6 12 19-16 20-29-3-19 12H314l-30 18-28-12-28 12-30-18H82L63 59l-29 3Z" fill="none" stroke="url(#metal)" stroke-width="2"/>
<path d="M43 40h166M303 40h166M76 65h123m114 0h123" stroke="url(#energy)" stroke-width="2"/>
<path d="m27 32 11 10-11 11m458-21-11 10 11 11M85 29l12 7m318 0 12-7" fill="none" stroke="{c}"/>
<path d="M45 45h161v16H45Zm261 0h161v16H306Z" fill="#04050a" stroke="#756077" stroke-width=".65"/>
<g fill="{a}"><path d="m39 42 3 3-3 3-3-3Zm434 0 3 3-3 3-3-3Z"/><circle cx="211" cy="51" r="2"/><circle cx="301" cy="51" r="2"/></g>'''
        save(directory,'chassis-'+token.lower(),chassis,512,128,c,a)
    rune = '<g fill="none" stroke="#ffffff" stroke-width="1.3">'
    rune += '<circle cx="64" cy="64" r="59" stroke-dasharray="34 12 2 12"/><circle cx="64" cy="64" r="56" stroke-dasharray="1 12"/>'
    for i in range(8):
        rune += f'<path d="m61 7 3-3 3 3-3 3Zm3 4v3" transform="rotate({i*45} 64 64)"/>'
    save(directory,'runes',rune+'</g>',128,128,'white','white')
    save(directory,'icon-frame','<rect x="2" y="2" width="60" height="60" rx="5" fill="none" stroke="#06060c" stroke-width="4"/><rect x="2" y="2" width="60" height="60" rx="5" fill="none" stroke="url(#metal)" stroke-width="1.7"/><path d="M3 15V3h12m34 0h12v12M3 49v12h12m34 0h12V49" stroke="#e0d4b7" stroke-width="1.3" fill="none"/>',64,64,'white','white')
    save(directory,'divider','<g transform="scale(1.6 2)"><path d="M0 8h144l16-5 16 5h144M148 8l12 5 12-5" stroke="url(#energy)" stroke-width=".7" fill="none"/></g>',512,32,'#9c79ce','#e8d3a7')
