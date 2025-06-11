-- fxmanifest.lua
-- Resource definition for APB Reloaded system ported to FiveM
-- Framework Compatibility: QBCore/Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'Your Name'
description 'District Zero - Dynamic Territory Control System'
version '1.0.0'

-- Shared scripts (configs, enums, utils)
shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    'locales/*.lua',
    'shared/*.lua'
}

-- Client-side scripts
client_scripts {
    'client/main/*.lua'
}

-- Server-side scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main/*.lua'
}

ui_page 'html/index.html'

files {
    'html/**/*'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'oxmysql'
}
