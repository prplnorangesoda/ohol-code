local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameFlagsModule = {}
local gameFlags = ReplicatedStorage:WaitForChild("GAMEFLAGS")
local flags: { [string]: BoolValue } = {
	["Debug"] = gameFlags.Debug,
	["FoodGen"] = gameFlags.FoodGen,
	["VisualizeNoise"] = gameFlags.VisualizeNoise,
}

---Get the state of the specified flag.
gameFlagsModule.getFlag = function(flag: string): boolean
	local value = flags[flag]
	if value == nil then
		error("Flag not found: " .. flag)
	end
	return value.Value
end

return gameFlagsModule
