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
    local problems = E.AuraProblems and E.AuraProblems() or {}
    if #problems > 0 then
        panel.auraStatus:SetText(table.concat(problems, " "))
        panel.auraStatus:SetTextColor(1, 0.45, 0.4)
    else
        panel.auraStatus:SetText(E.L("Auras up to date"))
        panel.auraStatus:SetTextColor(0.55, 0.85, 0.6)
    end
    panel.install:SetShown(#problems > 0)
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
    label(p, "F O R E V E R H U D", 22, 24, -23)
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
        check(p.sections.Modules,entry[1],entry[2],i%2==1 and 22 or 292,-190-math.floor((i-1)/2)*30)
    end
    label(p.sections.Modules,'Disabled modules unload their trackers.',11,27,-440,{.65,.61,.73})
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
    p.notice=label(p,'',11,27,-466,{.65,.61,.73});p.notice:SetWidth(506);p.notice:SetJustifyH('LEFT')
    -- Aura install status: red with an install button when the Core or class
    -- auras are missing, older than the addon, or need cleaning up.
    p.auraStatus=label(p,'',11,27,-490);p.auraStatus:SetWidth(335);p.auraStatus:SetJustifyH('LEFT')
    p.install=CreateFrame('Button',nil,p,'UIPanelButtonTemplate')
    p.install:SetSize(163,24);p.install:SetPoint('TOPLEFT',373,-486);p.install:SetText(E.L('Install / update auras'))
    p.install:SetScript('OnClick',function()
        if E.InCombat()then p.notice:SetText(E.L('Changes apply after combat.'));return end
        if E.InstallBundled then E.InstallBundled() end
    end)
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
-- 0.13.6: a ForeverHUD page in the game's Options -> AddOns list, so the HUD
-- size can be changed where players look for addon settings. It edits the
-- same per-class "scale" preference as the /fhud slider (60% to 160%); the
-- whole HUD scales together, so text keeps its proportion to the art.
function E.RegisterGameOptions()
    if E.gameOptions or type(Settings)~='table' or type(Settings.RegisterCanvasLayoutCategory)~='function'
        or type(Settings.RegisterAddOnCategory)~='function' then return end
    local page=CreateFrame('Frame')
    label(page,'F O R E V E R H U D',18,16,-16)
    label(page,'Each class keeps its own settings.',11,16,-44,{.65,.61,.73})
    label(page,'HUD size',12,16,-80)
    local s=CreateFrame('Slider',nil,page,'OptionsSliderTemplate')
    s:SetSize(260,16);s:SetPoint('TOPLEFT',18,-106)
    s:SetMinMaxValues(.6,1.6);s:SetValueStep(.05);s:SetObeyStepOnDrag(true)
    if s.Low then s.Low:SetText('60%')end;if s.High then s.High:SetText('160%')end;if s.Text then s.Text:SetText('')end
    s.value=label(page,'',12,292,-106)
    local function percent(value)return string.format('%d%%',math.floor(value*100+.5))end
    local function refresh()
        local p=E.Profile();if not p then return end
        page.refreshing=true;s:SetValue(p.scale);s.value:SetText(percent(p.scale));page.refreshing=false
    end
    s:SetScript('OnValueChanged',function(_,value)
        if page.refreshing then return end
        value=math.floor(value/.05+.5)*.05;E.Set('scale',value)
        s.value:SetText(percent(value));E.RefreshOptions()
    end)
    local note=label(page,'The whole HUD scales together, text included. A change made in combat applies after combat.',11,16,-136,{.65,.61,.73})
    note:SetWidth(520);note:SetJustifyH('LEFT')
    local open=CreateFrame('Button',nil,page,'UIPanelButtonTemplate')
    open:SetSize(240,26);open:SetPoint('TOPLEFT',16,-178);open:SetText(E.L('All ForeverHUD settings (/fhud)'))
    open:SetScript('OnClick',function()if not(E.panel and E.panel:IsShown())then E.ToggleOptions()end end)
    page:SetScript('OnShow',refresh)
    local ok,category=pcall(Settings.RegisterCanvasLayoutCategory,page,'ForeverHUD')
    if not ok or not category or not pcall(Settings.RegisterAddOnCategory,category) then return end
    E.gameOptions={page=page,slider=s,category=category,refresh=refresh}
end
local login=CreateFrame('Frame')
login:RegisterEvent('PLAYER_LOGIN')
login:SetScript('OnEvent',function()E.RegisterGameOptions()end)
SLASH_FOREVERHUD1 = "/fhud"
SLASH_FOREVERHUD2 = "/foreverhud"
SlashCmdList.FOREVERHUD = function(message)
    local install=message and message:match("^%s*install%s*(%a*)%s*$")
    if install and E.InstallBundled then E.InstallBundled(install=="force")
    elseif message and message:match("^%s*spells%s*$") and E.ReportSpells then E.ReportSpells()
    elseif message and message:match("^%s*inspect%s*$") and E.state then E.state.Inspect()
    else E.ToggleOptions() end
end
