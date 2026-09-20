-- ============================================================
-- RIVALS GUI - Product Faker Style with Icons (FIXED DROPDOWNS)
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local GUI = {}

local Theme = {
    Background = Color3.fromRGB(26, 27, 36),
    Darker = Color3.fromRGB(20, 20, 28),
    Element = Color3.fromRGB(90, 99, 109),
    ElementHover = Color3.fromRGB(104, 123, 165),
    Stroke = Color3.fromRGB(154, 154, 154),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    Accent = Color3.fromRGB(130, 100, 255),
    Blue = Color3.fromRGB(80, 140, 255),
    HeaderBlue = Color3.fromRGB(100, 180, 255),
    Yellow = Color3.fromRGB(255, 201, 37),
    Red = Color3.fromRGB(255, 53, 53),
}

local Icons = {
    Combat = "rbxassetid://93112623799121",
    Visuals = "rbxassetid://77636811910093",
    Skins = "rbxassetid://118949441189559",
    Misc = "rbxassetid://95043878684254",
    Settings = "rbxassetid://124034566612418",
}

local ScreenGui, MainFrame, TabBar, ContentHost
local Pages = {}
local ActiveTab = nil
local IsOpen = false
local IsLoading = true
local MenuKeybind = Enum.KeyCode.RightControl

-- Track all dropdowns for global close
local AllDropdowns = {}

local function tween(obj, props)
    TweenService:Create(obj, TweenInfo.new(0.15), props):Play()
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
end

local function stroke(parent, color, t)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = t or 1
    s.Parent = parent
end

local function gradient(parent)
    local g = Instance.new("UIGradient")
    g.Rotation = -90
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(163, 163, 163)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    g.Parent = parent
    return g
end

-- Components
local Components = {}

function Components.Section(page, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Theme.HeaderBlue
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or 0
    lbl.Parent = page
end

function Components.MasterSection(page, text, order, defaultOpen)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 28)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.LayoutOrder = order or 0
    sectionFrame.ClipsDescendants = false
    sectionFrame.Parent = page

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = Theme.Element
    header.BorderSizePixel = 0
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = sectionFrame
    corner(header, 6)
    stroke(header)
    gradient(header)

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Size = UDim2.new(1, -40, 1, 0)
    headerLbl.Position = UDim2.new(0, 12, 0, 0)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Text = string.upper(text)
    headerLbl.TextColor3 = Theme.Text
    headerLbl.Font = Enum.Font.GothamBold
    headerLbl.TextSize = 12
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Parent = header

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(20, 20)
    arrow.Position = UDim2.new(1, -28, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▶"
    arrow.TextColor3 = Theme.Text
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = header

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Visible = false
    content.Parent = sectionFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    local isOpen = false
    local contentHeight = 0

    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentHeight = contentLayout.AbsoluteContentSize.Y
        if isOpen then
            content.Size = UDim2.new(1, 0, 0, contentHeight)
            sectionFrame.Size = UDim2.new(1, 0, 0, 28 + contentHeight + 4)
        end
    end)

    local function setOpen(open)
        isOpen = (open == true)

        if isOpen then
            arrow.Text = "▼"
            content.Visible = true
            content.Size = UDim2.new(1, 0, 0, contentHeight)
            sectionFrame.Size = UDim2.new(1, 0, 0, 28 + contentHeight + 4)
        else
            arrow.Text = "▶"
            content.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.Size = UDim2.new(1, 0, 0, 28)
            for _, dd in ipairs(AllDropdowns) do
                if dd.Close then dd.Close() end
            end
            task.delay(0.1, function()
                if not isOpen then content.Visible = false end
            end)
        end
    end

    header.MouseButton1Click:Connect(function()
        setOpen(not isOpen)
    end)

    return content, setOpen
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
    bg.BackgroundColor3 = default and Theme.ElementHover or Theme.Element
    bg.BorderSizePixel = 0
    bg.Parent = frame
    corner(bg, 10)
    stroke(bg)

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
        local ok, err = pcall(function()
            state = not state
            if state then
                tween(bg, {BackgroundColor3 = Theme.ElementHover})
                tween(knob, {Position = UDim2.new(1, -17, 0.5, -7)})
            else
                tween(bg, {BackgroundColor3 = Theme.Element})
                tween(knob, {Position = UDim2.new(0, 3, 0.5, -7)})
            end
            if callback then callback(state) end
        end)
        if not ok then warn("[GUI] Toggle error: " .. tostring(err)) end
    end)

    return {Set = function(v) state = v end, Get = function() return state end}
