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
-- 0.13.19 (performance): unit flags, faction and target events arrive in
-- bursts. When one of them leaves everything the HUD shows exactly as it was,
-- a silent goal skips the full notification instead of re-running every
-- display's gate. Explicit callers (settings, preview, loading) still notify.
local function flag(v) return v==true and '1' or '0' end
function S.Signature(open)
    return table.concat({flag(open),flag(S.world),flag(S.loading),flag(S.hidden),flag(S.preview),flag(S.inspected),
        flag(S.manualFold),flag(E.inspectingSettings),flag(E.peeking),flag(S.combat),flag(E.InCombat()),
        flag(E.Call(UnitIsDeadOrGhost,'player')),flag(S.HostileTarget())})
end
function S.Goal(open,silent,fromEvent)
    if S.open==open and not silent then return end
    if fromEvent and S.open==open and not S.transition and S.notified==S.Signature(open) then
        if E.perf then E.perf.skipped=E.perf.skipped+1 end
        return
    end
    local edge=not S.open and open
    S.open=open
    -- 0.14.19: with Stay folded, opening restores the full layout and folding
    -- returns to the mini one (out of combat; Selection keeps it in combat).
    local p=E.Profile()
    if p and (p.stayFolded or (E.selection and E.selection.mini)) and E.selection and E.selection.ApplyLayout then
        E.selection.ApplyLayout()
    end
    if E.motion then E.motion.Change(open,silent) end
    if edge and not silent then
        local p=E.Profile()
        if p and p.unfoldSound and PlaySound and SOUNDKIT then PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,'Master') end
    end
    E.Notify()
    S.notified=S.Signature(open)
end
function S.Update(silent,combatExit,fromEvent)
    local p=E.Profile()
    local unavailable=not p or not p.enabled or not S.world or S.loading or S.hidden or E.Call(UnitIsDeadOrGhost,'player')~=false
    if unavailable then
        cancel('closeTimer'); cancel('inspectTimer'); S.inspected=false;S.manualFold=false
        S.Goal(false,true,fromEvent); return
    end
    local preview=S.Preview()
    if preview~=S.preview then silent=true; S.preview=preview end
    local combat=S.combat
    if combat==nil then combat=E.InCombat() end
    -- 0.14.18 (user: "option to not expand in combat, just retracted model"):
    -- Stay folded keeps the folded seal and tray in combat and with a hostile
    -- target; only the settings preview, a seal click, /fhud and the hover
    -- peek open the HUD.
    local auto=not p.stayFolded
    local want=preview or (auto and p.expandCombat and combat)
        or (not S.manualFold and (S.inspected or E.inspectingSettings or (auto and S.HostileTarget())))
        or E.peeking == true
    if want then cancel('closeTimer'); S.Goal(true,silent,fromEvent)
    elseif combatExit then cancel('closeTimer');S.Goal(false,silent,fromEvent)
    elseif S.open and not silent then
        if not S.closeTimer then
            S.closeTimer=C_Timer.NewTimer(5,function() S.closeTimer=nil; S.Goal(false,false) end)
        end
    else cancel('closeTimer'); S.Goal(false,true,fromEvent) end
end
function S.Inspect()
    local p=E.Profile();if not p or not p.enabled or not S.world then return end
    cancel('inspectTimer')
    S.manualFold=false;S.inspected=true; S.Update(false)
    S.inspectTimer=C_Timer.NewTimer(10,function()S.inspectTimer=nil;S.inspected=false;S.Update(false)end)
end
function S.ToggleInspect()
    local p=E.Profile();if not p or not p.enabled or not S.world then return end
    local combat=S.combat
    if combat==nil then combat=E.InCombat()end
    -- 0.14.21 (user: "click shouldn't expand it, and you should hint the
    -- option is turned off"): with Stay folded a click (seal, minimap or
    -- broker) never expands; it says why. An open HUD (settings preview,
    -- /fhud inspect) still folds on a click.
    if p.stayFolded and not S.open then
        S.inspected=false
        if E.StayFoldedHint then E.StayFoldedHint() end
        return false
    end
    cancel('inspectTimer');cancel('closeTimer')
    if combat then
        S.inspected=false;S.Update(false,true);return
    end
    -- A click is a persistent visual toggle, including during a delayed close.
    -- Folding suppresses the current target until a new target/combat edge.
    S.manualFold=S.open
    S.inspected=not S.open
    S.Update(false,true)
    return S.open
end
function S.Start()
    local p=E.Profile(); if not p or not p.enabled then S.Stop(); return end
    S.world=true; S.loading=false;S.combat=nil;S.manualFold=false
    for _,event in ipairs(watch) do pcall(events.RegisterEvent,events,event) end
    S.Update(true)
    if E.FoldedIntro then E.FoldedIntro() end
end
function S.Stop()
    cancel('closeTimer'); cancel('inspectTimer'); cancel('previewTimer')
    for _,event in ipairs(watch) do events:UnregisterEvent(event) end
    S.notified=nil;S.world=false; S.open=false; S.transition=false; S.inspected=false; S.preview=false;S.combat=nil;S.manualFold=false
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
    if event=='PLAYER_TARGET_CHANGED' then S.manualFold=false end
    if event=='PLAYER_REGEN_DISABLED' then S.combat=true;S.manualFold=false
    elseif event=='PLAYER_REGEN_ENABLED' then S.combat=false end
    S.Update(event=='LOADING_SCREEN_DISABLED' or event=='PLAYER_ALIVE' or event=='PLAYER_UNGHOST',event=='PLAYER_REGEN_ENABLED',true)
    -- 0.14.19: a folded HUD does not change on a combat edge, but the mini
    -- (Stay folded) wings and suggestions do, so the gates are re-run.
    if (event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED') and not S.open then
        local p=E.Profile()
        if p and p.stayFolded then E.Notify() end
    end
end)
function E.LayoutVisible() return not E.state or E.state.Visible() end
if UIParent.HookScript then
    UIParent:HookScript('OnHide',function()S.hidden=true;S.Update(true)end)
    UIParent:HookScript('OnShow',function()S.hidden=false;S.Update(true)end)
end
