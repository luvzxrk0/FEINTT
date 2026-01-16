--[[
	ParryInputHandler.lua
	Client-side script for handling parry inputs
	Place in StarterPlayer/StarterPlayerScripts
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameEnums = require(ReplicatedStorage.Modules.GameEnums)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local RemoteEvents = require(ReplicatedStorage.Modules.RemoteEventsSetup)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Animation tracks (using placeholder IDs)
local realParryAnim = nil
local fakeParryAnim = nil

-- Load animations
local function loadAnimations()
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	
	-- Real parry animation
	local realParryAnimObj = Instance.new("Animation")
	realParryAnimObj.AnimationId = GameConfig.REAL_PARRY_ANIMATION_ID
	realParryAnim = animator:LoadAnimation(realParryAnimObj)
	
	-- Fake parry animation
	local fakeParryAnimObj = Instance.new("Animation")
	fakeParryAnimObj.AnimationId = GameConfig.FAKE_PARRY_ANIMATION_ID
	fakeParryAnim = animator:LoadAnimation(fakeParryAnimObj)
end

-- Load animations when character is ready
loadAnimations()

-- Reload animations on character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	loadAnimations()
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Real parry: Left Mouse Button or Q key
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Q then
		-- Send real parry input to server
		RemoteEvents.ParryInput:FireServer(GameEnums.ParryType.REAL)
		
		-- Play animation
		if realParryAnim then
			realParryAnim:Play()
		end
	end
	
	-- Fake parry: Right Mouse Button or E key
	if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.E then
		-- Send fake parry input to server
		RemoteEvents.ParryInput:FireServer(GameEnums.ParryType.FAKE)
		
		-- Play animation
		if fakeParryAnim then
			fakeParryAnim:Play()
		end
	end
end)

print("Parry Input Handler loaded")
print("Controls:")
print("  Real Parry: Left Click or Q")
print("  Fake Parry: Right Click or E")
