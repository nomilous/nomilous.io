module.exports = -> 
    
    ### browser-side ### 

    dom      = require 'dom'
    THREE    = require 'three'
    xhr      = require 'xhr'
    Promise  = require 'promise'


    container = dom('body').append '<div></div>'

    width     = 400
    height    = 300
    fov       = 45
    aspect    = width / height
    near      = 0.1
    far       = 1000
    renderer  = new THREE.WebGLRenderer
    camera    = new THREE.PerspectiveCamera fov, aspect, near, far
    scene     = new THREE.Scene

    scene.add camera
    camera.position.z = 300
    renderer.setSize width, height
    renderer.setClearColor 0x222222, 1

    container.append renderer.domElement

    Promise.all( 

        ['/earth', '/visitors'].map (path) -> 

            new Promise (resolve, reject) ->  xhr

                method: 'GET'
                url: path

                ({status, response}) ->

                    if status is 200 then return resolve JSON.parse response
                    reject new Error "#{path} error status", status

                reject


    ).then(

        ([earth, visitors]) -> 

            animate = ->

                try requestAnimationFrame animate
                renderer.render scene, camera

            animate()

        (error) -> 

            console.log error

    )
