--[[
	RemoteEventsSetup.lua
	Creates and returns references to all RemoteEvents used in the game
	This should be required by both server and client scripts
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemoteEventsFolder then
	RemoteEventsFolder = Instance.new("Folder")
	RemoteEventsFolder.Name = "RemoteEvents"
	RemoteEventsFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemoteEvent(name)
	local event = RemoteEventsFolder:FindFirstChild(name)
	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = RemoteEventsFolder
	end
	return event
end

local RemoteEvents = {
	-- Client to Server
	ParryInput = getOrCreateRemoteEvent("ParryInput"),
	
	-- Server to Client
	RoundStateChanged = getOrCreateRemoteEvent("RoundStateChanged"),
	BladeTargetChanged = getOrCreateRemoteEvent("BladeTargetChanged"),
	BladeWarning = getOrCreateRemoteEvent("BladeWarning"),
	BladeAttack = getOrCreateRemoteEvent("BladeAttack"),
	PlayerEliminated = getOrCreateRemoteEvent("PlayerEliminated"),
	ParryResult = getOrCreateRemoteEvent("ParryResult"),
	UpdateRoundInfo = getOrCreateRemoteEvent("UpdateRoundInfo")
}

return RemoteEvents
