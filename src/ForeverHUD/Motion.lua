local _, E = ...
local M={entries={}}
E.motion=M
local function clamp(v) return math.max(0,math.min(1,v)) end
function M.Curve(elapsed,opening,rank,count)
    local delay=(opening and rank-1 or count-rank)*.065
    local t=clamp((elapsed-delay)/.28)
    return t*t*(3-2*t)
end
function M.Sample(entry,now)
    local transition=entry.transition
    if not transition then return entry.q or 0,entry.alpha or 0 end
    local elapsed=math.max(0,now-transition.at)
    local t=entry.resource and clamp(elapsed/.5) or M.Curve(elapsed,transition.goal==1,entry.rank,entry.count)
    return transition.from+(transition.goal-transition.from)*t,
        transition.alpha+(transition.goal-transition.alpha)*t
end
local function commit(entry,q,alpha)
    entry.q,entry.alpha=q,alpha
    entry.region:SetOffsetAnim(-entry.distance*(1-q),0)
    if alpha==1 then entry.region:SetAnimAlpha(nil) else entry.region:SetAnimAlpha(alpha) end
end
local function stopEntry(entry,restore)
    local q,alpha=M.Sample(entry,GetTime())
    entry.transition=nil
    if entry.group then entry.group:Stop() end
    if restore then
        entry.region:SetOffsetAnim(0,0); entry.region:SetAnimAlpha(nil)
    else commit(entry,q,alpha) end
end
local function entry(id,distance,rank,count,resource)
    local api=E.API()
    local region=api and api.GetRegion and api.GetRegion(id)
    if not region or not region.SetOffsetAnim or not region.SetAnimAlpha or not region.CreateAnimationGroup then return end
    local old=M.entries[id]
    if old and old.region~=region then stopEntry(old,true); old=nil end
    local baseline=E.state.open and 1 or 0
    if M.running then baseline=M.target and 0 or 1 end
    local item=old or {region=region,q=baseline,alpha=baseline}
    item.distance,item.rank,item.count,item.resource=distance,rank,count,resource
    M.entries[id]=item
    return item
end
function M.Gather()
    local active={}
    -- UIParent show/hide (Alt-Z) can arrive before a supported class is known.
    if not E.class then return end
    local p=E.Profile()
    local counts={0,0}
    local positions=p and p.primary and E.selection and E.selection.positions or {}
    for _,p in pairs(positions) do counts[p.side]=counts[p.side]+1 end
    for id,p in pairs(positions) do
        local rank=1
        for _,other in pairs(positions) do if other.side==p.side and other.slot<p.slot then rank=rank+1 end end
        local item=entry(id,p.x,rank,counts[p.side],false)
        if item then active[id]=true end
    end
    for _,row in ipairs({{'Health',-138,'resources'},{'Resource',138,'resources'},{'Chassis',0,'art'},{'Pet health',-138,'pet'},{'Soul Shards',138,'pet'}}) do
        local id=E.DisplayID(row[1])
        local item=id and p and p[row[3]] and entry(id,row[2],1,1,true)
        if item then active[id]=true end
    end
    for id,item in pairs(M.entries) do if not active[id] then stopEntry(item,true);M.entries[id]=nil end end
end
local function animate(item,goal)
    stopEntry(item,false)
    local from,alpha=item.q,item.alpha
    if item.resource and goal==1 then alpha=1 end
    commit(item,from,alpha)
    if not item.group then
        item.group=item.region:CreateAnimationGroup()
        item.parts={}
        -- The native animation clock plays a sampled smoothstep. Lua does no
        -- per-frame work and never reads protected button alpha/visibility.
        for i=1,24 do
            local translation=item.group:CreateAnimation('Translation')
            translation:SetOrder(i); translation:SetDuration(.5/24)
            local fade=item.group:CreateAnimation('Alpha')
            fade:SetOrder(i);fade:SetDuration(.5/24)
            item.parts[i]={translation,fade}
        end
        item.group:SetScript('OnFinished',function()
            if item.transition then
                local target=item.transition.goal
                item.transition=nil;item.group:Stop();commit(item,target,target)
            end
        end)
    end
    local previous,previousAlpha=from,alpha
    for i,part in ipairs(item.parts) do
        local t=item.resource and i/24 or M.Curve(i*.5/24,goal==1,item.rank,item.count)
        local q=from+(goal-from)*t
        local a=alpha+(goal-alpha)*t
        part[1]:SetOffset(item.distance*(q-previous),0)
        part[2]:SetFromAlpha(previousAlpha);part[2]:SetToAlpha(a)
        previous,previousAlpha=q,a
    end
    item.transition={at=GetTime(),from=from,alpha=alpha,goal=goal}
    item.group:Play()
end
local function finishLater()
    if M.finish then M.finish:Cancel();M.finish=nil end
    M.finish=C_Timer.NewTimer(.51,function()
        M.finish=nil;M.running=false;E.state.transition=false;E.Notify()
    end)
end
function M.Reconcile()
    if not E.state or not E.state.world then M.Stop();return end
    local previous={}
    for id,item in pairs(M.entries)do previous[id]=item end
    M.Gather()
    if M.running then
        local added=false
        for id,item in pairs(M.entries)do
            if previous[id]~=item then animate(item,M.target and 1 or 0);added=true end
        end
        if added then finishLater()end
    else
        for _,item in pairs(M.entries)do
            stopEntry(item,true);commit(item,E.state.open and 1 or 0,E.state.open and 1 or 0)
        end
    end
end
function M.Change(open,silent)
    if M.finish then M.finish:Cancel();M.finish=nil end
    local p=E.Profile()
    local immediate=silent or not p or not p.unfold
    M.target=open;M.running=not immediate
    M.Gather()
    E.state.transition=not immediate
    for _,item in pairs(M.entries) do
        if immediate then stopEntry(item,true);commit(item,open and 1 or 0,open and 1 or 0)
        else animate(item,open and 1 or 0) end
    end
    if not immediate then finishLater()end
end
function M.Stop()
    if M.finish then M.finish:Cancel(); M.finish=nil end
    for _,item in pairs(M.entries) do stopEntry(item,true) end
    M.entries={};M.running=false
    if E.state then E.state.transition=false end
end
