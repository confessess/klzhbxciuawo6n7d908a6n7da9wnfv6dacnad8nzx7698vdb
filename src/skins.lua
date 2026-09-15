-- ============================================================
-- Rivals Modular -- Skins (Correct mappings from user data)
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService, RunService

-- CORRECT skin mapping from user data
local CORRECT_SKINS = {
    ["Assault Rifle"] = {"Phoenix Rifle", "AK-47", "Boneclaw Rifle", "Pearl Rifle", "Augmented Rifle", "Gingerbread Augmented Rifle", "Tommy Gun", "AKEY-47", "10B Visits", "Glorious Assault Rifle"},
    ["Battle Axe"] = {"Ban Axe", "Nordic Axe", "Cerulean Axe", "Tiki Axe", "Balloon Axe", "Mimic Axe", "Street Sign", "The Shred", "Keyttle Axe", "Glorious Battle Axe"},
    ["Bow"] = {"Compound Bow", "Bat Bow", "Dream Bow", "Frostbite Bow", "Palm Bow", "Raven Bow", "Balloon Bow", "Beloved Bow", "Key Bow", "Glorious Bow"},
    ["Burst Rifle"] = {"Pine Burst", "Spectral Burst", "Aqua Burst", "Electro Rifle", "FAMAS", "Sand FAMAS", "Pixel Burst", "Keyst Rifle", "Glorious Burst Rifle"},
    ["Chainsaw"] = {"Sharksaw", "Blobsaw", "Buzzsaw", "Festive Buzzsaw", "Handsaws", "Mega Drill", "Glorious Chainsaw"},
    ["Crossbow"] = {"Campfire Crossbow", "Crossbone", "Frostbite Crossbow", "Harpoon Crossbow", "Violin Crossbow", "Pixel Crossbow", "Arch Crossbow", "Glorious Crossbow"},
    ["Daggers"] = {"Paper Planes", "Shurikens", "Starfish", "Aces", "Bat Daggers", "Cookies", "Broken Hearts", "Toaster", "Keynais", "Crystal Daggers", "Glorious Daggers"},
    ["Distortion"] = {"Cyber Distortion", "Bubble Distortion", "Electropunk Distortion", "Magma Distortion", "Plasma Distortion", "Sleighstortion", "Experiment D15", "Glorious Distortion"},
    ["Energy Rifle"] = {"New Year Energy Rifle", "Apex Rifle", "Hacker Rifle", "Hydro Rifle", "Sol Rifle", "Soul Rifle", "Void Rifle", "Glorious Energy Rifle"},
    ["Energy Pistols"] = {"New Year Energy Pistols", "Apex Pistols", "Hacker Pistols", "Hydro Pistols", "Sol Pistols", "Hyperlaser Guns", "Soul Pistols", "Void Pistols", "Glorious Energy Pistols"},
    ["Exogun"] = {"Midnight Festive Exogun", "Wondergun", "Exogourd", "Pearl Exogun", "Ray Gun", "Repulsor", "Singularity", "Glorious Exogun"},
    ["Flashbang"] = {"Lightbulb", "Skullbang", "Shining Star", "Camera", "Disco Ball", "Sol", "Pixel Flashbang", "Glorious Flashbang"},
    ["Flare Gun"] = {"Wrapped Flare Gun", "Dynamite Gun", "Banana Flare", "Firework Gun", "Pocket Volcano", "Vexed Flare Gun", "Glorious Flare Gun"},
    ["Flamethrower"] = {"Lamethrower", "Bubblethrower", "Glitterthrower", "Jack O' Thrower", "Snowblower", "Extinguisher", "Pixel Flamethrower", "Rainbowthrower", "Keythrower", "Glorious Flamethrower"},
    ["Fists"] = {"Brass Knuckles", "Festive Fists", "Pumpkin Claws", "Spy Gloves", "Boxing Gloves", "Fists of Hurt", "Crab Claws", "Pirate Hook", "Fist", "Glorious Fists"},
    ["Freeze Ray"] = {"Wrapped Freeze Ray", "Bubble Ray", "Gum Ray", "Spider Ray", "Temporal Ray", "Cooler", "Glorious Freeze Ray"},
    ["Grappler"] = {"Lifeguard Grappler", "Lasso", "Glorious Grappler"},
    ["Grenade"] = {"Dynamite", "Frozen Grenade", "Fizz Bomb", "Jingle Grenade", "Water Balloon", "Cuddle Bomb", "Soul Grenade", "Whoopee Cushion", "Keynade", "Glorious Grenade"},
    ["Grenade Launcher"] = {"Coconut Launcher", "Gearnade Launcher", "Snowball Launcher", "Uranium Launcher", "Balloon Launcher", "Skull Launcher", "Swashbuckler", "Glorious Grenade Launcher"},
    ["Gunblade"] = {"Boneblade", "Crude Gunblade", "Elf's Gunblade", "Sharkbite", "Gunsaw", "Hyper Gunblade", "Keyblade", "Glorious Gunblade"},
    ["Handgun"] = {"Gumball Handgun", "Pumpkin Handgun", "Towerstone Handgun", "Warp Handgun", "Blaster", "Gingerbread Handgun", "Sandgun", "Hand Gun", "Pixel Handgun", "Stealth Handgun", "Glorious Handgun"},
    ["Jump Pad"] = {"Flamingo Floatie", "Spider Web", "Trampoline", "Bounce House", "Jolly Man", "Shady Chicken Sandwich", "Glorious Jump Pad"},
    ["Katana"] = {"Swordfish", "New Year Katana", "Evil Trident", "Lightning Bolt", "Stellar Katana", "Cutlass", "Linked Sword", "Pixel Katana", "Saber", "Arch Katana", "Crystal Katana", "Keytana", "Riptide Katana", "Glorious Katana"},
    ["Knife"] = {"Birthday Candle", "Chancla", "Machete", "Shark Tooth", "Balisong", "Candy Cane", "Caladbolg", "Karambit", "Pencil", "Keyrambit", "Keylisong", "Armature.001", "Glorious Knife"},
    ["Maul"] = {"Giant Popsicle", "Ice Maul", "Sleigh Maul", "Ban Hammer", "Glorious Maul"},
    ["Medkit"] = {"Briefcase", "Box of Chocolates", "Bucket of Candy", "Ice Cream", "Laptop", "Medkitty", "Milk & Cookies", "Sandwich", "Glorious Medkit"},
    ["Minigun"] = {"Pumpkin Minigun", "Wrapped Minigun", "Shark Minigun", "Fighter Jet", "Lasergun 3000", "Pixel Minigun", "Glorious Minigun"},
    ["Molotov"] = {"Campfire Stick", "Coffee", "Torch", "Hot Coals", "Ship In A Bottle", "Vexed Candle", "Arch Molotov", "Glorious Molotov"},
    ["Paintball Gun"] = {"Ketchup Gun", "Lemonade Gun", "Brain Gun", "Slime Gun", "Snowball Gun", "Paintballoon Gun", "Boba Gun", "Glorious Paintball Gun"},
    ["Permafrost"] = {"Ice Permafrost", "Snowman Permafrost", "Permasand", "Glorious Permafrost"},
    ["Riot Shield"] = {"Broken Surfboard", "Door", "Sled", "Tombstone Shield", "Energy Shield", "Masterpiece", "Glorious Riot Shield"},
    ["Revolver"] = {"Boneclaw Revolver", "Desert Eagle", "Cruise Revolver", "Peppergun", "Peppermint Sheriff", "Sheriff", "Keyvolver", "Glorious Revolver"},
    ["RPG"] = {"Pencil Launcher", "Squid Launcher", "Sundae Launcher", "Cupcake Launcher", "Firework Launcher", "Nuke Launcher", "Pumpkin Launcher", "Rocket Launcher", "Spaceship Launcher", "RPKEY", "Glorious RPG"},
    ["Satchel"] = {"Bag o' Money", "Lifeguard Satchel", "Notebook Satchel", "Suspicious Gift", "Advanced Satchel", "Potion Satchel", "Pizza Box", "Glorious Satchel"},
    ["Scythe"] = {"Plastic Flamingo", "Anchor", "Bat Scythe", "Cryo Scythe", "Sakura Scythe", "Scythe of Death", "Palm Scythe", "Crystal Scythe", "Keythe", "Bug Net", "Glorious Scythe"},
    ["Shorty"] = {"Lovely Shorty", "Not So Shorty", "Too Shorty", "Wrapped Shorty", "Bubble Shorty", "Demon Shorty", "Balloon Shorty", "Cannon Shorty", "Glorious Shorty"},
    ["Shotgun"] = {"Cactus Shotgun", "Wrapped Shotgun", "Broomstick", "Balloon Shotgun", "Hyper Shotgun", "Shark Shotgun", "Shotkey", "Glorious Shotgun"},
    ["Slingshot"] = {"Goalpost", "Palmshot", "Stick", "Boneshot", "Reindeer Slingshot", "Harp", "Lucky Horseshoe", "Keyshot", "Glorious Slingshot"},
    ["Smoke Grenade"] = {"Balance", "Beach Ball", "Hourglass", "Snowglobe", "Emoji Cloud", "Eyeball", "Glorious Smoke Grenade"},
    ["Sniper"] = {"Campfire Sniper", "Eyething Sniper", "Gingerbread Sniper", "Event Horizon", "Hyper Sniper", "Kraken Sniper", "Pixel Sniper", "Keyper", "Glorious Sniper"},
    ["Spear"] = {"Giant Pencil", "Chark Kebab", "Studio Light", "Glorious Spear"},
    ["Spray"] = {"Lovely Spray", "Nail Gun", "Pine Spray", "Boneclaw Spray", "Campfire Spray", "Spray Bottle", "Key Spray", "Glorious Spray"},
    ["Subspace Tripmine"] = {"DIY Tripmine", "Trick or Treat", "Spring", "Don't Press", "Dev-in-the-Box", "Hazard Sign", "Pot o' Keys", "Glorious Subspace Tripmine"},
    ["Trowel"] = {"Garden Shovel", "Paintbrush", "Plastic Shovel", "Pumpkin Carver", "Scooper", "Snow Shovel", "Glorious Trowel"},
    ["Uzi"] = {"Ducky Uzi", "Pine Uzi", "Demon Uzi", "Water Uzi", "Electro Uzi", "Money Gun", "Keyzi", "Glorious Uzi"},
    ["War Horn"] = {"Mammoth Horn", "Megaphone", "Air Horn", "Boneclaw Horn", "Trumpet", "Lifeguard Whistle", "Glorious War Horn"},
    ["Warper"] = {"Bubbler", "Electropunk Warper", "Frost Warper", "Glitter Warper", "Arcane Warper", "Experiment W4", "Hotel Bell", "Glorious Warper"},
    ["Warpstone"] = {"Cyber Warpstone", "Warpbone", "Electropunk Warpstone", "Unstable Warpstone", "Warp Juice", "Teleport Disc", "Warpstar", "Warpeye", "Glorious Warpstone"},
}


