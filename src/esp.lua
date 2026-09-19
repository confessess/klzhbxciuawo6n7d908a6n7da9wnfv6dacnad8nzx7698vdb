-- ============================================================
-- RIVALS VISUALS - MAXIMUM COOL
-- Custom weather, player auras, screen FX, arm chams, ESP
-- ============================================================

local Visuals = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Settings (integrated with Config)
local Config

local function GetConfig(key, default)
    if Config and Config.Get then
        local val = Config.Get(key)
        if val ~= nil then return val end
    end
    return default
end

local function SetConfig(key, value)
    if Config and Config.Set then
        Config.Set(key, value)
    end
end

Visuals.Settings = {
    -- Master
    Enabled = false,

    -- ESP
    ESP = {
        Enabled = GetConfig("ESP_Enabled", false),
        TeamCheck = GetConfig("ESP_TeamCheck", true),
        MaxDistance = GetConfig("ESP_MaxDistance", 500),
        Chams = GetConfig("ESP_Highlight", false),
        ChamsFillColor = Color3.fromRGB(255, 60, 60),
        ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
        Boxes = GetConfig("ESP_Boxes", false),
        Names = GetConfig("ESP_Name", false),
        Health = GetConfig("ESP_HealthBar", false),
        Distance = GetConfig("ESP_Studs", false),
        Tracers = false,
    },

    -- Player Auras (High-Tech)
    Aura = {
        Enabled = false,
        Type = "Glow", -- Glow, Hexagon, DataStream, EnergyPulse, Hologram, ScanLines
        Color = Color3.fromRGB(0, 255, 255), -- Cyan
        SecondaryColor = Color3.fromRGB(255, 0, 255), -- Magenta
        Size = 5,
        Speed = 2,
        Intensity = 50,
        Transparency = 0.5,
    },

    -- Custom Chams
    ChamsStyle = {
        Enabled = false,
        Style = "Hologram", -- Hologram, Neon, Ghost, Cyber, None
        Color = Color3.fromRGB(0, 255, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        GlowIntensity = 2,
        ScanSpeed = 2,
    },

    -- Arm Chams
    ArmChams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 255),
        Material = Enum.Material.Neon,
        Transparency = 0.3,
    },

    -- Screen FX (removed - use World tab instead)

    -- Weather
    Weather = {
        Enabled = false,
        Type = "Rain",
        Intensity = 50,
        Color = Color3.fromRGB(200, 200, 255),
    },
}

-- Objects
local ESPObjects = {}
local AuraObjects = {}
local ScreenFXObjects = {}
local WeatherObjects = {}

-- ============================================================
-- ESP
-- ============================================================

local function IsTeammate(player)
    if not Visuals.Settings.ESP.TeamCheck then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return true end
    if player.TeamColor and LocalPlayer.TeamColor and player.TeamColor == LocalPlayer.TeamColor then return true end
    return false
end

local function CreateESP(player, character)
    if ESPObjects[character] then return end

    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not head or not humanoid or not root then return end

    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = Visuals.Settings.ESP.MaxDistance
    billboard.Size = UDim2.fromOffset(200, 60)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
    billboard.Parent = character

    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Parent = billboard

    -- Health bar (vertical, on left side)
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0, 5, 0, 40)
    healthBg.Position = UDim2.new(0, -10, 0.5, -20)
    healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthBg.BackgroundTransparency = 0.4
    healthBg.BorderSizePixel = 0
    healthBg.Parent = billboard

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.Position = UDim2.new(0, 0, 1, 0)
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg

    -- Distance (at bottom)
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 1, 2)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Font = Enum.Font.GothamMedium
    distLabel.TextSize = 11
    distLabel.Parent = billboard

    -- Highlight (Chams)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = Visuals.Settings.ESP.ChamsFillColor
    highlight.OutlineColor = Visuals.Settings.ESP.ChamsOutlineColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    ESPObjects[character] = {
        player = player,
        humanoid = humanoid,
        billboard = billboard,
        highlight = highlight,
        nameLabel = nameLabel,
        healthBg = healthBg,
        healthFill = healthFill,
        distLabel = distLabel,
    }
end

-- ============================================================
-- PLAYER AURAS
-- ============================================================

