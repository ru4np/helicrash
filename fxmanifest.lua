

fx_version "cerulean"
game "gta5"

shared_script {
    'controller/config.lua',
    "@vrp/lib/utils.lua"
} 

client_scripts {
    "client-side/*.lua"
}

server_scripts {
    "server-side/*.lua",
}              