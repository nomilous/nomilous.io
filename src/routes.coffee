module.exports = (opts, callback) -> 

    #
    # root as function receives all requests, 404 all but /
    #

    return callback null, statusCode: 404 unless opts.path is '/'


    #
    # from nginx config:
    # proxy_set_header X-Real-IP $remote_addr;
    #

    if ip = opts.headers['x-real-ip']
        if location = geoip.lookup ip
            console.log location


    callback null, 

        headers: 'Content-Type': 'text/html'
        body: '<body style="background: #000000"></body>'



#
# TODO: vertex recursor should walk past function if next node on path is present
#

module.exports.client = (opts, callback) -> 

    callback null, 

        headers: 'Content-Type': 'text/javascript'
        body: 'alert("okgood");'




module.exports.$www = {}
module.exports.client.$www = {}

