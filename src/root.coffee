{Visitor} = require './database'
geoip = require 'geoip-lite'

randomIP = ->
    random = -> Math.floor Math.random() * 254
    "#{random()}.#{random()}.#{random()}.#{random()}"


module.exports = (app) ->

    app.get '/', (req, res) -> 

        ip = req.headers['x-real-ip']

        ip ||= randomIP() unless process.env.NODE_ENV is 'production'

        (new Visitor location: geoip.lookup ip).save ->

            res.render 'index'
