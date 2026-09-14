-- ============================================================
-- Rivals Modular -- Utils
-- Services, enemy/team detection, raycast LOS, screen math
-- ============================================================

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = {}

Utils.Players           = Players
Utils.LocalPlayer       = Players.LocalPlayer
Utils.Camera            = workspace.CurrentCamera
Utils.RunService        = RunService
Utils.UserInputService  = UserInputService
Utils.ReplicatedStorage = ReplicatedStorage

Utils.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

task.spawn(function()
    while true do
        if workspace.CurrentCamera ~= Utils.Camera then
            Utils.Camera = workspace.CurrentCamera
        end
        task.wait(1)
    end
end)

-- ------------------------------------------------------------
-- Screen math
-- ------------------------------------------------------------

function Utils.GetCrosshairPosition()
    if not Utils.Camera then return Vector2.new(0, 0) end
    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        local vp = Utils.Camera.ViewportSize
        return Vector2.new(vp.X / 2, vp.Y / 2)
    end
    return UserInputService:GetMouseLocation()
end

function Utils.WorldToScreen(position)
    if not Utils.Camera then return nil, false end
    local ok, result = pcall(function()
        return Utils.Camera:WorldToScreenPoint(position)
    end)
    if not ok or not result then return nil, false end
    return Vector2.new(result.X, result.Y), result.Z > 0
end

-- ------------------------------------------------------------
-- Team detection
-- ------------------------------------------------------------

local TEAM_CACHE_DURATION = 0.15
local teamCache     = {}
local teamCacheTime = {}

local function normalizeTeamValue(value)
    if value == nil then return nil end
    local t = typeof(value)
    if t == "Instance"   then return value end
    if t == "Color3"     then return string.format("color:%.4f:%.4f:%.4f", value.R, value.G, value.B) end
    if t == "BrickColor" then return "brick:" .. value.Name end
    if t == "string"     then return value == "" and nil or "string:" .. value end
    if t == "number"     then return "number:" .. tostring(value) end
    if t == "boolean"    then return "boolean:" .. tostring(value) end
    return nil
end

local function isTeamName(name)
    if typeof(name) ~= "string" then return false end
    local lowered = string.gsub(string.lower(name), "[%s_%-]", "")
    return lowered == "team" or lowered == "teamid" or lowered == "teamidentifier"
        or lowered == "teamindex" or lowered == "teamcolor" or lowered == "teamcolour"
        or string.find(lowered, "teamid", 1, true) ~= nil
end

local function getTeamFromAttributes(container)
    if not container then return nil end
    local ok, attrs = pcall(function() return container:GetAttributes() end)
    if not ok or not attrs then return nil end
    for name, value in pairs(attrs) do
        if isTeamName(name) then
            local n = normalizeTeamValue(value)
            if n ~= nil then return n end
        end
    end
    return nil
end

local function getTeamFromValues(container)
    if not container then return nil end
    local ok, children = pcall(function() return container:GetChildren() end)
    if not ok or not children then return nil end
    for _, object in ipairs(children) do
        if isTeamName(object.Name) then
            local n = normalizeTeamValue(object.Value)
            if n then return n end
        end
    end
    return nil
end

function Utils.GetTeamSignature(player)
    if not player then return nil end
    local now = os.clock()
    if teamCache[player] ~= nil and teamCacheTime[player]
        and now - teamCacheTime[player] < TEAM_CACHE_DURATION then
        return teamCache[player]
    end

    local signature =
        player.Team
        or getTeamFromAttributes(player)
        or getTeamFromValues(player)
        or (player.Character and getTeamFromAttributes(player.Character))
        or (player.Character and getTeamFromValues(player.Character))

    if not signature then
        local ok, tc = pcall(function() return player.TeamColor end)
        if ok and tc and tc.Name and tc.Name ~= "Medium stone grey" then
            signature = "brick:" .. tc.Name
        end
    end

    teamCache[player]     = signature
    teamCacheTime[player] = now
    return signature
end

function Utils.ClearTeamCache(player)
    teamCache[player]     = nil
    teamCacheTime[player] = nil
end

