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

VERSION = "0.11.0"
TITLE = "ForeverHUD"
MEDIA = "Interface\\AddOns\\ForeverHUD\\Media\\"
EVENTS = "PLAYER_ENTERING_WORLD PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED PLAYER_TARGET_CHANGED UPDATE_SHAPESHIFT_FORM FOREVERHUD_UPDATE FA_OPTIONS_CLOSED"
# Must equal E.importAPI in src/ForeverHUD/Core.lua (checked by scripts/check.py).
IMPORT_API = 2
# Must equal the TOC "## Interface:" value (checked by scripts/check.py).
TOC_VERSION = 16001
# Companion install/update: ForeverAuras reads "wago.io/<slug>/<build>" from a
# display's url and offers an update when an addon registers a higher build for
# that slug. Nothing is fetched online; the URL is only a version tag.
BUILD = sum(int(part)*scale for part,scale in zip(VERSION.split('.'),(10000,100,1)))
# The shared Core import: displays every class uses, loaded for all classes
# and gated on the current class at runtime. Class imports hold the rest.
CORE = "CORE"
CORE_ID = TITLE+" | Core"
# Art draws in LOW strata so Core bars (inherited MEDIUM) stay above it even
# though the two imports are separate roots with independent frame levels.
ART_STRATA = 3
def update_slug(owner): return 'forever-hud-'+owner.lower()
def update_url(owner): return f'https://wago.io/{update_slug(owner)}/{BUILD}'
def root_id(owner): return CORE_ID if owner==CORE else TITLE+' | '+CLASSES[owner]['name']
def owner_of(display):
    """The import that owns a display: CORE or a class token."""
    load=display['load']
    return CORE if load.get('loadFlag','').startswith('FOREVERHUD_CORE_') else load['class']['single']
