component {
    /**
     * Primary entry point for cbwire subsequent requests.
     *
     * Currently uses /livewire URI to support Livewire JS.
     *
     * URI: /livewire/messages/:wireComponent
     */
    function index( event, rc, prc ){
        announce( "onCBWireSubsequentRequest" );
        return event.getValue( "_cbwire_subsequent_memento" );
    }

    /**
     * Endpoint for file uploads
     * 
     * URI: /livewire/messages/upload-file
     */
    function uploadFile( event, rc, prc ) {
        announce( "onCBWireFileUpload" );
        return event.getValue( "_cbwire_file_upload_memento" );
    }

}
