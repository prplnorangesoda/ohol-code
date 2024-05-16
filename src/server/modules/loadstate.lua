local ROJOSCRIPTS = game:GetService("ServerScriptService").Server
local worldgenModule = require(ROJOSCRIPTS.modules.worldgen)
local loadstateModule = {}

loadstateModule.isServerLoaded = function()
	return worldgenModule.isInitialWorldGenerated
end

loadstateModule.loadStateChanged = Instance.new("BindableEvent")
--- -1 = done
---
--- 0-any = state of loading
loadstateModule.getLoadState = function()
	if worldgenModule.isInitialWorldGenerated == true then
		return -1
	elseif worldgenModule.isTerrainGenerated then
		return 1
	elseif worldgenModule.isPoissonDiskGenerated then
		return 2
	elseif worldgenModule.isTreesPlaced then
		return 3
	else
		return 0
	end
end

worldgenModule.initialWorldGenerated.Event:Connect(function()
	loadstateModule.loadStateChanged:Fire(-1)
end)
worldgenModule.terrainGenerated.Event:Connect(function()
	loadstateModule.loadStateChanged:Fire(1)
end)
worldgenModule.poissonDiskGenerated.Event:Connect(function()
	loadstateModule.loadStateChanged:Fire(2)
end)
worldgenModule.treesPlaced.Event:Connect(function()
	loadstateModule.loadStateChanged:Fire(3)
end)

loadstateModule.serverLoaded = worldgenModule.initialWorldGenerated
return loadstateModule
