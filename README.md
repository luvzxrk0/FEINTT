# FEINT - Competitive Arena Game

A Roblox Lua game featuring server-controlled autonomous blade combat in a competitive arena.

## Overview

FEINT is a multiplayer survival game where players face off against an intelligent, server-controlled blade that hunts them down. Players must use precise timing to parry attacks or be eliminated and frozen as statues.

## Quick Start

1. Copy files from `src/` to your Roblox Studio project
2. Replace placeholder asset IDs in `GameConfig.lua` with your own sounds and animations
3. Create an arena around position (0, 10, 0)
4. Test with at least 2 players

## Key Features

- **Full server-side logic** for fair gameplay
- **Intelligent targeting** using weighted player selection
- **Parry system** with real (deflects blade) and fake (animation only) options
- **Progressive difficulty** - blade speeds up as players are eliminated
- **Round management** with automatic restart

## Controls

- **Real Parry**: Q or Left Mouse Button
- **Fake Parry**: E or Right Mouse Button

## Documentation

See [GAME_DOCUMENTATION.md](GAME_DOCUMENTATION.md) for complete setup instructions, configuration options, and gameplay details.

## Structure

```
src/
├── ServerScriptService/     # Server-side game logic
├── ReplicatedStorage/       # Shared modules and configuration
└── StarterPlayer/           # Client-side scripts and UI
```

## Configuration Required

⚠️ **Important**: Replace placeholder asset IDs in `src/ReplicatedStorage/Modules/GameConfig.lua`:
- Warning sound
- Hit sound  
- Parry success sound
- Real parry animation
- Fake parry animation

See documentation for details on obtaining and setting up these assets.