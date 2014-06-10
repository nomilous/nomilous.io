
require ['/js/q.min.js', '/js/three.min.js', '/js/stats.min.js'], (Q) ->

    stats = new Stats
    stats.setMode 0
    stats.domElement.style.position = 'absolute'
    stats.domElement.style.left = '0px'
    stats.domElement.style.top = '0px'

    width     = 800
    height    = 600
    fov       = 65
    aspect    = width / height
    near      = 0.1
    far       = 2000
    rotationX = 0.0005
    rotationY = 0.005
    renderer  = new THREE.WebGLRenderer antialias: true, alpha: false
    camera    = new THREE.PerspectiveCamera fov, aspect, near, far
    scene     = new THREE.Scene

    scene.add camera
    camera.position.z = 750

    scene.fog = new THREE.FogExp2 0x251d15, 0.0018
    renderer.setSize width, height
    renderer.setClearColor 0x050505, 1

    canvas = renderer.domElement

    canvas.style.width = '100%'
    canvas.style.height = '100%'
    canvas.style.position = 'absolute'
    canvas.style.left = '0px'
    canvas.style.top = '0px'

    progress = items: []
    progressBarLength = 300

    getResource = (url) ->

        Q.Promise (resolve, reject, notify) ->

            req = new XMLHttpRequest()

            req.onload = (event) ->
                if req.status != 200
                    reject new Error 'failed to load ' + url

            req.onerror = (event) ->
                reject new Error 'failed to load ' + url

            req.onprogress = (event) ->
                if event.lengthComputable
                    notify [event.loaded, event.total]

            req.onreadystatechange = (event) ->
                if req.readyState == 4
                    resolve JSON.parse req.responseText

            req.open 'GET', url, true

            req.send()

    Q.all(

        ['/earth', '/visitors'].map (url) -> getResource url

    ).then(

        ([earth, visitors]) ->

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

            landMasses = []
            for polygon in earth

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

            onResize = ->

                canvas.width = window.innerWidth
                canvas.height = window.innerHeight
                camera.aspect = canvas.width / canvas.height
                camera.updateProjectionMatrix()
                renderer.setSize canvas.width, canvas.height
            
            document.body.appendChild canvas
            document.body.appendChild stats.domElement

            onResize()

            window.addEventListener 'resize', onResize


            animate = ->

                stats.begin()
                try requestAnimationFrame animate
                
                renderer.render scene, camera

                for polygon in landMasses
                    polygon.rotation.x += rotationX
                    polygon.rotation.y += rotationY

                stats.end()

            animate()

        (error) ->

            console.log error: error

        (notify) ->

            progress.items[notify.index] = notify.value
            progress.total = 0
            progress.done = 0
            for item in progress.items
                continue unless item?
                progress.total += item[1]
                progress.done += item[0]

            doneLength = progressBarLength * progress.done / progress.total
            document.getElementById('progress').style.width = doneLength + 'px'

    )

    