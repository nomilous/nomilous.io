{ipso, mock, define, get} = require 'ipso'

describe 'Client', -> 

    before ipso -> 

        #
        # hackery to deal with module that exports 1 function
        # ===================================================
        # 
        # * create injectable mock with request function
        # * define 'xhr' node_module  
        # 

        xhrRequestor = mock('xhrRequestor').with request: -> 
        define $xhr: -> get('xhrRequestor').request.apply null, arguments


    it 'gets visitors list', 

        ipso (Client, xhrRequestor) -> 

            xhrRequestor.does 
                request: (opts) -> 
                    opts.url.should.equal '/visitors'

            Client()

