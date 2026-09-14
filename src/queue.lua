-- ============================================================
-- Rivals Modular -- Queue Chain
-- queue_on_teleport payload
-- ============================================================

local CACHE_FOLDER = "RivalsModular"
local MAIN_FILE    = CACHE_FOLDER .. "/main.lua"
local QUEUE_FILE   = CACHE_FOLDER .. "/queue.lua"

local function ensureFolder()
    pcall(function()
        if makefolder and not (isfolder and isfolder(CACHE_FOLDER)) then
            makefolder(CACHE_FOLDER)
        end
    end)
end

local function readFileSafe(path)
    local result = nil
    pcall(function()
        if isfile and isfile(path) then
            result = readfile(path)
        end
    end)
    if typeof(result) == "string" and result ~= "" then
        return result
    end
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

local function getQueueFn()
    return queue_on_teleport
        or (syn and syn.queue_on_teleport)
        or (fluxus and fluxus.queue_on_teleport)
end

task.wait(2)
ensureFolder()

local mainCode = readFileSafe(MAIN_FILE)
if not mainCode or mainCode == "-- killed" then return end
run(mainCode, "main")

local qf = getQueueFn()
if qf then
    local queueCode = readFileSafe(QUEUE_FILE)
    if queueCode and queueCode ~= "-- killed" then
        pcall(function() qf(queueCode) end)
    end
end
