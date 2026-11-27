-- Realistic Scripts | HyperShot Hub
-- Version 1.0.0 | By Realistic Scripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- CONFIGURATION (persists across toggles)
-- ============================================================
local Config = {
    -- Aimbot
    AimbotEnabled = false,
    AimbotKey = Enum.KeyCode.Q,
    AimbotFOV = 150,
    AimbotSmoothing = 0.15,
    AimbotTarget = "Head",
    AimbotSilent = false,
    AimbotPrediction = true,
    AimbotPredictionStrength = 0.08,
    AimbotTeamCheck = true,
    AimbotVisibilityCheck = true,
    -- ESP
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPTracers = false,
    ESPSkeleton = false,
    ESPMaxDist = 1000,
    ESPBoxColor = Color3.fromRGB(255, 60, 60),
    ESPNameColor = Color3.fromRGB(255, 255, 255),
    ESPTracerColor = Color3.fromRGB(255, 60, 60),
    ESPTeamCheck = true,
    -- Misc
    NoRecoil = false,
    NoSpread = false,
    InfiniteAmmo = false,
    FastShoot = false,
    AutoReload = false,
    SpeedHack = false,
    SpeedValue = 24,
    BunnyHop = false,
    NoclipEnabled = false,
    ThirdPerson = false,
    ThirdPersonDist = 10,
    -- Visuals
    FOVChanger = false,
    FOVValue = 90,
    Fullbright = false,
    CrosshairEnabled = false,
    CrosshairColor = Color3.fromRGB(255, 60, 60),
    CrosshairSize = 10,
    CrosshairThickness = 2,
    -- UI Customization
    AccentColor = Color3.fromRGB(255, 60, 60),
    BGColor = Color3.fromRGB(15, 15, 20),
    SecondaryBG = Color3.fromRGB(22, 22, 30),
    TextColor = Color3.fromRGB(240, 240, 255),
    TabColor = Color3.fromRGB(28, 28, 38),
    FontSize = 13,
}

-- ============================================================
-- UI LIBRARY
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RealisticScripts"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (syn and syn.protect_gui and syn.protect_gui(ScreenGui)) or gethui() or game.CoreGui

local function CreateInstance(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in pairs(children or {}) do c.Parent = inst end
    return inst
end

local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local MainFrame = CreateInstance("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 540, 0, 390),
    Position = UDim2.new(0.5, -270, 0.5, -195),
    BackgroundColor3 = Config.BGColor,
    BorderSizePixel = 0,
    Active = true,
    Parent = ScreenGui,
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 10)}, {MainFrame})

-- Drop shadow
local Shadow = CreateInstance("ImageLabel", {
    Size = UDim2.new(1, 30, 1, 30),
    Position = UDim2.new(0, -15, 0, -15),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.new(0, 0, 0),
    ImageTransparency = 0.5,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
    ZIndex = 0,
    Parent = MainFrame,
})

-- Title bar
local TitleBar = CreateInstance("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = Config.SecondaryBG,
    BorderSizePixel = 0,
    Parent = MainFrame,
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 10)}, {TitleBar})
-- fix bottom corners
CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = Config.SecondaryBG,
    BorderSizePixel = 0,
    Parent = TitleBar,
})

local LogoAccent = CreateInstance("Frame", {
    Size = UDim2.new(0, 4, 0, 24),
    Position = UDim2.new(0, 14, 0.5, -12),
    BackgroundColor3 = Config.AccentColor,
    BorderSizePixel = 0,
    Parent = TitleBar,
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 2)}, {LogoAccent})

local TitleLabel = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -50, 0, 20),
    Position = UDim2.new(0, 26, 0, 6),
    BackgroundTransparency = 1,
    Text = "Realistic Scripts",
    TextColor3 = Config.TextColor,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    Parent = TitleBar,
})

local SubLabel = CreateInstance("TextLabel", {
    Size = UDim2.new(1, -50, 0, 14),
    Position = UDim2.new(0, 26, 0, 24),
    BackgroundTransparency = 1,
    Text = "HyperShot  •  v1.0",
    TextColor3 = Color3.fromRGB(120, 120, 150),
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    Parent = TitleBar,
})

