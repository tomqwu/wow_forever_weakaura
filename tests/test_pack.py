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
    return ['Frame']+(['Resources'] if c.get('pet') or c.get('extra') else [])+['Primary','Utility','Auras','Nameplates','Alerts']
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
        self.assertEqual(len(files),23)
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
            # Damage side: the DoT row sits above the left wing, inside the chassis.
            dots=by_id[prefix+' | Target effects']
            self.assertEqual(dots['yOffset'],92)
            xs=[by_id[child]['xOffset'] for child in dots['controlledChildren']]
            self.assertTrue(all(-256<x<-60 for x in xs),(c['name'],xs))
            self.assertEqual(len(set(xs)),len(xs),'Fixed slots, one per DoT')
        tracked=by_id[CORE_ID+' | Native tracked bars | Entries']
        self.assertEqual(tracked['regionType'],'aurabar')
        self.assertEqual(tracked['triggers'][1]['trigger']['event'],'Blizzard CDM Buff')
        self.assertEqual(tracked['load']['loadFlag'],'FOREVERHUD_CORE_trackedBars')
        self.assertLess(by_id[CORE_ID+' | Native tracked bars']['xOffset'],-250,'Duration bars sit on the damage side')
        self.assertEqual(by_id[CORE_ID+' | Native items | Entries']['triggers'][1]['trigger']['event'],'Blizzard CDM Item')
        armor=by_id['ForeverHUD | Warlock | Player effects | Demon armor']
        self.assertEqual(armor['parent'],'ForeverHUD | Warlock | Maintenance')
        self.assertIn('_maintenance_',armor['load']['loadFlag'])
        self.assertFalse(armor['subRegions'][2]['text_visible'])
        self.assertEqual(armor['triggers'][1]['trigger']['secretShowOn'],'showOnActive')

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
