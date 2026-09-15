-- ============================================================
-- Rivals Modular -- Skins (Real-time refresh)
-- Forces viewmodel reload without rejoining
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService

local weaponsFolder = nil
local skinCases = {}
local originalWeapons = {}
local currentSkins = {}

local selectedWeapon = "None"
local selectedSkin = "None"
local skinOptions = {"Select a weapon first"}

local SKINS_FILE = "RivalsModular/skins.json"

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

-- FORCE VIEWMODEL RELOAD
local function forceViewModelReload()
    debugPrint("Forcing viewmodel reload...")

    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Method 1: Find and rebuild ClientViewModel
    local ok, vm = pcall(function()
        return LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel
    end)

    if ok and vm then
        debugPrint("Found ClientViewModel, rebuilding...")

        -- Clear the viewmodel children to force rebuild
        for _, child in ipairs(vm:GetChildren()) do
            if child.Name:find("Assault Rifle") or child.Name:find("AK%-47") or 
               child.Name:find("Boneclaw") or child.Name:find("Augmented") then
                child:Destroy()
                debugPrint("Destroyed old viewmodel: " .. child.Name)
            end
        end
    end

    -- Method 2: Re-equip current weapon
    local equipped = nil
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            equipped = child
            break
        end
    end

    if equipped then
        debugPrint("Re-equipping: " .. equipped.Name)
        humanoid:UnequipTools()
        task.wait(0.2)
        humanoid:EquipTool(equipped)
    end

    debugPrint("Reload complete")
end

local function saveSkins()
    pcall(function()
        if writefile then
            writefile(SKINS_FILE, HttpService:JSONEncode(currentSkins))
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
                else
                    skinOptions = {"Select a weapon first"}
                    selectedSkin = "None"
                end
            end, 2)

        GUI.AddDropdown(page, "Skin",
            function() return skinOptions end,
            function() return selectedSkin end,
            function(v)
                selectedSkin = v
                if selectedWeapon ~= "None" and v ~= "None" and v ~= "No skins found" then
                    local success = applySkin(selectedWeapon, v)
                    if success then
                        saveSkins()
                        -- Auto refresh after applying
                        task.spawn(function()
                            task.wait(0.1)
                            forceViewModelReload()
                        end)
                    end
                end
            end, 3)

        -- Manual refresh button
        GUI.AddButton(page, "Refresh Viewmodel",
            function()
                task.spawn(function()
                    forceViewModelReload()
                end)
            end, 4, false)

        GUI.AddButton(page, "Reset Weapon",
            function()
                if selectedWeapon ~= "None" then
                    resetWeapon(selectedWeapon)
                    saveSkins()
                    task.spawn(function()
                        forceViewModelReload()
                    end)
                end
            end, 5, true)

        GUI.AddButton(page, "Reset All",
            function()
                for weapon, _ in pairs(currentSkins) do
                    resetWeapon(weapon)
                end
                saveSkins()
                task.spawn(function()
                    forceViewModelReload()
                end)
            end, 6, true)
    end

    print("[rivals] Skins module initialized.")
end

function Skins.Cleanup()
    for weapon, _ in pairs(currentSkins) do
        resetWeapon(weapon)
    end
end

return Skins