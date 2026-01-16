# FEINT - Competitive Arena Game

A Roblox Lua game featuring a server-controlled autonomous blade that hunts players in a competitive arena setting.

## Game Description

FEINT is a competitive multiplayer arena game where players must survive against an autonomous blade controlled entirely by the server. The blade uses intelligent targeting, gives warnings before attacking, and players can attempt to parry attacks with precise timing.

## Features

### Core Gameplay
- **Server-Side Round Logic**: All game logic runs on the server for security and fairness
- **Autonomous Blade**: AI-controlled blade that targets players using weighted selection
- **Parry System**: Two parry types with shared cooldown
  - Real Parry: Very small timing window, reflects blade on success
  - Fake Parry: Animation only, no reflection
- **Progressive Difficulty**: Blade speeds up and warning times decrease as players are eliminated
- **Player Elimination**: Hit players are frozen as statues
- **Round Management**: Automatic round start, end, and intermission

### Intelligent Targeting
The blade uses weighted selection based on:
- **Movement Frequency**: Tracks how often players move
- **Reaction Timing**: Records parry reaction times
- **Parry Behavior**: Analyzes successful parry history
- **Anti-Repetition**: Won't target the same player twice in a row (unless only 2 remain)

### Difficulty Scaling
- Blade speed increases on each elimination and successful parry
- Warning time decreases as players are eliminated
- Warning beam is removed when 3 or fewer players remain
- Retargeting happens faster with fewer players

## Installation

### File Structure
```
FEINTT/
├── src/
│   ├── ServerScriptService/
│   │   ├── MainServer.lua              # Main server initialization
│   │   ├── RoundManager.lua            # Round state management
│   │   └── BladeController.lua         # Blade AI and physics
│   ├── ReplicatedStorage/
│   │   └── Modules/
│   │       ├── GameConfig.lua          # Configuration settings
│   │       ├── GameEnums.lua           # Shared enumerations
│   │       ├── PlayerDataTracker.lua   # Player statistics tracking
│   │       └── RemoteEventsSetup.lua   # Remote event references
│   └── StarterPlayer/
│       └── StarterPlayerScripts/
│           ├── ParryInputHandler.lua   # Client parry input
│           ├── ClientEffectsHandler.lua # Visual and audio effects
│           └── RoundInfoUI.lua         # Round info display
```

### Setup Instructions

1. **Create a new Roblox place** or open an existing one

2. **Copy the source files** to your Roblox Studio project:
   - Copy files from `src/ServerScriptService/` to `ServerScriptService`
   - Copy files from `src/ReplicatedStorage/` to `ReplicatedStorage`
   - Copy files from `src/StarterPlayer/` to `StarterPlayer/StarterPlayerScripts`

3. **Create the arena**:
   - The blade spawns at position (0, 10, 0) by default
   - Create a baseplate or arena floor around this position
   - Recommended arena size: 50 studs radius
   - Ensure spawn locations are within the arena

4. **Configure asset IDs** (see below)

5. **Test with at least 2 players** in a local server or published game

## Configuration

### Asset IDs (IMPORTANT)

The game uses placeholder asset IDs that **must be replaced** with actual Roblox assets:

Edit `src/ReplicatedStorage/Modules/GameConfig.lua`:

```lua
-- Sound Effects
GameConfig.WARNING_SOUND_ID = "rbxassetid://YOUR_WARNING_SOUND_ID"
GameConfig.BLADE_HIT_SOUND_ID = "rbxassetid://YOUR_HIT_SOUND_ID"
GameConfig.PARRY_SUCCESS_SOUND_ID = "rbxassetid://YOUR_SUCCESS_SOUND_ID"

-- Animations
GameConfig.REAL_PARRY_ANIMATION_ID = "rbxassetid://YOUR_REAL_PARRY_ANIM_ID"
GameConfig.FAKE_PARRY_ANIMATION_ID = "rbxassetid://YOUR_FAKE_PARRY_ANIM_ID"
```

#### How to Get Asset IDs:

**For Sounds:**
1. Upload audio files to Roblox or use Audio Library
2. Get the asset ID from the audio's properties
3. Replace the placeholder IDs in GameConfig.lua

