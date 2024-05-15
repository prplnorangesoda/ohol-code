local enabled = false

if not enabled then
	return
end

local MOISTURE_SEED = 0
local AMPLITUDE = 1

local function noiseWithMoistureSeed(x, y)
	local nx = x / 10
	local nz = y / 10
	return math.clamp(math.noise(nx, nz, MOISTURE_SEED), -1, 1) / 2 + 0.5
end

local function getMoisture(x, z): number
	local octave1 = noiseWithMoistureSeed(0.2 * x, 0.2 * z)
	return math.pow(octave1, 2)
end

local noiseTable = {}
for i = -150, 150 do
	noiseTable[i] = {}
	for j = -150, 150 do
		noiseTable[i][j] = getMoisture(i, j)
	end
end

local partFolder = Instance.new("Folder")
partFolder.Parent = workspace
for x, table in ipairs(noiseTable) do
	for z, noiseValue in ipairs(table) do
		local part = Instance.new("Part")
		part.Anchored = true
		part.Size = Vector3.new(4, 16, 4)
		part.CFrame = CFrame.new(x * 4, noiseValue * (AMPLITUDE * 25), z * 4)
		part.Color = Color3.fromHSV(0, 0, noiseValue)
		part.Parent = partFolder
	end
end

print(noiseTable)
