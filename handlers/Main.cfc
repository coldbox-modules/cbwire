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
     * URI: /livewire/upload-file
     */
    function uploadFile( event, rc, prc ) {
        return cbwireService.handleFileUpload( event, rc, prc );
    }

    /**
     * Endpoint for previewing file uploads
     * 
     * URI: /livewire/previe-file/:uploadUUID
     */
    function previewFile( event, rc, prc ) {
        return cbwireService.handlePreviewFile( event, rc, prc );
    }

}
