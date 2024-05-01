local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local queuingPlayersModule = require(ServerScriptService.Server.modules.queuingPlayersModule)
local initializeModule = require(ServerScriptService.Server.modules.initializePlayerModule)

local remoteEvents: Folder = ReplicatedStorage.Remotes

local babyEvent: RemoteEvent = remoteEvents.MakeChild
babyEvent.OnServerEvent:Connect(function(player)
	local playerToBaby = queuingPlayersModule.getPlayerToAdd()
	initializeModule.initPlayer(playerToBaby)
	playerToBaby.Character:PivotTo(player.Character.PrimaryPart.CFrame)
end)