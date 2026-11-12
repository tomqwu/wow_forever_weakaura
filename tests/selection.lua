dofile('tests/core.lua')
local E=ForeverHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/ForeverHUD/Catalog.lua'))('ForeverHUD',E)
assert(loadfile('src/ForeverHUD/Discovery.lua'))('ForeverHUD',E)
assert(loadfile('src/ForeverHUD/Selection.lua'))('ForeverHUD',E)
local S,D=E.selection,E.discovery
local frames={}
ForeverAuras.GetRegion=function(id)
    frames[id]=frames[id] or {SetOffset=function(self,x,y)self.x,self.y=x,y end}
    return frames[id]
end
local function loadout(class,names)
    UnitClass=function()return class,class end
    E.InitDB(); E.Profile().cooldownLayout='Class plan'; E.Profile().school='Auto'; E.Profile().cleave=false
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
    return S.positions['ForeverHUD | '..E.classNames[E.class]..' | Primary | '..name]
end
loadout('WARLOCK',{'Shadow Bolt','Corruption','Immolate','Drain Life','Drain Soul','Life Tap','Fear','Health Funnel'})
check(selected('Shadow Bolt') and selected('Corruption') and selected('Immolate'),'Leveling learned attacks fill main row')
check(selected('Life Tap').side==1 and selected('Shadow Bolt').side==2,'Two-sided functional hierarchy')
check(not selected('Conflagrate'),'No untrained maximum-level slot')
check(selected('Drain Life') and not selected('Drain Soul'),'Learned slot fallback has stable priority')
check(selected('Health Funnel').x-selected('Fear').x==47,'Unlearned priority slots compact without gaps or reordered learned skills')
check(selected('Shadow Bolt').x<0 and selected('Life Tap').x>0,'Class plans put attacks left over Health and support right')
do
    -- 0.7: each side is centred on its bar (x=±138) and grows both ways.
    local sums,counts={0,0},{0,0}
    for _,pos in pairs(S.positions) do sums[pos.side]=sums[pos.side]+pos.x;counts[pos.side]=counts[pos.side]+1 end
    check(math.abs(sums[1]/counts[1]-138)<1e-9 and math.abs(sums[2]/counts[2]+138)<1e-9,'Class-plan rows are centred on their bars')
end
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
ForeverAuras.GetData=function(id)
    if id:find('Native player effects',1,true) then return buffData end
    if id:find('Native cooldowns',1,true) then return data end
end
ForeverAuras.Add=function(new)writes=writes+1;if new.triggers[1].trigger.cdmSpells.multi[102] then buffData=new else data=new end end
D.cdm={[100]={name='Native extra',category='Essential',identities={}},[101]={name='Summon',category='Utility',identities={[698]=true}},[102]={name='Buff',category='TrackedBuff',identities={}},[103]={name='Breathing',category='TrackedBuff',identities={[5697]=true}}}
-- The native buff row is Cooldown Manager (Forever) mode's.
S.nativeMode,S.nativeUsed=true,{}
S.SyncCDM()
check(data.triggers[1].trigger.cdmSpells.multi[100] and not data.triggers[1].trigger.cdmSpells.multi[101],'Native learned combat overflow excludes preparation')
check(buffData.triggers[1].trigger.cdmSpells.multi[102] and not buffData.triggers[1].trigger.cdmSpells.multi[103],'Additional learned tracked buffs/counters exclude preparation')
S.SyncCDM();check(writes==2,'Unchanged CDM selections do not rewrite imports')
D.cdm[104]={name='Native extra 2',category='Essential',identities={}}
ForeverAuras.IsImporting=function()return true end
S.SyncCDM();check(writes==2,'CDM selection never calls Add during a native import')
ForeverAuras.IsImporting=nil
if E.bindTimer then E.bindTimer:Cancel();E.bindTimer=nil end
S.SyncCDM();check(writes==3 and data.triggers[1].trigger.cdmSpells.multi[104],'Deferred CDM selection applies after the import')
D.cdm[104]=nil
local edited={triggers={{trigger={type='aura2'}}}}
local previousData=ForeverAuras.GetData
ForeverAuras.GetData=function(id)if id:find('Native cooldowns',1,true)then return edited end return previousData(id)end
check(pcall(S.SyncCDM),'A user-edited CDM entry trigger is skipped, not indexed')
ForeverAuras.GetData=previousData
local reloads,previousRegion=0,ForeverAuras.GetRegion
ForeverAuras.GetRegion=function(id)
    if id:find('Native cooldowns',1,true)then return {ReloadControlledChildren=function()reloads=reloads+1 end} end
    return previousRegion(id)
