require('vertex')

    www: 

        allowRoot: true
        root: root = (opts, callback) -> 

            callback null, 

                headers: 'Content-Type': 'text/html'
                body: '<body style="background: #000000"></body>'

        listen: 
            port: process.env.WWW_PORT
        
root.$www = {}      

