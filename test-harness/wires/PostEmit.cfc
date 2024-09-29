component extends="cbwire.models.Component" {

    data = { "message" : "" };

    function emitEvent(){
        this.emit( "SomeEvent" );
    }

    function postEmit( eventName, parameters ){
        data.message = "Called postEmit for event '#arguments.eventName#'!";
    }

    function onRender(){
        return this.renderView( "wires/postEmit" );
    }

}
