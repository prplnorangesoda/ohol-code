local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ROJOSCRIPTS = game:GetService("ServerScriptService").Server
local worldgenModule = require(ROJOSCRIPTS.modules.worldgen)

worldgenModule.initialWorldGenerated.Event:Connect(function()
	ReplicatedStorage.Shared.remotes.ServerLoaded:FireAllClients()
end)
