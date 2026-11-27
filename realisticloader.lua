-- realistic | v1.0
-- Clean sidebar-style cheat menu for Roblox FPS games

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- CONFIG
-- ============================================================
local Cfg = {
    -- Aimbot
    Aim = false,
    AimKey = Enum.KeyCode.Q,
    AimFOV = 120,
    AimSmooth = 0.18,
    AimPart = "Head",
    SilentAim = false,
    AimPred = true,
    AimPredStr = 0.07,
    TeamCheck = true,
    VisCheck = true,
    -- Auto
    AutoShoot = false,
    AutoReload = false,
    TriggerBot = false,
    TriggerDelay = 0.05,
    -- ESP
    ESP = false,
    ESPBox = true,
    ESPName = true,
    ESPDist = true,
    ESPHealth = true,
    ESPTracer = false,
    ESPMaxDist = 1000,
    ESPBoxColor = Color3.fromRGB(255, 255, 255),
    ESPNameColor = Color3.fromRGB(255, 255, 255),
    ESPTracerColor = Color3.fromRGB(80, 160, 255),
    ESPTeamCheck = true,
    -- Visuals
    FOVChanger = false,
    FOVVal = 90,
    Fullbright = false,
    Crosshair = false,
    CrossColor = Color3.fromRGB(80, 160, 255),
    CrossSize = 10,
    CrossThick = 2,
    -- Misc
    AntiAFK = true,
    StatusHUD = true,
    SaveSettings = true,
    SpeedHack = false,
    SpeedVal = 24,
    BHop = false,
    Noclip = false,
    -- Skins (placeholder toggles)
    SkinChanger = false,
    SkinID = 1,
}

-- ============================================================
-- THEME
-- ============================================================
local T = {
    BG       = Color3.fromRGB(18, 18, 24),
    Sidebar  = Color3.fromRGB(13, 13, 18),
    Panel    = Color3.fromRGB(24, 24, 32),
    Row      = Color3.fromRGB(28, 28, 38),
    Accent   = Color3.fromRGB(80, 160, 255),
    AccentDim= Color3.fromRGB(40, 80, 140),
    Text     = Color3.fromRGB(230, 230, 240),
    TextDim  = Color3.fromRGB(120, 120, 150),
    Toggle   = Color3.fromRGB(40, 40, 55),
    Success  = Color3.fromRGB(60, 200, 100),
    Danger   = Color3.fromRGB(220, 60, 60),
    Border   = Color3.fromRGB(38, 38, 52),
}

-- ============================================================
-- GUI ROOT
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "REALISTIC"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (syn and syn.protect_gui and syn.protect_gui(ScreenGui)) or gethui() or game.CoreGui

local function New(class, props, children)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    for _, c in pairs(children or {}) do c.Parent = i end
    return i
end

local function Tween(obj, props, t, style)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props):Play()
end

local function Corner(r, parent)
    return New("UICorner", {CornerRadius = UDim.new(0, r), Parent = parent})
end

local function Stroke(color, thick, parent)
    return New("UIStroke", {Color = color, Thickness = thick or 1, Parent = parent})
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local Win = New("Frame", {
    Name = "Window",
    Size = UDim2.new(0, 540, 0, 400),
    Position = UDim2.new(0.5, -270, 0.5, -200),
    BackgroundColor3 = T.BG,
    BorderSizePixel = 0,
    Active = true,
    Parent = ScreenGui,
})
Corner(10, Win)
Stroke(T.Border, 1, Win)

-- shadow
New("ImageLabel", {
    Size = UDim2.new(1, 40, 1, 40),
    Position = UDim2.new(0, -20, 0, -20),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.new(0,0,0),
    ImageTransparency = 0.55,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49,49,450,450),
    ZIndex = 0,
    Parent = Win,
})

-- ============================================================
-- TOP BAR (like Solo hub)
-- ============================================================
local TopBar = New("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = T.Sidebar,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = Win,
})
Corner(10, TopBar)
-- fix bottom corners of topbar
New("Frame", {
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = T.Sidebar,
    BorderSizePixel = 0,
    Parent = TopBar,
})

