module.exports = -> 
    
    ### browser-side ### 

    xhr = require 'xhr'

    xhr 
        url: '/visitors'
        ({status, response}) -> console.log visitors: JSON.parse response
        (err) -> 

