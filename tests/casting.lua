dofile('tests/core.lua')
local E=EclipseHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/EclipseHUD/Discovery.lua'))('EclipseHUD',E)
function hooksecurefunc(object,key,hook)
    local original=object[key]
    object[key]=function(...)local result=original(...);hook(...);return result end
end
local function bar(value)
    local b={showCastbar=value,shown=value,scripts={}}
    function b:Hide()self.shown=false end
    function b:Show()self.shown=true;if self.scripts.OnShow then self.scripts.OnShow(self)end end
    function b:HookScript(key,fn)self.scripts[key]=fn end
    function b:SetAndUpdateShowCastbar(show)self.showCastbar=show;if show then self:Show()else self:Hide()end end
    return b
end
PlayerCastingBarFrame=bar(true)
ForeverAuras.GetData=function()return {}end
assert(loadfile('src/EclipseHUD/Casting.lua'))('EclipseHUD',E)
E.Reset();E.Set('hideDefaultCast',true)
local C=E.casting
check(not PlayerCastingBarFrame.showCastbar and C.owners.EclipseHUD,'Optional ownership suppresses default bar')
PlayerCastingBarFrame:SetAndUpdateShowCastbar(true)
check(not PlayerCastingBarFrame.showCastbar,'Edit/crafting re-enable is suppressed while owned')
GamepadPlayerCastingBarFrame=bar(true);C.events.scripts.OnEvent(nil,'ADDON_LOADED','Gamepad')
check(not GamepadPlayerCastingBarFrame.showCastbar,'Late-loaded gamepad bar acquired')
C.Acquire('AnotherAddon');E.Set('hideDefaultCast',false)
check(not PlayerCastingBarFrame.showCastbar,'Other cooperating owner retains suppression')
C.Release('AnotherAddon')
check(PlayerCastingBarFrame.showCastbar and GamepadPlayerCastingBarFrame.showCastbar,'Final release restores original request')
E.Set('hideDefaultCast',true);PlayerCastingBarFrame:SetAndUpdateShowCastbar(false);E.Set('hideDefaultCast',false)
check(PlayerCastingBarFrame.showCastbar==false,'Latest external suppression request is retained')
local effects={}
E.CastMotion=function(kind)effects[#effects+1]=kind end
C_Timer.NewTimer=function(_,fn)return {callback=fn,Cancel=function(self)self.cancelled=true end}end
C.CastEvent('UNIT_SPELLCAST_START','player','one')
C.CastEvent('UNIT_SPELLCAST_SUCCEEDED','player','other')
check(not C.finish,'Different cast GUID cannot trigger completion')
C.CastEvent('UNIT_SPELLCAST_SUCCEEDED','player','one');C.finish.callback()
check(effects[#effects]=='success' and not C.cast,'Observed start plus matching success pulses')
C.CastEvent('UNIT_SPELLCAST_SUCCEEDED','player','instant');check(not C.finish,'Unstarted instant cast does not fake cast completion')
C.CastEvent('UNIT_SPELLCAST_START','player','two');C.CastEvent('UNIT_SPELLCAST_FAILED','player','two')
check(effects[#effects]=='cancel' and not C.cast,'Failed cast cancels decoration')
C.CastEvent('UNIT_SPELLCAST_CHANNEL_START','player','channel');C.CastEvent('UNIT_SPELLCAST_SUCCEEDED','player','channel')
check(not C.finish,'Channel start success is not completion')
C.CastEvent('UNIT_SPELLCAST_CHANNEL_STOP','player','channel');local finish=C.finish
C.CastEvent('UNIT_SPELLCAST_INTERRUPTED','player','channel')
check(finish.cancelled and effects[#effects]=='cancel','Interrupted channel cannot play completion pulse')
C.CastEvent('UNIT_SPELLCAST_START','pet','petcast');check(not C.cast,'Pet casts do not drive player effect')
E.StopCasting();check(not C.active and not next(C.events.events),'Stop unregisters cast observers')
print('Cast ownership/event checks passed: '..checks)
