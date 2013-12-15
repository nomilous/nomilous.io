db   = require 'mongoose'
name = process.env.MONGODB_NAME || 'test'
uri  = "mongodb://localhost/#{ name }"

db.connect uri