end

function Components.Dropdown(page, label, options, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
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
    box.ZIndex = 10
    box.Parent = frame
    corner(box, 6)
    stroke(box)
    gradient(box)

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(1, -30, 1, 0)
    valueLbl.Position = UDim2.new(0, 10, 0, 0)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(default or "Select...")
    valueLbl.TextColor3 = Theme.TextDim
    valueLbl.Font = Enum.Font.GothamMedium
    valueLbl.TextSize = 12
    valueLbl.TextXAlignment = Enum.TextXAlignment.Left
    valueLbl.ZIndex = 11
    valueLbl.Parent = box

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(16, 16)
    arrow.Position = UDim2.new(1, -22, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Theme.TextDim
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 8
    arrow.ZIndex = 11
    arrow.Parent = box

    -- Create popup list - parented to frame for simple positioning
    local popup = Instance.new("ScrollingFrame")
    popup.Name = "DDPopup_" .. tostring(order or math.random(10000, 99999))
    popup.BackgroundColor3 = Theme.Background
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.ZIndex = 100
    popup.ScrollBarThickness = 6
    popup.ScrollBarImageColor3 = Theme.TextDim
    popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
    popup.CanvasSize = UDim2.fromScale(0, 0)
    popup.ScrollingDirection = Enum.ScrollingDirection.Y
    popup.ElasticBehavior = Enum.ElasticBehavior.Never
    popup.Parent = frame
    corner(popup, 6)
    stroke(popup)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = popup

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 4)
    listPad.PaddingLeft = UDim.new(0, 4)
    listPad.PaddingRight = UDim.new(0, 4)
    listPad.Parent = popup

    local expanded = false
    local currentValue = default
    local optionButtons = {}
    local closeConnection = nil

    local function getOptions()
        if type(options) == "function" then
            local ok, result = pcall(options)
            if ok and type(result) == "table" then return result end
            return {"Error"}
        end
        return options or {}
    end

    local function clearOptions()
        for _, btn in ipairs(optionButtons) do
            if btn and btn.Parent then btn:Destroy() end
        end
        table.clear(optionButtons)
    end

    local function rebuild()
        clearOptions()
        local opts = getOptions()
        for i, opt in ipairs(opts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 26)
            optBtn.BackgroundColor3 = Theme.Element
            optBtn.BorderSizePixel = 0
            optBtn.Text = ""
            optBtn.AutoButtonColor = false
            optBtn.LayoutOrder = i
            optBtn.ZIndex = 101
            optBtn.Parent = popup
            corner(optBtn, 4)

            local optLbl = Instance.new("TextLabel")
            optLbl.Size = UDim2.new(1, -16, 1, 0)
            optLbl.Position = UDim2.new(0, 8, 0, 0)
            optLbl.BackgroundTransparency = 1
            optLbl.Text = tostring(opt)
            optLbl.TextColor3 = (currentValue == opt) and Theme.Yellow or Theme.TextDim
            optLbl.Font = Enum.Font.GothamMedium
            optLbl.TextSize = 12
            optLbl.TextXAlignment = Enum.TextXAlignment.Left
            optLbl.ZIndex = 102
            optLbl.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                local ok, err = pcall(function()
                    currentValue = opt
                    valueLbl.Text = tostring(opt)
                    if callback then callback(opt) end
                end)
                if not ok then warn("[GUI] Dropdown error: " .. tostring(err)) end
                close()
            end)
            table.insert(optionButtons, optBtn)
        end
        return #opts
    end

    local function close()
        expanded = false
        popup.Visible = false
        popup.Size = UDim2.new(0.55, 0, 0, 0)
        if closeConnection then
            closeConnection:Disconnect()
            closeConnection = nil
        end
    end

    local function open()
        for _, dd in ipairs(AllDropdowns) do
            if dd ~= control and dd.Close then dd.Close() end
        end
        local optCount = rebuild()

        -- Position popup at the bottom of the frame using offset
        -- Frame is 32px tall, box is at Y=2 with height 28
        -- So popup should start at Y=34 (2 + 28 + 4 gap)
        popup.Position = UDim2.new(0.45, 0, 0, 34)
        popup.Size = UDim2.new(0.55, 0, 0, 0)
        popup.Visible = true

        local listHeight = math.min(optCount * 30 + 10, 280)
        popup.Size = UDim2.new(0.55, 0, 0, listHeight)
        expanded = true

        closeConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                local popupPos = popup.AbsolutePosition
                local popupSize = popup.AbsoluteSize
                local boxPos = box.AbsolutePosition
                local boxSize = box.AbsoluteSize
                local inPopup = mousePos.X >= popupPos.X and mousePos.X <= popupPos.X + popupSize.X 
                    and mousePos.Y >= popupPos.Y and mousePos.Y <= popupPos.Y + popupSize.Y
                local inBox = mousePos.X >= boxPos.X and mousePos.X <= boxPos.X + boxSize.X 
                    and mousePos.Y >= boxPos.Y and mousePos.Y <= boxPos.Y + boxSize.Y
                if not inPopup and not inBox then close() end
            end
        end)
    end

    box.MouseButton1Click:Connect(function()
        if expanded then close() else open() end
    end)

    local control = {
        Set = function(v) currentValue = v valueLbl.Text = tostring(v) end,
        Get = function() return currentValue end,
        Close = close,
        IsOpen = function() return expanded end
    }
    table.insert(AllDropdowns, control)
    return control
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
    fill.BackgroundColor3 = Theme.ElementHover
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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
    corner(btn, 6)
    stroke(btn)
    gradient(btn)

    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    return btn
