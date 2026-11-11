#!/usr/bin/env python3
"""Build combined and per-class ForeverAuras imports with the companion ZIP."""
import argparse
import copy
import hashlib
import json
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
from catalog import (CLASSES, candidates, RANKS, PLANS, SCHOOLS, PREPARATION, EFFECTS, ALERTS, UPKEEP,
    HEALTH_COLOR, PET_HEALTH_COLOR, UNKNOWN_RESOURCE_COLOR, RESOURCE_STYLES)

VERSION = "0.3.5"
TITLE = "Eclipse | Class Combat HUD"
MEDIA = "Interface\\AddOns\\EclipseHUD\\Media\\"
EVENTS = "PLAYER_ENTERING_WORLD PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED PLAYER_TARGET_CHANGED UPDATE_SHAPESHIFT_FORM ECLIPSE_HUD_UPDATE FA_OPTIONS_CLOSED"
# Must equal E.importAPI in src/EclipseHUD/Core.lua (checked by scripts/check.py).
IMPORT_API = 1
# Must equal the TOC "## Interface:" value (checked by scripts/check.py).
TOC_VERSION = 16001
# Companion install/update: ForeverAuras reads "wago.io/<slug>/<build>" from a
# display's url and offers an update when an addon registers a higher build for
# that slug. Nothing is fetched online; the URL is only a version tag.
BUILD = sum(int(part)*scale for part,scale in zip(VERSION.split('.'),(10000,100,1)))
def update_slug(cls): return 'eclipse-hud-'+cls.lower()
def update_url(cls): return f'https://wago.io/{update_slug(cls)}/{BUILD}'
PRIMARY_Y = 52
SORT_CDM = 'function(a,b) return EclipseHUD and EclipseHUD.SortCDM(a,b) or false end'
# Fixed ZIP entry timestamp so identical inputs give an identical archive.
ZIP_DATE = (2026, 1, 1, 0, 0, 0)
UTF8 = dict(encoding='utf-8')
LF = dict(encoding='utf-8', newline='\n')

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
    def __init__(self): self.displays = []; self.by_id = {}; self.eligibility = {}
    def add(self, name, region, parent=None, cls=None, module="base", x=0, y=0, **fields):
        d = dict(id=name, uid=hashlib.sha256(name.encode()).hexdigest()[:11], regionType=region,
            internalVersion=91, tocversion=TOC_VERSION, semver=VERSION, version=1, author="Eclipse HUD contributors",
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
        if triggers[0].get('type')=='secretAura': ts['secretFallback']='none'
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
        subRegions=[dict(type="subbackground"),
            dict(type="subtexture",textureVisible=True,textureTexture=MEDIA+"icon-frame.tga",textureColor=[1,1,1,1],
                textureBlendMode="BLEND",textureDesaturate=False,textureMirror=False,textureRotation=0,
                texture_alpha=1,anchor_mode="area",anchor_area="ALL",xOffset=8,yOffset=8),
            subtext("%p",size=13),subtext("%s","BOTTOMRIGHT",10,x=-2,y=2)])
    if modern: d.update(inverse=True,blizzardAuraDisplay=dict(maxIcons=1,sharedDisplay=True,actionSounds=False))
    if not modern and trigger['event'] in ('Cooldown Progress (Spell)','Blizzard Cooldown Manager','Blizzard CDM Item'):
        d['cooldownTextDisabled']=False
        d['subRegions'][2]['text_visible']=False
        d['actions']['init']=dict(do_custom=True,custom=f'if EclipseHUD then EclipseHUD.StyleCooldown(aura_env.region or (ForeverAuras or WeakAuras).GetRegion(aura_env.id, aura_env.cloneId), "{cls}", "{module}") end')
    if known: d["load"].update(use_spellknown=True,spellknown=known,use_exact_spellknown=False)
    seeds = trigger.get("auraRankSpellIDs") if modern else ([known] if known else None)
    if seeds:
        flag = f"ECLIPSE_{cls}_{module}_"+d["uid"]
        d["load"]["loadFlag"] = flag
        pack.eligibility[name] = dict(cls=cls,module=module,seeds=seeds,flag=flag,kind="aura" if modern else "ability")
    pack.triggers(d,[trigger],cls,module)
    return d

def aura_trigger(ids,unit="player",harmful=False):
    return dict(type="secretAura",event="Health",unit=unit,debuffType="HARMFUL" if harmful else "HELPFUL",
        auraTracking="native",secretUseRankSpellIDs=True,auraRankSpellIDs=ids,
        secretUseSpellIDs=False,auraspellids=[],secretShowOn="showOnActive",
        nativeFilters={"PLAYER":True},useExactSpellId=False)

