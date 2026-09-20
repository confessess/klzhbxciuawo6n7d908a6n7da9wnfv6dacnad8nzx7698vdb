-- ============================================================
-- Rivals Modular -- Combat
-- Legit aimbot, silent aim, ragebot, triggerbot
-- Master Section UI: Each header toggles its own module
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

-- Keybind (nil = no keybind, can be mouse button or key)
local aimbotKeybind = nil
local aimbotKeyDown = false

-- Helper to check if keybind is pressed
local function isKeybindPressed()
    if not aimbotKeybind then return false end

    if typeof(aimbotKeybind) == "EnumItem" then
        if aimbotKeybind.EnumType == Enum.UserInputType then
            return UserInputService:IsMouseButtonPressed(aimbotKeybind)
        elseif aimbotKeybind.EnumType == Enum.KeyCode then
            return UserInputService:IsKeyDown(aimbotKeybind)
        end
    end
    return false
end

-- Helper to format keybind for display
local function formatKeybind(kb)
    if not kb then return "None" end
    if typeof(kb) == "EnumItem" then
        local str = tostring(kb)
        local name = str:match("%.(%w+)$") or str
        return name
    end
    return tostring(kb)
end

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
        local skip = false
        if teamCheck and Utils.IsTeammate(player) then skip = true end
        if not skip and not isValidTarget(player) then skip = true end

        if not skip then
            local part = player.Character:FindFirstChild(aimPart)
            if not part then skip = true end

            if not skip and wallCheck and not Utils.HasLineOfSight(part) then skip = true end

            if not skip then
                local screenPos, onScreen = Utils.WorldToScreen(part.Position)
                if not screenPos or not onScreen then skip = true end

                if not skip then
                    local dist2d = (screenPos - crosshair).Magnitude
                    if dist2d <= fovSize and dist2d < bestDist then
                        best = player
                        bestDist = dist2d
                    end
                end
            end
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
    local shouldAim = isKeybindPressed()

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

        -- Check aimbot keybind
        if aimbotKeybind then
            if typeof(aimbotKeybind) == "EnumItem" then
                if aimbotKeybind.EnumType == Enum.UserInputType and input.UserInputType == aimbotKeybind then
                    aimbotKeyDown = true
                elseif aimbotKeybind.EnumType == Enum.KeyCode and input.KeyCode == aimbotKeybind then
                    aimbotKeyDown = true
                end
            end
        end

        -- Silent aim on click
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onButton1Down()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        -- Check aimbot keybind
        if aimbotKeybind then
            if typeof(aimbotKeybind) == "EnumItem" then
                if aimbotKeybind.EnumType == Enum.UserInputType and input.UserInputType == aimbotKeybind then
                    aimbotKeyDown = false
                elseif aimbotKeybind.EnumType == Enum.KeyCode and input.KeyCode == aimbotKeybind then
                    aimbotKeyDown = false
                end
            end
        end

        -- Silent aim on release
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onButton1Up()
        end
    end)

    Mouse.Button1Down:Connect(onButton1Down)
    Mouse.Button1Up:Connect(onButton1Up)

    -- Register GUI controls (Combat tab) with Master Sections
    local page = GUI.GetPage and GUI.GetPage("Combat")
    if page then
        local C = GUI.Components

        -- ========================================
        -- AIMBOT MASTER SECTION
        -- ========================================
        local aimbotSection, setAimbotOpen = C.MasterSection(page, "Aimbot", 1, Config.Get("Aimbot_Enabled") or false)

        C.Toggle(aimbotSection, "Enabled", Config.Get("Aimbot_Enabled"), function(v) 
            Config.Set("Aimbot_Enabled", v) 
        end, 2)

        -- Hotkey with clear button
        local hotkeyFrame = Instance.new("Frame")
        hotkeyFrame.Size = UDim2.new(1, 0, 0, 32)
        hotkeyFrame.BackgroundTransparency = 1
        hotkeyFrame.LayoutOrder = 3
        hotkeyFrame.Parent = aimbotSection

        local hotkeyLbl = Instance.new("TextLabel")
        hotkeyLbl.Size = UDim2.new(0.4, 0, 1, 0)
        hotkeyLbl.BackgroundTransparency = 1
        hotkeyLbl.Text = "Hotkey"
        hotkeyLbl.TextColor3 = Color3.fromRGB(220, 220, 235)
        hotkeyLbl.Font = Enum.Font.GothamMedium
        hotkeyLbl.TextSize = 13
        hotkeyLbl.TextXAlignment = Enum.TextXAlignment.Left
        hotkeyLbl.Parent = hotkeyFrame

        local hotkeyBtn = Instance.new("TextButton")
        hotkeyBtn.Size = UDim2.new(0.35, -30, 0, 26)
        hotkeyBtn.Position = UDim2.new(0.45, 0, 0.5, -13)
        hotkeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        hotkeyBtn.BorderSizePixel = 0
        hotkeyBtn.Text = formatKeybind(aimbotKeybind)
        hotkeyBtn.TextColor3 = Color3.fromRGB(80, 140, 255)
        hotkeyBtn.Font = Enum.Font.GothamBold
        hotkeyBtn.TextSize = 12
        hotkeyBtn.AutoButtonColor = false
        hotkeyBtn.Parent = hotkeyFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = hotkeyBtn

        local clearBtn = Instance.new("TextButton")
        clearBtn.Size = UDim2.fromOffset(24, 24)
        clearBtn.Position = UDim2.new(1, -24, 0.5, -12)
        clearBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        clearBtn.BorderSizePixel = 0
        clearBtn.Text = "×"
        clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        clearBtn.Font = Enum.Font.GothamBold
        clearBtn.TextSize = 14
        clearBtn.AutoButtonColor = false
        clearBtn.Parent = hotkeyFrame

        local clearCorner = Instance.new("UICorner")
        clearCorner.CornerRadius = UDim.new(0, 4)
        clearCorner.Parent = clearBtn

        -- Hotkey click handler
        local listening = false
        hotkeyBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            hotkeyBtn.Text = "..."

            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end

                if input.UserInputType == Enum.UserInputType.Keyboard then
                    aimbotKeybind = input.KeyCode
                    hotkeyBtn.Text = formatKeybind(input.KeyCode)
                    listening = false
                    conn:Disconnect()
                elseif input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.MouseButton2
                    or input.UserInputType == Enum.UserInputType.MouseButton3 then
                    aimbotKeybind = input.UserInputType
                    hotkeyBtn.Text = formatKeybind(input.UserInputType)
                    listening = false
                    conn:Disconnect()
                end
            end)
        end)

        -- Clear button
        clearBtn.MouseButton1Click:Connect(function()
            aimbotKeybind = nil
            hotkeyBtn.Text = "None"
            aimbotKeyDown = false
        end)

        C.Toggle(aimbotSection, "Wall Check", Config.Get("Aimbot_WallCheck"), function(v) Config.Set("Aimbot_WallCheck", v) end, 4)
        C.Toggle(aimbotSection, "Team Check", Config.Get("Aimbot_TeamCheck"), function(v) Config.Set("Aimbot_TeamCheck", v) end, 5)
        C.Toggle(aimbotSection, "Smoothness", Config.Get("Aimbot_Smoothness"), function(v) Config.Set("Aimbot_Smoothness", v) end, 6)
        C.Toggle(aimbotSection, "Prediction", Config.Get("Aimbot_Prediction"), function(v) Config.Set("Aimbot_Prediction", v) end, 7)
        C.Dropdown(aimbotSection, "Aim Part", {"Head", "HumanoidRootPart"}, Config.Get("Aimbot_AimPart"), function(v) Config.Set("Aimbot_AimPart", v) end, 8)
        C.Toggle(aimbotSection, "Show FOV", Config.Get("Aimbot_ShowFOV"), function(v) Config.Set("Aimbot_ShowFOV", v) end, 9)
        C.Slider(aimbotSection, "FOV Size", 0, 1000, Config.Get("Aimbot_FOVSize"), function(v) Config.Set("Aimbot_FOVSize", v) end, 10)
        C.Slider(aimbotSection, "Smooth Value", 0, 20, Config.Get("Aimbot_SmoothValue"), function(v) Config.Set("Aimbot_SmoothValue", v) end, 11)

        -- Auto-expand/collapse based on enabled state
        local aimbotEnabled = Config.Get("Aimbot_Enabled") or false
        

        -- Hook enabled toggle to expand/collapse
        local aimbotToggle = aimbotSection:FindFirstChildWhichIsA("Frame")
        -- We'll use a simpler approach: check on update

        -- ========================================
        -- SILENT AIM MASTER SECTION
        -- ========================================
        local silentSection, setSilentOpen = C.MasterSection(page, "Silent Aim", 20, Config.Get("SilentAim_Enabled") or false)

        C.Toggle(silentSection, "Enabled", Config.Get("SilentAim_Enabled"), function(v) Config.Set("SilentAim_Enabled", v) end, 21)
        C.Toggle(silentSection, "Wall Check", Config.Get("SilentAim_WallCheck"), function(v) Config.Set("SilentAim_WallCheck", v) end, 22)
        C.Toggle(silentSection, "Team Check", Config.Get("SilentAim_TeamCheck"), function(v) Config.Set("SilentAim_TeamCheck", v) end, 23)
        C.Toggle(silentSection, "Use FOV", Config.Get("SilentAim_UseFOV"), function(v) Config.Set("SilentAim_UseFOV", v) end, 24)
        C.Slider(silentSection, "FOV Size", 50, 1000, Config.Get("SilentAim_FOVSize"), function(v) Config.Set("SilentAim_FOVSize", v) end, 25)
        C.Slider(silentSection, "Hitchance %", 0, 100, Config.Get("SilentAim_Hitchance"), function(v) Config.Set("SilentAim_Hitchance", v) end, 26)
        C.Dropdown(silentSection, "Hit Part", {"Head", "HumanoidRootPart"}, Config.Get("SilentAim_HitPart"), function(v) Config.Set("SilentAim_HitPart", v) end, 27)

        

        -- ========================================
        -- TRIGGERBOT MASTER SECTION
        -- ========================================
        local triggerSection, setTriggerOpen = C.MasterSection(page, "Triggerbot", 40, Config.Get("Triggerbot_Enabled") or false)

        C.Toggle(triggerSection, "Enabled", Config.Get("Triggerbot_Enabled"), function(v) Config.Set("Triggerbot_Enabled", v) end, 41)
        C.Toggle(triggerSection, "Team Check", Config.Get("Triggerbot_TeamCheck"), function(v) Config.Set("Triggerbot_TeamCheck", v) end, 42)
        C.Slider(triggerSection, "Chance %", 1, 100, Config.Get("Triggerbot_Chance"), function(v) Config.Set("Triggerbot_Chance", v) end, 43)
        C.Slider(triggerSection, "Delay", 0, 50, Config.Get("Triggerbot_Delay"), function(v) Config.Set("Triggerbot_Delay", v) end, 44)

        

        -- ========================================
        -- RAGEBOT MASTER SECTION
        -- ========================================
        local rageSection, setRageOpen = C.MasterSection(page, "Ragebot", 60, Config.Get("Ragebot_Enabled") or false)

        C.Toggle(rageSection, "Enabled", Config.Get("Ragebot_Enabled"), function(v) Config.Set("Ragebot_Enabled", v) end, 61)

       
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