-- Logo dot (like Solo's circle icon)
local LogoDot = New("Frame", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0, 12, 0.5, -14),
    BackgroundColor3 = T.Accent,
    BorderSizePixel = 0,
    Parent = TopBar,
})
Corner(14, LogoDot)
New("Frame", {
    Size = UDim2.new(0, 10, 0, 10),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = T.BG,
    BorderSizePixel = 0,
    Parent = LogoDot,
})
Corner(5, LogoDot:FindFirstChildOfClass("Frame"))

-- Hub name
New("TextLabel", {
    Size = UDim2.new(0, 80, 0, 20),
    Position = UDim2.new(0, 48, 0, 8),
    BackgroundTransparency = 1,
    Text = "SOLO",
    TextColor3 = T.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})
New("TextLabel", {
    Size = UDim2.new(0, 100, 0, 14),
    Position = UDim2.new(0, 48, 0, 27),
    BackgroundTransparency = 1,
    Text = "Hypershot",
    TextColor3 = T.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

-- Player info (right side of topbar like Solo)
local function GetAvatar()
    return "rbxthumb://type=AvatarHeadShot&id="..Player.UserId.."&w=48&h=48"
end

local AvatarImg = New("ImageLabel", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -152, 0.5, -14),
    BackgroundColor3 = T.Row,
    Image = GetAvatar(),
    BorderSizePixel = 0,
    Parent = TopBar,
})
Corner(14, AvatarImg)

New("TextLabel", {
    Size = UDim2.new(0, 100, 0, 16),
    Position = UDim2.new(1, -120, 0, 10),
    BackgroundTransparency = 1,
    Text = Player.Name,
    TextColor3 = T.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

local EnemyCountLabel = New("TextLabel", {
    Size = UDim2.new(0, 100, 0, 14),
    Position = UDim2.new(1, -120, 0, 25),
    BackgroundTransparency = 1,
    Text = "0 enemies",
    TextColor3 = T.Accent,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

-- Close / minimize
local CloseBtn = New("TextButton", {
    Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(1, -34, 0.5, -11),
    BackgroundColor3 = T.Danger,
    BackgroundTransparency = 0.3,
    Text = "✕",
    TextColor3 = T.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    BorderSizePixel = 0,
    Parent = TopBar,
})
Corner(6, CloseBtn)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(Win, {Size = UDim2.new(0, 540, 0, 0), Position = UDim2.new(0.5,-270,0.5,0)}, 0.2)
    task.delay(0.22, function() ScreenGui:Destroy() end)
end)

local MinBtn = New("TextButton", {
    Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(1, -60, 0.5, -11),
    BackgroundColor3 = T.Toggle,
    Text = "−",
    TextColor3 = T.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    BorderSizePixel = 0,
    Parent = TopBar,
})
Corner(6, MinBtn)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Tween(Win, {Size = UDim2.new(0, 540, 0, minimized and 48 or 400)}, 0.25)
end)

-- ============================================================
-- DRAG
-- ============================================================
do
    local drag, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dragStart = inp.Position; startPos = Win.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and inp == dragInput then
            local d = inp.Position - dragStart
            Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- ============================================================
-- CONTENT AREA
-- ============================================================
local Content = New("Frame", {
    Name = "Content",
    Size = UDim2.new(1, 0, 1, -48),
    Position = UDim2.new(0, 0, 0, 48),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = Win,
})

-- LEFT SIDEBAR (tab icons + labels like Solo)
local Sidebar = New("Frame", {
    Size = UDim2.new(0, 130, 1, 0),
    BackgroundColor3 = T.Sidebar,
    BorderSizePixel = 0,
    Parent = Content,
})
-- sidebar right border
New("Frame", {
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = T.Border,
    BorderSizePixel = 0,
    Parent = Sidebar,
})

local TabList = New("Frame", {
    Size = UDim2.new(1, 0, 1, -60),
    Position = UDim2.new(0, 0, 0, 10),
    BackgroundTransparency = 1,
    Parent = Sidebar,
})
New("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2),
    Parent = TabList,
})
New("UIPadding", {
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    Parent = TabList,
})

-- Bottom version label
New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 1, -28),
    BackgroundTransparency = 1,
    Text = "v1.0",
    TextColor3 = T.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    Parent = Sidebar,
})

-- Bottom hint
New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundTransparency = 1,
    Text = "Hold RMB to aim",
    TextColor3 = T.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    Parent = Sidebar,
})

-- PAGE CONTAINER
local PageContainer = New("Frame", {
    Size = UDim2.new(1, -131, 1, 0),
    Position = UDim2.new(0, 131, 0, 0),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = Content,
})

