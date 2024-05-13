-- init.server = ServerScriptService.Server
print("Hello world, from server!")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Flags = require(ReplicatedStorage.Shared.gameFlags)

local TIME_BEFORE_FOOD_SPAWN = 2
local function foodDebugSpawner()
	while task.wait(TIME_BEFORE_FOOD_SPAWN) do
		local randVal = math.random(1, 2)

		local foodToClone

		if randVal == 1 then
			foodToClone = ReplicatedStorage.Food.apple
		else
			foodToClone = ReplicatedStorage.Food["bacon cheeseburger"]
		end

		local spawnedFood = foodToClone:Clone()
		spawnedFood.Parent = workspace
		spawnedFood:PivotTo(CFrame.new(0, 150, 0))
	end
end

if RunService:IsStudio() and Flags.getFlag("Debug") then
	task.spawn(foodDebugSpawner)
end

-- spawn trees

-- for _, value: Part in workspace.Saved.TreeSpawnpoints:GetChildren() do
-- 	local clonedTree = ReplicatedStorage.BasicTree:Clone()
-- 	clonedTree:PivotTo(value.CFrame)
-- 	clonedTree.Parent = workspace
-- end
