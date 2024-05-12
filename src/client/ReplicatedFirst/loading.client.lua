local plr = game:GetService("Players").LocalPlayer
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local loadingUI: ScreenGui = ReplicatedFirst:WaitForChild("LoadingGui")

loadingUI.Parent = plr.PlayerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()

local changingUI = loadingUI:WaitForChild("background"):FindFirstChildWhichIsA("CanvasGroup")

local tweenResult = {}
tweenResult.GroupTransparency = 0

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local TweenService = game:GetService("TweenService")

-- fade in the loading bar
TweenService:Create(changingUI, TweenInfo.new(3), tweenResult):Play()

local ContentProvider = game:GetService("ContentProvider")

local assets = game:GetDescendants()
local totalAssets = #assets

local loadingBar: Frame = changingUI:WaitForChild("LoadbarContainer")
local loadingBarValue: Frame = loadingBar:WaitForChild("LoadbarValue")
local loadingTextElement = loadingBar:FindFirstChildWhichIsA("TextLabel")

print("loading starting")
-- loading started
for index, asset in ipairs(assets) do
	ContentProvider:PreloadAsync({ asset })
	loadingTextElement.Text = index .. "/" .. totalAssets
	loadingBarValue.Size = UDim2.fromScale(index / totalAssets, 1)
end
print("loading ended")
-- loading done
-- transition to waiting state now since everything is loaded

-- wait until we can play
repeat
	task.wait(0.5)
until plr:FindFirstChild("IsPlaying").Value

plr.PlayerGui:WaitForChild("GameUI").Enabled = true
loadingUI:Destroy()
