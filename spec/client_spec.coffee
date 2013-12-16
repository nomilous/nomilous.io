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
                ogExp2: Mock 'FogExp2'
                LineBasicMaterial: Mock('LineBasicMaterial')
                Geometry: Mock('Geometry').with vertices:[]
                Vector3: Mock('Vector3').with
                    applyMatrix4: ->
                Line: Mock('Line')
                Matrix4: Mock('Matrix4').with
                    makeRotationY: ->
                    makeRotationX: ->




    it 'renders /earth and /visitors', 

        ipso (facto, Client, xhrRequestor, WebGLRenderer) -> 

            urls = []
            xhrRequestor.does request: (opts, onSuccess) -> 

                urls.push opts.url

                switch opts.url 

                    when '/earth' then onSuccess 

                        status: 200
                        response: JSON.stringify

                            count: 1420,
                            type: 5,
                            minBound: [ -180, -89.99892578125002, 0, 0 ],
                            maxBound: [ 180, 83.599609375, 0, 0 ],
                            shapes: [
                                {      
                                    id: 0
                                    type: 5
                                    partCount: 1
                                    vertexCount: 2
                                    vertices:[
                                        [179.99921875,-16.168554687500006,0,0],
                                        [179.84824218750003,-16.30166015625001,0,0]
                                    ]
                                },
                                {
                                    id: 2
                                    type: 5
                                    partCount: 1
                                    vertexCount: 2
                                    vertices:[
                                        [179.99921875,-16.168554687500006,0,0],
                                        [179.84824218750003,-16.30166015625001,0,0]
                                    ]
                                }
                            ]

                    when '/visitors' then onSuccess 

                        status: 200
                        response: "[]"

            WebGLRenderer.does render: -> facto()

            Client()
            urls.should.eql [ '/earth', '/visitors' ]

