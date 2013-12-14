geoip = require 'geoip-lite'

require('vertex')

    #
    # TODO: vertex should rather export .create() function
    #

    www: 

        allowRoot: true
        root: root = (opts, callback) -> 

            #
            # from nginx config:
            # proxy_set_header X-Real-IP $remote_addr;
            #

            console.log IP: opts.headers['X-Real-IP']

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

