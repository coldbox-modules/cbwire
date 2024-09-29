component extends="cbwire.models.Component" {

    data = { "message" : "" };

    function emitEvent(){
        this.emit( "SomeEvent" );
    }

    function preEmit( eventName, parameters ){
        data.message = "Called preEmit for event '#arguments.eventName#'!";
    }

    function onRender(){
        return this.renderView( "wires/preEmit" );
    }

}
