fx_version 'cerulean'
game 'gta5'

name 'Serrulata-Studios'
author 'MoneSuper#0001'
description 'Serrulata-ATMRobbery'
repository 'https://github.com/Serrulata-Studios/serrulata-atmrobbery'

version '2.0.0'


client_scripts {'client/*.lua'}

shared_scripts {'@ox_lib/init.lua', 'shared/config.lua'}

server_script {'server/*.lua'}

files {
    "client/modules/*.lua",
    'locales/*.json'
}

lua54 'yes'

