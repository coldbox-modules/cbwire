component {

	property name="wireRequest" inject="WireRequest@cbWire";

    /**
     * Primary entry point for subsequent wire requests after
     * initial component rendering
     *
     * Currently uses /livewire URI to support LivewireJS.
     *
     * URI: /livewire/messages/:component
     */
    function index( event, rc, prc ){
        return variables.wireRequest.handleSubsequentRequest( arguments.rc );
    }

}
