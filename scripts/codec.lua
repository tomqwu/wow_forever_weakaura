-- Use the exact LibSerialize + LibDeflate wire format accepted by FA.
strmatch = string.match
-- The game client is Lua 5.1; keep the tool usable on newer interpreters.
local unpack = unpack or table.unpack
local compile = loadstring or load
local base = arg[0]:match("^(.*[/\\])") or "scripts/"
dofile(base .. "../vendor/LibStub.lua")
dofile(base .. "../vendor/LibSerialize.lua")
dofile(base .. "../vendor/LibDeflate.lua")
local serialize = ForeverAurasLibSerialize or LibStub("LibSerialize")
local deflate = LibStub("LibDeflate")
local function read(path)
    local f=assert(io.open(path,"rb")); local value=f:read("*a"); f:close(); return value
end
local function decode(value)
    local payload=assert(value:match("^!WA:2!(.-)%s*$"),"Unsupported prefix")
    local bytes=assert(deflate:DecodeForPrint(payload),"Invalid encoding")
    local success,data=serialize:Deserialize(assert(deflate:DecompressDeflate(bytes)))
    assert(success,data);return data
end
if arg[1] == "encode" then
    local data=assert(loadfile(arg[2]))()
    local raw=serialize:SerializeEx({errorOnUnserializableType=true},data)
    local value="!WA:2!"..deflate:EncodeForPrint(deflate:CompressDeflate(raw,{level=9}))
    local roundtrip=decode(value)
    assert(roundtrip.d.id==data.d.id and #roundtrip.c==#data.c,"Round trip failed")
    local f=assert(io.open(arg[3],"wb"));f:write(value,"\n");f:close()
    print("Import codec round trip passed: "..#roundtrip.c.." children, "..#value.." characters")
elseif arg[1] == "verify" then
    local data=decode(read(arg[2]))
    if arg[3] then
        local expected=assert(loadfile(arg[3]))()
        local function equal(a,b)
            assert(type(a)==type(b),"Round-trip type mismatch")
            if type(a)~="table" then assert(a==b,"Round-trip value mismatch");return end
            for key,value in pairs(a)do equal(value,b[key])end
            for key in pairs(b)do assert(a[key]~=nil,"Round-trip missing key")end
        end
        equal(data,expected)
    end
    assert(data.m=="d" and data.v==2000 and data.d.regionType=="group")
    local ids,uids={},{}
    for _,d in ipairs({data.d,unpack(data.c)}) do
        assert(not ids[d.id],"Duplicate ID: "..d.id);ids[d.id]=d
        assert(not uids[d.uid],"Duplicate UID: "..d.uid);uids[d.uid]=true
        for _,t in ipairs(d.triggers) do
            for _,key in ipairs({"custom","customDuration","customName","customIcon","customStacks"}) do
                if t.trigger[key] then assert(compile("return "..t.trigger[key]),d.id.." "..key) end
            end
        end
        -- Display-level functions FA compiles as "return <code>".
        for _,key in ipairs({"customText","customSort"}) do
            if d[key] then assert(compile("return "..d[key]),d.id.." "..key) end
        end
        if d.triggers.customTriggerLogic then
            assert(compile("return "..d.triggers.customTriggerLogic),d.id.." customTriggerLogic")
        end
        for phase,a in pairs(d.actions) do if a.custom then assert(compile(a.custom),d.id.." "..phase.." action") end end
    end
    -- Both directions: every parent lists its child exactly once, and every
    -- listed child points back, so no display can be silently detached.
    local listed={}
    for _,d in pairs(ids) do
        for _,id in ipairs(d.controlledChildren or {}) do
            assert(ids[id],"Missing child: "..id)
            assert(ids[id].parent==d.id,"Broken child: "..id)
            assert(not listed[id],"Child listed twice: "..id);listed[id]=true
        end
    end
    for id,d in pairs(ids) do
        if d.parent then assert(ids[d.parent],"Missing parent: "..id);assert(listed[id],"Unlisted child: "..id)
        else assert(d==data.d,"Second root: "..id) end
    end
    print("Decoded import verified: "..#data.c.." children, unique IDs, hierarchy, Lua compilation")
else error("Usage: codec.lua encode INPUT.lua OUTPUT.txt | verify INPUT.txt [EXPECTED.lua]") end
