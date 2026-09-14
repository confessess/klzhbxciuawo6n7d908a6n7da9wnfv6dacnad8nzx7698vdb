-- ============================================================
-- Rivals Modular -- Skins (Fixed with viewmodel refresh)
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService

local WEAPON_SKINS = {
    ["Assault Rifle"] = {"AK-47", "AKEY-47", "Boneclaw Rifle", "AUG", "Phoenix Rifle", "Gingerbread AUG", "Tommy Gun", "Keyper", "Hyper Sniper", "Pixel Sniper"},
    ["Battle Axe"] = {"The Shred", "Nordic Axe", "Ban Axe"},
    ["Bow"] = {"Bat Bow"},
    ["Burst Rifle"] = {"Aqua Burst", "Electro Rifle", "Pixel Burst", "Pine Burst", "Spectral Burst"},
    ["Chainsaw"] = {"Blobsaw"},
    ["Crossbow"] = {"Frostbite Crossbow", "Pixel Crossbow", "Harpoon Crossbow"},
    ["Daggers"] = {"Aces", "Cookies"},
    ["Energy Rifle"] = {"2025 Energy Rifle", "Apex Rifle", "Hacker Rifle", "Hydro Rifle"},
    ["Energy Pistols"] = {"2025 Energy Pistols", "Apex Pistols", "Hacker Pistols", "Void Pistols"},
    ["Exogun"] = {"Ray Gun", "Singularity", "Wondergun", "Midnight Festive Exogun", "Exogourd"},
    ["Fists"] = {"Boxing Gloves", "Brass Knuckles", "Pumpkin Claws", "Festive Fists"},
    ["Flamethrower"] = {"Lamethrower", "Pixel Flamethrower", "Snowblower", "Jack O'Thrower"},
    ["Flare Gun"] = {"Dynamite Gun", "Firework Gun", "Wrapped Flare Gun", "Vexed Flare Gun"},
    ["Freeze Ray"] = {"Bubble Ray", "Temporal Ray", "Spider Ray", "Wrapped Freeze Ray"},
    ["Grenade"] = {"Water Balloon", "Whoopee Cushion", "Soul Grenade", "Jingle Grenade", "Dynamite"},
    ["Grenade Launcher"] = {"Swashbuckler", "Uranium Launcher", "Skull Launcher", "Snowball Launcher"},
    ["Gunblade"] = {"Hyper Gunblade", "Elf's Gunblade", "Crude Gunblade"},
    ["Handgun"] = {"Blaster", "Pixel Handgun", "Pumpkin Handgun", "Gingerbread Handgun", "Gumball Handgun"},
    ["Katana"] = {"Lightning Bolt", "Saber", "Pixel Katana", "Devil's Trident", "2025 Katana", "Keytana", "Stellar Katana"},
    ["Knife"] = {"Chancla", "Karambit", "Machete", "Candy Cane"},
    ["Minigun"] = {"Lasergun 3000", "Pixel Minigun", "Wrapped Minigun", "Pumpkin Minigun"},
    ["Molotov"] = {"Coffee", "Torch", "Hexxed Candle", "Hot Coals"},
    ["Paintball Gun"] = {"Boba Gun", "Slime Gun", "Snowball Gun", "Brain Gun"},
    ["Revolver"] = {"Boneclaw Revolver"},
    ["RPG"] = {"Nuke Launcher"},
    ["Riot Shield"] = {"Door", "Sled"},
    ["Scythe"] = {"Anchor", "Keythe", "Scythe of Death", "Bat Scythe", "Cryo Scythe"},
    ["Shorty"] = {"Lovely Shorty", "Not So Shorty", "Too Shorty", "Demon Shorty", "Wrapped Shorty", "Balloon Shorty"},
    ["Shotgun"] = {"Balloon Shotgun", "Hyper Shotgun", "Wrapped Shotgun", "Broomstick", "Cactus Shotgun"},
    ["Slingshot"] = {"Goalpost", "Stick", "Reindeer Slingshot", "Boneshot"},
    ["Smoke Grenade"] = {"Balance", "Emoji Cloud", "Eyeball", "Snowglobe"},
    ["Sniper"] = {"Hyper Sniper", "Pixel Sniper", "Keyper", "Gingerbread Sniper", "Eyething Sniper"},
    ["Subspace Tripmine"] = {"Don't Press", "Spring", "Dev-in-the-Box", "Trick or Treat"},
    ["Spray"] = {"Lovely Spray", "Pine Spray"},
    ["Trowel"] = {"Garden Shovel", "Plastic Shovel", "Snow Shovel", "Pumpkin Carver"},
    ["Uzi"] = {"Electro Uzi", "Water Uzi", "Pine Uzi", "Demon Uzi"},
    ["Flashbang"] = {"Camera", "Disco Ball", "Pixel Flashbang", "Skullbang", "Shining Star"},
    ["Medkit"] = {"Briefcase", "Laptop", "Medkitty"},
    ["War Horn"] = {"Trumpet", "Mammoth Horn"},
}

