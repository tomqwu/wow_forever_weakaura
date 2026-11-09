local _, E = ...
-- All combat readings and timers belong to ForeverAuras' native triggers.
-- This helper owns preferences, the anchor, and cosmetic controls only.
EclipseHUD = E
E.rootID = "Eclipse | Class Combat HUD"
E.classNames = {
    WARLOCK="Warlock", WARRIOR="Warrior", MAGE="Mage", PRIEST="Priest",
    ROGUE="Rogue", DRUID="Druid", HUNTER="Hunter", SHAMAN="Shaman", PALADIN="Paladin",
}
local defaults = {
    enabled=true, locked=true, combatOnly=false, hoverUtility=false,
    scale=1, x=0, y=-150, opacity=1,
    resources=true, primary=true, utility=true, dots=true, buffs=true,
    cast=true, pet=true, art=true, motion=true, nameplates=false,
}
local anchor = CreateFrame("Frame", "EclipseHUDAnchor", UIParent)
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
local function readable(v) return not issecretvalue or not issecretvalue(v) end
function E.API() return ForeverAuras or WeakAuras end
function E.Profile()
    if not E.class then return end
    return EclipseHUDDB and EclipseHUDDB.profiles and EclipseHUDDB.profiles[E.class]
end
local function fill(profile)
    for key, value in pairs(defaults) do
        if type(profile[key]) ~= type(value) then profile[key] = value end
    end
    local function limit(key, low, high)
        local value = profile[key]
        if value ~= value or value == math.huge or value == -math.huge then value = defaults[key] end
        profile[key] = math.max(low, math.min(high, value))
    end
    limit("scale", 0.6, 1.6); limit("opacity", 0.25, 1)
    limit("x", -2000, 2000); limit("y", -1200, 1200)
end
function E.InitDB()
    if type(EclipseHUDDB) ~= "table" then EclipseHUDDB = {} end
    if type(EclipseHUDDB.profiles) ~= "table" then EclipseHUDDB.profiles = {} end
    EclipseHUDDB.version = 1
    local _, class = UnitClass("player")
    if not readable(class) or not E.classNames[class] then E.class = nil; return end
    E.class = class
    if type(EclipseHUDDB.profiles[class]) ~= "table" then EclipseHUDDB.profiles[class] = {} end
    fill(EclipseHUDDB.profiles[class])
end
function E.InCombat()
    local value = InCombatLockdown()
    return not readable(value) or value == true
end
function E.Gate(module, class)
    local p = E.Profile()
    if not p or E.class ~= class or not p.enabled then return false end
    local api = E.API()
    local preview = api and api.IsOptionsOpen and api.IsOptionsOpen()
    if not preview and p.combatOnly and not E.InCombat() then return false end
    if module == "base" then return true end
    if p[module] == false then return false end
    if module == "motion" and not p.art then return false end
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
            local enabled = p and p.enabled and class == E.class or false
            api.SetLoadFlag("ECLIPSE_"..class.."_base", enabled)
            for _, module in ipairs(E.modules) do
                local on = enabled and p[module[1]] ~= false
                if module[1] == "motion" then on = on and p.art end
                api.SetLoadFlag("ECLIPSE_"..class.."_"..module[1], on)
            end
        end
    end
    local region = api and api.GetRegion and api.GetRegion(E.rootID)
    handle:SetShown(region ~= nil and E.Gate("base", E.class) and (p.art or not p.locked))
    if api and api.ScanEvents then api.ScanEvents("ECLIPSE_HUD_UPDATE") end
end
function E.ApplyLayout()
    if E.InCombat() then E.pending = true; return end
    local p = E.Profile()
    if not p then handle:Hide(); return end
    anchor:ClearAllPoints()
    anchor:SetPoint("CENTER", UIParent, "CENTER", p.x, p.y)
    local api = E.API()
    local region = api and api.GetRegion and api.GetRegion(E.rootID)
    if region then
        -- Scale the group, keeping the screen position in UIParent units.
        region:SetScale(p.scale)
        if region.SetRegionAlpha then region:SetRegionAlpha(p.opacity) end
    end
    handle:SetScale(p.scale)
    handle:ClearAllPoints()
    -- A scaled button's anchor offsets are in its own units.
    handle:SetPoint("CENTER", UIParent, "CENTER", p.x/p.scale, p.y/p.scale+13)
    handle:SetShown(region ~= nil and E.Gate("base", E.class) and (p.art or not p.locked))
    outline:SetShown(not p.locked)
    E.pending = nil
end
function E.Bind()
    -- Group initialization can precede the region registration in FA.
    if C_Timer and C_Timer.After then C_Timer.After(0, E.ApplyLayout) end
end
function E.Set(key, value)
    local p = E.Profile()
    if not p or defaults[key] == nil or type(defaults[key]) ~= type(value) then return end
    -- Keep all preference edits out of restricted native widget ancestry.
    if E.InCombat() then
        E.queued = E.queued or {}; E.queued[key] = value
        if E.panel and E.panel.notice then E.panel.notice:SetText(E.L("Changes apply after combat.")) end
        return
    end
    p[key] = value; fill(p)
    E.ApplyLayout(); E.Notify()
end
function E.Reset()
    if E.InCombat() then return end
    local p = E.Profile(); if not p then return end
    for key, value in pairs(defaults) do p[key] = value end
    E.hovering, E.utilityPinned = false, false
    E.ApplyLayout(); E.Notify()
    if E.RefreshOptions then E.RefreshOptions() end
end
local hoverTimer
local function stopHover()
    if hoverTimer then hoverTimer:Cancel(); hoverTimer = nil end
end
function E.Hover(value)
    stopHover()
    if value then
        E.hovering = true; E.Notify()
    elseif C_Timer and C_Timer.NewTimer then
        -- A short grace period lets the cursor move from the seal to its row.
        hoverTimer = C_Timer.NewTimer(0.7, function()
            E.hovering = false; hoverTimer = nil; E.Notify()
        end)
    else E.hovering = false; E.Notify() end
end
handle:SetScript("OnEnter", function()
    E.Hover(true)
    local p = E.Profile()
    if p and not p.locked then
        GameTooltip:SetOwner(handle, "ANCHOR_TOP")
        GameTooltip:SetText(E.L("Drag the center seal to move. Right-click it for settings."))
        GameTooltip:Show()
    end
end)
handle:SetScript("OnLeave", function() E.Hover(false); GameTooltip:Hide() end)
handle:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
        if E.ToggleOptions then E.ToggleOptions() end
    else E.utilityPinned = not E.utilityPinned; E.Notify() end
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
    stopHover(); E.StopDrag(false)
    E.hovering, E.utilityPinned = false, false
    handle:Hide()
    local api = E.API()
    if api and api.SetLoadFlag then
        for class in pairs(E.classNames) do
            api.SetLoadFlag("ECLIPSE_"..class.."_base", false)
            for _, module in ipairs(E.modules) do api.SetLoadFlag("ECLIPSE_"..class.."_"..module[1], false) end
        end
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
        if addon ~= "EclipseHUD" then return end
        E.InitDB(); events:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LEAVING_WORLD" then E.Shutdown(); return
    elseif event == "PLAYER_REGEN_DISABLED" then E.StopDrag(false)
    elseif event == "PLAYER_REGEN_ENABLED" then
        local p = E.Profile()
        if p and E.queued then
            for key, value in pairs(E.queued) do p[key] = value end
            fill(p); E.queued = nil
        end
        E.ApplyLayout()
        if E.RefreshOptions then E.RefreshOptions() end
    else E.InitDB(); E.ApplyLayout() end
    E.Notify()
end)
