component extends="cbwire.models.v4.Component" {

    data = {
        "start": 10,
        "response": ""
    };

    function startStream() {
        while( data.start >= 0 ) {
            stream( "count", data.start, true );
            data.start--;
            sleep( 1000 );
        }

    }
}