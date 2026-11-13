import json
import re
import struct
import unittest
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
sys.path.insert(0,str(ROOT/'src'))
from build import generate, class_import, TITLE, UTF8, PRIMARY_Y, VERSION, CORE, CORE_ID, ART_STRATA, owner_of, root_id
from catalog import CLASSES, HEALTH_COLOR, PET_HEALTH_COLOR, UNKNOWN_RESOURCE_COLOR, RESOURCE_STYLES
from build import rgba

def sections(c):
    """Class sections in draw order; Resources only for a pet or class extra."""
    return (['Frame']+(['Resources'] if c.get('pet') or c.get('extra') else [])+['Primary','Utility','Auras','Nameplates','Tray']
        +['Suggest']+(['Suggest cues'] if c['name'] in CUE_CLASSES else [])+['Alerts'])
# Classes whose suggestion lists include a threshold cue (mana, pet or execute).
CUE_CLASSES={'Warlock','Mage','Druid','Hunter','Shaman'}
CORE_SECTIONS=['Resources','Native rows','Native auras']

def subtree(by_id,root):
    """IDs reachable from root through controlledChildren, independent of load data."""
    found=[root]
    for child in by_id[root].get('controlledChildren',[]):found+=subtree(by_id,child)
    return found

class PackTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.pack,cls.eligibility=generate();cls.regions=[cls.pack['d']]+cls.pack['c']
    def test_class_switch_and_disabled_module_lifecycle(self):
        classes=set()
        for d in self.pack['c']:
            load=d['load']
            self.assertTrue(load['use_loadFlag'],d['id'])
            if d['id']==CORE_ID or d['id'].startswith(CORE_ID+' | '):
                # FA multi-select: loads for every supported class, gated at runtime.
                self.assertIs(load['use_class'],False,d['id'])
                self.assertEqual(load['class']['multi'],{cls:True for cls in CLASSES})
                self.assertTrue(load['loadFlag'].startswith('FOREVERHUD_CORE_'),d['id'])
                self.assertEqual(owner_of(d),CORE)
                continue
            self.assertTrue(load['use_class'],d['id'])
            classes.add(load['class']['single'])
            self.assertTrue(load['loadFlag'].startswith('FOREVERHUD_'+load['class']['single']+'_'))
        self.assertEqual(classes,set(CLASSES))
        self.assertEqual(self.pack['d']['controlledChildren'],[CORE_ID]+['ForeverHUD | '+c['name'] for c in CLASSES.values()])
    def test_class_import_scopes_preserve_ids_and_leave_other_classes_out(self):
        full={d['id']:d for d in self.pack['c']}
        seen=set()
        for cls in [CORE]+list(CLASSES):
            pack=class_import(self.pack,cls)
            rows=[pack['d']]+pack['c'];by_id={d['id']:d for d in rows}
            self.assertEqual(pack['d']['id'],root_id(cls))
            self.assertNotIn('parent',pack['d'])
            self.assertNotIn(TITLE,by_id,'Do not update a partial shared root')
            self.assertEqual(pack['d']['anchorFrameFrame'],'ForeverHUDAnchor','A standalone root follows the companion anchor')
            self.assertFalse(any(a.get('do_custom') for a in pack['d']['actions'].values()))
            if cls==CORE:
                for leaf in ('Health','Resource','Cast'):
                    init=by_id[CORE_ID+' | '+leaf]['actions']['init']['custom']
                    self.assertIn('importAPI == 2',init);self.assertIn('ForeverHUD.Bind()',init)
                self.assertFalse(any(d['regionType']=='texture' for d in rows),'Class art stays in class imports')
            else:
                guard=by_id[root_id(cls)+' | Class name']['actions']['init']['custom']
                self.assertIn('importAPI',guard);self.assertIn('ForeverHUD.Bind()',guard)
            # Independent of class_import's owner predicate: the file must be
            # exactly the root's reachable subtree.
            expected=set(subtree(full,root_id(cls)))
            self.assertEqual(set(by_id),expected)
            self.assertEqual(expected,{key for key,d in full.items() if owner_of(d)==cls})
            self.assertFalse(seen & expected,'Each class update must have a disjoint native UID scope')
            seen.update(expected)
            for d in rows:
                self.assertEqual(d['uid'],full[d['id']]['uid'])
                self.assertEqual(d['load'],full[d['id']]['load'])
                if d is not pack['d']:self.assertEqual(d,full[d['id']])
                if d.get('parent'):self.assertIn(d['parent'],by_id)
                for child in d.get('controlledChildren',[]):self.assertEqual(by_id[child]['parent'],d['id'])
        self.assertEqual(seen,set(full))
        self.assertTrue(all(d.get('parent') for d in self.pack['c']),'Class slicing must not mutate the combined pack')

    def test_readme_languages_configuration_and_screenshots(self):
        text=(ROOT/'README.md').read_text(**UTF8)
        english,chinese=text.split('## 简体中文',1)
        self.assertIn('## English',english)
        for section in (english,chinese):
            self.assertIn('Hide Blizzard',section)
            self.assertIn('Tracked Bars',section)
            self.assertIn('cdmsetup',section)
            self.assertIn('preview/casting/warlock-default.png',section)
            self.assertIn('preview/states/warlock-opening.png',section)
        images=re.findall(r'src="([^"]+)"',text)
        self.assertGreater(len(images),20)
        for name in images:self.assertTrue((ROOT/name).is_file(),name)

    def test_modern_auras_delegate_tracking_to_client(self):
        for d in self.regions:
            if d['triggers'][1]['trigger']['type']!='secretAura':continue
            t=d['triggers'][1]['trigger']
            self.assertEqual(t['auraTracking'],'native')
            self.assertIn(t['secretShowOn'],('showOnActive','showOnMissing'))
            self.assertEqual(t['nativeFilters'],{} if 'Battle Shout missing' in d['id'] or 'Battle Shout expiring' in d['id'] or ' | Upkeep' in d['id'] else {'PLAYER':True})
            self.assertTrue(t['auraRankSpellIDs'])
            self.assertEqual(d['blizzardAuraDisplay']['maxIcons'],1)
            self.assertEqual(d['triggers']['secretFallback'],'none')
            self.assertNotIn('secretFallback',d)
            self.assertTrue(all(a['type']=='none' for a in d['animation'].values()))
            self.assertFalse(d['actions']['start']);self.assertFalse(d['actions']['finish'])
            self.assertEqual(d['conditions'],[])
            if t['unit']=='nameplate':
                self.assertEqual(d['anchorFrameType'],'NAMEPLATE')
                self.assertIn('_nameplates_',d['load']['loadFlag'])
    def test_localization_and_forever_seeds(self):
        warlock=CLASSES['WARLOCK']
        self.assertIn((1293817,'Conflagrate'),warlock['primary'])
        self.assertIn((1316697,'Wrack'),warlock['dots'])
        self.assertIn((980,'Bane of Agony'),warlock['dots'])
        self.assertIn((402174,'Penance'),CLASSES['PRIEST']['primary'])
        for d in self.regions:
            if d['id'].endswith(' | Class name'):self.assertEqual(d['displayText'],'')
        for c in CLASSES.values():
            ids=[id for id,name in c['primary']+c['utility']]
            self.assertEqual(len(ids),len(set(ids)),c['name'])
    def test_own_assets_and_no_combat_reconstruction(self):
        for d in self.regions:
            self.assertNotIn('Guos',json.dumps(d,ensure_ascii=False))
            for key in ('texture','groupIcon'):
                value=d.get(key,'')
                if value.startswith('Interface\\AddOns\\ForeverHUD\\'):
                    self.assertTrue((ROOT/'src/ForeverHUD'/value.split('ForeverHUD\\',1)[1].replace('\\','/')).is_file(),value)
        code=(ROOT/'src/ForeverHUD/Core.lua').read_text(**UTF8)
        for forbidden in ('COMBAT_LOG_EVENT_UNFILTERED','UnitAura(', 'GetAuraDataByIndex','GetSpellCooldown','SetScript("OnUpdate"'):
            self.assertNotIn(forbidden,code)
    def test_wow_texture_format(self):
        files=list((ROOT/'src/ForeverHUD/Media').glob('*.tga'))
        self.assertEqual(len(files),24,'0.12 adds the drawn groove')
        for path in files:
            header=path.read_bytes()[:18]
            self.assertEqual(header[2],2,'Uncompressed true-color TGA')
            width,height=struct.unpack('<HH',header[12:16])
            self.assertEqual(header[16],32,'RGBA')
            self.assertEqual(width & (width-1),0,'Power-of-two width')
            self.assertEqual(height & (height-1),0,'Power-of-two height')
    def test_hierarchy_and_wire_metadata(self):
        self.assertEqual(self.pack['m'],'d');self.assertEqual(self.pack['v'],2000)
        by_id={d['id']:d for d in self.regions}
        self.assertEqual(len(by_id),len(self.regions))
        self.assertEqual(len({d['uid'] for d in self.regions}),len(self.regions))
        self.assertEqual(by_id[TITLE]['anchorFrameFrame'],'ForeverHUDAnchor')
        listed=[]
        for d in self.regions:
            for child in d.get('controlledChildren',[]):
                self.assertEqual(by_id[child]['parent'],d['id'])
                listed.append(child)
        # Both directions, exactly once: nothing is detached or double-listed.
        self.assertEqual(sorted(listed),sorted(d['id'] for d in self.pack['c']))
        self.assertEqual(sorted(subtree(by_id,TITLE)),sorted(by_id))

    def test_update_tags_link_displays_to_bundled_build(self):
        build=sum(int(part)*scale for part,scale in zip(VERSION.split('.'),(10000,100,1)))
        self.assertNotIn('url',self.pack['d'],'The combined root is not a companion update target')
        for d in self.pack['c']:
            cls=owner_of(d)
            self.assertEqual(d['url'],f'https://wago.io/forever-hud-{cls.lower()}/{build}',d['id'])
            # FA's own parser: wago.io/<slug>/<number>
            self.assertRegex(d['url'],r'wago\.io/[^/]+/[0-9]+$')
        manifest=json.loads((ROOT/'dist/classes/manifest.json').read_text(**UTF8))
        for record in manifest['imports']:
            self.assertEqual(record['updateBuild'],build)
            self.assertEqual(record['updateSlug'],'forever-hud-'+record['classToken'].lower())

    def test_class_root_holds_only_sections(self):
        by_id={d['id']:d for d in self.regions}
        core=by_id[CORE_ID]['controlledChildren']
        self.assertEqual(core,[f'{CORE_ID} | {name}' for name in CORE_SECTIONS]+[CORE_ID+' | Cast'])
        for name in CORE_SECTIONS:
            section=by_id[f'{CORE_ID} | {name}']
            self.assertEqual((section['xOffset'],section['yOffset']),(0,0),'Sections must not move their displays')
            self.assertTrue(section['controlledChildren'],section['id'])
        for c in CLASSES.values():
            prefix='ForeverHUD | '+c['name']
            children=by_id[prefix]['controlledChildren']
            self.assertEqual(children,[f'{prefix} | {name}' for name in sections(c)])
            for name in ('Health','Resource','Cast','Native rows','Native cooldowns','Native tracked bars'):
                self.assertNotIn(f'{prefix} | {name}',by_id,'Shared displays live only in Core')
            for name in sections(c):
                section=by_id[f'{prefix} | {name}']
                self.assertIn(section['regionType'],('group','dynamicgroup'))
                self.assertTrue(section['controlledChildren'],section['id'])
            for name in ('Frame','Resources','Auras','Nameplates','Alerts'):
                if name not in sections(c): continue
                section=by_id[f'{prefix} | {name}']
                self.assertEqual((section['xOffset'],section['yOffset']),(0,0),'Sections must not move their displays')
            self.assertFalse(any(d['regionType'] in ('group','dynamicgroup') and not d['controlledChildren']
                for d in self.regions),'No empty placeholder groups')
            depth=lambda id:0 if id==prefix else 1+depth(by_id[id]['parent'])
            self.assertLessEqual(max(depth(id) for id in subtree(by_id,prefix)),3)
        procs=[d for d in self.regions if ' | Usable proc | ' in d['id']]
        self.assertEqual(len(procs),4)
        for d in procs:
            self.assertEqual(d['parent'],'ForeverHUD | Warrior | Primary')
            self.assertEqual(d['yOffset']+PRIMARY_Y,-23,'Screen position unchanged from the class root')

    def test_native_effect_animation_and_resource_curve(self):
        effects=[d for d in self.regions if ' | FX | ' in d['id']]
        self.assertGreater(len(effects),30)
        for d in effects:
            self.assertEqual(d['triggers'][1]['trigger']['type'],'secretAura')
            self.assertIn(d['blizzardAuraDisplay']['auraStart']['type'],('fade','zoom'))
            self.assertEqual(d['blizzardAuraDisplay']['auraMain']['type'],'pulse')
        for cls,c in CLASSES.items():
            by_tier={d['id'].rsplit(' | ',1)[1]:d for d in effects if d['load']['class']['single']==cls}
            prefix=f"ForeverHUD | {c['name']}"
            frame=next(d for d in self.regions if d['id']==prefix+' | Frame')
            order=frame['controlledChildren']
            self.assertGreater(order.index(by_tier['defense']['id']),order.index(by_tier['major']['id']))
            # FA assigns frame levels depth-first in list order: FX stays behind the seal.
            self.assertLess(order.index(by_tier['defense']['id']),order.index(prefix+' | Seal'))
            self.assertLess(order.index(prefix+' | Living runes'),order.index(by_tier['major']['id']))
            resource=next(d for d in self.regions if d['id']==f"ForeverHUD | {c['name']} | FX resource intensity")
            self.assertEqual(resource['triggers'][1]['trigger']['event'],'Power')
            self.assertTrue(all(x['check']['variable']=='percentpower' for x in resource['conditions']))

    def test_native_cooldown_slots_and_maintenance_are_separate(self):
        by_id={d['id']:d for d in self.regions}
        for c in CLASSES.values():
            prefix='ForeverHUD | '+c['name']
            for slot in range(1,9):
                self.assertNotIn(f'{prefix} | Primary | Native {slot}',by_id,'Empty v0.3.2 slot groups are removed')
                icon=by_id[f'{prefix} | Primary | Native {slot} | Entry']
                self.assertEqual(icon['triggers'][1]['trigger']['event'],'Blizzard Cooldown Manager')
                self.assertEqual(icon['triggers'][1]['trigger']['cdmShow'],'cooldown')
                self.assertFalse(icon['triggers'][1]['trigger']['use_cdmShowGCD'])
                self.assertEqual(icon['parent'],prefix+' | Primary | Native '+('left' if slot<=4 else 'right'))
                self.assertEqual(by_id[icon['parent']]['regionType'],'dynamicgroup')
            if prefix+' | Maintenance' in by_id:
                self.assertIn('_maintenance',by_id[prefix+' | Maintenance']['load']['loadFlag'])
                # Upkeep is not damage: right of the resource bar, growing outward.
                self.assertGreater(by_id[prefix+' | Maintenance']['xOffset'],250)
                self.assertEqual(by_id[prefix+' | Maintenance']['grow'],'RIGHT')
            # 0.7: the DoT and buff rails are ForeverAuras Modern Aura Groups.
            # 0.12: one spine; they grow outward from the seal, the first icon's
            # inner edge at x=±52 (a 28 px icon centred at ±66).
            for name,x,growth in (('Target effects',-66,'LEFT'),('Player effects',66,'RIGHT')):
                rail=by_id[f'{prefix} | {name}']
                self.assertEqual((rail['xOffset'],rail['yOffset']),(x,40),rail['id'])
                self.assertEqual((rail['regionType'],rail['blizzardFlow'],rail['blizzardFlowGrowth']),('group',True,growth))
                for child in rail['controlledChildren']:
                    d=by_id[child]
                    self.assertEqual((d['xOffset'],d['yOffset']),(0,0),'Members take their place from the chain')
                    self.assertEqual(d['triggers'][1]['trigger']['type'],'secretAura','Only Aura (Modern) displays join the centred row')
            dots=by_id[prefix+' | Target effects']
            primary=by_id[prefix+' | Primary']
            self.assertGreaterEqual(primary['yOffset']-20,dots['yOffset']+12,'Wing icons clear the DoT row')
        tracked=by_id[CORE_ID+' | Native tracked bars | Entries']
        self.assertEqual(tracked['regionType'],'aurabar')
        self.assertEqual(tracked['triggers'][1]['trigger']['event'],'Blizzard CDM Buff')
        self.assertEqual(tracked['load']['loadFlag'],'FOREVERHUD_CORE_trackedBars')
        self.assertLess(by_id[CORE_ID+' | Native tracked bars']['xOffset'],-250,'Duration bars sit on the damage side')
        # 0.7.1: the native buff row mirrors the DoT row on the right rim.
        native=by_id[CORE_ID+' | Native player effects']
        # 0.12: grows right from the seal; a dynamic group centres its first icon on the origin.
        self.assertEqual((native['xOffset'],native['yOffset'],native['grow'],native['align']),(66,40,'RIGHT','CENTER'))
        # 0.12: drawn grooves in the frame under the spine rows, hidden while folded.
        for c in CLASSES.values():
            frame=f"ForeverHUD | {c['name']} | Frame"
            kids=by_id[frame]['controlledChildren']
            chassis=kids.index(f"ForeverHUD | {c['name']} | Chassis")
            for name,x,y in (('Left rim',-142,40),('Right rim',142,40),('Suggestions',-142,74)):
                g=by_id[f"ForeverHUD | {c['name']} | Groove | {name}"]
                self.assertEqual((g['xOffset'],g['yOffset'],g['width']),(x,y,184),g['id'])
                self.assertTrue(g['texture'].endswith('groove.tga'))
                self.assertGreater(kids.index(g['id']),chassis,'Drawn over the chassis')
                self.assertIn('not ForeverHUD.Retracted()',g['triggers'][2]['trigger']['custom'])
        for side,growth in (('left','LEFT'),('right','RIGHT')):
            self.assertEqual(by_id[f'ForeverHUD | Warlock | Primary | Native {side}']['grow'],growth,'Wings grow out from the seal')
        self.assertEqual(by_id[CORE_ID+' | Native player effects | Entries']['width'],by_id['ForeverHUD | Warlock | Target effects | Immolate']['width'],'Same icon size as the DoT row')
        effects=[e for id,e in self.eligibility.items() if ' | Player effects | ' in id and not id.endswith('Demon armor')]
        self.assertTrue(effects and all(e.get('effect') for e in effects),'Curated class buffs give way to the native row in Forever mode')
        self.assertEqual(by_id[CORE_ID+' | Native items | Entries']['triggers'][1]['trigger']['event'],'Blizzard CDM Item')
        # 0.7.3: Demon armor warns natively when missing or in its last 15 s.
        for state,show,rem in (('missing','showOnMissing',False),('expiring','showOnActive',True)):
            reminder=by_id['ForeverHUD | Warlock | Upkeep reminder | Demon armor '+state]
            t=reminder['triggers'][1]['trigger']
            self.assertEqual(reminder['parent'],'ForeverHUD | Warlock | Maintenance')
            self.assertEqual((t['type'],t['secretShowOn'],t['secretUseRem']),('secretAura',show,rem))
            self.assertEqual(t['auraRankSpellIDs'],[687,706,28176])
            self.assertIn('_maintenance_',reminder['load']['loadFlag'])
        # 0.8.1: an upkeep buff covered by reminders has no "it's up" icon;
        # one without reminders keeps its active icon as the only cue.
        self.assertNotIn('ForeverHUD | Warlock | Player effects | Demon armor',by_id)
        for cls,name in (('Mage','Arcane Intellect'),('Priest','Fortitude'),('Druid','Mark of the Wild')):
            self.assertNotIn(f'ForeverHUD | {cls} | Upkeep | {name}',by_id)
            self.assertIn(f'ForeverHUD | {cls} | Upkeep reminder | {name} missing',by_id)
        for cls,name in (('Mage','Mage armor'),('Priest','Inner Fire'),('Hunter','Aspect'),('Paladin','Blessing')):
            self.assertIn(f'ForeverHUD | {cls} | Upkeep | {name}',by_id)

    def test_resource_colors_follow_native_type_across_classes(self):
        by_id={d['id']:d for d in self.regions}
        # One shared pair serves every class; the power type picks the colour.
        health=by_id[CORE_ID+' | Health']
        self.assertEqual(health['barColor'],rgba(HEALTH_COLOR))
        power=by_id[CORE_ID+' | Resource']
        self.assertEqual(power['barColor'],rgba(UNKNOWN_RESOURCE_COLOR))
        self.assertFalse(power['triggers'][1]['trigger'].get('use_powertype',False))
        mapping={rule['check']['value']:rule['changes'][0]['value'] for rule in power['conditions']}
        self.assertEqual(mapping,{kind:rgba(style['color']) for kind,style in RESOURCE_STYLES.items()})
        self.assertTrue(all(rule['check']['variable']=='powertype' for rule in power['conditions']))
        self.assertIn('ForeverHUD.ResourceLabel()',power['customText'])
        self.assertIn('ForeverHUD.StyleResource(',power['actions']['init']['custom'])
        self.assertIn('"CORE"',power['actions']['init']['custom'])
        for c in CLASSES.values():
            prefix='ForeverHUD | '+c['name']
            if c.get('pet'):
                self.assertEqual(by_id[prefix+' | Pet health']['barColor'],rgba(PET_HEALTH_COLOR))
            if c.get('extra')=='combo':
                number=by_id[prefix+' | Combo points']['subRegions'][2]
                self.assertEqual(number['text_text'],'%p / %t')
                self.assertEqual(number['text_text_format_t_decimal_precision'],0)

    def test_damage_left_everything_else_right(self):
        by_id={d['id']:d for d in self.regions}
        def screen(d):
            x,y=d['xOffset'],d['yOffset']
            while d.get('parent') in by_id and d['parent'] not in (TITLE,):
                d=by_id[d['parent']];x+=d['xOffset'];y+=d['yOffset']
            return x,y
        left=lambda id:(' | Target effects | ' in id or id.endswith(' | Rend missing') or ' | Usable proc | ' in id
            or id.endswith(' | Utility | Offense') or id in (CORE_ID+' | Native cooldowns',CORE_ID+' | Native tracked bars'))
        right=lambda id:((' | Player effects | ' in id and not id.endswith('Demon armor')) or ' | Battle Shout ' in id
            or ' | Weapon coating | ' in id or id.endswith(' | Maintenance') or ' | Totem ' in id or id.endswith(' | Utility | Defense')
            or id in (CORE_ID+' | Native player effects',CORE_ID+' | Native utility',CORE_ID+' | Native items'))
        seen={'left':0,'right':0}
        for d in self.regions:
            id=d['id']
            if left(id):
                self.assertLess(screen(d)[0],0,id);seen['left']+=1
            elif right(id):
                self.assertGreater(screen(d)[0],0,id);seen['right']+=1
            # Rows seated on the frame stay within their bar (Health -228..-48, resource 48..228).
            if (' | Player effects | ' in id and not id.endswith('Demon armor')) or ' | Battle Shout ' in id:
                x,y=screen(d);half=d['width']/2
                self.assertEqual(y,40,id);self.assertTrue(48<=x-half and x+half<=228,(id,x))
            if ' | Weapon coating | ' in id:
                # Not Modern auras, so fixed slots on the rim past the bar's end.
                x,y=screen(d);half=d['width']/2
                self.assertEqual(y,40,id);self.assertTrue(228<x-half and x+half<=300,(id,x))
            if id.endswith(' | Rend missing'):
                x,y=screen(d);half=d['width']/2
                self.assertEqual(y,40,id);self.assertTrue(-228<=x-half and x+half<=-48,(id,x))
        self.assertGreater(seen['left'],40);self.assertGreater(seen['right'],40)

    def test_retracted_seal_and_tray(self):
        by_id={d['id']:d for d in self.regions}
        for cls,c in CLASSES.items():
            prefix='ForeverHUD | '+c['name']
            seal,big=by_id[prefix+' | Seal'],by_id[prefix+' | Seal | Retracted']
            self.assertIn('not ForeverHUD.Retracted()',seal['triggers'][2]['trigger']['custom'])
            self.assertIn('and ForeverHUD.Retracted()',big['triggers'][2]['trigger']['custom'])
            self.assertGreater(big['width'],seal['width'],'The retracted seal is larger')
            self.assertEqual(big['parent'],prefix+' | Frame')
            tray=subtree(by_id,prefix+' | Tray')[1:]
            self.assertTrue(tray)
            for id in tray:
                d=by_id[id]
                self.assertTrue(d['load']['loadFlag'].startswith(f'FOREVERHUD_{cls}_tray'),id)
                gate=d['triggers'][max(k for k in d['triggers'] if isinstance(k,int))]['trigger'].get('custom','')
                if 'controlledChildren' not in d: self.assertIn('Gate("tray"',gate,id)
                self.assertLess(d['yOffset']+by_id[d['parent']]['yOffset'],-52,'Tray hangs below the larger seal')
            row=by_id[prefix+' | Tray | Row']
            self.assertEqual((row['blizzardFlow'],row['blizzardFlowGrowth']),(True,'CENTER_HORIZONTAL'))
            names=[by_id[id]['triggers'][1]['trigger']['auraRankSpellIDs'] for id in row['controlledChildren'] if id.split(' | ')[-1] in ('Food','Drink','Well Fed')]
            self.assertEqual(names,[['Food'],['Drink'],['Well Fed']],'Matched by aura name, not an ID list')
            # 0.9.1 minimal tray: no health/resource percentages.
            for side in ('Health','Resource'):
                self.assertNotIn(f'{prefix} | Tray | {side}',by_id)
            # 0.9.2: one horizontal row right under the seal for every class.
            self.assertEqual(row['yOffset'],-74)
            self.assertEqual(by_id[prefix+' | Tray']['controlledChildren'],[row['id']],'Everything in the tray sits in the one row')
            sizes={by_id[id]['width'] for id in row['controlledChildren']}
            self.assertEqual(len(sizes),1,'Same icon size across the row')
        shards=by_id['ForeverHUD | Warlock | Tray | Row | Soul Shards']
        self.assertEqual(by_id['ForeverHUD | Warlock | Tray | Row']['controlledChildren'][0],shards['id'],'The counter leads the row')
        texts={s['text_text']:s['text_visible'] for s in shards['subRegions'] if s['type']=='subtext'}
        self.assertEqual(texts,{'%p':False,'%s':True},'One count, in the corner')
        # 0.9.3: the native buttons' dark inner ring, under the frame.
        kinds=[s['type'] for s in shards['subRegions']]
        self.assertLess(kinds.index('subborder'),kinds.index('subtexture'),'Ring under the ornate frame')
        ring=shards['subRegions'][kinds.index('subborder')]
        self.assertEqual((ring['border_size'],ring['border_offset']),(3,0))
        # 0.9.5: tight frame like the native buttons, and a wider tray gap.
        frame=shards['subRegions'][kinds.index('subtexture')]
        self.assertEqual((frame['xOffset'],frame['yOffset']),(3,3))
        self.assertEqual(by_id['ForeverHUD | Warlock | Tray | Row']['blizzardFlowSpacing'],8)
        self.assertIn('ForeverHUD | Warlock | Tray | Row | Upkeep reminder | Demon armor missing',by_id)
        self.assertNotIn('ForeverHUD | Warlock | Tray | Row | Food',self.eligibility,'Name-matched icons skip spell discovery')

    def test_warlock_spell_suggestions(self):
        by_id={d['id']:d for d in self.regions}
        row=by_id['ForeverHUD | Warlock | Suggest']
        cues=by_id['ForeverHUD | Warlock | Suggest cues']
        # 0.10: one list per spec; Leveling keeps the 0.9 display IDs.
        # 0.11: a list's actions chain in the row; its threshold cues sit by their bar.
        lists={}
        for id in [d['id'] for d in self.regions if d['id'].startswith('ForeverHUD | Warlock | Suggest | ')]:
            lists.setdefault(self.eligibility[id]['spec'],[]).append(id)
        self.assertEqual(set(lists),{'Leveling','Affliction','Demonology','Destruction'})
        names=lambda spec:[id.split(' | ')[-1] for id in lists[spec]]
        self.assertEqual(names('Leveling'),['Life Tap','Corruption','Immolate','Shadow Trance','Health Funnel'],'Priority order, left to right')
        self.assertTrue(all(id.count(' | ')==3 for id in lists['Leveling']),'Leveling keeps the 0.9 IDs')
        self.assertEqual(names('Affliction'),['Life Tap','Corruption','Bane of Agony','Siphon Life','Shadow Trance'])
        self.assertEqual(names('Demonology'),['Life Tap','Corruption','Immolate','Bane of Agony','Health Funnel'])
        self.assertEqual(names('Destruction'),['Life Tap','Immolate','Conflagrate','Backlash','Shadowburn'])
        # The row grows left from the seal, its lead slot's right edge 4 px
        # outside the Health bar's inner end; actions sit at the row origin.
        self.assertEqual((row['blizzardFlow'],row['blizzardFlowGrowth'],row['blizzardFlowSpacing']),(True,'LEFT',4))
        self.assertEqual((row['xOffset']+16,row['yOffset']),(-52,74))
        for spec,ids in lists.items():
            actions=[id for id in ids if by_id[id]['parent']==row['id']]
            self.assertEqual(actions,[id for id in row['controlledChildren'] if id in ids],f'{spec}: row in priority order')
            self.assertTrue(all((by_id[id]['xOffset'],by_id[id]['yOffset'])==(0,0) for id in actions),spec)
            self.assertLessEqual(len(actions)*32+(len(actions)-1)*4,180,'Fits over the Health bar')
            for id in ids:
                if by_id[id]['parent']==cues['id']:
                    self.assertEqual(by_id[id]['triggers'][1]['trigger']['type'],'unit','Only threshold cues leave the row')
        mana=by_id['ForeverHUD | Warlock | Suggest | Life Tap']
        pet=by_id['ForeverHUD | Warlock | Suggest | Health Funnel']
        burn=by_id['ForeverHUD | Warlock | Suggest | Destruction | Shadowburn']
        self.assertEqual((mana['parent'],mana['xOffset'],mana['yOffset'],mana['width']),(cues['id'],218,-28,22),'Life Tap under the Mana bar')
        self.assertEqual((pet['parent'],pet['xOffset'],pet['yOffset'],pet['width']),(cues['id'],-218,-28,22),'Health Funnel under the Pet bar')
        self.assertEqual((burn['xOffset']-16,burn['yOffset']),(-228,74),'Execute cue in the row\'s far slot')
        destruction=[id for id in lists['Destruction'] if by_id[id]['parent']==row['id']]
        self.assertLessEqual(len(destruction)*32+(len(destruction)-1)*4,180-32-4,'Row never reaches the execute slot')
        conflag=by_id['ForeverHUD | Warlock | Suggest | Destruction | Conflagrate']
        self.assertEqual((conflag['triggers'][1]['trigger']['event'],conflag['triggers'][1]['trigger']['spellName']),('Action Usable',1293817))
        self.assertIn('ForeverHUD.SuggestTarget()',conflag['triggers'][2]['trigger']['custom'])
        burn=by_id['ForeverHUD | Warlock | Suggest | Destruction | Shadowburn']
        self.assertEqual((burn['triggers'][1]['trigger']['unit'],burn['conditions'][0]['check']),('target',dict(trigger=1,variable='percenthealth',op='<=',value=25)))
        self.assertIn('ForeverHUD.SuggestTarget()',burn['triggers'][2]['trigger']['custom'],'Execute cue only in combat on a hostile target')
        # 0.9.6: on the damage side, right above the DoT row.
        dots=by_id['ForeverHUD | Warlock | Target effects']
        self.assertEqual(row['yOffset']-16,dots['yOffset']+14+4,'4 px above the 28 px DoT row')
        selection=(ROOT/'src/ForeverHUD/Selection.lua').read_text(encoding='utf-8')
        # 0.9.7: the left wing (40 px at y=80) rises 4 px clear of the suggestions.
        lift=row['yOffset']+16+4+20-80
        self.assertEqual(lift,34)
        self.assertIn(f"S.WING_LIFT={lift}",selection,'Companion wing lift matches the generator')
        tap=by_id['ForeverHUD | Warlock | Suggest | Life Tap']
        self.assertEqual(tap['alpha'],0)
        self.assertEqual(tap['triggers'][1]['trigger']['event'],'Power')
        self.assertEqual(tap['conditions'],[dict(check=dict(trigger=1,variable='percentpower',op='<=',value=30),changes=[dict(property='alpha',value=1)])])
        funnel=by_id['ForeverHUD | Warlock | Suggest | Health Funnel']
        self.assertEqual((funnel['triggers'][1]['trigger']['unit'],funnel['conditions'][0]['check']['variable']),('pet','percenthealth'))
        for name in ('Corruption','Immolate'):
            d=by_id['ForeverHUD | Warlock | Suggest | '+name]
            self.assertEqual(d['triggers'][1]['trigger']['secretShowOn'],'showOnMissing')
            self.assertIn('ForeverHUD.SuggestTarget()',d['triggers'][2]['trigger']['custom'])
        self.assertEqual(self.eligibility['ForeverHUD | Warlock | Suggest | Shadow Trance']['seeds'],[18094,18095],'Shown once Nightfall is learned')
        self.assertEqual(self.eligibility['ForeverHUD | Warlock | Suggest | Life Tap']['seeds'],[1454])
        for d in self.regions:
            if d['id'].startswith('ForeverHUD | Warlock | Suggest | '):
                self.assertTrue(d['load']['loadFlag'].startswith('FOREVERHUD_WARLOCK_suggest'),d['id'])

    def test_every_class_has_spec_suggestions(self):
        from build import SUGGESTIONS
        from catalog import SCHOOLS
        by_id={d['id']:d for d in self.regions}
        for cls,c in CLASSES.items():
            self.assertTrue(set(SCHOOLS[cls])<=set(SUGGESTIONS[cls]),f'{cls}: a list for every spec')
            row=by_id[f"ForeverHUD | {c['name']} | Suggest"]
            cues=by_id.get(f"ForeverHUD | {c['name']} | Suggest cues",{'controlledChildren':[]})
            for id in row['controlledChildren']+cues['controlledChildren']:
                entry=self.eligibility[id]
                self.assertEqual((entry['cls'],entry['module']),(cls,'suggest'),id)
                self.assertIn(entry['spec'],SUGGESTIONS[cls],id)
                self.assertTrue(entry['seeds'],f'{id}: loads only once learned')
                self.assertTrue(by_id[id]['load']['loadFlag'].startswith(f'FOREVERHUD_{cls}_suggest_'),id)
        innervate=by_id['ForeverHUD | Druid | Suggest | Balance | Innervate']['triggers'][1]['trigger']
        self.assertEqual((innervate.get('use_powertype'),innervate.get('powertype')),(True,0),'Innervate tests mana, not form energy')
        sdn=by_id['ForeverHUD | Rogue | Suggest | Combat | Slice and Dice']['triggers'][1]['trigger']
        self.assertEqual((sdn['unit'],sdn['secretShowOn'],sdn['nativeFilters']),('player','showOnMissing',{'PLAYER':True}),'Own buff missing')

    def test_class_art_draws_below_core(self):
        # Core and class roots get independent frame levels, so strata keeps
        # the shared bars above class art: textures LOW, everything else inherits.
        for d in self.regions:
            if d['regionType']=='texture':
                self.assertEqual(d['frameStrata'],ART_STRATA,d['id'])
                self.assertNotEqual(owner_of(d),CORE,d['id'])
            else:
                self.assertEqual(d['frameStrata'],1,d['id'])
        self.assertEqual(ART_STRATA,3,'FA strata index 3 is LOW')

    def test_painted_art_preserves_transparency_and_class_identity(self):
        from PIL import Image
        import hashlib
        media=ROOT/'src/ForeverHUD/Media'
        seals=[]
        for token in CLASSES:
            path=media/('crest-'+token.lower()+'.png')
            with Image.open(path) as image:
                self.assertEqual(image.size,(256,256))
                self.assertEqual(image.mode,'RGBA')
                self.assertEqual(image.getchannel('A').getextrema(),(0,255))
                seals.append(hashlib.sha256(image.tobytes()).hexdigest())
        self.assertEqual(len(set(seals)),9,'Classes must have distinct painted emblems')
        with Image.open(media/'icon-frame.png') as image:
            self.assertEqual(image.getpixel((image.width//2,image.height//2))[3],0,'Spell artwork remains visible through the border')
        for name in ('warlock-seal','resource-frame','class-seals-atlas','icon-frame'):
            self.assertTrue((ROOT/'assets/ai'/(name+'.png')).is_file())
            self.assertIn('Built-in image_gen',(ROOT/'assets/ai'/(name+'.prompt.txt')).read_text(**UTF8))

if __name__=='__main__':unittest.main()
