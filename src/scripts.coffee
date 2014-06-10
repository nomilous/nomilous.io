{normalize} = require 'path'
{Packager} = require 'cetera'

module.exports = (app) ->

    packager = new Packager

    packager.mount

        app: app
        name: 'client'
        src: normalize __dirname + '/../lib/client'
        scripts: [
            'main.js'
        ]
