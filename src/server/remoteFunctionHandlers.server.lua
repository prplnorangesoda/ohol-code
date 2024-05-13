local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ROJOSCRIPTS = game:GetService("ServerScriptService").Server
local loadStateModule = require(ROJOSCRIPTS.modules.loadstate)

local remoteFunctions = ReplicatedStorage.Shared.remotes.funcs

remoteFunctions.IsServerLoaded.OnServerInvoke = function()
	return loadStateModule.isServerLoaded()
end
