component extends="cbwire.models.Component" {

    variables.data = { "message" : "test" };

    variables.$listeners = { "someOtherEvent" : "someListener" };

    function someListener(){
        variables.data.message = "We have fired someListener() from a listener!";
    }

    function someAction(){
        this.$emit( "someOtherEvent", [ "grant", "allen", "copley" ] );
    }

    function $renderIt(){
        return this.$renderView( "_wires/fireEvent" );
    }

}
