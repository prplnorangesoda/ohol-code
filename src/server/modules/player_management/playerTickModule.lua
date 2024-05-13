local playerTickModule = {}

--- run this in a coroutine
playerTickModule.new = function(statsFolder)
	print(statsFolder)
	local playerThirst: NumberValue = statsFolder.Thirst
	local playerHunger: NumberValue = statsFolder.Hunger

	while task.wait(1) do
		playerThirst.Value = playerThirst.Value - 0.8
		playerHunger.Value = playerHunger.Value - 0.3
	end

end

return playerTickModule