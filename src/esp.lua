-- ============================================================
-- Rivals Modular -- ESP (Fixed)
-- ============================================================

local ESP = {}

local Config, Utils, Core
local Players, LocalPlayer, Camera

local ESP_COLOR = Color3.fromRGB(255, 255, 255)
local GUI_WIDTH, GUI_HEIGHT = 220, 58
local BAR_WIDTH, BAR_HEIGHT = 120, 7

local tracerLines = {}
local boxDrawings = {}
local nameDrawings = {}
local healthDrawings = {}
local distDrawings = {}

local function removeESPObjects(character)
    if not character then return end
    for _, name in ipairs({"ESP_Highlight", "ESP_Billboard", "ESP_HealthBar", "HealthBackground", "HealthOutline"}) do
        local obj = character:FindFirstChild(name)
        if obj then pcall(function() obj:Destroy() end) end
    end
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
end

local function createBillboard(character, head)
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

    local outline = Instance.new("Frame")
    outline.Name = "HealthOutline"
    outline.Position = UDim2.fromOffset((GUI_WIDTH - BAR_WIDTH) / 2 - 1, 1)
    outline.Size = UDim2.fromOffset(BAR_WIDTH + 2, BAR_HEIGHT + 2)
    outline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outline.BackgroundTransparency = 0.15
    outline.BorderSizePixel = 0
    outline.ZIndex = 5
    outline.Parent = billboard
    makeCorner(outline, 4)

    local bg = Instance.new("Frame")
    bg.Name = "HealthBackground"
    bg.Position = UDim2.fromOffset(1, 1)
    bg.Size = UDim2.fromOffset(BAR_WIDTH, BAR_HEIGHT)
    bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bg.BorderSizePixel = 0
    bg.ZIndex = 6
    bg.Parent = outline
    makeCorner(bg, 3)

    local bar = Instance.new("Frame")
    bar.Name = "ESP_HealthBar"
    bar.Position = UDim2.fromOffset(0, 0)
    bar.Size = UDim2.fromOffset(BAR_WIDTH, BAR_HEIGHT)
    bar.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
    bar.BorderSizePixel = 0
    bar.ZIndex = 7
    bar.Parent = bg
    makeCorner(bar, 3)

    local info = Instance.new("TextLabel")
    info.Name = "ESP_Info"
    info.Position = UDim2.fromOffset(0, 14)
    info.Size = UDim2.fromOffset(GUI_WIDTH, 22)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.GothamBold
    info.TextSize = 14
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.TextStrokeTransparency = 0.45
    info.TextXAlignment = Enum.TextXAlignment.Center
    info.TextYAlignment = Enum.TextYAlignment.Center
    info.Text = ""
    info.ZIndex = 8
    info.Parent = billboard

    return billboard
end

-- Drawing helpers
local function getTracerLine(player)
    if tracerLines[player] then return tracerLines[player] end
    local line = Utils.NewLine(1.5, ESP_COLOR, 0)
    if line then tracerLines[player] = line end
    return line
end

local function removeTracerLine(player)
    local line = tracerLines[player]
    if line then
        tracerLines[player] = nil
        Utils.DestroyDrawing(line)
    end
end

local function hideAllTracers()
    for _, line in pairs(tracerLines) do
        pcall(function() line.Visible = false end)
    end
end

local function getBoxDrawings(player)
    if boxDrawings[player] then return boxDrawings[player] end
    local box = Utils.NewSquare(Vector2.new(50, 50), ESP_COLOR, 0)
    local fill = Utils.NewSquare(Vector2.new(50, 50), ESP_COLOR, 0.7)
    if box and fill then
        boxDrawings[player] = { box = box, fill = fill }
        return boxDrawings[player]
    end
    return nil
end

local function getNameDrawing(player)
    if nameDrawings[player] then return nameDrawings[player] end
    local name = Utils.NewText(13, Color3.fromRGB(255, 255, 255))
    if name then nameDrawings[player] = name end
    return name
end

local function getHealthDrawing(player)
    if healthDrawings[player] then return healthDrawings[player] end
    local bg = Utils.NewLine(3, Color3.fromRGB(0, 0, 0), 0.5)
    local bar = Utils.NewLine(3, Color3.fromRGB(0, 220, 80), 0)
    if bg and bar then
        healthDrawings[player] = { bg = bg, bar = bar }
        return healthDrawings[player]
    end
    return nil
