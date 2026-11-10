local _, E = ...
-- A public cooperative owner interface, plus the latest external show request.
-- We retain Blizzard events/scripts and let its setters update the actual bar.
local C={owners={},bars={},active=false}
E.casting=C
local events=CreateFrame('Frame')
C.events=events
local function set(bar,record,value)
    record.writing=true
    if bar.SetAndUpdateShowCastbar then bar:SetAndUpdateShowCastbar(value)
    else bar.showCastbar=value end
    record.writing=false
end
local function acquireBars()
    if not next(C.owners) then return end
    for _,name in ipairs({'PlayerCastingBarFrame','CastingBarFrame','GamepadPlayerCastingBarFrame'}) do
        local bar=_G[name]
        if bar then
            local record=C.bars[bar]
            if not record then
                if not E.Readable(bar.showCastbar) then return end
                record={requested=bar.showCastbar};C.bars[bar]=record
                if bar.HookScript then bar:HookScript('OnShow',function()
                    if next(C.owners) then bar:Hide() end
                end) end
                if bar.SetAndUpdateShowCastbar and hooksecurefunc then
                    hooksecurefunc(bar,'SetAndUpdateShowCastbar',function(_,value)
                        if record.writing or not next(C.owners) then return end
                        if E.Readable(value) and (type(value)=='boolean' or value==nil) then record.requested=value end
                        set(bar,record,false)
                    end)
                end
            elseif not record.owned then
                -- A fresh ownership episode preserves the then-current state.
                if E.Readable(bar.showCastbar) then record.requested=bar.showCastbar end
            end
            record.owned=true
            set(bar,record,false);bar:Hide()
        end
    end
end
function C.Acquire(owner)
    if type(owner)~='string' then return end
    C.owners[owner]=true
    events:RegisterEvent('ADDON_LOADED')
    acquireBars()
end
function C.Release(owner)
    C.owners[owner]=nil
    if next(C.owners) then return end
    events:UnregisterEvent('ADDON_LOADED')
    for bar,record in pairs(C.bars) do
        if record.owned then record.owned=false;set(bar,record,record.requested) end
    end
end
local castEvents={'UNIT_SPELLCAST_START','UNIT_SPELLCAST_CHANNEL_START','UNIT_SPELLCAST_STOP',
    'UNIT_SPELLCAST_CHANNEL_STOP','UNIT_SPELLCAST_SUCCEEDED','UNIT_SPELLCAST_FAILED','UNIT_SPELLCAST_INTERRUPTED'}
local function clear()
    if C.finish then C.finish:Cancel();C.finish=nil end
    C.cast=nil
end
function C.CastEvent(event,unit,guid)
    if not E.Readable(unit) or unit~='player' or not E.Readable(guid) or type(guid)~='string' then return end
    if event=='UNIT_SPELLCAST_START' or event=='UNIT_SPELLCAST_CHANNEL_START' then
        clear();C.cast={guid=guid,channel=event=='UNIT_SPELLCAST_CHANNEL_START'}
        if E.CastMotion then E.CastMotion('start') end
        return
    end
    local cast=C.cast
    if not cast or cast.guid~=guid then return end
    if event=='UNIT_SPELLCAST_FAILED' or event=='UNIT_SPELLCAST_INTERRUPTED' then
        clear();if E.CastMotion then E.CastMotion('cancel') end;return
    end
    if event=='UNIT_SPELLCAST_SUCCEEDED' then cast.success=true
    elseif event=='UNIT_SPELLCAST_CHANNEL_STOP' or event=='UNIT_SPELLCAST_STOP' then
        cast.ended=true
        -- End motion at the observed stop, even if success is absent or late.
        if E.CastMotion then E.CastMotion('cancel') end
    end
    local finished=cast.success and (not cast.channel or cast.ended)
    if finished and not C.finish then
        -- Coalesce same-frame interruption/stop events before decorative success.
        C.finish=C_Timer.NewTimer(0,function()
            C.finish=nil
            if C.cast~=cast then return end
            C.cast=nil
            if E.CastMotion then E.CastMotion('success') end
        end)
    end
end
function E.RefreshCasting()
    local p,api=E.Profile(),E.API()
    local imported=api and api.GetData and E.class and api.GetData('Eclipse | '..E.classNames[E.class]..' | Cast')
    local active=p and p.enabled and p.cast and imported~=nil
    if E.state then active=active and E.LiveWorld() and not E.state.Preview() end
    if active and p.hideDefaultCast and E.Gate('cast',E.class) then C.Acquire('EclipseHUD') else C.Release('EclipseHUD') end
    if active~=C.active then
        C.active=active
        for _,event in ipairs(castEvents) do
            if active then events:RegisterEvent(event) else events:UnregisterEvent(event) end
        end
        if not active then
            clear();if E.CastMotion then E.CastMotion('cancel') end
        end
    end
end
function E.StopCasting()
    clear();C.Release('EclipseHUD');C.active=false
    for _,event in ipairs(castEvents) do events:UnregisterEvent(event) end
    if E.CastMotion then E.CastMotion('cancel') end
end
events:SetScript('OnEvent',function(_,event,...)
    if event=='ADDON_LOADED' then acquireBars() else C.CastEvent(event,...) end
end)