end

function Components.Keybind(page, label, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order or 0
    frame.Parent = page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.fromOffset(70, 24)
    keyBtn.Position = UDim2.new(1, -70, 0.5, -12)
    keyBtn.BackgroundColor3 = Theme.Element
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = default and tostring(default):gsub("Enum.KeyCode.", "") or "..."
    keyBtn.TextColor3 = Theme.Yellow
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11
    keyBtn.AutoButtonColor = false
    keyBtn.Parent = frame
    corner(keyBtn, 6)
    stroke(keyBtn)

    local listening = false
    local current = default

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                current = input.KeyCode
                keyBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                listening = false
                if callback then pcall(callback, input.KeyCode) end
                conn:Disconnect()
            end
        end)
    end)

    return {Set = function(k) current = k keyBtn.Text = tostring(k):gsub("Enum.KeyCode.", "") end, Get = function() return current end}
end

function Components.TextBox(page, label, placeholder, default, callback, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order or 0
    frame.Parent = page

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.35, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.6, 0, 0, 28)
    box.Position = UDim2.new(0.4, 0, 0.5, -14)
    box.BackgroundColor3 = Theme.Element
    box.BorderSizePixel = 0
    box.Text = default or ""
    box.PlaceholderText = placeholder or "Enter..."
    box.TextColor3 = Theme.Yellow
    box.PlaceholderColor3 = Theme.TextDim
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 12
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false
    box.LayoutOrder = order or 0
    box.Parent = frame
    corner(box, 6)
    stroke(box)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = box

    box.FocusLost:Connect(function(enterPressed)
        if callback then pcall(callback, box.Text) end
    end)

    return {Set = function(v) box.Text = tostring(v) end, Get = function() return box.Text end}
