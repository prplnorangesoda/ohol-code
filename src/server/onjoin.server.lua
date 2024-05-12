local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local newTimerModule = require(ServerScriptService.Server.modules.newTimerModule)
local queuingPlayersModule = require(ServerScriptService.Server.modules.queuingPlayersModule)
local initializeModule = require(ServerScriptService.Server.modules.initializePlayerModule)

local function onCharacterAdded(character: Model)
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		local player = Players:GetPlayerFromCharacter(character)
		if player == nil then
			return
		end
		while task.wait(5) do
			newTimerModule.findModuleFromPlayerID(player.UserId):KickEarly()
			break
		end
	end)

	print(character, " has spawned")
end

local function onCharacterRemoving(character: Model)
	print(character, " is despawning")
end

local hasFirstPlayerSpawned = false

Players.PlayerAdded:Connect(function(player)
	local IsPlaying = Instance.new("BoolValue")
	IsPlaying.Name = "IsPlaying"
	IsPlaying.Value = false
	IsPlaying.Parent = player

	player.CharacterAdded:Connect(onCharacterAdded)
	player.CharacterRemoving:Connect(onCharacterRemoving)

	if not hasFirstPlayerSpawned then
		hasFirstPlayerSpawned = true
		print("loading First player")
		initializeModule.initPlayer(player)
	else
		queuingPlayersModule.addPlayer(player)
	end
end)
