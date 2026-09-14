-- ============================================================
-- Rivals Modular -- ESP (No Drawing API - No Crashes)
-- Uses only BillboardGuis and Highlights
-- ============================================================

local ESP = {}

local Config, Utils, Core
local Players, LocalPlayer, Camera

local ESP_COLOR = Color3.fromRGB(255, 255, 255)
local GUI_WIDTH, GUI_HEIGHT = 220, 58
local BAR_WIDTH, BAR_HEIGHT = 120, 7

local function removeESPObjects(character)
    if not character then return end
    for _, name in ipairs({"ESP_Highlight", "ESP_Billboard"}) do
        local obj = character:FindFirstChild(name)
        if obj then pcall(function() obj:Destroy() end) end
    end
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
end

local function createESPBillboard(character, head)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = Config.Get("ESP_MaxDistance") or 500
    billboard.Size = UDim2.fromOffset(GUI_WIDTH, GUI_HEIGHT)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.7, 0)
    billboard.ClipsDescendants = false
    billboard.Parent = character

    local name = Instance.new("TextLabel")
    name.Name = "ESP_Name"
    name.Position = UDim2.fromOffset(0, 0)
    name.Size = UDim2.fromOffset(GUI_WIDTH, 20)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextStrokeTransparency = 0.3
    name.TextXAlignment = Enum.TextXAlignment.Center
    name.TextYAlignment = Enum.TextYAlignment.Center
    name.Text = ""
    name.ZIndex = 10
    name.Parent = billboard

    local healthBg = Instance.new("Frame")
    healthBg.Name = "ESP_HealthBg"
    healthBg.Position = UDim2.fromOffset((GUI_WIDTH - BAR_WIDTH) / 2, 24)
    healthBg.Size = UDim2.fromOffset(BAR_WIDTH + 2, BAR_HEIGHT + 2)
    healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthBg.BackgroundTransparency = 0.3
    healthBg.BorderSizePixel = 0
    healthBg.ZIndex = 10
    healthBg.Parent = billboard
    makeCorner(healthBg, 4)

    local healthBar = Instance.new("Frame")
    healthBar.Name = "ESP_HealthBar"
    healthBar.Position = UDim2.fromOffset(1, 1)
    healthBar.Size = UDim2.fromOffset(BAR_WIDTH, BAR_HEIGHT)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
    healthBar.BorderSizePixel = 0
    healthBar.ZIndex = 11
    healthBar.Parent = healthBg
    makeCorner(healthBar, 3)

    local dist = Instance.new("TextLabel")
    dist.Name = "ESP_Dist"
    dist.Position = UDim2.fromOffset(0, 36)
    dist.Size = UDim2.fromOffset(GUI_WIDTH, 16)
    dist.BackgroundTransparency = 1
    dist.Font = Enum.Font.GothamMedium
    dist.TextSize = 12
    dist.TextColor3 = Color3.fromRGB(200, 200, 200)
    dist.TextStrokeTransparency = 0.5
    dist.TextXAlignment = Enum.TextXAlignment.Center
    dist.TextYAlignment = Enum.TextYAlignment.Center
    dist.Text = ""
    dist.ZIndex = 10
    dist.Parent = billboard

    return billboard
end

local function updateESPForPlayer(player, character, humanoid, root, head, localRoot)
    local maxDist = Config.Get("ESP_MaxDistance") or 500
    local okRP, rootPos = pcall(function() return root.Position end)
    if not okRP then return end

    local distance = (rootPos - localRoot.Position).Magnitude
    if distance > maxDist then
        removeESPObjects(character)
        return
    end

    local highlight = character:FindFirstChild("ESP_Highlight")
    if Config.Get("ESP_Highlight") then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = character
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
        end
        highlight.FillColor = ESP_COLOR
        highlight.FillTransparency = Config.Get("ESP_BoxTransparency") or 0.5
        highlight.OutlineColor = ESP_COLOR
        highlight.OutlineTransparency = 0
        highlight.Enabled = true
    elseif highlight then
        highlight:Destroy()
    end

    local billboard = character:FindFirstChild("ESP_Billboard")
    if not billboard or not billboard:IsA("BillboardGui") then
        if billboard then billboard:Destroy() end
        billboard = createESPBillboard(character, head)
    end

    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = maxDist
    billboard.Enabled = true

    local nameLbl = billboard:FindFirstChild("ESP_Name")
    if nameLbl then
        if Config.Get("ESP_Name") then
            nameLbl.Text = player.Name
            nameLbl.Visible = true
        else
            nameLbl.Visible = false
        end
    end

    local healthBg = billboard:FindFirstChild("ESP_HealthBg")
    local healthBar = healthBg and healthBg:FindFirstChild("ESP_HealthBar")
    if healthBg and healthBar then
        if Config.Get("ESP_HealthBar") then
            healthBg.Visible = true
            local pct = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
            healthBar.Size = UDim2.fromOffset(math.max(0, math.floor(BAR_WIDTH * pct)), BAR_HEIGHT)
            if pct > 0.6 then healthBar.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
            elseif pct > 0.3 then healthBar.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
            else healthBar.BackgroundColor3 = Color3.fromRGB(235, 45, 45) end
        else
            healthBg.Visible = false
        end
    end

    local distLbl = billboard:FindFirstChild("ESP_Dist")
    if distLbl then
        if Config.Get("ESP_Studs") then
            distLbl.Text = string.format("%.0f studs", distance)
            distLbl.Visible = true
        else
            distLbl.Visible = false
        end
    end
end

function ESP.Update(_dt) end

function ESP.Refresh()
    if not Config.Get("ESP_Enabled") then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                removeESPObjects(player.Character)
            end
        end
        return
    end

    local localRoot = Utils.CharacterRoot(LocalPlayer)
    if not localRoot or not Camera then return end

    local teamCheck = Config.Get("ESP_TeamCheck") ~= false

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if not character then
                -- skip
            elseif teamCheck and Utils.IsTeammate(player) then
                removeESPObjects(character)
            else
                local humanoid = Utils.CharacterHumanoid(player)
                local root = Utils.CharacterRoot(player)
                local head = Utils.CharacterHead(player)
                if not humanoid or humanoid.Health <= 0 or not root or not head then
                    removeESPObjects(character)
                else
                    updateESPForPlayer(player, character, humanoid, root, head, localRoot)
                end
            end
        end
    end
end

function ESP.Init(deps)
    Config = deps.Config
    Utils = deps.Utils
    Core = deps.Core
    Players = Utils.Players
    LocalPlayer = Utils.LocalPlayer
    Camera = Utils.Camera

    Players.PlayerRemoving:Connect(function(player)
        if player.Character then removeESPObjects(player.Character) end
    end)

    print("[rivals] ESP module initialized (BillboardGui mode).")
end

function ESP.Cleanup()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            removeESPObjects(player.Character)
        end
    end
end

return ESP
