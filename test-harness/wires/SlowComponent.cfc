component extends="cbwire.models.Component" {

    data = [
        "sleepTime": ""
    ];

    function onMount( params ) {
        data.sleepTime = params.sleepTime;
        sleep( params.sleepTime );
    }

    function placeholder() {
        return "<div>Loading...</div>";
    }

    function onRender() {
        return "<div>Loaded after #data.sleepTime# ms</div>";
    }
}