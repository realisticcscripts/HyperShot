-- Hypershot v2.0 | REALISTIC 
-- UPDATED UI+ FEATURES FIX

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
        enabled=false, fov=120, smoothness=15,
        hitpart="Head", teamcheck=true, wallcheck=true,
        prediction=true, predMultiplier=8,
        silentaim=false, triggerbot=false,
        triggerDelay=5, vischeck=true,
    },
    esp = {
        enabled=false, boxes=true, names=true,
        health=true, distance=true, tracers=false, maxdist=500,
        teamcolor=Color3.fromRGB(0,200,255),
        enemycolor=Color3.fromRGB(255,60,100),
    },
    misc = {
        norecoil=false, nospread=false, rapidfire=false,
        infreload=false, bhop=false, speedhack=false,
        speedval=32, noclip=false, thirdperson=false,
        fovchanger=false, fovval=90,
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
    local v,on=Camera:WorldToViewportPoint(pos); return Vector2.new(v.X,v.Y),on,v.Z
end
local function getCenter() return Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2) end
local function hasLOS(pos)
    local o=Camera.CFrame.Position
    local ray=Ray.new(o,(pos-o).Unit*500)
    local hit=workspace:FindPartOnRayWithIgnoreList(ray,{getChar(lp)})
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
            if on then table.insert(t,{player=p,part=part,vp=vp,dist=(vp-getCenter()).Magnitude}) end
        end
    end
    table.sort(t,function(a,b)return a.dist<b.dist end)
    return t
end
local function getBestTarget()
    local t=getTargets(); if #t==0 then return nil end
    return t[1].dist<=cfg.aimbot.fov and t[1] or nil
end

-- ═══════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name="HSNotifs"; NotifGui.ResetOnSpawn=false
NotifGui.IgnoreGuiInset=true; NotifGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
NotifGui.Parent=(gethui and gethui()) or game:GetService("CoreGui")

local NotifHolder=Instance.new("Frame")
NotifHolder.Size=UDim2.new(0,280,1,0)
NotifHolder.Position=UDim2.new(1,-290,0,0)
NotifHolder.BackgroundTransparency=1; NotifHolder.Parent=NotifGui
local NHL=Instance.new("UIListLayout"); NHL.Parent=NotifHolder
NHL.SortOrder=Enum.SortOrder.LayoutOrder; NHL.VerticalAlignment=Enum.VerticalAlignment.Bottom
NHL.Padding=UDim.new(0,6)

local notifCount=0
local function notify(title,msg,ntype)
    notifCount=notifCount+1
    local col = ntype=="on" and Color3.fromRGB(100,255,160)
              or ntype=="off" and Color3.fromRGB(255,80,100)
              or Color3.fromRGB(120,160,255)

    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,0); card.AutomaticSize=Enum.AutomaticSize.Y
    card.BackgroundColor3=Color3.fromRGB(14,10,26)
    card.BorderSizePixel=0; card.LayoutOrder=notifCount
    card.Position=UDim2.new(1,0,0,0); card.Parent=NotifHolder
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)

    local accent=Instance.new("Frame")
    accent.Size=UDim2.new(0,3,1,0); accent.BackgroundColor3=col
    accent.BorderSizePixel=0; accent.Parent=card
    Instance.new("UICorner",accent).CornerRadius=UDim.new(0,10)

    local stroke=Instance.new("UIStroke"); stroke.Parent=card
    stroke.Color=col; stroke.Thickness=1; stroke.Transparency=0.6

    local pad=Instance.new("UIPadding"); pad.Parent=card
    pad.PaddingLeft=UDim.new(0,14); pad.PaddingRight=UDim.new(0,10)
    pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8)

    local inner=Instance.new("Frame"); inner.Size=UDim2.new(1,0,0,0)
    inner.AutomaticSize=Enum.AutomaticSize.Y; inner.BackgroundTransparency=1; inner.Parent=card
    local il=Instance.new("UIListLayout"); il.Parent=inner; il.Padding=UDim.new(0,2)

    local t=Instance.new("TextLabel"); t.Parent=inner
    t.Size=UDim2.new(1,0,0,16); t.BackgroundTransparency=1
    t.Text=title; t.TextColor3=col; t.TextScaled=true
    t.Font=Enum.Font.GothamBold; t.TextXAlignment=Enum.TextXAlignment.Left

    local b=Instance.new("TextLabel"); b.Parent=inner
    b.Size=UDim2.new(1,0,0,14); b.BackgroundTransparency=1
    b.Text=msg; b.TextColor3=Color3.fromRGB(180,160,220); b.TextScaled=true
    b.Font=Enum.Font.Gotham; b.TextXAlignment=Enum.TextXAlignment.Left

    TweenService:Create(card,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
        Position=UDim2.new(0,0,0,0)
    }):Play()

    task.delay(3,function()
        TweenService:Create(card,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
            Position=UDim2.new(1,20,0,0),BackgroundTransparency=1
        }):Play()
        task.delay(0.3,function() card:Destroy() end)
    end)
