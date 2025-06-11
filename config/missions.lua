Config.Missions = {
    -- Criminal Missions
    criminal = {
        {
            id = "drug_delivery",
            name = "Drug Delivery",
            description = "Deliver drugs to a specified location",
            reward = {
                money = 5000,
                reputation = 100
            },
            requiredRank = 1,
            cooldown = 1800, -- 30 minutes
            locations = {
                {x = 1240.0, y = -1626.0, z = 53.0},
                {x = 1271.0, y = -1714.0, z = 54.0},
                {x = 1301.0, y = -1732.0, z = 54.0}
            },
            vehicle = "speedo",
            timeLimit = 900, -- 15 minutes
            policeRequired = 2 -- Minimum police online
        },
        {
            id = "bank_robbery",
            name = "Bank Robbery",
            description = "Rob a bank and escape with the money",
            reward = {
                money = 15000,
                reputation = 250
            },
            requiredRank = 3,
            cooldown = 3600, -- 1 hour
            locations = {
                {x = 147.0, y = -1044.0, z = 29.0},
                {x = -1212.0, y = -336.0, z = 37.0},
                {x = -2962.0, y = 482.0, z = 15.0}
            },
            vehicle = "kuruma",
            timeLimit = 1800, -- 30 minutes
            policeRequired = 4 -- Minimum police online
        },
        {
            id = "jewelry_heist",
            name = "Jewelry Heist",
            description = "Steal valuable jewelry from the store",
            reward = {
                money = 10000,
                reputation = 200
            },
            requiredRank = 2,
            cooldown = 2700, -- 45 minutes
            locations = {
                {x = -630.0, y = -236.0, z = 38.0}
            },
            vehicle = "sultan",
            timeLimit = 1200, -- 20 minutes
            policeRequired = 3 -- Minimum police online
        }
    },

    -- Police Missions
    police = {
        {
            id = "patrol",
            name = "Patrol Duty",
            description = "Patrol the city and respond to calls",
            reward = {
                money = 2000,
                reputation = 50
            },
            requiredRank = 1,
            cooldown = 900, -- 15 minutes
            locations = {
                {x = 441.0, y = -982.0, z = 30.0},
                {x = -1108.0, y = -845.0, z = 19.0},
                {x = 1853.0, y = 3689.0, z = 34.0}
            },
            vehicle = "police",
            timeLimit = 600, -- 10 minutes
            minCriminals = 1 -- Minimum criminals online
        },
        {
            id = "high_speed_chase",
            name = "High-Speed Chase",
            description = "Pursue and stop a fleeing suspect",
            reward = {
                money = 5000,
                reputation = 100
            },
            requiredRank = 2,
            cooldown = 1800, -- 30 minutes
            locations = {
                {x = 441.0, y = -982.0, z = 30.0}
            },
            vehicle = "police2",
            timeLimit = 900, -- 15 minutes
            minCriminals = 2 -- Minimum criminals online
        },
        {
            id = "swat_raid",
            name = "SWAT Raid",
            description = "Lead a SWAT team in a high-risk operation",
            reward = {
                money = 8000,
                reputation = 150
            },
            requiredRank = 3,
            cooldown = 2700, -- 45 minutes
            locations = {
                {x = 441.0, y = -982.0, z = 30.0}
            },
            vehicle = "fbi",
            timeLimit = 1200, -- 20 minutes
            minCriminals = 3 -- Minimum criminals online
        }
    }
}

-- Mission States
Config.MissionStates = {
    AVAILABLE = "available",
    IN_PROGRESS = "in_progress",
    COMPLETED = "completed",
    FAILED = "failed"
}

-- Mission Types
Config.MissionTypes = {
    CRIMINAL = "criminal",
    POLICE = "police"
}

-- Mission Requirements
Config.MissionRequirements = {
    MIN_PLAYERS = 2,
    MAX_PLAYERS = 4,
    MIN_LEVEL = 1,
    MAX_LEVEL = 50
}

-- Mission Rewards
Config.MissionRewards = {
    BASE_MONEY = 1000,
    BASE_REPUTATION = 50,
    BONUS_MULTIPLIER = 1.5 -- Bonus for completing mission with full team
}

-- Mission Cooldowns
Config.MissionCooldowns = {
    GLOBAL = 300, -- 5 minutes between missions
    PLAYER = 600, -- 10 minutes between player missions
    FACTION = 1800 -- 30 minutes between faction missions
}

-- Mission Vehicles
Config.MissionVehicles = {
    CRIMINAL = {
        "kuruma",
        "sultan",
        "speedo"
    },
    POLICE = {
        "police",
        "police2",
        "fbi"
    }
}

-- Mission Locations
Config.MissionLocations = {
    START = {
        CRIMINAL = {x = 1240.0, y = -1626.0, z = 53.0},
        POLICE = {x = 441.0, y = -982.0, z = 30.0}
    },
    FINISH = {
        CRIMINAL = {x = 1271.0, y = -1714.0, z = 54.0},
        POLICE = {x = -1108.0, y = -845.0, z = 19.0}
    }
} 