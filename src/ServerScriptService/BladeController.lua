--[[
	BladeController.lua
	Server-side controller for the autonomous blade
	Handles targeting, warning, dashing, and hit detection
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local GameEnums = require(ReplicatedStorage.Modules.GameEnums)
local RemoteEvents = require(ReplicatedStorage.Modules.RemoteEventsSetup)

local BladeController = {}
BladeController.__index = BladeController

function BladeController.new(playerDataTracker)
	local self = setmetatable({}, BladeController)
	
	self.playerDataTracker = playerDataTracker
	self.state = GameEnums.BladeState.IDLE
	self.currentSpeed = GameConfig.BLADE_DASH_SPEED
	self.currentTarget = nil
	self.lastTarget = nil
	self.warningDelayMin = GameConfig.WARNING_DELAY_MIN
	self.warningDelayMax = GameConfig.WARNING_DELAY_MAX
	self.blade = nil
	self.warningBeam = nil
	self.isActive = false
	self.dashConnection = nil
	self.pendingParry = nil -- {player, timestamp, type}
	
	return self
end

function BladeController:Initialize()
	-- Create blade model
	self:CreateBlade()
end

function BladeController:CreateBlade()
	-- Clean up existing blade
	if self.blade then
		self.blade:Destroy()
	end
	
	-- Create blade part
	local blade = Instance.new("Part")
	blade.Name = "Blade"
	blade.Size = GameConfig.BLADE_SIZE
	blade.Position = GameConfig.ARENA_CENTER
	blade.Anchored = true
	blade.CanCollide = false
	blade.Material = Enum.Material.Neon
	blade.Color = Color3.fromRGB(255, 50, 50)
	blade.Parent = Workspace
	
	-- Add visual flair
	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 50, 50)
	pointLight.Brightness = 2
	pointLight.Range = 15
	pointLight.Parent = blade
	
	self.blade = blade
end

function BladeController:Start()
	self.isActive = true
	self.currentSpeed = GameConfig.BLADE_DASH_SPEED
	self.warningDelayMin = GameConfig.WARNING_DELAY_MIN
	self.warningDelayMax = GameConfig.WARNING_DELAY_MAX
	self.lastTarget = nil
	
	if self.blade then
		self.blade.Position = GameConfig.ARENA_CENTER
		self.blade.Anchored = true
	end
	
	-- Wait initial delay before first target
	wait(GameConfig.ROUND_START_DELAY)
	
	if self.isActive then
		self:SelectAndTargetPlayer()
	end
end

function BladeController:Stop()
	self.isActive = false
	self.state = GameEnums.BladeState.IDLE
	self.currentTarget = nil
	self.lastTarget = nil
	
	if self.dashConnection then
		self.dashConnection:Disconnect()
		self.dashConnection = nil
	end
	
	if self.warningBeam then
		self.warningBeam:Destroy()
		self.warningBeam = nil
	end
	
	if self.blade then
		self.blade.Position = GameConfig.ARENA_CENTER
		self.blade.Anchored = true
	end
end

function BladeController:SelectAndTargetPlayer()
	if not self.isActive then return end
	
	local alivePlayers = self.playerDataTracker:GetAlivePlayers()
	
	if #alivePlayers == 0 then
		return
	elseif #alivePlayers == 1 then
		-- Round over, only one player left
		return
	end
	
	-- Select target using weighted selection
	local target = self:SelectTargetWithWeights(alivePlayers)
	
	if target then
		self:BeginWarningPhase(target)
	end
end

function BladeController:SelectTargetWithWeights(alivePlayers)
	local weights = {}
	local totalWeight = 0
	
	for _, player in ipairs(alivePlayers) do
		-- Don't select same player twice in a row unless only 2 players
		if #alivePlayers > 2 and player == self.lastTarget then
			weights[player] = 0
		else
			local weight = self:CalculatePlayerWeight(player)
			weights[player] = weight
			totalWeight = totalWeight + weight
		end
	end
	
	if totalWeight == 0 then
		-- Fallback to random selection
		return alivePlayers[math.random(1, #alivePlayers)]
	end
	
	-- Weighted random selection
	local random = math.random() * totalWeight
	local cumulativeWeight = 0
	
	for _, player in ipairs(alivePlayers) do
		cumulativeWeight = cumulativeWeight + weights[player]
		if random <= cumulativeWeight then
			return player
		end
	end
	
	-- Fallback
	return alivePlayers[1]
end

function BladeController:CalculatePlayerWeight(player)
	local data = self.playerDataTracker:GetPlayerData(player)
	if not data then return 1 end
	
	local weight = 1.0
	
	-- Movement frequency weight
	weight = weight + (data.movementCount * GameConfig.MOVEMENT_WEIGHT * 0.1)
	
	-- Reaction timing weight (faster reactions = higher target priority)
	if #data.reactionTimes > 0 then
		local avgReaction = 0
		for _, time in ipairs(data.reactionTimes) do
			avgReaction = avgReaction + time
		end
		avgReaction = avgReaction / #data.reactionTimes
		-- Lower reaction time = higher weight
		weight = weight + ((1 / (avgReaction + 0.5)) * GameConfig.REACTION_WEIGHT)
	end
	
	-- Parry behavior weight
	if data.parryAttempts > 0 then
		local parryRate = data.successfulParries / data.parryAttempts
		weight = weight + (parryRate * GameConfig.PARRY_HISTORY_WEIGHT)
	end
	
	return math.max(weight, 0.1)
end

function BladeController:BeginWarningPhase(targetPlayer)
	if not self.isActive then return end
	
	self.currentTarget = targetPlayer
	self.state = GameEnums.BladeState.WARNING
	self.pendingParry = nil
	
	local warningStartTime = tick()
	
	-- Calculate warning delay
	local warningDelay = math.random() * (self.warningDelayMax - self.warningDelayMin) + self.warningDelayMin
	warningDelay = math.max(warningDelay, GameConfig.MIN_WARNING_DELAY)
	
	-- Show warning beam only if more than threshold players remain
	local alivePlayers = self.playerDataTracker:GetAlivePlayers()
	local showBeam = #alivePlayers > GameConfig.WARNING_BEAM_REMOVE_THRESHOLD
	
	if showBeam then
		self:CreateWarningBeam(targetPlayer)
	end
	
	-- Notify clients
	RemoteEvents.BladeWarning:FireAllClients(targetPlayer, warningDelay, showBeam)
	
	-- Wait for warning period
	wait(warningDelay)
	
	-- Record reaction time if parry was attempted
	if self.pendingParry and self.pendingParry.player == targetPlayer then
		local reactionTime = self.pendingParry.timestamp - warningStartTime
		self.playerDataTracker:RecordReactionTime(targetPlayer, reactionTime)
	end
	
	if not self.isActive then return end
	
	-- Remove warning beam
	if self.warningBeam then
		self.warningBeam:Destroy()
		self.warningBeam = nil
	end
	
	-- Execute dash
	self:DashToTarget(targetPlayer)
end

function BladeController:CreateWarningBeam(targetPlayer)
	if self.warningBeam then
		self.warningBeam:Destroy()
	end
	
	local character = targetPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	
	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = self.blade
	
	local attachment1 = Instance.new("Attachment")
	attachment1.Parent = character.HumanoidRootPart
	
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	beam.Width0 = 0.5
	beam.Width1 = 0.5
	beam.FaceCamera = true
	beam.Parent = self.blade
	
	self.warningBeam = beam
end

function BladeController:RegisterParryAttempt(player, parryType)
	if not self.isActive then return false end
	if self.state ~= GameEnums.BladeState.WARNING then return false end
	if player ~= self.currentTarget then return false end
	
	-- Check cooldown
	if self.playerDataTracker:IsOnCooldown(player) then
		return false
	end
	
	-- Set cooldown
	self.playerDataTracker:SetParryCooldown(player, GameConfig.PARRY_COOLDOWN)
	
	-- Record parry attempt
	self.pendingParry = {
		player = player,
		timestamp = tick(),
		type = parryType
	}
	
	return true
end

function BladeController:DashToTarget(targetPlayer)
	if not self.isActive then return end
	
	self.state = GameEnums.BladeState.DASHING
	
	local character = targetPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		-- Target invalid, retarget
		self:RetargetAfterPause(GameConfig.POST_ELIMINATION_PAUSE)
		return
	end
	
	local targetPosition = character.HumanoidRootPart.Position
	
	-- Notify clients
	RemoteEvents.BladeAttack:FireAllClients(targetPlayer, targetPosition)
	
	-- Check for successful real parry
	local parrySuccess = false
	if self.pendingParry and self.pendingParry.player == targetPlayer and self.pendingParry.type == GameEnums.ParryType.REAL then
		local timeSinceParry = tick() - self.pendingParry.timestamp
		if timeSinceParry <= GameConfig.REAL_PARRY_WINDOW then
			parrySuccess = true
		end
	end
	
	if parrySuccess then
		self:HandleSuccessfulParry(targetPlayer)
		return
	end
	
	-- Execute physics-based dash with raycast
	self:ExecuteDash(targetPosition, targetPlayer)
end

function BladeController:ExecuteDash(targetPosition, targetPlayer)
	if not self.blade then return end
	
	local startPosition = self.blade.Position
	local direction = (targetPosition - startPosition).Unit
	local distance = (targetPosition - startPosition).Magnitude
	
	self.blade.Anchored = false
	
	-- Apply velocity
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = direction * self.currentSpeed
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Parent = self.blade
	
	local startTime = tick()
	local maxDashTime = distance / self.currentSpeed + 1
	local hit = false
	
	-- Monitor dash with raycast hit detection
	self.dashConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not self.blade or not self.isActive then
			if bodyVelocity then bodyVelocity:Destroy() end
			if self.dashConnection then self.dashConnection:Disconnect() end
			return
		end
		
		local elapsed = tick() - startTime
		if elapsed > maxDashTime then
			-- Timeout, stop dash
			if bodyVelocity then bodyVelocity:Destroy() end
			if self.dashConnection then self.dashConnection:Disconnect() end
			self.blade.Anchored = true
			self:RetargetAfterPause(GameConfig.POST_ELIMINATION_PAUSE)
			return
		end
		
		-- Raycast for hit detection
		local rayOrigin = self.blade.Position
		local rayDirection = self.blade.AssemblyLinearVelocity.Unit * 3
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {self.blade}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		
		local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		
		if rayResult and rayResult.Instance then
			local hitCharacter = rayResult.Instance:FindFirstAncestorOfClass("Model")
			if hitCharacter and hitCharacter:FindFirstChild("Humanoid") then
				local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
				if hitPlayer == targetPlayer then
					-- Hit detected!
					hit = true
					if bodyVelocity then bodyVelocity:Destroy() end
					if self.dashConnection then self.dashConnection:Disconnect() end
					self.blade.Anchored = true
					
					self:HandlePlayerHit(targetPlayer)
					return
				end
			end
		end
	end)
end

function BladeController:HandlePlayerHit(player)
	-- Eliminate player
	self.playerDataTracker:SetPlayerState(player, GameEnums.PlayerState.ELIMINATED)
	
	-- Freeze player as statue
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
				part.Material = Enum.Material.Granite
				part.Color = Color3.fromRGB(150, 150, 150)
			end
		end
	end
	
	-- Notify clients
	RemoteEvents.PlayerEliminated:FireAllClients(player)
	
	-- Increase blade speed
	self.currentSpeed = math.min(self.currentSpeed + GameConfig.BLADE_SPEED_INCREMENT, GameConfig.BLADE_MAX_SPEED)
	
	-- Reduce warning times
	self.warningDelayMin = math.max(self.warningDelayMin - GameConfig.WARNING_DELAY_REDUCTION, GameConfig.MIN_WARNING_DELAY)
	self.warningDelayMax = math.max(self.warningDelayMax - GameConfig.WARNING_DELAY_REDUCTION, GameConfig.MIN_WARNING_DELAY)
	
	-- Record parry attempt result if applicable
	if self.pendingParry and self.pendingParry.player == player then
		self.playerDataTracker:RecordParryAttempt(player, false)
	end
	
	-- Retarget after pause
	self:RetargetAfterPause(GameConfig.POST_ELIMINATION_PAUSE)
end

function BladeController:HandleSuccessfulParry(player)
	-- Record successful parry
	self.playerDataTracker:RecordParryAttempt(player, true)
	
	-- Notify clients
	RemoteEvents.ParryResult:FireAllClients(player, true)
	
	-- Get player facing direction for reflection
	local character = player.Character
	local reflectDirection = Vector3.new(1, 0, 0) -- Default
	
	if character and character:FindFirstChild("HumanoidRootPart") then
		reflectDirection = character.HumanoidRootPart.CFrame.LookVector
	end
	
	-- Increase blade speed on deflection
	self.currentSpeed = math.min(
		self.currentSpeed + GameConfig.BLADE_DEFLECT_SPEED_INCREMENT,
		GameConfig.BLADE_MAX_SPEED
	)
	
	-- Visual feedback - blade bounces back briefly
	if self.blade then
		self.blade.Position = self.blade.Position + reflectDirection * 5
	end
	
	-- Retarget immediately after brief pause
	self:RetargetAfterPause(GameConfig.POST_DEFLECT_PAUSE)
end

function BladeController:RetargetAfterPause(pauseDuration)
	self.lastTarget = self.currentTarget
	self.currentTarget = nil
	self.state = GameEnums.BladeState.RETARGETING
	
	wait(pauseDuration)
	
	if self.isActive then
		self:SelectAndTargetPlayer()
	end
end

function BladeController:Cleanup()
	self:Stop()
	
	if self.blade then
		self.blade:Destroy()
		self.blade = nil
	end
end

return BladeController
