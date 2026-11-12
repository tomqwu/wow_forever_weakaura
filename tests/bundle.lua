-- Bundled class imports offered through ForeverAuras' companion interface.
dofile('tests/core.lua')
local E=ForeverHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/ForeverHUD/Catalog.lua'))('ForeverHUD',E)

local function read(path)local f=assert(io.open(path,'rb'));local v=f:read('*a');f:close();return v end
local warlock=E.bundledImports.WARLOCK
check(warlock and warlock.rootID=='ForeverHUD | Warlock' and warlock.slug=='forever-hud-warlock','Warlock import is bundled with its update slug')
check(warlock.encoded==read('dist/classes/ForeverHUD-Warlock.txt'):gsub('%s+$',''),'Bundled string is byte-identical to the published class file')
local classes=0;for _ in pairs(E.bundledImports)do classes=classes+1 end
check(classes==9,'All nine classes are bundled')

local registered,installed,imports
local function reset(data)
    registered,imports={},{}
    installed=data
    E.bundleRegistered,E.detachedChecked=nil,nil
    ForeverAuras.AddCompanionData=function(t)registered[#registered+1]=t end
    ForeverAuras.GetData=function(id)return id=='ForeverHUD | Warlock' and installed or nil end
    ForeverAuras.Import=function(encoded)imports[#imports+1]=encoded end
end
local function find(kind)
    for _,t in ipairs(registered)do if t[kind] then return t[kind] end end
end
UnitClass=function()return 'Warlock','WARLOCK' end
E.InitDB()

reset(nil);E.RegisterBundledImport()
local stash,slugs=find('stash'),find('slugs')
check(stash and stash['ForeverHUD | Warlock'] and stash['ForeverHUD | Warlock'].encoded==warlock.encoded,'Missing class group is listed as ready to install')
check(slugs and slugs['forever-hud-warlock'].wagoVersion==warlock.build,'Update slug carries the bundled build')
check(stash['ForeverHUD | Warlock']~=slugs['forever-hud-warlock'],'Install and update entries are separate tables')
E.RegisterBundledImport()
check(#registered==2,'Registration happens once per session')

reset({id='ForeverHUD | Warlock'});E.RegisterBundledImport()
check(find('stash') and find('slugs'),'A group installed before update tags is offered again; FA matches it by UID')

reset({id='ForeverHUD | Warlock',url='https://wago.io/forever-hud-warlock/'..(warlock.build-1)});E.RegisterBundledImport()
check(not find('stash') and find('slugs'),'An older tagged group uses FA\'s own update listing, not a second install entry')

reset({id='ForeverHUD | Warlock',url='https://wago.io/forever-hud-warlock/'..warlock.build});E.RegisterBundledImport()
check(not find('stash'),'A current group is not offered for install')

UnitClass=function()return 'Unknown','UNKNOWN' end;E.InitDB()
reset(nil);E.RegisterBundledImport()
check(#registered==0,'Unsupported classes register nothing')
UnitClass=function()return 'Warlock','WARLOCK' end;E.InitDB()

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
reset({id='ForeverHUD | Warlock'})
E.InstallBundled()
check(#imports==0 and printed[#printed]:find('2 displays',1,true),'Install refuses to import over detached displays and explains why')
E.InstallBundled(true)
check(#imports==1 and imports[1]==warlock.encoded,'install force still opens the import')
E.CheckDetached();E.CheckDetached()
local warnings=0;for _,line in ipairs(printed)do if line:find('outside their group',1,true)then warnings=warnings+1 end end
check(warnings==2,'The login check warns once per session (plus the refused install)')
ForeverAurasSaved.displays['ForeverHUD | Warlock | Chassis'].parent='ForeverHUD | Warlock | Frame'
ForeverAurasSaved.displays['ForeverHUD | Warlock | Health'].parent='ForeverHUD | Warlock | Resources'
E.InstallBundled()
check(#imports==2,'A clean install opens ForeverAuras\' import window')

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

SlashCmdList.FOREVERHUD('install')
check(#imports==3,'/fhud install opens the bundled import')

-- Chinese message keeps the same placeholder order (Lua 5.1 has no positional format).
local englishLocale=GetLocale;GetLocale=function()return 'zhCN' end
local Z={};assert(loadfile('src/ForeverHUD/Locale.lua'))('ForeverHUD',Z)
GetLocale=englishLocale
local key='%d displays of "%s" are outside their group because an earlier import stopped part way. In /fa, delete every top-level "%s" entry, then run /fhud install.'
check(Z.L(key)~=key and Z.L(key):format(2,'ForeverHUD | Warlock','ForeverHUD | Warlock'):find('ForeverHUD | Warlock',1,true),'Detached warning is translated and formats')
print('Bundled import checks passed: '..checks)
