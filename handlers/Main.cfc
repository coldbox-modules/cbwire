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

}