local function CreateAura(player, character)
    if AuraObjects[character] then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Create folder for aura effects
    local auraFolder = Instance.new("Folder")
    auraFolder.Name = "AuraEffects"
    auraFolder.Parent = character

    -- Create attachments on all body parts
    local attachments = {}
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local att = Instance.new("Attachment")
            att.Name = "AuraAtt"
            att.Parent = part
            table.insert(attachments, att)
        end
    end

    -- Main particles (will be configured based on type)
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "AuraParticles"
    particles.Rate = Visuals.Settings.Aura.Intensity
    particles.Lifetime = NumberRange.new(0.5, 1.5)
    particles.Speed = NumberRange.new(1, 3)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Color = ColorSequence.new(Visuals.Settings.Aura.Color)
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, Visuals.Settings.Aura.Transparency),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.LightEmission = 1
    particles.LightInfluence = 0
    particles.LockedToPart = true

    -- Add to all attachments
    for _, att in ipairs(attachments) do
        local clone = particles:Clone()
        clone.Parent = att
    end

    -- Point light
    local light = Instance.new("PointLight")
    light.Color = Visuals.Settings.Aura.Color
    light.Range = Visuals.Settings.Aura.Size * 2
    light.Brightness = 3
    light.Parent = root

    -- Energy pulse ring (for EnergyPulse type)
    local pulseRing = Instance.new("Part")
    pulseRing.Name = "PulseRing"
    pulseRing.Size = Vector3.new(1, 0.1, 1)
    pulseRing.Anchored = true
    pulseRing.CanCollide = false
    pulseRing.CanQuery = false
    pulseRing.CanTouch = false
    pulseRing.Transparency = 1
    pulseRing.Material = Enum.Material.Neon
    pulseRing.Shape = Enum.PartType.Cylinder
    pulseRing.Parent = auraFolder

    -- Scan lines part (for ScanLines type)
    local scanPart = Instance.new("Part")
    scanPart.Name = "ScanLines"
    scanPart.Size = Vector3.new(4, 0.05, 4)
    scanPart.Anchored = true
    scanPart.CanCollide = false
    scanPart.CanQuery = false
    scanPart.CanTouch = false
    scanPart.Transparency = 1
    scanPart.Material = Enum.Material.Neon
    scanPart.Parent = auraFolder

    AuraObjects[character] = {
        player = player,
        root = root,
        folder = auraFolder,
        attachments = attachments,
        particles = particles,
        light = light,
        pulseRing = pulseRing,
        scanPart = scanPart,
        pulseTime = 0,
        scanTime = 0,
    }
end

