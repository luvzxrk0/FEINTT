--[[
	GameEnums.lua
	Shared enumerations for FEINT game
]]

local GameEnums = {}

-- Round states
GameEnums.RoundState = {
	WAITING = "Waiting",
	STARTING = "Starting",
	ACTIVE = "Active",
	ENDING = "Ending",
	INTERMISSION = "Intermission"
}

-- Blade states
GameEnums.BladeState = {
	IDLE = "Idle",
	WARNING = "Warning",
	DASHING = "Dashing",
	RETARGETING = "Retargeting"
}

-- Parry types
GameEnums.ParryType = {
	REAL = "Real",
	FAKE = "Fake"
}

-- Player states
GameEnums.PlayerState = {
	ALIVE = "Alive",
	ELIMINATED = "Eliminated",
	SPECTATING = "Spectating"
}

return GameEnums
