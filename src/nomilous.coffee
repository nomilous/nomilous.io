require('vertex')

    www: 
        allowRoot: true
        root: root = (opts, callback) -> 

            callback null, 

                headers: 'Content-Type': 'text/html'
                body: '<body style="background: #000000"></body>'

        listen: 
            port: 3000
        
root.$www = {}      

