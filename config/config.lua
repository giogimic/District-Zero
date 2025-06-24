-- District Zero Configuration
-- Version: 1.0.0

Config = {}

-- Core Settings
Config.Debug = true
Config.Locale = 'en'

-- Team Configuration
Config.Teams = {
    pvp = {
        name = 'PVP Team',
        description = 'Fight for control of districts against other players',
        color = '#FF0000'
    },
    pve = {
        name = 'PVE Team',
        description = 'Complete missions against AI enemies',
        color = '#0000FF'
    }
}

-- District Configuration
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
        id = 'vinewood',
        name = 'Vinewood',
        description = 'The entertainment capital of Los Santos, home to the rich and famous',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(-300.0, 100.0, 66.0) -- Vinewood Sign
        },
        zones = {
            {
                name = 'Vinewood Hills',
                coords = vector3(-300.0, 100.0, 66.0),
                radius = 400.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                name = 'Vinewood Sign',
                coords = vector3(-300.0, 100.0, 66.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Galileo Observatory',
                coords = vector3(-420.0, 1070.0, 325.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Vinewood Bowl',
                coords = vector3(-1600.0, -300.0, 48.0),
                radius = 50.0,
                influence = 25
            }
        }
    },
    {
        id = 'port',
        name = 'Los Santos Port',
        description = 'The industrial heart of Los Santos, featuring the massive shipping port',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(1000.0, -3000.0, 5.0) -- Port Center
        },
        zones = {
            {
                name = 'Port Area',
                coords = vector3(1000.0, -3000.0, 5.0),
                radius = 500.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                name = 'Container Yard',
                coords = vector3(1000.0, -3000.0, 5.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Crane Control',
                coords = vector3(1200.0, -3100.0, 5.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Shipping Office',
                coords = vector3(900.0, -2900.0, 5.0),
                radius = 50.0,
                influence = 25
            }
        }
    },
    {
        id = 'airport',
        name = 'Los Santos International',
        description = 'The main airport of Los Santos, a hub of activity and commerce',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(-1000.0, -3000.0, 13.0) -- Airport Center
        },
        zones = {
            {
                name = 'Airport Zone',
                coords = vector3(-1000.0, -3000.0, 13.0),
                radius = 400.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                name = 'Main Terminal',
                coords = vector3(-1000.0, -3000.0, 13.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Control Tower',
                coords = vector3(-1100.0, -2900.0, 13.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Hangar Complex',
                coords = vector3(-900.0, -3100.0, 13.0),
                radius = 50.0,
                influence = 25
            }
        }
    },
    {
        id = 'sandy',
        name = 'Sandy Shores',
        description = 'A desert town with a mix of industrial and residential areas',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(2000.0, 3700.0, 32.0) -- Sandy Shores Center
        },
        zones = {
            {
                name = 'Sandy Shores',
                coords = vector3(2000.0, 3700.0, 32.0),
                radius = 300.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                name = 'Trevor\'s Airfield',
                coords = vector3(2000.0, 3700.0, 32.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Sandy Shores Medical',
                coords = vector3(1850.0, 3650.0, 32.0),
                radius = 50.0,
                influence = 25
            },
            {
                name = 'Gas Station',
                coords = vector3(1950.0, 3750.0, 32.0),
                radius = 50.0,
                influence = 25
            }
        }
    }
}

-- Mission Configuration
Config.Missions = {
    -- Downtown Missions
    {
        id = 'downtown_pvp_1',
        title = 'Financial District Control',
        description = 'Capture and hold key financial buildings',
        type = 'pvp',
        reward = 2500,
        district = 'downtown',
        objectives = {
            {
                type = 'capture',
                target = 'control_point',
                count = 2,
                timeLimit = 600
            }
        }
    },
    {
        id = 'downtown_pve_1',
        title = 'Corporate Espionage',
        description = 'Eliminate corporate security forces',
        type = 'pve',
        reward = 2000,
        district = 'downtown',
        objectives = {
            {
                type = 'eliminate',
                target = 'npc',
                count = 8,
                timeLimit = 900
            }
        }
    },
    -- Vinewood Missions
    {
        id = 'vinewood_pvp_1',
        title = 'Vinewood Showdown',
        description = 'Control key entertainment venues',
        type = 'pvp',
        reward = 3000,
        district = 'vinewood',
        objectives = {
            {
                type = 'capture',
                target = 'control_point',
                count = 2,
                timeLimit = 600
            }
        }
    },
    {
        id = 'vinewood_pve_1',
        title = 'Celebrity Protection',
        description = 'Defend VIPs from paparazzi',
        type = 'pve',
        reward = 2500,
        district = 'vinewood',
        objectives = {
            {
                type = 'eliminate',
                target = 'npc',
                count = 10,
                timeLimit = 900
            }
        }
    },
    -- Port Missions
    {
        id = 'port_pvp_1',
        title = 'Port Authority',
        description = 'Control shipping operations',
        type = 'pvp',
        reward = 2000,
        district = 'port',
        objectives = {
            {
                type = 'capture',
                target = 'control_point',
                count = 2,
                timeLimit = 600
            }
        }
    },
    {
        id = 'port_pve_1',
        title = 'Smuggler\'s Den',
        description = 'Clear out smuggling operations',
        type = 'pve',
        reward = 2000,
        district = 'port',
        objectives = {
            {
                type = 'eliminate',
                target = 'npc',
                count = 8,
                timeLimit = 900
            }
        }
    },
    -- Airport Missions
    {
        id = 'airport_pvp_1',
        title = 'Airport Control',
        description = 'Secure key airport facilities',
        type = 'pvp',
        reward = 2500,
        district = 'airport',
        objectives = {
            {
                type = 'capture',
                target = 'control_point',
                count = 2,
                timeLimit = 600
            }
        }
    },
    {
        id = 'airport_pve_1',
        title = 'Runway Security',
        description = 'Protect airport operations',
        type = 'pve',
        reward = 2000,
        district = 'airport',
        objectives = {
            {
                type = 'eliminate',
                target = 'npc',
                count = 8,
                timeLimit = 900
            }
        }
    },
    -- Sandy Shores Missions
    {
        id = 'sandy_pvp_1',
        title = 'Desert Control',
        description = 'Control key desert locations',
        type = 'pvp',
        reward = 2000,
        district = 'sandy',
        objectives = {
            {
                type = 'capture',
                target = 'control_point',
                count = 2,
                timeLimit = 600
            }
        }
    },
    {
        id = 'sandy_pve_1',
        title = 'Desert Raiders',
        description = 'Clear out desert bandits',
        type = 'pve',
        reward = 2000,
        district = 'sandy',
        objectives = {
            {
                type = 'eliminate',
                target = 'npc',
                count = 8,
                timeLimit = 900
            }
        }
    }
}

-- UI Configuration
Config.UI = {
    defaultKey = 'F5',
    menuTitle = 'District Zero',
    menuSubtitle = 'Mission Control',
    menuPosition = 'right',
    menuWidth = '400px'
}

-- Reward Configuration
Config.Rewards = {
    baseMissionReward = 1000,
    controlPointBonus = 500,
    districtControlBonus = 2000,
    teamBonus = 1.5 -- Multiplier for team-based rewards
}

-- Time Configuration
Config.Times = {
    missionTimeout = 1800, -- 30 minutes
    controlPointCaptureTime = 60, -- 1 minute
    districtUpdateInterval = 300 -- 5 minutes
}

-- Safe Zones (outside districts)
Config.SafeZones = {
    {
        name = 'Hospital',
        coords = vector3(295.0, -580.0, 43.0),
        radius = 100.0,
        blip = {
            sprite = 61,
            color = 2,
            scale = 0.6
        }
    },
    {
        name = 'Police Station',
        coords = vector3(425.0, -980.0, 30.0),
        radius = 150.0,
        blip = {
            sprite = 60,
            color = 29,
            scale = 0.6
        }
    },
    {
        name = 'Airport Terminal',
        coords = vector3(-1042.0, -2746.0, 21.0),
        radius = 200.0,
        blip = {
            sprite = 90,
            color = 3,
            scale = 0.6
        }
    }
}

-- Debug Configuration
Config.Debug = {
    enabled = true,
    logLevel = 'info', -- 'debug', 'info', 'warn', 'error'
    showBlips = true,
    showZones = true
}

-- Database Configuration
Config.Database = {
    updateInterval = 60, -- seconds
    saveOnMissionComplete = true,
    saveOnDistrictUpdate = true
}

-- Validation Configuration
Config.Validation = {
    validateDistricts = true,
    validateMissions = true,
    validateTeams = true,
    strictMode = true
}

return Config 