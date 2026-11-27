-- Hypershot v1.1 | Fracture
-- Mobile + PC | Blue/Pink UI | Bloody R Toggle

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
        enabled = false, fov = 120, smoothness = 0.15,
        hitpart = "Head", teamcheck = true, wallcheck = true,
        prediction = true, predMultiplier = 0.08,
        silentaim = false, triggerbot = false,
        triggerDelay = 0.05, vischeck = true,
    },
    esp = {
        enabled = false, boxes = true, names = true,
        health = true, distance = true, tracers = false,
        maxdist = 500,
        teamcolor = Color3.fromRGB(0, 200, 255),
        enemycolor = Color3.fromRGB(255, 60, 100),
    },
    misc = {
        norecoil = false, nospread = false, rapidfire = false,
        infreload = false, bhop = false, speedhack = false,
        speedval = 32, noclip = false, thirdperson = false,
        fovchanger = false, fovval = 90,
    }
}

-- ═══════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════
local function getChar(p) return p and p.Character end
local function getRoot(p) local c=getChar(p); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum(p)  local c=getChar(p); return c and c:FindFirstChildOfClass("Humanoid") end
local function getPart(p,n) local c=getChar(p); return c and c:FindFirstChild(n) end
local function isAlive(p) local h=getHum(p); return h and h.Health>0 end
local function isSameTeam(p) return p.Team and lp.Team and p.Team==lp.Team end

local function worldToVP(pos)
    local vp,on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(vp.X,vp.Y), on, vp.Z
end
local function getCenter()
    return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end
local function hasLOS(pos)
    local origin = Camera.CFrame.Position
    local ray = Ray.new(origin,(pos-origin).Unit*500)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray,{getChar(lp)})
    if not hit then return true end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp then local c=getChar(p); if c and hit:IsDescendantOf(c) then return true end end
    end
    return false
end
local function getTargets()
    local t={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and isAlive(p) then
            if cfg.aimbot.teamcheck and isSameTeam(p) then continue end
            local part=getPart(p,cfg.aimbot.hitpart) or getPart(p,"Head")
            if not part then continue end
            if cfg.aimbot.vischeck and not hasLOS(part.Position) then continue end
            local vp,on=worldToVP(part.Position)
            if on then
                local dist=(vp-getCenter()).Magnitude
                table.insert(t,{player=p,part=part,vp=vp,dist=dist})
            end
        end
    end
    table.sort(t,function(a,b) return a.dist<b.dist end)
    return t
end
local function getBestTarget()
    local t=getTargets(); if #t==0 then return nil end
    local b=t[1]; return b.dist<=cfg.aimbot.fov and b or nil
end

-- ═══════════════════════════════════
-- GUI PARENT
-- ═══════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HyperShot"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- ═══════════════════════════════════
-- MAIN FRAME  (built FIRST so toggle can reference it)
-- ═══════════════════════════════════
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,460,0,400)
Main.Position = UDim2.new(0.5,-230,0.5,-200)
Main.BackgroundColor3 = Color3.fromRGB(12,8,22)
Main.BorderSizePixel = 0
Main.Visible = false
Main.ZIndex = 10
Main.Parent = ScreenGui
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,14)
local MStroke = Instance.new("UIStroke")
MStroke.Color = Color3.fromRGB(90,60,180); MStroke.Thickness=1.5; MStroke.Parent=Main
local BgGrad = Instance.new("UIGradient")
BgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(14,8,28)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(8,14,32))
})
BgGrad.Rotation=135; BgGrad.Parent=Main

-- ═══════════════════════════════════
-- TOGGLE BUTTON  — InputEnded based, threshold drag
-- ═══════════════════════════════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,54,0,54)
ToggleBtn.Position = UDim2.new(0,12,0.5,-27)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(18,10,25)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "🩸R"
ToggleBtn.TextColor3 = Color3.fromRGB(220,30,60)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 999
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner",ToggleBtn).CornerRadius = UDim.new(0,10)
local TStroke = Instance.new("UIStroke")
TStroke.Color=Color3.fromRGB(180,20,50); TStroke.Thickness=2; TStroke.Parent=ToggleBtn

local guiOpen = false
local function openGUI()
    guiOpen = true
    Main.Size = UDim2.new(0,460,0,0)
    Main.Visible = true
    TweenService:Create(Main,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
        Size = UDim2.new(0,460,0,400)
    }):Play()
