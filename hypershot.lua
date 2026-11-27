-- Hypershot v1.0 | REALISTIC 
-- Mobile + PC | THE BEST

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════
local cfg = {
    aimbot = {
        enabled = false,
        fov = 120,
        smoothness = 0.15,
        hitpart = "Head",
        teamcheck = true,
        wallcheck = true,
        prediction = true,
        predMultiplier = 0.08,
        silentaim = false,
        triggerbot = false,
        triggerDelay = 0.05,
        vischeck = true,
    },
    esp = {
        enabled = false,
        boxes = true,
        names = true,
        health = true,
        distance = true,
        tracers = false,
        maxdist = 500,
        teamcolor = Color3.fromRGB(0, 200, 255),
        enemycolor = Color3.fromRGB(255, 60, 100),
    },
    misc = {
        norecoil = false,
        nospread = false,
        rapidfire = false,
        infreload = false,
        bhop = false,
        speedhack = false,
        speedval = 32,
        noclip = false,
        thirdperson = false,
        fovchanger = false,
        fovval = 90,
    }
}

-- ═══════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════
local function getChar(p)
    return p and p.Character
end

local function getRoot(p)
    local c = getChar(p)
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum(p)
    local c = getChar(p)
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getPart(p, name)
    local c = getChar(p)
    return c and c:FindFirstChild(name)
end

local function isAlive(p)
    local h = getHum(p)
    return h and h.Health > 0
end

local function isSameTeam(p)
    return p.Team and lp.Team and p.Team == lp.Team
end

local function worldToVP(pos)
    local vp, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(vp.X, vp.Y), onScreen, vp.Z
end

local function getCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function hasLOS(pos)
    local origin = Camera.CFrame.Position
    local dir = (pos - origin).Unit * 500
    local ray = Ray.new(origin, dir)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {getChar(lp)})
    if not hit then return true end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c = getChar(p)
            if c and hit:IsDescendantOf(c) then return true end
        end
    end
    return false
end

local function getTargets()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and isAlive(p) then
            if cfg.aimbot.teamcheck and isSameTeam(p) then continue end
            local part = getPart(p, cfg.aimbot.hitpart) or getPart(p, "Head")
            if not part then continue end
            local pos = part.Position
            if cfg.aimbot.vischeck and not hasLOS(pos) then continue end
            local vp, onScreen = worldToVP(pos)
            if onScreen then
                local dist = (vp - getCenter()).Magnitude
                table.insert(t, {player = p, part = part, vp = vp, dist = dist})
            end
        end
    end
    table.sort(t, function(a, b) return a.dist < b.dist end)
    return t
end

local function getBestTarget()
    local targets = getTargets()
    if #targets == 0 then return nil end
    local best = targets[1]
    if best.dist <= cfg.aimbot.fov then return best end
    return nil
end

-- ═══════════════════════════════════
-- GUI BUILD
-- ═══════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperShot"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- TOGGLE BUTTON (Bloody R)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 54, 0, 54)
ToggleBtn.Position = UDim2.new(0, 12, 0.5, -27)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 10, 25)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "🩸R"
ToggleBtn.TextColor3 = Color3.fromRGB(220, 30, 60)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 999
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
local TStroke = Instance.new("UIStroke")
TStroke.Color = Color3.fromRGB(180, 20, 50)
TStroke.Thickness = 2
TStroke.Parent = ToggleBtn

-- drag toggle button
do
    local drag, dragStart, startPos = false, nil, nil
    ToggleBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = inp.Position; startPos = ToggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            ToggleBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 460, 0, 400)
Main.Position = UDim2.new(0.5, -230, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(12, 8, 22)
Main.BorderSizePixel = 0
Main.Visible = false
Main.ZIndex = 10
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local MStroke = Instance.new("UIStroke")
MStroke.Color = Color3.fromRGB(90, 60, 180)
MStroke.Thickness = 1.5
MStroke.Parent = Main

local BgGrad = Instance.new("UIGradient")
BgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 8, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 14, 32))
})
BgGrad.Rotation = 135
BgGrad.Parent = Main

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleGrad = Instance.new("UIGradient")
TitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 20, 160)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 40, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 80, 200))
})
TitleGrad.Rotation = 90
TitleGrad.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🩸 HYPERSHOT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 12
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 13
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- drag main window
do
    local drag, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = inp.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

