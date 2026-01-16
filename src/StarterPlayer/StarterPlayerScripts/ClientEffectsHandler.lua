--[[
	ClientEffectsHandler.lua
	Client-side script for handling visual and audio effects
	Place in StarterPlayer/StarterPlayerScripts
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local RemoteEvents = require(ReplicatedStorage.Modules.RemoteEventsSetup)

local player = Players.LocalPlayer

-- Sound effects (using placeholder IDs)
local function createSound(soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = SoundService
	return sound
end

local warningSound = createSound(GameConfig.WARNING_SOUND_ID)
local hitSound = createSound(GameConfig.BLADE_HIT_SOUND_ID)
local parrySound = createSound(GameConfig.PARRY_SUCCESS_SOUND_ID)

-- Handle blade warning
RemoteEvents.BladeWarning.OnClientEvent:Connect(function(targetPlayer, warningDelay, showBeam)
	if targetPlayer == player then
		-- Play warning sound
		warningSound:Play()
		
		-- Visual feedback for being targeted
		local screenGui = player.PlayerGui:FindFirstChild("TargetWarningGui")
		if not screenGui then
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "TargetWarningGui"
			screenGui.ResetOnSpawn = false
			screenGui.Parent = player.PlayerGui
		end
		
		-- Remove old warning
		for _, child in ipairs(screenGui:GetChildren()) do
			child:Destroy()
		end
		
		-- Create warning frame
		local warningFrame = Instance.new("Frame")
		warningFrame.Size = UDim2.new(1, 0, 1, 0)
		warningFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		warningFrame.BackgroundTransparency = 0.7
		warningFrame.BorderSizePixel = 0
		warningFrame.Parent = screenGui
		
		local warningText = Instance.new("TextLabel")
		warningText.Size = UDim2.new(0.6, 0, 0.2, 0)
		warningText.Position = UDim2.new(0.2, 0, 0.4, 0)
		warningText.BackgroundTransparency = 1
		warningText.Text = "BLADE INCOMING!"
		warningText.TextColor3 = Color3.fromRGB(255, 255, 255)
		warningText.TextScaled = true
		warningText.Font = Enum.Font.GothamBold
		warningText.Parent = warningFrame
		
		-- Remove after delay
		task.delay(warningDelay, function()
			if screenGui then
				screenGui:Destroy()
			end
		end)
	end
end)

-- Handle blade attack
RemoteEvents.BladeAttack.OnClientEvent:Connect(function(targetPlayer, targetPosition)
	-- Could add additional visual effects here
end)

-- Handle player elimination
RemoteEvents.PlayerEliminated.OnClientEvent:Connect(function(eliminatedPlayer)
	-- Play hit sound
	hitSound:Play()
	
	if eliminatedPlayer == player then
		-- Show elimination message
		local screenGui = player.PlayerGui:FindFirstChild("EliminationGui")
		if not screenGui then
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "EliminationGui"
			screenGui.ResetOnSpawn = false
			screenGui.Parent = player.PlayerGui
		end
		
		local eliminationText = Instance.new("TextLabel")
		eliminationText.Size = UDim2.new(0.8, 0, 0.3, 0)
		eliminationText.Position = UDim2.new(0.1, 0, 0.35, 0)
		eliminationText.BackgroundTransparency = 1
		eliminationText.Text = "ELIMINATED"
		eliminationText.TextColor3 = Color3.fromRGB(255, 0, 0)
		eliminationText.TextScaled = true
		eliminationText.Font = Enum.Font.GothamBold
		eliminationText.Parent = screenGui
		
		-- Fade out after 3 seconds
		task.delay(3, function()
			if screenGui then
				screenGui:Destroy()
			end
		end)
	end
end)

-- Handle parry result
RemoteEvents.ParryResult.OnClientEvent:Connect(function(parryPlayer, successful)
	if successful and parryPlayer == player then
		-- Play success sound
		parrySound:Play()
		
		-- Show success message
		local screenGui = player.PlayerGui:FindFirstChild("ParrySuccessGui")
		if not screenGui then
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "ParrySuccessGui"
			screenGui.ResetOnSpawn = false
			screenGui.Parent = player.PlayerGui
		end
		
		local successText = Instance.new("TextLabel")
		successText.Size = UDim2.new(0.6, 0, 0.2, 0)
		successText.Position = UDim2.new(0.2, 0, 0.4, 0)
		successText.BackgroundTransparency = 1
		successText.Text = "PARRY SUCCESS!"
		successText.TextColor3 = Color3.fromRGB(0, 255, 0)
		successText.TextScaled = true
		successText.Font = Enum.Font.GothamBold
		successText.Parent = screenGui
		
		-- Fade out after 1 second
		task.delay(1, function()
			if screenGui then
				screenGui:Destroy()
			end
		end)
	end
end)

print("Client Effects Handler loaded")