end

function Components.Label(page, text, order, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Theme.TextDim
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.LayoutOrder = order or 0
    lbl.Parent = page
    return lbl
end

function Components.CollapsibleSection(page, text, order, defaultOpen)
    return Components.MasterSection(page, text, order, defaultOpen)
end

GUI.Components = Components

-- Tab system
local function switchTab(name)
    if IsLoading then return end
    if ActiveTab == name then return end
    ActiveTab = name
    for tabName, page in pairs(Pages) do
        page.Visible = (tabName == name)
    end
    for _, child in ipairs(TabBar:GetChildren()) do
        if child:IsA("TextButton") then
            local isActive = (child.Name == "Tab_" .. name)
            local icon = child:FindFirstChild("Icon")
            if icon then tween(icon, {ImageColor3 = isActive and Theme.Text or Theme.TextDim}) end
            child.BackgroundColor3 = isActive and Theme.ElementHover or Theme.Element
        end
    end
    if GUI.UpdatePreviewVisibility then GUI.UpdatePreviewVisibility() end
end

local function createTab(name, iconId, order)
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. name
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundColor3 = Theme.Element
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = TabBar
    corner(btn, 6)
    stroke(btn)
    gradient(btn)

    local iconSize = 28
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(iconSize, iconSize)
    icon.Position = UDim2.new(0.5, -iconSize/2, 0.5, -iconSize/2)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = Theme.TextDim
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = btn

    btn.MouseButton1Click:Connect(function() switchTab(name) end)

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
    page.ClipsDescendants = true
    page.Parent = ContentHost

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = page

    Pages[name] = page
    return page
end

-- Drag functionality
local function dragify(Frame)
    local dragToggle, dragSpeed, dragInput, dragStart, startPos = nil, 0.15, nil, nil, nil

    local function updateInput(input)
        local Delta = input.Position - dragStart
        local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
        TweenService:Create(Frame, TweenInfo.new(0.15), {Position = Position}):Play()
    end

    Frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UserInputService:GetFocusedTextBox() == nil then
            dragToggle = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
            end)
        end
    end)

    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then updateInput(input) end
    end)
end

-- Preview windows
local PreviewGui, SkinPreviewWindow, ESPPreviewWindow

local function updatePreviewPositions()
    local ok, err = pcall(function()
        if not MainFrame then return end
        local pos = MainFrame.AbsolutePosition
        local size = MainFrame.AbsoluteSize
        if ESPPreviewWindow then
            ESPPreviewWindow.Position = UDim2.new(0, pos.X - 225, 0, pos.Y)
            ESPPreviewWindow.Size = UDim2.fromOffset(220, size.Y)
        end
        if SkinPreviewWindow then
            SkinPreviewWindow.Position = UDim2.new(0, pos.X + size.X + 5, 0, pos.Y)
        end
    end)
end

GUI.UpdatePreviewVisibility = function()
    local ok, err = pcall(function()
        if GUI.SkinPreviewFrame then GUI.SkinPreviewFrame.Visible = (ActiveTab == "Skins") and IsOpen end
        if GUI.ESPPreviewFrame then GUI.ESPPreviewFrame.Visible = (ActiveTab == "Visuals") and IsOpen end
        updatePreviewPositions()
    end)
end

