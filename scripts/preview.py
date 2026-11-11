#!/usr/bin/env python3
"""A local visual review of the generated layout, using its actual painted media.

Samples are explicitly illustrative. This is not a WoW runtime emulator.
"""
import json
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'src'))
from catalog import CLASSES, PLANS, SCHOOLS, candidates, ALERTS, RESOURCE_STYLES, HEALTH_COLOR, PET_HEALTH_COLOR
from build import VERSION

HTML=r'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Eclipse · Class HUD preview</title><style>
*{box-sizing:border-box}body{margin:0;background:#0b0c11;color:#e8e5ed;font:13px system-ui,sans-serif}button,input{font:inherit}button{cursor:pointer;color:inherit}header{height:94px;display:flex;align-items:center;justify-content:space-between;padding:0 40px;border-bottom:1px solid #24232c}.brand{font:24px Georgia,serif;letter-spacing:7px}.brand small{display:block;font:10px system-ui;letter-spacing:2.3px;color:#88848f;margin-top:10px}.version{font:10px monospace;letter-spacing:1px;color:#a39aad;border:1px solid #35303e;padding:7px 11px}main{padding:28px 40px;max-width:1600px;margin:auto}.classes{display:flex;gap:6px;margin-bottom:22px;flex-wrap:wrap}.classes button{border:1px solid #25242e;background:#111218;padding:9px 13px;font-size:11px;border-radius:3px}.classes button.active{border-color:var(--class);background:color-mix(in srgb,var(--class) 12%,#0c0d12);color:var(--class)}.layout{display:grid;grid-template-columns:minmax(620px,1fr) 300px;gap:22px}.viewport{position:relative;min-height:570px;border:1px solid #272431;border-radius:5px;overflow:hidden;background:radial-gradient(ellipse at 50% 43%,#33274433,transparent 60%),linear-gradient(#14141f,#13151d 65%,#101218)}.viewport:before{content:"";position:absolute;inset:0;opacity:.15;background-image:radial-gradient(#baa2e5 1px,transparent 1px);background-size:57px 57px}.stage-label{position:absolute;left:22px;top:20px;font:10px monospace;letter-spacing:2px;color:#6d687b}.cross{position:absolute;top:104px;left:50%;width:16px;height:16px;opacity:.2}.cross:before,.cross:after{content:"";position:absolute;background:#c5b9d8}.cross:before{width:1px;height:15px;left:7px}.cross:after{height:1px;width:15px;top:7px}.hud{--class:#ac89ef;--accent:#b5f471;position:absolute;top:230px;left:50%;width:512px;height:1px;transform:translateX(-50%);transform-origin:50% 0;user-select:none}.chassis{position:absolute;width:512px;height:128px;left:0;top:-84px;z-index:1}.crest{position:absolute;width:104px;height:104px;left:204px;top:-65px;z-index:4;cursor:grab}.runes{position:absolute;width:112px;height:112px;left:200px;top:-69px;z-index:2;opacity:.18;pointer-events:none;animation:spin 45s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}.class-label{position:absolute;left:0;top:-84px;width:100%;text-align:center;font-size:10px;letter-spacing:3px;color:var(--class)}.bar{position:absolute;height:13px;width:180px;top:-20px;background:#04050a;z-index:3;box-shadow:0 0 0 1px #56435955}.hp{left:28px}.power{left:304px}.fill{height:100%;background:linear-gradient(#94ae60,#486d3a);box-shadow:0 0 9px #90bb4933}.power .fill{background:linear-gradient(color-mix(in srgb,var(--class) 80%,white),var(--class));opacity:.8}.bar span{position:absolute;right:5px;top:0;font:10px Georgia;line-height:13px;text-shadow:0 1px 2px #000}.tiny{position:absolute;height:6px;width:180px;left:28px;top:9px;background:#090a10;z-index:3}.tiny .fill{background:var(--accent);opacity:.55}.pet-label,.shards{position:absolute;top:22px;color:#858292;font-size:9px;letter-spacing:.5px}.pet-label{left:28px}.shards{left:304px;top:7px;width:180px;text-align:center;color:var(--accent);font-size:11px}.row{position:absolute;display:flex;gap:8px;justify-content:center;width:512px;left:0}.primary{top:45px}.effects{top:103px}.buffs{top:-129px}.utility{top:192px}.tile{position:relative;flex:0 0 42px;height:42px;background:radial-gradient(ellipse at 30% 25%,var(--tilecolor,#8b4cb0),#12101d 85%);border:1px solid #a88cb388;box-shadow:inset 0 0 0 2px #080910,0 2px 5px #0008;border-radius:3px;color:#ded1ed;display:grid;place-items:center;font:21px Georgia}.tile:before{content:"";position:absolute;inset:0;background:linear-gradient(115deg,#fff2,transparent 40%,#0004);pointer-events:none}.tile .time{position:absolute;inset:0;display:grid;place-items:center;font:bold 16px Georgia;color:#fff;text-shadow:0 1px 3px #000;background:#0004}.tile-label{position:absolute;top:47px;font:8px system-ui;color:#8f899c;white-space:nowrap;text-align:center}.effects{gap:8px}.effects .tile{flex-basis:32px;height:32px;font-size:17px}.effects .time{font-size:12px}.effects .tile-label{top:37px;font-size:7px}.buffs .tile{flex-basis:26px;height:26px;font-size:14px;border-color:var(--accent)}.utility .tile{flex-basis:30px;height:30px;font-size:15px;opacity:.75}.utility .time{font-size:12px}.cast{position:absolute;top:159.5px;left:106px;width:300px;height:13px;border:1px solid #8c786744;background:#05070c}.cast .fill{background:linear-gradient(90deg,var(--class),var(--accent));width:62%;opacity:.65}.cast span{position:absolute;top:-1px;left:5px;font:9px Georgia;line-height:13px}.cast .cast-time{left:auto;right:5px}.context{position:absolute;bottom:22px;left:22px;right:22px;color:#696674;font-size:10px;line-height:1.7}.context strong{color:#b0a6be;font-weight:400}.side{background:#121218;border:1px solid #2b2635;border-radius:5px;padding:24px}.side h1{font:18px Georgia;margin:0 0 7px}.side .muted{font-size:11px;color:#827a90;line-height:1.6;margin-bottom:22px}.line{height:1px;background:#282330;margin:20px 0}.option{display:flex;align-items:center;justify-content:space-between;margin:16px 0;color:#aaa3b6;font-size:12px}.option input[type=checkbox]{accent-color:#a887dd;width:15px;height:15px}.side label.scale{font-size:11px;color:#aaa3b6;display:flex;justify-content:space-between}.side input[type=range]{accent-color:#ad8bdd;width:100%;margin:15px 0}.note{font-size:10px;color:#756d84;line-height:1.8}.side code{background:#211c2d;color:#c4a3f1;padding:3px 6px;border-radius:3px}.side button{width:100%;border:1px solid #4d3b64;border-radius:3px;background:#2b203b;padding:10px;margin-top:14px;font-size:11px;color:#d6c2ee}.footer{display:flex;justify-content:space-between;color:#625e6c;font:10px monospace;padding-top:18px;line-height:1.7}@media(max-width:1050px){.layout{grid-template-columns:1fr}.side{display:none}}@media(prefers-reduced-motion:reduce){.runes{animation:none}}
.tile{border:0;border-radius:0;box-shadow:0 2px 7px #000b;background:#08060c}.tile .spell{width:100%;height:100%;object-fit:cover;border-radius:2px}.tile:before{display:none}.tile:after{content:"";position:absolute;inset:-4px;background:url('../src/EclipseHUD/Media/icon-frame.png') center/100% 100%;pointer-events:none;z-index:6}.tile .time{z-index:7;font:bold 15px system-ui;text-shadow:0 2px 3px #000,1px 0 #000}.buffs .tile,.utility .tile{border:0}.effects .tile{border:0}.viewport{min-height:610px}.context{font-size:11px}.footer{font-size:10px}
</style><header><div class="brand">ECLIPSE<small>CLASS COMBAT HUD / FOREVER</small></div><div class="version">VERSION_LABEL · BEHAVIOR PREVIEW</div></header><main><nav class="classes" aria-label="Class"></nav><div class="layout"><section class="viewport"><div class="stage-label">HUD LAYOUT · SAMPLE COMBAT STATE</div><div class="cross"></div><div class="game-cast"><span>Default game bar · sample</span><div>Health Funnel</div></div><div class="hud"><img class="chassis" alt="Original ornamental resource frame"><div class="class-label"></div><div class="bar hp"><div class="fill" style="width:83%"></div><span class="value">4,850</span><span class="role">Health</span></div><div class="bar power"><div class="fill" style="width:71%"></div><span class="value">3,420</span><span class="role">Mana</span></div><div class="tiny"><div class="fill" style="width:91%"></div><span class="value">922</span></div><div class="pet-label">Pet</div><div class="shards">◆ 24</div><img class="crest" alt="Class seal"><img class="runes" src="../src/EclipseHUD/Media/runes.png" alt=""><div class="row buffs"></div><div class="maintenance"></div><div class="trackedBars"></div><div class="row primary"></div><div class="row effects"></div><div class="cast"><div class="fill"></div><span class="cast-name">Shadow Bolt</span><span class="cast-time">1.2</span></div><div class="row utility"></div><div class="combo-bar"><div class="fill" style="width:40%"></div><span>2 / 5</span></div></div><div class="context"><strong>Drag the seal to reposition.</strong> Class tabs preview the same layout system.<br>Mock native categories and values; live auras, resources and timers are drawn by the game. Hover a spell for its name.</div></section><aside class="side"><h1>Warlock</h1><div class="muted">One import. The right class, automatically.<br>Each character class keeps its own settings.</div><label class="option">Health & resources<input type="checkbox" data-module="resources" checked></label><label class="option">Primary abilities<input type="checkbox" data-module="primary" checked></label><label class="option">Target effects<input type="checkbox" data-module="effects" checked></label><label class="option">Player effects<input type="checkbox" data-module="buffs" checked></label><label class="option">Maintenance buffs<input type="checkbox" data-module="maintenance" checked></label><label class="option">Utility row<input type="checkbox" data-module="utility" checked></label><label class="option">Cast bar<input type="checkbox" data-module="cast" checked></label><label class="option">Pet & class resource<input type="checkbox" data-module="pet" checked></label><label class="option">Tracked bars (Eclipse)<input type="checkbox" data-module="trackedBars"></label><label class="option">Living runes<input type="checkbox" data-module="runes" checked></label><div class="line"></div><label class="scale">HUD scale<span id="scale-value">100%</span></label><input type="range" id="scale" min="60" max="140" value="100" aria-label="HUD scale"><div class="line"></div><div class="note">IN GAME<br><code>/eclipse</code> for controls<br><code>/fa</code> for individual aura editing<br><br>Native combat aura tracking. No estimated DoT timers or combat-log reconstruction.</div><button id="reset">Reset this class preview</button></aside></div><div class="footer"><span>9 CLASSES / AI-PAINTED CLASS ART / ENGLISH + 简体中文</span><span>LOCAL PREVIEW · NOT A LIVE CLIENT TEST</span></div></main><script>

const classes=CATALOG, icons=ICONS, plans=PLANS, schools=SCHOOLS, resourceStyles=RESOURCE_PALETTE, healthColor=HEALTH_FILL, petHealthColor=PET_HEALTH_FILL;
const $=s=>document.querySelector(s), rowHTML=new Map(), params=new URLSearchParams(location.search);
let active=params.get('class')||'WARLOCK', profiles={}, currentState='idle', closing, manualOpen=false, manualFold=false;
const warlock23=['Shadow Bolt','Corruption','Immolate','Drain Life','Drain Soul','Life Tap','Fear','Health Funnel'];
function profile(){return profiles[active]??={scale:100,offset:[0,0],school:schools[active][0],
 form:'Caster',cooldownLayout:'Forever',castBarMode:'Default',scenario:'learned',modules:{trackedBars:false,maintenance:true,pet:true,resources:true,primary:true,effects:true,buffs:true,utility:true,cast:false,runes:true}}}
function tile(name,time='',x=null,index=0){
 const image=icons[name];if(!image)return '';
 const placement=x===null?'':`style="left:${256+x-20}px;--dx:${-x}px;--delay:${index*.065}s"`;
 return `<div class="tile" title="${name} · sample learned identity" aria-label="${name}" ${placement}><img class="spell" src="https://wow.zamimg.com/images/wow/icons/large/${image}.jpg" alt="${name}">${time?`<span class="time">${time}</span>`:''}</div>`;
}
function render(){
 const c=classes[active],p=profile(),sample23=active==='WARLOCK'&&p.scenario==='level23';
 const available=new Set(sample23?warlock23:c.candidates.map(x=>x[1]).filter(x=>icons[x]));
 let stage=sample23?'Leveling':p.school;
 if(active==='DRUID') stage=p.form!=='Caster'?p.form:(p.school==='Feral'?'Caster':stage);
 const scheme=plans[active][stage]||plans[active].Leveling||plans[active][schools[active][0]];
 const powerType=active==='WARRIOR'?1:active==='ROGUE'?3:active==='DRUID'&&p.form==='Bear'?1:active==='DRUID'&&p.form==='Cat'?3:0;
 const style=resourceStyles[powerType];
 $('.hud').style.setProperty('--health',healthColor);$('.hud').style.setProperty('--pet-health',petHealthColor);
 $('.hud').style.setProperty('--resource',style.color);$('.power .role').textContent=style.name;
 $('.power .value').textContent=sample23?'587':powerType===1?'75':powerType===3?'71':'3,420';
 $('.combo-bar').style.display=active==='ROGUE'||(active==='DRUID'&&p.form==='Cat')?'block':'none';
 $('.shards').textContent='Soul Shards: 24 ◆';
 const used=new Set(),main=[],dense=[0,0];
 if(p.cooldownLayout==='Forever'){
  const fixture=sample23?[]:c.alerts.filter(name=>available.has(name));
  const entries=[...new Set(fixture.filter(Boolean))].slice(0,8),left=Math.min(4,entries.length);
  entries.forEach((name,i)=>{const side=i<left?0:1;used.add(name);main.push(tile(name,'12',(side===0?-1:1)*(83+(dense[side]++)*47),dense[side]-1))});
 }else scheme.forEach((slots,side)=>slots.forEach((choices,i)=>{
  const name=choices.find(key=>available.has(key)&&!used.has(key));
  if(name){used.add(name);main.push(tile(name,'12',(side===0?-1:1)*(83+(dense[side]++)*47),dense[side]-1))}
 }));
 const primaryHTML=main.join('');if(rowHTML.get('primary')!==primaryHTML){$('.primary').innerHTML=primaryHTML;rowHTML.set('primary',primaryHTML)}
 const cooling=sample23?[]:c.alerts.filter(name=>available.has(name)&&!used.has(name)).slice(0,3);
 $('.utility').innerHTML=cooling.map((name,i)=>tile(name,String(12+i*8))).join('');
 const target=currentState==='enemy';
 $('.trackedBars').innerHTML=target?c.dots.filter(x=>available.has(x[1])).slice(0,3).map(x=>`<div class="tracked-sample"><i></i><span>${x[1]}</span><b>12</b></div>`).join(''):'';
 $('.effects').innerHTML=target?c.dots.filter(x=>available.has(x[1])).slice(0,3).map(x=>tile(x[1],'12')).join(''):'';
 $('.maintenance').innerHTML=active==='WARLOCK'?tile('Demon armor'):'';
 $('.buffs').innerHTML=sample23?'':c.buffs.slice(0,1).map(x=>tile(x[1],'8')).join('');
 const casts={WARLOCK:'Health Funnel',MAGE:'Evocation',PRIEST:'Flash Heal',DRUID:'Healing Touch',SHAMAN:'Healing Wave',PALADIN:'Holy Light'};
 $('.cast').style.display=currentState==='combat'&&casts[active]&&p.castBarMode!=='Default'?'block':'none';
 $('.cast-name').textContent=casts[active]||'';
 $('.game-cast').style.display=currentState==='combat'&&casts[active]&&p.castBarMode!=='Eclipse'?'block':'none';
 $('.game-cast div').textContent=casts[active]||'';
 $('#cast-mode').value=p.castBarMode;
 $('.stage-label').textContent=`SAMPLE ${currentState.toUpperCase()} · ${sample23?'LEVEL 23 MOCK SPELLBOOK':stage.toUpperCase()+' LEARNED FIXTURE'}`;
 $('.scenario-note').textContent=sample23?'Mock learned spells and native categories, not your captured character. Actual client categories and order determine the HUD.':'Declared school adaptation with sample training, auras and cooldowns. Not a live-client capture.';
 $('.hud').classList.toggle('collapsed',currentState!=='combat'&&(manualFold||(!manualOpen&&currentState==='idle')));
 $('.hud').dataset.state=currentState;
 document.querySelectorAll('.scenarios [data-state]').forEach(b=>b.classList.toggle('active',b.dataset.state===currentState));
 apply();
}
function state(value){
 clearTimeout(closing);manualOpen=false;manualFold=false;currentState=value;render();
 if(value==='lost')closing=setTimeout(()=>{currentState='idle';render()},5000);
}
function apply(){
 const p=profile();$('.hud').style.transform=`translateX(calc(-50% + ${p.offset[0]}px)) translateY(${p.offset[1]}px) scale(${p.scale/100})`;
 $('#scale').value=p.scale;$('#scale-value').textContent=p.scale+'%';
 document.querySelectorAll('[data-module]').forEach(x=>{
  const k=x.dataset.module;x.checked=k==='cast'?p.castBarMode!=='Default':p.modules[k];
  const selectors=k==='resources'?'.bar':k==='pet'?'.tiny,.pet-label,.shards,.combo-bar':'.'+k;
  document.querySelectorAll(selectors).forEach(el=>el.style.visibility=p.modules[k]?'visible':'hidden');
 });
}
function select(key){
 active=key;const c=classes[key],p=profile();
 document.documentElement.style.setProperty('--class',c.color);$('.hud').style.setProperty('--class',c.color);$('.hud').style.setProperty('--accent',c.accent);
 $('.chassis').src=`../src/EclipseHUD/Media/chassis-${key.toLowerCase()}.png`;
 $('.crest').src=`../src/EclipseHUD/Media/crest-${key.toLowerCase()}.png`;
 $('.class-label').textContent='';$('.side h1').textContent=c.name;
 $('.tiny').style.display=c.pet?'block':'none';$('.pet-label').style.display=c.pet?'block':'none';$('.shards').style.display=key==='WARLOCK'?'block':'none';
 $('.hp .value').textContent=key==='WARLOCK'&&p.scenario==='level23'?'83%  624':'83%  4,850';
 $('#school').innerHTML=schools[key].map(name=>`<option>${name}</option>`).join('');$('#school').value=p.school;
 $('#scenario').value=p.scenario;$('#scenario').disabled=key!=='WARLOCK';
 $('#cooldown-layout').value=p.cooldownLayout;$('#form').value=p.form;$('.form-control').hidden=key!=='DRUID';
 document.querySelectorAll('[data-class]').forEach(b=>b.classList.toggle('active',b.dataset.class===key));render();
}
$('.classes').innerHTML=Object.entries(classes).map(([key,c])=>`<button data-class="${key}">${c.name}</button>`).join('');
$('.classes').insertAdjacentHTML('afterend',`<div class="scenarios"><div>${['idle','enemy','combat','lost'].map(value=>`<button data-state="${value}">${{idle:'Idle',enemy:'Enemy target',combat:'Combat · no target',lost:'Target lost · 5s'}[value]}</button>`).join('')}</div><label>Training <select id="scenario"><option value="level23">Level 23 Warlock fixture</option><option value="learned">Learned sample</option></select></label><label>Cast bar <select id="cast-mode"><option value="Default">Default game bar</option><option value="Eclipse">Eclipse bar</option><option value="Both">Both bars</option></select></label><label>Cooldown layout <select id="cooldown-layout"><option value="Forever">Native category fixture</option><option>Class plan</option></select></label><label>School <select id="school"></select></label><label class="form-control" hidden>Form <select id="form"><option>Caster</option><option>Bear</option><option>Cat</option></select></label></div><div class="resource-key"></div><p class="scenario-note"></p>`);
const style=document.createElement('style');style.textContent=`
 .scenarios{display:flex;gap:16px;align-items:center;flex-wrap:wrap;margin-bottom:8px}.scenarios button,.scenarios select{background:#17141e;border:1px solid #39313f;border-radius:3px;color:#c7bfd3;padding:7px;font:11px system-ui}.scenarios .active{border-color:var(--class);color:var(--class)}.scenarios label{font-size:11px;color:#8b8298}.scenario-note{font-size:11px;color:#8c8299;min-height:16px;margin:8px 0 18px}.hud{top:300px}.primary{top:-72px;display:block;height:40px;z-index:5}.primary .tile{position:absolute;width:40px;height:40px;transition:transform .28s ease,opacity .28s ease;transition-delay:var(--delay)}.utility{top:43px}.utility .time{position:absolute;top:32px;font-size:11px;background:none;height:15px}.effects{top:114px}.cast{top:171.5px}.chassis,.bar,.tiny,.shards{transition:opacity .5s,transform .5s}.collapsed .primary .tile{opacity:0;transform:translateX(var(--dx));transition-delay:0s}.collapsed .chassis,.collapsed .bar,.collapsed .tiny,.collapsed .shards{opacity:0}.collapsed .hp,.collapsed .tiny{transform:translateX(138px)}.collapsed .power,.collapsed .shards{transform:translateX(-138px)}.viewport{min-height:610px}.version{white-space:nowrap}.context{font-size:10px}.tile{flex-shrink:0}@media(prefers-reduced-motion:reduce){.primary .tile,.bar,.chassis,.tiny,.shards{transition:none}}

 .trackedBars{position:absolute;left:570px;top:-23px;width:190px}.tracked-sample{position:relative;height:18px;margin-bottom:5px;background:#08090d;border:1px solid #5c526c;color:white;font-size:9px;line-height:16px}.tracked-sample i{position:absolute;inset:0 30% 0 0;background:var(--class);opacity:.6}.tracked-sample span{position:relative;margin-left:4px}.tracked-sample b{position:absolute;right:4px}
 .game-cast{display:none;position:absolute;bottom:70px;left:calc(50% - 100px);width:200px;height:18px;background:linear-gradient(90deg,#987026 65%,#08090d 65%);border:1px solid #b5a173;color:white;text-align:center;font-size:10px;line-height:16px}.game-cast span{position:absolute;top:-18px;left:0;width:200px;color:#aaa;font-size:9px}
 .maintenance{position:absolute;left:-40px;top:-23px;display:flex;gap:6px}.maintenance .tile{width:20px;height:20px;flex-basis:20px}.maintenance .spell{width:100%;height:100%}.class-label{display:none}
 .hp .fill{background:var(--health);box-shadow:none}.power .fill{background:var(--resource);opacity:1}
 .bar .role{left:4px;right:auto;font:9px system-ui;line-height:13px;color:#fff;text-shadow:0 1px 2px #000,1px 0 #000}
 .bar .value{font:9px system-ui;line-height:13px;color:#fff;text-shadow:0 1px 2px #000,1px 0 #000}
 .tiny .fill{background:var(--pet-health);opacity:1}.tiny .value{position:absolute;right:4px;top:-2px;font:8px system-ui;color:#fff;text-shadow:0 1px 2px #000}
 .pet-label{display:block;top:8px;left:32px;font:8px system-ui;color:#fff;z-index:4;text-shadow:0 1px 2px #000}.shards{font:9px system-ui;z-index:4}
 .combo-bar{position:absolute;left:206px;top:152.5px;width:100px;height:5px;background:#04050a;z-index:4}
 .combo-bar .fill{background:${resourceStyles[4].color}}.combo-bar span{position:absolute;right:4px;top:-4px;font:10px system-ui;color:#fff;text-shadow:0 1px 2px #000}
 .collapsed .combo-bar,.collapsed .pet-label{opacity:0}.resource-key{display:flex;gap:16px;margin-top:12px;font-size:10px;color:#aaa3b6}
 .resource-key i{display:inline-block;width:8px;height:8px;margin-right:5px;border-radius:2px}.form-control[hidden]{display:none}
`;document.head.appendChild(style);
$('.resource-key').innerHTML=[['Health',healthColor],...[0,3,1,2].map(id=>[resourceStyles[id].name,resourceStyles[id].color])].map(([name,color])=>`<span><i style="background:${color}"></i>${name}</span>`).join('');
document.querySelectorAll('[data-class]').forEach(b=>b.onclick=()=>select(b.dataset.class));
document.querySelectorAll('.scenarios [data-state]').forEach(b=>b.onclick=()=>state(b.dataset.state));
document.querySelectorAll('[data-module]').forEach(x=>x.onchange=()=>{profile().modules[x.dataset.module]=x.checked;if(x.dataset.module==='cast')profile().castBarMode=x.checked?'Eclipse':'Default';render()});
$('#school').onchange=e=>{profile().school=e.target.value;render()};
$('#cast-mode').onchange=e=>{profile().castBarMode=e.target.value;profile().modules.cast=e.target.value!=='Default';render()};
$('#cooldown-layout').onchange=e=>{profile().cooldownLayout=e.target.value;render()};
$('#form').onchange=e=>{profile().form=e.target.value;render()};
$('#scenario').onchange=e=>{profile().scenario=e.target.value;select(active)};
$('#scale').oninput=e=>{profile().scale=+e.target.value;apply()};
$('#reset').onclick=()=>{delete profiles[active];select(active)};
$('.crest').onclick=()=>{if(drag?.moved||currentState==='combat')return;clearTimeout(closing);const folded=$('.hud').classList.contains('collapsed');manualOpen=folded;manualFold=!folded;render()};
let drag;$('.crest').onpointerdown=e=>{drag={x:e.clientX,y:e.clientY,offset:[...profile().offset]};e.target.setPointerCapture(e.pointerId)};
$('.crest').onpointermove=e=>{if(drag){if(Math.abs(e.clientX-drag.x)+Math.abs(e.clientY-drag.y)>4)drag.moved=true;profile().offset=[drag.offset[0]+e.clientX-drag.x,drag.offset[1]+e.clientY-drag.y];apply()}};
$('.crest').onpointerup=()=>{setTimeout(()=>{drag=null},0)};
select(active);state(params.get('state')||'idle');
</script></html>'''
target=ROOT/'preview/index.html'
catalog={key:dict(value,candidates=candidates(key),alerts=[name for seed,name in candidates(key) if seed in dict(ALERTS[key])]) for key,value in CLASSES.items()}
# Order matters: PET_HEALTH_FILL contains HEALTH_FILL, so it is replaced first.
replacements=[('CATALOG',json.dumps(catalog,ensure_ascii=False)),
    ('ICONS',(ROOT/'preview/spell-icons.json').read_text(encoding='utf-8')),
    ('PLANS',json.dumps(PLANS)),('SCHOOLS',json.dumps(SCHOOLS)),('VERSION_LABEL','v'+VERSION),
    ('RESOURCE_PALETTE',json.dumps(RESOURCE_STYLES)),('PET_HEALTH_FILL',json.dumps(PET_HEALTH_COLOR)),
    ('HEALTH_FILL',json.dumps(HEALTH_COLOR))]
html=HTML
for token,value in replacements: html=html.replace(token,value)
target.write_text(html,encoding='utf-8',newline='\n')
print(target)
