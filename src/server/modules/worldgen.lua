local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Globals = require(game.ReplicatedStorage.Shared.gameGlobals)
local poissonDisk = require(script.Parent.poissondisk)
local worldgenModule = {}

local worldgenFolder: Folder = workspace:WaitForChild("procgen")

local BASE_SEED, HEIGHT_SEED, MOISTURE_SEED
local seedSet, worldCurrentlyGenerated = false, false

worldgenModule.terrainGenerated = Instance.new("BindableEvent")
worldgenModule.isTerrainGenerated = false

worldgenModule.poissonDiskGenerated = Instance.new("BindableEvent")
worldgenModule.isPoissonDiskGenerated = false

worldgenModule.treesPlaced = Instance.new("BindableEvent")
worldgenModule.isTreesPlaced = false

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
	HEIGHT_SEED = (BASE_SEED + 50) / 5
	MOISTURE_SEED = (HEIGHT_SEED + 30) / 4

	seedSet = true
	Globals.worldGen.SEED = BASE_SEED
	print("SERVER SEED SET:", BASE_SEED)
end

local AMPLITUDE = Globals.worldGen.AMPLITUDE

-- this will not run if it's too big :sob:
local INITIAL_SIZE = 10
if game:GetService("RunService"):IsStudio() then
	INITIAL_SIZE = 8
end
local CHUNK_SIZE = 32
local BLOCK_SIZE = 8

local SEA_LEVEL = Globals.worldGen.SEA_LEVEL
-- offset the water from the beachline to make it look more natural
local REAL_SEA_LEVEL = SEA_LEVEL + 0.9

local function noiseWithHeightSeed(x, y)
	local nx = x / 10
	local nz = y / 10
	return math.clamp(math.noise(nx, nz, HEIGHT_SEED), -1, 1) / 2 + 0.5
end
local function noiseWithMoistureSeed(x, y)
	local nx = x / 10
	local nz = y / 10
	return math.clamp(math.noise(nx, nz, MOISTURE_SEED), -1, 1) / 2 + 0.5
end

local function heightNoise(x, y)
	-- red noise - smoother noise tables are prioritized
	local octave1 = 1 * noiseWithHeightSeed(0.25 * x, 0.25 * y)
	local octave2 = 0.5 * noiseWithHeightSeed(0.3 * x, 0.3 * y)
	local octave3 = 0.25 * noiseWithHeightSeed(0.5 * x, 0.5 * y)
	local octave4 = 0.125 * noiseWithHeightSeed(x, y)
	local total = octave1 + octave2 + octave3 + octave4
	total = total / (1 + 0.5 + 0.25 + 0.125)
	total = math.pow(total * 1.3, 4)
	return total
end

local generatingThread

local biomeBlocks: { [string]: Part } = {
	["grass"] = ServerStorage:WaitForChild("BasicPart"),
	["dead"] = ServerStorage:WaitForChild("DeadPart"),
	["snow"] = ServerStorage:WaitForChild("SnowPart"),
	["rock"] = ServerStorage:WaitForChild("RockPart"),
	["wet"] = ServerStorage:WaitForChild("WetPart"),
	["water"] = ServerStorage:WaitForChild("Water"),
}

local function getHeight(x, z)
	if not seedSet then
		error("Seed not set")
	end
	return heightNoise(x, z)
end

local function getBlockHeight(x, z)
	local relativeHeight = getHeight(x, z)
	relativeHeight = relativeHeight * (50 * AMPLITUDE)

	relativeHeight = math.round(relativeHeight / 1.5) * 1.5
	return relativeHeight
end

---Get the moisture for a 2D position using the moisture noisemap.
---@param x number X coordinate
---@param z number Z coordinate
---@return number
local function getMoisture(x, z): number
	local octave1 = noiseWithMoistureSeed(0.2 * x, 0.2 * z)
	return math.pow(octave1, 2)
end

local function getBiome(x, y, z)
	local moisture = getMoisture(x, z)
	if y < SEA_LEVEL then
		return "OCEAN"
	elseif y <= SEA_LEVEL + 6 then
		return "BEACH"
	elseif moisture >= 0.7 and y < 50 then
		return "SWAMP"
	elseif y >= 180 and moisture >= 0.3 then
		return "MOUNTAIN_SNOW"
	elseif y >= 125 then
		return "MOUNTAIN"
	elseif moisture >= 0.3 then
		return "FOREST"
	else
		return "PLAINS"
	end
end

local function shouldSpawnTreeAt(x: number, y: number, z: number)
	local biome = getBiome(x, y, z)
	-- print(x, y, z, biome)

	if biome == "OCEAN" or biome == "BEACH" or biome == "MOUNTAIN_SNOW" then
		return false
	elseif biome == "PLAINS" or biome == "MOUNTAIN" then
		return false
	end
	return true
end

