--============================================================
--  HYPERSPOT  |  REALISTIC SCRIPTS (MOBILE OPTIMIZED)
--  Blue & Pink UI · Built-in Console · Draggable · No Key
--============================================================
local Players = game:GetService("Players")
local Run     = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local WS      = game:GetService("Workspace")
local Light   = game:GetService("Lighting")
local Tween   = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LP      = Players.LocalPlayer
local Cam     = WS.CurrentCamera

-- Colors
local PINK = Color3.fromRGB(255, 20, 147)
local BLUE = Color3.fromRGB(0, 191, 255)

--============================================================
-- CONFIG
--============================================================
local C = {
    -- Aimbot
    aimbot = false, aimKey = Enum.KeyCode.E, aimPart = "Head", fov = 120, smooth = 0.2, pred = 0.165, visCheck = true,
    -- Silent
    silent = false, silentFov = 160,
    -- Trigger
    trigger = false, triggerDelay = 0.1,
    -- Visuals
    esp = false, box = true, name = true, tracer = true, health = true, dist = true,
    fullbright = false, fovCircle = true,
    -- Combat
    hitbox = false, hbSize = 12, noSpread = false,
    -- Movement
    speed = false, speedVal = 50, jump = false, jumpVal = 100, unlockFps = false
}

--============================================================
-- HELPERS
--============================================================
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(r, p) return mk("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function stroke(c, t, p) return mk("UIStroke",{Color=c,Thickness=t,Parent=p}) end
local function alive(p) 
    local ch=p.Character local h=ch and ch:FindFirstChildOfClass("Humanoid") 
    return ch and h and h.Health>0 
end
local function getPart(p, n) 
    local ch=p.Character if not ch then return nil end 
    return ch:FindFirstChild(n) or ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart") 
end
local function w2s(v) local s,on=Cam:WorldToViewportPoint(v) return Vector2.new(s.X,s.Y), on end

-- Visibility Check
local function isVisible(targetPart)
    if not C.visCheck then return true end
    local origin = Cam.CFrame.Position
    local dir = targetPart.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LP.Character, Cam}
    local ray = WS:Raycast(origin, dir, rayParams)
    if ray then return ray.Instance:IsDescendantOf(targetPart.Parent) end
    return true
end

--============================================================
-- CONSOLE SYSTEM
--============================================================
local consoleUI
local originalPrint = print
local originalWarn = warn

local function addLog(msg, isError)
    if not consoleUI then return end
    local text = tostring(msg)
    local lbl = mk("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20), BackgroundTransparency = 1, Text = "> " .. text,
        TextColor3 = isError and Color3.fromRGB(255, 80, 80) or BLUE,
        Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, 
        TextWrapped = true, Parent = consoleUI
    })
    consoleUI.CanvasSize = UDim2.new(0, 0, 0, consoleUI.UIListLayout.AbsoluteContentSize.Y)
    task.defer(function() consoleUI.CanvasPosition = Vector2.new(0, consoleUI.AbsoluteCanvasSize.Y) end)
end

print = function(...) 
    originalPrint(...)
    local str = ""
    for i, v in ipairs({...}) do str = str .. tostring(v) .. " " end
    addLog(str, false)
end
warn = function(...)
    originalWarn(...)
    local str = ""
    for i, v in ipairs({...}) do str = str .. tostring(v) .. " " end
    addLog(str, true)
end

--============================================================
-- ESP & DRAWING
--============================================================
local ESP = {}
local fovDraw = Drawing.new("Circle")
fovDraw.Thickness = 1.5
fovDraw.NumSides = 50
fovDraw.Color = PINK
fovDraw.Transparency = 0.6
fovDraw.Filled = false

local function getTarget(fov)
    local best, bd, ctr = nil, fov, Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and alive(p) then
            local pt = getPart(p, C.aimPart)
            if pt and isVisible(pt) then
                local s, on = w2s(pt.Position)
                if on then
                    local d = (s - ctr).Magnitude
                    if d < bd then bd = d best = p end
                end
            end
        end
    end
    return best
end