function Utils.IsTeammate(player)
    if not player or player == Utils.LocalPlayer then return true end

    local ok1, lTeam = pcall(function() return Utils.LocalPlayer.Team end)
    local ok2, pTeam = pcall(function() return player.Team end)
    if ok1 and ok2 and lTeam and pTeam then
        return lTeam == pTeam
    end

    local ls = Utils.GetTeamSignature(Utils.LocalPlayer)
    local ts = Utils.GetTeamSignature(player)
    if ls ~= nil and ts ~= nil then
        if typeof(ls) == "Instance" and typeof(ts) == "Instance" then
            return ls == ts
        end
        return tostring(ls) == tostring(ts)
    end

    local ok3, ltc = pcall(function() return Utils.LocalPlayer.TeamColor end)
    local ok4, ptc = pcall(function() return player.TeamColor end)
    if ok3 and ok4 and ltc and ptc then
        local lc, tc = ltc.Name, ptc.Name
        if lc ~= "Medium stone grey" and tc ~= "Medium stone grey" then
            return lc == tc
        end
    end
    return false
end

function Utils.IsEnemy(player)
    if not player or player == Utils.LocalPlayer then return false end
    return not Utils.IsTeammate(player)
end

-- ------------------------------------------------------------
-- Enemy list
-- ------------------------------------------------------------

local cachedEnemies   = {}
local enemyCacheTime  = 0
local ENEMY_CACHE_TTL = 0.08

function Utils.GetEnemies()
    local now = os.clock()
    if now - enemyCacheTime < ENEMY_CACHE_TTL then
        return cachedEnemies
    end
    local result = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Utils.LocalPlayer and player.Character
            and Utils.IsEnemy(player) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(result, player)
            end
        end
    end
    cachedEnemies  = result
    enemyCacheTime = now
    return result
end

function Utils.InvalidateEnemyCache()
    enemyCacheTime = 0
end

-- ------------------------------------------------------------
-- Raycast / LOS
-- ------------------------------------------------------------

local sharedParams = RaycastParams.new()
sharedParams.FilterType = Enum.RaycastFilterType.Blacklist

local raycastBlacklistDirty = true
local raycastBlacklistTime  = 0

function Utils.InvalidateRaycast()
    raycastBlacklistDirty = true
end

local function buildBlacklist(targetCharacter)
    local blacklist = {}
    if Utils.LocalPlayer.Character then
        table.insert(blacklist, Utils.LocalPlayer.Character)
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Utils.LocalPlayer and player.Character
            and player.Character ~= targetCharacter then
            table.insert(blacklist, player.Character)
        end
    end
    return blacklist
end

function Utils.HasLineOfSight(targetPart)
    if not targetPart or not Utils.Camera then return false end
    local partParent = targetPart.Parent
    if not partParent then return false end

    local cameraPos = Utils.Camera.CFrame.Position
    local okPos, targetPos = pcall(function() return targetPart.Position end)
    if not okPos then return false end

    local offset   = targetPos - cameraPos
    local distance = offset.Magnitude
    if distance <= 0 then return false end

    local now = os.clock()
    if raycastBlacklistDirty or now - raycastBlacklistTime > 0.5 then
        sharedParams.FilterDescendantsInstances = buildBlacklist(partParent)
        raycastBlacklistDirty = false
        raycastBlacklistTime  = now
    end

    local ok, result = pcall(function()
        return workspace:Raycast(cameraPos, offset.Unit * distance, sharedParams)
    end)
    if not ok then return true end
    if not result or not result.Instance then return true end
    return result.Instance:IsDescendantOf(partParent)
end

-- ------------------------------------------------------------
-- Round state
-- ------------------------------------------------------------

local function isVoteScreenActive()
    local playerGui = Utils.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local mainGui = playerGui:FindFirstChild("MainGUI")
    if not mainGui then return false end
    local mainFrame = mainGui:FindFirstChild("MainFrame")
    if not mainFrame then return false end
    local di1 = mainFrame:FindFirstChild("DuelInterface")
    if not di1 then return false end
    local di2 = di1:FindFirstChild("DuelInterface")
    if not di2 then return false end
    local voting = di2:FindFirstChild("Voting")
    if not voting then return false end
    if voting.Visible then return true end
    local maps = voting:FindFirstChild("Maps")
    if maps and maps.Visible then return true end
    return maps:FindFirstChild("MapsList") ~= nil
