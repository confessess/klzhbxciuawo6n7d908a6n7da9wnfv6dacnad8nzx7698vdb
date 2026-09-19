-- ============================================================
-- Rivals Modular -- Misc
-- Hit sounds, device spoofer, particles, trash talk,
-- custom crosshair, teleport, matchmaking
-- Master Section UI: Each header toggles its own module
-- ============================================================

local Misc = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, RunService, UserInputService, Camera, ReplicatedStorage
local spooferLoop = false

-- Hit sounds
local HIT_SOUNDS = {
    ["Skeet.cc"] = "rbxassetid://5447626464",
    ["Baimware"] = "rbxassetid://6607339542",
    ["Neverlose"] = "rbxassetid://6607204501",
    ["Rust"] = "rbxassetid://5043539486",
    ["Gamesense"] = "rbxassetid://4817809188",
    ["Bell"] = "rbxassetid://6534947240",
    ["TF2"] = "rbxassetid://2868331684",
    ["Among Us"] = "rbxassetid://5700183626",
    ["Fortnite Headshot"] = "rbxassetid://2513174484",
    ["Minecraft"] = "rbxassetid://4018616850",
    ["Osu"] = "rbxassetid://7149255551",
    ["TF2 Critical"] = "rbxassetid://296102734",
    ["Bat"] = "rbxassetid://3333907347",
    ["Call of Duty"] = "rbxassetid://5952120301",
    ["Bubble"] = "rbxassetid://6534947588",
    ["Bruh"] = "rbxassetid://4275842574",
    ["Bamboo"] = "rbxassetid://3769434519",
    ["Crowbar"] = "rbxassetid://546410481",
    ["Weeb"] = "rbxassetid://6442965016",
    ["Beep"] = "rbxassetid://8177256015",
    ["Bambi"] = "rbxassetid://8437203821",
    ["Old Fatality"] = "rbxassetid://6607142036",
    ["Mario"] = "rbxassetid://2815207981",
    ["Steve"] = "rbxassetid://4965083997",
}

local HIT_SOUND_LIST = {
    "None", "Among Us", "Baimware", "Bat", "Bell", "Call of Duty",
    "Crowbar", "Fortnite Headshot", "Minecraft", "Neverlose",
    "Old Fatality", "Osu", "Rust", "Skeet.cc", "Steve", "TF2", "TF2 Critical"
}

-- Trash talk messages
local TRASH_MESSAGES = {
    "where are you aiming at?", "sonned", "bad", "even my grandma has faster reactions",
    ":clown:", "gg = get good", "im just better", "my gaming chair is just better",
    "clip me", "skill", ":Skull:", "go play adopt me", "go play brookhaven",
    "omg you are so good :screm:", "awesome", "you built like gru", "fridge",
    "do not bully pliisss :sobv:", "it was your lag ofc", "fly high",
    "*cough* *cough*", "son", "already mad?", "please don't report :sobv:",
    "sob harder", "alt + f4 for better aim", "bro can't even aim", "free kill",
    "thanks for the warm-up", "uninstall pls", "bet you can't hit a barn",
    "you lagging or what?", "try harder", "oh no, you're so scary",
    "you sure you're playing?", "that's it?", "must be your first time", "ez",
    "press Q to cry", "get a refund on your skills", "you're not that guy",
    "ouch, that was embarrassing", "no scope, no skill", "you look lost",
    "need help aiming?", "hold this L", "get rekt", "game over",
    "try again, maybe?", "what was that?", "no challenge at all",
    "level up your game", "delete system32", "I'm built different",
    "was that your best?", "you're softer than butter", "get clapped",
    "did you try turning it off and on again?", "boop, headshot", "smoked",
    "GG no re", "brain.exe stopped working", "better luck next time",
    "you tried, and that's cute", "are you serious right now?",
    "controller disconnected?", "your Wi-Fi playing for you?", "AFK or just bad?",
    "another one bites the dust", "you blinked and missed", "rookie move",
    "outplayed", "so close, yet so far", "that was tragic", "need a map?",
    "pack it up", "somebody uninstall", "better switch games", "missed me!",
    "predictable", "wow, impressive... not", "time to retire",
    "aim better, talk less", "oops, you slipped", "just uninstall already",
    "cry more, try less", "game sense is missing", "outskilled",
    "thanks for the highlight", "was that your secret move?", "yawn, too easy",
    "is your screen on?", "is that all you've got?", "the bot is better than you",
    "next time, bring skill", "you good, bro?", "zero effort", "keep dreaming",
    "the floor is your enemy", "bot behavior", "too predictable",
    "time for a rematch?", "you're joking, right?", "skill issue",
    "didn't see that coming, huh?", "oops, your skill leaked",
    "aiming practice needed", "outclassed", "step up your game", "flatline",
    "you just got benched", "casual spotted", "still warming up?",
    "forever stuck in tutorial?", "the audacity!", "lag excuse incoming",
    "is this a speedrun to lose?", "back to the drawing board", "better luck never",
    "your ego is misplaced", "that's just embarrassing", "you call that a strategy?",
    "practice more, cry less", "I've seen bots with better moves", "controller drift?",
    "you're like a free XP farm", "guess you missed the tutorial",
    "I didn't know we were playing hide and seek", "thanks for the easy W",
    "are you playing with your feet?", "is this your first time?",
    "even a potato has better aim", "the floor appreciates your effort",
    "you're just warming my seat", "you're basically a spectator",
    "bro really said 'skill gap'", "too slow, try again",
    "you walked right into that one", "come back when you're ready",
    "you might want to uninstall for real", "ever heard of aiming?",
    "rookie mistake", "you're better at losing", "is this your alt account?",
    "carry harder, I'm bored", "oops, forgot to try",
    "your aim is in another dimension", "are you even looking at your screen?",
    "you're on the wrong team", "I'll carry the pity points",
    "this is just sad", "when's the real challenge?", "too bad, so sad",
    "don't quit your day job", "you're like a walking target",
    "that was your peak?", "next time, try to hit something",
    "ouch, even the NPCs are laughing", "you're in the wrong game mode",
    "that's not how you win", "guess who's carrying?", "did you forget to show up?",
    "at least you're consistent", "you must be new here", "how did you miss that?",
    "I'm playing with my eyes closed", "this is just bullying",
    "you're my new favorite target", "did you mean to miss?",
    "get better, not bitter", "is this what losing feels like?",
    "did your dog take over the controls?", "stop, you're embarrassing us both",
    "are you even trying?", "that was cute",
    "you're like my personal highlight reel", "your strategy is confusing...ly bad",
    "is this your 'pro' move?", "oops, I win again",
    "your Wi-Fi needs an upgrade", "you're a gift that keeps on giving",
    "you're just filling my montage", "is this a charity match?",
    "congrats, you lost again", "try turning the monitor on next time"
}