end

local function getDistDrawing(player)
    if distDrawings[player] then return distDrawings[player] end
    local dist = Utils.NewText(11, Color3.fromRGB(200, 200, 200))
    if dist then distDrawings[player] = dist end
    return dist
end

local function removePlayerDrawings(player)
    local box = boxDrawings[player]
    if box then
        Utils.DestroyDrawing(box.box)
        Utils.DestroyDrawing(box.fill)
        boxDrawings[player] = nil
    end
    local name = nameDrawings[player]
    if name then
        Utils.DestroyDrawing(name)
        nameDrawings[player] = nil
    end
    local health = healthDrawings[player]
    if health then
        Utils.DestroyDrawing(health.bg)
        Utils.DestroyDrawing(health.bar)
        healthDrawings[player] = nil
    end
    local dist = distDrawings[player]
    if dist then
        Utils.DestroyDrawing(dist)
        distDrawings[player] = nil
    end
end

local function hideAllDrawings()
    for _, d in pairs(boxDrawings) do
        pcall(function() d.box.Visible = false; d.fill.Visible = false end)
    end
    for _, n in pairs(nameDrawings) do
        pcall(function() n.Visible = false end)
    end
    for _, h in pairs(healthDrawings) do
        pcall(function() h.bg.Visible = false; h.bar.Visible = false end)
    end
    for _, d in pairs(distDrawings) do
        pcall(function() d.Visible = false end)
    end
end

-- Safe character bounds
local function getCharacterBounds(character)
    if not Camera then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not root or not head then return nil end

    local rootPos, rootVis = Utils.WorldToScreen(root.Position)
    local headPos, headVis = Utils.WorldToScreen(head.Position + Vector3.new(0, 1.5, 0))
    if not rootVis and not headVis then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge

    for _, pos in ipairs({rootPos, headPos}) do
        if pos then
            if pos.X < minX then minX = pos.X end
            if pos.Y < minY then minY = pos.Y end
            if pos.X > maxX then maxX = pos.X end
            if pos.Y > maxY then maxY = pos.Y end
        end
    end

    -- Safety check
    if minX == math.huge or maxX == -math.huge then return nil end

    local height = maxY - minY
    local width = height * 0.5
    if height < 5 or width < 2 then return nil end

    return { x = minX - width / 2, y = minY, w = width, h = height }
end