local originalGuns = {}
local appliedSkins = {}
local selectedSkins = {}
local skinCases = {}
local weaponsFolder = nil

local SKINS_FILE = "RivalsModular/WeaponSkins.json"

local currentWeapon = "None"
local currentSkinList = {"Select a weapon first"}
local currentSkin = nil

local function debugPrint(msg)
    print("[skins] " .. msg)
end

local function getWeaponsFolder()
    if weaponsFolder then return weaponsFolder end
    local ok, result = pcall(function()
        return LocalPlayer.PlayerScripts.Assets.ViewModels.Weapons
    end)
    if ok and result then weaponsFolder = result end
    return weaponsFolder
end

local function getSkinCases()
    if #skinCases > 0 then return skinCases end
    local ok, viewModels = pcall(function()
        return LocalPlayer.PlayerScripts.Assets.ViewModels
    end)
    if not ok or not viewModels then return skinCases end
    local names = {"Spooky Skin Case", "Skin Case 2", "Skin Case 3", "Skin Case", "Other", "Festive Skin Case"}
    for _, name in ipairs(names) do
        local ok2, case = pcall(function() return viewModels:FindFirstChild(name) end)
        if ok2 and case then table.insert(skinCases, case) end
    end
    return skinCases
end

local function saveOriginal(weaponName)
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return end
    if not originalGuns[weaponName] then
        originalGuns[weaponName] = {}
        for _, child in pairs(weapon:GetChildren()) do
            table.insert(originalGuns[weaponName], child:Clone())
        end
    end
end

local function restoreOriginal(weaponName)
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return end
    if originalGuns[weaponName] then
        weapon:ClearAllChildren()
        for _, child in pairs(originalGuns[weaponName]) do
            child.Parent = weapon
        end
        originalGuns[weaponName] = nil
    end
end

local function applySkin(weaponName, skinName)
    debugPrint("Applying: " .. weaponName .. " -> " .. skinName)
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return end

    local skinModel = nil
    for _, case in ipairs(getSkinCases()) do
        local found = case:FindFirstChild(skinName)
        if found then skinModel = found break end
    end
    if not skinModel then
        debugPrint("ERROR: Skin not found")
        return
    end

    saveOriginal(weaponName)
    weapon:ClearAllChildren()
    for _, child in pairs(skinModel:GetChildren()) do
        child:Clone().Parent = weapon
    end
    appliedSkins[weaponName] = true
    debugPrint("Success!")
end

local function refreshViewModel()
    debugPrint("Refreshing viewmodel...")
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Store currently equipped tool
    local equippedTool = nil
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            equippedTool = child
            break
        end
    end

    -- Unequip all
    humanoid:UnequipTools()
    task.wait(0.1)

    -- Re-equip if there was one
    if equippedTool then
        humanoid:EquipTool(equippedTool)
    else
        -- Equip first tool in backpack
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end
    debugPrint("Viewmodel refreshed")
end

local function saveSettings()
    pcall(function()
        if writefile then writefile(SKINS_FILE, HttpService:JSONEncode({selectedSkins = selectedSkins})) end
    end)
end

local function loadSettings()
    pcall(function()
        if isfile and isfile(SKINS_FILE) then
            local data = HttpService:JSONDecode(readfile(SKINS_FILE))
            if data and data.selectedSkins then
                selectedSkins = data.selectedSkins
                for weapon, skin in pairs(selectedSkins) do
                    if WEAPON_SKINS[weapon] and table.find(WEAPON_SKINS[weapon], skin) then
                        applySkin(weapon, skin)
                    end
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
        getWeaponsFolder()
        getSkinCases()
        loadSettings()
    end)

    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        local weaponList = {"None"}
        for weapon, _ in pairs(WEAPON_SKINS) do table.insert(weaponList, weapon) end
        table.sort(weaponList)

        GUI.AddSection(page, "Skin Changer", 1)

        GUI.AddDropdown(page, "Weapon",
            function() return weaponList end,
            function() return currentWeapon end,
            function(v)
                currentWeapon = v
                debugPrint("Weapon: " .. v)
                if v ~= "None" and WEAPON_SKINS[v] then
                    currentSkinList = WEAPON_SKINS[v]
                    currentSkin = selectedSkins[v] or WEAPON_SKINS[v][1]
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
                debugPrint("Skin: " .. v)
                if currentWeapon ~= "None" then
                    selectedSkins[currentWeapon] = v
                    applySkin(currentWeapon, v)
                    saveSettings()
                    -- Refresh viewmodel to show new skin
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
    end

    print("[rivals] Skins module initialized.")
end

function Skins.Cleanup()
    for weaponName, _ in pairs(appliedSkins) do restoreOriginal(weaponName) end
end

return Skins