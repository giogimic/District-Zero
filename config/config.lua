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
                radius = 200.0
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
                radius = 200.0
            }
        }
    }
}

-- Missions Configuration
Config.Missions = {
    {
        id = 'mission_1',
        title = 'First Mission',
        description = 'A simple mission to get started',
        difficulty = 'easy',
        reward = 1000,
        district = 'downtown',
        requirements = {
            level = 1,
            items = {}
        }
    }
}

-- Factions Configuration
Config.Factions = {
    {
        id = 'police',
        name = 'Police Department',
        description = 'Law enforcement',
        color = '#0000FF',
        ranks = {
            { id = 1, name = 'Officer', salary = 1000 },
            { id = 2, name = 'Sergeant', salary = 1500 },
            { id = 3, name = 'Lieutenant', salary = 2000 }
        }
    },
    {
        id = 'ambulance',
        name = 'Emergency Services',
        description = 'Medical response',
        color = '#FF0000',
        ranks = {
            { id = 1, name = 'Paramedic', salary = 1000 },
            { id = 2, name = 'Senior Paramedic', salary = 1500 },
            { id = 3, name = 'Chief Paramedic', salary = 2000 }
        }
    }
}

-- UI Configuration
Config.UI = {
    keybind = 'F5',
    scale = 1.0,
    theme = 'dark'
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