end
S.rankKey=nil;D.cdmRank={[100]=1}
S.SyncCDM();S.SyncCDM()
check(reloads==1,'Native rows reload once for a new Cooldown Manager order, not on every sync')
D.cdmRank={[100]=2};S.SyncCDM()
check(reloads==2,'A Cooldown Manager reorder reloads native rows')
ForeverAuras.GetRegion=previousRegion;D.cdmRank={}
ForeverAuras.GetData=nil
UnitPowerType=function()return 3 end
loadout('DRUID',{"Tiger's Fury",'Barkskin','Shred','Claw','Rake','Rip','Faerie Fire','Maul','Bash','Frenzied Regeneration'})
check(S.stage=='Cat' and selected('Shred') and not selected('Maul'),'Energy form selects learned cat skills')
UnitPowerType=function()return 1 end
InCombatLockdown=function()return true end
D.events.scripts.OnEvent(nil,'UPDATE_SHAPESHIFT_FORM')
check(S.stage=='Bear' and selected('Maul') and not selected('Shred'),'Combat form switch reuses learned identities and switches native flags')
check(D.pending,'Combat form switch defers spellbook/CDM rediscovery')
local id='ForeverHUD | Druid | Primary | Maul'
local late={SetOffset=function(self,x,y)self.x,self.y=x,y end}
ForeverAuras.GetRegion=function(key)if key==id then return late end end
E.BindAbility(id);local layout=S.layoutTimer;E.BindAbility(id)
check(layout and S.layoutTimer==layout,'Late native region init coalesces layout after registration')
layout.callback();check(late.x==S.positions[id].x,'Newly eligible ability receives slot position after load scan')
-- Native manager mode follows saved categories instead of authored spell plans.
InCombatLockdown=function()return false end
loadout('WARLOCK',{'Fear','Life Tap','Shadow Bolt'})
E.Profile().cooldownLayout='Forever';D.cdmReady=true
local saved={}
local function template(id)
    saved[id]=saved[id] or {id=id,triggers={{trigger={cdmSpells={multi={}},cdmShow='cooldown'}}}}
    return saved[id]
