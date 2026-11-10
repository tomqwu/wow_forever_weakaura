dofile('tests/core.lua')
local E=EclipseHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/EclipseHUD/Catalog.lua'))('EclipseHUD',E)
GetLocale=function()return 'zhCN'end
assert(loadfile('src/EclipseHUD/Locale.lua'))('EclipseHUD',E)
E.panel=nil
UnitClass=function()return 'Warrior','WARRIOR'end
E.InitDB();E.Reset();E.ToggleOptions()
check(E.panel.checks.fx.Text.text=='战斗特效' and E.panel.checks.alerts.Text.text=='声音提示','Chinese controls are authored through locale boundary')
E.panel.school.scripts.OnClick()
check(E.Profile().school=='Arms' and E.panel.school.text:find('武器',1,true),'Actual school control chooses and localizes Arms')
E.panel.school.scripts.OnClick();check(E.Profile().school=='Fury','Manual school selection persists')
E.panel.swing.scripts.OnClick();check(E.Profile().swingMode=='Single','Actual swing selector cycles')
E.panel.checks.unfold:SetChecked(false);E.panel.checks.unfold.scripts.OnClick(E.panel.checks.unfold)
check(not E.Profile().unfold,'Unfold has an independent control')
UnitClass=function()return 'Warlock','WARLOCK'end
E.InitDB();E.RefreshOptions()
check(E.Profile().school=='Auto' and not E.panel.swing.shown and not E.panel.checks.cleave.shown,'Class adaptation hides Warrior-only controls')
E.panel.school.scripts.OnClick();check(E.Profile().school=='Affliction','Warlock has its own three-school selector')
for _,schools in pairs(E.schools)do for _,name in ipairs(schools)do check(E.L(name)~=name,'Every authored talent-school label is translated')end end
print('Settings/locale checks passed: '..checks)
