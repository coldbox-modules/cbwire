component extends="cbwire.models.Component" {

    data = {
        "loop": 1,
        "seconds": 5
    };

    function incrementLoop() {
        data.loop += 1;
    }
}