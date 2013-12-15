fs       = require 'fs'
geoip    = require 'geoip-lite'
database = require './database'

module.exports = (opts, callback) -> 

    #
    # root as function receives all non matched requests, 404 all but /
    #

    return callback null, statusCode: 404 unless opts.path is '/'

    if ip = opts.headers['x-real-ip']

        v = new database.Visitor location: geoip.lookup ip
        v.save -> # not waiting for save


    callback null, 

        headers: 'Content-Type': 'text/html'
        body: """
        <body>
            <script src="build"></script>
            <script src="client"></script>
        </body>
        """



module.exports.client = (opts, callback) -> 

    callback null, 

        headers: 'Content-Type': 'text/javascript'
        body: """(
        #{require('./client').toString()}
        ).call(self);
        """

buildScript = fs.readFileSync( __dirname + '/../build/build.js' ).toString('utf8')

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

            location: 
                country: v.location.country
                region: v.location.region
                city: v.location.city
                ll: v.location.ll




#
# enable www function routes
#

module.exports.$www = {}
module.exports.visitors.$www = {}
module.exports.build.$www = cache: true
module.exports.client.$www = cache: true
                                #
                                # TODO: vertex in production caches the 
                                #       response for /build and /client
                                #

