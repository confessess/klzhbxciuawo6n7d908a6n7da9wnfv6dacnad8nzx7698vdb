-- ============================================================
-- Rivals Modular -- Skins (Exact ZYPHERION logic)
-- ============================================================

local Skins = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, HttpService

-- EXACT weapon skins table from ZYPHERION
local r146_0 = {
    ["Assault Rifle"] = {
        "AK-47", "AKEY-47", "Boneclaw Rifle", "AUG", "Phoenix Rifle",
        "Gingerbread AUG", "Tommy Gun", "Keyper", "Hyper Sniper", "Pixel Sniper"
    },
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

-- EXACT state variables from ZYPHERION
local r147_0 = {}  -- SaveOriginalGunsNeg cache
local r148_0 = {}  -- Applied skins tracker
local r149_0 = game:GetService("Players").LocalPlayer.Name
local r150_0 = {}  -- Selected skins
local r151_0 = nil -- Weapons folder
local r152_0 = {}  -- Skin cases
local r153_0 = {}  -- Methods table

-- EXACT methods from ZYPHERION
r153_0["SaveOriginalGunsNeg"] = function(r0_51, r1_51)
    if r1_51 and not r147_0[r1_51.Name] then
        r147_0[r1_51.Name] = {}
        for r5_51, r6_51 in pairs(r1_51:GetChildren()) do
            table.insert(r147_0[r1_51.Name], r6_51:Clone())
        end
    end
end

r153_0["PutBackOriginal"] = function(r0_163, r1_163)
    if r1_163 and r147_0[r1_163.Name] then
        r1_163:ClearAllChildren()
        for r5_163, r6_163 in pairs(r147_0[r1_163.Name]) do
            r6_163.Parent = r1_163
        end
        r147_0[r1_163.Name] = nil
    end
end

r153_0["swapWeaponSkins"] = function(r0_22, r1_22, r2_22, r3_22)
    if not r1_22 then return end
    local r4_22 = r151_0:FindFirstChild(r1_22)
    if not r4_22 then return end
    if r3_22 then
        if r2_22 then
            local r5_22 = nil
            for r9_22, r10_22 in pairs(r152_0) do
                if r10_22:FindFirstChild(r2_22) then
                    r5_22 = r10_22
                    break
                end
            end
            if r5_22 then
                local r6_22 = r5_22:FindFirstChild(r2_22)
                if not r6_22 then return end
                r0_22:SaveOriginalGunsNeg(r4_22)
                r4_22:ClearAllChildren()
                for r10_22, r11_22 in pairs(r6_22:GetChildren()) do
                    r11_22:Clone().Parent = r4_22
                end
                r148_0[r1_22] = true
            end
        end
    else
        r0_22:PutBackOriginal(r4_22)
        r148_0[r1_22] = nil
    end
end

-- EXACT save/load from ZYPHERION
local r159_0 = "RivalsModular/WeaponSkins.json"

r153_0["saveSettings"] = function(r0_27)
    writefile(r159_0, HttpService:JSONEncode({
        selectedSkins = r150_0
    }))
end

r153_0["loadSettings"] = function(r0_108)
    local r1_108, r2_108 = pcall(function()
        return HttpService:JSONDecode(readfile(r159_0))
    end)
    if r1_108 and r2_108 then
        r150_0 = r2_108.selectedSkins or {}
        -- Reapply saved skins
        for r3_2, r4_2 in pairs(r150_0) do
            if r146_0[r3_2] and table.find(r146_0[r3_2], r4_2) then
                r153_0:swapWeaponSkins(r3_2, r4_2, true)
            end
        end
    end
end

-- EXACT reapply function from ZYPHERION
local function r154_0()
    for r3_2, r4_2 in pairs(r150_0) do
        if r146_0[r3_2] and table.find(r146_0[r3_2], r4_2) then
            r153_0:swapWeaponSkins(r3_2, r4_2, true)
        end
    end
end

-- ------------------------------------------------------------
-- Wrap Changer (EXACT from ZYPHERION)
-- ------------------------------------------------------------

local r160_0 = "RivalsModular/WrapChangerConfig"
local r161_0 = nil
local r162_0 = nil
local r163_0 = {
    ["Spooky Skin Case"] = true,
    ["Skin Case 2"] = true,
    ["Skin Case"] = true,
    ["Other"] = true,
    ["Festive Skin Case"] = true
}
local r164_0 = {""}
local r165_0 = r164_0[1]
local r166_0 = ""
local r167_0 = {}
local r168_0 = {}

local function r169_0(r0_119)
    for r4_119, r5_119 in ipairs(r0_119:GetDescendants()) do
        if r5_119:IsA("BasePart") and r5_119.Transparency == 1 then
            invisPart = r5_119
            table.insert(r167_0, invisPart)
        end
    end
end

local function r170_0(r0_24)
    for r4_24, r5_24 in ipairs(r0_24:GetDescendants()) do
        if r5_24:IsA("BasePart") then
            for r9_24, r10_24 in ipairs(r5_24:GetChildren()) do
                if r10_24:IsA("Texture") then
                    r10_24:Destroy()
                end
            end
        end
    end
end

local function r171_0(r0_47, r1_47)
    local r2_47 = LocalPlayer.PlayerScripts.Assets.WrapTextures:FindFirstChild(r1_47)
    if r2_47 then
        for r6_47, r7_47 in ipairs(r2_47:GetChildren()) do
            if r7_47:IsA("Texture") then
                for r11_47, r12_47 in ipairs(r0_47:GetDescendants()) do
                    if r12_47:IsA("BasePart") and r12_47 ~= invisPart then
                        r7_47:Clone().Parent = r12_47
                    end
                end
            end
        end
    end
end

local r172_0 = nil
local r173_0 = {"none"}

local function r174_0()
    writefile(r160_0 .. ".json", HttpService:JSONEncode(r168_0))
end

local function r175_0()
    if isfile(r160_0 .. ".json") then
        r168_0 = HttpService:JSONDecode(readfile(r160_0 .. ".json"))
        for r3_95, r4_95 in pairs(r168_0) do
            local r5_95 = r161_0:FindFirstChild(r3_95)
            if r5_95 then
                r169_0(r5_95)
                r170_0(r5_95)
                r171_0(r5_95, r4_95)
            end
        end
    end
end

-- ------------------------------------------------------------
-- Init
-- ------------------------------------------------------------

function Skins.Update(_dt)
    -- Event-driven, no per-frame work
end

function Skins.Init(deps)
    Config = deps.Config
    Utils = deps.Utils
    GUI = deps.GUI
    Core = deps.Core
    Players = Utils.Players
    LocalPlayer = Utils.LocalPlayer
    HttpService = game:GetService("HttpService")

    -- EXACT initialization from ZYPHERION
    r151_0 = LocalPlayer["PlayerScripts"]["Assets"]["ViewModels"]["Weapons"]
    r161_0 = r151_0

    r152_0 = {
        ["Spooky Skin Case"] = LocalPlayer["PlayerScripts"]["Assets"]["ViewModels"]["Spooky Skin Case"],
        ["Skin Case 2"] = LocalPlayer["PlayerScripts"]["Assets"]["ViewModels"]["Skin Case 2"],
        ["Skin Case 3"] = LocalPlayer["PlayerScripts"]["Assets"]["ViewModels"]["Skin Case 3"],
        ["Skin Case"] = LocalPlayer["PlayerScripts"]["Assets"]["ViewModels"]["Skin Case"],
        ["Other"] = LocalPlayer["PlayerScripts"]["Assets"]["ViewModels"]["Other"],
        ["Festive Skin Case"] = LocalPlayer["PlayerScripts"]["Assets"]["ViewModels"]["Festive Skin Case"]
    }

    -- Build wrap weapon list (EXACT from ZYPHERION)
    r162_0 = r161_0:GetChildren()
    for r168_0, r169_0 in ipairs(r162_0) do
        if not r163_0[r169_0.Name] then
            table.insert(r164_0, r169_0.Name)
        end
    end
    table.sort(r164_0, function(r0_73, r1_73)
        return r0_73:lower() < r1_73:lower()
    end)

    -- Build wrap list (EXACT from ZYPHERION)
    r172_0 = LocalPlayer["PlayerScripts"]["Assets"]["WrapTextures"]:GetChildren()
    for r177_0, r178_0 in ipairs(r172_0) do
        table.insert(r173_0, r178_0.Name)
    end
    table.remove(r173_0, 1)
    table.sort(r173_0, function(r0_96, r1_96)
        return r0_96:lower() < r1_96:lower()
    end)
    table.insert(r173_0, 1, "none")

    -- Load saved settings
    task.delay(1, function()
        r153_0:loadSettings()
        r175_0()
    end)

    -- Register GUI (EXACT structure from ZYPHERION)
    local page = GUI.GetPage and GUI.GetPage("Skins")
    if page then
        local r155_0, r156_0, r157_0 = nil, nil, nil

        -- Weapon dropdown
        local weaponList = {"None"}
        for weapon, _ in pairs(r146_0) do
            table.insert(weaponList, weapon)
        end
        table.sort(weaponList)

        GUI.AddSection(page, "Skin Changer", 1)

        GUI.AddDropdown(page, "Weapon",
            function() return weaponList end,
            function() return r155_0 end,
            function(r0_28)
                r155_0 = r0_28
                local r1_28 = r146_0[r0_28] or {}
                if r157_0 then
                    r157_0:SetValues(r1_28)
                    r156_0 = r150_0[r155_0] or r1_28[1]
                    r157_0:SetValue(r156_0)
                    r153_0:swapWeaponSkins(r155_0, r156_0, true)
                    r153_0:saveSettings()
                end
            end, 2)

        -- Skin dropdown
        r157_0 = GUI.AddDropdown(page, "Skin",
            function()
                if r155_0 and r146_0[r155_0] then
                    return r146_0[r155_0]
                end
                return {"PlaceHolder"}
            end,
            function() return r156_0 end,
            function(r0_161)
                r150_0[r155_0] = r0_161
                r156_0 = r0_161
                r153_0:swapWeaponSkins(r155_0, r156_0, true)
                r153_0:saveSettings()
            end, 3)

        -- Reset button
        GUI.AddButton(page, "Reset Skins",
            function()
                for r3_pr154_0, r4_pr154_0 in pairs(r148_0) do
                    local r5_pr154_0 = r151_0:FindFirstChild(r3_pr154_0)
                    if r5_pr154_0 then
                        r153_0:PutBackOriginal(r5_pr154_0)
                    end
                end
                r148_0 = {}
                r150_0 = {}
                writefile(r159_0, HttpService:JSONEncode({selectedSkins = {}}))
                for r3_pr154_0, r4_pr154_0 in pairs(r151_0:GetChildren()) do
                    if r147_0[r4_pr154_0.Name] then
                        r153_0:PutBackOriginal(r4_pr154_0)
                    end
                end
            end, 4, true)

        -- Wrap changer section
        GUI.AddSection(page, "Wrap Changer", 5)

        GUI.AddDropdown(page, "Weapon",
            function() return r164_0 end,
            function() return r165_0 end,
            function(r0_173)
                r165_0 = r0_173
                local r1_173 = r161_0:FindFirstChild(r165_0)
                if r1_173 then
                    r169_0(r1_173)
                end
            end, 6)

        GUI.AddDropdown(page, "Wrap",
            function() return r173_0 end,
            function() return r166_0 end,
            function(r0_98)
                r166_0 = r0_98
                local r1_98 = r161_0:FindFirstChild(r165_0)
                if r1_98 then
                    r170_0(r1_98)
                    r171_0(r1_98, r166_0)
                    r168_0[r165_0] = r166_0
                    r174_0()
                end
            end, 7)

        GUI.AddButton(page, "Clear All Wraps",
            function()
                writefile(r160_0 .. ".json", HttpService:JSONEncode({wrapConfig = {}}))
                for r3_pr6_1, r4_pr6_1 in ipairs(r164_0) do
                    local r5_pr6_1 = r161_0:FindFirstChild(r4_pr6_1)
                    if r5_pr6_1 then
                        r170_0(r5_pr6_1)
                    end
                end
            end, 8, true)
    end

    print("[rivals] Skins module initialized.")
end

function Skins.Cleanup()
    for r3_2, r4_2 in pairs(r148_0) do
        local r5_2 = r151_0:FindFirstChild(r3_2)
        if r5_2 then
            r153_0:PutBackOriginal(r5_2)
        end
    end
end

return Skins