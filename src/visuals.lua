-- ============================================================
-- RIVALS VISUALS - COMPLETE (ESP + Auras + Chams + Weather)
-- Drawing API ESP with Player Auras, Chams, and Weather
-- ============================================================

local Visuals = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Config, GUI, Core, Utils

-- ═════════════════════════════════════════════════════════════════════════════
-- DRAWING LIFECYCLE (from Utils)
-- ═════════════════════════════════════════════════════════════════════════════
local ESPDrawingObjects = {}
local ESPRenderConnection = nil
local ESPPlayerAddedConnection = nil
local ESPPlayerRemovingConnection = nil
local ESPCharacterAddedConnections = {}

local MakeDrawing = function(type, props) return Utils.MakeDrawing(type, props) end
local SetDrawing = function(obj, key, value) Utils.SetDrawing(obj, key, value) end
local RemoveDrawing = function(obj) Utils.RemoveDrawing(obj) end
local W2S = function(position) return Utils.W2S(position) end

-- ═════════════════════════════════════════════════════════════════════════════
-- SETTINGS
-- ═════════════════════════════════════════════════════════════════════════════
Visuals.Settings = {
    ESP = {
        Enabled = false,
        Boxes = false,
        Box3D = false,
        Names = false,
        Distance = false,
        Health = false,
        Skeleton = false,
        Chams = false,
        HeadDot = false,
        WeaponNames = false,
        TeamCheck = true,
        MaxDistance = 500,
        BoxThickness = 1,
        HeadDotSize = 1,
        HeadDotThickness = 1,
        Colors = {
            Box = Color3.fromRGB(255, 105, 180),
            Name = Color3.fromRGB(255, 255, 255),
            Distance = Color3.fromRGB(200, 200, 200),
            Health = Color3.fromRGB(0, 255, 100),
            Skeleton = Color3.fromRGB(255, 255, 255),
            HeadDot = Color3.fromRGB(255, 255, 255),
            ChamsFill = Color3.fromRGB(255, 60, 60),
            ChamsOutline = Color3.fromRGB(255, 255, 255),
        }
    },

    Aura = {
        Enabled = false,
        Type = "Glow",
        Color = Color3.fromRGB(0, 255, 255),
        SecondaryColor = Color3.fromRGB(255, 0, 255),
        Size = 5,
        Speed = 2,
        Intensity = 50,
        Transparency = 0.5,
    },

    PlayerChams = {
        Enabled = false,
        Material = "ForceField",
        Color = Color3.fromRGB(0, 255, 255),
        SecondaryColor = Color3.fromRGB(255, 0, 255),
        Transparency = 0.3,
        Glow = true,
        Rainbow = false,
        Pulse = false,
    },

    CustomChams = {
        Enabled = false,
        Style = "Hologram",
        Color = Color3.fromRGB(0, 255, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        GlowIntensity = 2,
        ScanSpeed = 2,
    },

    ArmChams = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 255),
        Material = Enum.Material.Neon,
        Transparency = 0.3,
    },

    Weather = {
        Enabled = false,
        Type = "Rain",
        Intensity = 50,
        Color = Color3.fromRGB(200, 200, 255),
    },
}

-- ═════════════════════════════════════════════════════════════════════════════
-- ESP UTILITIES
-- ═════════════════════════════════════════════════════════════════════════════
local function GetBoxData(character)
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    if not root then return nil end
    local s, extents = pcall(function() return character:GetExtentsSize() end)
    if not s or not extents then return nil end
    local size = extents * 1.1
    local topPos = root.Position + Vector3.new(0, size.Y / 2, 0)
    local botPos = root.Position - Vector3.new(0, size.Y / 2, 0)
    local topScr, topVis, topZ = W2S(topPos)
    local botScr, botVis, botZ = W2S(botPos)
    if (not topVis and not botVis) or topZ <= 0 or botZ <= 0 then return nil end
    local h = math.abs(botScr.Y - topScr.Y)
    local w = h * 0.6
    if h <= 1 or w <= 1 then return nil end
    return {
        TL = Vector2.new(topScr.X - w / 2, topScr.Y),
        BR = Vector2.new(topScr.X + w / 2, botScr.Y),
        Size = Vector2.new(w, h),
        Center = Vector2.new(topScr.X, (topScr.Y + botScr.Y) / 2),
        Pos = root.Position,
        Extents = extents
    }
end

local function Get3DCorners(character)
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    if not root then return nil end
    local s, extents = pcall(function() return character:GetExtentsSize() end)
    if not s or not extents then return nil end
    local p = root.Position
    local hx, hy, hz = extents.X / 2, extents.Y / 2, extents.Z / 2
    local corners = {
        p + Vector3.new(-hx, -hy, -hz), p + Vector3.new(hx, -hy, -hz),
        p + Vector3.new(hx, -hy, hz), p + Vector3.new(-hx, -hy, hz),
        p + Vector3.new(-hx, hy, -hz), p + Vector3.new(hx, hy, -hz),
        p + Vector3.new(hx, hy, hz), p + Vector3.new(-hx, hy, hz)
    }
    local screenCorners = {}
    for i = 1, 8 do
        local sp, vis, z = W2S(corners[i])
        if not vis or z <= 0 then return nil end
        screenCorners[i] = sp
    end
    return screenCorners
