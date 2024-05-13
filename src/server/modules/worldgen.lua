local ServerStorage = game:GetService("ServerStorage")
local worldgenModule = {}

local worldgenFolder: Folder = workspace:WaitForChild("procgen")

local BASE_SEED, HEIGHT_SEED, MOISTURE_SEED
local seedSet, worldCurrentlyGenerated = false, false

---Set the seed used by the world generator.
---@param seed number|nil The seed to set. If left blank, will be randomly generated.
function worldgenModule.setSeed(seed)
	if seed == nil then
		BASE_SEED = math.random(1, 1e9)
	else
		BASE_SEED = seed
	end
	HEIGHT_SEED = BASE_SEED
	MOISTURE_SEED = (HEIGHT_SEED + 30) / 4

	seedSet = true
	print("SERVER SEED SET:", BASE_SEED)
end

-- 0 = perfect smooth
-- up to 1 = more aggressive
local SMOOTH = 0.05

local SIZE = 100

local biomeBlocks: { Part } = {
	["grass"] = ServerStorage:WaitForChild("BasicPart"),
	["dead"] = ServerStorage:WaitForChild("DeadPart"),
}

local function getRelativeHeight(x, z)
	if not seedSet then
		error("Seed not set")
	end
	local noise = math.noise(x * SMOOTH, z * SMOOTH, HEIGHT_SEED)

	--- bias towards the lower ends of noise.
	-- @see https://www.redblobgames.com/maps/terrain-from-noise/#elevation-redistribution

	-- add 0.5 to put value between 0 to 1
	noise = math.pow(noise + 0.5, 2)

	return noise
end

---Get the moisture for a 2D position using the moisture noisemap.
---@param x number X coordinate
---@param z number Z coordinate
---@return string
local function getMoisture(x, z): string
	if not seedSet then
		error("Seed not set")
	end
	local noise = math.noise(x * SMOOTH, z * SMOOTH, MOISTURE_SEED)
	noise += 0.5 -- get a value between 0-1

	if noise >= 0.3 then
		return "HIGH"
	else
		return "LOW"
	end
end

--- Generates procgen terrain with the set seed.
--- Requires `worldgenModule.setSeed` to be run first.
function worldgenModule.drawTerrain()
	if not seedSet then
		error("Seed not set")
	end
	if worldCurrentlyGenerated then
		warn("World is already generated. Possible double run?")
	end
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

			block.Parent = worldgenFolder
			block.CFrame = CFrame.new(i * 4, blockHeight, j * 4)
		end
	end
	worldCurrentlyGenerated = true
end

--- Clear all generated terrain.
function worldgenModule.clearTerrain()
	worldgenFolder:ClearAllChildren()
	worldCurrentlyGenerated = false
end

return worldgenModule
