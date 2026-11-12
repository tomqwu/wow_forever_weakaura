-- Bundled class imports offered through ForeverAuras' companion interface.
dofile('tests/core.lua')
local E=ForeverHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/ForeverHUD/Catalog.lua'))('ForeverHUD',E)

local function read(path)local f=assert(io.open(path,'rb'));local v=f:read('*a');f:close();return v end
local warlock,core=E.bundledImports.WARLOCK,E.bundledImports.CORE
check(warlock and warlock.rootID=='ForeverHUD | Warlock' and warlock.slug=='forever-hud-warlock','Warlock import is bundled with its update slug')
check(core and core.rootID=='ForeverHUD | Core' and core.slug=='forever-hud-core' and core.build==warlock.build,'The shared Core is bundled with its own slug')
check(warlock.encoded==read('dist/classes/ForeverHUD-Warlock.txt'):gsub('%s+$',''),'Bundled string is byte-identical to the published class file')
check(core.encoded==read('dist/classes/ForeverHUD-Core.txt'):gsub('%s+$',''),'Bundled Core is byte-identical to the published Core file')
local classes=0;for _ in pairs(E.bundledImports)do classes=classes+1 end
check(classes==10,'The Core and all nine classes are bundled')

local registered,installed,imports
-- installed: map of root ID to its saved data, as FA's GetData would return.
local function reset(data)
    registered,imports={},{}
    installed=data or {}
    E.bundleRegistered,E.detachedChecked,E.oldLayoutChecked=nil,nil,nil
    ForeverAuras.AddCompanionData=function(t)registered[#registered+1]=t end
    ForeverAuras.GetData=function(id)return installed[id] end
    ForeverAuras.Import=function(encoded)imports[#imports+1]=encoded end
end
local function find(kind,key)
    for _,t in ipairs(registered)do if t[kind] and t[kind][key] then return t[kind][key] end end
end
local function tagged(id,slug,build)return {id=id,url='https://wago.io/'..slug..'/'..build} end
UnitClass=function()return 'Warlock','WARLOCK' end
E.InitDB()

reset(nil);E.RegisterBundledImport()
local stash,slug=find('stash','ForeverHUD | Warlock'),find('slugs','forever-hud-warlock')
check(stash and stash.encoded==warlock.encoded,'Missing class group is listed as ready to install')
check(find('stash','ForeverHUD | Core') and find('stash','ForeverHUD | Core').encoded==core.encoded,'Missing Core is listed as ready to install')
check(slug and slug.wagoVersion==warlock.build and find('slugs','forever-hud-core').wagoVersion==core.build,'Update slugs carry the bundled build')
check(stash~=slug,'Install and update entries are separate tables')
check(not find('stash','ForeverHUD | Warrior'),'Only this character\'s class is offered')
local count=#registered
E.RegisterBundledImport()
check(count==4 and #registered==count,'Registration happens once per session')

reset({['ForeverHUD | Warlock']={id='ForeverHUD | Warlock'}});E.RegisterBundledImport()
check(find('stash','ForeverHUD | Warlock') and find('slugs','forever-hud-warlock'),'A group installed before update tags is offered again; FA matches it by UID')

reset({['ForeverHUD | Warlock']=tagged('ForeverHUD | Warlock','forever-hud-warlock',warlock.build-1)});E.RegisterBundledImport()
check(not find('stash','ForeverHUD | Warlock') and find('slugs','forever-hud-warlock'),'An older tagged group uses FA\'s own update listing, not a second install entry')
check(find('stash','ForeverHUD | Core'),'A missing Core is still offered beside an installed class')

reset({['ForeverHUD | Warlock']=tagged('ForeverHUD | Warlock','forever-hud-warlock',warlock.build),
    ['ForeverHUD | Core']=tagged('ForeverHUD | Core','forever-hud-core',core.build)});E.RegisterBundledImport()
check(not find('stash','ForeverHUD | Warlock') and not find('stash','ForeverHUD | Core'),'Current groups are not offered for install')

UnitClass=function()return 'Unknown','UNKNOWN' end;E.InitDB()
reset(nil);E.RegisterBundledImport()
check(#registered==0,'Unsupported classes register nothing, not even the Core')
UnitClass=function()return 'Warlock','WARLOCK' end;E.InitDB()

-- FA runs one import window at a time: Core first, then the class.
reset(nil)
check(E.NextBundle()==core,'A fresh install starts with the Core')
installed['ForeverHUD | Core']=tagged('ForeverHUD | Core','forever-hud-core',core.build)
check(E.NextBundle()==warlock,'With a current Core, install moves on to the class')
installed['ForeverHUD | Core']=tagged('ForeverHUD | Core','forever-hud-core',core.build-1)
installed['ForeverHUD | Warlock']=tagged('ForeverHUD | Warlock','forever-hud-warlock',warlock.build)
check(E.NextBundle()==core,'An older Core is updated even when the class is current')
installed['ForeverHUD | Core']=tagged('ForeverHUD | Core','forever-hud-core',core.build)
check(E.NextBundle()==warlock,'With both current, install re-opens the class import')

-- Root resolution for layout: standalone Core and class roots, or the combined root.
reset({['ForeverHUD | Warlock']={id='ForeverHUD | Warlock'},['ForeverHUD | Core']={id='ForeverHUD | Core'}})
local roots=E.GetRootIDs()
check(#roots==2 and roots[1]=='ForeverHUD | Warlock' and roots[2]=='ForeverHUD | Core','Standalone class and Core roots are both anchored')
reset({['ForeverHUD | Warlock']={id='ForeverHUD | Warlock',parent='ForeverHUD'},['ForeverHUD | Core']={id='ForeverHUD | Core',parent='ForeverHUD'}})
roots=E.GetRootIDs()
check(#roots==1 and roots[1]=='ForeverHUD','A combined install anchors only its shared root')
reset(nil)
check(E.GetRootIDs()[1]=='ForeverHUD' and E.GetRootID()=='ForeverHUD','No install falls back to the combined root')

-- Detached displays from an interrupted import block /fhud install.
local printed={}
local oldPrint=print
print=function(...)printed[#printed+1]=table.concat({...},' ')end
ForeverAurasSaved={displays={
    ['ForeverHUD | Warlock']={},                                   -- standalone root: legitimate
    ['ForeverHUD | Warlock | Chassis']={},                         -- detached
    ['ForeverHUD | Warlock | Health']={},                          -- detached
    ['ForeverHUD | Warlock | Frame']={parent='ForeverHUD | Warlock'}, -- attached
    ['ForeverHUD | Warrior | Health']={},                          -- other class
}}
check(E.DetachedDisplays('ForeverHUD | Warlock')==2,'Only this class\'s parentless non-root displays count as detached')
local current={['ForeverHUD | Core']=tagged('ForeverHUD | Core','forever-hud-core',core.build),['ForeverHUD | Warlock']={id='ForeverHUD | Warlock'}}
reset(current)
E.InstallBundled()
check(#imports==0 and printed[#printed]:find('2 displays',1,true),'Install refuses to import over detached displays and explains why')
E.InstallBundled(true)
check(#imports==1 and imports[1]==warlock.encoded,'install force still opens the import')
E.CheckDetached();E.CheckDetached()
local warnings=0;for _,line in ipairs(printed)do if line:find('outside their group',1,true)then warnings=warnings+1 end end
check(warnings==2,'The login check warns once per session (plus the refused install)')
ForeverAurasSaved.displays['ForeverHUD | Warlock | Chassis'].parent='ForeverHUD | Warlock | Frame'
ForeverAurasSaved.displays['ForeverHUD | Warlock | Health'].parent='ForeverHUD | Warlock | Resources'
ForeverAurasSaved.displays['ForeverHUD | Core | Cast']={}
check(E.DetachedDisplays('ForeverHUD | Core')==1,'Detached Core displays are counted under the Core root')
E.InstallBundled()
check(#imports==1 and printed[#printed]:find('ForeverHUD | Core',1,true),'Detached Core displays also block install')
ForeverAurasSaved.displays['ForeverHUD | Core | Cast'].parent='ForeverHUD | Core'
E.InstallBundled()
check(#imports==2,'A clean install opens ForeverAuras\' import window')

-- A fresh install opens the Core and says the class comes next.
reset(nil)
E.InstallBundled()
check(#imports==1 and imports[1]==core.encoded and printed[#printed]:find('again for "ForeverHUD | Warlock"',1,true),'Core installs first and names the next step')

-- A 0.4 class group still holds displays that moved to Core: warn, never touch.
reset({['ForeverHUD | Warlock']={id='ForeverHUD | Warlock'},['ForeverHUD | Warlock | Health']={id='ForeverHUD | Warlock | Health'}})
check(E.OldClassLayout(),'A class group carrying Health is the 0.4 layout')
local before=#printed
E.CheckOldLayout();E.CheckOldLayout()
check(#printed==before+1 and printed[#printed]:find('0.4 or earlier',1,true),'The old layout warns once per session')
E.InstallBundled()
check(#imports==0 and #printed==before+2,'Install refuses over an old class group and repeats the warning')
reset({['ForeverHUD | Warlock']={id='ForeverHUD | Warlock'}})
check(not E.OldClassLayout(),'A 0.5 class group is not flagged')

-- Leftovers from the EclipseHUD name are reported once, never touched.
ForeverAurasSaved.displays['Eclipse | Warlock']={}
ForeverAurasSaved.displays['Eclipse | Warlock | Health']={parent='Eclipse | Warlock'}
EclipseHUD={}
local before=#printed
E.CheckLegacy();E.CheckLegacy()
check(E.LegacyDisplays()==2 and #printed==before+2,'Old addon and old displays each warn once')
check(printed[before+1]:find('EclipseHUD',1,true) and printed[before+2]:find('2 old',1,true),'Legacy warnings name what to delete')
check(ForeverAurasSaved.displays['Eclipse | Warlock'] and ForeverAurasSaved.displays['Eclipse | Warlock | Health'],'Legacy displays are left for the user to delete')
EclipseHUD=nil
print=oldPrint

-- Core displays pass "CORE" and follow the current class's preferences.
check(E.Owner('CORE')=='WARLOCK' and E.Owner('WARRIOR')=='WARRIOR','CORE resolves to the current class only')
check(E.Gate('base','CORE')==E.Gate('base','WARLOCK') and not E.Gate('base','WARRIOR'),'Core gates like the current class')
-- 0.8 retracted mode: folded shows only the seal and its tray.
do
    local saved=E.state
    E.state={world=true,ObservePreview=function()end,Visible=function()return false end}
    check(E.Retracted() and E.Gate('tray','WARLOCK'),'Folded: the tray shows')
    check(not E.Gate('buffs','WARLOCK') and not E.Gate('maintenance','WARLOCK') and not E.Gate('buffs','CORE'),'Folded: buff and upkeep rows give way to the tray')
    check(E.Gate('art','WARLOCK') and E.Gate('dots','WARLOCK'),'Folded: the seal and target rows are unaffected')
    E.state.Visible=function()return true end
    check(not E.Retracted() and not E.Gate('tray','WARLOCK') and E.Gate('buffs','WARLOCK'),'Open: full HUD, no tray')
    E.state.Visible=function()return false end;E.Profile().tray=false
    check(not E.Retracted() and not E.Gate('tray','WARLOCK') and E.Gate('buffs','WARLOCK'),'Tray off: folding keeps the old behaviour')
    E.Profile().tray=true;E.state=saved
end
local flags={}
local oldFlag=ForeverAuras.SetLoadFlag
ForeverAuras.SetLoadFlag=function(name,value)flags[name]=value end
E.Profile().cast=false;E.Notify()
check(flags.FOREVERHUD_CORE_resources==flags.FOREVERHUD_WARLOCK_resources and flags.FOREVERHUD_CORE_cast==false,'Core load flags mirror the current class modules')
E.Shutdown()
check(flags.FOREVERHUD_CORE_resources==false and flags.FOREVERHUD_CORE_base==false,'Shutdown unloads Core displays too')
ForeverAuras.SetLoadFlag=oldFlag;E.InitDB()
local painted
E.Tint({Color=function(_,r,g,b,a)painted={r,g,b,a}end},'accent')
local accent=E.classColors.WARLOCK.accent
check(painted and painted[1]==accent[1] and painted[4]==accent[4],'Core bars take the current class accent')
check(pcall(E.Tint,nil,'accent') and pcall(E.Tint,{},'accent'),'Tint ignores missing regions and methods')
local opened=#imports
SlashCmdList.FOREVERHUD('install')
check(#imports==opened+1,'/fhud install opens the bundled import')

-- Chinese message keeps the same placeholder order (Lua 5.1 has no positional format).
local englishLocale=GetLocale;GetLocale=function()return 'zhCN' end
local Z={};assert(loadfile('src/ForeverHUD/Locale.lua'))('ForeverHUD',Z)
GetLocale=englishLocale
local key='%d displays of "%s" are outside their group because an earlier import stopped part way. In /fa, delete every top-level "%s" entry, then run /fhud install.'
check(Z.L(key)~=key and Z.L(key):format(2,'ForeverHUD | Warlock','ForeverHUD | Warlock'):find('ForeverHUD | Warlock',1,true),'Detached warning is translated and formats')
for _,text in ipairs({'"%s" is from ForeverHUD 0.4 or earlier. In /fa, delete that group, then run /fhud install to add the Core and the new class group.',
    'After "%s" is installed, run /fhud install again for "%s".'})do
    check(Z.L(text)~=text and Z.L(text):format('ForeverHUD | Core','ForeverHUD | Warlock'):find('ForeverHUD',1,true),'Split-install messages are translated')
end
print('Bundled import checks passed: '..checks)