-- ALL 336 WRAPS from game
local ALL_WRAPS = {
    "Beige", "Blue", "Bluesteel", "Blush", "Brown", "Cheese", "Cool", "Crimson", "Green", "Gunmetal",
    "Highlighter", "Lemon", "Lumber", "MaGGenta", "Maroon", "Mint", "Navy", "Olive", "Olo", "Orange",
    "Ornate", "Pink", "Purple", "Red", "Salmon", "Sky", "Stained", "Teal", "Venom", "Yellow",
    "Arctic Camo", "Black", "Bliss", "Brain", "Carmine", "Carpet", "Celtic", "Circuit", "Clouds", "Cold Metal",
    "Crossed", "Dawn", "Desert Camo", "Digital Camo", "Eco", "Experience", "Fiery", "Forest Camo", "Frosted", "Gold",
    "Honeycomb", "Igneous", "Inlets", "Mainframe", "Maize", "Medium stone grey", "Money", "Ocean Camo", "OranGG", "Patriot",
    "PB & J", "Portal", "Reptile", "Rug", "Spartan", "Spellslinger", "Steel", "Street Camo", "Studs", "Surge",
    "Swirls", "Termination", "Universal", "Urban Camo", "Vile", "Voltaic", "White", ".exe", "Bee", "Black Opal",
    "Devourer", "Diamond", "Glass", "Hesper", "Luxe", "Malevolent", "Mint Choco Chip", "Omnisand", "Plaid Pajama", "Quasar",
    "Scorched", "Slime", "Sunset", "Water", "Aegis", "Blizzard", "Dark Matter", "Fracture", "Orichalcum",
    "Copper", "Cursed", "Frigid", "Haunted", "Jean", "Lavish Crystal", "Machine", "Midnight", "Mustard", "Noir",
    "Normal", "Rust", "Slush", "Tawny", "Titanium", "Tungsten", "Vexed", "Violet", "Ancient", "Antimatter",
    "Arbiter", "Black Granite", "Blush Wrapping", "Bunsen", "Caned Wrapping", "Carbon Wrapping", "Cashmere Wrapping", "Cerulean", "Chilled Wrapping", "Chrome Webs",
    "Clamshell", "Cool Crochet", "Cork", "Creme Wrapping", "Crimson Art", "Dunes", "Dusky Wrapping", "Evergreen Wrapping", "Forest Wrapping", "Fortune Wrapping",
    "Frosty Wrapping", "Glisten", "Glossy", "Grass", "Green Goo", "Hammered Copper", "Holly Wrapping", "Hypnotic", "Indigo Wrapping", "Jolly Wrapping",
    "Leafy Grass", "Liquid Chrome", "Lovely Leopard", "Luxury Wrapping", "Mahogany", "Merlot Wrapping", "Minty Wrapping", "Mocha Wrapping", "Model", "Mousse Wrapping",
    "Neo", "Obsidian", "Pearly Wrapping", "Peppermint Wrapping", "Periwinkle Wrapping", "Pink Crochet", "Pink Glitter", "Plasma", "Polar Wrapping", "Purple Goo",
    "Purpleize", "Rage", "Regal", "Regal Wrapping", "Rustic", "Scales", "Sentinel", "Snowfall", "Storm", "Strobe",
    "Studded", "Tealur", "Tempest", "TIX", "Toy", "Ugly Sweater", "Waste", "Well Done", "Werewolf Fur", "Winter Wrapping",
    "Yang", "Yin", "2025 Wrapping", "2026 Wrapping", "A5", "Amber", "Arabesque", "Aurora", "Bombastic", "Bright",
    "Candy Apple", "Carbon Fiber", "Cardinal", "Chrome", "Dark", "Dark Arena", "Encrypt", "Frankenstein",
    "Gingerbread", "Green Sparkle", "Hologram", "Hyperdrive", "Indigo Sparkle", "Insidious", "Insignia", "Iridescent", "Lightning", "Liquid Gold",
    "Malachite", "Mesh", "Mischief", "Moonstone", "Mummy", "Peppermint", "Plastic", "Resolute", "Rift", "Scourge",
    "Spectral", "Starblaze", "Starfall", "Thunderburst", "Tiger", "Webbed", "Festive Lights", "Neon Lights", "Solar", "Soulscourge",
    "Speed", "Glorious", "Hot Cocoa", "Lapis", "Pink Lemonade", "Playful", "Sleet", "Spiral", "Tusky", "Zombie",
    "Facility", "Fire", "Mintbread", "Nova", "Trophy", "Vigor", "Winter Solstice", "Black Glass", "Blaze", "Bubbles",
    "Candlelight", "Hallow", "Heirloom", "Magnetite", "Necromancer", "Peril", "Stocking Fur", "Supernova", "Wintergreen", "Wintry",
    "Borealis", "Celestial", "Crime Scene", "Encroached", "Ice Queen", "Paparazzi", "1B Visits", "Beggar", "Brimstone", "Cream",
    "Community", "Danger", "Glamour", "Glacier", "Pine", "Snowy Night",
    ".dll", "Arena", "Aurum", "Beach", "Birthday Wrapping", "Black Damascus", "Cardboard", "Classic", "Clovers", "Crystallized",
    "Damascus", "Disco", "Empress", "Fire Horse", "Frostbite", "Geometric", "Greenflame", "Groove", "Hologram Arena", "Honey",
    "Ladybug", "Lucre", "Luxurious", "Magma", "Messis", "Nebula", "Ornamented", "Paint", "Pixel Blight", "Red Rubber",
    "RIVALS Wrapping", "Serenity", "Shadow Ink", "Simulation", "Sunset Sparkle", "Triplaser", "Watermelon", "Wealth", "Woven",
    "Heartfelt", "Polaris", "The Heights", "TV Error",
    "Boomore", "Brianore", "Nekore", "Nosnite", "Sensite", "Shadore", "Scribble", "Net", "Rivalry", "Only Six",
}