local function UpdateAuras()
    local S = Visuals.Settings.Aura

    for character, data in pairs(AuraObjects) do
        if not character or not character.Parent or not data.root or not data.root.Parent then
            if data.folder then data.folder:Destroy() end
            AuraObjects[character] = nil
        elseif S.Enabled then
            -- Update all particle clones
            for _, att in ipairs(data.attachments) do
                if att and att.Parent then
                    local particles = att:FindFirstChild("AuraParticles")
                    if particles then
                        particles.Color = ColorSequence.new(S.Color)
                        particles.LightEmission = 1

                        -- Configure based on type
                        if S.Type == "Glow" then
                            particles.Texture = "rbxassetid://567454904"
                            particles.Rate = S.Intensity
                            particles.Lifetime = NumberRange.new(0.5, 1)
                            particles.Speed = NumberRange.new(1, 3)
                            particles.Size = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, S.Size * 0.5),
                                NumberSequenceKeypoint.new(1, 0)
                            })
                            particles.Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, S.Transparency),
                                NumberSequenceKeypoint.new(1, 1)
                            })
                            particles.Rotation = NumberRange.new(0, 360)
                            particles.RotSpeed = NumberRange.new(-90, 90)

                        elseif S.Type == "Hexagon" then
                            particles.Texture = "rbxassetid://243728733" -- hexagon
                            particles.Rate = S.Intensity * 0.5
                            particles.Lifetime = NumberRange.new(1, 2)
                            particles.Speed = NumberRange.new(0.5, 1)
                            particles.Size = NumberSequence.new(S.Size * 0.3)
                            particles.Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, S.Transparency),
                                NumberSequenceKeypoint.new(0.8, S.Transparency),
                                NumberSequenceKeypoint.new(1, 1)
                            })
                            particles.Rotation = NumberRange.new(0, 360)
                            particles.RotSpeed = NumberRange.new(-45, 45)

                        elseif S.Type == "DataStream" then
                            particles.Texture = "rbxassetid://243728733"
                            particles.Rate = S.Intensity * 2
                            particles.Lifetime = NumberRange.new(0.3, 0.8)
                            particles.Speed = NumberRange.new(5, 10)
                            particles.Size = NumberSequence.new(0.2)
                            particles.Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1)
                            })
                            particles.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, S.Color),
                                ColorSequenceKeypoint.new(1, S.SecondaryColor)
                            })
                            particles.Rotation = NumberRange.new(0, 0)
                            particles.RotSpeed = NumberRange.new(0, 0)
                            particles.VelocitySpread = 0
                            particles.Speed = NumberRange.new(-10, -5) -- falling

                        elseif S.Type == "EnergyPulse" then
                            particles.Texture = "rbxassetid://567454904"
                            particles.Rate = S.Intensity * 0.3
                            particles.Lifetime = NumberRange.new(0.3, 0.5)
                            particles.Speed = NumberRange.new(0.5, 1)
                            particles.Size = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(0.5, S.Size * 0.3),
                                NumberSequenceKeypoint.new(1, 0)
                            })
                            particles.Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1)
                            })

                        elseif S.Type == "Hologram" then
                            particles.Texture = "rbxassetid://243728733"
                            particles.Rate = S.Intensity * 0.8
                            particles.Lifetime = NumberRange.new(0.5, 1)
                            particles.Speed = NumberRange.new(0.2, 0.5)
                            particles.Size = NumberSequence.new(S.Size * 0.2)
                            particles.Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, S.Transparency),
                                NumberSequenceKeypoint.new(0.9, S.Transparency),
                                NumberSequenceKeypoint.new(1, 1)
                            })
                            particles.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, S.Color),
                                ColorSequenceKeypoint.new(0.5, S.SecondaryColor),
                                ColorSequenceKeypoint.new(1, S.Color)
                            })
                            particles.Rotation = NumberRange.new(0, 360)
                            particles.RotSpeed = NumberRange.new(-180, 180)

                        elseif S.Type == "ScanLines" then
                            particles.Texture = "rbxassetid://243728733"
                            particles.Rate = S.Intensity
                            particles.Lifetime = NumberRange.new(0.5, 1)
                            particles.Speed = NumberRange.new(-2, -4)
                            particles.Size = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, S.Size * 0.1),
                                NumberSequenceKeypoint.new(1, S.Size * 0.1)
                            })
                            particles.Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(0.5, S.Transparency),
                                NumberSequenceKeypoint.new(1, 0)
                            })
                            particles.Rotation = NumberRange.new(0, 0)
                            particles.RotSpeed = NumberRange.new(0, 0)
                        end

                        particles.Enabled = true
                    end
                end
            end

            -- Update light
            data.light.Color = S.Color
            data.light.Range = S.Size * 2
            data.light.Enabled = true

            -- Energy pulse ring
            if S.Type == "EnergyPulse" then
                data.pulseTime = data.pulseTime + (S.Speed * 0.02)
                local pulseSize = (data.pulseTime % 1) * S.Size * 2
                local pulseAlpha = 1 - (data.pulseTime % 1)

                data.pulseRing.Size = Vector3.new(pulseSize, 0.1, pulseSize)
                data.pulseRing.CFrame = CFrame.new(data.root.Position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
                data.pulseRing.Transparency = pulseAlpha * 0.5
                data.pulseRing.Color = S.Color
                data.pulseRing.Material = Enum.Material.Neon
            else
                data.pulseRing.Transparency = 1
            end

            -- Scan lines
            if S.Type == "ScanLines" then
                data.scanTime = data.scanTime + (S.Speed * 0.01)
                local scanY = math.sin(data.scanTime) * 3
                data.scanPart.CFrame = CFrame.new(data.root.Position + Vector3.new(0, scanY, 0))
                data.scanPart.Size = Vector3.new(S.Size, 0.05, S.Size)
                data.scanPart.Transparency = 0.3
                data.scanPart.Color = S.Color
                data.scanPart.Material = Enum.Material.Neon
            else
                data.scanPart.Transparency = 1
            end
        else
            -- Disable all
            for _, att in ipairs(data.attachments) do
                if att and att.Parent then
                    local particles = att:FindFirstChild("AuraParticles")
                    if particles then particles.Enabled = false end
                end
            end
            data.light.Enabled = false
            data.pulseRing.Transparency = 1
            data.scanPart.Transparency = 1
        end
    end
end

-- ============================================================
-- ARM CHAMS
-- ============================================================

local function ApplyArmChams()
    if not Visuals.Settings.ArmChams.Enabled then return end

    local viewModel = workspace.Camera:FindFirstChild("ViewModel")
    if not viewModel then return end

    for _, part in ipairs(viewModel:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name:find("Arm") or part.Name:find("Hand")) then
            part.Color = Visuals.Settings.ArmChams.Color
            part.Material = Visuals.Settings.ArmChams.Material
            part.Transparency = Visuals.Settings.ArmChams.Transparency
        end
    end
end

-- ============================================================
-- SCREEN FX
-- ============================================================

-- Screen FX removed - use World tab for color correction and bloom

-- ============================================================
-- WEATHER
-- ============================================================

local function CreateWeather()
    if WeatherObjects.particles then return end

    -- Create attachment in workspace for particles
    local weatherPart = Instance.new("Part")
    weatherPart.Name = "WeatherEmitter"
    weatherPart.Size = Vector3.new(200, 1, 200)
    weatherPart.Position = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 50, 0) or Vector3.new(0, 50, 0)
    weatherPart.Anchored = true
    weatherPart.CanCollide = false
    weatherPart.CanQuery = false
    weatherPart.CanTouch = false
    weatherPart.Transparency = 1
    weatherPart.Parent = workspace

    local attachment = Instance.new("Attachment")
    attachment.Parent = weatherPart

    -- Weather particles
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "WeatherParticles"
    particles.Rate = Visuals.Settings.Weather.Intensity
    particles.Lifetime = NumberRange.new(3, 5)
    particles.Speed = NumberRange.new(30, 50)
    particles.Size = NumberSequence.new(0.2)
    particles.Color = ColorSequence.new(Visuals.Settings.Weather.Color)
    particles.Transparency = NumberSequence.new(0.3)
    particles.LightEmission = 0.5
    particles.Parent = attachment

    WeatherObjects.particles = particles
    WeatherObjects.part = weatherPart
    WeatherObjects.attachment = attachment
