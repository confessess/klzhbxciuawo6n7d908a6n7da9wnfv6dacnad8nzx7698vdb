-- ============================================================
-- Rivals Modular -- GUI
-- Top tabs, icons, preview windows
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
    Background   = Color3.fromRGB(16, 16, 22),
    Sidebar      = Color3.fromRGB(20, 20, 28),
    Card         = Color3.fromRGB(22, 22, 30),
    Element      = Color3.fromRGB(28, 28, 38),
    ElementHover = Color3.fromRGB(36, 36, 48),
    Stroke       = Color3.fromRGB(45, 45, 58),
    Text         = Color3.fromRGB(235, 235, 240),
    TextDim      = Color3.fromRGB(140, 140, 155),
    Accent       = Color3.fromRGB(88, 145, 255),
    AccentAlt    = Color3.fromRGB(130, 100, 255),
    Green        = Color3.fromRGB(0, 190, 85),
    Red          = Color3.fromRGB(235, 60, 60),
}

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED  = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ------------------------------------------------------------
-- State
-- ------------------------------------------------------------

local ScreenGui, PreviewGui
local MainFrame, TabBar, ContentHost, TitleBar
local SkinPreviewFrame, SkinPreviewViewport, SkinPreviewCamera, SkinPreviewWorldModel
local ESPPreviewFrame, ESPPreviewViewport, ESPPreviewCamera, ESPPreviewWorldModel
local Pages     = {}
local ActiveTab = nil
local IsOpen    = false
local Keybind   = Enum.KeyCode.RightControl
local Dragging  = false
local DragStart = nil
local StartPos  = nil
local IsLoading = true

GUI.Components  = {}
GUI.Pages       = Pages

-- Tab icons (asset IDs from LO)
local TAB_ICONS = {
    Combat   = "rbxassetid://93112623799121",
    Visuals  = "rbxassetid://77636811910093",
    Skins    = "rbxassetid://118949441189559",
    Misc     = "rbxassetid://95043878684254",
    Settings = "rbxassetid://124034566612418",
}

-- ------------------------------------------------------------
-- Helpers
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
-- Preview visibility (called on every tab switch + menu toggle)
-- ------------------------------------------------------------

function GUI.UpdatePreviewVisibility()
    if not SkinPreviewFrame or not ESPPreviewFrame then return end
    local open = IsOpen and not IsLoading
    SkinPreviewFrame.Visible = open and (ActiveTab == "Skins")
    ESPPreviewFrame.Visible  = open and (ActiveTab == "Visuals")
end

function GUI.GetActiveTab()
    return ActiveTab
end

function GUI.IsOpen()
    return IsOpen
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
            StartPos  = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(
                StartPos.X.Scale, StartPos.X.Offset + delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
            )
            GUI.UpdatePreviewPositions()
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
    if ActiveTab == name then
        GUI.UpdatePreviewVisibility()
        return
    end
    ActiveTab = name

    for tabName, page in pairs(Pages) do
        page.Visible = (tabName == name)
    end

    -- update tab button visuals
    for _, child in ipairs(TabBar:GetChildren()) do
        if child:IsA("TextButton") and child.Name:sub(1, 4) == "Tab_" then
            local icon = child:FindFirstChild("Icon")
            local glow = child:FindFirstChild("Glow")
            local selected = (child.Name == "Tab_" .. name)
            if icon then
                tween(icon, TWEEN_FAST, {
                    ImageColor3 = selected and Theme.Text or Theme.TextDim
                })
            end
            if glow then
                glow.Visible = selected
            end
            tween(child, TWEEN_FAST, {
                BackgroundColor3 = selected and Theme.Element or Theme.Sidebar
            })
        end
    end

    GUI.UpdatePreviewVisibility()
