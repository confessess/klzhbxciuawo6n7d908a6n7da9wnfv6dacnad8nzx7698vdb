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

-- Settings
Visuals.Settings = {
    -- Master
    Enabled = true,

    -- ESP
    ESP = {
        Enabled = false,
        TeamCheck = true,
        MaxDistance = 500,
        Chams = true,
        ChamsFillColor = Color3.fromRGB(255, 60, 60),
        ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
        Boxes = false,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = false,
    },

    -- Player Auras
    Aura = {
        Enabled = false,
        Color = Color3.fromRGB(138, 43, 226), -- Purple
        Size = 5,
        Transparency = 0.7,
        Speed = 2,
    },

    -- Arm Chams
    ArmChams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 255), -- Magenta
        Material = Enum.Material.Neon,
        Transparency = 0.3,
    },

    -- Screen FX
    ScreenFX = {
        Enabled = false,
        Vignette = true,
        VignetteColor = Color3.fromRGB(0, 0, 0),
        VignetteTransparency = 0.3,
        ColorCorrection = true,
        TintColor = Color3.fromRGB(255, 200, 150),
        Saturation = 0.2,
        Contrast = 0.1,
        Bloom = true,
        BloomIntensity = 0.5,
        BloomSize = 24,
        BloomThreshold = 0.8,
    },

    -- Weather
    Weather = {
        Enabled = false,
        Type = "Rain", -- Rain, Snow, Fog, Storm
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

    -- Health bar
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0, 80, 0, 5)
    healthBg.Position = UDim2.new(0.5, -40, 0, 20)
    healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthBg.BackgroundTransparency = 0.4
    healthBg.BorderSizePixel = 0
    healthBg.Parent = billboard

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBg

    -- Distance
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 28)
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

    -- Aura ring
    local aura = Instance.new("Part")
    aura.Name = "Aura"
    aura.Size = Vector3.new(1, 0.1, 1)
    aura.Anchored = true
    aura.CanCollide = false
    aura.Transparency = Visuals.Settings.Aura.Transparency
    aura.Material = Enum.Material.Neon
    aura.Color = Visuals.Settings.Aura.Color
    aura.Shape = Enum.PartType.Cylinder
    aura.Parent = workspace

    -- Point light
    local light = Instance.new("PointLight")
    light.Color = Visuals.Settings.Aura.Color
    light.Range = Visuals.Settings.Aura.Size
    light.Brightness = 2
    light.Parent = aura

    AuraObjects[character] = {
        player = player,
        root = root,
        aura = aura,
        light = light,
        rotation = 0,
    }
end

local function UpdateAuras()
    for character, data in pairs(AuraObjects) do
        if not character or not character.Parent then
            if data.aura then data.aura:Destroy() end
            AuraObjects[character] = nil
        elseif Visuals.Settings.Aura.Enabled then
            data.aura.Transparency = Visuals.Settings.Aura.Transparency
            data.aura.Color = Visuals.Settings.Aura.Color
            data.light.Color = Visuals.Settings.Aura.Color
            data.light.Range = Visuals.Settings.Aura.Size

            -- Rotate aura
            data.rotation = data.rotation + Visuals.Settings.Aura.Speed
            data.aura.CFrame = CFrame.new(data.root.Position) * CFrame.Angles(0, math.rad(data.rotation), 0)
        else
            data.aura.Transparency = 1
            data.light.Enabled = false
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

local function CreateScreenFX()
    if ScreenFXObjects.vignette then return end

    -- Vignette
    local vignette = Instance.new("ImageLabel")
    vignette.Name = "Vignette"
    vignette.Size = UDim2.fromScale(1, 1)
    vignette.BackgroundTransparency = 1
    vignette.Image = "rbxassetid://4576475446"
    vignette.ImageColor3 = Visuals.Settings.ScreenFX.VignetteColor
    vignette.ImageTransparency = Visuals.Settings.ScreenFX.VignetteTransparency
    vignette.Parent = LocalPlayer.PlayerGui:FindFirstChild("VisualsGUI") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    ScreenFXObjects.vignette = vignette

    -- Color correction
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Parent = Lighting
    ScreenFXObjects.colorCorrection = cc

    -- Bloom
    local bloom = Instance.new("BloomEffect")
    bloom.Parent = Lighting
    ScreenFXObjects.bloom = bloom