end

local function UpdateWeather()
    if not Visuals.Settings.Weather.Enabled then
        if WeatherObjects.particles then WeatherObjects.particles.Enabled = false end
        return
    end

    CreateWeather()

    -- Move weather with player
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        WeatherObjects.part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 50, 0)
    end

    local particles = WeatherObjects.particles
    particles.Enabled = true
    particles.Rate = Visuals.Settings.Weather.Intensity
    particles.Color = ColorSequence.new(Visuals.Settings.Weather.Color)

    -- Adjust based on type
    if Visuals.Settings.Weather.Type == "Rain" then
        particles.Speed = NumberRange.new(80, 120)
        particles.Size = NumberSequence.new(0.1)
        particles.Transparency = NumberSequence.new(0.2)
        particles.Lifetime = NumberRange.new(1, 2)
        particles.Rotation = NumberRange.new(0, 0)
        particles.RotSpeed = NumberRange.new(0, 0)
    elseif Visuals.Settings.Weather.Type == "Snow" then
        particles.Speed = NumberRange.new(10, 20)
        particles.Size = NumberSequence.new(0.3)
        particles.Transparency = NumberSequence.new(0.4)
        particles.Lifetime = NumberRange.new(4, 6)
        particles.Rotation = NumberRange.new(0, 360)
        particles.RotSpeed = NumberRange.new(-90, 90)
    elseif Visuals.Settings.Weather.Type == "Storm" then
        particles.Speed = NumberRange.new(120, 180)
        particles.Size = NumberSequence.new(0.15)
        particles.Transparency = NumberSequence.new(0.15)
        particles.Lifetime = NumberRange.new(0.5, 1)
        particles.Rotation = NumberRange.new(0, 0)
        particles.RotSpeed = NumberRange.new(0, 0)
    end
end

-- ============================================================
-- PLAYER MANAGEMENT
-- ============================================================