end

-- ═══════════════════════════════════
-- GUI PARENT
-- ═══════════════════════════════════
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="HyperShot"; ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset=true
ScreenGui.Parent=(gethui and gethui()) or game:GetService("CoreGui")

-- ═══════════════════════════════════
-- MAIN FRAME
-- ═══════════════════════════════════
local Main=Instance.new("Frame")
Main.Size=UDim2.new(0,480,0,420)
Main.Position=UDim2.new(0.5,-240,0.5,-210)
Main.BackgroundColor3=Color3.fromRGB(10,7,20)
Main.BorderSizePixel=0; Main.Visible=false; Main.ZIndex=10; Main.Parent=ScreenGui
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,16)

local mainStroke=Instance.new("UIStroke"); mainStroke.Parent=Main
mainStroke.Color=Color3.fromRGB(100,50,200); mainStroke.Thickness=1.5

-- animated gradient bg
local bgGrad=Instance.new("UIGradient"); bgGrad.Parent=Main
bgGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(16,8,32)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(10,12,28)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(8,16,30))
})
bgGrad.Rotation=135

-- ═══════════════════════════════════
-- HEADER
-- ═══════════════════════════════════
local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,52); Header.BackgroundColor3=Color3.fromRGB(15,8,30)
Header.BorderSizePixel=0; Header.ZIndex=11; Header.Parent=Main
Instance.new("UICorner",Header).CornerRadius=UDim.new(0,16)
-- extend bottom so corners don't show
local headerFix=Instance.new("Frame")
headerFix.Size=UDim2.new(1,0,0,16); headerFix.Position=UDim2.new(0,0,1,-16)
headerFix.BackgroundColor3=Color3.fromRGB(15,8,30); headerFix.BorderSizePixel=0
headerFix.ZIndex=11; headerFix.Parent=Header

local hGrad=Instance.new("UIGradient"); hGrad.Parent=Header
hGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(90,20,180)),
    ColorSequenceKeypoint.new(0.4,Color3.fromRGB(180,40,130)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(50,90,220))
})
hGrad.Rotation=90

-- logo
local Logo=Instance.new("TextLabel"); Logo.Parent=Header
Logo.Size=UDim2.new(0,42,0,42); Logo.Position=UDim2.new(0,8,0.5,-21)
Logo.BackgroundColor3=Color3.fromRGB(180,20,50); Logo.Text="🩸"
Logo.TextScaled=true; Logo.Font=Enum.Font.GothamBold
Logo.TextColor3=Color3.fromRGB(255,255,255); Logo.ZIndex=13; Logo.BorderSizePixel=0
Instance.new("UICorner",Logo).CornerRadius=UDim.new(0,10)

local TitleLbl=Instance.new("TextLabel"); TitleLbl.Parent=Header
TitleLbl.Size=UDim2.new(0,180,0,26); TitleLbl.Position=UDim2.new(0,58,0,8)
TitleLbl.BackgroundTransparency=1; TitleLbl.Text="HYPERSHOT"
TitleLbl.TextColor3=Color3.fromRGB(255,255,255); TitleLbl.TextScaled=true
TitleLbl.Font=Enum.Font.GothamBold; TitleLbl.TextXAlignment=Enum.TextXAlignment.Left
TitleLbl.ZIndex=13

local SubLbl=Instance.new("TextLabel"); SubLbl.Parent=Header
SubLbl.Size=UDim2.new(0,180,0,16); SubLbl.Position=UDim2.new(0,58,0,32)
SubLbl.BackgroundTransparency=1; SubLbl.Text="v2.0 | by Fracture"
SubLbl.TextColor3=Color3.fromRGB(200,160,255); SubLbl.TextScaled=true
SubLbl.Font=Enum.Font.Gotham; SubLbl.TextXAlignment=Enum.TextXAlignment.Left
SubLbl.ZIndex=13

