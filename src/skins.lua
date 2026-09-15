-- ============================================================
-- Rivals Modular -- Skins (Fixed preview + proper filtering)
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

-- PROPER skin filtering - only show skins that match the weapon
local function getSkinsForWeapon(weaponName)
    local skins = {}
    local folder = getWeaponsFolder()
    if not folder then return skins end

    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then 
        debugPrint("Weapon not found: " .. weaponName)
        return skins 
    end

    -- Get weapon part names
    local weaponParts = {}
    for _, child in ipairs(weapon:GetChildren()) do
        table.insert(weaponParts, child.Name)
    end

    if #weaponParts == 0 then
        debugPrint("Weapon has no parts")
        return skins
    end

    -- Search all cases for matching skins
    for _, case in ipairs(getAllSkinCases()) do
        for _, skin in ipairs(case:GetChildren()) do
            local skinParts = skin:GetChildren()

            -- Must have same number of parts
            if #skinParts == #weaponParts then
                local allMatch = true

                -- Every skin part must exist in weapon parts
                for _, skinPart in ipairs(skinParts) do
                    local found = false
                    for _, weaponPart in ipairs(weaponParts) do
                        if skinPart.Name == weaponPart then
                            found = true
                            break
                        end
                    end
                    if not found then
                        allMatch = false
                        break
                    end
                end

                if allMatch then
                    table.insert(skins, skin.Name)
                end
            end
        end
    end

    table.sort(skins)
    debugPrint("Found " .. #skins .. " skins for " .. weaponName)
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
-- Preview (Fixed - no Position on lights)
-- ============================================================

local function createPreview(parent)
    previewFrame = Instance.new("Frame")
    previewFrame.Name = "SkinPreview"
    previewFrame.Size = UDim2.new(0, 180, 0, 220)
    previewFrame.Position = UDim2.new(1, -190, 0, 10)
    previewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    previewFrame.BorderSizePixel = 0
    previewFrame.Visible = false
    previewFrame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = previewFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(124, 108, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.4
    stroke.Parent = previewFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "PREVIEW"
    title.TextColor3 = Color3.fromRGB(124, 108, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.Parent = previewFrame

    previewViewport = Instance.new("ViewportFrame")
    previewViewport.Size = UDim2.new(1, -12, 1, -60)
    previewViewport.Position = UDim2.new(0, 6, 0, 28)
    previewViewport.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    previewViewport.BackgroundTransparency = 0
    previewViewport.BorderSizePixel = 0
    previewViewport.Parent = previewFrame

    local vpCorner = Instance.new("UICorner")
    vpCorner.CornerRadius = UDim.new(0, 8)
    vpCorner.Parent = previewViewport

    previewCamera = Instance.new("Camera")
    previewCamera.Parent = previewViewport
    previewViewport.CurrentCamera = previewCamera

    -- Simple lighting - no Position property
    local light = Instance.new("PointLight")
    light.Brightness = 3
    light.Range = 20
    light.Parent = previewViewport

    local disclaimer = Instance.new("TextLabel")
    disclaimer.Size = UDim2.new(1, -12, 0, 26)
    disclaimer.Position = UDim2.new(0, 6, 1, -30)
    disclaimer.BackgroundTransparency = 1
    disclaimer.Text = "Skins apply after death"
    disclaimer.TextColor3 = Color3.fromRGB(255, 180, 80)
    disclaimer.Font = Enum.Font.GothamMedium
    disclaimer.TextSize = 10
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

    -- CLOSER camera = bigger gun
    local distance = maxDim * 0.8

    previewCamera.CFrame = CFrame.new(
        center + Vector3.new(distance, distance * 0.5, distance),
        center
    )

    previewRotation = 0
end

local function startPreviewRotation()
    RunService.RenderStepped:Connect(function(dt)
        if not previewModel or not previewCamera then return end
        if not previewFrame or not previewFrame.Visible then return end
        if not Core.MenuOpen then return end

        previewRotation = previewRotation + dt * 0.5

        local cf, size = previewModel:GetBoundingBox()
        local center = cf.Position
        local maxDim = math.max(size.X, size.Y, size.Z)
        local distance = maxDim * 0.8
        local angle = previewRotation
        local x = math.cos(angle) * distance
        local z = math.sin(angle) * distance

        previewCamera.CFrame = CFrame.new(
            center + Vector3.new(x, distance * 0.5, z),
            center
        )
    end)
end

-- Tab visibility checker
local function startTabChecker()
    task.spawn(function()
        while true do
            task.wait(0.1)
            if previewFrame and Core.GUI then
                local skinsPage = Core.GUI.GetPage and Core.GUI.GetPage("Skins")
                if skinsPage then
                    previewFrame.Visible = skinsPage.Visible and Core.MenuOpen
                end
            end
        end
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
        startTabChecker()

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
    end

    print("[rivals] Skins module initialized.")
end

function Skins.Cleanup()
    for weapon, _ in pairs(currentSkins) do
        resetWeapon(weapon)
    end
end

return Skins