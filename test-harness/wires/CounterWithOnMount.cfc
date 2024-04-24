component extends="Counter" {

    function onMount( event, rc, prc, params ) {
        count = params.count;
        event.getValue( "test", "" );
        if ( !isStruct( arguments.rc ) ) {
            throw( "rc is not a struct" );
        }
        if ( !isStruct( arguments.prc ) ) {
            throw( "prc is not a struct" );
        }
    }
}