-- Close / minimize
local CloseBtn = CreateInstance("TextButton", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -34, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(220, 60, 60),
    Text = "✕",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    Parent = TitleBar,
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6)}, {CloseBtn})

local MinBtn = CreateInstance("TextButton", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -62, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(240, 180, 40),
    Text = "−",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    BorderSizePixel = 0,
    Parent = TitleBar,
})
CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6)}, {MinBtn})

-- Minimize logic
local minimized = false
local ContentArea
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Tween(MainFrame, {Size = UDim2.new(0, 540, 0, 44)}, 0.25)
    else
        Tween(MainFrame, {Size = UDim2.new(0, 540, 0, 390)}, 0.25)
    end
end)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, {Size = UDim2.new(0, 540, 0, 0)}, 0.2)
    task.delay(0.25, function() ScreenGui:Destroy() end)
end)

-- ============================================================
-- DRAG LOGIC
-- ============================================================
do
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- TAB SYSTEM
-- ============================================================
local TabBar = CreateInstance("Frame", {
    Name = "TabBar",
    Size = UDim2.new(0, 110, 1, -44),
    Position = UDim2.new(0, 0, 0, 44),
    BackgroundColor3 = Config.SecondaryBG,
    BorderSizePixel = 0,
    Parent = MainFrame,
})

-- separator line
CreateInstance("Frame", {
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(40, 40, 55),
    BorderSizePixel = 0,
    Parent = TabBar,
})

local TabList = CreateInstance("Frame", {
    Size = UDim2.new(1, 0, 1, -10),
    Position = UDim2.new(0, 0, 0, 10),
    BackgroundTransparency = 1,
    Parent = TabBar,
})
CreateInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2),
    Parent = TabList,
})

ContentArea = CreateInstance("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -111, 1, -44),
    Position = UDim2.new(0, 111, 0, 44),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = MainFrame,
})

local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, icon)
    local TabBtn = CreateInstance("TextButton", {
        Size = UDim2.new(1, -8, 0, 34),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundColor3 = Config.TabColor,
        BackgroundTransparency = 1,
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = #Tabs + 1,
        Parent = TabList,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 7)}, {TabBtn})

    local IconL = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 22, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = Color3.fromRGB(130, 130, 160),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = TabBtn,
    })
    local NameL = CreateInstance("TextLabel", {
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(130, 130, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = TabBtn,
    })
    local ActiveBar = CreateInstance("Frame", {
        Size = UDim2.new(0, 3, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundColor3 = Config.AccentColor,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = TabBtn,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 2)}, {ActiveBar})

    local Page = CreateInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = ContentArea,
    })
    CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Page,
    })
    CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = Page,
    })

    local tab = {Btn = TabBtn, Page = Page, Bar = ActiveBar, Icon = IconL, Name = NameL}

    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTab then
            ActiveTab.Page.Visible = false
            Tween(ActiveTab.Bar, {BackgroundTransparency = 1}, 0.15)
            Tween(ActiveTab.Icon, {TextColor3 = Color3.fromRGB(130, 130, 160)}, 0.15)
            Tween(ActiveTab.Name, {TextColor3 = Color3.fromRGB(130, 130, 160)}, 0.15)
            Tween(ActiveTab.Btn, {BackgroundTransparency = 1}, 0.15)
        end
        ActiveTab = tab
        Page.Visible = true
        Tween(ActiveBar, {BackgroundTransparency = 0}, 0.15)
        Tween(IconL, {TextColor3 = Config.AccentColor}, 0.15)
        Tween(NameL, {TextColor3 = Config.TextColor}, 0.15)
        Tween(TabBtn, {BackgroundTransparency = 0, BackgroundColor3 = Config.TabColor}, 0.15)
    end)

    Tabs[name] = tab
    return tab
end

