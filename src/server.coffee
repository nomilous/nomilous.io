require('vertex').create

    www: 

        listen: 
            port: process.env.WWW_PORT || 3001
            hostname: '0.0.0.0'
        root: require './routes'
        allowRoot: true

