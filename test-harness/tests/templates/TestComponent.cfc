component extends="cbwire.models.Component" {

    property name="CBWIREService" inject="CBWIREService@cbwire";

    constraints = {
        "email" = { required : true }
    };

    queryString = [ "name" ];

    listeners = {
        "onSuccess": "someMethod"
    };

    data = {
        "name": "Grant",
        "email": "",
        "mounted": false,
        "hydrated": false,
        "updated": false,
        "listener": false,
        "onDIComplete": false,
        "getInstance": false,
        "validateOrFail": false,
        "validate": false,
        "myFile": "",
        "sum": 0
    };

    computed = {
        "fivePlusFive": function() {
            return 5 + 5;
        },
        "getTick": function() {
            sleep( 10 );
            var data.tickCount = getTickCount();
            return data.tickCount;
        }
    }

    function onDIComplete() {
        data.onDIComplete = true;
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

    function callGetInstance() {
        getInstance( "CBWIREService@cbwire" );
        data.getInstance = true;
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

    function doNotRender() {
        noRender();
    }

    function redirectToURI() {
        return relocate( uri="/some-url" );
    }

    function redirectToURL() {
        return relocate( uri="https://www.google.com" );
    }

    function redirectToEvent(){
        return relocate( event="examples.index" );
    }

    function redirectWithFlash() {
        relocate( event="examples.index", persistStruct={
            confirm: "Redirect successful"
        } );
    }

    function runValidateFailure() {
        validateOrFail();
        data.validateOrFail = true;
    }

    function runValidate() {
        var result = validate();

        if ( result.hasErrors() ) {
            data.validate = true;
        }
    }

    function runValidateSuccess() {
        data.email = 'user@domain.com';
        validateOrFail();
        data.validateOrFail = true;
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

    function actionWithComputedProperty() {
        data.sum = computed.fivePlusFive();
    }

    function actionWithRefresh() {
        refresh();
    }
}