import json
import struct
import unittest
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
sys.path.insert(0,str(ROOT/'src'))
from build import generate, TITLE
from catalog import CLASSES

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
            self.assertEqual(t['secretShowOn'],'showOnActive')
            self.assertEqual(t['nativeFilters'],{'PLAYER':True})
            self.assertTrue(t['auraRankSpellIDs'])
            self.assertEqual(d['blizzardAuraDisplay']['maxIcons'],1)
            self.assertTrue(all(a['type']=='none' for a in d['animation'].values()))
            self.assertFalse(d['actions']['start']);self.assertFalse(d['actions']['finish'])
            self.assertEqual(d['conditions'],[])
            if t['unit']=='nameplate':
                self.assertEqual(d['anchorFrameType'],'NAMEPLATE')
                self.assertTrue(d['load']['loadFlag'].endswith('_nameplates'))
    def test_localization_and_forever_seeds(self):
        warlock=CLASSES['WARLOCK']
        self.assertIn((1293817,'Conflagrate'),warlock['primary'])
        self.assertIn((1316697,'Wrack'),warlock['dots'])
        self.assertIn((980,'Bane of Agony'),warlock['dots'])
        self.assertIn((402174,'Penance'),CLASSES['PRIEST']['primary'])
        for d in self.regions:
            if d['id'].endswith(' | Class name'):self.assertIn('EclipseHUD.L',d['customText'])
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
        self.assertEqual(len(files),21)
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
