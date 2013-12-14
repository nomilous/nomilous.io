require('vertex')

    #
    # TODO: vertex should rather export .create() function
    #

    www: 

        allowRoot: true
        root: root = (opts, callback) -> 

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

