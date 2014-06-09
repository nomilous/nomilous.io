module.exports = (id, hostname, port) -> 
    
    ### browser-side ### 

    require 'three-webgl-renderer'
    require 'three-camera'
    require 'three-scene'
    require 'three-line'
    require 'three-particle'

    THREE    = require 'three'
    dom      = require 'dom'
    xhr      = require 'xhr'
    Promise  = require 'promise'

    Stats    = require('three-stats')
    stats    = new Stats
    stats.setMode 0
    stats.domElement.style.position = 'absolute';
    stats.domElement.style.left = '0px';
    stats.domElement.style.top = '0px';


    container = dom('body').append('<div></div>').css
        position: 'absolute'
        width: '100%'
        height: '100%'
        top: '0px'
        left: '0px'

    container.append stats.domElement


    width     = 800
    height    = 600
    fov       = 65
    aspect    = width / height
    near      = 0.1
    far       = 2000
    bluriness = 1
    rotationX = 0.0005
    rotationY = 0.005
    renderer  = new THREE.WebGLRenderer antialias: true, alpha: false
    camera    = new THREE.PerspectiveCamera fov, aspect, near, far
    scene     = new THREE.Scene

    
    
    scene.add camera
    camera.position.z = 750


    scene.fog = new THREE.FogExp2 0x251d15, 0.0018
    #scene.fog = new THREE.FogExp2 0x251d15, 0.0013


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
            for polygon in earth # [0..1]
                material = new THREE.LineBasicMaterial color: 0xffffff
                geometry = new THREE.Geometry
                # i = 0
                for vertex in polygon

                    # #
                    # # draw line from every 4th vertex only
                    # # TODO: move this to server side if it stays
                    # #
                    # continue unless i++ % 4 is 0

                    geometry.vertices.push transform vertex[0], vertex[1] 
                landMasses.push polygon = new THREE.Line geometry, material
                scene.add polygon


            if canvas.width isnt canvas.clientWidth or canvas.height isnt canvas.clientHeight
                canvas.width = canvas.clientWidth
                canvas.height = canvas.clientHeight
                camera.aspect = canvas.width / canvas.height
                camera.updateProjectionMatrix()
                renderer.setSize canvas.width, canvas.height      


            #
            # visitors particle system
            # ========================
            # 

            persons = []
            updateLocation = (person) -> 

                #
                # update location of the visitors dom label
                # -----------------------------------------
                # 
                # * line.matrixWorld contains the transforms applied to the line
                # 
                # * use it to transform a clone of the vertex at the outer end
                #   of the label line to current "world" location
                # 

                vertex = person.line.geometry.vertices[1].clone()
                vertex.applyMatrix4 person.line.matrixWorld

                #
                # * project 3d vertex into 2d screen coords
                #

                projector.projectVector vertex, camera
                x = (vertex.x + 1)/2 * canvas.width
                y = -(vertex.y - 1)/2 * canvas.height


                #
                # * adjust label into new position
                #

                adjustHeight = 10
                adjustWidth  = person.text.length * 2
                x -= adjustWidth
                y -= adjustHeight
                person.elem.css top: "#{y}px", left: "#{x}px"


            material  = new THREE.ParticleBasicMaterial color: 0xaaaaaa, size: 4, fog: false
            geometry  = new THREE.Geometry
            particles = new THREE.ParticleSystem geometry, material
            projector = new THREE.Projector
            scene.add particles
            for {country, region, city, ll, me} in visitors

                position = transform ll[1], ll[0]

                if true # if me 

                    labelGeom = new THREE.Geometry
                    labelMat  = new THREE.LineBasicMaterial color: 0xffffff
                    labelGeom.vertices.push position
                    labelGeom.vertices.push position.clone().multiplyScalar 1.3
                    scene.add labelLine = new THREE.Line labelGeom, labelMat

                    text = "#{city}, #{country}"
                    elem = container.append("<div>#{text}</div>").css
                            color: '#cccccc'
                            'font-size': 'xx-small'
                            position: 'absolute'
                            top: '0px'
                            left: '0px'

                    persons.push
                        text: text
                        elem: elem
                        line: labelLine


                geometry.vertices.push position
 


            animate = ->

                stats.begin()

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
                    # composer.setSize canvas.width, canvas.height
                    # hblur.uniforms[ 'h' ].value = bluriness / canvas.width;
                    # vblur.uniforms[ 'v' ].value = bluriness / canvas.height;
                    

                # renderer.initWebGLObjects scene
                # renderer.autoClear = false
                # renderer.shadowMapEnabled = true
                # renderer.autoUpdateObjects = true
                # renderer.clearTarget null
                
                renderer.render scene, camera
                # renderer.render scene, nearCam
                # composer.render 0.1 


            

                #
                # animate for next frame
                #

                for polygon in landMasses
                    polygon.rotation.x += rotationX
                    polygon.rotation.y += rotationY

                particles.rotation.x +=  rotationX
                particles.rotation.y += rotationY

                for person in persons
                    person.line.rotation.x += rotationX
                    person.line.rotation.y += rotationY
                    updateLocation person


                stats.end()


            # #
            # # multiple pass render
            # # --------------------
            # # 
            # # * get a bit too heavy on fullscreen (?when antialias enable?)
            # #
            
            # # renderTarget = new THREE.WebGLRenderTarget canvas.width, canvas.height,
            # #     minFilter: THREE.LinearFilter
            # #     magFilter: THREE.LinearFilter
            # #     format: THREE.RGBFormat
            # #     stencilBuffer: false

            
            # renderModel = new THREE.RenderPass scene, camera

            # # kaleido     = new THREE.ShaderPass THREE.KaleidoShader 
            # # hblur       = new THREE.ShaderPass THREE.HorizontalTiltShiftShader
            # # vblur       = new THREE.ShaderPass THREE.VerticalTiltShiftShader
            # lastPass    = new THREE.ShaderPass THREE.CopyShader
            # lastPass.renderToScreen = true

            # composer    = new THREE.EffectComposer renderer #, renderTarget

            # # kaleido.uniforms.sides.value = 1
            # # kaleido.uniforms.angle.value = - Math.PI / 2

            # # #
            # # # * tiltshift perfoms post render vertical and horizontal fragment shader 
            # # #   passes to achieve a gausian blur effect 
            # # #   (excluding a narrow configured horizontal band)
            # # # 
            # # # * parameters h and v (propotional to the canvas) specify blur amount
            # # # * parameter r is used to set the vertical location of the horizontal 
            # # #   band that remains in focus
            # # #

            # # hblur.uniforms[ 'h' ].value = bluriness / canvas.width
            # # vblur.uniforms[ 'v' ].value = bluriness / canvas.height
            # # hblur.uniforms[ 'r' ].value = vblur.uniforms[ 'r' ].value = 0.6

            # composer.addPass renderModel
            # # composer.addPass kaleido
            # # composer.addPass hblur
            # # composer.addPass vblur
            # composer.addPass lastPass
            
            animate()


        (error) -> console.log error

    )