end

local Box3DEdges = {
    {1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}
}

local SkeletonConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}, {"Torso", "Head"}
}

-- ═════════════════════════════════════════════════════════════════════════════
-- ESP STATE
-- ═════════════════════════════════════════════════════════════════════════════
local function GetESPConfig()
    local S = Visuals.Settings.ESP
    return {
        Enabled = S.Enabled,
        Boxes = S.Boxes,
        Box3D = S.Box3D,
        Names = S.Names,
        Distance = S.Distance,
        Health = S.Health,
        Skeleton = S.Skeleton,
        Chams = S.Chams,
        HeadDot = S.HeadDot,
        WeaponNames = S.WeaponNames,
        TeamCheck = S.TeamCheck,
        MaxDistance = S.MaxDistance,
        BoxThickness = S.BoxThickness,
        HeadDotSize = S.HeadDotSize,
        HeadDotThickness = S.HeadDotThickness,
        Colors = S.Colors
    }
end

local function InitPlayer(player)
    if player == LocalPlayer or ESPDrawingObjects[player] then return end
    local skel = {}
    for i = 1, #SkeletonConnections do
        table.insert(skel, MakeDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(255,255,255), Transparency = 0.8}))
        table.insert(skel, MakeDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.fromRGB(0,0,0), Transparency = 0.5}))
    end
    local b3d, b3do = {}, {}
    for i = 1, 12 do
        table.insert(b3d, MakeDrawing("Line", {Visible = false, Thickness = 1.5, Color = Color3.fromRGB(255,105,180), Transparency = 0.9}))
        table.insert(b3do, MakeDrawing("Line", {Visible = false, Thickness = 3, Color = Color3.fromRGB(0,0,0), Transparency = 0.5}))
    end
    ESPDrawingObjects[player] = {
        Box = MakeDrawing("Square", {Visible = false, Thickness = 1, Color = Color3.fromRGB(255,105,180), Transparency = 0.9, Filled = false}),
        B3D = b3d, B3DO = b3do,
        Name = MakeDrawing("Text", {Visible = false, Text = player.Name, Size = 16, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(255,255,255)}),
        HB = MakeDrawing("Square", {Visible = false, Thickness = 1, Filled = true, Color = Color3.fromRGB(0,255,100)}),
        HBO = MakeDrawing("Square", {Visible = false, Thickness = 1, Filled = true, Color = Color3.fromRGB(0,0,0)}),
        HT = MakeDrawing("Text", {Visible = false, Text = "100", Size = 13, Center = false, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(255,255,255)}),
        Skel = skel,
        Dist = MakeDrawing("Text", {Visible = false, Text = "", Size = 14, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(200,200,200)}),
        HeadDot = MakeDrawing("Circle", {Visible = false, Thickness = 1, Color = Color3.fromRGB(255,255,255), Transparency = 0.9, NumSides = 16, Filled = true}),
        HeadDotO = MakeDrawing("Circle", {Visible = false, Thickness = 2, Color = Color3.fromRGB(0,0,0), Transparency = 0.5, NumSides = 16, Filled = false}),
        Weapon = MakeDrawing("Text", {Visible = false, Text = "", Size = 13, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(255,200,100)}),
    }
end

local function ClearPlayer(player)
    if not ESPDrawingObjects[player] then return end
    local o = ESPDrawingObjects[player]
    for k, v in pairs(o) do
        if k == "Skel" or k == "B3D" or k == "B3DO" then
            for _, line in pairs(v) do RemoveDrawing(line) end
        else
            RemoveDrawing(v)
        end
    end
    ESPDrawingObjects[player] = nil
    local char = player.Character
    if char then
        local h = char:FindFirstChild("Visuals_Chams")
        if h then h:Destroy() end
    end
    if ESPCharacterAddedConnections[player] then
        ESPCharacterAddedConnections[player]:Disconnect()
        ESPCharacterAddedConnections[player] = nil
    end
end

local function HideAll(o)
    SetDrawing(o.Box, "Visible", false)
    SetDrawing(o.Name, "Visible", false)
    SetDrawing(o.Dist, "Visible", false)
    SetDrawing(o.HB, "Visible", false)
    SetDrawing(o.HBO, "Visible", false)
    SetDrawing(o.HT, "Visible", false)
    SetDrawing(o.HeadDot, "Visible", false)
    SetDrawing(o.HeadDotO, "Visible", false)
    SetDrawing(o.Weapon, "Visible", false)
    for _, l in pairs(o.Skel) do SetDrawing(l, "Visible", false) end
    for _, l in pairs(o.B3D) do SetDrawing(l, "Visible", false) end
    for _, l in pairs(o.B3DO) do SetDrawing(l, "Visible", false) end
