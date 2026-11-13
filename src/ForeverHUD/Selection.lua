local _, E = ...
local S={primary={},used={},positions={}}
E.selection=S
-- Ability rows are centred on their bar (x=±138) and grow both ways; rank 1
-- sits nearest the seal. Matches BAR_X in scripts/build.py.
S.BAR_X,S.STEP=138,47
-- 0.9.7: spell suggestions always sit right above the DoT row (fixed in the
-- import). The left (attack) cooldown wing, whose native icons may appear
-- only while on cooldown, rises above them instead: 40 px icons centred
-- 34 px higher clear the 32 px suggestion row. Matches WING_LIFT in
-- scripts/build.py.
S.WING_LIFT=34
function S.Centred(sign,rank,count)
    return sign*(S.BAR_X-((count-1)/2-(rank-1))*S.STEP)
end
-- The lift applies only while this class has suggestions turned on.
function S.LeftLift()
    local p=E.Profile()
    if not p or p.suggest==false then return 0 end
    for _,entry in pairs(E.catalog or {}) do
        if entry.cls==E.class and entry.module=='suggest' then return S.WING_LIFT end
    end
    return 0
end
-- Only purchased, readable ranks contribute. Unavailable data leaves Leveling.
function S.TalentSchool()
    local config=E.Call(C_ClassTalents and C_ClassTalents.GetActiveConfigID)
    local info=E.Number(config) and E.Call(C_Traits and C_Traits.GetConfigInfo,config)
    if type(info)~="table" or not E.Readable(info.treeIDs) or type(info.treeIDs)~="table" then return end
    local nodes=E.Number(info.treeIDs[1]) and E.Call(C_Traits.GetTreeNodes,info.treeIDs[1])
    if type(nodes)~="table" then return end
    local columns,xs={},{}
    for _,id in ipairs(nodes) do
        local node=E.Number(id) and E.Call(C_Traits.GetNodeInfo,config,id)
        if type(node)=="table" and E.Readable(node.posX) and type(node.posX)=="number" then
            local x=node.posX
            if not columns[x] then xs[#xs+1]=x; columns[x]=0 end
            if E.Readable(node.ranksPurchased) and type(node.ranksPurchased)=="number" and node.ranksPurchased>0 then
                columns[x]=columns[x]+node.ranksPurchased
            end
        end
    end
    table.sort(xs)
    local step
    for i=2,#xs do
        local gap=xs[i]-xs[i-1]
        if gap>0 and (not step or gap<step) then step=gap end
    end
    if not step then return end
    local totals={columns[xs[1]]}
    for i=2,#xs do
        if xs[i]-xs[i-1]>2*step then totals[#totals+1]=0 end
        totals[#totals]=totals[#totals]+columns[xs[i]]
    end
    if #totals~=3 then return end
    local best
    for i,points in ipairs(totals) do if points>0 and (not best or points>totals[best]) then best=i end end
    return best and E.schools[E.class][best]
end
local function copy(value)
    if type(value)~="table" then return value end
    local result={}; for k,v in pairs(value) do result[k]=copy(v) end; return result
end
local function preparation(entry)
    return entry.identities[5697] or entry.identities[698] or entry.identities[20608]
end
function E.SortCDM(a,b)
    -- cloneId is FA's public identity key, never a duration, stack or alpha.
    local function key(row)
        local value=row and row.cloneId
        local id=E.Readable(value) and tonumber(value)
        return id and E.discovery.cdmRank and E.discovery.cdmRank[id] or math.huge,id or 0
    end
    local ar,ai=key(a);local br,bi=key(b)
    return ar~=br and ar<br or ar==br and ai<bi
end
local function cdmTrigger(data)
    -- The user may have edited or replaced this entry's trigger in /fa.
    local first=type(data)=='table' and type(data.triggers)=='table' and data.triggers[1]
    local trigger=type(first)=='table' and first.trigger
    if type(trigger)=='table' and type(trigger.cdmSpells)=='table' and type(trigger.cdmSpells.multi)=='table' then return trigger end
end
local function syncEntries(api,id,selected,show)
    local data=api.GetData(id)
    if not cdmTrigger(data) then return end
    local old=data.triggers[1].trigger.cdmSpells.multi
    for key in pairs(old) do if not selected[tonumber(key)] then old=nil; break end end
    if old then for key in pairs(selected) do if not old[key] and not old[tostring(key)] then old=nil; break end end end
    if old and (not show or (data.triggers[1].trigger.cdmShow==show and data.triggers[1].trigger.use_cdmShowGCD==false)) then return end
    data=copy(data); data.triggers[1].trigger.cdmSpells.multi=selected
    if show then data.triggers[1].trigger.cdmShow=show;data.triggers[1].trigger.use_cdmShowGCD=false end
    api.Add(data)
end
function S.SyncCDM()
    local api=E.API()
    if E.InCombat() or not api or not api.GetData or not api.Add then return end
    -- api.Add during an import would replace displays mid-update (the Druid
    -- form handler reaches here without the discovery import guard).
    if E.Importing() then E.Bind(); return end
    local represented={}
    for id,entry in pairs(E.catalog) do
        if entry.cls==E.class and entry.key and E.discovery.eligible[id] and not entry.prep
            and (entry.module=='primary' or entry.module=='utility') then
            represented[E.discovery.eligible[id].name]=true
        end
    end
    local selected,utility,items={},{},{}
    -- FA owns cooldown state, charges, overrides and clone rendering.
    for id,entry in pairs(E.discovery.cdm) do
        if S.nativeMode then
            if not preparation(entry) then
                if entry.category=='Essential' and not S.nativeUsed[id] then selected[id]=true
                elseif entry.category=='Utility' and not S.nativeUsed[id] then utility[id]=true
                elseif entry.category=='EquipSlotEssential' then items[id]=true end
            end
        elseif (entry.category=="Essential" or entry.category=="Utility" or entry.category=="SpecAgnosticEssential")
            and not represented[entry.name] then
            if not preparation(entry) then selected[id]=true end
        end
    end
    local ID=E.DisplayID
    syncEntries(api,ID('Native cooldowns | Entries'),selected,'cooldown')
    syncEntries(api,ID('Native utility | Entries'),utility,'cooldown')
    syncEntries(api,ID('Native items | Entries'),items,'cooldown')
    for index=1,8 do
        local cdmID=S.nativeSlots and S.nativeSlots[index]
        syncEntries(api,ID('Primary | Native '..index..' | Entry'),cdmID and {[cdmID]=true} or {},'cooldown')
    end
    local buffs,bars,representedBuffs,representedBuffIDs={},{},{},{}
    local p=E.Profile()
    for id,entry in pairs(E.catalog) do
        -- The CDM's tracked list also holds the player's DoTs on the target.
        -- A DoT the HUD's own target-effects row shows stays out of the
        -- native row above the HUD (unless that row is switched off).
        -- Curated class buffs are off in Forever mode, so the native row
        -- carries them instead of skipping them.
        local shown=(entry.module=='buffs' and not (entry.effect and S.nativeMode)) or entry.module=='maintenance' or (entry.module=='dots' and p.dots~=false)
        if entry.cls==E.class and shown and entry.kind=='aura' and E.discovery.eligible[id] then
            local record=E.discovery.eligible[id]
            representedBuffs[record.name]=true;representedBuffIDs[record.id]=true
            for _,seed in ipairs(entry.seeds)do
                representedBuffIDs[seed]=true
                local info=E.Call(C_Spell and C_Spell.GetSpellInfo,seed)
                if type(info)=='table' and E.Readable(info.name) and type(info.name)=='string' then representedBuffs[info.name]=true end
            end
        end
    end
    for id,entry in pairs(E.discovery.cdm) do
        local duplicate=representedBuffs[entry.name]
        for spell in pairs(entry.identities)do if representedBuffIDs[spell] then duplicate=true;break end end
        if entry.category=='TrackedBar' and not preparation(entry) then bars[id]=true end
        if (entry.category=='TrackedBuff' or (entry.category=='TrackedBar' and not p.trackedBars) or entry.category=='SpecAgnosticTracked')
            and not duplicate and not preparation(entry) then buffs[id]=true end
    end
    -- Class plan mode uses the curated class buffs on the right rim, so the
    -- native buff row at the same spot stays empty.
    syncEntries(api,ID('Native player effects | Entries'),S.nativeMode and buffs or {})
    syncEntries(api,ID('Native tracked bars | Entries'),bars)
    -- Native multi-entry pickers sort IDs internally. Re-sort ordinary clone
    -- containers by the public manager order, only outside combat. FA's
    -- SortUpdatedChildren only moves children flagged as updated, so a pure
    -- manager reorder needs a full reload; do that only when the order changed.
    local ranks={}
    for id,rank in pairs(E.discovery.cdmRank or {})do ranks[#ranks+1]=id..'='..rank end
    table.sort(ranks)
    local key=table.concat(ranks,',')
    if key==S.rankKey then return end
    S.rankKey=key
    for _,name in ipairs({'Native cooldowns','Native utility','Native items','Native tracked bars','Primary | Native left','Primary | Native right'})do
        local region=api.GetRegion and api.GetRegion(ID(name))
        if region and region.ReloadControlledChildren then region:ReloadControlledChildren()
        elseif region and region.SortUpdatedChildren then region:SortUpdatedChildren() end
    end
end
function S.ApplyLayout()
    local api=E.API(); if not api or not api.GetRegion then return end
    local lift=S.LeftLift()
    for id,position in pairs(S.positions) do
        local region=api.GetRegion(id)
        -- Ordinary spell displays only, never root ancestry or native aura
        -- buttons. Cached form selection can reposition these ordinary icons.
        if region and region.SetOffset then region:SetOffset(position.x,position.x<0 and lift or 0) end
    end
end
function S.Refresh()
    local available={}
    for id,entry in pairs(E.catalog or {}) do
        if entry.cls==E.class and entry.module=="primary" and entry.key and E.discovery.eligible[id] then
            available[entry.key]={id=id,record=E.discovery.eligible[id]}
        end
    end
    local p=E.Profile()
    if not E.InCombat() then S.talentMode=S.TalentSchool() end
    local mode=p.school~="Auto" and p.school or S.talentMode
    if not mode and E.class=="WARRIOR" then
        mode=available['Mortal Strike'] and 'Arms' or available.Bloodthirst and 'Fury'
            or available['Shield Slam'] and 'Protection'
    end
    mode=mode or 'Leveling'
    local stage=mode
    if E.class=="WARRIOR" then
        if mode=="Arms" and not available['Mortal Strike'] then stage="ArmsEarly" end
        if mode=="Fury" and not available.Bloodthirst then stage="FuryEarly" end
    end
    if E.class=='DRUID' then
        local power=E.Call(UnitPowerType,'player')
        if power==1 then stage='Bear'
        elseif power==3 then stage='Cat'
        elseif mode=='Feral' then stage='Caster' end
    end
    local plans=E.plans[E.class]
    local scheme=plans[stage] or plans.Leveling or plans[E.schools[E.class][1]]
    S.primary,S.used,S.positions={},{},{}
    S.mode,S.stage=mode,stage
    S.nativeMode=p.cooldownLayout~='Class plan' and E.discovery.cdmReady==true
    S.nativeSlots,S.nativeUsed={},{}
    if S.nativeMode then
        -- The player's own Cooldown Manager split decides the side: Essential
        -- (damage rotation) fills the left wing over Health, Utility
        -- (defensive, control, support) the right wing over the resource bar.
        -- Entries beyond four per side stay in the native rows below.
        local function ordered(category)
            local records={}
            for _,id in ipairs(E.discovery.cdmOrder[category] or {})do
                local record=E.discovery.cdm[id]
                if record and not preparation(record) and not S.used[record.name] and #records<4 then
                    S.used[record.name]=true;records[#records+1]=record
                end
            end
            return records
        end
        local sides={ordered('Essential'),p.utility~=false and ordered('Utility') or {}}
        local prefix='ForeverHUD | '..E.classNames[E.class]
        local api=E.API()
        local wing=api and api.GetData and api.GetData(prefix..' | Primary | Native left')
        S.nativeWings=wing and wing.regionType=='dynamicgroup'
        -- Each wing is a centred dynamic group placed at its bar's centre.
        if S.nativeWings and #sides[1]>0 then S.positions[prefix..' | Primary | Native left']={x=-S.BAR_X,side=1,slot=1}end
        if S.nativeWings and #sides[2]>0 then S.positions[prefix..' | Primary | Native right']={x=S.BAR_X,side=2,slot=1}end
        -- Every selected entry is rendered by an unchanged native FA CDM
        -- trigger inside an ordinary slot group. Never move its private widget.
        -- Entries 1-4 sit in the left wing, 5-8 in the right wing.
        for side,records in ipairs(sides) do
            for slot,record in ipairs(records) do
                local index=(side-1)*4+slot
                local id=prefix..' | Primary | Native '..index
                S.nativeSlots[index]=record.cdmID;S.nativeUsed[record.cdmID]=true
                S.primary[id]=true
                if not S.nativeWings then S.positions[id]={x=S.Centred(side==1 and -1 or 1,slot,#records),side=side,slot=slot}end
            end
        end
    else for side,slots in ipairs(scheme) do
        local shown={}
        for index,choices in ipairs(slots) do
            if E.class=="WARRIOR" and stage=="Fury" and side==2 and index==4 and p.cleave and available.Cleave then choices={"Cleave"} end
            for _,key in ipairs(choices) do
                local entry=available[key]
                if entry and not S.used[entry.record.name] then
                    S.primary[entry.id]=true; S.used[entry.record.name]=true
                    shown[#shown+1]={id=entry.id,slot=index}
                    break
                end
            end
        end
        -- Plan side 1 is cooldown/support, side 2 attack/heal. Damage sits
        -- left over Health and support right, centred on the bar.
        for rank,item in ipairs(shown) do
            S.positions[item.id]={x=S.Centred(side==1 and 1 or -1,rank,#shown),side=side,slot=item.slot}
        end
    end end
    S.ApplyLayout(); S.SyncCDM()
    if E.motion and E.state then E.motion.Reconcile() end
end
function S.Allowed(id,entry)
    if entry.prep then return false end
    -- The right rim shows one buff row: the Cooldown Manager's tracked buffs
    -- in Forever mode, the curated class buffs in Class plan mode.
    if entry.effect then return not S.nativeMode end
    if entry.proc then
        local record=E.discovery.eligible[id]
        return record~=nil and (S.nativeMode or not S.used[record.name])
    end
    if entry.module=="primary" and entry.key then return S.primary[id]==true end
    if entry.module=="utility" and entry.key then
        if S.nativeMode then return false end
        local record=E.discovery.eligible[id]
        return record~=nil and not S.used[record.name]
    end
    return true
end
function E.BindAbility(id)
    if not S.positions[id] or S.layoutTimer then return end
    -- Newly eligible regions can be created only after the load-flag scan.
    -- Coalesce their init callbacks after registration rather than leaving
    -- fresh slots stacked at the generator's temporary center coordinate.
    S.layoutTimer=C_Timer.NewTimer(0,function()
        S.layoutTimer=nil
        -- Init actions also run while an import rebuilds the groups. Hand off
        -- to the bind retry, which refreshes selection and layout afterwards.
        -- (Ordinary icon offsets stay allowed in combat for form switches.)
        if E.Importing() then E.Bind();return end
        S.ApplyLayout()
        if E.motion and E.state then E.motion.Reconcile() end
    end)
end
function S.Stop()
    if S.layoutTimer then S.layoutTimer:Cancel();S.layoutTimer=nil end
    S.rankKey=nil
    S.primary,S.used,S.positions={},{},{}
    S.nativeMode=false;S.nativeSlots,S.nativeUsed={},{}
end
function E.ReminderContext()
    return E.class=='WARRIOR' and S.mode=='Arms' and E.state and E.state.HostileTarget()
end
