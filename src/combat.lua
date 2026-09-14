-- ============================================================
-- Rivals Modular -- Combat
-- Legit aimbot, silent aim, ragebot, triggerbot
-- ============================================================

local Combat = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, Camera, UserInputService, RunService
local Mouse

-- State
local aimbotTarget = nil
local silentAimTarget = nil
local ragebotConn = nil
local triggerbotLastClick = 0

-- FOV circles
local aimbotFOVCircle = nil
local silentAimFOVCircle = nil

-- Keybind
local aimbotKeybind = Enum.UserInputType.MouseButton2
local aimbotKeyDown = false

-- ------------------------------------------------------------
-- Target selection
-- ------------------------------------------------------------

local function isValidTarget(player)
    if not player or player == LocalPlayer then return false end
    if not player.Character then return false end
    local humanoid = Utils.CharacterHumanoid(player)
    if not humanoid or humanoid.Health <= 0 then return false end
    return true
end

local function getAimbotTarget()
    local crosshair = Utils.GetCrosshairPosition()
    local localRoot = Utils.CharacterRoot(LocalPlayer)
    if not localRoot then return nil end

    local fovSize = Config.Get("Aimbot_FOVSize") or 250
    local wallCheck = Config.Get("Aimbot_WallCheck") == true
    local teamCheck = Config.Get("Aimbot_TeamCheck") ~= false
    local aimPart = Config.Get("Aimbot_AimPart") or "Head"

    -- Sticky aim - keep current target if valid
    if Config.Get("Aimbot_StickyAim") and aimbotTarget then
        if isValidTarget(aimbotTarget) then
            if teamCheck and Utils.IsTeammate(aimbotTarget) then
                aimbotTarget = nil
            else
                local part = aimbotTarget.Character:FindFirstChild(aimPart)
                if part then
                    if wallCheck and not Utils.HasLineOfSight(part) then
                        aimbotTarget = nil
                    else
                        return aimbotTarget
                    end
                else
                    aimbotTarget = nil
                end
            end
        else
            aimbotTarget = nil
        end
    end

    local best = nil
    local bestDist = math.huge

    for _, player in ipairs(Utils.GetEnemies()) do
        if teamCheck and Utils.IsTeammate(player) then continue end
        if not isValidTarget(player) then continue end

        local part = player.Character:FindFirstChild(aimPart)
        if not part then continue end

        if wallCheck and not Utils.HasLineOfSight(part) then continue end

        local screenPos, onScreen = Utils.WorldToScreen(part.Position)
        if not screenPos or not onScreen then continue end

        local dist2d = (screenPos - crosshair).Magnitude
        if dist2d <= fovSize and dist2d < bestDist then
            best = player
            bestDist = dist2d
        end
    end

    aimbotTarget = best
    return best
end

local function getSilentAimTarget()
    local localRoot = Utils.CharacterRoot(LocalPlayer)
    if not localRoot then return nil end

    local useFOV = Config.Get("SilentAim_UseFOV") == true
    local fovSize = Config.Get("SilentAim_FOVSize") or 500
    local wallCheck = Config.Get("SilentAim_WallCheck") == true
    local teamCheck = Config.Get("SilentAim_TeamCheck") ~= false
    local hitPart = Config.Get("SilentAim_HitPart") or "Head"
    local hitchance = Config.Get("SilentAim_Hitchance") or 100

    -- Hitchance roll
    if math.random(1, 100) > hitchance then return nil end

    local crosshair = Utils.GetCrosshairPosition()
    local best = nil
    local bestDist = math.huge

    for _, player in ipairs(Utils.GetEnemies()) do
        if teamCheck and Utils.IsTeammate(player) then continue end
        if not isValidTarget(player) then continue end

        local part = player.Character:FindFirstChild(hitPart)
        if not part then continue end

        if wallCheck and not Utils.HasLineOfSight(part) then continue end

        if useFOV then
            local screenPos, onScreen = Utils.WorldToScreen(part.Position)
            if not screenPos or not onScreen then continue end
            local dist2d = (screenPos - crosshair).Magnitude
            if dist2d > fovSize then continue end
        end

        local dist3d = (part.Position - localRoot.Position).Magnitude
        if dist3d < bestDist then
            best = player
            bestDist = dist3d
        end
    end

    return best
end

-- ------------------------------------------------------------
-- Aim application
-- ------------------------------------------------------------

