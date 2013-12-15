db   = require 'mongoose'
name = process.env.MONGODB_NAME || 'test'
uri  = "mongodb://localhost/#{ name }"

db.connect uri

visitorSchema = db.Schema

    timestamp:

        type: Date
        default: Date.now

    location: 

        #
        # geoip lookup response subrecord
        #

        range:

            #
            # dunno exactly what this is yet
            # [int, int]
            # 

            type: Array
            default: [0,0] # perhaps an inappropriate default

        country:

            type: String
            default: ''

        region:

            type: String
            default: ''

        city:

            type: String
            default: ''

        ll: 

            #
            # [lat, long]
            #

            type: Array
            default: [0, 0]



module.exports = 

    Visitor: db.model 'Visitor', visitorSchema

        
