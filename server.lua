local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")

local function kick(player)
	player:Kick("You are sussy ngl")
end

remoteEvent.OnServerEvent:Connect(kick)

