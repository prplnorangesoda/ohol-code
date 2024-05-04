local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
-- init.client = StarterPlayerScripts.Client
print("Hello world, from client!")
Players.LocalPlayer.PlayerGui:WaitForChild("Chat").Enabled = false
