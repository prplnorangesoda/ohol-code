local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local queuingPlayersModule = require(ServerScriptService.Server.modules.queuingPlayersModule)
local initializeModule = require(ServerScriptService.Server.modules.initializePlayerModule)

local remoteEvents: Folder = ReplicatedStorage.Shared.remotes

local babyEvent: RemoteEvent = remoteEvents.MakeChild
babyEvent.OnServerEvent:Connect(function(player)
	if player.PlayerStats.Hunger.Value >= 150 and player.PlayerStats.Thirst.Value >= 250 then
		local playerToBaby = queuingPlayersModule.getPlayerToAdd()
		player.PlayerStats.Hunger.Value -= 100
		player.PlayerStats.Thirst.Value -= 200
		initializeModule.initPlayer(playerToBaby)
		playerToBaby.Character:PivotTo(player.Character.PrimaryPart.CFrame)
	end
end)
