-- shared/config.lua
-- Central config for tuning APB-style systems (missions, factions, etc.)

Config = {}

-- Debug mode
Config.Debug = true

-- Faction System
Config.Factions = {
    ['enforcer'] = {
        label = "Enforcer",
        color = "#00aaff",
        blip = {
            sprite = 60,
            color = 3,
            scale = 0.8
        },
        ranks = {
            {label = "Rookie", level = 1, xpRequired = 0},
            {label = "Officer", level = 2, xpRequired = 1000},
            {label = "Detective", level = 3, xpRequired = 3000},
            {label = "Sergeant", level = 4, xpRequired = 6000},
            {label = "Lieutenant", level = 5, xpRequired = 10000}
        },
        abilities = {
            {
                name = "backup",
                label = "Request Backup",
                cooldown = 300, -- 5 minutes
                rankRequired = 1,
                description = "Call for police backup"
            },
            {
                name = "spike_strip",
                label = "Deploy Spike Strip",
                cooldown = 600, -- 10 minutes
                rankRequired = 2,
                description = "Deploy a spike strip to stop vehicles"
            },
            {
                name = "police_scanner",
                label = "Police Scanner",
                cooldown = 0,
                rankRequired = 3,
                description = "Scan for nearby criminal activity"
            }
        }
    },
    ['criminal'] = {
        label = "Criminal",
        color = "#ff5500",
        blip = {
            sprite = 60,
            color = 1,
            scale = 0.8
        },
        ranks = {
            {label = "Street Thug", level = 1, xpRequired = 0},
            {label = "Gang Member", level = 2, xpRequired = 1000},
            {label = "Crew Leader", level = 3, xpRequired = 3000},
            {label = "Gang Boss", level = 4, xpRequired = 6000},
            {label = "Crime Lord", level = 5, xpRequired = 10000}
        },
        abilities = {
            {
                name = "lockpick",
                label = "Lockpick",
                cooldown = 120, -- 2 minutes
                rankRequired = 1,
                description = "Lockpick vehicles and doors"
            },
            {
                name = "hack_phone",
                label = "Phone Hack",
                cooldown = 300, -- 5 minutes
                rankRequired = 2,
                description = "Hack into phones to disable police tracking"
            },
            {
                name = "jammer",
                label = "Signal Jammer",
                cooldown = 600, -- 10 minutes
                rankRequired = 3,
                description = "Jam police communications"
            }
        }
    }
}

