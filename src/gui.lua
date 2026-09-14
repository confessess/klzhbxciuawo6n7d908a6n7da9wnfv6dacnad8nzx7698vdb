-- ============================================================
-- Rivals Modular -- GUI
-- Sleek dark sidebar menu
-- Tabs: Legit, Rage, Visuals, Player, Teleport, World, Skins, Misc, Settings
-- ============================================================

local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local GUI = {}

local Config, Utils, Core

-- ------------------------------------------------------------
-- Theme
-- ------------------------------------------------------------

local Theme = {
    Background   = Color3.fromRGB(10, 10, 14),
    Sidebar      = Color3.fromRGB(14, 14, 19),
    Card         = Color3.fromRGB(18, 18, 24),
    Element      = Color3.fromRGB(24, 24, 31),
    ElementHover = Color3.fromRGB(32, 32, 41),
    Stroke       = Color3.fromRGB(38, 38, 48),
    Text         = Color3.fromRGB(235, 235, 240),
    TextDim      = Color3.fromRGB(120, 120, 132),
    Accent       = Color3.fromRGB(124, 108, 255),
    AccentDark   = Color3.fromRGB(92, 80, 200),
    Green        = Color3.fromRGB(0, 190, 85),
    Red          = Color3.fromRGB(235, 60, 60),
}

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ------------------------------------------------------------
-- State
-- ------------------------------------------------------------

local ScreenGui, MenuFrame, Sidebar, ContentHost, TitleBar
local Watermark, MobileButton
local Pages     = {}
local ActiveTab = nil
local IsOpen    = false
local Keybind   = Enum.KeyCode.RightControl
local Dragging  = false
local DragStart = nil
local StartPos  = nil

GUI._components = {}

-- ------------------------------------------------------------
-- Small helpers
-- ------------------------------------------------------------

local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color or Theme.Stroke
    s.Thickness    = thickness or 1
    s.Transparency = transparency or 0
    s.Parent       = parent
    return s
end

