{ipso, tag} = require 'ipso'

describe 'Routes', -> 

    before ipso (mongoose) -> 

        #
        # injectable tag name, '-' cannot be used by ipso injector
        #

        tag geoip: require 'geoip-lite'

        #
        # stub the db connect
        #

        mongoose.does connect: ->


    context '/', ->

        it 'looks up the geoip', 

            ipso (Routes, geoip, should) -> 

                geoip.does
                    _lookup: (ip) -> 
                        ip.should.equal '1.1.1.1'

                Routes 

                    #
                    # inbound from nginx config:
                    # proxy_set_header X-Real-IP $remote_addr;
                    #

                    headers: 'x-real-ip': '1.1.1.1'
                    path: '/'

                    (err, result) -> 




    context '/client', -> 

        it 'responds with js from client module', 

            ipso (Routes, should) -> 

                Routes.client {}, (err, result) -> 

                    result.headers.should.eql 'Content-Type':'text/javascript'
                    result.body.should.match /browser-side/