def bar(pack,name,parent,cls,module,trigger,width=170,height=13,x=0,y=0,color=None,text="%p",name_text=None,label=None):
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
        d["subRegions"][-1]["text_text_format_p_decimal_precision"]=0
        if trigger['event']=='Health' and trigger.get('unit')=='player':
            d['subRegions'][-1].update(text_text='%percenthealth%%  %p',
                text_text_format_percenthealth_format='Number',text_text_format_percenthealth_decimal_precision=0)
        d["subRegions"][-1]["text_text_format_p_big_number_format"]="AbbreviateNumbers"
        if '%t' in text:
            d['subRegions'][-1].update(text_text_format_t_format='Number',text_text_format_t_decimal_precision=0)
        if trigger.get('unit')=='player' and module=='resources':
            side='left' if trigger['event']=='Health' else 'right'
            d['actions']['init']=dict(do_custom=True,custom=f'if EclipseHUD then EclipseHUD.StyleResource(aura_env.region or (ForeverAuras or WeakAuras).GetRegion(aura_env.id), "{cls}", "{side}") end')
    if name_text: d["subRegions"].append(subtext(name_text,"INNER_LEFT",9,x=4))
    if label:
        d['subRegions'].append(subtext('%c','INNER_LEFT',9,x=4))
        d['customTextUpdate']='event'
        d['customText']=('function() return EclipseHUD and EclipseHUD.ResourceLabel() or "Resource" end' if label=='resource'
            else f'function() return EclipseHUD and EclipseHUD.L("{label}") or "{label}" end')
    if trigger['event']=='Power' and module=='resources':
        # Native state carries the current resource identity, including form
        # switches in combat. The helper never reads power amounts for color.
        d['barColor']=rgba(UNKNOWN_RESOURCE_COLOR)
        d['conditions']=[dict(check=dict(trigger=1,variable='powertype',op='==',value=power),
            changes=[dict(property='barColor',value=rgba(style['color']))]) for power,style in RESOURCE_STYLES.items()]
    pack.triggers(d,[trigger],cls,module)
    return d

def texture(pack,name,parent,cls,module,asset,w,h,x=0,y=0,color=None,level=None):
    d=pack.add(name,"texture",parent,cls,module,x,y,width=w,height=h,texture=MEDIA+asset+".tga",
        color=color or [1,1,1,1],desaturate=False,blendMode="BLEND",textureWrapMode="CLAMPTOBLACKADDITIVE",
        rotation=0,mirror=False,rotate=False)
    if level is not None: d['information']['eclipseFXPriority']=level
    return d

def cooldown(seed, secondary=False):
    return dict(type="spell",event="Cooldown Progress (Spell)",unit="player",spellName=seed,
        use_spellName=True,use_exact_spellName=False,use_ignoreoverride=False,use_ignoreSpellKnown=False,
        use_showgcd=not secondary,use_showgcdtext=False,track="cooldown",use_track=True,
        genericShowOn="showOnCooldown" if secondary else "showAlways",use_genericShowOn=True)

def combat_role(name):
    if name in {'Fear','Banish','Howl of Terror','Death Coil','Pummel','Shield Bash','Taunt','Mocking Blow',
        'Concussion Blow','Disarm','Intimidating Shout','Challenging Shout','Psychic Scream','Silence',
        'Counterspell','Frost Nova','Kick','Kidney Shot','Gouge','Blind','Distract','Bash','Challenging Roar',
        'Scatter Shot','Concussive Shot','Wing Clip','Frost Trap','Earthbind Totem','Hammer of Justice','Repentance','Turn Undead'}:
        return 'Control'
    if name in {'Shadow Ward','Fel Domination','Health Funnel','Shield Wall','Shield Block','Last Stand','Berserker Rage',
        'Ice Block','Ice Barrier','Evocation','Blink','Desperate Prayer','Fear Ward','Fade','Power Word: Shield',
        'Evasion','Vanish','Sprint','Barkskin','Frenzied Regeneration','Rebirth','Innervate','Tranquility',
        'Feign Death','Deterrence','Disengage','Grounding Totem','Tremor Totem','Mana Tide Totem','Riptide',
        'Divine Shield','Blessing of Protection','Blessing of Freedom','Lay on Hands','Holy Shield','Flash of Light','Holy Light'}:
        return 'Defense'
    return 'Offense'