local CloseBtn=Instance.new("TextButton"); CloseBtn.Parent=Header
CloseBtn.Size=UDim2.new(0,34,0,34); CloseBtn.Position=UDim2.new(1,-42,0.5,-17)
CloseBtn.BackgroundColor3=Color3.fromRGB(200,30,60); CloseBtn.Text="✕"
CloseBtn.TextColor3=Color3.fromRGB(255,255,255); CloseBtn.TextScaled=true
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.ZIndex=13; CloseBtn.BorderSizePixel=0
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,10)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(255,50,80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(200,30,60)}):Play()
end)

-- drag main
do
    local drag,ds,sp=false,nil,nil
    Header.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=inp.Position; sp=Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and(inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local d=inp.Position-ds
            Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

-- ═══════════════════════════════════
-- TAB BAR
-- ═══════════════════════════════════
local TabBar=Instance.new("Frame"); TabBar.Parent=Main
TabBar.Size=UDim2.new(1,-16,0,36); TabBar.Position=UDim2.new(0,8,0,56)
TabBar.BackgroundColor3=Color3.fromRGB(14,10,26); TabBar.BorderSizePixel=0; TabBar.ZIndex=11
Instance.new("UICorner",TabBar).CornerRadius=UDim.new(0,10)
local TBarL=Instance.new("UIListLayout"); TBarL.Parent=TabBar
TBarL.FillDirection=Enum.FillDirection.Horizontal
TBarL.SortOrder=Enum.SortOrder.LayoutOrder; TBarL.Padding=UDim.new(0,4)
local TBarP=Instance.new("UIPadding"); TBarP.Parent=TabBar
TBarP.PaddingLeft=UDim.new(0,4); TBarP.PaddingTop=UDim.new(0,4)
TBarP.PaddingRight=UDim.new(0,4); TBarP.PaddingBottom=UDim.new(0,4)

-- ═══════════════════════════════════
-- CONTENT AREA
-- ═══════════════════════════════════
local Content=Instance.new("ScrollingFrame"); Content.Parent=Main
Content.Size=UDim2.new(1,-16,1,-108); Content.Position=UDim2.new(0,8,0,100)
Content.BackgroundTransparency=1; Content.ScrollBarThickness=4
Content.ScrollBarImageColor3=Color3.fromRGB(140,60,255)
Content.BorderSizePixel=0; Content.ZIndex=11; Content.CanvasSize=UDim2.new(0,0,0,0)
local ContentL=Instance.new("UIListLayout"); ContentL.Parent=Content
ContentL.SortOrder=Enum.SortOrder.LayoutOrder; ContentL.Padding=UDim.new(0,8)
local ContentP=Instance.new("UIPadding"); ContentP.Parent=Content
ContentP.PaddingLeft=UDim.new(0,2); ContentP.PaddingRight=UDim.new(0,2)
ContentP.PaddingTop=UDim.new(0,4); ContentP.PaddingBottom=UDim.new(0,4)
ContentL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize=UDim2.new(0,0,0,ContentL.AbsoluteContentSize.Y+10)
end)

-- ═══════════════════════════════════
-- TABS SETUP
-- ═══════════════════════════════════
local tabDefs={
    {name="🎯  Aimbot", icon="🎯"},
    {name="👁  ESP",    icon="👁"},
    {name="⚡  Misc",   icon="⚡"},
}
local tabBtns,tabPages={},{}
local activeTab=1

local function setTab(idx)
    activeTab=idx
    for i,btn in ipairs(tabBtns) do
        local on=(i==idx)
        TweenService:Create(btn,TweenInfo.new(0.18),{
            BackgroundColor3=on and Color3.fromRGB(110,45,220) or Color3.fromRGB(20,14,36),
            TextColor3=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,100,190),
        }):Play()
    end
    for i,pg in ipairs(tabPages) do pg.Visible=(i==idx) end
end

