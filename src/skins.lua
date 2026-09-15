-- ============================================================
-- Rivals Modular -- Skins (Separate preview window)
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService, RunService, TweenService

local weaponsFolder = nil
local skinCases = {}
local originalWeapons = {}
local currentSkins = {}

local selectedWeapon = "None"
local selectedSkin = "None"
local skinOptions = {"Select a weapon first"}

local SKINS_FILE = "RivalsModular/skins.json"

-- Preview window state
local previewGui = nil
local previewWindow = nil
local previewViewport = nil
local previewCamera = nil
local previewModel = nil
local previewRotation = 0
local previewVisible = true

local function debugPrint(msg)
    print("[skins] " .. msg)
end

local function getWeaponsFolder()
    if weaponsFolder then return weaponsFolder end
    local ok, result = pcall(function()
        return LocalPlayer.PlayerScripts.Assets.ViewModels.Weapons
    end)
    if ok then weaponsFolder = result end
    return weaponsFolder
end

local function getAllSkinCases()
    if #skinCases > 0 then return skinCases end
    local ok, viewModels = pcall(function()
        return LocalPlayer.PlayerScripts.Assets.ViewModels
    end)
    if not ok then return skinCases end
    for _, child in ipairs(viewModels:GetChildren()) do
        if child:IsA("Folder") and child.Name ~= "Weapons" then
            table.insert(skinCases, child)
        end
    end
    return skinCases
end

local function getSkinsForWeapon(weaponName)
    local skins = {}
    local folder = getWeaponsFolder()
    if not folder then return skins end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return skins end

    local weaponParts = {}
    for _, child in ipairs(weapon:GetChildren()) do
        table.insert(weaponParts, child.Name)
    end

    for _, case in ipairs(getAllSkinCases()) do
        for _, skin in ipairs(case:GetChildren()) do
            local skinParts = skin:GetChildren()
            if #skinParts == #weaponParts then
                local match = true
                for _, skinPart in ipairs(skinParts) do
                    local found = false
                    for _, weaponPart in ipairs(weaponParts) do
                        if skinPart.Name == weaponPart then
                            found = true
                            break
                        end
                    end
                    if not found then
                        match = false
                        break
                    end
                end
                if match then
                    table.insert(skins, skin.Name)
                end
            end
        end
    end
    table.sort(skins)
    return skins
end

local function saveOriginal(weaponName)
    if originalWeapons[weaponName] then return end
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return end
    originalWeapons[weaponName] = {}
    for _, child in ipairs(weapon:GetChildren()) do
        table.insert(originalWeapons[weaponName], child:Clone())
    end
end

local function applySkin(weaponName, skinName)
    debugPrint("Applying: " .. weaponName .. " -> " .. skinName)
    local folder = getWeaponsFolder()
    if not folder then return false end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return false end

    local skinModel = nil
    for _, case in ipairs(getAllSkinCases()) do
        local found = case:FindFirstChild(skinName)
        if found then
            skinModel = found
            break
        end
    end
    if not skinModel then return false end

    saveOriginal(weaponName)
    weapon:ClearAllChildren()
    for _, child in ipairs(skinModel:GetChildren()) do
        child:Clone().Parent = weapon
    end

    currentSkins[weaponName] = skinName
    debugPrint("Applied!")
    return true
end

local function resetWeapon(weaponName)
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return end
    if originalWeapons[weaponName] then
        weapon:ClearAllChildren()
        for _, child in ipairs(originalWeapons[weaponName]) do
            child.Parent = weapon
        end
        originalWeapons[weaponName] = nil
        currentSkins[weaponName] = nil
    end
end

local function saveSkins()
    pcall(function()
        if writefile then
            writefile(SKINS_FILE, HttpService:JSONEncode(currentSkins))
        end
    end)
end

-- ============================================================
-- Preview Window (Separate GUI)
-- ============================================================

local function createPreviewWindow()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    previewGui = Instance.new("ScreenGui")
    previewGui.Name = "SkinPreviewGui"
    previewGui.ResetOnSpawn = false
    previewGui.IgnoreGuiInset = true
    previewGui.DisplayOrder = 998
    previewGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    previewGui.Parent = playerGui

    -- Main window
    previewWindow = Instance.new("Frame")
    previewWindow.Name = "PreviewWindow"
    previewWindow.Size = UDim2.fromOffset(220, 280)
    previewWindow.Position = UDim2.new(0, 20, 0.5, -140)
    previewWindow.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    previewWindow.BorderSizePixel = 0
    previewWindow.Active = true
    previewWindow.Draggable = true
    previewWindow.Parent = previewGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = previewWindow

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(124, 108, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = previewWindow

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = previewWindow

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 12)
    titleFix.Position = UDim2.new(0, 0, 1, -12)
    titleFix.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SKIN PREVIEW"
    title.TextColor3 = Color3.fromRGB(124, 108, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(24, 24)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        previewVisible = false
        previewWindow.Visible = false
    end)

    -- Viewport
    previewViewport = Instance.new("ViewportFrame")
    previewViewport.Size = UDim2.new(1, -16, 1, -80)
    previewViewport.Position = UDim2.new(0, 8, 0, 40)
    previewViewport.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    previewViewport.BackgroundTransparency = 0
    previewViewport.BorderSizePixel = 0
    previewViewport.Parent = previewWindow

    local vpCorner = Instance.new("UICorner")
    vpCorner.CornerRadius = UDim.new(0, 8)
    vpCorner.Parent = previewViewport

    previewCamera = Instance.new("Camera")
    previewCamera.Parent = previewViewport
    previewViewport.CurrentCamera = previewCamera

    -- Lighting
    local light = Instance.new("PointLight")
    light.Brightness = 2.5
    light.Range = 25
    light.Color = Color3.fromRGB(255, 255, 255)
    light.Parent = previewViewport

    local fillLight = Instance.new("PointLight")
    fillLight.Brightness = 1
    fillLight.Range = 20
    fillLight.Color = Color3.fromRGB(180, 180, 255)
    fillLight.Position = Vector3.new(5, 5, -5)
    light.Parent = previewViewport

    -- Disclaimer
    local disclaimer = Instance.new("TextLabel")
    disclaimer.Size = UDim2.new(1, -16, 0, 32)
    disclaimer.Position = UDim2.new(0, 8, 1, -38)
    disclaimer.BackgroundTransparency = 1
    disclaimer.Text = "Skins apply after death"
    disclaimer.TextColor3 = Color3.fromRGB(255, 180, 80)
    disclaimer.Font = Enum.Font.GothamMedium
    disclaimer.TextSize = 11
    disclaimer.TextWrapped = true
    disclaimer.Parent = previewWindow

    return previewWindow
