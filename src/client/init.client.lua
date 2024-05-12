local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
-- init.client = StarterPlayerScripts.Client
print("Hello world, from client!")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
Players.LocalPlayer.PlayerGui:WaitForChild("Chat").Enabled = false
