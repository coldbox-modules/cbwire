component extends="cbwire.models.Component" {

    listeners = {
        "onSuccess": "someMethod"
    };

    data = {
        "name": "Grant",
        "mounted": false,
        "hydrated": false
    };

    computed = {
        "fivePlusFive": function() {
            return 5 + 5;
        }
    }

    function onMount( parameters, rc, prc ) {
        data.mounted = true;
    }

    function onHydrate() {
        data.hydrated = true;
    }

    function names() {
        return [
            "Luis",
            "Esme",
            "Michael"
        ];
    }

    function changeDataProperty() {
        data.name = 'Something else';
    }
}