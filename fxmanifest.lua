-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
version_manifest '1.0.0'

author 'Your Name'
description 'District Zero - Advanced District Control System'
version '1.0.0'

-- Dependencies
dependencies {
    'qbx_core',
    'oxmysql',
    'ox_lib'
}

-- Shared Scripts (Load order matters)
shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    'shared/*.lua'
}

-- Client Scripts
client_scripts {
    'client/main/*.lua',
    'client/districts/*.lua',
    'client/missions/*.lua',
    'client/factions/*.lua',
    'client/ui/*.lua'
}

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database/*.lua',
    'server/main/*.lua',
    'server/districts/*.lua',
    'server/missions/*.lua',
    'server/factions/*.lua'
}

-- UI Files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js'
}

-- Resource Configuration
provide 'district_zero'
provide 'dz_missions'
provide 'dz_districts'

-- Resource information
repository 'https://github.com/GioGimic/district-zero'
issues 'https://github.com/GioGimic/district-zero/issues'
