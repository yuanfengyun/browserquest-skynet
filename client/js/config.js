
define(['text!../config/config_build.json'],
function(build) {
    var config = {
        build: JSON.parse(build)
    };
    
    return config;
});