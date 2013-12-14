geoip = require 'geoip-lite'

require('vertex')

    #
    # TODO: vertex should rather export .create() function
    #

    www: 

        allowRoot: true
        root: root = (opts, callback) -> 

            #
            # root as function receives all requests, 404 all but /
            #

            return callback null, statusCode: 404 unless opts.path is '/'


            #
            # from nginx config:
            # proxy_set_header X-Real-IP $remote_addr;
            #

            if ip = opts.headers['x-real-ip']
                if localtion = geoip.lookup ip
                    console.log location


            callback null, 

                headers: 'Content-Type': 'text/html'
                body: '<body style="background: #000000"></body>'


        listen: 
            port: process.env.WWW_PORT
            hostname: 'localhost'

            #
            # TODO: vertex should default to localhost
            #

            
        
root.$www = {}