end

local function UpdateScreenFX()
    if not Visuals.Settings.ScreenFX.Enabled then
        if ScreenFXObjects.vignette then ScreenFXObjects.vignette.Visible = false end
        if ScreenFXObjects.colorCorrection then ScreenFXObjects.colorCorrection.Enabled = false end
        if ScreenFXObjects.bloom then ScreenFXObjects.bloom.Enabled = false end
        return
    end

    CreateScreenFX()

    -- Vignette
    if ScreenFXObjects.vignette then
        ScreenFXObjects.vignette.Visible = Visuals.Settings.ScreenFX.Vignette
        ScreenFXObjects.vignette.ImageColor3 = Visuals.Settings.ScreenFX.VignetteColor
        ScreenFXObjects.vignette.ImageTransparency = Visuals.Settings.ScreenFX.VignetteTransparency
    end

    -- Color correction
    if ScreenFXObjects.colorCorrection then
        ScreenFXObjects.colorCorrection.Enabled = Visuals.Settings.ScreenFX.ColorCorrection
        ScreenFXObjects.colorCorrection.TintColor = Visuals.Settings.ScreenFX.TintColor
        ScreenFXObjects.colorCorrection.Saturation = Visuals.Settings.ScreenFX.Saturation
        ScreenFXObjects.colorCorrection.Contrast = Visuals.Settings.ScreenFX.Contrast
    end

    -- Bloom
    if ScreenFXObjects.bloom then
        ScreenFXObjects.bloom.Enabled = Visuals.Settings.ScreenFX.Bloom
        ScreenFXObjects.bloom.Intensity = Visuals.Settings.ScreenFX.BloomIntensity
        ScreenFXObjects.bloom.Size = Visuals.Settings.ScreenFX.BloomSize
        ScreenFXObjects.bloom.Threshold = Visuals.Settings.ScreenFX.BloomThreshold
    end
end

-- ============================================================
-- WEATHER
-- ============================================================

local function CreateWeather()
    if WeatherObjects.particles then return end

    local weatherFolder = Instance.new("Folder")
    weatherFolder.Name = "Weather"
    weatherFolder.Parent = workspace

    -- Rain/Snow particles
    local particles = Instance.new("ParticleEmitter")
    particles.Rate = Visuals.Settings.Weather.Intensity
    particles.Lifetime = NumberRange.new(2, 4)
    particles.Speed = NumberRange.new(50, 100)
    particles.Size = NumberSequence.new(0.1)
    particles.Color = ColorSequence.new(Visuals.Settings.Weather.Color)
    particles.Transparency = NumberSequence.new(0.3)
    particles.Parent = weatherFolder

    WeatherObjects.particles = particles
    WeatherObjects.folder = weatherFolder
end

