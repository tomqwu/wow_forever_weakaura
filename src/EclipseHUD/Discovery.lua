local _, E = ...
-- Public, out-of-combat identity discovery only. No cooldown/aura observations.
local D = {spells={}, byID={}, cdm={}, eligible={}, requested={}}
E.discovery = D
function E.Readable(v) return not issecretvalue or not issecretvalue(v) end
function E.Number(v) return E.Readable(v) and type(v)=="number" and v==v and v>0 and v<2^31 end
function E.Call(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, result = pcall(fn, ...)
    if ok and E.Readable(result) then return result end
end
local function text(v) return E.Readable(v) and type(v)=="string" and v~="" and v~="?" end
local function metadata(id)
    if not E.Number(id) then return end
    local info=E.Call(C_Spell and C_Spell.GetSpellInfo,id)
    if type(info)~="table" or not text(info.name) or not E.Number(info.iconID) or info.iconID==134400 then return end
    return {id=id,name=info.name,icon=info.iconID}
end
local function known(id)
    return E.Number(id) and E.Call(C_SpellBook and C_SpellBook.IsSpellKnown,id)==true
end
local function index(id, record)
    if E.Number(id) then D.byID[id]=record end
end
local function remember(id, base, passive, level)
    if not (known(id) or known(base)) then return end
    local record=metadata(id)
    if not record then return end
    record.passive,record.level=passive,level or 0
    index(id,record); index(base,record)
    local previous=D.spells[record.name]
    if not previous or record.level>=previous.level then D.spells[record.name]=record end
    local baseInfo=metadata(base)
    if baseInfo then
        local previousBase=D.spells[baseInfo.name]
        if not previousBase or record.level>=previousBase.level then D.spells[baseInfo.name]=record end
    end
end
function D.ScanBook()
    D.spells,D.byID={},{}
    local book=C_SpellBook
    local bank=Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
    if not book or not bank then return end
    local count=E.Call(book.GetNumSpellBookSkillLines)
    if not E.Number(count) or count>100 then return end
    for line=1,count do
        local info=E.Call(book.GetSpellBookSkillLineInfo,line)
        if type(info)=="table" and E.Readable(info.itemIndexOffset) and type(info.itemIndexOffset)=="number"
            and E.Readable(info.numSpellBookItems) and type(info.numSpellBookItems)=="number"
            and info.itemIndexOffset>=0 and info.numSpellBookItems>=0 and info.numSpellBookItems<=1000 then
            for slot=info.itemIndexOffset+1,info.itemIndexOffset+info.numSpellBookItems do
                local item=E.Call(book.GetSpellBookItemInfo,slot,bank)
                if type(item)=="table" and E.Readable(item.isOffSpec) and item.isOffSpec==false
                    and E.Readable(item.isPassive) and type(item.isPassive)=="boolean" then
                    local level=E.Call(book.GetSpellBookItemLevelLearned,slot,bank)
                    local base=E.Number(item.baseSpellID) and item.baseSpellID or item.actionID
                    remember(item.spellID,base,item.isPassive,E.Number(level) and level or 0)
                end
            end
        end
    end
end
function D.ScanCDM()
    D.cdm={}
    local api=C_CooldownViewer
    if not api or not Enum or not Enum.CooldownViewerCategory then return end
    for name,category in pairs(Enum.CooldownViewerCategory) do
        local ids=E.Call(api.GetCooldownViewerCategorySet,category,false)
        if type(ids)=="table" then
            for _,id in ipairs(ids) do
                local info=E.Number(id) and E.Call(api.GetCooldownViewerCooldownInfo,id)
                if type(info)=="table" and E.Readable(info.isKnown) and info.isKnown==true then
                    local override=E.Number(info.overrideSpellID) and info.overrideSpellID
                    local record=metadata(override or info.spellID)
                    if record then
                        record.cdmID,record.category=id,name
                        record.identities={}
                        for _,seed in pairs({info.spellID,override}) do
                            if E.Number(seed) then record.identities[seed]=true end
                        end
                        if E.Readable(info.linkedSpellIDs) and type(info.linkedSpellIDs)=="table" then
                            for _,seed in ipairs(info.linkedSpellIDs) do
                                if E.Number(seed) then record.identities[seed]=true end
                            end
                        end
                        D.cdm[id]=record
                    end
                end
            end
        end
    end
end
function D.Resolve(seed, kind)
    if not E.Number(seed) then return end
    local direct=D.byID[seed]
    if direct then direct=D.spells[direct.name] or direct end
    if direct and direct.passive and kind~='aura' then return end
    if direct and (kind=="aura" or not direct.passive) then return direct end
    local info=metadata(seed)
    if info then
        local rank=D.spells[info.name]
        if rank and (kind=="aura" or not rank.passive) then return rank end
    elseif C_Spell and C_Spell.RequestLoadSpellData and not D.requested[seed] then
        D.requested[seed]=true; E.Call(C_Spell.RequestLoadSpellData,seed)
    end
    -- Proc IDs are not necessarily spellbook abilities. A learned native CDM
    -- identity may qualify them; mere existence of their metadata never does.
    for _,entry in pairs(D.cdm) do
        if entry.identities[seed] and (kind=='aura' or entry.category=='Essential' or entry.category=='Utility'
            or entry.category=='SpecAgnosticEssential') then return entry end
    end
    if kind=="aura" and known(seed) then return info end -- genuine learned passive talents
end
function D.ApplyFlags()
    local api,p=E.API(),E.Profile()
    if not api or not api.SetLoadFlag then return end
    for id,entry in pairs(E.catalog or {}) do
        local on=p and p.enabled and E.LiveWorld() and E.class==entry.cls and p[entry.module]~=false and D.eligible[id]~=nil
        if on and E.selection then on=E.selection.Allowed(id,entry) end
        if entry.module=='fx' and (not p or not p.art) then on=false end
        api.SetLoadFlag(entry.flag,on==true)
    end
end
function D.Refresh()
    D.timer=nil
    local p=E.Profile()
    if not p or not p.enabled or D.stopped then return end
    if E.InCombat() then D.pending=true; return end
    D.requested=D.requested or {}
    D.ScanBook(); D.ScanCDM(); D.eligible={}
    for id,entry in pairs(E.catalog or {}) do
        if entry.cls==E.class then
            for _,seed in ipairs(entry.seeds) do
                local record=D.Resolve(seed,entry.kind)
                if record then D.eligible[id]=record; break end
            end
        end
    end
    D.pending=nil
    if E.selection then E.selection.Refresh() end
    if E.RefreshEquipment then E.RefreshEquipment() end
    if E.RefreshPresentation then E.RefreshPresentation() end
    D.ApplyFlags(); E.Notify()
end
function D.Schedule()
    if D.timer or D.stopped then return end
    local p=E.Profile(); if not p or not p.enabled then return end
    if E.InCombat() then D.pending=true; return end
    D.timer=C_Timer.NewTimer(.1,D.Refresh)
end
local frame=CreateFrame("Frame")
D.events=frame
local refreshEvents={"SPELLS_CHANGED","LEARNED_SPELL_IN_SKILL_LINE","SPELL_DATA_LOAD_RESULT","SPELL_TEXT_UPDATE",
    "TRAIT_CONFIG_UPDATED","PLAYER_TALENT_UPDATE","PLAYER_SPECIALIZATION_CHANGED","PLAYER_EQUIPMENT_CHANGED",
    "GET_ITEM_INFO_RECEIVED","UNIT_INVENTORY_CHANGED","UPDATE_SHAPESHIFT_FORM",
    "LOADING_SCREEN_DISABLED",
    "COOLDOWN_VIEWER_DATA_LOADED","COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED","COOLDOWN_VIEWER_TABLE_HOTFIXED"}
function D.Start()
    local p=E.Profile(); if not p or not p.enabled then D.Stop(); return end
    D.stopped=false
    for _,event in ipairs(refreshEvents) do pcall(frame.RegisterEvent,frame,event) end
    D.Schedule()
end
function D.Stop()
    D.stopped=true
    if E.selection then E.selection.Stop() end
    if D.timer then D.timer:Cancel(); D.timer=nil end
    for _,event in ipairs(refreshEvents) do frame:UnregisterEvent(event) end
    D.eligible,D.spells,D.byID,D.cdm,D.requested={},{},{},{},{}
    D.ApplyFlags()
end
frame:SetScript("OnEvent",function(_,event,unit)
    if event=='UNIT_INVENTORY_CHANGED' and unit~='player' then return end
    if event=='UPDATE_SHAPESHIFT_FORM' and E.class=='DRUID' and E.selection then
        -- Reuse learned identities in combat. No spellbook/CDM scan or root
        -- ancestry mutation; native module flags switch the ordinary skills.
        E.selection.Refresh();D.ApplyFlags();E.Notify()
    end
    D.Schedule()
end)
function E.ReportSpells()
    if E.InCombat() then print("Eclipse: "..E.L("Changes apply after combat.")); return end
    D.Refresh()
    print("Eclipse: "..E.L("Learned spell identities"))
    local rows={}
    for name,record in pairs(D.spells) do rows[#rows+1]=name.." ["..record.id.."]" end
    table.sort(rows); for _,row in ipairs(rows) do print(row) end
    local api=E.API()
    for id,entry in pairs(E.catalog or {}) do
        if entry.cls==E.class and entry.kind=="aura" then
            local region=api and api.GetRegion and api.GetRegion(id)
            local data=api and api.GetData and api.GetData(id)
            -- Attachment existence only: never inspect native visibility/alpha.
            print(id..": eligible="..tostring(D.eligible[id]~=nil)..", native="..tostring(region~=nil and region.blizzardAuraDisplay~=nil)
                ..", suppression="..tostring(region~=nil and region.blizzardSuppressed~=nil)
                ..", fallback="..tostring(data and data.triggers and data.triggers.secretFallback or 'default'))
        end
    end
end
