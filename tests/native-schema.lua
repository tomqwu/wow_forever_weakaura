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
WeakAuras={IsLibsOK=function()return true end,L=L,IsOptionsOpen=function()return false end,RegisterRegionType=noop,RegisterSubRegionType=noop}
ForeverAuras=WeakAuras
local P={frames={},regions={},callbacks=frame(),memoryRootAccessors={},subRegionTypes={subtext={default=function()return {}end}}}
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
    end
end
assert(count>50,"No native aura coverage")
print("ForeverAuras' native schema validator passed: "..count.." modern displays")