-- ============================================================
-- ELEMENT BUILDERS
-- ============================================================
local function AddSection(page, title)
    local Sect = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = page,
    })
    CreateInstance("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = title:upper(),
        TextColor3 = Config.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = Sect,
    })
    CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Config.AccentColor,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = Sect,
    })
    return Sect
end

local function AddToggle(page, label, default, callback)
    local Row = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Config.SecondaryBG,
        BorderSizePixel = 0,
        Parent = page,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 7)}, {Row})

    CreateInstance("TextLabel", {
        Size = UDim2.new(1, -56, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = Row,
    })

    local ToggleBg = CreateInstance("Frame", {
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -46, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(50, 50, 65),
        BorderSizePixel = 0,
        Parent = Row,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, {ToggleBg})

    local Knob = CreateInstance("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(180, 180, 200),
        BorderSizePixel = 0,
        Parent = ToggleBg,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, {Knob})

    local state = default or false
    local function SetState(s, silent)
        state = s
        if s then
            Tween(ToggleBg, {BackgroundColor3 = Config.AccentColor}, 0.18)
            Tween(Knob, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)}, 0.18)
        else
            Tween(ToggleBg, {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}, 0.18)
            Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(180,180,200)}, 0.18)
        end
        if not silent and callback then callback(s) end
    end
    SetState(state, true)

    local Btn = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Row,
    })
    Btn.MouseButton1Click:Connect(function() SetState(not state) end)
    Btn.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3 = Color3.fromRGB(28, 28, 40)}, 0.1) end)
    Btn.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3 = Config.SecondaryBG}, 0.1) end)

    return {SetState = SetState, GetState = function() return state end}
end

local function AddSlider(page, label, min, max, default, callback)
    local Row = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Config.SecondaryBG,
        BorderSizePixel = 0,
        Parent = page,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 7)}, {Row})

    local ValLabel = CreateInstance("TextLabel", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -48, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Config.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = Row,
    })
    CreateInstance("TextLabel", {
        Size = UDim2.new(1, -56, 0, 20),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = Row,
    })

    local Track = CreateInstance("Frame", {
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.new(0, 10, 0, 34),
        BackgroundColor3 = Color3.fromRGB(50, 50, 65),
        BorderSizePixel = 0,
        Parent = Row,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, {Track})

    local Fill = CreateInstance("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Config.AccentColor,
        BorderSizePixel = 0,
        Parent = Track,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, {Fill})

    local Knob = CreateInstance("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = Track,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, {Knob})

    local value = default
    local function SetValue(v, silent)
        v = math.clamp(math.round(v), min, max)
        value = v
        local pct = (v - min) / (max - min)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Knob.Position = UDim2.new(pct, 0, 0.5, 0)
        ValLabel.Text = tostring(v)
        if not silent and callback then callback(v) end
    end
    SetValue(default, true)

    local sliding = false
    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local abs = Track.AbsolutePosition
            local sz = Track.AbsoluteSize
            local pct = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
            SetValue(min + (max - min) * pct)
        end
    end)

    return {SetValue = SetValue, GetValue = function() return value end}
end

local function AddButton(page, label, callback)
    local Btn = CreateInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Config.AccentColor,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = label,
        TextColor3 = Config.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = page,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 7)}, {Btn})
    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundTransparency = 0.1}, 0.1) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundTransparency = 0.3}, 0.1) end)
    Btn.MouseButton1Click:Connect(function()
        Tween(Btn, {BackgroundTransparency = 0}, 0.05)
        task.delay(0.1, function() Tween(Btn, {BackgroundTransparency = 0.3}, 0.1) end)
        if callback then callback() end
    end)
    return Btn
end

