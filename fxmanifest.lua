fx_version 'cerulean'
game 'gta5'

author 'TrexVx'
description 'Modificador de Coches compatible con ESX y QBCore'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    /*'@qb-core/shared/locale.lua',*/
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js',
    'html/logo.png'
}

dependencies {
    'es_extended',
    /*'qb-core',*/
    'oxmysql'
}