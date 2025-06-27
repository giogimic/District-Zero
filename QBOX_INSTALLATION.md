# District Zero - QBox Framework Installation Guide

This guide will walk you through installing District Zero on a QBox Framework server.

## Prerequisites

Before installing District Zero, ensure you have:

1. **FiveM Server** with the latest artifacts
2. **QBox Framework** properly installed and configured
3. **MariaDB** database (as required by QBox)
4. **txAdmin** access for server management

## Step 1: QBox Framework Installation

### 1.1 Download QBox Framework

1. Visit the [QBox Documentation](https://docs.qbox.re/installation)
2. Download the latest FiveM artifacts (do not use the buttons at the top)
3. Extract the `server.7z` file to your server directory

### 1.2 Install QBox Framework

1. Run `FXServer.exe` to start txAdmin
2. Follow the QBox installation steps in txAdmin
3. Select "Popular Recipes" → "QBox Framework"
4. Complete the QBox installation process

### 1.3 Verify QBox Installation

Ensure these resources are properly loaded:
- `qbx_core`
- `oxmysql`
- `ox_lib`

## Step 2: District Zero Installation

### 2.1 Download District Zero

```bash
cd resources
git clone https://github.com/district-zero/fivem-mm.git district-zero
cd district-zero
```

### 2.2 Database Setup

1. **Create Database Tables**
   ```sql
   -- Connect to your MariaDB database
   mysql -u root -p qbox
   
   -- Import the District Zero schema
   source server/database/migrations/001_initial_schema.sql
   ```

2. **Verify Database Tables**
   ```sql
   SHOW TABLES LIKE 'district_zero%';
   ```

### 2.3 Resource Configuration

1. **Add to server.cfg**
   ```cfg
   # QBox Framework (must be loaded first)
   ensure qbx_core
   ensure oxmysql
   ensure ox_lib
   
   # Optional QBox resources
   ensure qbx_management
   ensure qbx_vehicleshop
   ensure qbx_garages
   
   # District Zero
   ensure district-zero
   ```

2. **Resource Loading Order**
   Ensure resources are loaded in this order:
   ```cfg
   # Core QBox resources first
   ensure qbx_core
   ensure oxmysql
   ensure ox_lib
   
   # Then District Zero
   ensure district-zero
   ```

### 2.4 Configuration Setup

1. **Edit Configuration File**
   ```bash
   nano shared/config.lua
   ```

2. **Update Database Settings**
   ```lua
   Config.Database = {
       type = 'oxmysql',
       host = 'localhost',
       port = 3306,
       database = 'qbox', -- Your QBox database name
       username = 'root',
       password = 'your_password',
       charset = 'utf8mb4',
       connectionLimit = 10,
       acquireTimeout = 60000,
       timeout = 60000,
       reconnect = true
   }
   ```

3. **Configure QBox Integration**
   ```lua
   Config.QBox = {
       enabled = true,
       coreResource = 'qbx_core',
       databaseResource = 'oxmysql',
       useQBoxNotifications = true,
       useQBoxInventory = false, -- Set to true if using qbx_inventory
       useQBoxVehicles = false,  -- Set to true if using qbx_vehicleshop
       useQBoxManagement = false, -- Set to true if using qbx_management
       useQBoxGarages = false    -- Set to true if using qbx_garages
   }
   ```

## Step 3: Verification

### 3.1 Check Resource Status

1. **In txAdmin Console**
   ```
   status
   ```

2. **Check for Errors**
   ```
   refresh
   restart district-zero
   ```

### 3.2 Test QBox Integration

1. **Join the Server**
   - Connect to your FiveM server
   - Check if District Zero features are available

2. **Test Commands**
   ```
   /district help
   /mission help
   /team help
   ```

### 3.3 Verify Database Connection

1. **Check Database Tables**
   ```sql
   USE qbox;
   SELECT COUNT(*) FROM district_zero_districts;
   SELECT COUNT(*) FROM district_zero_missions;
   SELECT COUNT(*) FROM district_zero_teams;
   ```

## Step 4: Configuration

### 4.1 District Configuration

Edit `config/districts.lua`:
```lua
Config.Districts = {
    {
        id = 'downtown',
        name = 'Downtown',
        description = 'The heart of the city',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(-200.0, -800.0, 30.0)
        },
        zones = {
            {
                name = 'Downtown Core',
                coords = vector3(-200.0, -800.0, 30.0),
                radius = 200.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                id = 'city_hall',
                name = 'City Hall',
                coords = vector3(-200.0, -800.0, 30.0),
                radius = 50.0,
                influence = 25
            }
        }
    }
}
```

### 4.2 Mission Configuration

Edit `config/missions.lua`:
```lua
Config.Missions = {
    {
        id = 'pvp_1',
        title = 'Territory Control',
        description = 'Capture and hold control points',
        type = 'pvp',
        reward = 2000,
        district = 'downtown',
        timeLimit = 300,
        objectives = {
            {
                type = 'capture',
                description = 'Capture the control point',
                coords = vector3(-200.0, -800.0, 30.0),
                radius = 10.0
            }
        }
    }
}
```

## Step 5: Troubleshooting

### 5.1 Common Issues

**Issue: Resource fails to start**
```
Solution: Check dependencies are loaded in correct order
```

**Issue: Database connection errors**
```
Solution: Verify MariaDB is running and credentials are correct
```

**Issue: QBox integration not working**
```
Solution: Ensure qbx_core is loaded before district-zero
```

### 5.2 Debug Mode

Enable debug mode in `shared/config.lua`:
```lua
Config.Development = {
    debug = true,
    verbose = true,
    testing = false,
    mockData = false,
    hotReload = false
}
```

### 5.3 Logs

Check server logs for errors:
```bash
tail -f /path/to/server/logs/server.log
```

## Step 6: Post-Installation

### 6.1 Performance Optimization

1. **Database Indexing**
   ```sql
   CREATE INDEX idx_district_zero_player_id ON district_zero_players(player_id);
   CREATE INDEX idx_district_zero_mission_id ON district_zero_missions(id);
   CREATE INDEX idx_district_zero_team_id ON district_zero_teams(id);
   ```

2. **Resource Optimization**
   - Monitor resource usage in txAdmin
   - Adjust configuration based on server performance

### 6.2 Security Considerations

1. **Database Security**
   - Use strong passwords
   - Limit database user permissions
   - Regular backups

2. **Resource Security**
   - Keep resources updated
   - Monitor for unauthorized access
   - Regular security audits

## Support

For additional support:

- **QBox Documentation**: https://docs.qbox.re/
- **District Zero Issues**: https://github.com/district-zero/fivem-mm/issues
- **QBox Discord**: Check QBox documentation for Discord link

## Version Compatibility

- **QBox Framework**: Latest version
- **FiveM**: Latest artifacts
- **MariaDB**: 10.5+ (as per QBox requirements)
- **District Zero**: 1.0.0+

---

**Note**: This installation guide assumes you have a working QBox Framework installation. If you encounter issues with QBox itself, please refer to the [official QBox documentation](https://docs.qbox.re/installation). 