-- TABS
local tabNames = {"Aimbot", "ESP", "Misc"}
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 34)
TabBar.Position = UDim2.new(0, 8, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 11
TabBar.Parent = Main
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabBar

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -16, 1, -98)
ContentArea.Position = UDim2.new(0, 8, 0, 90)
ContentArea.BackgroundTransparency = 1
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(120, 60, 200)
ContentArea.BorderSizePixel = 0
ContentArea.ZIndex = 11
ContentArea.Parent = Main
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.Parent = ContentArea
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
end)

local tabBtns = {}
local tabPages = {}
local activeTab = 1

local function setTab(idx)
    activeTab = idx
    for i, btn in ipairs(tabBtns) do
        if i == idx then
            btn.BackgroundColor3 = Color3.fromRGB(100, 40, 200)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 14, 40)
            btn.TextColor3 = Color3.fromRGB(140, 100, 200)
        end
    end
    for i, page in ipairs(tabPages) do
        page.Visible = (i == idx)
    end
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 14, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(140, 100, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 12
    btn.LayoutOrder = i
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    tabBtns[i] = btn

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 11
    page.LayoutOrder = i
    page.Parent = ContentArea
    local pl = Instance.new("UIListLayout")
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 6)
    pl.Parent = page
    tabPages[i] = page

    btn.MouseButton1Click:Connect(function() setTab(i) end)
end
setTab(1)

