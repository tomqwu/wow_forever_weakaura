dofile('tests/core.lua')
local E=ForeverHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local combat,exists,attack,dead,playerDead,preview=false,false,false,false,false,false
local secret={}
function issecretvalue(v)return rawequal(v,secret)end
function UnitExists()return exists end
function UnitCanAttack()return attack end
function UnitIsDeadOrGhost(unit)return unit=='player' and playerDead or dead end
function InCombatLockdown()return combat end
ForeverAuras.IsOptionsOpen=function()return preview end
C_Timer.NewTimer=function(delay,callback)return {delay=delay,callback=callback,Cancel=function(self)self.cancelled=true end}end
assert(loadfile('src/ForeverHUD/Discovery.lua'))('ForeverHUD',E)
assert(loadfile('src/ForeverHUD/State.lua'))('ForeverHUD',E)
local S=E.state
E.Reset();E.Set('castBarMode','ForeverHUD');S.Start()
check(not S.Visible() and E.Gate('art','WARLOCK') and not E.Gate('resources','WARLOCK'),'Compact idle retains emblem, folds resources')
check(E.Gate('cast','WARLOCK') and not E.Gate('buffs','WARLOCK') and E.Gate('tray','WARLOCK'),'Casting keeps its own rule; folded, the tray replaces the buff rows (0.8)')
exists=true;attack=true;S.Update(false)
check(S.open and S.Visible() and E.Gate('primary','WARLOCK'),'Living hostile target opens primary')
exists=false;S.Update(false);local close=S.closeTimer
check(close and close.delay==5 and S.open,'Target loss has exact five-second hold')
exists=true;S.Update(false)
check(close.cancelled and not S.closeTimer and S.open,'Reacquisition cancels close')
exists=false;S.Update(false);S.closeTimer.callback()
check(not S.open and not S.Visible(),'Hold expiration closes idle')
combat=true;S.Update(false);check(S.open,'Combat entry opens without target')
combat=false;E.Profile().expandCombat=false;S.Update(true);combat=true;S.Update(false)
check(not S.open,'Combat expansion is independently optional')
combat=false;exists=true;attack=false;S.Update(false);check(not S.open,'Friendly target does not open')
attack=true;dead=true;S.Update(false);check(not S.open,'Dead target does not open')
dead=secret;S.Update(false);check(not S.open,'Restricted target death never treated as living')
dead=false;exists=secret;S.Update(false);check(not S.open,'Restricted target existence rejected')
exists=false;S.Inspect();check(S.open and S.inspectTimer.delay==10,'Inspection opens temporarily')
S.inspectTimer.callback();check(S.closeTimer,'Inspection releases into normal close delay')
playerDead=true;S.Update(false);check(not S.open and not S.closeTimer,'Death cancels hold and folds')
playerDead=false;preview=true;S.Update(false);check(S.open,'Editor preview expands silently')
preview=false;S.Update(false);check(not S.open,'Returning to live mode clears preview expansion')
exists=true;S.Update(false);S.events.scripts.OnEvent(nil,'LOADING_SCREEN_ENABLED')
check(not S.open,'Loading suspends layout')
S.events.scripts.OnEvent(nil,'LOADING_SCREEN_DISABLED');check(S.open,'Loading return restores actual target')
exists=false;S.Update(false);close=S.closeTimer;S.Stop()
check(close.cancelled and not S.world and not S.Visible(),'World leave cancels timers and visibility')
check(not next(S.events.events),'Stop unregisters state listeners')
E.Notify();E.ApplyLayout()
check(not E.Gate('base','WARLOCK') and not E.handle.shown,'Late layout/notifications cannot restore world-leave controls')
S.Start();exists=false;combat=false;E.Profile().expandCombat=true
local changes={}
E.motion={Change=function(open,silent)changes[#changes+1]={open=open,silent=silent}end,Stop=function()end}
S.events.scripts.OnEvent(nil,'PLAYER_REGEN_DISABLED')
check(S.open and changes[#changes].open and not S.closeTimer,'Combat entry starts opening in the event callback even before lockdown changes')
combat=true;S.events.scripts.OnEvent(nil,'PLAYER_REGEN_ENABLED')
check(not S.open and not changes[#changes].open and not S.closeTimer,'Combat exit begins folding immediately without the five-second hold')
exists=true;attack=true;dead=false;combat=false
S.events.scripts.OnEvent(nil,'PLAYER_REGEN_DISABLED');S.events.scripts.OnEvent(nil,'PLAYER_REGEN_ENABLED')
check(S.open,'Independent living hostile-target condition remains after combat')
exists=false;S.events.scripts.OnEvent(nil,'PLAYER_TARGET_CHANGED')
check(S.closeTimer and S.closeTimer.delay==5,'Only target loss keeps the source five-second hold')
local hold=S.closeTimer;S.events.scripts.OnEvent(nil,'PLAYER_REGEN_DISABLED')
check(hold.cancelled and not S.closeTimer and S.open,'Immediate combat entry cancels a pending target-loss hold')
S.Stop()
-- Exercise the actual center-button callback, not a replacement UI fixture.
combat=false;exists=false;preview=false;playerDead=false;S.Start()
E.handle.scripts.OnClick(E.handle,'LeftButton')
check(S.open and S.inspected and not S.inspectTimer and E.utilityPinned,'First click pins an out-of-combat expansion without a timeout')
E.handle.scripts.OnClick(E.handle,'LeftButton')
check(not S.open and not S.inspected and not S.closeTimer and not E.utilityPinned,'Second click folds immediately with no inspection/close timer')
exists=true;attack=true;dead=false;S.events.scripts.OnEvent(nil,'PLAYER_TARGET_CHANGED')
E.handle.scripts.OnClick(E.handle,'LeftButton');S.Update(false)
check(not S.open and S.manualFold,'Manual fold remains closed with the same hostile target')
S.events.scripts.OnEvent(nil,'PLAYER_TARGET_CHANGED')
check(S.open and not S.manualFold,'A new target restores automatic expansion')
E.handle.scripts.OnClick(E.handle,'LeftButton');S.events.scripts.OnEvent(nil,'PLAYER_REGEN_DISABLED')
check(S.open and not S.manualFold,'Combat entry overrides an out-of-combat manual fold immediately')
combat=false;S.events.scripts.OnEvent(nil,'PLAYER_REGEN_ENABLED');exists=false;S.Update(true)
S.Inspect();local inspection=S.inspectTimer
E.handle.scripts.OnClick(E.handle,'LeftButton')
check(inspection.cancelled and not S.inspectTimer and not S.open,'Click can cancel slash-command temporary inspection')
S.Stop()
print('HUD state checks passed: '..checks)
