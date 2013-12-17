module.exports = (id, hostname, port) -> 
    
    ### browser-side ### 

    dom      = require 'dom'
    THREE    = require 'three'; require 'three-postprocessing'
    xhr      = require 'xhr'
    Promise  = require 'promise'
    client   = require 'vertex-client'


    # uplink = client.create

    #     uuid: id
    #     secret: 'x'
    #     connect: uri: "ws://#{hostname}:#{port}"


    # uplink.connect()

    # uplink.socket.on 'message', (payload) -> 

    #     console.log received: payload



    container = dom('body').append('<div></div>').css
        position: 'absolute'
        width: '100%'
        height: '100%'
        top: '0px'
        left: '0px'


    width     = 800
    height    = 600
    fov       = 60
    aspect    = width / height
    near      = 0.1
    far       = 2000
    bluriness = 5
    renderer  = new THREE.WebGLRenderer antialias: false, alpha: false
    camera    = new THREE.PerspectiveCamera fov, aspect, near, far
    scene     = new THREE.Scene
    scene.fog = new THREE.FogExp2 0x251d15, 0.0018

    scene.add camera
    camera.position.z = 750
    renderer.setSize width, height
    #renderer.setClearColor 0x222222, 1
    renderer.setClearColor 0x050505, 1

    canvas = renderer.domElement
    container.append canvas

    #
    # stretch to full available size
    #

    canvas.style.width = '100%'
    canvas.style.height = '100%'

    radianRatio = Math.PI / 180
    radius      = 300
    toLongitude = new THREE.Matrix4
    toLatitude  = new THREE.Matrix4

    transform = (longitude, latitude) -> 

        #
        # returns vertex [x,y,z] on sphere
        # --------------------------------
        # 
        # * position vertex at lat = 0.0, long = 0.0, radius
        # * transform position through lat and long rotation matrices
        # 

        vector = new THREE.Vector3 0.0, 0.0, radius
        toLongitude.makeRotationY longitude * radianRatio
        toLatitude.makeRotationX  -latitude * radianRatio
        vector.applyMatrix4 toLatitude
        vector.applyMatrix4 toLongitude
        return vector


    Promise.all( 

        ['/earth', '/visitors'].map (path) -> 
            new Promise (resolve, reject) -> xhr
                method: 'GET'
                url: path + "?id=#{id}"
                ({status, response}) ->
                    if status is 200 then return resolve JSON.parse response
                    reject new Error "#{path} error status", status
                reject

    ).then(

        ([earth, visitors]) -> 

            #
            # TODO: 
            # 
            # * fetch in multiple parts and load each immediately 
            #   (the page is silent till loaded)
            # 
            # * create opt-in cdn for model data
            #       * model uuid, title, version
            #       * use builtin browser db when available / update per version
            #

            #
            # earth landmass polygons
            # =======================
            # 

            landMasses = []
            for polygon in earth
                material = new THREE.LineBasicMaterial color: 0xffffff
                geometry = new THREE.Geometry
                for vertex in polygon
                    geometry.vertices.push transform vertex[0], vertex[1] 
                landMasses.push polygon = new THREE.Line geometry, material
                scene.add polygon

            #
            # visitors particle system
            # ========================
            # 

            material  = new THREE.ParticleBasicMaterial color: 0xffffff, size: 8, fog: false
            geometry  = new THREE.Geometry
            particles = new THREE.ParticleSystem geometry, material
            scene.add particles
            for {country, region, city, ll, me} in visitors

                if me then console.log city, region, country, ll
                geometry.vertices.push transform ll[1], ll[0]
 


            animate = ->

                #
                # schedule next frame refresh
                #

                try requestAnimationFrame animate

                #
                # handle possible resize that may have ocurred
                #

                if canvas.width isnt canvas.clientWidth or canvas.height isnt canvas.clientHeight
                    canvas.width = canvas.clientWidth
                    canvas.height = canvas.clientHeight
                    camera.aspect = canvas.width / canvas.height
                    camera.updateProjectionMatrix()
                    renderer.setSize canvas.width, canvas.height         
                    composer.setSize canvas.width, canvas.height
                    # hblur.uniforms[ 'h' ].value = bluriness / canvas.width;
                    # vblur.uniforms[ 'v' ].value = bluriness / canvas.height;
                    

                renderer.initWebGLObjects scene
                renderer.autoClear = false
                renderer.shadowMapEnabled = true
                renderer.autoUpdateObjects = true
                #renderer.clearTarget null
                composer.render 0.1

            

                #
                # animate for next frame
                #

                for polygon in landMasses
                    polygon.rotation.x += 0.003 
                    polygon.rotation.y += 0.03 

                particles.rotation.x +=  0.003
                particles.rotation.y += 0.03



            #
            # multiple pass render
            # --------------------
            # 
            # * get a bit too heavy on fullscreen (?when antialias enable?)
            #
            
            # renderTarget = new THREE.WebGLRenderTarget canvas.width, canvas.height,
            #     minFilter: THREE.LinearFilter
            #     magFilter: THREE.LinearFilter
            #     format: THREE.RGBFormat
            #     stencilBuffer: false

            # material_depth = new THREE.MeshDepthMaterial


            renderModel = new THREE.RenderPass scene, camera
            bokehPass   = new THREE.BokehPass scene, camera,
                    focus: 1.0
                    aperture: 0.025
                    maxblur: 1.0
                    width: canvas.width
                    height: canvas.height

            bokehPass.renderToScreen = true

            # hblur       = new THREE.ShaderPass THREE.HorizontalTiltShiftShader
            # vblur       = new THREE.ShaderPass THREE.VerticalTiltShiftShader
            # lastPass    = new THREE.ShaderPass THREE.CopyShader
            # lastPass.renderToScreen = true

            composer    = new THREE.EffectComposer renderer #, renderTarget

            # #
            # # * tiltshift perfoms post render vertical and horizontal fragment shader 
            # #   passes to achieve a gausian blur effect 
            # #   (excluding a narrow configured horizontal band)
            # # 
            # # * parameters h and v (propotional to the canvas) specify blur amount
            # # * parameter r is used to set the vertical location of the horizontal 
            # #   band that remains in focus
            # #

            # hblur.uniforms[ 'h' ].value = bluriness / canvas.width
            # vblur.uniforms[ 'v' ].value = bluriness / canvas.height
            # hblur.uniforms[ 'r' ].value = vblur.uniforms[ 'r' ].value = 0.6

            composer.addPass renderModel
            composer.addPass bokehPass
            # composer.addPass hblur
            # composer.addPass vblur
            # composer.addPass lastPass
            

            

            animate()


        (error) -> console.log error

    )