local blockTable: { Part } = {
	["BEACH"] = biomeBlocks.dead,
	["OCEAN"] = biomeBlocks.dead,
	["SWAMP"] = biomeBlocks.wet,
	["MOUNTAIN_SNOW"] = biomeBlocks.snow,
	["MOUNTAIN"] = biomeBlocks.rock,
	["PLAINS"] = biomeBlocks.grass,
	["FOREST"] = biomeBlocks.grass,
}
function worldgenModule.generateChunk(xChunkCoord: number, zChunkCoord: number)
	local chunkFolder = Instance.new("Folder")

	local xOffset = CHUNK_SIZE * xChunkCoord
	local zOffset = CHUNK_SIZE * zChunkCoord
	chunkFolder.Name = "chunk (" .. xChunkCoord .. ", " .. zChunkCoord .. ")"
	chunkFolder.Parent = worldgenFolder
	type blockInfo = {
		position: Vector3,
		biome: string,
	}
	local blockInfo2d: { { blockInfo } } = {}
	for i = 1, CHUNK_SIZE do
		local realX = i + xOffset
		blockInfo2d[i] = {}
		for j = 1, CHUNK_SIZE do
			local realZ = j + zOffset

			local blockHeight = getBlockHeight(realX, realZ)
			local biome = getBiome(realX, blockHeight, realZ)
			blockInfo2d[i][j] = {
				position = Vector3.new(realX * BLOCK_SIZE, blockHeight, realZ * BLOCK_SIZE),
				biome = biome,
			}
		end
	end

	coroutine.yield("BLOCKSPOS")

	for i, table in ipairs(blockInfo2d) do
		for j, blockInfo in ipairs(table) do
			local block = blockTable[blockInfo.biome]:Clone()

			block.Name = i .. " " .. j

			block.CFrame = CFrame.new(blockInfo.position)

			block.Parent = chunkFolder
		end
	end

	-- block rendering is done, yield
	coroutine.yield("BLOCKS")

	-- generate trees using a Poisson disk
	local poisson = poissonDisk(CHUNK_SIZE, CHUNK_SIZE, 2, 5)
	coroutine.yield("POISSON")

	for _, value: Vector2 in ipairs(poisson) do
		local roundedValues = {
			x = math.round(value.X),
			z = math.round(value.Y),
		}
		local realX = (roundedValues.x + xOffset)
		local realZ = (roundedValues.z + zOffset)
		local realY = getBlockHeight(realX, realZ)

		-- print(realX * BLOCK_SIZE, realZ * BLOCK_SIZE)
		-- this is ugly - we should just not generate poisson discs
		-- for trees outside of biomes that don't support them
		-- but i have no way how to do that
		local shouldSpawn = shouldSpawnTreeAt(realX, realY, realZ)
		-- print(shouldSpawn)
		if shouldSpawn then
			local treePosition = Vector3.new(realX * BLOCK_SIZE, realY + 21.5, realZ * BLOCK_SIZE)
			local tree: Model = ReplicatedStorage.BasicTree:Clone()
			tree:PivotTo(CFrame.new(treePosition))
			tree.Parent = worldgenFolder.trees
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

function worldgenModule.generateWater(extentX, extentZ)
	for i = -extentX, extentX do
		local realX = i * 2048
		for j = -extentZ, extentZ do
			local realZ = j * 2048

			local water: Part = ServerStorage.Water:Clone()
			water.Size = Vector3.new(2048, REAL_SEA_LEVEL, 2048)
			water.CFrame = CFrame.new(realX, REAL_SEA_LEVEL, realZ)
			water.Parent = workspace.Swimmable
		end
	end
end
--- Generates procgen terrain with the set seed.
--- Requires `worldgenModule.setSeed` to be run first.
function worldgenModule.drawInitialTerrain(size)
	if size == nil then
		size = INITIAL_SIZE
	end
	if not seedSet then
		error("Seed not set")
	end
	if worldCurrentlyGenerated then
		warn("World is already generated. Possible double run?")
	end
	generatingThread = task.spawn(function()
		local coroutines = {}
		for i = -size, size do
			coroutines[i] = {}
			for j = -size, size do
				coroutines[i][j] = coroutine.create(worldgenModule.generateChunk)
			end
		end
		task.wait()
		local terrainExecutionTime = os.clock()
		print("coroutines created, running")
		for i = -size, size do
			for j = -size, size do
				coroutine.resume(coroutines[i][j], i, j)
			end
		end
		task.wait()
		print("terrain positions done")
		for i = -size, size do
			for j = -size, size do
				coroutine.resume(coroutines[i][j], i, j)
			end
		end
		task.wait()
		worldgenModule.isTerrainGenerated = true
		worldgenModule.terrainGenerated:Fire()
		local poissonGenerationTime = os.clock()
		print("terrain done in ", poissonGenerationTime - terrainExecutionTime)
		for i = -size, size do
			for j = -size, size do
				coroutine.resume(coroutines[i][j])
			end
		end
		task.wait()

		worldgenModule.isPoissonDiskGenerated = true
		worldgenModule.poissonDiskGenerated:Fire()
		local treeGenerationTime = os.clock()
		print("poisson done in", treeGenerationTime - poissonGenerationTime)
		for i = -size, size do
			for j = -size, size do
				coroutine.resume(coroutines[i][j])
			end
		end
		task.wait()

		worldgenModule.isTreesPlaced = true
		worldgenModule.treesPlaced:Fire()
		print("trees done in", os.clock() - treeGenerationTime)
		local water: Part = ReplicatedStorage.Water

		water.CFrame = CFrame.new(0, REAL_SEA_LEVEL, 0)
		water.Size = Vector3.new(10, REAL_SEA_LEVEL, 10)

		worldgenModule.generateWater(10, 10)
		print("swimmable area done")

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
