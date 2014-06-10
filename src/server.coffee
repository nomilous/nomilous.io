{normalize} = require 'path'

express = require 'express'

session = require 'express-session'

RedisStore = require('connect-redis') session

cookieParser = require 'cookie-parser'

app = express()

app.use cookieParser()

app.use session store: new RedisStore(), secret: 'keyboard cat'

app.set 'view engine', 'jade'

app.use express.static normalize __dirname + '/../public'

require('./scripts') app

require('./root') app

require('./earth') app

require('./visitors') app

app.listen process.env.WWW_PORT || 3000, 'localhost'
