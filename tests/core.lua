-- Behaviour checks for the actual companion source; no game process is used.
local checks=0
local function check(value,message) checks=checks+1;assert(value,message) end
local secret=setmetatable({}, {__tostring=function()error("Secret inspected")end})
local class,combat,locale="WARLOCK",false,"enUS"
local flags,timers,scans={},{},0
local Frame={}
Frame.__index=Frame
function Frame:SetSize(w,h)self.width,self.height=w,h end
function Frame:SetPoint(...)self.point={...}end
function Frame:ClearAllPoints()self.point=nil end
function Frame:SetScale(scale)self.scale=scale end
function Frame:SetParent(parent)self.parent=parent end
function Frame:SetAnchor(...)self.nativeAnchor={...}end
function Frame:SetOffset(x,y)self.nativeOffset={x,y}end
function Frame:SetRegionAlpha(alpha)self.alpha=alpha end
function Frame:SetShown(show)if show then self:Show() else self:Hide()end end
function Frame:Hide()local shown=self.shown;self.shown=false;if shown and self.scripts.OnHide then self.scripts.OnHide(self)end end
function Frame:Show()local shown=self.shown;self.shown=true;if not shown and self.scripts.OnShow then self.scripts.OnShow(self)end end
function Frame:IsShown()return self.shown end
function Frame:SetScript(key,callback)self.scripts[key]=callback end
function Frame:RegisterEvent(event)self.events[event]=true end
function Frame:UnregisterEvent(event)self.events[event]=nil end
function Frame:CreateTexture()return setmetatable({scripts={},events={}},Frame)end
Frame.CreateFontString=Frame.CreateTexture
function Frame:SetHeight(value)self.height=value end
function Frame:SetText(value)self.text=value end
function Frame:SetChecked(value)self.checked=value end
function Frame:GetChecked()return self.checked end
function Frame:SetValue(value)self.valueNumber=value;if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,value)end end
function Frame:GetCenter()return self.x or 1000,self.y or 600 end
function Frame:StopMovingOrSizing()self.stopped=true end
for _,key in ipairs({"RegisterForClicks","RegisterForDrag","SetFrameStrata","SetAllPoints","SetColorTexture","SetMovable","SetClampedToScreen","SetBackdrop","SetBackdropColor","SetBackdropBorderColor","StartMoving","SetFont","SetTextColor","SetWidth","SetJustifyH","EnableMouse","SetMinMaxValues","SetValueStep","SetObeyStepOnDrag","SetTexture","SetTexCoord"})do Frame[key]=function()end end
function CreateFrame(_,name,parent,template)
    local frame=setmetatable({scripts={},events={},parent=parent},Frame)
    if template=="UICheckButtonTemplate" then frame.Text=frame:CreateFontString()end
    if template=="OptionsSliderTemplate" then frame.Low=frame:CreateFontString();frame.High=frame:CreateFontString();frame.Text=frame:CreateFontString()end
    if name then _G[name]=frame end
    return frame
