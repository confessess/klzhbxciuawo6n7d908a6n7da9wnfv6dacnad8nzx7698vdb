-- ============================================================
-- RIVALS GUI v3 - With icons and purple underglow
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- GUI table (defined early to prevent nil errors)
local GUI = {}

-- Theme
local Theme = {
    Background = Color3.fromRGB(26, 26, 36),
    Darker = Color3.fromRGB(20, 20, 28),
    Card = Color3.fromRGB(30, 30, 42),
    Element = Color3.fromRGB(35, 35, 48),
    ElementHover = Color3.fromRGB(42, 42, 58),
    Stroke = Color3.fromRGB(50, 50, 68),
    Text = Color3.fromRGB(220, 220, 235),
    TextDim = Color3.fromRGB(100, 100, 120),
    Accent = Color3.fromRGB(130, 100, 255),
    AccentLight = Color3.fromRGB(160, 130, 255),
    Blue = Color3.fromRGB(80, 140, 255),
    Green = Color3.fromRGB(60, 200, 100),
}

local TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Icon IDs
local Icons = {
    Combat = "rbxassetid://93112623799121",
    Visuals = "rbxassetid://77636811910093",
    Skins = "rbxassetid://118949441189559",
    Misc = "rbxassetid://95043878684254",
    Settings = "rbxassetid://124034566612418",
}

-- State
local ScreenGui, MainFrame, TabBar, ContentHost
local Pages = {}
local ActiveTab = nil
local IsOpen = false

local function tween(obj, props)
    TweenService:Create(obj, TWEEN, props):Play()
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = parent
end

local function stroke(parent, color, t, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = t or 1
    s.Transparency = trans or 0
    s.Parent = parent
end

-- ============================================================
-- COMPONENTS
-- ============================================================

local Components = {}

function Components.Section(page, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or 0
    lbl.Parent = page
    return lbl
end

function Components.Toggle(page, label, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order or 0
    frame.Parent = page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromOffset(36, 20)
    bg.Position = UDim2.new(1, -36, 0.5, -10)
    bg.BackgroundColor3 = default and Theme.Blue or Theme.Element
    bg.BorderSizePixel = 0
    bg.Parent = frame
    corner(bg, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
    knob.BorderSizePixel = 0
    knob.Parent = bg
    corner(knob, 7)

    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            tween(bg, {BackgroundColor3 = Theme.Blue})
            tween(knob, {Position = UDim2.new(1, -17, 0.5, -7)})
        else
            tween(bg, {BackgroundColor3 = Theme.Element})
            tween(knob, {Position = UDim2.new(0, 3, 0.5, -7)})
        end
        if callback then callback(state) end
    end)

    return {Set = function(v) state = v end, Get = function() return state end}
end

function Components.Dropdown(page, label, options, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.LayoutOrder = order or 0
    frame.ClipsDescendants = false
    frame.Parent = page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 0, 32)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0.55, 0, 0, 28)
    box.Position = UDim2.new(0.45, 0, 0, 2)
    box.BackgroundColor3 = Theme.Element
    box.BorderSizePixel = 0
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = frame
    corner(box, 4)
    stroke(box, Theme.Stroke, 1, 0.5)

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(1, -30, 1, 0)
    valueLbl.Position = UDim2.new(0, 10, 0, 0)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(default or "Select...")
    valueLbl.TextColor3 = Theme.TextDim
    valueLbl.Font = Enum.Font.GothamMedium
    valueLbl.TextSize = 12
    valueLbl.TextXAlignment = Enum.TextXAlignment.Left
    valueLbl.Parent = box

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(16, 16)
    arrow.Position = UDim2.new(1, -22, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.TextDim
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 8
    arrow.Parent = box

    local list = Instance.new("Frame")
    list.Size = UDim2.new(0.55, 0, 0, 0)
    list.Position = UDim2.new(0.45, 0, 0, 34)
    list.BackgroundColor3 = Theme.Card
    list.BorderSizePixel = 0
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 10
    list.Parent = frame
    corner(list, 4)
    stroke(list, Theme.Stroke, 1, 0.3)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list

    local expanded = false
    local currentValue = default

    local function rebuild()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.BackgroundColor3 = Theme.Element
            optBtn.BorderSizePixel = 0
            optBtn.Text = ""
            optBtn.AutoButtonColor = false
            optBtn.LayoutOrder = i
            optBtn.ZIndex = 11
            optBtn.Parent = list

            local optLbl = Instance.new("TextLabel")
            optLbl.Size = UDim2.new(1, -16, 1, 0)
            optLbl.Position = UDim2.new(0, 8, 0, 0)
            optLbl.BackgroundTransparency = 1
            optLbl.Text = tostring(opt)
            optLbl.TextColor3 = (currentValue == opt) and Theme.Blue or Theme.TextDim
            optLbl.Font = Enum.Font.GothamMedium
            optLbl.TextSize = 12
            optLbl.TextXAlignment = Enum.TextXAlignment.Left
            optLbl.ZIndex = 12
            optLbl.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                currentValue = opt
                valueLbl.Text = tostring(opt)
                if callback then callback(opt) end
                expanded = false
                tween(list, {Size = UDim2.new(0.55, 0, 0, 0)})
                task.delay(0.15, function() list.Visible = false end)
            end)
        end
    end

    box.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            rebuild()
            list.Visible = true
            local h = math.min(#options * 28, 180)
            tween(list, {Size = UDim2.new(0.55, 0, 0, h)})
        else
            tween(list, {Size = UDim2.new(0.55, 0, 0, 0)})
            task.delay(0.15, function() list.Visible = false end)
        end
    end)

    return {Set = function(v) currentValue = v valueLbl.Text = tostring(v) end, Get = function() return currentValue end}
end

function Components.Slider(page, label, min, max, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order or 0
    frame.Parent = page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(0.2, 0, 0, 20)
    valueLbl.Position = UDim2.new(0.8, 0, 0, 0)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(default)
    valueLbl.TextColor3 = Theme.TextDim
    valueLbl.Font = Enum.Font.GothamMedium
    valueLbl.TextSize = 12
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = Theme.Element
    track.BorderSizePixel = 0
    track.Parent = frame
    corner(track, 2)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
    fill.BackgroundColor3 = Theme.Blue
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 2)

    local value = default
    local dragging = false

    local function update()
        valueLbl.Text = tostring(value)
        fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + rel * (max - min) + 0.5)
            update()
            if callback then callback(value) end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + rel * (max - min) + 0.5)
            update()
            if callback then callback(value) end
        end
    end)

    return {Set = function(v) value = v update() end, Get = function() return value end}
