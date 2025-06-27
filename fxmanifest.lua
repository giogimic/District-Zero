-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'District Zero FiveM'
description 'District-based competitive gaming system for FiveM'
author 'District Zero Team'
version '1.0.0'
url 'https://github.com/district-zero/fivem-mm'

-- Resource dependencies
dependencies {
    'mysql-async',  -- Database support
    'oxmysql',      -- Alternative database support
    'es_extended',  -- ESX framework support (optional)
    'qb-core',       -- QBCore framework support (optional)
    'ox_lib'
}

-- Optional dependencies (will work without these but with reduced functionality)
optional_dependencies {
    'qbx_core'
}

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua',
    'shared/*.lua',
    'shared/config.lua',
    'shared/types.lua',
    'shared/utils.lua',
    'shared/constants.lua'
}

-- Client scripts
client_scripts {
    'client/*.lua',
    'client/main.lua',
    'client/ui.lua',
    'client/events.lua',
    'client/performance.lua'
}

-- Server scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/database/*.lua',
    'server/database.lua',
    'server/districts.lua',
    'server/missions.lua',
    'server/teams.lua',
    'server/events.lua',
    'server/achievements.lua',
    'server/analytics.lua',
    'server/security.lua',
    'server/performance.lua',
    'server/integration.lua',
    'server/polish.lua',
    'server/deployment.lua',
    'server/release.lua',
    'server/final_integration.lua'
}

-- UI files
ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
    'locales/*.json',
    'ui/index.html',
    'ui/static/js/main.js',
    'ui/static/css/main.css',
    'ui/static/media/*'
}

-- Configuration files
data_file 'CONFIG_FILE' 'config/*.json'

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
    'GetIntegrationHealth'
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
    'GetIntegrationHealth'
}

-- Client exports
client_exports {
    'GetUI',
    'GetClientEvents',
    'GetClientPerformance'
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
