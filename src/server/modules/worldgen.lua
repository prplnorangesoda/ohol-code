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
local SMOOTH = 0.02
local BIOME_SMOOTH = 0.05

local AMPLITUDE = 2

local SIZE = 100
local CHUNK_SIZE = 32
local BLOCK_SIZE = 8
local generatingThread

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
	noise = math.pow(noise + 0.5, 3)

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
	local noise = math.noise(x * BIOME_SMOOTH, z * BIOME_SMOOTH, MOISTURE_SEED)
	noise += 0.5 -- get a value between 0-1

	if noise >= 0.3 then
		return "HIGH"
	else
		return "LOW"
	end
end

local function generateChunk(xChunkCoord: number, zChunkCoord: number)
	local chunkFolder = Instance.new("Folder")
	chunkFolder.Name = "chunk" .. xChunkCoord .. " " .. zChunkCoord
	chunkFolder.Parent = worldgenFolder

	for i = 1, CHUNK_SIZE do
		local realX = i + (CHUNK_SIZE * xChunkCoord)
		for j = 1, CHUNK_SIZE do
			local realZ = j + (CHUNK_SIZE * zChunkCoord)

			local height = getRelativeHeight(realX, realZ)
			local moisture = getMoisture(realX, realZ)
			local blockHeight = math.floor(height * (50 * AMPLITUDE))
			local block
			if moisture == "HIGH" then
				block = biomeBlocks.grass:Clone()
			else
				block = biomeBlocks.dead:Clone()
			end

			block.Parent = chunkFolder
			-- a bit complicated: set the position to x|z - SIZE / 2 in order to center the map. This means that the true origin is the bottom right.
			block.CFrame = CFrame.new(realX * BLOCK_SIZE, blockHeight, realZ * BLOCK_SIZE)
		end
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
	generatingThread = task.spawn(function()
		for i = 1, SIZE do
			for j = 1, SIZE do
				task.spawn(generateChunk, i, j)
				task.wait(0.1)
				-- task.spawn(function()
				-- 	local height = getRelativeHeight(i, j)
				-- 	local moisture = getMoisture(i, j)
				-- 	local blockHeight = math.floor(height * (50 * AMPLITUDE))
				-- 	local block
				-- 	if moisture == "HIGH" then
				-- 		block = biomeBlocks.grass:Clone()
				-- 	else
				-- 		block = biomeBlocks.dead:Clone()
				-- 	end

				-- 	block.Parent = worldgenFolder
				-- 	-- a bit complicated: set the position to x|z - SIZE / 2 in order to center the map. This means that the true origin is the bottom right.
				-- 	block.CFrame = CFrame.new((i - SIZE / 2) * BLOCK_SIZE, blockHeight, (j - SIZE / 2) * BLOCK_SIZE)
				-- end)
			end
		end
		worldCurrentlyGenerated = true
	end)
end

--- Clear all generated terrain.
function worldgenModule.clearTerrain()
	-- Halt terrain generation
	if generatingThread then
		task.cancel(generatingThread)
	end
	worldgenFolder:ClearAllChildren()
	worldCurrentlyGenerated = false
end

return worldgenModule