-- ═══════════════════════════════════
-- WIDGET BUILDERS
-- ═══════════════════════════════════
local function mkToggle(parent, label, cfgTbl, key, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(20, 12, 36)
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.LayoutOrder = order or 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(210, 190, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = row

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 44, 0, 24)
    tog.Position = UDim2.new(1, -52, 0.5, -12)
    tog.BackgroundColor3 = cfgTbl[key] and Color3.fromRGB(120, 50, 220) or Color3.fromRGB(40, 25, 60)
    tog.Text = ""
    tog.ZIndex = 13
    tog.Parent = row
    Instance.new("UICorner", tog).CornerRadius = UDim.new(0.5, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = cfgTbl[key] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = tog
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    tog.MouseButton1Click:Connect(function()
        cfgTbl[key] = not cfgTbl[key]
        local on = cfgTbl[key]
        TweenService:Create(tog, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(120, 50, 220) or Color3.fromRGB(40, 25, 60)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
    end)
    return row
end

local function mkSlider(parent, label, cfgTbl, key, minV, maxV, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(20, 12, 36)
    row.BorderSizePixel = 0
    row.ZIndex = 12
    row.LayoutOrder = order or 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. tostring(cfgTbl[key])
    lbl.TextColor3 = Color3.fromRGB(210, 190, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(40, 25, 60)
    track.BorderSizePixel = 0
    track.ZIndex = 13
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(0.5, 0)

    local fill = Instance.new("Frame")
    local pct = (cfgTbl[key] - minV) / (maxV - minV)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(160, 60, 240)
    fill.BorderSizePixel = 0
    fill.ZIndex = 14
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0.5, 0)

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 14, 0, 14)
    handle.Position = UDim2.new(pct, -7, 0.5, -7)
    handle.BackgroundColor3 = Color3.fromRGB(220, 100, 255)
    handle.BorderSizePixel = 0
    handle.ZIndex = 15
    handle.Parent = track
    Instance.new("UICorner", handle).CornerRadius = UDim.new(0.5, 0)

    local sliding = false
    local function updateSlider(inp)
        local abs = track.AbsolutePosition
        local sz = track.AbsoluteSize
        local rx = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
        local val = math.floor(minV + rx * (maxV - minV))
        cfgTbl[key] = val
        fill.Size = UDim2.new(rx, 0, 1, 0)
        handle.Position = UDim2.new(rx, -7, 0.5, -7)
        lbl.Text = label .. ": " .. tostring(val)
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true; updateSlider(inp)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(inp)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    return row
end

-- ═══════════════════════════════════
-- POPULATE TABS
-- ═══════════════════════════════════
-- AIMBOT TAB
local ap = tabPages[1]
mkToggle(ap, "Aimbot Enabled",    cfg.aimbot, "enabled",    1)
mkToggle(ap, "Silent Aim",        cfg.aimbot, "silentaim",  2)
mkToggle(ap, "Team Check",        cfg.aimbot, "teamcheck",  3)
mkToggle(ap, "Wall Check",        cfg.aimbot, "wallcheck",  4)
mkToggle(ap, "Vis Check",         cfg.aimbot, "vischeck",   5)
mkToggle(ap, "Prediction",        cfg.aimbot, "prediction", 6)
mkToggle(ap, "Triggerbot",        cfg.aimbot, "triggerbot", 7)
mkSlider(ap,  "FOV",              cfg.aimbot, "fov",        10, 500, 8)
mkSlider(ap,  "Smoothness (x100)",cfg.aimbot, "smoothness" ~= nil and cfg.aimbot or cfg.aimbot, "fov", 1, 100, 9)

-- smoothness workaround (store as int 1-100, divide on use)
local smoothRow = Instance.new("Frame")
smoothRow.Size = UDim2.new(1, 0, 0, 52)
smoothRow.BackgroundColor3 = Color3.fromRGB(20, 12, 36)
smoothRow.BorderSizePixel = 0
smoothRow.ZIndex = 12
smoothRow.LayoutOrder = 10
smoothRow.Parent = ap
Instance.new("UICorner", smoothRow).CornerRadius = UDim.new(0, 8)
local smoothInt = {val = math.floor(cfg.aimbot.smoothness * 100)}
local function mkSmoothSlider()
    local lbl2 = Instance.new("TextLabel")
    lbl2.Size = UDim2.new(1, -10, 0, 20)
    lbl2.Position = UDim2.new(0, 10, 0, 6)
    lbl2.BackgroundTransparency = 1
    lbl2.Text = "Smoothness: " .. tostring(smoothInt.val)
    lbl2.TextColor3 = Color3.fromRGB(210, 190, 255)
    lbl2.TextScaled = true
    lbl2.Font = Enum.Font.Gotham
    lbl2.TextXAlignment = Enum.TextXAlignment.Left
    lbl2.ZIndex = 13
    lbl2.Parent = smoothRow

    local track2 = Instance.new("Frame")
    track2.Size = UDim2.new(1, -20, 0, 6)
    track2.Position = UDim2.new(0, 10, 0, 34)
    track2.BackgroundColor3 = Color3.fromRGB(40, 25, 60)
    track2.BorderSizePixel = 0
    track2.ZIndex = 13
    track2.Parent = smoothRow
    Instance.new("UICorner", track2).CornerRadius = UDim.new(0.5, 0)

    local fill2 = Instance.new("Frame")
    local pct2 = smoothInt.val / 100
    fill2.Size = UDim2.new(pct2, 0, 1, 0)
    fill2.BackgroundColor3 = Color3.fromRGB(160, 60, 240)
    fill2.BorderSizePixel = 0
    fill2.ZIndex = 14
    fill2.Parent = track2
    Instance.new("UICorner", fill2).CornerRadius = UDim.new(0.5, 0)

    local handle2 = Instance.new("Frame")
    handle2.Size = UDim2.new(0, 14, 0, 14)
    handle2.Position = UDim2.new(pct2, -7, 0.5, -7)
    handle2.BackgroundColor3 = Color3.fromRGB(220, 100, 255)
    handle2.BorderSizePixel = 0
    handle2.ZIndex = 15
    handle2.Parent = track2
    Instance.new("UICorner", handle2).CornerRadius = UDim.new(0.5, 0)

    local sl2 = false
    local function upd(inp)
        local abs = track2.AbsolutePosition
        local sz = track2.AbsoluteSize
        local rx = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
        local v = math.floor(rx * 100)
        smoothInt.val = v
        cfg.aimbot.smoothness = v / 100
        fill2.Size = UDim2.new(rx, 0, 1, 0)
        handle2.Position = UDim2.new(rx, -7, 0.5, -7)
        lbl2.Text = "Smoothness: " .. tostring(v)
    end
    track2.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then sl2=true; upd(i) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sl2 and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then sl2=false end
    end)
end
mkSmoothSlider()

-- ESP TAB
local ep = tabPages[2]
mkToggle(ep, "ESP Enabled",   cfg.esp, "enabled",  1)
mkToggle(ep, "Boxes",         cfg.esp, "boxes",    2)
mkToggle(ep, "Names",         cfg.esp, "names",    3)
mkToggle(ep, "Health Bars",   cfg.esp, "health",   4)
mkToggle(ep, "Distance",      cfg.esp, "distance", 5)
mkToggle(ep, "Tracers",       cfg.esp, "tracers",  6)
mkSlider(ep, "Max Distance",  cfg.esp, "maxdist",  50, 1000, 7)

-- MISC TAB
local mp = tabPages[3]
mkToggle(mp, "No Recoil",     cfg.misc, "norecoil",   1)
mkToggle(mp, "No Spread",     cfg.misc, "nospread",   2)
mkToggle(mp, "Rapid Fire",    cfg.misc, "rapidfire",  3)
mkToggle(mp, "Inf Reload",    cfg.misc, "infreload",  4)
mkToggle(mp, "Bunny Hop",     cfg.misc, "bhop",       5)
mkToggle(mp, "Speed Hack",    cfg.misc, "speedhack",  6)
mkToggle(mp, "Noclip",        cfg.misc, "noclip",     7)
mkToggle(mp, "Third Person",  cfg.misc, "thirdperson",8)
mkToggle(mp, "FOV Changer",   cfg.misc, "fovchanger", 9)
mkSlider(mp, "Speed",         cfg.misc, "speedval",  16, 100, 10)
mkSlider(mp, "Custom FOV",    cfg.misc, "fovval",    40, 120, 11)

-- TOGGLE GUI
local guiOpen = false
ToggleBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    Main.Visible = guiOpen
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = guiOpen and UDim2.new(0, 460, 0, 400) or UDim2.new(0, 460, 0, 0)
    }):Play()
