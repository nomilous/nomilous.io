// Generated by CoffeeScript 1.6.3
require(['/js/q.min.js', '/js/three.min.js', '/js/stats.min.js'], function(Q) {
  var aspect, camera, canvas, far, fov, getResource, height, near, progress, progressBarLength, renderer, rotationX, rotationY, scene, stats, width;
  stats = new Stats;
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  width = 800;
  height = 600;
  fov = 65;
  aspect = width / height;
  near = 0.1;
  far = 2000;
  rotationX = 0.0005;
  rotationY = 0.005;
  renderer = new THREE.WebGLRenderer({
    antialias: true,
    alpha: false
  });
  camera = new THREE.PerspectiveCamera(fov, aspect, near, far);
  scene = new THREE.Scene;
  scene.add(camera);
  camera.position.z = 750;
  scene.fog = new THREE.FogExp2(0x251d15, 0.0018);
  renderer.setSize(width, height);
  renderer.setClearColor(0x050505, 1);
  canvas = renderer.domElement;
  canvas.style.width = '100%';
  canvas.style.height = '100%';
  canvas.style.position = 'absolute';
  canvas.style.left = '0px';
  canvas.style.top = '0px';
  progress = {
    items: []
  };
  progressBarLength = 300;
  getResource = function(url) {
    return Q.Promise(function(resolve, reject, notify) {
      var req;
      req = new XMLHttpRequest();
      req.onload = function(event) {
        if (req.status !== 200) {
          return reject(new Error('failed to load ' + url));
        }
      };
      req.onerror = function(event) {
        return reject(new Error('failed to load ' + url));
      };
      req.onprogress = function(event) {
        if (event.lengthComputable) {
          return notify([event.loaded, event.total]);
        }
      };
      req.onreadystatechange = function(event) {
        if (req.readyState === 4) {
          return resolve(JSON.parse(req.responseText));
        }
      };
      req.open('GET', url, true);
      return req.send();
    });
  };
  return Q.all(['/earth', '/visitors'].map(function(url) {
    return getResource(url);
  })).then(function(_arg) {
    var animate, city, country, earth, elem, geometry, labelGeom, labelLine, labelMat, landMasses, ll, material, me, onResize, particles, persons, polygon, position, projector, radianRatio, radius, region, text, toLatitude, toLongitude, transform, updateLocation, vertex, visitors, _i, _j, _k, _len, _len1, _len2, _ref;
    earth = _arg[0], visitors = _arg[1];
    document.body.appendChild(canvas);
    radianRatio = Math.PI / 180;
    radius = 300;
    toLongitude = new THREE.Matrix4;
    toLatitude = new THREE.Matrix4;
    transform = function(longitude, latitude) {
      var vector;
      vector = new THREE.Vector3(0.0, 0.0, radius);
      toLongitude.makeRotationY(longitude * radianRatio);
      toLatitude.makeRotationX(-latitude * radianRatio);
      vector.applyMatrix4(toLatitude);
      vector.applyMatrix4(toLongitude);
      return vector;
    };
    landMasses = [];
    for (_i = 0, _len = earth.length; _i < _len; _i++) {
      polygon = earth[_i];
      material = new THREE.LineBasicMaterial({
        color: 0xffffff
      });
      geometry = new THREE.Geometry;
      for (_j = 0, _len1 = polygon.length; _j < _len1; _j++) {
        vertex = polygon[_j];
        geometry.vertices.push(transform(vertex[0], vertex[1]));
      }
      landMasses.push(polygon = new THREE.Line(geometry, material));
      scene.add(polygon);
    }
    persons = [];
    updateLocation = function(person) {
      var adjustHeight, adjustWidth, x, y;
      vertex = person.line.geometry.vertices[1].clone();
      vertex.applyMatrix4(person.line.matrixWorld);
      projector.projectVector(vertex, camera);
      x = (vertex.x + 1) / 2 * window.innerWidth;
      y = -(vertex.y - 1) / 2 * window.innerHeight;
      adjustHeight = 10;
      adjustWidth = person.text.length * 2;
      x -= adjustWidth;
      y -= adjustHeight;
      person.elem.style.top = "" + y + "px";
      return person.elem.style.left = "" + x + "px";
    };
    material = new THREE.ParticleBasicMaterial({
      color: 0xaaaaaa,
      size: 4,
      fog: false
    });
    geometry = new THREE.Geometry;
    particles = new THREE.ParticleSystem(geometry, material);
    projector = new THREE.Projector;
    scene.add(particles);
    for (_k = 0, _len2 = visitors.length; _k < _len2; _k++) {
      _ref = visitors[_k], country = _ref.country, region = _ref.region, city = _ref.city, ll = _ref.ll, me = _ref.me;
      position = transform(ll[1], ll[0]);
      if (true) {
        labelGeom = new THREE.Geometry;
        labelMat = new THREE.LineBasicMaterial({
          color: 0xffffff
        });
        labelGeom.vertices.push(position);
        labelGeom.vertices.push(position.clone().multiplyScalar(1.3));
        scene.add(labelLine = new THREE.Line(labelGeom, labelMat));
        text = "" + city + ", " + country;
        elem = document.createElement('div');
        elem.innerHTML = text;
        document.body.appendChild(elem);
        elem.style.position = 'absolute';
        elem.style.color = '#cccccc';
        elem.style['font-size'] = 'xx-small';
        elem.style.top = '0px';
        elem.style.left = '0px';
        persons.push({
          line: labelLine,
          text: text,
          elem: elem
        });
      }
      geometry.vertices.push(position);
    }
    onResize = function() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      camera.aspect = canvas.width / canvas.height;
      camera.updateProjectionMatrix();
      return renderer.setSize(canvas.width, canvas.height);
    };
    onResize();
    window.addEventListener('resize', onResize);
    animate = function() {
      var person, _l, _len3, _len4, _m;
      stats.begin();
      try {
        requestAnimationFrame(animate);
      } catch (_error) {}
      renderer.render(scene, camera);
      for (_l = 0, _len3 = landMasses.length; _l < _len3; _l++) {
        polygon = landMasses[_l];
        polygon.rotation.x += rotationX;
        polygon.rotation.y += rotationY;
      }
      particles.rotation.x += rotationX;
      particles.rotation.y += rotationY;
      for (_m = 0, _len4 = persons.length; _m < _len4; _m++) {
        person = persons[_m];
        person.line.rotation.x += rotationX;
        person.line.rotation.y += rotationY;
        updateLocation(person);
      }
      return stats.end();
    };
    return animate();
  }, function(error) {
    return console.log({
      error: error
    });
  }, function(notify) {
    var doneLength, item, _i, _len, _ref;
    progress.items[notify.index] = notify.value;
    progress.total = 0;
    progress.done = 0;
    _ref = progress.items;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item == null) {
        continue;
      }
      progress.total += item[1];
      progress.done += item[0];
    }
    doneLength = progressBarLength * progress.done / progress.total;
    return document.getElementById('progress').style.width = doneLength + 'px';
  });
});
