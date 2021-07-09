component {

    /**
     * Primary entry point for subsequent wire requests after
     * initial component rendering
     *
     * Currently uses /livewire URI to support LivewireJS.
     *
     * URI: /livewire/messages/:component
     */
    function index( event, rc, prc ){
        return variables.wirebox
            .getInstance( "cbwire.models.WireRequest" )
            .withComponent( arguments.rc.wireComponent )
            .hydrate()
            .$getMemento();
    }

}
