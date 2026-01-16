--[[
	PlayerDataTracker.lua
	Tracks player statistics for weighted targeting
]]

local GameEnums = require(script.Parent.GameEnums)

local PlayerDataTracker = {}
PlayerDataTracker.__index = PlayerDataTracker

function PlayerDataTracker.new()
	local self = setmetatable({}, PlayerDataTracker)
	self.playerData = {}
	return self
end

function PlayerDataTracker:InitializePlayer(player)
	if not self.playerData[player] then
		self.playerData[player] = {
			state = GameEnums.PlayerState.ALIVE,
			movementCount = 0,
			lastPosition = nil,
			reactionTimes = {}, -- Array of reaction times
			parryAttempts = 0,
			successfulParries = 0,
			lastTargetTime = 0,
			parryCooldownEnd = 0
		}
	end
end

function PlayerDataTracker:RemovePlayer(player)
	self.playerData[player] = nil
end

function PlayerDataTracker:UpdateMovement(player, currentPosition)
	local data = self.playerData[player]
	if not data then return end
	
	if data.lastPosition then
		local distance = (currentPosition - data.lastPosition).Magnitude
		if distance > 3 then -- Threshold for significant movement
			data.movementCount = data.movementCount + 1
		end
	end
	data.lastPosition = currentPosition
end

function PlayerDataTracker:RecordReactionTime(player, reactionTime)
	local data = self.playerData[player]
	if not data then return end
	
	table.insert(data.reactionTimes, reactionTime)
	-- Keep only last 5 reaction times
	if #data.reactionTimes > 5 then
		table.remove(data.reactionTimes, 1)
	end
end

function PlayerDataTracker:RecordParryAttempt(player, successful)
	local data = self.playerData[player]
	if not data then return end
	
	data.parryAttempts = data.parryAttempts + 1
	if successful then
		data.successfulParries = data.successfulParries + 1
	end
end

function PlayerDataTracker:SetPlayerState(player, state)
	local data = self.playerData[player]
	if not data then return end
	data.state = state
end

function PlayerDataTracker:GetPlayerState(player)
	local data = self.playerData[player]
	return data and data.state or GameEnums.PlayerState.SPECTATING
end

function PlayerDataTracker:IsOnCooldown(player)
	local data = self.playerData[player]
	if not data then return true end
	return tick() < data.parryCooldownEnd
end

function PlayerDataTracker:SetParryCooldown(player, duration)
	local data = self.playerData[player]
	if not data then return end
	data.parryCooldownEnd = tick() + duration
end

function PlayerDataTracker:GetPlayerData(player)
	return self.playerData[player]
end

function PlayerDataTracker:GetAlivePlayers()
	local alivePlayers = {}
	for player, data in pairs(self.playerData) do
		if data.state == GameEnums.PlayerState.ALIVE then
			table.insert(alivePlayers, player)
		end
	end
	return alivePlayers
end

function PlayerDataTracker:ResetAllPlayers()
	for player, data in pairs(self.playerData) do
		data.state = GameEnums.PlayerState.ALIVE
		data.movementCount = 0
		data.lastPosition = nil
		data.reactionTimes = {}
		data.parryAttempts = 0
		data.successfulParries = 0
		data.lastTargetTime = 0
		data.parryCooldownEnd = 0
	end
end

return PlayerDataTracker
