component extends="cbwire.models.Component" {

    data = {
        "hydrated": false,
        "hydratedProperty": false
    };

    function clicked() {}

    function onHydrate() {
        data.hydrated = true;
    }

    function onHydrateHydrated(){
        data.hydratedProperty = true;
    }

}