Config = {}

-- Core Settings
Config.Debug = true
Config.Locale = 'en'

-- Districts Configuration
Config.Districts = {
    {
        id = 'downtown',
        name = 'Downtown',
        description = 'The heart of the city',
        owner = 'neutral',
        influence = 0,
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
                name = 'City Hall',
                coords = vector3(-200.0, -800.0, 30.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Financial District',
                coords = vector3(-150.0, -750.0, 30.0),
                radius = 50.0,
                influence = 25
            }
        }
    },
    {
        id = 'industrial',
        name = 'Industrial Zone',
        description = 'The industrial heartland',
        owner = 'neutral',
        influence = 0,
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(800.0, -1200.0, 30.0)
        },
        zones = {
            {
                name = 'Industrial Core',
                coords = vector3(800.0, -1200.0, 30.0),
                radius = 200.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                name = 'Factory',
                coords = vector3(800.0, -1200.0, 30.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Warehouse',
                coords = vector3(850.0, -1150.0, 30.0),
                radius = 50.0,
                influence = 25
            }
        }
    }
}

-- Missions Configuration
Config.Missions = {
    -- PvP Missions
    {
        id = 'pvp_1',
        title = 'Territory Control',
        description = 'Capture and hold control points',
        type = 'pvp',
        reward = 2000,
        district = 'downtown',
        objectives = {
            {
                type = 'capture',
                target = 'control_point',
                count = 1,
                timeLimit = 300
            }
        }
    },
    -- PvE Missions
    {
        id = 'pve_1',
        title = 'Clear the Area',
        description = 'Eliminate hostile NPCs',
        type = 'pve',
        reward = 1500,
        district = 'industrial',
        objectives = {
            {
                type = 'eliminate',
                target = 'npc',
                count = 10,
                timeLimit = 600
            }
        }
    }
}

-- Team Configuration
Config.Teams = {
    pvp = {
        name = 'PvP Team',
        color = '#FF0000',
        blip = {
            sprite = 1,
            color = 1,
            scale = 0.8
        }
    },
    pve = {
        name = 'PvE Team',
        color = '#0000FF',
        blip = {
            sprite = 1,
            color = 2,
            scale = 0.8
        }
    }
}

-- UI Configuration
Config.UI = {
    keybind = 'F5',
    scale = 1.0,
    theme = 'dark',
    notifications = {
        duration = 5000,
        position = 'top-right'
    }
}

-- Database Configuration
Config.Database = {
    tablePrefix = 'dz_',
    migrations = {
        enabled = true,
        path = 'server/database/migrations'
    }
}

return Config 