-- Minimap button and addon-button tray (0.14.0): which buttons are borrowed,
-- how they are laid out, that everything borrowed returns exactly as found,
-- and that Forever Classmate's own tray takes precedence.
local count=0
local function check(ok,message) assert(ok,message);count=count+1 end

local methods={}
local function object(kind,name) return setmetatable({scripts={},events={},shown=true,points={},kind=kind or 'Frame',name=name},{__index=methods}) end
function methods:SetScript(event,fn) self.scripts[event]=fn end
function methods:GetScript(event) return self.scripts[event] end
function methods:HookScript(event,fn)
    local previous=self.scripts[event]
    self.scripts[event]=function(...) if previous then previous(...) end;fn(...) end
end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateTexture() return object('Texture') end
function methods:CreateFontString() return object('FontString') end
function methods:CreateMaskTexture() return object('MaskTexture') end
function methods:SetText(value) self.text=value end
function methods:SetTexture(value) self.texture=value end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetParent(parent) self.parent=parent end
function methods:GetParent() return self.parent end
function methods:ClearAllPoints() self.points={} end
function methods:SetPoint(...) self.points[#self.points+1]={...} end
function methods:GetNumPoints() return #self.points end
function methods:GetPoint(index) return unpack(self.points[index]) end
function methods:IsShown() return self.shown end
function methods:SetShown(value)
    local changed=self.shown~=value;self.shown=value
    if changed and self.scripts[value and 'OnShow' or 'OnHide'] then self.scripts[value and 'OnShow' or 'OnHide'](self) end
end
function methods:Show() self:SetShown(true) end
function methods:Hide() self:SetShown(false) end
function methods:IsObjectType(kind) return self.kind==kind end
function methods:GetName() return self.name end
function methods:IsProtected() return self.protected==true,false end
function methods:GetCenter() return self.cx,self.cy end
function methods:IsMouseOver() return self.over==true end
function methods:GetFrameLevel() return rawget(self,'level') or 1 end
function methods:SetFrameLevel(value) self.level=value end
function methods:GetFrameStrata() return rawget(self,'strata') or 'MEDIUM' end
function methods:SetFrameStrata(value) self.strata=value end
function methods:GetWidth() return 140 end
function methods:GetHeight() return 140 end
function methods:GetEffectiveScale() return 1 end
setmetatable(methods,{__index=function() return function() end end})

local created={}
CreateFrame=function(kind,name,parent)
    local frame=object(kind,name);frame.parent=parent;created[#created+1]=frame
    return frame
end
local function named(name) for _,frame in ipairs(created) do if frame.name==name then return frame end end end
hooksecurefunc=function(target,method,fn)
    local original=target[method]
    target[method]=function(...) local result={original(...)};fn(...);return unpack(result) end
end
local inCombat=false
InCombatLockdown=function() return inCombat end
local timers={}
C_Timer={After=function(delay,fn) timers[#timers+1]={delay=delay,fn=fn} end}
local loaded={}
C_AddOns={IsAddOnLoaded=function(name) return loaded[name]==true end}
UISpecialFrames={}
UIParent=object();UIParent.cx,UIParent.cy=960,540
Minimap=object('Frame','Minimap');Minimap.cx,Minimap.cy=1800,950
GameTooltip={SetOwner=function() end,SetText=function() end,Show=function() end,Hide=function() end,AddLine=function() end}
local cursorX,cursorY=1800,1100
GetCursorPosition=function() return cursorX,cursorY end

local function Button(name,extra)
    local button=object('Button',name);button.parent=Minimap
    button:SetPoint('CENTER',Minimap,'CENTER',50,60)
    button.scripts.OnDragStart=function() end;button.scripts.OnDragStop=function() end
    local clicks=0;button.scripts.OnClick=function() clicks=clicks+1 end
    button.Clicks=function() return clicks end
    for key,value in pairs(extra or {}) do button[key]=value end
    return button
end
local questie=Button('LibDBIcon10_Questie')
local fishfry=Button('FishFryMinimapButton')
local forever=Button('DungeonsHub',{minimapButtonSpec={}})
local hidden=Button('LibDBIcon10_Hidden');hidden.shown=false
local tracking=Button('MiniMapTrackingButton')
local clock=Button('GameTimeFrame')
local secure=Button('SecureMinimapLauncher',{protected=true})
local pin=Button(nil)
local texture=object('Frame','DecorMinimapOverlay');texture.parent=Minimap
local children={tracking,questie,clock,fishfry,secure,pin,texture,forever,hidden}
Minimap.GetChildren=function() return unpack(children) end
local function Original(button) return button.points[1][2]==Minimap and button.points[1][4]==50 end
local originalDrag=questie.scripts.OnDragStart
questie.level,questie.strata=8,'HIGH'

local optionsOpened,inspected=0,0
local E={class='WARLOCK'}
E.L=function(text) return text end
E.ToggleOptions=function() optionsOpened=optionsOpened+1 end
E.Notify=function() end
E.state={ToggleInspect=function() inspected=inspected+1 end}
ForeverHUDDB={}
assert(loadfile('src/ForeverHUD/MinimapTray.lua'))('ForeverHUD',E)
local Tray=E.minimapTray
local events=Tray.events
check(events.events.PLAYER_LOGIN,'the tray waits for login, after saved settings load')
events.scripts.OnEvent(events,'PLAYER_LOGIN')
local db=ForeverHUDDB.minimap
check(db.show==true and db.group==true and db.angle==225,'account-wide defaults: button shown, grouping on')
local anchor=Tray.Button()
check(anchor and anchor.name=='ForeverHUDMinimapButton' and anchor.parent==Minimap and anchor.shown,'the ForeverHUD button sits on the minimap')
check(anchor.icon.texture=='Interface\\AddOns\\ForeverHUD\\Media\\crest-warlock','the button shows the class crest')
check(not Tray.Candidate(anchor),'the ForeverHUD button is never borrowed by its own tray')
anchor.cx,anchor.cy=1800,1000
local tray=named('ForeverHUDMinimapTray')
check(tray and Tray.Active(),'grouping is on by default and creates the tray')
local borrowed=Tray.Borrowed()
check(#borrowed==4 and borrowed[1]==forever and borrowed[2]==fishfry and borrowed[3]==hidden and borrowed[4]==questie,
    'LibDBIcon, ForeverCore and *Minimap* addon buttons are borrowed, sorted by name')
for _,button in ipairs({tracking,clock,secure,pin}) do
    check(button.parent==Minimap and Original(button) and button.scripts.OnDragStart~=nil,
        'Blizzard, protected and unnamed buttons are never touched')
end
check(texture.parent==Minimap,'non-button minimap children are ignored')
check(questie.parent~=Minimap and questie.scripts.OnDragStart==nil and questie.scripts.OnDragStop==nil,
    'borrowed buttons move into the tray and stop dragging')
check(events.events.PLAYER_ENTERING_WORLD and events.events.PLAYER_REGEN_ENABLED,'tray listens for world entry and combat end')

anchor.scripts.OnEnter(anchor)
check(tray.shown,'hovering the ForeverHUD button opens the tray')
check(Tray.Open() and tray.shown,'hovering again keeps it open instead of toggling it closed')
check(#tray.cells==4 and tray.cells[2]==forever and tray.cells[4]==questie,'settings cell first, then visible buttons')
local first=tray.cells[1].points[1]
check(first[1]=='CENTER' and first[4]==17 and first[5]==-17 and questie.points[1][4]==119 and questie.points[1][5]==-17,
    'cells sit on a 34px grid')
check(tray.width==152 and tray.height==66,'one row of four fits with padding and title')
check(tray.points[1][1]=='TOPRIGHT' and tray.points[1][2]==anchor and tray.points[1][3]=='TOPLEFT' and tray.points[1][4]==-4,
    'a top-right minimap opens the tray down and to the left')

questie:ClearAllPoints();questie:SetPoint('CENTER',Minimap,'CENTER',-70,10)
local last=questie.points[#questie.points]
check(last[2]~=Minimap and last[4]==119 and last[5]==-17,'owner moves are answered by the tray layout')
hidden:Show()
check(#tray.cells==5 and tray.height==100 and tray.width==152,'a button shown by its addon joins the grid; the fifth wraps to a second row')
hidden:Hide()
check(#tray.cells==4 and tray.height==66,'a hidden button leaves the grid')

questie.scripts.OnClick(questie)
check(questie.Clicks()==1 and not tray.shown,'clicking a borrowed button runs it and closes the tray')
-- 0.14.29: a right-click opens the borrowed button's own menu, so the tray stays under it.
Tray.Open();questie.scripts.OnClick(questie,'RightButton')
check(questie.Clicks()==2 and tray.shown,'right-clicking a borrowed button runs it and keeps the tray open')
DropDownList1=object('Frame','DropDownList1');DropDownList1.shown=true
tray.over=false;anchor.over=false;tray.scripts.OnUpdate(tray,3)
check(tray.shown and Tray.MenuOpen(),'the tray stays while the button menu is open, even with the pointer on the menu')
questie.scripts.OnClick(questie,'LeftButton')
check(tray.shown,'a left-click that opens a menu keeps the tray too')
DropDownList1.shown=false
tray.scripts.OnUpdate(tray,1.5);check(tray.shown,'after the menu closes the tray waits as usual')
tray.scripts.OnUpdate(tray,1);check(not tray.shown,'and then closes')
Menu={GetManager=function() return {GetOpenMenu=function() return {} end} end}
check(Tray.MenuOpen(),'the newer menu system counts as an open menu')
Menu=nil;check(not Tray.MenuOpen(),'no menu is open afterwards')
Tray.Open();tray.cells[1].scripts.OnClick(tray.cells[1])
check(optionsOpened==1 and not tray.shown,'the first cell opens ForeverHUD settings')
anchor.scripts.OnMouseDown(anchor);anchor.scripts.OnClick(anchor,'LeftButton')
check(optionsOpened==2,'left-clicking the ForeverHUD button opens settings')
anchor.scripts.OnClick(anchor,'RightButton')
check(inspected==1 and optionsOpened==2,'right-click expands or folds the HUD')

Tray.Open();tray.over=false;anchor.over=false
tray.scripts.OnUpdate(tray,1.5);check(tray.shown,'the tray waits before closing')
tray.over=true;tray.scripts.OnUpdate(tray,1);tray.over=false;tray.scripts.OnUpdate(tray,1.5)
check(tray.shown,'pointer time over the tray resets the close timer')
tray.scripts.OnUpdate(tray,0.6);check(not tray.shown,'two seconds away closes the tray')

-- Dragging moves the button around the ring and saves the angle.
cursorX,cursorY=1800,1100
anchor.scripts.OnDragStart(anchor);anchor.scripts.OnUpdate(anchor)
anchor.scripts.OnDragStop(anchor)
check(math.abs(db.angle-90)<0.001 and anchor.points[#anchor.points][4]<0.001 and anchor.points[#anchor.points][5]==73,
    'dragging moves the button around the minimap and saves the angle')
anchor.scripts.OnClick(anchor,'LeftButton')
check(optionsOpened==2,'releasing a drag does not count as a click')

local late=Button('LibDBIcon10_Gargul');children[#children+1]=late
events.scripts.OnEvent(events,'PLAYER_ENTERING_WORLD')
check(late.parent~=Minimap and #Tray.Borrowed()==5 and timers[#timers].delay==3,'world entry scans now and again after three seconds')

Tray.Set('group',false)
for _,button in ipairs({questie,fishfry,forever,hidden,late}) do
    check(button.parent==Minimap and #button.points==1 and Original(button),'turning grouping off returns each button to its spot')
end
check(questie.scripts.OnDragStart==originalDrag and questie.scripts.OnDragStop~=nil,'original drag handlers are restored')
check(not Tray.Active() and not Tray.Open() and not events.events.PLAYER_ENTERING_WORLD and anchor.shown,
    'with grouping off the button stays, the tray does not open and listeners stop')
questie:SetPoint('CENTER',Minimap,'CENTER',1,2)
check(questie.points[#questie.points][2]==Minimap,'released buttons are no longer re-laid out by the old hook')

inCombat=true;Tray.Set('group',true)
check(#Tray.Borrowed()==0 and questie.parent==Minimap,'grouping waits for combat to end')
inCombat=false;events.scripts.OnEvent(events,'PLAYER_REGEN_ENABLED')
check(#Tray.Borrowed()==5,'combat end borrows the buttons')
inCombat=true;Tray.Set('group',false)
check(questie.parent~=Minimap and events.events.PLAYER_REGEN_ENABLED,'release also waits for combat to end')
inCombat=false;events.scripts.OnEvent(events,'PLAYER_REGEN_ENABLED')
check(questie.parent==Minimap and #Tray.Borrowed()==0 and not events.events.PLAYER_REGEN_ENABLED,'combat end returns the buttons and stops listening')

Tray.Set('group',true)
check(#Tray.Borrowed()==5,'grouping can be turned back on')
Tray.Set('show',false)
check(#Tray.Borrowed()==0 and questie.parent==Minimap and not anchor.shown,'hiding the ForeverHUD button returns every button')
check(questie.level==8 and questie.strata=='HIGH','a returned button gets its own frame level and strata back')

Tray.Set('show',true);Tray.Open()
local before=questie.Clicks();questie.scripts.OnClick(questie)
check(questie.Clicks()==before+1 and not tray.shown,'hooks are installed once per button')

-- Forever Classmate loaded: its tray groups the buttons, ours stands aside.
loaded.ForeverUtilities=true;Tray.Apply()
check(not Tray.Active() and #Tray.Borrowed()==0 and questie.parent==Minimap and anchor.shown,
    'with Forever Classmate loaded, its tray groups the buttons and ours returns them')
local classmateWouldTake=anchor.name:lower():find('minimap')~=nil
check(classmateWouldTake,'the ForeverHUD button name lets the Classmate tray collect it')
loaded.ForeverUtilities=nil;Tray.Apply()
check(Tray.Active() and #Tray.Borrowed()==5,'without Classmate the ForeverHUD tray groups again')

Tray.Set('group',false)
local saved=children;children={}
Tray.Set('group',true)
check(Tray.Active() and Tray.Open()==false and not tray.shown,'an empty tray never replaces the tooltip')
children=saved

-- Chinese labels come through the locale boundary.
GetLocale=function() return 'zhCN' end
local zh={}
assert(loadfile('src/ForeverHUD/Locale.lua'))('ForeverHUD',zh)
for _,text in ipairs({'Minimap button','Group addon minimap buttons','Addon buttons','ForeverHUD settings',
    'Click the ForeverHUD button: settings | Right-click: expand or fold','Drag to move around the minimap.','on','off'}) do
    check(zh.L(text)~=text,'Chinese label for "'..text..'"')
end
print('PASS: '..count..' minimap tray checks')
