component extends="cbwire.models.Component" {

    property name="jokeService" inject="JokeService";

    data = {
        "joke": ""
    };

    function getJoke() {
        stream( "joke", "", true );
        jokeService.getJoke( function( chunk ) {
            stream( "joke", chunk, false );
        } );
    }
}