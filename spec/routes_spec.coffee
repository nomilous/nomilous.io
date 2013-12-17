{ipso, tag} = require 'ipso'

describe 'Routes', -> 

    before ipso (mongoose) -> 

        #
        # injectable tag name, '-' cannot be used by ipso injector
        #

        tag geoip: require 'geoip-lite'


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


        it 'saves a new Visitor record', 

            ipso (facto, Routes, Database, should) -> 

                Database.Visitor = class 

                    constructor: ({location}) -> 

                        location.should.eql
                            range: [ 67305984, 67306239 ]
                            country: 'US'
                            region: 'CA'
                            city: 'Mountain View'
                            ll: [ 37.4192, -122.0574 ]

                    save: -> facto()

                Routes 
                    headers: 'x-real-ip': '4.3.2.1'
                    path: '/'
                    (err, result) -> 



    context '/client', -> 

        it 'responds with js from client module', 

            ipso (Routes, should) -> 

                Routes.client 

                    #
                    # inbound query contains id and assigned uplink hostname (websocket) 
                    # as templated in / html script tag
                    #

                    query: 
                        id: 'visitor_id'
                        hostname: 'uplink.hostname'
                        # port: 'uplink.port'

                    (err, result) -> 

                        result.headers.should.eql 'Content-Type':'text/javascript'
                        result.body.should.match /browser-side/


    context '/visitors', -> 

        it 'responds with json list of visitors and flags "me" for visitors own record', 

            ipso (facto, Routes, Database, should) -> 

                Database.Visitor = class 

                    #
                    # mock mongoose find()
                    #

                    @find = -> exec: (callback) -> 
                        callback null, [
                            { 
                                id: 'visitor_id'
                                location:
                                    country: 'US'
                                    region: 'CA'
                                    city: 'Mountain View'
                                    ll: [ 37.4192, -122.0574 ] 
                            }
                        ] 

                Routes.visitors 

                    #
                    # inbound query contains id as templated in / html script tag
                    #

                    query: id: 'visitor_id'

                    (err, result) -> 

                        result.should.eql [
                            { 
                                me: true
                                country: 'US'
                                region: 'CA'
                                city: 'Mountain View'
                                ll: [ 37.4192, -122.0574 ] 
                            }
                        ]

                        facto()


