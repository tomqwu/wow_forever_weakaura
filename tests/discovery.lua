-- Regressions for reported leveling/localized/placeholder failures. Mock client.
dofile("tests/core.lua")
local E=ForeverHUD
local checks=0
local function check(v,m) checks=checks+1; assert(v,m) end
local secret=setmetatable({}, {__tostring=function() error("secret inspected") end})
function issecretvalue(v) return rawequal(v,secret) end
local combat=false
function InCombatLockdown() return combat end
local flags, timers={},{}
ForeverAuras.SetLoadFlag=function(k,v) flags[k]=v end
C_Timer.NewTimer=function(delay,fn)
    local t={delay=delay,callback=fn,Cancel=function(self)self.cancelled=true end}
    timers[#timers+1]=t; return t
end
Enum={SpellBookSpellBank={Player=0},CooldownViewerCategory={Essential=0,TrackedBuff=2}}
local chinese=false
local function name(en,zh) return chinese and zh or en end
local trained={[101]=true,[102]=true,[201]=true,[401]=true,[701]=true}
local items={
    {spellID=101,actionID=101,isPassive=false,isOffSpec=false},
    {spellID=102,actionID=102,isPassive=false,isOffSpec=false},
    {spellID=202,baseSpellID=201,isPassive=false,isOffSpec=false},
    {spellID=301,actionID=301,isPassive=false,isOffSpec=false}, -- metadata exists, untrained
    {spellID=401,actionID=401,isPassive=true,isOffSpec=false},
    {spellID=701,actionID=701,isPassive=false,isOffSpec=false}, -- question mark
}
C_SpellBook={
    GetNumSpellBookSkillLines=function() return 1 end,
    GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=#items} end,
    GetSpellBookItemInfo=function(i) return items[i] end,
    GetSpellBookItemLevelLearned=function(i) return i==2 and 22 or 1 end,
    IsSpellKnown=function(id) return trained[id]==true end,
}
local info={
    [100]={"Corruption","腐蚀术"},[101]={"Corruption","腐蚀术"},[102]={"Corruption","腐蚀术"},
    [200]={"Fear","恐惧术"},[201]={"Fear","恐惧术"},[202]={"Override Fear","强化恐惧术"},
    [301]={"Untrained","未学技能"},[401]={"Passive","被动"},[501]={"Proc","触发"},
    [601]={"Unresolved","未知"},[701]={"Placeholder","占位"},[801]={"Restricted","受限"},
}
C_Spell={GetSpellInfo=function(id)
    local row=info[id]; if not row then return end
    return {name=id==801 and secret or name(row[1],row[2]),iconID=id==701 and 134400 or 12345}
end,RequestLoadSpellData=function()end}
C_CooldownViewer={
    GetCooldownViewerCategorySet=function(category,allowUnlearned)
        assert(allowUnlearned==false,"Must request learned CDM identities")
        return category==2 and {50,60} or {}
    end,
    GetCooldownViewerCooldownInfo=function(id)
        return {spellID=id==50 and 501 or 601,isKnown=id==50,linkedSpellIDs={}}
    end,
}
E.catalog={}
for _,row in ipairs({{"rank",100,"ability"},{"override",200,"ability"},{"untrained",301,"ability"},
    {"passive",401,"ability"},{"proc",501,"aura"},{"badproc",601,"aura"},{"question",701,"ability"},{"secret",801,"aura"}}) do
    E.catalog[row[1]]={cls="WARLOCK",module="primary",seeds={row[2]},kind=row[3],flag=row[1]}
end
E.Set("enabled",true); E.Set("primary",true)
assert(loadfile("src/ForeverHUD/Discovery.lua"))("ForeverHUD",E)
local D=E.discovery
D.Refresh()
check(D.eligible.rank.id==102,"Highest learned rank selected, not seed metadata")
check(D.Resolve(101,'ability').id==102,'Known rank-one ID still resolves highest learned rank')
local first,second=items[1],items[2]
items[1],items[2]=second,first
C_SpellBook.GetSpellBookItemLevelLearned=function(i)return items[i].spellID==102 and 22 or 1 end
D.Refresh();check(D.eligible.rank.id==102,'Spellbook order cannot downgrade discovered rank')
items[1],items[2]=first,second
check(D.eligible.override.id==202,"Learned base validates actual override")
check(not D.eligible.untrained,"Available level/metadata never proves training")
check(not D.eligible.passive,"Passive must not become castable action")
check(D.eligible.proc.id==501 and not D.eligible.badproc,"Proc needs learned native identity")
check(not flags.question and not flags.secret,"Question-mark and restricted metadata unload")
chinese=true; D.Refresh()
check(D.eligible.rank.name=="腐蚀术" and D.eligible.override.name=="强化恐惧术","Numeric seeds match localized names and bases")
trained[103]=true; info[103]={"Corruption","腐蚀术"}
items[#items+1]={spellID=103,actionID=103,isPassive=false,isOffSpec=false}
C_SpellBook.GetSpellBookItemLevelLearned=function(i)return i==#items and 30 or i==2 and 22 or 1 end
D.events.scripts.OnEvent(nil,"SPELLS_CHANGED"); local timer=D.timer
D.events.scripts.OnEvent(nil,"SPELLS_CHANGED")
check(D.timer==timer,"Learning events coalesce")
timer.callback(); check(D.eligible.rank.id==103,"New learned rank discovered without reimport")
combat=true; D.Schedule(); check(D.pending and not D.timer,"No combat spell discovery")
combat=false; D.Schedule(); timer=D.timer; D.Stop()
check(timer.cancelled and not D.timer and not next(D.eligible),"Stop cancels scheduled work and forgets identities")
check(not flags.rank,"Stop unloads spell trackers")
D.Start(); check(D.events.events.SPELLS_CHANGED and D.timer,"Resume registers learning events")
E.Set("enabled",false)
check(D.stopped and not D.events.events.SPELLS_CHANGED and not flags.rank,"Disable unregisters and unloads")
E.catalog.trim={cls='WARLOCK',module='fx',requires='resources',seeds={501},kind='aura',flag='trim'}
E.Set('enabled',true);E.Set('resources',true);D.Refresh()
check(flags.trim,'Qualified resource trim loads with resources enabled')
E.Set('resources',false)
check(not flags.trim and E.Profile().fx,'Resources off unloads trim without disabling other FX')
-- The native provider's arranged data must override raw API categories/order.
combat=false;D.stopped=false
Enum.CooldownViewerCategory={Essential=0,Utility=1,TrackedBuff=2,HiddenActive=-1,EquipSlotEssential=4}
local arranged={
    [10]={spellID=100,isKnown=true,category=0},[11]={spellID=200,isKnown=true,category=1},
    [12]={spellID=301,isKnown=true,category=-1},[13]={spellID=401,isKnown=false,category=0},
    [14]={spellID=501,isKnown=true,isInvisible=true,category=0},
    [15]={isKnown=true,equipSlot=13,category=4},
}
local provider={GetOrderedCooldownIDsForCategory=function(_,category,unknown)
    assert(unknown==false)
    return ({[0]={13,14,10},[1]={11},[-1]={12},[4]={15}})[category] or {}
end,GetCooldownInfoForID=function(_,id)return arranged[id]end}
CooldownViewerSettings={GetDataProvider=function()return provider end}
D.ScanCDM()
check(D.cdmReady and D.cdmOrder.Essential[1]==10 and #D.cdmOrder.Essential==1,'Native saved order filters unlearned/invisible identities')
check(D.cdm[11].category=='Utility' and D.cdm[12].category=='HiddenActive','Provider placement overrides raw default categories')
check(D.cdm[15].item and D.cdm[15].category=='EquipSlotEssential','Native equipped items need no guessed spell identity')
local callback,removed
EventRegistry={RegisterCallback=function(_,event,fn,owner)callback={event=event,fn=fn,owner=owner}end,
    UnregisterCallback=function(_,event,owner)removed=event=='CooldownViewerSettings.OnDataChanged' and owner==D end}
D.stopped=true;D.Start()
check(callback.event=='CooldownViewerSettings.OnDataChanged','Native layout edits register a refresh callback')
callback.fn();check(D.timer~=nil,'Native layout edits schedule a coalesced refresh')
D.Stop();check(removed and not D.layoutCallback and not D.timer,'Disable cancels layout callback and pending discovery')
CooldownViewerSettings=nil;EventRegistry=nil
print("Spell discovery checks passed: "..checks)
