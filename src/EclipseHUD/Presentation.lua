local _, E = ...
local P={cooldowns={},resources={},pending={}}
E.presentation=P
local formatter
local function enabled(class,module)
    local p=E.Profile()
    return p and p.enabled and E.class==class and p[module]~=false
end
local function getFormatter()
    if formatter then return formatter end
    if not C_StringUtil or not C_StringUtil.CreateNumericRuleFormatter or not Enum.NumericRuleFormatRounding then return end
    formatter=C_StringUtil.CreateNumericRuleFormatter()
    local up=Enum.NumericRuleFormatRounding.Up
    formatter:SetBreakpoints({
        {threshold=0,format=''},
        {threshold=.000001,format='|cffff5555%.1f|r'},
        {threshold=1,format='|cffff5555%d|r',step=1,rounding=up},
        {threshold=3,format='|cffffd580%d|r',step=1,rounding=up},
        {threshold=60,format='|cffffd580%d:%02d|r',step=1,rounding=up,components={{div=60},{mod=60}}},
    })
    return formatter
end
local function restoreCooldown(item)
    if not item.applied then return end
    item.applied=false
    if item.cd.SetCountdownFormatter then item.cd:SetCountdownFormatter(item.original) end
    if item.cd.SetCountdownMillisecondsThreshold and item.threshold then item.cd:SetCountdownMillisecondsThreshold(item.threshold) end
    if item.text and item.points and not E.InCombat() then
        if item.font then item.text:SetFont(item.font,item.size,item.flags) end
        item.text:ClearAllPoints()
        for _,point in ipairs(item.points) do item.text:SetPoint(unpack(point)) end
    end