-- ============================================================
-- TAB SYSTEM
-- ============================================================
local Tabs = {}
local ActiveTab = nil

local TabIcons = {
    Aimbot = "⊙",
    Auto   = "⌖",
    Visuals= "◉",
    Skins  = "◈",
    Misc   = "⚙",
}

local function MakeTab(name, order)
    local icon = TabIcons[name] or "•"

    local Btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = T.BG,
        BackgroundTransparency = 1,
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = TabList,
    })
    Corner(7, Btn)

    -- active left bar indicator
    local ActiveBar = New("Frame", {
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Btn,
    })
    Corner(2, ActiveBar)

    local IconL = New("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = T.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Parent = Btn,
    })
    local NameL = New("TextLabel", {
        Size = UDim2.new(1, -38, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = T.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = Btn,
    })

    -- scrolling page
    local Page = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = PageContainer,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = Page,
    })
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = Page,
    })

    local tab = {Btn=Btn, Page=Page, Bar=ActiveBar, Icon=IconL, Name=NameL, Active=false}

    Btn.MouseButton1Click:Connect(function()
        if ActiveTab then
            ActiveTab.Page.Visible = false
            Tween(ActiveTab.Bar, {BackgroundTransparency=1}, 0.15)
            Tween(ActiveTab.Icon, {TextColor3=T.TextDim}, 0.15)
            Tween(ActiveTab.Name, {TextColor3=T.TextDim}, 0.15)
            Tween(ActiveTab.Btn, {BackgroundTransparency=1}, 0.15)
        end
        ActiveTab = tab
        tab.Page.Visible = true
        Tween(ActiveBar, {BackgroundTransparency=0}, 0.15)
        Tween(IconL, {TextColor3=T.Accent}, 0.15)
        Tween(NameL, {TextColor3=T.Text}, 0.15)
        Tween(Btn, {BackgroundTransparency=0, BackgroundColor3=T.Row}, 0.15)
    end)

    Btn.MouseEnter:Connect(function()
        if ActiveTab ~= tab then
            Tween(Btn, {BackgroundTransparency=0.6, BackgroundColor3=T.Row}, 0.1)
        end
    end)
    Btn.MouseLeave:Connect(function()
        if ActiveTab ~= tab then
            Tween(Btn, {BackgroundTransparency=1}, 0.1)
        end
    end)

    Tabs[name] = tab
    return tab
end

-- ============================================================
-- ELEMENT BUILDERS
-- ============================================================

-- Section header (subtle, not all-caps)
local function Section(page, text)
    local F = New("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Parent = page,
    })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = T.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = F,
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel = 0,
        Parent = F,
    })
end

-- Toggle row (description optional)
local function Toggle(page, label, desc, default, cb)
    local Row = New("Frame", {
        Size = UDim2.new(1, 0, 0, desc and 44 or 36),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = page,
    })
    Corner(7, Row)

    New("TextLabel", {
        Size = UDim2.new(1, -56, 0, 18),
        Position = UDim2.new(0, 10, 0, desc and 6 or 9),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = Row,
    })

    if desc then
        New("TextLabel", {
            Size = UDim2.new(1, -56, 0, 14),
            Position = UDim2.new(0, 10, 0, 23),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = T.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            Parent = Row,
        })
    end

    local Track = New("Frame", {
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -46, 0.5, -9),
        BackgroundColor3 = T.Toggle,
        BorderSizePixel = 0,
        Parent = Row,
    })
    Corner(9, Track)

    local Knob = New("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(160, 160, 180),
        BorderSizePixel = 0,
        Parent = Track,
    })
    Corner(7, Knob)

    local state = default or false
    local function Set(s, silent)
        state = s
        if s then
            Tween(Track, {BackgroundColor3=T.Accent}, 0.18)
            Tween(Knob, {Position=UDim2.new(1,-16,0.5,-7), BackgroundColor3=Color3.new(1,1,1)}, 0.18)
        else
            Tween(Track, {BackgroundColor3=T.Toggle}, 0.18)
            Tween(Knob, {Position=UDim2.new(0,2,0.5,-7), BackgroundColor3=Color3.fromRGB(160,160,180)}, 0.18)
        end
        if not silent and cb then cb(s) end
    end
    Set(state, true)

    local HitBtn = New("TextButton", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Row,
    })
    HitBtn.MouseButton1Click:Connect(function() Set(not state) end)
    HitBtn.MouseEnter:Connect(function() Tween(Row, {BackgroundColor3=Color3.fromRGB(32,32,44)}, 0.1) end)
    HitBtn.MouseLeave:Connect(function() Tween(Row, {BackgroundColor3=T.Row}, 0.1) end)

    return {Set=Set, Get=function() return state end}
