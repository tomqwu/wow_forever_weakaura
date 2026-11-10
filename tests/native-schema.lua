-- Validate with FA's OWN validators when a source directory is supplied.
-- Rendering and the WoW protected environment remain outside this test.
local source=arg[1]
assert(source,"Usage: lua tests/native-schema.lua FOREVERAURAS_SOURCE_DIR")
local noop=function()end
local function frame()
    return setmetatable({}, {__index=function(_,key)
        if key=="CreateTexture" or key=="CreateFontString" then return frame end
        return noop
    end})
end
CreateFrame=frame;hooksecurefunc=noop
UIParent=frame();C_Timer={After=noop,NewTicker=noop,NewTimer=noop}
C_NamePlate={GetNamePlateForUnit=noop}
Enum=setmetatable({}, {__index=function(t,k)local v={};rawset(t,k,v);return v end})
Enum.LuaCurveType.Step=1
Enum.DurationTextBindingProperty.RemainingDuration=1
C_CurveUtil={CreateColorCurve=frame}
CreateColor=frame
GetLocale=function()return "enUS"end
GetScreenWidth=function()return 1920 end
GetScreenHeight=function()return 1080 end
GetTime=function()return 0 end
InCombatLockdown=function()return false end
issecretvalue=function()return false end
CopyTable=function(t)local c={};for k,v in pairs(t)do c[k]=type(v)=="table" and CopyTable(v) or v end;return c end
wipe=function(t)for k in pairs(t)do t[k]=nil end;return t end
strsplit=function()end
local media={Fetch=function()return "Fonts\\FRIZQT__.TTF"end}
LibStub=function(name,optional)if optional then return nil end;return media end
local L=setmetatable({}, {__index=function(_,key)return key end})
WeakAuras={newFeatureString='',IsLibsOK=function()return true end,L=L,IsOptionsOpen=function()return false end,RegisterRegionType=noop,RegisterSubRegionType=noop}
ForeverAuras=WeakAuras
local P={frames={},regions={},callbacks=frame(),ExecEnv={},memoryRootAccessors={},subRegionTypes={subtext={default=function()return {}end}}}
P.TimedAPI=function()return CreateFrame,noop,noop,C_Timer end
P.Profiled=function(_,fn)return fn end
local function load(name)assert(loadfile(source.."/"..name..".lua"))("ForeverAuras",P)end
load("BlizzardAuraDisplay")
load("SecretAuraAppearance")
load("SecretAuraSingle")
load("SecretAuraConditions")
load("SecretAuraFlow")
local D=P.BlizzardAuraDisplay
local data=dofile("dist/Eclipse-Class-Combat-HUD.lua")
local saved={[data.d.id]=data.d}
for _,d in ipairs(data.c)do saved[d.id]=d end
WeakAuras.GetData=function(id)return saved[id]end
local count=0
for _,d in ipairs(data.c)do
    if d.triggers[1].trigger.type=="secretAura" then
        local problem=D.Validate(d)
        assert(problem==nil,d.id..": "..tostring(problem));count=count+1
        assert(D.FallbackChoice(d)=='none',d.id..': modern aura may not follow the always-true gate')
        assert(D.FoundFollow(d)==nil,d.id..': inactive aura may not become a fallback icon')
        if d.triggers[1].trigger.unit=='player' and d.triggers[1].trigger.secretShowOn=='showOnActive' and not d.triggers[1].trigger.secretUseRem then
            local broken=CopyTable(d)
            broken.triggers.secretFallback=nil;broken.secretFallback='none'
            -- Reproduce v0.2.0's actual semantic bug using FA's own selector.
            assert(D.FoundFollow(broken)=='next','Expected old misplaced setting to follow visibility trigger')
        end
    end
end
assert(count>50,"No native aura coverage")
print("ForeverAuras' native schema validator passed: "..count.." modern displays")
load('Conditions')
local power=P.ExecEnv.PowerCurve
assert(power,'Native resource-curve support is required')
local secret={}
issecretvalue=function(v)return rawequal(v,secret)end
hasanysecretvalues=function(...)for i=1,select('#',...)do if issecretvalue(select(i,...))then return true end end;return false end
UnitPowerMax=function()return secret end
UnitPowerPercent=function(_,_,_,curve)assert(curve);return secret end
C_CurveUtil.CreateCurve=function()return {SetType=noop,AddPoint=noop}end
local ctx=power.Begin({show=true,unit='player',powertype=1,total=secret},'power')
local ops={}
for _,d in ipairs(data.c)do
    if d.id:find('FX resource intensity',1,true)then
        for _,condition in ipairs(d.conditions)do
            local c=condition.check
            ops[#ops+1]={power.Leaf(ctx,c.variable,c.op,c.value),condition.changes[1].value}
        end
        break
    end
end
assert(#ops==3,'Resource intensity has native curve conditions')
assert(rawequal(power.Evaluate(ctx,power.Pieces(0,ops)),secret),'Native curve result must pass through without inspection')
print('Actual ForeverAuras resource-curve path accepted restricted state')

-- Compile and run the actual FA condition code for a form-changing bar.
-- Trigger/property metadata is a fixture; condition evaluation is FA's code.
local resource=saved['Eclipse | Druid | Resource']
P.regionTypes={aurabar={properties={barColor={type='color',setter='Color'}}}}
P.GetTriggerConditions=function()return {[1]={powertype={type='select'}}}end
P.GetGlobalConditions=function()return {}end
P.ExecEnv.conditionHelpers={}
P.AuraWarnings={UpdateWarning=noop}
local active={}
WeakAuras.GetActiveConditions=function()return active end
P.LoadFunction=function(code)
    local fn=assert(loadstring(code))
    setfenv(fn,setmetatable({Private=P},{__index=_G}))
    return fn()
end
P.LoadConditionFunction(resource)
local condition=P.memoryRootAccessors['Conditions: checkConditions']()[resource.uid]
assert(condition,'No compiled native color conditions')
local region={id=resource.id,states={[1]={show=true,power=secret,total=secret}},
    Color=function(self,...)self.color={...}end}
for _,kind in ipairs({0,3,1,0}) do
    region.states[1].powertype=kind
    condition(region,false)
    local expected
    for _,rule in ipairs(resource.conditions)do if rule.check.value==kind then expected=rule.changes[1].value end end
    for i=1,4 do assert(math.abs(region.color[i]-expected[i])<1e-12,'Native resource color failed during form change') end
end
region.states[1].powertype=secret
condition(region,false)
for i=1,4 do assert(math.abs(region.color[i]-resource.barColor[i])<1e-12,'Restricted resource identity must restore neutral color')end
print('Actual ForeverAuras color conditions passed mana/energy/rage transitions with restricted amounts')