local WEAPON_LIST = {"None", "Assault Rifle", "Battle Axe", "Bow", "Burst Rifle", "Chainsaw", "Crossbow", "Daggers", "Distortion", "Energy Rifle", "Energy Pistols", "Exogun", "Fists", "Flamethrower", "Flare Gun", "Flashbang", "Freeze Ray", "Grappler", "Grenade", "Grenade Launcher", "Gunblade", "Handgun", "Jump Pad", "Katana", "Knife", "Maul", "Medkit", "Minigun", "Molotov", "Paintball Gun", "Permafrost", "Revolver", "Riot Shield", "RPG", "Satchel", "Scythe", "Shorty", "Shotgun", "Slingshot", "Smoke Grenade", "Sniper", "Spear", "Spray", "Subspace Tripmine", "Trowel", "Uzi", "War Horn", "Warper", "Warpstone"}

local weaponsFolder = nil
local skinCases = {}
local originalWeapons = {}
local currentSkins = {}

local selectedWeapon = "None"
local selectedSkin = "None"
local skinOptions = {"Select a weapon first"}
local glitchyMode = false
local selectedWrapWeapon = "None"
local selectedWrap = "None"
local wrapConfig = {}

local SKINS_FILE = "RivalsModular/skins.json"

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

local function getAllSkins()
    local all = {}
    for _, case in ipairs(getAllSkinCases()) do
        for _, skin in ipairs(case:GetChildren()) do
            table.insert(all, skin.Name)
        end
    end
    table.sort(all)
    return all
