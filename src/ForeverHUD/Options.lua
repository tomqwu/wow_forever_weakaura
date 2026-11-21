local _, E = ...
local castLabels={Default="Default game bar",ForeverHUD="ForeverHUD bar",Both="Both bars"}
local percentKeys={scale=true,opacity=true,castScale=true}
-- Shown in both languages, so the control can be found from either.
local languageNames={zhCN="简体中文",enUS="English"}
local function label(parent, text, size, x, y, color)
    local f = parent:CreateFontString(nil, "OVERLAY")
    f:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size, "")
    f:SetPoint("TOPLEFT", x, y); f:SetText(E.L(text))
    f:SetTextColor(unpack(color or {0.88, 0.86, 0.94}))
    return f
end
function E.RefreshOptions()
    local panel, p = E.panel, E.Profile()
    if not panel or not p then return end
    panel.refreshing = true
    panel.crest:SetTexture("Interface\\AddOns\\ForeverHUD\\Media\\crest-"..string.lower(E.class or "warlock"))
    panel.classLabel:SetText(E.L(E.classNames[E.class]) .. "  /  " .. E.L("Each class keeps its own settings."))
    for key, box in pairs(panel.checks) do box:SetChecked(p[key]) end
    local minimap = E.minimapTray and E.minimapTray.Settings()
    for key, box in pairs(panel.minimapChecks or {}) do box:SetChecked(minimap and minimap[key] ~= false) end
    for key, slider in pairs(panel.sliders) do
        slider:SetValue(p[key]); slider.value:SetText(tostring(p[key]))
        if percentKeys[key] then slider.value:SetText(string.format("%d%%", math.floor(p[key]*100+.5))) end
    end
    panel.school:SetText(E.L('Talent school')..': '..E.L(p.school)
        ..(p.school=='Auto' and E.selection and (' ('..E.L(E.selection.mode or 'Leveling')..')') or ''))
    panel.castChoice:SetText(E.L('Cast bar display')..': '..E.L(castLabels[p.castBarMode]))
    panel.cooldown:SetText(E.L('Cooldown layout')..': '..E.L(p.cooldownLayout))
    panel.frameStyle:SetText(E.L('Frame style')..': '..E.L(p.frameStyle))
    panel.language:SetText('Language / 语言: '..(languageNames[ForeverHUDDB.language] or E.L('Auto')))
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
-- 0.14.1 (user: "can you make the addon config UI a better better?
-- layout/categories/icon?"): a header with the class crest, a sidebar of
-- icon categories, and one page per category with a title, a one-line
-- description and grouped controls. Control names and preference keys are
-- unchanged, so saved settings carry over.
local W, H, SIDE, CX, CW = 720, 540, 186, 206, 494
local COL2 = CX + 254
-- Shown in the sidebar, in this order. Icons are native client icons.
local categories = {
    {key='General', icon='Interface\\Icons\\INV_Misc_Gear_01', text='Turn the HUD on, lock it, pick a language and keep the auras current.'},
    {key='Display', icon='Interface\\Icons\\Spell_Holy_MindVision', text='Choose which parts of the HUD show. Disabled modules unload their trackers.'},
    {key='Reminders', icon='Interface\\Icons\\INV_Misc_PocketWatch_01', text='Reminders for missing buffs, pets and weapon enchants, and alert sounds.'},
    {key='Combat', icon='Interface\\Icons\\Ability_Warrior_OffensiveStance', text='How the HUD unfolds and behaves in combat, and the plans it follows.'},
    {key='Layout', icon='Interface\\Icons\\INV_Misc_Map_01', text='Size, opacity and position. Drag the center seal to move it while unlocked.'},
    {key='Minimap', icon='Interface\\Icons\\INV_Misc_Spyglass_03', text='The ForeverHUD minimap button and its tray of other addons\' buttons.'},
}
local reminderKeys = {imbue=true, oil=true, petMissing=true, fedMissing=true, alerts=true}
local function build()
    local p = CreateFrame("Frame", "ForeverHUDOptions", UIParent, "BackdropTemplate")
    p:SetSize(W, H); p:SetPoint("CENTER"); p:SetFrameStrata("DIALOG")
    p:SetClampedToScreen(true); p:SetMovable(true); p:EnableMouse(true)
    p:RegisterForDrag("LeftButton")
    p:SetScript("OnDragStart", p.StartMoving); p:SetScript("OnDragStop", p.StopMovingOrSizing)
    p:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
    p:SetBackdropColor(0.035, 0.03, 0.065, 0.98); p:SetBackdropBorderColor(0.36, 0.26, 0.52, 1)
    table.insert(UISpecialFrames, "ForeverHUDOptions")
    -- Header: crest, title, class line and version.
    local header = p:CreateTexture(nil, "BACKGROUND")
    header:SetPoint("TOPLEFT", 1, -1); header:SetSize(W - 2, 76); header:SetColorTexture(0.075, 0.055, 0.12, 1)
    p.crest = p:CreateTexture(nil, "ARTWORK")
    p.crest:SetSize(60, 60); p.crest:SetPoint("TOPLEFT", 14, -9)
    label(p, "F O R E V E R H U D", 20, 84, -18)
    p.classLabel = label(p, "", 11, 86, -46, {0.72, 0.66, 0.84})
    p.version = label(p, "", 10, W - 150, -50, {0.5, 0.46, 0.58})
    p.version:SetWidth(120); p.version:SetJustifyH("RIGHT")
    p.version:SetText("v" .. tostring(E.releaseVersion or ""))
    local rule = p:CreateTexture(nil, "BORDER")
    rule:SetPoint("TOPLEFT", 1, -77); rule:SetSize(W - 2, 1); rule:SetColorTexture(0.36, 0.26, 0.52, 1)
    local close = CreateFrame("Button", nil, p, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4); close:SetScript("OnClick", function() p:Hide() end)
    -- Sidebar.
    local side = p:CreateTexture(nil, "BACKGROUND")
    side:SetPoint("TOPLEFT", 1, -78); side:SetSize(SIDE, H - 79); side:SetColorTexture(0.02, 0.018, 0.04, 1)
    local edge = p:CreateTexture(nil, "BORDER")
    edge:SetPoint("TOPLEFT", SIDE + 1, -78); edge:SetSize(1, H - 79); edge:SetColorTexture(0.22, 0.16, 0.32, 1)
    p.checks, p.sliders, p.sections, p.tabs = {}, {}, {}, {}
    local function select(key)
        p.current = key
        for name, frame in pairs(p.sections) do frame:SetShown(name == key) end
        for name, tab in pairs(p.tabs) do
            tab.selected:SetShown(name == key); tab.accent:SetShown(name == key)
            tab.label:SetTextColor(unpack(name == key and {1, 0.94, 0.78} or {0.78, 0.74, 0.86}))
        end
    end
    p.Select = select
    for i, category in ipairs(categories) do
        local tab = CreateFrame("Button", nil, p)
        tab:SetSize(SIDE - 16, 38); tab:SetPoint("TOPLEFT", 9, -88 - (i - 1) * 42)
        tab.selected = tab:CreateTexture(nil, "BACKGROUND"); tab.selected:SetAllPoints()
        tab.selected:SetColorTexture(0.36, 0.26, 0.52, 0.35)
        tab.accent = tab:CreateTexture(nil, "BORDER"); tab.accent:SetPoint("TOPLEFT", 0, 0); tab.accent:SetSize(3, 38)
        tab.accent:SetColorTexture(0.85, 0.7, 1, 1)
        local hover = tab:CreateTexture(nil, "HIGHLIGHT"); hover:SetAllPoints(); hover:SetColorTexture(0.75, 0.6, 1, 0.12)
        tab.icon = tab:CreateTexture(nil, "ARTWORK"); tab.icon:SetSize(26, 26); tab.icon:SetPoint("LEFT", 10, 0)
        tab.icon:SetTexture(category.icon); tab.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        tab.label = tab:CreateFontString(nil, "OVERLAY")
        tab.label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 13, ""); tab.label:SetPoint("LEFT", 46, 0)
        tab.label:SetText(E.L(category.key))
        tab:SetScript("OnClick", function() select(category.key) end)
        p.tabs[category.key] = tab
        local section = CreateFrame("Frame", nil, p); section:SetAllPoints(); p.sections[category.key] = section
        label(section, category.key, 16, CX, -94, {1, 0.94, 0.78})
        local about = label(section, category.text, 11, CX, -118, {0.65, 0.61, 0.73})
        about:SetWidth(CW); about:SetJustifyH("LEFT")
    end
    -- A small heading with a rule, grouping the controls below it.
    local function group(parent, text, y)
        label(parent, text, 12, CX, y, {0.85, 0.72, 1})
        local line = parent:CreateTexture(nil, "BORDER")
        line:SetPoint("TOPLEFT", CX, y - 18); line:SetSize(CW, 1); line:SetColorTexture(0.36, 0.26, 0.52, 0.6)
    end
    local function check(parent, key, text, x, y)
        local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        box:SetSize(25, 25); box:SetPoint("TOPLEFT", x, y)
        box.Text:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 12, "")
        box.Text:SetText(E.L(text)); box.Text:SetTextColor(.88, .86, .94)
        box:SetScript("OnClick", function(self) E.Set(key, self:GetChecked() == true) end)
        p.checks[key] = box
        return box
    end
    local function grid(parent, entries, y)
        for i, entry in ipairs(entries) do
            check(parent, entry[1], entry[2], i % 2 == 1 and CX - 4 or COL2, y - math.floor((i - 1) / 2) * 30)
        end
        return y - math.ceil(#entries / 2) * 30
    end
    local function wide(parent, x, y, width, text, callback)
        local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        b:SetSize(width, 28); b:SetPoint("TOPLEFT", x, y)
        if text then b:SetText(E.L(text)) end
        if callback then b:SetScript("OnClick", callback) end
        return b
    end
    -- General.
    local general = p.sections.General
    group(general, "HUD", -150)
    check(general, 'enabled', 'Enabled', CX - 4, -176); check(general, 'locked', 'Lock position', COL2, -176)
    p.language = wide(general, CX, -214, 240, nil, function()
        local nextChoice = {Auto='zhCN', zhCN='enUS', enUS='Auto'}
        E.SetLanguage(nextChoice[ForeverHUDDB.language or 'Auto'])
    end)
    group(general, "Auras", -262)
    -- Aura install status: red with an install button when the Core or class
    -- auras are missing, older than the addon, or need cleaning up.
    p.auraStatus = label(general, '', 11, CX, -290); p.auraStatus:SetWidth(CW); p.auraStatus:SetJustifyH('LEFT')
    p.install = wide(general, CX, -330, 240, 'Install / update auras', function()
        if E.InCombat() then p.notice:SetText(E.L('Changes apply after combat.')); return end
        if E.InstallBundled then E.InstallBundled() end
    end)
    wide(general, COL2, -330, 240, 'Open aura editor', function()
        local api = E.API()
        if E.InCombat() then p.notice:SetText(E.L('Changes apply after combat.')); return end
        if api and api.OpenOptions then api.OpenOptions(E.GetRootID()); p:Hide() end
    end)
    -- Display and Reminders: the module list, split by purpose. Modules only
    -- some classes have are left out elsewhere.
    local display, reminders = {}, {}
    for _, entry in ipairs(E.modules) do
        local only = E.moduleClasses and E.moduleClasses[entry[1]]
        if not only or only[E.class] then
            local list = reminderKeys[entry[1]] and reminders or display
            list[#list + 1] = entry
        end
    end
    group(p.sections.Display, "HUD modules", -150)
    local below = grid(p.sections.Display, display, -176)
    -- 0.14.6: the frame style, Bars or Globes, per class.
    group(p.sections.Display, "Frame style", below - 8)
    p.frameStyle = wide(p.sections.Display, CX, below - 36, 240, nil, function()
        local current = E.Profile().frameStyle
        E.Set('frameStyle', current == 'Globes' and 'Bars' or 'Globes'); E.RefreshOptions()
    end)
    group(p.sections.Reminders, "Reminders and alerts", -150)
    grid(p.sections.Reminders, reminders, -176)
    -- Combat.
    local combat = p.sections.Combat
    group(combat, "Behavior", -150)
    local after = grid(combat, {{'combatOnly','Combat only'}, {'hoverUtility','Utility on hover'},
        {'expandCombat','Expand when combat starts'}, {'unfold','Unfold animation'},
        {'unfoldSound','Unfold sound'}, {'resourceFlow','Resource flow'},
        {'cleave','Prefer Cleave in Fury'}, {'stayFolded','Stay folded'}}, -176)
    group(combat, "Plans", after - 12)
    local function cycle(key, values, title, x, y)
        local b = wide(combat, x, y, 240, nil, function()
            local options = values(); local current = E.Profile()[key]; local index = 0
            for i, value in ipairs(options) do if value == current then index = i; break end end
            E.Set(key, options[index % #options + 1]); E.RefreshOptions()
        end)
        b.title = title; return b
    end
    local row = after - 40
    p.school = cycle('school', function()
        local values = {'Auto'}; for _, school in ipairs(E.schools and E.schools[E.class] or {}) do values[#values + 1] = school end
        return values
    end, 'Talent school', CX, row)
    p.cooldown = cycle('cooldownLayout', function() return {'Forever', 'Class plan'} end, 'Cooldown layout', COL2, row)
    p.castChoice = cycle('castBarMode', function() return {'Default', 'ForeverHUD', 'Both'} end, 'Cast bar display', CX, row - 36)
    p.swing = cycle('swingMode', function() return {'Auto', 'Single', 'Dual'} end, 'Swing mode', COL2, row - 36)
    -- Layout.
    local position = p.sections.Layout
    local function slider(key, title, minimum, maximum, step, x, y)
        label(position, title, 11, x, y)
        local s = CreateFrame('Slider', nil, position, 'OptionsSliderTemplate')
        s:SetSize(226, 15); s:SetPoint('TOPLEFT', x + 2, y - 24)
        s:SetMinMaxValues(minimum, maximum); s:SetValueStep(step); s:SetObeyStepOnDrag(true)
        if s.Low then s.Low:SetText('') end; if s.High then s.High:SetText('') end; if s.Text then s.Text:SetText('') end
        s.value = label(position, '', 10, x + 176, y)
        s:SetScript('OnValueChanged', function(_, value)
            if p.refreshing then return end
            value = math.floor(value / step + .5) * step; E.Set(key, value)
            s.value:SetText(percentKeys[key] and string.format('%d%%', math.floor(value * 100 + .5)) or tostring(value))
        end)
        p.sliders[key] = s
    end
    group(position, "Size", -150)
    slider('scale', 'Scale', .6, 1.6, .05, CX, -178)
    slider('opacity', 'Opacity', .25, 1, .05, COL2, -178)
    slider('castScale', 'Cast bar size', .6, 2, .05, CX, -234)
    group(position, "Position", -292)
    slider('x', 'Horizontal position', -900, 900, 1, CX, -320)
    slider('y', 'Vertical position', -600, 600, 1, COL2, -320)
    wide(position, CX, -380, 240, 'Reset position', E.ResetPosition)
    wide(position, COL2, -380, 240, 'Expand for inspection', function() if E.state then E.state.Inspect() end end)
    -- Minimap: account-wide, so kept outside the per-class profile checks.
    local minimap = p.sections.Minimap
    group(minimap, "Minimap button", -150)
    p.minimapChecks = {}
    for i, entry in ipairs({{'show', 'Minimap button'}, {'group', 'Group addon minimap buttons'}}) do
        local box = CreateFrame('CheckButton', nil, minimap, 'UICheckButtonTemplate')
        box:SetSize(25, 25); box:SetPoint('TOPLEFT', i == 1 and CX - 4 or COL2, -176)
        box.Text:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 12, "")
        box.Text:SetText(E.L(entry[2])); box.Text:SetTextColor(.88, .86, .94)
        box:SetScript('OnClick', function(self) if E.minimapTray then E.minimapTray.Set(entry[1], self:GetChecked() == true) end end)
        p.minimapChecks[entry[1]] = box
    end
    local hint = label(minimap, 'Hover over the ForeverHUD minimap button to open the tray. Left-click opens settings, right-click expands or folds the HUD. These two settings are shared by all your characters.', 11, CX, -218, {.65, .61, .73})
    hint:SetWidth(CW); hint:SetJustifyH('LEFT')
    -- Footer: status line and the per-class reset.
    p.notice = label(p, '', 11, CX, -(H - 34), {.65, .61, .73}); p.notice:SetWidth(CW - 180); p.notice:SetJustifyH('LEFT')
    local reset = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
    reset:SetSize(160, 26); reset:SetPoint("BOTTOMRIGHT", -14, 14)
    reset:SetText(E.L('Reset this class')); reset:SetScript("OnClick", E.Reset)
    select(categories[1].key)
    p:SetScript('OnShow', function()
        E.inspectingSettings = true; if E.state then E.state.Update(true) end; E.RefreshOptions()
    end)
    p:SetScript('OnHide', function()
        E.inspectingSettings = false; if E.state then E.state.Update(false) end
    end)
    p:Hide(); E.panel = p; return p
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
-- 'zhCN', 'enUS' or 'Auto' (follow the game client). Account-wide.
function E.SetLanguage(choice)
    if type(ForeverHUDDB)~='table' then return end
    ForeverHUDDB.language=(choice=='zhCN' or choice=='enUS') and choice or nil
    E.RefreshOptions()
    local text=E.L('Language set. Type /reload to apply it everywhere.')
    if E.panel and E.panel.notice then E.panel.notice:SetText(text) end
    print('ForeverHUD: '..text)
end
function E.SetSize(percent)
    if not E.Profile() then return end
    if not percent or percent<60 or percent>160 then
        print('ForeverHUD: '..E.L('HUD size takes a number from 60 to 160, for example /fhud 80.'));return
    end
    local value=math.floor(percent/5+.5)*5
    E.Set('scale',value/100);E.RefreshOptions()
    if E.gameOptions and E.gameOptions.page:IsShown() then E.gameOptions.refresh() end
    print('ForeverHUD: '..E.L(E.InCombat() and 'HUD size %d%% applies after combat.' or 'HUD size %d%%.'):format(value))
end
-- 0.13.9: /fhud dump records what this character's client really has, so the
-- spell lists can be built from the game instead of from memory. It only
-- reads (spellbook, talents, auras outside combat, Cooldown Manager sets) and
-- writes into ForeverHUDDB.dump[class]; nothing is sent anywhere and no
-- character name is stored. Every client call is guarded: an API this client
-- lacks leaves its section empty instead of raising an error.
local function plain(value)
    if value == nil or (issecretvalue and issecretvalue(value)) then return nil end
    local kind = type(value)
    if kind == 'number' or kind == 'string' or kind == 'boolean' then return value end
end
local function try(func, ...)
    if type(func) ~= 'function' then return nil end
    local ok, a, b, c, d, e, f, g, h = pcall(func, ...)
    if ok then return a, b, c, d, e, f, g, h end
end
local function spellName(id)
    return plain(try(C_Spell and C_Spell.GetSpellName, id)) or plain((try(GetSpellInfo, id)))
end
local dump = {}
function dump.info()
    local version, build, _, interface = try(GetBuildInfo)
    local util = C_AuraContainerUtil
    return {version=plain(version), build=plain(build), interface=plain(interface), locale=plain(try(GetLocale)),
        class=E.class, level=plain(try(UnitLevel, 'player')), race=plain(select(2, try(UnitRace, 'player'))),
        addon=E.releaseVersion, time=plain(try(time)),
        spec=E.selection and E.selection.mode or nil,
        -- Decides whether "at N stacks" rules can be built (ForeverAuras Stack Count gate).
        stackGate=type(util) == 'table' and type(util.ProcessCustomAuraButtonApplicationBarOptions) == 'function'}
end
function dump.spells()
    local out, book = {}, C_SpellBook
    if type(book) == 'table' and book.GetNumSpellBookSkillLines then
        local banks = Enum and Enum.SpellBookSpellBank or {}
        for bankName, bank in pairs({player=banks.Player or 0, pet=banks.Pet or 1}) do
            local lines = bankName == 'player' and (try(book.GetNumSpellBookSkillLines) or 0) or 1
            for line = 1, lines do
                local info = bankName == 'player' and try(book.GetSpellBookSkillLineInfo, line) or nil
                local first = info and (info.itemIndexOffset or 0) + 1 or 1
                local last = info and (info.itemIndexOffset or 0) + (info.numSpellBookItems or 0)
                    or (try(book.HasPetSpells) or 0)
                for slot = first, type(last) == 'number' and last or 0 do
                    local item = try(book.GetSpellBookItemInfo, slot, bank)
                    if type(item) == 'table' and plain(item.spellID or item.actionID) then
                        out[#out+1] = {id=plain(item.spellID or item.actionID), name=plain(item.name), sub=plain(item.subName),
                            passive=plain(item.isPassive), offSpec=plain(item.isOffSpec), bank=bankName,
                            tab=info and plain(info.name) or nil}
                    end
                end
            end
        end
    elseif GetNumSpellTabs then
        for tab = 1, try(GetNumSpellTabs) or 0 do
            local tabName, _, offset, count = try(GetSpellTabInfo, tab)
            for slot = (offset or 0) + 1, (offset or 0) + (count or 0) do
                local name, sub, id = try(GetSpellBookItemName, slot, 'spell')
                if plain(id) then out[#out+1] = {id=plain(id), name=plain(name), sub=plain(sub), bank='player', tab=plain(tabName)} end
            end
        end
    end
    return out
end
function dump.talents()
    local out, traits = {}, C_Traits
    local config = try(C_ClassTalents and C_ClassTalents.GetActiveConfigID)
    if type(traits) ~= 'table' or not config then return out end
    local info = try(traits.GetConfigInfo, config)
    for _, tree in ipairs(type(info) == 'table' and info.treeIDs or {}) do
        for _, node in ipairs(try(traits.GetTreeNodes, tree) or {}) do
            local data = try(traits.GetNodeInfo, config, node)
            if type(data) == 'table' then
                for _, entry in ipairs(data.entryIDs or {}) do
                    local entryInfo = try(traits.GetEntryInfo, config, entry)
                    local definition = type(entryInfo) == 'table' and try(traits.GetDefinitionInfo, entryInfo.definitionID) or nil
                    local id = type(definition) == 'table' and plain(definition.spellID) or nil
                    out[#out+1] = {tree=tree, node=node, x=plain(data.posX), y=plain(data.posY), id=id, name=id and spellName(id) or nil,
                        rank=plain(data.activeRank), max=plain(data.maxRanks)}
                end
            end
        end
    end
    return out
end
function dump.auras()
    local out = {}
    if E.InCombat() or not (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then return out end
    for _, unit in ipairs({'player', 'target', 'pet', 'focus'}) do
        for _, filter in ipairs({'HELPFUL', 'HARMFUL'}) do
            for index = 1, 80 do
                local aura = try(C_UnitAuras.GetAuraDataByIndex, unit, index, filter)
                if type(aura) ~= 'table' then break end
                out[#out+1] = {unit=unit, filter=filter, id=plain(aura.spellId), name=plain(aura.name), stacks=plain(aura.applications),
                    duration=plain(aura.duration), source=plain(aura.sourceUnit), mine=plain(aura.isFromPlayerOrPlayerPet)}
            end
        end
    end
    return out
end
function dump.cdm()
    local out, viewer = {}, C_CooldownViewer
    if type(viewer) ~= 'table' or not viewer.GetCooldownViewerCategorySet then return out end
    for name, category in pairs(Enum and Enum.CooldownViewerCategory or {}) do
        for _, id in ipairs(try(viewer.GetCooldownViewerCategorySet, category) or {}) do
            local info = try(viewer.GetCooldownViewerCooldownInfo, id)
            if type(info) == 'table' then
                local linked = {}
                for _, value in ipairs(info.linkedSpellIDs or {}) do linked[#linked+1] = plain(value) end
                out[#out+1] = {category=name, cdmID=id, id=plain(info.spellID), override=plain(info.overrideSpellID), linked=linked,
                    name=plain(info.spellID) and spellName(info.spellID) or nil}
            end
        end
    end
    return out
end
local function store()
    if type(ForeverHUDDB) ~= 'table' or not E.class then return end
    ForeverHUDDB.dump = type(ForeverHUDDB.dump) == 'table' and ForeverHUDDB.dump or {}
    ForeverHUDDB.dump[E.class] = type(ForeverHUDDB.dump[E.class]) == 'table' and ForeverHUDDB.dump[E.class] or {}
    return ForeverHUDDB.dump[E.class]
end
E.DUMP_WATCH_LIMIT, E.DUMP_NAME_LIMIT, E.DUMP_SCAN_TOP, E.DUMP_SCAN_STEP = 40, 300, 1400000, 40000
local watch = CreateFrame('Frame')
watch:SetScript('OnEvent', function()
    local record = store()
    if not record or not record.watching then watch:UnregisterEvent('PLAYER_REGEN_ENABLED'); return end
    record.watch = type(record.watch) == 'table' and record.watch or {}
    if #record.watch < E.DUMP_WATCH_LIMIT then record.watch[#record.watch+1] = {time=plain(try(time)), auras=dump.auras()} end
end)
local function scanNames(record, text, from)
    local found = record.names[text]
    for id = from, math.min(from + E.DUMP_SCAN_STEP - 1, E.DUMP_SCAN_TOP) do
        local name = spellName(id)
        if name and #found < E.DUMP_NAME_LIMIT and name:lower():find(text, 1, true) then found[#found+1] = {id=id, name=name} end
    end
    if from + E.DUMP_SCAN_STEP <= E.DUMP_SCAN_TOP and C_Timer and C_Timer.After then
        C_Timer.After(0, function() scanNames(record, text, from + E.DUMP_SCAN_STEP) end)
    else
        print(('ForeverHUD: '..E.L('Found %d spells named like "%s". Type /reload to save them.')):format(#found, text))
    end
end
function E.Dump(what, text)
    local record = store()
    if not record then return end
    what = what ~= '' and what or 'all'
    if what == 'watch' then
        record.watching = not record.watching
        if record.watching then pcall(watch.RegisterEvent, watch, 'PLAYER_REGEN_ENABLED') else watch:UnregisterEvent('PLAYER_REGEN_ENABLED') end
        print('ForeverHUD: '..E.L(record.watching and 'Aura snapshots after each fight: on.' or 'Aura snapshots after each fight: off.'))
        return
    end
    if what == 'names' then
        text = (text or ''):lower()
        if #text < 3 then print('ForeverHUD: '..E.L('Give at least three letters, for example /fhud dump names brand.')); return end
        record.names = type(record.names) == 'table' and record.names or {}
        record.names[text] = {}
        scanNames(record, text, 1)
        return
    end
    if what ~= 'all' and not dump[what] then
        print('ForeverHUD: '..E.L('Use /fhud dump, or add spells, talents, auras, cdm, watch or names <text>.')); return
    end
    if (what == 'all' or what == 'auras') and E.InCombat() then
        print('ForeverHUD: '..E.L('Auras can only be read outside combat.'))
        if what == 'auras' then return end
    end
    record.info = dump.info()
    local counts = {}
    for _, section in ipairs({'spells', 'talents', 'auras', 'cdm'}) do
        if what == 'all' or what == section then
            record[section] = dump[section]()
            counts[#counts+1] = section..' '..#record[section]
        end
    end
    print(('ForeverHUD: '..E.L('Recorded %s. Type /reload to save it.')):format(table.concat(counts, ', ')))
end
-- 0.13.19: /fhud perf. The client's add-on profiler (the one /fa pprint
-- reads) gives ForeverHUD's and ForeverAuras' CPU time per frame; the
-- companion's own counters say how often it rescanned spells, updated the
-- HUD, and which events asked for the rescans. Each report starts a new count.
local function metric(name, key)
    if not (C_AddOnProfiler and C_AddOnProfiler.GetAddOnMetric and Enum and Enum.AddOnProfilerMetric) then return end
    local id = Enum.AddOnProfilerMetric[key]
    if id == nil then return end
    local ok, value = pcall(C_AddOnProfiler.GetAddOnMetric, name, id)
    if ok and type(value) == 'number' then return value end
end
function E.Perf()
    local perf = E.perf
    local now = type(GetTime) == 'function' and GetTime() or 0
    print('ForeverHUD: '..E.L('Performance since the last report (%d s)'):format(math.floor(now - (perf.since or now) + .5)))
    local profiled = false
    for _, name in ipairs({'ForeverHUD', 'ForeverAuras'}) do
        local recent, average, peak = metric(name, 'RecentAverageTime'), metric(name, 'SessionAverageTime'), metric(name, 'PeakTime')
        if recent or average or peak then
            profiled = true
            print(E.L('%s: %.2f ms per frame lately, %.2f ms on average, %.1f ms at the worst frame.'):format(name, recent or 0, average or 0, peak or 0))
        end
    end
    if not profiled then print(E.L("The game's add-on profiler is not available on this client.")) end
    print(E.L('%d spell rescans, %d HUD updates, %d unchanged updates skipped.'):format(perf.refresh, perf.notify, perf.skipped))
    local rows = {}
    for event, count in pairs(perf.events) do rows[#rows+1] = {event, count} end
    table.sort(rows, function(a, b) return a[2] > b[2] or (a[2] == b[2] and a[1] < b[1]) end)
    if #rows > 0 then
        local parts = {}
        for i = 1, math.min(#rows, 6) do parts[i] = rows[i][1]..' '..rows[i][2] end
        print(E.L('Rescans asked for by:')..' '..table.concat(parts, ', '))
    end
    perf.refresh, perf.notify, perf.skipped, perf.events, perf.since = 0, 0, 0, {}, now
end
SLASH_FOREVERHUD1 = "/fhud"
SLASH_FOREVERHUD2 = "/foreverhud"
SlashCmdList.FOREVERHUD = function(message)
    local install=message and message:match("^%s*install%s*(%a*)%s*$")
    -- 0.13.6: /fhud 60 or /fhud 60% sets the HUD size (60 to 160).
    local size=message and message:match("^%s*(%d+%.?%d*)%s*%%?%s*$")
    local language=message and ({zh='zhCN',cn='zhCN',zhcn='zhCN',['中文']='zhCN',en='enUS',english='enUS',enus='enUS',auto='Auto'})[(message:match('^%s*(%S+)%s*$') or ''):lower()]
    local dumping,dumpText=(message or ''):match('^%s*dump%s*(%a*)%s*(.-)%s*$')
    -- 0.14.0: /fhud minimap on|off shows or hides the minimap button;
    -- /fhud buttons on|off groups other addons' minimap buttons behind it.
    local minimapKey,minimapValue=(message or ''):lower():match('^%s*(%a+)%s+(%a+)%s*$')
    minimapKey=({minimap='show',buttons='group'})[minimapKey or '']
    minimapValue=({on=true,off=false})[minimapValue or '']
    -- 0.14.6: /fhud style bars|globes picks the frame style.
    local style=({bars='Bars',globes='Globes',globe='Globes'})[((message or ''):lower():match('^%s*style%s+(%a+)%s*$')) or '']
    if style then
        E.Set('frameStyle',style); E.RefreshOptions()
        print('ForeverHUD: '..E.L('Frame style')..': '..E.L(style))
    elseif minimapKey and minimapValue~=nil and E.minimapTray then
        E.minimapTray.Set(minimapKey,minimapValue)
        print('ForeverHUD: '..E.L(minimapKey=='show' and 'Minimap button' or 'Group addon minimap buttons')..': '..E.L(minimapValue and 'on' or 'off'))
    elseif dumping then E.Dump(dumping:lower(),dumpText)
    elseif size then E.SetSize(tonumber(size))
    elseif language then E.SetLanguage(language)
    elseif install and E.InstallBundled then E.InstallBundled(install=="force")
    elseif message and message:match("^%s*spells%s*$") and E.ReportSpells then E.ReportSpells()
    elseif message and message:match("^%s*inspect%s*$") and E.state then E.state.Inspect()
    elseif message and message:match("^%s*perf%s*$") then E.Perf()
    else E.ToggleOptions() end
end
-- 0.13.10: an entry in the minimap's addon list (TOC AddonCompartmentFunc),
-- as other Forever addons have. Left-click opens the settings, right-click
-- expands or folds the HUD, like the seal.
function ForeverHUD_OnAddonCompartmentClick(_, button)
    if button == "RightButton" then
        if E.state and E.state.ToggleInspect then E.state.ToggleInspect(); E.Notify() end
    else E.ToggleOptions() end
end
function ForeverHUD_OnAddonCompartmentEnter(_, frame)
    if not GameTooltip or not frame then return end
    GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
    GameTooltip:SetText("ForeverHUD")
    GameTooltip:AddLine(E.L("Left-click for settings. Right-click to expand or fold."), 1, 1, 1, true)
    GameTooltip:Show()
end
function ForeverHUD_OnAddonCompartmentLeave()
    if GameTooltip then GameTooltip:Hide() end
end
