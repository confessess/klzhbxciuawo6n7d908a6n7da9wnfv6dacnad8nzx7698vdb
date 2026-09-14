-- ============================================================
-- Rivals Modular -- Misc
-- Hit sounds, device spoofer, particles, trash talk,
-- custom crosshair, teleport, matchmaking
-- ============================================================

local Misc = {}

local Config, Utils, GUI, Core
local Players, LocalPlayer, RunService, UserInputService, Camera, ReplicatedStorage

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
    -- Hook into the viewmodel to detect hits
    local function onDescendantAdded(desc)
        if desc:IsA("Sound") and not desc:GetAttribute("Processed") then
            desc:SetAttribute("Processed", true)
            -- Check if it's a hit sound (has short duration)
            task.delay(0.1, function()
                if desc.Parent then
                    playHitSound()
                    desc:Stop()
                end
            end)
        end
    end

    local function hookViewModel()
        local ok, vm = pcall(function()
            return LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel
        end)
        if ok and vm then
            vm.DescendantAdded:Connect(onDescendantAdded)
        end
    end

    task.delay(2, hookViewModel)
    LocalPlayer.CharacterAdded:Connect(function()
        task.delay(2, hookViewModel)
    end)
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

    spooferConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            ReplicatedStorage.Remotes.Replication.Fighter.SetControls:FireServer(device)
        end)
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

local function updateCrosshair(dt)
    local enabled = Config.Get("Crosshair_Enabled") == true
    if not enabled or Core.MenuOpen then
        for _, line in ipairs(crosshairLines) do
            line.Visible = false
        end
        return
    end

    -- Initialize lines
    if #crosshairLines == 0 then
        for i = 1, 2 do
            local line = Utils.NewLine(3, Color3.fromRGB(255, 0, 0), 0)
            if line then
                table.insert(crosshairLines, line)
            end
        end
    end

    -- Update rotation
    if Config.Get("Crosshair_Rotation") then
        local speed = Config.Get("Crosshair_RotSpeed") or 3
        crosshairRotation = (crosshairRotation + speed * dt * 60) % 360
    end

    -- Get color
    local color
    if Config.Get("Crosshair_Rainbow") then
        color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    else
        color = Utils.HexToColor(Config.Get("Crosshair_Color"))
    end

    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local length = Config.Get("Crosshair_Length") or 10
    local thickness = Config.Get("Crosshair_Thickness") or 3

    -- Calculate rotated positions
    local angle = math.rad(crosshairRotation)
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)

    -- Horizontal line
    local hLine = crosshairLines[1]
    if hLine then
        local offset = Vector2.new(length, 0)
        local rotated = Vector2.new(offset.X * cosA - offset.Y * sinA, offset.X * sinA + offset.Y * cosA)
        hLine.From = center - rotated
        hLine.To = center + rotated
        hLine.Color = color
        hLine.Thickness = thickness
        hLine.Visible = true
    end

    -- Vertical line
    local vLine = crosshairLines[2]
    if vLine then
        local offset = Vector2.new(0, length)
        local rotated = Vector2.new(offset.X * cosA - offset.Y * sinA, offset.X * sinA + offset.Y * cosA)
        vLine.From = center - rotated
        vLine.To = center + rotated
        vLine.Color = color
        vLine.Thickness = thickness
        vLine.Visible = true
    end
end

-- ------------------------------------------------------------
-- Teleport Behind Enemy
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

