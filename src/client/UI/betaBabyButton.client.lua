local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer
local playerStats: Folder = plr:WaitForChild("PlayerStats")
local gui = plr.PlayerGui

local babyButton: TextButton = gui:WaitForChild("GameUI"):WaitForChild("BabyButton")

babyButton.Activated:Connect(function()
	local childEvent: RemoteEvent = ReplicatedStorage.Shared.remotes.MakeChild
	local Hunger: NumberValue, Thirst: NumberValue = playerStats.Hunger, playerStats.Thirst
	if Hunger.Value >= 150 and Thirst.Value >= 250 then
		childEvent:FireServer()
	end
end)