end

-- Slider
local function Slider(page, label, min, max, default, suffix, cb)
    local Row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = page,
    })
    Corner(7, Row)

    New("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 18),
        Position = UDim2.new(0, 10, 0, 7),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = Row,
    })

    local ValL = New("TextLabel", {
        Size = UDim2.new(0.4, -10, 0, 18),
        Position = UDim2.new(0.6, 0, 0, 7),
        BackgroundTransparency = 1,
        Text = tostring(default)..(suffix or ""),
        TextColor3 = T.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = Row,
    })

    local Track = New("Frame", {
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.new(0, 10, 0, 36),
        BackgroundColor3 = T.Toggle,
        BorderSizePixel = 0,
        Parent = Row,
    })
    Corner(2, Track)

    local Fill = New("Frame", {
        Size = UDim2.new(0,0,1,0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Parent = Track,
    })
    Corner(2, Fill)

    local KnobS = New("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0,0,0.5,0),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        Parent = Track,
    })
    Corner(5, KnobS)

    local value = default
    local function SetVal(v, silent)
        v = math.clamp(math.round(v), min, max)
        value = v
        local pct = (v-min)/(max-min)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        KnobS.Position = UDim2.new(pct, 0, 0.5, 0)
        ValL.Text = tostring(v)..(suffix or "")
        if not silent and cb then cb(v) end
    end
    SetVal(default, true)

    local sliding = false
    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local abs = Track.AbsolutePosition
            local sz = Track.AbsoluteSize
            SetVal(min + (max-min) * math.clamp((inp.Position.X - abs.X)/sz.X, 0, 1))
        end
    end)
    return {SetVal=SetVal, GetVal=function() return value end}
end

-- Button
local function Button(page, label, cb)
    local Btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Text = label,
        TextColor3 = T.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = page,
    })
    Corner(7, Btn)
    Stroke(T.Border, 1, Btn)
    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3=T.Panel}, 0.1) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3=T.Row}, 0.1) end)
    Btn.MouseButton1Click:Connect(function()
        Tween(Btn, {BackgroundColor3=T.AccentDim}, 0.07)
        task.delay(0.12, function() Tween(Btn, {BackgroundColor3=T.Row}, 0.1) end)
        if cb then cb() end
    end)
    return Btn
end

-- Accent Button
local function AccentButton(page, label, cb)
    local Btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Text = label,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = page,
    })
    Corner(7, Btn)
    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundTransparency=0.15}, 0.1) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundTransparency=0}, 0.1) end)
    Btn.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)
    return Btn
end

-- Dropdown
local function Dropdown(page, label, opts, default, cb)
    local Container = New("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 10,
        Parent = page,
    })
    Corner(7, Container)

    New("TextLabel", {
        Size = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 10,
        Parent = Container,
    })

    local SelBtn = New("TextButton", {
        Size = UDim2.new(0, 118, 0, 24),
        Position = UDim2.new(1, -126, 0.5, -12),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        Text = default or opts[1],
        TextColor3 = T.Text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        ZIndex = 10,
        Parent = Container,
    })
    Corner(5, SelBtn)
    Stroke(T.Border, 1, SelBtn)

    -- arrow
    New("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -16, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = T.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        ZIndex = 10,
        Parent = SelBtn,
    })

    local Drop = New("Frame", {
        Size = UDim2.new(0, 118, 0, #opts * 28 + 6),
        Position = UDim2.new(1, -126, 1, 4),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
        Parent = Container,
    })
    Corner(6, Drop)
    Stroke(T.Border, 1, Drop)
    New("UIListLayout", {Padding=UDim.new(0,2), Parent=Drop})
    New("UIPadding", {PaddingTop=UDim.new(0,3), PaddingLeft=UDim.new(0,3), PaddingRight=UDim.new(0,3), Parent=Drop})

    for _, opt in ipairs(opts) do
        local OBtn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = T.Row,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = opt,
            TextColor3 = T.Text,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            ZIndex = 20,
            Parent = Drop,
        })
        Corner(4, OBtn)
        OBtn.MouseEnter:Connect(function() Tween(OBtn, {BackgroundTransparency=0.4}, 0.1) end)
        OBtn.MouseLeave:Connect(function() Tween(OBtn, {BackgroundTransparency=1}, 0.1) end)
        OBtn.MouseButton1Click:Connect(function()
            SelBtn.Text = opt
            Drop.Visible = false
            if cb then cb(opt) end
        end)
    end

    SelBtn.MouseButton1Click:Connect(function() Drop.Visible = not Drop.Visible end)
    return Container
