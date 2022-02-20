component extends="cbwire.models.Component" {

    data = {
        "timestamp": now()
    };

    function getTimestamp(){
        return now() & "what!";
    }

    function renderIt(){
        return this.renderView( "_wires/poll" );
    }

}