-- Crosshair state
local crosshairLines = {}
local crosshairRotation = 0

-- Device spoofer
local spooferConn = nil

-- ------------------------------------------------------------
-- Hit Sounds
-- ------------------------------------------------------------

local function playHitSound()
    if not Config.Get("HitSound_Enabled") then return end
    local selection = Config.Get("HitSound_Selection") or "None"
    local soundId = HIT_SOUNDS[selection]
    if not soundId then return end

    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = (Config.Get("HitSound_Volume") or 5) / 10
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function setupHitSounds()
    -- DISABLED - causes crashes from constant sound creation
end

-- ------------------------------------------------------------
-- Device Spoofer
-- ------------------------------------------------------------

local function updateDeviceSpoofer()
    local device = Config.Get("DeviceSpoofer_Active") or "MouseKeyboard"

    if spooferConn then
        spooferConn:Disconnect()
        spooferConn = nil
    end

    if spooferLoop then
        spooferLoop = false
        task.wait(1.1)
    end
    spooferLoop = true

    task.spawn(function()
        while spooferLoop do
            task.wait(1)
            pcall(function()
                ReplicatedStorage.Remotes.Replication.Fighter.SetControls:FireServer(device)
            end)
        end
    end)
end

-- ------------------------------------------------------------
-- Particles
-- ------------------------------------------------------------

local function removeFlash()
    pcall(function()
        local flash = LocalPlayer.PlayerScripts.Assets.Misc:FindFirstChild("FlashbangEffect")
        if flash then flash:Destroy() end
    end)
end

local function removeSmoke()
    pcall(function()
        local smoke = LocalPlayer.PlayerScripts.Assets.Misc:FindFirstChild("SmokeClouds")
        if smoke then smoke:Destroy() end
    end)
end

local function randomizeFire()
    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("ParticleEmitter") and desc.Name == "Fire" then
            local keypoints = {}
            for i = 0, 1, 0.25 do
                table.insert(keypoints, ColorSequenceKeypoint.new(i, Color3.new(math.random(), math.random(), math.random())))
            end
            desc.Color = ColorSequence.new(keypoints)
        end
    end
end

-- ------------------------------------------------------------
-- Trash Talk
-- ------------------------------------------------------------

