component extends="cbwire.models.Component"{

    // Data Properties
    data = {
        "message": "This is the default template",
        "showButton": false
    };

    // Computed properties
    computed = {
        "counter": function() { return 0; }
    };

    // Listeners
    listeners = {
        "fooEvent": "fooEventCalled"
    };

    // Actions
    function foo( bar = false ) {
        if ( arguments.bar ) {
            data.message = "Foo called with params";
        } else {
            data.message = "Foo called";
        }
    }

    function fooEventCalled( name ){
        if ( !isNull( name ) ){
            data.message = "Foo event called by #name#";
        } else {
            data.message = "Foo event called";
        }
    }
}