local function AddDropdown(page, label, options, default, callback)
    local Container = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Config.SecondaryBG,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 10,
        Parent = page,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 7)}, {Container})

    CreateInstance("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 10,
        Parent = Container,
    })

    local Selected = CreateInstance("TextButton", {
        Size = UDim2.new(0, 110, 0, 22),
        Position = UDim2.new(1, -118, 0.5, -11),
        BackgroundColor3 = Config.TabColor,
        BorderSizePixel = 0,
        Text = default or options[1],
        TextColor3 = Config.TextColor,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        ZIndex = 10,
        Parent = Container,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 5)}, {Selected})

    local DropFrame = CreateInstance("Frame", {
        Size = UDim2.new(0, 110, 0, #options * 26 + 4),
        Position = UDim2.new(1, -118, 1, 4),
        BackgroundColor3 = Config.TabColor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
        Parent = Container,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 6)}, {DropFrame})
    CreateInstance("UIListLayout", {Padding = UDim.new(0, 2), Parent = DropFrame})
    CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 2),
        Parent = DropFrame,
    })

    for _, opt in ipairs(options) do
        local OptionBtn = CreateInstance("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Config.TabColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = opt,
            TextColor3 = Config.TextColor,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            ZIndex = 20,
            Parent = DropFrame,
        })
        CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4)}, {OptionBtn})
        OptionBtn.MouseEnter:Connect(function() Tween(OptionBtn, {BackgroundTransparency = 0.5}, 0.1) end)
        OptionBtn.MouseLeave:Connect(function() Tween(OptionBtn, {BackgroundTransparency = 1}, 0.1) end)
        OptionBtn.MouseButton1Click:Connect(function()
            Selected.Text = opt
            DropFrame.Visible = false
            if callback then callback(opt) end
        end)
    end

    Selected.MouseButton1Click:Connect(function()
        DropFrame.Visible = not DropFrame.Visible
    end)

    return Container
end

local function AddColorPicker(page, label, default, callback)
    local Row = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundColor3 = Config.SecondaryBG,
        BorderSizePixel = 0,
        Parent = page,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 7)}, {Row})

    CreateInstance("TextLabel", {
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Config.TextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = Row,
    })

    local Preview = CreateInstance("Frame", {
        Size = UDim2.new(0, 28, 0, 18),
        Position = UDim2.new(1, -38, 0, 7),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Parent = Row,
    })
    CreateInstance("UICorner", {CornerRadius = UDim.new(0, 4)}, {Preview})

    local r = math.floor(default.R * 255)
    local g = math.floor(default.G * 255)
    local b = math.floor(default.B * 255)

    local function UpdateColor(silent)
        local c = Color3.fromRGB(r, g, b)
        Preview.BackgroundColor3 = c
        if not silent and callback then callback(c) end
    end

    local chLabels = {"R", "G", "B"}
    local defaults = {r, g, b}
    local channels = {
        Color3.fromRGB(220, 60, 60),
        Color3.fromRGB(60, 200, 60),
        Color3.fromRGB(60, 120, 255),
    }

    for i, ch in ipairs(chLabels) do
        local ypos = 28 + (i - 1) * 22
        local Track2 = CreateInstance("Frame", {
            Size = UDim2.new(1, -50, 0, 4),
            Position = UDim2.new(0, 10, 0, ypos + 10),
            BackgroundColor3 = Color3.fromRGB(50, 50, 65),
            BorderSizePixel = 0,
            Parent = Row,
        })
        CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, {Track2})
        local Fill2 = CreateInstance("Frame", {
            Size = UDim2.new(defaults[i] / 255, 0, 1, 0),
            BackgroundColor3 = channels[i],
            BorderSizePixel = 0,
            Parent = Track2,
        })
        CreateInstance("UICorner", {CornerRadius = UDim.new(1, 0)}, {Fill2})
        CreateInstance("TextLabel", {
            Size = UDim2.new(0, 10, 0, 14),
            Position = UDim2.new(1, 4, 0.5, -7),
            BackgroundTransparency = 1,
            Text = ch,
            TextColor3 = Config.TextColor,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Parent = Track2,
        })

        local idx = i
        local sliding2 = false
        Track2.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding2 = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding2 = false end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if sliding2 and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local abs = Track2.AbsolutePosition
                local sz = Track2.AbsoluteSize
                local pct = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
                local val = math.floor(pct * 255)
                Fill2.Size = UDim2.new(pct, 0, 1, 0)
                if idx == 1 then r = val
                elseif idx == 2 then g = val
                else b = val end
                UpdateColor()
            end
        end)
    end
    return Row
