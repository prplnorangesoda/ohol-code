---@diagnostic disable: undefined-global
local map = remodel.readPlaceFile("ohol-fullymanaged.rbxl")

local SERVICES = { "Workspace" }
for _, serviceName in ipairs(SERVICES) do
	local service = map[serviceName]

	remodel.writeModelFile("assets/Workspace.rbxm", service)
end