local function makePadding(parent, l, t, r, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

-- ------------------------------------------------------------
-- Dragging
-- ------------------------------------------------------------

local function initDragging()
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Dragging  = true
            DragStart = input.Position
            StartPos  = MenuFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            MenuFrame.Position = UDim2.new(
                StartPos.X.Scale, StartPos.X.Offset + delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
end

-- ------------------------------------------------------------
-- Tab system
-- ------------------------------------------------------------

local function switchTab(name)
    if ActiveTab == name then return end
    ActiveTab = name

    for tabName, page in pairs(Pages) do
        page.Visible = (tabName == name)
    end

    for _, child in ipairs(Sidebar:GetChildren()) do
        if child:IsA("TextButton") and child.Name:sub(1, 4) == "Tab_" then
            local lbl = child:FindFirstChild("Label")
            if lbl then
                if child.Name == "Tab_" .. name then
                    tween(lbl, TWEEN_FAST, { TextColor3 = Theme.Text })
                    tween(child, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
                else
                    tween(lbl, TWEEN_FAST, { TextColor3 = Theme.TextDim })
                    tween(child, TWEEN_FAST, { BackgroundColor3 = Theme.Sidebar })
                end
            end
        end
    end
end

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Name             = "Tab_" .. name
    btn.Size             = UDim2.new(1, -12, 0, 34)
    btn.BackgroundColor3 = Theme.Sidebar
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.LayoutOrder      = order
    btn.Parent           = Sidebar
    makeCorner(btn, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Name                   = "Label"
    lbl.Size                   = UDim2.new(1, -16, 1, 0)
    lbl.Position               = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = name
    lbl.TextColor3             = Theme.TextDim
    lbl.Font                   = Enum.Font.GothamSemibold
    lbl.TextSize               = 13
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Parent                 = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    local page = Instance.new("ScrollingFrame")
    page.Name                   = "Page_" .. name
    page.Size                   = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel        = 0
    page.ScrollBarThickness     = 3
    page.ScrollBarImageColor3   = Theme.Stroke
    page.Visible                = false
    page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    page.CanvasSize             = UDim2.fromScale(0, 0)
    page.Parent                 = ContentHost

    local list = Instance.new("UIListLayout")
    list.Padding   = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent    = page

    makePadding(page, 14, 14, 14, 14)

    Pages[name] = page
    return page
end

function GUI.GetPage(name)
    return Pages[name]
end

-- ------------------------------------------------------------
-- Component: Section label
-- ------------------------------------------------------------

function GUI.AddSection(page, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = string.upper(text)
    lbl.TextColor3             = Theme.TextDim
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 11
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.LayoutOrder            = order or 0
    lbl.Parent                 = page
    return lbl
end

-- ------------------------------------------------------------
-- Component: Toggle
-- ------------------------------------------------------------

function GUI.AddToggle(page, label, getState, setState, order)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Theme.Element
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    btn.Parent           = page
    makeCorner(btn, 9)

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, -60, 1, 0)
    lbl.Position               = UDim2.new(0, 13, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = label
    lbl.TextColor3             = Theme.Text
    lbl.Font                   = Enum.Font.GothamMedium
    lbl.TextSize               = 13
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Parent                 = btn

    local track = Instance.new("Frame")
    track.Size             = UDim2.fromOffset(34, 18)
    track.Position         = UDim2.new(1, -45, 0.5, -9)
    track.BackgroundColor3 = Theme.Stroke
    track.BorderSizePixel  = 0
    track.Parent           = btn
    makeCorner(track, 9)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(14, 14)
    knob.Position         = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
    knob.BorderSizePixel  = 0
    knob.Parent           = track
    makeCorner(knob, 7)

    local function updateVisual()
        local on = getState()
        tween(track, TWEEN_FAST, {
            BackgroundColor3 = on and Theme.Green or Theme.Stroke
        })
        tween(knob, TWEEN_FAST, {
            Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        })
    end

    btn.MouseButton1Click:Connect(function()
        setState(not getState())
        updateVisual()
    end)

    btn.MouseEnter:Connect(function()
        tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.ElementHover })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
    end)

    updateVisual()
    table.insert(GUI._components, updateVisual)
    return btn, updateVisual
end

-- ------------------------------------------------------------
-- Component: Slider
-- ------------------------------------------------------------

function GUI.AddSlider(page, label, min, max, getValue, setValue, order)
    local wrapper = Instance.new("Frame")
    wrapper.Size             = UDim2.new(1, 0, 0, 52)
    wrapper.BackgroundColor3 = Theme.Element
    wrapper.BorderSizePixel  = 0
    wrapper.LayoutOrder      = order or 0
    wrapper.Parent           = page
    makeCorner(wrapper, 9)

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, -60, 0, 20)
    lbl.Position               = UDim2.new(0, 13, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Font                   = Enum.Font.GothamMedium
    lbl.TextSize               = 13
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.TextColor3             = Theme.Text
    lbl.Parent                 = wrapper

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size                   = UDim2.fromOffset(50, 20)
    valueLbl.Position               = UDim2.new(1, -58, 0, 7)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Font                   = Enum.Font.GothamBold
    valueLbl.TextSize               = 12
    valueLbl.TextColor3             = Theme.Accent
    valueLbl.TextXAlignment         = Enum.TextXAlignment.Right
    valueLbl.Parent                 = wrapper

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1, -26, 0, 4)
    track.Position         = UDim2.new(0, 13, 0, 34)
    track.BackgroundColor3 = Theme.Stroke
    track.BorderSizePixel  = 0
    track.Parent           = wrapper
    makeCorner(track, 2)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    makeCorner(fill, 2)

    local handle = Instance.new("TextButton")
    handle.Size             = UDim2.fromOffset(14, 14)
    handle.Position         = UDim2.new(0, -7, 0.5, -7)
    handle.BackgroundColor3 = Color3.fromRGB(220, 220, 225)
    handle.BorderSizePixel  = 0
    handle.Text             = ""
    handle.AutoButtonColor  = false
    handle.Parent           = wrapper
    makeCorner(handle, 7)

    local dragging = false

    local function refresh()
        local v = getValue()
        lbl.Text      = label
        valueLbl.Text = tostring(v)
        local alpha   = math.clamp((v - min) / (max - min), 0, 1)
        fill.Size     = UDim2.fromScale(alpha, 1)
        handle.Position = UDim2.new(0, 13 + alpha * (wrapper.AbsoluteSize.X - 26) - 7, 0.5, -7)
    end

    local function setFromX(x)
        local rel   = math.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local alpha = rel / track.AbsoluteSize.X
        local raw   = min + alpha * (max - min)
        local snapped
        if (max - min) <= 20 then
            snapped = math.floor(raw + 0.5)
        else
            snapped = math.floor((raw + 2.5) / 5) * 5
        end
        snapped = math.clamp(snapped, min, max)
        setValue(snapped)
        refresh()
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
            dragging = true
        end
    end)

    wrapper.MouseEnter:Connect(function()
        tween(wrapper, TWEEN_FAST, { BackgroundColor3 = Theme.ElementHover })
    end)
    wrapper.MouseLeave:Connect(function()
        tween(wrapper, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
    end)

    task.defer(refresh)
    table.insert(GUI._components, refresh)
    return wrapper, refresh
end

-- ------------------------------------------------------------
-- Component: Dropdown
-- ------------------------------------------------------------

function GUI.AddDropdown(page, label, options, getValue, setValue, order)
    local wrapper = Instance.new("Frame")
    wrapper.Size             = UDim2.new(1, 0, 0, 36)
    wrapper.BackgroundColor3 = Theme.Element
    wrapper.BorderSizePixel  = 0
    wrapper.AutomaticSize    = Enum.AutomaticSize.Y
    wrapper.LayoutOrder      = order or 0
    wrapper.ClipsDescendants = false
    wrapper.Parent           = page
    makeCorner(wrapper, 9)

    local header = Instance.new("TextButton")
    header.Size             = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Theme.Element
    header.BorderSizePixel  = 0
    header.Text             = ""
    header.AutoButtonColor  = false
    header.Parent           = wrapper
    makeCorner(header, 9)

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(0.5, 0, 1, 0)
    lbl.Position               = UDim2.new(0, 13, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = label
    lbl.TextColor3             = Theme.Text
    lbl.Font                   = Enum.Font.GothamMedium
    lbl.TextSize               = 13
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Parent                 = header

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size                   = UDim2.new(0.5, -40, 1, 0)
    valueLbl.Position               = UDim2.new(0.5, 0, 0, 0)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Font                   = Enum.Font.GothamSemibold
    valueLbl.TextSize               = 12
    valueLbl.TextColor3             = Theme.Accent
    valueLbl.TextXAlignment         = Enum.TextXAlignment.Right
    valueLbl.Text                   = tostring(getValue() or "None")
    valueLbl.Parent                 = header

    local arrow = Instance.new("TextLabel")
    arrow.Size                   = UDim2.fromOffset(20, 20)
    arrow.Position               = UDim2.new(1, -26, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Text                   = "\226\150\190"
    arrow.TextColor3             = Theme.TextDim
    arrow.Font                   = Enum.Font.GothamBold
    arrow.TextSize               = 12
    arrow.Parent                 = header

    local listFrame = Instance.new("Frame")
    listFrame.Size             = UDim2.new(1, 0, 0, 0)
    listFrame.Position         = UDim2.new(0, 0, 0, 38)
    listFrame.BackgroundColor3 = Theme.Card
    listFrame.BorderSizePixel  = 0
    listFrame.ClipsDescendants = true
    listFrame.Visible          = false
    listFrame.Parent           = wrapper
    makeCorner(listFrame, 9)
    makeStroke(listFrame, Theme.Stroke, 1, 0.2)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding   = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent    = listFrame

    makePadding(listFrame, 4, 4, 4, 4)

    local expanded  = false
    local animating = false

    local function rebuild()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, opt in ipairs(options()) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size             = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = Theme.Element
            optBtn.BorderSizePixel  = 0
            optBtn.Text             = ""
            optBtn.AutoButtonColor  = false
            optBtn.LayoutOrder      = i
            optBtn.Parent           = listFrame
            makeCorner(optBtn, 6)

            local optLbl = Instance.new("TextLabel")
            optLbl.Size                   = UDim2.new(1, -16, 1, 0)
            optLbl.Position               = UDim2.new(0, 10, 0, 0)
            optLbl.BackgroundTransparency = 1
            optLbl.Text                   = tostring(opt)
            optLbl.TextColor3             = (getValue() == opt) and Theme.Accent or Theme.TextDim
            optLbl.Font                   = Enum.Font.GothamMedium
            optLbl.TextSize               = 12
            optLbl.TextXAlignment         = Enum.TextXAlignment.Left
            optLbl.Parent                 = optBtn

            optBtn.MouseButton1Click:Connect(function()
                setValue(opt)
                valueLbl.Text = tostring(opt)
                rebuild()
                if expanded then
                    expanded = false
                    tween(listFrame, TWEEN_MED, { Size = UDim2.new(1, 0, 0, 0) })
                    tween(arrow, TWEEN_MED, { Rotation = 0 })
                    task.delay(0.22, function()
                        listFrame.Visible = false
                        animating = false
                    end)
                end
            end)

            optBtn.MouseEnter:Connect(function()
                tween(optBtn, TWEEN_FAST, { BackgroundColor3 = Theme.ElementHover })
            end)
            optBtn.MouseLeave:Connect(function()
                tween(optBtn, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
            end)
        end
    end

    header.MouseButton1Click:Connect(function()
        if animating then return end
        animating = true
        expanded  = not expanded

        if expanded then
            rebuild()
            listFrame.Visible = true
            local h = #options() * 30 + 8
            tween(listFrame, TWEEN_MED, { Size = UDim2.new(1, 0, 0, h) })
            tween(arrow, TWEEN_MED, { Rotation = 180 })
            task.delay(0.22, function() animating = false end)
        else
            tween(listFrame, TWEEN_MED, { Size = UDim2.new(1, 0, 0, 0) })
            tween(arrow, TWEEN_MED, { Rotation = 0 })
            task.delay(0.22, function()
                listFrame.Visible = false
                animating = false
            end)
        end
    end)

    header.MouseEnter:Connect(function()
        tween(header, TWEEN_FAST, { BackgroundColor3 = Theme.ElementHover })
    end)
    header.MouseLeave:Connect(function()
        tween(header, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
    end)

    table.insert(GUI._components, function()
        valueLbl.Text = tostring(getValue() or "None")
    end)

    return wrapper
end

-- ------------------------------------------------------------
-- Component: Keybind
-- ------------------------------------------------------------

function GUI.AddKeybind(page, label, getKey, setKey, order)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Theme.Element
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    btn.Parent           = page
    makeCorner(btn, 9)

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, -90, 1, 0)
    lbl.Position               = UDim2.new(0, 13, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = label
    lbl.TextColor3             = Theme.Text
    lbl.Font                   = Enum.Font.GothamMedium
    lbl.TextSize               = 13
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.Parent                 = btn

    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size             = UDim2.fromOffset(70, 22)
    keyLbl.Position         = UDim2.new(1, -80, 0.5, -11)
    keyLbl.BackgroundColor3 = Theme.Card
    keyLbl.BorderSizePixel  = 0
    keyLbl.Font             = Enum.Font.GothamBold
    keyLbl.TextSize         = 11
    keyLbl.TextColor3       = Theme.Accent
    keyLbl.Text             = tostring(getKey()):gsub("Enum.KeyCode.", "")
    keyLbl.Parent           = btn
    makeCorner(keyLbl, 6)

    local listening = false

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text = "..."
        tween(keyLbl, TWEEN_FAST, { TextColor3 = Theme.Green })

        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                setKey(input.KeyCode)
                keyLbl.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                tween(keyLbl, TWEEN_FAST, { TextColor3 = Theme.Accent })
                listening = false
                conn:Disconnect()
            end
        end)
    end)

    btn.MouseEnter:Connect(function()
        tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.ElementHover })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
    end)

    return btn
end

-- ------------------------------------------------------------
-- Component: Button
-- ------------------------------------------------------------

function GUI.AddButton(page, label, callback, order, isDanger)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = isDanger and Color3.fromRGB(120, 30, 30) or Theme.AccentDark
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    btn.Parent           = page
    makeCorner(btn, 9)

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = label
    lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 13
    lbl.Parent                 = btn

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    btn.MouseEnter:Connect(function()
        tween(btn, TWEEN_FAST, {
            BackgroundColor3 = isDanger and Color3.fromRGB(160, 40, 40) or Theme.Accent
        })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TWEEN_FAST, {
            BackgroundColor3 = isDanger and Color3.fromRGB(120, 30, 30) or Theme.AccentDark
        })
    end)

    return btn
end

-- ------------------------------------------------------------
-- Open / close
-- ------------------------------------------------------------

local function setOpen(state)
    IsOpen = state
    if Core then Core.MenuOpen = state end

    if state then
        MenuFrame.Visible = true
        Watermark.Visible = true
        MenuFrame.Size    = UDim2.fromOffset(560, 0)
        tween(MenuFrame, TWEEN_MED, { Size = UDim2.fromOffset(560, 380) })
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Tab, false, game)
        end)
    else
        tween(MenuFrame, TWEEN_MED, { Size = UDim2.fromOffset(560, 0) })
        task.delay(0.22, function()
            MenuFrame.Visible = false
            Watermark.Visible = false
        end)
        pcall(function()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Tab, false, game)
        end)
    end
