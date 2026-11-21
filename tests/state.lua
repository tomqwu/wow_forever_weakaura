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
-- 0.14.18: Stay folded keeps the folded seal and tray in combat and with a
-- hostile target; a seal click (inspection) still opens it.
combat=false;E.Profile().expandCombat=true;E.Profile().stayFolded=true;S.Update(true)
combat=true;exists=true;attack=true;S.Update(false)
check(not S.open and E.Retracted() and E.Gate('tray','WARLOCK') and not E.Gate('primary','WARLOCK'),'Stay folded: combat and a hostile target keep the folded HUD')
S.Inspect();check(S.open,'Stay folded: a seal click still opens the HUD')
S.inspectTimer.callback();S.closeTimer.callback();check(not S.open,'Stay folded: it folds again afterwards')
E.Profile().stayFolded=false;S.Update(false);check(S.open,'Turning Stay folded off restores automatic expansion')
combat=false;exists=false;S.Update(true);E.Profile().expandCombat=false
-- 0.14.19: with Stay folded and the mini layout in place, combat shows the
-- small wings and suggestions around the folded seal; cues by the bars and
-- the bars themselves stay hidden. The combat edge re-runs the gates.
do
    E.selection={mini=true}
    E.Profile().stayFolded=true;S.Update(true)
    local notified=E.perf.notify
    S.events.scripts.OnEvent(nil,'PLAYER_REGEN_DISABLED');combat=true
    check(E.perf.notify>notified,'Stay folded: combat entry re-runs the gates')
    check(not S.open and E.Mini() and E.Gate('primary','WARLOCK') and E.Gate('suggest','WARLOCK') and E.Gate('tray','WARLOCK'),
        'Mini: folded in combat, the wings, suggestions and tray show')
    check(not E.Gate('cue','WARLOCK') and not E.Gate('resources','WARLOCK') and not E.Gate('buffs','WARLOCK'),'Mini: cues, bars and buff rows stay hidden')
    -- 0.14.22: only the left (damage) wing; the right wing waits for the expanded HUD.
    E.selection.RightWing=function(id) return id=='right' end
    check(not E.Gate('rightWing','WARLOCK') and not E.WingShown('right') and E.WingShown('left'),'Mini: the right wing stays hidden')
    S.Inspect()
    check(S.open and E.Gate('rightWing','WARLOCK') and E.WingShown('right'),'Expanded: the right wing shows again')
    S.inspected=false;S.Update(false,true)
    E.selection.mini=false
    check(not E.Mini() and not E.Gate('primary','WARLOCK') and not E.Gate('suggest','WARLOCK'),'Without the mini layout in place nothing extra shows')
    E.selection.mini=true
    S.events.scripts.OnEvent(nil,'PLAYER_REGEN_ENABLED');combat=false
    check(not E.Mini() and not E.Gate('primary','WARLOCK') and not E.Gate('suggest','WARLOCK'),'Mini: out of combat only the folded seal and tray')
    E.Profile().stayFolded=false
    check(E.Gate('cue','WARLOCK')==E.Gate('suggest','WARLOCK'),'Without Stay folded a cue follows the suggest gate')
    E.selection=nil;S.Update(true)