local function OnPlayerAdded(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Head", 5)
        character:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.3)

        -- Always create ESP objects, visibility controlled by settings
        CreateESP(player, character)
        CreateAura(player, character)
    end)

    if player.Character then
        task.spawn(function()
            player.Character:WaitForChild("Head", 5)
            task.wait(0.3)

            -- Always create ESP objects, visibility controlled by settings
            CreateESP(player, player.Character)
            CreateAura(player, player.Character)
        end)
    end

    player.CharacterRemoving:Connect(function(character)
        if ESPObjects[character] then
            if ESPObjects[character].billboard then ESPObjects[character].billboard:Destroy() end
            if ESPObjects[character].highlight then ESPObjects[character].highlight:Destroy() end
            ESPObjects[character] = nil
        end

        if AuraObjects[character] then
            if AuraObjects[character].aura then AuraObjects[character].aura:Destroy() end
            AuraObjects[character] = nil
        end
    end)
end

-- Init
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        OnPlayerAdded(player)
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        if ESPObjects[player.Character] then
            if ESPObjects[player.Character].billboard then ESPObjects[player.Character].billboard:Destroy() end
            ESPObjects[player.Character] = nil
        end
        if AuraObjects[player.Character] then
            if AuraObjects[player.Character].aura then AuraObjects[player.Character].aura:Destroy() end
            AuraObjects[player.Character] = nil
        end
    end
end)

-- ESP Update (called from main loop)
function Visuals.Update()
    local S = Visuals.Settings

    -- Update ESP objects
    for character, data in pairs(ESPObjects) do
        if not character or not character.Parent then
            if data.billboard then data.billboard:Destroy() end
            if data.highlight then data.highlight:Destroy() end
            ESPObjects[character] = nil
        elseif not S.ESP.Enabled then
            if data.billboard then data.billboard.Enabled = false end
            if data.highlight then data.highlight.Enabled = false end
        else
            local humanoid = data.humanoid
            if not humanoid or humanoid.Health <= 0 then
                if data.billboard then data.billboard.Enabled = false end
                if data.highlight then data.highlight.Enabled = false end
            else
                local isTeammate = IsTeammate(data.player)
                local distance = 0
                local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if localRoot and character:FindFirstChild("HumanoidRootPart") then
                    distance = (character.HumanoidRootPart.Position - localRoot.Position).Magnitude
                end
                local visible = not isTeammate and distance <= S.ESP.MaxDistance

                if data.billboard then
                    data.billboard.Enabled = visible
                    data.billboard.MaxDistance = S.ESP.MaxDistance
                end
                if data.highlight then
                    data.highlight.Enabled = visible and S.ESP.Chams
                    data.highlight.FillColor = S.ESP.ChamsFillColor
                    data.highlight.OutlineColor = S.ESP.ChamsOutlineColor
                end

                if visible then
                    -- Name
                    if data.nameLabel then
                        data.nameLabel.Visible = S.ESP.Names
                    end

                    -- Health bar (vertical, left side)
                    if data.healthBg then
                        data.healthBg.Visible = S.ESP.Health
                        local pct = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                        data.healthFill.Size = UDim2.new(1, 0, pct, 0)

                        -- Color based on health
                        if pct > 0.6 then
                            data.healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        elseif pct > 0.3 then
                            data.healthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                        else
                            data.healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        end
                    end

                    -- Distance (bottom)
                    if data.distLabel then
                        data.distLabel.Visible = S.ESP.Distance
                        data.distLabel.Text = string.format("%.0f studs", distance)
                    end
                end
            end
        end
    end

    -- Update other features
    UpdateAuras()
    ApplyArmChams()
    UpdateScreenFX()
    UpdateWeather()
end

-- Update loop
RunService.RenderStepped:Connect(function()
    Visuals.Update()
end)

-- ============================================================
-- GUI Registration & Init
-- ============================================================

local GUI, Core

