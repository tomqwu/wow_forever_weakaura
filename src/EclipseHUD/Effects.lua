local _, E = ...
-- Only ordinary decorative frames are managed here. Buff lifetimes and
-- resource intensity are generated native FA triggers/animation settings.
local F={groups={},bindings={},hosts=setmetatable({},{__mode='k'}),attempts=0}
E.effects=F
local events=CreateFrame('Frame')
F.events=events
local function animated(parent,width,height,asset,loop)
    local frame=CreateFrame('Frame',nil,parent)
    frame:SetSize(width,height);frame:SetPoint('CENTER')
    local texture=frame:CreateTexture(nil,'OVERLAY')
    texture:SetAllPoints();texture:SetTexture('Interface\\AddOns\\EclipseHUD\\Media\\'..asset..'.tga')
    texture:SetBlendMode('ADD');texture:SetAlpha(0)
    local group=texture:CreateAnimationGroup()
    if loop then group:SetLooping('REPEAT') end
    local fade=group:CreateAnimation('Alpha');fade:SetOrder(1);fade:SetDuration(loop and .6 or .45)
    fade:SetFromAlpha(loop and .2 or .8);fade:SetToAlpha(loop and .65 or 0)
    if loop then
        fade=group:CreateAnimation('Alpha');fade:SetOrder(2);fade:SetDuration(.6);fade:SetFromAlpha(.65);fade:SetToAlpha(.2)
    end
    F.groups[#F.groups+1]=group
    return {parent=parent,frame=frame,group=group}
end
local specs={
    {'success','Seal','cast',152,152,'runes',false},
    {'cast','Cast','cast',320,26,'divider',true},
    {'left','Health','resources',180,22,'divider',false},
    {'right','Resource','resources',180,22,'divider',false},
}
local function pause(binding)
    binding.active=false;binding.group:Stop();binding.frame:Hide()
end
local function watch(binding,parent)
    local previous=F.hosts[binding.parent]
    if previous then previous[binding]=nil end
    local host=F.hosts[parent]
    if not host then
        host={};F.hosts[parent]=host
        parent:HookScript('OnHide',function()
            for item in pairs(host) do item.group:Stop() end
        end)
    end
    host[binding]=true;binding.parent=parent
end
local function attach(spec,p)
    local key,target,module,width,height,asset,loop=unpack(spec)
    local binding=F.bindings[key]
    if not p[module] then
        if binding then pause(binding) end
        return true -- a disabled widget is not a missing dependency
    end
    local api=E.API()
    local parent=api and api.GetRegion and api.GetRegion('Eclipse | '..E.classNames[E.class]..' | '..target)
    if not parent then if binding then pause(binding) end;return false end
    if not binding or binding.parent~=parent then
        if binding then pause(binding) end
        if E.InCombat() then return false end
        if not binding then
            binding=animated(parent,width,height,asset,loop)
            F.bindings[key]=binding;F[key]=binding.group
        else
            -- These frames contain only our textures. Reuse them on import
            -- region replacement; defer even this ancestry change in combat.
            binding.frame:SetParent(parent);binding.frame:ClearAllPoints()
            binding.frame:SetPoint('CENTER')
        end
        watch(binding,parent)
    end
    binding.active=true;binding.frame:Show()
    return true
end
function E.StopFX()
    F.active=false
    if F.retry then F.retry:Cancel();F.retry=nil end
    events:UnregisterEvent('PLAYER_SWING')
    for _,binding in pairs(F.bindings) do pause(binding) end
end
function E.RefreshFX(reset)
    local p=E.Profile()
    local active=p and p.enabled and p.fx and p.art and E.state and E.state.world and not E.state.loading
        and not E.state.hidden and not E.state.Preview() and E.Call(UnitIsDeadOrGhost,'player')==false
    if not active then E.StopFX();return end
    if reset then F.attempts=0 end
    local complete=true
    for _,spec in ipairs(specs) do if not attach(spec,p) then complete=false end end
    F.class=E.class;F.built=complete;F.active=true
    if complete then
        F.attempts=0
        if F.retry then F.retry:Cancel();F.retry=nil end
    elseif not E.InCombat() and not F.retry and F.attempts<8 then
        F.attempts=F.attempts+1
        F.retry=C_Timer.NewTimer(.25,function()F.retry=nil;E.RefreshFX(false)end)
    end
    local left,right=F.bindings.left,F.bindings.right
    if (left and left.active) or (right and right.active) then events:RegisterEvent('PLAYER_SWING')
    else events:UnregisterEvent('PLAYER_SWING') end
end
function E.CastMotion(kind)
    if kind=='cancel' then if F.cast then F.cast:Stop() end;return end
    if not F.active then return end
    local cast,success=F.bindings.cast,F.bindings.success
    if not E.Gate('cast',E.class) then return end
    if kind=='start' and cast and cast.active then cast.group:Stop();cast.group:Play()
    elseif kind=='success' then
        if cast then cast.group:Stop() end
        if success and success.active then success.group:Stop();success.group:Play() end
    end
end
events:SetScript('OnEvent',function(_,_,timestamp,hand)
    if not F.active or not E.LayoutVisible() or not E.Number(timestamp) or not E.Readable(hand)
        or (hand~=0 and hand~=1 and hand~=2) then return end
    if hand==1 and E.class=='WARRIOR' and not E.dualSwing then return end
    local now=GetTime()
    if F.lastSwing and now-F.lastSwing<.14 then return end
    F.lastSwing=now
    for _,key in ipairs({'left','right'}) do
        local binding=F.bindings[key]
        if binding and binding.active then binding.group:Stop();binding.group:Play() end
    end
end)
