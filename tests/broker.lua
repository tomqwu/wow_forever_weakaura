-- Titan Panel / LibDataBroker launcher (0.14.5): registered at login only when
-- a Broker display provides LibDataBroker-1.1; same clicks as the minimap button.
local count=0
local function check(ok,message) assert(ok,message);count=count+1 end

local frames={}
CreateFrame=function()
    local frame={events={},scripts={}}
    function frame:RegisterEvent(e) self.events[e]=true end
    function frame:UnregisterEvent(e) self.events[e]=nil end
    function frame:SetScript(k,fn) self.scripts[k]=fn end
    frames[#frames+1]=frame
    return frame
end
local function load(E)
    assert(loadfile('src/ForeverHUD/Broker.lua'))('ForeverHUD',E)
    return E.broker
end
local function newE()
    local E={class='WARLOCK',opened=0,folded=0}
    E.L=function(text) return text end
    E.ToggleOptions=function() E.opened=E.opened+1 end
    E.Notify=function() end
    E.state={ToggleInspect=function() E.folded=E.folded+1 end}
    return E
end

-- No Broker display: nothing happens, nothing errors.
LibStub=nil
local E=newE();local Broker=load(E)
check(Broker.events.events.PLAYER_LOGIN,'the launcher waits for login, after every addon has loaded')
Broker.events.scripts.OnEvent(Broker.events,'PLAYER_LOGIN')
check(Broker.object==nil and not Broker.events.events.PLAYER_LOGIN,'without LibDataBroker no launcher is made')

-- Titan Panel loaded: it bundles LibDataBroker-1.1 behind LibStub.
local objects={}
local ldb={}
function ldb:NewDataObject(name,data)
    if objects[name] then return nil end
    objects[name]=data;return data
end
function ldb:GetDataObjectByName(name) return objects[name] end
LibStub={GetLibrary=function(self,major,silent)
    assert(silent==true,'looked up silently, never raising when absent')
    if major=='LibDataBroker-1.1' then return ldb end
end}
setmetatable(LibStub,{__call=function(self,major,silent) return self:GetLibrary(major,silent) end})
E=newE();Broker=load(E)
Broker.events.scripts.OnEvent(Broker.events,'PLAYER_LOGIN')
local object=objects.ForeverHUD
check(object and Broker.object==object,'a ForeverHUD launcher is registered with LibDataBroker')
check(object.type=='launcher' and object.label=='ForeverHUD','it is a launcher labelled ForeverHUD')
check(object.icon=='Interface\\AddOns\\ForeverHUD\\Media\\crest-warlock','it shows the class crest')
object.OnClick(nil,'LeftButton')
check(E.opened==1 and E.folded==0,'left-click opens the settings')
object.OnClick(nil,'RightButton')
check(E.opened==1 and E.folded==1,'right-click expands or folds the HUD')
local lines={}
object.OnTooltipShow({AddLine=function(_,text) lines[#lines+1]=text end})
check(lines[1]=='ForeverHUD' and lines[2]=='Left-click for settings. Right-click to expand or fold.','the tooltip explains the clicks')
object.OnTooltipShow(nil)
check(true,'a missing tooltip is ignored')
E.class='MAGE'
check(Broker.Register()==object and object.icon:find('crest%-mage$'),'registering again reuses the launcher and refreshes the crest')

-- A second copy (name already taken) reuses the existing object.
local E2=newE();local Broker2=load(E2)
check(Broker2.Register()==object,'an already registered name is reused, not an error')

-- The Chinese label for the tooltip line exists.
local zh={}
GetLocale=function() return 'zhCN' end
assert(loadfile('src/ForeverHUD/Locale.lua'))('ForeverHUD',zh)
local text='Left-click for settings. Right-click to expand or fold.'
check(zh.L(text)~=text,'Chinese tooltip line')
print('PASS: '..count..' broker checks')
