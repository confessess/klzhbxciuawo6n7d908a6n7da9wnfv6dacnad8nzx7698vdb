-- ============================================================
-- Rivals Modular -- Bootstrap (GitHub version with cache busting)
-- ============================================================

if _G.__rivals_core then return end

local REPO_BASE = "https://raw.githubusercontent.com/confessess/klzhbxciuawo6n7d908a6n7da9wnfv6dacnad8nzx7698vdb/main/src/"
local CACHE_BUST = "?t=" .. tostring(os.time())  -- Add timestamp to bust cache

local function fetch(url)
    local result = nil
    pcall(function()
        result = game:HttpGet(url .. CACHE_BUST)
    end)
    if typeof(result) == "string" and #result > 10 and not result:find("<!DOCTYPE") then
        return result
    end
    return nil
end

local function loadModule(name)
    local url = REPO_BASE .. name .. ".lua"
    local code = fetch(url)
    if not code then
        warn("[rivals] failed to fetch: " .. name)
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
    Loaded = true, MenuOpen = false, Connections = {},
    CurrentTarget = nil, Unloaded = false,
}

local function track(conn)
    table.insert(Core.Connections, conn)
    return conn
end
Core.Track = track

function Core.Unload()
    if Core.Unloaded then return end
    Core.Unloaded = true
    for _, c in ipairs(Core.Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Core.Connections)
    for _, name in ipairs({"Teleport", "Misc", "World", "Player", "Skins", "Combat", "Visuals", "GUI"}) do
        local mod = Core[name]
        if mod and mod.Cleanup then pcall(mod.Cleanup) end
    end
    _G.__rivals_loaded = nil
    _G.__rivals_core = nil
end

_G.__rivals_core = Core

Core.Config   = loadModule("config")
Core.Utils    = loadModule("utils")
Core.GUI      = loadModule("gui")
Core.Visuals  = loadModule("visuals")
Core.Combat   = loadModule("combat")
Core.Skins    = loadModule("skins")
Core.Player   = loadModule("player")
Core.World    = loadModule("world")
Core.Misc     = loadModule("misc")
Core.Teleport = loadModule("teleport")

local deps = { Config = Core.Config, Utils = Core.Utils, GUI = Core.GUI, Core = Core }

for _, name in ipairs({"Utils", "GUI", "Visuals", "Combat", "Skins", "Player", "World", "Misc", "Teleport"}) do
    local mod = Core[name]
    if mod and mod.Init then
        pcall(function() mod.Init(deps) end)
    end
end

local RunService = game:GetService("RunService")
track(RunService.RenderStepped:Connect(function(dt)
    if Core.Unloaded then return end
    if Core.Visuals and Core.Visuals.Update then pcall(Core.Visuals.Update, dt) end
    if Core.Combat and Core.Combat.Update then pcall(Core.Combat.Update, dt) end
    if Core.Skins and Core.Skins.Update then pcall(Core.Skins.Update, dt) end
    if Core.Player and Core.Player.Update then pcall(Core.Player.Update, dt) end
    if Core.World and Core.World.Update then pcall(Core.World.Update, dt) end
    if Core.Misc and Core.Misc.Update then pcall(Core.Misc.Update, dt) end
    if Core.Teleport and Core.Teleport.Update then pcall(Core.Teleport.Update, dt) end
end))

task.spawn(function()
    while not Core.Unloaded do
        task.wait(0.15)
        if Core.Visuals and Core.Visuals.Refresh then pcall(Core.Visuals.Refresh) end
    end
end)

print("[rivals] loaded. RightCtrl opens menu.")