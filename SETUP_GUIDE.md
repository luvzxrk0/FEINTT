# FEINT - Roblox Studio Setup Guide

This guide walks you through setting up the FEINT game in Roblox Studio.

## Prerequisites

- Roblox Studio installed
- Basic familiarity with Roblox Studio interface
- At least 2 players for testing (use local server or publish to test)

## Step-by-Step Setup

### 1. Create or Open a Roblox Place

1. Open Roblox Studio
2. Create a new Baseplate template or open an existing place
3. Save the place with a meaningful name (e.g., "FEINT Arena")

### 2. Set Up the Arena

1. In the Workspace, create a large baseplate centered around (0, 0, 0)
   - Recommended size: 100x1x100 studs
   - Position: (0, 0, 0)
   
2. The blade will spawn at (0, 10, 0) by default
   - Ensure this position is above your arena floor
   - Adjust `ARENA_CENTER` in GameConfig.lua if needed

3. Optional: Add walls or boundaries around the arena

### 3. Import Server Scripts

In **ServerScriptService**:

1. Create a new Script (not LocalScript)
2. Name it "MainServer"
3. Copy contents from `src/ServerScriptService/MainServer.lua`
4. Create another Script named "RoundManager"
5. Copy contents from `src/ServerScriptService/RoundManager.lua`
6. Create another Script named "BladeController"
7. Copy contents from `src/ServerScriptService/BladeController.lua`

### 4. Set Up ReplicatedStorage

In **ReplicatedStorage**:

1. Create a Folder named "Modules"
2. Inside the Modules folder, create ModuleScripts:
   - "GameConfig" - copy from `src/ReplicatedStorage/Modules/GameConfig.lua`
   - "GameEnums" - copy from `src/ReplicatedStorage/Modules/GameEnums.lua`
   - "PlayerDataTracker" - copy from `src/ReplicatedStorage/Modules/PlayerDataTracker.lua`
   - "RemoteEventsSetup" - copy from `src/ReplicatedStorage/Modules/RemoteEventsSetup.lua`

### 5. Set Up Client Scripts

In **StarterPlayer** > **StarterPlayerScripts**:

1. Create a LocalScript named "ParryInputHandler"
2. Copy contents from `src/StarterPlayer/StarterPlayerScripts/ParryInputHandler.lua`
3. Create a LocalScript named "ClientEffectsHandler"
4. Copy contents from `src/StarterPlayer/StarterPlayerScripts/ClientEffectsHandler.lua`
5. Create a LocalScript named "RoundInfoUI"
6. Copy contents from `src/StarterPlayer/StarterPlayerScripts/RoundInfoUI.lua`

### 6. Configure Asset IDs

**IMPORTANT**: The game uses placeholder asset IDs that must be replaced.

1. Open the **GameConfig** ModuleScript in ReplicatedStorage/Modules
2. Find the placeholder asset IDs (search for "TODO")
3. Replace them with your actual Roblox asset IDs:

#### Getting Sound Asset IDs:

**Option A: Use Roblox Toolbox**
1. Go to View > Toolbox in Roblox Studio
2. Search for free sound effects
3. Insert them into your game
4. Right-click the sound > Properties
5. Copy the SoundId (it will be in format "rbxassetid://123456")

**Option B: Upload Your Own**
1. Go to Roblox.com > Create > Audio
2. Upload your audio files
3. Wait for moderation approval
4. Copy the asset IDs

**Recommended sounds to find:**
- Warning sound: Alert/siren sound
- Hit sound: Impact/slash sound
- Parry success sound: Success/ding sound

#### Getting Animation Asset IDs:

1. Open Animation Editor in Roblox Studio (Plugins > Animation Editor)
2. Create a simple parry animation:
   - **Real Parry**: Quick defensive pose (arms raised, slight crouch)
   - **Fake Parry**: Similar but slightly different timing
3. Save and publish each animation
4. Copy the animation asset IDs
5. Paste into GameConfig.lua

**Quick Workaround**: You can use dummy animation IDs temporarily. The game will work but animations won't play until you use real IDs.

### 7. Final Checks

Before testing:

1. **Verify folder structure**:
   ```
   ServerScriptService
   ├── MainServer (Script)
   ├── RoundManager (Script)
   └── BladeController (Script)
   
   ReplicatedStorage
   └── Modules (Folder)
       ├── GameConfig (ModuleScript)
       ├── GameEnums (ModuleScript)
       ├── PlayerDataTracker (ModuleScript)
       └── RemoteEventsSetup (ModuleScript)
   
   StarterPlayer
   └── StarterPlayerScripts
       ├── ParryInputHandler (LocalScript)
       ├── ClientEffectsHandler (LocalScript)
       └── RoundInfoUI (LocalScript)
   ```

2. **Check spawn locations**: Make sure player spawn points are in the arena

3. **Review Output window**: Open View > Output to see debug messages

### 8. Testing

**Local Server Test** (Recommended):

1. Go to Test tab in Roblox Studio
2. Click "Local Server"
3. Set number of players to 2 or more
4. Click "Start"
5. Multiple windows will open, each simulating a player

**What to expect:**
- "FEINT - Server Starting" message in output
- UI appears showing round state
- After 2+ players join, round starts automatically
- Blade spawns at center and begins hunting
- Red warning appears when you're targeted
- Press Q (or Left Click) to attempt real parry
- Press E (or Right Click) to attempt fake parry

## Troubleshooting

### "attempt to index nil value"
- Check that all ModuleScripts are in the correct folders
- Verify script names match exactly (case-sensitive)
- Ensure RemoteEventsSetup is in ReplicatedStorage/Modules

### Blade doesn't appear
- Check that game started with 2+ players
- Look in Workspace for "Blade" part
- Check Output window for errors

### Parry inputs don't work
- Verify LocalScripts are in StarterPlayerScripts (not ServerScriptService)
- Check that RemoteEvents are being created
- Look in ReplicatedStorage for "RemoteEvents" folder during runtime

### Players spawn in wrong location
- Check ARENA_CENTER in GameConfig
- Ensure spawn locations exist in Workspace
- Verify arena floor is below spawn height

### Animations don't play
- Replace placeholder animation IDs with real ones
- Ensure animations are published and public
- Check animation is compatible with your character rig type (R6/R15)

## Customization Tips

### Change Arena Size
Edit `GameConfig.lua`:
```lua
GameConfig.ARENA_SIZE = 100 -- Increase for larger arena
```

### Make Blade Faster/Slower
Edit `GameConfig.lua`:
```lua
GameConfig.BLADE_DASH_SPEED = 120 -- Default is 80
```

### Adjust Parry Difficulty
Edit `GameConfig.lua`:
```lua
GameConfig.REAL_PARRY_WINDOW = 0.25 -- Larger = easier (default 0.15)
```

### Change Blade Appearance
Edit `BladeController.lua`, in the `CreateBlade()` function:
```lua
blade.Color = Color3.fromRGB(0, 255, 255) -- Change to cyan
blade.Material = Enum.Material.Glass -- Change material
```

## Next Steps

- Create a custom arena environment
- Add decorative elements
- Design a lobby area
- Create a leaderboard UI
- Add more visual effects
- Publish and test with real players!

## Support

For issues or questions, refer to:
- [GAME_DOCUMENTATION.md](GAME_DOCUMENTATION.md) - Complete game documentation
- [README.md](README.md) - Project overview
- GitHub Issues - Report bugs or request features
