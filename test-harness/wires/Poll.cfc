component extends="cbwire.models.Component" {

    data = {
        "timestamp": now()
    };

    function getTimestamp(){
        return now() & "what!";
    }

    function renderIt(){
        return this.renderView( "wires/poll" );
    }

}
