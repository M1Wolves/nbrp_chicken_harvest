fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nbrp_chicken_harvest'
description 'Networked chicken harvest'
author 'M1Wolves'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/interact.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory'
}