end

-- ============================================================
-- CREATE TABS
-- ============================================================
local TabAimbot  = MakeTab("Aimbot",  1)
local TabAuto    = MakeTab("Auto",    2)
local TabVisuals = MakeTab("Visuals", 3)
local TabSkins   = MakeTab("Skins",   4)
local TabMisc    = MakeTab("Misc",    5)

-- activate first
TabAimbot.Btn.MouseButton1Click:Fire()

-- ============================================================
-- AIMBOT TAB
-- ============================================================
do
    local p = TabAimbot.Page
    Section(p, "Targeting")
    Toggle(p, "Aimbot", nil, false, function(v) Cfg.Aim = v end)
    Toggle(p, "Silent Aim", nil, false, function(v) Cfg.SilentAim = v end)
    Toggle(p, "Team Check", nil, true, function(v) Cfg.TeamCheck = v end)
    Toggle(p, "Visibility Check", nil, true, function(v) Cfg.VisCheck = v end)
    Toggle(p, "Prediction", nil, true, function(v) Cfg.AimPred = v end)
    Section(p, "Settings")
    Slider(p, "FOV", 10, 500, 120, nil, function(v) Cfg.AimFOV = v end)
    Slider(p, "Smoothing", 1, 50, 18, nil, function(v) Cfg.AimSmooth = v/100 end)
    Slider(p, "Prediction", 1, 20, 7, nil, function(v) Cfg.AimPredStr = v/100 end)
    Section(p, "Target")
    Dropdown(p, "Aim Part", {"Head","Neck","Torso","HumanoidRootPart"}, "Head", function(v) Cfg.AimPart = v end)
end

-- ============================================================
-- AUTO TAB
-- ============================================================
do
    local p = TabAuto.Page
    Section(p, "Automation")
    Toggle(p, "Auto Shoot", nil, false, function(v) Cfg.AutoShoot = v end)
    Toggle(p, "Auto Reload", nil, false, function(v) Cfg.AutoReload = v end)
    Toggle(p, "Triggerbot", nil, false, function(v) Cfg.TriggerBot = v end)
    Section(p, "Timing")
    Slider(p, "Trigger Delay", 0, 20, 5, "ms", function(v) Cfg.TriggerDelay = v/100 end)
end

-- ============================================================
-- VISUALS TAB
-- ============================================================
do
    local p = TabVisuals.Page
    Section(p, "ESP")
    Toggle(p, "Enable ESP", nil, false, function(v) Cfg.ESP = v end)
    Toggle(p, "Boxes", nil, true, function(v) Cfg.ESPBox = v end)
    Toggle(p, "Names", nil, true, function(v) Cfg.ESPName = v end)
    Toggle(p, "Health Bars", nil, true, function(v) Cfg.ESPHealth = v end)
    Toggle(p, "Distance", nil, true, function(v) Cfg.ESPDist = v end)
    Toggle(p, "Tracers", nil, false, function(v) Cfg.ESPTracer = v end)
    Toggle(p, "Team Check", nil, true, function(v) Cfg.ESPTeamCheck = v end)
    Slider(p, "Max Distance", 100, 2000, 1000, "m", function(v) Cfg.ESPMaxDist = v end)
    Section(p, "Camera")
    Toggle(p, "FOV Changer", nil, false, function(v)
        Cfg.FOVChanger = v
        Camera.FieldOfView = v and Cfg.FOVVal or 70
    end)
    Slider(p, "FOV Value", 50, 120, 90, nil, function(v)
        Cfg.FOVVal = v
        if Cfg.FOVChanger then Camera.FieldOfView = v end
    end)
    Toggle(p, "Fullbright", nil, false, function(v)
        Cfg.Fullbright = v
        if v then
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end)
    Section(p, "Crosshair")
    Toggle(p, "Custom Crosshair", nil, false, function(v) Cfg.Crosshair = v end)
    Slider(p, "Size", 4, 30, 10, nil, function(v) Cfg.CrossSize = v end)
    Slider(p, "Thickness", 1, 5, 2, nil, function(v) Cfg.CrossThick = v end)
