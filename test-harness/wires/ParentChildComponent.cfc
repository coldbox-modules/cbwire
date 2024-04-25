component extends="cbwire.models.v4.Component" {
    data = {
        "name": "Grant",
        "toggle": true
    };

    function toggleComps() {
        toggle = !toggle;
    }

    function reload() {
        refresh();
    }
}