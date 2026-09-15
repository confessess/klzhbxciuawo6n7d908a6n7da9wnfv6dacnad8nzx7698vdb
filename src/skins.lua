-- ============================================================
-- Rivals Modular -- Skins (Debug version)
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService

local WEAPON_LIST = {
    "None", "Assault Rifle", "Battle Axe", "Bow", "Burst Rifle", "Chainsaw",
    "Crossbow", "Daggers", "Energy Rifle", "Energy Pistols", "Exogun", "Fists",
    "Flamethrower", "Flare Gun", "Freeze Ray", "Grenade", "Grenade Launcher",
    "Gunblade", "Handgun", "Katana", "Knife", "Minigun", "Molotov",
    "Paintball Gun", "Revolver", "RPG", "Riot Shield", "Scythe", "Shorty",
    "Shotgun", "Slingshot", "Smoke Grenade", "Sniper", "Subspace Tripmine",
    "Spray", "Trowel", "Uzi", "Flashbang", "Medkit", "War Horn"
}

local trueOriginals = {}
local appliedSkins = {}
local selectedSkins = {}
local skinCases = {}
local weaponsFolder = nil
local wrapConfig = {}
local wrapWeapons = {}
local wrapList = {}

local SKINS_FILE = "RivalsModular/WeaponSkins.json"
local WRAPS_FILE = "RivalsModular/WrapChanger.json"

local currentWeapon = "None"
local currentSkinList = {"Select a weapon first"}
local currentSkin = nil
local currentWrapWeapon = "none"
local currentWrapList = {"none"}
local currentWrap = "none"

local function debugPrint(msg)
    print("[skins] " .. msg)
end

local function getWeaponsFolder()
    if weaponsFolder then return weaponsFolder end
    local ok, result = pcall(function()
        return LocalPlayer.PlayerScripts.Assets.ViewModels.Weapons
    end)
    if ok and result then
        weaponsFolder = result
        debugPrint("Found weapons folder")
    else
        debugPrint("ERROR: Weapons folder not found")
    end
    return weaponsFolder
end

