local _, E = ...
-- 0.14.0 (user: "add addon manager to include all addon into a box around
-- map, it's too crowded, similarly to what I've done in classmate addon"):
-- a ForeverHUD minimap button that gathers other addons' minimap buttons into
-- a framed tray, opened by hovering it. Only named, unprotected addon
-- launchers parented to the Minimap are borrowed; Blizzard controls, map pins
-- and protected frames are never touched, nothing moves in combat, and every
-- borrowed button returns exactly as found when grouping is turned off or the
-- button is hidden. With Forever Classmate (ForeverUtilities) loaded, its own
-- tray does the grouping and this button simply joins it.
local Tray = {}
E.minimapTray = Tray
local CELL, COLUMNS, PAD, TITLE = 34, 4, 8, 16
local BUTTON_NAME, TRAY_NAME = "ForeverHUDMinimapButton", "ForeverHUDMinimapTray"
local defaults = {show = true, group = true, angle = 225}

-- Blizzard minimap controls whose names do not start with Minimap/MiniMap.
local blizzard = {GameTimeFrame=true, TimeManagerClockButton=true, QueueStatusMinimapButton=true,
    GarrisonLandingPageMinimapButton=true, ExpansionLandingPageMinimapButton=true, AddonCompartmentFrame=true,
    LFGMinimapFrame=true, BattlefieldMinimap=true, HelpOpenWebTicketButton=true}

local records, order, hooked = {}, {}, {}
local tray, grid, settingsCell, button
local placing, pending, wanted, closeElapsed = false, false, false, 0
local events = CreateFrame("Frame")

local function call(method, frame, ...)
    if type(frame) ~= "table" or type(method) ~= "function" then return nil end
    local ok, a, b = pcall(method, frame, ...)
    if ok then return a, b end
end
local function number(v) return type(v) == "number" and v == v end
local function outOfCombat()
    if type(InCombatLockdown) == "function" then return InCombatLockdown() == false end
    return true
end

-- Account-wide: the minimap is the same for every character.
function Tray.Settings()
    if type(ForeverHUDDB) ~= "table" then return nil end
    if type(ForeverHUDDB.minimap) ~= "table" then ForeverHUDDB.minimap = {} end
    local db = ForeverHUDDB.minimap
    for key, value in pairs(defaults) do if db[key] == nil then db[key] = value end end
    if not number(db.angle) then db.angle = defaults.angle end
    return db
end

-- Forever Classmate already gathers minimap buttons; two trays would fight.
function Tray.Yields()
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    if type(loaded) ~= "function" then return false end
    local ok, result = pcall(loaded, "ForeverUtilities")
    return ok and result == true
end

-- A borrowable button: a named, unprotected addon Button on the Minimap that
-- looks like a minimap launcher (LibDBIcon, ForeverCore, or *Minimap* names).
function Tray.Candidate(frame)
    if type(frame) ~= "table" or records[frame] or frame == button then return false end
    if call(frame.IsObjectType, frame, "Button") ~= true then return false end
    local name = call(frame.GetName, frame)
    if type(name) ~= "string" or name == "" or name == BUTTON_NAME or name == TRAY_NAME then return false end
    if name:find("^MiniMap") or name:find("^Minimap") or blizzard[name] then return false end
    if call(frame.IsProtected, frame) ~= false then return false end
    return name:find("^LibDBIcon10_") ~= nil or rawget(frame, "minimapButtonSpec") ~= nil
        or name:lower():find("minimap") ~= nil
end

local function visible(b) return call(b.IsShown, b) == true end

-- 0.14.29 (user: "right click in mini map addon (other) will not work ... it
-- disappear again instead of showing addon right click option"): a borrowed
-- button's context menu belongs to that button, so hiding the tray under it
-- took the menu away. The tray now stays while such a menu is open.
local menuLists = {"DropDownList1", "L_DropDownList1", "Lib_DropDownList1", "LibDropDownMenu_List1", "MSA_DropDownList1"}
local function menuOpen()
    for _, name in ipairs(menuLists) do
        local list = _G[name]
        if type(list) == "table" and call(list.IsShown, list) == true then return true end
    end
    -- The newer Blizzard menu system, where the client has it.
    if type(Menu) == "table" and type(Menu.GetManager) == "function" then
        local ok, manager = pcall(Menu.GetManager)
        if ok and type(manager) == "table" and call(manager.GetOpenMenu, manager) then return true end
    end
    return false
end
Tray.MenuOpen = menuOpen

local function Layout()
    if not tray then return end
    placing = true
    local cells = {settingsCell}
    for _, b in ipairs(order) do if visible(b) then cells[#cells + 1] = b end end
    local columns = math.min(COLUMNS, #cells)
    local rows = math.ceil(#cells / COLUMNS)
    for index, cell in ipairs(cells) do
        local column, row = (index - 1) % COLUMNS, math.floor((index - 1) / COLUMNS)
        cell:ClearAllPoints()
        cell:SetPoint("CENTER", grid, "TOPLEFT", column * CELL + CELL / 2, -(row * CELL + CELL / 2))
    end
    placing = false
    local width = math.max(columns * CELL, CELL * 2)
    grid:SetSize(width, rows * CELL)
    tray:SetSize(width + PAD * 2, rows * CELL + PAD * 2 + TITLE)
    tray.cells = cells
end
Tray.Layout = Layout

local function Grab(b)
    -- Reparenting resets the frame level, so strata and level return too.
    local record = {parent = call(b.GetParent, b), points = {},
        strata = call(b.GetFrameStrata, b), level = call(b.GetFrameLevel, b),
        dragStart = b:GetScript("OnDragStart"), dragStop = b:GetScript("OnDragStop")}
    for index = 1, (call(b.GetNumPoints, b) or 0) do record.points[index] = {b:GetPoint(index)} end
    records[b] = record; order[#order + 1] = b
    -- Dragging inside the tray would fight its layout; it returns on release.
    b:SetScript("OnDragStart", nil); b:SetScript("OnDragStop", nil)
    b:SetParent(grid)
    if not hooked[b] then
        hooked[b] = true
        -- Owners re-place their buttons (login, settings, minimap shape). While
        -- borrowed, any such move is answered by re-laying out the tray.
        if type(hooksecurefunc) == "function" then
            hooksecurefunc(b, "SetPoint", function(self) if records[self] and not placing then Layout() end end)
        end
        b:HookScript("OnShow", function(self) if records[self] then Layout() end end)
        b:HookScript("OnHide", function(self) if records[self] then Layout() end end)
        -- A left-click runs the addon and closes the tray. A right-click, or
        -- any click that opened a menu, keeps the tray under that menu.
        b:HookScript("OnClick", function(self, which)
            if not records[self] then return end
            if which == "RightButton" or menuOpen() then closeElapsed = 0 else Tray.Close() end
        end)
    end
end

local function Release(b)
    local record = records[b]
    if not record then return end
    records[b] = nil
    if record.parent then b:SetParent(record.parent) end
    if type(record.strata) == "string" then call(b.SetFrameStrata, b, record.strata) end
    if number(record.level) then call(b.SetFrameLevel, b, record.level) end
    b:ClearAllPoints()
    for _, point in ipairs(record.points) do b:SetPoint(unpack(point)) end
    b:SetScript("OnDragStart", record.dragStart); b:SetScript("OnDragStop", record.dragStop)
end

function Tray.ReleaseAll()
    if not outOfCombat() then pending = true; return false end
    for _, b in ipairs(order) do Release(b) end
    order = {}
    if tray then Layout() end
    return true
end

function Tray.Scan()
    if not wanted or not Minimap or not tray then return end
    if not outOfCombat() then pending = true; return end
    local ok, children = pcall(function() return {Minimap:GetChildren()} end)
    if not ok or type(children) ~= "table" then return end
    local added = false
    for _, child in ipairs(children) do
        if Tray.Candidate(child) then Grab(child); added = true end
    end
    if added then
        table.sort(order, function(a, b) return (call(a.GetName, a) or "") < (call(b.GetName, b) or "") end)
    end
    Layout()
end

function Tray.Close() if tray then tray:Hide() end end

local function Place()
    tray:ClearAllPoints()
    local ax, ay = call(button.GetCenter, button)
    local ux, uy = call(UIParent.GetCenter, UIParent)
    local right = number(ax) and number(ux) and ax > ux
    local top = not (number(ay) and number(uy)) or ay > uy
    -- Open toward the screen center so the tray never runs off an edge.
    local vertical = top and "TOP" or "BOTTOM"
    tray:SetPoint(vertical .. (right and "RIGHT" or "LEFT"), button,
        vertical .. (right and "LEFT" or "RIGHT"), right and -4 or 4, 0)
end

-- Hovering the ForeverHUD minimap button opens the tray; it closes two
-- seconds after the pointer leaves both, on Escape, or on a left-click. It
-- stays while a borrowed button's right-click menu is open.
function Tray.Open()
    if not wanted or not tray then return false end
    closeElapsed = 0
    if not tray:IsShown() then
        Tray.Scan()
        -- Nothing to group: keep the minimap button's own tooltip.
        if #order == 0 then return false end
        Place(); tray:Show()
    end
    return true
end

function Tray.Active() return wanted end
function Tray.Borrowed()
    local list = {}
    for _, b in ipairs(order) do list[#list + 1] = b end
    return list
end
function Tray.Button() return button end

local function crestPath()
    return "Interface\\AddOns\\ForeverHUD\\Media\\crest-" .. string.lower(E.class or "warlock")
end

local function CreateTray()
    tray = CreateFrame("Frame", TRAY_NAME, UIParent, "BackdropTemplate")
    tray:SetFrameStrata("MEDIUM"); tray:SetFrameLevel(2); tray:SetClampedToScreen(true); tray:EnableMouse(true); tray:Hide()
    if UISpecialFrames then table.insert(UISpecialFrames, TRAY_NAME) end
    -- The settings panel's colors: deep violet fill, muted violet edge.
    if tray.SetBackdrop then
        tray:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
        tray:SetBackdropColor(0.035, 0.03, 0.065, 0.95); tray:SetBackdropBorderColor(0.36, 0.26, 0.52, 1)
    end
    local title = tray:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOP", tray, "TOP", 0, -PAD + 1); title:SetText(E.L("Addon buttons"))
    tray.title = title
    grid = CreateFrame("Frame", nil, tray); grid:SetPoint("TOPLEFT", tray, "TOPLEFT", PAD, -(PAD + TITLE))
    -- The first cell always opens ForeverHUD settings.
    settingsCell = CreateFrame("Button", nil, grid); settingsCell:SetSize(30, 30)
    local crest = settingsCell:CreateTexture(nil, "ARTWORK"); crest:SetAllPoints()
    settingsCell.crest = crest
    settingsCell:SetScript("OnClick", function() Tray.Close(); E.ToggleOptions() end)
    settingsCell:SetScript("OnEnter", function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetText(E.L("ForeverHUD settings"))
        -- The minimap button's own tooltip is replaced by the tray, so its hints live here.
        GameTooltip:AddLine(E.L("Click the ForeverHUD button: settings | Right-click: expand or fold"), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    settingsCell:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    -- Close after the pointer has been away from the tray and its button for
    -- two seconds. This runs only while the tray is open.
    tray:SetScript("OnUpdate", function(self, delta)
        local over = call(self.IsMouseOver, self) == true or (button and call(button.IsMouseOver, button) == true) or menuOpen()
        closeElapsed = over and 0 or closeElapsed + delta
        if closeElapsed >= 2 then self:Hide() end
    end)
    tray:SetScript("OnHide", function() closeElapsed = 0 end)
end

local function Position()
    local db = Tray.Settings()
    if not button or not db or not Minimap then return end
    local width, height = call(Minimap.GetWidth, Minimap), call(Minimap.GetHeight, Minimap)
    if not number(width) or width <= 0 then width = 140 end
    if not number(height) or height <= 0 then height = 140 end
    local angle = math.rad(db.angle)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * (width / 2 + 3), math.sin(angle) * (height / 2 + 3))
end
Tray.Position = Position

local function CreateButton()
    button = CreateFrame("Button", BUTTON_NAME, Minimap)
    button:SetSize(28, 28); button:SetFrameStrata("MEDIUM"); button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp"); button:RegisterForDrag("LeftButton")
    local function circle(size, layer)
        local texture = button:CreateTexture(nil, layer); texture:SetSize(size, size); texture:SetPoint("CENTER")
        if button.CreateMaskTexture then
            local mask = button:CreateMaskTexture()
            mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetSize(size, size); mask:SetPoint("CENTER"); texture:AddMaskTexture(mask)
        end
        return texture
    end
    circle(28, "BACKGROUND"):SetColorTexture(0.05, 0.04, 0.08, 1)
    circle(26, "BORDER"):SetColorTexture(0.42, 0.3, 0.62, 1)
    circle(23, "ARTWORK"):SetColorTexture(0.035, 0.03, 0.065, 1)
    button.icon = button:CreateTexture(nil, "OVERLAY"); button.icon:SetSize(24, 24); button.icon:SetPoint("CENTER")
    circle(24, "HIGHLIGHT"):SetColorTexture(0.75, 0.6, 1, 0.22)
    local dragged = false
    local function follow()
        local x, y = GetCursorPosition()
        local cx, cy = call(Minimap.GetCenter, Minimap)
        local scale = call(Minimap.GetEffectiveScale, Minimap)
        if not (number(x) and number(y) and number(cx) and number(cy) and number(scale)) or scale <= 0 then return end
        local dx, dy = x / scale - cx, y / scale - cy
        if dx == 0 and dy == 0 then return end
        Tray.Settings().angle = math.deg(math.atan2(dy, dx)) % 360; Position()
    end
    button:SetScript("OnMouseDown", function() dragged = false end)
    button:SetScript("OnDragStart", function(self)
        dragged = true; Tray.Close(); if GameTooltip then GameTooltip:Hide() end
        self:SetScript("OnUpdate", follow); follow()
    end)
    button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    button:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil) end)
    button:SetScript("OnClick", function(_, which)
        if dragged then return end
        Tray.Close()
        if which == "RightButton" then
            if E.state and E.state.ToggleInspect then E.state.ToggleInspect(); E.Notify() end
        else E.ToggleOptions() end
    end)
    button:SetScript("OnEnter", function(self)
        -- With grouping on, hovering opens the addon tray instead of a tooltip.
        if Tray.Active() and Tray.Open() then return end
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:SetText("ForeverHUD")
        GameTooltip:AddLine(E.L("Left-click for settings. Right-click to expand or fold."), 1, 1, 1, true)
        GameTooltip:AddLine(E.L("Drag to move around the minimap."), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    if Minimap.HookScript then Minimap:HookScript("OnSizeChanged", Position) end
end

local function SetEvents(on)
    for _, event in ipairs({"PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED"}) do
        if on then events:RegisterEvent(event) else events:UnregisterEvent(event) end
    end
end

-- Called at login and whenever a minimap setting changes.
function Tray.Apply()
    local db = Tray.Settings()
    if not db or not Minimap then return end
    if not button then CreateButton() end
    button.icon:SetTexture(crestPath())
    Position(); button:SetShown(db.show ~= false)
    local want = db.show ~= false and db.group ~= false and not Tray.Yields()
    if want and not tray then CreateTray() end
    if settingsCell then settingsCell.crest:SetTexture(crestPath()) end
    if tray and tray.title then tray.title:SetText(E.L("Addon buttons")) end
    wanted = want
    SetEvents(want)
    if want then Tray.Scan()
    else
        Tray.Close()
        Tray.ReleaseAll()
        -- Still waiting for combat to end to return borrowed buttons.
        if pending then events:RegisterEvent("PLAYER_REGEN_ENABLED") end
    end
end

-- /fhud minimap on|off and /fhud buttons on|off, and the settings checkboxes.
function Tray.Set(key, value)
    local db = Tray.Settings()
    if not db or (key ~= "show" and key ~= "group") then return end
    db[key] = value == true
    Tray.Apply()
    if E.RefreshOptions then E.RefreshOptions() end
end

events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        events:UnregisterEvent("PLAYER_LOGIN"); Tray.Apply(); return
    end
    if event == "PLAYER_REGEN_ENABLED" and pending then
        pending = false
        if wanted then Tray.Scan() else Tray.ReleaseAll(); if not pending then SetEvents(false) end end
        return
    end
    if event == "PLAYER_ENTERING_WORLD" and wanted then
        Tray.Scan()
        -- Many addons create their minimap buttons shortly after login.
        if C_Timer and type(C_Timer.After) == "function" then C_Timer.After(3, Tray.Scan) end
    end
end)
events:RegisterEvent("PLAYER_LOGIN")
Tray.events = events
