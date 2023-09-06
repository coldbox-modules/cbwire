component extends="cbwire.models.Component" {

    listeners = {
        "onSuccess": "someMethod"
    };

    data = {
        "name": "Grant",
        "mounted": false,
        "hydrated": false,
        "updated": false,
        "listener": false
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

    function onUpdate() {
        data.updated = true;
    }

    function emitEventWithoutArgs() {
        emit( "Event1" );
    }

    function emitEventWithOneArg() {
        emit( "Event1", "someArg" );
    }

    function emitEventWithManyArgs() {
        emit( "Event1", [ "arg1", "arg2", "arg3" ] );
    }
    
    function emitSelfEventWithoutArgs() {
        emitSelf( "Event1" );
    }

    function emitSelfEventWithOneArg() {
        emitSelf( "Event1", "someArg" );
    }

    function emitSelfEventWithManyArgs() {
        emitSelf( "Event1", [ "arg1", "arg2", "arg3" ] );
    }

    function emitUpEventWithoutArgs() {
        emitUp( "Event1" );
    }

    function emitUpEventWithOneArg() {
        emitUp( "Event1", "someArg" );
    }

    function emitUpEventWithManyArgs() {
        emitUp( "Event1", [ "arg1", "arg2", "arg3" ] );
    }

    function emitToEventWithoutArgs() {
        emitTo( "Component2", "Event1" );
    }

    function emitToEventWithOneArg() {
        emitTo( "Component2", "Event1", "someArg" );
    }

    function emitToEventWithManyArgs() {
        emitTo( "Component2", "Event1", [ "arg1", "arg2", "arg3" ] );
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

    function someMethod() {
        data.listener = true;
    }
}