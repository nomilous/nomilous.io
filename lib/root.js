// Generated by CoffeeScript 1.6.3
var Visitor, geoip, randomIP;

Visitor = require('./database').Visitor;

geoip = require('geoip-lite');

randomIP = function() {
  var random;
  random = function() {
    return Math.floor(Math.random() * 254);
  };
  return "" + (random()) + "." + (random()) + "." + (random()) + "." + (random());
};

module.exports = function(app) {
  return app.get('/', function(req, res) {
    var ip;
    ip = req.headers['x-real-ip'];
    if (process.env.NODE_ENV !== 'production') {
      ip || (ip = randomIP());
    }
    if (req.session.visitor_id == null) {
      return (new Visitor({
        location: geoip.lookup(ip)
      })).save(function(error, visitor) {
        console.log({
          "new": visitor._id
        });
        req.session.visitor_id = visitor._id;
        return res.render('index');
      });
    } else {
      console.log({
        existing: req.session.visitor_id
      });
      return res.render('index');
    }
  });
};