end

-- ============================================================
-- SKINS TAB
-- ============================================================
do
    local p = TabSkins.Page
    Section(p, "Skin Changer")
    Toggle(p, "Enable Skin Changer", nil, false, function(v) Cfg.SkinChanger = v end)
    Section(p, "Select Skin")
    local skinNames = {"Default","Obsidian","Gold","Arctic","Neon","Shadow","Crimson"}
    Dropdown(p, "Weapon Skin", skinNames, "Default", function(v)
        for i,s in ipairs(skinNames) do
            if s == v then Cfg.SkinID = i break end
        end
    end)
    Section(p, "Actions")
    Button(p, "Apply Skin", function()
        -- placeholder
    end)
    Button(p, "Reset to Default", function()
        Cfg.SkinID = 1
    end)
end

-- ============================================================
-- MISC TAB
-- ============================================================
do
    local p = TabMisc.Page
    Section(p, "Session and safety")
    Toggle(p, "Anti-AFK", "Blocks the idle kick", true, function(v) Cfg.AntiAFK = v end)
    Section(p, "Interface")
    Toggle(p, "Status HUD", nil, true, function(v) Cfg.StatusHUD = v end)
    Toggle(p, "Save settings", nil, true, function(v) Cfg.SaveSettings = v end)
    Section(p, "Movement")
    Toggle(p, "Speed Hack", nil, false, function(v)
        Cfg.SpeedHack = v
        Humanoid.WalkSpeed = v and Cfg.SpeedVal or 16
    end)
    Slider(p, "Speed", 16, 200, 24, nil, function(v)
        Cfg.SpeedVal = v
        if Cfg.SpeedHack then Humanoid.WalkSpeed = v end
    end)
    Toggle(p, "Bunny Hop", nil, false, function(v) Cfg.BHop = v end)
    Toggle(p, "Noclip", nil, false, function(v) Cfg.Noclip = v end)
    Section(p, "Actions")
    Button(p, "Rejoin server", function()
        TeleportService:Teleport(game.PlaceId)
    end)
    AccentButton(p, "Unload SOLO scripts", function()
        Tween(Win, {Size=UDim2.new(0,540,0,0)}, 0.2)
        task.delay(0.25, function() ScreenGui:Destroy() end)
    end)
end

-- ============================================================
-- STATUS HUD (bottom left, like Solo)
-- ============================================================
local HUDFrame = New("Frame", {
    Size = UDim2.new(0, 160, 0, 60),
    Position = UDim2.new(0, 10, 1, -70),
    BackgroundColor3 = T.BG,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Parent = ScreenGui,
})
Corner(8, HUDFrame)
Stroke(T.Border, 1, HUDFrame)

local HUDTitle = New("TextLabel", {
    Size = UDim2.new(1, -10, 0, 16),
    Position = UDim2.new(0, 8, 0, 6),
    BackgroundTransparency = 1,
    Text = "SOLO Hub",
    TextColor3 = T.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = HUDFrame,
})

local HUDAim = New("TextLabel", {
    Size = UDim2.new(0.5, -4, 0, 14),
    Position = UDim2.new(0, 8, 0, 24),
    BackgroundTransparency = 1,
    Text = "Aim: OFF",
    TextColor3 = T.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = HUDFrame,
})