# Ability wings sit above the DoT row, clear of the frame's top rim.
PRIMARY_Y = 80
# Target-effects (DoT) row seated on the frame directly over the Health bar
# (x -228..-48): the first slot sits at the bar's seal end, later slots run
# left along the bar.
DOT_ROW_Y = 40
DOT_SIZE = 28
DOT_STEP = 30
DOT_ROW_END = -60
# Mirror row seated over the resource bar (x 48..228) for the player's own
# buffs, Battle Shout reminders and weapon coatings: non-damage sits right.
BUFF_ROW_START = 60
# 0.7: rows are centred on their own bar and grow both ways. Bars sit at x=±138.
BAR_X = 138
# ForeverAuras Modern Aura Group: a normal group whose Aura (Modern) children
# are chained by the client and kept centred with half-size shadows, so the
# row re-centres in combat without any Lua reading aura state.
# 0.9 spell suggestions, highest priority first. Since 0.9.6 they sit on the
# damage side, centred over Health, directly above the DoT row (top y=54).
# 0.9.7: they stay there; for classes with suggestions the companion lifts
# the left cooldown wing (40 px icons at PRIMARY_Y) by WING_LIFT so it
# clears them (Selection.lua, S.WING_LIFT).
SUGGEST_SIZE = 32
SUGGEST_Y = DOT_ROW_Y + DOT_SIZE // 2 + 4 + SUGGEST_SIZE // 2
WING_LIFT = SUGGEST_Y + SUGGEST_SIZE // 2 + 4 + 40 // 2 - PRIMARY_Y
SUGGEST_STEP = 36
# 0.11: the rotation row is a Modern Aura Group growing LEFT from the seal:
# whatever shows closes up with no gaps, and the slot nearest the seal is
# always the top action. ForeverAuras starts a LEFT row at the first
# display's right edge, so the group sits half an icon in from that edge.
SUGGEST_LEAD_EDGE = -52          # 4 px outside the Health bar's inner end (-48)
SUGGEST_SPACING = 4
SUGGEST_ROW_X = SUGGEST_LEAD_EDGE - SUGGEST_SIZE // 2
SUGGEST_FLOW = dict(blizzardFlow=True, blizzardFlowGrowth='LEFT', blizzardFlowSpacing=SUGGEST_SPACING)
# Five actions fill the Health bar exactly (5*32 + 4*4 = 176 of 180 px).
SUGGEST_MAX = 5
# Threshold cues can't join the row (they're shown at zero opacity until the
# curve fires, so they'd hold a slot). They sit beside the bar they're about:
# mana under the Mana bar's outer end, pet under the Pet bar's, and a target
# execute cue in a fixed slot at the far end of the rotation row.
CUE_SIZE = 22
MANA_CUE = (218, -28)
PET_CUE = (-218, -28)
EXECUTE_CUE = (-228 + SUGGEST_SIZE // 2, SUGGEST_Y)
# 0.10: one priority list per spec (the companion's detected or chosen
# school), plus 'Leveling' for no talent points. Highest priority first.
# Rule kinds, each a single native check:
#   curve   - a player/pet/target health or power curve at or under a value
#   missing - your debuff is missing from the hostile target
#   buff    - your own buff is missing (in combat with a hostile target)
#   active  - a proc/buff aura of yours is up
#   ready   - the spell is usable now (native Action Usable)
# Every rule loads only once its spell (or talent) is learned, so an ID the
# client doesn't know never shows. IDs come from src/catalog.py where listed.
def curve(name,known,icon,at,unit='player',event='Power',powertype=None):
    variable='percentpower' if event=='Power' else 'percenthealth'
    return dict(kind='curve',name=name,event=event,unit=unit,variable=variable,at=at,known=known,icon=icon,powertype=powertype)
def missing(name,seed): return dict(kind='missing',name=name,seed=seed)
def buff(name,seed): return dict(kind='buff',name=name,seed=seed)
def active(name,seed,talent=None): return dict(kind='active',name=name,seed=seed,talent=talent)
def ready(name,seed): return dict(kind='ready',name=name,seed=seed)
LIFE_TAP=curve('Life Tap',1454,'Spell_Shadow_BurningSpirit',30)
HEALTH_FUNNEL=curve('Health Funnel',755,'Spell_Shadow_LifeDrain',35,'pet','Health')
EVOCATION=curve('Evocation',12051,'Spell_Nature_Purge',20)
# Druids shapeshift into energy/rage forms, so Innervate tests mana explicitly.
INNERVATE=curve('Innervate',29166,'Spell_Nature_Lightning',30,powertype=0)
MEND_PET=curve('Mend Pet',136,'Ability_Hunter_MendPet',40,'pet','Health')
HUNTERS=[missing("Hunter's Mark",1130),missing('Serpent Sting',1978)]
SUGGESTIONS = {
    'WARLOCK': {
        # 0.9 list, kept with its display IDs for characters without talents.
        'Leveling':[LIFE_TAP,missing('Corruption',172),missing('Immolate',348),
            active('Shadow Trance',17941,[18094,18095]),HEALTH_FUNNEL],
        'Affliction':[LIFE_TAP,missing('Corruption',172),missing('Bane of Agony',980),
            missing('Siphon Life',18265),active('Shadow Trance',17941,[18094,18095])],
        'Demonology':[LIFE_TAP,missing('Corruption',172),missing('Immolate',348),
            missing('Bane of Agony',980),HEALTH_FUNNEL],
        'Destruction':[LIFE_TAP,missing('Immolate',348),ready('Conflagrate',1293817),
            active('Backlash',34936),curve('Shadowburn',17877,'Spell_Shadow_ScourgeBuild',25,'target','Health')],
    },
    'MAGE': {
        'Arcane':[EVOCATION,active('Missile Barrage',44401)],
        'Fire':[EVOCATION,missing('Improved Scorch',22959),active('Hot Streak',44445)],
        'Frost':[EVOCATION,active('Fingers of Frost',44544)],
    },
    'PRIEST': {
        'Discipline':[active('Surge of Light',33151),ready('Penance',402174)],
        'Holy':[active('Surge of Light',33151),ready('Prayer of Mending',401859)],
        'Shadow':[buff('Shadowform',15473),missing('Shadow Word: Pain',589),missing('Vampiric Embrace',15286),
            missing('Devouring Plague',2944),ready('Mind Blast',8092)],
    },
    'ROGUE': {
        'Assassination':[buff('Slice and Dice',5171),missing('Rupture',1943)],
        'Combat':[buff('Slice and Dice',5171),missing('Rupture',1943)],
        'Subtlety':[buff('Slice and Dice',5171),missing('Hemorrhage',16511)],
    },
    'DRUID': {
        'Balance':[INNERVATE,missing('Moonfire',8921),missing('Faerie Fire',770),active('Clearcasting',16870)],
        'Feral':[missing('Faerie Fire',770),missing('Rake',1822),missing('Rip',1079),active('Clearcasting',16870)],
        'Restoration':[INNERVATE,active('Clearcasting',16870)],
    },
    'HUNTER': {
        'Beast Mastery':HUNTERS+[MEND_PET],
        'Marksmanship':HUNTERS+[MEND_PET],
        'Survival':HUNTERS+[ready('Counterattack',19306),ready('Mongoose Bite',1495),MEND_PET],
    },
    'SHAMAN': {
        'Elemental':[missing('Flame Shock',8050),buff('Lightning Shield',324)],
        'Enhancement':[buff('Lightning Shield',324),active('Maelstrom Weapon',53817),ready('Stormstrike',17364),missing('Flame Shock',8050)],
        'Restoration':[curve('Mana Tide Totem',16190,'Spell_Frost_SummonWaterElemental',30),ready('Riptide',408521)],
    },
    'PALADIN': {
        'Holy':[ready('Holy Shock',1311606)],
        'Protection':[buff('Holy Shield',20925),ready('Consecration',26573),ready('Judgement',20271)],
        'Retribution':[ready('Hammer of Wrath',24275),ready('Judgement',20271),ready('Consecration',26573)],
    },
    # Warrior procs (Overpower, Revenge, Execute, Victory Rush) and the Rend /
    # Battle Shout reminders already have their own rows; suggestions add
    # each spec's main strike.
    'WARRIOR': {
        'Arms':[ready('Mortal Strike',12294)],
        'Fury':[ready('Bloodthirst',23881),ready('Whirlwind',1680)],
        'Protection':[ready('Shield Slam',23922)],
    },
}
# 0.8 retracted mode: larger seal and the tray under it.
RETRACTED_SEAL = 132
TRAY_ICON = 34
# The native aura buttons' dark inner ring, copied on the ordinary tray icon.
TRAY_RING = 3
TRAY_RING_COLOR = [0.04, 0.03, 0.06, 1]
# Frame outset on the tray counter, matching the native buttons' tight frame,
# and the tray row's gap so neighbouring frames don't overlap.
TRAY_FRAME_OUTSET = 3
TRAY_SPACING = 8
TRAY_ROW1_Y = -74
CENTRED_FLOW = dict(blizzardFlow=True, blizzardFlowGrowth='CENTER_HORIZONTAL', blizzardFlowSpacing=2)
# Class-plan secondary rows by side: damage left, support right.
ROLE_X = {'Offense':-160,'Control':0,'Defense':160}
# Neutral Core paint until the helper applies the class colour.
CORE_ACCENT = "#B9A3E8"
SORT_CDM = 'function(a,b) return ForeverHUD and ForeverHUD.SortCDM(a,b) or false end'
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
            internalVersion=91, tocversion=TOC_VERSION, semver=VERSION, version=1, author="ForeverHUD contributors",
            xOffset=x, yOffset=y, anchorPoint="CENTER", selfPoint="CENTER", anchorFrameType="SCREEN",
            frameStrata=1, alpha=1, scale=1, load={}, subRegions=[], config={}, authorOptions=[], conditions=[],
            information=dict(forceEvents=False, groupOffset=False, ignoreOptionsEventErrors=False),
            actions=dict(init={},start={},finish={}),
            animation={k:dict(type="none",duration_type="seconds",easeType="none",easeStrength=3) for k in ("start","main","finish")})
        if parent:
            d["parent"] = parent
            self.by_id[parent]["controlledChildren"].append(name)
        if cls==CORE:
            # use_class=false is FA's multi-select mode: every supported class.
            d["load"] = dict(use_class=False, **{"class":dict(multi={c:True for c in CLASSES})},
                use_loadFlag=True, loadFlag=f"FOREVERHUD_CORE_{module}")
        elif cls:
            d["load"] = dict(use_class=True, **{"class":dict(single=cls,multi={})},
                use_loadFlag=True, loadFlag=f"FOREVERHUD_{cls}_{module}")
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
            custom=f'function(event) return ForeverHUD and ForeverHUD.Gate("{module}", "{cls}") or false end')
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
        d['actions']['init']=dict(do_custom=True,custom=f'if ForeverHUD then ForeverHUD.StyleCooldown(aura_env.region or (ForeverAuras or WeakAuras).GetRegion(aura_env.id, aura_env.cloneId), "{cls}", "{module}") end')
    if known: d["load"].update(use_spellknown=True,spellknown=known,use_exact_spellknown=False)
    seeds = trigger.get("auraRankSpellIDs") if modern else ([known] if known else None)
    if seeds:
        flag = f"FOREVERHUD_{cls}_{module}_"+d["uid"]
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
            d['actions']['init']=dict(do_custom=True,custom=f'if ForeverHUD then ForeverHUD.StyleResource(aura_env.region or (ForeverAuras or WeakAuras).GetRegion(aura_env.id), "{cls}", "{side}") end')
    if name_text: d["subRegions"].append(subtext(name_text,"INNER_LEFT",9,x=4))
    if label:
        d['subRegions'].append(subtext('%c','INNER_LEFT',9,x=4))
        d['customTextUpdate']='event'
        d['customText']=('function() return ForeverHUD and ForeverHUD.ResourceLabel() or "Resource" end' if label=='resource'
            else f'function() return ForeverHUD and ForeverHUD.L("{label}") or "{label}" end')
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
    if level is not None: d['information']['fxPriority']=level
    d['frameStrata']=ART_STRATA
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
    root=p.add(TITLE,"group",anchorFrameType="SELECTFRAME",anchorFrameFrame="ForeverHUDAnchor",anchorFrameParent=True,
        groupIcon=MEDIA+"crest-warlock.tga",desc="ForeverHUD "+VERSION+" / 职业战斗界面\nOne import: the shared Core plus nine classes. Controls: /fhud. Native aura tracking; learned abilities only.\n一份导入：通用核心加九个职业。/fhud 打开设置。使用原生光环追踪，只显示已学技能。")
    # Core: displays with the same layout and native data for every class.
    # Section order is draw order within this root; class art sits in LOW
    # strata, so these bars and icons render above it.
    core=p.group(CORE_ID,TITLE,CORE,'base')
    core['groupIcon']=MEDIA+'crest-warlock.tga'
    resources=CORE_ID+' | Resources'; p.group(resources,CORE_ID,CORE,'base')
    # Measured channel interiors in the packaged AI-painted frame.
    bar(p,CORE_ID+" | Health",resources,CORE,"resources",dict(type="unit",event="Health",unit="player",use_unit=True),
        x=-138,y=13,width=180,height=13,color=rgba(HEALTH_COLOR),label='Health')
    # No explicit powertype: Druid forms, Warrior rage and Rogue energy
    # follow the client's current resource automatically.
    bar(p,CORE_ID+" | Resource",resources,CORE,"resources",dict(type="unit",event="Power",unit="player",use_unit=True),
        x=138,y=13,width=180,height=13,label='resource',color=rgba(UNKNOWN_RESOURCE_COLOR))
    rows=CORE_ID+' | Native rows'; p.group(rows,CORE_ID,CORE,'base')
    overflow=CORE_ID+" | Native cooldowns"
    # Overflow rows follow the sides too: Essential (damage) under Health,
    # Utility and items under the resource bar.
    extra=p.group(overflow,rows,CORE,"primary",x=-138,y=-110,dynamic=True)
    extra.update(grow='GRID',gridType='HD',gridWidth=5,rowSpace=8,columnSpace=8,sort='custom',sortOn='index',customSort=SORT_CDM)
    icon(p,overflow+" | Entries",overflow,CORE,"primary",dict(type="cdm",event="Blizzard Cooldown Manager",
        cdmSource="cooldown",cdmSpells=dict(multi={}),cdmShow="cooldown",use_cdmShowGCD=False,
        cdmTrack="auto",cdmHideGCDText=True,use_ignoreSpellKnown=False),28)
    for title,event,source,y in [('Native utility','Blizzard Cooldown Manager','cooldown',-57),
        ('Native items','Blizzard CDM Item','cooldown',-130)]:
        name=CORE_ID+' | '+title
        extra=p.group(name,rows,CORE,'utility',x=138,y=y,dynamic=True)
        extra.update(grow='GRID',gridType='HD',gridWidth=5,rowSpace=12,columnSpace=8,sort='custom',sortOn='index',customSort=SORT_CDM)
        icon(p,name+' | Entries',name,CORE,'utility',dict(type='cdm',event=event,
            cdmSource=source,cdmSpells=dict(multi={}),cdmShow='cooldown',use_cdmShowGCD=False,
            cdmTrack='auto',cdmHideGCDText=True,use_ignoreSpellKnown=False),28)
    native_auras=CORE_ID+' | Native auras'; p.group(native_auras,CORE_ID,CORE,'base')
    native_effects=CORE_ID+' | Native player effects'
    # Native buffs mirror the DoT row: seated on the rim over the resource
    # bar, centred, same size and spacing. In Cooldown Manager mode they
    # replace the class buff rail at the same spot (Selection.Allowed), so the
    # two rows never share it.
    p.group(native_effects,native_auras,CORE,'buffs',x=BAR_X,y=DOT_ROW_Y,dynamic=True).update(grow='HORIZONTAL',align='CENTER',space=2)
    icon(p,native_effects+' | Entries',native_effects,CORE,'buffs',dict(type='cdm',event='Blizzard CDM Buff',
        cdmSource='buff',cdmSpells=dict(multi={}),cdmBuffShow='active',cdmTrack='auto',
        use_cdmShowGCD=False,cdmHideGCDText=True,use_ignoreSpellKnown=False),DOT_SIZE)
    tracked=CORE_ID+' | Native tracked bars'
    # Tracked bars carry DoT and proc durations: the damage side, left.
    p.group(tracked,native_auras,CORE,'trackedBars',x=-410,y=13,dynamic=True).update(grow='DOWN',space=5,
        sort='custom',sortOn='index',customSort=SORT_CDM)
    bar(p,tracked+' | Entries',tracked,CORE,'trackedBars',dict(type='cdm',event='Blizzard CDM Buff',
        cdmSource='buff',cdmSpells=dict(multi={}),cdmBuffShow='active',cdmTrack='auto',
        use_cdmShowGCD=False,cdmHideGCDText=True,use_ignoreSpellKnown=False),
        width=190,height=18,color=rgba(CORE_ACCENT),text='%p',name_text='%n')
    cast=bar(p,CORE_ID+" | Cast",CORE_ID,CORE,"cast",dict(type="unit",event="Cast",unit="player",use_unit=True,spellNames=[]),
        width=300,height=13,y=-178,color=rgba(CORE_ACCENT),text="%p",name_text="%n")
    # One Core serves every class: the helper paints the class accent.
    cast['actions']['init']=dict(do_custom=True,custom='if ForeverHUD then ForeverHUD.RefreshCasting(); ForeverHUD.Tint(aura_env.region or (ForeverAuras or WeakAuras).GetRegion(aura_env.id), "accent") end')
    # Core has no class name leaf, so its always-on bars request the layout
    # bind that anchors this root (Bind is idempotent).
    for leaf in (CORE_ID+' | Health',CORE_ID+' | Resource',CORE_ID+' | Cast'):
        p.by_id[leaf]['actions']['init']['custom']+='\nif ForeverHUD then ForeverHUD.Bind() end'
    loose=[id for id in core['controlledChildren'] if 'controlledChildren' not in p.by_id[id] and id!=CORE_ID+' | Cast']
    assert not loose,f'Loose displays at {CORE_ID}: {loose}'
    for cls,c in CLASSES.items():
        prefix=f"ForeverHUD | {c['name']}"
        group=p.group(prefix,TITLE,cls,"base")
        group["groupIcon"]="Interface\\Icons\\"+c['icon']
        # The class root holds only organising sections (plus the cast bar),
        # never loose displays. Sections sit at (0,0), so each display keeps
        # its class-root coordinates. Creation order is draw order: frame art
        # first, so bars, icons and auras render above the seal.
        frame=prefix+' | Frame'; p.group(frame,prefix,cls,'base')
        # Health, resource and cast live in Core; this section holds only the
        # class's own bars (pet health and the class extra), when it has any.
        resources=prefix+' | Resources'
        if c.get('pet') or c.get('extra'): p.group(resources,prefix,cls,'base')
        chassis=texture(p,prefix+" | Chassis",frame,cls,"art","chassis-"+cls.lower(),512,128,y=20)
        chassis['triggers'][2]['trigger']['custom']=f'function() return ForeverHUD and ForeverHUD.Gate("art","{cls}") and ForeverHUD.LayoutVisible() or false end'
        rune=texture(p,prefix+" | Living runes",frame,cls,"motion","runes",112,112,y=13,color=rgba(c['color'],.18))
        rune["animation"]["main"]=dict(type="custom",duration_type="seconds",duration=45,use_rotate=True,rotate=360,
            rotateType="straight",easeType="none",easeStrength=3)
        seal=texture(p,prefix+" | Seal",frame,cls,"art","crest-"+cls.lower(),104,104,y=13)
        # 0.8 retracted mode: a larger seal replaces the normal one while the
        # HUD is folded and its tray shows (both gated by the companion).
        seal['triggers'][2]['trigger']['custom']=f'function() return ForeverHUD and ForeverHUD.Gate("art","{cls}") and not ForeverHUD.Retracted() or false end'
        big=texture(p,prefix+" | Seal | Retracted",frame,cls,"art","crest-"+cls.lower(),RETRACTED_SEAL,RETRACTED_SEAL,y=13)
        big['triggers'][2]['trigger']['custom']=f'function() return ForeverHUD and ForeverHUD.Gate("art","{cls}") and ForeverHUD.Retracted() or false end'
        # ForeverAuras compiles custom actions only for non-group displays and
        # fails when a group with an Init action is activated (for example by
        # a dynamic-group sort during import). The companion bind and the
        # version guard therefore live on this always-loaded class leaf.
        name_text=p.add(prefix+" | Class name","text",frame,cls,"base",y=79,displayText="",
            font="Friz Quadrata TT",fontSize=10,outline="OUTLINE",color=rgba(c['color']),justify="CENTER",
            automaticWidth="Auto",fixedWidth=200,wordWrap="WordWrap",shadowColor=[0,0,0,1],shadowXOffset=0,shadowYOffset=0)
        name_text['actions']['init']=dict(do_custom=True,custom="if ForeverHUD then ForeverHUD.Bind() end")
        primary=prefix+" | Primary"; p.group(primary,prefix,cls,"primary",y=PRIMARY_Y)
        # Cradles: each wing is centred on its bar (the companion places it at
        # x=±138) and grows evenly both ways.
        for side in ('left','right'):
            wing_id=primary+' | Native '+side
            wing=p.group(wing_id,primary,cls,'primary',dynamic=True)
            wing.update(grow='HORIZONTAL',align='CENTER',space=7,animate=True,sort='custom',sortOn='index',
                customSort='function(a,b) return ForeverHUD and ForeverHUD.SortCDM(a,b) or false end')
        for slot in range(1,9):
            # Entry IDs/UIDs are stable since v0.3.2. Their former empty
            # "Native N" slot groups are gone: Update removes them, and a
            # v0.3.2 layout that still has them uses the helper's fallback.
            wing=primary+' | Native '+('left' if slot<=4 else 'right')
            slot_icon=icon(p,f'{primary} | Native {slot} | Entry',wing,cls,'primary',dict(type='cdm',event='Blizzard Cooldown Manager',
                cdmSource='cooldown',cdmSpells=dict(multi={}),cdmShow='cooldown',use_cdmShowGCD=False,
                cdmTrack='auto',cdmHideGCDText=True,use_ignoreSpellKnown=False),40)
            # The wing is a group, so its layout bind rides on each entry.
            slot_icon['actions']['init']['custom']+=f'\nif ForeverHUD then ForeverHUD.BindAbility("{wing}") end'
            slot_icon['conditions']=[dict(check=dict(trigger=1,variable=variable,value=value),changes=[dict(property=prop,value=color)]) for variable,value,prop,color in [('onCooldown',1,'desaturate',True),('isUsable',0,'desaturate',True),('inRange',0,'color',[1,.3,.3,1])]]
        for seed,name in candidates(cls):
            d=icon(p,primary+" | "+name,primary,cls,"primary",cooldown(seed),40,known=seed)
            d['actions']['init']['custom']+='\nif ForeverHUD then ForeverHUD.BindAbility(aura_env.id) end'
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
        for role in ('Defense','Offense','Control'):
            secondary=p.group(utility+" | "+role,utility,cls,"utility",x=ROLE_X[role],dynamic=True)
            secondary.update(grow='GRID',gridType='HD',gridWidth=4,rowSpace=8,columnSpace=8)
        for seed,name in candidates(cls)+[(seed,name) for seed,name in c['utility'] if seed in PREPARATION]:
            d=icon(p,utility+" | "+name,utility+" | "+combat_role(name),cls,"utility",cooldown(seed,True),28,known=seed)
            p.eligibility[d['id']].update(key=name,seeds=RANKS.get(name,[seed]) if cls=='WARRIOR' else [seed],prep=seed in PREPARATION)
            d['conditions']=[dict(check=dict(trigger=1,variable="onCooldown",value=1),changes=[dict(property="desaturate",value=True)])]
        # Modern aura slots stay fixed in combat. No Lua presence inspection,
        # inferred timers, refresh windows, or combat-dependent group reflow.
        auras=prefix+' | Auras'; p.group(auras,prefix,cls,'base')
        nameplates=prefix+' | Nameplates'; p.group(nameplates,prefix,cls,'base')
        # Damage sits on the left: the player's DoTs form a fixed row seated
        # on the frame over the Health bar, below the left (Essential) wing.
        # Fixed slots, never a combat reflow of modern aura buttons.
        dots=prefix+" | Target effects"; p.group(dots,auras,cls,"dots",x=-BAR_X,y=DOT_ROW_Y).update(CENTRED_FLOW)
        count=len(c['dots'])
        for i,(seed,name) in enumerate(c['dots']):
            icon(p,dots+" | "+name,dots,cls,"dots",aura_trigger([seed],"target",True),DOT_SIZE,modern=True)
            # Native nameplate displays are opt-in and tied to live plates.
            d=icon(p,nameplates+" | "+name,nameplates,cls,"nameplates",aura_trigger([seed],"nameplate",True),22,
                x=(i-(count-1)/2)*26,y=26,modern=True)
            d.update(anchorFrameType="NAMEPLATE",anchorFrameParent=False)
        maintenance=prefix+' | Maintenance'
        # Only classes with an upkeep aura get this row; no empty groups.
        # Upkeep buffs are not damage: they sit right, beyond the resource bar.
        if cls=='WARLOCK' or UPKEEP.get(cls):
            p.group(maintenance,auras,cls,'maintenance',x=286,y=13,dynamic=True).update(grow='RIGHT',space=6)
        # The player's own buffs are not damage: a fixed row seated over the
        # resource bar, mirroring the DoT row over Health.
        effects=prefix+" | Player effects";p.group(effects,auras,cls,"buffs",x=BAR_X,y=DOT_ROW_Y).update(CENTRED_FLOW)
        # 0.8.1: an upkeep buff that is up needs no icon; its missing and
        # expiring reminders (below) are the signal. Demon armor has no
        # always-on display any more.
        for i,(seed,name) in enumerate(c['buffs']):
            d=icon(p,effects+" | "+name,effects,cls,'buffs',
                aura_trigger(seed if isinstance(seed,list) else [seed]),DOT_SIZE,modern=True)
            # Curated class buffs show only in Class plan mode; Cooldown
            # Manager mode shows the player's tracked buffs at the same spot.
            p.eligibility[d['id']].update(effect=True)

        def upkeep_reminders(seeds,name):
            # Native Show On: Aura(s) Missing / Remaining Time; nothing inferred.
            upkeep=aura_trigger(seeds);upkeep['nativeFilters']={}
            for expiring in (False,True):
                reminder=copy.deepcopy(upkeep)
                reminder.update(secretShowOn='showOnActive' if expiring else 'showOnMissing',
                    secretUseRem=expiring,secretRem=15,secretRemOperator='<=')
                icon(p,prefix+' | Upkeep reminder | '+name+(' expiring' if expiring else ' missing'),maintenance,cls,'maintenance',
                    reminder,24,modern=True)
        for i,(seeds,name,missing) in enumerate(UPKEEP.get(cls,[])):
            if missing:
                # Reminders cover it: no "it's up" icon (0.8.1).
                upkeep_reminders(seeds,name)
            else:
                # No reminder for this buff, so its active icon is the only cue.
                upkeep=aura_trigger(seeds);upkeep['nativeFilters']={}
                icon(p,prefix+' | Upkeep | '+name,maintenance,cls,'maintenance',upkeep,20,modern=True)
        if cls=='WARLOCK':
            # Demon Skin / Demon Armor / Fel Armor: shown only when none is up,
            # or in its last 15 seconds.
            upkeep_reminders([687,706,28176],'Demon armor')
        if cls=='WARRIOR':
            # Rend (damage) joins the centred DoT row over Health; Battle Shout
            # (a buff) joins the centred buff row over the resource bar.
            for name,seed,unit,missing,remaining in (
                ('Rend missing',772,'target',True,False),
                ('Battle Shout missing',6673,'player',True,False),
                ('Battle Shout expiring',6673,'player',False,True)):
                trigger=aura_trigger([seed],unit,unit=='target')
                if unit=='player': trigger['nativeFilters']={}
                trigger.update(secretShowOn='showOnMissing' if missing else 'showOnActive',
                    secretUseRem=remaining,secretRem=15,secretRemOperator='<=')
                reminder=icon(p,prefix+' | '+name,dots if unit=='target' else effects,cls,'dots' if unit=='target' else 'buffs',trigger,DOT_SIZE,modern=True)
                if unit=='target':
                    reminder['triggers'][2]['trigger']['custom']='function() return ForeverHUD and ForeverHUD.Gate("dots","WARRIOR") and ForeverHUD.ReminderContext() or false end'
            for i,(seed,name) in enumerate(((7384,'Overpower'),(6572,'Revenge'),(5308,'Execute'),(402927,'Victory Rush'))):
                # Damage procs sit left, under the Health bar. Inside Primary,
                # so the offset is relative to PRIMARY_Y (screen y=-23).
                proc=icon(p,prefix+' | Usable proc | '+name,primary,cls,'primary',dict(type='spell',event='Action Usable',
                    spellName=seed,use_spellName=True,use_exact_spellName=False,use_ignoreSpellCooldown=False,use_targetRequired=True),28,x=-74-i*32,y=-23-PRIMARY_Y,known=seed)
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
            flag=f'FOREVERHUD_{cls}_fx_'+effect['uid'];effect['load']['loadFlag']=flag
            p.eligibility[effect['id']]=dict(cls=cls,module='fx',seeds=seeds,flag=flag,kind='aura')
            if tier in ('medium','major','defense'):
                # Coordinated resource trim is native too and folds with bars.
                trim=texture(p,prefix+' | FX trim | '+tier,frame,cls,'fx','divider',470,32,y=13,color=rgba(c['accent'],.5),level=priority)
                trim.update(inverse=True,blizzardAuraDisplay=copy.deepcopy(effect['blizzardAuraDisplay']))
                p.triggers(trim,[aura_trigger(seeds)],cls,'fx')
                trim['triggers'][2]['trigger']['custom']=f'function() return ForeverHUD and ForeverHUD.Gate("fx","{cls}") and ForeverHUD.Gate("resources","{cls}") or false end'
                flag=f'FOREVERHUD_{cls}_fx_'+trim['uid'];trim['load']['loadFlag']=flag
                p.eligibility[trim['id']]=dict(cls=cls,module='fx',requires='resources',seeds=seeds,flag=flag,kind='aura')
        powerfx=texture(p,prefix+' | FX resource intensity',frame,cls,'fx','runes',154,154,y=13,color=rgba(c['accent']),level=1)
        powerfx['alpha']=0
        powerfx['load']['loadFlag']=f'FOREVERHUD_{cls}_fx_power'
        p.triggers(powerfx,[dict(type='unit',event='Power',unit='player',use_unit=True)],cls,'fx')
        powerfx['triggers'][2]['trigger']['custom']=f'function() return ForeverHUD and ForeverHUD.Gate("fx","{cls}") and ForeverHUD.InCombat() or false end'
        powerfx['conditions']=[dict(check=dict(trigger=1,variable='percentpower',op='>=',value=threshold),
            changes=[dict(property='alpha',value=alpha)]) for threshold,alpha in ((65,.1),(80,.3),(95,.48))]
        # 0.8 retracted tray, shown only while folded (module "tray", gate
        # Retracted). Kept minimal (0.9.1: no health/resource percentages):
        # the class counter under the seal, then a centred Modern Aura Group
        # with missing upkeep and food, drink and Well Fed (matched by name).
        tray=prefix+' | Tray'; p.group(tray,prefix,cls,'tray')
        # 0.9.2: one centred horizontal row under the seal, every icon in the
        # same style. The counter is an ordinary display, which ForeverAuras
        # chains into a screen-mode Modern Aura Group like the aura icons.
        row=tray+' | Row'; p.group(row,tray,cls,'tray',y=TRAY_ROW1_Y).update(CENTRED_FLOW,blizzardFlowSpacing=TRAY_SPACING)
        if c.get('extra')=='shards':
            # The carried reagent count on its own item icon (native Item Count).
            shards=icon(p,row+' | Soul Shards',row,cls,'tray',dict(type='item',event='Item Count',itemName=6265,
                use_itemName=True,use_exact_itemName=True,use_includeBank=False,use_includeWarBandBank=False,use_includeCharges=False),
                TRAY_ICON)
            # One count, in the corner like the other tray icons' stacks.
            for sub in shards['subRegions']:
                if sub.get('type')=='subtext' and sub.get('text_text')=='%p': sub['text_visible']=False
            # Same look as the Modern aura icons beside it: ForeverAuras draws
            # those as native aura buttons, art inset inside a dark ring that
            # cannot be restyled, so this ordinary icon copies the ring (under
            # the frame, above the art).
            shards['subRegions'].insert(1,dict(type='subborder',border_visible=True,border_color=TRAY_RING_COLOR,
                border_edge='Square Full White',border_size=TRAY_RING,border_offset=0))
            # 0.9.5: the native buttons carry our frame tight around the art
            # (measured in game: ~43 px against ~56 px for the 8 px outset),
            # so this ordinary icon uses the same tight frame.
            for sub in shards['subRegions']:
                if sub.get('type')=='subtexture': sub.update(xOffset=TRAY_FRAME_OUTSET,yOffset=TRAY_FRAME_OUTSET)
        upkeeps=[(seeds,name) for seeds,name,missing in UPKEEP.get(cls,[]) if missing]
        if cls=='WARLOCK': upkeeps.append(([687,706,28176],'Demon armor'))
        for seeds,name in upkeeps:
            trigger=aura_trigger(seeds);trigger.update(nativeFilters={},secretShowOn='showOnMissing')
            icon(p,f'{row} | Upkeep reminder | {name} missing',row,cls,'tray',trigger,TRAY_ICON,modern=True)
        for name in ('Food','Drink','Well Fed'):
            # Aura names expand natively to every spell ID with that name
            # (ForeverAuras BlizzardAuraDisplay GetSpellIDs), so no ID list.
            d=icon(p,f'{row} | {name}',row,cls,'tray',aura_trigger([name]),TRAY_ICON,modern=True)
        # Name-matched tray icons follow the tray module only: a name is not a
        # learned spell for discovery. Upkeep reminders keep their learned-
        # spell eligibility, so an unlearned buff never nags.
        for d in p.displays:
            entry=p.eligibility.get(d['id'])
            if d['id'].startswith(tray+' | ') and entry and any(isinstance(seed,str) for seed in entry['seeds']):
                p.eligibility.pop(d['id'])
                d['load']['loadFlag']=f'FOREVERHUD_{cls}_tray'
        # 0.9 spell suggestions: a fixed row over Health. Each rule is a
        # native check (power/health curve, Show On Missing, aura active);
        # nothing is inferred in Lua. Protected percentages cannot be
        # combined natively, so each rule tests a single value.
        specs=SUGGESTIONS.get(cls,{})
        if specs:
            # 0.11: actions chain in the rotation row; threshold cues sit by their bar.
            suggest=prefix+' | Suggest'; p.group(suggest,prefix,cls,'suggest',x=SUGGEST_ROW_X,y=SUGGEST_Y).update(SUGGEST_FLOW)
            cues=prefix+' | Suggest cues'
            # No empty groups: only classes with a threshold cue get one.
            if any(r['kind']=='curve' for rules in specs.values() for r in rules): p.group(cues,prefix,cls,'suggest')
            in_target=f'function() return ForeverHUD and ForeverHUD.Gate("suggest","{cls}") and ForeverHUD.SuggestTarget() or false end'
            for spec,rules in specs.items():
                actions=[r for r in rules if r['kind']!='curve']
                spots=[{'player':MANA_CUE,'pet':PET_CUE,'target':EXECUTE_CUE}[r['unit']] for r in rules if r['kind']=='curve']
                assert len(set(spots))==len(spots),(cls,spec,'one cue per spot')
                # The execute slot is the row's fifth place, so it leaves four for actions.
                assert len(actions)<=SUGGEST_MAX-(EXECUTE_CUE in spots),(cls,spec)
                # Leveling keeps the 0.9 display IDs; each spec has its own.
                base=suggest if spec=='Leveling' else f'{suggest} | {spec}'
                for rule in rules:
                    name=f"{base} | {rule['name']}"
                    if rule['kind']=='curve':
                        t=dict(type='unit',event=rule['event'],unit=rule['unit'],use_unit=True)
                        if rule.get('powertype') is not None: t.update(use_powertype=True,powertype=rule['powertype'])
                        (cx,cy)={'player':MANA_CUE,'pet':PET_CUE,'target':EXECUTE_CUE}[rule['unit']]
                        size=SUGGEST_SIZE if rule['unit']=='target' else CUE_SIZE
                        d=icon(p,name,cues,cls,'suggest',t,size,x=cx,y=cy,known=rule['known'])
                        d.update(iconSource=0,displayIcon='Interface\\Icons\\'+rule['icon'],alpha=0)
                        d['subRegions'][2]['text_visible']=False;d['subRegions'][3]['text_visible']=False
                        # Hidden unless the native curve says the value is at or under the threshold.
                        d['conditions']=[dict(check=dict(trigger=1,variable=rule['variable'],op='<=',value=rule['at']),
                            changes=[dict(property='alpha',value=1)])]
                        if rule['unit']=='target': d['triggers'][2]['trigger']['custom']=in_target
                    elif rule['kind'] in ('missing','buff'):
                        target=rule['kind']=='missing'
                        # Own buffs (Slice and Dice, Shadowform...) only come from
                        # the player, so the default cast-by-you filter stays.
                        t=aura_trigger([rule['seed']],'target' if target else 'player',target);t['secretShowOn']='showOnMissing'
                        d=icon(p,name,suggest,cls,'suggest',t,SUGGEST_SIZE,modern=True)
                        d['triggers'][2]['trigger']['custom']=in_target
                    elif rule['kind']=='ready':
                        d=icon(p,name,suggest,cls,'suggest',dict(type='spell',event='Action Usable',spellName=rule['seed'],
                            use_spellName=True,use_exact_spellName=False,use_ignoreSpellCooldown=False,use_targetRequired=True),
                            SUGGEST_SIZE,known=rule['seed'])
                        d['subRegions'][2]['text_visible']=False;d['subRegions'][3]['text_visible']=False
                        d['triggers'][2]['trigger']['custom']=in_target
                    else:
                        d=icon(p,name,suggest,cls,'suggest',aura_trigger([rule['seed']]),SUGGEST_SIZE,modern=True)
                        if rule.get('talent'): p.eligibility[d['id']].update(seeds=rule['talent'])
                    # The companion loads only the list for the current spec.
                    p.eligibility[d['id']].update(spec=spec)
        alerts=prefix+' | Alerts'; p.group(alerts,prefix,cls,'base')
        for seed,priority in ALERTS[cls]:
            alert=p.add(prefix+f' | Ready alert | {seed}','empty',alerts,cls,'alerts',width=1,height=1)
            p.triggers(alert,[dict(type='spell',event='Cooldown Ready (Spell)',spellName=seed,
                use_spellName=True,use_exact_spellName=False,use_ignoreSpellKnown=False,use_ignoreoverride=False)],cls,'alerts')
            alert['triggers'][2]['trigger']['custom']=f'function() return ForeverHUD and ForeverHUD.AlertGate("{cls}") or false end'
            flag=f'FOREVERHUD_{cls}_alerts_'+alert['uid'];alert['load']['loadFlag']=flag
            p.eligibility[alert['id']]=dict(cls=cls,module='alerts',seeds=[seed],flag=flag,kind='ability')
            alert['actions']['start']=dict(do_custom=True,custom=f'if ForeverHUD then ForeverHUD.ReadyAlert("{alert["id"]}", {seed}, {priority}) end')
        # A second bar is optional; Blizzard's original cast bar is untouched.
        if c.get('pet'):
            bar(p,prefix+" | Pet health",resources,cls,"pet",dict(type="unit",event="Health",unit="pet",use_unit=True),
                x=-138,y=-13,width=180,height=7,color=rgba(PET_HEALTH_COLOR),text="%p",label='Pet')
        if c.get('extra')=="shards":
            d=p.add(prefix+" | Soul Shards","text",resources,cls,"pet",x=138,y=-13,displayText="%c: %s  |TInterface\\Icons\\INV_Misc_Gem_Amethyst_02:12|t",
                font="Friz Quadrata TT",fontSize=11,outline="OUTLINE",color=rgba(c['accent']),justify="CENTER",
                automaticWidth="Auto",fixedWidth=180,wordWrap="WordWrap",customTextUpdate='event',
                customText='function() return ForeverHUD and ForeverHUD.L("Soul Shards") or "Soul Shards" end')
            # Count the carried reagent, not a guessed modern Soul Shard power.
            p.triggers(d,[dict(type="item",event="Item Count",itemName=6265,use_itemName=True,use_exact_itemName=True,
                use_includeBank=False,use_includeWarBandBank=False,use_includeCharges=False)],cls,"pet")
        elif c.get('extra')=="combo":
            combo=bar(p,prefix+" | Combo points",resources,cls,"pet",dict(type="unit",event="Power",unit="player",use_unit=True,
                use_powertype=True,powertype=4),width=100,height=5,y=-155,color=rgba(RESOURCE_STYLES[4]['color']),text='%p / %t')
            if cls=='DRUID':
                combo['triggers'][2]['trigger']['custom']='function() return ForeverHUD and ForeverHUD.Gate("pet","DRUID") and ForeverHUD.ComboAllowed() or false end'
        elif c.get('extra')=="swing":
            for i,hand in enumerate([0,2] if cls=="HUNTER" else [0,1]):
                swing=bar(p,prefix+f" | Swing {hand}",resources,cls,"pet",dict(type="unit",event="Swing Timer",swingType=hand,use_swingType=True),
                    width=100,height=4,x=-55+i*110,y=-153,color=rgba(c['accent']),text="%p")
                if hand==1: swing['load']['loadFlag']='FOREVERHUD_WARRIOR_pet_offhand'
        elif c.get('extra')=="totems":
            for slot in range(1,5):
                icon(p,prefix+f" | Totem {slot}",resources,cls,"pet",dict(type="spell",event="Totem",unit="player",
                    use_totemType=True,totemType=slot,use_inverse=False,use_clones=False),24,x=180+(slot-2.5)*32,y=-157)
        if cls in ('SHAMAN','ROGUE'):
            for i,hand in enumerate(('main','off') if cls=='ROGUE' else ('main',)):
                icon(p,prefix+' | Weapon coating | '+hand,auras,cls,'buffs',dict(type='item',event='Weapon Enchant',
                    weapon=hand,enchantKind='imbue' if cls=='SHAMAN' else 'temporary',showOn='showOnActive',use_enchant=False),DOT_SIZE,
                    # Not a Modern aura, so not in the centred row: fixed slots
                    # on the rim just past the resource bar's outer end.
                    x=BAR_X+90+16+i*DOT_STEP,y=DOT_ROW_Y)
        # FA computes frame levels from controlledChildren, not a display's
        # frameLevel field. Put ordered FX behind foreground bars/icons/seal.
        frame_group=p.by_id[frame]
        children=frame_group['controlledChildren']
        layers=[id for id in children if ' | FX' in id]
        layers.sort(key=lambda id:p.by_id[id]['information'].get('fxPriority',0))
        foreground=[id for id in children if id not in layers]
        seal=foreground.index(prefix+' | Seal')
        frame_group['controlledChildren']=foreground[:seal]+layers+foreground[seal:]
        # Organising sections only: no loose leaves at the class root.
        loose=[id for id in group['controlledChildren'] if 'controlledChildren' not in p.by_id[id]]
        assert not loose,f'Loose displays at {prefix}: {loose}'
    # A newer import must fail closed while an older helper is still loaded.
    # Checking the table alone allowed hundreds of missing-method errors.
    for display in p.displays:
        containers=[display]+[action for action in display['actions'].values()]
        containers += [entry['trigger'] for key,entry in display['triggers'].items() if isinstance(key,int)]
        for container in containers:
            for key in ('custom','customText','customSort'):
                code=container.get(key)
                if isinstance(code,str) and 'ForeverHUD' in code:
                    guard=f'ForeverHUD and ForeverHUD.importAPI == {IMPORT_API}'
                    container[key]=code.replace('if ForeverHUD then',f'if {guard} then').replace('return ForeverHUD and ',f'return {guard} and ')
    # Every class display carries its class's update tag, so FA links the
    # installed group to the build the companion offers.
    for display in p.displays[1:]:
        display['url']=update_url(owner_of(display))
    message='Companion update required: install ForeverHUD and /reload before importing.'
    for display in p.displays:
        if 'controlledChildren' in display:
            custom=[key for key,action in display['actions'].items() if action.get('do_custom')]
            assert not custom,f'Group {display["id"]} has custom {custom} actions ForeverAuras never compiles'
    for display in p.displays[1:]:
        if display['id'].endswith(' | Class name'):
            display['actions']['init']['custom']=(f'if ForeverHUD and ForeverHUD.importAPI == {IMPORT_API} then ForeverHUD.Bind() '
                f'else local message="{message}"; print("ForeverHUD {VERSION}: "..(ForeverHUD and ForeverHUD.L and ForeverHUD.L(message) or message)) end')
    return dict(m="d",v=2000,s="1.3.5",d=p.displays[0],c=p.displays[1:]),p.eligibility

