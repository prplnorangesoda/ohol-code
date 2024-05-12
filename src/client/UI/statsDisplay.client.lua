local Players = game:GetService("Players")
local function normalizeToRange(value, min, max)
	return (value - min) / (max - min)
end

local function normalizeThirst(value)
	return normalizeToRange(value, 0, 500)
end

local function normalizeHunger(value)
	return normalizeToRange(value, 0, 300)
end


-- debug
-- print(normalizeHunger(0),normalizeHunger(50),normalizeHunger(150))
-- print(normalizeThirst(0),normalizeThirst(50),normalizeThirst(300))

local plr = Players.LocalPlayer
local gui = plr.PlayerGui

local statsFolder: Folder = plr:WaitForChild("PlayerStats")

local thirstValue: NumberValue = statsFolder:WaitForChild("Thirst")
local hungerValue: NumberValue = statsFolder:WaitForChild("Hunger")

local ThirstValueElement: TextLabel = gui.GameUI.Stats.ThirstBG.ThirstValue
local HungerValueElement: TextLabel = gui.GameUI.Stats.HungerBG.HungerValue

ThirstValueElement.Size = UDim2.fromScale(normalizeThirst(thirstValue.Value), 1)
HungerValueElement.Size = UDim2.fromScale(normalizeHunger(hungerValue.Value), 1)

thirstValue.Changed:Connect(function(value)
	ThirstValueElement.Size = UDim2.fromScale(normalizeThirst(value), 1)
end)
hungerValue.Changed:Connect(function(value)
	HungerValueElement.Size = UDim2.fromScale(normalizeHunger(value), 1)
end)



