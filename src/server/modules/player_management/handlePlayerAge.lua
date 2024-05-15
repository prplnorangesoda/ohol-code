local playerAgeModule = {}

local innerPlayerAgeModule = {
	["Player"] = nil,
	["Character"] = nil,
}

playerAgeModule.new = function(player: Player)
	local self = table.clone(innerPlayerAgeModule)
	self.Player = player
	if not player.Character then
		player.CharacterAdded:Wait()
	end
	self.Character = player.Character

	local timeRemainingValue: IntValue = player:WaitForChild("TimeRemaining")
	timeRemainingValue.Changed:Connect(function(value)
		local timeAlive = 3600 - value

		local yearsAlive = math.floor(timeAlive / 60)

		local nametag = player.Character:WaitForChild("Nametag", 0.5)
		if not nametag then
			return
		end
		local yearsAliveText
		if yearsAlive == 1 then
			yearsAliveText = "1 year alive"
		else
			yearsAliveText = yearsAlive .. " years alive"
		end
		nametag.YearsAlive.Text = yearsAliveText
		print(yearsAlive)
	end)
	return self
end

return playerAgeModule
