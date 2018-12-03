var electron = require('electron');
var currentWindow = electron.remote.getCurrentWindow();

var settings = {
    release: false,
    sync: true
};

var size = {
    width: currentWindow.getSize()[0],
    height: currentWindow.getSize()[1],
};

var Sync = function() {
    this.BPM = 91,
    this.ROWS_PER_BEAT = 8,
    this.ROW_RATE = this.BPM / 60 * this.ROWS_PER_BEAT,
    this.musicReady = false,
    this.music = new Audio(),
    this.device = new JSRocket.SyncDevice(),
    this.row = 0,
    this.previousRow = 0,
    this.tracks = {
        _tracks: {},
        init: function(device) {        
            this._tracks.logo = {
                name: "logo",
                position : {
                    x: device.getTrack("logo.position.x"),
                    y: device.getTrack("logo.position.y")
                },
                waves : {
                    value: device.getTrack("logo.waves"),
                },
                speed : {
                    value: device.getTrack("logo.speed"),
                },
                amplitude : {
                    value: device.getTrack("logo.amplitude"),
                },
                scopeAndLogo : {
                    value: device.getTrack("logo.scope"),
                }
            };
            this._tracks.scope = {
                name: "scope",
                color : {
                    r: device.getTrack("scope.color.r"),
                    g: device.getTrack("scope.color.g"),
                    b: device.getTrack("scope.color.b"),
                },
                speed : {
                    value: device.getTrack("scope.speed"),
                },
                amplitude : {
                    value: device.getTrack("scope.amplitude"),
                },
                frequency : {
                    value: device.getTrack("scope.frequency"),
                },
                trail : {
                    value: device.getTrack("scope.trail"),
                }
            };
            this._tracks.camera = {
                name: "camera",
                position : {
                    x: device.getTrack("camera.position.x"),
                    y: device.getTrack("camera.position.y"),
                    z: device.getTrack("camera.position.z")
                },
                look : {
                    x: device.getTrack("camera.look.x"),
                    y: device.getTrack("camera.look.y"),
                    z: device.getTrack("camera.look.z")
                },
                lightPosition : {
                    x: device.getTrack("camera.light.position.x"),
                    y: device.getTrack("camera.light.position.y"),
                    z: device.getTrack("camera.light.position.z")
                },
                maxSteps: {
                    value: device.getTrack("camera.maxSteps")
                },
                threshold: {
                    value: device.getTrack("camera.threshold")
                },

            };    
            this._tracks.scene1 = {
                name: "scene1",
                rotation : {
                    value: device.getTrack("scene1.rotation")
                },
                detail : {
                    value: device.getTrack("scene1.detail"),
                },
                modifier : {
                    x: device.getTrack("scene1.modifier.x"),
                    y: device.getTrack("scene1.modifier.y"),
                }

            }; 
            this._tracks.scene2 = {
                name: "scene2",
                position : {
                    x: device.getTrack("scene2.position.x"),
                    y: device.getTrack("scene2.position.y"),
                    z: device.getTrack("scene2.position.z"),
                },
                fractal : {
                    value: device.getTrack("scene2.fractal"),
                },
                torus : {
                    value: device.getTrack("scene2.torus"),
                },
                union : {
                    value: device.getTrack("scene2.union"),
                }
            };   
            this._tracks.scene3 = {
                name: "scene3",
                rotation : {
                    x: device.getTrack("scene3.rotation.x"),
                    y: device.getTrack("scene3.rotation.y"),
                    z: device.getTrack("scene3.rotation.z")
                }
            };
            this._tracks.scene4 = {
                name: "scene4",
                position : {
                    x: device.getTrack("scene4.bulb.position.x"),
                    y: device.getTrack("scene4.bulb.position.y"),
                    z: device.getTrack("scene4.bulb.position.z")
                },
                rotation : {
                    x: device.getTrack("scene4.bulb.rotation.x"),
                    y: device.getTrack("scene4.bulb.rotation.y"),
                    z: device.getTrack("scene4.bulb.rotation.z")
                },
                detail : {
                    x: device.getTrack("scene4.bulb.detail.x"),
                    y: device.getTrack("scene4.bulb.detail.y")
                },
                border : {
                    value: device.getTrack("scene4.bulb.border")
                },

            }; 
            this._tracks.scene5 = {
                name: "scene5",
                detail : {
                    x: device.getTrack("scene5.detail.x"),
                    y: device.getTrack("scene5.detail.y"),
                    z: device.getTrack("scene5.detail.z"),
                    w: device.getTrack("scene5.detail.w")
                }
            }; 
            this._tracks.scene6 = {
                name: "scene6",
                rotation : {
                    value: device.getTrack("scene6.rotation")
                },
                balls : {
                    value: device.getTrack("scene6.balls"),
                }
            }; 
            this._tracks.common = {
                name: "common",
                time : {
                    value: device.getTrack("common.time"),
                },
                alpha : {
                    value: device.getTrack("common.alpha"),
                },
                scene : {
                    value: device.getTrack("common.scene"),
                },
                oldTV : {
                    value: device.getTrack("common.oldTV"),
                },
                interfereFrequency: {
                    value: device.getTrack("common.interfereFrequency"),
                },
                interfereAmplitude: {
                    value: device.getTrack("common.interfereAmplitude"),
                },
                interfereToggle: {
                    value: device.getTrack("common.interfereToggle"),
                },
                interfereTime: {
                    value: device.getTrack("common.interfereTime"),
                },
                interfereTrail: {
                    value: device.getTrack("common.interfereTrail"),
                },
                interfereColor : {
                    r: device.getTrack("common.interfereTime.r"),
                    g: device.getTrack("common.interfereTime.g"),
                    b: device.getTrack("common.interfereTime.b")
                }
            };
                
        },
        get: function(name, row) {
            var track = this._tracks[name];
            if(track.name == "logo") {
                return {
                    position: {
                        x: track.position.x.getValue(row) || 0,
                        y: track.position.y.getValue(row) || 0
                    },
                    waves: {
                        value: track.waves.value.getValue(row) || 0
                    },
                    speed: {
                        value: track.speed.value.getValue(row) || 0
                    },
                    amplitude: {
                        value: track.amplitude.value.getValue(row) || 0
                    },
                    scopeAndLogo: {
                        value: track.scopeAndLogo.value.getValue(row) || 0
                    },
                }
            }
            else if(track.name == "scope") {
                return {
                    color: {
                        r: track.color.r.getValue(row) || 0,
                        g: track.color.g.getValue(row) || 0,
                        b: track.color.b.getValue(row) || 0,
                    },
                    speed: {
                        value: track.speed.value.getValue(row) || 0
                    },
                    amplitude: {
                        value: track.amplitude.value.getValue(row) || 0
                    },
                    trail: {
                        value: track.trail.value.getValue(row) || 0
                    },
                    frequency: {
                        value: track.frequency.value.getValue(row) || 0
                    }
                }
            }
            else if(track.name == "camera") {
                return {
                    position: {
                        x: track.position.x.getValue(row) || 0,
                        y: track.position.y.getValue(row) || 0,
                        z: track.position.z.getValue(row) || 0
                    },
                    look: {
                        x: track.look.x.getValue(row) || 0,
                        y: track.look.y.getValue(row) || 0,
                        z: track.look.z.getValue(row) || 0
                    },
                    lightPosition: {
                        x: track.lightPosition.x.getValue(row) || 0,
                        y: track.lightPosition.y.getValue(row) || 0,
                        z: track.lightPosition.z.getValue(row) || 0
                    },
                    maxSteps: {
                        value: track.maxSteps.value.getValue(row) || 0
                    },
                    threshold: {
                        value: track.threshold.value.getValue(row) || 0
                    }
                }
            }
            else if(track.name == "scene1") {
                return {
                    rotation: {
                        value: track.rotation.value.getValue(row) || 0
                    },
                    detail: {
                        value: track.detail.value.getValue(row) || 0
                    },
                    modifier: {
                        x: track.modifier.x.getValue(row) || 0,
                        y: track.modifier.y.getValue(row) || 0
                    }
                }
            }
            else if(track.name == "scene2") {
                return {
                    position: {
                        x: track.position.x.getValue(row) || 0,
                        y: track.position.y.getValue(row) || 0,
                        z: track.position.z.getValue(row) || 0,
                    },
                    fractal: {
                        value: track.fractal.value.getValue(row) || 0
                    },
                    torus: {
                        value: track.torus.value.getValue(row) || 0
                    },
                    union: {
                        value: track.union.value.getValue(row) || 0
                    }
                }
            }
            else if(track.name == "scene3") {
                return {
                    rotation: {
                        x: track.rotation.x.getValue(row) || 0,
                        y: track.rotation.y.getValue(row) || 0,
                        z: track.rotation.z.getValue(row) || 0,
                    }
                }
            }
            else if(track.name == "scene4") {
                return {
                    position: {
                        x: track.position.x.getValue(row) || 0,
                        y: track.position.y.getValue(row) || 0,
                        z: track.position.z.getValue(row) || 0,
                    },
                    rotation: {
                        x: track.rotation.x.getValue(row) || 0,
                        y: track.rotation.y.getValue(row) || 0,
                        z: track.rotation.z.getValue(row) || 0,
                    },
                    detail: {
                        x: track.detail.x.getValue(row) || 0,
                        y: track.detail.y.getValue(row) || 0
                    },
                    border: {
                        value: track.border.value.getValue(row) || 0
                    },
                }
            }
            else if(track.name == "scene5") {
                return {
                    detail: {
                        x: track.detail.x.getValue(row) || 0,
                        y: track.detail.y.getValue(row) || 0,
                        z: track.detail.z.getValue(row) || 0,
                        w: track.detail.w.getValue(row) || 0,
                    }
                }
            }
            else if(track.name == "scene6") {
                return {
                    rotation: {
                        value: track.rotation.value.getValue(row) || 0
                    },
                    balls: {
                        value: track.balls.value.getValue(row) || 0
                    }
                }
            }
            else if(track.name == "common") {
                return {
                    time: {
                        value: track.time.value.getValue(row) || 0
                    },
                    alpha: {
                        value: track.alpha.value.getValue(row) || 0
                    },
                    scene: {
                        value: track.scene.value.getValue(row) || 0
                    },
                    oldTV: {
                        value: track.oldTV.value.getValue(row) || 0
                    },
                    interfereFrequency: {
                        value: track.interfereFrequency.value.getValue(row) || 0
                    },
                    interfereAmplitude: {
                        value: track.interfereAmplitude.value.getValue(row) || 0
                    },
                    interfereToggle: {
                        value: track.interfereToggle.value.getValue(row) || 0
                    },
                    interfereTime: {
                        value: track.interfereTime.value.getValue(row) || 0
                    },
                    interfereTrail: {
                        value: track.interfereTrail.value.getValue(row) || 0
                    },
                    interfereColor: {
                        r: track.interfereColor.r.getValue(row) || 0,
                        g: track.interfereColor.g.getValue(row) || 0,
                        b: track.interfereColor.b.getValue(row) || 0,
                    },
                }
            }
    
        }
    },

    this.prepare = function() {
        if(settings.release) {
            this.device.setConfig({
                rocketXML: "assets/music/bogdan.rocket"
            });
            this.device.init("demo");
        }
        else {
            this.device.setConfig({
                socketURL:'ws://localhost:1339'
            });
            this.device.init();
        }
   
        this.device.on("ready", this.ready.bind(this));
        this.device.on("update", this.update.bind(this));
        this.device.on("play", this.play.bind(this));
        this.device.on("pause", this.pause.bind(this));
    },

    this.loadMusic = function() {
        this.music.src = "assets/music/Snow.mp3",
        this.music.load();
        this.music.preload = true;
        this.music.addEventListener("canplay", this.canPlay.bind(this));
    },

    this.canPlay = function() {
        if(this.musicReady) {
            return;
        }  
        if(settings.release) { 
            render();
            this.music.play();
        } else {
            this.music.pause();
            this.music.currentTime = sync.row / sync.ROW_RATE;
        }
        this.musicReady = true;
       
    },
    this.ready = function() {
        this.tracks.init(this.device);
        //this.loadMusic();
    },
    this.update = function(row) {
        if (!isNaN(row)) {
            this.row = row;
            this.music.currentTime = this.row / this.ROW_RATE;
        }
        render();
    },
    this.play = function() {
        this.music.currentTime = this.row / this.ROW_RATE;
        this.music.play();
        render();
    },
    this.pause = function() {
        this.row = this.music.currentTime * this.ROW_RATE;
        window.cancelAnimationFrame(render, document);
        this.music.pause();
    }
};



