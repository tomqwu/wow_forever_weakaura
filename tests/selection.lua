dofile('tests/core.lua')
local E=EclipseHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/EclipseHUD/Catalog.lua'))('EclipseHUD',E)
assert(loadfile('src/EclipseHUD/Discovery.lua'))('EclipseHUD',E)
assert(loadfile('src/EclipseHUD/Selection.lua'))('EclipseHUD',E)
local S,D=E.selection,E.discovery
local frames={}
ForeverAuras.GetRegion=function(id)
    frames[id]=frames[id] or {SetOffset=function(self,x,y)self.x,self.y=x,y end}
    return frames[id]
end
local function loadout(class,names)
    UnitClass=function()return class,class end
    E.InitDB(); E.Profile().school='Auto'; E.Profile().cleave=false
    local allowed={};for _,name in ipairs(names)do allowed[name]=true end
    D.eligible={}
    for id,entry in pairs(E.catalog)do
        if entry.cls==class and allowed[entry.key]then
            D.eligible[id]={id=entry.seeds[1],name=entry.key}
        end
    end
    S.Refresh()
end
local function selected(name)
    return S.positions['Eclipse | '..E.classNames[E.class]..' | Primary | '..name]
end
loadout('WARLOCK',{'Shadow Bolt','Corruption','Immolate','Drain Life','Drain Soul','Life Tap','Fear','Health Funnel'})
check(selected('Shadow Bolt') and selected('Corruption') and selected('Immolate'),'Leveling learned attacks fill main row')
check(selected('Life Tap').side==1 and selected('Shadow Bolt').side==2,'Two-sided functional hierarchy')
check(not selected('Conflagrate'),'No untrained maximum-level slot')
check(selected('Drain Life') and not selected('Drain Soul'),'Learned slot fallback has stable priority')
for id,entry in pairs(E.catalog) do
    if entry.cls=='WARLOCK' and entry.prep then check(not S.Allowed(id,entry),'Preparation excluded') end
    if entry.cls=='WARLOCK' and entry.key=='Fear' and entry.module=='utility' then check(not S.Allowed(id,entry),'Main ability absent from secondary') end
end
loadout('WARRIOR',{'Bloodrage','Retaliation','Shield Wall','Berserker Rage','Heroic Strike','Rend','Overpower','Thunder Clap','Sunder Armor'})
check(S.stage=='Leveling' and selected('Heroic Strike').slot==1,'Warrior leveling source fallback')
E.Profile().school='Arms';S.Refresh()
check(S.stage=='ArmsEarly' and selected('Thunder Clap').slot==3,'Early Arms source fallback')
loadout('WARRIOR',{'Bloodrage','Retaliation','Shield Wall','Mortal Strike','Overpower','Slam','Rend','Sweeping Strikes'})
check(S.stage=='Arms' and selected('Mortal Strike').slot==1 and selected('Slam').slot==3,'Learned Arms capstone plan')
loadout('WARRIOR',{'Death Wish','Recklessness','Bloodrage','Shield Wall','Bloodthirst','Whirlwind','Execute','Heroic Strike','Cleave'})
check(S.stage=='Fury' and selected('Heroic Strike').slot==4,'Fury source plan')
E.Profile().cleave=true;S.Refresh()
check(selected('Cleave').slot==4 and not selected('Heroic Strike'),'Manual Fury Cleave replaces Heroic Strike')
loadout('WARRIOR',{'Shield Slam','Revenge','Shield Block','Shield Wall','Last Stand','Bloodrage','Thunder Clap','Sunder Armor'})
check(S.stage=='Protection' and selected('Shield Slam').side==2 and selected('Shield Block').side==1,'Protection source plan')
C_ClassTalents={GetActiveConfigID=function()return 1 end}
C_Traits={GetConfigInfo=function()return {treeIDs={1}} end,
    GetTreeNodes=function()return {1,2,3,4,5,6}end,
    GetNodeInfo=function(_,id)return {posX=({0,10,100,110,200,210})[id],ranksPurchased=id==4 and 5 or 0}end}
check(S.TalentSchool()=='Fury','Invested talent points choose school, not class artwork')
for class,schools in pairs(E.schools)do
    loadout(class,{})
    for _,school in ipairs(schools)do E.Profile().school=school;S.Refresh();check(S.mode==school,'Every class has three manual plans')end
end
local data={triggers={{trigger={cdmSpells={multi={}}}}}}
local buffData={triggers={{trigger={cdmSpells={multi={}}}}}}
local writes=0
ForeverAuras.GetData=function(id)return id:find('Native player effects',1,true) and buffData or data end
ForeverAuras.Add=function(new)writes=writes+1;if new.triggers[1].trigger.cdmSpells.multi[102] then buffData=new else data=new end end
D.cdm={[100]={name='Native extra',category='Essential',identities={}},[101]={name='Summon',category='Utility',identities={[698]=true}},[102]={name='Buff',category='TrackedBuff',identities={}}}
S.SyncCDM()
check(data.triggers[1].trigger.cdmSpells.multi[100] and not data.triggers[1].trigger.cdmSpells.multi[101],'Native learned combat overflow excludes preparation')
check(buffData.triggers[1].trigger.cdmSpells.multi[102],'Additional learned tracked buffs/counters use native CDM')
S.SyncCDM();check(writes==2,'Unchanged CDM selections do not rewrite imports')
ForeverAuras.GetData=nil
UnitPowerType=function()return 3 end
loadout('DRUID',{"Tiger's Fury",'Barkskin','Shred','Claw','Rake','Rip','Faerie Fire','Maul','Bash','Frenzied Regeneration'})
check(S.stage=='Cat' and selected('Shred') and not selected('Maul'),'Energy form selects learned cat skills')
UnitPowerType=function()return 1 end
InCombatLockdown=function()return true end
D.events.scripts.OnEvent(nil,'UPDATE_SHAPESHIFT_FORM')
check(S.stage=='Bear' and selected('Maul') and not selected('Shred'),'Combat form switch reuses learned identities and switches native flags')
check(D.pending,'Combat form switch defers spellbook/CDM rediscovery')
local id='Eclipse | Druid | Primary | Maul'
local late={SetOffset=function(self,x,y)self.x,self.y=x,y end}
ForeverAuras.GetRegion=function(key)if key==id then return late end end
E.BindAbility(id);local layout=S.layoutTimer;E.BindAbility(id)
check(layout and S.layoutTimer==layout,'Late native region init coalesces layout after registration')
layout.callback();check(late.x==S.positions[id].x,'Newly eligible ability receives slot position after load scan')
print('Ability selection checks passed: '..checks)
