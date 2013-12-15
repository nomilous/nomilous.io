{ipso, mock, Mock, define, get} = require 'ipso'

describe 'Client', -> 

    before ipso -> 

        xhrRequestor = mock('xhrRequestor').with request: -> 

        define

            xhr: -> -> get('xhrRequestor').request.apply null, arguments
            asap: -> require process.cwd() + '/components/johntron-asap/asap'
            promise: -> require process.cwd() + '/components/then-promise'
            dom: -> (selector) -> append: -> append: ->
            three: ->
                WebGLRenderer: Mock('WebGLRenderer').with 
                    setSize: ->
                    setClearColor: ->
                PerspectiveCamera: Mock('PerspectiveCamera').with 
                    position: z: 0
                Scene: Mock('Scene').with 
                    add: ->


    it 'renders /earth and /visitors', 

        ipso (facto, Client, xhrRequestor, WebGLRenderer) -> 

            urls = []
            xhrRequestor.does request: (opts, onSuccess) -> 

                urls.push opts.url
                onSuccess status: 200, response: "[]"

            WebGLRenderer.does render: -> facto()

            Client()
            urls.should.eql [ '/earth', '/visitors' ]

