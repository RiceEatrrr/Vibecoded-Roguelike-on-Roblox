local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Game = require(script.Parent:WaitForChild("ShardfrontGame"))
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("ShardfrontRemotes")
Players.PlayerAdded:Connect(function(player)
    task.spawn(function() Game.attach(player) end)
end)
for _,player in ipairs(Players:GetPlayers()) do
    task.spawn(function() Game.attach(player) end)
end
Players.PlayerRemoving:Connect(Game.detach)
local commandEvent = remotes:FindFirstChild("Command")
if commandEvent and commandEvent:IsA("RemoteEvent") then
    commandEvent.OnServerEvent:Connect(function(player, action, data)
        Game.command(player,action,data)
    end)
else
    warn("Shardfront command channel missing")
end
RunService.Heartbeat:Connect(function(dt)
    Game.step(dt)
end)
