dofile('tests/core.lua')
local E=EclipseHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/EclipseHUD/Discovery.lua'))('EclipseHUD',E)
assert(loadfile('src/EclipseHUD/Presentation.lua'))('EclipseHUD',E)
assert(loadfile('src/EclipseHUD/Catalog.lua'))('EclipseHUD',E)
local rules
Enum={NumericRuleFormatRounding={Up=1}}
C_StringUtil={CreateNumericRuleFormatter=function()return {SetBreakpoints=function(_,value)rules=value end}end}
E.Reset()
local font={points={{'CENTER'}},font='original',size=16,flags='OUTLINE'}
function font:GetFont()return self.font,self.size,self.flags end
function font:GetNumPoints()return #self.points end
function font:GetPoint(i)return unpack(self.points[i])end
function font:ClearAllPoints()self.points={}end
function font:SetPoint(...)self.points[#self.points+1]={...}end
function font:SetFont(f,s,flags)self.font,self.size,self.flags=f,s,flags end
local cd={format='original',threshold=2}
function cd:GetCountdownFontString()return font end
function cd:GetCountdownFormatter()return self.format end
function cd:SetCountdownFormatter(value)self.format=value end
function cd:GetCountdownMillisecondsThreshold()return self.threshold end
function cd:SetCountdownMillisecondsThreshold(value)self.threshold=value end
local region={cooldown=cd,HookScript=function()end}
E.StyleCooldown(region,'WARLOCK','utility')
check(rules[1].format=='' and rules[2].format:find('%%.1f') and rules[3].rounding==1,'Native formatter hides zero, tenths and rounds seconds up')
check(rules[5].components[1].div==60 and rules[5].components[2].mod==60,'Native minute/second components')
check(font.points[1][1]=='TOP' and font.points[1][3]=='BOTTOM','Secondary countdown below icon')
E.Set('utility',false)
check(cd.format=='original' and cd.threshold==2 and font.font=='original' and font.points[1][1]=='CENTER','Disabling restores countdown ownership')
local flag
ForeverAuras.SetLoadFlag=function(key,value)if key=='ECLIPSE_WARRIOR_pet_offhand'then flag=value end end
UnitClass=function()return 'Warrior','WARRIOR'end;E.InitDB()
GetInventoryItemID=function()return 100 end
local loc,kind='INVTYPE_WEAPONOFFHAND',2
C_Item={GetItemInfoInstant=function()return 100,'Weapon','Sword',loc,1,kind end}
E.RefreshEquipment();check(flag and E.dualSwing,'Actual off-hand weapon enables second native swing')
loc='INVTYPE_SHIELD';kind=4;E.RefreshEquipment();check(not flag,'Shield does not create off-hand swing')
loc='INVTYPE_2HWEAPON';kind=2;E.RefreshEquipment();check(not flag,'Two-hander does not create off-hand swing')
loc='INVTYPE_WEAPONOFFHAND';E.Set('swingMode','Single');check(not flag,'Manual single suppresses real off-hand')
E.Set('swingMode','Dual');check(flag,'Manual dual still validates equipment')
GetInventoryItemID=function()return nil end;E.RefreshEquipment();check(not flag,'Manual dual cannot fabricate empty off-hand')
E.Set('pet',false);check(not flag,'Resource module disable unloads off-hand tracker')
UnitClass=function()return 'Druid','DRUID'end;E.InitDB()
UnitPowerType=function()return 0 end;check(not E.ComboAllowed(),'Caster form hides combo display')
UnitPowerType=function()return 3 end;check(E.ComboAllowed(),'Energy form allows native combo display')
E.LayoutVisible=function()return true end
local group={}
function group:SetLooping(value)self.loop=value end
function group:Play()self.playing=true end
function group:Stop()self.playing=false end
function group:CreateAnimation()
    self.flip=setmetatable({}, {__index=function(_,key)return function(self,value)self[key..'Value']=value end end})
    return self.flip
end
local mask={}
local fg={mask=mask,SetTexture=function(self,path)self.path=path end,SetTexCoord=function()end,
    CreateAnimationGroup=function()return group end}
local flow={bar={fg=fg,UpdateAnchors=function()end},scripts={}}
function flow:HookScript(key,fn)self.scripts[key]=fn end
function flow:UpdateStatusBarTexture()fg.path='original' end
E.StyleResource(flow,'DRUID','right')
check(group.loop=='REPEAT' and group.flip.SetDurationValue==8 and group.flip.SetFlipBookFramesValue==480,'480-frame flow uses eight-second native clock')
check(fg.mask==mask and fg.path:find('resource%-flow%-right'),'Original native progress mask retained')
flow.scripts.OnHide();check(not group.playing,'Hidden resource stops native animation')
flow.scripts.OnShow();check(group.playing,'Shown resource resumes native animation')
E.Set('resourceFlow',false);check(not group.playing and fg.path=='original' and fg.mask==mask,'Disable restores native paint without changing progress mask')
local kind=0
UnitPowerType=function()return kind end
for value,label in pairs({[0]='Mana',[1]='Rage',[2]='Focus',[3]='Energy',[4]='Combo points'}) do
    kind=value;check(E.ResourceLabel()==label,'Resource labels follow live type metadata')
end
local secret={};issecretvalue=function(v)return rawequal(v,secret)end
kind=secret;check(E.ResourceLabel()=='Resource','Restricted identity never becomes a guessed mana label')
kind=999;check(E.ResourceLabel()=='Resource','Unknown type has a neutral resource label')
GetLocale=function()return 'zhCN'end
assert(loadfile('src/EclipseHUD/Locale.lua'))('EclipseHUD',E)
kind=3;check(E.ResourceLabel()=='能量' and E.L('Health')=='生命' and E.L('Pet')=='宠物','Health/resource/pet labels localize')
print('Presentation/equipment checks passed: '..checks)
