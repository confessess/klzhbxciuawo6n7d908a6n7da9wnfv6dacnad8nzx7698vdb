-- ============================================================
-- Rivals Modular -- Skins (Complete mapping + Fixed preview)
-- All skins from game, proper filtering
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService, RunService

-- COMPLETE skin mapping based on actual game data
local WEAPON_SKINS = {
    ["Assault Rifle"] = {"AK-47", "Boneclaw Rifle", "Augmented Rifle", "Gingerbread Augmented Rifle", "Soul Rifle", "Glorious Burst Rifle", "Plasma Wildcat"},
    ["Battle Axe"] = {"The Shred", "Nordic Axe", "Ban Axe", "Cerulean Axe", "Mimic Axe"},
    ["Bow"] = {"Bat Bow", "Compound Bow", "Raven Bow", "Dream Bow", "Frostbite Bow"},
    ["Burst Rifle"] = {"Aqua Burst", "Electro Rifle", "Pixel Burst", "Pine Burst", "Spectral Burst", "Bullpup Burst", "Glorious Burst Rifle"},
    ["Chainsaw"] = {"Blobsaw", "Buzzsaw", "Festive Buzzsaw", "Gunsaw"},
    ["Crossbow"] = {"Frostbite Crossbow", "Pixel Crossbow", "Harpoon Crossbow", "Violin Crossbow"},
    ["Daggers"] = {"Aces", "Cookies", "Bat Daggers", "Balisong", "Shurikens", "Handsaws"},
    ["Energy Rifle"] = {"2025 Energy Rifle", "Apex Rifle", "Hacker Rifle", "Hydro Rifle", "Void Rifle", "New Year Energy Rifle"},
    ["Energy Pistols"] = {"2025 Energy Pistols", "Apex Pistols", "Hacker Pistols", "Void Pistols", "Hydro Pistols", "New Year Energy Pistols", "Soul Pistols"},
    ["Exogun"] = {"Ray Gun", "Singularity", "Wondergun", "Midnight Festive Exogun", "Exogourd"},
    ["Fists"] = {"Boxing Gloves", "Brass Knuckles", "Pumpkin Claws", "Festive Fists", "Fists of Hurt"},
    ["Flamethrower"] = {"Lamethrower", "Pixel Flamethrower", "Snowblower", "Jack O'Thrower", "Glitterthrower"},
    ["Flare Gun"] = {"Dynamite Gun", "Firework Gun", "Wrapped Flare Gun", "Vexed Flare Gun", "Banana Flare"},
    ["Freeze Ray"] = {"Bubble Ray", "Temporal Ray", "Spider Ray", "Wrapped Freeze Ray", "Gum Ray"},
    ["Grenade"] = {"Water Balloon", "Whoopee Cushion", "Soul Grenade", "Jingle Grenade", "Dynamite", "Gearnade"},
    ["Grenade Launcher"] = {"Swashbuckler", "Uranium Launcher", "Skull Launcher", "Snowball Launcher", "Squid Launcher", "Cupcake Launcher"},
    ["Gunblade"] = {"Hyper Gunblade", "Elf's Gunblade", "Crude Gunblade"},
    ["Handgun"] = {"Blaster", "Pixel Handgun", "Pumpkin Handgun", "Gingerbread Handgun", "Gumball Handgun", "Desert Eagle", "Towerstone Handgun", "Sheriff", "Peppermint Sheriff"},
    ["Katana"] = {"Lightning Bolt", "Saber", "Pixel Katana", "Devil's Trident", "2025 Katana", "Keytana", "Stellar Katana", "New Year Katana", "Boneblade"},
    ["Knife"] = {"Chancla", "Karambit", "Machete", "Candy Cane", "Fork"},
    ["Minigun"] = {"Lasergun 3000", "Pixel Minigun", "Wrapped Minigun", "Pumpkin Minigun", "Drum Gun"},
    ["Molotov"] = {"Coffee", "Torch", "Hexxed Candle", "Hot Coals", "Vexed Candle", "Birthday Candle"},
    ["Paintball Gun"] = {"Boba Gun", "Slime Gun", "Snowball Gun", "Brain Gun", "Ketchup Gun", "Peppergun", "Paintbrush", "Paintballoon Gun"},
    ["Revolver"] = {"Boneclaw Revolver"},
    ["RPG"] = {"Nuke Launcher"},
    ["Riot Shield"] = {"Door", "Sled", "Tombstone Shield", "Energy Shield"},
    ["Scythe"] = {"Anchor", "Keythe", "Scythe of Death", "Bat Scythe", "Cryo Scythe", "Sakura Scythe", "Palm Scythe"},
    ["Shorty"] = {"Lovely Shorty", "Not So Shorty", "Too Shorty", "Demon Shorty", "Wrapped Shorty", "Balloon Shorty"},
    ["Shotgun"] = {"Balloon Shotgun", "Hyper Shotgun", "Wrapped Shotgun", "Broomstick", "Cactus Shotgun"},
    ["Slingshot"] = {"Goalpost", "Stick", "Reindeer Slingshot", "Boneshot"},
    ["Smoke Grenade"] = {"Balance", "Emoji Cloud", "Eyeball", "Snowglobe"},
    ["Sniper"] = {"Hyper Sniper", "Pixel Sniper", "Keyper", "Gingerbread Sniper", "Eyething Sniper"},
    ["Subspace Tripmine"] = {"Don't Press", "Spring", "Dev-in-the-Box", "Trick or Treat", "DIY Tripmine"},
    ["Spray"] = {"Lovely Spray", "Pine Spray", "Boneclaw Spray", "Spray Bottle", "Campfire Spray"},
    ["Trowel"] = {"Garden Shovel", "Plastic Shovel", "Snow Shovel", "Pumpkin Carver"},
    ["Uzi"] = {"Electro Uzi", "Water Uzi", "Pine Uzi", "Demon Uzi", "Glorious Uzi", "Keyzi", "Ducky Uzi"},
    ["Flashbang"] = {"Camera", "Disco Ball", "Pixel Flashbang", "Skullbang", "Shining Star"},
    ["Medkit"] = {"Briefcase", "Laptop", "Medkitty"},
    ["War Horn"] = {"Trumpet", "Mammoth Horn", "Megaphone", "Air Horn", "Boneclaw Horn"},
    ["Wildcat"] = {"Plasma Wildcat", "Glorious Wildcat"},
    ["Warpstone"] = {"Cyber Warpstone", "Electropunk Warpstone"},
    ["Permafrost"] = {"Snowman Permafrost", "Starforge Permafrost", "Temporal Permafrost"},
    ["Distortion"] = {"Plasma Distortion", "Magma Distortion", "Cyber Distortion", "Sleighstortion"},
    ["Maul"] = {"Starforge Maul", "Sleigh Maul", "Clown Hammer"},
    ["Spear"] = {"Thunderpike", "Fishing Rod"},
    ["Satchel"] = {"Advanced Satchel", "Notebook Satchel", "Potion Satchel", "Bag o' Money"},
    ["Grappler"] = {"Arcade Claw"},
    ["Jump Pad"] = {"Trampoline", "Bounce House"},
    ["Warper"] = {"Arcane Warper", "Glitter Warper", "Frost Warper", "Warpeye", "Warpbone"},
}

