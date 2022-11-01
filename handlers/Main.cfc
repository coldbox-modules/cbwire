component {

    property name="cbwireManager" inject="CBWireManager@cbwire";

    /**
     * Primary entry point for cbwire requests.
     *
     * Currently uses /livewire URI to support Livewire JS.
     *
     * URI: /livewire/messages/:wireComponent
     */
    function index( event, rc, prc ){
        return cbwireManager.handleIncomingRequest( event, rc, prc );
    }

    /**
     * Endpoint for file uploads
     * 
     * URI: /livewire/upload-file
     */
    function uploadFile( event, rc, prc ) {
        return cbwireManager.handleFileUpload( event, rc, prc );
    }

    /**
     * Endpoint for previewing file uploads
     * 
     * URI: /livewire/previe-file/:uploadUUID
     */
    function previewFile( event, rc, prc ) {
        return cbwireManager.handlePreviewFile( event, rc, prc );
    }

}
