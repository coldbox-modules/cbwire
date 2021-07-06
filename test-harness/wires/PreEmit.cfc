component extends="cbwire.models.Component" {

    variables.$data = { "message" : "" };

    function emitEvent(){
        this.$emit( "SomeEvent" );
    }

    function $preEmit( eventName, parameters ){
        variables.$data.message = "Called $preEmit for event '#arguments.eventName#'!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/preEmit" );
    }

}