end

-- ============================================================
-- CREATE TABS
-- ============================================================
local TabAimbot = CreateTab("Aimbot", "⊙")
local TabESP    = CreateTab("ESP",    "◈")
local TabMisc   = CreateTab("Misc",   "⚙")
local TabVisual = CreateTab("Visuals","◉")
local TabCustom = CreateTab("Custom", "✦")

-- Activate first tab
TabAimbot.Btn.MouseButton1Click:Fire()

-- ============================================================
-- AIMBOT TAB
-- ============================================================
do
    local p = TabAimbot.Page
    AddSection(p, "Targeting")
    AddToggle(p, "Enable Aimbot", false, function(v) Config.AimbotEnabled = v end)
    AddToggle(p, "Silent Aim", false, function(v) Config.AimbotSilent = v end)
    AddToggle(p, "Team Check", true, function(v) Config.AimbotTeamCheck = v end)
    AddToggle(p, "Visibility Check", true, function(v) Config.AimbotVisibilityCheck = v end)
    AddToggle(p, "Prediction", true, function(v) Config.AimbotPrediction = v end)
    AddSection(p, "Settings")
    AddSlider(p, "FOV", 10, 500, 150, function(v) Config.AimbotFOV = v end)
    AddSlider(p, "Smoothing (ms)", 1, 50, 15, function(v) Config.AimbotSmoothing = v / 100 end)
    AddSlider(p, "Prediction Strength", 1, 20, 8, function(v) Config.AimbotPredictionStrength = v / 100 end)
    AddSection(p, "Target")
    AddDropdown(p, "Aim Part", {"Head","Neck","Torso","HumanoidRootPart"}, "Head", function(v) Config.AimbotTarget = v end)
end

-- ============================================================
-- ESP TAB
-- ============================================================
do
    local p = TabESP.Page
    AddSection(p, "Display")
    AddToggle(p, "Enable ESP", false, function(v) Config.ESPEnabled = v end)
    AddToggle(p, "Boxes", true, function(v) Config.ESPBoxes = v end)
    AddToggle(p, "Names", true, function(v) Config.ESPNames = v end)
    AddToggle(p, "Health Bars", true, function(v) Config.ESPHealth = v end)
    AddToggle(p, "Distance", true, function(v) Config.ESPDistance = v end)
    AddToggle(p, "Tracers", false, function(v) Config.ESPTracers = v end)
    AddToggle(p, "Skeleton", false, function(v) Config.ESPSkeleton = v end)
    AddToggle(p, "Team Check", true, function(v) Config.ESPTeamCheck = v end)
    AddSection(p, "Range")
    AddSlider(p, "Max Distance", 100, 2000, 1000, function(v) Config.ESPMaxDist = v end)
    AddSection(p, "Colors")
    AddColorPicker(p, "Box Color", Color3.fromRGB(255, 60, 60), function(v) Config.ESPBoxColor = v end)
    AddColorPicker(p, "Name Color", Color3.fromRGB(255, 255, 255), function(v) Config.ESPNameColor = v end)
    AddColorPicker(p, "Tracer Color", Color3.fromRGB(255, 60, 60), function(v) Config.ESPTracerColor = v end)
end