end

local function getSkinsForWeapon(weaponName)
    if glitchyMode then
        return getAllSkins()
    end
    return CORRECT_SKINS[weaponName] or {"No skins available"}
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
    if not folder then 
        debugPrint("ERROR: No weapons folder")
        return false 
    end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then 
        debugPrint("ERROR: Weapon not found: " .. weaponName)
        return false 
    end

    local skinModel = nil
    for _, case in ipairs(getAllSkinCases()) do
        local found = case:FindFirstChild(skinName)
        if found then
            skinModel = found
            debugPrint("Found skin in: " .. case.Name)
            break
        end
    end
    if not skinModel then 
        debugPrint("ERROR: Skin not found: " .. skinName)
        return false 
    end

    -- Check part count
    local weaponParts = #weapon:GetChildren()
    local skinParts = #skinModel:GetChildren()
    if weaponParts ~= skinParts then
        debugPrint("WARNING: Part count mismatch! Weapon: " .. weaponParts .. ", Skin: " .. skinParts)
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

local function updatePreview(weaponName, skinName)
    if not GUI.SkinPreviewViewport then return end
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
    previewModel.Parent = GUI.SkinPreviewViewport

    local cf, size = previewModel:GetBoundingBox()
    local center = cf.Position
    local maxDim = math.max(size.X, size.Y, size.Z)
    local distance = maxDim * 0.7

    GUI.SkinPreviewCamera.CFrame = CFrame.new(
        center + Vector3.new(distance, distance * 0.5, distance),
        center
    )

    previewRotation = 0