-- Mission System
Config.Missions = {
    types = {
        ['enforcer'] = {
            {
                id = "patrol",
                label = "Patrol Duty",
                description = "Patrol the streets and respond to criminal activities",
                xpReward = 100,
                cashReward = 500,
                timeLimit = 900, -- 15 minutes
                objectives = {
                    {type = "patrol", count = 3, label = "Complete patrol routes"},
                    {type = "arrest", count = 2, label = "Arrest criminals"}
                }
            },
            {
                id = "investigation",
                label = "Criminal Investigation",
                description = "Investigate and gather evidence of criminal activities",
                xpReward = 150,
                cashReward = 750,
                timeLimit = 1200, -- 20 minutes
                objectives = {
                    {type = "search", count = 3, label = "Search for evidence"},
                    {type = "arrest", count = 1, label = "Arrest the suspect"}
                }
            },
            {
                id = "high_speed",
                label = "High-Speed Pursuit",
                description = "Engage in a high-speed chase with dangerous criminals",
                xpReward = 200,
                cashReward = 1000,
                timeLimit = 600, -- 10 minutes
                objectives = {
                    {type = "chase", count = 1, label = "Catch the suspect"},
                    {type = "arrest", count = 1, label = "Arrest the suspect"}
                }
            },
            {
                id = "gang_raid",
                label = "Gang Raid",
                description = "Raid a known gang hideout and confiscate illegal items",
                xpReward = 300,
                cashReward = 1500,
                timeLimit = 1800, -- 30 minutes
                objectives = {
                    {type = "search", count = 5, label = "Search for contraband"},
                    {type = "arrest", count = 3, label = "Arrest gang members"},
                    {type = "confiscate", count = 1, label = "Confiscate illegal items"}
                }
            }
        },
        ['criminal'] = {
            {
                id = "robbery",
                label = "Store Robbery",
                description = "Rob a local store and escape with the loot",
                xpReward = 100,
                cashReward = 1000,
                timeLimit = 900, -- 15 minutes
                objectives = {
                    {type = "rob", count = 1, label = "Rob the store"},
                    {type = "escape", count = 1, label = "Escape the police"}
                }
            },
            {
                id = "heist",
                label = "Bank Heist",
                description = "Plan and execute a bank heist",
                xpReward = 200,
                cashReward = 2000,
                timeLimit = 1800, -- 30 minutes
                objectives = {
                    {type = "hack", count = 1, label = "Hack the security system"},
                    {type = "rob", count = 1, label = "Rob the bank vault"},
                    {type = "escape", count = 1, label = "Escape with the money"}
                }
            },
            {
                id = "drug_run",
                label = "Drug Run",
                description = "Transport illegal substances across the city",
                xpReward = 150,
                cashReward = 1500,
                timeLimit = 1200, -- 20 minutes
                objectives = {
                    {type = "pickup", count = 1, label = "Pick up the package"},
                    {type = "deliver", count = 1, label = "Deliver to the buyer"},
                    {type = "escape", count = 1, label = "Escape if spotted"}
                }
            },
            {
                id = "gang_war",
                label = "Gang War",
                description = "Engage in a territorial dispute with rival gangs",
                xpReward = 250,
                cashReward = 2000,
                timeLimit = 1500, -- 25 minutes
                objectives = {
                    {type = "eliminate", count = 5, label = "Eliminate rival gang members"},
                    {type = "capture", count = 1, label = "Capture the territory"},
                    {type = "defend", count = 1, label = "Defend the territory"}
                }
            }
        }
    },
    
    -- Mission locations
    locations = {
        patrol = {
            vector3(-1037.54, -2738.54, 20.17),
            vector3(185.17, -1278.62, 29.33),
            vector3(-1181.07, -505.76, 35.56)
        },
        robbery = {
            vector3(-706.41, -914.04, 19.22),
            vector3(24.49, -1347.31, 29.5),
            vector3(-47.42, -1757.86, 29.42)
        },
        heist = {
            vector3(253.41, 221.85, 106.29),
            vector3(-1212.98, -336.29, 37.78)
        },
        drug_run = {
            vector3(-1172.37, -1572.06, 4.66),
            vector3(1240.85, -1626.77, 53.28),
            vector3(1163.67, -323.92, 69.21)
        },
        gang_war = {
            vector3(143.37, -1968.95, 18.86),
            vector3(-1866.97, 2061.27, 135.43),
            vector3(2340.96, 3126.58, 48.21)
        }
    }
}

-- UI Configuration
Config.UI = {
    mission = {
        width = 400,
        height = 600,
        position = {x = 0.85, y = 0.5},
        colors = {
            background = "rgba(0, 0, 0, 0.8)",
            text = "#ffffff",
            accent = "#00aaff"
        }
    },
    faction = {
        width = 300,
        height = 400,
        position = {x = 0.15, y = 0.5},
        colors = {
            background = "rgba(0, 0, 0, 0.8)",
            text = "#ffffff",
            accent = "#00aaff"
        }
    }
}

-- Notification System
Config.Notifications = {
    position = "top-right",
    duration = 5000,
    types = {
        success = {color = "#00ff00", icon = "check"},
        error = {color = "#ff0000", icon = "times"},
        info = {color = "#00aaff", icon = "info"},
        warning = {color = "#ffaa00", icon = "exclamation"}
    }
}

-- Reward System
Config.Rewards = {
    xpMultiplier = 1.0,
    cashMultiplier = 1.0,
    levelUpBonus = {
        cash = 1000,
        items = {
            {name = "weapon_pistol", amount = 1},
            {name = "armor", amount = 1}
        }
    }
}

-- Anti-Cheat Measures
Config.Security = {
    maxDistance = 100.0,
    maxSpeed = 150.0,
    maxHealth = 200,
    maxArmor = 100,
    checkInterval = 5000
}

-- Ability System
Config.Abilities = {
    cooldownDisplay = true,
    cooldownColor = "#ff0000",
    activeColor = "#00ff00",
    defaultColor = "#ffffff",
    maxActiveAbilities = 3
}
