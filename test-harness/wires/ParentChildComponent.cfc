component extends="cbwire.models.v4.Component" {
    data = {
        "name": "Grant",
        "toggle": true
    };

    function toggleComps() {
        data.toggle = !data.toggle;
    }

    function reload() {
        refresh();
    }
}