-- ============================================================
-- MISC TAB
-- ============================================================
do
    local p = TabMisc.Page
    AddSection(p, "Gun")
    AddToggle(p, "No Recoil", false, function(v) Config.NoRecoil = v end)
    AddToggle(p, "No Spread", false, function(v) Config.NoSpread = v end)
    AddToggle(p, "Infinite Ammo", false, function(v) Config.InfiniteAmmo = v end)
    AddToggle(p, "Fast Shoot", false, function(v) Config.FastShoot = v end)
    AddToggle(p, "Auto Reload", false, function(v) Config.AutoReload = v end)
    AddSection(p, "Movement")
    AddToggle(p, "Speed Hack", false, function(v)
        Config.SpeedHack = v
        Humanoid.WalkSpeed = v and Config.SpeedValue or 16
    end)
    AddSlider(p, "Speed Value", 16, 200, 24, function(v)
        Config.SpeedValue = v
        if Config.SpeedHack then Humanoid.WalkSpeed = v end
    end)
    AddToggle(p, "Bunny Hop", false, function(v) Config.BunnyHop = v end)
    AddToggle(p, "Noclip", false, function(v) Config.NoclipEnabled = v end)
    AddSection(p, "Camera")
    AddToggle(p, "Third Person", false, function(v)
        Config.ThirdPerson = v
        if not v then
            Camera.CameraType = Enum.CameraType.Custom
        end
    end)
    AddSlider(p, "Third Person Dist", 5, 30, 10, function(v) Config.ThirdPersonDist = v end)
    AddSection(p, "Actions")
    AddButton(p, "Teleport to Spawn", function()
        if workspace:FindFirstChild("SpawnLocation") then
            RootPart.CFrame = workspace.SpawnLocation.CFrame + Vector3.new(0, 5, 0)
        end
    end)
    AddButton(p, "Rejoin Server", function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId)
    end)
end

-- ============================================================
-- VISUALS TAB
-- ============================================================
do
    local p = TabVisual.Page
    AddSection(p, "Camera")
    AddToggle(p, "FOV Changer", false, function(v)
        Config.FOVChanger = v
        Camera.FieldOfView = v and Config.FOVValue or 70
    end)
    AddSlider(p, "FOV Value", 50, 120, 90, function(v)
        Config.FOVValue = v
        if Config.FOVChanger then Camera.FieldOfView = v end
    end)
    AddToggle(p, "Fullbright", false, function(v)
        Config.Fullbright = v
        local Lighting = game:GetService("Lighting")
        if v then
            Lighting.Brightness = 10
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end)
    AddSection(p, "Crosshair")
    AddToggle(p, "Custom Crosshair", false, function(v) Config.CrosshairEnabled = v end)
    AddSlider(p, "Crosshair Size", 4, 30, 10, function(v) Config.CrosshairSize = v end)
    AddSlider(p, "Crosshair Thickness", 1, 5, 2, function(v) Config.CrosshairThickness = v end)
    AddColorPicker(p, "Crosshair Color", Color3.fromRGB(255, 60, 60), function(v) Config.CrosshairColor = v end)
end

-- ============================================================
-- CUSTOM TAB
-- ============================================================
do
    local p = TabCustom.Page
    AddSection(p, "Theme")
    AddColorPicker(p, "Accent Color", Config.AccentColor, function(v)
        Config.AccentColor = v
        LogoAccent.BackgroundColor3 = v
    end)
    AddColorPicker(p, "Background", Config.BGColor, function(v)
        Config.BGColor = v
        MainFrame.BackgroundColor3 = v
    end)
    AddColorPicker(p, "Secondary BG", Config.SecondaryBG, function(v)
        Config.SecondaryBG = v
        TitleBar.BackgroundColor3 = v
        TabBar.BackgroundColor3 = v
    end)
    AddSection(p, "Display")
    AddSlider(p, "UI Scale", 70, 130, 100, function(v)
        local scale = v / 100
        MainFrame.Size = UDim2.new(0, math.floor(540 * scale), 0, math.floor(390 * scale))
    end)
    AddSection(p, "Keybind")
    AddButton(p, "Toggle UI: [RightShift]", function() end)
    AddSection(p, "Info")
    AddButton(p, "Realistic Scripts v1.0 — HyperShot", function() end)
end

-- ============================================================
-- TOGGLE UI WITH RIGHTSHIFT
-- ============================================================
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================================
-- FOV CIRCLE DRAWING
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.6
FOVCircle.NumSides = 64
FOVCircle.Filled = false

