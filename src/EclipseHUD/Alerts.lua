local _, E = ...
local A={queue={},last={},sounds={},active=false}
E.alerts=A
local events=CreateFrame('Frame')
A.events=events
local path='Interface\\AddOns\\EclipseHUD\\Audio\\'
local function cancel(key)
    if A[key] then A[key]:Cancel();A[key]=nil end
end
local function clear()
    cancel('timer'); A.queue={}
    if A.handle and StopSound then StopSound(A.handle,.05);A.handle=nil end
end
local function allowed(entry)
    if not A.active or not E.discovery.eligible[entry.id] or (E.state and E.state.Preview()) then return false end
    return entry.kind=='active' or E.Call(UnitAffectingCombat,'player')==true
end
local function play(entry)
    if not PlaySoundFile then return end
    local ok,handle=PlaySoundFile(path..entry.kind..'.wav','Master')
    if ok then
        if E.Readable(handle) then A.handle=handle end
        A.blocked=GetTime()+(entry.kind=='active' and .42 or .32)+.1
    end
end
local drain
local function schedule(delay)
    cancel('timer')
    A.timer=C_Timer.NewTimer(math.max(.01,delay),function()A.timer=nil;drain()end)
end
drain=function()
    if not A.active or (E.state and E.state.Preview()) then clear();return end
    local now=GetTime()
    if A.blocked and now<A.blocked then
        if #A.queue>0 then schedule(A.blocked-now) end
        return
    end
    while #A.queue>0 do
        local entry=table.remove(A.queue,1)
        if now-entry.at<4 and allowed(entry) then
            play(entry)
            if #A.queue>0 then schedule((A.blocked or now+.1)-now) end
            return
        end
    end
end
function A.Interrupt()
    if E.class~='WARRIOR' then return end
    local stance=E.Call(GetShapeshiftForm)
    if stance==3 and E.discovery.Resolve(6552,'ability') then return 6552 end
    local item=E.Call(GetInventoryItemID,'player',17)
    if E.Number(item) and C_Item and C_Item.GetItemInfoInstant then
        local ok,_,_,_,loc,_,kind,subclass=pcall(C_Item.GetItemInfoInstant,item)
        if ok and E.Readable(loc) and loc=='INVTYPE_SHIELD' and E.Readable(kind) and kind==4
            and E.Readable(subclass) and subclass==6 and E.discovery.Resolve(72,'ability') then return 72 end
    end
end
local function enqueue(id,seed,priority,kind)
    local now=GetTime()
    if not A.active or now<(A.suppress or math.huge) then return end
    if kind=='ready' and (seed==6552 or seed==72) and A.Interrupt()~=seed then return end
    local entry={id=id,seed=seed,priority=priority,kind=kind,at=now}
    if not allowed(entry) then return end
    local key=id..kind
    if A.last[key] and now-A.last[key]<2 then return end
    A.last[key]=now;A.queue[#A.queue+1]=entry
    table.sort(A.queue,function(a,b)return a.priority>b.priority or (a.priority==b.priority and a.at<b.at)end)
    if not A.timer then schedule(.06) end
end
function E.ReadyAlert(id,seed,priority) enqueue(id,seed,priority,'ready') end
local function unregisterNative()
    if C_UnitAuras and C_UnitAuras.RemoveAuraSound then
        for _,id in ipairs(A.sounds) do pcall(C_UnitAuras.RemoveAuraSound,id) end
    end
    A.sounds={};A.signature=nil
end
function A.SyncNative()
    A.nativeTimer=nil
    if not A.active then return end
    if GetTime()<A.suppress then
        A.nativeTimer=C_Timer.NewTimer(A.suppress-GetTime(),A.SyncNative);return
    end
    if not C_UnitAuras or not C_UnitAuras.AddAuraSound or not C_UnitAuras.RemoveAuraSound
        or not Enum.UnitAuraSoundTrigger or Enum.UnitAuraSoundTrigger.Added==nil then
        A.error='Native aura audio is unavailable';return
    end
    local ids={}
    for _,seeds in pairs(E.effectSpells[E.class]) do
        for _,seed in ipairs(seeds) do
            local record=E.discovery.Resolve(seed,'aura')
            if record then ids[seed]=true;ids[record.id]=true end
        end
    end
    local keys={};for id in pairs(ids)do keys[#keys+1]=id end;table.sort(keys)
    local signature=table.concat(keys,',')
    if signature==A.signature then return end
    unregisterNative();A.signature=signature
    for _,id in ipairs(keys) do
        local handle=E.Call(C_UnitAuras.AddAuraSound,Enum.UnitAuraSoundTrigger.Added,
            {unitToken='player',spellID=id,soundFileName=path..'active.wav',outputChannel='Master'})
        if E.Number(handle) then A.sounds[#A.sounds+1]=handle end
    end
end
function E.StopAlerts()
    A.active=false;clear();cancel('nativeTimer');unregisterNative()
    events:UnregisterEvent('PLAYER_REGEN_ENABLED');events:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
end
function E.RefreshAlerts()
    local p=E.Profile()
    local active=p and p.enabled and p.alerts and E.state and E.state.world and not E.state.loading
        and not E.state.hidden and not E.state.Preview() and E.Call(UnitIsDeadOrGhost,'player')==false
    if not active then E.StopAlerts();return end
    if not A.active then
        A.active=true;A.suppress=GetTime()+1;A.last={};A.blocked=0
        events:RegisterEvent('PLAYER_REGEN_ENABLED');events:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
    end
    if not A.nativeTimer then A.SyncNative() end
end
events:SetScript('OnEvent',function(_,event,unit,_,spell)
    if event=='PLAYER_REGEN_ENABLED' then clear();return end
    if not A.active or unit~='player' or not E.Number(spell) then return end
    -- Native Added plays buff activation. This event only reserves that chime's
    -- length; it does not assert aura presence or produce a duplicate sound.
    for _,seeds in pairs(E.effectSpells[E.class]) do
        for _,seed in ipairs(seeds) do
            local record=E.discovery.Resolve(seed,'aura')
            if record and (spell==seed or spell==record.id) then
                if A.handle and StopSound then StopSound(A.handle,.05);A.handle=nil end
                A.blocked=GetTime()+.52
            end
        end
    end
    -- These source shouts have no player buff. Actual success is their event.
    if E.class=='WARRIOR' and (spell==1161 or spell==5246) then
        local id='Eclipse | Warrior | Ready alert | '..spell
        enqueue(id,spell,80,'active')
    end
end)
