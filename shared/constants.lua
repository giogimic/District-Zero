-- Constants for District Zero
-- Shared constants used across the resource

Constants = {}

-- System Constants
Constants.SYSTEM_NAME = 'District Zero'
Constants.VERSION = '1.0.0'
Constants.FRAMEWORK = 'qbox'

-- Event Names
Constants.EVENTS = {
    -- District Events
    DISTRICT_CAPTURED = 'district:captured',
    DISTRICT_LOST = 'district:lost',
    DISTRICT_UPDATE = 'district:update',
    
    -- Mission Events
    MISSION_STARTED = 'mission:started',
    MISSION_COMPLETED = 'mission:completed',
    MISSION_FAILED = 'mission:failed',
    MISSION_UPDATE = 'mission:update',
    
    -- Team Events
    TEAM_CREATED = 'team:created',
    TEAM_JOINED = 'team:joined',
    TEAM_LEFT = 'team:left',
    TEAM_UPDATE = 'team:update',
    
    -- Event Events
    EVENT_STARTED = 'event:started',
    EVENT_ENDED = 'event:ended',
    EVENT_UPDATE = 'event:update',
    
    -- Achievement Events
    ACHIEVEMENT_UNLOCKED = 'achievement:unlocked',
    ACHIEVEMENT_PROGRESS = 'achievement:progress',
    
    -- UI Events
    UI_SHOW = 'ui:show',
    UI_HIDE = 'ui:hide',
    UI_UPDATE = 'ui:update'
}

-- Database Tables
Constants.TABLES = {
    DISTRICTS = 'district_zero_districts',
    MISSIONS = 'district_zero_missions',
    TEAMS = 'district_zero_teams',
    EVENTS = 'district_zero_events',
    ACHIEVEMENTS = 'district_zero_achievements',
    PLAYERS = 'district_zero_players',
    ANALYTICS = 'district_zero_analytics'
}

-- Default Values
Constants.DEFAULTS = {
    CAPTURE_TIME = 300, -- 5 minutes
    MISSION_TIMEOUT = 600, -- 10 minutes
    TEAM_MAX_SIZE = 8,
    DISTRICT_RADIUS = 200.0,
    CONTROL_POINT_RADIUS = 50.0,
    SAFE_ZONE_RADIUS = 150.0
}

-- Money Types
Constants.MONEY_TYPES = {
    CASH = 'cash',
    BANK = 'bank',
    CRYPTO = 'crypto'
}

-- Mission Types
Constants.MISSION_TYPES = {
    CAPTURE = 'capture',
    DEFEND = 'defend',
    ESCORT = 'escort',
    DELIVERY = 'delivery',
    ELIMINATION = 'elimination'
}

-- Team Types
Constants.TEAM_TYPES = {
    PVP = 'pvp',
    PVE = 'pve'
}

-- Achievement Types
Constants.ACHIEVEMENT_TYPES = {
    PROGRESS = 'progress',
    MILESTONE = 'milestone',
    SPECIAL = 'special'
}

-- Notification Types
Constants.NOTIFICATION_TYPES = {
    SUCCESS = 'success',
    ERROR = 'error',
    WARNING = 'warning',
    INFO = 'info'
}

-- Performance Thresholds
Constants.PERFORMANCE = {
    MAX_PLAYERS_PER_DISTRICT = 20,
    MAX_ACTIVE_MISSIONS = 5,
    MAX_ACTIVE_EVENTS = 3,
    CACHE_SIZE = 1000,
    GC_INTERVAL = 300000 -- 5 minutes
}

-- Security Settings
Constants.SECURITY = {
    MAX_REQUESTS_PER_MINUTE = 100,
    RATE_LIMIT_WINDOW = 60000, -- 1 minute
    BAN_DURATION = 3600, -- 1 hour
    WHITELIST_ENABLED = false
}

-- Return the constants
return Constants 