end

local function GetPlayerWeapon(player)
    local char = player.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    return nil
end

local function ShouldShowESP(player)
    local ESP = GetESPConfig()
    if not ESP then return false end
    if not ESP.Enabled then return false end
    if player == LocalPlayer then return false end
    return true
end

local function UpdateChams(player, char, ESP)
    if not ESP.Chams then
        local old = char:FindFirstChild("Visuals_Chams")
        if old then old.Enabled = false end
        return
    end

    local hl = char:FindFirstChild("Visuals_Chams")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "Visuals_Chams"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
    end

    pcall(function()
        hl.FillColor = ESP.Colors.ChamsFill
        hl.OutlineColor = ESP.Colors.ChamsOutline
    end)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0.2
    hl.Enabled = true
end

local function UpdateESPPlayer(player)
    local ESP = GetESPConfig()
    if not ESP then return end
    local o = ESPDrawingObjects[player]
    if not o then return end
    if not ShouldShowESP(player) then 
        HideAll(o) 
        local char = player.Character
        if char then
            local hl = char:FindFirstChild("Visuals_Chams")
            if hl then hl.Enabled = false end
        end
        return 
    end
    local char = player.Character
    if not char then HideAll(o) return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not hum or not root or hum.Health <= 0 then 
        HideAll(o) 
        local hl = char:FindFirstChild("Visuals_Chams")
        if hl then hl.Enabled = false end
        return 
    end
    if ESP.TeamCheck then
        local isTeammate = false
        if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then isTeammate = true end
        if LocalPlayer.TeamColor and player.TeamColor and LocalPlayer.TeamColor == player.TeamColor then isTeammate = true end
        if isTeammate then 
            HideAll(o) 
            local hl = char:FindFirstChild("Visuals_Chams")
            if hl then hl.Enabled = false end
            return 
        end
    end
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > ESP.MaxDistance then 
        HideAll(o) 
        local hl = char:FindFirstChild("Visuals_Chams")
        if hl then hl.Enabled = false end
        return 
    end

    UpdateChams(player, char, ESP)

    local box = GetBoxData(char)
    if not box then 
        HideAll(o) 
        return 
    end

    -- 2D Box
    if ESP.Boxes and not ESP.Box3D then
        SetDrawing(o.Box, "Size", box.Size)
        SetDrawing(o.Box, "Position", box.TL)
        SetDrawing(o.Box, "Color", ESP.Colors.Box)
        SetDrawing(o.Box, "Thickness", ESP.BoxThickness)
        SetDrawing(o.Box, "Visible", true)
    else
        SetDrawing(o.Box, "Visible", false)
    end

    -- 3D Box
    if ESP.Boxes and ESP.Box3D then
        local c = Get3DCorners(char)
        if c then
            for i, e in ipairs(Box3DEdges) do
                SetDrawing(o.B3D[i], "From", c[e[1]])
                SetDrawing(o.B3D[i], "To", c[e[2]])
                SetDrawing(o.B3D[i], "Color", ESP.Colors.Box)
                SetDrawing(o.B3D[i], "Visible", true)
                SetDrawing(o.B3DO[i], "From", c[e[1]])
                SetDrawing(o.B3DO[i], "To", c[e[2]])
                SetDrawing(o.B3DO[i], "Visible", true)
            end
        else
            for _, l in pairs(o.B3D) do SetDrawing(l, "Visible", false) end
            for _, l in pairs(o.B3DO) do SetDrawing(l, "Visible", false) end
        end
    else
        for _, l in pairs(o.B3D) do SetDrawing(l, "Visible", false) end
        for _, l in pairs(o.B3DO) do SetDrawing(l, "Visible", false) end
    end

    -- Name
    if ESP.Names then
        SetDrawing(o.Name, "Position", Vector2.new(box.Center.X, box.TL.Y - 16))
        SetDrawing(o.Name, "Text", player.Name)
        SetDrawing(o.Name, "Color", ESP.Colors.Name)
        SetDrawing(o.Name, "Visible", true)
    else
        SetDrawing(o.Name, "Visible", false)
    end

    -- Distance
    if ESP.Distance then
        SetDrawing(o.Dist, "Position", Vector2.new(box.Center.X, box.BR.Y + 4))
        SetDrawing(o.Dist, "Text", math.floor(dist) .. "m")
        SetDrawing(o.Dist, "Color", ESP.Colors.Distance)
        SetDrawing(o.Dist, "Visible", true)
    else
        SetDrawing(o.Dist, "Visible", false)
    end

    -- Health
    if ESP.Health then
        local ok = pcall(function()
            local mh = hum.MaxHealth
            local ch = hum.Health
            if not mh or mh <= 0 or not ch or ch < 0 then
                SetDrawing(o.HB, "Visible", false)
                SetDrawing(o.HBO, "Visible", false)
                SetDrawing(o.HT, "Visible", false)
                return
            end
            local pct = math.clamp(ch / mh, 0, 1)
            local bh = math.max(box.Size.Y * pct, 2)
            local bw = 4
            if box.Size.Y <= 0 then
                SetDrawing(o.HB, "Visible", false)
                SetDrawing(o.HBO, "Visible", false)
                SetDrawing(o.HT, "Visible", false)
                return
            end
            SetDrawing(o.HBO, "Size", Vector2.new(bw + 2, box.Size.Y + 2))
            SetDrawing(o.HBO, "Position", Vector2.new(box.TL.X - bw - 6, box.TL.Y - 1))
            SetDrawing(o.HBO, "Visible", true)
            SetDrawing(o.HB, "Size", Vector2.new(bw, bh))
            SetDrawing(o.HB, "Position", Vector2.new(box.TL.X - bw - 5, box.BR.Y - bh))
            local fullColor = ESP.Colors.Health
            local emptyColor = Color3.fromRGB(255, 0, 0)
            local healthColor = emptyColor:Lerp(fullColor, pct)
            SetDrawing(o.HB, "Color", healthColor)
            SetDrawing(o.HB, "Visible", true)
            SetDrawing(o.HT, "Position", Vector2.new(box.TL.X - bw - 28, box.BR.Y - bh - 6))
            SetDrawing(o.HT, "Text", math.floor(ch))
            SetDrawing(o.HT, "Visible", true)
        end)
        if not ok then
            SetDrawing(o.HB, "Visible", false)
            SetDrawing(o.HBO, "Visible", false)
            SetDrawing(o.HT, "Visible", false)
        end
    else
        SetDrawing(o.HB, "Visible", false)
        SetDrawing(o.HBO, "Visible", false)
        SetDrawing(o.HT, "Visible", false)
    end

    -- Skeleton
    if ESP.Skeleton then
        local idx = 1
        for _, conn in ipairs(SkeletonConnections) do
            local p1 = char:FindFirstChild(conn[1])
            local p2 = char:FindFirstChild(conn[2])
            local line = o.Skel[idx]
            local outline = o.Skel[idx + 1]
            idx = idx + 2
            if p1 and p2 and line and outline then
                local s1, v1 = W2S(p1.Position)
                local s2, v2 = W2S(p2.Position)
                if v1 and v2 then
                    SetDrawing(line, "From", s1)
                    SetDrawing(line, "To", s2)
                    SetDrawing(line, "Color", ESP.Colors.Skeleton)
                    SetDrawing(line, "Visible", true)
                    SetDrawing(outline, "From", s1)
                    SetDrawing(outline, "To", s2)
                    SetDrawing(outline, "Visible", true)
                else
                    SetDrawing(line, "Visible", false)
                    SetDrawing(outline, "Visible", false)
                end
            else
                if line then SetDrawing(line, "Visible", false) end
                if outline then SetDrawing(outline, "Visible", false) end
            end
        end
    else
        for _, l in pairs(o.Skel) do SetDrawing(l, "Visible", false) end
    end

    -- Head Dot
    if ESP.HeadDot then
        local head = char:FindFirstChild("Head")
        if head then
            local headPos, onScreen = W2S(head.Position)
            if onScreen then
                local radius = math.clamp(3000 / dist, 3, 12) * ESP.HeadDotSize
                SetDrawing(o.HeadDot, "Position", headPos)
                SetDrawing(o.HeadDot, "Radius", radius)
                SetDrawing(o.HeadDot, "Color", ESP.Colors.HeadDot)
                SetDrawing(o.HeadDot, "Thickness", ESP.HeadDotThickness)
                SetDrawing(o.HeadDot, "Visible", true)
                SetDrawing(o.HeadDotO, "Position", headPos)
                SetDrawing(o.HeadDotO, "Radius", radius + 1)
                SetDrawing(o.HeadDotO, "Thickness", ESP.HeadDotThickness + 1)
                SetDrawing(o.HeadDotO, "Visible", true)
            else
                SetDrawing(o.HeadDot, "Visible", false)
                SetDrawing(o.HeadDotO, "Visible", false)
            end
        else
            SetDrawing(o.HeadDot, "Visible", false)
            SetDrawing(o.HeadDotO, "Visible", false)
        end
    else
        SetDrawing(o.HeadDot, "Visible", false)
        SetDrawing(o.HeadDotO, "Visible", false)
    end

    -- Weapon Names
    if ESP.WeaponNames then
        local weapon = GetPlayerWeapon(player)
        if weapon then
            SetDrawing(o.Weapon, "Position", Vector2.new(box.Center.X, box.BR.Y + 18))
            SetDrawing(o.Weapon, "Text", "[" .. weapon .. "]")
            SetDrawing(o.Weapon, "Visible", true)
        else
            SetDrawing(o.Weapon, "Visible", false)
        end
    else
        SetDrawing(o.Weapon, "Visible", false)
    end
