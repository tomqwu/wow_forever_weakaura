-- Bundled class imports offered through ForeverAuras' companion interface.
dofile('tests/core.lua')
local E=EclipseHUD
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
assert(loadfile('src/EclipseHUD/Catalog.lua'))('EclipseHUD',E)

local function read(path)local f=assert(io.open(path,'rb'));local v=f:read('*a');f:close();return v end
local warlock=E.bundledImports.WARLOCK
check(warlock and warlock.rootID=='Eclipse | Warlock' and warlock.slug=='eclipse-hud-warlock','Warlock import is bundled with its update slug')
check(warlock.encoded==read('dist/classes/Eclipse-Warlock.txt'):gsub('%s+$',''),'Bundled string is byte-identical to the published class file')
local classes=0;for _ in pairs(E.bundledImports)do classes=classes+1 end
check(classes==9,'All nine classes are bundled')

local registered,installed,imports
local function reset(data)
    registered,imports={},{}
    installed=data
    E.bundleRegistered,E.detachedChecked=nil,nil
    ForeverAuras.AddCompanionData=function(t)registered[#registered+1]=t end
    ForeverAuras.GetData=function(id)return id=='Eclipse | Warlock' and installed or nil end
    ForeverAuras.Import=function(encoded)imports[#imports+1]=encoded end
end
local function find(kind)
    for _,t in ipairs(registered)do if t[kind] then return t[kind] end end
end
UnitClass=function()return 'Warlock','WARLOCK' end
E.InitDB()

reset(nil);E.RegisterBundledImport()
local stash,slugs=find('stash'),find('slugs')
check(stash and stash['Eclipse | Warlock'] and stash['Eclipse | Warlock'].encoded==warlock.encoded,'Missing class group is listed as ready to install')
check(slugs and slugs['eclipse-hud-warlock'].wagoVersion==warlock.build,'Update slug carries the bundled build')
check(stash['Eclipse | Warlock']~=slugs['eclipse-hud-warlock'],'Install and update entries are separate tables')
E.RegisterBundledImport()
check(#registered==2,'Registration happens once per session')

reset({id='Eclipse | Warlock'});E.RegisterBundledImport()
check(find('stash') and find('slugs'),'A group installed before update tags is offered again; FA matches it by UID')

reset({id='Eclipse | Warlock',url='https://wago.io/eclipse-hud-warlock/'..(warlock.build-1)});E.RegisterBundledImport()
check(not find('stash') and find('slugs'),'An older tagged group uses FA\'s own update listing, not a second install entry')

reset({id='Eclipse | Warlock',url='https://wago.io/eclipse-hud-warlock/'..warlock.build});E.RegisterBundledImport()
check(not find('stash'),'A current group is not offered for install')

UnitClass=function()return 'Unknown','UNKNOWN' end;E.InitDB()
reset(nil);E.RegisterBundledImport()
check(#registered==0,'Unsupported classes register nothing')
UnitClass=function()return 'Warlock','WARLOCK' end;E.InitDB()

-- Detached displays from an interrupted import block /eclipse install.
local printed={}
local oldPrint=print
print=function(...)printed[#printed+1]=table.concat({...},' ')end
ForeverAurasSaved={displays={
    ['Eclipse | Warlock']={},                                   -- standalone root: legitimate
    ['Eclipse | Warlock | Chassis']={},                         -- detached
    ['Eclipse | Warlock | Health']={},                          -- detached
    ['Eclipse | Warlock | Frame']={parent='Eclipse | Warlock'}, -- attached
    ['Eclipse | Warrior | Health']={},                          -- other class
}}
check(E.DetachedDisplays('Eclipse | Warlock')==2,'Only this class\'s parentless non-root displays count as detached')
reset({id='Eclipse | Warlock'})
E.InstallBundled()
check(#imports==0 and printed[#printed]:find('2 displays',1,true),'Install refuses to import over detached displays and explains why')
E.InstallBundled(true)
check(#imports==1 and imports[1]==warlock.encoded,'install force still opens the import')
E.CheckDetached();E.CheckDetached()
local warnings=0;for _,line in ipairs(printed)do if line:find('outside their group',1,true)then warnings=warnings+1 end end
check(warnings==2,'The login check warns once per session (plus the refused install)')
ForeverAurasSaved.displays['Eclipse | Warlock | Chassis'].parent='Eclipse | Warlock | Frame'
ForeverAurasSaved.displays['Eclipse | Warlock | Health'].parent='Eclipse | Warlock | Resources'
E.InstallBundled()
check(#imports==2,'A clean install opens ForeverAuras\' import window')
print=oldPrint

SlashCmdList.ECLIPSEHUD('install')
check(#imports==3,'/eclipse install opens the bundled import')

-- Chinese message keeps the same placeholder order (Lua 5.1 has no positional format).
local englishLocale=GetLocale;GetLocale=function()return 'zhCN' end
local Z={};assert(loadfile('src/EclipseHUD/Locale.lua'))('EclipseHUD',Z)
GetLocale=englishLocale
local key='%d displays of "%s" are outside their group because an earlier import stopped part way. In /fa, delete every top-level "%s" entry, then run /eclipse install.'
check(Z.L(key)~=key and Z.L(key):format(2,'Eclipse | Warlock','Eclipse | Warlock'):find('Eclipse | Warlock',1,true),'Detached warning is translated and formats')
print('Bundled import checks passed: '..checks)
