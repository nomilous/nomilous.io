{ipso} = require 'ipso'

describe 'Database', -> 

    before ipso (mongoose) -> 

        mongoose.does connect: (@uri) =>


    it 'connected to the configured mongodb', 

        ipso (Database) -> 

            @uri.should.equal 'mongodb://localhost/nomilous_test'

