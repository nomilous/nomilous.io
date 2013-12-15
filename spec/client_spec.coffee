{ipso, mock, Mock, define, get} = require 'ipso'

describe 'Client', -> 

    before ipso -> 

        xhrRequestor = mock('xhrRequestor').with request: -> 

        define

            #
            # define for require('xhr')
            #

            $xhr: -> get('xhrRequestor').request.apply null, arguments


            #
            # define for require('promise')
            #

            promise: -> class Promise

                constructor: (resolver) -> 
                    resolver(
                        (@result) => 
                        (@error) => 
                    )
                then: (onResult, onError) ->  
                    if @error then return onError @error
                    onResult @result



    it 'gets visitors list', 

        ipso (Client, xhrRequestor) -> 

            xhrRequestor.does 
                request: (opts, onResult) -> 
                    opts.url.should.equal '/visitors'
                    onResult status: 200, response: "[]"

            Client()