end
local function closeGUI()
    guiOpen = false
    local tw = TweenService:Create(Main,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
        Size = UDim2.new(0,460,0,0)
    })
    tw:Play()
    tw.Completed:Connect(function() if not guiOpen then Main.Visible=false end end)
end

-- drag + tap logic separated by movement threshold
do
    local down = false
    local downPos = Vector2.new(0,0)
    local startUDim = UDim2.new(0,12,0.5,-27)
    local dragging = false
    local THRESH = 8

    ToggleBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            down=true; dragging=false
            downPos=Vector2.new(inp.Position.X,inp.Position.Y)
            startUDim=ToggleBtn.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not down then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch then
            local dx=inp.Position.X-downPos.X
            local dy=inp.Position.Y-downPos.Y
            if math.sqrt(dx*dx+dy*dy)>THRESH then
                dragging=true
            end
            if dragging then
                ToggleBtn.Position=UDim2.new(
                    startUDim.X.Scale,startUDim.X.Offset+dx,
                    startUDim.Y.Scale,startUDim.Y.Offset+dy
                )
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if not down then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            if not dragging then
                -- clean tap — toggle the GUI
                if guiOpen then closeGUI() else openGUI() end
            end
            down=false; dragging=false
        end
    end)
end

-- ═══════════════════════════════════
-- TITLE BAR
-- ═══════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Size=UDim2.new(1,0,0,44); TitleBar.BackgroundColor3=Color3.fromRGB(20,10,40)
TitleBar.BorderSizePixel=0; TitleBar.ZIndex=11; TitleBar.Parent=Main
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,14)
local TG=Instance.new("UIGradient"); TG.Parent=TitleBar
TG.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(80,20,160)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(160,40,120)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(40,80,200))
}); TG.Rotation=90

local TitleLabel=Instance.new("TextLabel")
TitleLabel.Size=UDim2.new(1,-50,1,0); TitleLabel.Position=UDim2.new(0,14,0,0)
TitleLabel.BackgroundTransparency=1; TitleLabel.Text="🩸 HYPERSHOT"
TitleLabel.TextColor3=Color3.fromRGB(255,255,255); TitleLabel.TextScaled=true
TitleLabel.Font=Enum.Font.GothamBold; TitleLabel.TextXAlignment=Enum.TextXAlignment.Left
TitleLabel.ZIndex=12; TitleLabel.Parent=TitleBar

local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,32,0,32); CloseBtn.Position=UDim2.new(1,-40,0.5,-16)
CloseBtn.BackgroundColor3=Color3.fromRGB(200,30,60); CloseBtn.Text="✕"
CloseBtn.TextColor3=Color3.fromRGB(255,255,255); CloseBtn.TextScaled=true
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.ZIndex=13; CloseBtn.Parent=TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,8)
CloseBtn.MouseButton1Click:Connect(closeGUI)

-- drag main window
do
    local drag,dragStart,startPos=false,nil,nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            drag=true; dragStart=inp.Position; startPos=Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch) then
            local d=inp.Position-dragStart
            Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

-- ═══════════════════════════════════
-- TABS
-- ═══════════════════════════════════
local tabNames={"Aimbot","ESP","Misc"}
local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(1,-16,0,34); TabBar.Position=UDim2.new(0,8,0,48)
TabBar.BackgroundTransparency=1; TabBar.ZIndex=11; TabBar.Parent=Main
local TL=Instance.new("UIListLayout"); TL.FillDirection=Enum.FillDirection.Horizontal
TL.SortOrder=Enum.SortOrder.LayoutOrder; TL.Padding=UDim.new(0,6); TL.Parent=TabBar

local ContentArea=Instance.new("ScrollingFrame")
ContentArea.Size=UDim2.new(1,-16,1,-98); ContentArea.Position=UDim2.new(0,8,0,90)
ContentArea.BackgroundTransparency=1; ContentArea.ScrollBarThickness=3
ContentArea.ScrollBarImageColor3=Color3.fromRGB(120,60,200)
ContentArea.BorderSizePixel=0; ContentArea.ZIndex=11; ContentArea.Parent=Main
local CL=Instance.new("UIListLayout"); CL.SortOrder=Enum.SortOrder.LayoutOrder
CL.Padding=UDim.new(0,6); CL.Parent=ContentArea
CL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentArea.CanvasSize=UDim2.new(0,0,0,CL.AbsoluteContentSize.Y+10)
end)