end

local function ESPUpdate()
    local ESP = GetESPConfig()
    if not ESP or not ESP.Enabled then
        for player, o in pairs(ESPDrawingObjects) do
            HideAll(o)
            local c = player.Character
            if c then local h = c:FindFirstChild("Visuals_Chams"); if h then h.Enabled = false end end
        end
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function() UpdateESPPlayer(p) end)
    end
end

local function ESPInit()
    for _, p in pairs(Players:GetPlayers()) do
        InitPlayer(p)
        if not ESPCharacterAddedConnections[p] then
            ESPCharacterAddedConnections[p] = p.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                local ESP = GetESPConfig()
                if ESP and ESP.Chams then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Visuals_Chams"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                    pcall(function()
                        hl.FillColor = ESP.Colors.ChamsFill
                        hl.OutlineColor = ESP.Colors.ChamsOutline
                    end)
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0.2
                    hl.Enabled = true
                end
            end)
        end
    end
    ESPPlayerAddedConnection = Players.PlayerAdded:Connect(function(p)
        InitPlayer(p)
        ESPCharacterAddedConnections[p] = p.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            local ESP = GetESPConfig()
            if ESP and ESP.Chams then
                local hl = Instance.new("Highlight")
                hl.Name = "Visuals_Chams"
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                pcall(function()
                    hl.FillColor = ESP.Colors.ChamsFill
                    hl.OutlineColor = ESP.Colors.ChamsOutline
                end)
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0.2
                hl.Enabled = true
            end
        end)
    end)
    ESPPlayerRemovingConnection = Players.PlayerRemoving:Connect(function(p)
        ClearPlayer(p)
    end)
