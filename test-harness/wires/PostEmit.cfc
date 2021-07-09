component extends="cbwire.models.Component" {

    variables.data = { "message" : "" };

    function emitEvent(){
        this.$emit( "SomeEvent" );
    }

    function $postEmit( eventName, parameters ){
        variables.data.message = "Called $postEmit for event '#arguments.eventName#'!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/postEmit" );
    }

}
