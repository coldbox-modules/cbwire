component extends="cbwire.models.Component" {

    variables.data = {
        "timestamp": now()
    };

    function getTimestamp(){
        return now() & "what!";
    }

    function renderIt(){
        return this.renderView( "_wires/poll" );
    }

}
