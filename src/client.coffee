module.exports = -> 
    
    ### browser-side ### 

    xhr      = require 'xhr'
    Promise  = require 'promise'


    Promise.all( 

        ['/earth', '/visitors'].map (path) -> 

            new Promise (resolve, reject) ->  xhr

                method: 'GET'
                url: path

                ({status, response}) ->

                    if status is 200 then return resolve JSON.parse response
                    reject new Error "#{path} error status", status

                reject


    ).then(

        ([earth, visitors]) -> 

            console.log e: earth
            console.log v: visitors

        (error) -> 

    )