local WEAPON_LIST = {"None"}
for weapon, _ in pairs(WEAPON_SKINS) do table.insert(WEAPON_LIST, weapon) end
table.sort(WEAPON_LIST)

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
    if not skinModel then 
        debugPrint("Skin not found: " .. skinName)
        return false 
    end

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
-- Preview (Fixed - parented to ContentHost)
-- ============================================================

local function createPreview()
    -- Find the main GUI's Content frame
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local mainGui = playerGui:FindFirstChild("RivalsModularGUI")
    if not mainGui then 
        debugPrint("ERROR: Main GUI not found")
        return 
    end

    local menu = mainGui:FindFirstChild("Menu")
    if not menu then 
        debugPrint("ERROR: Menu not found")
        return 
    end

    local content = menu:FindFirstChild("Content")
    if not content then 
        debugPrint("ERROR: Content not found")
        return 
    end

    previewFrame = Instance.new("Frame")
    previewFrame.Name = "SkinPreview"
    previewFrame.Size = UDim2.new(0, 180, 0, 220)
    previewFrame.Position = UDim2.new(1, -190, 0, 10)
    previewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    previewFrame.BorderSizePixel = 0
    previewFrame.Visible = false
    previewFrame.ZIndex = 50
    previewFrame.Parent = content

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
    title.ZIndex = 51
    title.Parent = previewFrame

    previewViewport = Instance.new("ViewportFrame")
    previewViewport.Size = UDim2.new(1, -12, 1, -60)
    previewViewport.Position = UDim2.new(0, 6, 0, 28)
    previewViewport.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    previewViewport.BackgroundTransparency = 0
    previewViewport.BorderSizePixel = 0
    previewViewport.ZIndex = 51
    previewViewport.Parent = previewFrame

    local vpCorner = Instance.new("UICorner")
    vpCorner.CornerRadius = UDim.new(0, 8)
    vpCorner.Parent = previewViewport

    previewCamera = Instance.new("Camera")
    previewCamera.Parent = previewViewport
    previewViewport.CurrentCamera = previewCamera

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
    disclaimer.ZIndex = 51
    disclaimer.Parent = previewFrame

    debugPrint("Preview created")
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
    local distance = maxDim * 0.7

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
        local distance = maxDim * 0.7
        local angle = previewRotation
        local x = math.cos(angle) * distance
        local z = math.sin(angle) * distance

        previewCamera.CFrame = CFrame.new(
            center + Vector3.new(x, distance * 0.5, z),
            center
        )
    end)
end

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

    task.delay(0.5, function()
        getWeaponsFolder()
        getAllSkinCases()
        createPreview()
        startPreviewRotation()
        startTabChecker()
    end)

    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        GUI.AddSection(page, "Skin Changer", 1)

        GUI.AddDropdown(page, "Weapon",
            function() return WEAPON_LIST end,
            function() return selectedWeapon end,
            function(v)
                selectedWeapon = v
                if v ~= "None" and WEAPON_SKINS[v] then
                    skinOptions = WEAPON_SKINS[v]
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
                if selectedWeapon ~= "None" and v ~= "None" then
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
    if previewFrame then
        previewFrame:Destroy()
    end
end

return Skins