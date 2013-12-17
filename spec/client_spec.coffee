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
                    initWebGLObjects: ->
                    clearTarget: ->
                    domElement: style: width: 0, height: 0
                PerspectiveCamera: Mock('PerspectiveCamera').with 
                    position: z: 0
                    updateProjectionMatrix: ->
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
                Vertex: Mock('Vertex')

                #
                # bits from postprocessing
                #

                WebGLRenderTarget: class
                CopyShader: class
                RenderPass: class
                ShaderPass: Mock('ShaderPass').with 
                    renderToScreen: true
                EffectComposer: Mock('EffectComposer').with
                    setSize: ->
                    addPass: ->
                    render: ->

            'vertex-client': -> mock('vertexClient').with 
                create: -> 
                    connect: ->
                    socket: on: ->

            'three-postprocessing': -> 


    it.only 'renders /earth and /visitors', 

        #ipso (facto, Client, xhrRequestor, WebGLRenderer) -> 
        ipso (facto, Client, xhrRequestor, EffectComposer) -> 

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

            #WebGLRenderer.does render: -> facto()
            EffectComposer.does render: -> facto()

            Client 'visitor_id'
            urls.should.eql [ '/earth?id=visitor_id', '/visitors?id=visitor_id' ]


    it 'creates vertex client socket connection', 

        ipso (facto, Client, vertexClient) -> 

            vertexClient.does 

                _create: (opts) -> 
                
                    opts.should.eql 

                        uuid: 'visitor_id'
                        secret: 'x'
                        connect: uri: 'ws://uplink.hostname:uplink.port'

                    facto()

            Client 'visitor_id', 'uplink.hostname', 'uplink.port'
            

