geoip = require 'geoip-lite'
fs    = require 'fs'

module.exports = (opts, callback) -> 

    #
    # root as function receives all non matched requests, 404 all but /
    #

    return callback null, statusCode: 404 unless opts.path is '/'

    if ip = opts.headers['x-real-ip']
        if location = geoip.lookup ip
            console.log LOCATION: location


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

module.exports.build = (opts, callback) -> 

    callback null,

        headers: 'Content-Type': 'text/javascript'
        body: fs.readFileSync( __dirname + '/../build/build.js' ).toString()



#
# enable www function routes
#

module.exports.$www = {}
module.exports.build.$www = cache: true
module.exports.client.$www = cache: true
                                #
                                # TODO: vertex in production caches the 
                                #       response for /build and /client
                                #

