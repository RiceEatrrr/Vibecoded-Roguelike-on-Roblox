local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local TweenService = game:GetService("TweenService")
local Storage = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS:WaitForChild("ShardfrontRemotes")
local stateEvent, effectEvent = remotes.State, remotes.Effect
local store = DataStoreService:GetDataStore("ShardfrontProgress_v1")
local Game = {}
local sessions = {}
local types = {
    skitter = {hp=48, speed=12, damage=8, interval=1.3, range=5, template="SkitterTemplate", height=1.5},
    spore = {hp=66, speed=7, damage=10, interval=2.8, range=31, template="SporeTemplate", height=5},
    boss = {hp=850, speed=5, damage=17, interval=3, range=22, template="WardenTemplate", height=6},
}
function Game.wavePlan(wave)
    if wave == 1 then return {"skitter","skitter","skitter","skitter"} end
    if wave == 2 then return {"skitter","spore","skitter","spore","skitter","spore"} end
    if wave == 3 then return {"spore","skitter","spore","skitter","spore","skitter","spore","skitter"} end
    return {"boss"}
end
local function snapshot(s)
    local alive = 0
    local bossHP = 0
    for _, enemy in ipairs(s.enemies) do
        if enemy.hp > 0 then
            alive += 1
            if enemy.kind == "boss" then bossHP = enemy.hp end
        end
    end
    return {phase=s.phase, wave=s.wave, alive=alive, kills=s.kills, hp=s.hp, maxHp=s.maxHp,
        damage=s.damage, speed=s.speed, shards=s.shards, rank=s.rank, best=s.best,
        bossHP=bossHP, bossMax=types.boss.hp, cooldown=math.max(0, s.pulseAt - os.clock())}
end
local function send(s)
    if s.player.Parent then stateEvent:FireClient(s.player, snapshot(s)) end
end
local function save(s)
    local data = {shards=s.shards, rank=s.rank, best=s.best}
    local ok, err = pcall(function()
        store:UpdateAsync(tostring(s.player.UserId), function(old)
            old = type(old)=="table" and old or {}
            return {shards=data.shards, rank=math.max(data.rank, tonumber(old.rank) or 0), best=math.max(data.best, tonumber(old.best) or 0)}
        end)
    end)
    if not ok then warn("Shardfront save failed: ", err) end
end
local function finish(s, won)
    if s.phase == "won" or s.phase == "lost" then return end
    s.phase = won and "won" or "lost"
    s.shards += math.max(0, s.wave - (won and 0 or 1)) + (won and 4 or 0)
    s.best = math.max(s.best, won and 4 or s.wave)
    for _, enemy in ipairs(s.enemies) do if enemy.model then enemy.model:Destroy() end end
    s.enemies = {}
    save(s)
    send(s)
    effectEvent:FireClient(s.player, won and "victory" or "defeat")
end
local function spawnEnemy(s, kind, index, total)
    local cfg = types[kind]
    local template = Storage:FindFirstChild(cfg.template)
    if not template then warn("Missing alien model: ", cfg.template) return end
    local model = template:Clone()
    model.Name = kind == "boss" and "Rift Warden" or (kind == "spore" and "Spore Drifter" or "Crystal Skitter")
    model:SetAttribute("OwnerUserId", s.player.UserId)
    model:SetAttribute("Kind", kind)
    model:SetAttribute("HP", cfg.hp)
    model.Parent = workspace.EnemyVisuals
    local angle = (index / total) * math.pi * 2 + s.wave * .6
    local r = kind == "boss" and 42 or 42 + (index%3)*5
    local pos = Vector3.new(math.cos(angle)*r, cfg.height, math.sin(angle)*r)
    model:PivotTo(CFrame.lookAt(pos, Vector3.new(0,pos.Y,0)))
    table.insert(s.enemies, {kind=kind, hp=cfg.hp, model=model, pos=pos, lastAttack=0, phase=index*.8})