end

-- ═════════════════════════════════════════════════════════════════════════════
-- PLAYER AURAS
-- ═════════════════════════════════════════════════════════════════════════════
local AuraObjects = {}

local function CreateAura(player, character)
    if AuraObjects[character] then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local auraFolder = Instance.new("Folder")
    auraFolder.Name = "AuraEffects"
    auraFolder.Parent = character

    local attachments = {}
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local att = Instance.new("Attachment")
            att.Name = "AuraAtt"
            att.Parent = part
            table.insert(attachments, att)
        end
    end

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

    for _, att in ipairs(attachments) do
        local clone = particles:Clone()
        clone.Parent = att
    end

    local light = Instance.new("PointLight")
    light.Color = Visuals.Settings.Aura.Color
    light.Range = Visuals.Settings.Aura.Size * 2
    light.Brightness = 3
    light.Parent = root

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
            for _, att in ipairs(data.attachments) do
                if att and att.Parent then
                    local particles = att:FindFirstChild("AuraParticles")
                    if particles then
                        particles.Color = ColorSequence.new(S.Color)
                        particles.LightEmission = 1

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
                            particles.Texture = "rbxassetid://243728733"
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
                            particles.Speed = NumberRange.new(-10, -5)

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

            data.light.Color = S.Color
            data.light.Range = S.Size * 2
            data.light.Enabled = true

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

-- ═════════════════════════════════════════════════════════════════════════════
-- PLAYER CHAMS (BODY REPLACEMENT)
-- ═════════════════════════════════════════════════════════════════════════════
local ChamObjects = {}

local CHAM_MATERIALS = {
    "ForceField", "Glass", "Neon", "SmoothPlastic", "Foil",
    "Ice", "CrackedLava", "DiamondPlate", "Sand", "Brick",
    "Granite", "Marble", "Pebble", "Rust", "Wood",
    "WoodPlanks", "Cobblestone", "Concrete", "Metal", "Grass"
}

local rainbowHue = 0

local function GetRainbowColor()
    rainbowHue = (rainbowHue + 0.01) % 1
    return Color3.fromHSV(rainbowHue, 1, 1)
end

