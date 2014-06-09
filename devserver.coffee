#
# node-dev ./devserver.coffee
# 

{readFileSync} = require 'fs'

envfile = readFileSync('.env.develop').toString()

for line in envfile.split '\n'

    try 
        
        [match, variable, value] = line.match /(.*)=(.*)/
        
        process.env[variable] = value


console.log "wait moment for possible coffee compile"

setTimeout (->

    require './lib/server'

), 1000
