component extends="cbwire.models.Component" {

    data = {
        "timestamp": now()
    };

    function getTimestamp(){
        return now() & "what!";
    }

    function onRender(){
        return this.renderView( "wires/poll" );
    }

}
