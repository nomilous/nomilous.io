require('vertex')

    #
    # TODO: vertex should rather export .create() function
    #

    www: 

        allowRoot: true
        root: require './routes'

        listen: 
            port: process.env.WWW_PORT || 3000
            hostname: 'localhost'

            #
            # TODO: vertex should default to localhost
            #