end
local function applyCooldown(item)
    if item.region.cooldown~=item.cd then restoreCooldown(item);return end
    if not enabled(item.class,item.module) then restoreCooldown(item);return end
    local format=getFormatter()
    if format and item.cd.SetCountdownFormatter then item.cd:SetCountdownFormatter(format) end
    if item.cd.SetCountdownMillisecondsThreshold then item.cd:SetCountdownMillisecondsThreshold(1) end
    item.applied=true
    if item.module=='utility' and not E.InCombat() and item.cd.GetCountdownFontString then
        local text=item.cd:GetCountdownFontString()
        if text then
            if not item.points then
                item.text=text;item.font,item.size,item.flags=text:GetFont();item.points={}
                for i=1,text:GetNumPoints() do item.points[#item.points+1]={text:GetPoint(i)} end
            end
            text:ClearAllPoints();text:SetPoint('TOP',item.cd,'BOTTOM',0,-3)
            text:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',11,'OUTLINE')
        end
    end
end
function E.StyleCooldown(region,class,module)
    if not region or not region.cooldown or class~=E.class then return end
    local item=P.cooldowns[region]
    if not item or item.cd~=region.cooldown then
        if item then restoreCooldown(item) end
        item={region=region,cd=region.cooldown,class=class,module=module}
        item.original=E.Call(item.cd.GetCountdownFormatter,item.cd)
        item.threshold=E.Call(item.cd.GetCountdownMillisecondsThreshold,item.cd)
        P.cooldowns[region]=item
        if region.HookScript then region:HookScript('OnShow',function()applyCooldown(item)end) end
    end
    applyCooldown(item)
end
local function resourceActive(item)
    local p=E.Profile()
    return enabled(item.class,'resources') and p.resourceFlow and E.LayoutVisible()
end
local function applyResource(item)
    if not resourceActive(item) then item.group:Stop();return end
    item.texture:SetTexture('Interface\\AddOns\\EclipseHUD\\Media\\resource-flow-'..item.side..'.tga')
    item.texture:SetTexCoord(0,1,0,1)
    item.group:Play()
end
local function restoreResource(item)
    item.group:Stop()
    item.restoring=true
    if item.region.UpdateStatusBarTexture then item.region:UpdateStatusBarTexture() end
    if item.region.bar.UpdateAnchors then item.region.bar:UpdateAnchors() end
    item.restoring=false
end
function E.StyleResource(region,class,side)
    if class~=E.class or not region or not region.bar or not region.bar.fg then return end
    if E.InCombat() then P.pending[region]={class,side};return end
    local item=P.resources[region]
    if not item then
        local texture=region.bar.fg
        if not texture.CreateAnimationGroup then return end
        local group=texture:CreateAnimationGroup()
        group:SetLooping('REPEAT')
        local flip=group:CreateAnimation('FlipBook')
        flip:SetTarget(texture);flip:SetDuration(8);flip:SetOrder(1)
        flip:SetFlipBookRows(16);flip:SetFlipBookColumns(32);flip:SetFlipBookFrames(480)
        flip:SetFlipBookFrameWidth(0);flip:SetFlipBookFrameHeight(0)
        item={region=region,texture=texture,group=group,class=class,side=side}
        P.resources[region]=item
        if region.HookScript then
            region:HookScript('OnShow',function()applyResource(item)end)
            region:HookScript('OnHide',function()item.group:Stop()end)
        end
        if hooksecurefunc then
            for _,target in ipairs({{region,'UpdateStatusBarTexture'},{region.bar,'UpdateAnchors'}}) do
                if target[1][target[2]] then hooksecurefunc(target[1],target[2],function()
                    if not item.restoring then applyResource(item) end
                end) end
            end
        end
    end
    -- Existing native foreground masks remain attached and continue to clip
    -- readable or restricted progress. We replace paint, never the value/mask.
    if resourceActive(item) then applyResource(item) else restoreResource(item) end
end
function E.RefreshPresentation()
    if not E.InCombat() then
        local pending=P.pending;P.pending={}
        for region,info in pairs(pending) do E.StyleResource(region,unpack(info)) end
    end
    for _,item in pairs(P.cooldowns) do applyCooldown(item) end
    for _,item in pairs(P.resources) do
        if resourceActive(item) then applyResource(item) else restoreResource(item) end
    end
end
function E.StopPresentation()
    P.pending={}
    for _,item in pairs(P.cooldowns) do restoreCooldown(item) end
    for _,item in pairs(P.resources) do restoreResource(item) end
end
function E.RefreshEquipment()
    local p,api=E.Profile(),E.API()
    if not p or not api then return end
    local dual=false
    if E.class=='WARRIOR' then
        local id=E.Call(GetInventoryItemID,'player',17)
        if E.Number(id) and C_Item and C_Item.GetItemInfoInstant then
            local ok,_,_,_,loc,_,kind=pcall(C_Item.GetItemInfoInstant,id)
            dual=ok and E.Readable(loc) and E.Readable(kind) and kind==2
                and (loc=='INVTYPE_WEAPON' or loc=='INVTYPE_WEAPONOFFHAND')
        end
        if p.swingMode=='Single' then dual=false end
        -- Manual Dual still requires an actual off-hand weapon. No fake timer.
    end
    E.dualSwing=dual
    api.SetLoadFlag('ECLIPSE_WARRIOR_pet_offhand',p.enabled and E.LiveWorld() and p.pet and E.class=='WARRIOR' and dual==true)
    if E.class=='WARRIOR' and not E.InCombat() and api.GetRegion then
        local main=api.GetRegion('Eclipse | Warrior | Swing 0')
        if main then
            if main.SetOffset then main:SetOffset(dual and -55 or 0,-153) end
            if main.SetRegionWidth then main:SetRegionWidth(dual and 100 or 210) end
        end
    end
end
function E.ComboAllowed()
    return E.class~='DRUID' or E.Call(UnitPowerType,'player')==3
end
function E.ResourceLabel()
    -- Resource identity only, never its current/max/restricted numeric amount.
    local power=E.Call(UnitPowerType,'player')
    local name=type(power)=='number' and E.resourceNames and E.resourceNames[power]
    return E.L(name or 'Resource')
end
