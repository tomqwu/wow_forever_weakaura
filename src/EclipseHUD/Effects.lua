local _, E = ...
-- Only ordinary decorative frames are managed here. Buff lifetimes and
-- resource intensity are generated native FA triggers/animation settings.
local F={groups={},attempts=0}
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
    parent:HookScript('OnHide',function()group:Stop()end)
    F.groups[#F.groups+1]=group
    return group
end
local function build()
    local api=E.API()
    local prefix='Eclipse | '..E.classNames[E.class]
    local seal=api and api.GetRegion and api.GetRegion(prefix..' | Seal')
    local cast=api and api.GetRegion and api.GetRegion(prefix..' | Cast')
    local health=api and api.GetRegion and api.GetRegion(prefix..' | Health')
    local power=api and api.GetRegion and api.GetRegion(prefix..' | Resource')
    if not seal or not cast or not health or not power then return false end
    F.cast=animated(cast,320,26,'divider',true)
    F.success=animated(seal,152,152,'runes',false)
    F.left=animated(health,180,22,'divider',false)
    F.right=animated(power,180,22,'divider',false)
    F.class=E.class;F.built=true
    return true
end
function E.StopFX()
    F.active=false
    if F.retry then F.retry:Cancel();F.retry=nil end
    events:UnregisterEvent('PLAYER_SWING')
    for _,group in ipairs(F.groups) do group:Stop() end
end
function E.RefreshFX(reset)
    local p=E.Profile()
    local active=p and p.enabled and p.fx and p.art and E.state and E.state.world and not E.state.loading
        and not E.state.hidden and not E.state.Preview() and E.Call(UnitIsDeadOrGhost,'player')==false
    if not active then E.StopFX();return end
    if reset then F.attempts=0 end
    if F.class and F.class~=E.class then E.StopFX();F.built=false;F.groups={} end
    if not F.built then
        if E.InCombat() then return end
        if not build() then
            if not F.retry and F.attempts<8 then
                F.attempts=F.attempts+1
                F.retry=C_Timer.NewTimer(.25,function()F.retry=nil;E.RefreshFX(false)end)
            end
            return
        end
    end
    F.active=true;events:RegisterEvent('PLAYER_SWING')
end
function E.CastMotion(kind)
    if kind=='cancel' then if F.cast then F.cast:Stop() end;return end
    if not F.active then return end
    if kind=='start' then F.cast:Stop();F.cast:Play()
    elseif kind=='success' then F.cast:Stop();F.success:Stop();F.success:Play() end
end
events:SetScript('OnEvent',function(_,_,timestamp,hand)
    if not F.active or not E.LayoutVisible() or not E.Number(timestamp) or not E.Readable(hand)
        or (hand~=0 and hand~=1 and hand~=2) then return end
    if hand==1 and E.class=='WARRIOR' and not E.dualSwing then return end
    local now=GetTime()
    if F.lastSwing and now-F.lastSwing<.14 then return end
    F.lastSwing=now
    F.left:Stop();F.right:Stop();F.left:Play();F.right:Play()
end)