local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if not alive(p) then
            if ESP[p] then for _, o in pairs(ESP[p]) do o.Visible = false end end
            continue
        end
        if not ESP[p] then
            ESP[p] = {
                box = Drawing.new("Square"), name = Drawing.new("Text"),
                tr = Drawing.new("Line"), hp = Drawing.new("Line"), dist = Drawing.new("Text")
            }
            ESP[p].box.Thickness = 1 ESP[p].box.Filled = false
            ESP[p].name.Size = 13 ESP[p].name.Center = true ESP[p].name.Outline = true
            ESP[p].tr.Thickness = 1 ESP[p].hp.Thickness = 2
            ESP[p].dist.Size = 12 ESP[p].dist.Center = true ESP[p].dist.Outline = true
        end
        local e = ESP[p]
        local head, hrp = getPart(p, "Head"), getPart(p, "HumanoidRootPart")
        local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        
        if not head or not hrp or not hum then continue end
        
        local sh, onH = w2s(head.Position + Vector3.new(0, 0.8, 0))
        local sf, onF = w2s(hrp.Position - Vector3.new(0, 2.8, 0))
        
        if C.esp and onH and onF then
            local h = math.abs(sf.Y - sh.Y) local w = h * 0.6
            local tl = Vector2.new(sh.X - w/2, sh.Y)
            local d = math.floor((Cam.CFrame.Position - hrp.Position).Magnitude)
            
            e.box.Visible = C.box
            if C.box then e.box.Size = Vector2.new(w, h) e.box.Position = tl e.box.Color = PINK end
            
            e.name.Visible = C.name
            if C.name then e.name.Text = p.Name e.name.Position = Vector2.new(sh.X, sh.Y - 20) e.name.Color = BLUE end
            
            e.tr.Visible = C.tracer
            if C.tracer then e.tr.From = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y) e.tr.To = sh e.tr.Color = PINK end
            
            e.hp.Visible = C.health
            if C.health then
                local pct = hum.Health / hum.MaxHealth
                e.hp.From = Vector2.new(tl.X - 5, tl.Y + h) e.hp.To = Vector2.new(tl.X - 5, tl.Y + h * (1 - pct))
                e.hp.Color = Color3.fromRGB(255 * (1-pct), 255 * pct, 0)
            end

            e.dist.Visible = C.dist
            if C.dist then e.dist.Text = d .. "m" e.dist.Position = Vector2.new(sh.X, sf.Y + 4) e.dist.Color = Color3.new(1,1,1) end
        else
            for _, o in pairs(e) do o.Visible = false end
        end
    end
end

--============================================================
-- SILENT AIM / TRIGGERBOT / MISC
--============================================================
local origRaycast = WS.Raycast
WS.Raycast = function(self, origin, dir, params)
    if C.silent then
        local t = getTarget(C.silentFov)
        if t and getPart(t, C.aimPart) then
            local newDir = (getPart(t, C.aimPart).Position - origin).Unit * dir.Magnitude
            return origRaycast(self, origin, newDir, params)
        end
    end
    return origRaycast(self, origin, dir, params)
end

local lastTrigger = 0
local function doTrigger()
    if not C.trigger then return end
    if tick() - lastTrigger < C.triggerDelay then return end
    local t = getTarget(10)
    if t then 
        lastTrigger = tick()
        if type(mouse1click) == "function" then mouse1click() 
        elseif type(mousemoveabs) == "function" then mousemoveabs(0,0) end
    end
end

local function doHitbox()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local hrp = getPart(p, "HumanoidRootPart")
            if hrp then
                if C.hitbox then hrp.Size = Vector3.new(C.hbSize, C.hbSize, C.hbSize) hrp.Transparency = 0.5 hrp.CanCollide = false
                else hrp.Size = Vector3.new(2,2,1) hrp.Transparency = 1 hrp.CanCollide = true end
            end
        end
    end
end

local function doNoSpread()
    if not C.noSpread then return end
    for _, v in pairs(LP.Backpack:GetChildren()) do
        if v:IsA("Tool") then pcall(function() v.Spread = 0 v.Recoil = 0 end) end
    end
    if LP.Character then
        for _, v in pairs(LP.Character:GetChildren()) do
            if v:IsA("Tool") then pcall(function() v.Spread = 0 v.Recoil = 0 end) end
        end
    end
end

--============================================================
-- MAIN LOOPS
--============================================================
Run.RenderStepped:Connect(function()
    -- Aimbot
    if C.aimbot and UIS:IsKeyDown(C.aimKey) then
        local t = getTarget(C.fov)
        if t then
            local pt = getPart(t, C.aimPart)
            if pt then
                local pos = pt.Position
                if C.pred > 0 then pos = pos + (pt.AssemblyLinearVelocity or Vector3.zero) * C.pred end
                Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, pos), C.smooth)
            end
        end
    end
    
    doTrigger()
    if C.esp then updateESP() end
    
    -- FOV Circle
    if fovDraw then
        fovDraw.Visible = C.aimbot and C.fovCircle
        fovDraw.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
        fovDraw.Radius = C.fov
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        doHitbox()
        doNoSpread()
        if C.unlockFps then pcall(function() setfpscap(999) end) end
        
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = C.speed and C.speedVal or 16
            hum.UseJumpPower = true
            hum.JumpPower = C.jump and C.jumpVal or 50
        end
        
        if C.fullbright then
            Light.Ambient = Color3.fromRGB(178,178,178)
            Light.OutdoorAmbient = Color3.fromRGB(178,178,178)
            Light.Brightness = 2
        end
    end
