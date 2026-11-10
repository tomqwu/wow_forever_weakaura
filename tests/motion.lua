dofile('tests/state.lua')
local E=EclipseHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local now=0
function GetTime()return now end
local frames={}
local function animation()
    return setmetatable({values={}}, {__index=function(_,key)return function(self,... )self.values[key]={...}end end})
end
ForeverAuras.GetRegion=function(id)
    if not frames[id] then
        frames[id]={SetOffsetAnim=function(self,x,y)self.x,self.y=x,y end,
            SetAnimAlpha=function(self,a)self.alpha=a end,
            CreateAnimationGroup=function(self)
                local group={scripts={},parts={}}
                function group:CreateAnimation(kind)local a=animation();a.kind=kind;self.parts[#self.parts+1]=a;return a end
                function group:SetScript(key,fn)self.scripts[key]=fn end
                function group:Play()self.playing=true end
                function group:Stop()self.playing=false end
                self.group=group;return group
            end}
    end
    return frames[id]
end
assert(loadfile('src/EclipseHUD/Motion.lua'))('EclipseHUD',E)
local M=E.motion
E.Profile().primary=true;E.Profile().resources=true;E.Profile().unfold=true
E.selection={positions={first={x=-83,side=1,slot=1},last={x=-224,side=1,slot=4}}}
E.state.open=false;M.Change(false,true)
check(frames.first.alpha==0 and frames.first.x==83,'Closed baseline retracts ordinary icons')
E.state.open=true;M.Change(true,false)
check(E.state.transition and frames.first.group.playing,'Opening uses native animation group')
check(M.Curve(.0325,true,1,4)>0 and M.Curve(.0325,true,2,4)==0,'65ms forward stagger')
check(M.Curve(.0325,false,1,4)==0 and M.Curve(.0325,false,4,4)>0,'Closing reverses stagger')
check(M.Curve(.28,true,1,4)==1,'280ms smoothstep movement')
now=.14;local mid,alpha=M.Sample(M.entries.first,now)
check(math.abs(mid-.5)<.0001 and math.abs(alpha-.5)<.0001,'Mid-transition sample matches smoothstep')
M.Change(false,false)
check(math.abs(M.entries.first.transition.from-.5)<.0001,'Interrupted close starts from current position')
check(math.abs(M.entries.first.transition.alpha-.5)<.0001,'Interrupted close preserves current opacity')
local resource=M.entries['Eclipse | Warlock | Health']
M.Change(true,false);check(resource.transition.alpha==1,'Opening resources remain visible while sliding')
now=1
for _,item in pairs(M.entries)do item.group.scripts.OnFinished()end
M.finish.callback()
check(not E.state.transition and not M.finish and frames.first.x==0 and frames.first.alpha==nil,'Settled animation restores normal offsets and alpha with no timer')
E.Profile().unfold=false;M.Change(false,false)
check(not M.finish and frames.first.alpha==0,'Animation-off commits immediately')
E.Profile().unfold=true;M.Change(true,false);local finish=M.finish;M.Stop()
check(finish.cancelled and not next(M.entries) and frames.first.x==0 and frames.first.alpha==nil,'Stop cancels clock and restores ordinary regions')
print('Unfold motion checks passed: '..checks)
