-- District Zero Districts Configuration
-- Version: 1.0.0

Config = Config or {}
Config.Districts = {
    {
        id = 'downtown',
        name = 'Downtown Los Santos',
        description = 'The heart of Los Santos, featuring the Maze Bank Tower and surrounding financial district',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(-75.0, -818.0, 243.0) -- Maze Bank Tower
        },
        zones = {
            {
                name = 'Financial District',
                coords = vector3(-75.0, -818.0, 243.0),
                radius = 300.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                name = 'Maze Bank Tower',
                coords = vector3(-75.0, -818.0, 243.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Lombank Building',
                coords = vector3(-158.0, -565.0, 34.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Arcadius Center',
                coords = vector3(-141.0, -620.0, 168.0),
                radius = 50.0,
                influence = 25
            }
        }
    },
    {
        id = 'industrial',
        name = 'Industrial District',
        description = 'The industrial heart of Los Santos',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(800.0, -1200.0, 30.0)
        },
        zones = {
            {
                name = 'Industrial Zone',
                coords = vector3(800.0, -1200.0, 30.0),
                radius = 500.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                name = 'Factory Complex',
                coords = vector3(800.0, -1200.0, 30.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Warehouse District',
                coords = vector3(900.0, -1300.0, 30.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Shipping Yard',
                coords = vector3(700.0, -1100.0, 30.0),
                radius = 50.0,
                influence = 25
            }
        }
    },
    {
        id = 'residential',
        name = 'Residential District',
        description = 'Where the citizens live',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(1200.0, -400.0, 30.0)
        },
        zones = {
            {
                name = 'Residential Zone',
                coords = vector3(1200.0, -400.0, 30.0),
                radius = 500.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                name = 'Community Center',
                coords = vector3(1200.0, -400.0, 30.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Shopping Mall',
                coords = vector3(1300.0, -500.0, 30.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Park',
                coords = vector3(1100.0, -300.0, 30.0),
                radius = 50.0,
                influence = 25
            }
        }
    }
} 