end
UIParent=CreateFrame("Frame")
local root=CreateFrame("Frame")
GameTooltip=setmetatable({}, {__index=function()return function()end end})
function GetLocale()return locale end
function UnitClass()return "Class",class end
function InCombatLockdown()return combat end
function issecretvalue(v)return rawequal(v,secret)end
C_Timer={
    After=function(_,callback)callback()end,
    NewTimer=function(_,callback)
        local timer={callback=callback,Cancel=function(self)self.cancelled=true end}
        timers[#timers+1]=timer;return timer
    end,
}
ForeverAuras={
    IsOptionsOpen=function()return false end,
    ScanEvents=function()scans=scans+1 end,
    SetLoadFlag=function(key,value)flags[key]=value end,
    GetRegion=function()return root end,
}
local E={}
assert(loadfile("src/ForeverHUD/Locale.lua"))("ForeverHUD",E)
assert(loadfile("src/ForeverHUD/Core.lua"))("ForeverHUD",E)
E.InitDB();E.Notify()
check(E.Gate("primary","WARLOCK"),"Active class must show")
check(not E.Gate("primary","MAGE"),"Inactive class must not show")
check(flags.FOREVERHUD_WARLOCK_primary,"Active native triggers load")
check(not flags.FOREVERHUD_MAGE_primary,"Inactive native triggers stay unloaded")
check(not flags.FOREVERHUD_WARLOCK_nameplates,"Nameplates are opt-in")
E.Set("primary",false)
check(not E.Gate("primary","WARLOCK"),"Disabled module hides")
check(not flags.FOREVERHUD_WARLOCK_primary,"Disabled module unloads native listeners")
check(flags.FOREVERHUD_WARLOCK_resources,"Other modules remain enabled")
E.Set("nameplates",true);check(flags.FOREVERHUD_WARLOCK_nameplates,"Optional native plates load")
E.Set("scale",1.25);E.Set("x",135);E.Set("y",-230);E.Set("opacity",.65)
check(E.anchor.point[4]==135 and E.anchor.point[5]==-230,"Position persists without scaling coordinates")
check(root.scale==1.25 and root.alpha==.65,"Scale and opacity applied to root")
check(root.parent==E.anchor and root.nativeAnchor[2]==E.anchor and root.nativeOffset[1]==0,"Late native root is attached to companion anchor")
check(E.anchor.scale==nil,"Position anchor stays unscaled")
E.InitDB();check(E.Profile().x==135 and E.Profile().scale==1.25,"Reload defaults preserve saved preferences")
E.ResetPosition();check(E.Profile().x==0 and E.Profile().y==-235 and E.Profile().scale==1.25 and not E.Profile().primary,"Position reset preserves module preferences and scale")
E.Set('x',135);E.Set('y',-230)
class="MAGE";E.InitDB();E.Notify()
check(E.Profile().x==0 and E.Profile().primary,"New class gets own defaults")
-- 0.13.10: weapon reminders default on only for classes that enchant their own weapon.
check(E.Profile().imbue==false and E.Profile().oil==false,"A Mage gets no weapon reminder by default")
check(not flags.FOREVERHUD_MAGE_oil,"An off reminder stays unloaded")
class="ROGUE";E.InitDB();E.Notify()
check(E.Profile().oil==true and E.Profile().imbue==false and flags.FOREVERHUD_ROGUE_oil,"Rogue poison reminder is on by default")
E.Set("oil",false);E.InitDB();check(E.Profile().oil==false and not flags.FOREVERHUD_ROGUE_oil,"Turning a weapon reminder off persists and unloads it")
E.Profile().oil=nil;E.InitDB();check(E.Profile().oil==true,"A missing value gets the class default")
class="MAGE";E.InitDB();E.Notify()
check(flags.FOREVERHUD_MAGE_primary and not flags.FOREVERHUD_WARLOCK_primary,"Login switches loaded modules")
class="WARLOCK";E.InitDB();E.Notify()
check(E.Profile().x==135 and not E.Profile().primary,"Returning class restores its settings")
check(E.Profile().imbue==true and E.Profile().oil==false and flags.FOREVERHUD_WARLOCK_imbue,"An existing Warlock profile gains the Firestone reminder, oil off")
E.ApplyLayout() -- the Rogue checks above applied that class's layout
combat=true;E.Set("x",999);E.Set("scale",1.4);E.Set("enabled",false)
check(E.Profile().x==135 and E.Profile().scale==1.25 and E.Profile().enabled,"Combat changes are deferred")
check(root.scale==1.25 and E.anchor.point[4]==135,"No combat writes to native ancestry")
combat=false;E.events.scripts.OnEvent(nil,"PLAYER_REGEN_ENABLED")
check(E.Profile().x==999 and E.Profile().scale==1.4 and not E.Profile().enabled,"Queued preferences flush after combat")
check(not flags.FOREVERHUD_WARLOCK_primary and not flags.FOREVERHUD_WARLOCK_resources,"Disable unloads modules")
check(not E.handle.shown,"Disabled helper handle hides")
E.Reset();E.Set("combatOnly",true)
check(not E.Gate("base","WARLOCK"),"Combat mode hides outside combat")
check(not E.handle.shown,"Combat-only mode has no invisible input surface outside combat")
combat=true;check(E.Gate("base","WARLOCK"),"Combat mode shows in combat")
E.Notify();check(E.handle.shown,"Independent input surface can show when combat starts")
combat=secret;check(E.InCombat(),"Unreadable lockdown treated as restricted")
combat=false;E.Set("combatOnly",false);E.Set("hoverUtility",true)
check(not E.Gate("utility","WARLOCK"),"Hover utility starts collapsed")
E.Hover(true);check(E.Gate("utility","WARLOCK"),"Center hover expands utility")
E.Hover(false);check(E.Gate("utility","WARLOCK"),"Leave has a grace period")
local timer=timers[#timers];E.Shutdown()
check(timer.cancelled,"World leave cancels hover timer")
check(not E.handle.shown and not E.hovering,"World leave removes interactive control")
check(not flags.FOREVERHUD_WARLOCK_resources,"World leave unloads native trackers")
E.Set("art",false);check(not flags.FOREVERHUD_WARLOCK_motion,"Artwork off also stops rune animation")
check(not E.handle.shown,"Locked invisible artwork leaves no click target")
E.Reset();check(E.Profile().art and E.Profile().primary and E.Profile().x==0,"Reset is scoped and restores defaults")
class="MAGE";E.InitDB();check(E.Profile().x==0,"Reset does not copy another class layout")
E.Profile().scale=0/0;E.Profile().opacity=math.huge;E.InitDB()
check(E.Profile().scale==1 and E.Profile().opacity==1,"Malformed numeric settings repaired")
E.Profile().resources="broken";E.InitDB();check(E.Profile().resources==true,"Wrong preference types repaired")
class=secret;E.InitDB();check(E.Profile()==nil,"Restricted class identity never becomes table key")
locale="zhTW";local TW={};assert(loadfile("src/ForeverHUD/Locale.lua"))("ForeverHUD",TW)
check(TW.L("Warlock")=="术士","A Traditional Chinese client gets the Chinese labels")
locale="zhCN";local Z={};assert(loadfile("src/ForeverHUD/Locale.lua"))("ForeverHUD",Z)
check(Z.L("Warlock")=="术士" and Z.L("Target effects")=="目标持续效果","Chinese labels")
check(E.L("Warlock")=="Warlock","English labels")
class="WARLOCK";E.InitDB();UISpecialFrames={};SlashCmdList={}
assert(loadfile("src/ForeverHUD/Options.lua"))("ForeverHUD",E)
E.ToggleOptions()
check(E.panel:IsShown() and E.panel.classLabel.text:find("Warlock"),"Actual settings panel opens for current class")
E.panel.checks.resources:SetChecked(false);E.panel.checks.resources.scripts.OnClick(E.panel.checks.resources)
check(not E.Profile().resources,"Actual settings checkbox changes module")
E.panel.sliders.scale:SetValue(1.2)
check(math.abs(E.Profile().scale-1.2)<0.0001,"Actual settings slider changes layout")
E.ToggleOptions();check(not E.panel:IsShown(),"Settings panel closes")
check(E.panel.checks.imbue and E.panel.checks.oil,"Warlock settings list both weapon reminders")
-- 0.13.10: the minimap addon-list entry (TOC AddonCompartmentFunc).
ForeverHUD_OnAddonCompartmentClick("ForeverHUD","LeftButton");check(E.panel:IsShown(),"Minimap entry left-click opens settings")
ForeverHUD_OnAddonCompartmentClick("ForeverHUD","LeftButton");check(not E.panel:IsShown(),"and closes them")
ForeverHUD_OnAddonCompartmentEnter("ForeverHUD",E.anchor);ForeverHUD_OnAddonCompartmentLeave()
do
    local toc=io.open("src/ForeverHUD/ForeverHUD.toc"):read("*a")
    for _,name in ipairs({"Click","Enter","Leave"}) do
        local fn=toc:match("## AddonCompartmentFunc"..(name=="Click" and "" or "On"..name)..": (%S+)")
        check(fn and type(_G[fn])=="function","TOC names the "..name.." handler")
    end
end
-- 0.13.6: a page in the game's Options -> AddOns list with the size slider.
E.RegisterGameOptions();check(E.gameOptions==nil,'Without the Settings API nothing is registered')
local registered
Settings={RegisterCanvasLayoutCategory=function(frame,name)return {frame=frame,name=name}end,RegisterAddOnCategory=function(category)registered=category end}
E.RegisterGameOptions();E.RegisterGameOptions()
check(registered and registered.name=='ForeverHUD' and registered.frame==E.gameOptions.page,'ForeverHUD registers one page in the game AddOns options')
E.gameOptions.page.scripts.OnShow(E.gameOptions.page)
check(E.gameOptions.slider.valueNumber==E.Profile().scale and E.gameOptions.slider.value.text=='120%','The game page shows the current size')
E.gameOptions.slider:SetValue(1.3)
check(math.abs(E.Profile().scale-1.3)<0.0001 and root.scale==E.Profile().scale and E.gameOptions.slider.value.text=='130%','The game page size slider resizes the HUD')
E.gameOptions.slider:SetValue(1.2);Settings=nil
SlashCmdList.FOREVERHUD('60%');check(math.abs(E.Profile().scale-.6)<0.0001,'/fhud 60% sets the size')
SlashCmdList.FOREVERHUD(' 130 ');check(math.abs(E.Profile().scale-1.3)<0.0001,'/fhud 130 sets the size')
SlashCmdList.FOREVERHUD('500');check(math.abs(E.Profile().scale-1.3)<0.0001 and not E.panel:IsShown(),'An out-of-range size changes nothing and opens nothing')
SlashCmdList.FOREVERHUD('120')
-- 0.13.9: /fhud dump. With none of the client APIs it still records the header.
SlashCmdList.FOREVERHUD('dump');local rec=ForeverHUDDB.dump.WARLOCK
check(rec.info.class=='WARLOCK' and rec.info.addon==E.releaseVersion and rec.info.stackGate==false and #rec.spells==0 and #rec.talents==0 and #rec.auras==0 and #rec.cdm==0,'A dump without client APIs records the header and empty sections')
check(not E.panel:IsShown(),'/fhud dump does not open the panel')
C_UnitAuras={GetAuraDataByIndex=function(unit,index,filter)if unit=='player' and filter=='HELPFUL' and index==1 then return {spellId=400625,name='Heating Up',applications=2,duration=20,sourceUnit='player'} end
    if unit=='target' and filter=='HARMFUL' and index==1 then return {spellId=secret,name='Hidden',applications=1} end end}
C_AuraContainerUtil={ProcessCustomAuraButtonApplicationBarOptions=function()end}
C_Spell={GetSpellName=function(id)return ({[1293695]='Demonic Brand',[1293696]='Demonic Brand',[980]='Bane of Agony'})[id] end}
SlashCmdList.FOREVERHUD('dump auras');rec=ForeverHUDDB.dump.WARLOCK
check(#rec.auras==2 and rec.auras[1].id==400625 and rec.auras[1].stacks==2 and rec.auras[2].id==nil and rec.auras[2].name=='Hidden' and rec.info.stackGate==true,'Auras are recorded with stacks; a secret value is left out, never stored')
InCombatLockdown=function()return true end;rec.auras=nil;SlashCmdList.FOREVERHUD('dump auras');check(rec.auras==nil,'Auras are not read in combat')
InCombatLockdown=function()return false end
SlashCmdList.FOREVERHUD('dump watch');check(rec.watching==true,'Watch arms a snapshot after each fight')
E.DUMP_SCAN_TOP=1300000;E.DUMP_SCAN_STEP=1300000;SlashCmdList.FOREVERHUD('dump names Brand')
check(#rec.names.brand==2 and rec.names.brand[1].id==1293695,'Name search lists every matching spell ID')
SlashCmdList.FOREVERHUD('dump names ab');SlashCmdList.FOREVERHUD('dump nonsense');check(rec.names.ab==nil,'A short search or unknown section changes nothing')
SlashCmdList.FOREVERHUD('dump watch');C_UnitAuras=nil;C_AuraContainerUtil=nil;C_Spell=nil;ForeverHUDDB.dump=nil
-- 0.13.7: cast bar size, language choice, lower default position.
local castBar=CreateFrame('Frame');local beforeCast=ForeverAuras.GetRegion
ForeverAuras.GetRegion=function(id)if id=='ForeverHUD | Core | Cast' then return castBar end;return beforeCast(id)end
E.Set('castScale',1.5);check(castBar.scale==1.5 and root.scale==E.Profile().scale,'The cast bar takes its own size without changing the HUD scale')
E.Profile().castScale=9;E.InitDB();check(E.Profile().castScale==2,'Cast bar size is clamped')
E.Set('castScale',1);ForeverAuras.GetRegion=beforeCast
check(E.L('Warlock')=='Warlock' and not E.Chinese(),'English client stays English by default')
SlashCmdList.FOREVERHUD('zh');check(ForeverHUDDB.language=='zhCN' and E.L('Warlock')=='术士','/fhud zh switches to Chinese on any client')
check(E.panel.language.text:find('简体中文'),'The language button names the choice')
SlashCmdList.FOREVERHUD('en');check(E.L('Warlock')=='Warlock','/fhud en switches back')
E.panel.language.scripts.OnClick(E.panel.language);check(ForeverHUDDB.language==nil,'The button cycles back to Auto')
-- Faint when opened by a target outside combat; full in combat and when inspected.
local fake={open=true,world=true,Preview=function()return false end,Visible=function()return true end,Update=function()end,ObservePreview=function()end,Start=function()end,Stop=function()end,Inspect=function()end,HostileTarget=function()return true end}
E.state=fake;E.Set('opacity',1);E.Notify()
check(E.AlphaFactor()==.2 and root.alpha==.2,'A targeted HUD outside combat is 20% visible')
fake.inspected=true;E.Notify();check(root.alpha==1,'An inspected HUD is fully visible')
fake.inspected=false;E.Notify();E.events.scripts.OnEvent(nil,'PLAYER_REGEN_DISABLED')
check(root.alpha==1 and E.combatEdge,'Entering combat makes it fully visible at once')
E.events.scripts.OnEvent(nil,'PLAYER_REGEN_ENABLED');check(root.alpha==.2,'Leaving combat with the HUD still open returns to faint')
fake.open=false;E.Notify();check(root.alpha==1,'A folded HUD keeps the seal and tray fully visible')
E.state=nil
local savedDB=ForeverHUDDB
ForeverHUDDB={version=1,profiles={WARLOCK={x=0,y=-160},MAGE={x=40,y=-160}}};E.InitDB()
check(ForeverHUDDB.profiles.WARLOCK.y==-235 and ForeverHUDDB.profiles.MAGE.y==-160 and ForeverHUDDB.version==2,'Only an untouched old default position moves down')
ForeverHUDDB=savedDB;E.InitDB()
local pref=E.Profile()
pref.castBarMode=nil;pref.cast=true;pref.hideDefaultCast=false;E.InitDB()
check(pref.castBarMode=='Default' and not pref.cast,'Old overlapping cast defaults migrate to the game bar only')
pref.castBarMode=nil;pref.cast=true;pref.hideDefaultCast=true;E.InitDB()
check(pref.castBarMode=='ForeverHUD' and pref.cast and pref.hideDefaultCast,'Existing explicit ForeverHUD suppression survives migration')
E.Set('castBarMode','Both');InCombatLockdown=function()return true end
E.Set('cast',false)
check(pref.cast and E.queued.castBarMode=='Default','Cast-mode changes queue atomically in combat')
InCombatLockdown=function()return false end
E.events.scripts.OnEvent(nil,'PLAYER_REGEN_ENABLED')
check(pref.castBarMode=='Default' and not pref.cast and not pref.hideDefaultCast,'Deferred cast choice applies consistently after combat')
local commonRoot=E.rootID
local classRoot='ForeverHUD | Warlock'
local currentRoot={id=classRoot,parent=commonRoot}
ForeverAuras.GetData=function(id)return id==classRoot and currentRoot end
check(E.GetRootID()==commonRoot,'Per-class update within a combined group keeps the shared anchor')
currentRoot.parent=nil
check(E.GetRootID()==classRoot,'A standalone class import resolves its own root')
local standalone=CreateFrame('Frame')
local previousGetRegion=ForeverAuras.GetRegion
ForeverAuras.GetRegion=function(id)if id==classRoot then return standalone end;return previousGetRegion(id)end
E.ApplyLayout()
check(standalone.parent==E.anchor and standalone.nativeAnchor[2]==E.anchor and standalone.scale==E.Profile().scale,'Standalone root uses the companion anchor, scale and preserved profile')
local oldParent=standalone.parent
InCombatLockdown=function()return true end;E.ApplyLayout()
check(E.pending and standalone.parent==oldParent,'Standalone ancestry changes defer in combat')
InCombatLockdown=function()return false end
check(E.version=='0.3.2' and E.importAPI==2 and E.releaseVersion=='0.13.10','Legacy v0.3.2 bridge and independent class import API remain compatible')
local legacy=assert(loadstring('return function()return ForeverHUD and ForeverHUD.version=="0.3.2" and ForeverHUD.Gate("base","WARLOCK") or false end'))()
check(legacy()==true,'An existing v0.3.2 class gate still works with the new companion')
local importing=true
ForeverAuras.IsImporting=function()return importing end
E.Bind();local initial=E.bindTimer;E.Bind()
check(E.bindTimer==initial,'Import binding requests coalesce')
initial.callback();check(E.bindTimer and E.bindAttempts==1,'Binding waits while native import parents are temporary')
currentRoot.parent=commonRoot;importing=false
E.bindTimer.callback()
check(not E.bindTimer and E.GetRootID()==commonRoot,'Completed class update resolves its preserved combined parent')
importing=true;E.Bind();local pendingBind=E.bindTimer;E.Shutdown()
check(pendingBind.cancelled and not E.bindTimer,'World leave cancels pending import binding')
local spy={SetParent=function(self)self.moved=true end}
ForeverAuras.GetRegion=function()return spy end
E.pending=nil;E.ApplyLayout()
check(not spy.moved and E.pending and E.bindTimer,'Layout never re-parents a root during a native import')
E.bindAttempts=1200;E.bindTimer.callback()
check(E.bindTimer and E.bindAttempts==1201,'A long import keeps a slow bind retry instead of giving up')
E.Shutdown();importing=false
ForeverAuras.IsImporting=nil
ForeverAuras.GetData=nil;ForeverAuras.GetRegion=previousGetRegion
-- 0.13.3 install cue: shown folded and out of combat while an aura group is
-- missing or older; clicking it imports; it goes once both are current.
local builds={['ForeverHUD | Core']=50,['ForeverHUD | Warlock']=40}
E.bundledImports={
    CORE={rootID='ForeverHUD | Core',build=50,version='0.13.3',encoded='core',slug='forever-hud-core'},
    WARLOCK={rootID='ForeverHUD | Warlock',build=50,version='0.13.3',encoded='warlock',slug='forever-hud-warlock'}}
ForeverAuras.GetData=function(id)return builds[id] and {url='https://wago.io/x/'..builds[id]} or nil end
local imported
ForeverAuras.Import=function(encoded)imported=encoded end
class='WARLOCK';E.InitDB();E.Reset();E.state=nil
E.RefreshInstallCue(true)
check(E.installCue.shown and #E.cueProblems==1 and E.cueProblems[1]:find('Warlock'),'An older class group shows the install cue with its reason')
-- 0.13.5: always on the tray row's line (y=-61 since 0.13.6), never a line of its own.
check(E.installCue.point[5]==E.Profile().y+E.INSTALL_CUE.y and E.INSTALL_CUE.y==-61,'The cue sits on the tray row line')
check(E.installCue.point[4]==E.Profile().x+84 and E.installCue.width==34 and not E.installCueInRow,'An older class group without the row icon gets the companion icon beside the row')
check(E.NeedsAuras(),'The row icon is told the auras need work')
local cueTimer=timers[#timers]
local rowIcon='ForeverHUD | Warlock | Tray | Row | Install';builds[rowIcon]=40
E.RefreshInstallCue(true)
check(E.installCueInRow and E.installCue.point[4]==E.Profile().x and E.installCue.width==E.INSTALL_CUE.strip,'A class group with the row icon gets only an invisible strip over the row')
E.Set('tray',false);check(not E.installCueInRow and E.installCue.point[4]==E.Profile().x and E.installCue.width==34,'With the tray off the companion icon sits centred')
E.Set('tray',true);builds[rowIcon]=nil
local scansBefore=scans
E.installCue.scripts.OnClick(E.installCue)
check(imported=='warlock','Clicking the cue opens the next import')
InCombatLockdown=function()return true end;E.Notify();check(not E.installCue.shown,'The cue hides in combat')
InCombatLockdown=function()return false end;E.Notify();check(E.installCue.shown,'The cue returns after combat')
-- 0.13.8: the timer never walks the saved displays while the builds are still behind.
local walks=0;ForeverAurasSaved={displays=setmetatable({},{__pairs=function(t)walks=walks+1;return next,t end})}
local realPairs=pairs;pairs=function(t)if t==ForeverAurasSaved.displays then walks=walks+1 end;return realPairs(t)end
cueTimer.callback();check(walks==0 and E.installCue.shown and E.INSTALL_CUE.recheck==10,'The periodic check reads only build numbers')
cueTimer=timers[#timers]
builds['ForeverHUD | Warlock']=50;cueTimer.callback();pairs=realPairs;ForeverAurasSaved=nil
check(not E.installCue.shown and #E.cueProblems==0,'A finished update clears the cue on the next look')
check(not E.NeedsAuras() and scans>scansBefore,'ForeverAuras is told when the answer flips, so the row icon hides')
builds['ForeverHUD | Core']=nil;E.RefreshInstallCue(true)
check(E.installCue.shown and E.cueProblems[1]:find('Core'),'A missing Core shows the cue')
E.Shutdown();check(not E.installCue.shown,'World leave hides the cue')
E.bundledImports=nil;ForeverAuras.GetData=nil;ForeverAuras.Import=nil;E.cueProblems=nil
print("Companion behaviour checks passed: "..checks)
