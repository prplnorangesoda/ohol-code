local TIME_BEFORE_KICK = 60 * 60 -- 60 Minutes in Seconds
local ServerScriptService = game:GetService("ServerScriptService")
local newTimerModule = require(ServerScriptService.Server.modules.newTimerModule)
local playerTickModule = require(ServerScriptService.Server.modules.playerTickModule)

local initializeModule = {}

initializeModule.initPlayer = function(player: Player)
	local timer = newTimerModule.new(player, TIME_BEFORE_KICK)

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
		end
	end)

	local thirstValue = Instance.new("NumberValue")
	thirstValue.Name = "Thirst"
	thirstValue.Value = 350
	thirstValue.Parent = statsFolder
	thirstValue.Changed:Connect(function(value)
		if value > 500 then
			thirstValue.Value = 500
		end
	end)

	local playerTickRoutine = coroutine.create(function()
		playerTickModule.new(statsFolder)
	end)

	coroutine.resume(playerTickRoutine)
end

return initializeModule
