-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: QBox Framework (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'District Zero FiveM'
description 'District-based competitive gaming system for FiveM - QBox Compatible'
author 'District Zero Team'
version '1.0.0'
url 'https://github.com/district-zero/fivem-mm'

-- QBox Framework Dependencies
dependencies {
    'qbx_core',     -- QBox Core Framework (Required)
    'oxmysql',      -- Database support (QBox Standard)
    'ox_lib'        -- QBox UI Library
}

-- Optional dependencies (will work without these but with reduced functionality)
optional_dependencies {
    'qbx_management',
    'qbx_vehicleshop',
    'qbx_garages'
}

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

-- Client scripts
client_scripts {
    'client/exports.lua',  -- Load exports first
    'client/main.lua',
    'client/main/*.lua'
}

-- Server scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/init.lua',  -- Load initialization first
    'server/main.lua',
    'server/teams.lua',
    'server/release.lua',
    'server/deployment.lua',
    'server/final_integration.lua',
    'server/main/*.lua',
    'server/database/*.lua'
}

-- UI files
ui_page 'ui/index.html'

files {
    'ui/index.html',
    'locales/*.json'
}

-- Export functions
exports {
    -- Core systems
    'GetDistrictsSystem',
    'GetMissionsSystem', 
    'GetTeamsSystem',
    'GetEventsSystem',
    'GetAchievementsSystem',
    
    -- Advanced systems
    'GetAnalyticsSystem',
    'GetSecuritySystem',
    'GetPerformanceSystem',
    
    -- Integration systems
    'GetIntegrationSystem',
    'GetPolishSystem',
    'GetDeploymentSystem',
    'GetReleaseSystem',
    
    -- Final integration
    'GetUnifiedAPI',
    'GetSystemStatus',
    'GetIntegrationHealth',
    
    -- Missing exports that are being called
    'GetConfig',
    'GetUtils',
    'GetDatabaseManager',
    'GetAdvancedMissionSystem',
    'GetDynamicEventsSystem',
    'GetAdvancedTeamSystem',
    'GetAchievementSystem',
    'GetCurrentDistrict',
    'GetCurrentTeam',
    'GetCurrentMission',
    'GetBlipCount',
    'GetAllDistricts',
    'GetDistrict',
    'GetPlayerTeam',
    'GetTeamStats',
    'GetAvailableMissions',
    'GetPerformanceMetrics',
    'GetErrorReport',
    'GetDistrictHistory',
    'GetPlayerMissionHistory',
    'GetTeamAnalytics',
    'GetPlayerLeaderboard',
    'GetGlobalLeaderboard',
    'GetSystemConfig',
    'GetDistrictControl',
    'GetDistrictInfluence',
    'GetControlPoints',
    'GetTeamMembers',
    'GetTeamBalance',
    'GetTeamLeaderboard',
    'GetTeamMembersInRange'
}

-- Server exports
server_exports {
    'GetDistrictsSystem',
    'GetMissionsSystem',
    'GetTeamsSystem', 
    'GetEventsSystem',
    'GetAchievementsSystem',
    'GetAnalyticsSystem',
    'GetSecuritySystem',
    'GetPerformanceSystem',
    'GetIntegrationSystem',
    'GetPolishSystem',
    'GetDeploymentSystem',
    'GetReleaseSystem',
    'GetUnifiedAPI',
    'GetSystemStatus',
    'GetIntegrationHealth',
    
    -- Missing server exports
    'GetConfig',
    'GetUtils',
    'GetDatabaseManager',
    'GetAdvancedMissionSystem',
    'GetDynamicEventsSystem',
    'GetAdvancedTeamSystem',
    'GetAchievementSystem',
    'GetDistrictHistory',
    'GetPlayerMissionHistory',
    'GetTeamAnalytics',
    'GetPlayerLeaderboard',
    'GetGlobalLeaderboard',
    'GetSystemConfig'
}

-- Client exports
client_exports {
    'GetUI',
    'GetClientEvents',
    'GetClientPerformance',
    
    -- Missing client exports
    'GetCurrentDistrict',
    'GetCurrentTeam',
    'GetCurrentMission',
    'GetBlipCount',
    'GetAllDistricts',
    'GetDistrict',
    'GetPlayerTeam',
    'GetTeamStats',
    'GetAvailableMissions',
    'GetPerformanceMetrics',
    'GetErrorReport',
    'GetDistrictControl',
    'GetDistrictInfluence',
    'GetControlPoints',
    'GetTeamMembers',
    'GetTeamBalance',
    'GetTeamLeaderboard',
    'GetTeamMembersInRange'
}

-- Resource Configuration
provide 'district_zero'

-- Resource information
repository 'https://github.com/district-zero/fivem-mm'
bugs 'https://github.com/district-zero/fivem-mm/issues'

escrow_ignore {
    'bridge/**/*.lua',
    'shared/**/*.lua',
    'locales/**/*.json'
}

-- Performance settings
use_experimental_fxv2_oal 'yes'

-- QBox Framework Integration
-- This resource is designed to work with QBox Framework
-- For installation instructions, see: https://docs.qbox.re/installation
