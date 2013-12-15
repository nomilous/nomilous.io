{ipso} = require 'ipso'

describe 'Database', -> 

    before ipso (mongoose) -> 

        #
        # spy on the connect and hoist uri into test context (self.uri)
        #

        mongoose.does _connect: (@uri) => 


    it 'connected to the configured mongodb', 

        ipso (Database) -> 

            @uri.should.equal 'mongodb://localhost/nomilous_test'


    it 'defines visitors collection', 

        ipso (Database, should) -> 

            should.exist Database.Visitor