end

function Utils.IsInActiveRound()
    local character = Utils.LocalPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if not character:FindFirstChild("HumanoidRootPart") then return false end
    if isVoteScreenActive() then return false end
    return true
end

-- ------------------------------------------------------------
-- Drawing helpers
-- ------------------------------------------------------------

function Utils.NewLine(thickness, color, transparency)
    local ok, line = pcall(function()
        local d = Drawing.new("Line")
        d.Thickness    = thickness or 1.5
        d.Color        = color or Color3.fromRGB(255, 255, 255)
        d.Transparency = transparency or 0
        d.Visible      = false
        return d
    end)
    if ok then return line end
    return nil
end

function Utils.NewCircle(radius, color, thickness)
    local ok, circle = pcall(function()
        local d = Drawing.new("Circle")
        d.Radius    = radius or 100
        d.Color     = color or Color3.fromRGB(255, 0, 0)
        d.Thickness = thickness or 2
        d.Filled    = false
        d.Visible   = false
        return d
    end)
    if ok then return circle end
    return nil
end

function Utils.NewSquare(size, color, transparency)
    local ok, square = pcall(function()
        local d = Drawing.new("Square")
        d.Size        = size or Vector2.new(50, 50)
        d.Color       = color or Color3.fromRGB(255, 255, 255)
        d.Thickness   = 1
        d.Transparency = transparency or 0
        d.Filled      = false
        d.Visible     = false
        return d
    end)
    if ok then return square end
    return nil
end

function Utils.NewText(size, color)
    local ok, text = pcall(function()
        local d = Drawing.new("Text")
        d.Size     = size or 14
        d.Color    = color or Color3.fromRGB(255, 255, 255)
        d.Outline  = true
        d.OutlineColor = Color3.fromRGB(0, 0, 0)
        d.Center   = true
        d.Visible  = false
        return d
    end)
    if ok then return text end
    return nil
end

function Utils.DestroyDrawing(obj)
    pcall(function()
        if obj then
            obj.Visible = false
            obj:Remove()
        end
    end)
end

-- ------------------------------------------------------------
-- Character shortcuts
-- ------------------------------------------------------------

function Utils.CharacterRoot(player)
    local char = player and player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function Utils.CharacterHead(player)
    local char = player and player.Character
    if not char then return nil end
    return char:FindFirstChild("Head")
end

function Utils.CharacterHumanoid(player)
    local char = player and player.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- ------------------------------------------------------------
-- Color helper
-- ------------------------------------------------------------

function Utils.HexToColor(hex)
    if not hex or type(hex) ~= "string" then return Color3.fromRGB(255, 255, 255) end
    hex = hex:gsub("#", "")
    if #hex ~= 6 then return Color3.fromRGB(255, 255, 255) end
    local r = tonumber(hex:sub(1, 2), 16) or 255
    local g = tonumber(hex:sub(3, 4), 16) or 255
    local b = tonumber(hex:sub(5, 6), 16) or 255
    return Color3.fromRGB(r, g, b)
end

-- ------------------------------------------------------------
-- Cache invalidation wiring
-- ------------------------------------------------------------

local function hookPlayer(player)
    Utils.ClearTeamCache(player)
    Utils.InvalidateEnemyCache()
    Utils.InvalidateRaycast()
    player:GetPropertyChangedSignal("Team"):Connect(function()
        Utils.ClearTeamCache(player)
        Utils.InvalidateEnemyCache()
    end)
    player:GetPropertyChangedSignal("TeamColor"):Connect(function()
        Utils.ClearTeamCache(player)
        Utils.InvalidateEnemyCache()
    end)
    player.CharacterAdded:Connect(function()
        Utils.ClearTeamCache(player)
        Utils.InvalidateEnemyCache()
        Utils.InvalidateRaycast()
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Utils.LocalPlayer then
        hookPlayer(player)
    end
end

Players.PlayerAdded:Connect(hookPlayer)

Players.PlayerRemoving:Connect(function(player)
    Utils.ClearTeamCache(player)
    Utils.InvalidateEnemyCache()
    Utils.InvalidateRaycast()
end)

return Utils
