-- ============================================================
-- Rivals Modular -- Skins (Proper mapping + Wrap Changer)
-- Based on actual game data
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService

-- Correct skin-to-weapon mapping based on actual game files
local WEAPON_SKINS = {
    ["Assault Rifle"] = {"AK-47", "Boneclaw Rifle", "Augmented Rifle", "Gingerbread Augmented Rifle", "Soul Rifle"},
    ["Battle Axe"] = {"The Shred", "Nordic Axe", "Ban Axe", "Cerulean Axe", "Mimic Axe"},
    ["Bow"] = {"Bat Bow", "Compound Bow", "Raven Bow", "Dream Bow", "Frostbite Bow"},
    ["Burst Rifle"] = {"Aqua Burst", "Electro Rifle", "Pixel Burst", "Pine Burst", "Spectral Burst", "Bullpup Burst"},
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
    ["Paintball Gun"] = {"Boba Gun", "Slime Gun", "Snowball Gun", "Brain Gun", "Ketchup Gun", "Peppergun", "Paintbrush"},
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
    ["Spray"] = {"Lovely Spray", "Pine Spray", "Boneclaw Spray", "Spray Bottle"},
    ["Trowel"] = {"Garden Shovel", "Plastic Shovel", "Snow Shovel", "Pumpkin Carver"},
    ["Uzi"] = {"Electro Uzi", "Water Uzi", "Pine Uzi", "Demon Uzi"},
    ["Flashbang"] = {"Camera", "Disco Ball", "Pixel Flashbang", "Skullbang", "Shining Star"},
    ["Medkit"] = {"Briefcase", "Laptop", "Medkitty"},
    ["War Horn"] = {"Trumpet", "Mammoth Horn", "Megaphone", "Air Horn", "Boneclaw Horn"},
}

local WEAPON_LIST = {"None"}
for weapon, _ in pairs(WEAPON_SKINS) do table.insert(WEAPON_LIST, weapon) end
table.sort(WEAPON_LIST)

-- State
local originalGuns = {}
local appliedSkins = {}
local selectedSkins = {}
local skinCases = {}
local weaponsFolder = nil
local wrapConfig = {}
local wrapWeapons = {}
local wrapList = {}

local SKINS_FILE = "RivalsModular/WeaponSkins.json"
local WRAPS_FILE = "RivalsModular/WrapChanger.json"

-- Shared state for dropdowns
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
    if ok and result then weaponsFolder = result end
    return weaponsFolder
end

local function getSkinCases()
    if #skinCases > 0 then return skinCases end
    local ok, viewModels = pcall(function()
        return LocalPlayer.PlayerScripts.Assets.ViewModels
    end)
    if not ok or not viewModels then return skinCases end

    for _, child in ipairs(viewModels:GetChildren()) do
        if child:IsA("Folder") and child.Name ~= "Weapons" then
            table.insert(skinCases, child)
        end
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
    if not weapon then
        debugPrint("ERROR: Weapon not found")
        return
    end

    local skinModel = nil
    for _, case in ipairs(getSkinCases()) do
        local found = case:FindFirstChild(skinName)
        if found then
            skinModel = found
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
    debugPrint("Success!")
end

local function refreshViewModel()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

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
    else
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
                    applySkin(weapon, skin)
                end
            end
        end
    end)
end

-- Wrap changer
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
        getWeaponsFolder()
        getSkinCases()
        loadSettings()
        loadWrapSettings()
    end)

    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        GUI.AddSection(page, "Skin Changer", 1)

        -- Weapon dropdown
        GUI.AddDropdown(page, "Weapon",
            function() return WEAPON_LIST end,
            function() return currentWeapon end,
            function(v)
                currentWeapon = v
                debugPrint("Weapon: " .. v)
                if v ~= "None" and WEAPON_SKINS[v] then
                    currentSkinList = WEAPON_SKINS[v]
                    currentSkin = selectedSkins[v] or currentSkinList[1]
                else
                    currentSkinList = {"Select a weapon first"}
                    currentSkin = nil
                end
            end, 2)

        -- Skin dropdown
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
                    task.spawn(function()
                        refreshViewModel()
                    end)
                end
            end, 3)

        -- Reset button
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

        -- Wrap changer section
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