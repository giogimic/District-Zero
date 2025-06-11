-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'District Zero Development Team'
description 'District Zero - Advanced Mission and District Management System'
version '1.0.0'

-- Dependencies
dependencies {
    'qbx_core',
    'oxmysql',
    'ox_lib'
}

-- Shared Scripts
shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

-- Client Scripts
client_scripts {
    'client/main/*.lua'
}

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main/*.lua'
}

-- UI Files
ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*.js',
    'ui/dist/assets/*.css',
    'ui/dist/assets/*.png',
    'ui/dist/assets/*.svg'
}

-- Resource Metadata
lua54 'yes'
use_experimental_fxv2_oal 'yes'

-- Resource Configuration
provide 'district_zero'
provide 'dz_missions'
provide 'dz_districts'

-- Resource information
repository 'https://github.com/GioGimic/district-zero'
issues 'https://github.com/GioGimic/district-zero/issues'
