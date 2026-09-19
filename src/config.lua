-- ============================================================
-- Rivals Modular -- Config
-- Defaults, JSON persistence
-- ============================================================

local HttpService = game:GetService("HttpService")

local CACHE_FOLDER  = "RivalsModular"
local SETTINGS_FILE = CACHE_FOLDER .. "/settings.json"

local Defaults = {
    -- Menu
    MenuKeybind      = "RightControl",
    MenuAccent       = "#7c6cff",

    -- ESP
    ESP_Enabled         = false,
    ESP_Highlight       = false,
    ESP_Name            = false,
    ESP_Studs           = false,
    ESP_Tracer          = false,
    ESP_HealthBar       = false,
    ESP_Boxes           = false,
    ESP_BoxColor        = "#ffffff",
    ESP_BoxFilled       = false,
    ESP_BoxFillColor    = "#ffffff",
    ESP_BoxTransparency = 0.5,
    ESP_MaxDistance     = 500,
    ESP_TeamCheck       = false,
    ESP_TeamColor       = false,

    -- Legit Aimbot
    Aimbot_Enabled      = false,
    Aimbot_WallCheck    = false,
    Aimbot_TeamCheck    = false,
    Aimbot_Smoothness   = false,
    Aimbot_Prediction   = false,
    Aimbot_StickyAim    = false,
    Aimbot_AimPart      = "Head",
    Aimbot_ShowFOV      = false,
    Aimbot_FOVSize      = 250,
    Aimbot_FOVColor     = "#7c6cff",
    Aimbot_SmoothValue  = 5,
    Aimbot_PredX        = 0,
    Aimbot_PredY        = 0,

    -- Triggerbot
    Triggerbot_Enabled  = false,
    Triggerbot_TeamCheck = false,
    Triggerbot_Chance   = 100,
    Triggerbot_Delay    = 0,

    -- Silent Aim
    SilentAim_Enabled   = false,
    SilentAim_WallCheck = false,
    SilentAim_TeamCheck = false,
    SilentAim_UseFOV    = false,
    SilentAim_FOVSize   = 500,
    SilentAim_FOVColor  = "#ff0000",
    SilentAim_Hitchance = 100,
    SilentAim_HitPart   = "Head",
    SilentAim_AutoClick = false,

    -- Ragebot
    Ragebot_Enabled     = false,

    -- Player
    Fly_Enabled         = false,
    Fly_Speed           = 16,
    WalkSpeed_Enabled   = false,
    WalkSpeed_Value     = 16,
    InfJump_Enabled     = false,
    Noclip_Enabled      = false,

    -- Teleport
    TPBehind_Enabled    = false,
    TPBehind_Distance   = 5,
    TPBehind_MaxDist    = 1000,

    -- World
    World_ColorCorrection = false,
    World_TintColor     = "#ffffff",
    World_Contrast      = 0,
    World_Saturation    = 0,
    World_CustomTime    = false,
    World_TimeOfDay     = 12,
    World_Ambient       = "#000000",
    World_OutdoorAmbient = "#000000",
    World_ShadowColor   = "#000000",
    World_Brightness    = 1,
    World_Fullbright    = false,
    World_FogEnabled    = false,
    World_FogColor      = "#ffffff",
    World_FogDensity    = 0.1,
    World_Skybox        = "Default",
    World_BloomEnabled  = false,
    World_BloomIntensity = 0.5,
    World_BloomSize     = 24,
    World_BloomThreshold = 0.8,

    -- Crosshair
    Crosshair_Enabled   = false,
    Crosshair_Rotation  = false,
    Crosshair_RotSpeed  = 3,
    Crosshair_Length    = 10,
    Crosshair_Thickness = 3,
    Crosshair_Color     = "#ff0000",
    Crosshair_Rainbow   = false,

    -- Hit Sounds
    HitSound_Enabled    = false,
    HitSound_Volume     = 5,
    HitSound_Selection  = "None",

    -- Device Spoofer
    DeviceSpoofer_Active = "MouseKeyboard",

    -- Trash Talk
    TrashTalk_Enabled   = false,

    -- Matchmaking
    MM_Queue            = "none",

    -- Skin Changer
    SkinChanger_Enabled = false,
}

local Config = {}
Config._folder = CACHE_FOLDER
Config._file   = SETTINGS_FILE

local SERIALIZABLE = { boolean = true, number = true, string = true }

local function deepCopy(t)
    local out = {}
    for k, v in pairs(t) do out[k] = v end
    return out
end

local function ensureFolder()
    pcall(function()
        if makefolder and not (isfolder and isfolder(CACHE_FOLDER)) then
            makefolder(CACHE_FOLDER)
        end
    end)
end

function Config.Load()
    ensureFolder()
    local settings = deepCopy(Defaults)

    pcall(function()
        if isfile and isfile(SETTINGS_FILE) then
            local raw = readfile(SETTINGS_FILE)
            local decoded = HttpService:JSONDecode(raw)
            if typeof(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if Defaults[k] ~= nil and SERIALIZABLE[typeof(v)] then
                        settings[k] = v
                    end
                end
            end
        end
    end)

    Config.Settings = settings
    return settings
end

function Config.Save()
    ensureFolder()
    pcall(function()
        if writefile and Config.Settings then
            local clean = {}
            for k, v in pairs(Config.Settings) do
                if SERIALIZABLE[typeof(v)] then
                    clean[k] = v
                end
            end
            writefile(SETTINGS_FILE, HttpService:JSONEncode(clean))
        end
    end)
end

function Config.Reset()
    Config.Settings = deepCopy(Defaults)
    pcall(function()
        if writefile then
            writefile(SETTINGS_FILE, "{}")
        end
    end)
end

function Config.Get(key)
    return Config.Settings and Config.Settings[key]
end

function Config.Set(key, value)
    if Config.Settings then
        Config.Settings[key] = value
        Config.Save()
    end
end

Config.Load()
return Config
