dofile('tests/core.lua')
local E=EclipseHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/EclipseHUD/Discovery.lua'))('EclipseHUD',E)
local now,combat=0,true
function GetTime()return now end
function UnitAffectingCombat()return combat end
function UnitIsDeadOrGhost()return false end
E.state={world=true,Preview=function()return false end}
local played,removed,registered={},{},{}
function PlaySoundFile(file)played[#played+1]=file;return true,#played end
function StopSound()end
C_Timer.NewTimer=function(delay,fn)return {delay=delay,callback=fn,Cancel=function(self)self.cancelled=true end}end
Enum={UnitAuraSoundTrigger={Added=1}}
C_UnitAuras={AddAuraSound=function(event,config)
    check(event==1 and config.spellID==101,'Activation registration is native Added with learned identity')
    registered[#registered+1]=config;return #registered
end,RemoveAuraSound=function(id)removed[#removed+1]=id end}
E.effectSpells={WARLOCK={major={101,999}}}
E.discovery.Resolve=function(id)if id==101 then return {id=101,name='Learned'}end end
E.discovery.eligible={low={id=101},high={id=102}}
assert(loadfile('src/EclipseHUD/Alerts.lua'))('EclipseHUD',E)
E.Profile().alerts=true;E.RefreshAlerts()
local A=E.alerts
E.ReadyAlert('low',101,10);check(#A.queue==0,'Initial one-second suppression')
now=1.1;A.nativeTimer.callback()
check(#registered==1,'Unlearned aura activation is not registered')
E.ReadyAlert('low',101,10);local timer=A.timer
E.ReadyAlert('high',102,90)
check(A.timer==timer and timer.delay==.06 and #A.queue==2,'60ms window coalesces simultaneous ready events')
check(A.queue[1].id=='high','Priority ordering')
E.ReadyAlert('low',101,10);check(#A.queue==2,'Two-second ready deduplication')
timer.callback();check(#played==1 and #A.queue==1,'One ready chime at a time')
now=1.2;A.timer.callback();check(#played==1,'Chime duration prevents overlapping ready playback')
now=6;A.timer.callback();check(#played==1 and #A.queue==0,'Four-second queue lifetime discards stale alerts')
combat=false;E.ReadyAlert('low',101,10);check(#A.queue==0,'Ready alerts require confirmed combat')
combat=true;E.ReadyAlert('low',101,10);timer=A.timer
A.events.scripts.OnEvent(nil,'PLAYER_REGEN_ENABLED')
check(timer.cancelled and #A.queue==0,'Leaving combat cancels pending ready audio')
E.StopAlerts();check(#removed==1 and not A.active and not next(A.events.events),'Stop removes native aura sounds and observers')
E.class='WARRIOR';E.discovery.Resolve=function(id)return {id=id}end
GetShapeshiftForm=function()return 3 end
check(A.Interrupt()==6552,'Berserker stance chooses learned Pummel')
GetShapeshiftForm=function()return 1 end
GetInventoryItemID=function()return 1 end
C_Item={GetItemInfoInstant=function()return 1,'Armor','Shield','INVTYPE_SHIELD',1,4,6 end}
check(A.Interrupt()==72,'Equipped shield chooses learned Shield Bash outside Berserker stance')
GetInventoryItemID=function()return nil end
check(A.Interrupt()==nil,'No valid stance/shield does not fabricate an interrupt source')
print('Audio scheduling checks passed: '..checks)
