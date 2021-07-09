component extends="cbwire.models.Component" {

    variables.data[ "message" ] = "test";

    variables.$listeners = { "someEvent" : "someListener" };

    function someAction(){
        this.$emit( "someEvent" );
    }

    function someListener(){
        variables.data.message = "We have fired someListener() from a second listener!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/fireEvent" );
    }

}