local function UpdateWeather()
    if not Visuals.Settings.Weather.Enabled then
        if WeatherObjects.particles then WeatherObjects.particles.Enabled = false end
        return
    end

    CreateWeather()

    local particles = WeatherObjects.particles
    particles.Enabled = true
    particles.Rate = Visuals.Settings.Weather.Intensity
    particles.Color = ColorSequence.new(Visuals.Settings.Weather.Color)

    -- Adjust based on type
    if Visuals.Settings.Weather.Type == "Rain" then
        particles.Speed = NumberRange.new(100, 150)
        particles.Size = NumberSequence.new(0.1)
        particles.Transparency = NumberSequence.new(0.3)
    elseif Visuals.Settings.Weather.Type == "Snow" then
        particles.Speed = NumberRange.new(10, 30)
        particles.Size = NumberSequence.new(0.3)
        particles.Transparency = NumberSequence.new(0.5)
    elseif Visuals.Settings.Weather.Type == "Storm" then
        particles.Speed = NumberRange.new(150, 200)
        particles.Size = NumberSequence.new(0.2)
        particles.Transparency = NumberSequence.new(0.2)
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

        if Visuals.Settings.ESP.Enabled then
            CreateESP(player, character)
        end

        if Visuals.Settings.Aura.Enabled then
            CreateAura(player, character)
        end
    end)

    if player.Character then
        task.spawn(function()
            player.Character:WaitForChild("Head", 5)
            task.wait(0.3)

            if Visuals.Settings.ESP.Enabled then
                CreateESP(player, player.Character)
            end

            if Visuals.Settings.Aura.Enabled then
                CreateAura(player, player.Character)
            end
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
    local ok, err = pcall(function()
        -- Update ESP objects
        for character, data in pairs(ESPObjects) do
            if not character or not character.Parent then
                if data.billboard then data.billboard:Destroy() end
                if data.highlight then data.highlight:Destroy() end
                ESPObjects[character] = nil
            elseif not Visuals.Settings.ESP.Enabled then
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
                    local visible = not isTeammate and distance <= Visuals.Settings.ESP.MaxDistance

                    if data.billboard then
                        data.billboard.Enabled = visible
                        data.billboard.MaxDistance = Visuals.Settings.ESP.MaxDistance
                    end
                    if data.highlight then
                        data.highlight.Enabled = visible and Visuals.Settings.ESP.Chams
                    end

                    if visible then
                        if data.nameLabel then
                            data.nameLabel.Visible = Visuals.Settings.ESP.Names
                        end
                        if data.healthBg then
                            data.healthBg.Visible = Visuals.Settings.ESP.Health
                            local pct = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                            data.healthFill.Size = UDim2.new(pct, 0, 1, 0)
                        end
                        if data.distLabel then
                            data.distLabel.Visible = Visuals.Settings.ESP.Distance
                            data.distLabel.Text = string.format("%.0f studs", distance)
                        end
                    end
                end
            end
        end

        UpdateAuras()
        ApplyArmChams()
        UpdateScreenFX()
        UpdateWeather()
    end)
    if not ok then
        warn("[Visuals] Update error: " .. tostring(err))
    end
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
    GUI = deps.GUI
    Core = deps.Core

    if not GUI then 
        print("[Visuals] No GUI module")
        return 
    end

    local page = GUI.GetPage and GUI.GetPage("Visuals")
    if not page then 
        print("[Visuals] No Visuals page")
        return 
    end

    local C = GUI.Components
    local S = Visuals.Settings

    -- ESP Section
    C.Section(page, "ESP", 1)
    C.Toggle(page, "Enabled", false, function(v) S.ESP.Enabled = v end, 2)
    C.Toggle(page, "Chams", true, function(v) S.ESP.Chams = v end, 3)
    C.Toggle(page, "Names", true, function(v) S.ESP.Names = v end, 4)
    C.Toggle(page, "Health", true, function(v) S.ESP.Health = v end, 5)
    C.Toggle(page, "Distance", true, function(v) S.ESP.Distance = v end, 6)
    C.Toggle(page, "Team Check", true, function(v) S.ESP.TeamCheck = v end, 7)
    C.Slider(page, "Max Distance", 100, 2000, 500, function(v) S.ESP.MaxDistance = v end, 8)

    -- Player Aura Section
    C.Section(page, "Player Aura", 10)
    C.Toggle(page, "Enabled", false, function(v) S.Aura.Enabled = v end, 11)
    C.Slider(page, "Size", 1, 20, 5, function(v) S.Aura.Size = v end, 12)
    C.Slider(page, "Speed", 1, 10, 2, function(v) S.Aura.Speed = v end, 13)

    -- Arm Chams Section
    C.Section(page, "Arm Chams", 20)
    C.Toggle(page, "Enabled", false, function(v) S.ArmChams.Enabled = v end, 21)

    -- Screen FX Section
    C.Section(page, "Screen FX", 30)
    C.Toggle(page, "Enabled", false, function(v) S.ScreenFX.Enabled = v end, 31)
    C.Toggle(page, "Vignette", true, function(v) S.ScreenFX.Vignette = v end, 32)
    C.Toggle(page, "Color Correction", true, function(v) S.ScreenFX.ColorCorrection = v end, 33)
    C.Toggle(page, "Bloom", true, function(v) S.ScreenFX.Bloom = v end, 34)

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
        if data.aura then data.aura:Destroy() end
    end
    table.clear(AuraObjects)

    if ScreenFXObjects.vignette then ScreenFXObjects.vignette:Destroy() end
    if ScreenFXObjects.colorCorrection then ScreenFXObjects.colorCorrection:Destroy() end
    if ScreenFXObjects.bloom then ScreenFXObjects.bloom:Destroy() end
    if WeatherObjects.folder then WeatherObjects.folder:Destroy() end
end

print("[Visuals] Module loaded - MAXIMUM COOL")

return Visuals