-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'Your Name'
description 'District Zero - APB-style mission system for FiveM'
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
    'config/*.lua',
    'shared/*.lua'
}

-- Client Scripts
client_scripts {
    'client/main/*.lua',
    'client/ui/*.lua'
}

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database/*.lua',
    'server/main/*.lua'
}

-- UI Files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/assets/**/*'
}

-- Resource Configuration
provide 'district_zero'

-- Resource information
repository 'https://github.com/GioGimic/district-zero'
issues 'https://github.com/GioGimic/district-zero/issues'