**For Animations:**
1. Create animations using Roblox Animation Editor
2. Publish the animations to Roblox
3. Get the animation asset IDs
4. Replace the placeholder IDs in GameConfig.lua

### Game Settings

Edit `src/ReplicatedStorage/Modules/GameConfig.lua` to customize:

**Blade Physics:**
- `BLADE_DASH_SPEED`: Initial blade speed (default: 80)
- `BLADE_SPEED_INCREMENT`: Speed increase per hit (default: 5)
- `BLADE_MAX_SPEED`: Maximum blade speed (default: 200)

**Warning System:**
- `WARNING_DELAY_MIN`: Minimum warning time (default: 2.0 seconds)
- `WARNING_DELAY_MAX`: Maximum warning time (default: 3.5 seconds)
- `WARNING_BEAM_REMOVE_THRESHOLD`: Players remaining when beam is removed (default: 3)

**Parry System:**
- `REAL_PARRY_WINDOW`: Timing window for successful parry (default: 0.15 seconds)
- `PARRY_COOLDOWN`: Cooldown between parry attempts (default: 1.5 seconds)

**Round Timing:**
- `ROUND_START_DELAY`: Delay before blade activates (default: 3 seconds)
- `ROUND_END_INTERMISSION`: Time between rounds (default: 5 seconds)
- `MIN_PLAYERS_TO_START`: Minimum players to start (default: 2)

**Arena:**
- `ARENA_CENTER`: Blade spawn position (default: Vector3.new(0, 10, 0))
- `ARENA_SIZE`: Arena radius (default: 50)

## Controls

- **Real Parry**: Q key or Left Mouse Button
- **Fake Parry**: E key or Right Mouse Button

## How to Play

1. **Round Start**: Players spawn around the arena. Blade spawns at center.
2. **Blade Activation**: After a short delay, the blade selects its first target.
3. **Warning Phase**: 
   - Target player sees a red warning overlay
   - Warning sound plays
   - Yellow beam connects blade to target (removed when ≤3 players)
   - Players can move or prepare to parry during this time
4. **Blade Attack**: After the warning delay, blade dashes to target's last position
5. **Parry Timing**:
   - Use Real Parry (Q or Left Click) with precise timing to deflect
   - Successful parry reflects the blade and immediately retargets
   - Fake Parry (E or Right Click) plays animation but doesn't deflect
6. **Elimination**: If hit without successful parry, player is frozen as a statue
7. **Round End**: Last player standing wins the round
8. **Intermission**: Brief pause before next round begins

## Technical Details

### Server-Side Logic
- All game state is managed server-side
- Blade movement uses physics-based BodyVelocity
- Hit detection uses raycasting for precision
- Player data is tracked for weighted targeting

### Client-Side
- Handles input and sends to server
- Displays visual effects and UI
- Plays animations and sounds
- No client-side prediction for fairness

### Safe Player Handling
- Players can join/leave during rounds
- Character respawn is handled safely
- Player leaving mid-round is detected and round can end appropriately
- State is reset cleanly between rounds

## Development Notes

### TODO Items
- Replace placeholder asset IDs with real Roblox assets
- Create custom animations for real and fake parries
- Add sound effects for warning, hit, and parry success
- Design custom blade model (currently uses a basic red neon part)
- Create arena map/environment
- Add particle effects for blade movement
- Add leaderboard system for tracking wins

### Future Enhancements
- Multiple blade variants with different behaviors
- Power-ups or special abilities
- Team modes
- Custom arena maps
- Spectator mode UI
- Replay system
- Statistics dashboard

## Troubleshooting

**Blade doesn't move:**
- Check that at least 2 players are in the game
- Verify MainServer.lua is in ServerScriptService
- Check output console for errors

**Parry doesn't work:**
- Ensure ParryInputHandler.lua is in StarterPlayerScripts
- Check that RemoteEvents are set up correctly
- Verify animations are loaded (check output console)

**Players not spawning:**
- Check that character spawn locations exist
- Verify ARENA_CENTER position is above ground
- Ensure spawn points are in workspace

**Animations don't play:**
- Replace placeholder animation IDs with real ones
- Verify animations are published and accessible
- Check that animations are compatible with R15/R6 as needed

## Credits

Created for the FEINT project (luvzxrk0/FEINTT)

## License

See repository license.
