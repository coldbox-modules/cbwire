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

}