end

function Components.Button(page, label, callback, order, isDanger)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = isDanger and Color3.fromRGB(180, 60, 60) or Theme.Element
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.LayoutOrder = order or 0
    btn.Parent = page
    corner(btn, 4)

    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = isDanger and Color3.fromRGB(200, 70, 70) or Theme.ElementHover})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = isDanger and Color3.fromRGB(180, 60, 60) or Theme.Element})
    end)

    return btn
end

-- ============================================================
-- TAB SYSTEM WITH ICONS
-- ============================================================

-- Early no-op definition (will be overridden after previews created)
GUI.UpdatePreviewVisibility = function() end

local function switchTab(name)
    if ActiveTab == name then return end
    ActiveTab = name

    local ok, err = pcall(function()
        for tabName, page in pairs(Pages) do
            page.Visible = (tabName == name)
        end
        GUI.UpdatePreviewVisibility()
    end)
    if not ok then
        warn("[GUI] Tab error: " .. tostring(err))
    end

    -- Update tab styles
    for _, child in ipairs(TabBar:GetChildren()) do
        if child:IsA("TextButton") then
            local isActive = (child.Name == "Tab_" .. name)
            local icon = child:FindFirstChild("Icon")
            local glow = child:FindFirstChild("Glow")

            if icon then
                tween(icon, {ImageColor3 = isActive and Theme.AccentLight or Color3.fromRGB(180, 180, 200)})
            end

            if glow then
                tween(glow, {BackgroundTransparency = isActive and 0.3 or 1})
                tween(glow, {Size = isActive and UDim2.new(0.5, 0, 0, 2) or UDim2.new(0, 0, 0, 2)})
            end
        end
    end
end

local function createTab(name, iconId, order)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. name
    btn.Size = UDim2.new(0, 95, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = TabBar

    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    -- Skins icon (paintbrush) needs bigger size
    if name == "Skins" then
        icon.Size = UDim2.fromOffset(56, 56)
        icon.Position = UDim2.new(0.5, -28, 0.5, -28)
    else
        icon.Size = UDim2.fromOffset(32, 32)
        icon.Position = UDim2.new(0.5, -16, 0.5, -16)
    end
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Color3.fromRGB(180, 180, 200)
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = btn

    -- Purple underglow
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(0, 0, 0, 2)
    glow.Position = UDim2.new(0.25, 0, 1, -2)
    glow.BackgroundColor3 = Theme.Accent
    glow.BorderSizePixel = 0
    glow.BackgroundTransparency = 1
    glow.Parent = btn
    corner(glow, 1)

    -- Glow shadow effect
    local glowShadow = Instance.new("ImageLabel")
    glowShadow.Name = "GlowShadow"
    glowShadow.Size = UDim2.new(0.5, 20, 0, 8)
    glowShadow.Position = UDim2.new(0.25, -10, 1, -6)
    glowShadow.BackgroundTransparency = 1
    glowShadow.Image = "rbxassetid://5554236805"
    glowShadow.ImageColor3 = Theme.Accent
    glowShadow.ImageTransparency = 0.5
    glowShadow.ScaleType = Enum.ScaleType.Slice
    glowShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    glowShadow.Visible = false
    glowShadow.Parent = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    -- Page
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Stroke
    page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.fromScale(0, 0)
    page.Parent = ContentHost

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingTop = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 20)
    pad.PaddingBottom = UDim.new(0, 20)
    pad.Parent = page

    Pages[name] = page
    return page
