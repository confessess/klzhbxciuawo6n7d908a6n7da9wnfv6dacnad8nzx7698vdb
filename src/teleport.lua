-- ============================================================
-- Rivals Modular -- Teleport
-- Teleport behind enemy
-- Master Section UI: Header toggles its own module
-- ============================================================

local Teleport = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer

local function getNearestEnemy()
    local localRoot = Utils.CharacterRoot(LocalPlayer)
    if not localRoot then return nil end

    local nearest = nil
    local nearestDist = math.huge

    for _, player in ipairs(Utils.GetEnemies()) do
        local root = Utils.CharacterRoot(player)
        if root then
            local dist = (root.Position - localRoot.Position).Magnitude
            if dist < nearestDist then
                nearest = player
                nearestDist = dist
            end
        end
    end

    return nearest
end

local function teleportBehindEnemy()
    if not Config.Get("TPBehind_Enabled") then return end

    local maxDist = Config.Get("TPBehind_MaxDist") or 1000
    local behindDist = Config.Get("TPBehind_Distance") or 5

    local target = getNearestEnemy()
    if not target then return end

    local localRoot = Utils.CharacterRoot(LocalPlayer)
    local targetRoot = Utils.CharacterRoot(target)
    if not localRoot or not targetRoot then return end

    local dist = (targetRoot.Position - localRoot.Position).Magnitude
    if dist > maxDist then return end

    local behindPos = targetRoot.Position - targetRoot.CFrame.LookVector * behindDist
    localRoot.CFrame = CFrame.new(behindPos)
end

function Teleport.Update(_dt)
    if Core.Unloaded then return end
    if Config.Get("TPBehind_Enabled") then
        teleportBehindEnemy()
    end
end

function Teleport.Init(deps)
    Config      = deps.Config
    Utils       = deps.Utils
    GUI         = deps.GUI
    Core        = deps.Core
    Players     = Utils.Players
    LocalPlayer = Utils.LocalPlayer

    -- Register GUI (Misc tab) with Master Section
    local page = GUI.GetPage and GUI.GetPage("Misc")
    if page then
        local C = GUI.Components

        -- ========================================
        -- TP BEHIND ENEMY MASTER SECTION
        -- ========================================
        local tpSection, setTpOpen = C.MasterSection(page, "TP Behind Enemy", 80, Config.Get("TPBehind_Enabled") or false)

        C.Toggle(tpSection, "Enabled", Config.Get("TPBehind_Enabled"), function(v) Config.Set("TPBehind_Enabled", v) end, 81)
        C.Slider(tpSection, "Distance Behind", 1, 10, Config.Get("TPBehind_Distance"), function(v) Config.Set("TPBehind_Distance", v) end, 82)
        C.Slider(tpSection, "Max Distance", 100, 5000, Config.Get("TPBehind_MaxDist"), function(v) Config.Set("TPBehind_MaxDist", v) end, 83)

        setTpOpen(Config.Get("TPBehind_Enabled") or false)
    end

    print("[rivals] Teleport module initialized.")
end

function Teleport.Cleanup()
end

return Teleport
