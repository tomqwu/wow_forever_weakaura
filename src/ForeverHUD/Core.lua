local _, E = ...
-- All combat readings and timers belong to ForeverAuras' native triggers.
-- This helper owns preferences, the anchor, and cosmetic controls only.
ForeverHUD = E
-- v0.3.2 strings compare this field literally. Preserve that bridge while
-- allowing class imports to update independently with this compatible helper.
E.version = "0.3.2"
E.releaseVersion = "0.7.3"
E.importAPI = 2
E.rootID = "ForeverHUD"
-- Since 0.5.0 displays every class shares live in one Core group; each class
-- group holds only its own spells, effects and art.
E.coreID = "ForeverHUD | Core"
E.coreParts = {
    ["Health"]=true, ["Resource"]=true, ["Cast"]=true,
    ["Native cooldowns"]=true, ["Native utility"]=true, ["Native items"]=true,
    ["Native player effects"]=true, ["Native tracked bars"]=true,
}
E.classNames = {
    WARLOCK="Warlock", WARRIOR="Warrior", MAGE="Mage", PRIEST="Priest",
    ROGUE="Rogue", DRUID="Druid", HUNTER="Hunter", SHAMAN="Shaman", PALADIN="Paladin",
}
local defaults = {
    enabled=true, locked=true, combatOnly=false, hoverUtility=false,
    scale=1, x=0, y=-160, opacity=1,
    school="Auto", cleave=false, cooldownLayout="Forever",
    expandCombat=true, unfoldSound=false, unfold=true,
    resourceFlow=true, swingMode="Auto",
    hideDefaultCast=false, castBarMode="Default",
    fx=true,
    alerts=true,
    resources=true, primary=true, utility=true, dots=true, buffs=true, maintenance=true, trackedBars=false,
    cast=false, pet=true, art=true, motion=true, nameplates=false,
}
local anchor = CreateFrame("Frame", "ForeverHUDAnchor", UIParent)
anchor:SetSize(1, 1)
E.anchor = anchor
-- The input surface stays outside the native aura ancestry, so its ordinary
-- mouse visibility can follow combat-only mode without touching those widgets.
local handle = CreateFrame("Button", nil, UIParent)
handle:SetSize(68, 68)
handle:SetPoint("CENTER")
handle:RegisterForClicks("LeftButtonUp", "RightButtonUp")
handle:RegisterForDrag("LeftButton")
handle:SetFrameStrata("MEDIUM")
handle:Hide()
E.handle = handle
local outline = handle:CreateTexture(nil, "OVERLAY")
outline:SetAllPoints()
outline:SetColorTexture(0.65, 0.45, 1, 0.12)
outline:Hide()
E.outline = outline
local events = CreateFrame("Frame")
E.events = events
E.hookedRoots = setmetatable({}, {__mode="k"})
local function readable(v) return not issecretvalue or not issecretvalue(v) end
function E.API() return ForeverAuras or WeakAuras end
-- True while FA's import/update coroutine runs. Its phase 1 re-adds every
-- display without a parent; nothing here may move or re-add regions then.
function E.Importing()
    local api=E.API()
    return api and api.IsImporting and api.IsImporting()==true or false
end
function E.ClassID()
    return E.class and E.classNames[E.class] and ('ForeverHUD | '..E.classNames[E.class]) or nil
end
-- The display ID for a section name such as "Health" or "Primary | Native left":
-- Core parts live under the Core group, everything else under the class group.
function E.DisplayID(name)
    local section=name:match('^(.-) | ') or name
    if E.coreParts[section] then return E.coreID..' | '..name end
    local classID=E.ClassID()
    return classID and (classID..' | '..name) or nil
end
-- Gate/style calls from Core displays pass "CORE": they belong to the current class.
function E.Owner(class)
    if class=='CORE' then return E.class end
    return class
