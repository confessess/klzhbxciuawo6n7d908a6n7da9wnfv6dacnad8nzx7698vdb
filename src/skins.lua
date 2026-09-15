-- ============================================================
-- Rivals Modular -- Skins (Auto-apply + Preview + Disclaimer)
-- Skins apply on selection, change visible after death
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService, RunService

local weaponsFolder = nil
local skinCases = {}
local originalWeapons = {}
local currentSkins = {}

local selectedWeapon = "None"
local selectedSkin = "None"
local skinOptions = {"Select a weapon first"}

local SKINS_FILE = "RivalsModular/skins.json"

local previewFrame = nil
local previewViewport = nil
local previewCamera = nil
local previewModel = nil
local previewRotation = 0

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

local function createPreview(parent)
    previewFrame = Instance.new("Frame")
    previewFrame.Name = "SkinPreview"
    previewFrame.Size = UDim2.new(0, 200, 0, 240)
    previewFrame.Position = UDim2.new(1, -210, 0, 50)
    previewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    previewFrame.BorderSizePixel = 0
    previewFrame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = previewFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(124, 108, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = previewFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundTransparency = 1
    title.Text = "PREVIEW"
    title.TextColor3 = Color3.fromRGB(124, 108, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.Parent = previewFrame

    previewViewport = Instance.new("ViewportFrame")
    previewViewport.Size = UDim2.new(1, -10, 1, -70)
    previewViewport.Position = UDim2.new(0, 5, 0, 32)
    previewViewport.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    previewViewport.BackgroundTransparency = 0
    previewViewport.BorderSizePixel = 0
    previewViewport.Parent = previewFrame

    local vpCorner = Instance.new("UICorner")
    vpCorner.CornerRadius = UDim.new(0, 8)
    vpCorner.Parent = previewViewport

    previewCamera = Instance.new("Camera")
    previewCamera.Parent = previewViewport
    previewViewport.CurrentCamera = previewCamera

    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 20
    light.Parent = previewViewport

    -- Disclaimer
    local disclaimer = Instance.new("TextLabel")
    disclaimer.Size = UDim2.new(1, -10, 0, 32)
    disclaimer.Position = UDim2.new(0, 5, 1, -36)
    disclaimer.BackgroundTransparency = 1
    disclaimer.Text = "Skins only change upon death"
    disclaimer.TextColor3 = Color3.fromRGB(255, 180, 80)
    disclaimer.Font = Enum.Font.GothamMedium
    disclaimer.TextSize = 11
    disclaimer.TextWrapped = true
    disclaimer.Parent = previewFrame

    return previewFrame
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
        if not previewModel or not previewCamera then return end
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
    end)

    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        createPreview(page)
        startPreviewRotation()

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
                    -- Auto-apply
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
    end

    print("[rivals] Skins module initialized.")
end

function Skins.Cleanup()
    for weapon, _ in pairs(currentSkins) do
        resetWeapon(weapon)
    end
    if previewFrame then
        previewFrame:Destroy()
    end
end

return Skins