local function applyAim(target)
    if not target or not target.Character then return end
    local aimPart = Config.Get("Aimbot_AimPart") or "Head"
    local part = target.Character:FindFirstChild(aimPart)
    if not part then return end

    local useSmooth = Config.Get("Aimbot_Smoothness") == true
    local smoothValue = Config.Get("Aimbot_SmoothValue") or 5
    local usePred = Config.Get("Aimbot_Prediction") == true
    local predX = Config.Get("Aimbot_PredX") or 0
    local predY = Config.Get("Aimbot_PredY") or 0

    local targetPos = part.Position

    -- Prediction
    if usePred then
        local root = Utils.CharacterRoot(target)
        if root then
            local vel = root.Velocity
            targetPos = targetPos + Vector3.new(vel.X * predX * 0.1, vel.Y * predY * 0.1, 0)
        end
    end

    local screenPos, onScreen = Utils.WorldToScreen(targetPos)
    if not screenPos or not onScreen then return end

    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local delta = screenPos - center

    if useSmooth and smoothValue > 0 then
        delta = delta / (smoothValue + 1)
    end

    pcall(function()
        mousemoverel(delta.X, delta.Y)
    end)
end

-- ------------------------------------------------------------
-- Update loops
-- ------------------------------------------------------------

local function updateAimbot()
    if not Config.Get("Aimbot_Enabled") then
        if aimbotFOVCircle then aimbotFOVCircle.Visible = false end
        return
    end

    -- Show FOV circle
    if Config.Get("Aimbot_ShowFOV") then
        if not aimbotFOVCircle then
            aimbotFOVCircle = Utils.NewCircle(
                Config.Get("Aimbot_FOVSize") or 250,
                Utils.HexToColor(Config.Get("Aimbot_FOVColor")),
                2
            )
        end
        if aimbotFOVCircle then
            aimbotFOVCircle.Position = Utils.GetCrosshairPosition()
            aimbotFOVCircle.Radius = Config.Get("Aimbot_FOVSize") or 250
            aimbotFOVCircle.Color = Utils.HexToColor(Config.Get("Aimbot_FOVColor"))
            aimbotFOVCircle.Visible = not Core.MenuOpen
        end
    elseif aimbotFOVCircle then
        aimbotFOVCircle.Visible = false
    end

    -- Check keybind
    local shouldAim = false
    if aimbotKeybind == Enum.UserInputType.MouseButton1
        or aimbotKeybind == Enum.UserInputType.MouseButton2
        or aimbotKeybind == Enum.UserInputType.MouseButton3 then
        shouldAim = UserInputService:IsMouseButtonPressed(aimbotKeybind)
    else
        shouldAim = UserInputService:IsKeyDown(aimbotKeybind)
    end

    if not shouldAim then
        if not Config.Get("Aimbot_StickyAim") then
            aimbotTarget = nil
        end
        return
    end

    local target = getAimbotTarget()
    if target then
        applyAim(target)
    end
end

local function updateSilentAim()
    if not Config.Get("SilentAim_Enabled") then
        if silentAimFOVCircle then silentAimFOVCircle.Visible = false end
        return
    end

    -- Show FOV circle
    if Config.Get("SilentAim_UseFOV") then
        if not silentAimFOVCircle then
            silentAimFOVCircle = Utils.NewCircle(
                Config.Get("SilentAim_FOVSize") or 500,
                Utils.HexToColor(Config.Get("SilentAim_FOVColor")),
                2
            )
        end
        if silentAimFOVCircle then
            silentAimFOVCircle.Position = Utils.GetCrosshairPosition()
            silentAimFOVCircle.Radius = Config.Get("SilentAim_FOVSize") or 500
            silentAimFOVCircle.Color = Utils.HexToColor(Config.Get("SilentAim_FOVColor"))
            silentAimFOVCircle.Visible = not Core.MenuOpen
        end
    elseif silentAimFOVCircle then
        silentAimFOVCircle.Visible = false
    end
end

local function updateRagebot()
    if not Config.Get("Ragebot_Enabled") then
        if ragebotConn then
            ragebotConn:Disconnect()
            ragebotConn = nil
        end
        return
    end

    if not ragebotConn then
        ragebotConn = RunService.RenderStepped:Connect(function()
            if not Config.Get("Ragebot_Enabled") then return end
            if not Utils.IsInActiveRound() then return end

            local target = getSilentAimTarget()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head and Utils.HasLineOfSight(head, Utils.CharacterRoot(LocalPlayer)) then
                    pcall(function()
                        mouse1click()
                    end)
                end
            end
        end)
    end