end

local function updatePreview(weaponName, skinName)
    if not previewViewport then return end
    if previewModel then
        previewModel:Destroy()
        previewModel = nil
    end
    if weaponName == "None" then return end

    local folder = getWeaponsFolder()
    if not folder then return end

    local source = nil
    if skinName and skinName ~= "None" then
        for _, case in ipairs(getAllSkinCases()) do
            local found = case:FindFirstChild(skinName)
            if found then
                source = found
                break
            end
        end
    end

    if not source then
        source = folder:FindFirstChild(weaponName)
    end
    if not source then return end

    previewModel = source:Clone()
    previewModel.Parent = previewViewport

    local cf, size = previewModel:GetBoundingBox()
    local center = cf.Position
    local maxDim = math.max(size.X, size.Y, size.Z)
    local distance = maxDim * 1.5

    previewCamera.CFrame = CFrame.new(
        center + Vector3.new(distance, distance * 0.5, distance),
        center
    )

    previewRotation = 0
end

local function startPreviewRotation()
    RunService.RenderStepped:Connect(function(dt)
        if not previewModel or not previewCamera or not previewVisible then return end
        previewRotation = previewRotation + dt * 0.5
        local cf, size = previewModel:GetBoundingBox()
        local center = cf.Position
        local maxDim = math.max(size.X, size.Y, size.Z)
        local distance = maxDim * 1.5
        local angle = previewRotation
        local x = math.cos(angle) * distance
        local z = math.sin(angle) * distance
        previewCamera.CFrame = CFrame.new(
            center + Vector3.new(x, distance * 0.3, z),
            center
        )
    end)
end

-- ============================================================
-- GUI
-- ============================================================

function Skins.Update(_dt) end

function Skins.Init(deps)
    Config = deps.Config
    Utils = deps.Utils
    GUI = deps.GUI
    Core = deps.Core
    Players = Utils.Players
    LocalPlayer = Utils.LocalPlayer
    HttpService = game:GetService("HttpService")
    RunService = Utils.RunService
    TweenService = game:GetService("TweenService")

    local weaponList = {"None"}
    local folder = getWeaponsFolder()
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if (child:IsA("Folder") or child:IsA("Model")) and child.Name ~= "Unobtainable" then
                table.insert(weaponList, child.Name)
            end
        end
    end
    table.sort(weaponList)

    task.delay(0.5, function()
        getWeaponsFolder()
        getAllSkinCases()
        createPreviewWindow()
        startPreviewRotation()
    end)

    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        GUI.AddSection(page, "Skin Changer", 1)

        GUI.AddDropdown(page, "Weapon",
            function() return weaponList end,
            function() return selectedWeapon end,
            function(v)
                selectedWeapon = v
                if v ~= "None" then
                    skinOptions = getSkinsForWeapon(v)
                    if #skinOptions == 0 then
                        skinOptions = {"No skins found"}
                    end
                    selectedSkin = "None"
                    updatePreview(v, nil)
                else
                    skinOptions = {"Select a weapon first"}
                    selectedSkin = "None"
                    updatePreview("None", nil)
                end
            end, 2)

        GUI.AddDropdown(page, "Skin",
            function() return skinOptions end,
            function() return selectedSkin end,
            function(v)
                selectedSkin = v
                if selectedWeapon ~= "None" and v ~= "None" and v ~= "No skins found" then
                    updatePreview(selectedWeapon, v)
                    local success = applySkin(selectedWeapon, v)
                    if success then
                        saveSkins()
                    end
                end
            end, 3)

        GUI.AddButton(page, "Reset Weapon",
            function()
                if selectedWeapon ~= "None" then
                    resetWeapon(selectedWeapon)
                    saveSkins()
                    updatePreview(selectedWeapon, nil)
                end
            end, 4, true)

        GUI.AddButton(page, "Reset All",
            function()
                for weapon, _ in pairs(currentSkins) do
                    resetWeapon(weapon)
                end
                saveSkins()
            end, 5, true)

        GUI.AddButton(page, "Toggle Preview",
            function()
                previewVisible = not previewVisible
                if previewWindow then
                    previewWindow.Visible = previewVisible
                end
            end, 6, false)
    end

    print("[rivals] Skins module initialized.")
end

function Skins.Cleanup()
    for weapon, _ in pairs(currentSkins) do
        resetWeapon(weapon)
    end
    if previewGui then
        previewGui:Destroy()
    end
end

return Skins