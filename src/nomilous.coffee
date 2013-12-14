require('vertex')

    www: 
        allowRoot: true
        root: root = (opts, callback) -> 

            console.log opts

            callback null, 

                headers: 'Content-Type': 'text/html'
                body: '<body style="background: #000000"></body>'

        listen: 
            port: 3000
        
root.$www = {}      

