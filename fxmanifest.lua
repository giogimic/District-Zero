-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'district-zero'
author 'District Zero Team'
description 'A dynamic mission and district control system for FiveM'
version '1.0.0'

use_experimental_fxv2_oal 'yes'

-- Dependencies
dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core'
}

-- Shared Scripts (Load order matters)
shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    'config/config.lua',  -- Load config first
    'shared/types.lua',   -- Then types
    'shared/utils.lua',   -- Then utils
    'shared/events.lua',  -- Then events
    'bridge/loader.lua'   -- Then bridge
}

-- Client Scripts
client_scripts {
    'bridge/client/*.lua',
    'client/main.lua',
    'client/districts.lua',
    'client/missions.lua',
    'client/teams.lua',
    'client/factions.lua',
    'client/ui.lua'
}

-- Server Scripts (Load order matters)
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server/*.lua',
    'server/database/init.lua',  -- Load database first
    'server/database/migrations/*.sql',
    'server/main.lua',         -- Then main scripts
    'server/database.lua',
    'server/districts.lua',
    'server/missions.lua',
    'server/teams.lua',
    'server/factions.lua',
    'server/*.lua'               -- Then other server scripts
}

-- UI Files
ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*.js',
    'ui/dist/assets/*.css',
    'locales/*.json'
}

-- Resource Configuration
provide 'district_zero'

-- Resource information
repository 'https://github.com/GioGimic/district-zero'
issues 'https://github.com/GioGimic/district-zero/issues'

escrow_ignore {
    'bridge/**/*.lua',
    'shared/**/*.lua',
    'locales/**/*.json'
}