-- ============================================================
-- CROSSHAIR DRAWING
-- ============================================================
local CrosshairLines = {}
for i = 1, 4 do
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 2
    l.Color = Color3.fromRGB(255, 60, 60)
    CrosshairLines[i] = l
end

-- ============================================================
-- ESP DRAWINGS POOL
-- ============================================================
local ESPObjects = {}

local function GetESP(player)
    if not ESPObjects[player] then
        local obj = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Health = Drawing.new("Square"),
            HealthFill = Drawing.new("Square"),
            Dist = Drawing.new("Text"),
            Tracer = Drawing.new("Line"),
        }
        obj.Box.Thickness = 1
        obj.Box.Filled = false
        obj.Name.Size = 13
        obj.Name.Center = true
        obj.Name.Outline = true
        obj.Name.Font = 2
        obj.Health.Thickness = 1
        obj.Health.Filled = true
        obj.Health.Color = Color3.fromRGB(50, 50, 50)
        obj.HealthFill.Thickness = 1
        obj.HealthFill.Filled = true
        obj.Dist.Size = 11
        obj.Dist.Center = true
        obj.Dist.Outline = true
        obj.Dist.Font = 2
        obj.Tracer.Thickness = 1
        ESPObjects[player] = obj
    end
    return ESPObjects[player]
end

local function HideESP(player)
    local obj = ESPObjects[player]
    if not obj then return end
    for _, v in pairs(obj) do v.Visible = false end
end

Players.PlayerRemoving:Connect(function(pl)
    local obj = ESPObjects[pl]
    if obj then
        for _, v in pairs(obj) do v:Remove() end
        ESPObjects[pl] = nil
    end
end)

-- ============================================================
-- AIMBOT HELPERS
-- ============================================================
local function IsEnemy(pl)
    if Config.AimbotTeamCheck and pl.Team == Player.Team then return false end
    return true
end

local function IsAlive(pl)
    local c = pl.Character
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function IsVisible(pos)
    if not Config.AimbotVisibilityCheck then return true end
    local ray = Ray.new(Camera.CFrame.Position, (pos - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Character}, false, true)
    return hit == nil or hit.Parent == game:GetService("Players"):GetPlayerFromCharacter(hit.Parent) and hit.Parent.Character
end

local function GetTarget()
    local best, bestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == Player or not IsEnemy(pl) or not IsAlive(pl) then continue end
        local c = pl.Character
        local part = c:FindFirstChild(Config.AimbotTarget) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local pos = part.Position
        if Config.AimbotPrediction then
            local vel = part.Velocity
            pos = pos + vel * Config.AimbotPredictionStrength
        end

        local screen, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then continue end

        local dist2d = (Vector2.new(screen.X, screen.Y) - center).Magnitude
        if dist2d < Config.AimbotFOV and dist2d < bestDist then
            if IsVisible(pos) then
                best = {Player = pl, Part = part, Pos = pos, Screen = Vector2.new(screen.X, screen.Y)}
                bestDist = dist2d
            end
        end
    end
    return best
end

-- ============================================================
-- NOCLIP
-- ============================================================
RunService.Stepped:Connect(function()
    if Config.NoclipEnabled then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ============================================================
-- BUNNY HOP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if Config.BunnyHop then
        Humanoid.Jump = true
    end
end)

-- ============================================================
-- THIRD PERSON
-- ============================================================
RunService.RenderStepped:Connect(function()
    if Config.ThirdPerson then
        Camera.CameraType = Enum.CameraType.Attach
        Camera.CFrame = CFrame.new(
            RootPart.Position + Vector3.new(0, 2, Config.ThirdPersonDist),
            RootPart.Position
        )
    end
end)

