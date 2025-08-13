fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'whoisdelta.'
version '0.1'

map 'cfx/map.lua'

resource_type 'map' {
    gameTypes = {
        ['Roleplay'] = true
    }
}

client_scripts {
    'base/client/*.lua',
    'cfx/spawnmanager.lua',
    'cfx/mapmanager_client.lua',
    'scripts/client/*.*'
}

server_scripts {
    'base/server/*.lua',
    'cfx/mapmanager_server.lua',
    'scripts/server/*.*'
}

shared_scripts {
    'cfx/mapmanager_shared.lua',
    'Config/*.lua'
}

ui_page "front/index.html"

files {
    'front/*.*',
    'front/css/*.*',
    'front/js/*.*',
}

resource_type 'gametype' {
    name = 'Roleplay'
}
