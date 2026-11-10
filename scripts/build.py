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
from catalog import CLASSES, candidates, RANKS, PLANS, SCHOOLS, PREPARATION, EFFECTS, ALERTS, UPKEEP

VERSION = "0.3.0"
TITLE = "Eclipse | Class Combat HUD"
MEDIA = "Interface\\AddOns\\EclipseHUD\\Media\\"
EVENTS = "PLAYER_ENTERING_WORLD PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED PLAYER_TARGET_CHANGED UPDATE_SHAPESHIFT_FORM ECLIPSE_HUD_UPDATE FA_OPTIONS_CLOSED"

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
    if not modern and trigger['event'] in ('Cooldown Progress (Spell)','Blizzard Cooldown Manager'):
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
        d["subRegions"][-1]["text_text_format_p_decimal_precision"]=0
        if trigger['event']=='Health' and trigger.get('unit')=='player':
            d['subRegions'][-1].update(text_text='%percenthealth%%  %p',
                text_text_format_percenthealth_format='Number',text_text_format_percenthealth_decimal_precision=0)
        d["subRegions"][-1]["text_text_format_p_big_number_format"]="AbbreviateNumbers"
        if trigger.get('unit')=='player' and module=='resources':
            side='left' if trigger['event']=='Health' else 'right'
            d['actions']['init']=dict(do_custom=True,custom=f'if EclipseHUD then EclipseHUD.StyleResource(aura_env.region or (ForeverAuras or WeakAuras).GetRegion(aura_env.id), "{cls}", "{side}") end')
    if name_text: d["subRegions"].append(subtext(name_text,"INNER_LEFT",9,x=4))
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
        chassis=texture(p,prefix+" | Chassis",prefix,cls,"art","chassis-"+cls.lower(),512,128,y=20)
        chassis['triggers'][2]['trigger']['custom']=f'function() return EclipseHUD and EclipseHUD.Gate("art","{cls}") and EclipseHUD.LayoutVisible() or false end'
        rune=texture(p,prefix+" | Living runes",prefix,cls,"motion","runes",112,112,y=13,color=rgba(c['color'],.18))
        rune["animation"]["main"]=dict(type="custom",duration_type="seconds",duration=45,use_rotate=True,rotate=360,
            rotateType="straight",easeType="none",easeStrength=3)
        texture(p,prefix+" | Seal",prefix,cls,"art","crest-"+cls.lower(),104,104,y=13)
        caption=p.add(prefix+" | Class name","text",prefix,cls,"base",y=79,displayText="%c",
            customText='function() return EclipseHUD and EclipseHUD.L("'+c['name']+'") or "'+c['name']+'" end',customTextUpdate="event",
            font="Friz Quadrata TT",fontSize=10,outline="OUTLINE",color=rgba(c['color']),justify="CENTER",
            automaticWidth="Auto",fixedWidth=200,wordWrap="WordWrap",shadowColor=[0,0,0,1],shadowXOffset=0,shadowYOffset=0)
        # Measured channel interiors in the packaged AI-painted frame.
        bar(p,prefix+" | Health",prefix,cls,"resources",dict(type="unit",event="Health",unit="player",use_unit=True),
            x=-138,y=13,width=180,height=13,color=[.43,.67,.36,1])
        # No explicit powertype: Druid forms, Warrior rage and Rogue energy
        # follow the client's current resource automatically.
        bar(p,prefix+" | Resource",prefix,cls,"resources",dict(type="unit",event="Power",unit="player",use_unit=True),
            x=138,y=13,width=180,height=13)
        primary=prefix+" | Primary"; p.group(primary,prefix,cls,"primary",y=52)
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
        overflow=prefix+" | Native cooldowns"
        extra=p.group(overflow,prefix,cls,"utility",y=-214,dynamic=True)
        extra.update(grow='GRID',gridType='HD',gridWidth=12,rowSpace=8,columnSpace=8)
        icon(p,overflow+" | Entries",overflow,cls,"utility",dict(type="cdm",event="Blizzard Cooldown Manager",
            cdmSource="cooldown",cdmSpells=dict(multi={}),cdmShow="cooldown",use_cdmShowGCD=False,
            cdmTrack="auto",cdmHideGCDText=True,use_ignoreSpellKnown=False),28)
        # Modern aura slots stay fixed in combat. No Lua presence inspection,
        # inferred timers, refresh windows, or combat-dependent group reflow.
        dots=prefix+" | Target effects"; p.group(dots,prefix,cls,"dots",y=-130)
        count=len(c['dots'])
        for i,(seed,name) in enumerate(c['dots']):
            icon(p,dots+" | "+name,dots,cls,"dots",aura_trigger([seed],"target",True),32,x=(i-(count-1)/2)*40,modern=True)
            # Native nameplate displays are opt-in and tied to live plates.
            d=icon(p,prefix+" | Nameplates | "+name,prefix,cls,"nameplates",aura_trigger([seed],"nameplate",True),22,
                x=(i-(count-1)/2)*26,y=26,modern=True)
            d.update(anchorFrameType="NAMEPLATE",anchorFrameParent=False)
        effects=prefix+" | Player effects";p.group(effects,prefix,cls,"buffs",y=116)
        native_effects=prefix+' | Native player effects'
        p.group(native_effects,prefix,cls,'buffs',y=151,dynamic=True)
        icon(p,native_effects+' | Entries',native_effects,cls,'buffs',dict(type='cdm',event='Blizzard CDM Buff',
            cdmSource='buff',cdmSpells=dict(multi={}),cdmBuffShow='active',cdmTrack='auto',
            use_cdmShowGCD=False,cdmHideGCDText=True,use_ignoreSpellKnown=False),26)
        buffs=list(c['buffs'])
        if cls=="WARLOCK": buffs.append(([687,706,28176],"Demon armor"))
        for i,(seed,name) in enumerate(buffs):
            icon(p,effects+" | "+name,effects,cls,"buffs",aura_trigger(seed if isinstance(seed,list) else [seed]),26,
                x=(i-(len(buffs)-1)/2)*34,modern=True)
        for i,(seeds,name,missing) in enumerate(UPKEEP.get(cls,[])):
            upkeep=aura_trigger(seeds);upkeep['nativeFilters']={}
            icon(p,prefix+' | Upkeep | '+name,prefix,cls,'buffs',upkeep,24,x=180+i*30,y=94,modern=True)
            if missing:
                for expiring in (False,True):
                    reminder=upkeep.copy()
                    reminder.update(secretShowOn='showOnActive' if expiring else 'showOnMissing',
                        secretUseRem=expiring,secretRem=15,secretRemOperator='<=')
                    icon(p,prefix+' | Upkeep reminder | '+name+(' expiring' if expiring else ' missing'),prefix,cls,'buffs',
                        reminder,28,y=94,modern=True)
        if cls=='WARRIOR':
            for name,seed,unit,missing,remaining,x in (
                ('Rend missing',772,'target',True,False,-44),
                ('Battle Shout missing',6673,'player',True,False,0),
                ('Battle Shout expiring',6673,'player',False,True,0)):
                trigger=aura_trigger([seed],unit,unit=='target')
                if unit=='player': trigger['nativeFilters']={}
                trigger.update(secretShowOn='showOnMissing' if missing else 'showOnActive',
                    secretUseRem=remaining,secretRem=15,secretRemOperator='<=')
                reminder=icon(p,prefix+' | '+name,prefix,cls,'dots' if unit=='target' else 'buffs',trigger,28,x=x,y=94,modern=True)
                if unit=='target':
                    reminder['triggers'][2]['trigger']['custom']='function() return EclipseHUD and EclipseHUD.Gate("dots","WARRIOR") and EclipseHUD.ReminderContext() or false end'
            for i,(seed,name) in enumerate(((7384,'Overpower'),(6572,'Revenge'),(5308,'Execute'),(402927,'Victory Rush'))):
                proc=icon(p,prefix+' | Usable proc | '+name,prefix,cls,'primary',dict(type='spell',event='Action Usable',
                    spellName=seed,use_spellName=True,use_exact_spellName=False,use_ignoreSpellCooldown=False,use_targetRequired=True),28,x=(i-1.5)*36,y=-23,known=seed)
                p.eligibility[proc['id']].update(proc=name)
        # FA's native Aura Start/Main settings bind playback to aura assignment
        # and lifetime. No helper hooks or alpha readback on native buttons.
        for tier,seeds in EFFECTS[cls].items():
            priority={'low':2,'blood':3,'eyes':4,'medium':5,'major':6,'defense':7}[tier]
            effect=texture(p,prefix+' | FX | '+tier,prefix,cls,'fx',
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
                trim=texture(p,prefix+' | FX trim | '+tier,prefix,cls,'fx','divider',470,32,y=13,color=rgba(c['accent'],.5),level=priority)
                trim.update(inverse=True,blizzardAuraDisplay=effect['blizzardAuraDisplay'].copy())
                p.triggers(trim,[aura_trigger(seeds)],cls,'fx')
                trim['triggers'][2]['trigger']['custom']=f'function() return EclipseHUD and EclipseHUD.Gate("fx","{cls}") and EclipseHUD.LayoutVisible() or false end'
                flag=f'ECLIPSE_{cls}_fx_'+trim['uid'];trim['load']['loadFlag']=flag
                p.eligibility[trim['id']]=dict(cls=cls,module='fx',seeds=seeds,flag=flag,kind='aura')
        powerfx=texture(p,prefix+' | FX resource intensity',prefix,cls,'fx','runes',154,154,y=13,color=rgba(c['accent']),level=1)
        powerfx['alpha']=0
        powerfx['load']['loadFlag']=f'ECLIPSE_{cls}_fx_power'
        p.triggers(powerfx,[dict(type='unit',event='Power',unit='player',use_unit=True)],cls,'fx')
        powerfx['triggers'][2]['trigger']['custom']=f'function() return EclipseHUD and EclipseHUD.Gate("fx","{cls}") and EclipseHUD.InCombat() or false end'
        powerfx['conditions']=[dict(check=dict(trigger=1,variable='percentpower',op='>=',value=threshold),
            changes=[dict(property='alpha',value=alpha)]) for threshold,alpha in ((65,.1),(80,.3),(95,.48))]
        for seed,priority in ALERTS[cls]:
            alert=p.add(prefix+f' | Ready alert | {seed}','empty',prefix,cls,'alerts',width=1,height=1)
            p.triggers(alert,[dict(type='spell',event='Cooldown Ready (Spell)',spellName=seed,
                use_spellName=True,use_exact_spellName=False,use_ignoreSpellKnown=False,use_ignoreoverride=False)],cls,'alerts')
            flag=f'ECLIPSE_{cls}_alerts_'+alert['uid'];alert['load']['loadFlag']=flag
            p.eligibility[alert['id']]=dict(cls=cls,module='alerts',seeds=[seed],flag=flag,kind='ability')
            alert['actions']['start']=dict(do_custom=True,custom=f'if EclipseHUD then EclipseHUD.ReadyAlert("{alert["id"]}", {seed}, {priority}) end')
        bar(p,prefix+" | Cast",prefix,cls,"cast",dict(type="unit",event="Cast",unit="player",use_unit=True,spellNames=[]),
            width=300,height=13,y=-178,color=rgba(c['accent']),text="%p",name_text="%n")
        # A second bar is optional; Blizzard's original cast bar is untouched.
        if c.get('pet'):
            bar(p,prefix+" | Pet health",prefix,cls,"pet",dict(type="unit",event="Health",unit="pet",use_unit=True),
                x=-138,y=-13,width=180,height=7,color=rgba(c['accent']),text="%p")
        if c.get('extra')=="shards":
            d=p.add(prefix+" | Soul Shards","text",prefix,cls,"pet",x=138,y=-13,displayText="%s  |TInterface\\Icons\\INV_Misc_Gem_Amethyst_02:12|t",
                font="Friz Quadrata TT",fontSize=11,outline="OUTLINE",color=rgba(c['accent']),justify="CENTER",
                automaticWidth="Auto",fixedWidth=120,wordWrap="WordWrap")
            # Count the carried reagent, not a guessed modern Soul Shard power.
            p.triggers(d,[dict(type="item",event="Item Count",itemName=6265,use_itemName=True,use_exact_itemName=True,
                use_includeBank=False,use_includeWarBandBank=False,use_includeCharges=False)],cls,"pet")
        elif c.get('extra')=="combo":
            combo=bar(p,prefix+" | Combo points",prefix,cls,"pet",dict(type="unit",event="Power",unit="player",use_unit=True,
                use_powertype=True,powertype=4),width=100,height=5,y=-155,color=rgba(c['accent']))
            if cls=='DRUID':
                combo['triggers'][2]['trigger']['custom']='function() return EclipseHUD and EclipseHUD.Gate("pet","DRUID") and EclipseHUD.ComboAllowed() or false end'
        elif c.get('extra')=="swing":
            for i,hand in enumerate([0,2] if cls=="HUNTER" else [0,1]):
                swing=bar(p,prefix+f" | Swing {hand}",prefix,cls,"pet",dict(type="unit",event="Swing Timer",swingType=hand,use_swingType=True),
                    width=100,height=4,x=-55+i*110,y=-153,color=rgba(c['accent']),text="%p")
                if hand==1: swing['load']['loadFlag']='ECLIPSE_WARRIOR_pet_offhand'
        elif c.get('extra')=="totems":
            for slot in range(1,5):
                icon(p,prefix+f" | Totem {slot}",prefix,cls,"pet",dict(type="spell",event="Totem",unit="player",
                    use_totemType=True,totemType=slot,use_inverse=False,use_clones=False),24,x=180+(slot-2.5)*32,y=-130)
        if cls in ('SHAMAN','ROGUE'):
            for i,hand in enumerate(('main','off') if cls=='ROGUE' else ('main',)):
                icon(p,prefix+' | Weapon coating | '+hand,prefix,cls,'buffs',dict(type='item',event='Weapon Enchant',
                    weapon=hand,enchantKind='imbue' if cls=='SHAMAN' else 'temporary',showOn='showOnActive',use_enchant=False),24,
                    x=180+i*32,y=94)
        # FA computes frame levels from controlledChildren, not a display's
        # frameLevel field. Put ordered FX behind foreground bars/icons/seal.
        children=group['controlledChildren']
        layers=[id for id in children if ' | FX' in id]
        layers.sort(key=lambda id:p.by_id[id]['information'].get('eclipseFXPriority',0))
        foreground=[id for id in children if id not in layers]
        seal=foreground.index(prefix+' | Seal')
        group['controlledChildren']=foreground[:seal]+layers+foreground[seal:]
    generate.eligibility = p.eligibility
    return dict(m="d",v=2000,s="1.3.5",d=p.displays[0],c=p.displays[1:])

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
    data=generate()
    (ROOT/'src/EclipseHUD/Catalog.lua').write_text('-- Generated by scripts/build.py. Edit src/catalog.py or the generator.\nlocal _, E = ...\nE.catalog = '+lua(generate.eligibility)+'\nE.plans = '+lua(PLANS)+'\nE.schools = '+lua(SCHOOLS)+'\nE.effectSpells = '+lua(EFFECTS)+'\n')
    (dist/'Eclipse-Class-Combat-HUD.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    (dist/'Eclipse-Class-Combat-HUD.lua').write_text('return '+lua(data)+'\n')
    subprocess.run(['lua',str(ROOT/'scripts/codec.lua'),'encode',str(dist/'Eclipse-Class-Combat-HUD.lua'),str(dist/'Eclipse-Class-Combat-HUD.txt')],check=True)
    target=dist/f'Eclipse-Class-Combat-HUD-v{VERSION}.zip'
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for path in sorted((ROOT/'src/EclipseHUD').rglob('*')):
            if path.is_file() and path.suffix in ('.toc','.lua','.tga','.wav'):
                z.write(path,path.relative_to(ROOT/'src'))
        z.write(dist/'Eclipse-Class-Combat-HUD.txt','Eclipse-Class-Combat-HUD.txt')
        for name in ('README.md','LICENSE','CHANGELOG.md'):
            if (ROOT/name).exists(): z.write(ROOT/name,name)
        for name in [str(path.relative_to(ROOT)) for path in sorted((ROOT/'docs').glob('*.md'))]+['preview/eclipse-warlock.png']:
            if (ROOT/name).exists(): z.write(ROOT/name,name)
    (dist/(target.name+'.sha256')).write_text(hashlib.sha256(target.read_bytes()).hexdigest()+'  '+target.name+'\n')
    print(f'Built {len(data["c"])+1} displays; {target.name} ({target.stat().st_size:,} bytes)')
if __name__=='__main__': main()