end

local function updateTriggerbot()
    if not Config.Get("Triggerbot_Enabled") then return end

    local delay = Config.Get("Triggerbot_Delay") or 0
    local chance = Config.Get("Triggerbot_Chance") or 100
    local teamCheck = Config.Get("Triggerbot_TeamCheck") ~= false

    local now = tick()
    if delay > 0 and now - triggerbotLastClick < delay then return end

    -- Check what's under the crosshair
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if not target then return end

    -- Find character from hit part
    local model = target:FindFirstAncestorWhichIsA("Model")
    if not model then return end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    -- Team check
    if teamCheck then
        local player = Players:GetPlayerFromCharacter(model)
        if player and Utils.IsTeammate(player) then return end
    end

    -- Chance roll
    if math.random(1, 100) > chance then return end

    pcall(function()
        mouse1click()
    end)
    triggerbotLastClick = now
end

-- ------------------------------------------------------------
-- Silent aim on click
-- ------------------------------------------------------------

local originalCameraCF = nil

local function onButton1Down()
    if not Config.Get("SilentAim_Enabled") then return end

    local target = getSilentAimTarget()
    if target and target.Character then
        local hitPart = Config.Get("SilentAim_HitPart") or "Head"
        local part = target.Character:FindFirstChild(hitPart)
        if part and Camera then
            originalCameraCF = Camera.CFrame
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        end
    end
end

local function onButton1Up()
    if originalCameraCF and Camera then
        Camera.CFrame = originalCameraCF
        originalCameraCF = nil
    end
end

-- ------------------------------------------------------------
-- Main Update
-- ------------------------------------------------------------

function Combat.Update(_dt)
    if Core.Unloaded then return end

    updateAimbot()
    updateSilentAim()
    updateRagebot()
    updateTriggerbot()
end

-- ------------------------------------------------------------
-- Lifecycle
-- ------------------------------------------------------------