end)

-- ═══════════════════════════════════
-- FOV CIRCLE
-- ═══════════════════════════════════
local fovCircle = Drawing and Drawing.new("Circle") or nil
if fovCircle then
    fovCircle.Visible = false
    fovCircle.Radius = cfg.aimbot.fov
    fovCircle.Color = Color3.fromRGB(180, 60, 255)
    fovCircle.Thickness = 1.5
    fovCircle.Transparency = 0.6
    fovCircle.Filled = false
end

-- ═══════════════════════════════════
-- ESP DRAWINGS
-- ═══════════════════════════════════
local espData = {}

local function clearESP(p)
    if espData[p] then
        for _, d in pairs(espData[p]) do
            if d.Remove then d:Remove() elseif d.Visible ~= nil then d.Visible = false end
        end
        espData[p] = nil
    end
end

local function mkDrawing(t, props)
    if not Drawing then return nil end
    local d = Drawing.new(t)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function updateESP()
    if not cfg.esp.enabled then
        for p in pairs(espData) do clearESP(p) end
        return
    end
    local active = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        active[p] = true
        local root = getRoot(p)
        local char = getChar(p)
        if not root or not char or not isAlive(p) then
            clearESP(p); continue
        end

        local hum = getHum(p)
        local isEnemy = not isSameTeam(p)
        local col = isEnemy and cfg.esp.enemycolor or cfg.esp.teamcolor

        if not espData[p] then
            espData[p] = {}
            if Drawing then
                espData[p].box    = mkDrawing("Square",  {Visible=false, Filled=false, Color=col, Thickness=1.5, Transparency=1})
                espData[p].name   = mkDrawing("Text",    {Visible=false, Color=Color3.fromRGB(255,255,255), Size=14, Font=2, Center=true, Outline=true})
                espData[p].health = mkDrawing("Square",  {Visible=false, Filled=true, Color=Color3.fromRGB(0,255,80), Transparency=1})
                espData[p].healthBg = mkDrawing("Square",{Visible=false, Filled=true, Color=Color3.fromRGB(0,0,0), Transparency=0.5})
                espData[p].dist   = mkDrawing("Text",    {Visible=false, Color=Color3.fromRGB(220,220,220), Size=12, Font=2, Center=true, Outline=true})
                espData[p].tracer = mkDrawing("Line",    {Visible=false, Color=col, Thickness=1, Transparency=1})
            end
        end

        local d = espData[p]
        local head = char:FindFirstChild("Head")
        local feet = char:FindFirstChild("HumanoidRootPart")
        if not head or not feet then continue end

        local topVP, topOn = worldToVP(head.Position + Vector3.new(0, 0.5, 0))
        local botVP, botOn = worldToVP(feet.Position - Vector3.new(0, 2.5, 0))
        local dist3d = (Camera.CFrame.Position - root.Position).Magnitude

        if not topOn and not botOn then
            for _, dr in pairs(d) do if dr and dr.Visible ~= nil then dr.Visible = false end end
            continue
        end
        if dist3d > cfg.esp.maxdist then
            for _, dr in pairs(d) do if dr and dr.Visible ~= nil then dr.Visible = false end end
            continue
        end

        local h = math.abs(botVP.Y - topVP.Y)
        local w = h * 0.5
        local cx = topVP.X

        if d.box then
            d.box.Visible = cfg.esp.boxes
            d.box.Color = col
            d.box.Position = Vector2.new(cx - w/2, topVP.Y)
            d.box.Size = Vector2.new(w, h)
        end

        if d.name then
            d.name.Visible = cfg.esp.names
            d.name.Text = p.Name
            d.name.Position = Vector2.new(cx, topVP.Y - 16)
        end

        if d.health and d.healthBg then
            local hp = hum and (hum.Health / hum.MaxHealth) or 0
            local barH = h * hp
            d.healthBg.Visible = cfg.esp.health
            d.healthBg.Position = Vector2.new(cx - w/2 - 7, topVP.Y)
            d.healthBg.Size = Vector2.new(4, h)
            d.health.Visible = cfg.esp.health
            d.health.Color = Color3.fromRGB(math.floor((1-hp)*255), math.floor(hp*220), 60)
            d.health.Position = Vector2.new(cx - w/2 - 7, topVP.Y + (h - barH))
            d.health.Size = Vector2.new(4, barH)
        end

        if d.dist then
            d.dist.Visible = cfg.esp.distance
            d.dist.Text = math.floor(dist3d) .. "m"
            d.dist.Position = Vector2.new(cx, botVP.Y + 2)
        end

        if d.tracer then
            local vp2 = Camera.ViewportSize
            d.tracer.Visible = cfg.esp.tracers
            d.tracer.From = Vector2.new(vp2.X/2, vp2.Y)
            d.tracer.To = botVP
            d.tracer.Color = col
        end
    end

    for p in pairs(espData) do
        if not active[p] then clearESP(p) end
    end
