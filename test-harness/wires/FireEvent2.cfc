component extends="cbwire.models.Component" {

    this.$data[ "message" ] = "test";

    this.$listeners = { "someEvent" : "someListener" };

    function someAction(){
        this.$emit( "someEvent" );
    }

    function someListener(){
        this.$data.message = "We have fired someListener() from a second listener!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/fireEvent" );
    }

}
