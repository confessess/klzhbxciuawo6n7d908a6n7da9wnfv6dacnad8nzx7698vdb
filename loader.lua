local REPO_URL = "https://raw.githubusercontent.com/confessess/klzhbxciuawo6n7d908a6n7da9wnfv6dacnad8nzx7698vdb/main/main.lua"

if not game or not game.GetService then return end
if not game:GetService("Players").LocalPlayer then return end
if _G.__rivals_loaded then return end
_G.__rivals_loaded = true

local code = game:HttpGet(REPO_URL)
if not code or #code < 100 or code:find("<!DOCTYPE") then
    _G.__rivals_loaded = nil
    return
end

local fn = loadstring(code)
if not fn then
    _G.__rivals_loaded = nil
    return
end

pcall(fn)