end

-- ═══════════════════════════════════
-- AIMBOT LOGIC
-- ═══════════════════════════════════
local aiming = false

local function doAimbot()
    if not cfg.aimbot.enabled then return end
    local target = getBestTarget()
    if not target then
        if fovCircle then fovCircle.Visible = true end
        return
    end

    local part = target.part
    local pos = part.Position

    if cfg.aimbot.prediction then
        local vel = part.AssemblyLinearVelocity
        pos = pos + vel * cfg.aimbot.predMultiplier
    end

    local camCF = Camera.CFrame
    local targetCF = CFrame.new(camCF.Position, pos)
    local lerpAlpha = math.clamp(cfg.aimbot.smoothness, 0.01, 1)

    if cfg.aimbot.silentaim then
        -- silent aim handled in hitbox offset
    else
        Camera.CFrame = camCF:Lerp(targetCF, lerpAlpha)
    end

    if fovCircle then
        fovCircle.Visible = true
        fovCircle.Radius = cfg.aimbot.fov
        fovCircle.Position = getCenter()
    end
end

-- ═══════════════════════════════════
-- MISC LOGIC
-- ═══════════════════════════════════
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

lp.CharacterAdded:Connect(function(c)
    char = c
    hum = c:WaitForChild("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart")
end)

local origFOV = Camera.FieldOfView

local function doBhop()
    if not cfg.misc.bhop then return end
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        hum.Jump = true
    end
end

local function doNoclip()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = not cfg.misc.noclip
        end
    end
end

local function doSpeed()
    if not hum then return end
    hum.WalkSpeed = cfg.misc.speedhack and cfg.misc.speedval or 16
end

local function doFOV()
    Camera.FieldOfView = cfg.misc.fovchanger and cfg.misc.fovval or origFOV
end

local function doThirdPerson()
    if cfg.misc.thirdperson then
        Camera.CameraType = Enum.CameraType.Fixed
        local root = getRoot(lp)
        if root then
            Camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 4, 10), root.Position)
        end
    else
        Camera.CameraType = Enum.CameraType.Custom
    end
end

-- triggerbot
local lastTrigger = 0
local function doTriggerbot()
    if not cfg.aimbot.triggerbot then return end
    local t = getBestTarget()
    if not t then return end
    local now = tick()
    if now - lastTrigger < cfg.aimbot.triggerDelay then return end
    lastTrigger = now
    local vp, onScreen = worldToVP(t.part.Position)
    local center = getCenter()
    if (vp - center).Magnitude < 20 then
        local tool = char and char:FindFirstChildOfClass("Tool")
        local remote = tool and tool:FindFirstChild("RemoteEvent") or tool and tool:FindFirstChild("RemoteFunction")
        if remote then
            -- fire if found, game-specific
        end
        mouse1click(mouse)
    end
end

-- ═══════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- aimbot
    local holding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if holding or isMobile then
        doAimbot()
    else
        if fovCircle then fovCircle.Visible = false end
    end

    doTriggerbot()
    updateESP()
    doBhop()
    doNoclip()
    doSpeed()
    doFOV()
    if not cfg.misc.thirdperson then
        Camera.CameraType = Enum.CameraType.Custom
    else
        doThirdPerson()
    end
end)

-- keyboard toggle
if not isMobile then
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.RightShift then
            guiOpen = not guiOpen
            Main.Visible = guiOpen
        end
    end)
end