local function ApplyPlayerChams(character, data)
    local S = Visuals.Settings.PlayerChams

    if not S.Enabled then
        for part, original in pairs(data.originals) do
            if part and part.Parent then
                part.Material = original.Material
                part.Color = original.Color
                part.Transparency = original.Transparency
            end
        end
        if data.highlight then
            data.highlight:Destroy()
            data.highlight = nil
        end
        if data.glowLight then
            data.glowLight:Destroy()
            data.glowLight = nil
        end
        return
    end

    local color = S.Color
    if S.Rainbow then
        color = GetRainbowColor()
    end

    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not data.originals[part] then
                data.originals[part] = {
                    Material = part.Material,
                    Color = part.Color,
                    Transparency = part.Transparency
                }
            end

            local material = Enum.Material[S.Material]
            part.Material = material

            if S.Material == "ForceField" then
                part.Color = color
                part.Transparency = 0.3 + math.sin(tick() * 2) * 0.1
            elseif S.Material == "Glass" then
                part.Color = Color3.new(1, 1, 1)
                part.Transparency = 0.5
            elseif S.Material == "Neon" then
                part.Color = color
                part.Transparency = S.Transparency
            elseif S.Material == "Ice" then
                part.Color = Color3.fromRGB(200, 230, 255)
                part.Transparency = 0.2
            elseif S.Material == "CrackedLava" then
                part.Color = Color3.fromRGB(255, 100, 0)
                part.Transparency = 0
            else
                part.Color = color
                part.Transparency = S.Transparency
            end

            if S.Pulse then
                local pulse = math.sin(tick() * 3) * 0.1
                part.Transparency = math.clamp(part.Transparency + pulse, 0, 1)
            end
        end
    end

    if S.Glow and not data.highlight then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = color
        highlight.OutlineColor = S.SecondaryColor
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
        data.highlight = highlight
    elseif data.highlight then
        data.highlight.FillColor = color
        data.highlight.OutlineColor = S.SecondaryColor
    end

    if S.Glow and not data.glowLight then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local light = Instance.new("PointLight")
            light.Color = color
            light.Range = 8
            light.Brightness = 2
            light.Parent = root
            data.glowLight = light
        end
    elseif data.glowLight then
        data.glowLight.Color = color
    end
end

local function CreatePlayerChams(player, character)
    if ChamObjects[character] then return end

    ChamObjects[character] = {
        player = player,
        originals = {},
        highlight = nil,
        glowLight = nil,
    }
end

local function UpdatePlayerChams()
    for character, data in pairs(ChamObjects) do
        if not character or not character.Parent then
            ChamObjects[character] = nil
        else
            ApplyPlayerChams(character, data)
        end
    end
end

local function CleanupPlayerChams(character)
    if ChamObjects[character] then
        local data = ChamObjects[character]
        for part, original in pairs(data.originals) do
            if part and part.Parent then
                part.Material = original.Material
                part.Color = original.Color
                part.Transparency = original.Transparency
            end
        end
        if data.highlight then data.highlight:Destroy() end
        if data.glowLight then data.glowLight:Destroy() end
        ChamObjects[character] = nil
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- CUSTOM CHAMS (HIGHLIGHT STYLES)
-- ═════════════════════════════════════════════════════════════════════════════
local function ApplyCustomChams(character, data)
    if not Visuals.Settings.CustomChams.Enabled then
        if data.highlight then
            data.highlight.FillTransparency = 0.5
            data.highlight.OutlineTransparency = 0
        end
        return
    end

    local style = Visuals.Settings.CustomChams.Style
    local color = Visuals.Settings.CustomChams.Color
    local outlineColor = Visuals.Settings.CustomChams.OutlineColor
    local glow = Visuals.Settings.CustomChams.GlowIntensity
    local scanSpeed = Visuals.Settings.CustomChams.ScanSpeed

    if not data.highlight then return end

    if style == "Hologram" then
        data.highlight.FillColor = color
        data.highlight.OutlineColor = outlineColor
        data.highlight.FillTransparency = 0.7
        data.highlight.OutlineTransparency = 0
    elseif style == "Neon" then
        data.highlight.FillColor = color
        data.highlight.OutlineColor = Color3.new(1, 1, 1)
        data.highlight.FillTransparency = 0.3
        data.highlight.OutlineTransparency = 0
    elseif style == "Ghost" then
        data.highlight.FillColor = color
        data.highlight.OutlineColor = outlineColor
        data.highlight.FillTransparency = 0.9
        data.highlight.OutlineTransparency = 0.5
    elseif style == "Cyber" then
        data.highlight.FillColor = color
        data.highlight.OutlineColor = outlineColor
        data.highlight.FillTransparency = 0.4 + math.sin(tick() * scanSpeed) * 0.2
        data.highlight.OutlineTransparency = 0
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- ARM CHAMS
-- ═════════════════════════════════════════════════════════════════════════════
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

-- ═════════════════════════════════════════════════════════════════════════════
-- WEATHER
-- ═════════════════════════════════════════════════════════════════════════════
local WeatherObjects = {}

local function CreateWeather()
    if WeatherObjects.particles then return end

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

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        WeatherObjects.part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 50, 0)
    end

    local particles = WeatherObjects.particles
    particles.Enabled = true
    particles.Rate = Visuals.Settings.Weather.Intensity
    particles.Color = ColorSequence.new(Visuals.Settings.Weather.Color)

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

