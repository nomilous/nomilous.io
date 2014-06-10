{normalize} = require 'path'
{Packager} = require 'cetera'
{Visitor} = require './database'
express = require 'express'
geoip = require 'geoip-lite'

app = express()

app.set 'view engine', 'jade'

app.use express.static normalize __dirname + '/../public'

packager = new Packager
packager.mount
    app: app
    name: 'client'
    src: normalize __dirname + '/../lib/client'
    scripts: [
        'main.js'
    ]

require('./earth') app

require('./visitors') app


app.get '/', (req, res) -> 

    randomIP = -> 
        random = -> Math.floor Math.random() * 254
        "#{random()}.#{random()}.#{random()}.#{random()}"

    ip = req.headers['x-real-ip']
    ip ||= randomIP() unless process.env.NODE_ENV is 'production'
    v = new Visitor location: geoip.lookup ip
    v.save -> 
        res.render 'index'

app.listen process.env.WWW_PORT || 3000, 'localhost'
