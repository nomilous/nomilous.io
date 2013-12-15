db   = require 'mongoose'
name = process.env.MONGODB_NAME || 'test'
uri  = "mongodb://localhost/#{ name }"

db.connect uri

module.exports = 

    Visitor: db.model 'Visitor', db.Schema

        at: 
            type: Date
            default: Date.now

