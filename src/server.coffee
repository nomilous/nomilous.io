express = require 'express'
app = express()

app.set 'view engine', 'jade'

app.get '/', (req, res) -> res.render 'index'

app.listen 3000, 'localhost'