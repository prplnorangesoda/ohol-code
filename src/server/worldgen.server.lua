local ReplicatedStorage = game:GetService("ReplicatedStorage")

local part: Part = ReplicatedStorage:WaitForChild("BasicPart")

local SEED = 8

-- 0 = perfect smooth
-- up to 1 = more aggressive
local SMOOTH = 0.05

local SIZE = 300

local function getBlock(x, z)
	local noise = math.noise(x * SMOOTH, z * SMOOTH, SEED)

	-- -0.5 0.5
	return noise
end

local function drawTerrain()
	for i = 1, SIZE do
		for j = 1, SIZE do
			local noise = getBlock(i, j)
			local block = part:Clone()
			block.Parent = workspace.procgen
			block.CFrame = CFrame.new(i * 4, math.floor(noise * 32), j * 4)
		end
	end
end

drawTerrain()