end
local function topRoot(api,id)
    local ok,data=pcall(api.GetData,id)
    if not ok or type(data)~='table' or data.id~=id then return nil end
    -- Native per-group updates preserve an existing combined parent.
    -- A fresh Core or class import has no parent and owns its own anchor.
    if data.parent then return E.rootID end
    return id
end
-- Every installed root this class uses: the combined root, or the standalone
-- class group and Core group. Never empty, so callers always have a target.
function E.GetRootIDs()
    local api,ids,seen=E.API(),{},{}
    if api and api.GetData then
        for _,id in ipairs({E.ClassID(),E.coreID}) do
            local root=id and topRoot(api,id)
            if root and not seen[root] then seen[root]=true;ids[#ids+1]=root end
        end
    end
    if #ids==0 then ids[1]=E.rootID end
    return ids
end
function E.GetRootID() return E.GetRootIDs()[1] end
local function rootRegions()
    local api,regions=E.API(),{}
    if not api or not api.GetRegion then return regions end
    for _,id in ipairs(E.GetRootIDs()) do
        local region=api.GetRegion(id)
        if region then regions[#regions+1]=region end
    end
    return regions
end
-- Paint a shared Core bar with the current class's colour.
function E.Tint(region,key)
    local colors=E.classColors and E.class and E.classColors[E.class]
    local color=colors and colors[key]
    if not region or not color or not region.Color then return end
    region:Color(color[1],color[2],color[3],color[4])
end
function E.Profile()
    if not E.class then return end
    return ForeverHUDDB and ForeverHUDDB.profiles and ForeverHUDDB.profiles[E.class]
end
local function fill(profile)
    if profile.castBarMode~='Default' and profile.castBarMode~='ForeverHUD' and profile.castBarMode~='Both' then
        profile.castBarMode=profile.cast~=false and profile.hideDefaultCast==true and 'ForeverHUD' or 'Default'
    end
    for key, value in pairs(defaults) do
        if type(profile[key]) ~= type(value) then profile[key] = value end
    end
    profile.cast=profile.castBarMode~='Default'
    profile.hideDefaultCast=profile.castBarMode=='ForeverHUD'
    local function limit(key, low, high)
        local value = profile[key]
        if value ~= value or value == math.huge or value == -math.huge then value = defaults[key] end
        profile[key] = math.max(low, math.min(high, value))
    end
    limit("scale", 0.6, 1.6); limit("opacity", 0.25, 1)
    limit("x", -2000, 2000); limit("y", -1200, 1200)
    if E.schools and E.class then
        local valid=profile.school=="Auto"
        for _,school in ipairs(E.schools[E.class]) do if profile.school==school then valid=true end end
        if not valid then profile.school="Auto" end
    end
    if profile.cooldownLayout~='Forever' and profile.cooldownLayout~='Class plan' then profile.cooldownLayout='Forever' end
    if profile.swingMode~='Auto' and profile.swingMode~='Single' and profile.swingMode~='Dual' then profile.swingMode='Auto' end
end
function E.InitDB()
    if type(ForeverHUDDB) ~= "table" then ForeverHUDDB = {} end
    if type(ForeverHUDDB.profiles) ~= "table" then ForeverHUDDB.profiles = {} end
    ForeverHUDDB.version = 1
    local _, class = UnitClass("player")
    if not readable(class) or not E.classNames[class] then E.class = nil; return end
    E.class = class
    if type(ForeverHUDDB.profiles[class]) ~= "table" then ForeverHUDDB.profiles[class] = {} end
    fill(ForeverHUDDB.profiles[class])
end
function E.InCombat()
    local value = InCombatLockdown()
    return not readable(value) or value == true
end
function E.LiveWorld()
    return not E.state or (E.state.world and not E.state.loading and not E.state.hidden)
end
function E.Gate(module, class)
    class = E.Owner(class)
    local p = E.Profile()
    if not p or E.class ~= class or not p.enabled or not E.LiveWorld() then return false end
    local api = E.API()
    local preview = api and api.IsOptionsOpen and api.IsOptionsOpen()
    if E.state then E.state.ObservePreview(preview==true) end
    if not preview and p.combatOnly and not E.InCombat() then return false end
    if module == "base" then return true end
    if p[module] == false then return false end
    if module == "motion" and not p.art then return false end
    if module == "fx" and (not p.art or (E.state and (not E.state.world or E.state.loading or E.state.hidden or preview
        or E.Call(UnitIsDeadOrGhost,"player")~=false))) then return false end
    if E.state and (module=="primary" or module=="resources" or module=="pet") and not E.state.Visible() then return false end
    if module == "utility" and p.hoverUtility and not preview then
        return E.hovering == true or E.utilityPinned == true
    end
    return true
end
function E.Notify()
    local api = E.API()
    local p = E.Profile()
    if api and api.SetLoadFlag then
        for class in pairs(E.classNames) do
            local enabled = p and p.enabled and class == E.class and E.LiveWorld() or false
            api.SetLoadFlag("FOREVERHUD_"..class.."_base", enabled)
            for _, module in ipairs(E.modules) do
                local on = enabled and p[module[1]] ~= false
                if module[1] == "motion" then on = on and p.art end
                if module[1] == "fx" then on = on and p.art end
                api.SetLoadFlag("FOREVERHUD_"..class.."_"..module[1], on)
            end
            api.SetLoadFlag('FOREVERHUD_'..class..'_fx_power',enabled and p.fx and p.art and p.resources or false)
        end
        -- Core displays follow the current class's preferences.
        local enabled = p and p.enabled and E.class ~= nil and E.LiveWorld() or false
        api.SetLoadFlag("FOREVERHUD_CORE_base", enabled)
        for _, module in ipairs(E.modules) do
            api.SetLoadFlag("FOREVERHUD_CORE_"..module[1], enabled and p[module[1]] ~= false or false)
        end
    end
    if E.discovery then E.discovery.ApplyFlags() end
    if E.RefreshEquipment and not E.InCombat() then E.RefreshEquipment() end
    if E.RefreshCasting then E.RefreshCasting() end
    if E.RefreshFX then E.RefreshFX(false) end
    if E.RefreshAlerts then E.RefreshAlerts() end
    handle:SetShown(#rootRegions() > 0 and E.Gate("base", E.class) and (p.art or not p.locked))
    if api and api.ScanEvents then api.ScanEvents("FOREVERHUD_UPDATE") end
end
function E.ApplyLayout()
    if E.InCombat() then E.pending = true; return end
    -- Never re-parent a root the importer has temporarily detached; the bind
    -- retry applies the layout once the import finishes.
    if E.Importing() then E.pending = true; E.Bind(); return end
    local p = E.Profile()
    if not p then handle:Hide(); return end
    anchor:ClearAllPoints()
    anchor:SetPoint("CENTER", UIParent, "CENTER", p.x, p.y)
    local regions = rootRegions()
    -- The Core and class roots share the anchor, so they move and scale together.
    for _, region in ipairs(regions) do
        -- FA can initialize before its companion anchor exists. Repair the
        -- actual parent/anchor once registered, outside combat, rather than
        -- assuming SELECTFRAME resolved its target during import.
        if region.SetParent then region:SetParent(anchor) end
        if region.SetAnchor then region:SetAnchor("CENTER",anchor,"CENTER") end
        if region.SetOffset then region:SetOffset(0,0) end
        -- Scale the group, keeping the screen position in UIParent units.
        region:SetScale(p.scale)
        if region.SetRegionAlpha then region:SetRegionAlpha(p.opacity) end
    end
    handle:SetScale(p.scale)
    handle:ClearAllPoints()
    -- A scaled button's anchor offsets are in its own units.
    handle:SetPoint("CENTER", UIParent, "CENTER", p.x/p.scale, p.y/p.scale+13)
    handle:SetShown(#regions > 0 and E.Gate("base", E.class) and (p.art or not p.locked))
    outline:SetShown(not p.locked)
    E.pending = nil
end
local function finishBind()
    E.bindTimer=nil
    if E.state and not E.state.world then return end
    local api=E.API()
    -- Import updates temporarily strip the root's parent in phase 1. Wait for
    -- the public import state to settle before choosing/anchoring its root.
    -- A large import can outlast the fast window, so keep retrying slowly
    -- rather than giving up and leaving the layout unapplied until combat.
    if E.Importing() then
        E.bindAttempts=E.bindAttempts+1
        E.bindTimer=C_Timer.NewTimer(E.bindAttempts<1200 and .1 or 1,finishBind)
        return
    end
    E.ApplyLayout()
    if E.discovery then E.discovery.Schedule() end
    if E.RefreshFX then E.RefreshFX(true) end
    -- Hook each root region once: roots can switch between the combined and
    -- standalone Core/class groups, and re-hooking would stack handlers.
    for _,region in ipairs(rootRegions()) do
        if region.HookScript and not E.hookedRoots[region] then
            E.hookedRoots[region]=true
            region:HookScript('OnHide',function()if E.motion and not E.Importing() then E.motion.Stop() end end)
            region:HookScript('OnShow',function()if E.motion and E.state and not E.Importing() then E.motion.Reconcile() end end)
        end
    end
end
function E.Bind()
    if E.bindTimer or not C_Timer or not C_Timer.NewTimer then return end
    E.bindAttempts=0
    E.bindTimer=C_Timer.NewTimer(0,finishBind)
end
function E.Set(key, value)
    local p = E.Profile()
    if not p or defaults[key] == nil or type(defaults[key]) ~= type(value) then return end
    if key=='cast' then key,value='castBarMode',value and 'ForeverHUD' or 'Default'
    elseif key=='hideDefaultCast' then
        local mode=E.queued and E.queued.castBarMode or p.castBarMode
        key,value='castBarMode',value and 'ForeverHUD' or (mode~='Default' and 'Both' or 'Default')
    end
    -- Keep all preference edits out of restricted native widget ancestry.
    if E.InCombat() then
        E.queued = E.queued or {}; E.queued[key] = value
        if E.panel and E.panel.notice then E.panel.notice:SetText(E.L("Changes apply after combat.")) end
        return
    end
    p[key] = value; fill(p)
    if E.discovery and key=="enabled" then
        if value then E.discovery.Start() else E.discovery.Stop() end
    end
    if key=='enabled' and not value and E.ClearInteraction then E.ClearInteraction() end
    if E.state then
        if key=="enabled" then
            if value then E.state.Start() else E.state.Stop() end
        else E.state.Update(true) end
    end
    if E.discovery and (key=="school" or key=="cleave" or key=="cooldownLayout") then E.discovery.Schedule() end
    if E.RefreshPresentation then E.RefreshPresentation() end
    if E.RefreshEquipment then E.RefreshEquipment() end
    E.ApplyLayout(); E.Notify()
end
function E.Reset()
    if E.InCombat() then return end
    local p = E.Profile(); if not p then return end
    for key, value in pairs(defaults) do p[key] = value end
    E.hovering, E.utilityPinned = false, false
    if E.state then E.state.Start() end
    if E.discovery then E.discovery.Start() end
    E.ApplyLayout(); E.Notify()
    if E.RefreshOptions then E.RefreshOptions() end
end
function E.ResetPosition()
    if E.InCombat() then
        E.Set("x",defaults.x); E.Set("y",defaults.y); return
    end
    local p=E.Profile(); if not p then return end
    p.x,p.y=defaults.x,defaults.y
    E.ApplyLayout(); E.Notify()
    if E.RefreshOptions then E.RefreshOptions() end
end
-- Bundled class imports. ForeverAuras' companion interface lists the current
-- class in /fa: "ready to install" when the group is missing (or predates
-- update tags), or an update when the installed tag's build is older. FA runs
-- the import and shows its window first; nothing here writes aura data.
local function bundleFor(class) return class and E.bundledImports and E.bundledImports[class] end
-- The bundles this character needs, Core first: class displays sit on top of it.
local function bundlesFor(class)
    local list={}
    if not bundleFor(class) then return list end
    if bundleFor('CORE') then list[#list+1]=bundleFor('CORE') end
    list[#list+1]=bundleFor(class)
    return list
end
E.BundlesFor=bundlesFor
local function companionEntry(bundle)
    return {name=bundle.rootID..' '..bundle.version, author='ForeverHUD', encoded=bundle.encoded, wagoVersion=bundle.build,
        versionNote=E.L('Bundled with ForeverHUD. ForeverAuras shows its import window before changing anything.')}
end
function E.InstalledBuild(rootID)
    local api=E.API()
    local data=api and api.GetData and api.GetData(rootID)
    if type(data)~='table' then return nil end
    local url=type(data.url)=='string' and data.url or ''
    return tonumber(url:match('wago%.io/[^/]+/(%d+)')) or 0
end
-- Displays of this class left without a parent by an import that stopped
-- part way. Read-only scan of FA's saved table; the class root itself is a
-- legitimate parentless display for a standalone class install.
function E.DetachedDisplays(rootID)
    local saved=ForeverAurasSaved and ForeverAurasSaved.displays
    if type(saved)~='table' then return 0 end
    local prefix,count=rootID..' | ',0
    for id,data in pairs(saved) do
        if type(id)=='string' and id:sub(1,#prefix)==prefix and type(data)=='table' and data.parent==nil then count=count+1 end
    end
    return count
end
local function warnDetached(rootID,count)
    print('ForeverHUD: '..E.L('%d displays of "%s" are outside their group because an earlier import stopped part way. In /fa, delete every top-level "%s" entry, then run /fhud install.'):format(count,rootID,rootID))
end
function E.RegisterBundledImport()
    local bundles,api=bundlesFor(E.class),E.API()
    if E.bundleRegistered or #bundles==0 or not api or not api.AddCompanionData then return end
    E.bundleRegistered=true
    for _,bundle in ipairs(bundles) do
        api.AddCompanionData({slugs={[bundle.slug]=companionEntry(bundle)}})
        local installed=E.InstalledBuild(bundle.rootID)
        -- FA's import window matches an existing group by UID and offers Update.
        if not installed or installed==0 then api.AddCompanionData({stash={[bundle.rootID]=companionEntry(bundle)}}) end
    end
end
function E.CheckDetached()
    if E.detachedChecked then return end
    local bundles=bundlesFor(E.class)
    if #bundles==0 then return end
    E.detachedChecked=true
    for _,bundle in ipairs(bundles) do
        local count=E.DetachedDisplays(bundle.rootID)
        if count>0 then warnDetached(bundle.rootID,count) end
    end
end
-- A class group from 0.4 or earlier still carries the displays that moved to
-- Core in 0.5.0; with both installed they would draw twice. Read-only check.
function E.OldClassLayout()
    local api,classID=E.API(),E.ClassID()
    if not api or not api.GetData or not classID then return false end
    local ok,data=pcall(api.GetData,classID..' | Health')
    return ok and type(data)=='table'
end
function E.CheckOldLayout()
    if E.oldLayoutChecked or not E.class then return end
    E.oldLayoutChecked=true
    if E.OldClassLayout() then
        print('ForeverHUD: '..E.L('"%s" is from ForeverHUD 0.4 or earlier. In /fa, delete that group, then run /fhud install to add the Core and the new class group.'):format(E.ClassID()))
    end
end
-- Before 0.4.0 this addon was EclipseHUD with "Eclipse | <Class>" auras. New
-- names mean new UIDs, so nothing is migrated: warn once so both get removed.
local LEGACY_PREFIX='Eclipse | '
function E.LegacyDisplays()
    local saved=ForeverAurasSaved and ForeverAurasSaved.displays
    if type(saved)~='table' then return 0 end
    local count=0
    for id in pairs(saved) do
        if type(id)=='string' and id:sub(1,#LEGACY_PREFIX)==LEGACY_PREFIX then count=count+1 end
    end
    return count
end
function E.CheckLegacy()
    if E.legacyChecked then return end
    E.legacyChecked=true
    if rawget(_G,'EclipseHUD')~=nil then
        print('ForeverHUD: '..E.L('The old EclipseHUD addon is still installed. Exit the game and delete Interface/AddOns/EclipseHUD.'))
    end
    local count=E.LegacyDisplays()
    if count>0 then
        print('ForeverHUD: '..E.L('%d old "Eclipse | ..." displays are still in /fa. ForeverHUD does not use them; delete every "Eclipse | ..." group.'):format(count))
    end
end
-- FA runs one import window at a time, so /fhud install opens the first
-- bundle that is missing or older (Core before class) and says what is next.
function E.NextBundle()
    local bundles=bundlesFor(E.class)
    for index,bundle in ipairs(bundles) do
        local installed=E.InstalledBuild(bundle.rootID)
        if not installed or installed<bundle.build then return bundle,bundles[index+1] end
    end
    return bundles[#bundles],nil
end
function E.InstallBundled(force)
    local api=E.API()
    local bundle,later=E.NextBundle()
    if not bundle or not api or not api.Import then print('ForeverHUD: '..E.L('No bundled import is available for this class.'));return end
    if E.OldClassLayout() and not force then E.oldLayoutChecked=false;E.CheckOldLayout();return end
    for _,item in ipairs(bundlesFor(E.class)) do
        local count=E.DetachedDisplays(item.rootID)
        -- An import over detached displays meets their old UIDs outside the group.
        if count>0 and not force then warnDetached(item.rootID,count);return end
    end
    api.Import(bundle.encoded)
    if later then
        print('ForeverHUD: '..E.L('After "%s" is installed, run /fhud install again for "%s".'):format(bundle.rootID,later.rootID))
    end
end
local hoverTimer
local function stopHover()
    if hoverTimer then hoverTimer:Cancel(); hoverTimer = nil end
end
function E.Hover(value)
    stopHover()
    local p=E.Profile()
    if not p or not p.enabled or (E.state and not E.state.world) then E.hovering=false;return end
    if value then
        E.hovering = true; E.Notify()
    elseif C_Timer and C_Timer.NewTimer then
        -- A short grace period lets the cursor move from the seal to its row.
        hoverTimer = C_Timer.NewTimer(0.7, function()
            E.hovering = false; hoverTimer = nil; E.Notify()
        end)
    else E.hovering = false; E.Notify() end
end
function E.ClearInteraction()
    stopHover();E.StopDrag(false);E.hovering,E.utilityPinned=false,false
end
handle:SetScript("OnEnter", function()
    E.Hover(true)
    local p = E.Profile()
    if p and not p.locked then
        GameTooltip:SetOwner(handle, "ANCHOR_TOP")
        GameTooltip:SetText(E.L("Left-click to expand or fold. Right-click for settings."))
        GameTooltip:Show()
    end
end)
handle:SetScript("OnLeave", function() E.Hover(false); GameTooltip:Hide() end)
handle:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
        if E.ToggleOptions then E.ToggleOptions() end
    else
        local opened=E.state and E.state.ToggleInspect()
        if opened==nil then E.utilityPinned=not E.utilityPinned else E.utilityPinned=opened end
        E.Notify()
    end
end)
handle:SetScript("OnDragStart", function()
    local p = E.Profile()
    if not p or p.locked or E.InCombat() then return end
    -- Move a UIParent-owned proxy, so FA's parented native widgets stay still
    -- until the drag ends and the saved layout is applied once.
    if not E.drag then
        E.drag = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        E.drag:SetSize(68, 68); E.drag:SetMovable(true); E.drag:SetClampedToScreen(true)
        E.drag:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
        E.drag:SetBackdropColor(0.1, 0.06, 0.2, 0.85); E.drag:SetBackdropBorderColor(0.7, 0.5, 1, 1)
    end
    E.drag:ClearAllPoints(); E.drag:SetPoint("CENTER", UIParent, "CENTER", p.x, p.y)
    E.drag:Show(); E.drag:StartMoving()
end)
function E.StopDrag(save)
    if not E.drag or not E.drag:IsShown() then return end
    E.drag:StopMovingOrSizing()
    local x, y = E.drag:GetCenter()
    E.drag:Hide()
    if not save or E.InCombat() or not readable(x) or not readable(y) then return end
    local cx, cy = UIParent:GetCenter()
    if not readable(cx) or not readable(cy) or not x or not y or not cx or not cy then return end
    E.Set("x", math.floor(x-cx+0.5)); E.Set("y", math.floor(y-cy+0.5))
    if E.RefreshOptions then E.RefreshOptions() end
end
handle:SetScript("OnDragStop", function() E.StopDrag(true) end)
function E.Shutdown()
    if E.bindTimer then E.bindTimer:Cancel();E.bindTimer=nil end
    stopHover(); E.StopDrag(false)
    if E.discovery then E.discovery.Stop() end
    if E.state then E.state.Stop() end
    if E.StopPresentation then E.StopPresentation() end
    if E.StopCasting then E.StopCasting() end
    if E.StopFX then E.StopFX() end
    if E.StopAlerts then E.StopAlerts() end
    E.hovering, E.utilityPinned = false, false
    handle:Hide()
    local api = E.API()
    if api and api.SetLoadFlag then
        api.SetLoadFlag('FOREVERHUD_WARRIOR_pet_offhand',false)
        for class in pairs(E.classNames) do
            api.SetLoadFlag("FOREVERHUD_"..class.."_base", false)
            for _, module in ipairs(E.modules) do api.SetLoadFlag("FOREVERHUD_"..class.."_"..module[1], false) end
            api.SetLoadFlag('FOREVERHUD_'..class..'_fx_power',false)
        end
        api.SetLoadFlag("FOREVERHUD_CORE_base", false)
        for _, module in ipairs(E.modules) do api.SetLoadFlag("FOREVERHUD_CORE_"..module[1], false) end
    end
end
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LEAVING_WORLD")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" then
        if addon ~= "ForeverHUD" then return end
        E.InitDB(); events:UnregisterEvent("ADDON_LOADED")
        -- Before FA's login announcement, so /fa lists the bundled import.
        E.RegisterBundledImport()
    elseif event == "PLAYER_LEAVING_WORLD" then E.Shutdown(); return
    elseif event == "PLAYER_REGEN_DISABLED" then E.StopDrag(false)
    elseif event == "PLAYER_REGEN_ENABLED" then
        local p = E.Profile()
        if p and E.queued then
            for key, value in pairs(E.queued) do p[key] = value end
            fill(p); E.queued = nil
        end
        E.ApplyLayout()
        if E.discovery then
            if p and p.enabled then E.discovery.Start() else E.discovery.Stop() end
        end
        if E.state then
            if p and p.enabled then E.state.Update(false) else E.state.Stop() end
        end
        if p and not p.enabled then E.ClearInteraction() end
        if E.RefreshOptions then E.RefreshOptions() end
    else
        E.InitDB(); E.ApplyLayout()
        if E.discovery then E.discovery.Start() end
        if E.state then E.state.Start() end
        if event == "PLAYER_ENTERING_WORLD" then E.RegisterBundledImport(); E.CheckDetached(); E.CheckLegacy(); E.CheckOldLayout() end
    end
    E.Notify()
end)