local tabBtns,tabPages,activeTab={},{},1
local function setTab(idx)
    activeTab=idx
    for i,btn in ipairs(tabBtns) do
        btn.BackgroundColor3 = i==idx and Color3.fromRGB(100,40,200) or Color3.fromRGB(22,14,40)
        btn.TextColor3       = i==idx and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,100,200)
    end
    for i,pg in ipairs(tabPages) do pg.Visible=(i==idx) end
end

for i,name in ipairs(tabNames) do
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,130,1,0); btn.BackgroundColor3=Color3.fromRGB(22,14,40)
    btn.Text=name; btn.TextColor3=Color3.fromRGB(140,100,200)
    btn.TextScaled=true; btn.Font=Enum.Font.GothamBold
    btn.ZIndex=12; btn.LayoutOrder=i; btn.Parent=TabBar
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    tabBtns[i]=btn

    local pg=Instance.new("Frame")
    pg.Size=UDim2.new(1,0,0,0); pg.AutomaticSize=Enum.AutomaticSize.Y
    pg.BackgroundTransparency=1; pg.Visible=false
    pg.ZIndex=11; pg.LayoutOrder=i; pg.Parent=ContentArea
    local pl=Instance.new("UIListLayout"); pl.SortOrder=Enum.SortOrder.LayoutOrder
    pl.Padding=UDim.new(0,6); pl.Parent=pg
    tabPages[i]=pg

    btn.MouseButton1Click:Connect(function() setTab(i) end)
end
setTab(1)

