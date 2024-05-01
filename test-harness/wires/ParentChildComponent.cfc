component extends="cbwire.models.Component" {
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