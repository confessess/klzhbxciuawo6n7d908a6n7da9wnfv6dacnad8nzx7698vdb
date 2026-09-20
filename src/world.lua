-- ============================================================
-- Rivals Modular -- World
-- Lighting, skybox, fog, bloom, color correction
-- Master Section UI: Each header toggles its own module
-- ============================================================

local World = {}

local Config, Utils, GUI, Core
local Lighting, Camera

-- State
local colorCorrection = nil
local bloomEffect = nil
local currentSkybox = "Default"
local skyboxConn = nil

-- Original lighting values storage
local OriginalLighting = {}

-- Skybox presets
local SKYBOXES = {
    Default = nil,
    Neptune = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    Nebula = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    Vaporwave = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    Clouds = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    Twilight = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    Minecraft = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    Chill = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    Redshift = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    ["Blue Stars"] = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    ["Blue Aurora"] = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    ["Pink Daylight"] = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    ["Setting Sun"] = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    ["Fade Blue"] = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    ["Elegant Morning"] = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
    ["Aesthetic Night"] = {
        SkyboxBk = "rbxassetid://6444884337", SkyboxDn = "rbxassetid://6444884337",
        SkyboxFt = "rbxassetid://6444884337", SkyboxLf = "rbxassetid://6444884337",
        SkyboxRt = "rbxassetid://6444884337", SkyboxUp = "rbxassetid://6444884337",
    },
}

local SKYBOX_LIST = {
    "Default", "Neptune", "Nebula", "Vaporwave", "Clouds", "Twilight",
    "Minecraft", "Chill", "Redshift", "Blue Stars", "Blue Aurora",
    "Pink Daylight", "Setting Sun", "Fade Blue", "Elegant Morning", "Aesthetic Night"
}

-- ------------------------------------------------------------
-- Original lighting backup/restore
-- ------------------------------------------------------------

local function storeOriginalLighting()
    if not Lighting then return end
    OriginalLighting.Ambient = Lighting.Ambient
    OriginalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
    OriginalLighting.ShadowColor = Lighting.ShadowColor
    OriginalLighting.Brightness = Lighting.Brightness
    OriginalLighting.GlobalShadows = Lighting.GlobalShadows
    OriginalLighting.FogEnd = Lighting.FogEnd
    OriginalLighting.FogColor = Lighting.FogColor
    OriginalLighting.ClockTime = Lighting.ClockTime
end

local function restoreOriginalLighting()
    if not Lighting then return end
    if OriginalLighting.Ambient ~= nil then Lighting.Ambient = OriginalLighting.Ambient end
    if OriginalLighting.OutdoorAmbient ~= nil then Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient end
    if OriginalLighting.ShadowColor ~= nil then Lighting.ShadowColor = OriginalLighting.ShadowColor end
    if OriginalLighting.Brightness ~= nil then Lighting.Brightness = OriginalLighting.Brightness end
    if OriginalLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = OriginalLighting.GlobalShadows end
    if OriginalLighting.FogEnd ~= nil then Lighting.FogEnd = OriginalLighting.FogEnd end
    if OriginalLighting.FogColor ~= nil then Lighting.FogColor = OriginalLighting.FogColor end
    if OriginalLighting.ClockTime ~= nil then Lighting.ClockTime = OriginalLighting.ClockTime end
end

-- ------------------------------------------------------------
-- Skybox
-- ------------------------------------------------------------

local function applySkybox(name)
    currentSkybox = name

    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then
            child:Destroy()
        end
    end

    if name ~= "Default" and SKYBOXES[name] then
        local sky = Instance.new("Sky")
        for prop, value in pairs(SKYBOXES[name]) do
            sky[prop] = value
        end
        sky.Parent = Lighting
    end
end

-- ------------------------------------------------------------
-- Lighting updates
-- ------------------------------------------------------------

local function isAnyWorldFeatureEnabled()
    return Config.Get("World_ColorCorrection") == true
        or Config.Get("World_CustomTime") == true
        or Config.Get("World_Fullbright") == true
        or Config.Get("World_FogEnabled") == true
        or Config.Get("World_BloomEnabled") == true
        or (Config.Get("World_Skybox") or "Default") ~= "Default"
end

