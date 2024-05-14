local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ReplicatedStorage.Shared.gameGlobals)
local water: Part = ReplicatedStorage:WaitForChild("Water"):Clone()

-- ugly!
water.CFrame = CFrame.new(0, Globals.worldGen.SEA_LEVEL + 0.8, 0)
water.Size = Vector3.new(1, Globals.worldGen.SEA_LEVEL + 0.8, 1)
water.Parent = workspace
