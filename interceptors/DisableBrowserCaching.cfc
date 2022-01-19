component {

    function preProcess( event, rc, prc ) eventPattern="cbwire.*"{
        event.setHTTPHeader( name="Pragma", value="no-cache" );
        event.setHTTPHeader( name="Expires", value="Fri, 01 Jan 1990 00:00:00 GMT" );
        event.setHTTPHeader( name="Cache-Control", value="no-cache, must-revalidate, no-store, max-age=0, private" );
    }
}