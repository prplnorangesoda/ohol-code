local ROJOSCRIPTS = game:GetService("ServerScriptService").Server
local worldgenModule = require(ROJOSCRIPTS.modules.worldgen)
local loadstateModule = {}

loadstateModule.isServerLoaded = function()
	return worldgenModule.isInitialWorldGenerated
end

loadstateModule.serverLoaded = worldgenModule.initialWorldGenerated
return loadstateModule