end
local function beginWave(s, wave)
    s.wave = wave
    s.phase = wave == 4 and "boss" or "wave"
    s.enemies = {}
    local plan = Game.wavePlan(wave)
    for i, kind in ipairs(plan) do spawnEnemy(s, kind, i, #plan) end
    send(s)
    effectEvent:FireClient(s.player, wave == 4 and "boss" or "wave")
end
function Game.attach(player)
    local s = {player=player, phase="title", wave=0, enemies={}, hp=100, maxHp=100,
        damage=25, speed=20, kills=0, shards=0, rank=0, best=0, shotAt=0, pulseAt=0, lastSend=0}
    sessions[player] = s
    local ok, data = pcall(function() return store:GetAsync(tostring(player.UserId)) end)
    if ok and type(data)=="table" then
        s.shards=math.max(0, tonumber(data.shards) or 0)
        s.rank=math.clamp(tonumber(data.rank) or 0,0,5)
        s.best=math.max(0, tonumber(data.best) or 0)
    end
    local function setupCharacter(character)
        local hum = character:WaitForChild("Humanoid", 8)
        local root = character:WaitForChild("HumanoidRootPart", 8)
        if hum then
            hum.WalkSpeed=s.speed
            hum.Died:Connect(function()
                if s.phase=="wave" or s.phase=="boss" or s.phase=="upgrade" then finish(s,false) end
            end)
        end
        if root and not root:FindFirstChild("IonAura") then
            local light=Instance.new("PointLight")
            light.Name="IonAura"
            light.Color=Color3.fromRGB(76,246,226)
            light.Range=11
            light.Brightness=1.5
            light.Parent=root
            local spark=Instance.new("ParticleEmitter")
            spark.Name="IonSparks"
            spark.Rate=9
            spark.Lifetime=NumberRange.new(.3,.7)
            spark.Speed=NumberRange.new(0,1)
            spark.Size=NumberSequence.new(.22,0)
            spark.Color=ColorSequence.new(Color3.fromRGB(83,251,227))
            spark.LightEmission=1
            spark.Parent=root
        end
        task.delay(.6,function() if sessions[player]==s then send(s) end end)
    end
    player.CharacterAdded:Connect(setupCharacter)
    if player.Character then task.spawn(setupCharacter,player.Character) end
    send(s)
    return s
end
function Game.detach(player)
    local s = sessions[player]
    if not s then return end
    for _,e in ipairs(s.enemies) do if e.model then e.model:Destroy() end end
    save(s)
    sessions[player]=nil
end
local function rootOf(s)
    local char=s.player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if root and hum and hum.Health>0 then return root,hum end
end
local function hit(s,e,amount)
    if e.hp<=0 or not e.model or not e.model.Parent then return end
    e.hp=math.max(0,e.hp-amount)
    e.model:SetAttribute("HP",e.hp)
    effectEvent:FireClient(s.player,"impact",e.pos)
    if e.hp==0 then
        s.kills+=1
        local model=e.model
        e.model=nil
        task.defer(function() if model then model:Destroy() end end)
        local remaining=0
        for _,other in ipairs(s.enemies) do if other.hp>0 then remaining+=1 end end
        if remaining==0 then
            if s.phase=="boss" then finish(s,true)
            else s.phase="upgrade"; send(s); effectEvent:FireClient(s.player,"upgrade") end
        else send(s) end
    else send(s) end
end
function Game.command(player, action, data)
    local s=sessions[player]
    if not s or type(action)~="string" then return false end
    if action=="start" then
        if s.phase~="title" and s.phase~="lost" and s.phase~="won" then return false end
        for _,e in ipairs(s.enemies) do if e.model then e.model:Destroy() end end
        s.enemies={};s.kills=0;s.wave=0;s.damage=25;s.speed=20;s.maxHp=100+s.rank*10;s.hp=s.maxHp;s.pulseAt=0;s.shotAt=0
        local root,hum=rootOf(s)
        if not root then player:LoadCharacter() else root.CFrame=CFrame.new(0,5,0);hum.Health=hum.MaxHealth;hum.WalkSpeed=s.speed end
        beginWave(s,1)
        return true
    end
    if action=="rank" then
        if (s.phase~="title" and s.phase~="won" and s.phase~="lost") or s.shards<5 or s.rank>=5 then return false end
        s.shards-=5;s.rank+=1;save(s);send(s);return true
    end
    if action=="choose" then
        if s.phase~="upgrade" or type(data)~="string" then return false end
        if data=="vitality" then s.maxHp+=30;s.hp=math.min(s.maxHp,s.hp+45)
        elseif data=="power" then s.damage+=12
        elseif data=="haste" then s.speed+=4
        else return false end
        local _,hum=rootOf(s)
        if hum then hum.WalkSpeed=s.speed end
        beginWave(s,s.wave+1)
        return true
    end
    if action=="shoot" then
        if (s.phase~="wave" and s.phase~="boss") or os.clock()-s.shotAt<.24 then return false end
        local root=rootOf(s)
        if not root or typeof(data)~="Vector3" or data.Magnitude<.9 or data.Magnitude>1.1 then return false end
        local direction=data.Unit
        if direction.Y < -.85 or direction.Y > .85 then return false end
        s.shotAt=os.clock()
        local origin=root.Position+Vector3.new(0,2,0)
        local best,bestDist=nil,180
        for _,e in ipairs(s.enemies) do
            if e.hp>0 then
                local delta=e.pos-origin
                local projection=delta:Dot(direction)
                local radius=e.kind=="boss" and 7 or 3.5
                if projection>0 and projection<bestDist and projection<180 and (delta-direction*projection).Magnitude<radius then best=e;bestDist=projection end
            end
        end
        effectEvent:FireClient(player,"shot",origin, best and best.pos or origin+direction*100)
        if best then hit(s,best,s.damage) end
        return true
    end
    if action=="pulse" then
        if (s.phase~="wave" and s.phase~="boss") or os.clock()<s.pulseAt then return false end
        local root=rootOf(s)
        if not root then return false end
        s.pulseAt=os.clock()+8
        for _,e in ipairs(s.enemies) do if e.hp>0 and (e.pos-root.Position).Magnitude<18 then hit(s,e,s.damage*1.7) end end
        effectEvent:FireClient(player,"pulse",root.Position)
        send(s)
        return true
    end
    return false
end
function Game.step(dt)
    dt=math.min(dt,.1)
    for player,s in pairs(sessions) do
        if s.phase~="wave" and s.phase~="boss" then continue end
        local root,hum=rootOf(s)
        if not root then continue end
        local pos=root.Position
        if pos.Y < -20 then root.CFrame=CFrame.new(0,5,0);s.hp=math.max(0,s.hp-20) end
        for _,e in ipairs(s.enemies) do
            if e.hp<=0 or not e.model or not e.model.Parent then continue end
            local cfg=types[e.kind]
            local planar=Vector3.new(pos.X-e.pos.X,0,pos.Z-e.pos.Z)
            local dist=planar.Magnitude
            if dist>.1 then
                local desired=e.kind=="skitter" and 4 or (e.kind=="spore" and 24 or 12)
                if dist>desired then
                    local nextPos=e.pos+planar.Unit*math.min(cfg.speed*dt,dist-desired)
                    e.pos=Vector3.new(math.clamp(nextPos.X,-66,66),cfg.height,math.clamp(nextPos.Z,-66,66))
                end
                local bob=math.sin(os.clock()*2+e.phase)*.3
                e.model:PivotTo(CFrame.lookAt(e.pos+Vector3.new(0,bob,0),Vector3.new(pos.X,cfg.height+bob,pos.Z)))
            end
            if dist<cfg.range and os.clock()-e.lastAttack>cfg.interval then
                e.lastAttack=os.clock()
                if e.kind=="skitter" and dist>6 then continue end
                if e.kind == "skitter" then
                    s.hp=math.max(0,s.hp-cfg.damage)
                    effectEvent:FireClient(player,"hurt",e.pos,pos)
                    if s.hp<=0 then finish(s,false);break end
                else
                    local target=Vector3.new(pos.X,0,pos.Z)
                    local origin=e.pos
                    local radius=e.kind=="boss" and 17 or 5
                    effectEvent:FireClient(player,"telegraph",target,radius)
                    task.delay(e.kind=="boss" and 1.15 or .85,function()
                        if sessions[player]~=s or (s.phase~="wave" and s.phase~="boss") then return end
                        local liveRoot=rootOf(s)
                        if not liveRoot then return end
                        effectEvent:FireClient(player,"enemyShot",origin,target)
                        local flat=Vector3.new(liveRoot.Position.X-target.X,0,liveRoot.Position.Z-target.Z)
                        if flat.Magnitude<=radius then
                            s.hp=math.max(0,s.hp-cfg.damage)
                            effectEvent:FireClient(player,"hurt",origin,target)
                            if s.hp<=0 then finish(s,false) else send(s) end
                        end
                    end)
                end
            end
        end
        if os.clock()-s.lastSend>.4 then s.lastSend=os.clock();send(s) end
    end
end
function Game.debugSnapshot(player) local s=sessions[player]; return s and snapshot(s) end
return Game
