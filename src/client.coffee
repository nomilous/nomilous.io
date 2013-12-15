module.exports = -> 
    
    ### browser-side ### 

    xhr     = require 'xhr'
    Promise = require 'promise'

    visitors = new Promise (resolve, reject) -> 

        xhr

            url: '/visitors'

            ({status, response}) ->
                
                if status is 200 then return resolve JSON.parse response
                reject new Error 'could not get visitors list status:', status

            # (error) -> reject error
            reject




    visitors.then (res) -> console.log visitors: res

