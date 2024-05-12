-- init.server = ServerScriptService.Server
print("Hello world, from server!")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TIME_BEFORE_FOOD_SPAWN = 2

local spawnFood = coroutine.create(function()
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
end)

coroutine.resume(spawnFood)
