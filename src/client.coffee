module.exports = -> 
    
    ### browser-side ### 

    dom      = require 'dom'
    THREE    = require 'three'
    xhr      = require 'xhr'
    Promise  = require 'promise'


    container = dom('body').append '<div></div>'

    width     = 800
    height    = 800
    fov       = 60
    aspect    = width / height
    near      = 0.1
    far       = 2000
    renderer  = new THREE.WebGLRenderer
    camera    = new THREE.PerspectiveCamera fov, aspect, near, far
    scene     = new THREE.Scene
    scene.fog = new THREE.FogExp2 0x251d15, 0.0018

    scene.add camera
    camera.position.z = 650
    renderer.setSize width, height
    renderer.setClearColor 0x222222, 1

    container.append renderer.domElement



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
                url: path

                ({status, response}) ->

                    if status is 200 then return resolve JSON.parse response
                    reject new Error "#{path} error status", status

                reject


    ).then(

        ([earth, visitors]) -> 

            #
            # TODO: 
            # 
            # * landmass shapedata is 2.5Mb as json (tighten)
            # * fetch in multiple parts and load each immediately 
            #   (the page is silent till loaded)
            #

            landMasses = []

            for shape in earth.shapes

                material = new THREE.LineBasicMaterial color: 0xffffff
                geometry = new THREE.Geometry
                vertices = shape.vertices

                for vertex in vertices

                    #
                    # polygons with lat and long as x and y (flat)
                    #

                    geometry.vertices.push transform vertex[0], vertex[1]


                landMasses.push polygon = new THREE.Line geometry, material
                scene.add polygon


            animate = ->

                try requestAnimationFrame animate
                renderer.render scene, camera
                polygon.rotation.y += 0.03 for polygon in landMasses
                polygon.rotation.x += 0.003 for polygon in landMasses


            animate()

        (error) -> 

            console.log error

    )
