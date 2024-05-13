local ServerStorage = game:GetService("ServerStorage")

local HEIGHT_SEED = 12
local MOISTURE_SEED = 30

-- 0 = perfect smooth
-- up to 1 = more aggressive
local SMOOTH = 0.05

local SIZE = 100

local biomeBlocks: { Part } = {
	["grass"] = ServerStorage:WaitForChild("BasicPart"),
	["dead"] = ServerStorage:WaitForChild("DeadPart"),
}

local function getRelativeHeight(x, z)
	local noise = math.noise(x * SMOOTH, z * SMOOTH, HEIGHT_SEED)

	-- bias towards the lower ends of noise. see: https://www.redblobgames.com/maps/terrain-from-noise/#elevation-redistribution
	-- add 0.5 to put value between 0 to 1
	noise = math.pow(noise + 0.5, 2)

	return noise
end

local function getMoisture(x, z): string
	local noise = math.noise(x * SMOOTH, z * SMOOTH, MOISTURE_SEED)
	noise += 0.5 -- get a value between 0-1

	if noise >= 0.5 then
		return "HIGH"
	else
		return "LOW"
	end
end

local function drawTerrain()
	for i = 1, SIZE do
		for j = 1, SIZE do
			local height = getRelativeHeight(i, j)
			local moisture = getMoisture(i, j)
			local blockHeight = math.floor(height * 16)
			local block
			if moisture == "HIGH" then
				block = biomeBlocks.grass:Clone()
			else
				block = biomeBlocks.dead:Clone()
			end

			block.Parent = workspace.procgen
			block.CFrame = CFrame.new(i * 4, blockHeight, j * 4)
		end
	end
end

drawTerrain()
