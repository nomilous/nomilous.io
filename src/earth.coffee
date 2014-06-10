#
# preload landmass polygons
# -------------------------
#
# * reduce vertex precision to 1/10th of a degree
# * remap to array of arrays of 2vecs
#

{ShapeFile} = require 'node-shapelib-partial'

round = (value) -> Math.floor( value * 10 ) / 10

earth = undefined

sf = new ShapeFile
sf.open 'data/ne_50m_land', (err, res) ->
    earth = res.shapes.map (shape) ->
        shape.vertices.map (vertex) ->
            lat = round vertex[0]
            lon = round vertex[1]
            [lat, lon]

module.exports = (app) ->

    #
    # assumes earth is loaded
    #

    app.get '/earth', (req, res) ->

        res.send earth

