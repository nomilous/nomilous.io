{normalize} = require 'path'
{Packager} = require 'cetera'
express = require 'express'

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

require('./root') app

require('./earth') app

require('./visitors') app

app.listen process.env.WWW_PORT || 3000, 'localhost'
