fs          = require 'fs'
geoip       = require 'geoip-lite'
{ShapeFile} = require 'node-shapelib-partial'
database    = require './database'

module.exports = (opts, callback) -> 

    #
    # root as function receives all non matched requests, 404 all but /
    #

    return callback null, statusCode: 404 unless opts.path is '/'

    response = -> 

        callback null, 

            headers: 'Content-Type': 'text/html'
            body: """
            <body>
                <script src="build"></script>
                <script src="client"></script>
            </body>
            """

    if ip = opts.headers['x-real-ip']

        v = new database.Visitor location: geoip.lookup ip
        v.save -> response()

    else response()



module.exports.client = (opts, callback) -> 

    callback null, 

        headers: 'Content-Type': 'text/javascript'
        body: """(
        #{require('./client').toString()}
        ).call(self);
        """


buildScript = """
    
    #{fs.readFileSync( __dirname + '/../build/build.js' ).toString()}

    //
    // something is chopping the last few chars off the build script delivery
    //

"""

module.exports.build = (opts, callback) -> 

    callback null,

        headers: 'Content-Type': 'text/javascript'
        body: buildScript


module.exports.visitors = (opts, callback) -> 

    #
    # TODO: limit to recent
    #

    database.Visitor.find().exec (err, result) -> 

        callback null, result.map (v) -> 

            country: v.location.country
            region: v.location.region
            city: v.location.city
            ll: v.location.ll


earth = undefined
sf = new ShapeFile
sf.open 'data/ne_50m_land', (err, shapes) -> 

    #
    # map to array of arrays of 2vecs
    #
    
    earth = shapes.shapes.map (p) -> p.vertices.map (v) -> v[0..1]


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

