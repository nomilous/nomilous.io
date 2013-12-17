require('vertex').create

    www: 

        listen: 
            port: process.env.WWW_PORT || 3000
        root: require './routes'
        allowRoot: true


    secret: 'secret'
    listen: port: process.env.SOCKET_PORT || 3003