var sync = new Sync();


var gl = null;
var program = null;
var buffer = null;
var uniforms = {
    alpha: 0.0,
    scene: 1,
    resolution: [0.0, 0.0],
    time: 0.0,
    oldTV: 0.0,
    logoWaves: 0.0,
    logoSpeed: 0.0,
    logoPosition: [0.0, 0.0],
    logoAmplitude: 0.0,
    scopeColor: [0.0, 0.0, 0.0],
    scopeFrequency: 0.0,
    scopeTrail: 0.0,
    scopeSpeed: 0.0,
    scopeAmplitude: 0.0,
    scopeAndLogo: 0.0,
    rayCameraPosition: [0.0, 0.0, 0.0],
    rayCameraLookAt: [0.0, 0.0, 0.0],
    rayMaxSteps: 0.0,
    rayThreshold: 0.0,
    lightPosition: [0.0, 0.0, 0.0],
    scene2Fractal: 0.0,
    scene2Torus: 0.0,
    scene2Position: [0.0, 0.0, 0.0],
    scene2Union: 0.0,
    scene3Rotation:[0.0, 0.0, 0.0],
    scene1Rotation: 0.0,
    scene1Detail: 0.0,
    scene1Modifier: 0.0
};

var textures = null;

var shaders = {};

shaders["vertex"] = {
    url: "assets/shaders/vertex.glsl",
    content: ""
};
shaders["fragment"] = {
    url: "assets/shaders/fragment.glsl",
    content: ""
};

