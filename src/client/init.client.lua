local Players = game:GetService("Players")
-- init.client = StarterPlayerScripts.Client
print("Hello world, from client!")
Players.LocalPlayer.PlayerGui:WaitForChild("Chat").Enabled = false