local function createPreviewWindows()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    PreviewGui = Instance.new("ScreenGui")
    PreviewGui.Name = "RivalsPreviews"
    PreviewGui.ResetOnSpawn = false
    PreviewGui.IgnoreGuiInset = true
    PreviewGui.DisplayOrder = 998
    PreviewGui.Parent = playerGui

    ESPPreviewWindow = Instance.new("Frame")
    ESPPreviewWindow.Size = UDim2.fromOffset(220, 520)
    ESPPreviewWindow.BackgroundColor3 = Theme.Background
    ESPPreviewWindow.BorderSizePixel = 0
    ESPPreviewWindow.Visible = false
    ESPPreviewWindow.Parent = PreviewGui
    corner(ESPPreviewWindow, 6)
    stroke(ESPPreviewWindow)

    local espTitle = Instance.new("TextLabel")
    espTitle.Size = UDim2.new(1, 0, 0, 32)
    espTitle.BackgroundTransparency = 1
    espTitle.Text = "ESP PREVIEW"
    espTitle.TextColor3 = Theme.HeaderBlue
    espTitle.Font = Enum.Font.GothamBold
    espTitle.TextSize = 12
    espTitle.Parent = ESPPreviewWindow

    local espViewport = Instance.new("ViewportFrame")
    espViewport.Size = UDim2.new(1, -16, 1, -40)
    espViewport.Position = UDim2.new(0, 8, 0, 36)
    espViewport.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    espViewport.BorderSizePixel = 0
    espViewport.Parent = ESPPreviewWindow
    corner(espViewport, 6)

    local espCam = Instance.new("Camera")
    espCam.Parent = espViewport
    espViewport.CurrentCamera = espCam

    local espLight = Instance.new("PointLight")
    espLight.Brightness = 3
    espLight.Range = 25
    espLight.Parent = espViewport

    SkinPreviewWindow = Instance.new("Frame")
    SkinPreviewWindow.Size = UDim2.fromOffset(200, 280)
    SkinPreviewWindow.BackgroundColor3 = Theme.Background
    SkinPreviewWindow.BorderSizePixel = 0
    SkinPreviewWindow.Visible = false
    SkinPreviewWindow.Parent = PreviewGui
    corner(SkinPreviewWindow, 6)
    stroke(SkinPreviewWindow)

    local skinTitle = Instance.new("TextLabel")
    skinTitle.Size = UDim2.new(1, 0, 0, 28)
    skinTitle.BackgroundTransparency = 1
    skinTitle.Text = "SKIN PREVIEW"
    skinTitle.TextColor3 = Theme.HeaderBlue
    skinTitle.Font = Enum.Font.GothamBold
    skinTitle.TextSize = 11
    skinTitle.Parent = SkinPreviewWindow

    local skinViewport = Instance.new("ViewportFrame")
    skinViewport.Size = UDim2.new(1, -16, 1, -70)
    skinViewport.Position = UDim2.new(0, 8, 0, 32)
    skinViewport.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    skinViewport.BorderSizePixel = 0
    skinViewport.Parent = SkinPreviewWindow
    corner(skinViewport, 6)

    local skinCam = Instance.new("Camera")
    skinCam.Parent = skinViewport
    skinViewport.CurrentCamera = skinCam

    local skinLight = Instance.new("PointLight")
    skinLight.Brightness = 3
    skinLight.Range = 20
    skinLight.Parent = skinViewport

    local disclaimer = Instance.new("TextLabel")
    disclaimer.Size = UDim2.new(1, -16, 0, 28)
    disclaimer.Position = UDim2.new(0, 8, 1, -34)
    disclaimer.BackgroundTransparency = 1
    disclaimer.Text = "Skins apply after death"
    disclaimer.TextColor3 = Color3.fromRGB(255, 180, 80)
    disclaimer.Font = Enum.Font.GothamMedium
    disclaimer.TextSize = 10
    disclaimer.Parent = SkinPreviewWindow

    GUI.SkinPreviewFrame = SkinPreviewWindow
    GUI.SkinPreviewViewport = skinViewport
    GUI.SkinPreviewCamera = skinCam
    GUI.ESPPreviewFrame = ESPPreviewWindow
    GUI.ESPPreviewViewport = espViewport
    GUI.ESPPreviewCamera = espCam

    task.wait(0.1)
    updatePreviewPositions()
end