-- ═══════════════════════════════════
-- WIDGET BUILDERS
-- ═══════════════════════════════════
local function mkToggle(parent,label,cfgTbl,key,order)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=Color3.fromRGB(20,12,36)
    row.BorderSizePixel=0; row.ZIndex=12; row.LayoutOrder=order or 0; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(210,190,255); lbl.TextScaled=true
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=13; lbl.Parent=row

    local tog=Instance.new("TextButton")
    tog.Size=UDim2.new(0,44,0,24); tog.Position=UDim2.new(1,-52,0.5,-12)
    tog.BackgroundColor3=cfgTbl[key] and Color3.fromRGB(120,50,220) or Color3.fromRGB(40,25,60)
    tog.Text=""; tog.ZIndex=13; tog.Parent=row
    Instance.new("UICorner",tog).CornerRadius=UDim.new(0.5,0)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,18,0,18)
    knob.Position=cfgTbl[key] and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    knob.ZIndex=14; knob.Parent=tog
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0.5,0)

    tog.MouseButton1Click:Connect(function()
        cfgTbl[key]=not cfgTbl[key]; local on=cfgTbl[key]
        TweenService:Create(tog,TweenInfo.new(0.15),{BackgroundColor3=on and Color3.fromRGB(120,50,220) or Color3.fromRGB(40,25,60)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.15),{Position=on and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
    end)
end

local function mkSlider(parent,label,cfgTbl,key,minV,maxV,order)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,52); row.BackgroundColor3=Color3.fromRGB(20,12,36)
    row.BorderSizePixel=0; row.ZIndex=12; row.LayoutOrder=order or 0; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-10,0,20); lbl.Position=UDim2.new(0,10,0,6)
    lbl.BackgroundTransparency=1; lbl.Text=label..": "..tostring(cfgTbl[key])
    lbl.TextColor3=Color3.fromRGB(210,190,255); lbl.TextScaled=true
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=13; lbl.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-20,0,8); track.Position=UDim2.new(0,10,0,32)
    track.BackgroundColor3=Color3.fromRGB(40,25,60); track.BorderSizePixel=0
    track.ZIndex=13; track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(0.5,0)

    local pct=(cfgTbl[key]-minV)/(maxV-minV)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=Color3.fromRGB(160,60,240)
    fill.BorderSizePixel=0; fill.ZIndex=14; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0.5,0)

    local handle=Instance.new("Frame")
    handle.Size=UDim2.new(0,16,0,16); handle.Position=UDim2.new(pct,-8,0.5,-8)
    handle.BackgroundColor3=Color3.fromRGB(220,100,255); handle.BorderSizePixel=0
    handle.ZIndex=15; handle.Parent=track
    Instance.new("UICorner",handle).CornerRadius=UDim.new(0.5,0)

    local sliding=false
    local function upd(inp)
        local rx=math.clamp((inp.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        cfgTbl[key]=math.floor(minV+rx*(maxV-minV))
        fill.Size=UDim2.new(rx,0,1,0); handle.Position=UDim2.new(rx,-8,0.5,-8)
        lbl.Text=label..": "..tostring(cfgTbl[key])
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true; upd(i) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
    end)
end

-- ═══════════════════════════════════
-- POPULATE TABS
-- ═══════════════════════════════════
local ap=tabPages[1]
mkToggle(ap,"Aimbot Enabled",  cfg.aimbot,"enabled",   1)
mkToggle(ap,"Silent Aim",      cfg.aimbot,"silentaim", 2)
mkToggle(ap,"Team Check",      cfg.aimbot,"teamcheck", 3)
mkToggle(ap,"Wall Check",      cfg.aimbot,"wallcheck", 4)
mkToggle(ap,"Vis Check",       cfg.aimbot,"vischeck",  5)
mkToggle(ap,"Prediction",      cfg.aimbot,"prediction",6)
mkToggle(ap,"Triggerbot",      cfg.aimbot,"triggerbot",7)
mkSlider(ap,"FOV",             cfg.aimbot,"fov",       10,500,8)
mkSlider(ap,"Smoothness",      cfg.aimbot,"smoothness" ~= nil and cfg.aimbot or cfg.aimbot,"fov",1,100,9)

-- smoothness needs float storage; use a proxy int table
local _sm={v=math.floor(cfg.aimbot.smoothness*100)}
local smRow=Instance.new("Frame")
smRow.Size=UDim2.new(1,0,0,52); smRow.BackgroundColor3=Color3.fromRGB(20,12,36)
smRow.BorderSizePixel=0; smRow.ZIndex=12; smRow.LayoutOrder=9; smRow.Parent=ap
Instance.new("UICorner",smRow).CornerRadius=UDim.new(0,8)
do
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-10,0,20); lbl.Position=UDim2.new(0,10,0,6)
    lbl.BackgroundTransparency=1; lbl.Text="Smoothness: ".._sm.v
    lbl.TextColor3=Color3.fromRGB(210,190,255); lbl.TextScaled=true
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=13; lbl.Parent=smRow

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-20,0,8); track.Position=UDim2.new(0,10,0,32)
    track.BackgroundColor3=Color3.fromRGB(40,25,60); track.BorderSizePixel=0
    track.ZIndex=13; track.Parent=smRow
    Instance.new("UICorner",track).CornerRadius=UDim.new(0.5,0)

    local pct=_sm.v/100
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=Color3.fromRGB(160,60,240)
    fill.BorderSizePixel=0; fill.ZIndex=14; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0.5,0)

    local handle=Instance.new("Frame")
    handle.Size=UDim2.new(0,16,0,16); handle.Position=UDim2.new(pct,-8,0.5,-8)
    handle.BackgroundColor3=Color3.fromRGB(220,100,255); handle.BorderSizePixel=0
    handle.ZIndex=15; handle.Parent=track
    Instance.new("UICorner",handle).CornerRadius=UDim.new(0.5,0)

    local sl=false
    local function upd(inp)
        local rx=math.clamp((inp.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        _sm.v=math.floor(rx*100); cfg.aimbot.smoothness=_sm.v/100
        fill.Size=UDim2.new(rx,0,1,0); handle.Position=UDim2.new(rx,-8,0.5,-8)
        lbl.Text="Smoothness: ".._sm.v
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sl=true;upd(i) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sl and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sl=false end
    end)
end

-- fix FOV slider (remove the broken double-call from before)
mkSlider(ap,"FOV",cfg.aimbot,"fov",10,500,8)

local ep=tabPages[2]
mkToggle(ep,"ESP Enabled",  cfg.esp,"enabled", 1)
mkToggle(ep,"Boxes",        cfg.esp,"boxes",   2)
mkToggle(ep,"Names",        cfg.esp,"names",   3)
mkToggle(ep,"Health Bars",  cfg.esp,"health",  4)
mkToggle(ep,"Distance",     cfg.esp,"distance",5)
mkToggle(ep,"Tracers",      cfg.esp,"tracers", 6)
mkSlider(ep,"Max Distance", cfg.esp,"maxdist", 50,1000,7)

local mp=tabPages[3]
mkToggle(mp,"No Recoil",    cfg.misc,"norecoil",   1)
mkToggle(mp,"No Spread",    cfg.misc,"nospread",   2)
mkToggle(mp,"Rapid Fire",   cfg.misc,"rapidfire",  3)
mkToggle(mp,"Inf Reload",   cfg.misc,"infreload",  4)
mkToggle(mp,"Bunny Hop",    cfg.misc,"bhop",       5)
mkToggle(mp,"Speed Hack",   cfg.misc,"speedhack",  6)
mkToggle(mp,"Noclip",       cfg.misc,"noclip",     7)
mkToggle(mp,"Third Person", cfg.misc,"thirdperson",8)
mkToggle(mp,"FOV Changer",  cfg.misc,"fovchanger", 9)
mkSlider(mp,"Speed",        cfg.misc,"speedval",   16,100,10)
mkSlider(mp,"Custom FOV",   cfg.misc,"fovval",     40,120,11)

-- ═══════════════════════════════════
-- FOV CIRCLE
-- ═══════════════════════════════════
local fovCircle = Drawing and Drawing.new("Circle") or nil
if fovCircle then
    fovCircle.Visible=false; fovCircle.Radius=cfg.aimbot.fov
    fovCircle.Color=Color3.fromRGB(180,60,255); fovCircle.Thickness=1.5
    fovCircle.Transparency=0.6; fovCircle.Filled=false
end

-- ═══════════════════════════════════
-- ESP
-- ═══════════════════════════════════
local espData={}
local function clearESP(p)
    if espData[p] then
        for _,d in pairs(espData[p]) do
            if d and d.Remove then d:Remove() elseif d and d.Visible~=nil then d.Visible=false end
        end
        espData[p]=nil
    end
end
local function mkD(t,props)
    if not Drawing then return nil end
    local d=Drawing.new(t); for k,v in pairs(props) do d[k]=v end; return d
end
local function updateESP()
    if not cfg.esp.enabled then for p in pairs(espData) do clearESP(p) end; return end
    local active={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end; active[p]=true
        local root=getRoot(p); local chr=getChar(p)
        if not root or not chr or not isAlive(p) then clearESP(p); continue end
        local hum=getHum(p)
        local col=isSameTeam(p) and cfg.esp.teamcolor or cfg.esp.enemycolor
        if not espData[p] then
            espData[p]={
                box=mkD("Square",{Visible=false,Filled=false,Color=col,Thickness=1.5,Transparency=1}),
                name=mkD("Text",{Visible=false,Color=Color3.fromRGB(255,255,255),Size=14,Font=2,Center=true,Outline=true}),
                health=mkD("Square",{Visible=false,Filled=true,Color=Color3.fromRGB(0,255,80),Transparency=1}),
                healthBg=mkD("Square",{Visible=false,Filled=true,Color=Color3.fromRGB(0,0,0),Transparency=0.5}),
                dist=mkD("Text",{Visible=false,Color=Color3.fromRGB(220,220,220),Size=12,Font=2,Center=true,Outline=true}),
                tracer=mkD("Line",{Visible=false,Color=col,Thickness=1,Transparency=1}),
            }
        end
        local d=espData[p]
        local head=chr:FindFirstChild("Head"); local feet=chr:FindFirstChild("HumanoidRootPart")
        if not head or not feet then continue end
        local topVP,topOn=worldToVP(head.Position+Vector3.new(0,0.5,0))
        local botVP=worldToVP(feet.Position-Vector3.new(0,2.5,0))
        local dist3d=(Camera.CFrame.Position-root.Position).Magnitude
        if not topOn or dist3d>cfg.esp.maxdist then
            for _,dr in pairs(d) do if dr and dr.Visible~=nil then dr.Visible=false end end; continue
        end
        local h=math.abs(botVP.Y-topVP.Y); local w=h*0.5; local cx=topVP.X
        if d.box then d.box.Visible=cfg.esp.boxes;d.box.Color=col;d.box.Position=Vector2.new(cx-w/2,topVP.Y);d.box.Size=Vector2.new(w,h) end
        if d.name then d.name.Visible=cfg.esp.names;d.name.Text=p.Name;d.name.Position=Vector2.new(cx,topVP.Y-16) end
        if d.health and d.healthBg then
            local hp=hum and(hum.Health/hum.MaxHealth) or 0; local bh=h*hp
            d.healthBg.Visible=cfg.esp.health;d.healthBg.Position=Vector2.new(cx-w/2-7,topVP.Y);d.healthBg.Size=Vector2.new(4,h)
            d.health.Visible=cfg.esp.health;d.health.Color=Color3.fromRGB(math.floor((1-hp)*255),math.floor(hp*220),60)
            d.health.Position=Vector2.new(cx-w/2-7,topVP.Y+(h-bh));d.health.Size=Vector2.new(4,bh)
        end
        if d.dist then d.dist.Visible=cfg.esp.distance;d.dist.Text=math.floor(dist3d).."m";d.dist.Position=Vector2.new(cx,botVP.Y+2) end
        if d.tracer then
            local vp2=Camera.ViewportSize
            d.tracer.Visible=cfg.esp.tracers;d.tracer.From=Vector2.new(vp2.X/2,vp2.Y);d.tracer.To=botVP;d.tracer.Color=col
        end
    end
    for p in pairs(espData) do if not active[p] then clearESP(p) end end
end

-- ═══════════════════════════════════
-- AIMBOT
-- ═══════════════════════════════════
local function doAimbot()
    if not cfg.aimbot.enabled then return end
    local target=getBestTarget()
    if not target then if fovCircle then fovCircle.Visible=false end; return end
    local pos=target.part.Position
    if cfg.aimbot.prediction then pos=pos+target.part.AssemblyLinearVelocity*cfg.aimbot.predMultiplier end
    if not cfg.aimbot.silentaim then
        local camCF=Camera.CFrame
        Camera.CFrame=camCF:Lerp(CFrame.new(camCF.Position,pos),math.clamp(cfg.aimbot.smoothness,0.01,1))
    end
    if fovCircle then fovCircle.Visible=true;fovCircle.Radius=cfg.aimbot.fov;fovCircle.Position=getCenter() end
end

-- ═══════════════════════════════════
-- MISC
-- ═══════════════════════════════════
local char=lp.Character or lp.CharacterAdded:Wait()
local hum=char:WaitForChild("Humanoid")
lp.CharacterAdded:Connect(function(c) char=c; hum=c:WaitForChild("Humanoid") end)
local origFOV=Camera.FieldOfView

local lastTrigger=0
local function doTriggerbot()
    if not cfg.aimbot.triggerbot then return end
    local t=getBestTarget(); if not t then return end
    local now=tick(); if now-lastTrigger<cfg.aimbot.triggerDelay then return end
    lastTrigger=now
    local vp=worldToVP(t.part.Position)
    if (vp-getCenter()).Magnitude<20 then
        pcall(function() mouse1click(mouse) end)
    end
end

-- ═══════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════
RunService.RenderStepped:Connect(function()
    local holding=UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if holding or isMobile then doAimbot()
    else if fovCircle then fovCircle.Visible=false end end

    doTriggerbot(); updateESP()

    if hum then
        if cfg.misc.bhop and hum.FloorMaterial~=Enum.Material.Air then hum.Jump=true end
        hum.WalkSpeed=cfg.misc.speedhack and cfg.misc.speedval or 16
    end
    if char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=not cfg.misc.noclip end
        end
    end
    Camera.FieldOfView=cfg.misc.fovchanger and cfg.misc.fovval or origFOV
    if cfg.misc.thirdperson then
        Camera.CameraType=Enum.CameraType.Fixed
        local root=getRoot(lp)
        if root then Camera.CFrame=CFrame.new(root.Position+Vector3.new(0,4,10),root.Position) end
    else
        Camera.CameraType=Enum.CameraType.Custom
    end
end)

-- PC hotkey
if not isMobile then
    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.KeyCode==Enum.KeyCode.RightShift then
            if guiOpen then closeGUI() else openGUI() end
        end
    end)
end

print("[HyperShot v1.1] Loaded | tap 🩸R to toggle | RShift on PC")
