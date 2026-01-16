--[[
	RoundManager.lua
	Server-side round management system
	Handles round state, player lifecycle, and round transitions
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local GameEnums = require(ReplicatedStorage.Modules.GameEnums)
local PlayerDataTracker = require(ReplicatedStorage.Modules.PlayerDataTracker)
local RemoteEvents = require(ReplicatedStorage.Modules.RemoteEventsSetup)
local BladeController = require(script.Parent.BladeController)

local RoundManager = {}
RoundManager.__index = RoundManager

function RoundManager.new()
	local self = setmetatable({}, RoundManager)
	
	self.state = GameEnums.RoundState.WAITING
	self.playerDataTracker = PlayerDataTracker.new()
	self.bladeController = BladeController.new(self.playerDataTracker)
	self.roundNumber = 0
	
	return self
end

function RoundManager:Initialize()
	print("FEINT - Initializing Round Manager")
	
	-- Initialize blade
	self.bladeController:Initialize()
	
	-- Set up player connections
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerJoined(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerLeaving(player)
	end)
	
	-- Initialize existing players
	for _, player in ipairs(Players:GetPlayers()) do
		self:OnPlayerJoined(player)
	end
	
	-- Set up parry input handler
	RemoteEvents.ParryInput.OnServerEvent:Connect(function(player, parryType)
		self:HandleParryInput(player, parryType)
	end)
	
	-- Start game loop
	self:StartGameLoop()
end

function RoundManager:OnPlayerJoined(player)
	print("Player joined:", player.Name)
	self.playerDataTracker:InitializePlayer(player)
	
	-- Respawn player if round is active
	if self.state == GameEnums.RoundState.ACTIVE or self.state == GameEnums.RoundState.WAITING then
		self:RespawnPlayer(player)
	end
end

function RoundManager:OnPlayerLeaving(player)
	print("Player leaving:", player.Name)
	self.playerDataTracker:RemovePlayer(player)
	
	-- Check if round should end
	if self.state == GameEnums.RoundState.ACTIVE then
		self:CheckRoundEnd()
	end
end

function RoundManager:RespawnPlayer(player)
	-- Wait for character to load
	if not player.Character then
		player.CharacterAdded:Wait()
	end
	
	local character = player.Character
	if not character then return end
	
	-- Position player in arena
	local spawnAngle = math.random() * math.pi * 2
	local spawnRadius = GameConfig.ARENA_SIZE * 0.7
	local spawnPosition = GameConfig.ARENA_CENTER + Vector3.new(
		math.cos(spawnAngle) * spawnRadius,
		0,
		math.sin(spawnAngle) * spawnRadius
	)
	
	if character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = CFrame.new(spawnPosition)
	end
	
	-- Reset character appearance if they were eliminated
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end
	
	-- Reset player state
	self.playerDataTracker:SetPlayerState(player, GameEnums.PlayerState.ALIVE)
end

function RoundManager:HandleParryInput(player, parryType)
	-- Validate parry type
	if parryType ~= GameEnums.ParryType.REAL and parryType ~= GameEnums.ParryType.FAKE then
		return
	end
	
	-- Forward to blade controller
	local success = self.bladeController:RegisterParryAttempt(player, parryType)
	
	-- Send feedback to client
	if success then
		RemoteEvents.ParryResult:FireClient(player, player, false) -- Not successful yet, just registered
	end
end

function RoundManager:StartGameLoop()
	while true do
		-- Wait for minimum players
		while #self.playerDataTracker:GetAlivePlayers() < GameConfig.MIN_PLAYERS_TO_START do
			self:SetState(GameEnums.RoundState.WAITING)
			RemoteEvents.UpdateRoundInfo:FireAllClients("Waiting for players...", 0)
			wait(2)
		end
		
		-- Start new round
		self:StartRound()
		
		-- Wait for round to end
		while self.state == GameEnums.RoundState.ACTIVE do
			wait(0.5)
			self:CheckRoundEnd()
		end
		
		-- Intermission
		self:SetState(GameEnums.RoundState.INTERMISSION)
		self:ShowIntermission()
		wait(GameConfig.ROUND_END_INTERMISSION)
	end
end

function RoundManager:StartRound()
	self.roundNumber = self.roundNumber + 1
	print("Starting round", self.roundNumber)
	
	self:SetState(GameEnums.RoundState.STARTING)
	RemoteEvents.UpdateRoundInfo:FireAllClients("Round " .. self.roundNumber .. " starting...", self.roundNumber)
	
	-- Reset all players
	self.playerDataTracker:ResetAllPlayers()
	
	-- Respawn all players
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			self:RespawnPlayer(player)
		end
	end
	
	wait(2)
	
	-- Start round
	self:SetState(GameEnums.RoundState.ACTIVE)
	RemoteEvents.UpdateRoundInfo:FireAllClients("Round " .. self.roundNumber .. " - Fight!", self.roundNumber)
	
	-- Start blade
	self.bladeController:Start()
end

function RoundManager:CheckRoundEnd()
	if self.state ~= GameEnums.RoundState.ACTIVE then return end
	
	local alivePlayers = self.playerDataTracker:GetAlivePlayers()
	
	if #alivePlayers <= 1 then
		self:EndRound(alivePlayers[1])
	end
end

function RoundManager:EndRound(winner)
	print("Round ended")
	
	self:SetState(GameEnums.RoundState.ENDING)
	
	-- Stop blade
	self.bladeController:Stop()
	
	-- Announce winner
	if winner then
		RemoteEvents.UpdateRoundInfo:FireAllClients(winner.Name .. " wins round " .. self.roundNumber .. "!", self.roundNumber)
	else
		RemoteEvents.UpdateRoundInfo:FireAllClients("Round " .. self.roundNumber .. " ended - No winner", self.roundNumber)
	end
end

function RoundManager:ShowIntermission()
	local alivePlayers = self.playerDataTracker:GetAlivePlayers()
	local winner = alivePlayers[1]
	
	if winner then
		RemoteEvents.UpdateRoundInfo:FireAllClients("Winner: " .. winner.Name .. " - Next round starting soon...", self.roundNumber)
	else
		RemoteEvents.UpdateRoundInfo:FireAllClients("Next round starting soon...", self.roundNumber)
	end
end

function RoundManager:SetState(newState)
	self.state = newState
	RemoteEvents.RoundStateChanged:FireAllClients(newState)
end

return RoundManager
