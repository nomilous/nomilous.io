
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

            document.body.appendChild canvas
            document.body.appendChild stats.domElement
            

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
                x = (vertex.x + 1)/2 * window.innerWidth # canvas.width
                y = -(vertex.y - 1)/2 * window.innerHeight # canvas.height


                #
                # * adjust label into new position
                #

                adjustHeight = 10
                adjustWidth  = person.text.length * 2
                x -= adjustWidth
                y -= adjustHeight
                person.elem.style.top = "#{y}px"
                person.elem.style.left = "#{x}px"


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
                    elem = document.createElement 'div'
                    elem.innerHTML = text
                    document.body.appendChild elem
                    elem.style.position = 'absolute'
                    elem.style.color = '#cccccc'
                    elem.style['font-size'] = 'xx-small'
                    elem.style.top = '0px'
                    elem.style.left = '0px'

                    persons.push
                        line: labelLine
                        text: text
                        elem: elem


                geometry.vertices.push position


            onResize = ->

                canvas.width = window.innerWidth
                canvas.height = window.innerHeight
                camera.aspect = canvas.width / canvas.height
                camera.updateProjectionMatrix()
                renderer.setSize canvas.width, canvas.height

            onResize()

            window.addEventListener 'resize', onResize


            animate = ->

                stats.begin()
                try requestAnimationFrame animate
                
                renderer.render scene, camera

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

    