component {

    property name="cbwireController" inject="CBWIREController@cbwire";

    /**
     * Primary entry point for cbwire requests.
     *
     * URI: /cbwire/update
     */
    function index( event, rc, prc ){
        return cbwireController.handleRequest( getHTTPRequestData(), arguments.event );
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
