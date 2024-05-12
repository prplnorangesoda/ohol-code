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

	local whatToDoForEachFoodType = {
		["apple"] = ReplicatedStorage.Food.apple,
		["bacon cheeseburger"] = ReplicatedStorage.Food["bacon cheeseburger"],
	}

	local foodItem = whatToDoForEachFoodType[foodType]

	local fruitSpawningRoutine = coroutine.create(function()
		while task.wait(2) do
			local newFruit: Tool = foodItem:Clone()
			newFruit.Parent = tree
			newFruit.PrimaryPart.Anchored = true
			print(leaves.CFrame + determineSpawningLocationInLeavesRandomly(leaves.Size))
			newFruit.PrimaryPart:PivotTo(leaves.CFrame + determineSpawningLocationInLeavesRandomly(leaves.Size))
		end
	end)

	coroutine.resume(fruitSpawningRoutine)
	print(trunk, leaves, foodType)
end
return treeModule
