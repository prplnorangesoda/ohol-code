local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameFlagsModule = {}
local gameFlags = ReplicatedStorage:WaitForChild("GAMEFLAGS")
local flags: { [string]: BoolValue } = {
	["Debug"] = gameFlags.Debug,
}

---Get the state of the specified flag.
gameFlagsModule.getFlag = function(flag: string): boolean
	return flags[flag].Value or error("Flag not found: ", flag)
end

return gameFlagsModule
