local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")


local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character.HumanoidRootPart
local Humanoid2 = Character.Humanoid

local flagCounter = 0
local loopCounter = 0
local jumppower = 50
local speed = 16

local isJumping = false
local isSitting = false
local backpackAllowed = false

local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")


function onJumpRequest()
	isJumping = true
end

local result, code = pcall(function()
	return LocalizationService:GetCountryRegionForPlayerAsync(Player)
end)

Humanoid2.Seated:Connect(function(active,currentSeat)
	if active and currentSeat.Name == "VehicleSeat" or currentSeat.Name == "DriveSeat" then
		isSitting = true
	end
end)

UserInputService.JumpRequest:Connect(onJumpRequest)

game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
game.Players.LocalPlayer.Character.Humanoid.JumpPower = jumppower

while true do
	local startingPlayerX = Humanoid.CFrame.X
	local startingPlayerY = Humanoid.CFrame.Y
	local startingPlayerZ = Humanoid.CFrame.Z
	wait(0.1)
	local endingPlayerX = Humanoid.CFrame.X
	local endingPlayerY = Humanoid.CFrame.Y
	local endingPlayerZ = Humanoid.CFrame.Z
	local DifferenceX2D = (startingPlayerX - endingPlayerX) ^ 2
	local DifferenceY2D = (startingPlayerY - endingPlayerY) ^ 2
	local DifferenceZ2D = (startingPlayerZ - endingPlayerZ) ^ 2
	local fallingDirection = (startingPlayerY - endingPlayerY) < 0
	local playerState = Player.Character.Humanoid:GetState()
	local playerBackpack = Player.Backpack:GetChildren()
	
	if DifferenceX2D < 0 then
		DifferenceX2D = DifferenceX2D * -1
	end
	if DifferenceZ2D < 0 then
		DifferenceZ2D = DifferenceZ2D * -1
	end
	
	distance2D = math.sqrt(DifferenceX2D + DifferenceZ2D)
	distanceY = startingPlayerY - endingPlayerY
	print(distance2D, distanceY)
	
	if ((distance2D > (speed/8) or DifferenceY2D > 31)) and isSitting == false and distanceY < 0 then
		if playerState ~= Enum.HumanoidStateType.Seated then
			flagCounter += 1
		end
	end 
	
	if (((distanceY < 0.02 and Humanoid2.Jump == false and isJumping == false) and isSitting == false) and (playerState == Enum.HumanoidStateType.PlatformStanding or playerState == Enum.HumanoidStateType.Flying)) then
		if playerState ~= Enum.HumanoidStateType.Seated then -- needs testing
			flagCounter += 1
		end
	end
	
	if distance2D > (speed/7) then
		if playerState ~= Enum.HumanoidStateType.Seated then
			flagCounter += 3
		end
	end
	
	if distanceY < -6 then
		if playerState ~= Enum.HumanoidStateType.Seated then
			flagCounter += 3
			print("lol")
		end
	end
	
	
	
	if game.Players.LocalPlayer.Character.Humanoid.WalkSpeed > speed then
		flagCounter += 3
	end

	if game.Players.LocalPlayer.Character.Humanoid.JumpPower > jumppower then
		flagCounter += 3
	end
	
	if next(playerBackpack) ~= nil and backpackAllowed == false then
		flagCounter += 3
	end
	
	if Humanoid.CanCollide == false then
		flagCounter += 3
	end
	
	if flagCounter >= 9 then
		Humanoid.Anchored = true
		remoteEvent:FireServer()
	end
	
	if loopCounter >= 50 then
		loopCounter = 0
		flagCounter = 0
	else
		loopCounter += 1
	end
	
	if playerState == Enum.HumanoidStateType.Running then
		isJumping = false
		isSitting = false
	end
	
	loopCounter += 1
end