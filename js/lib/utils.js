var Utils = {
    isNullOrUndefined: function(obj) {
        if(typeof obj === "undefined" || obj === null) {
            return true;
        }
        else {
            return false;
        }
    },
    isNullOrEmpty: function(s) {
        if(s === null || s === "") {
            return true;
        }
        else {
            return false;
        }
    },
    isClose: function(v1, v2, d) {
        if(typeof d === "undefined" || d === null) {
            d = 0.01;
        }
        var r = v1.distanceToSquared(v2);
        if(v1.distanceToSquared(v2) <= d) {
            return true;
        }
        else {
            return false;
        }
    },
    screenXY: function(vec3, camera, dimensions) {
    	var vector = vec3.project(camera);
    	var result = new Object();
    	result.x = vector.x * (dimensions.width);
    	result.y = -(0-vector.y) * (dimensions.height);

    	return result;
    }
};


Number.prototype.clamp = function(min, max) {
    return Math.min(Math.max(this, min), max);
  };

  Number.prototype.scale = function(inputHigh, inputLow, outputHigh, outputLow) {
    return ((this - inputLow) / (inputHigh - inputLow)) * (outputHigh - outputLow) + outputLow;
  };