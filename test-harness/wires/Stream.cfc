component extends="cbwire.models.Component" {

    data = {
        "finished": false
    };

    function start() {
        stream( "response", "Fetching report data...", true );
        sleep( 3000 );
        stream( "response", "Inspecting for errors...", true );
        sleep( 3000 );
        stream( "response", "Parsing records...", true );
        sleep( 3000 );
        data.finished = true;
    }
}