-- ═════════════════════════════════════════════════════════════════════════════
-- PLAYER MANAGEMENT
-- ═════════════════════════════════════════════════════════════════════════════
local function OnPlayerAdded(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Head", 5)
        character:WaitForChild("HumanoidRootPart", 5)
        task.wait(0.3)

        if Visuals.Settings.Aura.Enabled then
            CreateAura(player, character)
        end
        if Visuals.Settings.PlayerChams.Enabled then
            CreatePlayerChams(player, character)
        end
    end)

    if player.Character then
        task.spawn(function()
            player.Character:WaitForChild("Head", 5)
            task.wait(0.3)

            if Visuals.Settings.Aura.Enabled then
                CreateAura(player, player.Character)
            end
            if Visuals.Settings.PlayerChams.Enabled then
                CreatePlayerChams(player, player.Character)
            end
        end)
    end

    player.CharacterRemoving:Connect(function(character)
        if AuraObjects[character] then
            if AuraObjects[character].folder then AuraObjects[character].folder:Destroy() end
            AuraObjects[character] = nil
        end
        CleanupPlayerChams(character)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        OnPlayerAdded(player)
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        if AuraObjects[player.Character] then
            if AuraObjects[player.Character].folder then AuraObjects[player.Character].folder:Destroy() end
            AuraObjects[player.Character] = nil
        end
        CleanupPlayerChams(player.Character)
    end
end)

-- ═════════════════════════════════════════════════════════════════════════════
-- MAIN UPDATE LOOP
-- ═════════════════════════════════════════════════════════════════════════════
function Visuals.Update()
    ESPUpdate()
    UpdateAuras()
    UpdatePlayerChams()
    ApplyArmChams()
    UpdateWeather()
end

