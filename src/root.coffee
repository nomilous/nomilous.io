{Visitor} = require './database'
geoip = require 'geoip-lite'

randomIP = ->
    random = -> Math.floor Math.random() * 254
    "#{random()}.#{random()}.#{random()}.#{random()}"


module.exports = (app) ->

    app.get '/', (req, res) -> 

        ip = req.headers['x-real-ip']

        ip ||= randomIP() unless process.env.NODE_ENV is 'production'

        if not req.session.visitor_id?

            (new Visitor location: geoip.lookup ip).save (error, visitor) ->

                console.log new: visitor._id
                req.session.visitor_id = visitor._id
                res.render 'index'

        else

            console.log existing: req.session.visitor_id
            res.render 'index'