end

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Name             = "Tab_" .. name
    btn.Size             = UDim2.new(0, 95, 1, -8)
    btn.BackgroundColor3 = Theme.Sidebar
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.LayoutOrder      = order
    btn.Parent           = TabBar
    makeCorner(btn, 6)

    local icon = Instance.new("ImageLabel")
    icon.Name                   = "Icon"
    icon.Size                   = UDim2.fromOffset(32, 32)
    icon.Position               = UDim2.new(0.5, -16, 0.5, -16)
    icon.BackgroundTransparency = 1
    icon.Image                  = TAB_ICONS[name] or ""
    icon.ImageColor3            = Theme.TextDim
    icon.ScaleType              = Enum.ScaleType.Fit
    icon.Parent                 = btn

    -- paintbrush gets 1.5x
    if name == "Skins" then
        icon.Size     = UDim2.fromOffset(48, 48)
        icon.Position = UDim2.new(0.5, -24, 0.5, -24)
    end

    -- purple underglow
    local glow = Instance.new("Frame")
    glow.Name                   = "Glow"
    glow.Size                   = UDim2.new(1, 0, 0, 3)
    glow.Position               = UDim2.new(0, 0, 1, 0)
    glow.BackgroundColor3       = Theme.AccentAlt
    glow.BorderSizePixel        = 0
    glow.Visible                = false
    glow.Parent                 = btn
    makeCorner(glow, 2)

    btn.MouseButton1Click:Connect(function()
        if IsLoading then return end
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
    page.ClipsDescendants       = true
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
-- Components
-- ------------------------------------------------------------

function GUI.Components.Section(page, text, order)
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

function GUI.Components.Toggle(page, label, default, callback, order)
    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Theme.Element
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    btn.Parent           = page
    makeCorner(btn, 6)

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
        tween(track, TWEEN_FAST, {
            BackgroundColor3 = state and Theme.Green or Theme.Stroke
        })
        tween(knob, TWEEN_FAST, {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        })
    end

    btn.MouseButton1Click:Connect(function()
        if IsLoading then return end
        state = not state
        updateVisual()
        pcall(callback, state)
    end)

    btn.MouseEnter:Connect(function()
        tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.ElementHover })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TWEEN_FAST, { BackgroundColor3 = Theme.Element })
    end)

    updateVisual()
    return btn, function() return state end
end

