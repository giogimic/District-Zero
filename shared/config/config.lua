Config = {}

-- Debug mode
Config.Debug = true

-- Database settings
Config.Database = {
    TablePrefix = 'dz_',
    UpdateInterval = 300 -- 5 minutes
}

-- General settings
Config.Settings = {
    MaxFactionMembers = 50,
    MinFactionMembers = 3,
    MaxDistrictsPerFaction = 5,
    MissionCooldown = 1800, -- 30 minutes
    EventCooldown = 3600, -- 1 hour
    TurfWarDuration = 1800, -- 30 minutes
    RaidDuration = 900, -- 15 minutes
    EmergencyDuration = 600, -- 10 minutes
    GangAttackDuration = 1200, -- 20 minutes
    PatrolDuration = 300 -- 5 minutes
}

-- Reward multipliers
Config.Rewards = {
    TerritoryControl = 1.5,
    MissionCompletion = 1.0,
    EventParticipation = 1.2,
    TurfWarVictory = 2.0
}

-- Reputation thresholds
Config.Reputation = {
    MinLevel = 1,
    MaxLevel = 100,
    LevelUpThreshold = 1000,
    DecayRate = 0.1 -- 10% decay per day
}

-- Notification settings
Config.Notifications = {
    TerritoryControl = true,
    MissionUpdates = true,
    EventAlerts = true,
    FactionWars = true
}

-- UI settings
Config.UI = {
    BlipUpdateInterval = 5000, -- 5 seconds
    MapUpdateInterval = 10000, -- 10 seconds
    NotificationDuration = 5000 -- 5 seconds
} 