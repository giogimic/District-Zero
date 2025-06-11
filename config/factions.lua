Config.Factions = {
    -- Criminal Factions
    criminal = {
        name = "Criminal",
        ranks = {
            {
                id = 1,
                name = "Recruit",
                requiredReputation = 0,
                abilities = {"backup"},
                maxMembers = 10
            },
            {
                id = 2,
                name = "Enforcer",
                requiredReputation = 1000,
                abilities = {"backup", "tracking"},
                maxMembers = 20
            },
            {
                id = 3,
                name = "Lieutenant",
                requiredReputation = 5000,
                abilities = {"backup", "tracking", "jammer"},
                maxMembers = 30
            },
            {
                id = 4,
                name = "Boss",
                requiredReputation = 10000,
                abilities = {"backup", "tracking", "jammer"},
                maxMembers = 50
            }
        },
        territories = {
            {
                id = "downtown",
                name = "Downtown",
                center = vector3(0.0, 0.0, 0.0),
                radius = 500.0,
                reward = {
                    money = 1000,
                    reputation = 50
                }
            }
        }
    },

    -- Police Faction
    police = {
        name = "Police",
        ranks = {
            {
                id = 1,
                name = "Officer",
                requiredReputation = 0,
                abilities = {"backup"},
                maxMembers = 20
            },
            {
                id = 2,
                name = "Sergeant",
                requiredReputation = 1000,
                abilities = {"backup", "tracking"},
                maxMembers = 30
            },
            {
                id = 3,
                name = "Lieutenant",
                requiredReputation = 5000,
                abilities = {"backup", "tracking", "jammer"},
                maxMembers = 40
            },
            {
                id = 4,
                name = "Captain",
                requiredReputation = 10000,
                abilities = {"backup", "tracking", "jammer"},
                maxMembers = 50
            }
        },
        territories = {
            {
                id = "downtown",
                name = "Downtown",
                center = vector3(0.0, 0.0, 0.0),
                radius = 500.0,
                reward = {
                    money = 1000,
                    reputation = 50
                }
            }
        }
    },

    -- Civilian Faction
    civilian = {
        name = "Civilian",
        ranks = {
            {
                id = 1,
                name = "Citizen",
                requiredReputation = 0,
                abilities = {},
                maxMembers = 100
            }
        },
        territories = {},
        jobs = {"delivery", "taxi", "medic", "mechanic"}
    },

    -- Gang Template (for player-created gangs)
    gang_template = {
        name = "Player Gang",
        color = {r=255, g=255, b=255},
        ranks = {
            {
                id = 1,
                name = "Member",
                requiredReputation = 0,
                abilities = {},
                maxMembers = 20
            },
            {
                id = 2,
                name = "Lieutenant",
                requiredReputation = 1000,
                abilities = {},
                maxMembers = 10
            },
            {
                id = 3,
                name = "Boss",
                requiredReputation = 5000,
                abilities = {},
                maxMembers = 1
            }
        },
        territories = {},
        permissions = {"invite", "kick", "promote", "demote", "set_color", "set_name"},
        jobs = {},
        isPlayerCreated = true
    }
}

-- Faction States
Config.FactionStates = {
    ACTIVE = "active",
    INACTIVE = "inactive",
    AT_WAR = "at_war"
}

-- Faction Requirements
Config.FactionRequirements = {
    MIN_MEMBERS = 2,
    MAX_MEMBERS = 50,
    MIN_REPUTATION = 0,
    MAX_REPUTATION = 100000
}

-- Faction War Settings
Config.FactionWar = {
    DURATION = 3600, -- 1 hour
    COOLDOWN = 7200, -- 2 hours
    MIN_MEMBERS = 5,
    TERRITORY_CAPTURE_TIME = 300, -- 5 minutes
    REWARD_MULTIPLIER = 2.0
}

-- Faction Territory Settings
Config.Territory = {
    CAPTURE_RADIUS = 50.0,
    CAPTURE_TIME = 300, -- 5 minutes
    REWARD_INTERVAL = 600, -- 10 minutes
    INFLUENCE_RADIUS = 100.0
}

-- Faction Vehicle Settings
Config.FactionVehicles = {
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

-- Faction Weapon Settings
Config.FactionWeapons = {
    CRIMINAL = {
        "WEAPON_PISTOL",
        "WEAPON_SMG",
        "WEAPON_CARBINERIFLE"
    },
    POLICE = {
        "WEAPON_PISTOL",
        "WEAPON_STUNGUN",
        "WEAPON_CARBINERIFLE"
    }
}

-- Faction Clothing Settings
Config.FactionClothing = {
    CRIMINAL = {
        male = {
            components = {
                [1] = {drawable = 0, texture = 0},
                [3] = {drawable = 0, texture = 0},
                [4] = {drawable = 0, texture = 0},
                [5] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0},
                [8] = {drawable = 0, texture = 0},
                [9] = {drawable = 0, texture = 0},
                [10] = {drawable = 0, texture = 0},
                [11] = {drawable = 0, texture = 0}
            },
            props = {
                [0] = {drawable = 0, texture = 0},
                [1] = {drawable = 0, texture = 0},
                [2] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0}
            }
        },
        female = {
            components = {
                [1] = {drawable = 0, texture = 0},
                [3] = {drawable = 0, texture = 0},
                [4] = {drawable = 0, texture = 0},
                [5] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0},
                [8] = {drawable = 0, texture = 0},
                [9] = {drawable = 0, texture = 0},
                [10] = {drawable = 0, texture = 0},
                [11] = {drawable = 0, texture = 0}
            },
            props = {
                [0] = {drawable = 0, texture = 0},
                [1] = {drawable = 0, texture = 0},
                [2] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0}
            }
        }
    },
    POLICE = {
        male = {
            components = {
                [1] = {drawable = 0, texture = 0},
                [3] = {drawable = 0, texture = 0},
                [4] = {drawable = 0, texture = 0},
                [5] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0},
                [8] = {drawable = 0, texture = 0},
                [9] = {drawable = 0, texture = 0},
                [10] = {drawable = 0, texture = 0},
                [11] = {drawable = 0, texture = 0}
            },
            props = {
                [0] = {drawable = 0, texture = 0},
                [1] = {drawable = 0, texture = 0},
                [2] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0}
            }
        },
        female = {
            components = {
                [1] = {drawable = 0, texture = 0},
                [3] = {drawable = 0, texture = 0},
                [4] = {drawable = 0, texture = 0},
                [5] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0},
                [8] = {drawable = 0, texture = 0},
                [9] = {drawable = 0, texture = 0},
                [10] = {drawable = 0, texture = 0},
                [11] = {drawable = 0, texture = 0}
            },
            props = {
                [0] = {drawable = 0, texture = 0},
                [1] = {drawable = 0, texture = 0},
                [2] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0}
            }
        }
    }
} 