local function updateLighting()
    if not Lighting then return end

    -- If no world features are enabled, restore originals and disable effects
    if not isAnyWorldFeatureEnabled() then
        restoreOriginalLighting()
        if colorCorrection then colorCorrection.Enabled = false end
        if bloomEffect then bloomEffect.Enabled = false end
        return
    end

    -- Color correction
    if colorCorrection then
        colorCorrection.Enabled = Config.Get("World_ColorCorrection") == true
        colorCorrection.TintColor = Utils.HexToColor(Config.Get("World_TintColor"))
        colorCorrection.Contrast = Config.Get("World_Contrast") or 0
        colorCorrection.Saturation = Config.Get("World_Saturation") or 0
    end

    -- Time
    if Config.Get("World_CustomTime") then
        Lighting.ClockTime = Config.Get("World_TimeOfDay") or 12
    end

    -- Ambient (only if fullbright or custom ambient is intended)
    if Config.Get("World_Fullbright") then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        -- Restore from original if we had changed them
        if OriginalLighting.Ambient ~= nil then
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
            Lighting.ShadowColor = OriginalLighting.ShadowColor
            Lighting.Brightness = OriginalLighting.Brightness
            Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        end
    end

    -- Fog
    if Config.Get("World_FogEnabled") then
        Lighting.FogColor = Utils.HexToColor(Config.Get("World_FogColor"))
        local density = Config.Get("World_FogDensity") or 0.1
        Lighting.FogEnd = 1000 - density * 900
    else
        if OriginalLighting.FogEnd ~= nil then
            Lighting.FogEnd = OriginalLighting.FogEnd
        end
        if OriginalLighting.FogColor ~= nil then
            Lighting.FogColor = OriginalLighting.FogColor
        end
    end

    -- Bloom
    if bloomEffect then
        bloomEffect.Enabled = Config.Get("World_BloomEnabled") == true
        bloomEffect.Intensity = Config.Get("World_BloomIntensity") or 0.5
        bloomEffect.Size = Config.Get("World_BloomSize") or 24
        bloomEffect.Threshold = Config.Get("World_BloomThreshold") or 0.8
    end
end

-- ------------------------------------------------------------
-- Update
-- ------------------------------------------------------------

function World.Update(_dt)
    -- Event-driven, no per-frame work needed
end

-- ------------------------------------------------------------
-- Lifecycle
-- ------------------------------------------------------------

function World.Init(deps)
    Config   = deps.Config
    Utils    = deps.Utils
    GUI      = deps.GUI
    Core     = deps.Core
    Lighting = game:GetService("Lighting")
    Camera   = Utils.Camera

    -- Store original lighting values before we touch anything
    storeOriginalLighting()

    -- Create effects (disabled by default)
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = Lighting
    colorCorrection.Enabled = false

    bloomEffect = Instance.new("BloomEffect")
    bloomEffect.Parent = Lighting
    bloomEffect.Enabled = false

    -- Apply initial settings ONLY if something is actually enabled
    task.delay(0.5, function()
        if isAnyWorldFeatureEnabled() then
            updateLighting()
        end
        applySkybox(Config.Get("World_Skybox") or "Default")
    end)

    -- Register GUI (Misc tab) with Master Sections
    local page = GUI.GetPage and GUI.GetPage("Misc")
    if page then
        local C = GUI.Components

        -- ========================================
        -- COLOR CORRECTION MASTER SECTION
        -- ========================================
        local ccSection, setCcOpen = C.MasterSection(page, "Color Correction", 40, Config.Get("World_ColorCorrection") or false)

        C.Toggle(ccSection, "Enabled", Config.Get("World_ColorCorrection"), function(v) Config.Set("World_ColorCorrection", v) updateLighting() end, 41)
        C.Slider(ccSection, "Contrast", -10, 10, (Config.Get("World_Contrast") or 0) * 10, function(v) Config.Set("World_Contrast", v / 10) updateLighting() end, 42)
        C.Slider(ccSection, "Saturation", -10, 10, (Config.Get("World_Saturation") or 0) * 10, function(v) Config.Set("World_Saturation", v / 10) updateLighting() end, 43)

        setCcOpen(Config.Get("World_ColorCorrection") or false)

        -- ========================================
        -- FULLBRIGHT MASTER SECTION
        -- ========================================
        local fbSection, setFbOpen = C.MasterSection(page, "Fullbright", 50, Config.Get("World_Fullbright") or false)

        C.Toggle(fbSection, "Enabled", Config.Get("World_Fullbright"), function(v) Config.Set("World_Fullbright", v) updateLighting() end, 51)

        setFbOpen(Config.Get("World_Fullbright") or false)

        -- ========================================
        -- BLOOM MASTER SECTION
        -- ========================================
        local bloomSection, setBloomOpen = C.MasterSection(page, "Bloom", 60, Config.Get("World_BloomEnabled") or false)

        C.Toggle(bloomSection, "Enabled", Config.Get("World_BloomEnabled"), function(v) Config.Set("World_BloomEnabled", v) updateLighting() end, 61)

        setBloomOpen(Config.Get("World_BloomEnabled") or false)

        -- ========================================
        -- SKYBOX MASTER SECTION
        -- ========================================
        local skySection, setSkyOpen = C.MasterSection(page, "Skybox", 70, (Config.Get("World_Skybox") or "Default") ~= "Default")

        C.Dropdown(skySection, "Skybox", SKYBOX_LIST, Config.Get("World_Skybox"), function(v) Config.Set("World_Skybox", v) applySkybox(v) end, 71)

        setSkyOpen((Config.Get("World_Skybox") or "Default") ~= "Default")
    end

    print("[rivals] World module initialized.")
end

function World.Cleanup()
    restoreOriginalLighting()
    if colorCorrection then
        colorCorrection:Destroy()
        colorCorrection = nil
    end
    if bloomEffect then
        bloomEffect:Destroy()
        bloomEffect = nil
    end
end

return World