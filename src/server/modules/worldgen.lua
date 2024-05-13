local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local worldgenModule = {}

local worldgenFolder: Folder = workspace:WaitForChild("procgen")

local BASE_SEED, HEIGHT_SEED, MOISTURE_SEED
local seedSet, worldCurrentlyGenerated = false, false

worldgenModule.initialWorldGenerated = Instance.new("BindableEvent")
worldgenModule.isInitialWorldGenerated = false

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
local BIOME_SMOOTH = 0.02

local AMPLITUDE = 2

local INITIAL_SIZE = 5
local CHUNK_SIZE = 32
local BLOCK_SIZE = 8

local SEA_LEVEL = 15

local generatingThread

local biomeBlocks: { [string]: Part } = {
	["grass"] = ServerStorage:WaitForChild("BasicPart"),
	["dead"] = ServerStorage:WaitForChild("DeadPart"),
	["snow"] = ServerStorage:WaitForChild("SnowPart"),
	["rock"] = ServerStorage:WaitForChild("RockPart"),
	["wet"] = ServerStorage:WaitForChild("WetPart"),
	["water"] = ServerStorage:WaitForChild("Water"),
}

local function getRelativeHeight(x, z)
	if not seedSet then
		error("Seed not set")
	end
	local noise = math.noise(x * SMOOTH, z * SMOOTH, HEIGHT_SEED)

	-- force a lower end to avoid holes caused by NaN Y
	if noise < -0.5 then
		noise = -0.5
	end
	--- bias towards the lower ends of noise.
	-- @see https://www.redblobgames.com/maps/terrain-from-noise/#elevation-redistribution

	-- add 0.5 to put value between 0 to 1
	noise = math.pow((noise + 0.5) * 1.3 --[[fudge factor]], 2.5)

	return noise
end

local function getBlockHeight(x, z)
	return math.floor(getRelativeHeight(x, z) * (50 * AMPLITUDE))
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

	if noise >= 0.3 and noise <= 0.8 then
		return "MEDIUM"
	elseif noise > 0.8 then
		return "HIGH"
	else
		return "LOW"
	end
end

function worldgenModule.generateChunk(xChunkCoord: number, zChunkCoord: number)
	local chunkFolder = Instance.new("Folder")
	chunkFolder.Name = "chunk" .. xChunkCoord .. " " .. zChunkCoord
	chunkFolder.Parent = worldgenFolder
	for i = 1, CHUNK_SIZE do
		local realX = i + (CHUNK_SIZE * xChunkCoord)
		for j = 1, CHUNK_SIZE do
			local realZ = j + (CHUNK_SIZE * zChunkCoord)

			local moisture = getMoisture(realX, realZ)
			local blockHeight = getBlockHeight(realX, realZ)
			local block
			if moisture == "HIGH" and blockHeight < 50 then
				block = biomeBlocks.wet:Clone()
			elseif blockHeight <= SEA_LEVEL + 10 then
				block = biomeBlocks.dead:Clone()
			elseif blockHeight >= 90 and (moisture == "MEDIUM" or moisture == "HIGH") then
				block = biomeBlocks.snow:Clone()
			elseif blockHeight >= 50 then
				block = biomeBlocks.rock:Clone()
			else
				block = biomeBlocks.grass:Clone()
			end
			block.Name = i .. " " .. j
			block.CFrame = CFrame.new(realX * BLOCK_SIZE, blockHeight, realZ * BLOCK_SIZE)
			block.Parent = chunkFolder

			if block.CFrame.Y < -500 then
				print(blockHeight, i, j, math.noise(realX * SMOOTH, realZ * SMOOTH, HEIGHT_SEED))
			end
		end
	end

	-- if #waterBlocksInChunk ~= 0 then
	-- 	print(waterBlocksInChunk)
	-- 	local part = table.remove(waterBlocksInChunk, 1)
	-- 	local success, unionedWater: UnionOperation = pcall(function()
	-- 		return part:UnionAsync(waterBlocksInChunk)
	-- 	end)
	-- 	if success and unionedWater then
	-- 		unionedWater.Position = part.Position
	-- 		unionedWater.Parent = chunkFolder
	-- 		part:Destroy()
	-- 		for _, block in pairs(waterBlocksInChunk) do
	-- 			block:Destroy()
	-- 		end
	-- 	else
	-- 		print(unionedWater)
	-- 	end
	-- end
end
--- Generates procgen terrain with the set seed.
--- Requires `worldgenModule.setSeed` to be run first.
function worldgenModule.drawInitialTerrain()
	if not seedSet then
		error("Seed not set")
	end
	if worldCurrentlyGenerated then
		warn("World is already generated. Possible double run?")
	end
	generatingThread = task.spawn(function()
		for i = -INITIAL_SIZE, INITIAL_SIZE do
			for j = -INITIAL_SIZE, INITIAL_SIZE do
				task.spawn(worldgenModule.generateChunk, i, j)
			end
		end
		local water: Part = workspace.Swimmable.Water
		water.CFrame = CFrame.new(0, SEA_LEVEL + 0.8, 0)

		worldCurrentlyGenerated = true
		worldgenModule.initialWorldGenerated:Fire()
		worldgenModule.isInitialWorldGenerated = true
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
