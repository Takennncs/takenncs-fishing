fx_version 'cerulean'
game 'gta5'

author 'Takenncs'
description 'Fishing Script'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'locales/ee.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

lua54 'yes'

dependencies {
    'qb-core',
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'takenncs-skillbar'
}