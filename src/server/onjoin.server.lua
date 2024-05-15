local Players = game:GetService("Players")
local ROJOSCRIPTS = game:GetService("ServerScriptService").Server
local newTimerModule = require(ROJOSCRIPTS.modules.player_management.newTimerModule)
local queuingPlayersModule = require(ROJOSCRIPTS.modules.player_management.queuingPlayersModule)
local initializeModule = require(ROJOSCRIPTS.modules.player_management.initializePlayerModule)
local loadstateModule = require(ROJOSCRIPTS.modules.loadstate)
local playerDrinkingModule = require(ROJOSCRIPTS.modules.player_management.playerDrinkingModule)

local function onCharacterAdded(character: Model)
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		local player = Players:GetPlayerFromCharacter(character)
		if player == nil then
			return
		end
		playerDrinkingModule.removePlayerDrinking(player)
		task.wait(5)
		newTimerModule.findModuleFromPlayerID(player.UserId):KickEarly()
	end)
	humanoid.StateChanged:Connect(function(old, new)
		task.wait(0.3)
		if new == Enum.HumanoidStateType.Swimming then
			playerDrinkingModule.addPlayerDrinking(Players:GetPlayerFromCharacter(character))
		elseif old == Enum.HumanoidStateType.Swimming then
			playerDrinkingModule.removePlayerDrinking(Players:GetPlayerFromCharacter(character))
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

	if not loadstateModule.isServerLoaded() then
		loadstateModule.serverLoaded.Event:Wait()
	end
	if not hasFirstPlayerSpawned then
		hasFirstPlayerSpawned = true
		print("loading First player")
		initializeModule.initPlayer(player)
	else
		queuingPlayersModule.addPlayer(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	playerDrinkingModule.removePlayerDrinking(player)
end)
