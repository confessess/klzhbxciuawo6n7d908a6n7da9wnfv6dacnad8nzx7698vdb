-- ============================================================
-- Rivals Modular -- Skins (Working version)
-- Based on gwnrdt method - proper skin swapping
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService

-- State
local weaponsFolder = nil
local skinCases = {}
local originalWeapons = {}  -- Store originals per weapon
local currentSkins = {}     -- Current applied skins

-- Dropdown state
local selectedWeapon = "None"
local selectedSkin = "None"
local skinOptions = {"Select a weapon first"}

local SKINS_FILE = "RivalsModular/skins.json"

-- ============================================================
-- Core Functions
-- ============================================================

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

-- Find which weapon a skin belongs to by checking if parts match
local function findWeaponForSkin(skinName)
    local folder = getWeaponsFolder()
    if not folder then return nil end

    -- Search all cases for this skin
    local skinModel = nil
    for _, case in ipairs(getAllSkinCases()) do
        local found = case:FindFirstChild(skinName)
        if found then
            skinModel = found
            break
        end
    end
    if not skinModel then return nil end

    -- Get skin children names
    local skinParts = {}
    for _, child in ipairs(skinModel:GetChildren()) do
        table.insert(skinParts, child.Name)
    end

    -- Find weapon with matching parts
    for _, weapon in ipairs(folder:GetChildren()) do
        if weapon:IsA("Folder") or weapon:IsA("Model") then
            local weaponParts = {}
            for _, child in ipairs(weapon:GetChildren()) do
                table.insert(weaponParts, child.Name)
            end

            -- Check if all skin parts exist in weapon
            local match = true
            for _, skinPart in ipairs(skinParts) do
                local found = false
                for _, weaponPart in ipairs(weaponParts) do
                    if skinPart == weaponPart then
                        found = true
                        break
                    end
                end
                if not found then
                    match = false
                    break
                end
            end

            if match and #skinParts > 0 then
                return weapon.Name
            end
        end
    end

    return nil
end

-- Get all skins for a weapon
local function getSkinsForWeapon(weaponName)
    local skins = {}
    local folder = getWeaponsFolder()
    if not folder then return skins end

    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return skins end

    -- Get weapon part names
    local weaponParts = {}
    for _, child in ipairs(weapon:GetChildren()) do
        table.insert(weaponParts, child.Name)
    end

    -- Search all cases for matching skins
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

-- Save original weapon state
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
    debugPrint("Saved original: " .. weaponName)
end

-- Apply skin to weapon
local function applySkin(weaponName, skinName)
    debugPrint("Applying: " .. weaponName .. " -> " .. skinName)

    local folder = getWeaponsFolder()
    if not folder then
        debugPrint("ERROR: No weapons folder")
        return false
    end

    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then
        debugPrint("ERROR: Weapon not found: " .. weaponName)
        return false
    end

    -- Find skin model
    local skinModel = nil
    for _, case in ipairs(getAllSkinCases()) do
        local found = case:FindFirstChild(skinName)
        if found then
            skinModel = found
            break
        end
    end

    if not skinModel then
        debugPrint("ERROR: Skin not found: " .. skinName)
        return false
    end

    -- Save original first
    saveOriginal(weaponName)

    -- Clear and apply
    weapon:ClearAllChildren()
    for _, child in ipairs(skinModel:GetChildren()) do
        child:Clone().Parent = weapon
    end

    currentSkins[weaponName] = skinName
    debugPrint("SUCCESS!")
    return true
end

-- Reset weapon to original
local function resetWeapon(weaponName)
    debugPrint("Resetting: " .. weaponName)

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
        debugPrint("Reset complete")
    end
end

-- Refresh viewmodel by re-equipping
local function refreshViewModel()
    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Find equipped tool
    local equipped = nil
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            equipped = child
            break
        end
    end

    -- Unequip and re-equip
    humanoid:UnequipTools()
    task.wait(0.1)

    if equipped then
        humanoid:EquipTool(equipped)
    end
end

-- Save/Load
local function saveSkins()
    pcall(function()
        if writefile then
            writefile(SKINS_FILE, HttpService:JSONEncode(currentSkins))
        end
    end)
end

local function loadSkins()
    pcall(function()
        if isfile and isfile(SKINS_FILE) then
            local data = HttpService:JSONDecode(readfile(SKINS_FILE))
            if data then
                for weapon, skin in pairs(data) do
                    applySkin(weapon, skin)
                end
            end
        end
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

    -- Build weapon list
    local weaponList = {"None"}
    local folder = getWeaponsFolder()
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                if child.Name ~= "Unobtainable" then
                    table.insert(weaponList, child.Name)
                end
            end
        end
    end
    table.sort(weaponList)

    -- Init
    task.delay(0.5, function()
        getWeaponsFolder()
        getAllSkinCases()
        -- Don't auto-load, let user pick
    end)

    -- Register GUI
    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        GUI.AddSection(page, "Skin Changer", 1)

        -- Weapon dropdown
        GUI.AddDropdown(page, "Weapon",
            function() return weaponList end,
            function() return selectedWeapon end,
            function(v)
                selectedWeapon = v
                debugPrint("Weapon: " .. v)
                if v ~= "None" then
                    skinOptions = getSkinsForWeapon(v)
                    if #skinOptions == 0 then
                        skinOptions = {"No skins found"}
                    end
                    selectedSkin = "None"
                else
                    skinOptions = {"Select a weapon first"}
                    selectedSkin = "None"
                end
            end, 2)

        -- Skin dropdown
        GUI.AddDropdown(page, "Skin",
            function() return skinOptions end,
            function() return selectedSkin end,
            function(v)
                selectedSkin = v
                debugPrint("Skin: " .. v)
                if selectedWeapon ~= "None" and v ~= "None" and v ~= "No skins found" then
                    local success = applySkin(selectedWeapon, v)
                    if success then
                        saveSkins()
                        task.spawn(function()
                            refreshViewModel()
                        end)
                    end
                end
            end, 3)

        -- Reset button
        GUI.AddButton(page, "Reset Weapon",
            function()
                if selectedWeapon ~= "None" then
                    resetWeapon(selectedWeapon)
                    saveSkins()
                    task.spawn(function()
                        refreshViewModel()
                    end)
                end
            end, 4, true)

        -- Reset all
        GUI.AddButton(page, "Reset All Skins",
            function()
                for weapon, _ in pairs(currentSkins) do
                    resetWeapon(weapon)
                end
                saveSkins()
                task.spawn(function()
                    refreshViewModel()
                end)
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