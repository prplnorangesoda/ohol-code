local playerDrinkingModule = {}

local currentPlayersDrinking: { [number]: thread } = {}
playerDrinkingModule.addPlayerDrinking = function(player: Player)
	print("adding player", player)
	if currentPlayersDrinking[player.UserId] then
		return
	end
	table.insert(
		currentPlayersDrinking,
		player.UserId,
		task.spawn(function()
			while task.wait(1) do
				player.PlayerStats.Thirst.Value += 20
			end
		end)
	)
	print(currentPlayersDrinking)
end
playerDrinkingModule.removePlayerDrinking = function(player: Player)
	if currentPlayersDrinking[player.UserId] == nil then
		return
	end
	print("removing player", player)
	task.cancel(currentPlayersDrinking[player.UserId])
	currentPlayersDrinking[player.UserId] = nil
	print(currentPlayersDrinking)
end

return playerDrinkingModule