local function getSkinCases()
    if #skinCases > 0 then return skinCases end
    local ok, viewModels = pcall(function()
        return LocalPlayer.PlayerScripts.Assets.ViewModels
    end)
    if not ok or not viewModels then
        debugPrint("ERROR: ViewModels not found")
        return skinCases
    end

    for _, child in ipairs(viewModels:GetChildren()) do
        if child:IsA("Folder") and child.Name ~= "Weapons" then
            table.insert(skinCases, child)
        end
    end
    debugPrint("Found " .. #skinCases .. " skin cases")
    return skinCases
end

local function findSkinsForWeapon(weaponName)
    local skins = {}
    local folder = getWeaponsFolder()
    if not folder then
        debugPrint("ERROR: No weapons folder in findSkins")
        return skins
    end

    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then
        debugPrint("ERROR: Weapon not found: " .. weaponName)
        return skins
    end

    local originalNames = {}
    local originalCount = 0
    for _, child in ipairs(weapon:GetChildren()) do
        table.insert(originalNames, child.Name)
        originalCount = originalCount + 1
    end

    debugPrint("Weapon " .. weaponName .. " has " .. originalCount .. " children")

    if originalCount == 0 then
        debugPrint("ERROR: Weapon has no children")
        return skins
    end

    for _, case in ipairs(getSkinCases()) do
        for _, skin in ipairs(case:GetChildren()) do
            local skinChildren = skin:GetChildren()
            local skinCount = #skinChildren

            if skinCount == originalCount then
                local matchCount = 0
                for _, skinChild in ipairs(skinChildren) do
                    for _, origName in ipairs(originalNames) do
                        if skinChild.Name == origName then
                            matchCount = matchCount + 1
                            break
                        end
                    end
                end

                if matchCount == originalCount then
                    table.insert(skins, skin.Name)
                end
            end
        end
    end

    debugPrint("Found " .. #skins .. " skins for " .. weaponName)
    table.sort(skins)
    return skins
end

local function saveOriginal(weaponName)
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return end

    if not trueOriginals[weaponName] then
        trueOriginals[weaponName] = {}
        for _, child in pairs(weapon:GetChildren()) do
            table.insert(trueOriginals[weaponName], child:Clone())
        end
        debugPrint("Saved original: " .. weaponName .. " (" .. #trueOriginals[weaponName] .. " parts)")
    end
end

local function restoreOriginal(weaponName)
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return end

    if trueOriginals[weaponName] then
        weapon:ClearAllChildren()
        for _, child in pairs(trueOriginals[weaponName]) do
            child.Parent = weapon
        end
        debugPrint("Restored: " .. weaponName)
    end

    appliedSkins[weaponName] = nil
end

local function applySkin(weaponName, skinName)
    debugPrint("=== APPLY SKIN ===")
    debugPrint("Weapon: " .. weaponName)
    debugPrint("Skin: " .. skinName)

    local folder = getWeaponsFolder()
    if not folder then
        debugPrint("ERROR: No weapons folder")
        return
    end

    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then
        debugPrint("ERROR: Weapon not found: " .. weaponName)
        return
    end

    local skinModel = nil
    for _, case in ipairs(getSkinCases()) do
        local found = case:FindFirstChild(skinName)
        if found then
            skinModel = found
            debugPrint("Found skin in case: " .. case.Name)
            break
        end
    end

    if not skinModel then
        debugPrint("ERROR: Skin not found: " .. skinName)
        return
    end

    saveOriginal(weaponName)

    weapon:ClearAllChildren()
    for _, child in pairs(skinModel:GetChildren()) do
        child:Clone().Parent = weapon
    end

    appliedSkins[weaponName] = true
    debugPrint("SUCCESS! Applied " .. skinName .. " to " .. weaponName)
end

local function refreshViewModel()
    debugPrint("Refreshing viewmodel...")
    local character = LocalPlayer.Character
    if not character then
        debugPrint("ERROR: No character")
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        debugPrint("ERROR: No humanoid")
        return
    end

    local equippedTool = nil
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            equippedTool = child
            break
        end
    end

    humanoid:UnequipTools()
    task.wait(0.1)

    if equippedTool then
        humanoid:EquipTool(equippedTool)
        debugPrint("Re-equipped: " .. equippedTool.Name)
    else
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    humanoid:EquipTool(tool)
                    debugPrint("Equipped from backpack: " .. tool.Name)
                    break
                end
            end
        end
    end
end

local function saveSettings()
    pcall(function()
        if writefile then writefile(SKINS_FILE, HttpService:JSONEncode({selectedSkins = selectedSkins})) end
    end)
end

local function getWrapWeapons()
    if #wrapWeapons > 0 then return wrapWeapons end
    local folder = getWeaponsFolder()
    if not folder then return wrapWeapons end
    local skip = {["Unobtainable"] = true}
    for _, child in ipairs(folder:GetChildren()) do
        if not skip[child.Name] and child:IsA("Folder") then
            table.insert(wrapWeapons, child.Name)
        end
    end
    table.sort(wrapWeapons, function(a, b) return a:lower() < b:lower() end)
    return wrapWeapons
end

local function getWrapList()
    if #wrapList > 0 then return wrapList end
    local ok, wraps = pcall(function() return LocalPlayer.PlayerScripts.Assets.WrapTextures:GetChildren() end)
    if ok and wraps then
        for _, wrap in ipairs(wraps) do
            if wrap:IsA("Folder") or wrap:IsA("Model") then
                table.insert(wrapList, wrap.Name)
            end
        end
        table.sort(wrapList, function(a, b) return a:lower() < b:lower() end)
    end
    table.insert(wrapList, 1, "none")
    return wrapList
end

local function applyWrap(weaponName, wrapName)
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return end

    for _, desc in ipairs(weapon:GetDescendants()) do
        if desc:IsA("BasePart") then
            for _, child in ipairs(desc:GetChildren()) do
                if child:IsA("Texture") then child:Destroy() end
            end
        end
    end

    if wrapName ~= "none" then
        local ok, wrapFolder = pcall(function()
            return LocalPlayer.PlayerScripts.Assets.WrapTextures:FindFirstChild(wrapName)
        end)
        if ok and wrapFolder then
            for _, tex in ipairs(wrapFolder:GetChildren()) do
                if tex:IsA("Texture") then
                    for _, desc in ipairs(weapon:GetDescendants()) do
                        if desc:IsA("BasePart") then
                            tex:Clone().Parent = desc
                        end
                    end
                end
            end
        end
    end
    wrapConfig[weaponName] = wrapName
end

local function saveWrapSettings()
    pcall(function()
        if writefile then writefile(WRAPS_FILE, HttpService:JSONEncode(wrapConfig)) end
    end)
end

local function loadWrapSettings()
    pcall(function()
        if isfile and isfile(WRAPS_FILE) then
            local data = HttpService:JSONDecode(readfile(WRAPS_FILE))
            if data then
                wrapConfig = data
                for weapon, wrap in pairs(wrapConfig) do
                    applyWrap(weapon, wrap)
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

    task.delay(0.5, function()
        debugPrint("=== INIT ===")
        getWeaponsFolder()
        getSkinCases()
        loadWrapSettings()
    end)

    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        GUI.AddSection(page, "Skin Changer", 1)

        GUI.AddDropdown(page, "Weapon",
            function() return WEAPON_LIST end,
            function() return currentWeapon end,
            function(v)
                currentWeapon = v
                debugPrint("Selected weapon: " .. v)
                if v ~= "None" then
                    currentSkinList = findSkinsForWeapon(v)
                    if #currentSkinList == 0 then
                        currentSkinList = {"No skins found"}
                        currentSkin = nil
                    else
                        currentSkin = nil
                    end
                else
                    currentSkinList = {"Select a weapon first"}
                    currentSkin = nil
                end
            end, 2)

        GUI.AddDropdown(page, "Skin",
            function() return currentSkinList end,
            function() return currentSkin end,
            function(v)
                currentSkin = v
                debugPrint("Selected skin: " .. v)
                if currentWeapon ~= "None" and v ~= "No skins found" then
                    selectedSkins[currentWeapon] = v
                    applySkin(currentWeapon, v)
                    saveSettings()
                    task.spawn(function()
                        refreshViewModel()
                    end)
                end
            end, 3)

        GUI.AddButton(page, "Reset Skins",
            function()
                for weaponName, _ in pairs(appliedSkins) do restoreOriginal(weaponName) end
                appliedSkins = {}
                selectedSkins = {}
                saveSettings()
                task.spawn(function()
                    refreshViewModel()
                end)
            end, 4, true)

        GUI.AddSection(page, "Wrap Changer", 5)

        GUI.AddDropdown(page, "Weapon",
            function()
                local list = {"none"}
                for _, w in ipairs(getWrapWeapons()) do table.insert(list, w) end
                return list
            end,
            function() return currentWrapWeapon end,
            function(v)
                currentWrapWeapon = v
                debugPrint("Wrap weapon: " .. v)
            end, 6)

        GUI.AddDropdown(page, "Wrap",
            function() return getWrapList() end,
            function() return currentWrap end,
            function(v)
                currentWrap = v
                debugPrint("Wrap: " .. v)
                if currentWrapWeapon ~= "none" then
                    applyWrap(currentWrapWeapon, v)
                    saveWrapSettings()
                end
            end, 7)

        GUI.AddButton(page, "Clear All Wraps",
            function()
                for weaponName, _ in pairs(wrapConfig) do
                    applyWrap(weaponName, "none")
                end
                wrapConfig = {}
                saveWrapSettings()
            end, 8, true)
    end

    print("[rivals] Skins module initialized.")
end

function Skins.Cleanup()
    for weaponName, _ in pairs(appliedSkins) do restoreOriginal(weaponName) end
end

return Skins