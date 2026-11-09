#!/usr/bin/env python3
"""Build one nested, class-switched ForeverAuras import and its companion ZIP."""
import argparse
import hashlib
import json
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from catalog import CLASSES

VERSION = "0.1.0"
TITLE = "Eclipse | Class Combat HUD"
MEDIA = "Interface\\AddOns\\EclipseHUD\\Media\\"
EVENTS = "PLAYER_ENTERING_WORLD PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED PLAYER_TARGET_CHANGED ECLIPSE_HUD_UPDATE FA_OPTIONS_CLOSED"

def lua(value):
    if value is None: return "nil"
    if value is True: return "true"
    if value is False: return "false"
    if isinstance(value, (int,float)): return str(value)
    if isinstance(value, str):
        return '"' + value.replace('\\','\\\\').replace('"','\\"').replace('\n','\\n').replace('\r','\\r') + '"'
    if isinstance(value, list): return "{" + ",".join(map(lua,value)) + "}"
    return "{" + ",".join("["+lua(k)+"]="+lua(v) for k,v in sorted(value.items(), key=lambda kv:str(kv[0]))) + "}"

def rgba(hexcolor, alpha=1):
    return [int(hexcolor[i:i+2],16)/255 for i in (1,3,5)] + [alpha]

class Pack:
    def __init__(self): self.displays = []; self.by_id = {}
    def add(self, name, region, parent=None, cls=None, module="base", x=0, y=0, **fields):
        d = dict(id=name, uid=hashlib.sha256(name.encode()).hexdigest()[:11], regionType=region,
            internalVersion=91, tocversion=16001, semver=VERSION, version=1, author="Eclipse HUD contributors",
            xOffset=x, yOffset=y, anchorPoint="CENTER", selfPoint="CENTER", anchorFrameType="SCREEN",
            frameStrata=1, alpha=1, scale=1, load={}, subRegions=[], config={}, authorOptions=[], conditions=[],
            information=dict(forceEvents=False, groupOffset=False, ignoreOptionsEventErrors=False),
            actions=dict(init={},start={},finish={}),
            animation={k:dict(type="none",duration_type="seconds",easeType="none",easeStrength=3) for k in ("start","main","finish")})
        if parent:
            d["parent"] = parent
            self.by_id[parent]["controlledChildren"].append(name)
        if cls:
            d["load"] = dict(use_class=True, **{"class":dict(single=cls,multi={})},
                use_loadFlag=True, loadFlag=f"ECLIPSE_{cls}_{module}")
        if region in ("group","dynamicgroup"):
            d.update(controlledChildren=[],border=False,borderColor=[0,0,0,1],backdropColor=[0,0,0,0],
                borderEdge="Square Full White",borderOffset=4,borderInset=1,borderSize=2,borderBackdrop="Blizzard Tooltip")
        d.update(fields)
        self.displays.append(d); self.by_id[name]=d
        if cls: self.triggers(d, [self.always()], cls, module)
        else: d["triggers"] = {1:dict(trigger=self.always(),untrigger={}),"activeTriggerMode":1,"disjunctive":"all"}
        return d
    @staticmethod
    def always(): return dict(type="unit",event="Conditions",unit="player",use_alwaystrue=True)
    def triggers(self,d,triggers,cls,module):
        gate = dict(type="custom",custom_type="status",check="event",events=EVENTS,
            custom=f'function(event) return EclipseHUD and EclipseHUD.Gate("{module}", "{cls}") or false end')
        ts = {i+1:dict(trigger=t,untrigger={}) for i,t in enumerate(triggers+[gate])}
        ts.update(activeTriggerMode=1,disjunctive="all")
        d["triggers"] = ts
    def group(self,name,parent,cls,module,x=0,y=0,dynamic=False):
        fields = dict(grow="HORIZONTAL",align="CENTER",space=8,stagger=0,sort="none",animate=False,
            radius=200,rotation=0,stepAngle=15,fullCircle=True,arcLength=360,constantFactor="RADIUS",
            useLimit=False,limit=12,gridType="RD",centerType="LR",gridWidth=6,rowSpace=1,columnSpace=1) if dynamic else {}
        return self.add(name,"dynamicgroup" if dynamic else "group",parent,cls,module,x,y,**fields)

def subtext(text, point="CENTER", size=12, x=0, y=0):
    return dict(type="subtext",text_text=text,text_color=[.94,.91,1,1],text_font="Friz Quadrata TT",
        text_fontSize=size,text_fontType="OUTLINE",text_visible=True,text_justify="CENTER",text_selfPoint="AUTO",
        anchor_point=point,anchorXOffset=x,anchorYOffset=y,text_shadowColor=[0,0,0,1],text_shadowXOffset=0,
        text_shadowYOffset=0,rotateText="NONE",text_automaticWidth="Auto",text_fixedWidth=64,text_wordWrap="WordWrap",
        text_text_format_p_format="timed",text_text_format_p_time_format=0,text_text_format_p_time_precision=0,
        text_text_format_p_time_dynamic_threshold=3)

