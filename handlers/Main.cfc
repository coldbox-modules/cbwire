component {

    property name="cbwireController" inject="CBWIREController@cbwire";

    /**
     * Primary entry point for cbwire requests.
     *
     * URI: /cbwire/update
     */
    function index( event, rc, prc ){
        try {
            return cbwireController.handleRequest( getHTTPRequestData(), arguments.event );
        } catch ( any e ) {
            if ( e.message contains "Page expired" ) {
                event.noLayout();
                event.setView( view="errors/pageExpired", module="cbwire" );
                event.setHTTPHeader( statusCode="419", statusText="Page Expired" );
            } else {
                rethrow;
            }
        }
    }

    /**
     * Endpoint for file uploads
     * 
     * URI: /cbwire/upload-file
     */
    function uploadFile( event, rc, prc ) {
        return cbwireController.handleFileUpload( getHTTPRequestData(), event );
    }

    /**
     * Endpoint for previewing file uploads
     * 
     * URI: /cbwire/preview-file/:uploadUUID
     */
    function previewFile( event, rc, prc ) {
        return cbwireController.handleFilePreview( getHTTPRequestData(), event );
    }

}
