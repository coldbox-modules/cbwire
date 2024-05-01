component extends="cbwire.models.Component" {
    
    data = {
        "ran": false
    };

    function runTeleport() {
        data.ran = true;
    }
}