local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	print("Not registering debug event handlers")
	return
end

print("Is Studio, registering debug event handlers")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local worldgenModule = require(ServerScriptService.Server.modules.worldgen)
local debugEvents = ReplicatedStorage.Shared.remotes.debug

debugEvents.SetWorldGenSeed.OnServerEvent:Connect(function(player, seed: number | nil)
	print(player, "requested seed", seed)
	worldgenModule.setSeed(seed)
end)
debugEvents.GenWorld.OnServerEvent:Connect(function(player)
	print(player, "requested terrain generation")
	worldgenModule.drawTerrain()
end)
debugEvents.ClearWorldGen.OnServerEvent:Connect(function(player)
	print(player, "requested terrain clear")
	worldgenModule.clearTerrain()
end)
