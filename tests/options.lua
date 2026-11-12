dofile('tests/core.lua')
local E=ForeverHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/ForeverHUD/Catalog.lua'))('ForeverHUD',E)
GetLocale=function()return 'zhCN'end
assert(loadfile('src/ForeverHUD/Locale.lua'))('ForeverHUD',E)
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
E.panel.cooldown.scripts.OnClick();check(E.Profile().cooldownLayout=='Class plan' and E.panel.cooldown.text:find('职业方案',1,true),'Cooldown layout has a localized independent control')
E.Set('castBarMode','Default');E.panel.castChoice.scripts.OnClick()
check(E.Profile().castBarMode=='ForeverHUD' and E.Profile().hideDefaultCast and E.panel.castChoice.text:find('ForeverHUD',1,true),'Localized cast selector chooses ForeverHUD exclusively')
E.panel.castChoice.scripts.OnClick();check(E.Profile().castBarMode=='Both' and not E.Profile().hideDefaultCast,'Cast selector explicitly supports both bars')
-- 0.9: the panel shows whether the auras the addon ships are installed.
local installed={}
ForeverAuras.GetData=function(id)return installed[id]end
ForeverAurasSaved={displays={}}
E.RefreshOptions()
check(E.panel.install.shown and E.panel.auraStatus.text:find('ForeverHUD | Core',1,true) and E.panel.auraStatus.text:find('ForeverHUD | Warlock',1,true),
    'Missing Core and class auras show in red with an install button')
local core,warlock=E.bundledImports.CORE,E.bundledImports.WARLOCK
installed['ForeverHUD | Core']={id='ForeverHUD | Core',url='https://wago.io/forever-hud-core/'..core.build}
installed['ForeverHUD | Warlock']={id='ForeverHUD | Warlock',url='https://wago.io/forever-hud-warlock/'..(warlock.build-1)}
E.RefreshOptions()
check(E.panel.install.shown and E.panel.auraStatus.text:find('0.9',1,true) and not E.panel.auraStatus.text:find('Core',1,true),'An older class group is reported; a current Core is not')
installed['ForeverHUD | Warlock'].url='https://wago.io/forever-hud-warlock/'..warlock.build
E.RefreshOptions()
check(not E.panel.install.shown and E.panel.auraStatus.text=='光环已是最新','Current auras: no button, localized all-clear')
check(E.panel.checks.suggest and E.panel.checks.tray,'New modules have controls')
print('Settings/locale checks passed: '..checks)
