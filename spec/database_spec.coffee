{ipso} = require 'ipso'

describe 'Database', -> 

    before ipso (done, mongoose) -> 

        #
        # spy on the connect and hoist uri into test context (self.uri)
        #

        mongoose.does _connect: (@uri) => 

            #
            # um... 
            #    save() silently fails if called before db connected
            #    or never tries, because test runner exists before it can save
            #

        setTimeout done, 100


    it 'connected to the configured mongodb', 

        ipso (Database) -> 

            @uri.should.equal 'mongodb://localhost/nomilous_test'


    it 'defines visitors collection', 

        ipso (Database, should) -> 

            should.exist Database.Visitor


    it 'stores a visitor timestamp', 

        ipso (facto, Database) -> 

            (new Database.Visitor).save (err, saved) -> 

                saved.timestamp.should.be.an.instanceof Date
                facto()


    it 'defaults location when unknown', 

        ipso (facto, Database) -> 

            (new Database.Visitor).save (err, saved) -> 

                saved.location.country.should.eql ''
                saved.location.region.should.eql ''
                saved.location.city.should.eql ''
                # saved.location.ll.should.eql [0,0]  # # ## huh?
                saved.location.ll[0].should.equal 0
                saved.location.ll[1].should.equal 0

                # saved.location.range.should.eql [ 0, 0 ]
                #     # range: [0, 0]
                #     # country: ''
                #     # region: ''
                #     # city: ''
                #     # ll: [0,0]

                facto()