function initialize() {
    for(var name in shaders) {
        var shader = shaders[name];
        (function(s) {
            let xhr = new XMLHttpRequest();
            xhr.open("GET", s.url, false);
            xhr.onload = function() {
                s.content = xhr.responseText;           
            };
            xhr.send();    
        }(shader));
        
    }
 
    var c = document.getElementById("c");
    c.width = size.width;
    c.height = size.height;
    
    gl = c.getContext("webgl2");
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    program = twgl.createProgramInfo(gl, [shaders["vertex"].content, shaders["fragment"].content]);
    const arrays = {
        position: [-1, -1, 0, 1, -1, 0, -1, 1, 0, -1, 1, 0, 1, -1, 0, 1, 1, 0],
    };
    buffer = twgl.createBufferInfoFromArrays(gl, arrays);
    uniforms.resolution = [size.width, size.height];

    textures = twgl.createTextures(gl, {
        logo: {
            src: "assets/graphics/TahtiTuho_2.jpg"
        },
        gallo: {
            src: "assets/graphics/gallo2.jpg"
        },
        bogdan: {
            src: "assets/graphics/bogdan_transparent.png"
        }
    });

    uniforms.logo = textures.logo;
    uniforms.gallo = textures.gallo;
    uniforms.bogdan = textures.bogdan;
   

    sync.prepare();
    sync.loadMusic();

}

