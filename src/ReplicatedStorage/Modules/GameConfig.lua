--[[
	GameConfig.lua
	Configuration module for FEINT game
	Contains all tunable parameters for blade behavior, timing, and round logic
]]

local GameConfig = {}

-- Blade Physics
GameConfig.BLADE_DASH_SPEED = 80 -- Initial blade dash speed
GameConfig.BLADE_SPEED_INCREMENT = 5 -- Speed increase per successful hit
GameConfig.BLADE_DEFLECT_SPEED_INCREMENT = 8 -- Speed increase per deflection
GameConfig.BLADE_MAX_SPEED = 200 -- Maximum blade speed
GameConfig.BLADE_SIZE = Vector3.new(2, 0.5, 4) -- Blade dimensions

-- Warning Phase
GameConfig.WARNING_DELAY_MIN = 2.0 -- Minimum warning time (seconds)
GameConfig.WARNING_DELAY_MAX = 3.5 -- Maximum warning time (seconds)
GameConfig.WARNING_DELAY_REDUCTION = 0.2 -- Reduction per elimination
GameConfig.MIN_WARNING_DELAY = 0.5 -- Minimum possible warning time
GameConfig.WARNING_BEAM_REMOVE_THRESHOLD = 3 -- Remove beam when this many players remain

-- Parry System
GameConfig.REAL_PARRY_WINDOW = 0.15 -- Very small timing window for real parry (seconds)
GameConfig.PARRY_COOLDOWN = 1.5 -- Cooldown for all parry actions (seconds)
GameConfig.PARRY_REFLECT_SPEED = 1.2 -- Multiplier for blade speed on deflect

-- Targeting System Weights
GameConfig.MOVEMENT_WEIGHT = 1.0 -- Weight for movement frequency
GameConfig.REACTION_WEIGHT = 1.5 -- Weight for reaction timing
GameConfig.PARRY_HISTORY_WEIGHT = 1.2 -- Weight for parry behavior

-- Round Timing
GameConfig.ROUND_START_DELAY = 3 -- Delay before blade activates (seconds)
GameConfig.POST_ELIMINATION_PAUSE = 1.0 -- Pause after elimination before retarget (seconds)
GameConfig.POST_DEFLECT_PAUSE = 0.3 -- Pause after deflection before retarget (seconds)
GameConfig.ROUND_END_INTERMISSION = 5 -- Time between rounds (seconds)
GameConfig.MIN_PLAYERS_TO_START = 2 -- Minimum players needed to start round

-- Arena
GameConfig.ARENA_CENTER = Vector3.new(0, 10, 0) -- Blade spawn position
GameConfig.ARENA_SIZE = 50 -- Radius of arena

-- Placeholder Asset IDs
-- TODO: Replace these with actual Roblox asset IDs
GameConfig.WARNING_SOUND_ID = "rbxassetid://0000000000" -- Replace with actual warning sound asset
GameConfig.BLADE_HIT_SOUND_ID = "rbxassetid://0000000000" -- Replace with blade hit sound
GameConfig.PARRY_SUCCESS_SOUND_ID = "rbxassetid://0000000000" -- Replace with parry success sound

-- Animation IDs (Placeholder)
-- TODO: Replace these with actual animation asset IDs from Roblox
GameConfig.REAL_PARRY_ANIMATION_ID = "rbxassetid://0000000000" -- Replace with real parry animation
GameConfig.FAKE_PARRY_ANIMATION_ID = "rbxassetid://0000000000" -- Replace with fake parry animation

return GameConfig
