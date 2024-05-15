local Players = game:GetService("Players")
local character = script.Parent.Parent
local thisPlayer = Players:GetPlayerFromCharacter(character)

local name = "@" .. thisPlayer.Name

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local nameTag: BillboardGui = ReplicatedStorage.Nametag:Clone()
nameTag.PlayerName.Text = name
nameTag.Parent = character
