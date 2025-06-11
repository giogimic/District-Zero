-- fxmanifest.lua
-- Resource definition for APB Reloaded system ported to FiveM
-- Framework Compatibility: QBCore/Qbox (Modern Standards Only)

fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'FiveM MM - APB Reloaded-like System'
version '1.0.0'

-- Shared scripts (configs, enums, utils)
shared_scripts {
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'config/*.lua',
    'shared/*.lua'
}

-- Client-side scripts
client_scripts {
    'client/*.lua'
}

-- Server-side scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/districts.html',
    'html/missions.html',
    'html/abilities.html',
    'html/style.css',
    'html/districts.css',
    'html/missions.css',
    'html/abilities.css',
    'html/script.js',
    'html/districts.js',
    'html/missions.js',
    'html/abilities.js'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
