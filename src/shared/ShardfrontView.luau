local View = {}
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local Tween=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local Debris=game:GetService("Debris")
local RunService=game:GetService("RunService")
local remote=RS:WaitForChild("ShardfrontRemotes")
local blue=Color3.fromRGB(20,25,60)
local cyan=Color3.fromRGB(91,244,224)
local coral=Color3.fromRGB(255,135,131)
local white=Color3.fromRGB(244,250,255)
local muted=Color3.fromRGB(170,196,219)
local function rounded(o,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r)
    c.Parent=o
end
local function text(parent,name,value,size,height,color)
    local o=Instance.new("TextLabel")
    o.Name=name
    o.BackgroundTransparency=1
    o.Size=UDim2.new(1,0,0,height)
    o.Font=Enum.Font.GothamBold
    o.TextSize=size
    o.TextColor3=color or white
    o.TextWrapped=true
    o.Text=value
    o.Parent=parent
    return o
end
local function button(parent,name,value,color,height)
    local o=Instance.new("TextButton")
    o.Name=name
    o.Size=UDim2.new(1,0,0,height)
    o.Text=value
    o.TextSize=17
    o.TextColor3=blue
    o.Font=Enum.Font.GothamBlack
    o.BackgroundColor3=color
    o.Selectable=true
    o.Parent=parent
    rounded(o,12)
    return o
end
local function frame(parent,name,size,position,color)
    local o=Instance.new("Frame")
    o.Name=name
    o.Size=size
    o.Position=position
    o.BackgroundColor3=color
    o.BorderSizePixel=0
    o.Parent=parent
    return o