end

local function startPreviewRotation()
    RunService.RenderStepped:Connect(function(dt)
        if not previewModel or not GUI.SkinPreviewCamera then return end
        if not GUI.SkinPreviewFrame or not GUI.SkinPreviewFrame.Visible then return end
        if not Core.MenuOpen then return end

        previewRotation = previewRotation + dt * 0.5

        local cf, size = previewModel:GetBoundingBox()
        local center = cf.Position
        local maxDim = math.max(size.X, size.Y, size.Z)
        local distance = maxDim * 0.7
        local angle = previewRotation
        local x = math.cos(angle) * distance
        local z = math.sin(angle) * distance

        GUI.SkinPreviewCamera.CFrame = CFrame.new(
            center + Vector3.new(x, distance * 0.5, z),
            center
        )
    end)
end


-- ============================================================
-- Wrap Changer
-- ============================================================

local WRAPS_FILE = "RivalsModular/wraps.json"

local function getWrapWeapons()
    local list = {"None"}
    local folder = getWeaponsFolder()
    if not folder then return list end
    for _, child in ipairs(folder:GetChildren()) do
        if (child:IsA("Folder") or child:IsA("Model")) and child.Name ~= "Unobtainable" then
            table.insert(list, child.Name)
        end
    end
    table.sort(list)
    return list
