local ServerScriptService = game:GetService("ServerScriptService")
local kickPlayer = require(ServerScriptService.Server.modules.kickModule).kick
-- redoing this
local innerTimerModule = {
	Player = nil,
	TimeIntVal = nil
}
local playerTimerModulePairs = {}


function innerTimerModule:StartSession()
	print("timer session started", self.Player, self.TimeIntVal)

	while task.wait(1) do
		self.TimeIntVal.Value -= 1

		if self.TimeIntVal.Value <= 0 then
			kickPlayer(self.Player)
			break
		end
	end
end

function innerTimerModule:KickEarly()
	kickPlayer(self.Player)
end


local TimerModule = {}

---create a new TimerModule with
---@param player Player the player to which this timer applies
---@param timeSeconds number the time (in seconds) until timer ends when the session starts
---
TimerModule.new = function(player: Player, timeSeconds: number)
	local self = table.clone(innerTimerModule)

	self.Player = player

	local timeIntVal = Instance.new("IntValue")
	timeIntVal.Name = "TimeRemaining"
	timeIntVal.Value = timeSeconds
	timeIntVal.Parent = player
	self.TimeIntVal = timeIntVal

	playerTimerModulePairs[player.UserId] = self
	print(playerTimerModulePairs)
	return self
end

TimerModule.findModuleFromPlayerID = function(playerID: number)
	return playerTimerModulePairs[playerID]
end




return TimerModule