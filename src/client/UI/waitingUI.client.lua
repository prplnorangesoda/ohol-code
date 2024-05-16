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

local function textForLoadingState(loadingState)
	if loadingState == -1 then
		return ""
	end
	if loadingState == 0 then
		return "Server is loading terrain"
	end
	if loadingState == 1 then
		return "Server is getting where trees should go"
	end
	if loadingState == 2 then
		return "Server is placing trees"
	end
	if loadingState == 3 then
		return "Server is finishing up..."
	end
end

LoadingGui.Destroying:Once(function()
	task.wait(0.5)
	local loadbarFadeout = TweenService:Create(background.ChangingUI, TweenInfo.new(2), { GroupTransparency = 1 })
	loadbarFadeout:Play()
	local isServerLoaded = ReplicatedStorage.Shared.remotes.funcs.IsServerLoaded:InvokeServer()
	if not isServerLoaded then
		local serverLoadedState = ReplicatedStorage.Shared.remotes.funcs.ServerLoadedState:InvokeServer()
		ServerLoadingText.Text = textForLoadingState(serverLoadedState)
		if loadbarFadeout.PlaybackState ~= Enum.PlaybackState.Completed then
			loadbarFadeout.Completed:Wait()
		end
		ServerLoadingText.Visible = true
		ReplicatedStorage.Shared.remotes.LoadStateChanged.OnClientEvent:Connect(function(state)
			ServerLoadingText.Text = textForLoadingState(state)
		end)
		ReplicatedStorage.Shared.remotes.ServerLoaded.OnClientEvent:Wait()
	end

	ServerLoadingText.Visible = false

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
