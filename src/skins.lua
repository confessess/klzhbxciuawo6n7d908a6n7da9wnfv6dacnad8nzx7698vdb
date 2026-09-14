-- ============================================================
-- Rivals Modular -- Skins (Fixed with debug)
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
local wrapConfig = {}
local wrapWeapons = {}
local wrapList = {}

local SKINS_FILE = "RivalsModular/WeaponSkins.json"
local WRAPS_FILE = "RivalsModular/WrapChanger.json"

-- Debug function
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
        debugPrint("Found weapons folder: " .. weaponsFolder:GetFullName())
    else
        debugPrint("ERROR: Could not find Weapons folder")
    end
    return weaponsFolder
end

local function getSkinCases()
    if #skinCases > 0 then return skinCases end
    local ok, viewModels = pcall(function()
        return LocalPlayer.PlayerScripts.Assets.ViewModels
    end)
    if not ok or not viewModels then
        debugPrint("ERROR: Could not find ViewModels")
        return skinCases
    end
    local names = {"Spooky Skin Case", "Skin Case 2", "Skin Case 3", "Skin Case", "Other", "Festive Skin Case"}
    for _, name in ipairs(names) do
        local ok2, case = pcall(function() return viewModels:FindFirstChild(name) end)
        if ok2 and case then
            table.insert(skinCases, case)
            debugPrint("Found skin case: " .. name)
        end
    end
    return skinCases
end

local function saveOriginal(weaponName)
    local folder = getWeaponsFolder()
    if not folder then return end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then
        debugPrint("ERROR: Weapon not found: " .. weaponName)
        return
    end
    if not originalGuns[weaponName] then
        originalGuns[weaponName] = {}
        for _, child in pairs(weapon:GetChildren()) do
            table.insert(originalGuns[weaponName], child:Clone())
        end
        debugPrint("Saved original: " .. weaponName .. " (" .. #originalGuns[weaponName] .. " children)")
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
        debugPrint("Restored original: " .. weaponName)
    end
end

local function applySkin(weaponName, skinName)
    debugPrint("Applying skin: " .. weaponName .. " -> " .. skinName)
    local folder = getWeaponsFolder()
    if not folder then return end
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
    debugPrint("Skin applied successfully!")
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

local function getWrapWeapons()
    if #wrapWeapons > 0 then return wrapWeapons end
    local folder = getWeaponsFolder()
    if not folder then return wrapWeapons end
    local skip = {["Spooky Skin Case"] = true, ["Skin Case 2"] = true, ["Skin Case"] = true, ["Other"] = true, ["Festive Skin Case"] = true}
    for _, child in ipairs(folder:GetChildren()) do
        if not skip[child.Name] then table.insert(wrapWeapons, child.Name) end
    end
    table.sort(wrapWeapons, function(a, b) return a:lower() < b:lower() end)
    return wrapWeapons
end

local function getWrapList()
    if #wrapList > 0 then return wrapList end
    local ok, wraps = pcall(function() return LocalPlayer.PlayerScripts.Assets.WrapTextures:GetChildren() end)
    if ok and wraps then
        for _, wrap in ipairs(wraps) do table.insert(wrapList, wrap.Name) end
        table.sort(wrapList, function(a, b) return a:lower() < b:lower() end)
    end
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
        local ok, wrapFolder = pcall(function() return LocalPlayer.PlayerScripts.Assets.WrapTextures:FindFirstChild(wrapName) end)
        if ok and wrapFolder then
            for _, tex in ipairs(wrapFolder:GetChildren()) do
                if tex:IsA("Texture") then
                    for _, desc in ipairs(weapon:GetDescendants()) do
                        if desc:IsA("BasePart") then tex:Clone().Parent = desc end
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
                for weapon, wrap in pairs(wrapConfig) do applyWrap(weapon, wrap) end
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

    -- Debug: Check if paths exist
    task.delay(0.5, function()
        debugPrint("Initializing...")
        getWeaponsFolder()
        getSkinCases()
        loadSettings()
        loadWrapSettings()
    end)

    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        local selectedWeapon = "None"
        local selectedSkin = nil
        local skinDropdown = nil

        local weaponList = {"None"}
        for weapon, _ in pairs(WEAPON_SKINS) do table.insert(weaponList, weapon) end
        table.sort(weaponList)

        GUI.AddSection(page, "Skin Changer", 1)

        GUI.AddDropdown(page, "Weapon",
            function() return weaponList end,
            function() return selectedWeapon end,
            function(v)
                selectedWeapon = v
                debugPrint("Selected weapon: " .. v)
                if v ~= "None" and WEAPON_SKINS[v] then
                    selectedSkin = selectedSkins[v] or WEAPON_SKINS[v][1]
                    if skinDropdown then
                        skinDropdown:SetValues(WEAPON_SKINS[v])
                        skinDropdown:SetValue(selectedSkin)
                    end
                    selectedSkins[v] = selectedSkin
                    applySkin(v, selectedSkin)
                    saveSettings()
                end
            end, 2)

        local skinWrapper, skinObj = GUI.AddDropdown(page, "Skin",
            function()
                if selectedWeapon ~= "None" and WEAPON_SKINS[selectedWeapon] then
                    return WEAPON_SKINS[selectedWeapon]
                end
                return {"Select a weapon first"}
            end,
            function() return selectedSkin end,
            function(v)
                selectedSkin = v
                debugPrint("Selected skin: " .. v)
                if selectedWeapon ~= "None" then
                    selectedSkins[selectedWeapon] = v
                    applySkin(selectedWeapon, v)
                    saveSettings()
                end
            end, 3)
        skinDropdown = skinObj

        GUI.AddButton(page, "Reset Skins",
            function()
                for weaponName, _ in pairs(appliedSkins) do restoreOriginal(weaponName) end
                appliedSkins = {}
                selectedSkins = {}
                saveSettings()
            end, 4, true)

        GUI.AddSection(page, "Wrap Changer", 5)
        local wrapWeapon = "none"
        local wrapName = "none"

        GUI.AddDropdown(page, "Weapon",
            function()
                local list = {"none"}
                for _, w in ipairs(getWrapWeapons()) do table.insert(list, w) end
                return list
            end,
            function() return wrapWeapon end,
            function(v) wrapWeapon = v end, 6)

        GUI.AddDropdown(page, "Wrap",
            function()
                local list = {"none"}
                for _, w in ipairs(getWrapList()) do table.insert(list, w) end
                return list
            end,
            function() return wrapName end,
            function(v)
                wrapName = v
                if wrapWeapon ~= "none" then
                    applyWrap(wrapWeapon, v)
                    saveWrapSettings()
                end
            end, 7)

        GUI.AddButton(page, "Clear All Wraps",
            function()
                for weaponName, _ in pairs(wrapConfig) do applyWrap(weaponName, "none") end
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