end
function View.start(player, dryRun)
    local gui=Instance.new("ScreenGui")
    gui.Name="ShardfrontUI"
    gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
    gui.DisplayOrder=10
    gui.ResetOnSpawn=false
    gui.Parent=player:WaitForChild("PlayerGui")
    local tokens=Instance.new("StyleSheet")
    tokens.Name="Tokens"
    tokens:SetAttribute("StyleCategory","Tokens")
    tokens:SetAttribute("Accent",cyan)
    tokens.Parent=gui
    local rules=Instance.new("StyleSheet")
    rules.Name="Rules"
    rules:SetDerives({tokens})
    rules.Parent=gui
    local style=Instance.new("StyleLink")
    style.StyleSheet=rules
    style.Parent=gui
    local rule=Instance.new("StyleRule")
    rule.Selector="Frame, TextLabel, TextButton, ScrollingFrame"
    rule:SetProperties({BorderSizePixel=0})
    rule.Parent=rules
    local hud=frame(gui,"HUD",UDim2.new(1,0,0,94),UDim2.new(),blue)
    hud.BackgroundTransparency=.2
    local hp=text(hud,"Health","VITALITY 100 / 100",18,32)
    hp.Size=UDim2.new(.37,0,0,32)
    hp.Position=UDim2.fromOffset(16,9)
    local fill=frame(hud,"HealthFill",UDim2.new(.25,0,0,9),UDim2.fromOffset(16,65),coral)
    rounded(fill,5)
    local wave=text(hud,"Wave","WAVE 1 / 3",19,35,cyan)
    wave.Size=UDim2.new(.44,0,0,35)
    wave.Position=UDim2.new(.38,0,0,9)
    local info=text(hud,"Info","HOSTILES 4",14,29,muted)
    info.Size=UDim2.new(.6,0,0,29)
    info.Position=UDim2.new(.37,0,0,52)
    local boss=frame(gui,"BossBar",UDim2.new(.5,0,0,12),UDim2.new(.25,0,0,108),blue)
    rounded(boss,6)
    local bossFill=frame(boss,"Fill",UDim2.fromScale(1,1),UDim2.new(),coral)
    rounded(bossFill,6)
    local cross=text(gui,"Crosshair","+",29,38)
    cross.Size=UDim2.fromOffset(38,38)
    cross.AnchorPoint=Vector2.new(.5,.5)
    cross.Position=UDim2.fromScale(.5,.49)
    local overlay=frame(gui,"Overlay",UDim2.fromScale(1,1),UDim2.new(),blue)
    overlay.BackgroundTransparency=.12
    overlay.ZIndex=3
    local panel=Instance.new("ScrollingFrame")
    panel.Name="Panel"
    panel.AnchorPoint=Vector2.new(.5,.5)
    panel.Position=UDim2.fromScale(.5,.5)
    panel.Size=UDim2.new(.88,0,.88,0)
    panel.BackgroundColor3=blue
    panel.BackgroundTransparency=.06
    panel.ScrollingDirection=Enum.ScrollingDirection.Y
    panel.ScrollBarThickness=5
    panel.ScrollBarImageColor3=cyan
    panel.AutomaticCanvasSize=Enum.AutomaticSize.Y
    panel.CanvasSize=UDim2.new()
    panel.Parent=overlay
    rounded(panel,20)
    local bound=Instance.new("UISizeConstraint")
    bound.MaxSize=Vector2.new(550,650)
    bound.Parent=panel
    local pad=Instance.new("UIPadding")
    pad.PaddingLeft=UDim.new(0,22)
    pad.PaddingRight=UDim.new(0,22)
    pad.PaddingTop=UDim.new(0,18)
    pad.PaddingBottom=UDim.new(0,18)
    pad.Parent=panel
    local list=Instance.new("UIListLayout")
    list.Padding=UDim.new(0,9)
    list.SortOrder=Enum.SortOrder.LayoutOrder
    list.Parent=panel
    local title=text(panel,"Title","LUMENFALL",32,62,cyan)
    title.LayoutOrder=1
    local subtitle=text(panel,"Subtitle","SHARDFRONT  /  THE RIFT ARENA",16,34,muted)
    subtitle.LayoutOrder=2
    local description=text(panel,"Description","Survive three rising waves. Shape your build. Bring down the Rift Warden.",17,76)
    description.LayoutOrder=3
    local progress=text(panel,"Progress","",16,54,muted)
    progress.LayoutOrder=4
    local choices={}
    for i=1,3 do
        choices[i]=button(panel,"Choice"..i,"",i==1 and cyan or Color3.fromRGB(191,215,239),58)
        choices[i].LayoutOrder=4+i
    end
    local hint=text(panel,"Controls","WASD MOVE  /  MOUSE FIRE  /  E PULSE",13,43,muted)
    hint.LayoutOrder=9
    local fire=button(gui,"FireButton","FIRE",cyan,70)
    fire.Size=UDim2.fromOffset(85,70)
    fire.AnchorPoint=Vector2.new(1,1)
    fire.Position=UDim2.new(1,-15,1,-150)
    local burst=button(gui,"BurstButton","BURST",coral,62)
    burst.Size=UDim2.fromOffset(85,62)
    burst.AnchorPoint=Vector2.new(1,1)
    burst.Position=UDim2.new(1,-110,1,-158)
    local musicGroup=Instance.new("SoundGroup")
    musicGroup.Name="ShardfrontMusic"
    musicGroup.Parent=SoundService
    local fxGroup=Instance.new("SoundGroup")
    fxGroup.Name="ShardfrontSFX"
    fxGroup.Parent=SoundService
    local music=RS:WaitForChild("MusicBed"):Clone()
    music.Looped=true
    music.Volume=.19
    music.SoundGroup=musicGroup
    music.Parent=SoundService
    music:Play()
    local lastSound={}
    local function sound(name)
        if os.clock()-(lastSound[name] or 0)<.12 then return end
        lastSound[name]=os.clock()
        local asset=RS:FindFirstChild(name)
        if not asset then return end
        local one=asset:Clone()
        one.SoundGroup=fxGroup
        one.Volume=name=="ShotSfx" and .33 or .48
        one.Parent=SoundService
        one:Play()
        Debris:AddItem(one,3)
        musicGroup.Volume=.5
        Tween:Create(musicGroup,TweenInfo.new(.27),{Volume=1}):Play()
    end
    local current={phase="title",shards=0,rank=0,best=0,kills=0}
    local function display()
        local phase=current.phase
        local playing=phase=="wave" or phase=="boss"
        overlay.Visible=not playing
        hud.Visible=playing
        cross.Visible=playing
        boss.Visible=phase=="boss"
        fire.Visible=playing and UIS.TouchEnabled
        burst.Visible=playing and UIS.TouchEnabled
        if phase=="title" then
            title.Text="LUMENFALL"
            subtitle.Text="SHARDFRONT  /  THE RIFT ARENA"
            description.Text="Survive three rising waves. Shape your build. Bring down the Rift Warden."
            progress.Text=string.format("SHARDS %d     VITALITY %d/5     BEST %d",current.shards,current.rank,current.best)
            choices[1].Text="BEGIN EXPEDITION"
            choices[2].Text="VITALITY +10 / 5 SHARDS"
            choices[3].Visible=false
        elseif phase=="upgrade" then
            title.Text="RIFT CLEARED"
            subtitle.Text="CHOOSE ONE ADAPTATION"
            description.Text="Your choice lasts until this run ends."
            progress.Text="NEXT: "..(current.wave==3 and "RIFT WARDEN" or "WAVE "..(current.wave+1))
            choices[1].Text="VITALITY   +30 MAX HP, HEAL 45"
            choices[2].Text="OVERCHARGE   +12 DAMAGE"
            choices[3].Text="KINETIC   +4 MOVE SPEED"
            choices[3].Visible=true
        elseif phase=="won" or phase=="lost" then
            title.Text=phase=="won" and "RIFT SEALED" or "SIGNAL LOST"
            subtitle.Text=phase=="won" and "EXPEDITION COMPLETE" or "YOUR RUN HAS ENDED"
            description.Text=phase=="won" and "The Warden falls. The shardfront glows again." or "Gather shards, fortify your suit, and try again."
            progress.Text=string.format("KILLS %d     SHARDS %d     BEST %d",current.kills,current.shards,current.best)
            choices[1].Text="NEW EXPEDITION"
            choices[2].Text="VITALITY +10 / 5 SHARDS"
            choices[3].Visible=false
        end
        choices[2].BackgroundColor3=(phase=="upgrade" or (current.shards>=5 and current.rank<5)) and Color3.fromRGB(191,215,239) or Color3.fromRGB(91,107,143)
    end
    local function aim()
        local camera=workspace.CurrentCamera
        if not camera then return Vector3.new(0,0,-1) end
        local point=UIS.MouseEnabled and UIS:GetMouseLocation() or camera.ViewportSize*Vector2.new(.5,.49)
        local ray=camera:ViewportPointToRay(point.X,point.Y)
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local origin=root and root.Position+Vector3.new(0,2,0) or ray.Origin
        return (ray.Origin+ray.Direction*160-origin).Unit
    end
    local firing=false
    local lastShot=0
    local function shoot()
        if current.phase~="wave" and current.phase~="boss" then return end
        if os.clock()-lastShot<.24 then return end
        lastShot=os.clock()
        remote.Command:FireServer("shoot",aim())
        sound("ShotSfx")
    end
    local function pulse()
        if current.phase=="wave" or current.phase=="boss" then remote.Command:FireServer("pulse") end
    end
    if dryRun then display(); return gui end
    for i,b in ipairs(choices) do
        b.Activated:Connect(function()
            if current.phase=="upgrade" then
                remote.Command:FireServer("choose",({"vitality","power","haste"})[i])
            elseif i==1 then remote.Command:FireServer("start")
            elseif i==2 then remote.Command:FireServer("rank") end
        end)
    end
    fire.MouseButton1Down:Connect(function() firing=true;shoot() end)
    fire.MouseButton1Up:Connect(function() firing=false end)
    fire.MouseLeave:Connect(function() firing=false end)
    burst.Activated:Connect(pulse)
    UIS.InputBegan:Connect(function(input,processed)
        if not processed and input.UserInputType==Enum.UserInputType.MouseButton1 then firing=true;shoot() end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then firing=false end
    end)
    CAS:BindAction("IonFire",function(_,state)
        if state==Enum.UserInputState.Begin then firing=true;shoot() else firing=false end
    end,false,Enum.KeyCode.ButtonR2)
    CAS:BindAction("IonPulse",function(_,state)
        if state==Enum.UserInputState.Begin then pulse() end
    end,false,Enum.KeyCode.E,Enum.KeyCode.ButtonB)
    remote.State.OnClientEvent:Connect(function(data)
        local old=current.phase
        current=data
        hp.Text=string.format("VITALITY %d / %d",data.hp,data.maxHp)
        fill.Size=UDim2.new(.25*math.clamp(data.hp/math.max(1,data.maxHp),0,1),0,0,9)
        wave.Text=data.phase=="boss" and "RIFT WARDEN" or string.format("WAVE %d / 3",data.wave)
        info.Text=string.format("HOSTILES %d     KILLS %d     POWER %d",data.alive,data.kills,data.damage)
        bossFill.Size=UDim2.fromScale(data.bossHP/data.bossMax,1)
        burst.Text=data.cooldown>0 and string.format("BURST %.0fs",data.cooldown) or "BURST"
        if old~=data.phase or not (data.phase=="wave" or data.phase=="boss") then display() end
    end)
    local function orb(position,color,radius,lifetime)
        local p=Instance.new("Part")
        p.Shape=Enum.PartType.Ball
        p.Size=Vector3.new(radius,radius,radius)
        p.Material=Enum.Material.Neon
        p.Color=color
        p.Position=position
        p.Anchored=true
        p.CanCollide=false
        p.Parent=workspace.Projectiles
        Tween:Create(p,TweenInfo.new(lifetime),{Transparency=1,Size=Vector3.new(.1,.1,.1)}):Play()
        Debris:AddItem(p,lifetime+.1)
    end
    remote.Effect.OnClientEvent:Connect(function(kind,a,b)
        if kind=="shot" and typeof(a)=="Vector3" and typeof(b)=="Vector3" then
            local trail=Instance.new("Part")
            trail.Name="IonTrail"
            trail.Size=Vector3.new(.18,.18,(b-a).Magnitude)
            trail.CFrame=CFrame.lookAt((a+b)/2,b)
            trail.Color=cyan
            trail.Material=Enum.Material.Neon
            trail.Anchored=true
            trail.CanCollide=false
            trail.Parent=workspace.Projectiles
            Tween:Create(trail,TweenInfo.new(.14),{Transparency=1}):Play()
            Debris:AddItem(trail,.17)
        elseif kind=="telegraph" and typeof(a)=="Vector3" then
            local p=Instance.new("Part")
            p.Name="IncomingStrike"
            p.Shape=Enum.PartType.Cylinder
            p.Size=Vector3.new(.12,(b or 5)*2,(b or 5)*2)
            p.CFrame=CFrame.new(a+Vector3.new(0,.2,0))*CFrame.Angles(0,0,math.pi/2)
            p.Material=Enum.Material.Neon
            p.Color=coral
            p.Transparency=.48
            p.Anchored=true
            p.CanCollide=false
            p.Parent=workspace.Projectiles
            Tween:Create(p,TweenInfo.new(1),{Transparency=.9}):Play()
            Debris:AddItem(p,1.2)
        elseif kind=="impact" and typeof(a)=="Vector3" then orb(a,coral,3,.25);sound("HitSfx")
        elseif kind=="pulse" and typeof(a)=="Vector3" then orb(a,cyan,22,.4);sound("HitSfx")
        elseif kind=="enemyShot" and typeof(b)=="Vector3" then orb(b,coral,4,.3)
        elseif kind=="hurt" then
            sound("HitSfx")
            local flash=frame(gui,"DamageFlash",UDim2.fromScale(1,1),UDim2.new(),coral)
            flash.BackgroundTransparency=.83
            flash.ZIndex=5
            Tween:Create(flash,TweenInfo.new(.3),{BackgroundTransparency=1}):Play()
            Debris:AddItem(flash,.34)
        elseif kind=="victory" or kind=="upgrade" then sound("HitSfx") end
    end)
    RunService.RenderStepped:Connect(function() if firing then shoot() end end)
    display()
    return gui
end
return View