local function sendTrashMessage()
    local message = TRASH_MESSAGES[math.random(1, #TRASH_MESSAGES)]
    local TextChatService = game:GetService("TextChatService")

    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
        else
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        end
    end)
end

-- ------------------------------------------------------------
-- Custom Crosshair
-- ------------------------------------------------------------

local crosshairGui = nil

local function updateCrosshair(dt)
    -- Disabled for stability
    return
end

-- ------------------------------------------------------------
-- Teleport Behind Enemy (moved to teleport.lua, keeping for compat)
-- ------------------------------------------------------------

local function getNearestEnemy()
    local localRoot = Utils.CharacterRoot(LocalPlayer)
    if not localRoot then return nil end

    local nearest = nil
    local nearestDist = math.huge

    for _, player in ipairs(Utils.GetEnemies()) do
        local root = Utils.CharacterRoot(player)
        if root then
            local dist = (root.Position - localRoot.Position).Magnitude
            if dist < nearestDist then
                nearest = player
                nearestDist = dist
            end
        end
    end

    return nearest
end

-- ------------------------------------------------------------
-- Matchmaking
-- ------------------------------------------------------------

local function joinQueue(queueType)
    local mm = ReplicatedStorage.Remotes.Matchmaking
    pcall(function()
        mm.LeaveQueue:FireServer()
        if queueType ~= "none" then
            task.wait(0.1)
            mm.JoinQueue:InvokeServer(queueType)
        end
    end)
end

-- ------------------------------------------------------------
-- Main Update
-- ------------------------------------------------------------

function Misc.Update(dt)
    if Core.Unloaded then return end
    updateCrosshair(dt)
end

-- ------------------------------------------------------------
-- Lifecycle
-- ------------------------------------------------------------

function Misc.Init(deps)
    Config         = deps.Config
    Utils          = deps.Utils
    GUI            = deps.GUI
    Core           = deps.Core
    Players        = Utils.Players
    LocalPlayer    = Utils.LocalPlayer
    RunService     = Utils.RunService
    UserInputService = Utils.UserInputService
    Camera         = Utils.Camera
    ReplicatedStorage = Utils.ReplicatedStorage

    -- Setup hit sounds
    setupHitSounds()

    -- Device spoofer
    updateDeviceSpoofer()

    -- Trash talk keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.V and Config.Get("TrashTalk_Enabled") then
            sendTrashMessage()
        end
    end)

    -- Register GUI (Misc tab) with Master Sections
    local page = GUI.GetPage and GUI.GetPage("Misc")
    if page then
        local C = GUI.Components

        -- ========================================
        -- HIT SOUNDS MASTER SECTION
        -- ========================================
        local hitSection, setHitOpen = C.MasterSection(page, "Hit Sounds", 90, Config.Get("HitSound_Enabled") or false)

        C.Toggle(hitSection, "Enabled", Config.Get("HitSound_Enabled"), function(v) Config.Set("HitSound_Enabled", v) end, 91)
        C.Slider(hitSection, "Volume", 0, 10, Config.Get("HitSound_Volume"), function(v) Config.Set("HitSound_Volume", v) end, 92)
        C.Dropdown(hitSection, "Sound", HIT_SOUND_LIST, Config.Get("HitSound_Selection"), function(v) Config.Set("HitSound_Selection", v) end, 93)

        setHitOpen(Config.Get("HitSound_Enabled") or false)

        -- ========================================
        -- CROSSHAIR MASTER SECTION
        -- ========================================
        local crossSection, setCrossOpen = C.MasterSection(page, "Crosshair", 100, Config.Get("Crosshair_Enabled") or false)

        C.Toggle(crossSection, "Enabled", Config.Get("Crosshair_Enabled"), function(v) Config.Set("Crosshair_Enabled", v) end, 101)
        C.Toggle(crossSection, "Rainbow", Config.Get("Crosshair_Rainbow"), function(v) Config.Set("Crosshair_Rainbow", v) end, 102)

        setCrossOpen(Config.Get("Crosshair_Enabled") or false)

        -- ========================================
        -- TRASH TALK MASTER SECTION
        -- ========================================
        local trashSection, setTrashOpen = C.MasterSection(page, "Trash Talk (V)", 110, Config.Get("TrashTalk_Enabled") or false)

        C.Toggle(trashSection, "Enabled", Config.Get("TrashTalk_Enabled"), function(v) Config.Set("TrashTalk_Enabled", v) end, 111)

        setTrashOpen(Config.Get("TrashTalk_Enabled") or false)
    end

    print("[rivals] Misc module initialized.")
end

function Misc.Cleanup()
    if spooferConn then
        spooferConn:Disconnect()
        spooferConn = nil
    end
    for _, line in ipairs(crosshairLines) do
        Utils.DestroyDrawing(line)
    end
    crosshairLines = {}
end

return Misc
