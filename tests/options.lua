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
-- 0.14.6: the Display page's frame style button flips Bars and Globes; /fhud style sets it.
check(E.panel.frameStyle.text:find('条形',1,true),'Frame style shows the localized current style')
E.panel.frameStyle.scripts.OnClick();check(E.Profile().frameStyle=='Globes' and E.panel.frameStyle.text:find('球形',1,true),'Frame style button switches to Globes')
E.panel.frameStyle.scripts.OnClick();check(E.Profile().frameStyle=='Bars','and back to Bars')
SlashCmdList.FOREVERHUD('style globes');check(E.Profile().frameStyle=='Globes','/fhud style globes')
SlashCmdList.FOREVERHUD('style bars');check(E.Profile().frameStyle=='Bars','/fhud style bars')
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
check(E.panel.install.shown and E.panel.auraStatus.text:find(warlock.version,1,true) and not E.panel.auraStatus.text:find('Core',1,true),'An older class group is reported; a current Core is not')
installed['ForeverHUD | Warlock'].url='https://wago.io/forever-hud-warlock/'..warlock.build
E.RefreshOptions()
check(not E.panel.install.shown and E.panel.auraStatus.text=='光环已是最新','Current auras: no button, localized all-clear')
check(E.panel.checks.suggest and E.panel.checks.tray,'New modules have controls')
-- 0.13.19: /fhud perf reads the client's add-on profiler and the counters.
do
    local lines,oldPrint={},print
    print=function(text)lines[#lines+1]=text end
    Enum=Enum or {};Enum.AddOnProfilerMetric={SessionAverageTime=0,RecentAverageTime=1,PeakTime=3}
    C_AddOnProfiler={GetAddOnMetric=function(name,metric)return name=='ForeverHUD' and ({[0]=.05,[1]=.04,[3]=2.5})[metric] or .5 end}
    E.perf.refresh,E.perf.notify,E.perf.skipped,E.perf.events=3,7,40,{SPELLS_CHANGED=2,PLAYER_EQUIPMENT_CHANGED=1}
    SlashCmdList.FOREVERHUD('perf')
    print=oldPrint
    local text=table.concat(lines,'\n')
    check(text:find('ForeverHUD',1,true) and text:find('ForeverAuras',1,true) and text:find('3',1,true) and text:find('SPELLS_CHANGED 2',1,true),'/fhud perf prints CPU time, counters and the events behind rescans')
    check(E.perf.refresh==0 and E.perf.notify==0 and not next(E.perf.events),'Each report starts a new count')
    C_AddOnProfiler=nil
end
-- 0.14.1: sidebar categories with icons, one page each.
do
    local p=E.panel
    local order={'General','Display','Reminders','Combat','Layout','Minimap'}
    for _,key in ipairs(order) do
        check(p.tabs[key] and p.sections[key] and p.tabs[key].icon.texture and p.tabs[key].icon.texture:find('^Interface\\Icons\\'),
            'Category '..key..' has a sidebar tab with a native icon and a page')
        check(E.L(key)~=key,'Category '..key..' is translated')
    end
    p.Select('Combat')
    check(p.current=='Combat' and p.sections.Combat.shown and not p.sections.General.shown and p.tabs.Combat.selected.shown
        and not p.tabs.General.selected.shown,'Choosing a category shows only its page and marks its tab')
    p.tabs.Minimap.scripts.OnClick(p.tabs.Minimap)
    check(p.sections.Minimap.shown and p.minimapChecks.show and p.minimapChecks.group,'The Minimap page holds the minimap settings')
    -- This panel was built for a Warrior, so the Warlock/Hunter-only reminders are absent.
    check(not p.checks.petMissing and p.checks.oil.parent==p.sections.Reminders and p.checks.fedMissing.parent==p.sections.Reminders
        and p.checks.alerts.parent==p.sections.Reminders and p.checks.fx.parent==p.sections.Display
        and p.checks.cleave.parent==p.sections.Combat and p.sliders.scale.parent==p.sections.Layout,
        'Controls sit on the page for their purpose')
    check(p.crest.texture=='Interface\\AddOns\\ForeverHUD\\Media\\crest-warlock' and p.version.text=='v'..E.releaseVersion,
        'The header shows the class crest and the version')
end
print('Settings/locale checks passed: '..checks)
