--[[
	MainServer.lua
	Main server initialization script for FEINT
	Place this in ServerScriptService
]]

local RoundManager = require(script.Parent.RoundManager)

print("=================================")
print("FEINT - Server Starting")
print("=================================")

-- Initialize the game
local roundManager = RoundManager.new()
roundManager:Initialize()

print("FEINT - Server Ready")
