local queuingPlayersModule = {}
local queuingPlayers = {}

queuingPlayersModule.addPlayer = function(player: Player)
	table.insert(queuingPlayers, player)
	return queuingPlayers
end

queuingPlayersModule.getPlayerToAdd = function(): Player
	return table.remove(queuingPlayers, 1) or error("Found no player in queuingPlayers")
end

return queuingPlayersModule