-- Main Update
function ESP.Update(_dt)
    if not Config.Get("ESP_Enabled") or (Core and Core.MenuOpen) then
        hideAllDrawings()
        return
    end

    local localRoot = Utils.CharacterRoot(LocalPlayer)
    if not localRoot or not Camera then
        hideAllDrawings()
        return
    end

    local maxDist = Config.Get("ESP_MaxDistance") or 500
    local teamCheck = Config.Get("ESP_TeamCheck") ~= false
    local teamColor = Config.Get("ESP_TeamColor") == true

    -- Tracers
    if Config.Get("ESP_Tracer") then
        local vp = Camera.ViewportSize
        local origin = Vector2.new(vp.X / 2, vp.Y / 2)
        local seen = {}

        for _, player in ipairs(Utils.GetEnemies()) do
            local humanoid = Utils.CharacterHumanoid(player)
            local root = Utils.CharacterRoot(player)
            local head = Utils.CharacterHead(player)

            if humanoid and humanoid.Health > 0 and root and head then
                local okRP, rootPos = pcall(function() return root.Position end)
                if okRP and (rootPos - localRoot.Position).Magnitude <= maxDist then
                    local okHP, targetPos = pcall(function() return head.Position end)
                    if okHP then
                        local okSP, sp = pcall(function() return Camera:WorldToViewportPoint(targetPos) end)
                        if okSP and sp.Z > 0 then
                            local line = getTracerLine(player)
                            if line then
                                line.From = origin
                                line.To = Vector2.new(sp.X, sp.Y)
                                line.Visible = true
                                seen[player] = true
                            end
                        end
                    end
                end
            end
        end

        for player, line in pairs(tracerLines) do
            if not seen[player] then
                pcall(function() line.Visible = false end)
            end
        end
    else
        for _, line in pairs(tracerLines) do
            pcall(function() line.Visible = false end)
        end
    end

    -- Boxes, names, health, distance
    local seenPlayers = {}

    for _, player in ipairs(Utils.GetEnemies()) do
        local shouldSkip = false

        if teamCheck and Utils.IsTeammate(player) then
            removePlayerDrawings(player)
            shouldSkip = true
        end

        if not shouldSkip then
            local character = player.Character
            if not character then
                removePlayerDrawings(player)
                shouldSkip = true
            end
        end

        if not shouldSkip then
            local humanoid = Utils.CharacterHumanoid(player)
            local root = Utils.CharacterRoot(player)
            if not humanoid or humanoid.Health <= 0 or not root then
                removePlayerDrawings(player)
                shouldSkip = true
            end
        end

        if not shouldSkip then
            local okRP, rootPos = pcall(function() return Utils.CharacterRoot(player).Position end)
            if not okRP then
                removePlayerDrawings(player)
                shouldSkip = true
            else
                local distance = (rootPos - localRoot.Position).Magnitude
                if distance > maxDist then
                    removePlayerDrawings(player)
                    shouldSkip = true
                end
            end
        end

        if not shouldSkip then
            seenPlayers[player] = true
            local character = player.Character
            local bounds = getCharacterBounds(character)

            if not bounds then
                removePlayerDrawings(player)
            else
                local color = ESP_COLOR
                if teamColor then
                    local okTC, tc = pcall(function() return player.TeamColor end)
                    if okTC and tc then color = tc.Color end
                end

                -- Boxes
                if Config.Get("ESP_Boxes") then
                    local drawings = getBoxDrawings(player)
                    if drawings then
                        drawings.box.Size = Vector2.new(bounds.w, bounds.h)
                        drawings.box.Position = Vector2.new(bounds.x, bounds.y)
                        drawings.box.Color = Utils.HexToColor(Config.Get("ESP_BoxColor"))
                        drawings.box.Visible = true

                        if Config.Get("ESP_BoxFilled") then
                            drawings.fill.Size = Vector2.new(bounds.w, bounds.h)
                            drawings.fill.Position = Vector2.new(bounds.x, bounds.y)
                            drawings.fill.Color = Utils.HexToColor(Config.Get("ESP_BoxFillColor"))
                            drawings.fill.Transparency = Config.Get("ESP_BoxTransparency") or 0.7
                            drawings.fill.Visible = true
                        else
                            drawings.fill.Visible = false
                        end
                    end
                else
                    local drawings = boxDrawings[player]
                    if drawings then
                        drawings.box.Visible = false
                        drawings.fill.Visible = false
                    end
                end

                -- Name
                if Config.Get("ESP_Name") then
                    local nameDraw = getNameDrawing(player)
                    if nameDraw then
                        nameDraw.Text = player.Name
                        nameDraw.Position = Vector2.new(bounds.x + bounds.w / 2, bounds.y - 16)
                        nameDraw.Color = Color3.fromRGB(255, 255, 255)
                        nameDraw.Visible = true
                    end
                else
                    local nd = nameDrawings[player]
                    if nd then nd.Visible = false end
                end

                -- Health
                if Config.Get("ESP_HealthBar") then
                    local healthDraw = getHealthDrawing(player)
                    if healthDraw then
                        local humanoid = Utils.CharacterHumanoid(player)
                        if humanoid then
                            local pct = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                            local barHeight = bounds.h
                            local barX = bounds.x - 6
                            local barY = bounds.y

                            healthDraw.bg.From = Vector2.new(barX, barY)
                            healthDraw.bg.To = Vector2.new(barX, barY + barHeight)
                            healthDraw.bg.Visible = true

                            local fillHeight = barHeight * pct
                            local healthColor
                            if pct > 0.6 then healthColor = Color3.fromRGB(0, 220, 80)
                            elseif pct > 0.3 then healthColor = Color3.fromRGB(255, 190, 0)
                            else healthColor = Color3.fromRGB(235, 45, 45) end

                            healthDraw.bar.From = Vector2.new(barX, barY + barHeight - fillHeight)
                            healthDraw.bar.To = Vector2.new(barX, barY + barHeight)
                            healthDraw.bar.Color = healthColor
                            healthDraw.bar.Visible = true
                        end
                    end
                else
                    local hd = healthDrawings[player]
                    if hd then hd.bg.Visible = false; hd.bar.Visible = false end
                end

                -- Distance
                if Config.Get("ESP_Studs") then
                    local distDraw = getDistDrawing(player)
                    if distDraw then
                        local rootPos = Utils.CharacterRoot(player).Position
                        local distance = (rootPos - localRoot.Position).Magnitude
                        distDraw.Text = string.format("%.0f studs", distance)
                        distDraw.Position = Vector2.new(bounds.x + bounds.w / 2, bounds.y + bounds.h + 4)
                        distDraw.Color = Color3.fromRGB(200, 200, 200)
                        distDraw.Visible = true
                    end
                else
                    local dd = distDrawings[player]
                    if dd then dd.Visible = false end
                end
            end
        end
    end

    -- Cleanup
    for player, _ in pairs(boxDrawings) do
        if not seenPlayers[player] then removePlayerDrawings(player) end
    end
