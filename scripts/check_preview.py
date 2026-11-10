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
    if os.environ.get('ECLIPSE_CHROMIUM'): options['executable_path']=os.environ['ECLIPSE_CHROMIUM']
    browser=p.chromium.launch(**options)
    page=browser.new_page(viewport={'width':1400,'height':1000},device_scale_factor=1)
    errors=[]
    page.on('pageerror',lambda error:errors.append(str(error)))
    page.goto((ROOT/'preview/index.html').as_uri(),wait_until='domcontentloaded')
    page.wait_for_timeout(550)
    opacity=lambda:float(page.locator('.primary .tile').first.evaluate('(el)=>getComputedStyle(el).opacity'))
    assert opacity()==0,'Idle must fold primary'
    names=page.locator('.primary .tile').evaluate_all('(els)=>els.map(el=>el.getAttribute("aria-label"))')
    assert set(names)=={'Life Tap','Fear','Health Funnel','Shadow Bolt','Immolate','Corruption','Drain Life'}
    assert not any('questionmark' in (src or '') for src in page.locator('img.spell').evaluate_all('(els)=>els.map(el=>el.src)'))
    page.locator('button[data-state="enemy"]').click();page.wait_for_timeout(600)
    assert opacity()==1,'Enemy target must unfold'
    assert page.locator('.effects .tile').count()==2
    assert page.locator('.primary .tile').evaluate_all('''els=>els.every(el=>{
        const r=el.getBoundingClientRect();return document.elementFromPoint(r.x+r.width/2,r.y+r.height/2)?.closest('.tile')===el
    })'''),'Artwork must not cover main spell centers'
    if args.capture:
        page.screenshot(path=str(ROOT/'preview/eclipse-warlock.png'))
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
        if args.capture:page.locator('.viewport').screenshot(path=str(ROOT/'preview/classes'/f'{token.lower()}.png'))
    page.locator('[data-class="WARLOCK"]').click()
    assert page.locator('#scale').input_value()=='120','Class preview preferences persist independently'
    page.locator('#reset').click();assert page.locator('#scale').input_value()=='100'
    assert not errors,errors
    browser.close()
print('Preview browser regressions passed: nine classes, leveling fixture, visibility/delay, artwork stacking, settings')
