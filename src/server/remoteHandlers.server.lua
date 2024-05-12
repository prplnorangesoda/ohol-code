local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local queuingPlayersModule = require(ServerScriptService.Server.modules.queuingPlayersModule)
local initializeModule = require(ServerScriptService.Server.modules.initializePlayerModule)

local remoteEvents: Folder = ReplicatedStorage.Shared.remotes

local babyRequestDebounce = false
local babyEvent: RemoteEvent = remoteEvents.MakeChild
babyEvent.OnServerEvent:Connect(function(player)
	if babyRequestDebounce then
		return
	end
	if player.PlayerStats.Hunger.Value < 150 or player.PlayerStats.Thirst.Value < 250 then
		return
	end

	local wasPlayerFound, playerToBaby = pcall(function()
		return queuingPlayersModule.getPlayerToAdd()
	end)
	-- if it recently failed, cool off for 0.5 seconds so we don't spam the server
	if not wasPlayerFound then
		print("No player found. Debouncing")
		task.spawn(function()
			babyRequestDebounce = true
			task.wait(0.5)
			babyRequestDebounce = false
		end)
		return
	end

	-- successful, subtract cost of pregnancy and init new player
	player.PlayerStats.Hunger.Value -= 100
	player.PlayerStats.Thirst.Value -= 200
	initializeModule.initPlayer(playerToBaby)
	playerToBaby.Character:PivotTo(player.Character.PrimaryPart.CFrame)
end)