local HUDESP = New("TextLabel", {
    Size = UDim2.new(0.5, -4, 0, 14),
    Position = UDim2.new(0.5, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = "ESP: OFF",
    TextColor3 = T.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = HUDFrame,
})

local HUDFps = New("TextLabel", {
    Size = UDim2.new(1, -10, 0, 14),
    Position = UDim2.new(0, 8, 0, 40),
    BackgroundTransparency = 1,
    Text = "FPS: --",
    TextColor3 = T.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = HUDFrame,
})

-- ============================================================
-- FOV CIRCLE
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(80, 160, 255)
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 80
FOVCircle.Filled = false

-- ============================================================
-- CROSSHAIR
-- ============================================================
local CLines = {}
for i = 1, 4 do
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 2
    l.Color = Color3.fromRGB(80, 160, 255)
    CLines[i] = l
end

-- ============================================================
-- ESP POOL
-- ============================================================
local ESPPool = {}

local function GetESPObj(pl)
    if not ESPPool[pl] then
        local o = {
            Box=Drawing.new("Square"),
            Name=Drawing.new("Text"),
            Hbar=Drawing.new("Square"),
            HbarFill=Drawing.new("Square"),
            Dist=Drawing.new("Text"),
            Tracer=Drawing.new("Line"),
        }
        o.Box.Thickness=1; o.Box.Filled=false
        o.Name.Size=13; o.Name.Center=true; o.Name.Outline=true; o.Name.Font=2
        o.Hbar.Filled=true; o.Hbar.Color=Color3.fromRGB(40,40,40)
        o.HbarFill.Filled=true
        o.Dist.Size=11; o.Dist.Center=true; o.Dist.Outline=true; o.Dist.Font=2
        o.Tracer.Thickness=1
        ESPPool[pl] = o
    end
    return ESPPool[pl]
end

local function HideESP(pl)
    local o = ESPPool[pl]
    if not o then return end
    for _,v in pairs(o) do v.Visible=false end
end

Players.PlayerRemoving:Connect(function(pl)
    local o = ESPPool[pl]
    if o then
        for _,v in pairs(o) do v:Remove() end
        ESPPool[pl] = nil
    end
end)

-- ============================================================
-- AIMBOT HELPERS
-- ============================================================
local function IsEnemy(pl)
    if Cfg.TeamCheck and pl.Team == Player.Team then return false end
    return true
end
local function IsAlive(pl)
    local c = pl.Character
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end
local function RayVisible(pos)
    if not Cfg.VisCheck then return true end
    local ray = Ray.new(Camera.CFrame.Position, (pos-Camera.CFrame.Position).Unit * 2000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Character}, false, true)
    return hit == nil
end
local function GetTarget()
    local best, bestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl==Player or not IsEnemy(pl) or not IsAlive(pl) then continue end
        local c = pl.Character
        local part = c:FindFirstChild(Cfg.AimPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local pos = part.Position
        if Cfg.AimPred then pos = pos + part.Velocity * Cfg.AimPredStr end
        local screen, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then continue end
        local d2d = (Vector2.new(screen.X, screen.Y) - center).Magnitude
        if d2d < Cfg.AimFOV and d2d < bestDist and RayVisible(pos) then
            best = {Pl=pl, Part=part, Pos=pos}
            bestDist = d2d
        end
    end
    return best
end

-- ============================================================
-- NOCLIP
-- ============================================================
RunService.Stepped:Connect(function()
    if Cfg.Noclip and Character then
        for _,p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- ============================================================
-- BHOP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if Cfg.BHop then Humanoid.Jump = true end
end)

-- ============================================================
-- ANTI AFK
-- ============================================================
local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    if Cfg.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- ============================================================
-- TOGGLE UI: RightShift
-- ============================================================
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        Win.Visible = not Win.Visible
    end
end)

-- ============================================================
-- ENEMY COUNT TRACKER
-- ============================================================
local function GetEnemyCount()
    local count = 0
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= Player and IsAlive(pl) and IsEnemy(pl) then count += 1 end
    end
    return count
end

-- ============================================================
-- RENDER LOOP
-- ============================================================
local fpsTimer, fpsTick, fpsCount = 0, tick(), 0

