{ipso, mock, Mock, define, get} = require 'ipso'

describe 'Client', -> 

    before ipso -> 

        xhrRequestor = mock('xhrRequestor').with request: -> 

        define

            xhr: -> -> get('xhrRequestor').request.apply null, arguments
            asap: -> require process.cwd() + '/components/johntron-asap/asap'
            promise: -> require process.cwd() + '/components/then-promise'
            dom: -> (selector) -> 
            three: -> 


    it 'gets /earth and /visitors', 

        ipso (Client, xhrRequestor) -> 

            urls = []
            xhrRequestor.does request: (opts) -> urls.push opts.url  
            Client()
            urls.should.eql [ '/earth', '/visitors' ]