end

function GUI.ToggleMenu()
    setOpen(not IsOpen)
end

function GUI.IsOpen()
    return IsOpen
end

-- ------------------------------------------------------------
-- Build
-- ------------------------------------------------------------

local function build()
    local playerGui = Utils.LocalPlayer:WaitForChild("PlayerGui")

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "RivalsModularGUI"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder   = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent         = playerGui

    Watermark = Instance.new("TextLabel")
    Watermark.AnchorPoint            = Vector2.new(0, 1)
    Watermark.Position               = UDim2.new(0, 10, 1, -10)
    Watermark.Size                   = UDim2.fromOffset(200, 28)
    Watermark.BackgroundTransparency = 1
    Watermark.Text                   = "rivals.dev"
    Watermark.TextColor3             = Color3.fromRGB(255, 255, 255)
    Watermark.Font                   = Enum.Font.GothamBold
    Watermark.TextSize               = 18
    Watermark.TextXAlignment         = Enum.TextXAlignment.Left
    Watermark.TextStrokeTransparency = 0.6
    Watermark.Visible                = false
    Watermark.Parent                 = ScreenGui

    MenuFrame = Instance.new("Frame")
    MenuFrame.Name             = "Menu"
    MenuFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
    MenuFrame.Position         = UDim2.fromScale(0.5, 0.5)
    MenuFrame.Size             = UDim2.fromOffset(560, 0)
    MenuFrame.BackgroundColor3 = Theme.Background
    MenuFrame.BorderSizePixel  = 0
    MenuFrame.Visible          = false
    MenuFrame.ClipsDescendants = true
    MenuFrame.Parent           = ScreenGui
    makeCorner(MenuFrame, 14)
    makeStroke(MenuFrame, Theme.Stroke, 1, 0.1)

    TitleBar = Instance.new("Frame")
    TitleBar.Name             = "TitleBar"
    TitleBar.Size             = UDim2.new(1, 0, 0, 38)
    TitleBar.BackgroundColor3 = Theme.Sidebar
    TitleBar.BorderSizePixel  = 0
    TitleBar.Parent           = MenuFrame
    makeCorner(TitleBar, 14)

    local titleFix = Instance.new("Frame")
    titleFix.Size             = UDim2.new(1, 0, 0, 14)
    titleFix.Position         = UDim2.new(0, 0, 1, -14)
    titleFix.BackgroundColor3 = Theme.Sidebar
    titleFix.BorderSizePixel  = 0
    titleFix.Parent           = TitleBar

    local titleAccent = Instance.new("Frame")
    titleAccent.Size             = UDim2.fromOffset(3, 14)
    titleAccent.Position         = UDim2.new(0, 0, 0.5, -7)
    titleAccent.BackgroundColor3 = Theme.Accent
    titleAccent.BorderSizePixel  = 0
    titleAccent.Parent           = TitleBar
    makeCorner(titleAccent, 2)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size                   = UDim2.new(1, -60, 1, 0)
    titleLbl.Position               = UDim2.new(0, 16, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                   = "RIVALS"
    titleLbl.TextColor3             = Theme.Text
    titleLbl.Font                   = Enum.Font.GothamBold
    titleLbl.TextSize               = 14
    titleLbl.TextXAlignment         = Enum.TextXAlignment.Left
    titleLbl.Parent                 = TitleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size             = UDim2.fromOffset(26, 26)
    closeBtn.Position         = UDim2.new(1, -32, 0.5, -13)
    closeBtn.BackgroundColor3 = Theme.Element
    closeBtn.BorderSizePixel  = 0
    closeBtn.Text             = ""
    closeBtn.AutoButtonColor  = false
    closeBtn.Parent           = TitleBar
    makeCorner(closeBtn, 7)

    local closeLbl = Instance.new("TextLabel")
    closeLbl.Size                   = UDim2.new(1, 0, 1, 0)
    closeLbl.BackgroundTransparency = 1
    closeLbl.Text                   = "X"
    closeLbl.TextColor3             = Theme.TextDim
    closeLbl.Font                   = Enum.Font.GothamBold
    closeLbl.TextSize               = 12
    closeLbl.Parent                 = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        setOpen(false)
    end)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, TWEEN_FAST, { BackgroundColor3 = Theme.Red })
        tween(closeLbl, TWEEN_FAST, { TextColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
        tween(closeLbl, TWEEN_FAST, { TextColor3 = Theme.TextDim })
    end)

    Sidebar = Instance.new("Frame")
    Sidebar.Name             = "Sidebar"
    Sidebar.Size             = UDim2.new(0, 140, 1, -38)
    Sidebar.Position         = UDim2.new(0, 0, 0, 38)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel  = 0
    Sidebar.Parent           = MenuFrame

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Padding             = UDim.new(0, 4)
    sidebarLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
    sidebarLayout.Parent              = Sidebar

    makePadding(Sidebar, 0, 10, 0, 10)

    ContentHost = Instance.new("Frame")
    ContentHost.Name             = "Content"
    ContentHost.Size             = UDim2.new(1, -140, 1, -38)
    ContentHost.Position         = UDim2.new(0, 140, 0, 38)
    ContentHost.BackgroundColor3 = Theme.Background
    ContentHost.BorderSizePixel  = 0
    ContentHost.Parent           = MenuFrame

    createTab("Legit",     1)
    createTab("Rage",      2)
    createTab("Visuals",   3)
    createTab("Player",    4)
    createTab("Teleport",  5)
    createTab("World",     6)
    createTab("Skins",     7)
    createTab("Misc",      8)
    createTab("Settings",  9)

    if Utils.IsMobile then
        MobileButton = Instance.new("TextButton")
        MobileButton.Name             = "MobileToggle"
        MobileButton.Size             = UDim2.fromOffset(44, 44)
        MobileButton.Position         = UDim2.new(1, -60, 1, -60)
        MobileButton.AnchorPoint      = Vector2.new(1, 1)
        MobileButton.BackgroundColor3 = Theme.Card
        MobileButton.BorderSizePixel  = 0
        MobileButton.Text             = "<>"
        MobileButton.TextColor3       = Theme.Text
        MobileButton.Font             = Enum.Font.GothamBold
        MobileButton.TextSize         = 14
        MobileButton.AutoButtonColor  = false
        MobileButton.Parent           = ScreenGui
        makeCorner(MobileButton, 12)
        makeStroke(MobileButton, Theme.Stroke, 1, 0.2)

        MobileButton.MouseButton1Click:Connect(function()
            GUI.ToggleMenu()
        end)
    end

    initDragging()
    switchTab("Legit")
end

-- ------------------------------------------------------------
-- Keybind handling
-- ------------------------------------------------------------

local function initKeybind()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Keybind then
            GUI.ToggleMenu()
        end
    end)
