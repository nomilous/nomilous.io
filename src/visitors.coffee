{Visitor} = require './database'

module.exports = (app) ->

    app.get '/visitors', (req, res) ->

        id = req.session.visitor_id

        #
        # TODO: limit to recent, carry id round for 'me'ness
        #

        Visitor.find().exec (err, result) ->

            if err? then return res.send 500, err

            res.send result.map (v) ->

                me: v._id.toString() == id
                country: v.location.country
                region: v.location.region
                city: v.location.city
                ll: v.location.ll