def generate():
    p=Pack()
    root=p.add(TITLE,"group",anchorFrameType="SELECTFRAME",anchorFrameFrame="EclipseHUDAnchor",anchorFrameParent=True,
        groupIcon=MEDIA+"crest-warlock.tga",desc="Eclipse "+VERSION+" / 星蚀职业战斗界面\nOne import, nine classes. Controls: /eclipse. Native aura tracking; learned abilities only.\n一份导入，九职业自动切换。/eclipse 打开设置。使用原生光环追踪，只显示已学技能。")
    root["actions"]["init"] = dict(do_custom=True,custom="if EclipseHUD then EclipseHUD.Bind() end")
    for cls,c in CLASSES.items():
        prefix=f"Eclipse | {c['name']}"
        group=p.group(prefix,TITLE,cls,"base")
        group["groupIcon"]="Interface\\Icons\\"+c['icon']
        # The class root holds only organising sections (plus the cast bar),
        # never loose displays. Sections sit at (0,0), so each display keeps
        # its class-root coordinates. Creation order is draw order: frame art
        # first, so bars, icons and auras render above the seal.
        frame=prefix+' | Frame'; p.group(frame,prefix,cls,'base')
        resources=prefix+' | Resources'; p.group(resources,prefix,cls,'base')
        chassis=texture(p,prefix+" | Chassis",frame,cls,"art","chassis-"+cls.lower(),512,128,y=20)
        chassis['triggers'][2]['trigger']['custom']=f'function() return EclipseHUD and EclipseHUD.Gate("art","{cls}") and EclipseHUD.LayoutVisible() or false end'
        rune=texture(p,prefix+" | Living runes",frame,cls,"motion","runes",112,112,y=13,color=rgba(c['color'],.18))
        rune["animation"]["main"]=dict(type="custom",duration_type="seconds",duration=45,use_rotate=True,rotate=360,
            rotateType="straight",easeType="none",easeStrength=3)
        texture(p,prefix+" | Seal",frame,cls,"art","crest-"+cls.lower(),104,104,y=13)
        p.add(prefix+" | Class name","text",frame,cls,"base",y=79,displayText="",
            font="Friz Quadrata TT",fontSize=10,outline="OUTLINE",color=rgba(c['color']),justify="CENTER",
            automaticWidth="Auto",fixedWidth=200,wordWrap="WordWrap",shadowColor=[0,0,0,1],shadowXOffset=0,shadowYOffset=0)
        # Measured channel interiors in the packaged AI-painted frame.
        bar(p,prefix+" | Health",resources,cls,"resources",dict(type="unit",event="Health",unit="player",use_unit=True),
            x=-138,y=13,width=180,height=13,color=rgba(HEALTH_COLOR),label='Health')
        # No explicit powertype: Druid forms, Warrior rage and Rogue energy
        # follow the client's current resource automatically.
        bar(p,prefix+" | Resource",resources,cls,"resources",dict(type="unit",event="Power",unit="player",use_unit=True),
            x=138,y=13,width=180,height=13,label='resource')
        primary=prefix+" | Primary"; p.group(primary,prefix,cls,"primary",y=PRIMARY_Y)
        for side,grow in [('left','LEFT'),('right','RIGHT')]:
            wing_id=primary+' | Native '+side
            wing=p.group(wing_id,primary,cls,'primary',dynamic=True)
            wing.update(grow=grow,space=7,animate=True,sort='custom',sortOn='index',
                customSort='function(a,b) return EclipseHUD and EclipseHUD.SortCDM(a,b) or false end')
            wing['actions']['init']=dict(do_custom=True,custom=f'if EclipseHUD then EclipseHUD.BindAbility("{wing_id}") end')
        for slot in range(1,9):
            # Entry IDs/UIDs are stable since v0.3.2. Their former empty
            # "Native N" slot groups are gone: Update removes them, and a
            # v0.3.2 layout that still has them uses the helper's fallback.
            wing=primary+' | Native '+('left' if slot<=4 else 'right')
            slot_icon=icon(p,f'{primary} | Native {slot} | Entry',wing,cls,'primary',dict(type='cdm',event='Blizzard Cooldown Manager',
                cdmSource='cooldown',cdmSpells=dict(multi={}),cdmShow='cooldown',use_cdmShowGCD=False,
                cdmTrack='auto',cdmHideGCDText=True,use_ignoreSpellKnown=False),40)
            slot_icon['conditions']=[dict(check=dict(trigger=1,variable=variable,value=value),changes=[dict(property=prop,value=color)]) for variable,value,prop,color in [('onCooldown',1,'desaturate',True),('isUsable',0,'desaturate',True),('inRange',0,'color',[1,.3,.3,1])]]
        for seed,name in candidates(cls):
            d=icon(p,primary+" | "+name,primary,cls,"primary",cooldown(seed),40,known=seed)
            d['actions']['init']['custom']+='\nif EclipseHUD then EclipseHUD.BindAbility(aura_env.id) end'
            p.eligibility[d['id']].update(key=name,seeds=RANKS.get(name,[seed]) if cls=='WARRIOR' else [seed])
            d['conditions']=[dict(check=dict(trigger=1,variable="onCooldown",value=1),
                changes=[dict(property="desaturate",value=True)])]
            d['conditions'].append(dict(check=dict(trigger=1,variable="spellUsable",value=0),
                changes=[dict(property="desaturate",value=True)]))
            d['conditions'].append(dict(check=dict(trigger=1,variable="spellInRange",value=0),
                changes=[dict(property="color",value=[1,.3,.3,1])]))
            if cls=='WARRIOR' and name in {'Heroic Strike','Cleave','Overpower','Revenge','Execute','Victory Rush'}:
                d['subRegions'].append(dict(type="subglow",glow=False,useGlowColor=True,
                    glowColor=[1,.83,.25,1],glowType="Proc",glowFrequency=.25,glowDuration=1,glowLength=10,
                    glowThickness=1,glowScale=1,glowLines=8,glowXOffset=0,glowYOffset=0,glowBorder=False,
                    glowStartAnim=False))
                event='Queued Action' if name in {'Heroic Strike','Cleave'} else 'Spell Activation Overlay'
                d['triggers'][3]=dict(trigger=dict(type='spell',event=event,spellName=seed,
                    use_spellName=True,use_exact_spellName=False),untrigger={})
                d['triggers'].update(disjunctive='custom',customTriggerLogic='function(t) return t[1] and t[2] end')
                d['conditions'].append(dict(check=dict(trigger=3,variable='show',value=1),
                    changes=[dict(property='sub.5.glow',value=True)]))
                if event=='Spell Activation Overlay':
                    d['triggers'][4]=dict(trigger=dict(type='spell',event='Action Usable',spellName=seed,
                        use_spellName=True,use_exact_spellName=False,use_ignoreSpellCooldown=False,use_targetRequired=True),untrigger={})
                    d['conditions'].append(dict(check=dict(trigger=4,variable='show',value=1),
                        changes=[dict(property='sub.5.glow',value=True)]))
        utility=prefix+" | Utility";p.group(utility,prefix,cls,"utility",y=-57)
        for i,role in enumerate(('Defense','Offense','Control')):
            secondary=p.group(utility+" | "+role,utility,cls,"utility",x=(i-1)*160,dynamic=True)
            secondary.update(grow='GRID',gridType='HD',gridWidth=4,rowSpace=8,columnSpace=8)
        for seed,name in candidates(cls)+[(seed,name) for seed,name in c['utility'] if seed in PREPARATION]:
            d=icon(p,utility+" | "+name,utility+" | "+combat_role(name),cls,"utility",cooldown(seed,True),28,known=seed)
            p.eligibility[d['id']].update(key=name,seeds=RANKS.get(name,[seed]) if cls=='WARRIOR' else [seed],prep=seed in PREPARATION)
            d['conditions']=[dict(check=dict(trigger=1,variable="onCooldown",value=1),changes=[dict(property="desaturate",value=True)])]
        rows=prefix+' | Native rows'; p.group(rows,prefix,cls,'base')
        overflow=prefix+" | Native cooldowns"
        extra=p.group(overflow,rows,cls,"primary",y=-214,dynamic=True)
        extra.update(grow='GRID',gridType='HD',gridWidth=12,rowSpace=8,columnSpace=8,sort='custom',sortOn='index',customSort=SORT_CDM)
        icon(p,overflow+" | Entries",overflow,cls,"primary",dict(type="cdm",event="Blizzard Cooldown Manager",
            cdmSource="cooldown",cdmSpells=dict(multi={}),cdmShow="cooldown",use_cdmShowGCD=False,
            cdmTrack="auto",cdmHideGCDText=True,use_ignoreSpellKnown=False),28)
        for title,event,source,y in [('Native utility','Blizzard Cooldown Manager','cooldown',-57),
            ('Native items','Blizzard CDM Item','cooldown',-98)]:
            name=prefix+' | '+title
            extra=p.group(name,rows,cls,'utility',y=y,dynamic=True)
            extra.update(grow='GRID',gridType='HD',gridWidth=10,rowSpace=12,columnSpace=8,sort='custom',sortOn='index',customSort=SORT_CDM)
            icon(p,name+' | Entries',name,cls,'utility',dict(type='cdm',event=event,
                cdmSource=source,cdmSpells=dict(multi={}),cdmShow='cooldown',use_cdmShowGCD=False,
                cdmTrack='auto',cdmHideGCDText=True,use_ignoreSpellKnown=False),28)
        # Modern aura slots stay fixed in combat. No Lua presence inspection,
        # inferred timers, refresh windows, or combat-dependent group reflow.
        auras=prefix+' | Auras'; p.group(auras,prefix,cls,'base')
        nameplates=prefix+' | Nameplates'; p.group(nameplates,prefix,cls,'base')
        dots=prefix+" | Target effects"; p.group(dots,auras,cls,"dots",y=-130)
        count=len(c['dots'])
        for i,(seed,name) in enumerate(c['dots']):
            icon(p,dots+" | "+name,dots,cls,"dots",aura_trigger([seed],"target",True),32,x=(i-(count-1)/2)*40,modern=True)
            # Native nameplate displays are opt-in and tied to live plates.
            d=icon(p,nameplates+" | "+name,nameplates,cls,"nameplates",aura_trigger([seed],"nameplate",True),22,
                x=(i-(count-1)/2)*26,y=26,modern=True)
            d.update(anchorFrameType="NAMEPLATE",anchorFrameParent=False)
        maintenance=prefix+' | Maintenance'
        # Only classes with an upkeep aura get this row; no empty groups.
        if cls=='WARLOCK' or UPKEEP.get(cls):
            p.group(maintenance,auras,cls,'maintenance',x=-286,y=13,dynamic=True).update(grow='LEFT',space=6)
        effects=prefix+" | Player effects";p.group(effects,auras,cls,"buffs",y=116)
        native_effects=prefix+' | Native player effects'
        p.group(native_effects,auras,cls,'buffs',y=151,dynamic=True)
        icon(p,native_effects+' | Entries',native_effects,cls,'buffs',dict(type='cdm',event='Blizzard CDM Buff',
            cdmSource='buff',cdmSpells=dict(multi={}),cdmBuffShow='active',cdmTrack='auto',
            use_cdmShowGCD=False,cdmHideGCDText=True,use_ignoreSpellKnown=False),26)
        tracked=prefix+' | Native tracked bars'
        p.group(tracked,auras,cls,'trackedBars',x=410,y=13,dynamic=True).update(grow='DOWN',space=5,
            sort='custom',sortOn='index',customSort=SORT_CDM)
        bar(p,tracked+' | Entries',tracked,cls,'trackedBars',dict(type='cdm',event='Blizzard CDM Buff',
            cdmSource='buff',cdmSpells=dict(multi={}),cdmBuffShow='active',cdmTrack='auto',
            use_cdmShowGCD=False,cdmHideGCDText=True,use_ignoreSpellKnown=False),
            width=190,height=18,color=rgba(c['color']),text='%p',name_text='%n')
        buffs=list(c['buffs'])
        if cls=="WARLOCK": buffs.append(([687,706,28176],"Demon armor"))
        for i,(seed,name) in enumerate(buffs):
            upkeep=name=='Demon armor'
            d=icon(p,effects+" | "+name,maintenance if upkeep else effects,cls,'maintenance' if upkeep else 'buffs',
                aura_trigger(seed if isinstance(seed,list) else [seed]),20 if upkeep else 26,
                x=0 if upkeep else (i-(len(c['buffs'])-1)/2)*34,modern=True)
            if upkeep: d['subRegions'][2]['text_visible']=False

        for i,(seeds,name,missing) in enumerate(UPKEEP.get(cls,[])):
            upkeep=aura_trigger(seeds);upkeep['nativeFilters']={}
            icon(p,prefix+' | Upkeep | '+name,maintenance,cls,'maintenance',upkeep,20,modern=True)
            if missing:
                for expiring in (False,True):
                    reminder=copy.deepcopy(upkeep)
                    reminder.update(secretShowOn='showOnActive' if expiring else 'showOnMissing',
                        secretUseRem=expiring,secretRem=15,secretRemOperator='<=')
                    icon(p,prefix+' | Upkeep reminder | '+name+(' expiring' if expiring else ' missing'),maintenance,cls,'maintenance',
                        reminder,24,modern=True)
        if cls=='WARRIOR':
            for name,seed,unit,missing,remaining,x in (
                ('Rend missing',772,'target',True,False,-44),
                ('Battle Shout missing',6673,'player',True,False,0),
                ('Battle Shout expiring',6673,'player',False,True,0)):
                trigger=aura_trigger([seed],unit,unit=='target')
                if unit=='player': trigger['nativeFilters']={}
                trigger.update(secretShowOn='showOnMissing' if missing else 'showOnActive',
                    secretUseRem=remaining,secretRem=15,secretRemOperator='<=')
                reminder=icon(p,prefix+' | '+name,auras,cls,'dots' if unit=='target' else 'buffs',trigger,28,x=x,y=94,modern=True)
                if unit=='target':
                    reminder['triggers'][2]['trigger']['custom']='function() return EclipseHUD and EclipseHUD.Gate("dots","WARRIOR") and EclipseHUD.ReminderContext() or false end'
            for i,(seed,name) in enumerate(((7384,'Overpower'),(6572,'Revenge'),(5308,'Execute'),(402927,'Victory Rush'))):
                # Inside Primary, so the offset is relative to PRIMARY_Y; the
                # screen position matches the former class-root y=-23.
                proc=icon(p,prefix+' | Usable proc | '+name,primary,cls,'primary',dict(type='spell',event='Action Usable',
                    spellName=seed,use_spellName=True,use_exact_spellName=False,use_ignoreSpellCooldown=False,use_targetRequired=True),28,x=(i-1.5)*36,y=-23-PRIMARY_Y,known=seed)
                p.eligibility[proc['id']].update(proc=name)
        # FA's native Aura Start/Main settings bind playback to aura assignment
        # and lifetime. No helper hooks or alpha readback on native buttons.
        for tier,seeds in EFFECTS[cls].items():
            priority={'low':2,'blood':3,'eyes':4,'medium':5,'major':6,'defense':7}[tier]
            effect=texture(p,prefix+' | FX | '+tier,frame,cls,'fx',
                'crest-'+cls.lower() if tier in ('major','defense') else 'runes',
                110+priority*10,110+priority*10,y=13,color=rgba(c['accent'],.4),level=priority)
            if tier in ('major','defense'): effect['blendMode']='BLEND'
            else: effect['blendMode']='ADD'
            effect.update(inverse=True,blizzardAuraDisplay=dict(maxIcons=1,sharedDisplay=True,actionSounds=False,
                auraStart=dict(type='zoom' if tier in ('major','defense') else 'fade',duration=.35),
                auraMain=dict(type='pulse',duration=1.6)))
            p.triggers(effect,[aura_trigger(seeds)],cls,'fx')
            flag=f'ECLIPSE_{cls}_fx_'+effect['uid'];effect['load']['loadFlag']=flag
            p.eligibility[effect['id']]=dict(cls=cls,module='fx',seeds=seeds,flag=flag,kind='aura')
            if tier in ('medium','major','defense'):
                # Coordinated resource trim is native too and folds with bars.
                trim=texture(p,prefix+' | FX trim | '+tier,frame,cls,'fx','divider',470,32,y=13,color=rgba(c['accent'],.5),level=priority)
                trim.update(inverse=True,blizzardAuraDisplay=copy.deepcopy(effect['blizzardAuraDisplay']))
                p.triggers(trim,[aura_trigger(seeds)],cls,'fx')
                trim['triggers'][2]['trigger']['custom']=f'function() return EclipseHUD and EclipseHUD.Gate("fx","{cls}") and EclipseHUD.Gate("resources","{cls}") or false end'
                flag=f'ECLIPSE_{cls}_fx_'+trim['uid'];trim['load']['loadFlag']=flag
                p.eligibility[trim['id']]=dict(cls=cls,module='fx',requires='resources',seeds=seeds,flag=flag,kind='aura')
        powerfx=texture(p,prefix+' | FX resource intensity',frame,cls,'fx','runes',154,154,y=13,color=rgba(c['accent']),level=1)
        powerfx['alpha']=0
        powerfx['load']['loadFlag']=f'ECLIPSE_{cls}_fx_power'
        p.triggers(powerfx,[dict(type='unit',event='Power',unit='player',use_unit=True)],cls,'fx')
        powerfx['triggers'][2]['trigger']['custom']=f'function() return EclipseHUD and EclipseHUD.Gate("fx","{cls}") and EclipseHUD.InCombat() or false end'
        powerfx['conditions']=[dict(check=dict(trigger=1,variable='percentpower',op='>=',value=threshold),
            changes=[dict(property='alpha',value=alpha)]) for threshold,alpha in ((65,.1),(80,.3),(95,.48))]
        alerts=prefix+' | Alerts'; p.group(alerts,prefix,cls,'base')
        for seed,priority in ALERTS[cls]:
            alert=p.add(prefix+f' | Ready alert | {seed}','empty',alerts,cls,'alerts',width=1,height=1)
            p.triggers(alert,[dict(type='spell',event='Cooldown Ready (Spell)',spellName=seed,
                use_spellName=True,use_exact_spellName=False,use_ignoreSpellKnown=False,use_ignoreoverride=False)],cls,'alerts')
            alert['triggers'][2]['trigger']['custom']=f'function() return EclipseHUD and EclipseHUD.AlertGate("{cls}") or false end'
            flag=f'ECLIPSE_{cls}_alerts_'+alert['uid'];alert['load']['loadFlag']=flag
            p.eligibility[alert['id']]=dict(cls=cls,module='alerts',seeds=[seed],flag=flag,kind='ability')
            alert['actions']['start']=dict(do_custom=True,custom=f'if EclipseHUD then EclipseHUD.ReadyAlert("{alert["id"]}", {seed}, {priority}) end')
        cast=bar(p,prefix+" | Cast",prefix,cls,"cast",dict(type="unit",event="Cast",unit="player",use_unit=True,spellNames=[]),
            width=300,height=13,y=-178,color=rgba(c['accent']),text="%p",name_text="%n")
        cast['actions']['init']=dict(do_custom=True,custom='if EclipseHUD then EclipseHUD.RefreshCasting() end')
        # A second bar is optional; Blizzard's original cast bar is untouched.
        if c.get('pet'):
            bar(p,prefix+" | Pet health",resources,cls,"pet",dict(type="unit",event="Health",unit="pet",use_unit=True),
                x=-138,y=-13,width=180,height=7,color=rgba(PET_HEALTH_COLOR),text="%p",label='Pet')
        if c.get('extra')=="shards":
            d=p.add(prefix+" | Soul Shards","text",resources,cls,"pet",x=138,y=-13,displayText="%c: %s  |TInterface\\Icons\\INV_Misc_Gem_Amethyst_02:12|t",
                font="Friz Quadrata TT",fontSize=11,outline="OUTLINE",color=rgba(c['accent']),justify="CENTER",
                automaticWidth="Auto",fixedWidth=180,wordWrap="WordWrap",customTextUpdate='event',
                customText='function() return EclipseHUD and EclipseHUD.L("Soul Shards") or "Soul Shards" end')
            # Count the carried reagent, not a guessed modern Soul Shard power.
            p.triggers(d,[dict(type="item",event="Item Count",itemName=6265,use_itemName=True,use_exact_itemName=True,
                use_includeBank=False,use_includeWarBandBank=False,use_includeCharges=False)],cls,"pet")
        elif c.get('extra')=="combo":
            combo=bar(p,prefix+" | Combo points",resources,cls,"pet",dict(type="unit",event="Power",unit="player",use_unit=True,
                use_powertype=True,powertype=4),width=100,height=5,y=-155,color=rgba(RESOURCE_STYLES[4]['color']),text='%p / %t')
            if cls=='DRUID':
                combo['triggers'][2]['trigger']['custom']='function() return EclipseHUD and EclipseHUD.Gate("pet","DRUID") and EclipseHUD.ComboAllowed() or false end'
        elif c.get('extra')=="swing":
            for i,hand in enumerate([0,2] if cls=="HUNTER" else [0,1]):
                swing=bar(p,prefix+f" | Swing {hand}",resources,cls,"pet",dict(type="unit",event="Swing Timer",swingType=hand,use_swingType=True),
                    width=100,height=4,x=-55+i*110,y=-153,color=rgba(c['accent']),text="%p")
                if hand==1: swing['load']['loadFlag']='ECLIPSE_WARRIOR_pet_offhand'
        elif c.get('extra')=="totems":
            for slot in range(1,5):
                icon(p,prefix+f" | Totem {slot}",resources,cls,"pet",dict(type="spell",event="Totem",unit="player",
                    use_totemType=True,totemType=slot,use_inverse=False,use_clones=False),24,x=180+(slot-2.5)*32,y=-130)
        if cls in ('SHAMAN','ROGUE'):
            for i,hand in enumerate(('main','off') if cls=='ROGUE' else ('main',)):
                icon(p,prefix+' | Weapon coating | '+hand,auras,cls,'buffs',dict(type='item',event='Weapon Enchant',
                    weapon=hand,enchantKind='imbue' if cls=='SHAMAN' else 'temporary',showOn='showOnActive',use_enchant=False),24,
                    x=180+i*32,y=94)
        # FA computes frame levels from controlledChildren, not a display's
        # frameLevel field. Put ordered FX behind foreground bars/icons/seal.
        frame_group=p.by_id[frame]
        children=frame_group['controlledChildren']
        layers=[id for id in children if ' | FX' in id]
        layers.sort(key=lambda id:p.by_id[id]['information'].get('eclipseFXPriority',0))
        foreground=[id for id in children if id not in layers]
        seal=foreground.index(prefix+' | Seal')
        frame_group['controlledChildren']=foreground[:seal]+layers+foreground[seal:]
        # Organising sections only: no loose leaves at the class root.
        loose=[id for id in group['controlledChildren'] if 'controlledChildren' not in p.by_id[id] and id!=prefix+' | Cast']
        assert not loose,f'Loose displays at {prefix}: {loose}'
    # A newer import must fail closed while an older helper is still loaded.
    # Checking the table alone allowed hundreds of missing-method errors.
    for display in p.displays:
        containers=[display]+[action for action in display['actions'].values()]
        containers += [entry['trigger'] for key,entry in display['triggers'].items() if isinstance(key,int)]
        for container in containers:
            for key in ('custom','customText','customSort'):
                code=container.get(key)
                if isinstance(code,str) and 'EclipseHUD' in code:
                    guard=f'EclipseHUD and EclipseHUD.importAPI == {IMPORT_API}'
                    container[key]=code.replace('if EclipseHUD then',f'if {guard} then').replace('return EclipseHUD and ',f'return {guard} and ')
    # Every class display carries its class's update tag, so FA links the
    # installed group to the build the companion offers.
    for display in p.displays[1:]:
        display['url']=update_url(display['load']['class']['single'])
    message='Companion update required: install EclipseHUD and /reload before importing.'
    p.displays[0]['actions']['init']['custom']=(f'if EclipseHUD and EclipseHUD.importAPI == {IMPORT_API} then EclipseHUD.Bind() '
        f'else local message="{message}"; print("Eclipse {VERSION}: "..(EclipseHUD and EclipseHUD.L and EclipseHUD.L(message) or message)) end')
    return dict(m="d",v=2000,s="1.3.5",d=p.displays[0],c=p.displays[1:]),p.eligibility