end
ForeverAuras.GetData=template
local nativeWrites=0
ForeverAuras.Add=function(d)nativeWrites=nativeWrites+1;saved[d.id]=d end
D.cdmOrder={Essential={13,11,12,14,15,16,17,18,19},Utility={30,32,34,35,36,37}}
D.cdmRank={[13]=1,[11]=2}
D.cdm={}
for _,id in ipairs(D.cdmOrder.Essential)do D.cdm[id]={cdmID=id,name='Native '..id,category='Essential',identities={}}end
D.cdm[30]={cdmID=30,name='Fear',category='Utility',identities={[5782]=true}}
D.cdm[31]={cdmID=31,name='Hidden spell',category='HiddenActive',identities={}}
D.cdm[32]={cdmID=32,name='Summoning',category='Utility',identities={[698]=true}}
D.cdm[33]={cdmID=33,name='Equipped item',category='EquipSlotEssential',identities={}}
for id=34,37 do D.cdm[id]={cdmID=id,name='Support '..id,category='Utility',identities={}}end
S.Refresh()
local noState=setmetatable({}, {__index=function()error('Protected state must not be inspected for sorting')end})
check(E.SortCDM({cloneId='13',region=noState},{cloneId='11',region=noState}),'Overflow sorting uses native identity rank instead of numeric ID or restricted state')
check(not E.SortCDM({cloneId='11'},{cloneId='13'}),'Native-order comparator is consistent in both directions')
check(S.nativeMode and S.nativeSlots[1]==13 and S.nativeSlots[2]==11,'Native Essential order replaces authored priorities, including uncatalogued spells')
check(S.nativeSlots[4]==14 and S.nativeUsed[14] and not S.nativeUsed[15],'The left (damage) wing takes the first four Essential entries')
check(S.nativeSlots[5]==30 and S.nativeSlots[6]==34 and S.nativeSlots[8]==36 and not S.nativeUsed[37],'The right wing takes Utility in Cooldown Manager order, skipping preparation')
local prefix='ForeverHUD | Warlock'
-- Native rows and auras live in Core since 0.5.0; DisplayID picks the group.
local function trigger(suffix)return saved[E.DisplayID(suffix:sub(4))].triggers[1].trigger end
check(E.DisplayID('Native cooldowns | Entries')=='ForeverHUD | Core | Native cooldowns | Entries'
    and E.DisplayID('Primary | Native 1 | Entry')==prefix..' | Primary | Native 1 | Entry','Shared rows resolve to Core, class wings to the class group')
check(trigger(' | Native cooldowns | Entries').cdmSpells.multi[15] and trigger(' | Native cooldowns | Entries').cdmSpells.multi[19]
    and not trigger(' | Native cooldowns | Entries').cdmSpells.multi[14] and trigger(' | Native cooldowns | Entries').cdmShow=='cooldown','Essential beyond the left wing overflows to the native row with real-cooldown filtering')
