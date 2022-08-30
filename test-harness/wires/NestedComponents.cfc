component extends="cbwire.models.Component" {

    data = {
        "clicked": false
    };

    function click() {
        data.clicked = true;
    }
}