end)

--============================================================
-- MOBILE UI CREATION
--============================================================
local gui = mk("ScreenGui", {Name="RealisticScripts", ResetOnSpawn=false, Parent=CoreGui})

-- Floating Toggle Button
local toggleBtn = mk("TextButton", {
    Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0, 100),
    BackgroundColor3 = Color3.fromRGB(20, 20, 30), Text = "RS",
    Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = PINK,
    BorderSizePixel = 0, Parent = gui
})
corner(25, toggleBtn) stroke(BLUE, 2, toggleBtn)

-- Main Frame
local main = mk("Frame", {
    Size = UDim2.new(0, 540, 0, 360), Position = UDim2.new(0.5, -270, 0.5, -180),
    BackgroundColor3 = Color3.fromRGB(15, 15, 20), BorderSizePixel = 0, ClipsDescendants = true, Parent = gui
})
corner(8, main)
stroke(BLUE, 1.5, main)
mk("UIGradient", {Color = ColorSequence.new{{Time=0, Color=Color3.fromRGB(20,20,30)},{Time=1, Color=Color3.fromRGB(10,10,15)}}, Rotation=90, Parent=main})

-- Header
local header = mk("Frame", {Size=UDim2.new(1,0,0,46), BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.3, Parent=main})
mk("UIGradient", {Color = ColorSequence.new{{Time=0, Color=PINK},{Time=0.5, Color=Color3.fromRGB(150,50,150)},{Time=1, Color=BLUE}}, Parent=header})
mk("TextLabel", {
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="  REALISTIC SCRIPTS | MOBILE",
    Font=Enum.Font.GothamBlack, TextSize=15, TextColor3=Color3.fromRGB(255,255,255),
    TextXAlignment=Enum.TextXAlignment.Left, Parent=header
})

-- Draggable Logic (Mobile & PC)
local function makeDraggable(frame, dragFrame)
    local dragging, dragInput, dragStart, startPos
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(main, header)
makeDraggable(toggleBtn, toggleBtn)

-- Toggle UI Visibility
toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- Tab System
local tabBar = mk("Frame", {Size=UDim2.new(0, 130, 1, -46), Position = UDim2.new(0, 0, 0, 46), BackgroundTransparency=1, Parent=main})
mk("UIListLayout", {Padding=UDim.new(0, 6), HorizontalAlignment=Enum.HorizontalAlignment.Center, Parent=tabBar})

local pages = {}
local function addTab(name, text)
    local btn = mk("TextButton", {
        Size=UDim2.new(0, 110, 0, 38), BackgroundColor3=Color3.fromRGB(25,25,35), Text=text,
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=BLUE, BorderSizePixel=0, Parent=tabBar
    })
    corner(6, btn) stroke(Color3.fromRGB(40,40,60), 1, btn)
    
    local page = mk("ScrollingFrame", {
        Size=UDim2.new(1,-140,1,-56), Position=UDim2.new(0, 135, 0, 51),
        BackgroundTransparency=1, ScrollBarThickness=4, ScrollBarImageColor3=PINK, BorderSizePixel=0, Parent=main
    })
    mk("UIListLayout", {Padding=UDim.new(0, 8), Parent=page})
    pages[name] = page
    
    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do p.Visible = (k == name) end
        for _, b in pairs(tabBar:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = BLUE b.BackgroundColor3 = Color3.fromRGB(25,25,35) end
        end
        btn.TextColor3 = Color3.fromRGB(255,255,255) btn.BackgroundColor3 = Color3.fromRGB(50, 20, 40)
    end)
    return page
end

-- UI Helpers (Made larger for fingers)
local function addSection(parent, text)
    mk("TextLabel", {
        Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=text,
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=PINK, TextXAlignment=Enum.TextXAlignment.Left, Parent=parent
    })
end

local function addToggle(parent, text, key, cb)
    local btn = mk("TextButton", {Size=UDim2.new(1,-6,0,38), BackgroundColor3=Color3.fromRGB(20,20,28), Text="", BorderSizePixel=0, Parent=parent})
    corner(6, btn) stroke(Color3.fromRGB(35,35,50), 1.5, btn)
    mk("TextLabel", {Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,12,0,0), BackgroundTransparency=1, Text=text, Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left, Parent=btn})
    
    local pill = mk("Frame", {Size=UDim2.new(0,36,0,20), Position=UDim2.new(1,-48,0.5,-10), BackgroundColor3=Color3.fromRGB(40,40,50), BorderSizePixel=0, Parent=btn})
    corner(10, pill)
    local dot = mk("Frame", {Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,2,0.5,-8), BackgroundColor3=Color3.fromRGB(150,150,150), BorderSizePixel=0, Parent=pill})
    corner(8, dot)
    
    local function set(v)
        C[key] = v
        Tween:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = v and BLUE or Color3.fromRGB(40,40,50)}):Play()
        Tween:Create(dot, TweenInfo.new(0.2), {Position = v and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), BackgroundColor3 = v and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)}):Play()
        if cb then cb(v) end
    end
    set(C[key])
    btn.MouseButton1Click:Connect(function() set(not C[key]) print(text .. ": " .. tostring(not C[key])) end)