RunService.RenderStepped:Connect(function(dt)
    -- FPS calc
    fpsCount += 1
    fpsTimer += dt
    if fpsTimer >= 1 then
        HUDFps.Text = "FPS: "..fpsCount
        fpsCount = 0; fpsTimer = 0
    end

    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- HUD update
    if Cfg.StatusHUD then
        HUDFrame.Visible = true
        HUDAim.Text = "Aim: "..(Cfg.Aim and "ON" or "OFF")
        HUDAim.TextColor3 = Cfg.Aim and T.Accent or T.TextDim
        HUDESP.Text = "ESP: "..(Cfg.ESP and "ON" or "OFF")
        HUDESP.TextColor3 = Cfg.ESP and T.Accent or T.TextDim
    else
        HUDFrame.Visible = false
    end

    -- Enemy counter
    EnemyCountLabel.Text = GetEnemyCount().." enemies"

    -- FOV circle
    FOVCircle.Visible = Cfg.Aim
    FOVCircle.Radius = Cfg.AimFOV
    FOVCircle.Position = center

    -- Crosshair
    if Cfg.Crosshair then
        local s, t, c = Cfg.CrossSize, Cfg.CrossThick, Cfg.CrossColor
        CLines[1].From=Vector2.new(center.X, center.Y-s); CLines[1].To=Vector2.new(center.X, center.Y-3)
        CLines[2].From=Vector2.new(center.X, center.Y+3); CLines[2].To=Vector2.new(center.X, center.Y+s)
        CLines[3].From=Vector2.new(center.X-s, center.Y); CLines[3].To=Vector2.new(center.X-3, center.Y)
        CLines[4].From=Vector2.new(center.X+3, center.Y); CLines[4].To=Vector2.new(center.X+s, center.Y)
        for _,l in ipairs(CLines) do l.Visible=true; l.Thickness=t; l.Color=c end
    else
        for _,l in ipairs(CLines) do l.Visible=false end
    end

    -- Aimbot
    if Cfg.Aim then
        local tgt = GetTarget()
        if tgt and not Cfg.SilentAim then
            local cur = Camera.CFrame.LookVector
            local dir = (tgt.Pos - Camera.CFrame.Position).Unit
            local newDir = cur:Lerp(dir, Cfg.AimSmooth)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newDir)
        end
    end

    -- ESP
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl==Player then continue end
        if Cfg.ESPTeamCheck and pl.Team==Player.Team then HideESP(pl) continue end
        if not Cfg.ESP or not IsAlive(pl) then HideESP(pl) continue end

        local c = pl.Character
        local root = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChild("Humanoid")
        local head = c:FindFirstChild("Head")
        if not root or not hum or not head then HideESP(pl) continue end

        local dist = (root.Position - RootPart.Position).Magnitude
        if dist > Cfg.ESPMaxDist then HideESP(pl) continue end

        local rs, onScreen = Camera:WorldToViewportPoint(root.Position)
        local hs = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.7,0))
        if not onScreen then HideESP(pl) continue end

        local o = GetESPObj(pl)
        local h = math.abs(hs.Y - rs.Y) * 2.2
        local w = h * 0.5
        local x = rs.X - w/2
        local y = hs.Y - 2

        o.Box.Visible = Cfg.ESPBox
        o.Box.Color = Cfg.ESPBoxColor
        o.Box.Position = Vector2.new(x, y)
        o.Box.Size = Vector2.new(w, h)

        o.Name.Visible = Cfg.ESPName
        o.Name.Text = pl.Name
        o.Name.Color = Cfg.ESPNameColor
        o.Name.Position = Vector2.new(rs.X, y-16)

        local hp = hum.Health / hum.MaxHealth
        o.Hbar.Visible = Cfg.ESPHealth
        o.Hbar.Position = Vector2.new(x-7, y)
        o.Hbar.Size = Vector2.new(4, h)
        o.HbarFill.Visible = Cfg.ESPHealth
        o.HbarFill.Position = Vector2.new(x-7, y + h*(1-hp))
        o.HbarFill.Size = Vector2.new(4, h*hp)
        o.HbarFill.Color = Color3.fromRGB(math.floor(255*(1-hp)), math.floor(255*hp), 60)

        o.Dist.Visible = Cfg.ESPDist
        o.Dist.Text = math.floor(dist).."m"
        o.Dist.Color = Color3.fromRGB(180,180,180)
        o.Dist.Position = Vector2.new(rs.X, y+h+2)

        o.Tracer.Visible = Cfg.ESPTracer
        o.Tracer.From = Vector2.new(center.X, Camera.ViewportSize.Y)
        o.Tracer.To = Vector2.new(rs.X, rs.Y)
        o.Tracer.Color = Cfg.ESPTracerColor
    end
end)

-- ============================================================
-- CHARACTER RESPAWN
-- ============================================================
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    if Cfg.SpeedHack then Humanoid.WalkSpeed = Cfg.SpeedVal end
end)

print("[SOLO Hub] Loaded — Toggle: RightShift")