for i,td in ipairs(tabDefs) do
    local btn=Instance.new("TextButton"); btn.Parent=TabBar
    btn.Size=UDim2.new(0,138,1,0)
    btn.BackgroundColor3=Color3.fromRGB(20,14,36)
    btn.Text=td.name; btn.TextColor3=Color3.fromRGB(130,100,190)
    btn.TextScaled=true; btn.Font=Enum.Font.GothamBold
    btn.ZIndex=12; btn.LayoutOrder=i; btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    tabBtns[i]=btn

    local pg=Instance.new("Frame"); pg.Parent=Content
    pg.Size=UDim2.new(1,0,0,0); pg.AutomaticSize=Enum.AutomaticSize.Y
    pg.BackgroundTransparency=1; pg.Visible=false; pg.ZIndex=11; pg.LayoutOrder=i
    local pl=Instance.new("UIListLayout"); pl.Parent=pg
    pl.SortOrder=Enum.SortOrder.LayoutOrder; pl.Padding=UDim.new(0,6)
    tabPages[i]=pg

    btn.MouseButton1Click:Connect(function() setTab(i) end)
end
setTab(1)

-- ═══════════════════════════════════
-- WIDGET BUILDERS
-- ═══════════════════════════════════
local function mkSection(parent, title, order)
    local sec=Instance.new("Frame"); sec.Parent=parent
    sec.Size=UDim2.new(1,0,0,22); sec.BackgroundTransparency=1
    sec.LayoutOrder=order or 0
    local lbl=Instance.new("TextLabel"); lbl.Parent=sec
    lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text="── "..title.." ──"
    lbl.TextColor3=Color3.fromRGB(160,100,255); lbl.TextScaled=true
    lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left
end

local function mkToggle(parent, label, cfgTbl, key, order, desc)
    local row=Instance.new("Frame"); row.Parent=parent
    row.Size=UDim2.new(1,0,0,42); row.BackgroundColor3=Color3.fromRGB(16,10,30)
    row.BorderSizePixel=0; row.ZIndex=12; row.LayoutOrder=order or 0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rs=Instance.new("UIStroke"); rs.Parent=row
    rs.Color=Color3.fromRGB(60,30,100); rs.Thickness=1

    local lbl=Instance.new("TextLabel"); lbl.Parent=row
    lbl.Size=UDim2.new(1,-70,0,22); lbl.Position=UDim2.new(0,12,0,5)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(220,200,255); lbl.TextScaled=true
    lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=13

    if desc then
        local sub=Instance.new("TextLabel"); sub.Parent=row
        sub.Size=UDim2.new(1,-70,0,14); sub.Position=UDim2.new(0,12,0,25)
        sub.BackgroundTransparency=1; sub.Text=desc
        sub.TextColor3=Color3.fromRGB(130,110,170); sub.TextScaled=true
        sub.Font=Enum.Font.Gotham; sub.TextXAlignment=Enum.TextXAlignment.Left; sub.ZIndex=13
    end

    local togBg=Instance.new("Frame"); togBg.Parent=row
    togBg.Size=UDim2.new(0,48,0,26); togBg.Position=UDim2.new(1,-60,0.5,-13)
    togBg.BackgroundColor3=cfgTbl[key] and Color3.fromRGB(120,50,230) or Color3.fromRGB(35,22,55)
    togBg.BorderSizePixel=0; togBg.ZIndex=13
    Instance.new("UICorner",togBg).CornerRadius=UDim.new(0.5,0)

    local knob=Instance.new("Frame"); knob.Parent=togBg
    knob.Size=UDim2.new(0,20,0,20)
    knob.Position=cfgTbl[key] and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.ZIndex=14
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0.5,0)
    local ks=Instance.new("UIStroke"); ks.Parent=knob
    ks.Color=Color3.fromRGB(180,180,180); ks.Thickness=0.5

    local clickArea=Instance.new("TextButton"); clickArea.Parent=row
    clickArea.Size=UDim2.new(1,0,1,0); clickArea.BackgroundTransparency=1
    clickArea.Text=""; clickArea.ZIndex=15

    clickArea.MouseButton1Click:Connect(function()
        cfgTbl[key]=not cfgTbl[key]; local on=cfgTbl[key]
        TweenService:Create(togBg,TweenInfo.new(0.18),{
            BackgroundColor3=on and Color3.fromRGB(120,50,230) or Color3.fromRGB(35,22,55)
        }):Play()
        TweenService:Create(knob,TweenInfo.new(0.18),{
            Position=on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
        }):Play()
        notify(label, on and "Enabled" or "Disabled", on and "on" or "off")
    end)

    -- hover glow
    clickArea.MouseEnter:Connect(function()
        TweenService:Create(rs,TweenInfo.new(0.15),{Color=Color3.fromRGB(120,60,220),Transparency=0}):Play()
    end)
    clickArea.MouseLeave:Connect(function()
        TweenService:Create(rs,TweenInfo.new(0.15),{Color=Color3.fromRGB(60,30,100),Transparency=0}):Play()
    end)