-- ═════════════════════════════════════════════════════════════════════════════
-- GUI REGISTRATION & INIT
-- ═════════════════════════════════════════════════════════════════════════════
function Visuals.Init(deps)
    print("[Visuals] Init called")
    Config = deps.Config
    GUI = deps.GUI
    Core = deps.Core
    Utils = deps.Utils

    -- Wait for Utils to be available
    if not Utils then
        warn("[Visuals] Utils not available, waiting...")
        local startTime = tick()
        while not Utils and tick() - startTime < 5 do
            task.wait(0.1)
            Utils = deps.Utils
        end
    end

    if not Utils then
        warn("[Visuals] Utils still not available, ESP will not work")
        return
    end

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
    local espSection, setEspOpen = C.MasterSection(page, "ESP", 1, false)

    C.Toggle(espSection, "Enabled", S.ESP.Enabled, function(v) 
        S.ESP.Enabled = v
        if v then
            ESPInit()
            if not ESPRenderConnection then
                ESPRenderConnection = RunService.RenderStepped:Connect(ESPUpdate)
            end
        else
            if ESPRenderConnection then
                ESPRenderConnection:Disconnect()
                ESPRenderConnection = nil
            end
        end
    end, 2)

    C.Toggle(espSection, "2D Boxes", S.ESP.Boxes, function(v) S.ESP.Boxes = v end, 3)
    C.Toggle(espSection, "3D Boxes", S.ESP.Box3D, function(v) S.ESP.Box3D = v end, 4)
    C.Toggle(espSection, "Names", S.ESP.Names, function(v) S.ESP.Names = v end, 5)
    C.Toggle(espSection, "Distance", S.ESP.Distance, function(v) S.ESP.Distance = v end, 6)
    C.Toggle(espSection, "Health", S.ESP.Health, function(v) S.ESP.Health = v end, 7)
    C.Toggle(espSection, "Skeleton", S.ESP.Skeleton, function(v) S.ESP.Skeleton = v end, 8)
    C.Toggle(espSection, "Head Dot", S.ESP.HeadDot, function(v) S.ESP.HeadDot = v end, 9)
    C.Toggle(espSection, "Weapon Names", S.ESP.WeaponNames, function(v) S.ESP.WeaponNames = v end, 10)
    C.Toggle(espSection, "Chams", S.ESP.Chams, function(v) S.ESP.Chams = v end, 11)
    C.Toggle(espSection, "Team Check", S.ESP.TeamCheck, function(v) S.ESP.TeamCheck = v end, 12)
    C.Slider(espSection, "Max Distance", 100, 2000, S.ESP.MaxDistance, function(v) S.ESP.MaxDistance = v end, 13)
    C.Slider(espSection, "Box Thickness", 1, 5, S.ESP.BoxThickness, function(v) S.ESP.BoxThickness = v end, 14)

    -- Player Chams Section
    local chamsSection, setChamsOpen = C.MasterSection(page, "Player Chams", 20, false)

    C.Toggle(chamsSection, "Enabled", S.PlayerChams.Enabled, function(v) S.PlayerChams.Enabled = v end, 21)
    C.Dropdown(chamsSection, "Material", CHAM_MATERIALS, S.PlayerChams.Material, function(v) S.PlayerChams.Material = v end, 22)
    C.TextBox(chamsSection, "Color (RGB)", "255,0,255", "0,255,255", function(v)
        local r, g, b = v:match("(%d+),(%d+),(%d+)")
        if r and g and b then
            S.PlayerChams.Color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        end
    end, 23)
    C.TextBox(chamsSection, "Outline Color", "255,255,255", "255,0,255", function(v)
        local r, g, b = v:match("(%d+),(%d+),(%d+)")
        if r and g and b then
            S.PlayerChams.SecondaryColor = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        end
    end, 24)
    C.Slider(chamsSection, "Transparency", 0, 100, S.PlayerChams.Transparency * 100, function(v) S.PlayerChams.Transparency = v / 100 end, 25)
    C.Toggle(chamsSection, "Glow", S.PlayerChams.Glow, function(v) S.PlayerChams.Glow = v end, 26)
    C.Toggle(chamsSection, "Rainbow", S.PlayerChams.Rainbow, function(v) S.PlayerChams.Rainbow = v end, 27)
    C.Toggle(chamsSection, "Pulse", S.PlayerChams.Pulse, function(v) S.PlayerChams.Pulse = v end, 28)

    -- Player Aura Section
    local auraSection, setAuraOpen = C.MasterSection(page, "Player Aura", 30, false)

    C.Toggle(auraSection, "Enabled", S.Aura.Enabled, function(v) S.Aura.Enabled = v end, 31)
    C.Dropdown(auraSection, "Aura Type", {"Glow", "Hexagon", "DataStream", "EnergyPulse", "Hologram", "ScanLines"}, S.Aura.Type, function(v) S.Aura.Type = v end, 32)
    C.Slider(auraSection, "Size", 1, 20, S.Aura.Size, function(v) S.Aura.Size = v end, 33)
    C.Slider(auraSection, "Speed", 1, 10, S.Aura.Speed, function(v) S.Aura.Speed = v end, 34)
    C.Slider(auraSection, "Intensity", 10, 200, S.Aura.Intensity, function(v) S.Aura.Intensity = v end, 35)

    -- Custom Chams Section
    local customChamsSection, setCustomChamsOpen = C.MasterSection(page, "Custom Chams", 40, false)

    C.Toggle(customChamsSection, "Enabled", S.CustomChams.Enabled, function(v) S.CustomChams.Enabled = v end, 41)
    C.Dropdown(customChamsSection, "Style", {"Hologram", "Neon", "Ghost", "Cyber"}, S.CustomChams.Style, function(v) S.CustomChams.Style = v end, 42)
    C.Slider(customChamsSection, "Glow Intensity", 0, 10, S.CustomChams.GlowIntensity, function(v) S.CustomChams.GlowIntensity = v end, 43)
    C.Slider(customChamsSection, "Scan Speed", 0, 10, S.CustomChams.ScanSpeed, function(v) S.CustomChams.ScanSpeed = v end, 44)

    -- Arm Chams Section
    local armSection, setArmOpen = C.MasterSection(page, "Arm Chams", 50, false)

    C.Toggle(armSection, "Enabled", S.ArmChams.Enabled, function(v) S.ArmChams.Enabled = v end, 51)

    -- Weather Section
    local weatherSection, setWeatherOpen = C.MasterSection(page, "Weather", 60, false)

    C.Toggle(weatherSection, "Enabled", S.Weather.Enabled, function(v) S.Weather.Enabled = v end, 61)
    C.Dropdown(weatherSection, "Type", {"Rain", "Snow", "Storm"}, S.Weather.Type, function(v) S.Weather.Type = v end, 62)
    C.Slider(weatherSection, "Intensity", 10, 200, S.Weather.Intensity, function(v) S.Weather.Intensity = v end, 63)

    print("[Visuals] GUI registered")
end

function Visuals.Cleanup()
    if ESPRenderConnection then
        ESPRenderConnection:Disconnect()
        ESPRenderConnection = nil
    end
    if ESPPlayerAddedConnection then ESPPlayerAddedConnection:Disconnect() end
    if ESPPlayerRemovingConnection then ESPPlayerRemovingConnection:Disconnect() end
    for player, conn in pairs(ESPCharacterAddedConnections) do
        if conn then conn:Disconnect() end
    end
    ESPCharacterAddedConnections = {}
    for player, _ in pairs(ESPDrawingObjects) do
        ClearPlayer(player)
    end
    ESPDrawingObjects = {}

    for character, data in pairs(AuraObjects) do
        if data.folder then data.folder:Destroy() end
    end
    table.clear(AuraObjects)

    for character, data in pairs(ChamObjects) do
        CleanupPlayerChams(character)
    end
    table.clear(ChamObjects)

    if WeatherObjects.part then WeatherObjects.part:Destroy() end
end

ESPInit()

return Visuals