-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'district-zero'
author 'District Zero Team'
description 'District Zero - APB-style mission system for FiveM'
version '1.0.0'

use_experimental_fxv2_oal 'yes'

-- Dependencies
dependencies {
    'ox_lib',
    'oxmysql',
    'qb-core'
}

-- Shared Scripts (Load order matters)
shared_scripts {
    '@ox_lib/init.lua',
    'bridge/loader.lua',
    'shared/*.lua'
}

-- Client Scripts
client_scripts {
    'bridge/client/*.lua',
    'client/*.lua'
}

-- Server Scripts
server_scripts {
    'bridge/server/*.lua',
    'server/*.lua'
}

-- UI Files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/dist/*.js',
    'html/dist/*.css',
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