-- Build main GUI
local function build()
    print("[GUI] Building GUI...")

    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RivalsGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = playerGui

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.fromOffset(600, 460)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    corner(MainFrame, 6)
    stroke(MainFrame)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 197, 0, 19)
    title.Position = UDim2.new(0.025, 0, 0.032, 0)
    title.BackgroundTransparency = 1
    title.Text = "RIVALS"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextScaled = true
    title.Parent = MainFrame

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
    corner(closeBtn, 6)
    stroke(closeBtn)

    closeBtn.MouseButton1Click:Connect(function() GUI.ToggleMenu() end)

    TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0, 570, 0, 28)
    TabBar.AnchorPoint = Vector2.new(0.5, 0.5)
    TabBar.Position = UDim2.new(0.5, 0, 0.13, 0)
    TabBar.BackgroundTransparency = 1
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0.01, 0)
    tabLayout.Parent = TabBar

    ContentHost = Instance.new("Frame")
    ContentHost.Size = UDim2.new(0, 570, 0, 360)
    ContentHost.AnchorPoint = Vector2.new(0.5, 0.5)
    ContentHost.Position = UDim2.new(0.5, 0, 0.57, 0)
    ContentHost.BackgroundTransparency = 1
    ContentHost.ClipsDescendants = true
    ContentHost.Parent = MainFrame

    createTab("Combat", Icons.Combat, 1)
    createTab("Visuals", Icons.Visuals, 2)
    createTab("Skins", Icons.Skins, 3)
    createTab("Misc", Icons.Misc, 4)
    createTab("Settings", Icons.Settings, 5)

    dragify(MainFrame)

    UserInputService.InputBegan:Connect(function(input, gp)
        local ok, err = pcall(function()
            if gp then return end
            if input.KeyCode == MenuKeybind then
                if IsLoading then return end
                GUI.ToggleMenu()
            end
        end)
    end)

    switchTab("Combat")
    print("[GUI] GUI built successfully!")
end

function GUI.ToggleMenu()
    if IsLoading then return end
    IsOpen = not IsOpen
    if GUI.UpdatePreviewVisibility then GUI.UpdatePreviewVisibility() end
    if MainFrame then MainFrame.Visible = IsOpen end
end

function GUI.IsOpen() return IsOpen end
function GUI.GetPage(name) return Pages[name] end

function GUI.Cleanup()
    if ScreenGui then ScreenGui:Destroy() end
    if PreviewGui then PreviewGui:Destroy() end
end

function GUI.Init(deps)
    print("[GUI] Initializing...")
    deps = deps or {}
    Config = deps.Config
    Utils = deps.Utils
    Core = deps.Core

    local ok, err = pcall(function()
        build()
        createPreviewWindows()
    end)
    if not ok then warn("[GUI] Error: " .. tostring(err)) end

    local settings = GUI.GetPage("Settings")
    if settings then
        local C = GUI.Components
        local savedKeybind = Enum.KeyCode.RightControl
        if Config and Config.Get then
            local saved = Config.Get("MenuKeybind")
            if saved then
                local ok, parsed = pcall(function() return Enum.KeyCode[saved] end)
                if ok and parsed then savedKeybind = parsed end
            end
        end

        C.Section(settings, "Menu", 1)
        C.Keybind(settings, "Menu Keybind", savedKeybind, function(k)
            print("[GUI] Keybind changed to: " .. tostring(k))
            if Config and Config.Set then Config.Set("MenuKeybind", tostring(k):gsub("Enum.KeyCode.", "")) end
            MenuKeybind = k
        end, 2)

        C.Section(settings, "Config", 10)
        C.Button(settings, "Reset Config", function() if Config and Config.Reset then Config.Reset() end end, 11, false)
        C.Button(settings, "Unload Script", function() if Core and Core.Unload then Core.Unload() end end, 12, true)
    end

    IsLoading = true
    if MainFrame then MainFrame.Active = false end

    task.delay(3, function()
        IsLoading = false
        if MainFrame then MainFrame.Active = true end
        print("================================")
        print("[rivals] GUI READY")
        print("================================")
    end)

    print("[rivals] GUI initialized.")
end

return GUI