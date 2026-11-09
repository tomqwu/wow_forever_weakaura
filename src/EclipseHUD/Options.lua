local _, E = ...
local function label(parent, text, size, x, y, color)
    local f = parent:CreateFontString(nil, "OVERLAY")
    f:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size, "")
    f:SetPoint("TOPLEFT", x, y); f:SetText(E.L(text))
    f:SetTextColor(unpack(color or {0.88, 0.86, 0.94}))
    return f
end
local function button(parent, text, x, y, width, callback)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 26); b:SetPoint("BOTTOMLEFT", x, y)
    b:SetText(E.L(text)); b:SetScript("OnClick", callback)
    return b
end
function E.RefreshOptions()
    local panel, p = E.panel, E.Profile()
    if not panel or not p then return end
    panel.refreshing = true
    panel.classLabel:SetText(E.L(E.classNames[E.class]) .. "  /  " .. E.L("Each class keeps its own settings."))
    for key, box in pairs(panel.checks) do box:SetChecked(p[key]) end
    for key, slider in pairs(panel.sliders) do
        slider:SetValue(p[key]); slider.value:SetText(tostring(p[key]))
        if key == "scale" or key == "opacity" then slider.value:SetText(string.format("%d%%", p[key]*100)) end
    end
    panel.notice:SetText(E.L(E.InCombat() and "Changes apply after combat." or "Drag the center seal to move. Right-click it for settings."))
    panel.refreshing = false
end
local function build()
    local p = CreateFrame("Frame", "EclipseHUDOptions", UIParent, "BackdropTemplate")
    p:SetSize(500, 580); p:SetPoint("CENTER"); p:SetFrameStrata("DIALOG")
    p:SetClampedToScreen(true); p:SetMovable(true); p:EnableMouse(true)
    p:RegisterForDrag("LeftButton")
    p:SetScript("OnDragStart", p.StartMoving); p:SetScript("OnDragStop", p.StopMovingOrSizing)
    p:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
    p:SetBackdropColor(0.035, 0.03, 0.065, 0.98); p:SetBackdropBorderColor(0.36, 0.26, 0.52, 1)
    local stripe = p:CreateTexture(nil, "ARTWORK")
    stripe:SetPoint("TOPLEFT", 1, -1); stripe:SetPoint("TOPRIGHT", -1, -1); stripe:SetHeight(3)
    stripe:SetColorTexture(0.65, 0.42, 0.95, 1)
    label(p, "E C L I P S E", 22, 24, -23)
    label(p, "Class Combat HUD", 11, 26, -51, {0.65,0.6,0.73})
    p.classLabel = label(p, "", 11, 25, -80)
    local close = CreateFrame("Button", nil, p, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() p:Hide() end)
    table.insert(UISpecialFrames, "EclipseHUDOptions")
    p.checks, p.sliders = {}, {}
    local function check(key, text, x, y)
        local box = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
        box:SetSize(25, 25); box:SetPoint("TOPLEFT", x, y)
        box.Text:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 11, "")
        box.Text:SetText(E.L(text)); box.Text:SetTextColor(0.88,0.86,0.94)
        box:SetScript("OnClick", function(self) E.Set(key, self:GetChecked() == true) end)
        p.checks[key] = box
    end
    check("enabled", "Enabled", 22, -108); check("locked", "Lock position", 260, -108)
    check("combatOnly", "Combat only", 22, -140); check("hoverUtility", "Utility on hover", 260, -140)
    for i, entry in ipairs(E.modules) do
        check(entry[1], entry[2], i % 2 == 1 and 22 or 260, -184-math.floor((i-1)/2)*30)
    end
    local function slider(key, title, minimum, maximum, step, x, y)
        label(p, title, 11, x, y)
        local s = CreateFrame("Slider", nil, p, "OptionsSliderTemplate")
        s:SetSize(192, 15); s:SetPoint("TOPLEFT", x+2, y-24)
        s:SetMinMaxValues(minimum, maximum); s:SetValueStep(step); s:SetObeyStepOnDrag(true)
        if s.Low then s.Low:SetText("") end
        if s.High then s.High:SetText("") end
        if s.Text then s.Text:SetText("") end
        s.value = label(p, "", 10, x+152, y)
        s:SetScript("OnValueChanged", function(_, value)
            if p.refreshing then return end
            value = math.floor(value/step+0.5)*step
            E.Set(key, value)
            s.value:SetText((key == "scale" or key == "opacity") and string.format("%d%%", value*100) or tostring(value))
        end)
        p.sliders[key] = s
    end
    slider("scale", "Scale", 0.6, 1.6, 0.05, 27, -350)
    slider("opacity", "Opacity", 0.25, 1, 0.05, 266, -350)
    slider("x", "Horizontal position", -900, 900, 1, 27, -408)
    slider("y", "Vertical position", -600, 600, 1, 266, -408)
    p.notice = label(p, "", 11, 27, -474, {0.65,0.61,0.73})
    p.notice:SetWidth(446); p.notice:SetJustifyH("LEFT")
    label(p, "Preview in /fa; only learned abilities appear in play.", 10, 27, -511, {0.54,0.51,0.62})
    button(p, "Open aura editor", 25, 18, 216, function()
        local api = E.API()
        if E.InCombat() then p.notice:SetText(E.L("Changes apply after combat.")); return end
        if api and api.OpenOptions then api.OpenOptions(E.rootID); p:Hide() end
    end)
    button(p, "Reset this class", 259, 18, 216, E.Reset)
    p:SetScript("OnShow", E.RefreshOptions)
    p:Hide(); E.panel = p
    return p
end
function E.ToggleOptions()
    if not E.Profile() then return end
    local p = E.panel or build()
    p:SetShown(not p:IsShown())
end
SLASH_ECLIPSEHUD1 = "/eclipse"
SLASH_ECLIPSEHUD2 = "/ehud"
SlashCmdList.ECLIPSEHUD = function() E.ToggleOptions() end