-- ============================================================
-- MAIN RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- FOV Circle
    FOVCircle.Visible = Config.AimbotEnabled
    FOVCircle.Radius = Config.AimbotFOV
    FOVCircle.Position = center

    -- Crosshair
    if Config.CrosshairEnabled then
        local s = Config.CrosshairSize
        local t = Config.CrosshairThickness
        local c = Config.CrosshairColor
        CrosshairLines[1].From = Vector2.new(center.X, center.Y - s)
        CrosshairLines[1].To   = Vector2.new(center.X, center.Y - 3)
        CrosshairLines[2].From = Vector2.new(center.X, center.Y + 3)
        CrosshairLines[2].To   = Vector2.new(center.X, center.Y + s)
        CrosshairLines[3].From = Vector2.new(center.X - s, center.Y)
        CrosshairLines[3].To   = Vector2.new(center.X - 3, center.Y)
        CrosshairLines[4].From = Vector2.new(center.X + 3, center.Y)
        CrosshairLines[4].To   = Vector2.new(center.X + s, center.Y)
        for _, l in ipairs(CrosshairLines) do
            l.Visible = true
            l.Thickness = t
            l.Color = c
        end
    else
        for _, l in ipairs(CrosshairLines) do l.Visible = false end
    end

    -- Aimbot
    if Config.AimbotEnabled then
        local target = GetTarget()
        if target then
            if not Config.AimbotSilent then
                local currentAngle = Camera.CFrame.LookVector
                local targetDir = (target.Pos - Camera.CFrame.Position).Unit
                local newDir = currentAngle:Lerp(targetDir, Config.AimbotSmoothing)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newDir)
            end
        end
    end

    -- ESP
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == Player then continue end
        if Config.ESPTeamCheck and pl.Team == Player.Team then
            HideESP(pl)
            continue
        end
        if not IsAlive(pl) or not Config.ESPEnabled then
            HideESP(pl)
            continue
        end

        local c = pl.Character
        local root = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChild("Humanoid")
        local head = c:FindFirstChild("Head")
        if not root or not hum or not head then HideESP(pl) continue end

        local dist = (root.Position - RootPart.Position).Magnitude
        if dist > Config.ESPMaxDist then HideESP(pl) continue end

        local rootScreen, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))

        if not onScreen then HideESP(pl) continue end

        local obj = GetESP(pl)
        local h = math.abs(headScreen.Y - rootScreen.Y) * 2
        local w = h * 0.5
        local x = rootScreen.X - w / 2
        local y = headScreen.Y - 2

        obj.Box.Visible = Config.ESPBoxes
        obj.Box.Color = Config.ESPBoxColor
        obj.Box.Position = Vector2.new(x, y)
        obj.Box.Size = Vector2.new(w, h)

        obj.Name.Visible = Config.ESPNames
        obj.Name.Text = pl.Name
        obj.Name.Color = Config.ESPNameColor
        obj.Name.Position = Vector2.new(rootScreen.X, y - 15)

        local hpPct = hum.Health / hum.MaxHealth
        obj.Health.Visible = Config.ESPHealth
        obj.Health.Position = Vector2.new(x - 7, y)
        obj.Health.Size = Vector2.new(4, h)
        obj.HealthFill.Visible = Config.ESPHealth
        obj.HealthFill.Position = Vector2.new(x - 7, y + h * (1 - hpPct))
        obj.HealthFill.Size = Vector2.new(4, h * hpPct)
        obj.HealthFill.Color = Color3.fromRGB(math.floor(255 * (1 - hpPct)), math.floor(255 * hpPct), 50)

        obj.Dist.Visible = Config.ESPDistance
        obj.Dist.Text = math.floor(dist) .. "m"
        obj.Dist.Color = Color3.fromRGB(200, 200, 200)
        obj.Dist.Position = Vector2.new(rootScreen.X, y + h + 2)

        obj.Tracer.Visible = Config.ESPTracers
        obj.Tracer.From = Vector2.new(center.X, Camera.ViewportSize.Y)
        obj.Tracer.To = Vector2.new(rootScreen.X, rootScreen.Y)
        obj.Tracer.Color = Config.ESPTracerColor
    end
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    if Config.SpeedHack then
        Humanoid.WalkSpeed = Config.SpeedValue
    end
end)

print("[Realistic Scripts] Loaded — HyperShot | Toggle UI: RightShift")
