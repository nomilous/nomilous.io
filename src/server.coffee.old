require('vertex').create

    www: 
        listen: port: process.env.WWW_PORT || 3000
        root: require './routes'
        allowRoot: true

    secret: 'x'
    listen: 
        hostname: process.env.WEBSOCKET_HOSTNAME || 'localhost'
        port: process.env.WEBSOCKET_PORT || 3003


