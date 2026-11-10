-- Execute generated callbacks against the old-helper situation in General.log.
local pack=dofile('dist/Eclipse-Class-Combat-HUD.lua')
local checked=0
for _,helper in ipairs({false,{Gate=function()return true end,L=function(s)return s end}})do
    local env=setmetatable({EclipseHUD=helper or nil,print=function()end},{__index=_G})
    local function run(code,expression)
        if type(code)~='string' or not code:find('EclipseHUD',1,true)then return end
        local fn=assert(loadstring(expression and 'return '..code or code));setfenv(fn,env)
        local value=fn()
        if expression then value=value();assert(value~=true,'Old helper must never open a native tracker')end
        checked=checked+1
    end
    for _,d in ipairs(pack.c)do
        for _,a in pairs(d.actions)do run(a.custom,false)end
        for key,t in pairs(d.triggers)do if type(key)=='number'then run(t.trigger.custom,true)end end
        run(d.customText,true);run(d.customSort,true)
    end
    run(pack.d.actions.init.custom,false)
end
assert(checked>1000,'Missing generated bridge coverage')
print('Old/missing companion bridge checks passed: 2 scenarios ('..checked..' callbacks)')