def class_import(data, cls):
    """A native update is scoped to this class UID, never the shared root."""
    selected=[copy.deepcopy(d) for d in data['c'] if d['load']['class']['single']==cls]
    class_id='Eclipse | '+CLASSES[cls]['name']
    root=next(d for d in selected if d['id']==class_id)
    root.pop('parent',None)
    root['actions']['init']=copy.deepcopy(data['d']['actions']['init'])
    root['desc']='Eclipse '+VERSION+' / '+CLASSES[cls]['name']+' only. Update this class group; controls: /eclipse.'
    return dict(m=data['m'],v=data['v'],s=data['s'],d=root,c=[d for d in selected if d is not root])

def write_import(data, source, target):
    source.parent.mkdir(parents=True,exist_ok=True)
    target.parent.mkdir(parents=True,exist_ok=True)
    source.write_text('return '+lua(data)+'\n',**LF)
    subprocess.run(['lua',str(ROOT/'scripts/codec.lua'),'encode',str(source),str(target)],check=True)

def write_class_imports(data,dist):
    records=[]
    # Start clean so a renamed or removed class cannot leave a stale import
    # that would still be packaged.
    for folder in (dist/'classes',dist/'.build/classes'):
        if folder.exists(): shutil.rmtree(folder)
    for cls,c in CLASSES.items():
        value=class_import(data,cls)
        target=dist/'classes'/('Eclipse-'+c['name']+'.txt')
        write_import(value,dist/'.build/classes'/target.with_suffix('.lua').name,target)
        raw=target.read_bytes()
        records.append(dict(classToken=cls,name=c['name'],file=target.name,characters=len(raw.rstrip(b'\n')),
            bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),displays=len(value['c'])+1,rootID=value['d']['id'],rootUID=value['d']['uid'],
            updateSlug=update_slug(cls),updateBuild=BUILD))
    (dist/'classes/manifest.json').write_text(json.dumps(dict(version=VERSION,imports=records),indent=2)+'\n',**LF)
    rows=['# Per-class imports','','## English','',
        'You normally do not need these files. Install the EclipseHUD addon, `/reload`, and open `/fa`: your class is listed under **ready to be installed** or **updates**, or type `/eclipse install`. ForeverAuras shows its import window and you confirm.',
        'For manual import, paste one class file into `/fa` → Import; choose **Update** for an existing class group, not Import as Copy.',
        'Each file targets only its class group, preserving an existing combined parent and the other classes. New installations can use a class file alone.',
        'Use the combined import for a fresh nine-class installation or to update an existing combined group. Use class files for standalone class updates; choose Update rather than creating copies.',
        '', '| Class | Import | Characters | Displays |','| --- | --- | ---: | ---: |']
    rows += [f"| {r['name']} | [{r['file']}]({r['file']}) | {r['characters']:,} | {r['displays']} |" for r in records]
    rows += ['', '## 简体中文', '',
        '通常无需使用这些文件。安装 EclipseHUD 插件后输入 `/reload` 并打开 `/fa`：当前职业会出现在“待安装”或“更新”列表中，也可输入 `/eclipse install`。ForeverAuras 会显示导入窗口，由你确认。',
        '如需手动导入，把职业文件粘贴到 `/fa` → 导入；已有职业组请选择“更新”，不要导入为副本。',
        '每份文件仅更新自身职业组，保留原有合并父组和其他职业；首次安装也可单独使用一个职业文件。',
        '合并文件用于首次安装九职业或更新已有合并组；独立职业安装继续使用职业文件更新。',
        '', '| 职业 | 导入文件 | 字符数 | 显示数量 |', '| --- | --- | ---: | ---: |']
    rows += [f"| {CLASSES[r['classToken']]['zh']} | [{r['file']}]({r['file']}) | {r['characters']:,} | {r['displays']} |" for r in records]
    (dist/'classes/README.md').write_text('\n'.join(rows)+'\n',**LF)
    return records

