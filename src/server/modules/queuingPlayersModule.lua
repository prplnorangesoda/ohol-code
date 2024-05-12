local Teams = game:GetService("Teams")
local queuingPlayersModule = {}
local queuingPlayers = {}

queuingPlayersModule.addPlayer = function(player: Player)
	table.insert(queuingPlayers, player)
	player.Team = Teams.Waiting
	return queuingPlayers
end

queuingPlayersModule.getPlayerToAdd = function(): Player
	local playerToAdd: Player = table.remove(queuingPlayers, 1) or error("Found no player in queuingPlayers")
	playerToAdd.Team = Teams.Ingame
	return playerToAdd
end

return queuingPlayersModule
