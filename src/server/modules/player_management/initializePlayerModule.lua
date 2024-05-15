local TIME_BEFORE_KICK = 60 * 60 -- 60 Minutes in Seconds
local Teams = game:GetService("Teams")
local newTimerModule = require(script.Parent.newTimerModule)
local playerTickModule = require(script.Parent.playerTickModule)
local playerAgeModule = require(script.Parent.handlePlayerAge)

local initializeModule = {}

initializeModule.initPlayer = function(player: Player)
	local timer = newTimerModule.new(player, TIME_BEFORE_KICK)

	player.Team = Teams.Ingame
	player:FindFirstChild("IsPlaying").Value = true
	player:LoadCharacter()
	local timerRoutine = coroutine.create(function()
		timer:StartSession()
	end)

	coroutine.resume(timerRoutine)

	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "PlayerStats"
	statsFolder.Parent = player

	local hungerValue = Instance.new("NumberValue")
	hungerValue.Name = "Hunger"
	hungerValue.Value = 200
	hungerValue.Parent = statsFolder
	hungerValue.Changed:Connect(function(value)
		if value > 300 then
			hungerValue.Value = 300
		elseif value < 0 then
			hungerValue.Value = 0
		end
	end)

	local thirstValue = Instance.new("NumberValue")
	thirstValue.Name = "Thirst"
	thirstValue.Value = 350
	thirstValue.Parent = statsFolder
	thirstValue.Changed:Connect(function(value)
		if value > 500 then
			thirstValue.Value = 500
		elseif value < 0 then
			thirstValue.Value = 0
		end
	end)

	local _playerTickRoutine = task.spawn(function()
		playerTickModule.new(statsFolder)
	end)

	local _handlePlayerAge = task.spawn(function()
		playerAgeModule.new(player)
	end)
end

return initializeModule
