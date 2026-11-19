local _, E = ...
-- 0.14.5 (user: "integration with titan panel"): a LibDataBroker launcher, so
-- Titan Panel (and any other Broker display: ChocolateBar, Bazooka, ...)
-- shows a ForeverHUD button with the class crest. Titan bundles
-- LibDataBroker-1.1 itself, so ForeverHUD ships no library: without a Broker
-- display loaded this file does nothing. Same clicks as the minimap button.
local Broker = {}
E.broker = Broker
local NAME = "ForeverHUD"

local function crestPath()
    return "Interface\\AddOns\\ForeverHUD\\Media\\crest-" .. string.lower(E.class or "warlock")
end

-- The shared LibDataBroker-1.1 instance, if a Broker display loaded one.
function Broker.Library()
    if type(LibStub) ~= "table" and type(LibStub) ~= "function" then return nil end
    local get = type(LibStub) == "table" and LibStub.GetLibrary
    if type(get) ~= "function" then return nil end
    local ok, ldb = pcall(get, LibStub, "LibDataBroker-1.1", true)
    if ok and type(ldb) == "table" and type(ldb.NewDataObject) == "function" then return ldb end
end

local function click(_, which)
    if which == "RightButton" then
        if E.state and E.state.ToggleInspect then E.state.ToggleInspect(); E.Notify() end
    else E.ToggleOptions() end
end

local function tooltip(tip)
    if type(tip) ~= "table" or type(tip.AddLine) ~= "function" then return end
    tip:AddLine("ForeverHUD")
    tip:AddLine(E.L("Left-click for settings. Right-click to expand or fold."), 1, 1, 1, true)
end

-- Called at login; creates the launcher once.
function Broker.Register()
    if Broker.object then Broker.object.icon = crestPath(); return Broker.object end
    local ldb = Broker.Library()
    if not ldb then return nil end
    local ok, object = pcall(ldb.NewDataObject, ldb, NAME, {
        type = "launcher", label = NAME, icon = crestPath(),
        OnClick = click, OnTooltipShow = tooltip,
    })
    -- Another copy already registered the name: reuse it rather than fail.
    if (not ok or type(object) ~= "table") and type(ldb.GetDataObjectByName) == "function" then
        object = ldb:GetDataObjectByName(NAME)
    end
    if type(object) ~= "table" then return nil end
    Broker.object = object
    return object
end

local events = CreateFrame("Frame")
Broker.events = events
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then events:UnregisterEvent("PLAYER_LOGIN"); Broker.Register() end
end)
events:RegisterEvent("PLAYER_LOGIN")
