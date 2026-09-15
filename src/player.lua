-- ============================================================
-- Rivals Modular -- Player
-- Fly, walkspeed, noclip, infinite jump
-- ============================================================

local Player = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, RunService, UserInputService, Camera

-- State
local flyConn = nil
local flyBodyVelocity = nil
local walkSpeedConn = nil
local noclipConn = nil

-- ------------------------------------------------------------
-- Fly
-- ------------------------------------------------------------

local function stopFly()
    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
end

local function startFly()
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    stopFly()

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    flyBodyVelocity.Parent = root

    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.Get("Fly_Enabled") then
            stopFly()
            return
        end

        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir = dir + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir = dir - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir = dir - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir = dir + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Camera.CFrame.UpVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir = dir - Camera.CFrame.UpVector
        end

        local speed = Config.Get("Fly_Speed") or 16
        if flyBodyVelocity then
            flyBodyVelocity.Velocity = dir * speed
        end
    end)
end

-- ------------------------------------------------------------
-- WalkSpeed
-- ------------------------------------------------------------

local function startWalkSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    stopWalkSpeed()

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(100000, 0, 100000)
    bv.Parent = root

    walkSpeedConn = RunService.RenderStepped:Connect(function()
        if not Config.Get("WalkSpeed_Enabled") then
            stopWalkSpeed()
            return
        end

        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir = dir + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir = dir - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir = dir - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir = dir + Camera.CFrame.RightVector
        end

        bv.Velocity = dir * (Config.Get("WalkSpeed_Value") or 16)
    end)
end

function stopWalkSpeed()
    if walkSpeedConn then
        walkSpeedConn:Disconnect()
        walkSpeedConn = nil
    end
    local character = LocalPlayer.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChildOfClass("BodyVelocity")
            if bv then bv:Destroy() end
        end
    end
end

-- ------------------------------------------------------------
-- Noclip
-- ------------------------------------------------------------

local function startNoclip()
    stopNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not Config.Get("Noclip_Enabled") then
            stopNoclip()
            return
        end
        local character = LocalPlayer.Character
        if not character then return end
        for _, desc in pairs(character:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.CanCollide = false
            end
        end
    end)
end

function stopNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    local character = LocalPlayer.Character
    if character then
        for _, desc in pairs(character:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.CanCollide = true
            end
        end
    end
end

-- ------------------------------------------------------------
-- Infinite Jump
-- ------------------------------------------------------------

local function onJumpRequest()
    if not Config.Get("InfJump_Enabled") then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ------------------------------------------------------------
-- Update
-- ------------------------------------------------------------

function Player.Update(_dt)
    -- Event-driven, no per-frame work needed
end

-- ------------------------------------------------------------
-- Lifecycle
-- ------------------------------------------------------------

function Player.Init(deps)
    Config         = deps.Config
    Utils          = deps.Utils
    GUI            = deps.GUI
    Core           = deps.Core
    Players        = Utils.Players
    LocalPlayer    = Utils.LocalPlayer
    RunService     = Utils.RunService
    UserInputService = Utils.UserInputService
    Camera         = Utils.Camera

    -- Jump request
    UserInputService.JumpRequest:Connect(onJumpRequest)

    -- Character respawn
    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if Config.Get("Fly_Enabled") then
            startFly()
        end
        if Config.Get("Noclip_Enabled") then
            startNoclip()
        end
    end)

    -- Register GUI
    -- Register GUI (Misc tab)
    local page = GUI.GetPage and GUI.GetPage("Misc")
    if page then
        GUI.Components.Section(page, "Movement", 1)
        GUI.Components.Toggle(page, "Fly", Config.Get("Fly_Enabled"), function(v) 
            Config.Set("Fly_Enabled", v)
            if v then startFly() else stopFly() end
        end, 2)
        GUI.Components.Slider(page, "Fly Speed", 1, 100, Config.Get("Fly_Speed"), function(v) Config.Set("Fly_Speed", v) end, 3)
        GUI.Components.Toggle(page, "WalkSpeed", Config.Get("WalkSpeed_Enabled"), function(v)
            Config.Set("WalkSpeed_Enabled", v)
            if v then startWalkSpeed() else stopWalkSpeed() end
        end, 4)
        GUI.Components.Slider(page, "WalkSpeed Value", 1, 100, Config.Get("WalkSpeed_Value"), function(v) Config.Set("WalkSpeed_Value", v) end, 5)
        GUI.Components.Toggle(page, "Infinite Jump", Config.Get("InfJump_Enabled"), function(v) Config.Set("InfJump_Enabled", v) end, 6)
        GUI.Components.Toggle(page, "Noclip", Config.Get("Noclip_Enabled"), function(v)
            Config.Set("Noclip_Enabled", v)
            if v then startNoclip() else stopNoclip() end
        end, 7)
    end

    print("[rivals] Player module initialized.")
end

function Player.Cleanup()
    stopFly()
    stopWalkSpeed()
    stopNoclip()
end

return Player