def border(cls):
    return dict(type="subborder",border_visible=True,border_color=rgba(CLASSES[cls]["color"],.8),
        border_edge="Square Full White",border_size=1,border_offset=0)

def icon(pack,name,parent,cls,module,trigger,size=40,x=0,y=0,known=None,modern=False):
    d=pack.add(name,"icon",parent,cls,module,x,y,width=size,height=size,icon=True,iconSource=-1,
        progressSource=[-1,""],adjustedMax="",adjustedMin="",inverse=False,color=[1,1,1,1],zoom=.18,
        desaturate=False,keepAspectRatio=False,cooldown=True,cooldownTextDisabled=True,cooldownSwipe=True,
        cooldownEdge=False,useCooldownModRate=True,
        subRegions=[dict(type="subbackground"),border(cls),subtext("%p",size=13),subtext("%s","BOTTOMRIGHT",10,x=-2,y=2)])
    if modern: d.update(secretFallback="none",inverse=True,blizzardAuraDisplay=dict(maxIcons=1,sharedDisplay=True,actionSounds=False))
    if known: d["load"].update(use_spellknown=True,spellknown=known,use_exact_spellknown=False)
    pack.triggers(d,[trigger],cls,module)
    return d

def aura_trigger(ids,unit="player",harmful=False):
    return dict(type="secretAura",event="Health",unit=unit,debuffType="HARMFUL" if harmful else "HELPFUL",
        auraTracking="native",secretUseRankSpellIDs=True,auraRankSpellIDs=ids,
        secretUseSpellIDs=False,auraspellids=[],secretShowOn="showOnActive",
        nativeFilters={"PLAYER":True},useExactSpellId=False)

def bar(pack,name,parent,cls,module,trigger,width=170,height=13,x=0,y=0,color=None,text="%p",name_text=None):
    d=pack.add(name,"aurabar",parent,cls,module,x,y,width=width,height=height,icon=False,desaturate=False,iconSource=-1,
        progressSource=[-1,""],adjustedMax="",adjustedMin="",texture="Blizzard",textureSource="LSM",
        orientation="HORIZONTAL",inverse=False,barColor=color or rgba(CLASSES[cls]["color"]),
        barColor2=[1,1,1,1],enableGradient=False,gradientOrientation="HORIZONTAL",backgroundColor=[.02,.02,.04,.95],
        spark=False,sparkWidth=8,sparkHeight=20,sparkColor=[1,1,1,1],sparkTexture="Interface\\CastingBar\\UI-CastingBar-Spark",
        sparkBlendMode="ADD",sparkOffsetX=0,sparkOffsetY=0,sparkRotationMode="AUTO",sparkRotation=0,sparkHidden="NEVER",
        icon_side="LEFT",icon_color=[1,1,1,1],zoom=0,
        subRegions=[dict(type="subbackground"),dict(type="subforeground"),subtext(text,"INNER_RIGHT",10,x=-4)])
    # Resource values use native dynamic formatting, with no Lua arithmetic.
    if trigger["event"] in ("Health","Power"):
        d["subRegions"][-1]["text_text_format_p_format"]="Number"
        d["subRegions"][-1]["text_text_format_p_big_number_format"]="AbbreviateNumbers"
    if name_text: d["subRegions"].append(subtext(name_text,"INNER_LEFT",9,x=4))
    pack.triggers(d,[trigger],cls,module)
    return d

def texture(pack,name,parent,cls,module,asset,w,h,x=0,y=0,color=None,level=None):
    d=pack.add(name,"texture",parent,cls,module,x,y,width=w,height=h,texture=MEDIA+asset+".tga",
        color=color or [1,1,1,1],desaturate=False,blendMode="BLEND",textureWrapMode="CLAMPTOBLACKADDITIVE",
        rotation=0,mirror=False,rotate=False)
    if level is not None: d["frameLevel"]=level
    return d