end

local function mkSlider(parent, label, cfgTbl, key, minV, maxV, order, fmt)
    local row=Instance.new("Frame"); row.Parent=parent
    row.Size=UDim2.new(1,0,0,56); row.BackgroundColor3=Color3.fromRGB(16,10,30)
    row.BorderSizePixel=0; row.ZIndex=12; row.LayoutOrder=order or 0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rs=Instance.new("UIStroke"); rs.Parent=row
    rs.Color=Color3.fromRGB(60,30,100); rs.Thickness=1

    local function fmtVal(v) return fmt and string.format(fmt,v) or tostring(v) end

    local topRow=Instance.new("Frame"); topRow.Parent=row
    topRow.Size=UDim2.new(1,-16,0,20); topRow.Position=UDim2.new(0,10,0,8)
    topRow.BackgroundTransparency=1

    local lbl=Instance.new("TextLabel"); lbl.Parent=topRow
    lbl.Size=UDim2.new(0.7,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text=label; lbl.TextColor3=Color3.fromRGB(220,200,255)
    lbl.TextScaled=true; lbl.Font=Enum.Font.GothamBold
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=13

    local valLbl=Instance.new("TextLabel"); valLbl.Parent=topRow
    valLbl.Size=UDim2.new(0.3,0,1,0); valLbl.Position=UDim2.new(0.7,0,0,0)
    valLbl.BackgroundTransparency=1; valLbl.Text=fmtVal(cfgTbl[key])
    valLbl.TextColor3=Color3.fromRGB(160,100,255); valLbl.TextScaled=true
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=13

    local trackBg=Instance.new("Frame"); trackBg.Parent=row
    trackBg.Size=UDim2.new(1,-20,0,8); trackBg.Position=UDim2.new(0,10,0,36)
    trackBg.BackgroundColor3=Color3.fromRGB(30,20,50); trackBg.BorderSizePixel=0; trackBg.ZIndex=13
    Instance.new("UICorner",trackBg).CornerRadius=UDim.new(0.5,0)

    local pct=(cfgTbl[key]-minV)/(maxV-minV)
    local fill=Instance.new("Frame"); fill.Parent=trackBg
    fill.Size=UDim2.new(pct,0,1,0); fill.BorderSizePixel=0; fill.ZIndex=14
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0.5,0)
    local fg=Instance.new("UIGradient"); fg.Parent=fill
    fg.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(100,40,200)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(220,80,255))
    })

    local handle=Instance.new("Frame"); handle.Parent=trackBg
    handle.Size=UDim2.new(0,18,0,18); handle.Position=UDim2.new(pct,-9,0.5,-9)
    handle.BackgroundColor3=Color3.fromRGB(230,120,255); handle.BorderSizePixel=0; handle.ZIndex=15
    Instance.new("UICorner",handle).CornerRadius=UDim.new(0.5,0)
    local hs=Instance.new("UIStroke"); hs.Parent=handle
    hs.Color=Color3.fromRGB(255,180,255); hs.Thickness=1.5

    local sliding=false
    local function upd(inp)
        local rx=math.clamp((inp.Position.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1)
        cfgTbl[key]=math.floor(minV+rx*(maxV-minV))
        fill.Size=UDim2.new(rx,0,1,0); handle.Position=UDim2.new(rx,-9,0.5,-9)
        valLbl.Text=fmtVal(cfgTbl[key])
    end
    trackBg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true; upd(i) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
    end)
end