def class_import(data, owner):
    """A native update is scoped to the Core or one class UID, never the
    combined root, so it cannot remove other installed groups."""
    selected=[copy.deepcopy(d) for d in data['c'] if owner_of(d)==owner]
    root=next(d for d in selected if d['id']==root_id(owner))
    root.pop('parent',None)
    # A standalone root follows the companion anchor like the combined root.
    root.update(anchorFrameType='SELECTFRAME',anchorFrameFrame='ForeverHUDAnchor',anchorFrameParent=True)
    root['desc']=('ForeverHUD '+VERSION+' Core, shared by every class. Install it with your class group; controls: /fhud.'
        if owner==CORE else
        'ForeverHUD '+VERSION+' / '+CLASSES[owner]['name']+' only. Needs the ForeverHUD Core group; controls: /fhud.')
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
    for owner in [CORE]+list(CLASSES):
        value=class_import(data,owner)
        name='Core' if owner==CORE else CLASSES[owner]['name']
        target=dist/'classes'/('ForeverHUD-'+name+'.txt')
        write_import(value,dist/'.build/classes'/target.with_suffix('.lua').name,target)
        raw=target.read_bytes()
        records.append(dict(classToken=owner,name=name,file=target.name,characters=len(raw.rstrip(b'\n')),
            bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),displays=len(value['c'])+1,rootID=value['d']['id'],rootUID=value['d']['uid'],
            updateSlug=update_slug(owner),updateBuild=BUILD))
    (dist/'classes/manifest.json').write_text(json.dumps(dict(version=VERSION,imports=records),indent=2)+'\n',**LF)
    rows=['# Core and class imports','','## English','',
        'You normally do not need these files. Install the ForeverHUD addon, `/reload`, and open `/fa`: the Core and your class are listed under **ready to be installed** or **updates**, or type `/fhud install`. ForeverAuras shows its import window and you confirm.',
        'Every class needs `ForeverHUD-Core.txt` (health, resource, cast bar and the native cooldown and aura rows) plus its own class file (spells, effects and art).',
        'For manual import, paste the Core file, then one class file, into `/fa` → Import; choose **Update** for an existing group, not Import as Copy.',
        'Each file targets only its own group, preserving an existing combined parent and the other classes.',
        'Use the combined import for a fresh nine-class installation or to update an existing combined group.',
        '', '| Group | Import | Characters | Displays |','| --- | --- | ---: | ---: |']
    rows += [f"| {r['name']} | [{r['file']}]({r['file']}) | {r['characters']:,} | {r['displays']} |" for r in records]
    rows += ['', '## 简体中文', '',
        '通常无需使用这些文件。安装 ForeverHUD 插件后输入 `/reload` 并打开 `/fa`：核心和当前职业会出现在“待安装”或“更新”列表中，也可输入 `/fhud install`。ForeverAuras 会显示导入窗口，由你确认。',
        '每个职业都需要 `ForeverHUD-Core.txt`（生命、资源、施法条以及原生冷却和光环行）加上自己的职业文件（技能、特效和美术）。',
        '如需手动导入，先把核心文件、再把职业文件粘贴到 `/fa` → 导入；已有分组请选择“更新”，不要导入为副本。',
        '每份文件仅更新自身分组，保留原有合并父组和其他职业。',
        '合并文件用于首次安装九职业或更新已有合并组。',
        '', '| 分组 | 导入文件 | 字符数 | 显示数量 |', '| --- | --- | ---: | ---: |']
    rows += [f"| {'核心' if r['classToken']==CORE else CLASSES[r['classToken']]['zh']} | [{r['file']}]({r['file']}) | {r['characters']:,} | {r['displays']} |" for r in records]
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
    for path in sorted((ROOT/'src/ForeverHUD').rglob('*')):
        if path.is_file() and path.suffix in ('.toc','.lua','.tga','.wav'):
            entries.append((path.relative_to(ROOT/'src').as_posix(),path.read_bytes()))
    entries.append(('ForeverHUD-All-Classes.txt',(dist/'ForeverHUD-All-Classes.txt').read_bytes()))
    for path in sorted((dist/'classes').iterdir()):
        if path.suffix in ('.txt','.json','.md'): entries.append(('imports/'+path.name,path.read_bytes()))
    entries.append(('README.md',packaged_readme().encode('utf-8')))
    for name in ('LICENSE','CHANGELOG.md'):
        if (ROOT/name).exists(): entries.append((name,(ROOT/name).read_bytes()))
    for path in sorted((ROOT/'docs').glob('*.md'))+[ROOT/'preview/foreverhud-warlock.png']:
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
        build(ROOT/'src/ForeverHUD/Media',CLASSES)
    from audio import build as build_audio
    build_audio(ROOT/'src/ForeverHUD/Audio')
    data,eligibility=generate()
    (dist/'ForeverHUD-All-Classes.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',**LF)
    write_import(data,dist/'ForeverHUD-All-Classes.lua',dist/'ForeverHUD-All-Classes.txt')
    records=write_class_imports(data,dist)
    # The encoded class imports ship inside the addon (no separate file, so the
    # TOC file list is unchanged), for ForeverAuras' companion install/update.
    bundled={r['classToken']:dict(slug=r['updateSlug'],build=BUILD,version=VERSION,rootID=r['rootID'],
        encoded=(dist/'classes'/r['file']).read_text(**UTF8).strip()) for r in records}
    resource_names={power:style['name'] for power,style in RESOURCE_STYLES.items()}
    class_colors={cls:dict(color=rgba(c['color']),accent=rgba(c['accent'])) for cls,c in CLASSES.items()}
    catalog=('-- Generated by scripts/build.py. Edit src/catalog.py or the generator.\nlocal _, E = ...\n'
        f'E.catalog = {lua(eligibility)}\nE.plans = {lua(PLANS)}\nE.schools = {lua(SCHOOLS)}\n'
        f'E.effectSpells = {lua(EFFECTS)}\nE.resourceNames = {lua(resource_names)}\n'
        f'E.classColors = {lua(class_colors)}\n'
        f'E.bundledImports = {lua(bundled)}\n')
    (ROOT/'src/ForeverHUD/Catalog.lua').write_text(catalog,**LF)
    target=dist/f'ForeverHUD-v{VERSION}.zip'
    write_package(target,dist)
    (dist/(target.name+'.sha256')).write_text(hashlib.sha256(target.read_bytes()).hexdigest()+'  '+target.name+'\n',**LF)
    print(f'Built {len(data["c"])+1} displays; {target.name} ({target.stat().st_size:,} bytes)')
if __name__=='__main__': main()
