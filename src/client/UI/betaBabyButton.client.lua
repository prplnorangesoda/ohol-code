local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer
local gui = plr.PlayerGui

local babyButton: TextButton = gui:WaitForChild("GameUI"):WaitForChild("BabyButton")

babyButton.Activated:Connect(function()
	local childEvent: RemoteEvent = ReplicatedStorage.Remotes.MakeChild
	childEvent:FireServer()
end)