-- ═══════════════════════════════════
-- POPULATE — AIMBOT
-- ═══════════════════════════════════
local ap=tabPages[1]
mkSection(ap,"Core",0)
mkToggle(ap,"Aimbot",       cfg.aimbot,"enabled",   1,"Lock onto nearest target")
mkToggle(ap,"Silent Aim",   cfg.aimbot,"silentaim", 2,"Hit without moving camera")
mkToggle(ap,"Triggerbot",   cfg.aimbot,"triggerbot",3,"Auto-fire on target")
mkSection(ap,"Filters",10)
mkToggle(ap,"Team Check",   cfg.aimbot,"teamcheck", 11,"Skip teammates")
mkToggle(ap,"Wall Check",   cfg.aimbot,"wallcheck", 12,"Skip players behind walls")
mkToggle(ap,"Vis Check",    cfg.aimbot,"vischeck",  13,"Only aim at visible targets")
mkToggle(ap,"Prediction",   cfg.aimbot,"prediction",14,"Lead moving targets")
mkSection(ap,"Settings",20)
mkSlider(ap,"FOV Radius",   cfg.aimbot,"fov",       10,500,21)
mkSlider(ap,"Smoothness",   cfg.aimbot,"smoothness",1,100,22)
mkSlider(ap,"Trigger Delay",cfg.aimbot,"triggerDelay",1,50,23)
mkSlider(ap,"Prediction",   cfg.aimbot,"predMultiplier",1,20,24)

-- ═══════════════════════════════════
-- POPULATE — ESP
-- ═══════════════════════════════════
local ep=tabPages[2]
mkSection(ep,"Rendering",0)
mkToggle(ep,"ESP",          cfg.esp,"enabled", 1,"Draw overlays on players")
mkToggle(ep,"Boxes",        cfg.esp,"boxes",   2,"Bounding boxes")
mkToggle(ep,"Names",        cfg.esp,"names",   3,"Player names")
mkToggle(ep,"Health Bars",  cfg.esp,"health",  4,"HP bar beside each player")
mkToggle(ep,"Distance",     cfg.esp,"distance",5,"Distance in metres")
mkToggle(ep,"Tracers",      cfg.esp,"tracers", 6,"Lines from screen bottom")
mkSection(ep,"Settings",10)
mkSlider(ep,"Max Distance", cfg.esp,"maxdist", 50,1000,11)

-- ═══════════════════════════════════
-- POPULATE — MISC
-- ═══════════════════════════════════
local mp=tabPages[3]
mkSection(mp,"Weapon",0)
mkToggle(mp,"No Recoil",    cfg.misc,"norecoil",   1,"Remove weapon recoil")
mkToggle(mp,"No Spread",    cfg.misc,"nospread",   2,"Perfect bullet accuracy")
mkToggle(mp,"Rapid Fire",   cfg.misc,"rapidfire",  3,"Max fire rate")
mkToggle(mp,"Inf Reload",   cfg.misc,"infreload",  4,"Never need to reload")
mkSection(mp,"Movement",10)
mkToggle(mp,"Bunny Hop",    cfg.misc,"bhop",       11,"Auto-jump to maintain speed")
mkToggle(mp,"Speed Hack",   cfg.misc,"speedhack",  12,"Increase walk speed")
mkToggle(mp,"Noclip",       cfg.misc,"noclip",     13,"Phase through walls")
mkSection(mp,"Visual",20)
mkToggle(mp,"Third Person", cfg.misc,"thirdperson",21,"Third-person camera")
mkToggle(mp,"FOV Changer",  cfg.misc,"fovchanger", 22,"Override field of view")
mkSection(mp,"Settings",30)
mkSlider(mp,"Walk Speed",   cfg.misc,"speedval",   16,100,31)
mkSlider(mp,"Field of View",cfg.misc,"fovval",     40,120,32)

-- ═══════════════════════════════════
-- TOGGLE BUTTON
-- ═══════════════════════════════════
local ToggleBtn=Instance.new("TextButton"); ToggleBtn.Parent=ScreenGui
ToggleBtn.Size=UDim2.new(0,56,0,56)
ToggleBtn.Position=UDim2.new(0,14,0.5,-28)
ToggleBtn.BackgroundColor3=Color3.fromRGB(18,10,32)
ToggleBtn.BorderSizePixel=0; ToggleBtn.Text="🩸\nR"
ToggleBtn.TextColor3=Color3.fromRGB(220,30,60); ToggleBtn.TextScaled=true
ToggleBtn.Font=Enum.Font.GothamBold; ToggleBtn.LineHeight=1; ToggleBtn.ZIndex=999
Instance.new("UICorner",ToggleBtn).CornerRadius=UDim.new(0,12)
local tStroke=Instance.new("UIStroke"); tStroke.Parent=ToggleBtn
tStroke.Color=Color3.fromRGB(180,20,50); tStroke.Thickness=2
-- pulse glow
local tGlow=Instance.new("UIStroke"); tGlow.Parent=ToggleBtn
tGlow.Color=Color3.fromRGB(255,60,100); tGlow.Thickness=0

