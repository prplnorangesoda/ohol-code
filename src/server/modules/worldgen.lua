local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Flags = require(game.ReplicatedStorage.Shared.gameFlags)
local Globals = require(game.ReplicatedStorage.Shared.gameGlobals)
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

local BIOME_SMOOTH = 0.02
local AMPLITUDE = Globals.worldGen.AMPLITUDE

-- this will not run if it's too big :sob:
local INITIAL_SIZE = 10
if game:GetService("RunService"):IsStudio() then
	INITIAL_SIZE = 2
end
local CHUNK_SIZE = 32
local BLOCK_SIZE = 8

local SEA_LEVEL = Globals.worldGen.SEA_LEVEL
-- offset the water from the beachline to make it look more natural
local REAL_SEA_LEVEL = SEA_LEVEL + 0.9

local function noise(x, y)
	local nx = x / 10
	local nz = y / 10
	return math.clamp(math.noise(nx, nz, HEIGHT_SEED), -1, 1) / 2 + 0.5
end

local function heightNoise(x, y)
	local octave1 = 1 * noise(0.25 * x, 0.25 * y)
	local octave2 = 0.5 * noise(0.3 * x, 0.3 * y)
	local octave3 = 0.25 * noise(0.5 * x, 0.5 * y)
	local octave4 = 0.125 * noise(x, y)
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
---@return string
local function getMoisture(x, z): string
	if not seedSet then
		error("Seed not set")
	end
	local moisture = math.noise(x * BIOME_SMOOTH, z * BIOME_SMOOTH, MOISTURE_SEED)
	moisture += 0.5 -- get a value between 0-1

	if moisture >= 0.3 and moisture <= 0.8 then
		return "MEDIUM"
	elseif moisture > 0.7 then
		return "HIGH"
	else
		return "LOW"
	end
end

function worldgenModule.generateChunk(xChunkCoord: number, zChunkCoord: number)
	local chunkFolder = Instance.new("Folder")
	chunkFolder.Name = "chunk (" .. xChunkCoord .. ", " .. zChunkCoord .. ")"
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
			elseif blockHeight >= 180 and (moisture == "MEDIUM" or moisture == "HIGH") then
				block = biomeBlocks.snow:Clone()
			elseif blockHeight >= 125 then
				block = biomeBlocks.rock:Clone()
			else
				block = biomeBlocks.grass:Clone()
			end

			block.Name = i .. " " .. j

			if visNoise then
				block.CFrame = CFrame.new(realX * BLOCK_SIZE, 50, realZ * BLOCK_SIZE)
				local colorValue = getHeight(realX, realZ)
				block.Color = Color3.fromHSV(0, 0, colorValue)
			else
				block.CFrame = CFrame.new(realX * BLOCK_SIZE, blockHeight, realZ * BLOCK_SIZE)
			end
			block.Parent = chunkFolder
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

		local water: Part = ReplicatedStorage.Water

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