function Visuals.Init(deps)
    print("[Visuals] Init called")
    GUI = deps.GUI
    Core = deps.Core
    Config = deps.Config

    if not GUI then 
        print("[Visuals] No GUI module")
        return 
    end
    print("[Visuals] GUI module found")

    local page = GUI.GetPage and GUI.GetPage("Visuals")
    if not page then 
        print("[Visuals] No Visuals page found!")
        print("[Visuals] Available pages:", GUI.Pages and "exists" or "nil")
        return 
    end
    print("[Visuals] Visuals page found")

    local C = GUI.Components
    local S = Visuals.Settings
    print("[Visuals] Got components, registering controls...")

    -- ESP Section
    C.Section(page, "ESP", 1)
    C.Toggle(page, "Enabled", S.ESP.Enabled, function(v) 
        S.ESP.Enabled = v 
        SetConfig("ESP_Enabled", v)
    end, 2)
    C.Toggle(page, "Chams", S.ESP.Chams, function(v)
        S.ESP.Chams = v
        SetConfig("ESP_Highlight", v)
    end, 3)
    C.Toggle(page, "Names", S.ESP.Names, function(v)
        S.ESP.Names = v
        SetConfig("ESP_Name", v)
    end, 4)
    C.Toggle(page, "Health", S.ESP.Health, function(v)
        S.ESP.Health = v
        SetConfig("ESP_HealthBar", v)
    end, 5)
    C.Toggle(page, "Distance", S.ESP.Distance, function(v)
        S.ESP.Distance = v
        SetConfig("ESP_Studs", v)
    end, 6)
    C.Toggle(page, "Team Check", S.ESP.TeamCheck, function(v)
        S.ESP.TeamCheck = v
        SetConfig("ESP_TeamCheck", v)
    end, 7)
    C.Slider(page, "Max Distance", 100, 2000, S.ESP.MaxDistance, function(v) 
        S.ESP.MaxDistance = v
        SetConfig("ESP_MaxDistance", v)
    end, 8)

    -- Player Aura Section (High-Tech)
    C.Section(page, "Player Aura", 10)
    C.Toggle(page, "Enabled", S.Aura.Enabled, function(v) S.Aura.Enabled = v end, 11)
    C.Dropdown(page, "Aura Type", {"Glow", "Hexagon", "DataStream", "EnergyPulse", "Hologram", "ScanLines"}, S.Aura.Type, function(v) S.Aura.Type = v end, 12)
    C.Slider(page, "Size", 1, 20, S.Aura.Size, function(v) S.Aura.Size = v end, 13)
    C.Slider(page, "Speed", 1, 10, S.Aura.Speed, function(v) S.Aura.Speed = v end, 14)
    C.Slider(page, "Intensity", 10, 200, S.Aura.Intensity, function(v) S.Aura.Intensity = v end, 15)

    -- Custom Chams Section
    C.Section(page, "Custom Chams", 20)
    C.Toggle(page, "Enabled", S.ChamsStyle.Enabled, function(v) S.ChamsStyle.Enabled = v end, 21)
    C.Dropdown(page, "Style", {"Hologram", "Neon", "Ghost", "Cyber"}, S.ChamsStyle.Style, function(v) S.ChamsStyle.Style = v end, 22)
    C.Slider(page, "Glow Intensity", 0, 10, S.ChamsStyle.GlowIntensity, function(v) S.ChamsStyle.GlowIntensity = v end, 23)
    C.Slider(page, "Scan Speed", 0, 10, S.ChamsStyle.ScanSpeed, function(v) S.ChamsStyle.ScanSpeed = v end, 24)

    -- Arm Chams Section
    C.Section(page, "Arm Chams", 30)
    C.Toggle(page, "Enabled", S.ArmChams.Enabled, function(v) S.ArmChams.Enabled = v end, 31)

    -- Weather Section
    C.Section(page, "Weather", 40)
    C.Toggle(page, "Enabled", false, function(v) S.Weather.Enabled = v end, 41)
    C.Dropdown(page, "Type", {"Rain", "Snow", "Storm"}, "Rain", function(v) S.Weather.Type = v end, 42)
    C.Slider(page, "Intensity", 10, 200, 50, function(v) S.Weather.Intensity = v end, 43)

    print("[Visuals] GUI registered")
end

function Visuals.Cleanup()
    for character, data in pairs(ESPObjects) do
        if data.billboard then data.billboard:Destroy() end
        if data.highlight then data.highlight:Destroy() end
    end
    table.clear(ESPObjects)

    for character, data in pairs(AuraObjects) do
        if data.attachment then data.attachment:Destroy() end
    end
    table.clear(AuraObjects)

    if WeatherObjects.folder then WeatherObjects.folder:Destroy() end
end

print("[Visuals] Module loaded - MAXIMUM COOL")

return Visuals