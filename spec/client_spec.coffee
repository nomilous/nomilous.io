{ipso, mock, Mock, define, get} = require 'ipso'

describe 'Client', -> 

    before ipso -> 

        xhrRequestor = mock('xhrRequestor').with request: -> 

        define

            xhr: -> -> get('xhrRequestor').request.apply null, arguments
            asap: -> require process.cwd() + '/components/johntron-asap/asap'
            promise: -> require process.cwd() + '/components/then-promise'
            dom: -> (selector) -> append: -> css: -> append: ->
            three: ->
                WebGLRenderer: Mock('WebGLRenderer').with 
                    setSize: ->
                    setClearColor: ->
                    domElement: style: width: 0, height: 0
                PerspectiveCamera: Mock('PerspectiveCamera').with 
                    position: z: 0
                Scene: Mock('Scene').with 
                    add: ->
                FogExp2: Mock 'FogExp2'
                Geometry: Mock('Geometry').with vertices:[]
                ParticleBasicMaterial: Mock('ParticleBasicMaterial')
                ParticleSystem: Mock 'ParticleSystem'
                LineBasicMaterial: Mock('LineBasicMaterial')
                Vector3: Mock('Vector3').with
                    applyMatrix4: ->
                Line: Mock('Line')
                Matrix4: Mock('Matrix4').with
                    makeRotationY: ->
                    makeRotationX: ->
                Vertex: Mock 'Vertex'



    it 'renders /earth and /visitors', 

        ipso (facto, Client, xhrRequestor, WebGLRenderer) -> 

            urls = []
            xhrRequestor.does request: (opts, onSuccess) -> 

                urls.push opts.url

                switch opts.url 

                    when '/earth?id=visitor_id' then onSuccess 

                        status: 200
                        response: JSON.stringify [

                            [[-180, -89.99892578125002], [180, 83.599609375]]
                            [[179.99921875,-16.168554687500006],[179.84824218750003,-16.30166015625001]]

                        ]

                    when '/visitors?id=visitor_id' then onSuccess 

                        status: 200
                        response: "[]"

            WebGLRenderer.does render: -> facto()

            Client 'visitor_id'
            urls.should.eql [ '/earth?id=visitor_id', '/visitors?id=visitor_id' ]

