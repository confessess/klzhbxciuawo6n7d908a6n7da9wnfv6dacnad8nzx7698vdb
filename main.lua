-- ============================================================
-- Rivals Modular -- Bootstrap
-- Wires config -> utils -> modules -> GUI -> render loop
-- ============================================================

if _G.__rivals_core then
    warn("[rivals] core already initialized.")
    return
end

local CACHE_FOLDER = "RivalsModular"

local function ensureFolder()
    pcall(function()
        if makefolder and not (isfolder and isfolder(CACHE_FOLDER)) then
            makefolder(CACHE_FOLDER)
        end
    end)
end

local function writeFile(path, content)
    pcall(function()
        if writefile and content then
            writefile(path, content)
        end
    end)
end

local function readFile(path)
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

local SRC_FILES = {
    ["config"]   = [==[
@@SRC:config@@
]==],
    ["utils"]    = [==[
@@SRC:utils@@
]==],
    ["gui"]      = [==[
@@SRC:gui@@
]==],
    ["esp"]      = [==[
@@SRC:esp@@
]==],
    ["combat"]   = [==[
@@SRC:combat@@
]==],
    ["skins"]    = [==[
@@SRC:skins@@
]==],
    ["player"]   = [==[
@@SRC:player@@
]==],
    ["world"]    = [==[
@@SRC:world@@
]==],
    ["misc"]     = [==[
@@SRC:misc@@
]==],
    ["teleport"] = [==[
@@SRC:teleport@@
]==],
    ["queue"]    = [==[
@@SRC:queue@@
]==],
}

local function resolveSource(name)
    local embedded = SRC_FILES[name]
    if embedded and not embedded:match("^@@SRC:") then
        return embedded
    end
    return readFile(CACHE_FOLDER .. "/src/" .. name .. ".lua")
end

ensureFolder()

local queueSrc = resolveSource("queue")
if queueSrc then
    writeFile(CACHE_FOLDER .. "/src/queue.lua", queueSrc)
end

local function loadModule(name)
    local code = resolveSource(name)
    if not code then
        warn("[rivals] missing module: " .. name)
        return nil
    end
    local fn, err = loadstring(code)
    if not fn then
        warn("[rivals/" .. name .. "] compile error: " .. tostring(err))
        return nil
    end
    local ok, mod = pcall(fn)
    if not ok then
        warn("[rivals/" .. name .. "] runtime error: " .. tostring(mod))
        return nil
    end
    return mod
end

local Core = {
    Loaded        = true,
    MenuOpen      = false,
    Connections   = {},
    CurrentTarget = nil,
    Unloaded      = false,
}

local function track(conn)
    table.insert(Core.Connections, conn)
    return conn
end
Core.Track = track

function Core.Unload()
    if Core.Unloaded then return end
    Core.Unloaded = true
    Core.Loaded   = false

    for _, c in ipairs(Core.Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Core.Connections)

    for _, name in ipairs({ "Teleport", "Misc", "World", "Player", "Skins", "Combat", "ESP", "GUI" }) do
        local mod = Core[name]
        if mod and mod.Cleanup then
            pcall(mod.Cleanup)
        end
    end

    pcall(function()
        if writefile then
            writeFile(CACHE_FOLDER .. "/src/queue.lua", "-- killed")
            writeFile(CACHE_FOLDER .. "/main.lua", "-- killed")
        end
    end)

    _G.__rivals_modular_loaded = nil
    _G.__rivals_core = nil
    print("[rivals] unloaded cleanly.")
end

_G.__rivals_core = Core

Core.Config   = loadModule("config")
Core.Utils    = loadModule("utils")
Core.GUI      = loadModule("gui")
Core.ESP      = loadModule("esp")
Core.Combat   = loadModule("combat")
Core.Skins    = loadModule("skins")
Core.Player   = loadModule("player")
Core.World    = loadModule("world")
Core.Misc     = loadModule("misc")
Core.Teleport = loadModule("teleport")

local deps = {
    Config = Core.Config,
    Utils  = Core.Utils,
    GUI    = Core.GUI,
    Core   = Core,
}

for _, name in ipairs({ "Utils", "GUI", "ESP", "Combat", "Skins", "Player", "World", "Misc", "Teleport" }) do
    local mod = Core[name]
    if mod and mod.Init then
        local ok, err = pcall(function() mod.Init(deps) end)
        if not ok then
            warn("[rivals/" .. name .. "] Init error: " .. tostring(err))
        end
    end
end

local RunService = game:GetService("RunService")
track(RunService.RenderStepped:Connect(function(dt)
    if Core.Unloaded then return end
    if Core.ESP      and Core.ESP.Update      then pcall(Core.ESP.Update, dt)      end
    if Core.Combat   and Core.Combat.Update   then pcall(Core.Combat.Update, dt)   end
    if Core.Skins    and Core.Skins.Update    then pcall(Core.Skins.Update, dt)    end
    if Core.Player   and Core.Player.Update   then pcall(Core.Player.Update, dt)   end
    if Core.World    and Core.World.Update    then pcall(Core.World.Update, dt)    end
    if Core.Misc     and Core.Misc.Update     then pcall(Core.Misc.Update, dt)     end
    if Core.Teleport and Core.Teleport.Update then pcall(Core.Teleport.Update, dt) end
end))

task.spawn(function()
    while not Core.Unloaded do
        task.wait(0.15)
        if Core.ESP and Core.ESP.Refresh then
            pcall(Core.ESP.Refresh)
        end
    end
end)

print("[rivals] modular base loaded. RightCtrl opens menu.")
