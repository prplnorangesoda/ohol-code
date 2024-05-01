-- init.server = ServerScriptService.Server
print("Hello world, from server!")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local spawnFood = coroutine.create(function()
	while task.wait(0.5) do
		local randVal = math.random(1, 2)
		print(randVal)

		local foodToClone

		if randVal == 1 then
			foodToClone = ReplicatedStorage.Shared.apple
		else
			foodToClone = ReplicatedStorage.Shared["bacon cheeseburger"]
		end

		local spawnedFood = foodToClone:Clone()
		spawnedFood.Parent = workspace
		spawnedFood:PivotTo(CFrame.new(0, 150, 0))
	end
end)

coroutine.resume(spawnFood)
