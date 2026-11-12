"""Browser regressions for the illustrative preview, never a live-client test."""
import argparse
import os
from pathlib import Path
from playwright.sync_api import sync_playwright

ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--capture',action='store_true')
args=parser.parse_args()
with sync_playwright() as p:
    options=dict(headless=True,args=['--no-sandbox'])
    if os.environ.get('FOREVERHUD_CHROMIUM'): options['executable_path']=os.environ['FOREVERHUD_CHROMIUM']
    browser=p.chromium.launch(**options)
    page=browser.new_page(viewport={'width':1400,'height':1000},device_scale_factor=1)
    errors=[]
    page.on('pageerror',lambda error:errors.append(str(error)))
    page.goto((ROOT/'preview/index.html').as_uri(),wait_until='domcontentloaded')
    page.wait_for_timeout(550)
    opacity=lambda:float(page.locator('.primary .tile').first.evaluate('(el)=>getComputedStyle(el).opacity'))
    assert opacity()==0,'Idle must fold primary'
    names=page.locator('.primary .tile').evaluate_all('(els)=>els.map(el=>el.getAttribute("aria-label"))')
    assert names and not {'Shadow Bolt','Corruption','Life Tap'} & set(names),'Cooldown fixture must not use GCD-only fillers'
    page.locator('#scenario').select_option('level23')
    assert page.locator('.primary .tile').count()==0,'Leveling fixture has no fabricated real cooldowns'
    page.locator('#scenario').select_option('learned')
    assert page.locator('.class-label').inner_text()==''
    assert page.locator('.maintenance .tile').count()==1
    assert page.locator('.maintenance .time').count()==0,'Long armor duration must not sit above the emblem'
    assert page.locator('.maintenance .tile').get_attribute('aria-label')=='Demon armor'
    page.locator('#cooldown-layout').select_option('Class plan')
    assert page.locator('.primary .tile[aria-label="Shadow Bolt"]').count()==1,'Authored plans remain explicit'
    page.locator('#cooldown-layout').select_option('Forever')
    assert not any('questionmark' in (src or '') for src in page.locator('img.spell').evaluate_all('(els)=>els.map(el=>el.src)'))
    page.locator('button[data-state="enemy"]').click();page.wait_for_timeout(600)
    assert opacity()==1,'Enemy target must unfold'
    assert page.locator('.effects .tile').count()==3
    assert page.locator('.primary .tile').evaluate_all('''els=>els.every(el=>{
        const r=el.getBoundingClientRect();return document.elementFromPoint(r.x+r.width/2,r.y+r.height/2)?.closest('.tile')===el
    })'''),'Artwork must not cover main spell centers'
    if args.capture:
        page.wait_for_function("Array.from(document.querySelectorAll('.viewport img')).every(img=>img.complete&&img.naturalWidth>0)")
        page.screenshot(path=str(ROOT/'preview/foreverhud-warlock.png'))
        page.locator('.viewport').screenshot(path=str(ROOT/'preview/classes/warlock.png'))
    page.locator('button[data-state="lost"]').click()
    assert page.locator('.effects .tile').count()==0,'Lost target clears effects immediately'
    page.wait_for_timeout(300);assert opacity()==1,'Close delay retains main row'
    page.wait_for_timeout(5050);assert opacity()==0,'Five-second hold eventually folds'
    page.locator('button[data-state="lost"]').click();page.wait_for_timeout(100)
    page.locator('button[data-state="enemy"]').click();page.wait_for_timeout(5200)
    assert opacity()==1,'Reacquisition cancels delayed close'
    page.locator('button[data-state="combat"]').click();page.wait_for_timeout(550)
    assert opacity()==1 and page.locator('.effects .tile').count()==0,'Combat without target stays expanded'
    page.locator('#scale').fill('120');page.locator('#scale').dispatch_event('input')
    for token in ('WARRIOR','MAGE','PRIEST','ROGUE','DRUID','HUNTER','SHAMAN','PALADIN'):
        page.locator(f'[data-class="{token}"]').click()
        page.locator('button[data-state="enemy"]').click();page.wait_for_timeout(550)
        assert page.locator('.primary .tile').count()>0,token+' empty sample'
        assert page.locator('#school option').count()==3,token+' missing school choices'
        if args.capture:
            page.wait_for_function("Array.from(document.querySelectorAll('.viewport img')).every(img=>img.complete&&img.naturalWidth>0)")
            page.locator('.viewport').screenshot(path=str(ROOT/'preview/classes'/f'{token.lower()}.png'))
    # Public identity fixtures exercise the same semantic palette as the import.
    color=lambda selector:page.locator(selector).evaluate('(el)=>getComputedStyle(el).backgroundColor')
    for token,label,expected in [('WARLOCK','Mana','rgb(67, 141, 255)'),('WARRIOR','Rage','rgb(242, 122, 50)'),('ROGUE','Energy','rgb(244, 199, 71)')]:
        page.locator(f'[data-class="{token}"]').click()
        assert page.locator('.power .role').inner_text()==label
        assert color('.power .fill')==expected
        assert color('.hp .fill')=='rgb(217, 74, 90)'
        assert not page.locator('.form-control').is_visible()
    assert page.locator('.combo-bar').is_visible()
    assert page.locator('.combo-bar').inner_text()=='2 / 5'
    assert not page.locator('.pet-label').is_visible(),'Rogue has no pet health role'
    page.locator('[data-class="DRUID"]').click()
    assert page.locator('.form-control').is_visible()
    for form,label,expected in [('Caster','Mana','rgb(67, 141, 255)'),('Cat','Energy','rgb(244, 199, 71)'),('Bear','Rage','rgb(242, 122, 50)'),('Caster','Mana','rgb(67, 141, 255)')]:
        page.locator('#form').select_option(form)
        assert page.locator('.power .role').inner_text()==label
        assert color('.power .fill')==expected
        assert page.locator('.combo-bar').is_visible()==(form=='Cat')
    page.locator('[data-class="WARLOCK"]').click()
    page.locator('[data-module="maintenance"]').uncheck()
    assert page.locator('.maintenance').evaluate('(el)=>getComputedStyle(el).visibility')=='hidden'
    assert page.locator('.hp').evaluate('(el)=>getComputedStyle(el).visibility')=='visible'
    page.locator('[data-module="maintenance"]').check()
    page.locator('[data-module="pet"]').uncheck()
    assert page.locator('.tiny').evaluate('(el)=>getComputedStyle(el).visibility')=='hidden'
    assert page.locator('.shards').evaluate('(el)=>getComputedStyle(el).visibility')=='hidden'
    assert page.locator('.hp').evaluate('(el)=>getComputedStyle(el).visibility')=='visible'
    page.locator('[data-module="pet"]').check()
    page.locator('[data-module="resources"]').uncheck()
    assert page.locator('.tiny').evaluate('(el)=>getComputedStyle(el).visibility')=='visible'
    assert page.locator('.hp').evaluate('(el)=>getComputedStyle(el).visibility')=='hidden'
    page.locator('[data-module="resources"]').check()
    assert page.locator('#scale').input_value()=='120','Class preview preferences persist independently'
    page.locator('#reset').click();assert page.locator('#scale').input_value()=='100'
    # Readable visual toggle and explicit bar selection are illustrative fixtures.
    page.locator('button[data-state="idle"]').click();page.wait_for_timeout(550)
    if args.capture:
        (ROOT/'preview/states').mkdir(exist_ok=True)
        (ROOT/'preview/casting').mkdir(exist_ok=True)
        page.locator('.viewport').screenshot(path=str(ROOT/'preview/states/warlock-idle.png'))
    page.locator('.crest').click();page.wait_for_timeout(120)
    assert 0<opacity()<1,'Expansion must have visible intermediate frames'
    if args.capture:page.locator('.viewport').screenshot(path=str(ROOT/'preview/states/warlock-opening.png'))
    page.wait_for_timeout(550)
    assert opacity()==1,'First crest click expands out of combat'
    if args.capture:page.locator('.viewport').screenshot(path=str(ROOT/'preview/states/warlock-click-open.png'))
    page.locator('.crest').click();page.wait_for_timeout(550)
    assert opacity()==0,'Second crest click folds immediately'
    page.locator('button[data-state="combat"]').click()
    for mode in ('Default','ForeverHUD','Both'):
        page.locator('#cast-mode').select_option(mode);page.wait_for_timeout(550)
        assert page.locator('.cast').is_visible()==(mode!='Default')
        assert page.locator('.game-cast').is_visible()==(mode!='ForeverHUD')
        if args.capture:page.locator('.viewport').screenshot(path=str(ROOT/'preview/casting'/f'warlock-{mode.lower()}.png'))
    page.locator('button[data-state="enemy"]').click()
    page.locator('[data-module="trackedBars"]').check()
    assert page.locator('.tracked-sample').count()==3
    assert 'Corruption' in page.locator('.trackedBars').inner_text()
    if args.capture:
        page.set_viewport_size({'width':1600,'height':1000});page.wait_for_timeout(550)
        page.locator('.viewport').screenshot(path=str(ROOT/'preview/states/warlock-tracked-bars.png'))
    assert not errors,errors
    browser.close()
print('Preview browser regressions passed: nine classes, leveling fixture, visibility/delay, artwork stacking, semantic colors/form transitions, independent settings')
