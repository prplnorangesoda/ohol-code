local seed = 0
local fudge_factor = 1.2
local size = 200
local noiseTable = {}
local AMPLITUDE = 3

local function noise(x, y)
	local nx = x / 10
	local nz = y / 10
	return math.clamp(math.noise(nx, nz, seed), -1, 1) / 2 + 0.5
end

for x = 0, size do
	noiseTable[x] = {}
	for z = 0, size do
		local octave1 = 1 * noise(0.5 * x, 0.5 * z)
		local octave2 = 0.5 * noise(x, z)
		local octave3 = 0.25 * noise(2 * x, 2 * z)
		local total = octave1 + octave2 + octave3
		total = total / (1 + 0.5 + 0.25)
		total = math.pow(total * fudge_factor, 1.5)
		noiseTable[x][z] = total
	end
end

local partFolder = Instance.new("Folder", workspace)
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