local utilityRow=trigger(' | Native utility | Entries').cdmSpells.multi
check(utilityRow[37] and not utilityRow[30] and not utilityRow[34] and not utilityRow[32],'Utility beyond the right wing overflows to its row; wing entries and preparation are not repeated')
check(trigger(' | Primary | Native 5 | Entry').cdmSpells.multi[30],'The right wing renders the first Utility entry natively')
E.Profile().utility=false;S.Refresh()
check(not S.nativeSlots[5] and not next(trigger(' | Primary | Native 5 | Entry').cdmSpells.multi),'With utility abilities off, the right wing stays empty')
E.Profile().utility=true;S.Refresh()
check(trigger(' | Native items | Entries').cdmSpells.multi[33],'Equipped cooldown items have a separate native row')
check(not trigger(' | Native cooldowns | Entries').cdmSpells.multi[31],'Hidden entries are never promoted into cooldown rows')
local fear=prefix..' | Utility | Fear'
check(not S.Allowed(fear,E.catalog[fear]) and not selected('Life Tap'),'Native mode unloads curated duplicates and unrelated filler')
check(trigger(' | Primary | Native 1 | Entry').cdmSpells.multi[13],'Native primary uses CDM identity selections rather than guessed spell IDs')
-- 0.8.1: the armor family is represented by its reminder, not an active icon.
local armor=prefix..' | Upkeep reminder | Demon armor missing'
D.eligible[armor]={id=687,name='Demon Skin'}
D.cdm[40]={cdmID=40,name='Demon Armor',category='TrackedBuff',identities={[706]=true}}
S.SyncCDM()
check(not trigger(' | Native player effects | Entries').cdmSpells.multi[40],'Maintenance families cannot reappear as duplicate native proc/buff icons')
-- The CDM's tracked list includes the player's DoTs; the HUD's own target row
-- shows them, so the native row above the HUD must not repeat them.
local immolate=prefix..' | Target effects | Immolate'
check(E.catalog[immolate] and E.catalog[immolate].module=='dots','Immolate is a catalogued HUD DoT')
D.eligible[immolate]={id=348,name='Immolate'}
D.cdm[41]={cdmID=41,name='Immolate',category='TrackedBuff',identities={[348]=true}}
S.SyncCDM()
check(not trigger(' | Native player effects | Entries').cdmSpells.multi[41],'A DoT shown in the HUD target row stays out of the native row above the HUD')
E.Profile().dots=false;S.SyncCDM()
check(trigger(' | Native player effects | Entries').cdmSpells.multi[41],'With the target row off, the native row keeps the DoT')
E.Profile().dots=true;D.eligible[immolate]=nil;D.cdm[41]=nil;S.SyncCDM()
-- 0.7.1: one buff row on the right rim. Forever mode shows the tracked buffs
-- (curated class buffs off, and not skipped from the native row).
local backlash=prefix..' | Player effects | Backlash'
check(E.catalog[backlash] and E.catalog[backlash].effect,'Curated class buffs are marked as rim effects')
D.eligible[backlash]={id=34936,name='Backlash'}
D.cdm[42]={cdmID=42,name='Backlash',category='TrackedBuff',identities={[34936]=true}}
S.SyncCDM()
check(S.nativeMode and not S.Allowed(backlash,E.catalog[backlash]),'Forever mode unloads the curated buff icons')
check(trigger(' | Native player effects | Entries').cdmSpells.multi[42],'Forever mode shows the tracked buff natively on the rim')
D.eligible[backlash]=nil;D.cdm[42]=nil;S.SyncCDM()
template(prefix..' | Primary | Native left').regionType='dynamicgroup'
S.Refresh()
check(S.nativeWings and S.positions[prefix..' | Primary | Native left'] and not S.positions[prefix..' | Primary | Native 1'],'New native cooldown wings compact shown clones while legacy slot roots remain compatible')
check(S.positions[prefix..' | Primary | Native left'].x<0 and S.positions[prefix..' | Primary | Native right'].x>0,'Essential wing left over Health, Utility wing right')
D.eligible.nativeProc={name='Native 13'}
check(S.Allowed('nativeProc',{proc=true}),'Native cooldown-only mode retains usable-proc cues while ready ability icons are hidden')
local before=nativeWrites;S.Refresh()
check(nativeWrites==before,'Unchanged native layout does not rewrite aura data')
D.cdmOrder.Essential={};S.Refresh()
check(not S.positions[prefix..' | Primary | Native left'] and S.positions[prefix..' | Primary | Native right'] and S.nativeMode,'A known empty Essential list does not invent left-wing icons')
D.cdmOrder.Utility={};S.Refresh()
check(not next(S.positions) and S.nativeMode,'Empty native lists invent no fallback icons')
E.Profile().cooldownLayout='Class plan';S.Refresh()
check(selected('Shadow Bolt') and not next(trigger(' | Primary | Native 1 | Entry').cdmSpells.multi),'Class plans are explicit and clear old native selections')
check(S.Allowed(prefix..' | Player effects | Backlash',E.catalog[prefix..' | Player effects | Backlash'])
    and not next(trigger(' | Native player effects | Entries').cdmSpells.multi),'Class plan mode uses the curated buffs and leaves the native rim row empty')
D.cdm[50]={cdmID=50,name='Corruption',category='TrackedBar',identities={[172]=true}}
-- Tracked bars and the native buff row are Cooldown Manager (Forever) mode.
E.Profile().cooldownLayout='Forever';D.cdmOrder.Essential={13,11}
E.Profile().trackedBars=true;S.Refresh()
check(trigger(' | Native tracked bars | Entries').cdmSpells.multi[50],'Tracked-bar identities have a separate native duration-bar renderer')
check(not trigger(' | Native player effects | Entries').cdmSpells.multi[50],'Enabled tracked bars do not duplicate the same native entry as an overflow icon')
E.Profile().trackedBars=false;S.Refresh()
check(trigger(' | Native player effects | Entries').cdmSpells.multi[50],'Disabling optional bars preserves legacy icon coverage')
D.cdmReady=false;E.Profile().cooldownLayout='Forever';S.Refresh()
check(not S.nativeMode and selected('Shadow Bolt'),'Unavailable CDM retains learned class-plan fallback')
print('Ability selection checks passed: '..checks)
