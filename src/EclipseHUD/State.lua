local _, E = ...
local S={open=false,world=false,transition=false}
E.state=S
local events=CreateFrame('Frame')
S.events=events
local watch={'PLAYER_TARGET_CHANGED','UNIT_FACTION','UNIT_FLAGS','PLAYER_DEAD','PLAYER_ALIVE','PLAYER_UNGHOST',
    'PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','LOADING_SCREEN_ENABLED','LOADING_SCREEN_DISABLED'}
local function cancel(key)
    if S[key] then S[key]:Cancel(); S[key]=nil end
end
function S.HostileTarget()
    return E.Call(UnitExists,'target')==true and E.Call(UnitCanAttack,'player','target')==true
        and E.Call(UnitIsDeadOrGhost,'target')==false
end
function S.Preview()
    local api=E.API()
    return api~=nil and E.Call(api.IsOptionsOpen)==true
end
function S.Visible()
    return S.world and (S.open or S.transition or S.Preview())
end
function S.Goal(open,silent)
    if S.open==open and not silent then return end
    local edge=not S.open and open
    S.open=open
    if E.motion then E.motion.Change(open,silent) end
    if edge and not silent then
        local p=E.Profile()
        if p and p.unfoldSound and PlaySound and SOUNDKIT then PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,'Master') end
    end
    E.Notify()
end
function S.Update(silent,combatExit)
    local p=E.Profile()
    local unavailable=not p or not p.enabled or not S.world or S.loading or S.hidden or E.Call(UnitIsDeadOrGhost,'player')~=false
    if unavailable then
        cancel('closeTimer'); cancel('inspectTimer'); S.inspected=false
        S.Goal(false,true); return
    end
    local preview=S.Preview()
    if preview~=S.preview then silent=true; S.preview=preview end
    local combat=S.combat
    if combat==nil then combat=E.InCombat() end
    local want=preview or S.inspected or E.inspectingSettings or S.HostileTarget() or (p.expandCombat and combat)
    if want then cancel('closeTimer'); S.Goal(true,silent)
    elseif combatExit then cancel('closeTimer');S.Goal(false,silent)
    elseif S.open and not silent then
        if not S.closeTimer then
            S.closeTimer=C_Timer.NewTimer(5,function() S.closeTimer=nil; S.Goal(false,false) end)
        end
    else cancel('closeTimer'); S.Goal(false,true) end
end
function S.Inspect()
    local p=E.Profile();if not p or not p.enabled or not S.world then return end
    cancel('inspectTimer')
    S.inspected=true; S.Update(false)
    S.inspectTimer=C_Timer.NewTimer(10,function()S.inspectTimer=nil;S.inspected=false;S.Update(false)end)
end
function S.Start()
    local p=E.Profile(); if not p or not p.enabled then S.Stop(); return end
    S.world=true; S.loading=false;S.combat=nil
    for _,event in ipairs(watch) do pcall(events.RegisterEvent,events,event) end
    S.Update(true)
end
function S.Stop()
    cancel('closeTimer'); cancel('inspectTimer'); cancel('previewTimer')
    for _,event in ipairs(watch) do events:UnregisterEvent(event) end
    S.world=false; S.open=false; S.transition=false; S.inspected=false; S.preview=false;S.combat=nil
    if E.motion then E.motion.Stop() end
end
function S.ObservePreview(preview)
    if preview~=S.preview and not S.previewTimer and S.world then
        S.previewTimer=C_Timer.NewTimer(0,function()S.previewTimer=nil;S.Update(true)end)
    end
end
events:SetScript('OnEvent',function(_,event,unit)
    if (event=='UNIT_FACTION' or event=='UNIT_FLAGS') and unit~='target' and unit~='player' then return end
    if event=='LOADING_SCREEN_ENABLED' then S.loading=true
    elseif event=='LOADING_SCREEN_DISABLED' then S.loading=false end
    if event=='PLAYER_REGEN_DISABLED' then S.combat=true
    elseif event=='PLAYER_REGEN_ENABLED' then S.combat=false end
    S.Update(event=='LOADING_SCREEN_DISABLED' or event=='PLAYER_ALIVE' or event=='PLAYER_UNGHOST',event=='PLAYER_REGEN_ENABLED')
end)
function E.LayoutVisible() return not E.state or E.state.Visible() end
if UIParent.HookScript then
    UIParent:HookScript('OnHide',function()S.hidden=true;S.Update(true)end)
    UIParent:HookScript('OnShow',function()S.hidden=false;S.Update(true)end)
end