end
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
-- 0.9.4 hover peek: the folded seal shows a faint ghost of the whole HUD.
do
    local alphas={}
    local root={SetRegionAlpha=function(_,a)alphas[#alphas+1]=a end}
    local oldRegion,oldData=ForeverAuras.GetRegion,ForeverAuras.GetData
    ForeverAuras.GetRegion=function()return root end
    ForeverAuras.GetData=function()return nil end
    combat=false;exists=false;S.inspected=false;S.manualFold=false;S.Update(true)
    local opacity=E.Profile().opacity
    check(not S.open,'Folded before hovering')
    E.Hover(true)
    check(E.peeking and S.open and math.abs(alphas[#alphas]-opacity*E.PEEK_ALPHA)<1e-9,'Hovering the folded seal opens a faint ghost')
    -- Leaving starts a short grace timer; its end ends the peek (SetPeek(false)).
    E.Hover(false)
    check(E.peeking,'The ghost stays during the short leave grace')
    E.SetPeek(false)
    check(not E.peeking and not S.open and not S.closeTimer and alphas[#alphas]==opacity,'Leaving folds straight back at full opacity')
    E.Hover(true)
    E.handle.scripts.OnClick(E.handle,'LeftButton')
    check(not E.peeking and S.open and S.inspected and alphas[#alphas]==opacity,'Clicking the ghost opens the HUD for real')
    E.handle.scripts.OnClick(E.handle,'LeftButton');E.Hover(false);E.SetPeek(false)
    check(not S.open,'A second click folds it again')
    E.Hover(true)
    E.events.scripts.OnEvent(nil,'PLAYER_REGEN_DISABLED')
    check(not E.peeking and alphas[#alphas]==opacity,'Combat start drops the ghost to full opacity')
    combat=true;E.SetPeek(false);E.Hover(false)
    E.SetPeek(true)
    check(not E.peeking,'No peek in combat')
    combat=false
    ForeverAuras.GetRegion,ForeverAuras.GetData=oldRegion,oldData
end
-- 0.14.20: the click button follows the seal that shows (the Globes open seal
-- sits above the rail at y=76), and Stay folded has no hover peek.
do
    local root={SetRegionAlpha=function()end}
    local oldRegion,oldData=ForeverAuras.GetRegion,ForeverAuras.GetData
    ForeverAuras.GetRegion=function()return root end
    ForeverAuras.GetData=function()return nil end
    combat,exists,attack=false,false,false;S.inspected=false;S.manualFold=false;S.Update(true)
    E.selection={sealY=76}
    local p=E.Profile()
    local function handleY()return E.handle.point[5]-p.y/p.scale end
    E.Notify()
    check(not S.open and handleY()==13,'Folded: the button is on the folded seal')
    E.Hover(true)
    check(E.peeking and S.open and handleY()==13,'Peeking: the button stays under the cursor')
    E.handle.scripts.OnClick(E.handle,'LeftButton')
    check(S.open and not E.peeking and handleY()==76,'Opened: the button moves onto the raised seal')
    E.handle.scripts.OnClick(E.handle,'LeftButton')
    check(not S.open and handleY()==13,'A single click on the raised seal folds the HUD')
    E.Hover(false);E.SetPeek(false)
    p.stayFolded=true
    E.Hover(true)
    check(not E.peeking and not S.open,'Stay folded: hovering does not open the ghost')
    -- 0.14.21: nor does a click; it says why instead.
    local hints={};UIErrorsFrame={AddMessage=function(_,text)hints[#hints+1]=text end}
    E.handle.scripts.OnClick(E.handle,'LeftButton')
    check(not S.open and handleY()==13 and #hints==1 and hints[1]:find('Stay folded is on',1,true),'Stay folded: a click does not expand; it shows the hint')
    check(S.ToggleInspect()==false and not S.open and #hints==2,'Stay folded: every toggle (minimap, broker) refuses with the hint')
    -- An HUD opened another way (/fhud inspect) still folds on a click, with no hint.
    S.Inspect();check(S.open,'Stay folded: /fhud inspect still opens it')
    E.handle.scripts.OnClick(E.handle,'LeftButton')
    check(not S.open and #hints==2,'Stay folded: a click folds an opened HUD')
    UIErrorsFrame=nil
    E.Hover(false);E.SetPeek(false);p.stayFolded=false;E.selection=nil
    ForeverAuras.GetRegion,ForeverAuras.GetData=oldRegion,oldData
end
-- 0.13.19: bursts of unit-flag, faction and target events that change
-- nothing skip the full HUD update; settings changes still notify.
exists,attack,dead,combat,preview=false,false,false,false,false
S.Stop();S.Start();S.Update(false)
local notifies,skips=E.perf.notify,E.perf.skipped
for _=1,20 do S.events.scripts.OnEvent(nil,'UNIT_FLAGS','player') end
S.events.scripts.OnEvent(nil,'PLAYER_TARGET_CHANGED')
check(E.perf.notify==notifies and E.perf.skipped==skips+21 and not S.open,'Unchanged folded events skip the HUD update')
E.Set('unfoldSound',not E.Profile().unfoldSound)
check(E.perf.notify>notifies,'A settings change still updates the HUD')
notifies=E.perf.notify
exists=true;attack=false;S.events.scripts.OnEvent(nil,'PLAYER_TARGET_CHANGED')
S.events.scripts.OnEvent(nil,'UNIT_FLAGS','target')
check(E.perf.notify==notifies and not S.open,'A friendly target changes nothing shown: skipped')
attack=true;S.events.scripts.OnEvent(nil,'UNIT_FLAGS','target')
check(E.perf.notify>notifies and S.open,'A target turning hostile still opens and updates the HUD')
notifies=E.perf.notify;S.Update(true)
check(E.perf.notify>notifies,'Explicit silent updates still notify')
exists=false;S.Update(true)
S.Stop()
print('HUD state checks passed: '..checks)
