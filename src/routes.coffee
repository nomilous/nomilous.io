fs          = require 'fs'
geoip       = require 'geoip-lite'
{ShapeFile} = require 'node-shapelib-partial'
database    = require './database'
minify      = require 'minify'


hostname = process.env.WEBSOCKET_HOSTNAME || 'localhost'
port     = process.env.WEBSOCKET_PORT     ||  3003

module.exports = (opts, callback) -> 

    #
    # root as function receives all non matched requests, 404 all but /
    #

    return callback null, statusCode: 404 unless opts.path is '/'

    randomIP = -> 
        random = -> Math.floor Math.random() * 254
        "#{random()}.#{random()}.#{random()}.#{random()}"

    ip = opts.headers['x-real-ip']
    ip ||= randomIP() unless process.env.NODE_ENV is 'production'
    v = new database.Visitor location: geoip.lookup ip

    v.save (err, visitor)-> 

        if err? then return callback null, 'error'

        callback null, 

            headers: 'Content-Type': 'text/html'
            body: """
            <body>
                <script src="build"></script>
                <!-- script src="client?id=#{  visitor.id  }&hostname=#{ hostname }&port=#{ port }"></script -->
                <script src="client"></script>
            </body>
            """
                                                                        #
                                                                        # client script is ""query templated"",
                                                                        # allows for handy post-assignment of
                                                                        # websocket details.
                                                                        #


module.exports.client = (opts, callback) -> 

    id       = opts.query.id
    hostname = opts.query.hostname
    port     = opts.query.port

    callback null, 

        headers: 'Content-Type': 'text/javascript'
        body: """(
        #{require('./client').toString()}
        ).call(self, '#{id}', '#{hostname}', #{port});
        """



buildScript = undefined

if process.env.NODE_ENV is 'production'

    minify.optimize __dirname + '/../build/build.js',
    callback: (data) -> buildScript = data

else

    buildScript = """
        #{fs.readFileSync( __dirname + '/../build/build.js' ).toString()}
        //
        // TODO: fix something (is chopping the last few chars off the build script delivery)
        //

        
    """

module.exports.build = (opts, callback) -> 

    # 
    # first hit might not have build minifi finished
    # ----------------------------------------------
    # 
    # * Appears that minify holds the flow for it's entire operation
    # * So this does not get called till afterwards
    # * Leaving it here just incase
    # 
    
    respond = ->

        return setTimeout respond, 1000 unless buildScript? 
    
        callback null,
    
            headers: 'Content-Type': 'text/javascript'
            body: buildScript
    
    respond()


module.exports.visitors = (opts, callback) -> 

    id = opts.query.id

    #
    # TODO: limit to recent
    #

    database.Visitor.find().exec (err, result) -> 

        callback null, result.map (v) -> 

            me: id == v.id
            country: v.location.country
            region: v.location.region
            city: v.location.city
            ll: v.location.ll


#
# load landmass polygons from shapefile
# -------------------------------------
# 
# * reduce vertex precision to 1/10th of a degree
# * remap to array of arrays of 2vecs
#

round = (value) -> Math.floor( value * 10 ) / 10
earth = undefined
sf = new ShapeFile
sf.open 'data/ne_50m_land', (err, res) -> 
# sf.open 'data/ne_110m_land', (err, res) -> 
    earth = res.shapes.map (shape) -> 
        shape.vertices.map (vertex) -> 
            lat = round vertex[0]
            lon = round vertex[1]
            [lat, lon]

    
            


module.exports.earth = (opts, callback) -> 

    #
    # assumes earth is ready
    #

    callback null, earth




#
# enable www function routes
#

module.exports.$www = {}
module.exports.visitors.$www = {}
module.exports.earth.$www = {}
module.exports.build.$www = cache: true
module.exports.client.$www = cache: true
                                #
                                # TODO: vertex in production caches the 
                                #       response for /build and /client
                                #

