local ServerStorage = game:GetService("ServerStorage")
local Flags = require(game.ReplicatedStorage.Shared.gameFlags)
local worldgenModule = {}

local worldgenFolder: Folder = workspace:WaitForChild("procgen")

local BASE_SEED, HEIGHT_SEED, MOISTURE_SEED
local seedSet, worldCurrentlyGenerated = false, false

worldgenModule.initialWorldGenerated = Instance.new("BindableEvent")
worldgenModule.isInitialWorldGenerated = false
local visNoise = false

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
local SMOOTH = 0.5
local BIOME_SMOOTH = 0.02

local AMPLITUDE = 2

-- this will not run if it's too big :sob:
local INITIAL_SIZE = 6
if game:GetService("RunService"):IsStudio() then
	INITIAL_SIZE = 1
end
local CHUNK_SIZE = 32
local BLOCK_SIZE = 8

local SEA_LEVEL = 17
-- offset the water from the beachline to make it look more natural
local REAL_SEA_LEVEL = SEA_LEVEL + 0.9

local function heightNoise(x, y)
	local nx = x / INITIAL_SIZE
	local ny = y / INITIAL_SIZE
	local noise = math.noise(nx, ny, HEIGHT_SEED)
	return noise
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

	local octave1 = heightNoise(x, z)
	local octave2 = 0.5 * heightNoise(2 * x, 2 * z)
	local octave3 = 0.25 * heightNoise(4 * x, 4 * z)
	local e = octave1 + octave2 + octave3
	return e / (1 + 0.5 + 0.25)
end

local function getBlockHeight(x, z)
	--- bias towards the lower ends of noise.
	-- @see https://www.redblobgames.com/maps/terrain-from-noise/#elevation-redistribution
	local relativeHeight = math.pow((getHeight(x, z)) * 1.2 --[[fudge factor]], 3)
	return math.floor(relativeHeight * (50 * AMPLITUDE))
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
	elseif noise > 0.7 then
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
			if blockHeight <= SEA_LEVEL + 6 then
				block = biomeBlocks.dead:Clone()
			elseif moisture == "HIGH" and blockHeight < 50 then
				block = biomeBlocks.wet:Clone()
			elseif blockHeight >= 350 and (moisture == "MEDIUM" or moisture == "HIGH") then
				block = biomeBlocks.snow:Clone()
			elseif blockHeight >= 150 then
				block = biomeBlocks.rock:Clone()
			else
				block = biomeBlocks.grass:Clone()
			end

			block.Name = i .. " " .. j

			if visNoise then
				block.CFrame = CFrame.new(realX * BLOCK_SIZE, 50, realZ * BLOCK_SIZE)
				local colorValue = getHeight(realX, realZ)
				if colorValue > 1 then
					print(colorValue, block, math.noise(realX * SMOOTH, realZ * SMOOTH, HEIGHT_SEED))
				end
				block.Color = Color3.fromHSV(0, 0, colorValue)
			else
				block.CFrame = CFrame.new(realX * BLOCK_SIZE, blockHeight, realZ * BLOCK_SIZE)
			end
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
	visNoise = Flags.getFlag("VisualizeNoise")
	generatingThread = task.spawn(function()
		for i = -size, size do
			for j = -size, size do
				task.spawn(worldgenModule.generateChunk, i, j)
			end
		end

		local water: Part = workspace.Water
		-- ?????
		water.CFrame = CFrame.new(0, REAL_SEA_LEVEL, 0)
		water.Size = Vector3.new(10, REAL_SEA_LEVEL, 10)

		worldgenModule.generateWater(10, 10)

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
