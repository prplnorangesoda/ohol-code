local ReplicatedStorage = game:GetService("ReplicatedStorage")
local treeModule = {}

local function determineSpawningLocationInLeavesRandomly(leavesSize: Vector3)
	local rotation = math.random(0, 360)
	local rads = math.rad(rotation)
	local distX = math.cos(rads) * leavesSize.X / 2
	local distZ = math.sin(rads) * leavesSize.X / 2
	print(distX, distZ)
	return Vector3.new(distX, 0, distZ)
end

treeModule.createTreeFrom = function(tree: Model, foodType: string)
	local trunk: Part = tree["Trunk"] or error("No trunk in" .. tree)
	local leaves: Part = tree["Leaves"] or error("No leaves in" .. tree)
	local proxPrompt: ProximityPrompt = tree.Trunk.TreeShakePrompt

	local whatToDoForEachFoodType = {
		["apple"] = ReplicatedStorage.Food.apple,
		["bacon cheeseburger"] = ReplicatedStorage.Food["bacon cheeseburger"],
	}

	local foodItem = whatToDoForEachFoodType[foodType]

	local fruitSpawningRoutine = coroutine.create(function() -- Coroutine Vs Task spawn
		local fruitSpawned = 0
		while task.wait(math.random(45, 180)) do
			if fruitSpawned >= 5 then
				continue
			end
			local newFruit: Tool = foodItem:Clone()
			newFruit.Parent = tree
			newFruit.PrimaryPart.Anchored = true
			newFruit.PrimaryPart:PivotTo(leaves.CFrame + determineSpawningLocationInLeavesRandomly(leaves.Size))
		end
	end)

	proxPrompt.Triggered:Connect(function()
		local treeChildren = tree:GetChildren()

		for _, value in treeChildren do
			if value.ClassName == "Tool" then
				value.Handle.Anchored = false
			end
		end
	end)
	coroutine.resume(fruitSpawningRoutine)
	print(trunk, leaves, foodType)
end
return treeModule
