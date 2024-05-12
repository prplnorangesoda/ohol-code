local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
local humanoid: Humanoid = character:WaitForChild("Humanoid")

local deathBlackFade: CanvasGroup = plr.PlayerGui.DeathFade.DeathBlackFade -- define

local deathFadeTweenInfo = TweenInfo.new(4)
local deathFadeTween = TweenService:Create(deathBlackFade, deathFadeTweenInfo, {GroupTransparency = 0})

humanoid.Died:Connect(function()
	deathFadeTween:Play()
end)

-- instance, info, properties