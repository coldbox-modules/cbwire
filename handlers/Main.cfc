component {

    property name="cbwireService" inject="CBWireService@cbwire";

    /**
     * Primary entry point for cbwire requests.
     *
     * Currently uses /livewire URI to support Livewire JS.
     *
     * URI: /livewire/messages/:wireComponent
     */
    function index( event, rc, prc ){
        return getInstance( "IncomingRequest@cbwire" ).handle( event, rc, prc );
    }

    /**
     * Endpoint for file uploads
     * 
     * URI: /livewire/upload-file
     */
    function uploadFile( event, rc, prc ) {
        return getInstance( "IncomingFileUpload@cbwire" ).handle( event, rc, prc );
    }

    /**
     * Endpoint for previewing file uploads
     * 
     * URI: /livewire/preview-file/:uploadUUID
     */
    function previewFile( event, rc, prc ) {
        return getInstance( "IncomingFilePreview@cbwire" ).handle( event, rc, prc );
    }

}