def generate():
    p=Pack()
    root=p.add(TITLE,"group",anchorFrameType="SELECTFRAME",anchorFrameFrame="EclipseHUDAnchor",anchorFrameParent=True,
        groupIcon=MEDIA+"crest-warlock.tga",desc="Eclipse 0.1.0 / 星蚀职业战斗界面\nOne import, nine classes. Controls: /eclipse. Native aura tracking; learned abilities only.\n一份导入，九职业自动切换。/eclipse 打开设置。使用原生光环追踪，只显示已学技能。")
    root["actions"]["init"] = dict(do_custom=True,custom="if EclipseHUD then EclipseHUD.Bind() end")
    for cls,c in CLASSES.items():
        prefix=f"Eclipse | {c['name']}"
        group=p.group(prefix,TITLE,cls,"base")
        group["groupIcon"]="Interface\\Icons\\"+c['icon']
        texture(p,prefix+" | Chassis",prefix,cls,"art","chassis-"+cls.lower(),512,128,y=0)
        texture(p,prefix+" | Seal",prefix,cls,"art","crest-"+cls.lower(),82,82,y=13)
        rune=texture(p,prefix+" | Living runes",prefix,cls,"motion","runes",88,88,y=13,color=rgba(c['color'],.55))
        rune["animation"]["main"]=dict(type="custom",duration_type="seconds",duration=45,use_rotate=True,rotate=360,
            rotateType="straight",easeType="none",easeStrength=3)
        caption=p.add(prefix+" | Class name","text",prefix,cls,"base",y=65,displayText="%c",
            customText='function() return EclipseHUD and EclipseHUD.L("'+c['name']+'") or "'+c['name']+'" end',customTextUpdate="event",
            font="Friz Quadrata TT",fontSize=10,outline="OUTLINE",color=rgba(c['color']),justify="CENTER",
            automaticWidth="Auto",fixedWidth=200,wordWrap="WordWrap",shadowColor=[0,0,0,1],shadowXOffset=0,shadowYOffset=0)
        # The chassis's bar cutouts are at +/-130, +13 in its 512x128 box.
        bar(p,prefix+" | Health",prefix,cls,"resources",dict(type="unit",event="Health",unit="player",use_unit=True),
            x=-130,y=13,width=161,height=13,color=[.43,.67,.36,1])
        # No explicit powertype: Druid forms, Warrior rage and Rogue energy
        # follow the client's current resource automatically.
        bar(p,prefix+" | Resource",prefix,cls,"resources",dict(type="unit",event="Power",unit="player",use_unit=True),
            x=130,y=13,width=161,height=13)
        primary=prefix+" | Primary"; p.group(primary,prefix,cls,"primary",y=-45,dynamic=True)
        for seed,name in c['primary']:
            trigger=dict(type="spell",event="Cooldown Progress (Spell)",unit="player",spellName=seed,
                use_spellName=True,use_exact_spellName=False,use_ignoreoverride=False,use_ignoreSpellKnown=False,
                use_showgcd=False,use_showgcdtext=False,track="cooldown",use_track=True,
                genericShowOn="showAlways",use_genericShowOn=True)
            d=icon(p,primary+" | "+name,primary,cls,"primary",trigger,42,known=seed)
            d['conditions']=[dict(check=dict(trigger=1,variable="onCooldown",value=1),
                changes=[dict(property="desaturate",value=True),dict(property="alpha",value=.65)])]
        utility=prefix+" | Utility";p.group(utility,prefix,cls,"utility",y=-195,dynamic=True)
        for seed,name in c['utility']:
            trigger=dict(type="spell",event="Cooldown Progress (Spell)",unit="player",spellName=seed,
                use_spellName=True,use_exact_spellName=False,use_ignoreSpellKnown=False,use_showgcd=False,
                use_showgcdtext=False,use_track=True,track="cooldown",genericShowOn="showAlways",use_genericShowOn=True)
            d=icon(p,utility+" | "+name,utility,cls,"utility",trigger,30,known=seed)
            d['conditions']=[dict(check=dict(trigger=1,variable="onCooldown",value=1),changes=[dict(property="desaturate",value=True)])]
        # Modern aura slots stay fixed in combat. No Lua presence inspection,
        # inferred timers, refresh windows, or combat-dependent group reflow.
        dots=prefix+" | Target effects"; p.group(dots,prefix,cls,"dots",y=-100)
        count=len(c['dots'])
        for i,(seed,name) in enumerate(c['dots']):
            icon(p,dots+" | "+name,dots,cls,"dots",aura_trigger([seed],"target",True),32,x=(i-(count-1)/2)*40,modern=True)
            # Native nameplate displays are opt-in and tied to live plates.
            d=icon(p,prefix+" | Nameplates | "+name,prefix,cls,"nameplates",aura_trigger([seed],"nameplate",True),22,
                x=(i-(count-1)/2)*26,y=26,modern=True)
            d.update(anchorFrameType="NAMEPLATE",anchorFrameParent=False)
        effects=prefix+" | Player effects";p.group(effects,prefix,cls,"buffs",y=96)
        buffs=list(c['buffs'])
        if cls=="WARLOCK": buffs.append(([687,706,28176],"Demon armor"))
        for i,(seed,name) in enumerate(buffs):
            icon(p,effects+" | "+name,effects,cls,"buffs",aura_trigger(seed if isinstance(seed,list) else [seed]),26,
                x=(i-(len(buffs)-1)/2)*34,modern=True)
        bar(p,prefix+" | Cast",prefix,cls,"cast",dict(type="unit",event="Cast",unit="player",use_unit=True,spellNames=[]),
            width=300,height=13,y=-148,color=rgba(c['accent']),text="%p",name_text="%n")
        # A second bar is optional; Blizzard's original cast bar is untouched.
        if c.get('pet'):
            bar(p,prefix+" | Pet health",prefix,cls,"pet",dict(type="unit",event="Health",unit="pet",use_unit=True),
                x=-130,y=-13,width=161,height=7,color=rgba(c['accent']),text="%p")
        if c.get('extra')=="shards":
            d=p.add(prefix+" | Soul Shards","text",prefix,cls,"pet",x=130,y=-13,displayText="%s  |TInterface\\Icons\\INV_Misc_Gem_Amethyst_02:12|t",
                font="Friz Quadrata TT",fontSize=11,outline="OUTLINE",color=rgba(c['accent']),justify="CENTER",
                automaticWidth="Auto",fixedWidth=120,wordWrap="WordWrap")
            # Count the carried reagent, not a guessed modern Soul Shard power.
            p.triggers(d,[dict(type="item",event="Item Count",itemName=6265,use_itemName=True,use_exact_itemName=True,
                use_includeBank=False,use_includeWarBandBank=False,use_includeCharges=False)],cls,"pet")
        elif c.get('extra')=="combo":
            bar(p,prefix+" | Combo points",prefix,cls,"pet",dict(type="unit",event="Power",unit="player",use_unit=True,
                use_powertype=True,powertype=4),width=100,height=5,y=-127,color=rgba(c['accent']))
        elif c.get('extra')=="swing":
            for i,hand in enumerate([2] if cls=="HUNTER" else [0,1]):
                bar(p,prefix+f" | Swing {hand}",prefix,cls,"pet",dict(type="unit",event="Swing Timer",swingType=hand,use_swingType=True),
                    width=100,height=4,x=0 if cls=="HUNTER" else -55+i*110,y=-127,color=rgba(c['accent']),text="%p")
        elif c.get('extra')=="totems":
            for slot in range(1,5):
                icon(p,prefix+f" | Totem {slot}",prefix,cls,"pet",dict(type="spell",event="Totem",unit="player",
                    use_totemType=True,totemType=slot,use_inverse=False,use_clones=False),24,x=(slot-2.5)*32,y=-128)
    return dict(m="d",v=2000,s="1.3.5",d=p.displays[0],c=p.displays[1:])

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--skip-media',action='store_true')
    args=parser.parse_args()
    dist=ROOT/'dist';dist.mkdir(exist_ok=True)
    if not args.skip_media:
        from media import build
        build(ROOT/'src/EclipseHUD/Media',CLASSES)
    data=generate()
    (dist/'Eclipse-Class-Combat-HUD.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    (dist/'Eclipse-Class-Combat-HUD.lua').write_text('return '+lua(data)+'\n')
    subprocess.run(['lua',str(ROOT/'scripts/codec.lua'),'encode',str(dist/'Eclipse-Class-Combat-HUD.lua'),str(dist/'Eclipse-Class-Combat-HUD.txt')],check=True)
    target=dist/f'Eclipse-Class-Combat-HUD-v{VERSION}.zip'
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for path in sorted((ROOT/'src/EclipseHUD').rglob('*')):
            if path.is_file() and path.suffix in ('.toc','.lua','.tga'):
                z.write(path,path.relative_to(ROOT/'src'))
        z.write(dist/'Eclipse-Class-Combat-HUD.txt','Eclipse-Class-Combat-HUD.txt')
        for name in ('README.md','LICENSE','CHANGELOG.md'):
            if (ROOT/name).exists(): z.write(ROOT/name,name)
        for name in ('docs/design.md','docs/validation.md','preview/eclipse-warlock.png'):
            if (ROOT/name).exists(): z.write(ROOT/name,name)
    (dist/(target.name+'.sha256')).write_text(hashlib.sha256(target.read_bytes()).hexdigest()+'  '+target.name+'\n')
    print(f'Built {len(data["c"])+1} displays; {target.name} ({target.stat().st_size:,} bytes)')
if __name__=='__main__': main()
