--[[
	RoundInfoUI.lua
	Client-side script for displaying round information
	Place in StarterPlayer/StarterPlayerScripts
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteEvents = require(ReplicatedStorage.Modules.RemoteEventsSetup)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RoundInfoGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Round state label
local roundStateLabel = Instance.new("TextLabel")
roundStateLabel.Size = UDim2.new(0.3, 0, 0.08, 0)
roundStateLabel.Position = UDim2.new(0.35, 0, 0.02, 0)
roundStateLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
roundStateLabel.BackgroundTransparency = 0.5
roundStateLabel.BorderSizePixel = 2
roundStateLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)
roundStateLabel.Text = "Waiting for round..."
roundStateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
roundStateLabel.TextScaled = true
roundStateLabel.Font = Enum.Font.GothamBold
roundStateLabel.Parent = screenGui

-- Controls info label
local controlsLabel = Instance.new("TextLabel")
controlsLabel.Size = UDim2.new(0.25, 0, 0.12, 0)
controlsLabel.Position = UDim2.new(0.02, 0, 0.85, 0)
controlsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
controlsLabel.BackgroundTransparency = 0.7
controlsLabel.BorderSizePixel = 1
controlsLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)
controlsLabel.Text = "Controls:\nReal Parry: Q or Left Click\nFake Parry: E or Right Click"
controlsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
controlsLabel.TextSize = 14
controlsLabel.Font = Enum.Font.Gotham
controlsLabel.TextXAlignment = Enum.TextXAlignment.Left
controlsLabel.TextYAlignment = Enum.TextYAlignment.Top
controlsLabel.Parent = screenGui

-- Listen for round state changes
RemoteEvents.RoundStateChanged.OnClientEvent:Connect(function(newState)
	roundStateLabel.Text = "Round State: " .. newState
	
	-- Color code based on state
	if newState == "Active" then
		roundStateLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
	elseif newState == "Waiting" then
		roundStateLabel.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
	elseif newState == "Intermission" then
		roundStateLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 100)
	else
		roundStateLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end)

-- Listen for round info updates
RemoteEvents.UpdateRoundInfo.OnClientEvent:Connect(function(message, roundNumber)
	roundStateLabel.Text = message
end)

print("Round Info UI loaded")
