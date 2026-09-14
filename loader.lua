-- ============================================================
-- Rivals Modular -- Loader Stub
-- Obfuscate this file for release
-- ============================================================

local CACHE_FOLDER = "RivalsModular"
local MAIN_FILE    = CACHE_FOLDER .. "/main.lua"
local QUEUE_FILE   = CACHE_FOLDER .. "/queue.lua"

local EMBEDDED_PAYLOAD = nil

local function ensureFolder()
    pcall(function()
        if makefolder and not (isfolder and isfolder(CACHE_FOLDER)) then
            makefolder(CACHE_FOLDER)
        end
    end)
end

local function writeCache(path, content)
    pcall(function()
        if writefile and content then writefile(path, content) end
    end)
end

local function readCache(path)
    local result = nil
    pcall(function()
        if isfile and isfile(path) then result = readfile(path) end
    end)
    if typeof(result) == "string" and result ~= "" then return result end
    return nil
end

local function run(code, label)
    if not code or code == "-- killed" then return false end
    if not loadstring then return false end
    local fn, err = loadstring(code)
    if not fn then return false end
    local ok, runErr = pcall(fn)
    return ok
end

if _G.__rivals_modular_loaded then return end
_G.__rivals_modular_loaded = true

ensureFolder()

local payload = EMBEDDED_PAYLOAD or readCache(MAIN_FILE)
if payload then
    writeCache(MAIN_FILE, payload)
    run(payload, "main")
end

local queuePayload = readCache(QUEUE_FILE)
local queueFunc = queue_on_teleport
    or (syn and syn.queue_on_teleport)
    or (fluxus and fluxus.queue_on_teleport)

if queueFunc and queuePayload and queuePayload ~= "-- killed" then
    pcall(function() queueFunc(queuePayload) end)
end
