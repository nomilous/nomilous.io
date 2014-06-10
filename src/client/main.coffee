
require ['/js/q.min.js', '/js/three.min.js', '/js/stats.min.js'], (Q) ->

    stats = new Stats
    stats.setMode 0
    stats.domElement.style.position = 'absolute'
    stats.domElement.style.left = '0px'
    stats.domElement.style.top = '0px'
    document.body.appendChild stats.domElement

    width     = 800
    height    = 600
    fov       = 65
    aspect    = width / height
    near      = 0.1
    far       = 2000
    renderer  = new THREE.WebGLRenderer antialias: true, alpha: false
    camera    = new THREE.PerspectiveCamera fov, aspect, near, far
    scene     = new THREE.Scene

    scene.add camera
    camera.position.z = 750

    scene.fog = new THREE.FogExp2 0x251d15, 0.0018
    renderer.setSize width, height
    renderer.setClearColor 0x050505, 1

    canvas = renderer.domElement
    document.body.appendChild canvas

    canvas.style.width = '100%'
    canvas.style.height = '100%'


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
                    notify progress: [event.loaded, event.total]

            req.onreadystatechange = (event) ->
                if req.readyState == 4
                    resolve JSON.parse req.responseText

            req.open 'GET', url, true

            req.send()

    Q.all(

        ['/earth', '/visitors'].map (url) -> getResource url

    ).then(

        ([earth, visitors]) -> console.log visitors
        (error) ->
        (notify) ->
    )
        

    animate = ->

        stats.begin()
        try requestAnimationFrame animate
        stats.end()

    animate()
    