local function teleportBehindEnemy()
    if not Config.Get("TPBehind_Enabled") then return end

    local maxDist = Config.Get("TPBehind_MaxDist") or 1000
    local behindDist = Config.Get("TPBehind_Distance") or 5

    local target = getNearestEnemy()
    if not target then return end

    local localRoot = Utils.CharacterRoot(LocalPlayer)
    local targetRoot = Utils.CharacterRoot(target)
    if not localRoot or not targetRoot then return end

    local dist = (targetRoot.Position - localRoot.Position).Magnitude
    if dist > maxDist then return end

    local behindPos = targetRoot.Position - targetRoot.CFrame.LookVector * behindDist
    localRoot.CFrame = CFrame.new(behindPos)
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

    -- Teleport behind enemy
    if Config.Get("TPBehind_Enabled") then
        teleportBehindEnemy()
    end
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

    -- Register GUI
    local page = GUI.GetPage and GUI.GetPage("Misc")
    if page then
        GUI.AddSection(page, "Hit Sounds", 1)
        GUI.AddToggle(page, "Enabled",
            function() return Config.Get("HitSound_Enabled") end,
            function(v) Config.Set("HitSound_Enabled", v) end, 2)
        GUI.AddSlider(page, "Volume", 0, 10,
            function() return Config.Get("HitSound_Volume") end,
            function(v) Config.Set("HitSound_Volume", v) end, 3)
        GUI.AddDropdown(page, "Sound",
            function() return HIT_SOUND_LIST end,
            function() return Config.Get("HitSound_Selection") end,
            function(v) Config.Set("HitSound_Selection", v) end, 4)

        GUI.AddSection(page, "Device Spoofer", 5)
        GUI.AddDropdown(page, "Device",
            function() return {"MouseKeyboard", "Touch", "Gamepad", "VR"} end,
            function() return Config.Get("DeviceSpoofer_Active") end,
            function(v)
                Config.Set("DeviceSpoofer_Active", v)
                updateDeviceSpoofer()
            end, 6)

        GUI.AddSection(page, "Particles", 7)
        GUI.AddButton(page, "Remove Flashbang",
            function() removeFlash() end, 8, false)
        GUI.AddButton(page, "Remove Smoke",
            function() removeSmoke() end, 9, false)
        GUI.AddButton(page, "Random Fire Color",
            function() randomizeFire() end, 10, false)

        GUI.AddSection(page, "Custom Crosshair", 11)
        GUI.AddToggle(page, "Enabled",
            function() return Config.Get("Crosshair_Enabled") end,
            function(v) Config.Set("Crosshair_Enabled", v) end, 12)
        GUI.AddToggle(page, "Rotation",
            function() return Config.Get("Crosshair_Rotation") end,
            function(v) Config.Set("Crosshair_Rotation", v) end, 13)
        GUI.AddSlider(page, "Rotation Speed", 1, 10,
            function() return Config.Get("Crosshair_RotSpeed") end,
            function(v) Config.Set("Crosshair_RotSpeed", v) end, 14)
        GUI.AddSlider(page, "Length", 1, 50,
            function() return Config.Get("Crosshair_Length") end,
            function(v) Config.Set("Crosshair_Length", v) end, 15)
        GUI.AddSlider(page, "Thickness", 1, 10,
            function() return Config.Get("Crosshair_Thickness") end,
            function(v) Config.Set("Crosshair_Thickness", v) end, 16)
        GUI.AddToggle(page, "Rainbow",
            function() return Config.Get("Crosshair_Rainbow") end,
            function(v) Config.Set("Crosshair_Rainbow", v) end, 17)

        GUI.AddSection(page, "Trash Talk", 18)
        GUI.AddToggle(page, "Enabled (Press V)",
            function() return Config.Get("TrashTalk_Enabled") end,
            function(v) Config.Set("TrashTalk_Enabled", v) end, 19)

        GUI.AddSection(page, "Teleport", 20)
        GUI.AddToggle(page, "TP Behind Enemy",
            function() return Config.Get("TPBehind_Enabled") end,
            function(v) Config.Set("TPBehind_Enabled", v) end, 21)
        GUI.AddSlider(page, "TP Distance", 1, 10,
            function() return Config.Get("TPBehind_Distance") end,
            function(v) Config.Set("TPBehind_Distance", v) end, 22)

        GUI.AddSection(page, "Matchmaking", 23)
        GUI.AddDropdown(page, "Join Queue",
            function() return {"none", "1v1", "2v2", "3v3", "4v4", "5v5", "1v1v1", "2v2v2", "2v2_beginner"} end,
            function() return Config.Get("MM_Queue") end,
            function(v)
                Config.Set("MM_Queue", v)
                joinQueue(v)
            end, 24)
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
