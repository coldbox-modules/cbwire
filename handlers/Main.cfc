component {

    property name="cbwireManager" inject="CBWireManager@cbwire";

	property name="cbwireRequest" inject="CBWireRequest@cbwire";

    /**
     * Primary entry point for cbwire requests after
     * initial component rendering.
     *
     * Currently uses /livewire URI to support LivewireJS.
     *
     * URI: /livewire/messages/:component
     */
    function index( event, rc, prc ){

        var component = cbwireManager.getComponentInstance( rc.wireComponent );

        return variables.cbwireRequest.handle( component );
    }

}
