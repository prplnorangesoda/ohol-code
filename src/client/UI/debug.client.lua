local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	print("Not initializing debug UI")
	return
end
print("initializing debug UI")
local plr = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local debugContainer = Instance.new("ScreenGui")
debugContainer.Parent = plr.PlayerGui

local debugUIFrame = Instance.new("Frame")
debugUIFrame.Position = UDim2.fromScale(1, 1)
debugUIFrame.AnchorPoint = Vector2.new(1, 1)
debugUIFrame.Size = UDim2.fromOffset(400, 200)
debugUIFrame.Parent = debugContainer

Instance.new("UIGridLayout").Parent = debugUIFrame
local debugEvents: { RemoteEvent } = ReplicatedStorage.Shared.remotes.debug:GetChildren()

for _, event in ipairs(debugEvents) do
	local textButton = Instance.new("TextButton")
	textButton.Text = event.Name
	textButton.TextWrapped = true
	textButton.Activated:Connect(function()
		event:FireServer()
	end)
	textButton.Parent = debugUIFrame
end
