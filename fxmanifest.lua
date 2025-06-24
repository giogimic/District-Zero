-- fxmanifest.lua
-- Resource definition for District Zero
-- Framework Compatibility: Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'District-Zero'
author 'District Zero Team'
description 'District Zero - A dynamic district control system'
version '1.0.0'

use_experimental_fxv2_oal 'yes'

-- Dependencies (flexible for different QBX versions)
dependencies {
    'ox_lib',
    'oxmysql'
}

-- Optional dependencies (will work without these but with reduced functionality)
optional_dependencies {
    'qbx_core',
    'qb-core'
}

-- Shared Scripts (Load order matters)
shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua',
    'shared/*.lua'
}

-- Client Scripts
client_scripts {
    'client/*.lua'
}

-- Server Scripts (Load order matters)
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/database/*.lua'
}

-- UI Files
ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/assets/*',
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