end

-- ============================================================
-- MAIN GUI
-- ============================================================

local function build()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RivalsGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = playerGui

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
    MainFrame.Size = UDim2.fromOffset(780, 520)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    corner(MainFrame, 8)
    stroke(MainFrame, Theme.Stroke, 1, 0.3)

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 100, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "RIVALS"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = MainFrame

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 6)
    closeBtn.BackgroundColor3 = Theme.Element
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.TextDim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = MainFrame
    corner(closeBtn, 4)

    closeBtn.MouseButton1Click:Connect(function()
        setOpen(false)
    end)

    -- Tab bar
    TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -40, 0, 52)
    TabBar.Position = UDim2.new(0, 20, 0, 52)
    TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame
    corner(TabBar, 6)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = TabBar

    -- Content
    ContentHost = Instance.new("Frame")
    ContentHost.Size = UDim2.new(1, -40, 1, -108)
    ContentHost.Position = UDim2.new(0, 20, 0, 108)
    ContentHost.BackgroundTransparency = 1
    ContentHost.ClipsDescendants = true
    ContentHost.Parent = MainFrame

    -- Create tabs with icons
    createTab("Combat", Icons.Combat, 1)
    createTab("Visuals", Icons.Visuals, 2)
    createTab("Skins", Icons.Skins, 3)
    createTab("Misc", Icons.Misc, 4)
    createTab("Settings", Icons.Settings, 5)

    -- Keybind
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            setOpen(not IsOpen)
        end
    end)

    -- Update preview visibility function (defined after frames exist)
    local function updatePreviewVisibility()
        if GUI.SkinPreviewFrame then
            GUI.SkinPreviewFrame.Visible = (ActiveTab == "Skins") and IsOpen
        end
        if GUI.ESPPreviewFrame then
            GUI.ESPPreviewFrame.Visible = (ActiveTab == "Visuals") and IsOpen
        end
    end
    GUI.UpdatePreviewVisibility = updatePreviewVisibility

    switchTab("Combat")
end

function setOpen(state)
    IsOpen = state
    if state then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.fromOffset(780, 0)
        tween(MainFrame, {Size = UDim2.fromOffset(780, 520)})
    else
        tween(MainFrame, {Size = UDim2.fromOffset(680, 0)})
        task.delay(0.2, function()
            MainFrame.Visible = false
        end)
    end
end

-- ============================================================
-- MODULE INIT
-- ============================================================

local GUI = {}

function GUI.Init(deps)
    Config = deps.Config
    Utils = deps.Utils
    Core = deps.Core

    local ok, err = pcall(function()
        build()
        createPreviewWindows()
    end)
    if not ok then
        warn("[GUI] Build error: " .. tostring(err))
    end

    -- Update positions when main GUI moves
    if TitleBar then
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn
                conn = game:GetService("RunService").RenderStepped:Connect(function()
                    updatePreviewPositions()
                    if not IsOpen then
                        conn:Disconnect()
                    end
                end)
            end
        end)
    end

    -- Register demo controls for testing
    local combat = Pages["Combat"]
    Components.Section(combat, "Aimbot", 1)
    Components.Toggle(combat, "Enable", false, function(v) print("Aimbot:", v) end, 2)
    Components.Dropdown(combat, "Target Part", {"Head", "Chest", "Pelvis"}, "Head", function(v) print("Target:", v) end, 3)
    Components.Slider(combat, "FOV", 0, 360, 90, function(v) print("FOV:", v) end, 4)

    local visuals = Pages["Visuals"]
    Components.Section(visuals, "ESP", 1)
    Components.Toggle(visuals, "Enable Glow", false, function(v) print("ESP:", v) end, 2)

    local skins = Pages["Skins"]
    Components.Section(skins, "Skin Changer", 1)
    Components.Dropdown(skins, "Weapon", {"None", "Assault Rifle", "Uzi"}, "None", function(v) print("Weapon:", v) end, 2)

    local settings = Pages["Settings"]
    Components.Button(settings, "Unload", function() 
        if Core and Core.Unload then Core.Unload() end
    end, 1, true)

    print("[rivals] GUI initialized.")
end

function GUI.ToggleMenu()
    setOpen(not IsOpen)
end

function GUI.IsOpen()
    return IsOpen
end

function GUI.GetPage(name)
    return Pages[name]
end

function GUI.Cleanup()
    if ScreenGui then ScreenGui:Destroy() end
    if PreviewGui then PreviewGui:Destroy() end
end

-- Expose components for other modules
GUI.Components = Components

return GUI