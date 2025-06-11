-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
version_manifest '1.0.0'

author 'Your Name'
description 'District Zero - A FiveM Resource'
version '1.0.0'

-- Dependencies
dependencies {
    'qbx_core',
    'oxmysql',
    'ox_lib',
    'qb-core'
}

-- Shared Scripts (Load order matters)
shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'config/*.lua',
    'shared/*.lua',
    'locales/*.json'
}

-- Client Scripts
client_scripts {
    'client/main/input.lua',
    'client/ui/ui.lua',
    'client/main/*.lua'
}

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database/init.lua',
    'server/database/*.lua',
    'server/main/*.lua'
}

-- UI Files
ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/**/*'
}

-- Resource Configuration
provide 'district_zero'
provide 'dz_missions'
provide 'dz_districts'

-- Resource information
repository 'https://github.com/GioGimic/district-zero'
issues 'https://github.com/GioGimic/district-zero/issues'