end

-- Slow refresh (billboards)
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

    local maxDist = Config.Get("ESP_MaxDistance") or 500

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if not character then
                -- skip
            elseif not Utils.IsEnemy(player) then
                removeESPObjects(character)
            else
                local humanoid = Utils.CharacterHumanoid(player)
                local root = Utils.CharacterRoot(player)
                local head = Utils.CharacterHead(player)

                if not humanoid or humanoid.Health <= 0 or not root or not head then
                    removeESPObjects(character)
                else
                    local okRP, rootPos = pcall(function() return root.Position end)
                    if not okRP or (rootPos - localRoot.Position).Magnitude > maxDist then
                        removeESPObjects(character)
                    else
                        -- Highlight
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

                        -- Billboard
                        local billboard = character:FindFirstChild("ESP_Billboard")
                        if not billboard or not billboard:IsA("BillboardGui") then
                            if billboard then billboard:Destroy() end
                            billboard = createBillboard(character, head)
                        end

                        billboard.Adornee = head
                        billboard.AlwaysOnTop = true
                        billboard.LightInfluence = 0
                        billboard.MaxDistance = maxDist
                        billboard.Size = UDim2.fromOffset(GUI_WIDTH, GUI_HEIGHT)
                        billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.7, 0)
                        billboard.Enabled = true

                        local outline = billboard:FindFirstChild("HealthOutline")
                        local bg = outline and outline:FindFirstChild("HealthBackground")
                        local bar = bg and bg:FindFirstChild("ESP_HealthBar")

                        if not outline or not bg or not bar then
                            billboard:Destroy()
                            billboard = createBillboard(character, head)
                            outline = billboard:FindFirstChild("HealthOutline")
                            bg = outline and outline:FindFirstChild("HealthBackground")
                            bar = bg and bg:FindFirstChild("ESP_HealthBar")
                        end

                        if bar then
                            outline.Visible = Config.Get("ESP_HealthBar") ~= false
                            local pct = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                            bar.Size = UDim2.fromOffset(math.max(0, math.floor(BAR_WIDTH * pct)), BAR_HEIGHT)

                            if pct > 0.6 then bar.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
                            elseif pct > 0.3 then bar.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
                            else bar.BackgroundColor3 = Color3.fromRGB(235, 45, 45) end

                            local info = billboard:FindFirstChild("ESP_Info")
                            if info then
                                local showName = Config.Get("ESP_Name")
                                local showStuds = Config.Get("ESP_Studs")
                                local distance = (rootPos - localRoot.Position).Magnitude

                                if showName and showStuds then
                                    info.Text = player.Name .. " | " .. string.format("%.1f studs", distance)
                                    info.Visible = true
                                elseif showName then
                                    info.Text = player.Name
                                    info.Visible = true
                                elseif showStuds then
                                    info.Text = string.format("%.1f studs", distance)
                                    info.Visible = true
                                else
                                    info.Text = ""
                                    info.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Lifecycle
function ESP.Init(deps)
    Config = deps.Config
    Utils = deps.Utils
    Core = deps.Core
    Players = Utils.Players
    LocalPlayer = Utils.LocalPlayer
    Camera = Utils.Camera

    Players.PlayerRemoving:Connect(function(player)
        removeTracerLine(player)
        removePlayerDrawings(player)
    end)

    print("[rivals] ESP module initialized.")
end

function ESP.Cleanup()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            removeESPObjects(player.Character)
        end
        removeTracerLine(player)
        removePlayerDrawings(player)
    end
    hideAllTracers()
    hideAllDrawings()
end

return ESP