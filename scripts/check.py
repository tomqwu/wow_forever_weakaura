#!/usr/bin/env python3
"""Local and CI checks, without starting or modifying the game client."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import zipfile
from build import VERSION
ROOT=Path(__file__).resolve().parents[1]
os.chdir(ROOT)
def run(args): subprocess.run(args,check=True)
assert f'## Version: {VERSION}' in (ROOT/'src/EclipseHUD/EclipseHUD.toc').read_text()
assert f'E.releaseVersion = "{VERSION}"' in (ROOT/'src/EclipseHUD/Core.lua').read_text()
assert f'Version {VERSION}' in (ROOT/'README.md').read_text()
assert f'## {VERSION} ' in (ROOT/'CHANGELOG.md').read_text()
assert f'name: Eclipse-Class-Combat-HUD-v{VERSION}' in (ROOT/'.github/workflows/check.yml').read_text()
for path in (ROOT/'src/EclipseHUD').glob('*.lua'):run(['luac','-p',str(path)])
run(['lua','tests/core.lua'])
run(['lua','tests/bridge.lua'])
run(['lua','tests/discovery.lua'])
run(['lua','tests/selection.lua'])
run(['lua','tests/state.lua'])
run(['lua','tests/motion.lua'])
run(['lua','tests/presentation.lua'])
run(['lua','tests/casting.lua'])
run(['lua','tests/alerts.lua'])
run(['lua','tests/effects.lua'])
run(['lua','tests/options.lua'])
run([sys.executable,'-m','unittest','discover','-s','tests','-v'])
run(['lua','scripts/codec.lua','verify','dist/Eclipse-Class-Combat-HUD.txt'])
source=os.environ.get('FOREVERAURAS_SOURCE')
if source:run(['lua','tests/native-schema.lua',source])
manifest=json.loads((ROOT/'dist/classes/manifest.json').read_text())
assert manifest['version']==VERSION
assert len(manifest['imports'])==9
combined_size=len((ROOT/'dist/Eclipse-Class-Combat-HUD.txt').read_text().strip())
for record in manifest['imports']:
    path=ROOT/'dist/classes'/record['file']
    raw=path.read_bytes()
    assert record['characters']==len(raw.rstrip(b'\n')) and record['bytes']==len(raw)
    assert record['sha256']==hashlib.sha256(raw).hexdigest()
    assert record['characters']<combined_size/2,'Class import is not materially smaller'
    run(['lua','scripts/codec.lua','verify',str(path),str(ROOT/'dist/.build/classes'/path.with_suffix('.lua').name)])
    if source:run(['lua','tests/native-schema.lua',source,str(ROOT/'dist/.build/classes'/path.with_suffix('.lua').name)])
archive=ROOT/f'dist/Eclipse-Class-Combat-HUD-v{VERSION}.zip'
with zipfile.ZipFile(archive) as z:
    names=z.namelist()
    assert z.testzip() is None,'Corrupt ZIP entry'
    assert 'EclipseHUD/EclipseHUD.toc' in names
    assert 'Eclipse-Class-Combat-HUD.txt' in names
    assert 'README.md' in names and 'LICENSE' in names
    assert len([name for name in names if name.endswith('.tga')])==23
    assert not any('Guos' in name or name.startswith('vendor/') for name in names)
    for path in (ROOT/'src/EclipseHUD').rglob('*'):
        if path.suffix in ('.toc','.lua','.tga','.wav'):
            relative=str(path.relative_to(ROOT/'src'))
            assert hashlib.sha256(path.read_bytes()).digest()==hashlib.sha256(z.read(relative)).digest(),relative+' mismatched'
    for path in (ROOT/'dist/classes').iterdir():
        if path.suffix in ('.txt','.md','.json'):assert z.read('imports/'+path.name)==path.read_bytes(),path.name+' mismatched'
    assert z.read('Eclipse-Class-Combat-HUD.txt')==(ROOT/'dist/Eclipse-Class-Combat-HUD.txt').read_bytes()
receipt=archive.with_suffix('.zip.sha256').read_text().split()[0]
assert receipt==hashlib.sha256(archive.read_bytes()).hexdigest(),'ZIP hash mismatched'
print('Package: correct addon root, all source/media bytes verified, no reference assets, SHA-256 verified')
