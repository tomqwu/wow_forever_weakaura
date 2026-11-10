import json
import struct
import unittest
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
sys.path.insert(0,str(ROOT/'src'))
from build import generate, TITLE
from catalog import CLASSES, HEALTH_COLOR, PET_HEALTH_COLOR, UNKNOWN_RESOURCE_COLOR, RESOURCE_STYLES
from build import rgba

class PackTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.pack=generate();cls.regions=[cls.pack['d']]+cls.pack['c']
    def test_class_switch_and_disabled_module_lifecycle(self):
        classes=set()
        for d in self.pack['c']:
            load=d['load']
            self.assertTrue(load['use_class'],d['id'])
            classes.add(load['class']['single'])
            self.assertTrue(load['use_loadFlag'],d['id'])
            self.assertTrue(load['loadFlag'].startswith('ECLIPSE_'+load['class']['single']+'_'))
        self.assertEqual(classes,set(CLASSES))
        self.assertEqual(len(self.pack['d']['controlledChildren']),9)
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
                if value.startswith('Interface\\AddOns\\EclipseHUD\\'):
                    self.assertTrue((ROOT/'src/EclipseHUD'/value.split('EclipseHUD\\',1)[1].replace('\\','/')).is_file(),value)
        code=(ROOT/'src/EclipseHUD/Core.lua').read_text()
        for forbidden in ('COMBAT_LOG_EVENT_UNFILTERED','UnitAura(', 'GetAuraDataByIndex','GetSpellCooldown','SetScript("OnUpdate"'):
            self.assertNotIn(forbidden,code)
    def test_wow_texture_format(self):
        files=list((ROOT/'src/EclipseHUD/Media').glob('*.tga'))
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
        self.assertEqual(by_id[TITLE]['anchorFrameFrame'],'EclipseHUDAnchor')
        for d in self.regions:
            for child in d.get('controlledChildren',[]):self.assertEqual(by_id[child]['parent'],d['id'])

    def test_native_effect_animation_and_resource_curve(self):
        effects=[d for d in self.regions if ' | FX | ' in d['id']]
        self.assertGreater(len(effects),30)
        for d in effects:
            self.assertEqual(d['triggers'][1]['trigger']['type'],'secretAura')
            self.assertIn(d['blizzardAuraDisplay']['auraStart']['type'],('fade','zoom'))
            self.assertEqual(d['blizzardAuraDisplay']['auraMain']['type'],'pulse')
        for cls,c in CLASSES.items():
            by_tier={d['id'].rsplit(' | ',1)[1]:d for d in effects if d['load']['class']['single']==cls}
            parent=next(d for d in self.regions if d['id']==f"Eclipse | {c['name']}")
            order=parent['controlledChildren']
            self.assertGreater(order.index(by_tier['defense']['id']),order.index(by_tier['major']['id']))
            self.assertLess(order.index(by_tier['defense']['id']),order.index(f"Eclipse | {c['name']} | Primary"))
            resource=next(d for d in self.regions if d['id']==f"Eclipse | {c['name']} | FX resource intensity")
            self.assertEqual(resource['triggers'][1]['trigger']['event'],'Power')
            self.assertTrue(all(x['check']['variable']=='percentpower' for x in resource['conditions']))

    def test_native_cooldown_slots_and_maintenance_are_separate(self):
        by_id={d['id']:d for d in self.regions}
        for c in CLASSES.values():
            prefix='Eclipse | '+c['name']
            for slot in range(1,9):
                group=by_id[f'{prefix} | Primary | Native {slot}']
                self.assertEqual(group['regionType'],'group')
                icon=by_id[group['id']+' | Entry']
                self.assertEqual(icon['triggers'][1]['trigger']['event'],'Blizzard Cooldown Manager')
                self.assertEqual(icon['triggers'][1]['trigger']['cdmShow'],'always')
                self.assertEqual(icon['parent'],group['id'])
            self.assertEqual(by_id[prefix+' | Native items | Entries']['triggers'][1]['trigger']['event'],'Blizzard CDM Item')
            self.assertIn('_maintenance',by_id[prefix+' | Maintenance']['load']['loadFlag'])
            self.assertLess(by_id[prefix+' | Maintenance']['xOffset'],-250)
        armor=by_id['Eclipse | Warlock | Player effects | Demon armor']
        self.assertEqual(armor['parent'],'Eclipse | Warlock | Maintenance')
        self.assertIn('_maintenance_',armor['load']['loadFlag'])
        self.assertFalse(armor['subRegions'][2]['text_visible'])
        self.assertEqual(armor['triggers'][1]['trigger']['secretShowOn'],'showOnActive')

    def test_resource_colors_follow_native_type_across_classes(self):
        by_id={d['id']:d for d in self.regions}
        for c in CLASSES.values():
            prefix='Eclipse | '+c['name']
            health=by_id[prefix+' | Health']
            self.assertEqual(health['barColor'],rgba(HEALTH_COLOR))
            power=by_id[prefix+' | Resource']
            self.assertEqual(power['barColor'],rgba(UNKNOWN_RESOURCE_COLOR))
            self.assertFalse(power['triggers'][1]['trigger'].get('use_powertype',False))
            mapping={rule['check']['value']:rule['changes'][0]['value'] for rule in power['conditions']}
            self.assertEqual(mapping,{kind:rgba(style['color']) for kind,style in RESOURCE_STYLES.items()})
            self.assertTrue(all(rule['check']['variable']=='powertype' for rule in power['conditions']))
            self.assertIn('EclipseHUD.ResourceLabel()',power['customText'])
            if c.get('pet'):
                self.assertEqual(by_id[prefix+' | Pet health']['barColor'],rgba(PET_HEALTH_COLOR))
            if c.get('extra')=='combo':
                number=by_id[prefix+' | Combo points']['subRegions'][2]
                self.assertEqual(number['text_text'],'%p / %t')
                self.assertEqual(number['text_text_format_t_decimal_precision'],0)

    def test_painted_art_preserves_transparency_and_class_identity(self):
        from PIL import Image
        import hashlib
        media=ROOT/'src/EclipseHUD/Media'
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
            self.assertIn('Built-in image_gen',(ROOT/'assets/ai'/(name+'.prompt.txt')).read_text())

if __name__=='__main__':unittest.main()