end

-- ------------------------------------------------------------
-- Lifecycle
-- ------------------------------------------------------------

function GUI.Init(deps)
    Config = deps.Config
    Utils  = deps.Utils
    Core   = deps.Core

    local savedKey = Config.Get("MenuKeybind")
    if savedKey then
        local ok, parsed = pcall(function()
            return Enum.KeyCode[savedKey]
        end)
        if ok and parsed then
            Keybind = parsed
        end
    end

    build()
    initKeybind()

    UserInputService.InputBegan:Connect(function(input)
        if not IsOpen then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local mfPos  = MenuFrame.AbsolutePosition
        local mfSize = MenuFrame.AbsoluteSize
        local x, y   = input.Position.X, input.Position.Y
        local inside = x >= mfPos.X and x <= mfPos.X + mfSize.X
            and y >= mfPos.Y and y <= mfPos.Y + mfSize.Y
        if not inside then
            setOpen(false)
        end
    end)

    local settings = Pages["Settings"]
    if settings then
        GUI.AddSection(settings, "Menu", 1)
        GUI.AddKeybind(settings, "Menu Keybind",
            function() return Keybind end,
            function(k)
                Keybind = k
                Config.Set("MenuKeybind", tostring(k):gsub("Enum.KeyCode.", ""))
            end, 2)
        GUI.AddSection(settings, "Config", 3)
        GUI.AddButton(settings, "Reset Config",
            function() Config.Reset() end, 4, false)
        GUI.AddButton(settings, "Unload Script",
            function()
                if Core and Core.Unload then Core.Unload() end
            end, 5, true)
    end

    print("[rivals] GUI initialized.")
end

function GUI.Cleanup()
    pcall(function()
        if ScreenGui then ScreenGui:Destroy() end
    end)
    Pages     = {}
    IsOpen    = false
    ActiveTab = nil
end

return GUI