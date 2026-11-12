dofile('tests/state.lua')
local E=ForeverHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local now=1
function GetTime()return now end
local create=CreateFrame
function CreateFrame(...)
    local frame=create(...)
    frame.HookScript=function(self,key,fn)self.scripts[key]=fn end
    local makeTexture=frame.CreateTexture
    frame.CreateTexture=function(self,...)
        local t=makeTexture(self,...)
        t.SetTexture=function()end;t.SetBlendMode=function()end;t.SetAlpha=function()end
        t.CreateAnimationGroup=function()
            local g={count=0}
            function g:SetLooping()end
            function g:Play()self.playing=true;self.count=self.count+1 end
            function g:Stop()self.playing=false end
            function g:CreateAnimation()return setmetatable({}, {__index=function()return function()end end})end
            return g
        end
        return t
    end
    return frame
end
local regions,ready={},false
ForeverAuras.GetRegion=function(id)
    if not ready then return end
    regions[id]=regions[id] or CreateFrame('Frame');return regions[id]
end
assert(loadfile('src/ForeverHUD/Effects.lua'))('ForeverHUD',E)
local F=E.effects
E.state.world=true;E.state.open=true;E.Profile().fx=true;E.Profile().art=true
for i=1,9 do E.RefreshFX(false);if F.retry then local t=F.retry;t.callback()end end
check(F.attempts==8 and not F.retry,'Missing attachment retries stop after eight attempts')
ready=true;E.RefreshFX(true)
check(F.built and F.active and F.events.events.PLAYER_SWING,'Late binding creates ordinary effects and actual-swing observer')
E.CastMotion('start');check(F.cast.playing,'Actual cast start runs decorative cast motion')
E.CastMotion('cancel');check(not F.cast.playing and not F.success.playing,'Interrupted cast stops with no success pulse')
E.CastMotion('success');check(F.success.playing,'Verified completion invokes success pulse')
F.events.scripts.OnEvent(nil,'PLAYER_SWING',1,0);local count=F.left.count
F.events.scripts.OnEvent(nil,'PLAYER_SWING',1,1)
check(count==1 and F.left.count==1,'Simultaneous hands merge one real-swing pulse')
now=2;F.events.scripts.OnEvent(nil,'PLAYER_SWING',0,0)
check(F.left.count==1,'Invalid swing event cannot invent a pulse')
E.Set('fx',false)
check(not F.active and not F.events.events.PLAYER_SWING and not F.retry,'Master disable cancels listener and retries')
for _,group in ipairs(F.groups)do check(not group.playing,'Master disable stops ordinary native groups')end

-- Fresh login with Cast disabled: no cast/seal region is required for swings.
E.Profile().fx=true;E.Profile().cast=false;E.Profile().resources=true;E.state.open=true
local health,power=CreateFrame('Frame'),CreateFrame('Frame')
local cast,seal=CreateFrame('Frame'),CreateFrame('Frame')
local queriedCast=false
ForeverAuras.GetRegion=function(id)
    if id:match(' | Health$')then return health end
    if id:match(' | Resource$')then return power end
    queriedCast=true
end
assert(loadfile('src/ForeverHUD/Effects.lua'))('ForeverHUD',E)
F=E.effects;E.RefreshFX(true)
check(F.built and F.left and F.right and not F.cast and not queriedCast,'Resource FX build without disabled cast/seal dependencies')
check(not F.retry and #F.groups==2,'Disabled widgets consume no attachment retry or animation allocation')

-- Enable only Cast. Existing resource bindings pause instead of recreating.
E.Profile().cast=true;E.Profile().resources=false
ForeverAuras.GetRegion=function(id)
    if id:match(' | Cast$')then return cast end
    if id:match(' | Seal$')then return seal end
end
E.RefreshFX(false);E.CastMotion('start')
check(F.built and F.cast.playing and not F.retry,'Cast FX build without resource regions')
check(not F.bindings.left.frame.shown and not F.events.events.PLAYER_SWING,'Resources off hides trim and removes real-swing listener')

-- Reuse the owned frames if FA replaces an ordinary host during reimport.
local replacement=CreateFrame('Frame')
E.Profile().resources=true
ForeverAuras.GetRegion=function(id)
    if id:match(' | Health$')then return replacement end
    if id:match(' | Resource$')then return power end
    if id:match(' | Cast$')then return cast end
    if id:match(' | Seal$')then return seal end
end
local owned=F.bindings.left.frame
InCombatLockdown=function()return true end
E.RefreshFX(false)
check(owned.parent==health and not F.bindings.left.active,'Combat defers cosmetic ancestry replacement')
InCombatLockdown=function()return false end
E.RefreshFX(false)
check(owned.parent==replacement and #F.groups==4,'After combat, reimport reuses bounded owned frames')
now=3;F.events.scripts.OnEvent(nil,'PLAYER_SWING',1,0)
health.scripts.OnHide()
check(F.left.playing,'Former host hook cannot stop the replacement host effect')
replacement.scripts.OnHide();check(not F.left.playing,'Current host hide stops its ordinary effect')
E.Profile().cast=false;E.Profile().resources=false;E.RefreshFX(false)
check(F.built and not F.retry and not F.events.events.PLAYER_SWING,'All optional hosts disabled need no timer or event observer')
for _,binding in pairs(F.bindings)do check(not binding.active and not binding.frame.shown,'Disabled module leaves no ordinary effect frame')end
print('Effect lifecycle checks passed: '..checks)
