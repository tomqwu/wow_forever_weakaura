"""Package AI-painted masters into alpha-preserving WoW UI textures.

No generation occurs here. The built-in image_gen originals and prompts are
checked in under assets/ai/. This script extracts sprites, trims transparent
margins, resizes proportionally and converts formats.
"""
import io
from pathlib import Path
import cairosvg
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
MASTERS = ROOT / 'assets/ai'
ATLAS_CLASSES = ('WARRIOR','MAGE','PRIEST','ROGUE','DRUID','HUNTER','SHAMAN','PALADIN')

def export(directory, name, image, size, padding=0, trim=True):
    image = image.convert('RGBA')
    if trim:
        # Ignore virtually invisible alpha specks when locating the art;
        # retain the original alpha inside the crop, without thresholding it.
        box = image.getchannel('A').point(lambda a: 255 if a > 1 else 0).getbbox()
        if not box:
            raise ValueError(f'Empty generated asset: {name}')
        image = image.crop(box)
    image = ImageOps.contain(image, (size[0]-2*padding,size[1]-2*padding), Image.Resampling.LANCZOS)
    canvas = Image.new('RGBA',size,(0,0,0,0))
    canvas.alpha_composite(image,((size[0]-image.width)//2,(size[1]-image.height)//2))
    canvas.save(directory/(name+'.png'))
    canvas.save(directory/(name+'.tga'),compression=None)

def vector(directory,name,body,width,height):
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}">{body}</svg>'
    (directory/(name+'.svg')).write_text(svg,encoding='utf-8',newline='\n')
    image = Image.open(io.BytesIO(cairosvg.svg2png(bytestring=svg.encode()))).convert('RGBA')
    export(directory,name,image,(width,height),trim=False)

def build(directory,classes):
    directory.mkdir(parents=True,exist_ok=True)
    atlas=Image.open(MASTERS/'class-seals-atlas.png').convert('RGBA')
    frame=Image.open(MASTERS/'resource-frame.png').convert('RGBA')
    for token in classes:
        if token=='WARLOCK':
            seal=Image.open(MASTERS/'warlock-seal.png')
        else:
            i=ATLAS_CLASSES.index(token)
            col,row=i%4,i//4
            box=(round(col*atlas.width/4),round(row*atlas.height/2),round((col+1)*atlas.width/4),round((row+1)*atlas.height/2))
            seal=atlas.crop(box)
        export(directory,'crest-'+token.lower(),seal,(256,256),padding=8)
        export(directory,'chassis-'+token.lower(),frame,(1024,256))
    export(directory,'icon-frame',Image.open(MASTERS/'icon-frame.png'),(128,128),trim=False)
    # Geometry-only animation accents remain code-native.
    ticks=''.join(f'<path d="m61 7 3-3 3 3-3 3Zm3 4v3" transform="rotate({i*45} 64 64)"/>' for i in range(8))
    vector(directory,'runes','<g fill="none" stroke="#ffffff" stroke-width="1.3"><circle cx="64" cy="64" r="59" stroke-dasharray="34 12 2 12"/><circle cx="64" cy="64" r="56" stroke-dasharray="1 12"/>'+ticks+'</g>',128,128)
    # 0.12: a recessed channel behind an icon row (drawn stand-in for the
    # painted rail-groove master in assets/ai). Neutral tones, tinted in game.
    vector(directory,'groove','<rect x="1" y="2" width="254" height="28" rx="6" fill="#000" fill-opacity=".55"/>'
        '<rect x="3" y="3" width="250" height="5" rx="3" fill="#000" fill-opacity=".45"/>'
        '<rect x="1.5" y="2.5" width="253" height="27" rx="6" fill="none" stroke="#fff" stroke-opacity=".2"/>'
        '<path d="M8 29.5h240" stroke="#fff" stroke-opacity=".6" stroke-width="1"/>',256,32)
    vector(directory,'divider','<path d="M0 16h232l24-8 24 8h232m-280 0 24 8 24-8" stroke="#bb93df" stroke-width="1" fill="none"/>',512,32)
    # Small original geometric flow accent. Native FlipBook playback supplies
    # the clock; this SVG is a 480-frame, 32-column atlas with transparent gaps.
    for side,direction in (('left',1),('right',-1)):
        cells=[]
        for i in range(480):
            x,y=(i%32)*64,(i//32)*8
            phase=(i/480)*64*direction
            cells.append(f'<clipPath id="c{i}"><rect x="{x}" y="{y}" width="64" height="8"/></clipPath>')
            cells.append(f'<rect x="{x}" y="{y}" width="64" height="8" fill="white" fill-opacity=".7"/>')
            paths=''.join(f'<path d="M{x+k*32+phase-16:.3f} {y}l{8*direction} 4 {-8*direction} 4"/>' for k in range(-3,5))
            cells.append(f'<g clip-path="url(#c{i})" fill="none" stroke="white" stroke-opacity=".5" stroke-width="1">{paths}</g>')
        vector(directory,'resource-flow-'+side,''.join(cells),2048,128)