local function pulseToggle()
    TweenService:Create(tGlow,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,math.huge,true),{
        Thickness=4
    }):Play()
end
pulseToggle()

local guiOpen=false
local function openGUI()
    guiOpen=true
    Main.Size=UDim2.new(0,480,0,0); Main.Visible=true; Main.BackgroundTransparency=1
    TweenService:Create(Main,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,480,0,420), BackgroundTransparency=0
    }):Play()
end
local function closeGUI()
    guiOpen=false
    local tw=TweenService:Create(Main,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
        Size=UDim2.new(0,480,0,0), BackgroundTransparency=1
    })
    tw:Play()
    tw.Completed:Connect(function() if not guiOpen then Main.Visible=false end end)
end
CloseBtn.MouseButton1Click:Connect(closeGUI)

do
    local down,downPos,startPos,dragging=false,Vector2.zero,nil,false
    local THRESH=8
    ToggleBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            down=true; dragging=false
            downPos=Vector2.new(inp.Position.X,inp.Position.Y); startPos=ToggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not down then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local dx=inp.Position.X-downPos.X; local dy=inp.Position.Y-downPos.Y
            if math.sqrt(dx*dx+dy*dy)>THRESH then dragging=true end
            if dragging then
                ToggleBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+dx,startPos.Y.Scale,startPos.Y.Offset+dy)
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if not down then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            if not dragging then if guiOpen then closeGUI() else openGUI() end end
            down=false; dragging=false
        end
    end)
end

-- PC hotkey
if not isMobile then
    UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.KeyCode==Enum.KeyCode.RightShift then
            if guiOpen then closeGUI() else openGUI() end
        end
    end)
end

-- ═══════════════════════════════════
-- FOV CIRCLE
-- ═══════════════════════════════════
local fovCircle=Drawing and Drawing.new("Circle") or nil
if fovCircle then
    fovCircle.Visible=false; fovCircle.Radius=cfg.aimbot.fov
    fovCircle.Color=Color3.fromRGB(180,60,255); fovCircle.Thickness=1.5
    fovCircle.Transparency=0.5; fovCircle.Filled=false
end

-- ═══════════════════════════════════
-- ESP DRAWINGS
-- ═══════════════════════════════════
local espData={}
local function clearESP(p)
    if espData[p] then
        for _,d in pairs(espData[p]) do
            if d then pcall(function() if d.Remove then d:Remove() else d.Visible=false end end) end
        end
        espData[p]=nil
    end