function Combat.Init(deps)
    Config = deps.Config
    Utils  = deps.Utils
    GUI    = deps.GUI
    Core   = deps.Core

    Players          = Utils.Players
    LocalPlayer      = Utils.LocalPlayer
    Camera           = Utils.Camera
    UserInputService = Utils.UserInputService
    RunService       = Utils.RunService
    Mouse            = LocalPlayer:GetMouse()

    -- Input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == aimbotKeybind then
            aimbotKeyDown = true
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onButton1Down()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == aimbotKeybind then
            aimbotKeyDown = false
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onButton1Up()
        end
    end)

    Mouse.Button1Down:Connect(onButton1Down)
    Mouse.Button1Up:Connect(onButton1Up)

    -- Register GUI controls
    local page = GUI.GetPage and GUI.GetPage("Legit")
    if page then
        GUI.AddSection(page, "Aimbot", 1)
        GUI.AddToggle(page, "Enabled",
            function() return Config.Get("Aimbot_Enabled") end,
            function(v) Config.Set("Aimbot_Enabled", v) end, 2)
        GUI.AddToggle(page, "Wall Check",
            function() return Config.Get("Aimbot_WallCheck") end,
            function(v) Config.Set("Aimbot_WallCheck", v) end, 3)
        GUI.AddToggle(page, "Team Check",
            function() return Config.Get("Aimbot_TeamCheck") end,
            function(v) Config.Set("Aimbot_TeamCheck", v) end, 4)
        GUI.AddToggle(page, "Smoothness",
            function() return Config.Get("Aimbot_Smoothness") end,
            function(v) Config.Set("Aimbot_Smoothness", v) end, 5)
        GUI.AddToggle(page, "Prediction",
            function() return Config.Get("Aimbot_Prediction") end,
            function(v) Config.Set("Aimbot_Prediction", v) end, 6)
        GUI.AddToggle(page, "Sticky Aim",
            function() return Config.Get("Aimbot_StickyAim") end,
            function(v) Config.Set("Aimbot_StickyAim", v) end, 7)
        GUI.AddDropdown(page, "Aim Part",
            function() return {"Head", "HumanoidRootPart"} end,
            function() return Config.Get("Aimbot_AimPart") end,
            function(v) Config.Set("Aimbot_AimPart", v) end, 8)
        GUI.AddToggle(page, "Show FOV",
            function() return Config.Get("Aimbot_ShowFOV") end,
            function(v) Config.Set("Aimbot_ShowFOV", v) end, 9)
        GUI.AddSlider(page, "FOV Size", 0, 1000,
            function() return Config.Get("Aimbot_FOVSize") end,
            function(v) Config.Set("Aimbot_FOVSize", v) end, 10)
        GUI.AddSlider(page, "Smoothness", 0, 20,
            function() return Config.Get("Aimbot_SmoothValue") end,
            function(v) Config.Set("Aimbot_SmoothValue", v) end, 11)
        GUI.AddSlider(page, "Prediction X", 0, 10,
            function() return Config.Get("Aimbot_PredX") end,
            function(v) Config.Set("Aimbot_PredX", v) end, 12)
        GUI.AddSlider(page, "Prediction Y", 0, 10,
            function() return Config.Get("Aimbot_PredY") end,
            function(v) Config.Set("Aimbot_PredY", v) end, 13)

        GUI.AddSection(page, "Triggerbot", 14)
        GUI.AddToggle(page, "Enabled",
            function() return Config.Get("Triggerbot_Enabled") end,
            function(v) Config.Set("Triggerbot_Enabled", v) end, 15)
        GUI.AddToggle(page, "Team Check",
            function() return Config.Get("Triggerbot_TeamCheck") end,
            function(v) Config.Set("Triggerbot_TeamCheck", v) end, 16)
        GUI.AddSlider(page, "Chance %", 1, 100,
            function() return Config.Get("Triggerbot_Chance") end,
            function(v) Config.Set("Triggerbot_Chance", v) end, 17)
        GUI.AddSlider(page, "Click Delay", 0, 50,
            function() return Config.Get("Triggerbot_Delay") end,
            function(v) Config.Set("Triggerbot_Delay", v) end, 18)
    end

    -- Rage tab
    local ragePage = GUI.GetPage and GUI.GetPage("Rage")
    if ragePage then
        GUI.AddSection(ragePage, "Silent Aim", 1)
        GUI.AddToggle(ragePage, "Enabled",
            function() return Config.Get("SilentAim_Enabled") end,
            function(v) Config.Set("SilentAim_Enabled", v) end, 2)
        GUI.AddToggle(ragePage, "Auto Click",
            function() return Config.Get("SilentAim_AutoClick") end,
            function(v) Config.Set("SilentAim_AutoClick", v) end, 3)
        GUI.AddToggle(ragePage, "Wall Check",
            function() return Config.Get("SilentAim_WallCheck") end,
            function(v) Config.Set("SilentAim_WallCheck", v) end, 4)
        GUI.AddToggle(ragePage, "Team Check",
            function() return Config.Get("SilentAim_TeamCheck") end,
            function(v) Config.Set("SilentAim_TeamCheck", v) end, 5)
        GUI.AddToggle(ragePage, "Use FOV",
            function() return Config.Get("SilentAim_UseFOV") end,
            function(v) Config.Set("SilentAim_UseFOV", v) end, 6)
        GUI.AddSlider(ragePage, "FOV Size", 50, 1000,
            function() return Config.Get("SilentAim_FOVSize") end,
            function(v) Config.Set("SilentAim_FOVSize", v) end, 7)
        GUI.AddSlider(ragePage, "Hitchance %", 0, 100,
            function() return Config.Get("SilentAim_Hitchance") end,
            function(v) Config.Set("SilentAim_Hitchance", v) end, 8)
        GUI.AddDropdown(ragePage, "Hit Part",
            function() return {"Head", "HumanoidRootPart"} end,
            function() return Config.Get("SilentAim_HitPart") end,
            function(v) Config.Set("SilentAim_HitPart", v) end, 9)

        GUI.AddSection(ragePage, "Ragebot", 10)
        GUI.AddToggle(ragePage, "Enabled",
            function() return Config.Get("Ragebot_Enabled") end,
            function(v) Config.Set("Ragebot_Enabled", v) end, 11)
    end

    print("[rivals] Combat module initialized.")
end

function Combat.Cleanup()
    if aimbotFOVCircle then
        Utils.DestroyDrawing(aimbotFOVCircle)
        aimbotFOVCircle = nil
    end
    if silentAimFOVCircle then
        Utils.DestroyDrawing(silentAimFOVCircle)
        silentAimFOVCircle = nil
    end
    if ragebotConn then
        ragebotConn:Disconnect()
        ragebotConn = nil
    end
    aimbotTarget = nil
    silentAimTarget = nil
end

return Combat
