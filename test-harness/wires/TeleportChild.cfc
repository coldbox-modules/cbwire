component extends="cbwire.models.v4.Component" {
    
    data = {
        "ran": false
    };

    function runTeleport() {
        data.ran = true;
    }
}