end
local function mkD(t,props)
    if not Drawing then return nil end
    local ok,d=pcall(function() return Drawing.new(t) end)
    if not ok then return nil end
    for k,v in pairs(props) do pcall(function() d[k]=v end) end
    return d
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
                healthBg=mkD("Square",{Visible=false,Filled=true,Color=Color3.fromRGB(0,0,0),Transparency=0.6}),
                dist=mkD("Text",{Visible=false,Color=Color3.fromRGB(220,220,220),Size=12,Font=2,Center=true,Outline=true}),
                tracer=mkD("Line",{Visible=false,Color=col,Thickness=1,Transparency=1}),
            }
        end
        local d=espData[p]
        local head=chr:FindFirstChild("Head"); local feet=chr:FindFirstChild("HumanoidRootPart")
        if not head or not feet then continue end
        local topVP,topOn=worldToVP(head.Position+Vector3.new(0,0.6,0))
        local botVP=worldToVP(feet.Position-Vector3.new(0,2.8,0))
        local dist3d=(Camera.CFrame.Position-root.Position).Magnitude
        if not topOn or dist3d>cfg.esp.maxdist then
            for _,dr in pairs(d) do if dr then pcall(function() dr.Visible=false end) end end; continue
        end
        local h=math.abs(botVP.Y-topVP.Y); local w=h*0.55; local cx=topVP.X
        if d.box then pcall(function()
            d.box.Visible=cfg.esp.boxes; d.box.Color=col
            d.box.Position=Vector2.new(cx-w/2,topVP.Y); d.box.Size=Vector2.new(w,h)
        end) end
        if d.name then pcall(function()
            d.name.Visible=cfg.esp.names; d.name.Text=p.Name
            d.name.Position=Vector2.new(cx,topVP.Y-18)
        end) end
        if d.health and d.healthBg then pcall(function()
            local hp=hum and(hum.Health/hum.MaxHealth) or 0; local bh=h*hp
            d.healthBg.Visible=cfg.esp.health; d.healthBg.Position=Vector2.new(cx-w/2-8,topVP.Y); d.healthBg.Size=Vector2.new(5,h)
            d.health.Visible=cfg.esp.health
            d.health.Color=Color3.fromRGB(math.floor((1-hp)*255),math.floor(hp*220),60)
            d.health.Position=Vector2.new(cx-w/2-8,topVP.Y+(h-bh)); d.health.Size=Vector2.new(5,bh)
        end) end
        if d.dist then pcall(function()
            d.dist.Visible=cfg.esp.distance; d.dist.Text=math.floor(dist3d).."m"
            d.dist.Position=Vector2.new(cx,botVP.Y+4)
        end) end
        if d.tracer then pcall(function()
            local vp2=Camera.ViewportSize
            d.tracer.Visible=cfg.esp.tracers; d.tracer.Color=col
            d.tracer.From=Vector2.new(vp2.X/2,vp2.Y); d.tracer.To=botVP
        end) end
    end
    for p in pairs(espData) do if not active[p] then clearESP(p) end end
end

-- ═══════════════════════════════════
-- AIMBOT LOGIC
-- ═══════════════════════════════════
local function doAimbot()
    if not cfg.aimbot.enabled then
        if fovCircle then fovCircle.Visible=false end; return
    end
    if fovCircle then
        fovCircle.Visible=true; fovCircle.Radius=cfg.aimbot.fov; fovCircle.Position=getCenter()
    end
    local target=getBestTarget(); if not target then return end
    local pos=target.part.Position
    if cfg.aimbot.prediction then
        pos=pos+target.part.AssemblyLinearVelocity*(cfg.aimbot.predMultiplier/100)
    end
    if not cfg.aimbot.silentaim then
        local camCF=Camera.CFrame
        local alpha=math.clamp(cfg.aimbot.smoothness/100,0.01,1)
        Camera.CFrame=camCF:Lerp(CFrame.new(camCF.Position,pos),alpha)
    end
end

-- ═══════════════════════════════════
-- CHAR REFS
-- ═══════════════════════════════════
local char=lp.Character or lp.CharacterAdded:Wait()
local hum=char:WaitForChild("Humanoid")
lp.CharacterAdded:Connect(function(c)
    char=c; hum=c:WaitForChild("Humanoid")
end)
local origFOV=Camera.FieldOfView

local lastTrigger=0
local function doTriggerbot()
    if not cfg.aimbot.triggerbot then return end
    local t=getBestTarget(); if not t then return end
    local now=tick(); if now-lastTrigger<(cfg.aimbot.triggerDelay/100) then return end
    lastTrigger=now
    local vp=worldToVP(t.part.Position)
    if (vp-getCenter()).Magnitude<24 then
        pcall(function() mouse1click(mouse) end)
    end
end

-- ═══════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════
RunService.RenderStepped:Connect(function()
    local rmb=UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if rmb or isMobile then doAimbot()
    else if fovCircle then fovCircle.Visible=false end end

    doTriggerbot()
    updateESP()

    if hum then
        if cfg.misc.bhop and hum.FloorMaterial~=Enum.Material.Air then hum.Jump=true end
        hum.WalkSpeed = cfg.misc.speedhack and cfg.misc.speedval or 16
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
        if root then Camera.CFrame=CFrame.new(root.Position+Vector3.new(0,5,12),root.Position) end
    else
        Camera.CameraType=Enum.CameraType.Custom
    end
end)

-- ═══════════════════════════════════
-- STARTUP NOTIF
-- ═══════════════════════════════════
task.delay(0.5,function()
    notify("🩸 HyperShot v2.0","Loaded successfully | tap R to open","info")
end)

print("[HyperShot v2.0] Loaded | tap 🩸R | RShift on PC")
