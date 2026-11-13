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
for _,key in ipairs({"RegisterForClicks","RegisterForDrag","SetFrameStrata","SetAllPoints","SetColorTexture","SetMovable","SetClampedToScreen","SetBackdrop","SetBackdropColor","SetBackdropBorderColor","StartMoving","SetFont","SetTextColor","SetWidth","SetJustifyH","EnableMouse","SetMinMaxValues","SetValueStep","SetObeyStepOnDrag"})do Frame[key]=function()end end
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
E.ResetPosition();check(E.Profile().x==0 and E.Profile().y==-160 and E.Profile().scale==1.25 and not E.Profile().primary,"Position reset preserves module preferences and scale")
E.Set('x',135);E.Set('y',-230)
class="MAGE";E.InitDB();E.Notify()
check(E.Profile().x==0 and E.Profile().primary,"New class gets own defaults")
check(flags.FOREVERHUD_MAGE_primary and not flags.FOREVERHUD_WARLOCK_primary,"Login switches loaded modules")
class="WARLOCK";E.InitDB();E.Notify()
check(E.Profile().x==135 and not E.Profile().primary,"Returning class restores its settings")
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
check(E.version=='0.3.2' and E.importAPI==2 and E.releaseVersion=='0.11.0','Legacy v0.3.2 bridge and independent class import API remain compatible')
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
print("Companion behaviour checks passed: "..checks)