end

local function addSlider(parent, text, key, min, max, sfx)
    local f = mk("Frame", {Size=UDim2.new(1,-6,0,50), BackgroundColor3=Color3.fromRGB(20,20,28), Parent=parent})
    corner(6, f) stroke(Color3.fromRGB(35,35,50), 1.5, f)
    local l = mk("TextLabel", {Size=UDim2.new(1,-20,0,20), Position=UDim2.new(0,12,0,6), BackgroundTransparency=1, Text=text..": "..C[key]..(sfx or ""), Font=Enum.Font.Gotham, TextSize=12, TextColor3=Color3.fromRGB(220,220,230), TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
    
    -- Thicker bar for mobile touch
    local bar = mk("TextButton", {Size=UDim2.new(1,-24,0,10), Position=UDim2.new(0,12,0,32), BackgroundColor3=Color3.fromRGB(40,40,50), Text="", BorderSizePixel=0, Parent=f})
    corner(5, bar)
    local fill = mk("Frame", {Size=UDim2.new((C[key]-min)/(max-min),0,1,0), BackgroundColor3=PINK, BorderSizePixel=0, Parent=bar})
    corner(5, fill)
    
    local drag = false
    local function update(i)
        local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rel)
        C[key] = v 
        fill.Size = UDim2.new(rel,0,1,0) 
        l.Text = text..": "..v..(sfx or "")
    end
    
    bar.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            drag = true update(i)
        end 
    end)
    bar.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            drag = false 
        end 
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i)
        end
    end)
end

-- Build Tabs
local combat = addTab("combat", "COMBAT")
addSection(combat, "AIMBOT")
addToggle(combat, "Enabled [Hold E]", "aimbot")
addSlider(combat, "FOV", "fov", 20, 400)
addSlider(combat, "Smoothness", "smooth", 0.05, 1)
addSlider(combat, "Prediction", "pred", 0, 0.5)
addToggle(combat, "Visible Check", "visCheck")
addSection(combat, "SILENT AIM")
addToggle(combat, "Enabled", "silent")
addSlider(combat, "Silent FOV", "silentFov", 20, 400)
addSection(combat, "TRIGGERBOT")
addToggle(combat, "Enabled", "trigger")

local visual = addTab("visual", "VISUALS")
addSection(visual, "PLAYER ESP")
addToggle(visual, "Enabled", "esp")
addToggle(visual, "Box", "box")
addToggle(visual, "Name", "name")
addToggle(visual, "Health", "health")
addToggle(visual, "Distance", "dist")
addToggle(visual, "Tracer", "tracer")
addSection(visual, "WORLD VISUALS")
addToggle(visual, "Fullbright", "fullbright")
addToggle(visual, "FOV Circle", "fovCircle")

local move = addTab("move", "PLAYER")
addSection(move, "CHARACTER")
addToggle(move, "Speed", "speed")
addSlider(move, "Speed Value", "speedVal", 16, 200)
addToggle(move, "Jump", "jump")
addSlider(move, "Jump Value", "jumpVal", 50, 300)
addSection(move, "GAME")
addToggle(move, "No Spread / Recoil", "noSpread")
addToggle(move, "Hitbox Expander", "hitbox")
addSlider(move, "Hitbox Size", "hbSize", 2, 30)
addToggle(move, "Unlock FPS (999)", "unlockFps")

local consoleTab = addTab("console", "CONSOLE")
consoleUI = mk("ScrollingFrame", {Size=UDim2.new(1,-6,1,0), BackgroundColor3=Color3.fromRGB(5,5,8), BorderSizePixel=0, ScrollBarThickness=4, Parent=consoleTab})
corner(4, consoleUI)
mk("UIListLayout", {Padding=UDim.new(0,4), Parent=consoleUI})
mk("UIPadding", {PaddingTop=UDim.new(0,6), PaddingLeft=UDim.new(0,6)}, consoleUI)

-- Set default tab
for k, p in pairs(pages) do p.Visible = (k == "combat") end
tabBar:GetChildren()[1].TextColor3 = Color3.fromRGB(255,255,255)
tabBar:GetChildren()[1].BackgroundColor3 = Color3.fromRGB(50, 20, 40)

print("Realistic Scripts Loaded Successfully.")
print("Aimbot hold key is E.")
print("Tap the floating RS button to hide this menu.")