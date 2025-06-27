# District Zero - Troubleshooting Guide

## Common Issues and Solutions

### 1. Resource blocks spawning only after stopping the resource

**Problem**: Blips (map markers) only appear after stopping and restarting the resource.

**Solution**: 
- Use the debug command: `/dzdebug` to check if blips are being created
- If blips are not created, use `/dzreload` to restart the resource
- Ensure the resource is started after `qbx_core` and `ox_lib`

### 2. No map indicators for districts

**Problem**: District blips are not showing on the map.

**Solution**:
- Check if the resource is properly loaded with `/dzdebug`
- Verify that `Config.Districts` is loaded correctly
- Use `/dzreload` to restart the resource
- Check server console for any error messages

### 3. Commands not working

**Problem**: `/district` or `/dz` commands don't work.

**Solution**:
- The commands only work when you're inside a district zone
- Use `/dzdebug` to check your current district status
- Make sure you're in one of the configured districts:
  - Downtown Los Santos
  - Vinewood
  - Los Santos Port
  - Los Santos International
  - Sandy Shores

### 4. UI not opening

**Problem**: The district menu doesn't open when using the command.

**Solution**:
- You must be inside a district zone to open the menu
- Check if you're in a district with `/dzdebug`
- The UI will automatically show team selection if you haven't selected a team yet

## Available Commands

- `/district` - Open the district menu (only works in districts)
- `/dz` - Alias for `/district`
- `/dzdebug` - Show debug information about the resource
- `/dzreload` - Restart the resource

## Key Binding

- `F6` - Open district menu (same as `/district` command)

## District Locations

The following districts are configured:

1. **Downtown Los Santos** - Financial district around Maze Bank Tower
2. **Vinewood** - Entertainment district around Vinewood Sign
3. **Los Santos Port** - Industrial port area
4. **Los Santos International** - Airport area
5. **Sandy Shores** - Desert town

## Team System

- **PvP Team** - Fight against other players for district control
- **PvE Team** - Complete missions against AI enemies

## Mission System

- Missions are available based on your team selection
- You must be in a district to accept missions
- Missions have objectives that must be completed
- Rewards are given upon mission completion

## Troubleshooting Steps

1. **Check resource status**: Use `/dzdebug` to see if everything is loaded
2. **Verify location**: Make sure you're in a district zone
3. **Check dependencies**: Ensure `qbx_core` and `ox_lib` are running
4. **Restart resource**: Use `/dzreload` if needed
5. **Check server logs**: Look for any error messages in the server console

## Common Error Messages

- "You must be in a district to open the menu" - You're not in a district zone
- "Config not loaded" - The configuration failed to load
- "QBX Core not available" - The core framework isn't loaded

## Support

If you continue to have issues:
1. Check the server console for error messages
2. Use `/dzdebug` to get detailed information
3. Ensure all dependencies are properly installed and running
4. Verify the resource is started in the correct order 