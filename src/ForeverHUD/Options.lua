local _, E = ...
local castLabels={Default="Default game bar",ForeverHUD="ForeverHUD bar",Both="Both bars"}
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
    panel.school:SetText(E.L('Talent school')..': '..E.L(p.school)
        ..(p.school=='Auto' and E.selection and (' ('..E.L(E.selection.mode or 'Leveling')..')') or ''))
    panel.castChoice:SetText(E.L('Cast bar display')..': '..E.L(castLabels[p.castBarMode]))
    panel.cooldown:SetText(E.L('Cooldown layout')..': '..E.L(p.cooldownLayout))
    panel.swing:SetText(E.L('Swing mode')..': '..E.L(p.swingMode))
    panel.swing:SetShown(E.class=='WARRIOR')
    panel.checks.cleave:SetShown(E.class=='WARRIOR')
    panel.notice:SetText(E.L(E.InCombat() and "Changes apply after combat." or "Drag the center seal to move. Right-click it for settings."))
    panel.refreshing = false
end
local function build()
    local p = CreateFrame("Frame", "ForeverHUDOptions", UIParent, "BackdropTemplate")
    p:SetSize(560, 570); p:SetPoint("CENTER"); p:SetFrameStrata("DIALOG")
    p:SetClampedToScreen(true); p:SetMovable(true); p:EnableMouse(true)
    p:RegisterForDrag("LeftButton")
    p:SetScript("OnDragStart", p.StartMoving); p:SetScript("OnDragStop", p.StopMovingOrSizing)
    p:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
    p:SetBackdropColor(0.035, 0.03, 0.065, 0.98); p:SetBackdropBorderColor(0.36, 0.26, 0.52, 1)
    label(p, "E C L I P S E", 22, 24, -23)
    label(p, "Class Combat HUD", 11, 26, -51, {0.65,0.6,0.73})
    p.classLabel = label(p, "", 11, 25, -80)
    local close = CreateFrame("Button", nil, p, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4); close:SetScript("OnClick", function() p:Hide() end)
    table.insert(UISpecialFrames, "ForeverHUDOptions")
    p.checks, p.sliders, p.sections = {}, {}, {}
    local function check(parent,key,text,x,y)
        local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        box:SetSize(25,25); box:SetPoint("TOPLEFT",x,y)
        box.Text:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",11,"")
        box.Text:SetText(E.L(text));box.Text:SetTextColor(.88,.86,.94)
        box:SetScript("OnClick",function(self)E.Set(key,self:GetChecked()==true)end)
        p.checks[key]=box
    end
    check(p,'enabled','Enabled',22,-104); check(p,'locked','Lock position',292,-104)
    for i,title in ipairs({'Modules','Behavior','Position'}) do
        local section=CreateFrame('Frame',nil,p);section:SetAllPoints();p.sections[title]=section
        local tab=CreateFrame('Button',nil,p,'UIPanelButtonTemplate')
        tab:SetSize(163,27);tab:SetPoint('TOPLEFT',25+(i-1)*174,-145);tab:SetText(E.L(title))
        tab:SetScript('OnClick',function()
            for key,frame in pairs(p.sections)do frame:SetShown(key==title)end
        end)
        section:SetShown(i==1)
    end
    for i,entry in ipairs(E.modules)do
        check(p.sections.Modules,entry[1],entry[2],i%2==1 and 22 or 292,-195-math.floor((i-1)/2)*36)
    end
    label(p.sections.Modules,'Disabled modules unload their trackers.',11,27,-438,{.65,.61,.73})
    local behavior=p.sections.Behavior
    for i,entry in ipairs({{'combatOnly','Combat only'},{'hoverUtility','Utility on hover'},
        {'expandCombat','Expand when combat starts'},{'unfold','Unfold animation'},
        {'unfoldSound','Unfold sound'},{'resourceFlow','Resource flow'},
        {'cleave','Prefer Cleave in Fury'}})do
        check(behavior,entry[1],entry[2],i%2==1 and 22 or 292,-195-math.floor((i-1)/2)*36)
    end
    local function cycle(key,values,title,y)
        local b=CreateFrame('Button',nil,behavior,'UIPanelButtonTemplate')
        b:SetSize(506,29);b:SetPoint('TOPLEFT',27,y)
        b:SetScript('OnClick',function()
            local options=values();local current=E.Profile()[key];local index=0
            for i,value in ipairs(options)do if value==current then index=i;break end end
            E.Set(key,options[index%#options+1]);E.RefreshOptions()
        end)
        b.title=title;return b
    end
    p.castChoice=cycle('castBarMode',function()return {'Default','ForeverHUD','Both'}end,'Cast bar display',-303)
    p.castChoice:SetSize(241,29);p.castChoice:ClearAllPoints();p.castChoice:SetPoint('TOPLEFT',292,-303)
    p.school=cycle('school',function()
        local values={'Auto'};for _,school in ipairs(E.schools and E.schools[E.class] or {})do values[#values+1]=school end
        return values
    end,'Talent school',-359)
    p.swing=cycle('swingMode',function()return {'Auto','Single','Dual'}end,'Swing mode',-397)
    p.cooldown=cycle('cooldownLayout',function()return {'Forever','Class plan'}end,'Cooldown layout',-435)
    local position=p.sections.Position
    local function slider(key,title,minimum,maximum,step,x,y)
        label(position,title,11,x,y)
        local s=CreateFrame('Slider',nil,position,'OptionsSliderTemplate')
        s:SetSize(218,15);s:SetPoint('TOPLEFT',x+2,y-24)
        s:SetMinMaxValues(minimum,maximum);s:SetValueStep(step);s:SetObeyStepOnDrag(true)
        if s.Low then s.Low:SetText('')end;if s.High then s.High:SetText('')end;if s.Text then s.Text:SetText('')end
        s.value=label(position,'',10,x+166,y)
        s:SetScript('OnValueChanged',function(_,value)
            if p.refreshing then return end
            value=math.floor(value/step+.5)*step;E.Set(key,value)
            s.value:SetText((key=='scale' or key=='opacity')and string.format('%d%%',value*100)or tostring(value))
        end)
        p.sliders[key]=s
    end
    slider('scale','Scale',.6,1.6,.05,27,-205)
    slider('opacity','Opacity',.25,1,.05,292,-205)
    slider('x','Horizontal position',-900,900,1,27,-290)
    slider('y','Vertical position',-600,600,1,292,-290)
    local inspect=CreateFrame('Button',nil,position,'UIPanelButtonTemplate')
    inspect:SetSize(506,29);inspect:SetPoint('TOPLEFT',27,-382);inspect:SetText(E.L('Expand for inspection'))
    inspect:SetScript('OnClick',function()if E.state then E.state.Inspect()end end)
    p.notice=label(p,'',11,27,-473,{.65,.61,.73});p.notice:SetWidth(506);p.notice:SetJustifyH('LEFT')
    button(p,'Open aura editor',25,18,163,function()
        local api=E.API()
        if E.InCombat()then p.notice:SetText(E.L('Changes apply after combat.'));return end
        if api and api.OpenOptions then api.OpenOptions(E.GetRootID());p:Hide()end
    end)
    button(p,'Reset position',199,18,163,E.ResetPosition)
    button(p,'Reset this class',373,18,163,E.Reset)
    p:SetScript('OnShow',function()
        E.inspectingSettings=true;if E.state then E.state.Update(true)end;E.RefreshOptions()
    end)
    p:SetScript('OnHide',function()
        E.inspectingSettings=false;if E.state then E.state.Update(false)end
    end)
    p:Hide();E.panel=p;return p
end
function E.ToggleOptions()
    if not E.Profile() then return end
    local p = E.panel or build()
    p:SetShown(not p:IsShown())
end
SLASH_FOREVERHUD1 = "/fhud"
SLASH_FOREVERHUD2 = "/foreverhud"
SlashCmdList.FOREVERHUD = function(message)
    local install=message and message:match("^%s*install%s*(%a*)%s*$")
    if install and E.InstallBundled then E.InstallBundled(install=="force")
    elseif message and message:match("^%s*spells%s*$") and E.ReportSpells then E.ReportSpells()
    elseif message and message:match("^%s*inspect%s*$") and E.state then E.state.Inspect()
    else E.ToggleOptions() end
end
