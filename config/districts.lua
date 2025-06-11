Config = Config or {}
Config.Districts = {
    -- Downtown
    downtown = {
        name = "Downtown",
        label = "Downtown",
        description = "The heart of the city",
        blip = {
            sprite = 1,
            color = 2,
            scale = 0.8,
            label = "Downtown"
        },
        coords = vector3(-200.0, -800.0, 30.0),
        radius = 500.0,
        factions = {
            police = true,
            ambulance = true,
            mechanic = true
        },
        missions = {
            "delivery",
            "escort",
            "patrol"
        },
        abilities = {
            "backup",
            "tracking",
            "jammer"
        }
    },
    
    -- Industrial
    industrial = {
        name = "Industrial",
        label = "Industrial District",
        description = "The industrial heart of the city",
        blip = {
            sprite = 1,
            color = 3,
            scale = 0.8,
            label = "Industrial"
        },
        coords = vector3(800.0, -1200.0, 30.0),
        radius = 500.0,
        factions = {
            mechanic = true,
            police = true
        },
        missions = {
            "delivery",
            "escort",
            "patrol"
        },
        abilities = {
            "backup",
            "tracking"
        }
    },
    
    -- Residential
    residential = {
        name = "Residential",
        label = "Residential District",
        description = "Where the citizens live",
        blip = {
            sprite = 1,
            color = 4,
            scale = 0.8,
            label = "Residential"
        },
        coords = vector3(1200.0, -400.0, 30.0),
        radius = 500.0,
        factions = {
            police = true,
            ambulance = true
        },
        missions = {
            "delivery",
            "escort",
            "patrol"
        },
        abilities = {
            "backup",
            "tracking"
        }
    }
} 