end

local function applyWrap(weaponName, wrapName)
    debugPrint("Applying wrap: " .. weaponName .. " -> " .. wrapName)
    local folder = getWeaponsFolder()
    if not folder then return false end
    local weapon = folder:FindFirstChild(weaponName)
    if not weapon then return false end

    -- Remove existing textures
    for _, desc in ipairs(weapon:GetDescendants()) do
        if desc:IsA("BasePart") then
            for _, child in ipairs(desc:GetChildren()) do
                if child:IsA("Texture") then child:Destroy() end
            end
        end
    end

    -- Apply new wrap
    if wrapName ~= "None" then
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
    debugPrint("Wrap applied!")
    return true
end

local function saveWraps()
    pcall(function()
        if writefile then
            writefile(WRAPS_FILE, HttpService:JSONEncode(wrapConfig))
        end
    end)
end

local function loadWraps()
    pcall(function()
        if isfile and isfile(WRAPS_FILE) then
            local data = HttpService:JSONDecode(readfile(WRAPS_FILE))
            if data then
                wrapConfig = data
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
        loadWraps()
        startPreviewRotation()
    end)

    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        GUI.Components.Section(page, "Skin Changer", 1)

        GUI.Components.Toggle(page, "Use Any Skin (GLITCHY)", glitchyMode, function(v)
            glitchyMode = v
            if selectedWeapon ~= "None" then
                skinOptions = getSkinsForWeapon(selectedWeapon)
                selectedSkin = "None"
            end
        end, 2)

        GUI.Components.Dropdown(page, "Weapon", WEAPON_LIST, selectedWeapon, function(v)
            selectedWeapon = v
            if v ~= "None" then
                skinOptions = getSkinsForWeapon(v)
                selectedSkin = "None"
                updatePreview(v, nil)
            else
                skinOptions = {"Select a weapon first"}
                selectedSkin = "None"
                updatePreview("None", nil)
            end
        end, 3)

        GUI.Components.Dropdown(page, "Skin", function() return skinOptions end, selectedSkin, function(v)
            selectedSkin = v
            if selectedWeapon ~= "None" and v ~= "None" then
                updatePreview(selectedWeapon, v)
                local success = applySkin(selectedWeapon, v)
                if success then
                    saveSkins()
                end
            end
        end, 4)

        GUI.Components.Button(page, "Reset Weapon", function()
            if selectedWeapon ~= "None" then
                resetWeapon(selectedWeapon)
                saveSkins()
                updatePreview(selectedWeapon, nil)
            end
        end, 5, true)

        GUI.Components.Button(page, "Reset All", function()
            for weapon, _ in pairs(currentSkins) do
                resetWeapon(weapon)
            end
            saveSkins()
        end, 6, true)

        -- Wrap Changer Section
        GUI.Components.Section(page, "Wrap Changer", 7)

        GUI.Components.Dropdown(page, "Weapon", getWrapWeapons(), selectedWrapWeapon, function(v)
            selectedWrapWeapon = v
        end, 8)

        GUI.Components.Dropdown(page, "Wrap", ALL_WRAPS, selectedWrap, function(v)
            selectedWrap = v
            if selectedWrapWeapon ~= "None" and v ~= "None" then
                applyWrap(selectedWrapWeapon, v)
                saveWraps()
            end
        end, 9)

        GUI.Components.Button(page, "Clear Wrap", function()
            if selectedWrapWeapon ~= "None" then
                applyWrap(selectedWrapWeapon, "None")
                saveWraps()
            end
        end, 10, true)

        GUI.Components.Button(page, "Clear All Wraps", function()
            for weapon, _ in pairs(wrapConfig) do
                applyWrap(weapon, "None")
            end
            wrapConfig = {}
            saveWraps()
        end, 11, true)
    end

    print("[rivals] Skins module initialized.")
end

function Skins.Cleanup()
    for weapon, _ in pairs(currentSkins) do
        resetWeapon(weapon)
    end
    if previewModel then
        previewModel:Destroy()
    end
end

return Skins