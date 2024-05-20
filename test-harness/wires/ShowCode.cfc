component extends="cbwire.models.Component" {

    data = [
        "component": ""
    ];

    function onMount( params ) {
        data.component = params.wire;
    }
}