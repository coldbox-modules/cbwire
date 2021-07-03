component extends="cbwire.models.Component" {

    this.$data = {
        "message": "test"
    };

    this.$listeners = { "someOtherEvent" : "someListener" };


    function someListener(){
        this.$data.message = "We have fired someListener() from a listener!";
    }

    function someAction(){
        this.$emit( "someOtherEvent" );
    }

    function $renderIt(){
        return this.$renderView( "_wires/fireEvent" );
    }

}