function render() {
    twgl.resizeCanvasToDisplaySize(gl.canvas);
    gl.viewport(0, 0, size.width, size.height);

    if(sync.music.paused === false) {
        sync.row = sync.music.currentTime * sync.ROW_RATE;
        sync.device.update(sync.row);
    }

    var commonSync = sync.tracks.get("common", sync.row);
    uniforms.alpha = commonSync.alpha.value;
    uniforms.time = commonSync.time.value;
    uniforms.scene = commonSync.scene.value;
    uniforms.oldTV = commonSync.oldTV.value;
    uniforms.interfereFrequency = commonSync.interfereFrequency.value;
    uniforms.interfereAmplitude = commonSync.interfereAmplitude.value;
    uniforms.interfereToggle = commonSync.interfereToggle.value;
    uniforms.interfereTime = commonSync.interfereTime.value;
    uniforms.interfereTrail = commonSync.interfereTrail.value;
    uniforms.interfereColor = [commonSync.interfereColor.r, commonSync.interfereColor.g, commonSync.interfereColor.b];

    var logoSync = sync.tracks.get("logo", sync.row);
    uniforms.logoWaves = logoSync.waves.value;
    uniforms.logoSpeed = logoSync.speed.value;
    uniforms.logoAmplitude = logoSync.amplitude.value;
    uniforms.logoPosition = [logoSync.position.x, logoSync.position.y];
    uniforms.scopeAndLogo = logoSync.scopeAndLogo.value;

    var scopeSync = sync.tracks.get("scope", sync.row);
    uniforms.scopeFrequency = scopeSync.frequency.value;
    uniforms.scopeSpeed = scopeSync.speed.value;
    uniforms.scopeAmplitude = scopeSync.amplitude.value;
    uniforms.scopeColor = [scopeSync.color.r, scopeSync.color.g, scopeSync.color.b];
    uniforms.scopeTrail = scopeSync.trail.value;
    
    var cameraSync = sync.tracks.get("camera", sync.row);
    uniforms.rayCameraLookAt = [cameraSync.look.x, cameraSync.look.y, cameraSync.look.z];
    uniforms.rayCameraPosition = [cameraSync.position.x, cameraSync.position.y, cameraSync.position.z];
    uniforms.lightPosition = [cameraSync.lightPosition.x, cameraSync.lightPosition.y, cameraSync.lightPosition.z];
    uniforms.rayMaxSteps = cameraSync.maxSteps.value;
    uniforms.rayThreshold = cameraSync.threshold.value;
    
    var scene1Sync = sync.tracks.get("scene1", sync.row);
    uniforms.scene1Rotation = scene1Sync.rotation.value;
    uniforms.scene1Detail = scene1Sync.detail.value;
    uniforms.scene1Modifier = [scene1Sync.modifier.x, scene1Sync.modifier.y];

    var scene2Sync = sync.tracks.get("scene2", sync.row);
    uniforms.scene2Fractal = scene2Sync.fractal.value;
    uniforms.scene2Torus = scene2Sync.torus.value;
    uniforms.scene2Union = scene2Sync.union.value;
    uniforms.scene2Position = [scene2Sync.position.x, scene2Sync.position.y, scene2Sync.position.z];
    
    var scene3Sync = sync.tracks.get("scene3", sync.row);
    uniforms.scene3Rotation = [scene3Sync.rotation.x, scene3Sync.rotation.y, scene3Sync.rotation.z];

    var scene4Sync = sync.tracks.get("scene4", sync.row);
    uniforms.scene4BulbPosition = [scene4Sync.position.x, scene4Sync.position.y, scene4Sync.position.z];
    uniforms.scene4BulbRotation = [scene4Sync.rotation.x, scene4Sync.rotation.y, scene4Sync.rotation.z];
    uniforms.scene4BulbDetail = [scene4Sync.detail.x, scene4Sync.detail.y];
    uniforms.scene4BulbBorder = scene4Sync.border.value;

    var scene5Sync = sync.tracks.get("scene5", sync.row);
    uniforms.scene5Detail = [scene5Sync.detail.x, scene5Sync.detail.y, scene5Sync.detail.z, scene5Sync.detail.w];

    var scene6Sync = sync.tracks.get("scene6", sync.row);
    uniforms.scene6Balls = scene6Sync.balls.value;
    uniforms.scene6Rotation = scene6Sync.rotation.value;
 

    /*
    uniforms.prevFrame = twgl.createTexture(gl, {
        src: gl.canvas
    });
    */
    
    gl.useProgram(program.program);
    twgl.setBuffersAndAttributes(gl, program, buffer);
    twgl.setUniforms(program, uniforms);
    twgl.drawBufferInfo(gl, buffer);

    if((settings.release === true)  || (sync.music.paused === false || settings.sync === false)) {
        if(uniforms.time >= 160) {
            currentWindow.close();
        }
        window.requestAnimationFrame(render);
    }
    else {
        window.cancelAnimationFrame(render);
    }
}