def packaged_readme():
    return (ROOT/'README.md').read_text(**UTF8).replace('dist/classes/','imports/')

def zip_add(z,name,data):
    """Store one entry with fixed metadata, so equal bytes give an equal ZIP."""
    info=zipfile.ZipInfo(name,date_time=ZIP_DATE)
    info.compress_type=zipfile.ZIP_DEFLATED
    info.external_attr=0o644<<16
    z.writestr(info,data,compresslevel=9)

def write_package(target,dist):
    entries=[]
    for path in sorted((ROOT/'src/EclipseHUD').rglob('*')):
        if path.is_file() and path.suffix in ('.toc','.lua','.tga','.wav'):
            entries.append((path.relative_to(ROOT/'src').as_posix(),path.read_bytes()))
    entries.append(('Eclipse-Class-Combat-HUD.txt',(dist/'Eclipse-Class-Combat-HUD.txt').read_bytes()))
    for path in sorted((dist/'classes').iterdir()):
        if path.suffix in ('.txt','.json','.md'): entries.append(('imports/'+path.name,path.read_bytes()))
    entries.append(('README.md',packaged_readme().encode('utf-8')))
    for name in ('LICENSE','CHANGELOG.md'):
        if (ROOT/name).exists(): entries.append((name,(ROOT/name).read_bytes()))
    for path in sorted((ROOT/'docs').glob('*.md'))+[ROOT/'preview/eclipse-warlock.png']:
        if path.exists(): entries.append((path.relative_to(ROOT).as_posix(),path.read_bytes()))
    for folder in ('docs/images','preview/classes','preview/states','preview/casting'):
        for path in sorted((ROOT/folder).glob('*.png')): entries.append((path.relative_to(ROOT).as_posix(),path.read_bytes()))
    with zipfile.ZipFile(target,'w') as z:
        for name,data in entries: zip_add(z,name,data)

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--skip-media',action='store_true')
    args=parser.parse_args()
    dist=ROOT/'dist';dist.mkdir(exist_ok=True)
    if not args.skip_media:
        from media import build
        build(ROOT/'src/EclipseHUD/Media',CLASSES)
    from audio import build as build_audio
    build_audio(ROOT/'src/EclipseHUD/Audio')
    data,eligibility=generate()
    (dist/'Eclipse-Class-Combat-HUD.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',**LF)
    write_import(data,dist/'Eclipse-Class-Combat-HUD.lua',dist/'Eclipse-Class-Combat-HUD.txt')
    records=write_class_imports(data,dist)
    # The encoded class imports ship inside the addon (no separate file, so the
    # TOC file list is unchanged), for ForeverAuras' companion install/update.
    bundled={r['classToken']:dict(slug=r['updateSlug'],build=BUILD,version=VERSION,rootID=r['rootID'],
        encoded=(dist/'classes'/r['file']).read_text(**UTF8).strip()) for r in records}
    resource_names={power:style['name'] for power,style in RESOURCE_STYLES.items()}
    catalog=('-- Generated by scripts/build.py. Edit src/catalog.py or the generator.\nlocal _, E = ...\n'
        f'E.catalog = {lua(eligibility)}\nE.plans = {lua(PLANS)}\nE.schools = {lua(SCHOOLS)}\n'
        f'E.effectSpells = {lua(EFFECTS)}\nE.resourceNames = {lua(resource_names)}\n'
        f'E.bundledImports = {lua(bundled)}\n')
    (ROOT/'src/EclipseHUD/Catalog.lua').write_text(catalog,**LF)
    target=dist/f'Eclipse-Class-Combat-HUD-v{VERSION}.zip'
    write_package(target,dist)
    (dist/(target.name+'.sha256')).write_text(hashlib.sha256(target.read_bytes()).hexdigest()+'  '+target.name+'\n',**LF)
    print(f'Built {len(data["c"])+1} displays; {target.name} ({target.stat().st_size:,} bytes)')
if __name__=='__main__': main()
