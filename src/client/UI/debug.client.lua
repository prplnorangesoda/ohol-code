local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if (not RunService:IsStudio()) or not ReplicatedStorage.GAMEFLAGS.Debug.Value then
	print("Not initializing debug UI")
	return
end
print("initializing debug UI")
local plr = game.Players.LocalPlayer

local debugContainer = Instance.new("ScreenGui")
debugContainer.Parent = plr.PlayerGui

local debugUIFrame = Instance.new("Frame")
debugUIFrame.Position = UDim2.fromScale(1, 1)
debugUIFrame.AnchorPoint = Vector2.new(1, 1)
debugUIFrame.Size = UDim2.fromOffset(400, 100)
debugUIFrame.Parent = debugContainer

Instance.new("UIGridLayout").Parent = debugUIFrame

-- create simple event firing UI

local debugEvents = ReplicatedStorage.Shared.remotes.debug:GetChildren()
for _, event: RemoteEvent in ipairs(debugEvents) do
	if not event:IsA("RemoteEvent") then
		continue
	end
	local textButton = Instance.new("TextButton")
	textButton.Text = event.Name
	textButton.TextWrapped = true
	textButton.Activated:Connect(function()
		event:FireServer()
	end)
	textButton.Parent = debugUIFrame
end

-- create number event firing ui

local numberEvents: { RemoteEvent } = ReplicatedStorage.Shared.remotes.debug.number:GetChildren()
local debugUI: Folder = ReplicatedStorage:WaitForChild("DebugUI")
local frame: ScrollingFrame = debugUI.ScrollingFrame:Clone()
frame.Parent = debugContainer

for _, event in ipairs(numberEvents) do
	if not event:IsA("RemoteEvent") then
		continue
	end
	local container: Frame = debugUI.DebugNumberContainer:Clone()
	local valueEntry = container:FindFirstChildWhichIsA("TextBox")
	local button = container:FindFirstChildWhichIsA("TextButton")
	button.Text = event.Name
	button.Activated:Connect(function()
		event:FireServer(valueEntry.Text)
	end)
	container.Parent = frame
end
