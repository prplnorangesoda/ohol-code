local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local plr = game.Players.LocalPlayer

local LoadingGui: ScreenGui = plr.PlayerGui:WaitForChild("LoadingGui")
local WaitingUI: ScreenGui = ReplicatedStorage:WaitForChild("WaitingUI"):Clone()
WaitingUI.Parent = plr.PlayerGui
local wholeUI: CanvasGroup = WaitingUI:WaitForChild("wholeUI")
local background: Frame = wholeUI:WaitForChild("background")
local ServerLoadingText: TextLabel = background:WaitForChild("ServerLoading")
local WaitingToPlayText: TextLabel = background:WaitForChild("WaitingToPlay")

LoadingGui.Destroying:Once(function()
	task.wait(1)
	local loadbarFadeout = TweenService:Create(background.ChangingUI, TweenInfo.new(2), { GroupTransparency = 1 })
	loadbarFadeout:Play()
	local isServerLoaded = ReplicatedStorage.Shared.remotes.funcs.IsServerLoaded:InvokeServer()
	if loadbarFadeout.PlaybackState ~= Enum.PlaybackState.Completed then
		loadbarFadeout.Completed:Wait()
	end
	if not isServerLoaded then
		ServerLoadingText.Visible = true
		ReplicatedStorage.Shared.remotes.ServerLoaded.OnClientEvent:Wait()
		ServerLoadingText.Visible = false
	end

	-- currently waiting
	WaitingToPlayText.Visible = true
	local isPlaying: BoolValue = plr:WaitForChild("IsPlaying")
	if not isPlaying.Value then
		isPlaying.Changed:Wait()
	end

	-- we're ready to play
	WaitingToPlayText.Visible = false
	plr.PlayerGui:WaitForChild("GameUI").Enabled = true
	local waitingUIfadeout = TweenService:Create(wholeUI, TweenInfo.new(0.5), { GroupTransparency = 1 })
	waitingUIfadeout:Play()
end)
