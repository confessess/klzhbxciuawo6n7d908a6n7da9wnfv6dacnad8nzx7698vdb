-- ============================================================
-- Rivals Modular -- World
-- Lighting, skybox, fog, bloom, color correction
-- ============================================================

local World = {}

local Config, Utils, GUI, Core
local Lighting, Camera

-- State
local colorCorrection = nil
local bloomEffect = nil
local currentSkybox = "Default"
local skyboxConn = nil

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
-- Skybox
-- ------------------------------------------------------------

local function applySkybox(name)
    currentSkybox = name

    -- Remove existing skyboxes
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

local function updateLighting()
    if not Lighting then return end

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

    -- Ambient
    Lighting.Ambient = Utils.HexToColor(Config.Get("World_Ambient"))
    Lighting.OutdoorAmbient = Utils.HexToColor(Config.Get("World_OutdoorAmbient"))
    Lighting.ShadowColor = Utils.HexToColor(Config.Get("World_ShadowColor"))
    Lighting.Brightness = Config.Get("World_Brightness") or 1

    -- Fullbright
    if Config.Get("World_Fullbright") then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end

    -- Fog
    if Config.Get("World_FogEnabled") then
        Lighting.FogColor = Utils.HexToColor(Config.Get("World_FogColor"))
        local density = Config.Get("World_FogDensity") or 0.1
        Lighting.FogEnd = 1000 - density * 900
    else
        Lighting.FogEnd = 100000
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

    -- Create effects
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = Lighting
    colorCorrection.Enabled = false

    bloomEffect = Instance.new("BloomEffect")
    bloomEffect.Parent = Lighting
    bloomEffect.Enabled = false

    -- Apply initial settings
    task.delay(0.5, function()
        updateLighting()
        applySkybox(Config.Get("World_Skybox") or "Default")
    end)

    -- Register GUI
    -- Register GUI (Misc tab)
    local page = GUI.GetPage and GUI.GetPage("Misc")
    if page then
        GUI.Components.Section(page, "World", 30)
        GUI.Components.Toggle(page, "Color Correction", Config.Get("World_ColorCorrection"), function(v) Config.Set("World_ColorCorrection", v) updateLighting() end, 31)
        GUI.Components.Slider(page, "Contrast", -10, 10, (Config.Get("World_Contrast") or 0) * 10, function(v) Config.Set("World_Contrast", v / 10) updateLighting() end, 32)
        GUI.Components.Slider(page, "Saturation", -10, 10, (Config.Get("World_Saturation") or 0) * 10, function(v) Config.Set("World_Saturation", v / 10) updateLighting() end, 33)
        GUI.Components.Toggle(page, "Fullbright", Config.Get("World_Fullbright"), function(v) Config.Set("World_Fullbright", v) updateLighting() end, 34)
        GUI.Components.Toggle(page, "Bloom", Config.Get("World_BloomEnabled"), function(v) Config.Set("World_BloomEnabled", v) updateLighting() end, 35)
        GUI.Components.Dropdown(page, "Skybox", {"Default", "Neptune", "Nebula", "Vaporwave"}, Config.Get("World_Skybox"), function(v) Config.Set("World_Skybox", v) applySkybox(v) end, 36)
    end

    print("[rivals] World module initialized.")
end

function World.Cleanup()
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