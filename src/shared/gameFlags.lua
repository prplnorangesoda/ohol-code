local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameFlagsModule = {}
local gameFlags = ReplicatedStorage:WaitForChild("GAMEFLAGS")
local flags: { [string]: BoolValue } = {
	["Debug"] = gameFlags.Debug,
	["FoodGen"] = gameFlags.FoodGen,
}

---Get the state of the specified flag.
gameFlagsModule.getFlag = function(flag: string): boolean
	local value = flags[flag].Value
	if value == nil then
		error("Flag not found: " .. flag)
	end
	return value
end

return gameFlagsModule
