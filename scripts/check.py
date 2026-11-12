#!/usr/bin/env python3
"""Local and CI checks, without starting or modifying the game client."""
import hashlib
import json
import os
import re
import shutil
from pathlib import Path
import subprocess
import sys
import zipfile
from build import VERSION, IMPORT_API, TOC_VERSION, UTF8, packaged_readme
ROOT=Path(__file__).resolve().parents[1]
os.chdir(ROOT)

def run(args): subprocess.run(args,check=True)
def text(name): return (ROOT/name).read_text(**UTF8)

for tool in ('lua','luac'):
    if not shutil.which(tool): sys.exit(f'check.py: "{tool}" is not on PATH; install Lua 5.1 (CI uses the lua5.1 package).')

# One version, checked everywhere it must appear. Word boundaries keep 0.3.3
# from matching 0.3.30, and the changelog's newest entry must be this version.
version=re.escape(VERSION)
toc=text('src/ForeverHUD/ForeverHUD.toc')
assert re.search(rf'^## Version: {version}$',toc,re.M),'TOC version'
assert re.search(rf'^## Interface: {TOC_VERSION}$',toc,re.M),'TOC interface must match build.TOC_VERSION'
core=text('src/ForeverHUD/Core.lua')
assert f'E.releaseVersion = "{VERSION}"' in core,'Core.lua releaseVersion'
assert f'E.importAPI = {IMPORT_API}\n' in core,'Core.lua importAPI must match build.IMPORT_API'
assert re.search(rf'Version {version}\b',text('README.md')),'README version'
first=re.search(r'^## (\S+)',text('CHANGELOG.md'),re.M)
assert first and first.group(1)==VERSION,f'Newest CHANGELOG entry must be {VERSION}'
assert re.search(rf'name: ForeverHUD-v{version}$',text('.github/workflows/check.yml'),re.M),'Workflow artifact name'

for path in sorted((ROOT/'src/ForeverHUD').glob('*.lua')):run(['luac','-p',str(path)])
for suite in ('core','bridge','discovery','selection','state','motion','presentation','casting','alerts','effects','options','bundle'):
    run(['lua',f'tests/{suite}.lua'])
run([sys.executable,'-m','unittest','discover','-s','tests','-v'])
run(['lua','scripts/codec.lua','verify','dist/ForeverHUD-All-Classes.txt','dist/ForeverHUD-All-Classes.lua'])
source=os.environ.get('FOREVERAURAS_SOURCE')
if source:run(['lua','tests/native-schema.lua',source])
manifest=json.loads(text('dist/classes/manifest.json'))
assert manifest['version']==VERSION
assert len(manifest['imports'])==9
combined_size=len(text('dist/ForeverHUD-All-Classes.txt').strip())
class_files={path.name for path in (ROOT/'dist/classes').glob('*.txt')}
assert class_files=={record['file'] for record in manifest['imports']},'Stale or missing class import'
for record in manifest['imports']:
    path=ROOT/'dist/classes'/record['file']
    raw=path.read_bytes()
    assert record['characters']==len(raw.rstrip(b'\n')) and record['bytes']==len(raw)
    assert record['sha256']==hashlib.sha256(raw).hexdigest()
    assert record['characters']<combined_size/2,'Class import is not materially smaller'
    expected=ROOT/'dist/.build/classes'/path.with_suffix('.lua').name
    run(['lua','scripts/codec.lua','verify',str(path),str(expected)])
    if source:run(['lua','tests/native-schema.lua',source,str(expected)])
archive=ROOT/f'dist/ForeverHUD-v{VERSION}.zip'
with zipfile.ZipFile(archive) as z:
    names=z.namelist()
    assert z.testzip() is None,'Corrupt ZIP entry'
    assert len(names)==len(set(names)),'Duplicate ZIP entry'
    assert 'ForeverHUD/ForeverHUD.toc' in names
    assert 'ForeverHUD-All-Classes.txt' in names
    assert 'README.md' in names and 'LICENSE' in names
    assert z.read('README.md').decode('utf-8')==packaged_readme()
    assert z.read('CHANGELOG.md')==(ROOT/'CHANGELOG.md').read_bytes()
    for folder in ('docs/images','preview/classes','preview/states','preview/casting'):
        for path in (ROOT/folder).glob('*.png'):
            assert z.read(path.relative_to(ROOT).as_posix())==path.read_bytes(),str(path)
    assert len([name for name in names if name.endswith('.tga')])==23
    assert not any('Guos' in name or name.startswith('vendor/') for name in names)
    for path in (ROOT/'src/ForeverHUD').rglob('*'):
        if path.suffix in ('.toc','.lua','.tga','.wav'):
            relative=path.relative_to(ROOT/'src').as_posix()
            assert z.read(relative)==path.read_bytes(),relative+' mismatched'
    packaged_imports={name[len('imports/'):] for name in names if name.startswith('imports/')}
    assert packaged_imports=={path.name for path in (ROOT/'dist/classes').iterdir() if path.suffix in ('.txt','.md','.json')}
    for name in packaged_imports:
        assert z.read('imports/'+name)==(ROOT/'dist/classes'/name).read_bytes(),name+' mismatched'
    assert z.read('ForeverHUD-All-Classes.txt')==(ROOT/'dist/ForeverHUD-All-Classes.txt').read_bytes()
receipt=archive.with_suffix('.zip.sha256').read_text(**UTF8).split()[0]
assert receipt==hashlib.sha256(archive.read_bytes()).hexdigest(),'ZIP hash mismatched'
print('Package: correct addon root, all source/media bytes verified, no reference assets, SHA-256 verified')