function GUI.Components.Slider(page, label, min, max, default, callback, order)
    local value = default or min
    local wrapper = Instance.new("Frame")
    wrapper.Size             = UDim2.new(1, 0, 0, 52)
    wrapper.BackgroundColor3 = Theme.Element
    wrapper.BorderSizePixel  = 0
    wrapper.LayoutOrder      = order or 0
    wrapper.Parent           = page
    makeCorner(wrapper, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, -60, 0, 20)
    lbl.Position               = UDim2.new(0, 13, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Font                   = Enum.Font.GothamMedium
    lbl.TextSize               = 13
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.TextColor3             = Theme.Text
    lbl.Text                   = label
    lbl.Parent                 = wrapper

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size                   = UDim2.fromOffset(50, 20)
    valueLbl.Position               = UDim2.new(1, -58, 0, 7)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Font                   = Enum.Font.GothamBold
    valueLbl.TextSize               = 12
    valueLbl.TextColor3             = Theme.Accent
    valueLbl.TextXAlignment         = Enum.TextXAlignment.Right
    valueLbl.Text                   = tostring(value)
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
        lbl.Text      = label
        valueLbl.Text = tostring(value)
        local alpha   = math.clamp((value - min) / (max - min), 0, 1)
        fill.Size     = UDim2.fromScale(alpha, 1)
        handle.Position = UDim2.new(0, 13 + alpha * (wrapper.AbsoluteSize.X - 26) - 7, 0.5, -7)
    end

    local function setFromX(x)
        local rel   = math.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local alpha = rel / track.AbsoluteSize.X
        local raw   = min + alpha * (max - min)
        local snapped = math.floor(raw + 0.5)
        snapped = math.clamp(snapped, min, max)
        value = snapped
        pcall(callback, value)
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
    return wrapper, function() return value end
end

function GUI.Components.Dropdown(page, label, options, default, callback, order)
    -- options can be a table OR a function returning a table
    local currentValue = default
    local expanded = false
    local animating = false

    local wrapper = Instance.new("Frame")
    wrapper.Size             = UDim2.new(1, 0, 0, 36)
    wrapper.BackgroundColor3 = Theme.Element
    wrapper.BorderSizePixel  = 0
    wrapper.LayoutOrder      = order or 0
    wrapper.ClipsDescendants = false
    wrapper.Parent           = page
    makeCorner(wrapper, 6)

    local header = Instance.new("TextButton")
    header.Size             = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = Theme.Element
    header.BorderSizePixel  = 0
    header.Text             = ""
    header.AutoButtonColor  = false
    header.Parent           = wrapper
    makeCorner(header, 6)

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
    valueLbl.Text                   = tostring(currentValue or "None")
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

    -- scrolling dropdown list (self-contained, doesn't expand page)
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size             = UDim2.new(1, 0, 0, 0)
    listFrame.Position         = UDim2.new(0, 0, 0, 38)
    listFrame.BackgroundColor3 = Theme.Card
    listFrame.BorderSizePixel  = 0
    listFrame.ClipsDescendants = true
    listFrame.Visible          = false
    listFrame.ScrollBarThickness = 3
    listFrame.ScrollBarImageColor3 = Theme.Stroke
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.CanvasSize       = UDim2.fromScale(0, 0)
    listFrame.ZIndex           = 50
    listFrame.Parent           = wrapper
    makeCorner(listFrame, 6)
    makeStroke(listFrame, Theme.Stroke, 1, 0.2)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding   = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent    = listFrame

    makePadding(listFrame, 4, 4, 4, 4)

    local MAX_LIST_HEIGHT = 150

    local function getOptions()
        if type(options) == "function" then
            return options()
        end
        return options or {}
    end

    local function rebuild()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local opts = getOptions()
        for i, opt in ipairs(opts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size             = UDim2.new(1, 0, 0, 28)
            optBtn.BackgroundColor3 = Theme.Element
            optBtn.BorderSizePixel  = 0
            optBtn.Text             = ""
            optBtn.AutoButtonColor  = false
            optBtn.LayoutOrder      = i
            optBtn.ZIndex           = 51
            optBtn.Parent           = listFrame
            makeCorner(optBtn, 4)

            local optLbl = Instance.new("TextLabel")
            optLbl.Size                   = UDim2.new(1, -16, 1, 0)
            optLbl.Position               = UDim2.new(0, 10, 0, 0)
            optLbl.BackgroundTransparency = 1
            optLbl.Text                   = tostring(opt)
            optLbl.TextColor3             = (currentValue == opt) and Theme.Accent or Theme.TextDim
            optLbl.Font                   = Enum.Font.GothamMedium
            optLbl.TextSize               = 12
            optLbl.TextXAlignment         = Enum.TextXAlignment.Left
            optLbl.ZIndex                 = 52
            optLbl.Parent                 = optBtn

            optBtn.MouseButton1Click:Connect(function()
                currentValue = opt
                valueLbl.Text = tostring(opt)
                pcall(callback, opt)
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
        if IsLoading or animating then return end
        animating = true
        expanded  = not expanded

        if expanded then
            rebuild()
            listFrame.Visible = true
            local opts = getOptions()
            local h = math.min(#opts * 30 + 8, MAX_LIST_HEIGHT)
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

    -- return object with SetValues for dynamic updates
    local obj = {}
    obj.SetValues = function(_, newOpts)
        options = newOpts
        if expanded then rebuild() end
    end
    obj.SetValue = function(_, v)
        currentValue = v
        valueLbl.Text = tostring(v)
    end
    obj.GetValue = function() return currentValue end

    return wrapper, obj
end

function GUI.Components.Button(page, label, callback, order, isDanger)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = isDanger and Color3.fromRGB(120, 30, 30) or Theme.Accent
    btn.BackgroundTransparency = isDanger and 0 or 0.2
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    btn.Parent           = page
    makeCorner(btn, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = label
    lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 13
    lbl.Parent                 = btn

    btn.MouseButton1Click:Connect(function()
        if IsLoading then return end
        pcall(callback)
    end)

    btn.MouseEnter:Connect(function()
        tween(btn, TWEEN_FAST, {
            BackgroundColor3 = isDanger and Color3.fromRGB(160, 40, 40) or Theme.AccentAlt,
            BackgroundTransparency = 0
        })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TWEEN_FAST, {
            BackgroundColor3 = isDanger and Color3.fromRGB(120, 30, 30) or Theme.Accent,
            BackgroundTransparency = isDanger and 0 or 0.2
        })
    end)

    return btn
end

function GUI.Components.Keybind(page, label, default, callback, order)
    local current = default or Enum.KeyCode.RightControl
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Theme.Element
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    btn.Parent           = page
    makeCorner(btn, 6)

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
    keyLbl.Text             = tostring(current):gsub("Enum.KeyCode.", "")
    keyLbl.Parent           = btn
    makeCorner(keyLbl, 4)

    local listening = false

    btn.MouseButton1Click:Connect(function()
        if IsLoading or listening then return end
        listening = true
        keyLbl.Text = "..."
        tween(keyLbl, TWEEN_FAST, { TextColor3 = Theme.Green })

        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode
                keyLbl.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                tween(keyLbl, TWEEN_FAST, { TextColor3 = Theme.Accent })
                listening = false
                pcall(callback, input.KeyCode)
                conn:Disconnect()
            end
        end)
    end)

    return btn
end

-- ------------------------------------------------------------
-- Open / close
-- ------------------------------------------------------------

function GUI.ToggleMenu()
    if IsLoading then
        print("[GUI] Still loading, blocked toggle")
        return
    end
    IsOpen = not IsOpen
    if Core then Core.MenuOpen = IsOpen end

    if MainFrame then
        MainFrame.Visible = IsOpen
    end
    GUI.UpdatePreviewVisibility()
end

local function setOpen(state)
    IsOpen = state
    if Core then Core.MenuOpen = state end
    if MainFrame then
        MainFrame.Visible = state
    end
    GUI.UpdatePreviewVisibility()
end

-- ------------------------------------------------------------
-- Preview windows (separate ScreenGui, positioned beside main)
-- ------------------------------------------------------------

local function createPreviewWindows()
    local playerGui = Utils.LocalPlayer:WaitForChild("PlayerGui")

    PreviewGui = Instance.new("ScreenGui")
    PreviewGui.Name           = "RivalsPreviewGUI"
    PreviewGui.ResetOnSpawn   = false
    PreviewGui.IgnoreGuiInset = true
    PreviewGui.DisplayOrder   = 998
    PreviewGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    PreviewGui.Parent         = playerGui

    -- ===== SKIN PREVIEW (right side) =====
    SkinPreviewFrame = Instance.new("Frame")
    SkinPreviewFrame.Name             = "SkinPreview"
    SkinPreviewFrame.Size             = UDim2.fromOffset(200, 280)
    SkinPreviewFrame.BackgroundColor3 = Theme.Card
    SkinPreviewFrame.BorderSizePixel  = 0
    SkinPreviewFrame.Visible          = false
    SkinPreviewFrame.Parent           = PreviewGui
    makeCorner(SkinPreviewFrame, 8)
    makeStroke(SkinPreviewFrame, Theme.Stroke, 1, 0.2)

    local skinTitle = Instance.new("TextLabel")
    skinTitle.Size                   = UDim2.new(1, 0, 0, 28)
    skinTitle.BackgroundColor3       = Theme.Sidebar
    skinTitle.BorderSizePixel        = 0
    skinTitle.Text                   = "SKIN PREVIEW"
    skinTitle.TextColor3             = Theme.Text
    skinTitle.Font                   = Enum.Font.GothamBold
    skinTitle.TextSize               = 11
    skinTitle.Parent                 = SkinPreviewFrame
    makeCorner(skinTitle, 8)

    local skinTitleFix = Instance.new("Frame")
    skinTitleFix.Size             = UDim2.new(1, 0, 0, 14)
    skinTitleFix.Position         = UDim2.new(0, 0, 1, -14)
    skinTitleFix.BackgroundColor3 = Theme.Sidebar
    skinTitleFix.BorderSizePixel  = 0
    skinTitleFix.Parent           = skinTitle

    SkinPreviewViewport = Instance.new("ViewportFrame")
    SkinPreviewViewport.Size                   = UDim2.new(1, -16, 1, -60)
    SkinPreviewViewport.Position               = UDim2.new(0, 8, 0, 32)
    SkinPreviewViewport.BackgroundColor3       = Color3.fromRGB(10, 10, 14)
    SkinPreviewViewport.BackgroundTransparency = 0
    SkinPreviewViewport.BorderSizePixel        = 0
    SkinPreviewViewport.Ambient                = Color3.fromRGB(120, 120, 130)
    SkinPreviewViewport.LightColor             = Color3.fromRGB(200, 200, 210)
    SkinPreviewViewport.LightDirection         = Vector3.new(1, 1, -1)
    SkinPreviewViewport.Parent                 = SkinPreviewFrame
    makeCorner(SkinPreviewViewport, 6)

    SkinPreviewWorldModel = Instance.new("WorldModel")
    SkinPreviewWorldModel.Parent = SkinPreviewViewport

    SkinPreviewCamera = Instance.new("Camera")
    SkinPreviewCamera.Parent = SkinPreviewViewport
    SkinPreviewViewport.CurrentCamera = SkinPreviewCamera

    local skinDisclaimer = Instance.new("TextLabel")
    skinDisclaimer.Size                   = UDim2.new(1, -16, 0, 16)
    skinDisclaimer.Position               = UDim2.new(0, 8, 1, -22)
    skinDisclaimer.BackgroundTransparency = 1
    skinDisclaimer.Text                   = "Skins apply after death"
    skinDisclaimer.TextColor3             = Color3.fromRGB(255, 170, 60)
    skinDisclaimer.Font                   = Enum.Font.GothamMedium
    skinDisclaimer.TextSize               = 10
    skinDisclaimer.Parent                 = SkinPreviewFrame

    -- ===== ESP PREVIEW (left side, full height) =====
    ESPPreviewFrame = Instance.new("Frame")
    ESPPreviewFrame.Name             = "ESPPreview"
    ESPPreviewFrame.Size             = UDim2.fromOffset(220, 520)
    ESPPreviewFrame.BackgroundColor3 = Theme.Card
    ESPPreviewFrame.BorderSizePixel  = 0
    ESPPreviewFrame.Visible          = false
    ESPPreviewFrame.Parent           = PreviewGui
    makeCorner(ESPPreviewFrame, 8)
    makeStroke(ESPPreviewFrame, Theme.Stroke, 1, 0.2)

    local espTitle = Instance.new("TextLabel")
    espTitle.Size                   = UDim2.new(1, 0, 0, 28)
    espTitle.BackgroundColor3       = Theme.Sidebar
    espTitle.BorderSizePixel        = 0
    espTitle.Text                   = "ESP PREVIEW"
    espTitle.TextColor3             = Theme.Text
    espTitle.Font                   = Enum.Font.GothamBold
    espTitle.TextSize               = 11
    espTitle.Parent                 = ESPPreviewFrame
    makeCorner(espTitle, 8)

    local espTitleFix = Instance.new("Frame")
    espTitleFix.Size             = UDim2.new(1, 0, 0, 14)
    espTitleFix.Position         = UDim2.new(0, 0, 1, -14)
    espTitleFix.BackgroundColor3 = Theme.Sidebar
    espTitleFix.BorderSizePixel  = 0
    espTitleFix.Parent           = espTitle

    ESPPreviewViewport = Instance.new("ViewportFrame")
    ESPPreviewViewport.Size                   = UDim2.new(1, -16, 1, -44)
    ESPPreviewViewport.Position               = UDim2.new(0, 8, 0, 32)
    ESPPreviewViewport.BackgroundColor3       = Color3.fromRGB(10, 10, 14)
    ESPPreviewViewport.BackgroundTransparency = 0
    ESPPreviewViewport.BorderSizePixel        = 0
    ESPPreviewViewport.Ambient                = Color3.fromRGB(120, 120, 130)
    ESPPreviewViewport.LightColor             = Color3.fromRGB(200, 200, 210)
    ESPPreviewViewport.LightDirection         = Vector3.new(1, 1, -1)
    ESPPreviewViewport.Parent                 = ESPPreviewFrame
    makeCorner(ESPPreviewViewport, 6)

    ESPPreviewWorldModel = Instance.new("WorldModel")
    ESPPreviewWorldModel.Parent = ESPPreviewViewport

    ESPPreviewCamera = Instance.new("Camera")
    ESPPreviewCamera.Parent = ESPPreviewViewport
    ESPPreviewViewport.CurrentCamera = ESPPreviewCamera

    -- expose
    GUI.SkinPreviewFrame    = SkinPreviewFrame
    GUI.SkinPreviewViewport = SkinPreviewViewport
    GUI.SkinPreviewCamera   = SkinPreviewCamera
    GUI.SkinPreviewWorldModel = SkinPreviewWorldModel
    GUI.ESPPreviewFrame     = ESPPreviewFrame
    GUI.ESPPreviewViewport  = ESPPreviewViewport
    GUI.ESPPreviewCamera    = ESPPreviewCamera
    GUI.ESPPreviewWorldModel = ESPPreviewWorldModel
end

function GUI.UpdatePreviewPositions()
    if not MainFrame or not SkinPreviewFrame or not ESPPreviewFrame then return end
    if not PreviewGui then return end

    local mainPos  = MainFrame.AbsolutePosition
    local mainSize = MainFrame.AbsoluteSize

    -- skin preview: right side, aligned to top
    SkinPreviewFrame.Position = UDim2.fromOffset(
        mainPos.X + mainSize.X + 5,
        mainPos.Y
    )

    -- esp preview: left side, full height aligned
    ESPPreviewFrame.Position = UDim2.fromOffset(
        mainPos.X - 225,
        mainPos.Y
    )
    ESPPreviewFrame.Size = UDim2.fromOffset(220, mainSize.Y)
end

-- ------------------------------------------------------------
-- Build main GUI
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

    MainFrame = Instance.new("Frame")
    MainFrame.Name             = "Main"
    MainFrame.Position         = UDim2.new(0.5, -390, 0.5, -260)
    MainFrame.Size             = UDim2.fromOffset(780, 520)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel  = 0
    MainFrame.Visible          = false
    MainFrame.ClipsDescendants = true
    MainFrame.Parent           = ScreenGui
    makeCorner(MainFrame, 10)
    makeStroke(MainFrame, Theme.Stroke, 1, 0.1)

    TitleBar = Instance.new("Frame")
    TitleBar.Name             = "TitleBar"
    TitleBar.Size             = UDim2.new(1, 0, 0, 38)
    TitleBar.BackgroundColor3 = Theme.Sidebar
    TitleBar.BorderSizePixel  = 0
    TitleBar.Parent           = MainFrame
    makeCorner(TitleBar, 10)

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
    makeCorner(closeBtn, 6)

    local closeLbl = Instance.new("TextLabel")
    closeLbl.Size                   = UDim2.new(1, 0, 1, 0)
    closeLbl.BackgroundTransparency = 1
    closeLbl.Text                   = "X"
    closeLbl.TextColor3             = Theme.TextDim
    closeLbl.Font                   = Enum.Font.GothamBold
    closeLbl.TextSize               = 12
    closeLbl.Parent                 = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        if IsLoading then return end
        setOpen(false)
    end)

    -- Tab bar (top tabs)
    TabBar = Instance.new("Frame")
    TabBar.Name             = "TabBar"
    TabBar.Size             = UDim2.new(1, 0, 0, 52)
    TabBar.Position         = UDim2.new(0, 0, 0, 38)
    TabBar.BackgroundColor3 = Theme.Sidebar
    TabBar.BorderSizePixel  = 0
    TabBar.Parent           = MainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding       = UDim.new(0, 4)
    tabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    tabLayout.Parent        = TabBar

    -- Content area
    ContentHost = Instance.new("Frame")
    ContentHost.Name             = "Content"
    ContentHost.Size             = UDim2.new(1, 0, 1, -90)
    ContentHost.Position         = UDim2.new(0, 0, 0, 90)
    ContentHost.BackgroundColor3 = Theme.Background
    ContentHost.BorderSizePixel  = 0
    ContentHost.ClipsDescendants = true
    ContentHost.Parent           = MainFrame

    -- Create tabs
    createTab("Combat",   1)
    createTab("Visuals",  2)
    createTab("Skins",    3)
    createTab("Misc",     4)
    createTab("Settings", 5)

    -- Create preview windows
    createPreviewWindows()

    initDragging()
    switchTab("Combat")
end

-- ------------------------------------------------------------
-- Keybind
-- ------------------------------------------------------------

local function initKeybind()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if IsLoading then return end
        if input.KeyCode == Keybind then
            GUI.ToggleMenu()
        end
    end)
end

-- ------------------------------------------------------------
-- Skin preview model management
-- ------------------------------------------------------------

local previewRotation = 0
local previewConnection = nil

function GUI.SetSkinPreviewModel(model)
    if not SkinPreviewWorldModel then return end
    -- clear old
    for _, child in ipairs(SkinPreviewWorldModel:GetChildren()) do
        child:Destroy()
    end
    if not model then return end

    local clone = model:Clone()
    clone.Parent = SkinPreviewWorldModel

    -- frame model
    local cf, size = clone:GetBoundingBox()
    local maxDim = math.max(size.X, size.Y, size.Z)
    local distance = maxDim * 0.7

    SkinPreviewCamera.CFrame = CFrame.new(
        cf.Position + Vector3.new(distance, distance * 0.3, distance),
        cf.Position
    )
end

function GUI.SetESPPreviewModel(model)
    if not ESPPreviewWorldModel then return end
    for _, child in ipairs(ESPPreviewWorldModel:GetChildren()) do
        child:Destroy()
    end
    if not model then return end

    local clone = model:Clone()
    clone.Parent = ESPPreviewWorldModel

    local cf, size = clone:GetBoundingBox()
    local maxDim = math.max(size.X, size.Y, size.Z)
    local distance = maxDim * 1.2

    ESPPreviewCamera.CFrame = CFrame.new(
        cf.Position + Vector3.new(distance, distance * 0.2, distance),
        cf.Position
    )
end

-- rotation loop (throttled)
local function startPreviewRotation()
    if previewConnection then previewConnection:Disconnect() end
    local lastTick = tick()
    previewConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local now = tick()
        if now - lastTick < 0.033 then return end -- ~30fps
        lastTick = now

        if SkinPreviewFrame and SkinPreviewFrame.Visible and SkinPreviewWorldModel then
            local model = SkinPreviewWorldModel:FindFirstChildWhichIsA("Model")
            if model then
                previewRotation = previewRotation + 0.5
                local cf, size = model:GetBoundingBox()
                local maxDim = math.max(size.X, size.Y, size.Z)
                local distance = maxDim * 0.7
                local angle = math.rad(previewRotation)
                SkinPreviewCamera.CFrame = CFrame.new(
                    cf.Position + Vector3.new(
                        math.sin(angle) * distance,
                        distance * 0.3,
                        math.cos(angle) * distance
                    ),
                    cf.Position
                )
            end
        end
    end)
end

-- ------------------------------------------------------------
-- Init
-- ------------------------------------------------------------

function GUI.Init(deps)
    Config = deps.Config
    Utils  = deps.Utils
    Core   = deps.Core

    local savedKey = Config and Config.Get and Config.Get("MenuKeybind")
    if savedKey then
        local ok, parsed = pcall(function()
            return Enum.KeyCode[savedKey]
        end)
        if ok and parsed then
            Keybind = parsed
        end
    end

    local ok, err = pcall(function()
        build()
    end)
    if not ok then
        warn("[GUI] Build error: " .. tostring(err))
    end

    initKeybind()
    startPreviewRotation()

    -- position previews after a frame
    task.defer(function()
        GUI.UpdatePreviewPositions()
    end)

    -- Settings tab
    local settings = Pages["Settings"]
    if settings then
        GUI.Components.Section(settings, "Menu", 1)
        GUI.Components.Keybind(settings, "Menu Keybind", Keybind, function(k)
            Keybind = k
            if Config and Config.Set then
                Config.Set("MenuKeybind", tostring(k):gsub("Enum.KeyCode.", ""))
            end
        end, 2)
        GUI.Components.Section(settings, "Config", 3)
        GUI.Components.Button(settings, "Reset Config", function()
            if Config and Config.Reset then Config.Reset() end
        end, 4, false)
        GUI.Components.Button(settings, "Unload Script", function()
            if Core and Core.Unload then Core.Unload() end
        end, 5, true)
    end

    -- loading done
    IsLoading = false
    print("[rivals] GUI ready. RightCtrl opens menu.")
end

function GUI.Cleanup()
    if previewConnection then
        previewConnection:Disconnect()
        previewConnection = nil
    end
    pcall(function()
        if ScreenGui then ScreenGui:Destroy() end
    end)
    pcall(function()
        if PreviewGui then PreviewGui:Destroy() end
    end)
    Pages     = {}
    IsOpen    = false
    ActiveTab = nil
end

return GUI